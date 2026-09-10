extends SceneTree

const AuthoringReviewManifestScript = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const AutoStackGroupRegistryScript = preload("res://tools/asset_pipeline/auto_stack_group_registry.gd")
const MainSceneLootAdapterScript = preload("res://tools/asset_pipeline/main_scene_loot_adapter.gd")
const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const StackRoleAuthoringScript = preload("res://tools/asset_pipeline/stack_role_authoring.gd")

const MAIN_SCENE_PATH: String = "res://main.tscn"
const MANIFEST_PATH: String = "res://tools/asset_pipeline/item_authoring_review.json"
const AUTO_STACK_GROUP_REGISTRY_PATH: String = "res://tools/asset_pipeline/auto_stack_group_registry.json"
const NORMALIZED_ITEM_IDS: PackedStringArray = [
	"loot_000006", "loot_000012", "loot_000022", "loot_000029", "loot_000033", "loot_000034", "loot_000039"
]


func _init() -> void:
	quit(_run())


func _run() -> int:
	var current_assets: Array[Dictionary] = []
	for scene_record: Dictionary in MainSceneLootAdapterScript.enumerate_loot_instances(MAIN_SCENE_PATH):
		current_assets.append(_manifest_asset(scene_record))

	var existing_manifest: Dictionary = AuthoringReviewManifestScript.load_manifest(MANIFEST_PATH)
	if OS.get_cmdline_user_args().has("--apply-stack-metadata-phase-1"):
		return _apply_stack_metadata_phase_1(existing_manifest, current_assets)
	if OS.get_cmdline_user_args().has("--apply-stack-role-batch-1"):
		return _apply_stack_role_batch_1(existing_manifest, current_assets)
	if OS.get_cmdline_user_args().has("--apply-stack-role-batch-2"):
		return _apply_stack_role_batch_2(existing_manifest, current_assets)
	if OS.get_cmdline_user_args().has("--apply-stack-role-batch-3"):
		return _apply_stack_role_batch_3(existing_manifest, current_assets)
	if OS.get_cmdline_user_args().has("--apply-stack-role-batch-4"):
		return _apply_stack_role_batch_4(existing_manifest, current_assets)
	if OS.get_cmdline_user_args().has("--item-ids-only"):
		return _sync_item_ids_only(existing_manifest, current_assets)

	var before: String = AuthoringReviewManifestScript.serialize_manifest(existing_manifest)
	var result: Dictionary = AuthoringReviewManifestScript.seed_or_sync(existing_manifest, current_assets)
	var updated_manifest: Dictionary = result["manifest"] as Dictionary
	if OS.get_cmdline_user_args().has("--apply-scale-review-reconciliation"):
		var reconciliation: Dictionary = AuthoringReviewManifestScript.apply_scale_review_reconciliation(
			existing_manifest, current_assets, NORMALIZED_ITEM_IDS
		)
		var errors: PackedStringArray = reconciliation["errors"] as PackedStringArray
		if not errors.is_empty():
			for message: String in errors:
				push_error(message)
			return 1
		updated_manifest = reconciliation["manifest"] as Dictionary
	var after: String = AuthoringReviewManifestScript.serialize_manifest(updated_manifest)
	if before != after and not AuthoringReviewManifestScript.write_manifest(MANIFEST_PATH, updated_manifest):
		return 1

	print("AUTHORING_REVIEW_SYNC_COMPLETE assets=%d records=%d added=%d updated=%d ambiguous=%d wrote=%s" % [
		current_assets.size(),
		(updated_manifest["assets"] as Dictionary).size(),
		(result["added_keys"] as Array).size(),
		(result["updated_keys"] as Array).size(),
		(result["ambiguous_paths"] as Array).size(),
		str(before != after)
	])
	for path_value: String in result["ambiguous_paths"] as Array[String]:
		push_warning("AUTHORING_REVIEW_AMBIGUOUS source_path=%s" % path_value)
	if OS.get_cmdline_user_args().has("--apply-scale-review-reconciliation"):
		print("AUTHORING_REVIEW_SCALE_RECONCILIATION_COMPLETE approved=35 unreviewed=7")
	return 0


func _sync_item_ids_only(
	existing_manifest: Dictionary, current_assets: Array[Dictionary]
) -> int:
	var matches: Array[Dictionary] = AuthoringReviewManifestScript.correlate_current_assets(
		existing_manifest, current_assets
	)
	var associations: Dictionary = {}
	for match: Dictionary in matches:
		var authoring_key: String = String(match.get("authoring_key", ""))
		var problem_flag: String = String(match.get("problem_flag", ""))
		var asset: Dictionary = match.get("asset", {}) as Dictionary
		var item_id: String = String(asset.get("item_id", ""))
		if authoring_key.is_empty() or problem_flag == "AUTHORING_REVIEW_AMBIGUOUS":
			push_error(
				"Cannot sync item ID association for source path: %s"
				% String(asset.get("source_path", ""))
			)
			return 1
		if item_id != authoring_key:
			push_error(
				"ItemDefinition ID '%s' does not match authoring key '%s'."
				% [item_id, authoring_key]
			)
			return 1
		associations[authoring_key] = item_id

	var result: Dictionary = AuthoringReviewManifestScript.sync_item_id_associations(
		existing_manifest, associations
	)
	var unknown_keys: PackedStringArray = result["unknown_keys"] as PackedStringArray
	if not unknown_keys.is_empty():
		push_error("Manifest item ID sync found unknown authoring keys: %s" % ", ".join(unknown_keys))
		return 1

	var updated_manifest: Dictionary = result["manifest"] as Dictionary
	var before: String = AuthoringReviewManifestScript.serialize_manifest(existing_manifest)
	var after: String = AuthoringReviewManifestScript.serialize_manifest(updated_manifest)
	if before != after and not AuthoringReviewManifestScript.write_manifest(
		MANIFEST_PATH, updated_manifest
	):
		return 1

	print(
		"AUTHORING_REVIEW_ITEM_ID_SYNC_COMPLETE records=%d updated=%d wrote=%s"
		% [
			associations.size(),
			(result["updated_keys"] as PackedStringArray).size(),
			str(before != after)
		]
	)
	return 0


func _manifest_asset(scene_record: Dictionary) -> Dictionary:
	var source_path: String = String(scene_record.get("source_path", ""))
	var definition: ItemDefinition = PrototypeItemCatalogScript.create_definition_for_scene_path(source_path)
	return {
		"source_path": source_path,
		"item_id": String(definition.item_id) if definition != null else "",
		"source_fingerprint": AuthoringReviewManifestScript.fingerprint_for_path(source_path),
		"has_item_definition": definition != null,
		"definition_path": definition.resource_path if definition != null else "",
		"display_name": definition.display_name if definition != null else "",
		"storage_category": definition.storage_category if definition != null else "",
		"storage_rotation_degrees": _vector3_array(definition.storage_rotation_degrees) if definition != null else [],
		"storage_footprint": _vector3i_array(definition.storage_footprint) if definition != null else [],
		"can_be_stacked": definition.can_be_stacked if definition != null else false,
		"can_support_stack": definition.can_support_stack if definition != null else false,
		"auto_stack_group": String(definition.auto_stack_group) if definition != null else ""
	}


func _apply_stack_metadata_phase_1(
	existing_manifest: Dictionary,
	current_assets: Array[Dictionary]
) -> int:
	var registry: Dictionary = AutoStackGroupRegistryScript.load_registry(
		AUTO_STACK_GROUP_REGISTRY_PATH
	)
	var result: Dictionary = StackRoleAuthoringScript.apply_phase_1(
		existing_manifest,
		current_assets,
		registry
	)
	var errors: PackedStringArray = result["errors"] as PackedStringArray
	if not errors.is_empty():
		for message: String in errors:
			push_error(message)
		return 1

	var updated_resource_count: int = 0
	var candidate_values: Dictionary = result["candidate_values"] as Dictionary
	for item_id: String in StackRoleAuthoringScript.candidate_ids():
		var values: Dictionary = candidate_values[item_id] as Dictionary
		var definition_path: String = String(values["definition_path"])
		var definition: ItemDefinition = load(definition_path) as ItemDefinition
		if definition == null:
			push_error("Unable to load Phase 1 candidate ItemDefinition: %s" % definition_path)
			return 1
		var changed: bool = (
			definition.can_be_stacked != bool(values["can_be_stacked"])
			or definition.can_support_stack != bool(values["can_support_stack"])
		)
		if not changed:
			continue
		definition.can_be_stacked = bool(values["can_be_stacked"])
		definition.can_support_stack = bool(values["can_support_stack"])
		var save_error: Error = ResourceSaver.save(definition, definition_path)
		if save_error != OK:
			push_error("Unable to save Phase 1 candidate ItemDefinition: %s" % definition_path)
			return 1
		updated_resource_count += 1

	var updated_manifest: Dictionary = result["manifest"] as Dictionary
	var serialized_manifest: String = AuthoringReviewManifestScript.serialize_manifest(updated_manifest)
	var existing_text: String = _file_text(MANIFEST_PATH)
	var wrote_manifest: bool = existing_text != serialized_manifest
	if wrote_manifest and not AuthoringReviewManifestScript.write_manifest(
		MANIFEST_PATH, updated_manifest
	):
		return 1

	var counts: Dictionary = result["counts"] as Dictionary
	print(
		"STACK_METADATA_PHASE_1_COMPLETE grandfathered=%d candidates=%d blocked=%d resources_updated=%d manifest_written=%s"
		% [
			int(counts["grandfathered"]),
			int(counts["candidates"]),
			int(counts["blocked"]),
			updated_resource_count,
			str(wrote_manifest)
		]
	)
	return 0


func _apply_stack_role_batch_1(
	existing_manifest: Dictionary,
	current_assets: Array[Dictionary]
) -> int:
	var registry: Dictionary = AutoStackGroupRegistryScript.load_registry(
		AUTO_STACK_GROUP_REGISTRY_PATH
	)
	var result: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_1(
		existing_manifest,
		current_assets,
		registry
	)
	var errors: PackedStringArray = result["errors"] as PackedStringArray
	if not errors.is_empty():
		for message: String in errors:
			push_error(message)
		return 1
	var updated_manifest: Dictionary = result["manifest"] as Dictionary
	var serialized_manifest: String = AuthoringReviewManifestScript.serialize_manifest(updated_manifest)
	var existing_text: String = _file_text(MANIFEST_PATH)
	var wrote_manifest: bool = existing_text != serialized_manifest
	if wrote_manifest and not AuthoringReviewManifestScript.write_manifest(
		MANIFEST_PATH, updated_manifest
	):
		return 1
	var approved_item_ids: PackedStringArray = result["approved_item_ids"] as PackedStringArray
	print(
		"STACK_ROLE_BATCH_1_APPLY_COMPLETE approved=%d manifest_written=%s item_ids=%s"
		% [approved_item_ids.size(), str(wrote_manifest), ",".join(approved_item_ids)]
	)
	return 0


func _apply_stack_role_batch_2(
	existing_manifest: Dictionary,
	current_assets: Array[Dictionary]
) -> int:
	var updated_resource_count: int = 0
	for item_id: String in ["loot_000024", "loot_000025", "loot_000027"]:
		var role: Array = StackRoleAuthoringScript.batch_two_reviewed_role(item_id)
		var definition_path: String = "res://data/items/definitions/%s.tres" % item_id
		var definition: ItemDefinition = load(definition_path) as ItemDefinition
		if definition == null:
			push_error("Unable to load Batch 2 ItemDefinition: %s" % definition_path)
			return 1
		if definition.can_be_stacked == bool(role[0]) and definition.can_support_stack == bool(role[1]):
			continue
		definition.can_be_stacked = bool(role[0])
		definition.can_support_stack = bool(role[1])
		if ResourceSaver.save(definition, definition_path) != OK:
			push_error("Unable to save Batch 2 ItemDefinition: %s" % definition_path)
			return 1
		updated_resource_count += 1
	var updated_assets: Array[Dictionary] = []
	for scene_record: Dictionary in MainSceneLootAdapterScript.enumerate_loot_instances(MAIN_SCENE_PATH):
		updated_assets.append(_manifest_asset(scene_record))
	var registry: Dictionary = AutoStackGroupRegistryScript.load_registry(
		AUTO_STACK_GROUP_REGISTRY_PATH
	)
	var result: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_2(
		existing_manifest, updated_assets, registry
	)
	var errors: PackedStringArray = result["errors"] as PackedStringArray
	if not errors.is_empty():
		for message: String in errors:
			push_error(message)
		return 1
	var updated_manifest: Dictionary = result["manifest"] as Dictionary
	var serialized_manifest: String = AuthoringReviewManifestScript.serialize_manifest(updated_manifest)
	var wrote_manifest: bool = _file_text(MANIFEST_PATH) != serialized_manifest
	if wrote_manifest and not AuthoringReviewManifestScript.write_manifest(MANIFEST_PATH, updated_manifest):
		return 1
	var approved_item_ids: PackedStringArray = result["approved_item_ids"] as PackedStringArray
	print(
		"STACK_ROLE_BATCH_2_APPLY_COMPLETE approved=%d resources_updated=%d manifest_written=%s item_ids=%s"
		% [approved_item_ids.size(), updated_resource_count, str(wrote_manifest), ",".join(approved_item_ids)]
	)
	return 0


func _apply_stack_role_batch_3(
	existing_manifest: Dictionary,
	current_assets: Array[Dictionary]
) -> int:
	var updated_resource_count: int = 0
	for item_id: String in ["loot_000012", "loot_000014", "loot_000029"]:
		var role: Array = StackRoleAuthoringScript.batch_three_reviewed_role(item_id)
		var definition_path: String = "res://data/items/definitions/%s.tres" % item_id
		var definition: ItemDefinition = load(definition_path) as ItemDefinition
		if definition == null:
			push_error("Unable to load Batch 3 ItemDefinition: %s" % definition_path)
			return 1
		if definition.can_be_stacked == bool(role[0]) and definition.can_support_stack == bool(role[1]):
			continue
		definition.can_be_stacked = bool(role[0])
		definition.can_support_stack = bool(role[1])
		if ResourceSaver.save(definition, definition_path) != OK:
			push_error("Unable to save Batch 3 ItemDefinition: %s" % definition_path)
			return 1
		updated_resource_count += 1
	var updated_assets: Array[Dictionary] = []
	for scene_record: Dictionary in MainSceneLootAdapterScript.enumerate_loot_instances(MAIN_SCENE_PATH):
		updated_assets.append(_manifest_asset(scene_record))
	var registry: Dictionary = AutoStackGroupRegistryScript.load_registry(AUTO_STACK_GROUP_REGISTRY_PATH)
	var result: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_3(existing_manifest, updated_assets, registry)
	var errors: PackedStringArray = result["errors"] as PackedStringArray
	if not errors.is_empty():
		for message: String in errors:
			push_error(message)
		return 1
	var updated_manifest: Dictionary = result["manifest"] as Dictionary
	var serialized_manifest: String = AuthoringReviewManifestScript.serialize_manifest(updated_manifest)
	var wrote_manifest: bool = _file_text(MANIFEST_PATH) != serialized_manifest
	if wrote_manifest and not AuthoringReviewManifestScript.write_manifest(MANIFEST_PATH, updated_manifest):
		return 1
	var approved_item_ids: PackedStringArray = result["approved_item_ids"] as PackedStringArray
	print("STACK_ROLE_BATCH_3_APPLY_COMPLETE approved=%d resources_updated=%d manifest_written=%s item_ids=%s" % [approved_item_ids.size(), updated_resource_count, str(wrote_manifest), ",".join(approved_item_ids)])
	return 0

func _apply_stack_role_batch_4(existing_manifest: Dictionary, current_assets: Array[Dictionary]) -> int:
	var definition: ItemDefinition = load("res://data/items/definitions/loot_000032.tres") as ItemDefinition
	if definition == null: return 1
	var updated_resource_count: int = 0
	if not definition.can_be_stacked or definition.can_support_stack:
		definition.can_be_stacked = true
		definition.can_support_stack = false
		if ResourceSaver.save(definition, "res://data/items/definitions/loot_000032.tres") != OK: return 1
		updated_resource_count = 1
	var updated_assets: Array[Dictionary] = []
	for scene_record: Dictionary in MainSceneLootAdapterScript.enumerate_loot_instances(MAIN_SCENE_PATH): updated_assets.append(_manifest_asset(scene_record))
	var result: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_4(existing_manifest, updated_assets, AutoStackGroupRegistryScript.load_registry(AUTO_STACK_GROUP_REGISTRY_PATH))
	var errors: PackedStringArray = result["errors"] as PackedStringArray
	if not errors.is_empty():
		for message: String in errors: push_error(message)
		return 1
	var updated_manifest: Dictionary = result["manifest"] as Dictionary
	var wrote_manifest: bool = _file_text(MANIFEST_PATH) != AuthoringReviewManifestScript.serialize_manifest(updated_manifest)
	if wrote_manifest and not AuthoringReviewManifestScript.write_manifest(MANIFEST_PATH, updated_manifest): return 1
	print("STACK_ROLE_BATCH_4_APPLY_COMPLETE approved=%d resources_updated=%d manifest_written=%s" % [(result["approved_item_ids"] as PackedStringArray).size(), updated_resource_count, str(wrote_manifest)])
	return 0


func _file_text(path: String) -> String:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var result: String = file.get_as_text()
	file.close()
	return result


func _vector3_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _vector3i_array(value: Vector3i) -> Array[int]:
	return [value.x, value.y, value.z]
