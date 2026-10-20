extends "res://tools/asset_pipeline/run_main_scene_loot_audit.gd"

func _init() -> void:
	var output := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	if not output.is_absolute_path():
		push_error("Explicit absolute external --output required")
		quit(1)
		return
	var records: Array = []
	for path: String in load("res://tools/asset_pipeline/props_catalogue.gd").discover():
		records.append(_audit_asset({"source_path":path,"scene_nodes":[],"instance_transforms":[],"instance_count":0},0.10))
	var file := FileAccess.open(output, FileAccess.WRITE)
	file.store_string(JSON.stringify(records,"\t",true)+"\n")
	file.close()
	print("PROPS_INSPECTION_COMPLETE models=",records.size())
	quit()
