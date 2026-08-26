extends SceneTree

const ItemDefinitionSeederScript = preload(
	"res://tools/asset_pipeline/item_definition_seeder.gd"
)
const ItemDefinitionScript = preload("res://item_definition.gd")

var _fingerprints: Dictionary = {}


func _init() -> void:
	_test_valid_missing_record_produces_approved_scaffold()
	_test_wrong_audit_schema_is_rejected()
	_test_missing_authoring_key_is_rejected()
	_test_stale_fingerprint_is_rejected()
	_test_scene_and_audit_path_sets_must_match()
	_test_existing_definition_is_never_planned_for_update()
	_test_metal_can_category_is_hydration()
	_test_general_is_rejected_as_an_item_category()
	_test_provisional_display_name_is_readable()
	_test_apply_plan_preserves_existing_definition_bytes()
	print("PASS: item definition seeder tests")
	quit(0)


# Catches wrong scaffold defaults or an orientation-B/minimized Footprint seed.
func _test_valid_missing_record_produces_approved_scaffold() -> void:
	var path: String = "res://assets/props/Food/New_Item.glb"
	var report: Dictionary = _report(_audit_record(path, "loot_000043", "hash-new"))
	var manifest: Dictionary = _manifest("loot_000043", path, "hash-new")
	_fingerprints = {path: "hash-new"}
	var result: Dictionary = ItemDefinitionSeederScript.plan_seed(
		report, manifest, _scene_records([path]), {}, _fingerprint_for_test
	)

	assert((result["errors"] as PackedStringArray).is_empty())
	var creations: Array = result["definitions_to_create"] as Array
	assert(creations.size() == 1)
	var seed: Dictionary = creations[0] as Dictionary
	assert(seed["item_id"] == &"loot_000043")
	assert(String(seed["visual_scene_path"]) == path)
	assert(int(seed["bulk"]) == 1)
	assert(seed["utility_id"] == &"None")
	assert(int(seed["utility_value"]) == 0)
	assert(seed["storage_footprint"] == Vector3i(2, 3, 1))
	assert(seed["storage_rotation_degrees"] == Vector3.ZERO)
	assert(String(seed["storage_category"]) == "Food")


# Catches accidental consumption of obsolete generated-audit formats.
func _test_wrong_audit_schema_is_rejected() -> void:
	var path: String = "res://assets/props/Food/New_Item.glb"
	var report: Dictionary = _report(_audit_record(path, "loot_000043", "hash-new"))
	report["schema_version"] = "1.1"
	_fingerprints = {path: "hash-new"}
	var result: Dictionary = ItemDefinitionSeederScript.plan_seed(
		report,
		_manifest("loot_000043", path, "hash-new"),
		_scene_records([path]),
		{},
		_fingerprint_for_test
	)
	assert(_errors_contain(result["errors"] as PackedStringArray, "schema 1.2"))


# Catches definition creation without durable manifest identity.
func _test_missing_authoring_key_is_rejected() -> void:
	var path: String = "res://assets/props/Food/New_Item.glb"
	var record: Dictionary = _audit_record(path, "", "hash-new")
	_fingerprints = {path: "hash-new"}
	var result: Dictionary = ItemDefinitionSeederScript.plan_seed(
		_report(record),
		{"schema_version": "1.0", "assets": {}},
		_scene_records([path]),
		{},
		_fingerprint_for_test
	)
	assert(_errors_contain(result["errors"] as PackedStringArray, "authoring_key"))


# Catches creation from an audit measured against older GLB bytes.
func _test_stale_fingerprint_is_rejected() -> void:
	var path: String = "res://assets/props/Food/New_Item.glb"
	_fingerprints = {path: "current-hash"}
	var result: Dictionary = ItemDefinitionSeederScript.plan_seed(
		_report(_audit_record(path, "loot_000043", "old-hash")),
		_manifest("loot_000043", path, "old-hash"),
		_scene_records([path]),
		{},
		_fingerprint_for_test
	)
	assert(_errors_contain(result["errors"] as PackedStringArray, "fingerprint"))


# Catches partial seeding after main-scene loot membership changes.
func _test_scene_and_audit_path_sets_must_match() -> void:
	var path: String = "res://assets/props/Food/New_Item.glb"
	_fingerprints = {path: "hash-new"}
	var result: Dictionary = ItemDefinitionSeederScript.plan_seed(
		_report(_audit_record(path, "loot_000043", "hash-new")),
		_manifest("loot_000043", path, "hash-new"),
		_scene_records([path, "res://assets/props/Food/Another.glb"]),
		{},
		_fingerprint_for_test
	)
	assert(_errors_contain(result["errors"] as PackedStringArray, "asset set"))


# Catches a future rerun turning advisory audit values into authored updates.
func _test_existing_definition_is_never_planned_for_update() -> void:
	var path: String = "res://assets/props/Food/New_Item.glb"
	var definition_path: String = "res://data/items/definitions/loot_000043.tres"
	_fingerprints = {path: "hash-new"}
	var result: Dictionary = ItemDefinitionSeederScript.plan_seed(
		_report(_audit_record(path, "loot_000043", "hash-new")),
		_manifest("loot_000043", path, "hash-new"),
		_scene_records([path]),
		{definition_path: true},
		_fingerprint_for_test
	)
	assert((result["errors"] as PackedStringArray).is_empty())
	assert((result["definitions_to_create"] as Array).is_empty())
	assert((result["catalogue_paths_to_append"] as PackedStringArray).is_empty())


# Catches regression to the legacy Food assignment for this confirmed asset.
func _test_metal_can_category_is_hydration() -> void:
	var path: String = "res://assets/props/Hydration/SM_Metal_Can_01a.glb"
	var record: Dictionary = _audit_record(path, "loot_000019", "hash-can")
	record["authored_category"] = "Food"
	record["folder_category_hint"] = "Hydration"
	_fingerprints = {path: "hash-can"}
	var result: Dictionary = ItemDefinitionSeederScript.plan_seed(
		_report(record),
		_manifest("loot_000019", path, "hash-can"),
		_scene_records([path]),
		{},
		_fingerprint_for_test
	)
	var seed: Dictionary = (result["definitions_to_create"] as Array)[0] as Dictionary
	assert(String(seed["storage_category"]) == "Hydration")


# Catches zone-only General leaking into persistent item data.
func _test_general_is_rejected_as_an_item_category() -> void:
	var path: String = "res://assets/props/General/Unknown.glb"
	var record: Dictionary = _audit_record(path, "loot_000043", "hash-general")
	record["folder_category_hint"] = "General"
	_fingerprints = {path: "hash-general"}
	var result: Dictionary = ItemDefinitionSeederScript.plan_seed(
		_report(record),
		_manifest("loot_000043", path, "hash-general"),
		_scene_records([path]),
		{},
		_fingerprint_for_test
	)
	assert(_errors_contain(result["errors"] as PackedStringArray, "valid item category"))


# Catches raw technical basenames being exposed unchanged to players.
func _test_provisional_display_name_is_readable() -> void:
	assert(
		ItemDefinitionSeederScript.provisional_display_name(
			"res://assets/props/electronics/SM_ComputerMouse_01.glb"
		) == "Computer Mouse 01"
	)


# Catches a writer regression that overwrites reviewed authored data or adds an
# old pre-existing file to catalogue membership during an unrelated new seed.
func _test_apply_plan_preserves_existing_definition_bytes() -> void:
	var fixture_root: String = "user://item-seeder-test-%d" % Time.get_ticks_usec()
	var definitions_directory: String = fixture_root + "/definitions"
	var catalogue_path: String = fixture_root + "/item_catalog.tres"
	assert(
		DirAccess.make_dir_recursive_absolute(
			ProjectSettings.globalize_path(definitions_directory)
		) == OK
	)

	var existing_path: String = definitions_directory + "/loot_000001.tres"
	var existing: ItemDefinition = ItemDefinitionScript.new()
	existing.item_id = &"loot_000001"
	existing.display_name = "Reviewed Existing Name"
	existing.bulk = 77
	existing.utility_id = &"ReviewedUtility"
	existing.utility_value = 91
	existing.storage_category = "Medical"
	existing.storage_footprint = Vector3i(8, 9, 1)
	existing.storage_rotation_degrees = Vector3(10.0, 20.0, 30.0)
	existing.visual_scene = load("res://assets/props/Food/cereal_box.glb") as PackedScene
	assert(ResourceSaver.save(existing, existing_path) == OK)
	var before_bytes: PackedByteArray = FileAccess.get_file_as_bytes(existing_path)

	var existing_seed: Dictionary = _seed_record(
		&"loot_000001", "res://assets/props/Food/cereal_box.glb"
	)
	var missing_seed: Dictionary = _seed_record(
		&"loot_000002", "res://assets/props/Hydration/soda_can.glb"
	)
	var apply_result: Dictionary = ItemDefinitionSeederScript.apply_seed_plan(
		{
			"errors": PackedStringArray(),
			"definitions_to_create": [existing_seed, missing_seed]
		},
		definitions_directory,
		catalogue_path
	)

	assert((apply_result["errors"] as PackedStringArray).is_empty())
	assert((apply_result["created_paths"] as PackedStringArray).size() == 1)
	assert(
		(apply_result["created_paths"] as PackedStringArray)[0]
		== definitions_directory + "/loot_000002.tres"
	)
	assert(FileAccess.get_file_as_bytes(existing_path) == before_bytes)
	var loaded_existing: Resource = ResourceLoader.load(
		existing_path, "", ResourceLoader.CACHE_MODE_IGNORE
	)
	assert(loaded_existing is ItemDefinition)
	assert((loaded_existing as ItemDefinition).bulk == 77)

	var loaded_catalogue: Resource = ResourceLoader.load(
		catalogue_path, "", ResourceLoader.CACHE_MODE_IGNORE
	)
	assert(loaded_catalogue != null)
	var members: Array = loaded_catalogue.get("definitions") as Array
	assert(members.size() == 1)
	assert((members[0] as ItemDefinition).item_id == &"loot_000002")
	assert(
		(members[0] as ItemDefinition).resource_path
		== definitions_directory + "/loot_000002.tres"
	)
	_remove_test_tree(fixture_root)


func _report(record: Dictionary) -> Dictionary:
	return {"schema_version": "1.2", "assets": [record]}


func _audit_record(path: String, authoring_key: String, fingerprint: String) -> Dictionary:
	return {
		"source_path": path,
		"authoring_key": authoring_key,
		"source_fingerprint": fingerprint,
		"authored_category": "",
		"folder_category_hint": "Food",
		"raw_width_cells": 2,
		"raw_depth_cells": 3
	}


func _manifest(authoring_key: String, path: String, fingerprint: String) -> Dictionary:
	return {
		"schema_version": "1.0",
		"assets": {
			authoring_key: {
				"source_path": path,
				"source_fingerprint": fingerprint,
				"item_id": ""
			}
		}
	}


func _scene_records(paths: Array[String]) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for path: String in paths:
		records.append({"source_path": path})
	return records


func _fingerprint_for_test(path: String) -> String:
	return String(_fingerprints.get(path, ""))


func _seed_record(item_id: StringName, visual_path: String) -> Dictionary:
	return {
		"item_id": item_id,
		"display_name": "Seeded Item",
		"visual_scene_path": visual_path,
		"bulk": 1,
		"utility_id": &"None",
		"utility_value": 0,
		"storage_category": "Food",
		"storage_footprint": Vector3i(1, 1, 1),
		"storage_rotation_degrees": Vector3.ZERO
	}


func _remove_test_tree(path: String) -> void:
	var directory: DirAccess = DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry: String = directory.get_next()
	while not entry.is_empty():
		var child_path: String = path.path_join(entry)
		if directory.current_is_dir():
			_remove_test_tree(child_path)
		else:
			directory.remove(entry)
		entry = directory.get_next()
	directory.list_dir_end()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _errors_contain(errors: PackedStringArray, fragment: String) -> bool:
	for error: String in errors:
		if error.contains(fragment):
			return true
	return false
