extends SceneTree

const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const StorageCategoriesScript = preload("res://storage_categories.gd")

const AUDIT_PATH: String = "res://reports/asset_pipeline/main_scene_loot_audit.json"
const MANIFEST_PATH: String = "res://tools/asset_pipeline/item_authoring_review.json"
const METAL_CAN_PATH: String = "res://assets/props/Hydration/SM_Metal_Can_01a.glb"


func _init() -> void:
	_test_initial_seed_matches_manifest_and_raw_audit_baseline()
	print("PASS: item catalog initial seed tests")
	quit(0)


# This intentionally temporary baseline catches mistakes in the one-time seed:
# wrong identity, balance leakage, minimized Footprints, or review pose changes.
func _test_initial_seed_matches_manifest_and_raw_audit_baseline() -> void:
	var audit: Dictionary = _load_json(AUDIT_PATH)
	var manifest: Dictionary = _load_json(MANIFEST_PATH)
	var manifest_assets: Dictionary = manifest["assets"] as Dictionary
	var definitions: Array = PersistentItemCatalog.get("definitions") as Array
	assert(String(audit["schema_version"]) == "1.2")
	assert(manifest_assets.size() == 42)
	assert(definitions.size() == 42)

	var audit_by_key: Dictionary = {}
	for record_value: Variant in audit["assets"] as Array:
		var record: Dictionary = record_value as Dictionary
		audit_by_key[String(record["authoring_key"])] = record
	assert(audit_by_key.size() == 42)

	var seen_ids: Dictionary = {}
	var seen_paths: Dictionary = {}
	for definition_value: Variant in definitions:
		var definition: ItemDefinition = definition_value as ItemDefinition
		assert(definition != null)
		var item_id: String = String(definition.item_id)
		var visual_path: String = definition.visual_scene.resource_path
		assert(manifest_assets.has(item_id))
		assert(audit_by_key.has(item_id))
		assert(not seen_ids.has(item_id))
		assert(not seen_paths.has(visual_path))
		seen_ids[item_id] = true
		seen_paths[visual_path] = true

		var manifest_record: Dictionary = manifest_assets[item_id] as Dictionary
		var audit_record: Dictionary = audit_by_key[item_id] as Dictionary
		assert(String(manifest_record["source_path"]) == visual_path)
		assert(String(audit_record["source_path"]) == visual_path)
		assert(PrototypeItemCatalogScript.get_definition_by_id(definition.item_id) == definition)
		assert(
			PrototypeItemCatalogScript.create_definition_for_scene_path(visual_path)
			== definition
		)
		assert(StorageCategoriesScript.is_item_category(definition.storage_category))
		assert(definition.storage_category != StorageCategoriesScript.GENERAL)
		assert(definition.bulk == 1)
		assert(definition.utility_id == &"None")
		assert(definition.utility_value == 0)
		assert(definition.storage_rotation_degrees == Vector3.ZERO)
		assert(
			definition.storage_footprint
			== Vector3i(
				int(audit_record["raw_width_cells"]),
				int(audit_record["raw_depth_cells"]),
				1
			)
		)
		if visual_path == METAL_CAN_PATH:
			assert(definition.storage_category == StorageCategoriesScript.HYDRATION)


func _load_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert(file != null)
	var parser: JSON = JSON.new()
	assert(parser.parse(file.get_as_text()) == OK)
	file.close()
	assert(parser.data is Dictionary)
	return parser.data as Dictionary
