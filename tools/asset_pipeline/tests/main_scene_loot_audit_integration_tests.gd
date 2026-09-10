extends SceneTree

const REPORT_PATH: String = "res://reports/asset_pipeline/main_scene_loot_audit.json"
const MANIFEST_PATH: String = "res://tools/asset_pipeline/item_authoring_review.json"
const REGISTRY_PATH: String = "res://tools/asset_pipeline/auto_stack_group_registry.json"
const CANDIDATE_FOOTPRINT_ITEM_IDS: PackedStringArray = []
const INELIGIBLE_FOOTPRINT_ITEM_IDS: PackedStringArray = ["loot_000034", "loot_000036"]
const BATCH_ONE_STACK_ROLES: Dictionary = {
	"loot_000003": [true, false],
	"loot_000007": [true, true],
	"loot_000020": [true, false],
	"loot_000021": [true, false]
}
const BATCH_TWO_STACK_ROLES: Dictionary = {
	"loot_000008": [true, true], "loot_000010": [true, true],
	"loot_000015": [true, false], "loot_000016": [true, false],
	"loot_000017": [true, false], "loot_000018": [true, false],
	"loot_000022": [true, true], "loot_000023": [true, true],
	"loot_000024": [true, false], "loot_000025": [true, false],
	"loot_000027": [true, false]
}
const BATCH_THREE_STACK_ROLES: Dictionary = {
	"loot_000001": [true, false], "loot_000004": [true, false],
	"loot_000012": [true, false], "loot_000014": [false, false],
	"loot_000029": [true, false], "loot_000033": [true, false],
	"loot_000035": [true, false]
}
const BATCH_FOUR_STACK_ROLES: Dictionary = {"loot_000011": [false, false], "loot_000026": [true, false], "loot_000032": [true, false]}
const PRINTER_BATCH_ONE_NOTE: String = "Flat stable base; irregular exposed-electronics top is not a credible support surface."


func _init() -> void:
	var manifest_before: PackedByteArray = FileAccess.get_file_as_bytes(MANIFEST_PATH)
	var registry_before: PackedByteArray = FileAccess.get_file_as_bytes(REGISTRY_PATH)
	var output: Array[String] = []
	var exit_code: int = OS.execute(
		OS.get_executable_path(),
		[
			"--headless", "--path", ProjectSettings.globalize_path("res://"),
			"--script", "res://tools/asset_pipeline/run_main_scene_loot_audit.gd"
		],
		output,
		true
	)
	assert(exit_code == 0)
	assert(FileAccess.get_file_as_bytes(MANIFEST_PATH) == manifest_before)
	assert(FileAccess.get_file_as_bytes(REGISTRY_PATH) == registry_before)
	var file: FileAccess = FileAccess.open(REPORT_PATH, FileAccess.READ)
	assert(file != null)
	var parser: JSON = JSON.new()
	assert(parser.parse(file.get_as_text()) == OK)
	file.close()
	var report: Dictionary = parser.data as Dictionary
	assert(String(report["schema_version"]) == "1.4")
	assert(String(report["authoring_review_manifest_schema_version"]) == "2.0")
	assert(String(report["auto_stack_group_registry_schema_version"]) == "1.0")
	var review_summary: Dictionary = report["review_summary"] as Dictionary
	_assert_summary(review_summary["stack_role"] as Dictionary, [42, 40, 34, 6, 0, 2])
	_assert_summary(review_summary["auto_group"] as Dictionary, [42, 34, 9, 25, 0, 8])
	var registry_summary: Dictionary = report["registry_summary"] as Dictionary
	assert(int(registry_summary["approved_class_count"]) == 4)
	assert((registry_summary["unknown_references"] as Array).is_empty())
	var assets: Array = report["assets"] as Array
	assert(assets.size() == 42)
	var default_pose_count: int = 0
	var custom_pose_approved_count: int = 0
	var custom_pose_required_count: int = 0
	var scale_current_count: int = 0
	var footprint_approved_count: int = 0
	var footprint_unreviewed_count: int = 0
	var stale_pose_approval_count: int = 0
	var unresolved_item_ids: PackedStringArray = []
	for asset_value: Variant in assets:
		var asset: Dictionary = asset_value as Dictionary
		var item_id: String = String(asset["item_id"])
		if BATCH_ONE_STACK_ROLES.has(item_id) or BATCH_TWO_STACK_ROLES.has(item_id) or BATCH_THREE_STACK_ROLES.has(item_id) or BATCH_FOUR_STACK_ROLES.has(item_id):
			var expected_role: Array = (BATCH_ONE_STACK_ROLES.get(item_id, BATCH_TWO_STACK_ROLES.get(item_id, BATCH_THREE_STACK_ROLES.get(item_id, BATCH_FOUR_STACK_ROLES.get(item_id)))) as Array)
			assert(bool(asset["can_be_stacked"]) == bool(expected_role[0]))
			assert(bool(asset["can_support_stack"]) == bool(expected_role[1]))
			assert(String(asset["stack_role_review_status"]) == "APPROVED")
			assert(bool(asset["stack_role_review_eligible"]))
			assert(bool(asset["stack_role_review_current"]))
			assert(not bool(asset["stack_role_review_stale"]))
			assert(not bool(asset["stack_role_review_dependency_blocked"]))
			assert((asset["stack_role_review_flags"] as Array).is_empty())
			assert(String(asset["auto_group_review_status"]) == "UNREVIEWED")
			assert(bool(asset["auto_group_review_eligible"]))
			assert(not bool(asset["auto_group_review_current"]))
			assert(not bool(asset["auto_group_review_stale"]))
			assert(not bool(asset["auto_group_review_dependency_blocked"]))
			if item_id == "loot_000003":
				assert(String(asset["stack_role_review_notes"]) == PRINTER_BATCH_ONE_NOTE)
		var pose_status: String = String(asset["storage_pose_review_status"])
		if pose_status == "DEFAULT_POSE_APPROVED":
			default_pose_count += 1
		elif pose_status == "CUSTOM_POSE_APPROVED":
			custom_pose_approved_count += 1
		elif pose_status == "CUSTOM_POSE_REQUIRED":
			custom_pose_required_count += 1
			unresolved_item_ids.append(String(asset["item_id"]))
			assert(bool(asset["storage_pose_review_current"]))
			assert(not bool(asset["footprint_review_current"]))
		if bool(asset["scale_review_current"]):
			scale_current_count += 1
		var footprint_status: String = String(asset["footprint_review_status"])
		if CANDIDATE_FOOTPRINT_ITEM_IDS.has(item_id) or INELIGIBLE_FOOTPRINT_ITEM_IDS.has(item_id):
			assert(footprint_status == "UNREVIEWED")
			assert(not bool(asset["footprint_review_current"]))
		else:
			var footprint: Array = asset["storage_footprint"] as Array
			var current_orientation: String = "%dx%d" % [int(footprint[0]), int(footprint[1])]
			var matches_posed_geometry: bool = current_orientation == String(asset["posed_raw_orientation_a"]) \
				or current_orientation == String(asset["posed_raw_orientation_b"])
			assert(footprint_status == ("GEOMETRY_APPROVED" if matches_posed_geometry else "OVERRIDE_APPROVED"))
			assert(bool(asset["footprint_review_current"]))
		if footprint_status in ["GEOMETRY_APPROVED", "OVERRIDE_APPROVED"]:
			footprint_approved_count += 1
		elif footprint_status == "UNREVIEWED":
			footprint_unreviewed_count += 1
		if pose_status in ["DEFAULT_POSE_APPROVED", "CUSTOM_POSE_APPROVED"] \
			and not bool(asset["storage_pose_review_current"]):
			stale_pose_approval_count += 1
	unresolved_item_ids.sort()
	assert(default_pose_count == 28)
	assert(custom_pose_approved_count == 12)
	assert(custom_pose_required_count == 2)
	assert(default_pose_count + custom_pose_approved_count == 40)
	assert(scale_current_count == 42)
	assert(footprint_approved_count == 40)
	assert(footprint_unreviewed_count == 2)
	assert(stale_pose_approval_count == 0)
	assert(unresolved_item_ids == PackedStringArray(["loot_000034", "loot_000036"]))
	var record: Dictionary = assets[0] as Dictionary
	for field: String in [
		"authoring_key", "source_fingerprint", "scale_review_status", "scale_review_current",
		"storage_pose_review_status", "storage_pose_review_current", "footprint_review_status",
		"footprint_review_current", "storage_rotation_degrees", "posed_effective_bounds",
		"posed_width_m", "posed_height_m", "posed_depth_m", "posed_raw_width_cells",
		"posed_raw_depth_cells", "posed_raw_orientation_a", "posed_raw_orientation_b",
		"can_be_stacked", "can_support_stack", "auto_stack_group",
		"stack_role_review_status", "stack_role_review_eligible", "stack_role_review_current",
		"stack_role_review_stale", "stack_role_review_dependency_blocked",
		"auto_group_review_status", "auto_group_review_eligible", "auto_group_review_current",
		"auto_group_review_stale", "auto_group_review_dependency_blocked",
		"auto_group_reference_valid", "auto_group_registry_compatibility_revision"
	]:
		assert(record.has(field))
	assert(String(record["scale_review_status"]) == "APPROVED")
	assert(bool(record["scale_review_current"]))
	assert(not (record["flags"] as Array).has("SCALE_REVIEW_STALE"))
	print("PASS: main scene loot audit integration tests")
	quit(0)


func _assert_summary(summary: Dictionary, values: Array) -> void:
	assert(int(summary["total"]) == int(values[0]))
	assert(int(summary["currently_eligible"]) == int(values[1]))
	assert(int(summary["approved_current"]) == int(values[2]))
	assert(int(summary["unreviewed"]) == int(values[3]))
	assert(int(summary["stale"]) == int(values[4]))
	assert(int(summary["dependency_blocked"]) == int(values[5]))
