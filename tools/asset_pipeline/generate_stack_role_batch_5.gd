extends SceneTree
const StackRoleAuthoringScript = preload("res://tools/asset_pipeline/stack_role_authoring.gd")
func _init() -> void:
	var file := FileAccess.open("res://reports/asset_pipeline/main_scene_loot_audit.json", FileAccess.READ)
	if file == null: quit(1); return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK: quit(1); return
	file.close()
	var records: Array[Dictionary] = []
	for value: Variant in (json.data as Dictionary).get("assets", []) as Array:
		if value is Dictionary: records.append(value as Dictionary)
	if StackRoleAuthoringScript.batch_five_rows(records).size() != StackRoleAuthoringScript.BATCH_FIVE_ITEM_IDS.size(): quit(1); return
	var output := FileAccess.open("res://reports/asset_pipeline/stack_role_batch_5.md", FileAccess.WRITE)
	if output == null: quit(1); return
	output.store_string(StackRoleAuthoringScript.batch_five_markdown(records)); output.close()
	print("STACK_ROLE_BATCH_5_COMPLETE rows=%d" % StackRoleAuthoringScript.BATCH_FIVE_ITEM_IDS.size()); quit(0)
