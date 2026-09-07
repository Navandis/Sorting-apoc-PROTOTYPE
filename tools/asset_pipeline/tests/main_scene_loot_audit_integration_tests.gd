extends SceneTree

const REPORT_PATH: String = "res://reports/asset_pipeline/main_scene_loot_audit.json"


func _init() -> void:
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
	var file: FileAccess = FileAccess.open(REPORT_PATH, FileAccess.READ)
	assert(file != null)
	var parser: JSON = JSON.new()
	assert(parser.parse(file.get_as_text()) == OK)
	file.close()
	var report: Dictionary = parser.data as Dictionary
	assert(String(report["schema_version"]) == "1.3")
	assert(String(report["authoring_review_manifest_schema_version"]) == "1.0")
	var assets: Array = report["assets"] as Array
	assert(assets.size() == 42)
	var default_pose_count: int = 0
	var custom_pose_approved_count: int = 0
	var custom_pose_required_count: int = 0
	var scale_current_count: int = 0
	var footprint_approved_count: int = 0
	var stale_pose_approval_count: int = 0
	var unresolved_item_ids: PackedStringArray = []
	for asset_value: Variant in assets:
		var asset: Dictionary = asset_value as Dictionary
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
		if String(asset["footprint_review_status"]) in ["GEOMETRY_APPROVED", "OVERRIDE_APPROVED"]:
			footprint_approved_count += 1
		if pose_status in ["DEFAULT_POSE_APPROVED", "CUSTOM_POSE_APPROVED"] \
			and not bool(asset["storage_pose_review_current"]):
			stale_pose_approval_count += 1
	unresolved_item_ids.sort()
	assert(default_pose_count == 28)
	assert(custom_pose_approved_count == 12)
	assert(custom_pose_required_count == 2)
	assert(default_pose_count + custom_pose_approved_count == 40)
	assert(scale_current_count == 42)
	assert(footprint_approved_count == 0)
	assert(stale_pose_approval_count == 0)
	assert(unresolved_item_ids == PackedStringArray(["loot_000034", "loot_000036"]))
	var record: Dictionary = assets[0] as Dictionary
	for field: String in [
		"authoring_key", "source_fingerprint", "scale_review_status", "scale_review_current",
		"storage_pose_review_status", "storage_pose_review_current", "footprint_review_status",
		"footprint_review_current", "storage_rotation_degrees", "posed_effective_bounds",
		"posed_width_m", "posed_height_m", "posed_depth_m", "posed_raw_width_cells",
		"posed_raw_depth_cells", "posed_raw_orientation_a", "posed_raw_orientation_b"
	]:
		assert(record.has(field))
	assert(String(record["scale_review_status"]) == "APPROVED")
	assert(bool(record["scale_review_current"]))
	assert(not (record["flags"] as Array).has("SCALE_REVIEW_STALE"))
	print("PASS: main scene loot audit integration tests")
	quit(0)
