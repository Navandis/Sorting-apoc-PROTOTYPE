extends RefCounted

const Codec = preload("res://gameplay/run/state_codec.gd")
const Catalog = preload("res://prototype_item_catalog.gd")
const Goal = preload("res://gameplay/run/collection_goal.gd")
const ExpeditionSnapshot = preload("res://gameplay/expeditions/expedition_snapshot.gd")
const KitchenSnapshot = preload("res://gameplay/kitchen/kitchen_snapshot.gd")
const WING_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const FuelSnapshot := preload("res://gameplay/fuel/fuel_snapshot.gd")
const FuelConfig := preload("res://gameplay/fuel/fuel_test_config.gd")
const SCHEMA := 10
const NORMAL_CARRY_BULK := 20
static var _seed_definitions: Dictionary = {}
var _error := ""

func capture(wing: Node) -> Dictionary:
	if wing.run_identity == null or wing.restoring or not wing.get_initialization_error().is_empty():
		return {}
	var items: Dictionary = {}
	var player := wing.get_node("Player")
	for item: ItemInstance in player.carried_items.get_items():
		if not _record_item(items, item):
			return {}
	var registrar := wing.get_node("DevelopmentSetup/SeedRegistrar")
	var hosts: Array = registrar.capture_state()
	for host: Dictionary in hosts:
		if not _record_item(items, registrar.get_node("../SeedItems").get_node(host.host).get_node("WorldItem").get_item_instance()):
			return {}
	var surfaces: Dictionary = {}
	for surface: Node in wing.get_functional_surfaces():
		surfaces[String(wing.get_path_to(surface))] = surface.capture_state()
		for item: ItemInstance in surface.get_stored_items():
			if not _record_item(items, item):
				return {}
	var runtime := wing.get_node("ReceivingRuntime")
	var receiving: Dictionary = runtime.capture_state()
	var expeditions: Dictionary = wing.expeditions.capture_state()
	var presented: Dictionary = {}
	for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		if not _record_item(presented, world.get_item_instance()):
			return {}
	var batches := _batch_states(receiving)
	batches.append_array(expeditions.away_cargo.values())
	for batch_state: Dictionary in batches:
		for entry: Dictionary in batch_state.entries:
			if not entry.remaining_in_batch:
				continue
			var id: String = entry.item_instance_id
			if items.has(id):
				push_error("Multiply owned cargo item: " + id)
				return {}
			items[id] = presented.get(id, {"definition": String(entry.definition_id), "contaminated": false})
			presented.erase(id)
	if not presented.is_empty():
		push_error("Presented items have no remaining cargo owner")
		return {}
	return {"schema": SCHEMA, "content": content_fingerprint(), "run": wing.run_identity.capture_state(),
		"timeline": wing.run_timeline.capture_state(), "goal": wing.collection_goal.capture_state(),
		"expeditions": expeditions, "incinerator": wing.incinerator.capture_state(),
		"kitchen": wing.kitchen.capture_state(), "fuel": wing.fuel.capture_state(),
		"items": items, "carry": player.carried_items.capture_state(),
		"hosts": hosts, "surfaces": surfaces, "player": player.capture_state(wing), "receiving": receiving}

func _record_item(items: Dictionary, item: ItemInstance) -> bool:
	if items.has(item.instance_id):
		push_error("Multiply owned physical item: " + item.instance_id)
		return false
	items[item.instance_id] = {"definition": String(item.definition.item_id), "contaminated": item.contaminated}
	return true

func content_fingerprint() -> String:
	var physical: Dictionary = {}
	var catalog := Catalog._catalogue() as ItemCatalog
	for definition: ItemDefinition in catalog.definitions:
		physical[String(definition.item_id)] = [definition.bulk, definition.storage_footprint,
			definition.storage_rotation_degrees, definition.can_be_stacked, definition.can_support_stack,
			definition.auto_stack_group, definition.visual_scene.resource_path if definition.visual_scene != null else "", definition.visual_scale,
			definition.storage_category, definition.utility_id, definition.utility_value, definition.context_utility_overrides]
	physical["pose_contract"] = "vertex_vertical_seating"
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
	if state.get("schema") in [1, 2, 3, 4]:
		return "Legacy M4 or earlier continuation uses an incompatible schema. Start a new collection run. The legacy save is preserved."
	if state.get("schema") == 5:
		return "This continuation is from the collection foundation (schema 5). Expeditions require a New Run. The previous snapshot is preserved."
	if state.get("schema") == 6:
		return "This continuation is from the expedition build (schema 6). Incinerator continuation requires a New Run. The previous snapshot is preserved."
	if state.get("schema") == 7:
		return "This continuation is from the Incinerator build (schema 7). Continuous Kitchen requires a New Run. The previous snapshot is preserved."
	if state.get("schema") == 8:
		return "This continuation is from the Kitchen build (schema 8). Fuel reserve requires a New Run. The previous snapshot is preserved."
	if state.get("schema") == 9:
		return "This continuation is from the Fuel build (schema 9). Receiving stack continuation requires a New Run. The previous snapshot is preserved."
	if state.get("schema") != SCHEMA:
		return "Unsupported save schema %s (collection schema %s required)" % [state.get("schema"), SCHEMA]
	if not _fields(state, {"schema":TYPE_INT,"content":TYPE_STRING,"run":TYPE_DICTIONARY,"timeline":TYPE_DICTIONARY,"goal":TYPE_DICTIONARY,
		"items":TYPE_DICTIONARY,"carry":TYPE_DICTIONARY,"hosts":TYPE_ARRAY,"surfaces":TYPE_DICTIONARY,
		"player":TYPE_DICTIONARY,"receiving":TYPE_DICTIONARY,"expeditions":TYPE_DICTIONARY,
		"incinerator":TYPE_DICTIONARY,"kitchen":TYPE_DICTIONARY,"fuel":TYPE_DICTIONARY}, "Snapshot"): return _error
	if state.content != content_fingerprint(): return "Save's physical item data is incompatible with this build"
	if not _fields(state.run, {"id":TYPE_STRING,"next_sequence":TYPE_INT}, "Run"): return _error
	if state.run.id.length() != 24 or not state.run.id.is_valid_hex_number(false) or state.run.next_sequence < 1:
		return "Unsupported run identity or allocator"
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
	# The slot records normal capacity. Kitchen can lower the pickup limit
	# without invalidating items that already belong to the carried bundle.
	if bulk > NORMAL_CARRY_BULK or state.carry.max_bulk != NORMAL_CARRY_BULK \
			or (selected == -1 and not owners.is_empty()) \
			or (selected != -1 and (selected < 0 or selected >= state.carry.slots.size() or state.carry.slots[selected].is_empty())):
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
	var collection_error := _validate_collection_state(state)
	if not collection_error.is_empty(): return collection_error
	var expedition := ExpeditionSnapshot.new()
	var expedition_error := expedition.validate(state.expeditions, state.run, state.timeline.elapsed, state.items)
	if not expedition_error.is_empty(): return expedition_error
	var terminal := expedition.spent.duplicate()
	var disposal_error := _validate_disposals(state, terminal)
	if not disposal_error.is_empty(): return disposal_error
	var kitchen_error := KitchenSnapshot.new().validate(state.kitchen, state.timeline.elapsed, state.items,
		terminal, state.run.id + ":wing_seed_v1:", _seed_definition)
	if not kitchen_error.is_empty(): return kitchen_error
	var fuel := FuelSnapshot.new()
	var fuel_error := fuel.validate(state.fuel, state.timeline.elapsed, state.items,
		terminal, state.run.id + ":wing_seed_v1:", _seed_definition)
	if not fuel_error.is_empty(): return fuel_error
	terminal.make_read_only()
	var receiving_error := _validate_receiving(state, owners, expedition, terminal, fuel.normal_freight_through)
	if not receiving_error.is_empty(): return receiving_error
	if owners.size() != state.items.size(): return "Unowned physical item in save"
	if not _fields(state.player, {"transform":TYPE_TRANSFORM3D,"camera":TYPE_TRANSFORM3D,"pitch":TYPE_FLOAT,
		"velocity":TYPE_VECTOR3,"ladder":TYPE_STRING,"ladder_yaw":TYPE_FLOAT,"ladder_anchor":TYPE_VECTOR2,"suppressed_ladders":TYPE_ARRAY}, "Player"): return _error
	if state.player.ladder.contains("..") or state.player.ladder.begins_with("/"): return "Invalid ladder reference"
	for path: Variant in state.player.suppressed_ladders:
		if not path is String or path.contains("..") or path.begins_with("/") or path.is_empty(): return "Invalid ladder suppression reference"
	return ""

func _validate_collection_state(state: Dictionary) -> String:
	var timeline: Dictionary = state.timeline
	if not _fields(timeline, {"elapsed":TYPE_FLOAT,"last_auto_attempt_at":TYPE_FLOAT}, "Collection timeline"):
		return _error
	if not is_finite(timeline.elapsed) or timeline.elapsed < 0.0 or not is_finite(timeline.last_auto_attempt_at) or timeline.last_auto_attempt_at < 0.0 or timeline.last_auto_attempt_at > timeline.elapsed:
		return "Inconsistent active time or automatic save timing"
	var goal: Dictionary = state.goal
	if not _fields(goal, {"target":TYPE_INT,"rule_revision":TYPE_INT,"completed":TYPE_BOOL,"first_completion_at":TYPE_FLOAT}, "Collection goal"):
		return _error
	if goal.target <= 0 or goal.rule_revision != Goal.RULE_REVISION:
		return "Unsupported collection target or rule revision"
	if goal.completed:
		if not is_finite(goal.first_completion_at) or goal.first_completion_at < 0.0 or goal.first_completion_at > timeline.elapsed:
			return "Invalid first collection completion time"
	elif goal.first_completion_at != -1.0:
		return "An incomplete collection has a completion time"
	return ""

func _validate_disposals(state: Dictionary, terminal: Dictionary) -> String:
	var disposal: Dictionary = state.incinerator
	if not _fields(disposal, {"warning_shown": TYPE_BOOL, "receipts": TYPE_ARRAY}, "Incinerator"):
		return _error
	if not disposal.warning_shown and not disposal.receipts.is_empty():
		return "Disposal receipts require a displayed warning"
	var seed_prefix: String = state.run.id + ":wing_seed_v1:"
	var previous := 0.0
	for receipt: Variant in disposal.receipts:
		if not _fields(receipt, {"item_id": TYPE_STRING, "definition_id": TYPE_STRING, "at": TYPE_FLOAT}, "Disposal receipt"):
			return _error
		var id: String = receipt.item_id
		if id.is_empty() or state.items.has(id) or terminal.has(id):
			return "Missing or multiply owned disposal identity: " + id
		if not is_finite(receipt.at) or receipt.at < previous or receipt.at > state.timeline.elapsed:
			return "Invalid disposal time: " + id
		if Catalog.get_definition_by_id(StringName(receipt.definition_id)) == null:
			return "Unknown disposal definition: " + id
		if id.begins_with(seed_prefix) and receipt.definition_id != _seed_definition(id.trim_prefix(seed_prefix)):
			return "Disposal receipt differs from its authored seed: " + id
		terminal[id] = receipt
		previous = receipt.at
	return ""

func _seed_definition(host: String) -> String:
	if _seed_definitions.is_empty():
		# Read the palette and wing overrides without instantiating any world items.
		var wing_scene := load(WING_PATH) as PackedScene
		var authored := wing_scene.get_state()
		for index in authored.get_node_count():
			if String(authored.get_node_path(index)).trim_prefix("./") == "DevelopmentSetup":
				var setup := authored.get_node_instance(index)
				if setup != null:
					_read_seed_definitions(setup.get_state(), "SeedItems")
				break
		_read_seed_definitions(authored, "DevelopmentSetup/SeedItems")
	return _seed_definitions.get(host, "")

func _read_seed_definitions(scene: SceneState, parent: String) -> void:
	for index in scene.get_node_count():
		if String(scene.get_node_path(index, true)).trim_prefix("./") != parent:
			continue
		for property in scene.get_node_property_count(index):
			if scene.get_node_property_name(index, property) == &"item_id":
				_seed_definitions[String(scene.get_node_name(index))] = String(scene.get_node_property_value(index, property))
				break

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
	return all

func _validate_receiving(state: Dictionary, owners: Dictionary, expedition: RefCounted, terminal: Dictionary,
		normal_freight_through: float) -> String:
	var receiving: Dictionary = state.receiving
	var away: Dictionary = state.expeditions.away_cargo
	var items: Dictionary = state.items
	if not _fields(receiving, {"manager":TYPE_DICTIONARY,"admission":TYPE_DICTIONARY,"cycle":TYPE_DICTIONARY}, "Receiving"): return _error
	if not _fields(receiving.manager, {"active":TYPE_STRING,"queue":TYPE_ARRAY,"batches":TYPE_ARRAY}, "Deposits"): return _error
	if not _fields(receiving.admission, {"returns":TYPE_DICTIONARY,"batch_teams":TYPE_DICTIONARY,"pending":TYPE_ARRAY}, "Return admission"): return _error
	for pending: Variant in receiving.admission.pending:
		if not _fields(pending, {"team":TYPE_STRING,"batch":TYPE_DICTIONARY,"commitment":TYPE_DICTIONARY}, "Pending return"): return _error
	var batches: Dictionary = {}
	var historical_ids: Dictionary = {}
	var current_profile := load("res://data/receiving/receiving_deck_stage_b_proof.tres") as ReceivingDeckProfile
	var batch_states := _batch_states(receiving)
	batch_states.append_array(away.values())
	for batch_state: Variant in batch_states:
		if not batch_state is Dictionary: return "Invalid batch record"
		var batch := LootBatch.from_snapshot(batch_state)
		if batch == null or batches.has(batch.batch_id) or batch.preparation_state != LootBatch.STATE_PREPARED: return "Invalid/duplicate committed batch"
		for entry_state: Dictionary in batch_state.entries:
			if not entry_state.has("released_as_base"): return "Missing Receiving base removal history"
		if batch.presentation_profile_id != current_profile.profile_id or batch.presentation_profile_revision != current_profile.revision: return "Incompatible Receiving presentation profile"
		batches[batch.batch_id] = batch
		for entry: LootBatchEntry in batch.entries:
			if historical_ids.has(entry.item_instance_id): return "Duplicate batch item history"
			historical_ids[entry.item_instance_id] = true
			if Catalog.get_definition_by_id(entry.definition_id) == null: return "Unknown cargo definition"
			if entry.remaining_in_batch:
				if not _claim(entry.item_instance_id, "away cargo" if away.has(batch.batch_id) else "cargo", items, owners): return _error
			elif batch.batch_id != receiving.manager.active:
				return "Cargo released before becoming active"
			elif terminal.has(entry.item_instance_id):
				if terminal[entry.item_instance_id].definition_id != String(entry.definition_id):
					return "Released active cargo has a mismatched consumption receipt"
				continue
			elif not owners.has(entry.item_instance_id):
				return "Released active cargo has no physical owner or receipt: " + entry.item_instance_id
			if items[entry.item_instance_id].definition != String(entry.definition_id):
				return "Cargo definition mismatch"
	var manager: Dictionary = receiving.manager
	var deposited: Dictionary = {}
	for batch_state: Dictionary in manager.batches:
		deposited[batch_state.batch_id] = true
	if manager.queue.size() > 2 or (manager.active.is_empty() and not manager.queue.is_empty()) or deposited.size() != manager.queue.size() + (0 if manager.active.is_empty() else 1):
		return "Invalid deposited capacity"
	var queue_ids: Dictionary = {}
	if not manager.active.is_empty() and not deposited.has(manager.active): return "Missing active batch"
	for id: Variant in manager.queue:
		if not id is String or not deposited.has(id) or queue_ids.has(id) or id == manager.active or batches[id].is_drained(): return "Invalid deposited FIFO"
		queue_ids[id] = true
	for team: String in receiving.admission.returns:
		if not _fields(receiving.admission.returns[team], {"team_id":TYPE_STRING,"batch_id":TYPE_STRING,"status":TYPE_STRING_NAME}, "Return status shape"): return _error
	var pending_teams: Dictionary = {}
	if not receiving.admission.pending.is_empty() and manager.queue.size() < 2:
		return "Awaiting Lift cargo left a deposited slot free"
	for pending: Dictionary in receiving.admission.pending:
		if not receiving.admission.returns.has(pending.team) or pending_teams.has(pending.team) or deposited.has(pending.batch.batch_id): return "Invalid awaiting return owner"
		pending_teams[pending.team] = true
		if pending.batch != pending.commitment: return "Awaiting return commitment changed"
		var record: Dictionary = receiving.admission.returns[pending.team]
		if record.status != &"AWAITING_LIFT" or record.batch_id != pending.batch.batch_id or batches[record.batch_id].is_drained():
			return "Inconsistent waiting cargo identity/status"
	for team: String in receiving.admission.returns:
		var record: Variant = receiving.admission.returns[team]
		if record.team_id != team or receiving.admission.batch_teams.get(record.batch_id) != team:
			return "Inconsistent return identity"
		var expected: StringName = &"AWAITING_LIFT" if pending_teams.has(team) else &"ADMITTED_RETURNED"
		if record.status != expected:
			return "Inconsistent return status"
	if receiving.admission.batch_teams.size() != receiving.admission.returns.size(): return "Orphan return identity"
	for batch_id: String in batches:
		if not away.has(batch_id) and not receiving.admission.batch_teams.has(batch_id):
			return "Cargo has no admission commitment"
	var active: LootBatch = batches.get(manager.active)
	var lift_error := _validate_lift(receiving.cycle, active, state.timeline.elapsed, expedition, normal_freight_through)
	if not lift_error.is_empty(): return lift_error
	return expedition.validate_cargo(receiving, batches, items, owners, current_profile, terminal)

func _validate_lift(cycle: Variant, active: LootBatch, elapsed: float, expedition: RefCounted,
		normal_freight_through: float) -> String:
	if not _fields(cycle, {"state":TYPE_INT,"elapsed":TYPE_FLOAT,"duration":TYPE_FLOAT,"warning_elapsed":TYPE_FLOAT,
		"busy":TYPE_BOOL,"departing":TYPE_BOOL,"batch":TYPE_STRING,"shutter_y":TYPE_FLOAT,
		"start_due_at":TYPE_FLOAT,"last_turnaround_at":TYPE_FLOAT}, "Lift"): return _error
	var phase: int = cycle.state
	var closed := phase == ReceivingLiftCycle.State.SEALED_EMPTY
	var waiting: bool = cycle.start_due_at != ReceivingLiftCycle.NO_START_DEADLINE
	if phase < ReceivingLiftCycle.State.SEALED_EMPTY or phase > ReceivingLiftCycle.State.CLOSING \
			or cycle.busy != (active != null) or cycle.batch != (active.batch_id if active != null else "") \
			or cycle.busy != (not closed or waiting or cycle.departing) \
			or (waiting and cycle.departing) or ((waiting or cycle.departing) and not closed):
		return "Inconsistent lift continuation"
	for value: float in [cycle.elapsed, cycle.duration, cycle.warning_elapsed]:
		if not is_finite(value) or value < 0.0: return "Invalid lift phase time"
	if not is_finite(cycle.shutter_y): return "Invalid shutter pose"
	if active != null and active.is_drained() != (phase == ReceivingLiftCycle.State.CLOSING or cycle.departing):
		return "Lift phase/drained cargo mismatch"
	var turnaround: float = cycle.last_turnaround_at
	if not is_finite(turnaround) or (turnaround != -1.0 and (turnaround < 0.0 or turnaround > elapsed)):
		return "Invalid completed freight turnaround time"
	if waiting:
		var due: float = cycle.start_due_at
		var eligible_at := maxf(turnaround, expedition.cargo_handover_at(active.batch_id))
		if not is_finite(due) or due <= elapsed or eligible_at > elapsed \
				or due != eligible_at + FuelConfig.EMERGENCY_WAIT or eligible_at <= normal_freight_through:
			return "Invalid emergency freight start deadline or power"
		if cycle.elapsed != 0.0 or cycle.duration != 0.0 or cycle.warning_elapsed != 0.0 \
				or cycle.shutter_y != _authored_closed_shutter_y():
			return "Emergency freight must wait with the shutter closed and no cycle underway"
		for entry: LootBatchEntry in active.entries:
			if not entry.remaining_in_batch:
				return "Emergency freight waiting to start has released cargo"
	return ""

func _authored_closed_shutter_y() -> float:
	var scene: SceneState = (load(WING_PATH) as PackedScene).get_state()
	const CLOSED_MARKER := "ReceivingLiftInstallation/ShutterPoseMarkers/Closed"
	for index in scene.get_node_count():
		if String(scene.get_node_path(index)).trim_prefix("./") != CLOSED_MARKER:
			continue
		for property in scene.get_node_property_count(index):
			if scene.get_node_property_name(index, property) == &"transform":
				var pose: Transform3D = scene.get_node_property_value(index, property)
				return pose.origin.y
		break
	return INF

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
	wing.incinerator.restore_state(state.incinerator)
	wing.kitchen.restore_state(state.kitchen)
	wing.get_node("DevelopmentSetup/SeedRegistrar").restore_state(state.hosts, items)
	player.carried_items.restore_state(state.carry, items)
	for path: String in state.surfaces:
		if not surfaces[path].restore_state(state.surfaces[path], items, player._storage_placement): return "Could not restore committed storage: " + path
	var batches: Dictionary = {}
	for batch_state: Dictionary in _batch_states(state.receiving):
		batches[batch_state.batch_id] = LootBatch.from_snapshot(batch_state)
	wing.expeditions.restore_state(state.expeditions)
	if not wing.get_node("ReceivingRuntime").restore_state(state.receiving, batches, items): return "Could not reconstruct saved Receiving presentation"
	player.restore_state(state.player, wing)
	return wing.finish_restoring()
