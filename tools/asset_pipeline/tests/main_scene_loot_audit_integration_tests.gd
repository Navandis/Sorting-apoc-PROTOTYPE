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
	assert(String(report["schema_version"]) == "1.2")
	assert(String(report["authoring_review_manifest_schema_version"]) == "1.0")
	var assets: Array = report["assets"] as Array
	assert(not assets.is_empty())
	var record: Dictionary = assets[0] as Dictionary
	for field: String in [
		"authoring_key", "source_fingerprint", "scale_review_status", "scale_review_current",
		"storage_pose_review_status", "storage_pose_review_current", "footprint_review_status",
		"footprint_review_current"
	]:
		assert(record.has(field))
	assert(String(record["scale_review_status"]) == "APPROVED")
	assert(bool(record["scale_review_current"]))
	assert(not (record["flags"] as Array).has("SCALE_REVIEW_STALE"))
	print("PASS: main scene loot audit integration tests")
	quit(0)
