extends SceneTree

const AuthoringReviewManifestScript = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const AutoStackGroupRegistryScript = preload("res://tools/asset_pipeline/auto_stack_group_registry.gd")


func _init() -> void:
	_test_initial_seed_assigns_monotonic_opaque_keys()
	_test_repeated_seed_does_not_duplicate_records()
	_test_new_asset_uses_highest_existing_suffix_plus_one()
	_test_unique_fingerprint_rename_correlates()
	_test_item_id_matched_rename_updates_source_path()
	_test_ambiguous_fingerprint_does_not_correlate()
	_test_fingerprint_change_stales_completed_scale_decision()
	_test_rotation_change_stales_default_pose_approval()
	_test_rotation_change_stales_custom_pose_approval()
	_test_candidate_tuning_does_not_stale_custom_pose_required()
	_test_fingerprint_change_stales_every_completed_pose_decision()
	_test_unresolved_pose_blocks_completed_footprint_review()
	_test_footprint_change_stales_completed_footprint_decision()
	_test_rotation_change_stales_completed_footprint_decision()
	_test_unreviewed_decisions_are_not_stale()
	_test_item_id_association_sync_preserves_all_review_evidence()
	_test_scale_reconciliation_approves_unchanged_and_leaves_normalized_unreviewed()
	_test_manifest_schema_is_two_zero()
	_test_legacy_migration_preserves_previous_review_data()
	_test_manifest_migration_is_idempotent()
	_test_unknown_new_review_status_fails_validation()
	_test_unknown_review_flags_fail_validation()
	_test_malformed_review_evidence_fails_validation()
	_test_malformed_review_snapshots_fail_validation()
	_test_stack_role_dependencies_block_currentness()
	_test_stack_role_snapshot_staleness_inputs()
	_test_unrelated_metadata_does_not_stale_stack_role()
	_test_auto_group_requires_current_stack_role()
	_test_auto_group_registry_revision_and_description_semantics()
	_test_approved_empty_auto_group_is_current()
	_test_auto_group_apply_is_idempotent_but_refuses_stack_role_drift()
	_test_auto_group_apply_refuses_registry_revision_drift()
	_test_auto_group_apply_refuses_malformed_source_review()
	_test_serialization_is_deterministic()
	_test_serialized_manifest_validates_after_json_parse()
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


# Ensures the stable ItemDefinition association also migrates an authored
# source path when a re-export changes both the GLB bytes and its filename.
func _test_item_id_matched_rename_updates_source_path() -> void:
	var manifest: Dictionary = _manifest_with_record(
		"loot_000001", _asset("res://old.glb", "loot_000001", "old")
	)
	var result: Dictionary = AuthoringReviewManifestScript.seed_or_sync(
		manifest,
		[_asset("res://new.glb", "loot_000001", "new")]
	)
	var record: Dictionary = (result["manifest"] as Dictionary)["assets"]["loot_000001"] as Dictionary
	assert(String(record["source_path"]) == "res://new.glb")
	assert(String(record["source_fingerprint"]) == "new")


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


func _test_rotation_change_stales_default_pose_approval() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "same"))
	(record["storage_pose_review"] as Dictionary)["status"] = "DEFAULT_POSE_APPROVED"
	(record["storage_pose_review"] as Dictionary)["reviewed_source_fingerprint"] = "same"
	(record["storage_pose_review"] as Dictionary)["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "same", [0.0, 90.0, 0.0]))
	assert(not bool(evidence["storage_pose_review_current"]))
	assert((evidence["flags"] as PackedStringArray).has("STORAGE_POSE_REVIEW_STALE"))


func _test_rotation_change_stales_custom_pose_approval() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "same"))
	(record["storage_pose_review"] as Dictionary)["status"] = "CUSTOM_POSE_APPROVED"
	(record["storage_pose_review"] as Dictionary)["reviewed_source_fingerprint"] = "same"
	(record["storage_pose_review"] as Dictionary)["reviewed_rotation_degrees"] = [90.0, 0.0, 0.0]
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "same", [0.0, 0.0, 90.0]))
	assert(not bool(evidence["storage_pose_review_current"]))
	assert((evidence["flags"] as PackedStringArray).has("STORAGE_POSE_REVIEW_STALE"))


func _test_candidate_tuning_does_not_stale_custom_pose_required() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "same"))
	(record["storage_pose_review"] as Dictionary)["status"] = "CUSTOM_POSE_REQUIRED"
	(record["storage_pose_review"] as Dictionary)["reviewed_source_fingerprint"] = "same"
	(record["storage_pose_review"] as Dictionary)["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "same", [90.0, 45.0, 10.0]))
	assert(bool(evidence["storage_pose_review_current"]))
	assert(not (evidence["flags"] as PackedStringArray).has("STORAGE_POSE_REVIEW_STALE"))


func _test_fingerprint_change_stales_every_completed_pose_decision() -> void:
	for status: String in ["DEFAULT_POSE_APPROVED", "CUSTOM_POSE_REQUIRED", "CUSTOM_POSE_APPROVED"]:
		var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "", "old"))
		(record["storage_pose_review"] as Dictionary)["status"] = status
		(record["storage_pose_review"] as Dictionary)["reviewed_source_fingerprint"] = "old"
		var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://a.glb", "", "new"))
		assert(not bool(evidence["storage_pose_review_current"]))
		assert((evidence["flags"] as PackedStringArray).has("STORAGE_POSE_REVIEW_STALE"))


func _test_unresolved_pose_blocks_completed_footprint_review() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://pants.glb", "", "same"))
	(record["storage_pose_review"] as Dictionary)["status"] = "CUSTOM_POSE_REQUIRED"
	(record["storage_pose_review"] as Dictionary)["reviewed_source_fingerprint"] = "same"
	(record["footprint_review"] as Dictionary)["status"] = "GEOMETRY_APPROVED"
	(record["footprint_review"] as Dictionary)["reviewed_source_fingerprint"] = "same"
	(record["footprint_review"] as Dictionary)["reviewed_footprint"] = [1, 1, 1]
	(record["footprint_review"] as Dictionary)["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, _asset("res://pants.glb", "", "same"))
	assert(bool(evidence["storage_pose_review_current"]))
	assert(not bool(evidence["footprint_review_current"]))
	assert((evidence["flags"] as PackedStringArray).has("FOOTPRINT_REVIEW_STALE"))


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


func _test_scale_reconciliation_approves_unchanged_and_leaves_normalized_unreviewed() -> void:
	var approved_record: Dictionary = AuthoringReviewManifestScript.new_record(
		_asset("res://approved.glb", "loot_000001", "old-approved")
	)
	var normalized_record: Dictionary = AuthoringReviewManifestScript.new_record(
		_asset("res://normalized.glb", "loot_000002", "old-normalized")
	)
	(normalized_record["storage_pose_review"] as Dictionary)["notes"] = "preserve pose"
	(normalized_record["footprint_review"] as Dictionary)["notes"] = "preserve footprint"
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {
		"loot_000001": approved_record,
		"loot_000002": normalized_record
	}
	var result: Variant = AuthoringReviewManifestScript.apply_scale_review_reconciliation(
		manifest,
		[
			_asset("res://approved.glb", "loot_000001", "new-approved"),
			_asset("res://normalized.glb", "loot_000002", "new-normalized")
		],
		PackedStringArray(["loot_000002"])
	)
	assert(result is Dictionary)
	var records: Dictionary = (result as Dictionary)["manifest"]["assets"] as Dictionary
	var approved_scale: Dictionary = (records["loot_000001"] as Dictionary)["scale_review"] as Dictionary
	var normalized_scale: Dictionary = (records["loot_000002"] as Dictionary)["scale_review"] as Dictionary
	assert(String(approved_scale["status"]) == "APPROVED")
	assert(String(approved_scale["reviewed_source_fingerprint"]) == "new-approved")
	assert(String(normalized_scale["status"]) == "UNREVIEWED")
	assert(String(normalized_scale["reviewed_source_fingerprint"]).is_empty())
	assert(String(normalized_scale["notes"]) == "Normalized after initial scale review; pending in-game recheck.")
	assert(String(((records["loot_000002"] as Dictionary)["storage_pose_review"] as Dictionary)["notes"]) == "preserve pose")
	assert(String(((records["loot_000002"] as Dictionary)["footprint_review"] as Dictionary)["notes"]) == "preserve footprint")


func _test_manifest_schema_is_two_zero() -> void:
	assert(String(AuthoringReviewManifestScript.empty_manifest()["schema_version"]) == "2.0")


func _test_legacy_migration_preserves_previous_review_data() -> void:
	var legacy_record: Dictionary = AuthoringReviewManifestScript.new_record(
		_asset("res://a.glb", "loot_000001", "hash", [1.0, 2.0, 3.0], [4, 5, 1])
	)
	legacy_record.erase("stack_role_review")
	legacy_record.erase("auto_group_review")
	(legacy_record["scale_review"] as Dictionary)["status"] = "NORMALIZATION_REQUIRED"
	(legacy_record["scale_review"] as Dictionary)["notes"] = "scale evidence"
	(legacy_record["storage_pose_review"] as Dictionary)["status"] = "CUSTOM_POSE_APPROVED"
	(legacy_record["storage_pose_review"] as Dictionary)["reviewed_rotation_degrees"] = [1.0, 2.0, 3.0]
	(legacy_record["storage_pose_review"] as Dictionary)["notes"] = "pose evidence"
	(legacy_record["footprint_review"] as Dictionary)["status"] = "OVERRIDE_APPROVED"
	(legacy_record["footprint_review"] as Dictionary)["reviewed_footprint"] = [4, 5, 1]
	(legacy_record["footprint_review"] as Dictionary)["notes"] = "footprint evidence"
	var expected_scale: Dictionary = (legacy_record["scale_review"] as Dictionary).duplicate(true)
	var expected_pose: Dictionary = (legacy_record["storage_pose_review"] as Dictionary).duplicate(true)
	var expected_footprint: Dictionary = (legacy_record["footprint_review"] as Dictionary).duplicate(true)
	var legacy: Dictionary = {"schema_version": "1.0", "assets": {"loot_000001": legacy_record}}

	var migrated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(legacy)
	var migrated_record: Dictionary = (migrated["assets"] as Dictionary)["loot_000001"] as Dictionary
	assert(String(migrated["schema_version"]) == "2.0")
	assert(migrated_record["scale_review"] == expected_scale)
	assert(migrated_record["storage_pose_review"] == expected_pose)
	assert(migrated_record["footprint_review"] == expected_footprint)
	assert(migrated_record["stack_role_review"] == {
		"status": "UNREVIEWED",
		"reviewed_source_fingerprint": "",
		"reviewed_rotation_degrees": [0.0, 0.0, 0.0],
		"reviewed_footprint": [0, 0, 0],
		"reviewed_can_be_stacked": false,
		"reviewed_can_support_stack": false,
		"flags": [],
		"notes": ""
	})
	assert(migrated_record["auto_group_review"] == {
		"status": "UNREVIEWED",
		"reviewed_stack_role_snapshot": {},
		"reviewed_auto_stack_group": "",
		"reviewed_registry_compatibility_revision": 0,
		"flags": [],
		"notes": ""
	})


func _test_manifest_migration_is_idempotent() -> void:
	var legacy: Dictionary = {
		"schema_version": "1.0",
		"assets": {
			"loot_000002": AuthoringReviewManifestScript.new_record(_asset("res://b.glb", "loot_000002", "b")),
			"loot_000001": AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "loot_000001", "a"))
		}
	}
	for record_value: Variant in (legacy["assets"] as Dictionary).values():
		var record: Dictionary = record_value as Dictionary
		record.erase("stack_role_review")
		record.erase("auto_group_review")
	var once: Dictionary = AuthoringReviewManifestScript.migrate_manifest(legacy)
	var twice: Dictionary = AuthoringReviewManifestScript.migrate_manifest(once)
	assert(AuthoringReviewManifestScript.serialize_manifest(once) == AuthoringReviewManifestScript.serialize_manifest(twice))


func _test_unknown_new_review_status_fails_validation() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "loot_000001", "a"))
	(record["stack_role_review"] as Dictionary)["status"] = "HEURISTICALLY_APPROVED"
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {"loot_000001": record}
	assert(_errors_contain(AuthoringReviewManifestScript.validate_manifest(manifest), "stack_role_review.status"))
	(record["stack_role_review"] as Dictionary)["status"] = "UNREVIEWED"
	(record["auto_group_review"] as Dictionary)["status"] = "MISSING"
	assert(_errors_contain(AuthoringReviewManifestScript.validate_manifest(manifest), "auto_group_review.status"))


func _test_unknown_review_flags_fail_validation() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "loot_000001", "a"))
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {"loot_000001": record}
	(record["stack_role_review"] as Dictionary)["flags"] = ["FLAT_AABB_AUTO_APPROVAL"]
	assert(_errors_contain(AuthoringReviewManifestScript.validate_manifest(manifest), "Unknown Stack Role flag"))
	(record["stack_role_review"] as Dictionary)["flags"] = []
	(record["auto_group_review"] as Dictionary)["flags"] = ["SILENT_NEW_GROUP"]
	assert(_errors_contain(AuthoringReviewManifestScript.validate_manifest(manifest), "Unknown Auto Group flag"))


func _test_malformed_review_evidence_fails_validation() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(_asset("res://a.glb", "loot_000001", "a"))
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {"loot_000001": record}
	(record["stack_role_review"] as Dictionary)["flags"] = "IRREGULAR_SHAPE"
	assert(_errors_contain(AuthoringReviewManifestScript.validate_manifest(manifest), "stack_role_review.flags"))
	(record["stack_role_review"] as Dictionary)["flags"] = []
	(record["auto_group_review"] as Dictionary)["notes"] = 42
	assert(_errors_contain(AuthoringReviewManifestScript.validate_manifest(manifest), "auto_group_review.notes"))


func _test_malformed_review_snapshots_fail_validation() -> void:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(
		_asset("res://a.glb", "loot_000001", "a")
	)
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {"loot_000001": record}
	(record["stack_role_review"] as Dictionary)["reviewed_rotation_degrees"] = [0.0, "bad", 0.0]
	assert(_errors_contain(
		AuthoringReviewManifestScript.validate_manifest(manifest),
		"stack_role_review.reviewed_rotation_degrees"
	))
	(record["stack_role_review"] as Dictionary)["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	(record["stack_role_review"] as Dictionary)["reviewed_can_be_stacked"] = "true"
	assert(_errors_contain(
		AuthoringReviewManifestScript.validate_manifest(manifest),
		"stack_role_review.reviewed_can_be_stacked"
	))
	(record["stack_role_review"] as Dictionary)["reviewed_can_be_stacked"] = false
	(record["auto_group_review"] as Dictionary)["reviewed_stack_role_snapshot"] = []
	assert(_errors_contain(
		AuthoringReviewManifestScript.validate_manifest(manifest),
		"auto_group_review.reviewed_stack_role_snapshot"
	))
	(record["auto_group_review"] as Dictionary)["reviewed_stack_role_snapshot"] = {}
	(record["auto_group_review"] as Dictionary)["reviewed_registry_compatibility_revision"] = 1.5
	assert(_errors_contain(
		AuthoringReviewManifestScript.validate_manifest(manifest),
		"auto_group_review.reviewed_registry_compatibility_revision"
	))


func _test_stack_role_dependencies_block_currentness() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 0.0, 0.0], [2, 3, 1], true, false, "")
	var unresolved_pose: Dictionary = AuthoringReviewManifestScript.new_record(asset)
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(unresolved_pose, asset, _registry())
	assert(not bool(evidence["stack_role_review_eligible"]))
	assert(bool(evidence["stack_role_review_dependency_blocked"]))
	assert(not bool(evidence["stack_role_review_stale"]))

	var stale_footprint: Dictionary = AuthoringReviewManifestScript.new_record(asset)
	_approve_geometry(stale_footprint, asset)
	(stale_footprint["footprint_review"] as Dictionary)["reviewed_footprint"] = [9, 9, 1]
	evidence = AuthoringReviewManifestScript.review_evidence(stale_footprint, asset, _registry())
	assert(not bool(evidence["stack_role_review_eligible"]))
	assert(bool(evidence["stack_role_review_dependency_blocked"]))


func _test_stack_role_snapshot_staleness_inputs() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 90.0, 0.0], [2, 3, 1], true, false, "")
	var mutations: Array[Dictionary] = [
		_stack_asset("changed", [0.0, 90.0, 0.0], [2, 3, 1], true, false, ""),
		_stack_asset("hash", [0.0, 0.0, 0.0], [2, 3, 1], true, false, ""),
		_stack_asset("hash", [0.0, 90.0, 0.0], [3, 3, 1], true, false, ""),
		_stack_asset("hash", [0.0, 90.0, 0.0], [2, 3, 1], false, false, ""),
		_stack_asset("hash", [0.0, 90.0, 0.0], [2, 3, 1], true, true, "")
	]
	for mutation: Dictionary in mutations:
		var record: Dictionary = _approved_stack_role_record(asset)
		var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, mutation, _registry())
		assert(not bool(evidence["stack_role_review_current"]))
		assert(bool(evidence["stack_role_review_stale"]))


func _test_unrelated_metadata_does_not_stale_stack_role() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 90.0, 0.0], [2, 3, 1], true, false, "")
	var record: Dictionary = _approved_stack_role_record(asset)
	var renamed: Dictionary = asset.duplicate(true)
	renamed["display_name"] = "Renamed"
	renamed["storage_category"] = "Medical"
	renamed["bulk"] = 999
	renamed["utility_id"] = "Fuel"
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, renamed, _registry())
	assert(bool(evidence["stack_role_review_current"]))
	assert(not bool(evidence["stack_role_review_stale"]))


func _test_auto_group_requires_current_stack_role() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 0.0, 0.0], [2, 2, 1], true, true, "flat_media")
	var record: Dictionary = AuthoringReviewManifestScript.new_record(asset)
	_approve_geometry(record, asset)
	var auto_review: Dictionary = record["auto_group_review"] as Dictionary
	auto_review["status"] = "APPROVED"
	auto_review["reviewed_auto_stack_group"] = "flat_media"
	auto_review["reviewed_registry_compatibility_revision"] = 1
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, asset, _registry())
	assert(not bool(evidence["auto_group_review_eligible"]))
	assert(bool(evidence["auto_group_review_dependency_blocked"]))
	assert(not bool(evidence["auto_group_review_current"]))
	assert(bool(evidence["auto_group_review_stale"]))


func _test_auto_group_registry_revision_and_description_semantics() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 0.0, 0.0], [2, 2, 1], true, true, "flat_media")
	var record: Dictionary = _approved_stack_role_record(asset)
	_approve_auto_group(record, asset, 1)
	var editorial_registry: Dictionary = _registry()
	((editorial_registry["classes"] as Dictionary)["flat_media"] as Dictionary)["description"] = "Editorial wording only."
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, asset, editorial_registry)
	assert(bool(evidence["auto_group_review_current"]))
	var semantic_registry: Dictionary = _registry()
	((semantic_registry["classes"] as Dictionary)["flat_media"] as Dictionary)["compatibility_revision"] = 2
	evidence = AuthoringReviewManifestScript.review_evidence(record, asset, semantic_registry)
	assert(not bool(evidence["auto_group_review_current"]))
	assert(bool(evidence["auto_group_review_stale"]))


func _test_approved_empty_auto_group_is_current() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 0.0, 0.0], [2, 2, 1], true, false, "")
	var record: Dictionary = _approved_stack_role_record(asset)
	_approve_auto_group(record, asset, 0)
	var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, asset, _registry())
	assert(bool(evidence["auto_group_review_eligible"]))
	assert(bool(evidence["auto_group_review_current"]))
	assert(not bool(evidence["auto_group_review_stale"]))


func _test_auto_group_apply_is_idempotent_but_refuses_stack_role_drift() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 0.0, 0.0], [2, 2, 1], true, true, "flat_media")
	var record: Dictionary = _approved_stack_role_record(asset)
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {"loot_000001": record}
	var applied: Dictionary = AuthoringReviewManifestScript.apply_auto_group_approvals(
		manifest, [asset], _registry(), {"loot_000001": "flat_media"}
	)
	assert((applied["errors"] as PackedStringArray).is_empty())
	var applied_manifest: Dictionary = applied["manifest"] as Dictionary
	var applied_record: Dictionary = (applied_manifest["assets"] as Dictionary)["loot_000001"] as Dictionary
	assert(bool(AuthoringReviewManifestScript.review_evidence(applied_record, asset, _registry())["auto_group_review_current"]))
	var repeated: Dictionary = AuthoringReviewManifestScript.apply_auto_group_approvals(
		applied_manifest, [asset], _registry(), {"loot_000001": "flat_media"}
	)
	assert((repeated["errors"] as PackedStringArray).is_empty())
	assert(repeated["manifest"] == applied_manifest)
	var missing_group_asset: Dictionary = asset.duplicate(true)
	missing_group_asset["auto_stack_group"] = ""
	var missing_group: Dictionary = AuthoringReviewManifestScript.apply_auto_group_approvals(
		applied_manifest, [missing_group_asset], _registry(), {"loot_000001": "flat_media"}
	)
	assert(_errors_contain(missing_group["errors"] as PackedStringArray, "does not match"))
	assert(missing_group["manifest"] == applied_manifest)

	var changed_asset: Dictionary = asset.duplicate(true)
	changed_asset["can_support_stack"] = false
	var changed_manifest: Dictionary = applied_manifest.duplicate(true)
	var changed_record: Dictionary = (changed_manifest["assets"] as Dictionary)["loot_000001"] as Dictionary
	var changed_stack_review: Dictionary = changed_record["stack_role_review"] as Dictionary
	for key_value: Variant in AuthoringReviewManifestScript.stack_role_snapshot(changed_asset).keys():
		changed_stack_review[key_value] = AuthoringReviewManifestScript.stack_role_snapshot(changed_asset)[key_value]
	var rejected: Dictionary = AuthoringReviewManifestScript.apply_auto_group_approvals(
		changed_manifest, [changed_asset], _registry(), {"loot_000001": "flat_media"}
	)
	assert(_errors_contain(rejected["errors"] as PackedStringArray, "existing approval is stale"))
	assert(rejected["manifest"] == changed_manifest)


func _test_auto_group_apply_refuses_registry_revision_drift() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 0.0, 0.0], [2, 2, 1], true, true, "flat_media")
	var record: Dictionary = _approved_stack_role_record(asset)
	_approve_auto_group(record, asset, 1)
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {"loot_000001": record}
	var changed_registry: Dictionary = _registry()
	((changed_registry["classes"] as Dictionary)["flat_media"] as Dictionary)["compatibility_revision"] = 2
	var rejected: Dictionary = AuthoringReviewManifestScript.apply_auto_group_approvals(
		manifest, [asset], changed_registry, {"loot_000001": "flat_media"}
	)
	assert(_errors_contain(rejected["errors"] as PackedStringArray, "existing approval is stale"))
	assert(rejected["manifest"] == manifest)


func _test_auto_group_apply_refuses_malformed_source_review() -> void:
	var asset: Dictionary = _stack_asset("hash", [0.0, 0.0, 0.0], [2, 2, 1], true, true, "flat_media")
	var record: Dictionary = _approved_stack_role_record(asset)
	(record["auto_group_review"] as Dictionary)["status"] = "BROKEN"
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {"loot_000001": record}
	var rejected: Dictionary = AuthoringReviewManifestScript.apply_auto_group_approvals(
		manifest, [asset], _registry(), {"loot_000001": "flat_media"}
	)
	assert(_errors_contain(rejected["errors"] as PackedStringArray, "auto_group_review.status"))
	assert(rejected["manifest"] == manifest)


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


func _test_serialized_manifest_validates_after_json_parse() -> void:
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	manifest["assets"] = {
		"loot_000001": AuthoringReviewManifestScript.new_record(
			_asset("res://a.glb", "loot_000001", "a")
		)
	}
	var parsed: Variant = JSON.parse_string(
		AuthoringReviewManifestScript.serialize_manifest(manifest)
	)
	assert(parsed is Dictionary)
	assert(AuthoringReviewManifestScript.validate_manifest(parsed as Dictionary).is_empty())


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


func _errors_contain(errors: PackedStringArray, fragment: String) -> bool:
	for message: String in errors:
		if fragment in message:
			return true
	return false


func _stack_asset(
	fingerprint: String,
	rotation: Array,
	footprint: Array,
	can_be_stacked: bool,
	can_support_stack: bool,
	group_id: String
) -> Dictionary:
	var asset: Dictionary = _asset("res://a.glb", "loot_000001", fingerprint, rotation, footprint)
	asset["has_item_definition"] = true
	asset["can_be_stacked"] = can_be_stacked
	asset["can_support_stack"] = can_support_stack
	asset["auto_stack_group"] = group_id
	return asset


func _approve_geometry(record: Dictionary, asset: Dictionary) -> void:
	var pose_review: Dictionary = record["storage_pose_review"] as Dictionary
	pose_review["status"] = "CUSTOM_POSE_APPROVED"
	pose_review["reviewed_source_fingerprint"] = asset["source_fingerprint"]
	pose_review["reviewed_rotation_degrees"] = (asset["storage_rotation_degrees"] as Array).duplicate()
	var footprint_review: Dictionary = record["footprint_review"] as Dictionary
	footprint_review["status"] = "GEOMETRY_APPROVED"
	footprint_review["reviewed_source_fingerprint"] = asset["source_fingerprint"]
	footprint_review["reviewed_rotation_degrees"] = (asset["storage_rotation_degrees"] as Array).duplicate()
	footprint_review["reviewed_footprint"] = (asset["storage_footprint"] as Array).duplicate()


func _approved_stack_role_record(asset: Dictionary) -> Dictionary:
	var record: Dictionary = AuthoringReviewManifestScript.new_record(asset)
	_approve_geometry(record, asset)
	var review: Dictionary = record["stack_role_review"] as Dictionary
	review["status"] = "APPROVED"
	var snapshot: Dictionary = AuthoringReviewManifestScript.stack_role_snapshot(asset)
	for key_value: Variant in snapshot.keys():
		review[key_value] = snapshot[key_value]
	return record


func _approve_auto_group(record: Dictionary, asset: Dictionary, revision: int) -> void:
	var auto_review: Dictionary = record["auto_group_review"] as Dictionary
	auto_review["status"] = "APPROVED"
	auto_review["reviewed_stack_role_snapshot"] = AuthoringReviewManifestScript.stack_role_snapshot(asset)
	auto_review["reviewed_auto_stack_group"] = String(asset["auto_stack_group"])
	auto_review["reviewed_registry_compatibility_revision"] = revision


func _registry() -> Dictionary:
	return {
		"schema_version": "1.0",
		"classes": {
			"flat_media": {
				"approval_status": "APPROVED",
				"compatibility_revision": 1,
				"description": "Compatible flat media."
			}
		}
	}
