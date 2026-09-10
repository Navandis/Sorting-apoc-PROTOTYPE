extends SceneTree

const AuthoringReviewManifestScript = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const StackRoleAuthoringScript = preload("res://tools/asset_pipeline/stack_role_authoring.gd")

const BLOCKED_IDS: PackedStringArray = ["loot_000034", "loot_000036"]
const BATCH_ONE_IDS: PackedStringArray = [
	"loot_000003", "loot_000007", "loot_000020", "loot_000021"
]
const BATCH_TWO_IDS: PackedStringArray = [
	"loot_000008", "loot_000010", "loot_000015", "loot_000016", "loot_000017",
	"loot_000018", "loot_000022", "loot_000023", "loot_000024", "loot_000025",
	"loot_000027"
]
const BATCH_TWO_ADJUSTED_ROLES: Dictionary = {
	"loot_000024": [true, false],
	"loot_000025": [true, false],
	"loot_000027": [true, false]
}
const BATCH_THREE_IDS: PackedStringArray = [
	"loot_000001", "loot_000004", "loot_000012", "loot_000014", "loot_000029",
	"loot_000033", "loot_000035"
]
const BATCH_THREE_ADJUSTED_ROLES: Dictionary = {
	"loot_000012": [true, false],
	"loot_000014": [false, false],
	"loot_000029": [true, false]
}
const GRANDFATHERED: Dictionary = {
	"loot_000002": [false, true, ""],
	"loot_000005": [true, true, "boxed_food"],
	"loot_000006": [true, false, ""],
	"loot_000009": [true, true, "round_cans"],
	"loot_000019": [true, true, "round_cans"],
	"loot_000028": [true, true, "medical_boxes"],
	"loot_000030": [true, true, "flat_media"],
	"loot_000031": [true, true, "flat_media"],
	"loot_000039": [true, false, ""]
}
const EXPECTED_CANDIDATES: Dictionary = {
	"loot_000001": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "irregular_rigid"],
	"loot_000003": [true, false, ["SUPPORT_SURFACE_AMBIGUOUS", "VISUAL_REVIEW_RECOMMENDED"], "rigid_boxlike"],
	"loot_000004": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "irregular_rigid"],
	"loot_000007": [true, true, [], "rigid_boxlike"],
	"loot_000008": [true, true, [], "cylindrical_container"],
	"loot_000010": [true, true, [], "cylindrical_container"],
	"loot_000011": [false, false, ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS", "SOFT_OR_DEFORMABLE_FORM", "VISUAL_REVIEW_RECOMMENDED"], "soft_irregular"],
	"loot_000012": [false, false, ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS"], "irregular_rigid"],
	"loot_000013": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS", "RESTING_STABILITY_AMBIGUOUS"], "long_narrow"],
	"loot_000014": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS", "VISUAL_REVIEW_RECOMMENDED"], "irregular_rigid"],
	"loot_000015": [true, false, ["SUPPORT_SURFACE_AMBIGUOUS"], "cylindrical_container"],
	"loot_000016": [true, false, ["SUPPORT_SURFACE_AMBIGUOUS", "VISUAL_REVIEW_RECOMMENDED"], "cylindrical_container"],
	"loot_000017": [true, false, ["SUPPORT_SURFACE_AMBIGUOUS"], "cylindrical_container"],
	"loot_000018": [true, false, ["SUPPORT_SURFACE_AMBIGUOUS"], "cylindrical_container"],
	"loot_000020": [true, false, ["SUPPORT_SURFACE_AMBIGUOUS"], "rigid_boxlike"],
	"loot_000021": [true, false, ["SUPPORT_SURFACE_AMBIGUOUS"], "rigid_boxlike"],
	"loot_000022": [true, true, [], "cylindrical_container"],
	"loot_000023": [true, true, [], "cylindrical_container"],
	"loot_000024": [true, true, [], "cylindrical_container"],
	"loot_000025": [true, true, [], "cylindrical_container"],
	"loot_000026": [true, false, ["SUPPORT_SURFACE_AMBIGUOUS", "SOFT_OR_DEFORMABLE_FORM"], "soft_irregular"],
	"loot_000027": [true, true, ["VISUAL_REVIEW_RECOMMENDED"], "cylindrical_container"],
	"loot_000029": [false, false, ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS"], "irregular_rigid"],
	"loot_000032": [false, false, ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS", "SOFT_OR_DEFORMABLE_FORM", "POSE_DEPENDENT", "VISUAL_REVIEW_RECOMMENDED"], "soft_irregular"],
	"loot_000033": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "irregular_rigid"],
	"loot_000035": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "irregular_rigid"],
	"loot_000037": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "long_narrow"],
	"loot_000038": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "long_narrow"],
	"loot_000040": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "long_narrow"],
	"loot_000041": [false, false, ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS", "POSE_DEPENDENT", "VISUAL_REVIEW_RECOMMENDED"], "long_narrow"],
	"loot_000042": [true, false, ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS", "SOFT_OR_DEFORMABLE_FORM"], "long_narrow"]
}


func _init() -> void:
	_test_exact_candidate_table()
	_test_phase_one_migration_approves_only_exact_nine()
	_test_batch_one_apply_approves_only_human_decisions()
	_test_batch_two_apply_snapshots_human_adjustments_without_auto_groups()
	_test_batch_three_apply_snapshots_human_adjustments_without_auto_groups()
	_test_gloves_and_pants_remain_blocked_without_candidates()
	_test_catalogue_set_mismatch_aborts_without_writes()
	_test_invalid_manifest_aborts_without_writes()
	_test_phase_one_preserves_opaque_authoring_keys()
	_test_future_items_use_reusable_pipeline_not_phase_one_table()
	print("PASS: stack role authoring tests")
	quit(0)


func _test_exact_candidate_table() -> void:
	assert(StackRoleAuthoringScript.candidate_ids() == _sorted_keys(EXPECTED_CANDIDATES))
	assert(EXPECTED_CANDIDATES.size() == 31)
	for item_id: String in _sorted_keys(EXPECTED_CANDIDATES):
		var expected: Array = EXPECTED_CANDIDATES[item_id] as Array
		var candidate: Dictionary = StackRoleAuthoringScript.candidate_for(item_id)
		assert(bool(candidate["can_be_stacked"]) == bool(expected[0]))
		assert(bool(candidate["can_support_stack"]) == bool(expected[1]))
		assert(candidate["flags"] == expected[2])
		assert(String(candidate["form_batch"]) == String(expected[3]))
		assert(not String(candidate["rationale"]).is_empty())
		assert(String(candidate["rationale"]).ends_with("."))


func _test_phase_one_migration_approves_only_exact_nine() -> void:
	var fixture: Dictionary = _fixture()
	var result: Dictionary = StackRoleAuthoringScript.apply_phase_1(
		fixture["manifest"] as Dictionary,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	assert((result["errors"] as PackedStringArray).is_empty())
	assert(int((result["counts"] as Dictionary)["grandfathered"]) == 9)
	assert(int((result["counts"] as Dictionary)["candidates"]) == 31)
	assert(int((result["counts"] as Dictionary)["blocked"]) == 2)
	var records: Dictionary = (result["manifest"] as Dictionary)["assets"] as Dictionary
	var approved_stack_ids: PackedStringArray = []
	var approved_group_ids: PackedStringArray = []
	for item_id: String in _sorted_keys(records):
		var record: Dictionary = records[item_id] as Dictionary
		if String((record["stack_role_review"] as Dictionary)["status"]) == "APPROVED":
			approved_stack_ids.append(item_id)
		if String((record["auto_group_review"] as Dictionary)["status"]) == "APPROVED":
			approved_group_ids.append(item_id)
	assert(approved_stack_ids == _sorted_keys(GRANDFATHERED))
	assert(approved_group_ids == _sorted_keys(GRANDFATHERED))


func _test_batch_one_apply_approves_only_human_decisions() -> void:
	var fixture: Dictionary = _fixture()
	_apply_candidate_roles(fixture["current_assets"] as Array[Dictionary])
	var seeded: Dictionary = StackRoleAuthoringScript.apply_phase_1(
		fixture["manifest"] as Dictionary,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	var result: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_1(
		seeded["manifest"] as Dictionary,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	assert((result["errors"] as PackedStringArray).is_empty())
	assert(result["approved_item_ids"] == BATCH_ONE_IDS)
	var records: Dictionary = (result["manifest"] as Dictionary)["assets"] as Dictionary
	var assets_by_id: Dictionary = {}
	for asset: Dictionary in fixture["current_assets"] as Array[Dictionary]:
		assets_by_id[String(asset["item_id"])] = asset
	for item_id: String in BATCH_ONE_IDS:
		var record: Dictionary = records[item_id] as Dictionary
		var role_review: Dictionary = record["stack_role_review"] as Dictionary
		assert(String(role_review["status"]) == "APPROVED")
		assert(role_review["flags"] == [])
		assert(AuthoringReviewManifestScript.stack_role_snapshot(
			assets_by_id[item_id] as Dictionary
		) == {
			"reviewed_source_fingerprint": role_review["reviewed_source_fingerprint"],
			"reviewed_rotation_degrees": role_review["reviewed_rotation_degrees"],
			"reviewed_footprint": role_review["reviewed_footprint"],
			"reviewed_can_be_stacked": role_review["reviewed_can_be_stacked"],
			"reviewed_can_support_stack": role_review["reviewed_can_support_stack"]
		})
		assert(String((record["auto_group_review"] as Dictionary)["status"]) == "UNREVIEWED")
	assert(String((records["loot_000003"] as Dictionary)["stack_role_review"]["notes"]) == "Flat stable base; irregular exposed-electronics top is not a credible support surface.")
	var remaining_unreviewed: int = 0
	for item_id: String in StackRoleAuthoringScript.candidate_ids():
		if BATCH_ONE_IDS.has(item_id):
			continue
		assert(String((records[item_id] as Dictionary)["stack_role_review"]["status"]) == "UNREVIEWED")
		remaining_unreviewed += 1
	assert(remaining_unreviewed == 27)
	for item_id: String in BLOCKED_IDS:
		assert(String((records[item_id] as Dictionary)["stack_role_review"]["status"]) == "UNREVIEWED")


func _test_batch_two_apply_snapshots_human_adjustments_without_auto_groups() -> void:
	var fixture: Dictionary = _fixture()
	_apply_candidate_roles(fixture["current_assets"] as Array[Dictionary])
	var seeded: Dictionary = StackRoleAuthoringScript.apply_phase_1(
		fixture["manifest"] as Dictionary,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	var batch_one: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_1(
		seeded["manifest"] as Dictionary,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	for asset: Dictionary in fixture["current_assets"] as Array[Dictionary]:
		var adjusted: Array = BATCH_TWO_ADJUSTED_ROLES.get(String(asset["item_id"]), []) as Array
		if not adjusted.is_empty():
			asset["can_be_stacked"] = bool(adjusted[0])
			asset["can_support_stack"] = bool(adjusted[1])
	var result: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_2(
		batch_one["manifest"] as Dictionary,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	assert((result["errors"] as PackedStringArray).is_empty())
	assert(result["approved_item_ids"] == BATCH_TWO_IDS)
	var records: Dictionary = (result["manifest"] as Dictionary)["assets"] as Dictionary
	var assets_by_id: Dictionary = {}
	for asset: Dictionary in fixture["current_assets"] as Array[Dictionary]:
		assets_by_id[String(asset["item_id"])] = asset
	for item_id: String in BATCH_TWO_IDS:
		var record: Dictionary = records[item_id] as Dictionary
		var role_review: Dictionary = record["stack_role_review"] as Dictionary
		assert(String(role_review["status"]) == "APPROVED")
		assert(role_review["flags"] == [])
		assert(AuthoringReviewManifestScript.stack_role_snapshot(
			assets_by_id[item_id] as Dictionary
		) == {
			"reviewed_source_fingerprint": role_review["reviewed_source_fingerprint"],
			"reviewed_rotation_degrees": role_review["reviewed_rotation_degrees"],
			"reviewed_footprint": role_review["reviewed_footprint"],
			"reviewed_can_be_stacked": role_review["reviewed_can_be_stacked"],
			"reviewed_can_support_stack": role_review["reviewed_can_support_stack"]
		})
		assert(String((record["auto_group_review"] as Dictionary)["status"]) == "UNREVIEWED")
	for item_id: String in BATCH_TWO_ADJUSTED_ROLES:
		var expected: Array = BATCH_TWO_ADJUSTED_ROLES[item_id] as Array
		var adjusted_asset: Dictionary = assets_by_id[item_id] as Dictionary
		assert(bool(adjusted_asset["can_be_stacked"]) == bool(expected[0]))
		assert(bool(adjusted_asset["can_support_stack"]) == bool(expected[1]))
	var remaining_unreviewed: int = 0
	for item_id: String in StackRoleAuthoringScript.candidate_ids():
		if BATCH_ONE_IDS.has(item_id) or BATCH_TWO_IDS.has(item_id):
			continue
		assert(String((records[item_id] as Dictionary)["stack_role_review"]["status"]) == "UNREVIEWED")
		remaining_unreviewed += 1
	assert(remaining_unreviewed == 16)
	for item_id: String in BLOCKED_IDS:
		assert(String((records[item_id] as Dictionary)["stack_role_review"]["status"]) == "UNREVIEWED")


func _test_batch_three_apply_snapshots_human_adjustments_without_auto_groups() -> void:
	var fixture: Dictionary = _fixture()
	_apply_candidate_roles(fixture["current_assets"] as Array[Dictionary])
	var seeded: Dictionary = StackRoleAuthoringScript.apply_phase_1(fixture["manifest"] as Dictionary, fixture["current_assets"] as Array[Dictionary], _registry())
	var batch_one: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_1(seeded["manifest"] as Dictionary, fixture["current_assets"] as Array[Dictionary], _registry())
	for asset: Dictionary in fixture["current_assets"] as Array[Dictionary]:
		var batch_two_adjusted: Array = BATCH_TWO_ADJUSTED_ROLES.get(String(asset["item_id"]), []) as Array
		if not batch_two_adjusted.is_empty():
			asset["can_be_stacked"] = bool(batch_two_adjusted[0])
			asset["can_support_stack"] = bool(batch_two_adjusted[1])
	var batch_two: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_2(batch_one["manifest"] as Dictionary, fixture["current_assets"] as Array[Dictionary], _registry())
	for asset: Dictionary in fixture["current_assets"] as Array[Dictionary]:
		var batch_three_adjusted: Array = BATCH_THREE_ADJUSTED_ROLES.get(String(asset["item_id"]), []) as Array
		if not batch_three_adjusted.is_empty():
			asset["can_be_stacked"] = bool(batch_three_adjusted[0])
			asset["can_support_stack"] = bool(batch_three_adjusted[1])
	var result: Dictionary = StackRoleAuthoringScript.apply_stack_role_batch_3(batch_two["manifest"] as Dictionary, fixture["current_assets"] as Array[Dictionary], _registry())
	assert((result["errors"] as PackedStringArray).is_empty())
	assert(result["approved_item_ids"] == BATCH_THREE_IDS)
	var records: Dictionary = (result["manifest"] as Dictionary)["assets"] as Dictionary
	for item_id: String in BATCH_THREE_IDS:
		var record: Dictionary = records[item_id] as Dictionary
		assert(String((record["stack_role_review"] as Dictionary)["status"]) == "APPROVED")
		assert(((record["stack_role_review"] as Dictionary)["flags"] as Array).is_empty())
		assert(String((record["auto_group_review"] as Dictionary)["status"]) == "UNREVIEWED")
	for item_id: String in BATCH_THREE_ADJUSTED_ROLES:
		var expected: Array = BATCH_THREE_ADJUSTED_ROLES[item_id] as Array
		var role_review: Dictionary = (records[item_id] as Dictionary)["stack_role_review"] as Dictionary
		assert(bool(role_review["reviewed_can_be_stacked"]) == bool(expected[0]))
		assert(bool(role_review["reviewed_can_support_stack"]) == bool(expected[1]))
	var remaining_unreviewed: int = 0
	for item_id: String in StackRoleAuthoringScript.candidate_ids():
		if BATCH_ONE_IDS.has(item_id) or BATCH_TWO_IDS.has(item_id) or BATCH_THREE_IDS.has(item_id):
			continue
		assert(String((records[item_id] as Dictionary)["stack_role_review"]["status"]) == "UNREVIEWED")
		remaining_unreviewed += 1
	assert(remaining_unreviewed == 9)


func _test_gloves_and_pants_remain_blocked_without_candidates() -> void:
	var fixture: Dictionary = _fixture()
	var result: Dictionary = StackRoleAuthoringScript.apply_phase_1(
		fixture["manifest"] as Dictionary,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	var records: Dictionary = (result["manifest"] as Dictionary)["assets"] as Dictionary
	for item_id: String in BLOCKED_IDS:
		assert(StackRoleAuthoringScript.candidate_for(item_id).is_empty())
		var record: Dictionary = records[item_id] as Dictionary
		assert((record["stack_role_review"] as Dictionary) == AuthoringReviewManifestScript.new_record({})["stack_role_review"])
		assert((record["auto_group_review"] as Dictionary) == AuthoringReviewManifestScript.new_record({})["auto_group_review"])


func _test_catalogue_set_mismatch_aborts_without_writes() -> void:
	var fixture: Dictionary = _fixture()
	var missing_assets: Array[Dictionary] = (fixture["current_assets"] as Array[Dictionary]).duplicate(true)
	missing_assets.pop_back()
	var result: Dictionary = StackRoleAuthoringScript.apply_phase_1(
		fixture["manifest"] as Dictionary, missing_assets, _registry()
	)
	assert(not (result["errors"] as PackedStringArray).is_empty())
	assert((result["candidate_values"] as Dictionary).is_empty())
	assert((result["manifest"] as Dictionary) == (fixture["manifest"] as Dictionary))


func _test_invalid_manifest_aborts_without_writes() -> void:
	var fixture: Dictionary = _fixture()
	var manifest: Dictionary = fixture["manifest"] as Dictionary
	var record: Dictionary = (manifest["assets"] as Dictionary)["loot_000003"] as Dictionary
	(record["stack_role_review"] as Dictionary)["flags"] = ["UNRECOGNIZED_FLAG"]
	var result: Dictionary = StackRoleAuthoringScript.apply_phase_1(
		manifest,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	assert(not (result["errors"] as PackedStringArray).is_empty())
	assert((result["candidate_values"] as Dictionary).is_empty())
	assert((result["manifest"] as Dictionary) == manifest)


func _test_phase_one_preserves_opaque_authoring_keys() -> void:
	var fixture: Dictionary = _fixture()
	var manifest: Dictionary = fixture["manifest"] as Dictionary
	var records: Dictionary = manifest["assets"] as Dictionary
	var opaque_key: String = "legacy_asset_key"
	records[opaque_key] = records["loot_000002"]
	records.erase("loot_000002")
	var result: Dictionary = StackRoleAuthoringScript.apply_phase_1(
		manifest,
		fixture["current_assets"] as Array[Dictionary],
		_registry()
	)
	assert((result["errors"] as PackedStringArray).is_empty())
	var updated_records: Dictionary = (result["manifest"] as Dictionary)["assets"] as Dictionary
	assert(updated_records.has(opaque_key))
	assert(not updated_records.has("loot_000002"))
	assert(String((updated_records[opaque_key]["stack_role_review"] as Dictionary)["status"]) == "APPROVED")


func _test_future_items_use_reusable_pipeline_not_phase_one_table() -> void:
	assert(StackRoleAuthoringScript.candidate_for("loot_999999").is_empty())
	var future_asset: Dictionary = _asset("loot_999999", false, false, "")
	var future_record: Dictionary = AuthoringReviewManifestScript.new_record(future_asset)
	assert(String((future_record["stack_role_review"] as Dictionary)["status"]) == "UNREVIEWED")
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	var result: Dictionary = AuthoringReviewManifestScript.seed_or_sync(manifest, [future_asset])
	assert((result["manifest"] as Dictionary)["assets"].size() == 1)


func _fixture() -> Dictionary:
	var manifest: Dictionary = AuthoringReviewManifestScript.empty_manifest()
	var records: Dictionary = {}
	var current_assets: Array[Dictionary] = []
	for number: int in range(1, 43):
		var item_id: String = "loot_%06d" % number
		var role: Array = GRANDFATHERED.get(item_id, [false, false, ""]) as Array
		var asset: Dictionary = _asset(item_id, bool(role[0]), bool(role[1]), String(role[2]))
		var record: Dictionary = AuthoringReviewManifestScript.new_record(asset)
		if not BLOCKED_IDS.has(item_id):
			_approve_geometry(record, asset)
		else:
			var pose_review: Dictionary = record["storage_pose_review"] as Dictionary
			pose_review["status"] = "CUSTOM_POSE_REQUIRED"
			pose_review["reviewed_source_fingerprint"] = asset["source_fingerprint"]
		records[item_id] = record
		current_assets.append(asset)
	manifest["assets"] = records
	return {"manifest": manifest, "current_assets": current_assets}


func _asset(item_id: String, stacked: bool, supports: bool, group_id: String) -> Dictionary:
	return {
		"source_path": "res://%s.glb" % item_id,
		"definition_path": "res://data/items/definitions/%s.tres" % item_id,
		"item_id": item_id,
		"display_name": item_id,
		"storage_category": "General",
		"source_fingerprint": "hash-%s" % item_id,
		"has_item_definition": true,
		"storage_rotation_degrees": [0.0, 0.0, 0.0],
		"storage_footprint": [1, 1, 1],
		"can_be_stacked": stacked,
		"can_support_stack": supports,
		"auto_stack_group": group_id
	}


func _approve_geometry(record: Dictionary, asset: Dictionary) -> void:
	var pose_review: Dictionary = record["storage_pose_review"] as Dictionary
	pose_review["status"] = "DEFAULT_POSE_APPROVED"
	pose_review["reviewed_source_fingerprint"] = asset["source_fingerprint"]
	pose_review["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	var footprint_review: Dictionary = record["footprint_review"] as Dictionary
	footprint_review["status"] = "GEOMETRY_APPROVED"
	footprint_review["reviewed_source_fingerprint"] = asset["source_fingerprint"]
	footprint_review["reviewed_rotation_degrees"] = [0.0, 0.0, 0.0]
	footprint_review["reviewed_footprint"] = [1, 1, 1]


func _apply_candidate_roles(current_assets: Array[Dictionary]) -> void:
	for asset: Dictionary in current_assets:
		var candidate: Dictionary = StackRoleAuthoringScript.candidate_for(
			String(asset["item_id"])
		)
		if candidate.is_empty():
			continue
		asset["can_be_stacked"] = bool(candidate["can_be_stacked"])
		asset["can_support_stack"] = bool(candidate["can_support_stack"])


func _registry() -> Dictionary:
	var classes: Dictionary = {}
	for group_id: String in ["flat_media", "round_cans", "boxed_food", "medical_boxes"]:
		classes[group_id] = {
			"approval_status": "APPROVED",
			"compatibility_revision": 1,
			"description": "Approved %s compatibility." % group_id
		}
	return {"schema_version": "1.0", "classes": classes}


func _sorted_keys(dictionary: Dictionary) -> PackedStringArray:
	var keys: PackedStringArray = []
	for key_value: Variant in dictionary.keys():
		keys.append(String(key_value))
	keys.sort()
	return keys
