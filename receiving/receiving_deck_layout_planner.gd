extends RefCounted
class_name ReceivingDeckLayoutPlanner

const DiagnosticsScript = preload("res://receiving/receiving_deck_layout_diagnostics.gd")
const DeckProfileScript = preload("res://receiving/receiving_deck_profile.gd")
const DeckPoseScript = preload("res://receiving/receiving_deck_item_pose.gd")
const DeckSurfaceSpecScript = preload("res://receiving/receiving_deck_surface_spec.gd")
const StorageStackScript = preload("res://storage_stack.gd")

const MAX_STACK_USED_FRACTION: float = 0.95
const SURFACE_Y_OFFSET_M: float = 0.012
const FAILURE_INVALID_INPUT: StringName = &"invalid_layout_input"
const FAILURE_INSUFFICIENT_CAPACITY: StringName = &"insufficient_layout_capacity"
const FAILURE_COMMIT_REJECTED: StringName = &"layout_commit_rejected"


func prepare(batch: LootBatch, catalog: ItemCatalog, profile: Resource):
	var diagnostics = DiagnosticsScript.new()
	if not _inputs_are_valid(batch, catalog, profile):
		diagnostics.mark_failure(FAILURE_INVALID_INPUT, 0)
		return diagnostics
	var maximum_attempts := int(profile.get("max_layout_attempts"))
	for attempt_index: int in range(maximum_attempts):
		var placements: Dictionary = _build_attempt(batch, catalog, profile, attempt_index)
		if placements.is_empty():
			continue
		if batch.commit_deck_layout(
			placements,
			profile.get("profile_id") as StringName,
			int(profile.get("revision"))
		):
			diagnostics.mark_success(attempt_index + 1, placements)
			return diagnostics
		diagnostics.mark_failure(FAILURE_COMMIT_REJECTED, attempt_index + 1)
		return diagnostics
	diagnostics.mark_failure(FAILURE_INSUFFICIENT_CAPACITY, maximum_attempts)
	return diagnostics


func _inputs_are_valid(batch: LootBatch, catalog: ItemCatalog, profile: Resource) -> bool:
	if (
		batch == null
		or catalog == null
		or profile == null
		or profile.get_script() != DeckProfileScript
		or batch.preparation_state != LootBatch.STATE_CONTENT_COMMITTED
		or not catalog.get_validation_errors().is_empty()
	):
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


func _build_attempt(batch: LootBatch, catalog: ItemCatalog, profile: Resource, attempt_index: int) -> Dictionary:
	var attempt_state: Dictionary = _create_attempt_state(profile, attempt_index)
	if attempt_state.is_empty():
		return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = _attempt_seed(batch.presentation_seed, attempt_index)
	var entries: Array[LootBatchEntry] = []
	for entry: LootBatchEntry in batch.entries:
		if entry.remaining_in_batch:
			entries.append(entry)
	_shuffle_entries(entries, rng)
	var scan_left_to_right := (rng.randi() & 1) == 0
	var placements: Dictionary = {}
	for entry: LootBatchEntry in entries:
		var item: ItemInstance = batch.create_item_instance(entry.entry_id, catalog)
		var orientation_records: Array[Dictionary] = _orientation_records(item, rng)
		if orientation_records.is_empty():
			return {}
		var placement: Dictionary = _try_append_stack(orientation_records, attempt_state)
		if placement.is_empty():
			placement = _try_empty_placement(orientation_records, attempt_state, scan_left_to_right)
		if placement.is_empty():
			return {}
		placements[entry.entry_id] = placement
	return placements


func _create_attempt_state(profile: Resource, attempt_index: int) -> Dictionary:
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
		var cell_size_m := float(profile.get("cell_size_m"))
		var grid_size := Vector2i(
			maxi(1, floori(float(spec.get("usable_width_m")) / cell_size_m)),
			maxi(1, floori(float(spec.get("usable_depth_m")) / cell_size_m))
		)
		var cells: Array[String] = []
		cells.resize(grid_size.x * grid_size.y)
		cells.fill("")
		var stack_order: Array[String] = []
		surfaces[surface_id] = {
			"spec": spec,
			"cell_size_m": cell_size_m,
			"grid_size": grid_size,
			"usable_size_m": Vector2(float(grid_size.x) * cell_size_m, float(grid_size.y) * cell_size_m),
			"stack_clearance_m": float(spec.get("stack_clearance_m")),
			"cells": cells,
			"stacks": {},
			"stack_order": stack_order,
			"next_stack_number": 0,
		}
		surface_order.append(surface_id)
	return {"surfaces": surfaces, "surface_order": surface_order}


func _try_append_stack(orientation_records: Array[Dictionary], attempt_state: Dictionary) -> Dictionary:
	var surfaces: Dictionary = attempt_state["surfaces"] as Dictionary
	for surface_id: StringName in attempt_state["surface_order"] as Array[StringName]:
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


func _try_empty_placement(
	orientation_records: Array[Dictionary],
	attempt_state: Dictionary,
	scan_left_to_right: bool
) -> Dictionary:
	var surfaces: Dictionary = attempt_state["surfaces"] as Dictionary
	for surface_id: StringName in attempt_state["surface_order"] as Array[StringName]:
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
	var spec: Resource = surface_state["spec"] as Resource
	return {
		"surface_id": surface_id,
		"cell_origin": cell_origin,
		"quarter_turns": DeckPoseScript.normalize_quarter_turns(quarter_turns),
		"stack_group_id": stack_group_id,
		"stack_index": stack_index,
		"frozen_transform": (spec.get("local_transform") as Transform3D) * local_item_transform,
	}


func _shuffle_entries(entries: Array[LootBatchEntry], rng: RandomNumberGenerator) -> void:
	for index: int in range(entries.size() - 1, 0, -1):
		var other := rng.randi_range(0, index)
		var temporary: LootBatchEntry = entries[index]
		entries[index] = entries[other]
		entries[other] = temporary


func _attempt_seed(presentation_seed: int, attempt_index: int) -> int:
	return presentation_seed ^ ((attempt_index + 1) * 1103515245)
