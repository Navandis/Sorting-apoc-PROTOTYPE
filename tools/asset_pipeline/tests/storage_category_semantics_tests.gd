extends SceneTree

const StorageCategoriesScript = preload("res://storage_categories.gd")
const ItemDefinitionScript = preload("res://item_definition.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_category_taxonomy()
	_test_missing_item_category_stays_uncategorized()
	_test_zone_auto_fit_priorities()
	print("PASS: storage category semantics tests")
	quit(0)


func _test_category_taxonomy() -> void:
	assert(StorageCategoriesScript.EDITOR_CATEGORIES.has(StorageCategoriesScript.GENERAL))
	assert(not StorageCategoriesScript.ITEM_CATEGORIES.has(StorageCategoriesScript.GENERAL))
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
		assert(StorageCategoriesScript.is_item_category(category))


func _test_missing_item_category_stays_uncategorized() -> void:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.storage_category = ""
	var item: ItemInstance = ItemInstanceScript.new(definition)
	assert(item.get_storage_category().is_empty())
	assert(ItemInstanceScript.new().get_storage_category().is_empty())


func _test_zone_auto_fit_priorities() -> void:
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.configure(&"test_surface", 0.31, 0.10, 0.10)
	surface.set_zone_rect(StorageCategoriesScript.FOOD, Vector2i(0, 0), Vector2i(0, 0))
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i(1, 0), Vector2i(1, 0))

	var matching_fit: Dictionary = surface.find_zone_auto_fit(StorageCategoriesScript.FOOD, Vector2i.ONE)
	assert(matching_fit["zone_kind"] == "matching")
	assert(matching_fit["zone_category"] == StorageCategoriesScript.FOOD)

	surface.reserve_at(&"food", matching_fit["origin"] as Vector2i, Vector2i.ONE)
	var general_fit: Dictionary = surface.find_zone_auto_fit(StorageCategoriesScript.FOOD, Vector2i.ONE)
	assert(general_fit["zone_kind"] == "general")
	assert(general_fit["zone_category"] == StorageCategoriesScript.GENERAL)

	surface.reserve_at(&"general", general_fit["origin"] as Vector2i, Vector2i.ONE)
	var unassigned_fit: Dictionary = surface.find_zone_auto_fit("", Vector2i.ONE)
	assert(unassigned_fit["zone_kind"] == "unassigned")
	assert(unassigned_fit["zone_category"] == "")
	surface.free()
