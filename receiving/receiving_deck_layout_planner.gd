extends RefCounted
class_name ReceivingDeckLayoutPlanner

const DiagnosticsScript = preload("res://receiving/receiving_deck_layout_diagnostics.gd")
const DeckProfileScript = preload("res://receiving/receiving_deck_profile.gd")
const DeckPoseScript = preload("res://receiving/receiving_deck_item_pose.gd")
const DeckSurfaceSpecScript = preload("res://receiving/receiving_deck_surface_spec.gd")
const FreightFixtureInstanceScript = preload("res://receiving/receiving_freight_fixture_instance.gd")
const FreightFixturePolicyScript = preload("res://receiving/receiving_freight_fixture_policy.gd")
const StorageStackScript = preload("res://storage_stack.gd")

const MAX_STACK_USED_FRACTION: float = 0.95
const SURFACE_Y_OFFSET_M: float = 0.012
const FAILURE_INVALID_INPUT: StringName = &"invalid_layout_input"
const FAILURE_INSUFFICIENT_CAPACITY: StringName = &"insufficient_layout_capacity"
const FAILURE_COMMIT_REJECTED: StringName = &"layout_commit_rejected"

enum FixtureMode {
	BARE,
	CRATES_ALLOWED,
	PALLETS_ALLOWED,
	MIXED,
}


func prepare(
	batch: LootBatch,
	catalog: ItemCatalog,
	profile: Resource,
	fixture_mode: FixtureMode = FixtureMode.BARE
):
	var diagnostics = DiagnosticsScript.new()
	diagnostics.fixture_mode = fixture_mode
	if not _inputs_are_valid(batch, catalog, profile, fixture_mode):
		diagnostics.mark_failure(FAILURE_INVALID_INPUT, 0)
		return diagnostics
	var maximum_attempts := int(profile.get("max_layout_attempts"))
	for attempt_index: int in range(maximum_attempts):
		var attempt: Dictionary = _build_attempt(
			batch, catalog, profile, attempt_index, fixture_mode
		)
		if attempt.is_empty():
			continue
		var placements: Dictionary = attempt["placements"] as Dictionary
		var fixtures: Array = attempt["fixtures"] as Array
		if batch.commit_deck_layout(
			placements,
			profile.get("profile_id") as StringName,
			int(profile.get("revision")),
			fixtures,
			profile
		):
			diagnostics.mark_success(
				attempt_index + 1,
				placements,
				fixtures,
				attempt["surface_item_counts"] as Dictionary
			)
			return diagnostics
		diagnostics.mark_failure(FAILURE_COMMIT_REJECTED, attempt_index + 1)
		return diagnostics
	diagnostics.mark_failure(FAILURE_INSUFFICIENT_CAPACITY, maximum_attempts)
	return diagnostics


func _inputs_are_valid(
	batch: LootBatch,
	catalog: ItemCatalog,
	profile: Resource,
	fixture_mode: int
) -> bool:
	if (
		batch == null
		or catalog == null
		or profile == null
		or profile.get_script() != DeckProfileScript
		or batch.preparation_state != LootBatch.STATE_CONTENT_COMMITTED
		or not catalog.get_validation_errors().is_empty()
	):
		return false
	if fixture_mode < FixtureMode.BARE or fixture_mode > FixtureMode.MIXED:
		return false
	if not (profile.call("validate") as PackedStringArray).is_empty():
		return false
	var remaining_count := 0
	for entry: LootBatchEntry in batch.entries:
		if not entry.remaining_in_batch:
			continue
		remaining_count += 1
		if batch.create_item_instance(entry.entry_id, catalog) == null:
			return false
	if remaining_count <= 0:
		return false
	for surface: Resource in profile.get("surfaces") as Array[Resource]:
		if surface != null and surface.get_script() == DeckSurfaceSpecScript and bool(surface.get("enabled")):
			return true
	return false


func _build_attempt(
	batch: LootBatch,
	catalog: ItemCatalog,
	profile: Resource,
	attempt_index: int,
	fixture_mode: FixtureMode
) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = _attempt_seed(batch.presentation_seed, attempt_index)
	var attempt_state: Dictionary = _create_attempt_state(
		profile, attempt_index, rng, fixture_mode
	)
	if attempt_state.is_empty():
		return {}
	var entries: Array[LootBatchEntry] = []
	for entry: LootBatchEntry in batch.entries:
		if entry.remaining_in_batch:
			entries.append(entry)
	_shuffle_entries(entries, rng)
	if fixture_mode != FixtureMode.BARE:
		_prioritize_large_positions(entries, batch, catalog, rng.seed)
	var scan_left_to_right := (rng.randi() & 1) == 0
	var placements: Dictionary = {}
	for entry: LootBatchEntry in entries:
		var item: ItemInstance = batch.create_item_instance(entry.entry_id, catalog)
		var orientation_records: Array[Dictionary] = _orientation_records(item, rng)
		if orientation_records.is_empty():
			return {}
		var placement: Dictionary = _place_entry(
			item, orientation_records, attempt_state, scan_left_to_right, rng
		)
		if placement.is_empty():
			return {}
		placements[entry.entry_id] = placement
	var surface_item_counts: Dictionary = {}
	for placement_value: Variant in placements.values():
		var surface_id: StringName = (placement_value as Dictionary)["surface_id"] as StringName
		surface_item_counts[surface_id] = int(surface_item_counts.get(surface_id, 0)) + 1
	return {
		"placements": placements,
		"fixtures": (attempt_state["fixtures"] as Array).duplicate(),
		"surface_item_counts": surface_item_counts,
	}


func _create_attempt_state(
	profile: Resource,
	attempt_index: int,
	rng: RandomNumberGenerator,
	fixture_mode: FixtureMode
) -> Dictionary:
	var enabled_specs: Array[Resource] = []
	for surface_spec: Resource in profile.get("surfaces") as Array[Resource]:
		if surface_spec != null and bool(surface_spec.get("enabled")):
			enabled_specs.append(surface_spec)
	if enabled_specs.is_empty():
		return {}
	var surfaces: Dictionary = {}
	var surface_order: Array[StringName] = []
	var start_index := attempt_index % enabled_specs.size()
	for offset: int in range(enabled_specs.size()):
		var spec: Resource = enabled_specs[(start_index + offset) % enabled_specs.size()]
		var surface_id: StringName = spec.get("surface_id") as StringName
		surfaces[surface_id] = _new_surface_state(
			surface_id,
			float(profile.get("cell_size_m")),
			float(spec.get("usable_width_m")),
			float(spec.get("usable_depth_m")),
			float(spec.get("stack_clearance_m")),
			spec.get("local_transform") as Transform3D
		)
		surface_order.append(surface_id)
	var definitions_by_family: Dictionary = {
		ReceivingFreightFixtureDefinition.FixtureFamily.CRATE: [],
		ReceivingFreightFixtureDefinition.FixtureFamily.PALLET: [],
	}
	if fixture_mode != FixtureMode.BARE:
		for definition: Resource in profile.get("freight_fixture_definitions") as Array[Resource]:
			if definition != null and bool(definition.get("enabled")):
				(definitions_by_family[int(definition.get("family"))] as Array).append(definition)
	var sockets_by_family: Dictionary = {
		ReceivingFreightFixtureDefinition.FixtureFamily.CRATE: [],
		ReceivingFreightFixtureDefinition.FixtureFamily.PALLET: [],
	}
	if fixture_mode != FixtureMode.BARE:
		for socket: Resource in profile.get("freight_fixture_sockets") as Array[Resource]:
			if socket != null and bool(socket.get("enabled")):
				(sockets_by_family[int(socket.get("allowed_family"))] as Array).append(socket)
		_shuffle_variants(definitions_by_family[ReceivingFreightFixtureDefinition.FixtureFamily.CRATE] as Array, rng)
		_shuffle_variants(definitions_by_family[ReceivingFreightFixtureDefinition.FixtureFamily.PALLET] as Array, rng)
		_shuffle_variants(sockets_by_family[ReceivingFreightFixtureDefinition.FixtureFamily.CRATE] as Array, rng)
		_shuffle_variants(sockets_by_family[ReceivingFreightFixtureDefinition.FixtureFamily.PALLET] as Array, rng)
	return {
		"surfaces": surfaces,
		"surface_order": surface_order,
		"main_deck_id": &"MainDeck" if surfaces.has(&"MainDeck") else surface_order[0],
		"fixture_mode": fixture_mode,
		"fixtures": [],
		"fixture_surface_ids": {
			ReceivingFreightFixtureDefinition.FixtureFamily.CRATE: [],
			ReceivingFreightFixtureDefinition.FixtureFamily.PALLET: [],
		},
		"definitions_by_family": definitions_by_family,
		"sockets_by_family": sockets_by_family,
		"used_definition_ids": {},
		"used_socket_ids": {},
		"crate_count": 0,
		"pallet_count": 0,
	}


func _new_surface_state(
	surface_id: StringName,
	cell_size_m: float,
	usable_width_m: float,
	usable_depth_m: float,
	stack_clearance_m: float,
	local_transform: Transform3D
) -> Dictionary:
	var grid_size := Vector2i(
		maxi(1, floori(usable_width_m / cell_size_m)),
		maxi(1, floori(usable_depth_m / cell_size_m))
	)
	var cells: Array[String] = []
	cells.resize(grid_size.x * grid_size.y)
	cells.fill("")
	var stack_order: Array[String] = []
	return {
		"surface_id": surface_id,
		"cell_size_m": cell_size_m,
		"grid_size": grid_size,
		"usable_size_m": Vector2(float(grid_size.x) * cell_size_m, float(grid_size.y) * cell_size_m),
		"stack_clearance_m": stack_clearance_m,
		"local_transform": local_transform,
		"cells": cells,
		"stacks": {},
		"stack_order": stack_order,
		"next_stack_number": 0,
	}


func _place_entry(
	item: ItemInstance,
	orientation_records: Array[Dictionary],
	attempt_state: Dictionary,
	scan_left_to_right: bool,
	rng: RandomNumberGenerator
) -> Dictionary:
	var mode: FixtureMode = int(attempt_state["fixture_mode"]) as FixtureMode
	if mode == FixtureMode.BARE:
		var bare_placement := _try_append_stack(orientation_records, attempt_state)
		if bare_placement.is_empty():
			bare_placement = _try_empty_placement(
				orientation_records, attempt_state, scan_left_to_right
			)
		return bare_placement

	var main_deck_ids: Array[StringName] = [attempt_state["main_deck_id"] as StringName]
	var band := FreightFixturePolicyScript.size_band(item.definition)
	var crate_allowed := mode == FixtureMode.CRATES_ALLOWED or mode == FixtureMode.MIXED
	var pallet_allowed := mode == FixtureMode.PALLETS_ALLOWED or mode == FixtureMode.MIXED
	if band == ReceivingFreightFixturePolicy.SizeBand.SMALL:
		if crate_allowed and FreightFixturePolicyScript.is_crate_eligible(item.definition):
			var crate_placement := _try_existing_then_activate(
				orientation_records,
				ReceivingFreightFixtureDefinition.FixtureFamily.CRATE,
				attempt_state,
				scan_left_to_right,
				rng
			)
			if not crate_placement.is_empty():
				return crate_placement
		var floor_placement := _try_place_on_surfaces(
			orientation_records, main_deck_ids, attempt_state, scan_left_to_right
		)
		if not floor_placement.is_empty():
			return floor_placement
		if pallet_allowed:
			return _try_existing_then_activate(
				orientation_records,
				ReceivingFreightFixtureDefinition.FixtureFamily.PALLET,
				attempt_state,
				scan_left_to_right,
				rng
			)
		return {}
	if band == ReceivingFreightFixturePolicy.SizeBand.MEDIUM:
		var medium_floor := _try_place_on_surfaces(
			orientation_records, main_deck_ids, attempt_state, scan_left_to_right
		)
		if not medium_floor.is_empty():
			return medium_floor
		if pallet_allowed:
			return _try_existing_then_activate(
				orientation_records,
				ReceivingFreightFixtureDefinition.FixtureFamily.PALLET,
				attempt_state,
				scan_left_to_right,
				rng
			)
		return {}
	if pallet_allowed:
		var pallet_placement := _try_existing_then_activate(
			orientation_records,
			ReceivingFreightFixtureDefinition.FixtureFamily.PALLET,
			attempt_state,
			scan_left_to_right,
			rng
		)
		if not pallet_placement.is_empty():
			return pallet_placement
	return _try_place_on_surfaces(
		orientation_records, main_deck_ids, attempt_state, scan_left_to_right
	)


func _try_existing_then_activate(
	orientation_records: Array[Dictionary],
	family: int,
	attempt_state: Dictionary,
	scan_left_to_right: bool,
	rng: RandomNumberGenerator
) -> Dictionary:
	var fixture_surface_ids: Dictionary = attempt_state["fixture_surface_ids"] as Dictionary
	var active_ids: Array = fixture_surface_ids[family] as Array
	var placement := _try_place_on_surfaces(
		orientation_records, active_ids, attempt_state, scan_left_to_right
	)
	if not placement.is_empty():
		return placement
	return _try_activate_fixture(
		orientation_records, family, attempt_state, scan_left_to_right, rng
	)


func _try_place_on_surfaces(
	orientation_records: Array[Dictionary],
	surface_ids: Array,
	attempt_state: Dictionary,
	scan_left_to_right: bool
) -> Dictionary:
	var placement := _try_append_stack_on_surfaces(
		orientation_records, surface_ids, attempt_state
	)
	if not placement.is_empty():
		return placement
	return _try_empty_on_surfaces(
		orientation_records, surface_ids, attempt_state, scan_left_to_right
	)


func _try_append_stack_on_surfaces(
	orientation_records: Array[Dictionary],
	surface_ids: Array,
	attempt_state: Dictionary
) -> Dictionary:
	var surfaces: Dictionary = attempt_state["surfaces"] as Dictionary
	for surface_id: StringName in surface_ids:
		if not surfaces.has(surface_id):
			continue
		var surface_state: Dictionary = surfaces[surface_id] as Dictionary
		var stacks: Dictionary = surface_state["stacks"] as Dictionary
		for stack_id: String in surface_state["stack_order"] as Array[String]:
			var stack: StorageStack = stacks[stack_id] as StorageStack
			if stack == null or not stack.is_auto_coherent():
				continue
			for orientation: Dictionary in orientation_records:
				var candidate: StorageStack.Entry = orientation["entry"] as StorageStack.Entry
				if candidate.auto_stack_group == &"" or candidate.auto_stack_group != stack.entries[0].auto_stack_group:
					continue
				var base_position := _local_placement_position(surface_state, stack.surface_origin, stack.base_footprint)
				var physical_fit: Dictionary = stack.find_manual_append(
					candidate,
					float(surface_state["stack_clearance_m"]) * MAX_STACK_USED_FRACTION,
					base_position.y
				)
				if not bool(physical_fit.get("valid", false)):
					continue
				var stack_index := stack.entries.size()
				stack.entries.append(candidate)
				return _placement_record(
					surface_id, stack.surface_origin, int(orientation["quarter_turns"]),
					stack_id, stack_index, float(physical_fit["host_y_m"]), surface_state
				)
	return {}


func _try_empty_on_surfaces(
	orientation_records: Array[Dictionary],
	surface_ids: Array,
	attempt_state: Dictionary,
	scan_left_to_right: bool
) -> Dictionary:
	var surfaces: Dictionary = attempt_state["surfaces"] as Dictionary
	for surface_id: StringName in surface_ids:
		if not surfaces.has(surface_id):
			continue
		var surface_state: Dictionary = surfaces[surface_id] as Dictionary
		for orientation: Dictionary in orientation_records:
			var candidate: StorageStack.Entry = orientation["entry"] as StorageStack.Entry
			var origin := _find_front_to_rear_fit(surface_state, candidate.footprint, scan_left_to_right)
			if origin.x < 0:
				continue
			var group_number := int(surface_state["next_stack_number"])
			var stack_id := "%s:stack_%04d" % [String(surface_id), group_number]
			var host_y_m := _local_placement_position(surface_state, origin, candidate.footprint).y
			if host_y_m + candidate.aligned_bounds.end.y > float(surface_state["stack_clearance_m"]):
				continue
			_reserve(surface_state, stack_id, origin, candidate.footprint)
			var stack: StorageStack = StorageStackScript.new()
			stack.stack_id = stack_id
			stack.surface_origin = origin
			stack.base_footprint = candidate.footprint
			stack.entries.append(candidate)
			(surface_state["stacks"] as Dictionary)[stack_id] = stack
			(surface_state["stack_order"] as Array[String]).append(stack_id)
			surface_state["next_stack_number"] = group_number + 1
			return _placement_record(
				surface_id, origin, int(orientation["quarter_turns"]),
				stack_id, 0, host_y_m, surface_state
			)
	return {}


func _try_activate_fixture(
	orientation_records: Array[Dictionary],
	family: int,
	attempt_state: Dictionary,
	scan_left_to_right: bool,
	_rng: RandomNumberGenerator
) -> Dictionary:
	var count_key := "crate_count" if family == ReceivingFreightFixtureDefinition.FixtureFamily.CRATE else "pallet_count"
	var maximum := (
		FreightFixturePolicyScript.MAX_CRATES
		if family == ReceivingFreightFixtureDefinition.FixtureFamily.CRATE
		else FreightFixturePolicyScript.MAX_PALLETS
	)
	var current_count := int(attempt_state[count_key])
	if current_count >= maximum:
		return {}
	var definitions_by_family: Dictionary = attempt_state["definitions_by_family"] as Dictionary
	var sockets_by_family: Dictionary = attempt_state["sockets_by_family"] as Dictionary
	var definitions: Array = definitions_by_family[family] as Array
	var sockets: Array = sockets_by_family[family] as Array
	var used_definition_ids: Dictionary = attempt_state["used_definition_ids"] as Dictionary
	var used_socket_ids: Dictionary = attempt_state["used_socket_ids"] as Dictionary
	var surfaces: Dictionary = attempt_state["surfaces"] as Dictionary
	var main_deck_id: StringName = attempt_state["main_deck_id"] as StringName
	if not surfaces.has(main_deck_id):
		return {}
	var main_surface: Dictionary = surfaces[main_deck_id] as Dictionary
	for definition_value: Variant in definitions:
		var definition: Resource = definition_value as Resource
		var definition_id: StringName = definition.get("fixture_id") as StringName
		if used_definition_ids.has(definition_id):
			continue
		for socket_value: Variant in sockets:
			var socket: Resource = socket_value as Resource
			var socket_id: StringName = socket.get("socket_id") as StringName
			if used_socket_ids.has(socket_id):
				continue
			var quarter_turns := int(socket.get("quarter_turns"))
			var base_footprint: Vector2i = definition.get("base_footprint") as Vector2i
			if quarter_turns % 2 == 1:
				base_footprint = Vector2i(base_footprint.y, base_footprint.x)
			var origin: Vector2i = socket.get("main_deck_origin") as Vector2i
			if not _can_place(main_surface, origin, base_footprint):
				continue
			var prefix := "Crate" if family == ReceivingFreightFixtureDefinition.FixtureFamily.CRATE else "Pallet"
			var surface_id := StringName("%s_%02d" % [prefix, current_count])
			var instance_id := "receiving_fixture:%s" % String(surface_id)
			var owner_key := "__fixture__:%s" % instance_id
			var local_position := _local_placement_position(main_surface, origin, base_footprint)
			local_position.y = 0.0
			var fixture_basis := Basis(Vector3.UP, float(quarter_turns) * PI * 0.5)
			var fixture_transform := (
				(main_surface["local_transform"] as Transform3D)
				* Transform3D(fixture_basis, local_position)
			)
			var fixture = FreightFixtureInstanceScript.create(
				instance_id,
				definition_id,
				family,
				socket_id,
				surface_id,
				origin,
				quarter_turns,
				base_footprint,
				fixture_transform
			)
			if fixture == null:
				continue
			var item_surface_transform := (
				fixture_transform
				* (definition.get("item_surface_local_transform") as Transform3D)
			)
			var fixture_surface := _new_surface_state(
				surface_id,
				float(main_surface["cell_size_m"]),
				float(definition.get("item_surface_usable_width_m")),
				float(definition.get("item_surface_usable_depth_m")),
				float(definition.get("item_surface_stack_clearance_m")),
				item_surface_transform
			)
			_reserve(main_surface, owner_key, origin, base_footprint)
			surfaces[surface_id] = fixture_surface
			var candidate_ids: Array[StringName] = [surface_id]
			var placement := _try_place_on_surfaces(
				orientation_records, candidate_ids, attempt_state, scan_left_to_right
			)
			if placement.is_empty():
				surfaces.erase(surface_id)
				_unreserve(main_surface, owner_key)
				continue
			(attempt_state["fixtures"] as Array).append(fixture)
			var fixture_surface_ids: Dictionary = attempt_state["fixture_surface_ids"] as Dictionary
			(fixture_surface_ids[family] as Array).append(surface_id)
			used_definition_ids[definition_id] = true
			used_socket_ids[socket_id] = true
			attempt_state[count_key] = current_count + 1
			return placement
	return {}


func _unreserve(surface_state: Dictionary, owner_key: String) -> void:
	var cells: Array[String] = surface_state["cells"] as Array[String]
	for index: int in range(cells.size()):
		if cells[index] == owner_key:
			cells[index] = ""


func _try_append_stack(orientation_records: Array[Dictionary], attempt_state: Dictionary) -> Dictionary:
	return _try_append_stack_on_surfaces(
		orientation_records, attempt_state["surface_order"] as Array, attempt_state
	)


func _try_empty_placement(
	orientation_records: Array[Dictionary],
	attempt_state: Dictionary,
	scan_left_to_right: bool
) -> Dictionary:
	return _try_empty_on_surfaces(
		orientation_records,
		attempt_state["surface_order"] as Array,
		attempt_state,
		scan_left_to_right
	)


func _find_front_to_rear_fit(surface_state: Dictionary, footprint: Vector2i, left_to_right: bool) -> Vector2i:
	var grid: Vector2i = surface_state["grid_size"] as Vector2i
	if footprint.x > grid.x or footprint.y > grid.y:
		return Vector2i(-1, -1)
	var maximum_row := grid.y - footprint.y
	var maximum_column := grid.x - footprint.x
	for row: int in range(maximum_row, -1, -1):
		if left_to_right:
			for column: int in range(maximum_column + 1):
				var origin := Vector2i(column, row)
				if _can_place(surface_state, origin, footprint):
					return origin
		else:
			for column: int in range(maximum_column, -1, -1):
				var origin := Vector2i(column, row)
				if _can_place(surface_state, origin, footprint):
					return origin
	return Vector2i(-1, -1)


func _can_place(surface_state: Dictionary, origin: Vector2i, footprint: Vector2i) -> bool:
	var grid: Vector2i = surface_state["grid_size"] as Vector2i
	if origin.x < 0 or origin.y < 0 or origin.x + footprint.x > grid.x or origin.y + footprint.y > grid.y:
		return false
	var cells: Array[String] = surface_state["cells"] as Array[String]
	for row: int in range(origin.y, origin.y + footprint.y):
		for column: int in range(origin.x, origin.x + footprint.x):
			if not cells[row * grid.x + column].is_empty():
				return false
	return true


func _reserve(surface_state: Dictionary, stack_id: String, origin: Vector2i, footprint: Vector2i) -> void:
	var grid: Vector2i = surface_state["grid_size"] as Vector2i
	var cells: Array[String] = surface_state["cells"] as Array[String]
	for row: int in range(origin.y, origin.y + footprint.y):
		for column: int in range(origin.x, origin.x + footprint.x):
			cells[row * grid.x + column] = stack_id


func _local_placement_position(surface_state: Dictionary, origin: Vector2i, footprint: Vector2i) -> Vector3:
	var usable_size: Vector2 = surface_state["usable_size_m"] as Vector2
	var cell_size_m := float(surface_state["cell_size_m"])
	return Vector3(
		-usable_size.x * 0.5 + (float(origin.x) + float(footprint.x) * 0.5) * cell_size_m,
		SURFACE_Y_OFFSET_M,
		-usable_size.y * 0.5 + (float(origin.y) + float(footprint.y) * 0.5) * cell_size_m
	)


func _orientation_records(item: ItemInstance, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var even_quarter_turns := 0 if (rng.randi() & 1) == 0 else 2
	var odd_quarter_turns := 1 if (rng.randi() & 1) == 0 else 3
	var even := _orientation_record(item, even_quarter_turns)
	var odd := _orientation_record(item, odd_quarter_turns)
	if even.is_empty() or odd.is_empty():
		return []
	var result: Array[Dictionary] = []
	if (rng.randi() & 1) == 0:
		result.append(even)
		result.append(odd)
	else:
		result.append(odd)
		result.append(even)
	return result


func _orientation_record(item: ItemInstance, quarter_turns: int) -> Dictionary:
	var measured: Dictionary = DeckPoseScript.measure_item(item, quarter_turns)
	if not bool(measured.get("valid", false)):
		return {}
	var storage_entry: StorageStack.Entry = StorageStackScript.create_entry(
		item, measured["footprint"] as Vector2i,
		bool(measured["packing_rotated"]), measured["aligned_bounds"] as AABB
	)
	return {"quarter_turns": quarter_turns, "entry": storage_entry}


func _placement_record(
	surface_id: StringName,
	cell_origin: Vector2i,
	quarter_turns: int,
	stack_group_id: String,
	stack_index: int,
	host_y_m: float,
	surface_state: Dictionary
) -> Dictionary:
	var stacks: Dictionary = surface_state["stacks"] as Dictionary
	var stack: StorageStack = stacks[stack_group_id] as StorageStack
	var local_position := _local_placement_position(surface_state, cell_origin, stack.base_footprint)
	local_position.y = host_y_m
	var outer_yaw := PI if DeckPoseScript.normalize_quarter_turns(quarter_turns) >= 2 else 0.0
	var local_item_transform := Transform3D(Basis(Vector3.UP, outer_yaw), local_position)
	return {
		"surface_id": surface_id,
		"cell_origin": cell_origin,
		"quarter_turns": DeckPoseScript.normalize_quarter_turns(quarter_turns),
		"stack_group_id": stack_group_id,
		"stack_index": stack_index,
		"frozen_transform": (surface_state["local_transform"] as Transform3D) * local_item_transform,
	}


func _shuffle_entries(entries: Array[LootBatchEntry], rng: RandomNumberGenerator) -> void:
	for index: int in range(entries.size() - 1, 0, -1):
		var other := rng.randi_range(0, index)
		var temporary: LootBatchEntry = entries[index]
		entries[index] = entries[other]
		entries[other] = temporary


func _shuffle_variants(values: Array, rng: RandomNumberGenerator) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var other := rng.randi_range(0, index)
		var temporary: Variant = values[index]
		values[index] = values[other]
		values[other] = temporary


func _prioritize_large_positions(
	entries: Array[LootBatchEntry],
	batch: LootBatch,
	catalog: ItemCatalog,
	attempt_seed: int
) -> void:
	var large_positions: Array[int] = []
	var large_records: Array[Dictionary] = []
	for index: int in range(entries.size()):
		var entry: LootBatchEntry = entries[index]
		var item: ItemInstance = batch.create_item_instance(entry.entry_id, catalog)
		if item == null or FreightFixturePolicyScript.size_band(item.definition) != ReceivingFreightFixturePolicy.SizeBand.LARGE:
			continue
		large_positions.append(index)
		large_records.append({
			"entry": entry,
			"area": FreightFixturePolicyScript.footprint_area(item.definition),
			"tie": String(entry.entry_id).hash() ^ attempt_seed,
		})
	large_records.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			if int(a["area"]) != int(b["area"]):
				return int(a["area"]) > int(b["area"])
			return int(a["tie"]) < int(b["tie"])
	)
	for position_index: int in range(large_positions.size()):
		entries[large_positions[position_index]] = large_records[position_index]["entry"] as LootBatchEntry


func _attempt_seed(presentation_seed: int, attempt_index: int) -> int:
	return presentation_seed ^ ((attempt_index + 1) * 1103515245)
