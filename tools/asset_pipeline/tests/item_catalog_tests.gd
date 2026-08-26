extends SceneTree

const ItemCatalogScript = preload("res://item_catalog.gd")
const ItemDefinitionScript = preload("res://item_definition.gd")
const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")


func _init() -> void:
	_test_unique_definitions_resolve_from_both_indexes_once()
	_test_duplicate_id_invalidates_only_that_id_lookup()
	_test_duplicate_visual_path_invalidates_only_that_path_lookup()
	_test_compatibility_facade_resolves_every_persistent_visual()
	_test_node_scene_path_is_primary_and_name_mapping_is_fallback_only()
	print("PASS: item catalog tests")
	quit(0)


# Catches a regression where normal queries rebuild caches or stop returning
# the exact persistent definition referenced by the catalogue.
func _test_unique_definitions_resolve_from_both_indexes_once() -> void:
	var definition: ItemDefinition = _definition(
		&"loot_000001",
		"res://assets/props/Food/cereal_box.glb"
	)
	var catalog: Variant = ItemCatalogScript.new()
	var definitions: Array[ItemDefinition] = [definition]
	catalog.set_definitions(definitions)

	assert(catalog.get_definition_by_id(&"loot_000001") == definition)
	assert(
		catalog.get_definition_by_visual_path(
			"res://assets/props/Food/cereal_box.glb"
		) == definition
	)
	assert(catalog.get_index_build_count() == 1)
	assert(catalog.get_definition_by_id(&"loot_000001") == definition)
	assert(catalog.get_index_build_count() == 1)
	assert(catalog.get_validation_errors().is_empty())


# Catches a regression where duplicate gameplay identity silently picks one
# definition and makes content resolution depend on array order.
func _test_duplicate_id_invalidates_only_that_id_lookup() -> void:
	var first: ItemDefinition = _definition(
		&"loot_000001",
		"res://assets/props/Food/cereal_box.glb"
	)
	var second: ItemDefinition = _definition(
		&"loot_000001",
		"res://assets/props/Hydration/soda_can.glb"
	)
	var catalog: Variant = ItemCatalogScript.new()
	var definitions: Array[ItemDefinition] = [first, second]
	catalog.set_definitions(definitions)

	assert(catalog.get_definition_by_id(&"loot_000001") == null)
	assert(catalog.get_definition_by_visual_path(first.visual_scene.resource_path) == first)
	assert(catalog.get_definition_by_visual_path(second.visual_scene.resource_path) == second)
	assert(_errors_contain(catalog.get_validation_errors(), "Duplicate ItemDefinition ID 'loot_000001'"))


# Catches a regression where ambiguous prototype visual lookup silently picks
# one definition even though the current pickup route cannot disambiguate it.
func _test_duplicate_visual_path_invalidates_only_that_path_lookup() -> void:
	var first: ItemDefinition = _definition(
		&"loot_000001",
		"res://assets/props/Food/cereal_box.glb"
	)
	var second: ItemDefinition = _definition(
		&"loot_000002",
		"res://assets/props/Food/cereal_box.glb"
	)
	var catalog: Variant = ItemCatalogScript.new()
	var definitions: Array[ItemDefinition] = [first, second]
	catalog.set_definitions(definitions)

	assert(catalog.get_definition_by_visual_path(first.visual_scene.resource_path) == null)
	assert(catalog.get_definition_by_id(&"loot_000001") == first)
	assert(catalog.get_definition_by_id(&"loot_000002") == second)
	assert(_errors_contain(
		catalog.get_validation_errors(),
		"Duplicate ItemDefinition visual path 'res://assets/props/Food/cereal_box.glb'"
	))


# Catches a regression where runtime pickup registration still sees only the
# legacy 11 hard-coded paths instead of the persistent catalogue membership.
func _test_compatibility_facade_resolves_every_persistent_visual() -> void:
	var members: Array = PersistentItemCatalog.get("definitions") as Array
	assert(members.size() == 42)
	for member_value: Variant in members:
		var definition: ItemDefinition = member_value as ItemDefinition
		assert(definition != null)
		assert(
			PrototypeItemCatalogScript.create_definition_for_scene_path(
				definition.visual_scene.resource_path
			) == definition
		)
		assert(
			PrototypeItemCatalogScript.get_definition_by_id(definition.item_id)
			== definition
		)


# Catches name heuristics overriding an explicit PackedScene path, while still
# protecting compatibility for nodes whose scene path is unavailable.
func _test_node_scene_path_is_primary_and_name_mapping_is_fallback_only() -> void:
	var bread_scene: PackedScene = load(
		"res://assets/props/Food/SM_Bread_1.glb"
	) as PackedScene
	var bread_node: Node = bread_scene.instantiate()
	bread_node.name = "cereal_box_misleading_name"
	var bread_definition: ItemDefinition = (
		PrototypeItemCatalogScript.create_definition_for_node(bread_node)
	)
	assert(bread_definition != null)
	assert(
		bread_definition.visual_scene.resource_path
		== "res://assets/props/Food/SM_Bread_1.glb"
	)
	bread_node.free()

	var fallback_node: Node3D = Node3D.new()
	fallback_node.name = "cereal_box_without_scene_path"
	var fallback_definition: ItemDefinition = (
		PrototypeItemCatalogScript.create_definition_for_node(fallback_node)
	)
	assert(fallback_definition != null)
	assert(
		fallback_definition.visual_scene.resource_path
		== "res://assets/props/Food/cereal_box.glb"
	)
	fallback_node.free()


func _definition(item_id: StringName, visual_path: String) -> ItemDefinition:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.item_id = item_id
	var visual: Resource = load(visual_path)
	assert(visual is PackedScene)
	definition.visual_scene = visual as PackedScene
	return definition


func _errors_contain(errors: PackedStringArray, fragment: String) -> bool:
	for error: String in errors:
		if error.contains(fragment):
			return true
	return false
