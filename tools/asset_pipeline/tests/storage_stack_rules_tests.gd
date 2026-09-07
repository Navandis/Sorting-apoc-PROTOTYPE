extends SceneTree

const StorageStackScript = preload("res://storage_stack.gd")

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_support_fit_and_roles()
	_test_orientation_and_terminal_rules()
	_test_clearance_threshold()
	_test_auto_coherence()
	_test_smart_insertion_cone()
	_test_highest_position_beats_orientation_preference()
	_test_deterministic_parity_bias()
	if _failed:
		quit(1)
		return
	print("PASS: storage stack rules tests")
	quit(0)


func _test_support_fit_and_roles() -> void:
	_check(StorageStackScript.footprint_fits(Vector2i(2, 3), Vector2i(4, 3)), "upper fits immediate lower")
	_check(not StorageStackScript.footprint_fits(Vector2i(4, 4), Vector2i(5, 3)), "oversized depth rejected")

	var stack = _stack_with_base(_entry("base_only", Vector2i(5, 5), 0.20, false, true, &""))
	var incoming = _entry("top", Vector2i(2, 2), 0.10, true, false, &"")
	var fit: Dictionary = stack.find_manual_append(incoming, 1.0, 0.0)
	_check(bool(fit.get("valid", false)), "base-only item supports an upper item")
	var attempt_to_stack_base = _entry("base_only", Vector2i(2, 2), 0.10, false, true, &"")
	_check(not bool(stack.find_manual_append(attempt_to_stack_base, 1.0, 0.0).get("valid", false)), "base-only item cannot itself be stacked")


func _test_orientation_and_terminal_rules() -> void:
	var stack = _stack_with_base(_entry("base", Vector2i(3, 2), 0.10, false, true, &"group"))
	var native = _entry("incoming", Vector2i(2, 3), 0.10, true, true, &"group", false)
	var rotated = _entry("incoming", Vector2i(3, 2), 0.10, true, true, &"group", true)
	_check(not bool(stack.find_manual_append(native, 1.0, 0.0).get("valid", false)), "native orientation rejected")
	_check(bool(stack.find_manual_append(rotated, 1.0, 0.0).get("valid", false)), "existing 90-degree orientation allows fit")

	stack.entries.append(_entry("terminal", Vector2i(2, 1), 0.05, true, false, &""))
	_check(not bool(stack.find_manual_append(_entry("later", Vector2i.ONE, 0.05, true, true, &""), 1.0, 0.0).get("valid", false)), "terminal top accepts no item")


func _test_clearance_threshold() -> void:
	var below = _entry("below", Vector2i(2, 2), 0.50, false, true, &"test")
	var stack = _stack_with_base(below)
	var just_below = _entry("below_limit", Vector2i.ONE, 0.4499, true, true, &"test")
	var just_above = _entry("above_limit", Vector2i.ONE, 0.4501, true, true, &"test")
	var accepted: Dictionary = stack.find_manual_append(just_below, 0.95, 0.0)
	var rejected: Dictionary = stack.find_manual_append(just_above, 0.95, 0.0)
	_check(bool(accepted.get("clearance_ok", false)), "0.9499 is below 95-percent limit")
	_check(bool(accepted.get("valid", false)), "just-below threshold accepted")
	_check(not bool(rejected.get("clearance_ok", true)), "0.9501 exceeds 95-percent limit")
	_check(not bool(rejected.get("valid", true)), "just-above threshold rejected")


func _test_auto_coherence() -> void:
	var stack = _stack_with_base(_entry("book", Vector2i(3, 2), 0.04, true, true, &"flat_media"))
	stack.entries.append(_entry("cd", Vector2i(2, 2), 0.06, true, true, &"flat_media"))
	_check(stack.is_auto_coherent(), "matching non-empty groups are coherent")
	var matching = _entry("book2", Vector2i(2, 1), 0.04, true, true, &"flat_media")
	_check(bool(stack.find_auto_insertion([matching], 1.0, 0.0).get("valid", false)), "matching group auto inserts")
	var empty_group = _entry("pistol", Vector2i(2, 1), 0.04, true, false, &"")
	stack.entries.append(empty_group)
	_check(not stack.is_auto_coherent(), "manual mixed terminal cap breaks coherence")
	_check(not bool(stack.find_auto_insertion([matching], 1.0, 0.0).get("valid", false)), "incoherent stack rejects auto insertion")


func _test_smart_insertion_cone() -> void:
	var stack = _stack_with_base(_entry("5x5", Vector2i(5, 5), 0.10, true, true, &"cone"))
	var one = _entry("1x1", Vector2i(1, 1), 0.10, true, true, &"cone")
	var two_by_three = _entry("2x3", Vector2i(2, 3), 0.10, true, true, &"cone")
	var four = _entry("4x4", Vector2i(4, 4), 0.10, true, true, &"cone")
	_insert_from_fit(stack, one, stack.find_auto_insertion([one], 1.0, 0.0))
	_check(_footprints(stack) == [Vector2i(5, 5), Vector2i(1, 1)], "first cone insertion")
	_insert_from_fit(stack, two_by_three, stack.find_auto_insertion([two_by_three], 1.0, 0.0))
	_check(_footprints(stack) == [Vector2i(5, 5), Vector2i(2, 3), Vector2i(1, 1)], "second cone insertion")
	var old_order: Array[String] = _keys(stack)
	var old_rotations: Array[bool] = _rotations(stack)
	_insert_from_fit(stack, four, stack.find_auto_insertion([four], 1.0, 0.0))
	_check(_footprints(stack) == [Vector2i(5, 5), Vector2i(4, 4), Vector2i(2, 3), Vector2i(1, 1)], "full smart insertion cone")
	_check(_without(_keys(stack), "4x4") == old_order, "existing relative order preserved")
	_check(_rotations_without_key(stack, "4x4") == old_rotations, "existing packing rotations preserved")


func _test_highest_position_beats_orientation_preference() -> void:
	var stack = _stack_with_base(_entry("base", Vector2i(4, 3), 0.10, true, true, &"shape"))
	stack.entries.append(_entry("top", Vector2i(3, 2), 0.10, true, true, &"shape"))
	var native = _entry("incoming", Vector2i(2, 3), 0.10, true, true, &"shape", false)
	var rotated = _entry("incoming", Vector2i(3, 2), 0.10, true, true, &"shape", true)
	var fit: Dictionary = stack.find_auto_insertion([native, rotated], 1.0, 0.0)
	_check(bool(fit.get("valid", false)), "an orientation inserts")
	_check(int(fit.get("insertion_index", -1)) == 2, "highest valid insertion wins")
	_check(bool(fit.get("rotated", false)), "rotation may beat lower native insertion")

	var equivalent_native = _entry("equal", Vector2i(2, 2), 0.10, true, true, &"shape", false)
	var equivalent_rotated = _entry("equal", Vector2i(2, 2), 0.10, true, true, &"shape", true)
	var tie: Dictionary = stack.find_auto_insertion([equivalent_native, equivalent_rotated], 1.0, 0.0)
	_check(not bool(tie.get("rotated", true)), "native orientation wins equivalent position tie")


func _test_deterministic_parity_bias() -> void:
	_check(StorageStackScript.centered_shrink_origin(Vector2i(10, 20), Vector2i(5, 5), Vector2i(2, 2)) == Vector2i(11, 21), "odd parity uses lower-index bias")
	_check(StorageStackScript.centered_shrink_origin(Vector2i(10, 20), Vector2i(6, 4), Vector2i(2, 2)) == Vector2i(12, 21), "even parity centers exactly")


func _entry(
	key: String,
	footprint: Vector2i,
	height_m: float,
	stacked: bool,
	supports: bool,
	group: StringName,
	rotated: bool = false
):
	var entry = StorageStackScript.Entry.new()
	entry.item_key = key
	entry.footprint = footprint
	entry.packing_rotated = rotated
	entry.aligned_bounds = AABB(Vector3.ZERO, Vector3(0.1, height_m, 0.1))
	entry.posed_height_m = height_m
	entry.can_be_stacked = stacked
	entry.can_support_stack = supports
	entry.auto_stack_group = group
	return entry


func _stack_with_base(base_entry):
	var stack = StorageStackScript.new()
	stack.stack_id = "test_stack"
	stack.surface_origin = Vector2i.ZERO
	stack.base_footprint = base_entry.footprint
	stack.entries.append(base_entry)
	return stack


func _insert_from_fit(stack, entry, fit: Dictionary) -> void:
	_check(bool(fit.get("valid", false)), "%s has insertion" % entry.item_key)
	if bool(fit.get("valid", false)):
		stack.entries.insert(int(fit["insertion_index"]), entry)


func _footprints(stack) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for entry in stack.entries:
		result.append(entry.footprint)
	return result


func _keys(stack) -> Array[String]:
	var result: Array[String] = []
	for entry in stack.entries:
		result.append(entry.item_key)
	return result


func _rotations(stack) -> Array[bool]:
	var result: Array[bool] = []
	for entry in stack.entries:
		result.append(entry.packing_rotated)
	return result


func _without(values: Array[String], removed: String) -> Array[String]:
	var result: Array[String] = []
	for value: String in values:
		if value != removed:
			result.append(value)
	return result


func _rotations_without_key(stack, removed: String) -> Array[bool]:
	var result: Array[bool] = []
	for entry in stack.entries:
		if entry.item_key != removed:
			result.append(entry.packing_rotated)
	return result


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
