extends SceneTree

const ItemDefinitionSeederScript = preload(
	"res://tools/asset_pipeline/item_definition_seeder.gd"
)
const AuthoringReviewManifestScript = preload(
	"res://tools/asset_pipeline/authoring_review_manifest.gd"
)
const MainSceneLootAdapterScript = preload(
	"res://tools/asset_pipeline/main_scene_loot_adapter.gd"
)

const MAIN_SCENE_PATH: String = "res://main.tscn"
const AUDIT_PATH: String = "res://reports/asset_pipeline/main_scene_loot_audit.json"
const MANIFEST_PATH: String = "res://tools/asset_pipeline/item_authoring_review.json"
const DEFINITIONS_DIRECTORY: String = "res://data/items/definitions"
const CATALOGUE_PATH: String = "res://data/items/item_catalog.tres"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var report: Dictionary = _load_json_dictionary(AUDIT_PATH)
	var manifest: Dictionary = _load_json_dictionary(MANIFEST_PATH)
	if report.is_empty() or manifest.is_empty():
		quit(1)
		return

	var existing_definition_paths: Dictionary = {}
	var directory: DirAccess = DirAccess.open(DEFINITIONS_DIRECTORY)
	if directory != null:
		for file_name: String in directory.get_files():
			if file_name.get_extension().to_lower() == "tres":
				existing_definition_paths[DEFINITIONS_DIRECTORY.path_join(file_name)] = true

	var scene_records: Array[Dictionary] = MainSceneLootAdapterScript.enumerate_loot_instances(
		MAIN_SCENE_PATH
	)
	var plan: Dictionary = ItemDefinitionSeederScript.plan_seed(
		report,
		manifest,
		scene_records,
		existing_definition_paths,
		AuthoringReviewManifestScript.fingerprint_for_path
	)
	var plan_errors: PackedStringArray = plan["errors"] as PackedStringArray
	if not plan_errors.is_empty():
		for message: String in plan_errors:
			push_error(message)
		push_error("Item definition seed aborted. Rerun the main-scene audit after resolving stale evidence.")
		quit(1)
		return

	var result: Dictionary = ItemDefinitionSeederScript.apply_seed_plan(
		plan, DEFINITIONS_DIRECTORY, CATALOGUE_PATH
	)
	var write_errors: PackedStringArray = result["errors"] as PackedStringArray
	if not write_errors.is_empty():
		for message: String in write_errors:
			push_error(message)
		quit(1)
		return

	var created: PackedStringArray = result["created_paths"] as PackedStringArray
	var skipped: PackedStringArray = result["skipped_existing_paths"] as PackedStringArray
	print(
		"Item definition seed complete: %d created, %d existing definitions preserved."
		% [created.size(), skipped.size()]
	)
	quit(0)


func _load_json_dictionary(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Unable to read JSON file: %s" % path)
		return {}
	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not (parser.data is Dictionary):
		push_error("Invalid JSON dictionary: %s" % path)
		return {}
	return parser.data as Dictionary
