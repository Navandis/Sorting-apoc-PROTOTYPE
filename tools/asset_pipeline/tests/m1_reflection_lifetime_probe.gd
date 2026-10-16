extends SceneTree

func _init() -> void:
	run.call_deferred()

func run() -> void:
	var script_path := "res://gameplay/logistics_wing/receiving/receiving_reflections.gd"
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--reflection-script="):
			script_path = argument.trim_prefix("--reflection-script=")
	for frame_count: int in [1,2]:
		var owner := Node3D.new()
		owner.name = "ReflectionOwner"
		owner.set_script(load(script_path))
		var probe := ReflectionProbe.new()
		probe.name = "InteriorProbe"
		owner.add_child(probe)
		root.add_child(owner)
		owner.request_refresh()
		for frame: int in frame_count: await process_frame
		owner.free()
		for frame: int in 4: await process_frame
	print("M1_REFLECTION_LIFETIME_COMPLETE deletion_windows=2")
	quit(0)
