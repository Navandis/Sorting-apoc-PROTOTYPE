extends RefCounted

const Ops = preload("res://gameplay/expeditions/expedition_operations.gd")
const Config = preload("res://gameplay/expeditions/expedition_test_config.gd")
const Loadout = preload("res://gameplay/expeditions/expedition_loadout.gd")
const DeckPose = preload("res://receiving/receiving_deck_item_pose.gd")

var spent: Dictionary = {}
var _journeys: Dictionary
var _cargo_teams: Dictionary = {}
var _waiting: Array[String] = []
var _run: Dictionary
var _elapsed: float

func validate(state: Dictionary, run: Dictionary, elapsed: float, items: Dictionary) -> String:
	if not _shape(state, {"config": TYPE_DICTIONARY, "ready": TYPE_INT, "rng_state": TYPE_INT,
			"draft": TYPE_DICTIONARY, "journeys": TYPE_DICTIONARY, "away_cargo": TYPE_DICTIONARY}):
		return "Invalid expedition state"
	if state.config != Config.signature():
		return "Incompatible expedition test configuration"
	_run = run
	_elapsed = elapsed
	_journeys = state.journeys
	var draft: Dictionary = state.draft
	if not _shape(draft, {"members": TYPE_INT, "affinities": TYPE_ARRAY, "loadout": TYPE_DICTIONARY}) \
			or not _valid_count(draft.members) or draft.affinities.size() > 2:
		return "Invalid expedition draft"
	var seen_affinities := {}
	for affinity: Variant in draft.affinities:
		if not affinity is String or not Config.CATEGORIES.has(affinity) or seen_affinities.has(affinity):
			return "Invalid draft affinities"
		seen_affinities[affinity] = true
	var draft_id: Variant = draft.loadout.get("id")
	if not draft_id is String or (not draft_id.is_empty() and (not _valid_id(draft_id) or _journeys.has(draft_id))):
		return "Invalid formed preparation identity"
	var draft_bulk := _validate_loadout(draft.loadout, draft_id, draft.members, elapsed, items)
	if draft_bulk < 0 or draft_id.is_empty() != draft.loadout.spent.is_empty():
		return "Invalid preparation receipts or formation"
	var unavailable: int = 0 if draft_id.is_empty() else draft.members
	var away := {}
	var ids: Array[String] = []
	for id: Variant in _journeys:
		if not id is String or not _valid_id(id):
			return "Invalid expedition identity"
		var trip: Variant = _journeys[id]
		if not _valid_journey(trip):
			return "Invalid expedition timing, status or destination: " + id
		var bulk := _validate_loadout(trip.loadout, id, trip.members, trip.departed_at, items)
		if bulk < 0 or not _valid_manifest(trip, id, trip.members * Config.BULK_PER_MEMBER - bulk):
			return "Invalid expedition supply or manifest commitment: " + id
		if trip.status != Ops.COMPLETE:
			unavailable += int(trip.members)
		if trip.status == Ops.AWAY and not trip.batch_id.is_empty():
			away[trip.batch_id] = true
		if trip.status == Ops.WAITING:
			_waiting.append(id)
		ids.append(id)
	if state.ready < 0 or state.ready + unavailable != Config.READY_START:
		return "Expedition personnel do not add up to the initial roster"
	if state.away_cargo.size() != away.size():
		return "Missing or duplicate Away cargo"
	for batch_id: String in away:
		if not state.away_cargo.get(batch_id) is Dictionary or state.away_cargo[batch_id].get("batch_id") != batch_id:
			return "Invalid Away cargo owner"
	ids.sort_custom(func(a: String, b: String): return Ops.sequence(a) < Ops.sequence(b))
	var destination_returns := {}
	var previous_departure := 0.0
	for id: String in ids:
		var trip: Dictionary = _journeys[id]
		if trip.departed_at < previous_departure or trip.departed_at < destination_returns.get(trip.destination, 0.0):
			return "Overlapping destination occupancy or invalid departure order"
		destination_returns[trip.destination] = trip.return_at
		previous_departure = trip.departed_at
	if not draft_id.is_empty() and not ids.is_empty() and Ops.sequence(draft_id) <= Ops.sequence(ids.back()):
		return "Formed preparation predates a later departure"
	_waiting.sort_custom(_earlier_return)
	return ""

func _valid_count(count: int) -> bool:
	return count >= 1 and count <= Config.MAX_MEMBERS

func _valid_id(id: String) -> bool:
	var serial := Ops.sequence(id)
	return serial >= 1 and serial < _run.next_sequence and id == "%s:%s:%d" % [_run.id, Ops.ID_KIND, serial]

func _valid_journey(trip: Variant) -> bool:
	if not _shape(trip, {"members": TYPE_INT, "destination": TYPE_STRING, "departed_at": TYPE_FLOAT,
			"duration": TYPE_FLOAT, "return_at": TYPE_FLOAT, "handover_at": TYPE_FLOAT, "status": TYPE_STRING,
			"loadout": TYPE_DICTIONARY, "batch_id": TYPE_STRING, "manifest": TYPE_ARRAY, "presentation_seed": TYPE_INT}):
		return false
	if not _valid_count(trip.members) or not Config.valid_destination(trip.destination) \
			or not _in_range(trip.departed_at, 0.0, _elapsed) or not _in_range(trip.duration, Config.MIN_DURATION, Config.MAX_DURATION) \
			or not is_finite(trip.return_at) or trip.return_at != trip.departed_at + trip.duration:
		return false
	match trip.status:
		Ops.AWAY:
			# An observer can capture between two returns due at the same timestamp.
			return trip.return_at >= _elapsed and trip.handover_at == -1.0
		Ops.WAITING:
			return not trip.manifest.is_empty() and trip.return_at <= _elapsed and trip.handover_at == -1.0
		Ops.COMPLETE:
			return _in_range(trip.handover_at, trip.return_at, _elapsed) \
				and (not trip.manifest.is_empty() or trip.handover_at == trip.return_at)
	return false

func _valid_manifest(trip: Dictionary, id: String, capacity: int) -> bool:
	var remaining := capacity
	for item_id: Variant in trip.manifest:
		if not item_id is String:
			return false
		var definition := PrototypeItemCatalog.get_definition_by_id(StringName(item_id))
		if definition == null or not Config.POOL_IDS.get(definition.storage_category, []).has(item_id) or definition.bulk > remaining:
			return false
		remaining -= definition.bulk
	if remaining >= Config.MIN_POOL_BULK:
		return false
	if trip.manifest.is_empty():
		return trip.batch_id.is_empty() and trip.presentation_seed == 0
	if trip.batch_id != Ops.cargo_id(id) or trip.presentation_seed < 0 or trip.presentation_seed > 0xffffffff:
		return false
	_cargo_teams[trip.batch_id] = id
	return true

func _validate_loadout(loadout: Dictionary, id: String, members: int, until: float, items: Dictionary) -> int:
	if not _shape(loadout, {"id": TYPE_STRING, "destination": TYPE_STRING, "targets": TYPE_DICTIONARY,
			"credited": TYPE_DICTIONARY, "spent": TYPE_ARRAY, "closed": TYPE_BOOL, "result": TYPE_DICTIONARY}):
		return -1
	var targets := Config.targets_for(members)
	if loadout.id != id or loadout.destination != Loadout.CONTEXT or loadout.targets != targets:
		return -1
	var credited := {}
	for lane: String in targets:
		credited[lane] = 0
	var bulk := 0
	var previous := 0.0
	for receipt: Variant in loadout.spent:
		if not _shape(receipt, {"item_id": TYPE_STRING, "definition_id": TYPE_STRING, "lane": TYPE_STRING,
				"raw": TYPE_INT, "applied": TYPE_INT, "wasted": TYPE_INT, "bulk": TYPE_INT,
				"contaminated": TYPE_BOOL, "at": TYPE_FLOAT}):
			return -1
		if receipt.item_id.is_empty() or items.has(receipt.item_id) or spent.has(receipt.item_id) \
				or not _in_range(receipt.at, previous, until) or not targets.has(receipt.lane):
			return -1
		var definition := PrototypeItemCatalog.get_definition_by_id(StringName(receipt.definition_id))
		if definition == null or definition.storage_category != receipt.lane or definition.bulk != receipt.bulk:
			return -1
		var item := ItemInstance.new(definition, receipt.item_id)
		item.contaminated = receipt.contaminated
		var raw := item.get_utility_value()
		var applied := mini(raw, targets[receipt.lane] - credited[receipt.lane])
		bulk += definition.bulk
		if applied <= 0 or receipt.applied != applied or receipt.raw != raw or receipt.wasted != raw - applied \
				or bulk > members * Config.BULK_PER_MEMBER:
			return -1
		credited[receipt.lane] += applied
		previous = receipt.at
		spent[receipt.item_id] = receipt
	var full := credited == targets
	var result := {}
	if full:
		for lane: String in targets:
			result[lane] = {"required": targets[lane], "supplied": credited[lane], "unmet": 0}
	return bulk if loadout.credited == credited and loadout.closed == full and loadout.result == result else -1

func cargo_handover_at(batch_id: String) -> float:
	var trip: Dictionary = _journeys.get(_cargo_teams.get(batch_id, ""), {})
	return trip.get("handover_at", INF)

func validate_cargo(receiving: Dictionary, batches: Dictionary, items: Dictionary, owners: Dictionary,
		profile: ReceivingDeckProfile, terminal: Dictionary) -> String:
	var admission: Dictionary = receiving.admission
	var spec := profile.get_surface(&"MainDeck") as ReceivingDeckSurfaceSpec
	if spec == null or not spec.enabled:
		return "Missing expedition cargo deck"
	var grid := Rect2i(Vector2i.ZERO, Vector2i(
		floori(spec.usable_width_m / profile.cell_size_m + 0.000001),
		floori(spec.usable_depth_m / profile.cell_size_m + 0.000001)))
	var waiting: Array[String] = []
	for pending: Dictionary in admission.pending:
		waiting.append(pending.team)
	if waiting != _waiting:
		return "Awaiting Lift crew or FIFO mismatch"
	var order: Array = []
	if not receiving.manager.active.is_empty():
		order.append(receiving.manager.active)
	order.append_array(receiving.manager.queue)
	for pending: Dictionary in admission.pending:
		order.append(pending.batch.batch_id)
	var previous := ""
	for batch_id: String in order:
		var team: String = _cargo_teams.get(batch_id, "")
		if team.is_empty() or (not previous.is_empty() and not _earlier_return(previous, team)):
			return "Invalid deposited and Awaiting Lift FIFO order"
		previous = team
	var expected_returns := 0
	var last_retired_handover := -1.0
	var expedition_items := {}
	for batch_id: String in _cargo_teams:
		var id: String = _cargo_teams[batch_id]
		var trip: Dictionary = _journeys[id]
		var record: Dictionary = admission.returns.get(id, {})
		var batch: LootBatch = batches.get(batch_id)
		if trip.status == Ops.AWAY:
			if not record.is_empty() or batch == null or admission.batch_teams.has(batch_id):
				return "Away expedition already has a cargo admission"
		else:
			expected_returns += 1
			var status := AwaitingLiftAdmission.AWAITING_LIFT if trip.status == Ops.WAITING else AwaitingLiftAdmission.ADMITTED_RETURNED
			if record.get("status") != status or record.get("batch_id") != batch_id:
				return "Expedition handover disagrees with Receiving"
		if batch == null and trip.status == Ops.COMPLETE:
			last_retired_handover = maxf(last_retired_handover, trip.handover_at)
		var entries: Array[LootBatchEntry] = []
		if batch != null:
			entries = batch.entries
		if batch != null and (batch.source_kind != &"expedition" or batch.source_ref != id \
				or batch.presentation_seed != trip.presentation_seed or not batch.presentation_fixtures.is_empty() \
				or entries.size() != trip.manifest.size()):
			return "Prepared cargo differs from its expedition commitment"
		var bulk := 0
		var groups := {}
		for index in trip.manifest.size():
			var item_id := "%s:item_%04d" % [batch_id, index]
			var definition: String = trip.manifest[index]
			var item_definition := PrototypeItemCatalog.get_definition_by_id(StringName(definition))
			bulk += item_definition.bulk
			expedition_items[item_id] = true
			if batch != null:
				var entry := entries[index]
				if entry.entry_id != "entry_%04d" % index or entry.item_instance_id != item_id or String(entry.definition_id) != definition \
						or not entry.has_deck_layout or entry.presentation_surface_id != &"MainDeck" \
						or (trip.status != Ops.COMPLETE and not entry.remaining_in_batch):
					return "Invalid expedition cargo entry"
				var footprint := DeckPose.footprint_for(ItemInstance.new(item_definition, item_id), entry.presentation_quarter_turns)
				var bounds := Rect2i(entry.presentation_cell_origin, footprint)
				if not grid.encloses(bounds):
					return "Expedition cargo lies outside the deck"
				var group := entry.presentation_stack_group_id
				if not groups.has(group):
					groups[group] = []
				(groups[group] as Array).append(entry)
			if terminal.has(item_id):
				var receipt: Dictionary = terminal[item_id]
				if trip.status != Ops.COMPLETE or (batch != null and entries[index].remaining_in_batch) \
						or receipt.definition_id != definition or receipt.at < trip.handover_at:
					return "Consumed cargo has no matching prior handover"
			elif not owners.has(item_id) or items[item_id].definition != definition:
				return "Expedition cargo has no exact owner"
		if batch != null and (batch.actual_bulk != bulk or batch.target_bulk != bulk):
			return "Expedition batch Bulk mismatch"
		var occupied: Array[Rect2i] = []
		for members: Array in groups.values():
			members.sort_custom(func(a: LootBatchEntry, b: LootBatchEntry) -> bool:
				return a.presentation_stack_index < b.presentation_stack_index)
			var stack := StorageStack.new()
			for entry: LootBatchEntry in members:
				var definition := PrototypeItemCatalog.get_definition_by_id(entry.definition_id)
				var item := ItemInstance.new(definition, entry.item_instance_id)
				var measured := DeckPose.measure_item(item, entry.presentation_quarter_turns)
				if not measured.get("valid", false):
					return "Expedition cargo pose is invalid"
				var member := StorageStack.create_entry(item, measured.footprint, measured.packing_rotated, measured.aligned_bounds)
				if stack.entries.is_empty():
					if not DeckPose.fits_as_base(member, spec.stack_clearance_m):
						return "Expedition cargo base exceeds deck clearance"
					var bounds := Rect2i(entry.presentation_cell_origin, member.footprint)
					for other: Rect2i in occupied:
						if bounds.intersects(other):
							return "Expedition cargo has overlapping deck reservations"
					occupied.append(bounds)
				elif not DeckPose.find_stack_append(stack, member, spec.stack_clearance_m).get("valid", false):
					return "Expedition cargo has an invalid support chain"
				stack.entries.append(member)
	var turnaround: float = receiving.cycle.last_turnaround_at
	if (turnaround == -1.0) != (last_retired_handover == -1.0) or turnaround < last_retired_handover:
		return "Completed freight turnaround disagrees with retired cargo history"
	if expected_returns != admission.returns.size() or batches.size() > _cargo_teams.size():
		return "Cargo or handover has no expedition"
	for batch_id: String in batches:
		if not _cargo_teams.has(batch_id):
			return "Unknown expedition cargo batch"
	for item_id: String in terminal:
		if not expedition_items.has(item_id) and not _seed_identity(item_id):
			return "Receipt has no expedition or original palette identity"
	for item_id: String in items:
		if not expedition_items.has(item_id) and not _seed_identity(item_id):
			return "Physical item has no expedition or original palette identity"
	return ""

func _seed_identity(id: String) -> bool:
	var parts := id.split(":")
	return parts.size() == 3 and parts[0] == _run.id and parts[1] == "wing_seed_v1" \
		and not parts[2].is_empty() and not parts[2].contains("/")

func _earlier_return(a: String, b: String) -> bool:
	var at: float = _journeys[a].return_at
	var bt: float = _journeys[b].return_at
	return at < bt or (at == bt and Ops.sequence(a) < Ops.sequence(b))

func _in_range(value: float, minimum: float, maximum: float) -> bool:
	return is_finite(value) and value >= minimum and value <= maximum

func _shape(value: Variant, fields: Dictionary) -> bool:
	if not value is Dictionary:
		return false
	for key: String in fields:
		if typeof(value.get(key)) != fields[key]:
			return false
	return true
