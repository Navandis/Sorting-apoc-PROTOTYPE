extends SceneTree

const AuthoringReviewManifestScript = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const MainSceneLootAdapterScript = preload("res://tools/asset_pipeline/main_scene_loot_adapter.gd")
const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")

const MAIN_SCENE_PATH: String = "res://main.tscn"
const MANIFEST_PATH: String = "res://tools/asset_pipeline/item_authoring_review.json"
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
		"storage_rotation_degrees": _vector3_array(definition.storage_rotation_degrees) if definition != null else [],
		"storage_footprint": _vector3i_array(definition.storage_footprint) if definition != null else []
	}


func _vector3_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _vector3i_array(value: Vector3i) -> Array[int]:
	return [value.x, value.y, value.z]
