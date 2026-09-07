extends SceneTree

const StorageCategoriesScript = preload("res://storage_categories.gd")
const ItemDefinitionScript = preload("res://item_definition.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_category_taxonomy()
	_test_missing_item_category_stays_uncategorized()
	_test_zone_auto_fit_priorities()
	_test_general_accepts_every_item_category()
	_test_manual_enabled_policy_and_first_use_initialization()
	if _failed:
		quit(1)
		return
	print("PASS: storage category semantics tests")
	quit(0)


func _test_category_taxonomy() -> void:
	_check(StorageCategoriesScript.EDITOR_CATEGORIES.has(StorageCategoriesScript.GENERAL), "General is editor-selectable")
	_check(not StorageCategoriesScript.ITEM_CATEGORIES.has(StorageCategoriesScript.GENERAL), "General is not an item category")
	for category: String in [
		StorageCategoriesScript.FOOD,
		StorageCategoriesScript.HYDRATION,
		StorageCategoriesScript.MEDICAL,
		StorageCategoriesScript.WEAPONS,
		StorageCategoriesScript.PROTECTION,
		StorageCategoriesScript.FUEL,
		StorageCategoriesScript.MORALE,
		StorageCategoriesScript.ELECTRONICS
	]:
		_check(StorageCategoriesScript.is_item_category(category), "%s is a valid item category" % category)


func _test_missing_item_category_stays_uncategorized() -> void:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.storage_category = ""
	var item: ItemInstance = ItemInstanceScript.new(definition)
	_check(item.get_storage_category().is_empty(), "explicit missing category remains uncategorized")
	_check(ItemInstanceScript.new().get_storage_category().is_empty(), "missing definition remains uncategorized")


func _test_zone_auto_fit_priorities() -> void:
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.configure(&"test_surface", 0.31, 0.10, 0.10)
	surface.set_zone_rect(StorageCategoriesScript.FOOD, Vector2i(0, 0), Vector2i(0, 0))
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i(1, 0), Vector2i(1, 0))

	var matching_fit: Dictionary = surface.find_zone_auto_fit(StorageCategoriesScript.FOOD, Vector2i.ONE)
	_check(matching_fit["zone_kind"] == "matching", "matching category is first auto tier")
	_check(matching_fit["zone_category"] == StorageCategoriesScript.FOOD, "matching category is reported")

	_check(surface.reserve_at(&"food", matching_fit["origin"] as Vector2i, Vector2i.ONE), "matching fixture reserves")
	var general_fit: Dictionary = surface.find_zone_auto_fit(StorageCategoriesScript.FOOD, Vector2i.ONE)
	_check(general_fit["zone_kind"] == "general", "General follows matching category")
	_check(general_fit["zone_category"] == StorageCategoriesScript.GENERAL, "General category is reported")

	_check(surface.reserve_at(&"general", general_fit["origin"] as Vector2i, Vector2i.ONE), "General fixture reserves")
	var disabled_fit: Dictionary = surface.find_zone_auto_fit("", Vector2i.ONE)
	_check(not bool(disabled_fit["valid"]), "initialized blank cell is not an auto fallback")
	_check(disabled_fit["zone_kind"] == "none", "disabled auto result reports no zone")
	surface.free()


func _test_general_accepts_every_item_category() -> void:
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.configure(&"general_categories", 0.81, 0.10, 0.10)
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(7, 0))
	for category: String in StorageCategoriesScript.ITEM_CATEGORIES:
		var fit: Dictionary = surface.find_zone_auto_fit(category, Vector2i.ONE, false)
		_check(bool(fit["valid"]), "General accepts %s" % category)
		_check(fit["zone_kind"] == "general", "%s destination reports General policy" % category)
		_check(fit["zone_category"] == StorageCategoriesScript.GENERAL, "%s destination reports General category" % category)
		_check(surface.reserve_at(category, fit["origin"] as Vector2i, Vector2i.ONE), "%s General fixture reserves" % category)
	surface.free()


func _test_manual_enabled_policy_and_first_use_initialization() -> void:
	var untouched: StorageSurface = StorageSurfaceScript.new()
	root.add_child(untouched)
	untouched.configure(&"untouched", 0.21, 0.20, 0.10)
	_check(not untouched.are_zones_initialized(), "fresh surface starts untouched")
	var untouched_manual: Dictionary = untouched.find_nearest_fit_to_local_point(Vector3.ZERO, Vector2i.ONE)
	_check(bool(untouched_manual["valid"]), "untouched surface preserves ordinary manual placement")
	_check(untouched.initialize_zones_if_needed(StorageCategoriesScript.GENERAL), "first zoning interaction initializes surface")
	_check(untouched.are_zones_initialized(), "first zoning interaction marks surface initialized")
	_check(is_equal_approx(untouched.get_zone_coverage_ratio(StorageCategoriesScript.GENERAL), 1.0), "first zoning interaction creates General 100 percent")
	_check(not untouched.initialize_zones_if_needed(StorageCategoriesScript.GENERAL), "later zoning interaction does not reinitialize")
	untouched.free()

	var mismatched: StorageSurface = StorageSurfaceScript.new()
	root.add_child(mismatched)
	mismatched.configure(&"manual_mismatch", 0.11, 0.10, 0.10)
	mismatched.set_zone_rect(StorageCategoriesScript.FOOD, Vector2i.ZERO, Vector2i.ZERO)
	var mismatch_manual: Dictionary = mismatched.find_nearest_fit_to_local_point(Vector3.ZERO, Vector2i.ONE)
	_check(bool(mismatch_manual["valid"]), "manual placement ignores enabled category mismatch")
	mismatched.free()

	var erased: StorageSurface = StorageSurfaceScript.new()
	root.add_child(erased)
	erased.configure(&"manual_erased", 0.11, 0.10, 0.10)
	erased.initialize_zones_if_needed(StorageCategoriesScript.GENERAL)
	erased.clear_all_zones()
	_check(erased.are_zones_initialized(), "erasing all cells does not reset initialized state")
	_check(is_zero_approx(erased.get_zone_coverage_ratio()), "erased surface has no enabled coverage")
	var erased_manual: Dictionary = erased.find_nearest_fit_to_local_point(Vector3.ZERO, Vector2i.ONE)
	_check(not bool(erased_manual["valid"]), "manual placement rejects deliberately erased cell")
	var erased_auto: Dictionary = erased.find_zone_auto_fit(StorageCategoriesScript.FOOD, Vector2i.ONE)
	_check(not bool(erased_auto["valid"]), "automatic placement rejects deliberately erased cell")
	erased.free()


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
