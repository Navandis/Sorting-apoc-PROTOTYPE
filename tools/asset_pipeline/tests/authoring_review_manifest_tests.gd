extends SceneTree

const AuthoringReviewManifestScript = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")


func _init() -> void:
	_test_initial_seed_assigns_monotonic_opaque_keys()
	_test_repeated_seed_does_not_duplicate_records()
	_test_new_asset_uses_highest_existing_suffix_plus_one()
	_test_unique_fingerprint_rename_correlates()
	_test_ambiguous_fingerprint_does_not_correlate()
	_test_fingerprint_change_stales_completed_scale_decision()
	_test_rotation_change_stales_completed_pose_decision()
	_test_footprint_change_stales_completed_footprint_decision()
	_test_rotation_change_stales_completed_footprint_decision()
	_test_unreviewed_decisions_are_not_stale()
	_test_item_id_association_sync_preserves_all_review_evidence()
	_test_manifest_schema_is_one_zero()
	_test_serialization_is_deterministic()
	print("PASS: authoring review manifest tests")
	quit(0)


func _test_initial_seed_assigns_monotonic_opaque_keys() -> void:
	var result: Dictionary = AuthoringReviewManifestScript.seed_or_sync(
		AuthoringReviewManifestScript.empty_manifest(),
		[_asset("res://assets/props/Food/a.glb", "apple", "hash-a"), _asset("res://assets/props/Food/b.glb", "", "hash-b")]
	)
	var assets: Dictionary = result["manifest"]["assets"] as Dictionary
	assert(assets.has("loot_000001"))
	assert(assets.has("loot_000002"))
	assert(String((assets["loot_000001"] as Dictionary)["source_path"]) == "res://assets/props/Food/a.glb")
	assert(String(((assets["loot_000001"] as Dictionary)["scale_review"] as Dictionary)["status"]) == "UNREVIEWED")


func _test_repeated_seed_does_not_duplicate_records() -> void:
	var initial: Dictionary = AuthoringReviewManifestScript.seed_or_sync(
		AuthoringReviewManifestScript.empty_manifest(),
		[_asset("res://assets/props/Food/a.glb", "apple", "hash-a")]
	)
	var repeated: Dictionary = AuthoringReviewManifestScript.seed_or_sync(
		initial["manifest"] as Dictionary,
		[_asset("res://assets/props/Food/a.glb", "apple", "hash-a")]
	)
	assert((repeated["manifest"] as Dictionary)["assets"].size() == 1)
	assert((repeated["added_keys"] as Array).is_empty())


func _test_new_asset_uses_highest_existing_suffix_plus_one() -> void:
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {
		"loot_000003": AuthoringReviewManifestScript.new_record(_asset("res://old.glb", "", "old")),
		"loot_000017": AuthoringReviewManifestScript.new_record(_asset("res://gone.glb", "", "gone"))
	}
	var result: Dictionary = AuthoringReviewManifestScript.seed_or_sync(
		manifest,
		[_asset("res://new.glb", "", "new")]
	)
	assert((result["manifest"] as Dictionary)["assets"].has("loot_000018"))


func _test_unique_fingerprint_rename_correlates() -> void:
	var manifest: Dictionary = _manifest_with_record("loot_000001", _asset("res://old.glb", "", "same"))
	var matches: Array[Dictionary] = AuthoringReviewManifestScript.correlate_current_assets(
		manifest,
		[_asset("res://renamed.glb", "", "same")]
	)
	assert(String(matches[0]["authoring_key"]) == "loot_000001")
	assert(String(matches[0]["correlation"]) == "fingerprint")
	assert(String(matches[0]["problem_flag"]) == "AUTHORING_REVIEW_PATH_STALE")


func _test_ambiguous_fingerprint_does_not_correlate() -> void:
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {
		"loot_000001": AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "same")),
		"loot_000002": AuthoringReviewManifestScript.new_record(_asset("res://b.glb", "", "same"))
	}
	var matches: Array[Dictionary] = AuthoringReviewManifestScript.correlate_current_assets(
		manifest,
		[_asset("res://renamed.glb", "", "same")]
	)
	assert(String(matches[0]["authoring_key"]).is_empty())
	assert(String(matches[0]["problem_flag"]) == "AUTHORING_REVIEW_AMBIGUOUS")


func _test_fingerprint_change_stales_completed_scale_decision() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "old"))
	(record["scale_review"] as Dictionary)["status"] = "NORMALIZATION_REQUIRED"
	(record["scale_review"] as Dictionary)["reviewed_source_fingerprint"] = "old"
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "new"))
	assert(not bool(evidence["scale_review_current"]))
	assert((evidence["flags"] as PackedStringArray).has("SCALE_REVIEW_STALE"))


func _test_rotation_change_stales_completed_pose_decision() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "same"))
	(record["storage_pose_review"] as Dictionary)["status"] = "CUSTOM_POSE_REQUIRED"
	(record["storage_pose_review"] as Dictionary)["reviewed_source_fingerprint"] = "same"
	(record["storage_pose_review"] as Dictionary)["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "same", [0.0, 90.0, 0.0]))
	assert(not bool(evidence["storage_pose_review_current"]))
	assert((evidence["flags"] as PackedStringArray).has("STORAGE_POSE_REVIEW_STALE"))


func _test_footprint_change_stales_completed_footprint_decision() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "same"))
	(record["footprint_review"] as Dictionary)["status"] = "GEOMETRY_APPROVED"
	(record["footprint_review"] as Dictionary)["reviewed_source_fingerprint"] = "same"
	(record["footprint_review"] as Dictionary)["reviewed_footprint"] = [1, 1, 1]
	(record["footprint_review"] as Dictionary)["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "same", [0.0, 0.0, 0.0], [2, 1, 1]))
	assert(not bool(evidence["footprint_review_current"]))
	assert((evidence["flags"] as PackedStringArray).has("FOOTPRINT_REVIEW_STALE"))


func _test_rotation_change_stales_completed_footprint_decision() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "same"))
	(record["footprint_review"] as Dictionary)["status"] = "OVERRIDE_APPROVED"
	(record["footprint_review"] as Dictionary)["reviewed_source_fingerprint"] = "same"
	(record["footprint_review"] as Dictionary)["reviewed_footprint"] = [1, 1, 1]
	(record["footprint_review"] as Dictionary)["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "same", [0.0, 0.0, 90.0], [1, 1, 1]))
	assert(not bool(evidence["footprint_review_current"]))
	assert((evidence["flags"] as PackedStringArray).has("FOOTPRINT_REVIEW_STALE"))


func _test_unreviewed_decisions_are_not_stale() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "old"))
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "new"))
	assert(not bool(evidence["scale_review_current"]))
	assert(not (evidence["flags"] as PackedStringArray).has("SCALE_REVIEW_STALE"))
	assert(not (evidence["flags"] as PackedStringArray).has("STORAGE_POSE_REVIEW_STALE"))
	assert(not (evidence["flags"] as PackedStringArray).has("FOOTPRINT_REVIEW_STALE"))


# Catches association sync accidentally completing, clearing, or resnapshotting
# any human review dimension while catalogue IDs are migrated.
func _test_item_id_association_sync_preserves_all_review_evidence() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(
		_asset("res://a.glb", "legacy_id", "fingerprint")
	)
	(record["scale_review"] as Dictionary)["status"] = "APPROVED"
	(record["scale_review"] as Dictionary)["reviewed_source_fingerprint"] = "fingerprint"
	(record["scale_review"] as Dictionary)["notes"] = "scale note"
	(record["storage_pose_review"] as Dictionary)["status"] = "CUSTOM_POSE_REQUIRED"
	(record["storage_pose_review"] as Dictionary)["reviewed_source_fingerprint"] = "fingerprint"
	(record["storage_pose_review"] as Dictionary)["reviewed_rotation_degrees"] = [1.0, 2.0, 3.0]
	(record["storage_pose_review"] as Dictionary)["notes"] = "pose note"
	(record["footprint_review"] as Dictionary)["status"] = "OVERRIDE_APPROVED"
	(record["footprint_review"] as Dictionary)["reviewed_source_fingerprint"] = "fingerprint"
	(record["footprint_review"] as Dictionary)["reviewed_footprint"] = [4, 5, 1]
	(record["footprint_review"] as Dictionary)["reviewed_rotation_degrees"] = [1.0, 2.0, 3.0]
	(record["footprint_review"] as Dictionary)["notes"] = "footprint note"
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {"loot_000001": record}
	var expected_record: Dictionary = record.duplicate(true)
	expected_record["item_id"] = "loot_000001"

	var result: Dictionary = AuthoringReviewManifestScript.sync_item_id_associations(
		manifest,
		{
			"loot_000001": "loot_000001",
			"loot_999999": "loot_999999"
		}
	)
	var updated_manifest: Dictionary = result["manifest"] as Dictionary
	assert((updated_manifest["assets"] as Dictionary)["loot_000001"] == expected_record)
	assert(not (updated_manifest["assets"] as Dictionary).has("loot_999999"))
	assert((result["updated_keys"] as PackedStringArray) == PackedStringArray(["loot_000001"]))
	assert((result["unknown_keys"] as PackedStringArray) == PackedStringArray(["loot_999999"]))


func _test_manifest_schema_is_one_zero() -> void:
	assert(String(AuthoringReviewManifestScript.empty_manifest()["schema_version"]) == "1.0")


func _test_serialization_is_deterministic() -> void:
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {
		"loot_000002": AuthoringReviewManifestScript.new_record(_asset("res://b.glb", "", "b")),
		"loot_000001": AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "a"))
	}
	assert(
		AuthoringReviewManifestScript.serialize_manifest(manifest)
		== AuthoringReviewManifestScript.serialize_manifest(manifest.duplicate(true))
	)


func _asset(
	source_path: String,
	item_id: String,
	source_fingerprint: String,
	storage_rotation_degrees: Array = [0.0, 0.0, 0.0],
	storage_footprint: Array = [1, 1, 1]
) -> Dictionary:
	return {
		"source_path": source_path,
		"item_id": item_id,
		"source_fingerprint": source_fingerprint,
		"storage_rotation_degrees": storage_rotation_degrees,
		"storage_footprint": storage_footprint
	}


func _manifest_with_record(authoring_key: String, asset: Dictionary) -> Dictionary:
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {authoring_key: AuthoringReviewManifestScript.new_record(asset)}
	return manifest
