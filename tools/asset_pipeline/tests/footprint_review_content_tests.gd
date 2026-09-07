extends SceneTree

const CATALOG_PATH: String = "res://data/items/item_catalog.tres"
const MAIN_SCENE_PATH: String = "res://main.tscn"
const VALIDATED_FOOTPRINTS: Dictionary = {
	"loot_000003": Vector2i(3, 5), "loot_000011": Vector2i(10, 5),
	"loot_000016": Vector2i(3, 2), "loot_000017": Vector2i(4, 3),
	"loot_000039": Vector2i(3, 2)
}


func _init() -> void:
	call_deferred("_run")


# Catches a candidate Footprint that cannot occupy even an empty current storage surface.
func _run() -> void:
	var scene: PackedScene = load(MAIN_SCENE_PATH) as PackedScene
	assert(scene != null)
	var scene_root: Node = scene.instantiate()
	root.add_child(scene_root)
	await process_frame
	await process_frame
	var surfaces: Array[StorageSurface] = []
	_collect_surfaces(scene_root, surfaces)
	assert(not surfaces.is_empty())
	var catalogue: Resource = load(CATALOG_PATH)
	assert(catalogue != null)
	var definitions: Array = catalogue.get("definitions") as Array
	var by_id: Dictionary = {}
	for value: Variant in definitions:
		var definition: ItemDefinition = value as ItemDefinition
		by_id[String(definition.item_id)] = definition
	for item_id_value: Variant in VALIDATED_FOOTPRINTS.keys():
		var item_id: String = String(item_id_value)
		var expected: Vector2i = VALIDATED_FOOTPRINTS[item_id]
		var definition: ItemDefinition = by_id[item_id] as ItemDefinition
		assert(Vector2i(definition.storage_footprint.x, definition.storage_footprint.y) == expected)
		var fits_any_surface: bool = false
		for surface: StorageSurface in surfaces:
			var grid: Vector2i = surface.grid_size
			if (expected.x <= grid.x and expected.y <= grid.y) or (expected.y <= grid.x and expected.x <= grid.y):
				fits_any_surface = true
				break
		assert(fits_any_surface, "%s does not fit any current StorageSurface" % item_id)
		print("FOOTPRINT_VALIDATED_SURFACE_FIT %s=%s" % [item_id, fits_any_surface])
	scene_root.queue_free()
	print("PASS: footprint review content tests")
	quit(0)


func _collect_surfaces(node: Node, output: Array[StorageSurface]) -> void:
	if node is StorageSurface:
		output.append(node as StorageSurface)
	for child: Node in node.get_children():
		_collect_surfaces(child, output)
