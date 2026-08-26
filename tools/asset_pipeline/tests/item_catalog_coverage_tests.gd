extends SceneTree

const MainSceneLootAdapterScript = preload(
	"res://tools/asset_pipeline/main_scene_loot_adapter.gd"
)
const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const CarriedItemsScript = preload("res://carried_items.gd")


func _init() -> void:
	_test_exact_pickup_registration_route_resolves_all_42_assets()
	print("PASS: item catalog coverage tests")
	quit(0)


# Catches any catalogue omission that would leave a main-scene GLB inert when
# player_controller calls create_definition_for_node during registration.
func _test_exact_pickup_registration_route_resolves_all_42_assets() -> void:
	var records: Array[Dictionary] = MainSceneLootAdapterScript.enumerate_loot_instances(
		"res://main.tscn"
	)
	assert(records.size() == 42)
	var resolved_count: int = 0
	for record: Dictionary in records:
		var source_path: String = String(record["source_path"])
		var visual_resource: Resource = load(source_path)
		assert(visual_resource is PackedScene)
		var host: Node = (visual_resource as PackedScene).instantiate()
		var definition: ItemDefinition = (
			PrototypeItemCatalogScript.create_definition_for_node(host)
		)
		assert(definition != null)
		assert(definition.visual_scene != null)
		assert(definition.visual_scene.resource_path == source_path)
		assert(definition.storage_footprint.x > 0)
		assert(definition.storage_footprint.y > 0)
		assert(definition.storage_footprint.z > 0)
		var carried_items: Node = CarriedItemsScript.new()
		assert(definition.bulk <= int(carried_items.get("max_bulk")))
		carried_items.free()
		host.free()
		resolved_count += 1
	assert(resolved_count == 42)
