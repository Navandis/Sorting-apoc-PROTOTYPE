extends SceneTree

const StorageCategoriesScript = preload("res://storage_categories.gd")
const StorageStackScript = preload("res://storage_stack.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")
const WorldItemScript = preload("res://world_item.gd")

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
	_test_base_promotion_rekeys_every_owner()
	_test_failed_base_promotion_is_atomic()
	_test_manual_stack_orientation_resolution()
	_test_erased_cells_reject_auto_and_manual_stacking()
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
	_check(not bool(fit.get("valid", true)), "disabled blank stack is never an automatic fallback")
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
	_check(not bool(fit.get("valid", true)), "disabled blank cell does not follow General")
	_check(fit.get("zone_kind", "") == "none", "disabled cell is reported as no destination")
	surface.free()


func _test_stable_stack_scan_and_fallback() -> void:
	var surface: StorageSurface = _surface(Vector2i(5, 2))
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(4, 1))
	_commit_base(surface, _entry("later", Vector2i(2, 2), 0.10, true, true, &"shape"), Vector2i(3, 0))
	_commit_base(surface, _entry("first", Vector2i(1, 1), 0.10, true, true, &"shape"), Vector2i(0, 0))
	var incoming = _entry("incoming", Vector2i(2, 2), 0.10, true, true, &"shape")
	var fit: Dictionary = surface.find_zone_stack_or_empty_fit("", incoming)
	_check(fit.get("stack_id", "") == "later", "invalid first stack falls through to next compatible stack")
	var empty_fallback: StorageSurface = _surface(Vector2i(4, 2))
	empty_fallback.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(3, 1))
	_commit_base(empty_fallback, _entry("too_small", Vector2i.ONE, 0.10, true, true, &"shape"), Vector2i.ZERO)
	fit = empty_fallback.find_zone_stack_or_empty_fit("", incoming)
	_check(fit.get("placement_kind", "") == "empty", "invalid insertion falls back to empty placement in same tier")

	var equal_surface: StorageSurface = _surface(Vector2i(4, 1))
	equal_surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(3, 0))
	_commit_base(equal_surface, _entry("right", Vector2i.ONE, 0.10, true, true, &"shape"), Vector2i(2, 0))
	_commit_base(equal_surface, _entry("left", Vector2i.ONE, 0.10, true, true, &"shape"), Vector2i.ZERO)
	fit = equal_surface.find_zone_stack_or_empty_fit("", _entry("small", Vector2i.ONE, 0.10, true, true, &"shape"))
	_check(fit.get("stack_id", "") == "left", "row-column scan order is stable")
	surface.free()
	empty_fallback.free()
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
	_check(stack.stack_id == "replacement_top", "promoted final survivor becomes authoritative stack ID")
	_check(surface.get_storage_stack("base") == null, "removed base no longer resolves as an active stack")
	_check(not bool(surface.get_reservation("base").get("valid", false)), "removed base owns no reservation after promotion")
	var reservation: Dictionary = surface.get_reservation("replacement_top")
	_check(reservation.get("origin", Vector2i.ZERO) == Vector2i(3, 3), "reservation origin shrinks inside old cells")
	_check(reservation.get("footprint", Vector2i.ZERO) == Vector2i.ONE, "reservation footprint shrinks")
	var expected_position: Vector3 = surface.get_local_placement_position(Vector2i(3, 3), Vector2i.ONE)
	_check(replacement_top.host.position.is_equal_approx(expected_position), "promoted base recenters visually")

	_check(surface.remove_stack_entry("replacement_top", "replacement_top"), "final removal succeeds")
	_check(surface.get_stack_count() == 0, "empty stack record removed")
	_check(surface.get_reservation_count() == 0, "empty stack reservation released")
	_check(is_zero_approx(surface.get_occupancy_ratio()), "empty stack leaves no hidden occupancy")
	surface.free()


func _test_base_promotion_rekeys_every_owner() -> void:
	var surface: StorageSurface = _surface(Vector2i(8, 8))
	var base = _entry("old_base", Vector2i(5, 5), 0.20, true, true, &"cone")
	var promoted = _entry("promoted", Vector2i(3, 3), 0.15, true, true, &"cone")
	var top = _entry("top_survivor", Vector2i.ONE, 0.10, true, true, &"cone")
	for entry in [base, promoted, top]:
		entry.host = Node3D.new()
	_commit_base(surface, base, Vector2i(1, 1))
	_check(surface.commit_stack_entry(promoted, surface.find_manual_stack_fit("old_base", promoted)), "promotion fixture middle committed")
	_check(surface.commit_stack_entry(top, surface.find_manual_stack_fit("old_base", top)), "promotion fixture top committed")
	var promoted_world: WorldItem = _attach_stored_world_item(surface, promoted, "old_base")
	var top_world: WorldItem = _attach_stored_world_item(surface, top, "old_base")

	_check(surface.remove_stack_entry("old_base", "old_base"), "base promotion succeeds")
	var stack = surface.get_storage_stack("promoted")
	_check(stack != null, "promoted ID resolves authoritative stack")
	_check(surface.get_storage_stack("old_base") == null, "old base ID absent from stack registry")
	_check(not (surface.get("_stacks") as Dictionary).has("old_base"), "old base ID absent from raw stack ownership")
	_check(not (surface.get("_reservations") as Dictionary).has("old_base"), "old base ID absent from reservation registry")
	_check(not (surface.get("_cells") as Array[String]).has("old_base"), "old base ID absent from occupied-cell ownership")
	_check(not (surface.get("_item_to_stack") as Dictionary).has("old_base"), "old base ID absent as an item lookup key")
	_check(not (surface.get("_item_to_stack") as Dictionary).values().has("old_base"), "old base ID absent as an item lookup value")
	_check(surface.get_stack_id_for_item("promoted") == "promoted", "promoted member maps to authoritative ID")
	_check(surface.get_stack_id_for_item("top_survivor") == "promoted", "all surviving members map to authoritative ID")
	_check(bool(surface.get_reservation("promoted").get("valid", false)), "promoted ID owns reservation")
	_check(String(surface.get_reservation("promoted").get("item_key", "")) == "promoted", "promoted ID is reservation owner")
	_check(stack != null and stack.stack_id == "promoted", "stack object records promoted ID")
	_check(promoted_world.get_storage_stack_id() == "promoted", "promoted WorldItem metadata rekeyed")
	_check(top_world.get_storage_stack_id() == "promoted", "every surviving WorldItem metadata entry rekeyed")
	surface.free()


func _test_failed_base_promotion_is_atomic() -> void:
	var surface: StorageSurface = _surface(Vector2i(8, 8))
	var base = _entry("atomic_base", Vector2i(3, 3), 0.20, true, true, &"cone")
	var promoted = _entry("atomic_promoted", Vector2i.ONE, 0.10, true, true, &"cone")
	_commit_base(surface, base, Vector2i(1, 1))
	_check(surface.commit_stack_entry(promoted, surface.find_manual_stack_fit("atomic_base", promoted)), "atomic fixture upper committed")
	var reservations: Dictionary = surface.get("_reservations") as Dictionary
	reservations["atomic_promoted"] = {
		"valid": true,
		"item_key": "atomic_promoted",
		"origin": Vector2i(7, 7),
		"footprint": Vector2i.ONE,
		"rotated": false
	}

	_check(not surface.remove_stack_entry("atomic_base", "atomic_base"), "rekey destination collision rejects promotion")
	var stack = surface.get_storage_stack("atomic_base")
	_check(stack != null and _entry_keys(stack) == ["atomic_base", "atomic_promoted"], "failed promotion preserves original entry order")
	_check(surface.get_stack_id_for_item("atomic_base") == "atomic_base", "failed promotion preserves base lookup")
	_check(surface.get_stack_id_for_item("atomic_promoted") == "atomic_base", "failed promotion preserves survivor lookup")
	_check(bool(surface.get_reservation("atomic_base").get("valid", false)), "failed promotion preserves original reservation")
	_check((surface.get("_cells") as Array[String]).has("atomic_base"), "failed promotion preserves original occupied-cell owner")
	surface.free()

	var owner_surface: StorageSurface = _surface(Vector2i(8, 8))
	var owner_base = _entry("owner_base", Vector2i(3, 3), 0.20, true, true, &"cone")
	var owner_promoted = _entry("owner_promoted", Vector2i.ONE, 0.10, true, true, &"cone")
	_commit_base(owner_surface, owner_base, Vector2i(1, 1))
	_check(owner_surface.commit_stack_entry(owner_promoted, owner_surface.find_manual_stack_fit("owner_base", owner_promoted)), "owner fixture upper committed")
	var owner_reservations: Dictionary = owner_surface.get("_reservations") as Dictionary
	var corrupted_owner: Dictionary = (owner_reservations["owner_base"] as Dictionary).duplicate(true)
	corrupted_owner["item_key"] = "wrong_owner"
	owner_reservations["owner_base"] = corrupted_owner
	_check(not owner_surface.remove_stack_entry("owner_base", "owner_base"), "mismatched reservation owner rejects promotion")
	var owner_stack = owner_surface.get_storage_stack("owner_base")
	_check(owner_stack != null and _entry_keys(owner_stack) == ["owner_base", "owner_promoted"], "owner validation failure preserves original entries")
	_check(owner_surface.get_stack_id_for_item("owner_base") == "owner_base", "owner validation failure preserves base lookup")
	_check(owner_surface.get_stack_id_for_item("owner_promoted") == "owner_base", "owner validation failure preserves survivor lookup")
	_check((owner_surface.get("_cells") as Array[String]).has("owner_base"), "owner validation failure preserves cell ownership")
	owner_surface.free()


func _test_manual_stack_orientation_resolution() -> void:
	var alternate_surface: StorageSurface = _surface(Vector2i(8, 8))
	var alternate_base = _entry("alternate_base", Vector2i(4, 5), 0.10, true, true, &"shape")
	_commit_base(alternate_surface, alternate_base, Vector2i.ZERO)
	var preferred_invalid = _entry("alternate_incoming", Vector2i(5, 4), 0.10, true, true, &"shape")
	preferred_invalid.packing_rotated = false
	var alternate_valid = _entry("alternate_incoming", Vector2i(4, 5), 0.10, true, true, &"shape")
	alternate_valid.packing_rotated = true
	var alternate_fit: Dictionary = alternate_surface.find_manual_stack_fit(
		"alternate_base",
		preferred_invalid,
		alternate_valid
	)
	_check(bool(alternate_fit.get("valid", false)), "alternate orientation is used when preferred is invalid")
	_check(bool(alternate_fit.get("rotated", false)), "alternate effective orientation is reported")
	alternate_surface.free()

	var both_surface: StorageSurface = _surface(Vector2i(8, 8))
	var both_base = _entry("both_base", Vector2i(6, 6), 0.10, true, true, &"shape")
	_commit_base(both_surface, both_base, Vector2i.ZERO)
	var both_preferred = _entry("both_incoming", Vector2i(2, 3), 0.10, true, true, &"shape")
	both_preferred.packing_rotated = false
	var both_alternate = _entry("both_incoming", Vector2i(3, 2), 0.10, true, true, &"shape")
	both_alternate.packing_rotated = true
	var both_fit: Dictionary = both_surface.find_manual_stack_fit(
		"both_base",
		both_preferred,
		both_alternate
	)
	_check(bool(both_fit.get("valid", false)), "both-valid manual stack fit succeeds")
	_check(not bool(both_fit.get("rotated", true)), "both-valid manual stack fit preserves preferred orientation")
	both_surface.free()

	var neither_surface: StorageSurface = _surface(Vector2i(8, 8))
	var neither_base = _entry("neither_base", Vector2i(2, 2), 0.10, true, true, &"shape")
	_commit_base(neither_surface, neither_base, Vector2i.ZERO)
	var neither_preferred = _entry("neither_incoming", Vector2i(3, 2), 0.10, true, true, &"shape")
	var neither_alternate = _entry("neither_incoming", Vector2i(2, 3), 0.10, true, true, &"shape")
	neither_alternate.packing_rotated = true
	var neither_fit: Dictionary = neither_surface.find_manual_stack_fit(
		"neither_base",
		neither_preferred,
		neither_alternate
	)
	_check(not bool(neither_fit.get("valid", true)), "neither-valid manual orientations remain invalid")
	neither_surface.free()


func _test_erased_cells_reject_auto_and_manual_stacking() -> void:
	var surface: StorageSurface = _surface(Vector2i.ONE)
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i.ZERO)
	var base = _entry("erased_base", Vector2i.ONE, 0.10, true, true, &"shape")
	_commit_base(surface, base, Vector2i.ZERO)
	surface.clear_all_zones()
	var incoming = _entry("erased_incoming", Vector2i.ONE, 0.10, true, true, &"shape")
	var auto_fit: Dictionary = surface.find_zone_stack_or_empty_fit(StorageCategoriesScript.FOOD, incoming)
	_check(not bool(auto_fit.get("valid", true)), "automatic stacking rejects base reservation in erased cells")
	var manual_fit: Dictionary = surface.find_manual_stack_fit("erased_base", incoming)
	_check(not bool(manual_fit.get("valid", true)), "manual stacking rejects base reservation in erased cells")
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


func _attach_stored_world_item(
	surface: StorageSurface,
	entry,
	stack_id: String
) -> WorldItem:
	var component: WorldItem = WorldItemScript.new()
	component.name = "WorldItem"
	entry.host.add_child(component)
	component.configure_existing(entry.host, null, surface, stack_id, entry.item_key)
	entry.world_item = component
	return component


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
