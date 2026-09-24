extends RefCounted
class_name LootBatch

const ItemInstanceScript = preload("res://item_instance.gd")
const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const FreightFixtureInstanceScript = preload("res://receiving/receiving_freight_fixture_instance.gd")
const FreightFixturePolicyScript = preload("res://receiving/receiving_freight_fixture_policy.gd")

const STATE_CONTENT_COMMITTED: StringName = &"CONTENT_COMMITTED"
const STATE_PREPARED: StringName = &"PREPARED"

var _batch_id: String = ""
var _source_kind: StringName = &""
var _source_ref: String = ""
var _target_bulk: int = 0
var _actual_bulk: int = 0
var _content_seed: int = 0
var _presentation_seed: int = 0
var _preparation_state: StringName = STATE_CONTENT_COMMITTED
var _presentation_profile_id: StringName = &""
var _presentation_profile_revision: int = 0
var _entries: Array[LootBatchEntry] = []
var _presentation_fixtures: Array[ReceivingFreightFixtureInstance] = []

var batch_id: String:
	set(_value):
		pass
	get:
		return _batch_id
var source_kind: StringName:
	set(_value):
		pass
	get:
		return _source_kind
var source_ref: String:
	set(_value):
		pass
	get:
		return _source_ref
var target_bulk: int:
	set(_value):
		pass
	get:
		return _target_bulk
var actual_bulk: int:
	set(_value):
		pass
	get:
		return _actual_bulk
var content_seed: int:
	set(_value):
		pass
	get:
		return _content_seed
var presentation_seed: int:
	set(_value):
		pass
	get:
		return _presentation_seed
var preparation_state: StringName:
	set(_value):
		pass
	get:
		return _preparation_state
var presentation_profile_id: StringName:
	set(_value):
		pass
	get:
		return _presentation_profile_id
var presentation_profile_revision: int:
	set(_value):
		pass
	get:
		return _presentation_profile_revision
var entries: Array[LootBatchEntry]:
	set(_value):
		pass
	get:
		var read_view: Array[LootBatchEntry] = []
		for entry: LootBatchEntry in _entries:
			read_view.append(LootBatchEntryScript.from_snapshot(entry.to_snapshot()))
		return read_view
var presentation_fixtures: Array[ReceivingFreightFixtureInstance]:
	set(_value):
		pass
	get:
		var read_view: Array[ReceivingFreightFixtureInstance] = []
		for fixture: ReceivingFreightFixtureInstance in _presentation_fixtures:
			read_view.append(FreightFixtureInstanceScript.from_snapshot(fixture.to_snapshot()))
		return read_view


static func create_committed(
	new_batch_id: String,
	new_source_kind: StringName,
	new_source_ref: String,
	new_target_bulk: int,
	new_actual_bulk: int,
	new_content_seed: int,
	new_presentation_seed: int,
	new_entries: Array[LootBatchEntry]
) -> LootBatch:
	if not _has_valid_content(
		new_batch_id, new_target_bulk, new_actual_bulk, new_entries
	):
		return null
	var owned_entries: Array[LootBatchEntry] = []
	for entry: LootBatchEntry in new_entries:
		owned_entries.append(LootBatchEntryScript.new(
			entry.entry_id, entry.item_instance_id, entry.definition_id
		))
	return _create_from_validated_values(
		new_batch_id,
		new_source_kind,
		new_source_ref,
		new_target_bulk,
		new_actual_bulk,
		new_content_seed,
		new_presentation_seed,
		STATE_CONTENT_COMMITTED,
		&"",
		0,
		owned_entries
	)


func commit_arrangement(
	transforms_by_entry_id: Dictionary,
	profile_id: StringName,
	profile_revision: int
) -> bool:
	if _preparation_state != STATE_CONTENT_COMMITTED:
		return false
	if profile_id == &"" or profile_revision <= 0:
		return false

	var remaining_count: int = 0
	var remaining_by_id: Dictionary = {}
	for entry: LootBatchEntry in _entries:
		if entry.remaining_in_batch:
			remaining_count += 1
			remaining_by_id[entry.entry_id] = entry
	if transforms_by_entry_id.size() != remaining_count:
		return false

	var validated_transforms: Dictionary = {}
	for key_value: Variant in transforms_by_entry_id:
		if typeof(key_value) != TYPE_STRING and typeof(key_value) != TYPE_STRING_NAME:
			return false
		var entry_id: String = String(key_value)
		if not remaining_by_id.has(entry_id):
			return false
		var transform_value: Variant = transforms_by_entry_id[key_value]
		if typeof(transform_value) != TYPE_TRANSFORM3D:
			return false
		var transform: Transform3D = transform_value as Transform3D
		if not _is_finite_transform(transform):
			return false
		validated_transforms[entry_id] = transform
	if validated_transforms.size() != remaining_count:
		return false

	for entry: LootBatchEntry in _entries:
		if not entry.remaining_in_batch:
			continue
		entry._commit_frozen_transform(validated_transforms[entry.entry_id] as Transform3D)
	_presentation_profile_id = profile_id
	_presentation_profile_revision = profile_revision
	_preparation_state = STATE_PREPARED
	return true


func commit_deck_layout(
	placements_by_entry_id: Dictionary,
	profile_id: StringName,
	profile_revision: int,
	fixtures: Array = [],
	profile: Resource = null
) -> bool:
	if _preparation_state != STATE_CONTENT_COMMITTED:
		return false
	if profile_id == &"" or profile_revision <= 0:
		return false

	var remaining_by_id: Dictionary = {}
	for entry: LootBatchEntry in _entries:
		if entry.remaining_in_batch:
			remaining_by_id[entry.entry_id] = entry
	if placements_by_entry_id.size() != remaining_by_id.size():
		return false

	var validated: Dictionary = {}
	var indices_by_group: Dictionary = {}
	var anchor_by_group: Dictionary = {}
	for key_value: Variant in placements_by_entry_id:
		if typeof(key_value) != TYPE_STRING and typeof(key_value) != TYPE_STRING_NAME:
			return false
		var entry_id := String(key_value)
		if entry_id.is_empty() or validated.has(entry_id) or not remaining_by_id.has(entry_id):
			return false
		var placement_value: Variant = placements_by_entry_id[key_value]
		if typeof(placement_value) != TYPE_DICTIONARY:
			return false
		var placement: Dictionary = placement_value as Dictionary
		var surface_value: Variant = placement.get("surface_id")
		var cell_value: Variant = placement.get("cell_origin")
		var quarter_value: Variant = placement.get("quarter_turns")
		var group_value: Variant = placement.get("stack_group_id")
		var index_value: Variant = placement.get("stack_index")
		var transform_value: Variant = placement.get("frozen_transform")
		if (
			(typeof(surface_value) != TYPE_STRING_NAME and typeof(surface_value) != TYPE_STRING)
			or typeof(cell_value) != TYPE_VECTOR2I
			or typeof(quarter_value) != TYPE_INT
			or typeof(group_value) != TYPE_STRING
			or typeof(index_value) != TYPE_INT
			or typeof(transform_value) != TYPE_TRANSFORM3D
		):
			return false
		var surface_id := StringName(surface_value)
		var cell_origin: Vector2i = cell_value as Vector2i
		var quarter_turns: int = _normalize_quarter_turns(int(quarter_value))
		var stack_group_id := String(group_value)
		var stack_index := int(index_value)
		var frozen_transform: Transform3D = transform_value as Transform3D
		if (
			surface_id == &""
			or cell_origin.x < 0
			or cell_origin.y < 0
			or stack_group_id.is_empty()
			or stack_index < 0
			or not _is_finite_transform(frozen_transform)
		):
			return false
		var group_indices: Dictionary = indices_by_group.get(stack_group_id, {}) as Dictionary
		if group_indices.has(stack_index):
			return false
		var anchor: Dictionary = anchor_by_group.get(stack_group_id, {}) as Dictionary
		if anchor.is_empty():
			anchor_by_group[stack_group_id] = {
				"surface_id": surface_id,
				"cell_origin": cell_origin,
			}
		elif anchor.get("surface_id") != surface_id or anchor.get("cell_origin") != cell_origin:
			return false
		group_indices[stack_index] = true
		indices_by_group[stack_group_id] = group_indices
		validated[entry_id] = {
			"surface_id": surface_id,
			"cell_origin": cell_origin,
			"quarter_turns": quarter_turns,
			"stack_group_id": stack_group_id,
			"stack_index": stack_index,
			"frozen_transform": frozen_transform,
		}
	if validated.size() != remaining_by_id.size():
		return false
	for group_value: Variant in indices_by_group.values():
		var group_indices: Dictionary = group_value as Dictionary
		for expected_index: int in range(group_indices.size()):
			if not group_indices.has(expected_index):
				return false

	var validated_fixtures: Array[ReceivingFreightFixtureInstance] = []
	for fixture_value: Variant in fixtures:
		if not fixture_value is ReceivingFreightFixtureInstance:
			return false
		var fixture: ReceivingFreightFixtureInstance = fixture_value as ReceivingFreightFixtureInstance
		var owned_fixture: ReceivingFreightFixtureInstance = FreightFixtureInstanceScript.from_snapshot(
			fixture.to_snapshot()
		)
		if owned_fixture == null:
			return false
		validated_fixtures.append(owned_fixture)
	if not _validate_fixture_commit(
		validated_fixtures, validated, profile_id, profile_revision, profile
	):
		return false

	for entry: LootBatchEntry in _entries:
		if not entry.remaining_in_batch:
			continue
		var placement: Dictionary = validated[entry.entry_id] as Dictionary
		entry._commit_deck_layout(
			placement["surface_id"] as StringName,
			placement["cell_origin"] as Vector2i,
			int(placement["quarter_turns"]),
			String(placement["stack_group_id"]),
			int(placement["stack_index"]),
			placement["frozen_transform"] as Transform3D
		)
	_presentation_profile_id = profile_id
	_presentation_profile_revision = profile_revision
	_presentation_fixtures = validated_fixtures
	_preparation_state = STATE_PREPARED
	return true


func create_item_instance(entry_id: String, catalog: ItemCatalog) -> ItemInstance:
	if catalog == null:
		return null
	var entry: LootBatchEntry = _find_entry(entry_id)
	if entry == null:
		return null
	var definition: ItemDefinition = catalog.get_definition_by_id(entry.definition_id)
	if definition == null:
		return null
	return ItemInstanceScript.new(definition, entry.item_instance_id)


func mark_entry_released(entry_id: String, item_instance_id: String) -> bool:
	var entry: LootBatchEntry = _find_entry(entry_id)
	if entry == null:
		return false
	if entry.item_instance_id != item_instance_id or not entry.remaining_in_batch:
		return false
	entry._mark_released()
	return true


func is_drained() -> bool:
	for entry: LootBatchEntry in _entries:
		if entry.remaining_in_batch:
			return false
	return true


func to_snapshot() -> Dictionary:
	var entry_snapshots: Array[Dictionary] = []
	for entry: LootBatchEntry in _entries:
		entry_snapshots.append(entry.to_snapshot())
	var fixture_snapshots: Array[Dictionary] = []
	for fixture: ReceivingFreightFixtureInstance in _presentation_fixtures:
		fixture_snapshots.append(fixture.to_snapshot())
	return {
		"batch_id": _batch_id,
		"source_kind": _source_kind,
		"source_ref": _source_ref,
		"target_bulk": _target_bulk,
		"actual_bulk": _actual_bulk,
		"content_seed": _content_seed,
		"presentation_seed": _presentation_seed,
		"preparation_state": _preparation_state,
		"presentation_profile_id": _presentation_profile_id,
		"presentation_profile_revision": _presentation_profile_revision,
		"presentation_fixtures": fixture_snapshots,
		"entries": entry_snapshots,
	}


static func from_snapshot(snapshot: Dictionary) -> LootBatch:
	if not _has_valid_batch_snapshot_fields(snapshot):
		return null

	var restored_entries: Array[LootBatchEntry] = []
	var entry_values: Array = snapshot["entries"] as Array
	for entry_value: Variant in entry_values:
		if typeof(entry_value) != TYPE_DICTIONARY:
			return null
		var entry: LootBatchEntry = LootBatchEntryScript.from_snapshot(
			entry_value as Dictionary
		)
		if entry == null:
			return null
		restored_entries.append(entry)
	var restored_fixtures: Array[ReceivingFreightFixtureInstance] = []
	var fixture_values: Array = snapshot.get("presentation_fixtures", []) as Array
	for fixture_value: Variant in fixture_values:
		if typeof(fixture_value) != TYPE_DICTIONARY:
			return null
		var fixture: ReceivingFreightFixtureInstance = FreightFixtureInstanceScript.from_snapshot(
			fixture_value as Dictionary
		)
		if fixture == null:
			return null
		restored_fixtures.append(fixture)

	var restored_batch_id: String = String(snapshot["batch_id"])
	var restored_target_bulk: int = int(snapshot["target_bulk"])
	var restored_actual_bulk: int = int(snapshot["actual_bulk"])
	if not _has_valid_content(
		restored_batch_id,
		restored_target_bulk,
		restored_actual_bulk,
		restored_entries
	):
		return null
	var restored_state: StringName = StringName(snapshot["preparation_state"])
	var restored_profile_id: StringName = StringName(snapshot["presentation_profile_id"])
	var restored_profile_revision: int = int(snapshot["presentation_profile_revision"])
	if not _has_consistent_preparation_snapshot(
		restored_state, restored_profile_id, restored_profile_revision, restored_entries,
		restored_fixtures
	):
		return null

	return _create_from_validated_values(
		restored_batch_id,
		StringName(snapshot["source_kind"]),
		String(snapshot["source_ref"]),
		restored_target_bulk,
		restored_actual_bulk,
		int(snapshot["content_seed"]),
		int(snapshot["presentation_seed"]),
		restored_state,
		restored_profile_id,
		restored_profile_revision,
		restored_entries,
		restored_fixtures
	)


func _find_entry(wanted_entry_id: String) -> LootBatchEntry:
	for entry: LootBatchEntry in _entries:
		if entry.entry_id == wanted_entry_id:
			return entry
	return null


static func _create_from_validated_values(
	new_batch_id: String,
	new_source_kind: StringName,
	new_source_ref: String,
	new_target_bulk: int,
	new_actual_bulk: int,
	new_content_seed: int,
	new_presentation_seed: int,
	new_preparation_state: StringName,
	new_profile_id: StringName,
	new_profile_revision: int,
	owned_entries: Array[LootBatchEntry],
	owned_fixtures: Array[ReceivingFreightFixtureInstance] = []
) -> LootBatch:
	var batch: LootBatch = LootBatch.new()
	batch._batch_id = new_batch_id
	batch._source_kind = new_source_kind
	batch._source_ref = new_source_ref
	batch._target_bulk = new_target_bulk
	batch._actual_bulk = new_actual_bulk
	batch._content_seed = new_content_seed
	batch._presentation_seed = new_presentation_seed
	batch._preparation_state = new_preparation_state
	batch._presentation_profile_id = new_profile_id
	batch._presentation_profile_revision = new_profile_revision
	batch._entries = owned_entries
	batch._presentation_fixtures = owned_fixtures
	return batch


static func _has_valid_content(
	wanted_batch_id: String,
	wanted_target_bulk: int,
	wanted_actual_bulk: int,
	wanted_entries: Array[LootBatchEntry]
) -> bool:
	if wanted_batch_id.is_empty() or wanted_target_bulk <= 0 or wanted_actual_bulk <= 0:
		return false
	if wanted_entries.is_empty():
		return false
	var entry_ids: Dictionary = {}
	var item_ids: Dictionary = {}
	for entry: LootBatchEntry in wanted_entries:
		if entry == null:
			return false
		if entry.entry_id.is_empty() or entry_ids.has(entry.entry_id):
			return false
		if entry.item_instance_id.is_empty() or item_ids.has(entry.item_instance_id):
			return false
		if entry.definition_id == &"":
			return false
		entry_ids[entry.entry_id] = true
		item_ids[entry.item_instance_id] = true
	return true


static func _has_valid_batch_snapshot_fields(snapshot: Dictionary) -> bool:
	if typeof(snapshot.get("batch_id")) != TYPE_STRING:
		return false
	var source_kind_value: Variant = snapshot.get("source_kind")
	if typeof(source_kind_value) != TYPE_STRING_NAME and typeof(source_kind_value) != TYPE_STRING:
		return false
	if typeof(snapshot.get("source_ref")) != TYPE_STRING:
		return false
	if typeof(snapshot.get("target_bulk")) != TYPE_INT:
		return false
	if typeof(snapshot.get("actual_bulk")) != TYPE_INT:
		return false
	if typeof(snapshot.get("content_seed")) != TYPE_INT:
		return false
	if typeof(snapshot.get("presentation_seed")) != TYPE_INT:
		return false
	var state_value: Variant = snapshot.get("preparation_state")
	if typeof(state_value) != TYPE_STRING_NAME and typeof(state_value) != TYPE_STRING:
		return false
	var profile_id_value: Variant = snapshot.get("presentation_profile_id")
	if typeof(profile_id_value) != TYPE_STRING_NAME and typeof(profile_id_value) != TYPE_STRING:
		return false
	if typeof(snapshot.get("presentation_profile_revision")) != TYPE_INT:
		return false
	if snapshot.has("presentation_fixtures") and typeof(snapshot.get("presentation_fixtures")) != TYPE_ARRAY:
		return false
	return typeof(snapshot.get("entries")) == TYPE_ARRAY


static func _has_consistent_preparation_snapshot(
	state: StringName,
	profile_id: StringName,
	profile_revision: int,
	restored_entries: Array[LootBatchEntry],
	restored_fixtures: Array[ReceivingFreightFixtureInstance]
) -> bool:
	if state == STATE_CONTENT_COMMITTED:
		if profile_id != &"" or profile_revision != 0 or not restored_fixtures.is_empty():
			return false
		for entry: LootBatchEntry in restored_entries:
			if entry.has_frozen_transform or entry.has_deck_layout:
				return false
		return true
	if state != STATE_PREPARED or profile_id == &"" or profile_revision <= 0:
		return false
	for entry: LootBatchEntry in restored_entries:
		if entry.remaining_in_batch and not entry.has_frozen_transform:
			return false
	return (
		_has_consistent_deck_snapshot(restored_entries)
		and _has_consistent_fixture_snapshot(restored_entries, restored_fixtures)
	)


static func _has_consistent_deck_snapshot(restored_entries: Array[LootBatchEntry]) -> bool:
	var deck_entry_count := 0
	var remaining_count := 0
	var remaining_deck_count := 0
	var indices_by_group: Dictionary = {}
	var anchor_by_group: Dictionary = {}
	for entry: LootBatchEntry in restored_entries:
		if entry.remaining_in_batch:
			remaining_count += 1
		if not entry.has_deck_layout:
			continue
		deck_entry_count += 1
		if entry.remaining_in_batch:
			remaining_deck_count += 1
		var group_id := entry.presentation_stack_group_id
		var indices: Dictionary = indices_by_group.get(group_id, {}) as Dictionary
		if indices.has(entry.presentation_stack_index):
			return false
		indices[entry.presentation_stack_index] = true
		indices_by_group[group_id] = indices
		var anchor: Dictionary = anchor_by_group.get(group_id, {}) as Dictionary
		if anchor.is_empty():
			anchor_by_group[group_id] = {
				"surface_id": entry.presentation_surface_id,
				"cell_origin": entry.presentation_cell_origin,
			}
		elif (
			anchor.get("surface_id") != entry.presentation_surface_id
			or anchor.get("cell_origin") != entry.presentation_cell_origin
		):
			return false
	if deck_entry_count == 0:
		return true
	if remaining_deck_count != remaining_count:
		return false
	for group_value: Variant in indices_by_group.values():
		var indices: Dictionary = group_value as Dictionary
		for expected_index: int in range(indices.size()):
			if not indices.has(expected_index):
				return false
	return true


static func _validate_fixture_commit(
	fixtures: Array[ReceivingFreightFixtureInstance],
	placements: Dictionary,
	profile_id: StringName,
	profile_revision: int,
	profile: Resource
) -> bool:
	if profile == null:
		return fixtures.is_empty()
	if (
		profile.get("profile_id") != profile_id
		or int(profile.get("revision")) != profile_revision
		or not (profile.call("validate") as PackedStringArray).is_empty()
	):
		return false

	var allowed_surfaces: Dictionary = {}
	var main_deck_spec: Resource = null
	for surface: Resource in profile.get("surfaces") as Array[Resource]:
		if surface == null or not bool(surface.get("enabled")):
			continue
		var surface_id: StringName = surface.get("surface_id") as StringName
		allowed_surfaces[surface_id] = true
		if surface_id == &"MainDeck":
			main_deck_spec = surface

	var definitions: Dictionary = {}
	for definition: Resource in profile.get("freight_fixture_definitions") as Array[Resource]:
		if definition != null and bool(definition.get("enabled")):
			definitions[definition.get("fixture_id") as StringName] = definition
	var sockets: Dictionary = {}
	for socket: Resource in profile.get("freight_fixture_sockets") as Array[Resource]:
		if socket != null and bool(socket.get("enabled")):
			sockets[socket.get("socket_id") as StringName] = socket

	var instance_ids: Dictionary = {}
	var surface_ids: Dictionary = {}
	var socket_ids: Dictionary = {}
	var definition_keys: Dictionary = {}
	var occupied_main_deck_cells: Dictionary = {}
	var referenced_surfaces: Dictionary = {}
	var crate_count := 0
	var pallet_count := 0
	var main_grid := Vector2i.ZERO
	if main_deck_spec != null:
		var cell_size_m := float(profile.get("cell_size_m"))
		main_grid = Vector2i(
			floori(float(main_deck_spec.get("usable_width_m")) / cell_size_m),
			floori(float(main_deck_spec.get("usable_depth_m")) / cell_size_m)
		)

	for fixture: ReceivingFreightFixtureInstance in fixtures:
		if fixture == null or not fixture.validate().is_empty():
			return false
		if (
			instance_ids.has(fixture.instance_id)
			or surface_ids.has(fixture.surface_id)
			or socket_ids.has(fixture.socket_id)
		):
			return false
		if not _is_stable_fixture_surface_id(fixture.surface_id, fixture.family):
			return false
		if not definitions.has(fixture.fixture_definition_id) or not sockets.has(fixture.socket_id):
			return false
		var definition: Resource = definitions[fixture.fixture_definition_id] as Resource
		var socket: Resource = sockets[fixture.socket_id] as Resource
		if (
			int(definition.get("family")) != fixture.family
			or int(socket.get("allowed_family")) != fixture.family
			or socket.get("main_deck_origin") != fixture.main_deck_origin
			or int(socket.get("quarter_turns")) != fixture.quarter_turns
		):
			return false
		var expected_footprint: Vector2i = definition.get("base_footprint") as Vector2i
		if fixture.quarter_turns % 2 == 1:
			expected_footprint = Vector2i(expected_footprint.y, expected_footprint.x)
		if fixture.base_footprint != expected_footprint:
			return false
		if main_deck_spec == null or fixture.main_deck_origin.x + fixture.base_footprint.x > main_grid.x or fixture.main_deck_origin.y + fixture.base_footprint.y > main_grid.y:
			return false
		var definition_key := "%d:%s" % [fixture.family, String(fixture.fixture_definition_id)]
		if definition_keys.has(definition_key):
			return false
		for row: int in range(fixture.main_deck_origin.y, fixture.main_deck_origin.y + fixture.base_footprint.y):
			for column: int in range(fixture.main_deck_origin.x, fixture.main_deck_origin.x + fixture.base_footprint.x):
				var cell := Vector2i(column, row)
				if occupied_main_deck_cells.has(cell):
					return false
				occupied_main_deck_cells[cell] = fixture.instance_id
		instance_ids[fixture.instance_id] = true
		surface_ids[fixture.surface_id] = true
		socket_ids[fixture.socket_id] = true
		definition_keys[definition_key] = true
		allowed_surfaces[fixture.surface_id] = true
		if fixture.family == ReceivingFreightFixtureDefinition.FixtureFamily.CRATE:
			crate_count += 1
		else:
			pallet_count += 1
	if crate_count > FreightFixturePolicyScript.MAX_CRATES or pallet_count > FreightFixturePolicyScript.MAX_PALLETS:
		return false

	for placement_value: Variant in placements.values():
		var placement: Dictionary = placement_value as Dictionary
		var surface_id: StringName = placement["surface_id"] as StringName
		if not allowed_surfaces.has(surface_id):
			return false
		if surface_ids.has(surface_id):
			referenced_surfaces[surface_id] = true
	for fixture: ReceivingFreightFixtureInstance in fixtures:
		if not referenced_surfaces.has(fixture.surface_id):
			return false
	return true


static func _has_consistent_fixture_snapshot(
	entries_to_check: Array[LootBatchEntry],
	fixtures: Array[ReceivingFreightFixtureInstance]
) -> bool:
	if fixtures.is_empty():
		return true
	var instance_ids: Dictionary = {}
	var surface_ids: Dictionary = {}
	var socket_ids: Dictionary = {}
	var definition_keys: Dictionary = {}
	var occupied_cells: Dictionary = {}
	var crate_count := 0
	var pallet_count := 0
	for fixture: ReceivingFreightFixtureInstance in fixtures:
		if fixture == null or not fixture.validate().is_empty():
			return false
		if instance_ids.has(fixture.instance_id) or surface_ids.has(fixture.surface_id) or socket_ids.has(fixture.socket_id):
			return false
		if not _is_stable_fixture_surface_id(fixture.surface_id, fixture.family):
			return false
		var definition_key := "%d:%s" % [fixture.family, String(fixture.fixture_definition_id)]
		if definition_keys.has(definition_key):
			return false
		for row: int in range(fixture.main_deck_origin.y, fixture.main_deck_origin.y + fixture.base_footprint.y):
			for column: int in range(fixture.main_deck_origin.x, fixture.main_deck_origin.x + fixture.base_footprint.x):
				var cell := Vector2i(column, row)
				if occupied_cells.has(cell):
					return false
				occupied_cells[cell] = true
		instance_ids[fixture.instance_id] = true
		surface_ids[fixture.surface_id] = true
		socket_ids[fixture.socket_id] = true
		definition_keys[definition_key] = true
		if fixture.family == ReceivingFreightFixtureDefinition.FixtureFamily.CRATE:
			crate_count += 1
		else:
			pallet_count += 1
	if crate_count > FreightFixturePolicyScript.MAX_CRATES or pallet_count > FreightFixturePolicyScript.MAX_PALLETS:
		return false
	var referenced_surfaces: Dictionary = {}
	for entry: LootBatchEntry in entries_to_check:
		if not entry.has_deck_layout:
			continue
		if entry.presentation_surface_id != &"MainDeck" and not surface_ids.has(entry.presentation_surface_id):
			return false
		if surface_ids.has(entry.presentation_surface_id):
			referenced_surfaces[entry.presentation_surface_id] = true
	for fixture: ReceivingFreightFixtureInstance in fixtures:
		if not referenced_surfaces.has(fixture.surface_id):
			return false
	return true


static func _is_stable_fixture_surface_id(surface_id: StringName, family: int) -> bool:
	if family == ReceivingFreightFixtureDefinition.FixtureFamily.CRATE:
		return surface_id in [&"Crate_00", &"Crate_01", &"Crate_02"]
	if family == ReceivingFreightFixtureDefinition.FixtureFamily.PALLET:
		return surface_id in [&"Pallet_00", &"Pallet_01"]
	return false


static func _is_finite_transform(value: Transform3D) -> bool:
	return (
		value.origin.is_finite()
		and value.basis.x.is_finite()
		and value.basis.y.is_finite()
		and value.basis.z.is_finite()
	)


static func _normalize_quarter_turns(value: int) -> int:
	return ((value % 4) + 4) % 4
