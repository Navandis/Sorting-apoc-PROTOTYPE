extends SceneTree

const StorageCategoriesScript = preload("res://storage_categories.gd")
const StorageStackScript = preload("res://storage_stack.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var api_probe: StorageSurface = StorageSurfaceScript.new()
	for method_name: StringName in [
		&"get_stack_count", &"get_storage_stack", &"get_stack_id_for_item",
		&"find_zone_stack_or_empty_fit", &"find_manual_stack_fit",
		&"commit_stack_entry", &"remove_stack_entry",
		&"get_stack_candidate_transform"
	]:
		if not api_probe.has_method(method_name):
			push_error("StorageSurface.%s is missing" % method_name)
			api_probe.free()
			quit(1)
			return
	api_probe.free()

	_test_base_only_reserves_cells()
	_test_stack_first_inside_each_zone_tier()
	_test_zone_order_and_mismatched_specific_exclusion()
	_test_stable_stack_scan_and_fallback()
	_test_general_cross_category_group()
	_test_top_middle_base_and_final_removal()
	if _failed:
		quit(1)
		return
	print("PASS: storage stack surface tests")
	quit(0)


func _test_base_only_reserves_cells() -> void:
	var surface: StorageSurface = _surface(Vector2i(8, 8))
	var base = _entry("base", Vector2i(5, 5), 0.20, true, true, &"cone")
	var base_fit: Dictionary = _empty_fit(base, Vector2i(1, 1), "unassigned", "")
	_check(surface.commit_stack_entry(base, base_fit), "base commit succeeds")
	var upper = _entry("upper", Vector2i(2, 2), 0.10, true, true, &"cone")
	var stack_fit: Dictionary = surface.find_manual_stack_fit("base", upper)
	_check(surface.commit_stack_entry(upper, stack_fit), "upper commit succeeds")
	_check(surface.get_reservation_count() == 1, "upper entry owns no reservation")
	_check(surface.get_stack_count() == 1, "one explicit stack record")
	_check(surface.get_storage_stack("base").entries.size() == 2, "two physical entries recorded")
	surface.free()


func _test_stack_first_inside_each_zone_tier() -> void:
	var matching: StorageSurface = _surface(Vector2i(3, 1))
	matching.set_zone_rect(StorageCategoriesScript.FOOD, Vector2i(0, 0), Vector2i(2, 0))
	_commit_base(matching, _entry("matching_stack", Vector2i.ONE, 0.10, true, true, &"boxed"), Vector2i.ZERO)
	var incoming = _entry("incoming", Vector2i.ONE, 0.10, true, true, &"boxed")
	var fit: Dictionary = matching.find_zone_stack_or_empty_fit(StorageCategoriesScript.FOOD, incoming)
	_check(fit.get("placement_kind", "") == "stack", "matching tier chooses stack before empty")
	_check(fit.get("stack_id", "") == "matching_stack", "matching stack selected")

	var general: StorageSurface = _surface(Vector2i(3, 1))
	general.set_zone_rect(StorageCategoriesScript.FOOD, Vector2i(0, 0), Vector2i(0, 0))
	general.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i(1, 0), Vector2i(2, 0))
	_commit_base(general, _entry("general_stack", Vector2i.ONE, 0.10, true, true, &"boxed"), Vector2i(1, 0))
	fit = general.find_zone_stack_or_empty_fit(StorageCategoriesScript.FOOD, incoming)
	_check(fit.get("placement_kind", "") == "empty", "matching empty precedes General stack")
	_check(fit.get("zone_kind", "") == "matching", "matching empty tier retained")
	_commit_base(general, _entry("fills_matching", Vector2i.ONE, 0.10, false, false, &""), Vector2i.ZERO)
	fit = general.find_zone_stack_or_empty_fit(StorageCategoriesScript.FOOD, incoming)
	_check(fit.get("placement_kind", "") == "stack", "General tier chooses stack before General empty")
	_check(fit.get("stack_id", "") == "general_stack", "General stack selected")

	var unassigned: StorageSurface = _surface(Vector2i(3, 1))
	unassigned.set_zone_rect(StorageCategoriesScript.FOOD, Vector2i(0, 0), Vector2i(0, 0))
	unassigned.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i(1, 0), Vector2i(1, 0))
	_commit_base(unassigned, _entry("fills_food", Vector2i.ONE, 0.10, false, false, &""), Vector2i.ZERO)
	_commit_base(unassigned, _entry("fills_general", Vector2i.ONE, 0.10, false, false, &""), Vector2i(1, 0))
	_commit_base(unassigned, _entry("unassigned_stack", Vector2i.ONE, 0.10, true, true, &"boxed"), Vector2i(2, 0))
	fit = unassigned.find_zone_stack_or_empty_fit(StorageCategoriesScript.FOOD, incoming)
	_check(fit.get("placement_kind", "") == "stack", "unassigned tier stacks when higher tiers full")
	_check(fit.get("zone_kind", "") == "unassigned", "unassigned tier reported")
	matching.free()
	general.free()
	unassigned.free()


func _test_zone_order_and_mismatched_specific_exclusion() -> void:
	var surface: StorageSurface = _surface(Vector2i(3, 1))
	surface.set_zone_rect(StorageCategoriesScript.HYDRATION, Vector2i(0, 0), Vector2i(0, 0))
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i(1, 0), Vector2i(1, 0))
	_commit_base(surface, _entry("hydration_can", Vector2i.ONE, 0.10, true, true, &"round_cans"), Vector2i.ZERO)
	var food_can = _entry("food_can", Vector2i.ONE, 0.10, true, true, &"round_cans")
	var fit: Dictionary = surface.find_zone_stack_or_empty_fit(StorageCategoriesScript.FOOD, food_can)
	_check(fit.get("placement_kind", "") == "empty", "mismatched specific stack is skipped")
	_check(fit.get("zone_kind", "") == "general", "General follows absent matching tier")
	_commit_base(surface, _entry("fills_general", Vector2i.ONE, 0.10, false, false, &""), Vector2i(1, 0))
	fit = surface.find_zone_stack_or_empty_fit(StorageCategoriesScript.FOOD, food_can)
	_check(fit.get("placement_kind", "") == "empty", "unassigned follows General")
	_check(fit.get("zone_kind", "") == "unassigned", "unassigned is final tier")
	_commit_base(surface, _entry("fills_unassigned", Vector2i.ONE, 0.10, false, false, &""), Vector2i(2, 0))
	fit = surface.find_zone_stack_or_empty_fit(StorageCategoriesScript.FOOD, food_can)
	_check(not bool(fit.get("valid", true)), "mismatched specific stack never becomes fallback")
	surface.free()


func _test_stable_stack_scan_and_fallback() -> void:
	var surface: StorageSurface = _surface(Vector2i(5, 2))
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(4, 1))
	_commit_base(surface, _entry("later", Vector2i(2, 2), 0.10, true, true, &"shape"), Vector2i(3, 0))
	_commit_base(surface, _entry("first", Vector2i(1, 1), 0.10, true, true, &"shape"), Vector2i(0, 0))
	var incoming = _entry("incoming", Vector2i(2, 2), 0.10, true, true, &"shape")
	var fit: Dictionary = surface.find_zone_stack_or_empty_fit("", incoming)
	_check(fit.get("stack_id", "") == "later", "invalid first stack falls through to next compatible stack")

	var equal_surface: StorageSurface = _surface(Vector2i(4, 1))
	equal_surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(3, 0))
	_commit_base(equal_surface, _entry("right", Vector2i.ONE, 0.10, true, true, &"shape"), Vector2i(2, 0))
	_commit_base(equal_surface, _entry("left", Vector2i.ONE, 0.10, true, true, &"shape"), Vector2i.ZERO)
	fit = equal_surface.find_zone_stack_or_empty_fit("", _entry("small", Vector2i.ONE, 0.10, true, true, &"shape"))
	_check(fit.get("stack_id", "") == "left", "row-column scan order is stable")
	surface.free()
	equal_surface.free()


func _test_general_cross_category_group() -> void:
	var surface: StorageSurface = _surface(Vector2i(2, 1))
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(1, 0))
	_commit_base(surface, _entry("hydration_can", Vector2i.ONE, 0.10, true, true, &"round_cans"), Vector2i.ZERO)
	var fit: Dictionary = surface.find_zone_stack_or_empty_fit(
		StorageCategoriesScript.FOOD,
		_entry("food_can", Vector2i.ONE, 0.10, true, true, &"round_cans")
	)
	_check(fit.get("placement_kind", "") == "stack", "General permits cross-category coherent can stack")
	_check(fit.get("zone_kind", "") == "general", "cross-category can remains General policy")
	surface.free()


func _test_top_middle_base_and_final_removal() -> void:
	var surface: StorageSurface = _surface(Vector2i(8, 8))
	var base = _entry("base", Vector2i(5, 5), 0.20, true, true, &"cone")
	var middle = _entry("middle", Vector2i(2, 2), 0.15, true, true, &"cone")
	var top = _entry("top", Vector2i(1, 1), 0.10, true, true, &"cone")
	for entry in [base, middle, top]:
		entry.host = Node3D.new()
	_commit_base(surface, base, Vector2i(1, 1))
	_check(surface.commit_stack_entry(middle, surface.find_manual_stack_fit("base", middle)), "middle committed")
	_check(surface.commit_stack_entry(top, surface.find_manual_stack_fit("base", top)), "top committed")
	var stack = surface.get_storage_stack("base")
	var middle_y_before: float = middle.host.position.y
	_check(surface.remove_stack_entry("base", "top"), "top removal succeeds")
	top.host.free()
	_check(stack.entries.size() == 2, "top removal leaves two entries")
	_check(is_equal_approx(middle.host.position.y, middle_y_before), "top removal does not move lower entries")

	var replacement_top = _entry("replacement_top", Vector2i(1, 1), 0.10, true, true, &"cone")
	replacement_top.host = Node3D.new()
	_check(surface.commit_stack_entry(replacement_top, surface.find_manual_stack_fit("base", replacement_top)), "replacement top committed")
	_check(surface.remove_stack_entry("base", "middle"), "middle removal succeeds")
	middle.host.free()
	_check(_entry_keys(stack) == ["base", "replacement_top"], "middle removal preserves survivor order")
	_check(is_equal_approx(replacement_top.host.position.y, stack.entry_host_y(1, surface.get_local_placement_position(stack.surface_origin, stack.base_footprint).y)), "middle removal compresses upper host")

	_check(surface.remove_stack_entry("base", "base"), "base removal succeeds")
	base.host.free()
	_check(stack.surface_origin == Vector2i(3, 3), "base shrink uses lower-index parity bias")
	_check(stack.base_footprint == Vector2i.ONE, "promoted base owns smaller footprint")
	var reservation: Dictionary = surface.get_reservation("base")
	_check(reservation.get("origin", Vector2i.ZERO) == Vector2i(3, 3), "reservation origin shrinks inside old cells")
	_check(reservation.get("footprint", Vector2i.ZERO) == Vector2i.ONE, "reservation footprint shrinks")
	var expected_position: Vector3 = surface.get_local_placement_position(Vector2i(3, 3), Vector2i.ONE)
	_check(replacement_top.host.position.is_equal_approx(expected_position), "promoted base recenters visually")

	_check(surface.remove_stack_entry("base", "replacement_top"), "final removal succeeds")
	_check(surface.get_stack_count() == 0, "empty stack record removed")
	_check(surface.get_reservation_count() == 0, "empty stack reservation released")
	_check(is_zero_approx(surface.get_occupancy_ratio()), "empty stack leaves no hidden occupancy")
	surface.free()


func _surface(size: Vector2i) -> StorageSurface:
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.configure(&"stack_test", float(size.x) * 0.10 + 0.001, float(size.y) * 0.10 + 0.001, 0.10)
	return surface


func _entry(
	key: String,
	footprint: Vector2i,
	height_m: float,
	stacked: bool,
	supports: bool,
	group: StringName
):
	var entry = StorageStackScript.Entry.new()
	entry.item_key = key
	entry.footprint = footprint
	entry.aligned_bounds = AABB(Vector3.ZERO, Vector3(0.1, height_m, 0.1))
	entry.posed_height_m = height_m
	entry.can_be_stacked = stacked
	entry.can_support_stack = supports
	entry.auto_stack_group = group
	return entry


func _commit_base(surface: StorageSurface, entry, origin: Vector2i) -> void:
	if entry.host == null:
		entry.host = Node3D.new()
	surface.add_child(entry.host)
	_check(surface.commit_stack_entry(entry, _empty_fit(entry, origin, "fixture", "")), "%s base fixture commits" % entry.item_key)


func _empty_fit(entry, origin: Vector2i, zone_kind: String, zone_category: String) -> Dictionary:
	return {
		"valid": true,
		"placement_kind": "empty",
		"stack_id": entry.item_key,
		"insertion_index": 0,
		"origin": origin,
		"footprint": entry.footprint,
		"base_footprint": entry.footprint,
		"rotated": entry.packing_rotated,
		"zone_kind": zone_kind,
		"zone_category": zone_category,
		"host_y_m": 0.012
	}


func _entry_keys(stack) -> Array[String]:
	var keys: Array[String] = []
	for entry in stack.entries:
		keys.append(entry.item_key)
	return keys


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
