extends SceneTree

## One-time Phase 1 human handoff generator. Future review batches must use
## the reusable manifest/audit evidence rather than extending this closed seed.

const StackRoleAuthoringScript = preload("res://tools/asset_pipeline/stack_role_authoring.gd")
const AUDIT_PATH: String = "res://reports/asset_pipeline/main_scene_loot_audit.json"
const REPORT_PATH: String = "res://reports/asset_pipeline/stack_role_batch_2.md"


func _init() -> void:
	quit(_run())


func _run() -> int:
	var file: FileAccess = FileAccess.open(AUDIT_PATH, FileAccess.READ)
	if file == null:
		push_error("Run the main-scene loot audit before generating Stack Role Batch 2.")
		return 1
	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not (parser.data is Dictionary):
		push_error("Unable to parse main-scene loot audit for Stack Role Batch 2.")
		return 1
	var report: Dictionary = parser.data as Dictionary
	if String(report.get("schema_version", "")) != "1.4":
		push_error("Stack Role Batch 2 requires audit schema 1.4.")
		return 1
	var records_value: Variant = report.get("assets", [])
	if not (records_value is Array):
		push_error("Stack Role Batch 2 audit assets are invalid.")
		return 1
	var records: Array[Dictionary] = []
	for record_value: Variant in records_value as Array:
		if record_value is Dictionary:
			records.append(record_value as Dictionary)
	var rows: Array[Dictionary] = StackRoleAuthoringScript.batch_two_rows(records)
	if rows.size() != StackRoleAuthoringScript.BATCH_TWO_ITEM_IDS.size():
		push_error("Stack Role Batch 2 requires all expected candidate records.")
		return 1
	var output: FileAccess = FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if output == null:
		push_error("Unable to write Stack Role Batch 2 report.")
		return 1
	output.store_string(StackRoleAuthoringScript.batch_two_markdown(records))
	output.close()
	print("STACK_ROLE_BATCH_2_COMPLETE rows=%d report=%s" % [rows.size(), REPORT_PATH])
	return 0
