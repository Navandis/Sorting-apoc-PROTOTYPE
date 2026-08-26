extends RefCounted
class_name ItemDefinitionSeeder

const StorageCategoriesScript = preload("res://storage_categories.gd")
const ItemCatalogScript = preload("res://item_catalog.gd")
const ItemDefinitionScript = preload("res://item_definition.gd")

const AUDIT_SCHEMA_VERSION: String = "1.2"
const MANIFEST_SCHEMA_VERSION: String = "1.0"
const DEFINITION_DIRECTORY: String = "res://data/items/definitions"
const METAL_CAN_PATH: String = "res://assets/props/Hydration/SM_Metal_Can_01a.glb"

const LEGACY_DISPLAY_NAMES: Dictionary = {
	"res://assets/props/Food/cereal_box.glb": "Cereal Box",
	"res://assets/props/medical/pill_bottle.glb": "Painkillers",
	"res://assets/props/Weapons/hammer.glb": "Hammer",
	"res://assets/props/Hydration/soda_can.glb": "Soda Can",
	"res://assets/props/Weapons/tennis_racket.glb": "Tennis Racket",
	"res://assets/props/Weapons/SM_Gun_AssaultRifle.glb": "Assault Rifle",
	"res://assets/props/Weapons/SM_Gun_Pistol.glb": "Pistol",
	"res://assets/props/Weapons/SM_Gun_Shotgun.glb": "Shotgun",
	"res://assets/props/Hydration/SM_Metal_Can_01a.glb": "Food Can",
	"res://assets/props/medical/SM_CoughSyrup_01.glb": "Medicine Bottle",
	"res://assets/props/medical/SM_Antibiotics_01.glb": "Medicine Bottle"
}


static func plan_seed(
	report: Dictionary,
	manifest: Dictionary,
	scene_records: Array[Dictionary],
	existing_definition_paths: Dictionary,
	fingerprint_provider: Callable
) -> Dictionary:
	var errors: PackedStringArray = validate_inputs(
		report, manifest, scene_records, fingerprint_provider
	)
	var result: Dictionary = {
		"errors": errors,
		"definitions_to_create": [],
		"catalogue_paths_to_append": PackedStringArray()
	}
	if not errors.is_empty():
		return result

	var manifest_assets: Dictionary = manifest["assets"] as Dictionary
	var definitions_to_create: Array[Dictionary] = []
	var catalogue_paths: PackedStringArray = []
	for record_value: Variant in report["assets"] as Array:
		var audit_record: Dictionary = record_value as Dictionary
		var authoring_key: String = String(audit_record["authoring_key"])
		var definition_path: String = "%s/%s.tres" % [DEFINITION_DIRECTORY, authoring_key]
		if existing_definition_paths.has(definition_path):
			continue
		definitions_to_create.append(
			build_seed_record(audit_record, manifest_assets[authoring_key] as Dictionary)
		)
		catalogue_paths.append(definition_path)

	result["definitions_to_create"] = definitions_to_create
	result["catalogue_paths_to_append"] = catalogue_paths
	return result


static func validate_inputs(
	report: Dictionary,
	manifest: Dictionary,
	scene_records: Array[Dictionary],
	fingerprint_provider: Callable
) -> PackedStringArray:
	var errors: PackedStringArray = []
	if String(report.get("schema_version", "")) != AUDIT_SCHEMA_VERSION:
		errors.append("Item definition seed requires audit schema 1.2.")
		return errors
	if String(manifest.get("schema_version", "")) != MANIFEST_SCHEMA_VERSION:
		errors.append("Item definition seed requires manifest schema 1.0.")
		return errors
	if not (report.get("assets", []) is Array):
		errors.append("Audit assets must be an array.")
		return errors
	if not (manifest.get("assets", {}) is Dictionary):
		errors.append("Manifest assets must be a dictionary.")
		return errors

	var manifest_assets: Dictionary = manifest["assets"] as Dictionary
	var audit_paths: PackedStringArray = []
	var authoring_keys: Dictionary = {}
	for record_value: Variant in report["assets"] as Array:
		if not (record_value is Dictionary):
			errors.append("Audit contains a non-dictionary asset record.")
			continue
		var record: Dictionary = record_value as Dictionary
		var source_path: String = String(record.get("source_path", ""))
		var authoring_key: String = String(record.get("authoring_key", ""))
		var recorded_fingerprint: String = String(record.get("source_fingerprint", ""))
		audit_paths.append(source_path)

		if authoring_key.is_empty():
			errors.append("Audit asset '%s' has no authoring_key." % source_path)
			continue
		if authoring_keys.has(authoring_key):
			errors.append("Duplicate audit authoring_key '%s'." % authoring_key)
		else:
			authoring_keys[authoring_key] = true
		if not manifest_assets.has(authoring_key):
			errors.append("Manifest has no record for authoring_key '%s'." % authoring_key)
			continue

		var manifest_record: Dictionary = manifest_assets[authoring_key] as Dictionary
		if String(manifest_record.get("source_path", "")) != source_path:
			errors.append("Manifest source path differs for '%s'." % authoring_key)
		if String(manifest_record.get("source_fingerprint", "")) != recorded_fingerprint:
			errors.append("Manifest fingerprint differs for '%s'." % source_path)

		var current_fingerprint: String = ""
		if fingerprint_provider.is_valid():
			current_fingerprint = String(fingerprint_provider.call(source_path))
		if current_fingerprint.is_empty() or current_fingerprint != recorded_fingerprint:
			errors.append("Audit fingerprint is stale for '%s'." % source_path)

		var category_error: String = _category_error(record)
		if not category_error.is_empty():
			errors.append(category_error)

	var scene_paths: PackedStringArray = []
	for scene_record: Dictionary in scene_records:
		scene_paths.append(String(scene_record.get("source_path", "")))
	audit_paths.sort()
	scene_paths.sort()
	if audit_paths != scene_paths:
		errors.append("Current main-scene asset set does not match the audit asset set.")

	return errors


static func build_seed_record(audit_record: Dictionary, _manifest_record: Dictionary) -> Dictionary:
	var source_path: String = String(audit_record["source_path"])
	return {
		"item_id": StringName(String(audit_record["authoring_key"])),
		"display_name": _display_name_for(source_path),
		"visual_scene_path": source_path,
		"bulk": 1,
		"utility_id": &"None",
		"utility_value": 0,
		"storage_category": _category_for(audit_record),
		"storage_footprint": Vector3i(
			int(audit_record.get("raw_width_cells", 0)),
			int(audit_record.get("raw_depth_cells", 0)),
			1
		),
		"storage_rotation_degrees": Vector3.ZERO
	}


static func apply_seed_plan(
	seed_plan: Dictionary,
	definitions_directory: String = DEFINITION_DIRECTORY,
	catalogue_path: String = "res://data/items/item_catalog.tres"
) -> Dictionary:
	var errors: PackedStringArray = []
	var planned_errors_value: Variant = seed_plan.get("errors", PackedStringArray())
	if planned_errors_value is PackedStringArray:
		errors = (planned_errors_value as PackedStringArray).duplicate()
	if not errors.is_empty():
		return {
			"errors": errors,
			"created_paths": PackedStringArray(),
			"skipped_existing_paths": PackedStringArray()
		}

	var absolute_directory: String = ProjectSettings.globalize_path(definitions_directory)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK:
		errors.append("Unable to create item definition directory: %s" % definitions_directory)
		return {
			"errors": errors,
			"created_paths": PackedStringArray(),
			"skipped_existing_paths": PackedStringArray()
		}

	var seeds_value: Variant = seed_plan.get("definitions_to_create", [])
	var seeds: Array = seeds_value as Array if seeds_value is Array else []
	var prepared: Array[Dictionary] = []
	for seed_value: Variant in seeds:
		if not (seed_value is Dictionary):
			errors.append("Seed plan contains a non-dictionary definition record.")
			continue
		var seed: Dictionary = seed_value as Dictionary
		var item_id: String = String(seed.get("item_id", ""))
		var target_path: String = definitions_directory.path_join(item_id + ".tres")
		if item_id.is_empty():
			errors.append("Seed plan contains an empty ItemDefinition ID.")
			continue
		if FileAccess.file_exists(target_path):
			prepared.append({"seed": seed, "target_path": target_path, "existing": true})
			continue
		var visual_path: String = String(seed.get("visual_scene_path", ""))
		var visual_resource: Resource = load(visual_path)
		if not (visual_resource is PackedScene):
			errors.append("Unable to load ItemDefinition visual: %s" % visual_path)
			continue
		prepared.append({
			"seed": seed,
			"target_path": target_path,
			"existing": false,
			"visual_scene": visual_resource
		})

	if not errors.is_empty():
		return {
			"errors": errors,
			"created_paths": PackedStringArray(),
			"skipped_existing_paths": PackedStringArray()
		}

	var created_paths: PackedStringArray = []
	var skipped_paths: PackedStringArray = []
	var created_definitions: Array[ItemDefinition] = []
	for operation: Dictionary in prepared:
		var target_path: String = String(operation["target_path"])
		if bool(operation["existing"]):
			skipped_paths.append(target_path)
			continue
		var seed: Dictionary = operation["seed"] as Dictionary
		var definition: ItemDefinition = ItemDefinitionScript.new()
		definition.item_id = seed["item_id"] as StringName
		definition.display_name = String(seed["display_name"])
		definition.visual_scene = operation["visual_scene"] as PackedScene
		definition.bulk = int(seed["bulk"])
		definition.utility_id = seed["utility_id"] as StringName
		definition.utility_value = int(seed["utility_value"])
		definition.storage_category = String(seed["storage_category"])
		definition.storage_footprint = seed["storage_footprint"] as Vector3i
		definition.storage_rotation_degrees = seed["storage_rotation_degrees"] as Vector3
		var save_error: Error = ResourceSaver.save(definition, target_path)
		if save_error != OK:
			errors.append("Unable to save ItemDefinition: %s" % target_path)
			continue
		var saved_resource: Resource = ResourceLoader.load(
			target_path, "", ResourceLoader.CACHE_MODE_IGNORE
		)
		if not (saved_resource is ItemDefinition):
			errors.append("Unable to reload saved ItemDefinition: %s" % target_path)
			continue
		created_paths.append(target_path)
		created_definitions.append(saved_resource as ItemDefinition)

	if not errors.is_empty() or created_definitions.is_empty():
		return {
			"errors": errors,
			"created_paths": created_paths,
			"skipped_existing_paths": skipped_paths
		}

	var catalogue: Resource
	var catalogue_definitions: Array[ItemDefinition] = []
	if FileAccess.file_exists(catalogue_path):
		catalogue = ResourceLoader.load(
			catalogue_path, "", ResourceLoader.CACHE_MODE_IGNORE
		)
		if catalogue == null or catalogue.get_script() != ItemCatalogScript:
			errors.append("Existing item catalogue has the wrong resource type: %s" % catalogue_path)
			return {
				"errors": errors,
				"created_paths": created_paths,
				"skipped_existing_paths": skipped_paths
			}
		var existing_members_value: Variant = catalogue.get("definitions")
		if existing_members_value is Array:
			for member_value: Variant in existing_members_value as Array:
				if member_value is ItemDefinition:
					catalogue_definitions.append(member_value as ItemDefinition)
	else:
		catalogue = ItemCatalogScript.new()

	for definition: ItemDefinition in created_definitions:
		catalogue_definitions.append(definition)
	catalogue.call("set_definitions", catalogue_definitions)
	var catalogue_save_error: Error = ResourceSaver.save(catalogue, catalogue_path)
	if catalogue_save_error != OK:
		errors.append("Unable to save item catalogue: %s" % catalogue_path)

	return {
		"errors": errors,
		"created_paths": created_paths,
		"skipped_existing_paths": skipped_paths
	}


static func provisional_display_name(source_path: String) -> String:
	var basename: String = source_path.get_file().get_basename()
	if basename.begins_with("SM_"):
		basename = basename.trim_prefix("SM_")
	basename = basename.replace("_", " ")
	var camel_splitter: RegEx = RegEx.new()
	camel_splitter.compile("([a-z0-9])([A-Z])")
	basename = camel_splitter.sub(basename, "$1 $2", true)
	var whitespace: RegEx = RegEx.new()
	whitespace.compile("\\s+")
	return whitespace.sub(basename, " ", true).strip_edges()


static func _display_name_for(source_path: String) -> String:
	return String(
		LEGACY_DISPLAY_NAMES.get(source_path, provisional_display_name(source_path))
	)


static func _category_error(record: Dictionary) -> String:
	var source_path: String = String(record.get("source_path", ""))
	if source_path == METAL_CAN_PATH:
		return ""
	var authored: String = _canonical_category(String(record.get("authored_category", "")))
	var hinted: String = _canonical_category(String(record.get("folder_category_hint", "")))
	if authored.is_empty() and hinted.is_empty():
		return "Asset '%s' has no valid item category." % source_path
	if not authored.is_empty() and not hinted.is_empty() and authored != hinted:
		return "Asset '%s' has an ambiguous authored/folder category conflict." % source_path
	return ""


static func _category_for(record: Dictionary) -> String:
	if String(record.get("source_path", "")) == METAL_CAN_PATH:
		return StorageCategoriesScript.HYDRATION
	var authored: String = _canonical_category(String(record.get("authored_category", "")))
	if not authored.is_empty():
		return authored
	return _canonical_category(String(record.get("folder_category_hint", "")))


static func _canonical_category(value: String) -> String:
	var normalized: String = value.strip_edges().to_lower()
	for category: String in StorageCategoriesScript.ITEM_CATEGORIES:
		if category.to_lower() == normalized:
			return category
	return ""
