extends RefCounted

const Codec = preload("res://gameplay/run/state_codec.gd")
const Catalog = preload("res://prototype_item_catalog.gd")
const WING := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const SCHEMA := 3
var _error := ""

func capture(wing: Node) -> Dictionary:
	if wing.run_identity == null or wing.run_schedule == null or wing.restoring or not wing.get_initialization_error().is_empty():
		return {}
	for request: RefCounted in wing.run_schedule.requests:
		if request.transaction_active: return {}
	var items: Dictionary = {}
	var player := wing.get_node("Player")
	for item: ItemInstance in player.carried_items.get_items():
		_record_item(items, item)
	var registrar := wing.get_node("DevelopmentSetup/SeedRegistrar")
	var hosts: Array = registrar.capture_state()
	for host: Dictionary in hosts:
		_record_item(items, registrar.get_node("../SeedItems").get_node(host.host).get_node("WorldItem").get_item_instance())
	var surfaces: Dictionary = {}
	for surface: Node in wing.get_functional_surfaces():
		surfaces[String(wing.get_path_to(surface))] = surface.capture_state()
		for stack: StorageStack in surface._stacks.values():
			for entry: StorageStack.Entry in stack.entries:
				_record_item(items, entry.item)
	var runtime := wing.get_node("ReceivingRuntime")
	var receiving: Dictionary = runtime.capture_state()
	for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		_record_item(items, world.get_item_instance())
	for batch_state: Dictionary in _batch_states(receiving):
		for entry: Dictionary in batch_state.entries:
			if entry.remaining_in_batch and not items.has(entry.item_instance_id):
				items[entry.item_instance_id] = {"definition": String(entry.definition_id), "contaminated": false}
	return {"schema": SCHEMA, "content": content_fingerprint(), "run": wing.run_identity.capture_state(),
		"clock": wing.run_schedule.clock.capture_state(), "schedule": wing.run_schedule.capture_state(),
		"items": items, "carry": player.carried_items.capture_state(),
		"hosts": hosts, "surfaces": surfaces, "player": player.capture_state(wing), "receiving": receiving}

func _record_item(items: Dictionary, item: ItemInstance) -> void:
	items[item.instance_id] = {"definition": String(item.definition.item_id), "contaminated": item.contaminated}

func content_fingerprint() -> String:
	var physical: Dictionary = {}
	var catalog := load(Catalog.CATALOGUE_PATH) as ItemCatalog
	for definition: ItemDefinition in catalog.definitions:
		physical[String(definition.item_id)] = [definition.bulk, definition.storage_footprint,
			definition.storage_rotation_degrees, definition.can_be_stacked, definition.can_support_stack,
			definition.auto_stack_group, definition.visual_scene.resource_path if definition.visual_scene != null else "", definition.visual_scale]
	return Codec.new().stringify(physical).sha256_text()

func _fields(value: Variant, fields: Dictionary, label: String) -> bool:
	if not value is Dictionary:
		_error = label + " must be a record"
		return false
	for key: String in fields:
		if not value.has(key) or typeof(value[key]) != fields[key]:
			_error = label + ": missing or invalid " + key
			return false
	return true

func validate(state: Dictionary) -> String:
	_error = ""
	if state.get("schema") in [1,2]: return "Prior continuation is incompatible with the M3 scenario; save left untouched. Confirm New Run to replace it."
	if not _fields(state, {"schema":TYPE_INT,"content":TYPE_STRING,"run":TYPE_DICTIONARY,"clock":TYPE_DICTIONARY,"schedule":TYPE_DICTIONARY,
		"items":TYPE_DICTIONARY,"carry":TYPE_DICTIONARY,"hosts":TYPE_ARRAY,"surfaces":TYPE_DICTIONARY,
		"player":TYPE_DICTIONARY,"receiving":TYPE_DICTIONARY}, "Snapshot"): return _error
	if state.schema != SCHEMA: return "Unsupported save schema %s (supported: 3)" % state.schema
	if state.content != content_fingerprint(): return "Save's physical item data is incompatible with this build"
	if not _fields(state.run, {"id":TYPE_STRING,"scenario":TYPE_STRING,"next_sequence":TYPE_INT,"gameplay_seconds":TYPE_FLOAT}, "Run"): return _error
	if state.run.id.length() != 24 or not state.run.id.is_valid_hex_number(false) or state.run.next_sequence < 1 or not is_finite(state.run.gameplay_seconds) or state.run.gameplay_seconds < 0.0:
		return "Unsupported run identity, scenario or logical time"
	var timed = load("res://gameplay/run/timed_state_validation.gd").new()
	var timed_error: String = timed.validate(state)
	if not timed_error.is_empty(): return timed_error
	var spent_ids: Dictionary = {}
	for request: Dictionary in state.schedule.requests:
		for receipt: Dictionary in request.spent: spent_ids[receipt.item_id] = true
	for id: String in state.items:
		if not _fields(state.items[id], {"definition":TYPE_STRING,"contaminated":TYPE_BOOL}, "Item"): return _error
		if id.is_empty() or Catalog.get_definition_by_id(StringName(state.items[id].definition)) == null or state.items[id].definition in ["loot_000034", "loot_000036"]: return "Unsupported item identity/definition"
	var owners: Dictionary = {}
	if not _fields(state.carry, {"slots":TYPE_ARRAY,"selected":TYPE_INT,"max_bulk":TYPE_INT}, "Carrying"): return _error
	var bulk := 0
	for id: Variant in state.carry.slots:
		if not id is String: return "Invalid carrying slot"
		if not id.is_empty():
			if not _claim(id, "carrying", state.items, owners): return _error
			bulk += Catalog.get_definition_by_id(StringName(state.items[id].definition)).bulk
	var selected: int = state.carry.selected
	if state.carry.max_bulk < bulk or state.carry.max_bulk < 1 or (selected == -1 and not owners.is_empty()) or (selected != -1 and (selected < 0 or selected >= state.carry.slots.size() or state.carry.slots[selected].is_empty())):
		return "Invalid carrying selection/capacity"
	var host_names: Dictionary = {}
	for host: Variant in state.hosts:
		if not _fields(host, {"host":TYPE_STRING,"item":TYPE_STRING,"transform":TYPE_TRANSFORM3D}, "Seed host"): return _error
		if host.host.is_empty() or host.host.contains("/") or host_names.has(host.host) or host.item != state.run.id + ":wing_seed_v1:" + host.host: return "Invalid original seed host identity"
		host_names[host.host] = true
		if not _claim(host.item, "seed host", state.items, owners): return _error
	for path: String in state.surfaces:
		if path.contains("..") or path.begins_with("/"): return "Invalid storage owner path"
		var storage_error := _validate_surface(state.surfaces[path], state.items, owners)
		if not storage_error.is_empty(): return path + ": " + storage_error
	var receiving_error := _validate_receiving(state.receiving, state.items, owners, spent_ids)
	if not receiving_error.is_empty(): return receiving_error
	if owners.size() != state.items.size(): return "Unowned physical item in save"
	if not _fields(state.player, {"transform":TYPE_TRANSFORM3D,"camera":TYPE_TRANSFORM3D,"pitch":TYPE_FLOAT,
		"velocity":TYPE_VECTOR3,"ladder":TYPE_STRING,"ladder_yaw":TYPE_FLOAT,"ladder_anchor":TYPE_VECTOR2,"suppressed_ladders":TYPE_ARRAY}, "Player"): return _error
	if state.player.ladder.contains("..") or state.player.ladder.begins_with("/"): return "Invalid ladder reference"
	for path: Variant in state.player.suppressed_ladders:
		if not path is String or path.contains("..") or path.begins_with("/") or path.is_empty(): return "Invalid ladder suppression reference"
	return _validate_allocator(state)

func _validate_allocator(state: Dictionary) -> String:
	var ids: Array = state.items.keys()
	for request: Dictionary in state.schedule.requests:
		ids.append(request.id)
		for receipt: Dictionary in request.spent: ids.append(receipt.item_id)
	for batch: Dictionary in _batch_states(state.receiving): ids.append(batch.batch_id)
	ids.append_array(state.receiving.admission.batch_teams.keys())
	var highest := 0
	for id: String in ids:
		var parts := id.split(":")
		if parts.size() >= 3 and parts[0] == state.run.id and parts[1] in ["cargo", "medical", "kitchen"]:
			if not parts[2].is_valid_int() or int(parts[2]) < 1: return "Invalid allocated run identity"
			highest = maxi(highest, int(parts[2]))
	if state.run.next_sequence <= highest: return "Saved allocation sequence would reuse an existing identity"
	return ""

func _claim(id: String, owner: String, items: Dictionary, owners: Dictionary) -> bool:
	if not items.has(id) or owners.has(id):
		_error = "Missing or multiply owned item %s (%s)" % [id, owner]
		return false
	owners[id] = owner
	return true

func _validate_surface(surface: Variant, items: Dictionary, owners: Dictionary) -> String:
	if not _fields(surface, {"id":TYPE_STRING,"grid":TYPE_VECTOR2I,"cell_size":TYPE_FLOAT,"name":TYPE_STRING,
		"zones_initialized":TYPE_BOOL,"zones":TYPE_ARRAY,"cells":TYPE_ARRAY,"reservations":TYPE_DICTIONARY,
		"stacks":TYPE_ARRAY,"orientation":TYPE_INT}, "Storage"): return _error
	var size: Vector2i = surface.grid
	if size.x < 1 or size.y < 1 or size.x * size.y != surface.cells.size() or surface.zones.size() != surface.cells.size() or surface.orientation not in [0,1,2,3]: return "Invalid storage dimensions/orientation"
	var cells: Array[String] = []
	cells.resize(size.x * size.y)
	cells.fill("")
	for id: String in surface.reservations:
		var reservation: Variant = surface.reservations[id]
		if not _fields(reservation, {"valid":TYPE_BOOL,"item_key":TYPE_STRING,"origin":TYPE_VECTOR2I,"footprint":TYPE_VECTOR2I,"rotated":TYPE_BOOL}, "Reservation"): return _error
		var origin: Vector2i = reservation.origin
		var footprint: Vector2i = reservation.footprint
		if not reservation.valid or reservation.item_key != id or origin.x < 0 or origin.y < 0 or footprint.x < 1 or footprint.y < 1 or origin.x + footprint.x > size.x or origin.y + footprint.y > size.y: return "Invalid committed reservation"
		for y: int in range(origin.y, origin.y + footprint.y):
			for x: int in range(origin.x, origin.x + footprint.x):
				var index := y * size.x + x
				if not cells[index].is_empty(): return "Overlapping committed reservations"
				cells[index] = id
	if cells != surface.cells: return "Reservation/cell mismatch"
	var stack_ids: Dictionary = {}
	for stack: Variant in surface.stacks:
		if not _fields(stack, {"id":TYPE_STRING,"origin":TYPE_VECTOR2I,"footprint":TYPE_VECTOR2I,"entries":TYPE_ARRAY}, "Stack"): return _error
		if stack_ids.has(stack.id) or not surface.reservations.has(stack.id) or stack.entries.is_empty(): return "Invalid storage stack"
		stack_ids[stack.id] = true
		if surface.reservations[stack.id].origin != stack.origin or surface.reservations[stack.id].footprint != stack.footprint: return "Stack reservation mismatch"
		for member: Variant in stack.entries:
			if not _fields(member, {"item":TYPE_STRING,"footprint":TYPE_VECTOR2I,"packing":TYPE_BOOL,"bounds":TYPE_AABB,"height":TYPE_FLOAT,
				"stackable":TYPE_BOOL,"support":TYPE_BOOL,"group":TYPE_STRING_NAME,"poses":TYPE_DICTIONARY}, "Stack member"): return _error
			if not _claim(member.item, "storage", items, owners): return _error
			if not member.poses.has(".") or member.height < 0.0: return "Missing committed storage pose"
			for path: String in member.poses:
				if not member.poses[path] is Transform3D or path.contains("..") or path.begins_with("/"): return "Invalid storage pose"
	if stack_ids.size() != surface.reservations.size(): return "Reservation without a live stack"
	for zone: Variant in surface.zones:
		if not zone is String or (not zone.is_empty() and not StorageCategories.EDITOR_CATEGORIES.has(zone)): return "Unsupported storage zone"
	return ""

func _batch_states(receiving: Dictionary) -> Array:
	var all: Array = receiving.manager.batches.duplicate()
	for pending: Dictionary in receiving.admission.pending:
		all.append(pending.batch)
	if not receiving.pending_debug.is_empty(): all.append(receiving.pending_debug)
	return all

func _validate_receiving(receiving: Variant, items: Dictionary, owners: Dictionary, spent: Dictionary) -> String:
	if not _fields(receiving, {"manager":TYPE_DICTIONARY,"admission":TYPE_DICTIONARY,"cycle":TYPE_DICTIONARY,"debug_started":TYPE_BOOL,"pending_debug":TYPE_DICTIONARY,"debug_first":TYPE_STRING}, "Receiving"): return _error
	if not _fields(receiving.manager, {"active":TYPE_STRING,"queue":TYPE_ARRAY,"batches":TYPE_ARRAY}, "Deposits"): return _error
	if not _fields(receiving.admission, {"returns":TYPE_DICTIONARY,"batch_teams":TYPE_DICTIONARY,"pending":TYPE_ARRAY}, "Return admission"): return _error
	for pending: Variant in receiving.admission.pending:
		if not _fields(pending, {"team":TYPE_STRING,"batch":TYPE_DICTIONARY,"commitment":TYPE_DICTIONARY}, "Pending return"): return _error
	var batches: Dictionary = {}
	var historical_ids: Dictionary = {}
	var current_profile: Resource = load("res://data/receiving/receiving_deck_stage_b_proof.tres")
	for batch_state: Variant in _batch_states(receiving):
		if not batch_state is Dictionary: return "Invalid batch record"
		var batch := LootBatch.from_snapshot(batch_state)
		if batch == null or batches.has(batch.batch_id) or batch.preparation_state != LootBatch.STATE_PREPARED: return "Invalid/duplicate committed batch"
		if batch.presentation_profile_id != current_profile.profile_id or batch.presentation_profile_revision != current_profile.revision: return "Incompatible Receiving presentation profile"
		batches[batch.batch_id] = batch
		for entry: LootBatchEntry in batch.entries:
			if historical_ids.has(entry.item_instance_id): return "Duplicate batch item history"
			historical_ids[entry.item_instance_id] = true
			if Catalog.get_definition_by_id(entry.definition_id) == null: return "Unknown cargo definition"
			if entry.remaining_in_batch:
				if spent.has(entry.item_instance_id) or not _claim(entry.item_instance_id, "cargo", items, owners): return "Inconsistent remaining cargo ownership"
				if items[entry.item_instance_id].definition != String(entry.definition_id): return "Cargo definition mismatch"
	var manager: Dictionary = receiving.manager
	var deposited: Dictionary = {}
	for batch_state: Dictionary in manager.batches:
		deposited[batch_state.batch_id] = true
	if manager.queue.size() > 2 or deposited.size() != manager.queue.size() + (0 if manager.active.is_empty() else 1): return "Invalid deposited capacity"
	var queue_ids: Dictionary = {}
	if not manager.active.is_empty() and not deposited.has(manager.active): return "Missing active batch"
	for id: Variant in manager.queue:
		if not id is String or not deposited.has(id) or queue_ids.has(id) or id == manager.active or batches[id].is_drained(): return "Invalid deposited FIFO"
		queue_ids[id] = true
	for team: String in receiving.admission.returns:
		if not _fields(receiving.admission.returns[team], {"team_id":TYPE_STRING,"batch_id":TYPE_STRING,"status":TYPE_STRING_NAME}, "Return status shape"): return _error
	var pending_teams: Dictionary = {}
	for pending: Dictionary in receiving.admission.pending:
		if not receiving.admission.returns.has(pending.team) or pending_teams.has(pending.team) or deposited.has(pending.batch.batch_id): return "Invalid awaiting return owner"
		pending_teams[pending.team] = true
		if pending.batch != pending.commitment: return "Awaiting return commitment changed"
		if receiving.admission.returns[pending.team].get("status") != &"AWAITING_LIFT": return "Pending return has terminal status"
	for team: String in receiving.admission.returns:
		var record: Variant = receiving.admission.returns[team]
		if not _fields(record, {"team_id":TYPE_STRING,"batch_id":TYPE_STRING,"status":TYPE_STRING_NAME}, "Return status"): return _error
		if record.team_id != team or receiving.admission.batch_teams.get(record.batch_id) != team or record.status not in [&"AWAITING_LIFT", &"ADMITTED_RETURNED", &"FORFEITED_RETURNED", &"INVALID_RETURN"] or (record.status == &"AWAITING_LIFT" and not pending_teams.has(team)): return "Inconsistent return identity/status"
	if receiving.admission.batch_teams.size() != receiving.admission.returns.size(): return "Orphan return identity"
	if not receiving.pending_debug.is_empty() and (receiving.debug_first != manager.active or deposited.has(receiving.pending_debug.batch_id)): return "Invalid pending debug delivery"
	if not _fields(receiving.cycle, {"state":TYPE_INT,"elapsed":TYPE_FLOAT,"duration":TYPE_FLOAT,"warning_elapsed":TYPE_FLOAT,
		"busy":TYPE_BOOL,"departing":TYPE_BOOL,"batch":TYPE_STRING,"shutter_y":TYPE_FLOAT}, "Lift"): return _error
	var cycle: Dictionary = receiving.cycle
	if cycle.state not in [0,1,2,3,4,5] or cycle.elapsed < 0.0 or cycle.duration < 0.0 or cycle.departing != (cycle.state == 0 and cycle.busy) or cycle.busy != (not manager.active.is_empty()) or cycle.batch != manager.active: return "Inconsistent lift continuation"
	if not manager.active.is_empty() and batches[manager.active].is_drained() != (cycle.state == 5 or cycle.departing): return "Lift phase/drained cargo mismatch"
	return ""

func restore(wing: Node, state: Dictionary) -> String:
	var validation := validate(state)
	if not validation.is_empty(): return validation
	validation = wing.get_initialization_error()
	if not validation.is_empty(): return validation
	var surfaces: Dictionary = {}
	for surface: Node in wing.get_functional_surfaces(): surfaces[String(wing.get_path_to(surface))] = surface
	if surfaces.size() != state.surfaces.size(): return "Storage owner set changed"
	for path: String in state.surfaces:
		if not surfaces.has(path) or surfaces[path].surface_id != StringName(state.surfaces[path].id) or surfaces[path].grid_size != state.surfaces[path].grid: return "Storage owner/layout changed: " + path
	for host: Dictionary in state.hosts:
		var original := wing.get_node_or_null("DevelopmentSetup/SeedItems/" + host.host)
		if original == null or String(original.item_id) != state.items[host.item].definition: return "Original seed host changed: " + host.host
	if not state.player.ladder.is_empty() and not wing.get_node_or_null(state.player.ladder) is FixedLadder: return "Saved ladder is unavailable"
	for path: String in state.player.suppressed_ladders:
		if not wing.get_node_or_null(path) is FixedLadder: return "Saved ladder rearm owner is unavailable"
	var items: Dictionary = {}
	for id: String in state.items:
		var item := ItemInstance.new(Catalog.get_definition_by_id(StringName(state.items[id].definition)), id)
		item.contaminated = state.items[id].contaminated
		items[id] = item
	var player := wing.get_node("Player")
	wing.get_node("DevelopmentSetup/SeedRegistrar").restore_state(state.hosts, items)
	player.carried_items.restore_state(state.carry, items)
	for path: String in state.surfaces:
		if not surfaces[path].restore_state(state.surfaces[path], items, player._storage_placement): return "Could not restore committed storage: " + path
	var batches: Dictionary = {}
	for batch_state: Dictionary in _batch_states(state.receiving):
		batches[batch_state.batch_id] = LootBatch.from_snapshot(batch_state)
	if not wing.get_node("ReceivingRuntime").restore_state(state.receiving, batches, items): return "Could not reconstruct saved Receiving presentation"
	player.restore_state(state.player, wing)
	wing.restoring = false
	return ""
