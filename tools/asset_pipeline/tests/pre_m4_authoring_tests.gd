extends SceneTree

var failures:=0

func check(ok: bool,message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)

func _init() -> void:
	run.call_deferred()

func run() -> void:
	var output:=""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--evidence-dir="):output=arg.trim_prefix("--evidence-dir=")
	if not output.is_absolute_path():
		quit(1)
		return
	var source_path:="res://data/items/definitions/loot_000100.tres"
	var before:=FileAccess.get_sha256(source_path)
	var working: ItemDefinition=load(source_path).duplicate()
	var external_path:=output.path_join("authoring-external-item.tres")
	check(ResourceSaver.save(working,external_path)==OK,"Save external test ItemDefinition")
	working=ResourceLoader.load(external_path,"",ResourceLoader.CACHE_MODE_IGNORE)
	var fixture: Node3D=load("res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn").instantiate()
	root.add_child(fixture)
	fixture.item_definition=working
	fixture.refresh_preview()
	check(fixture.get_preview_contract().valid,"Actual workbench previews external new item")
	working.storage_rotation_degrees=Vector3(90,45,0)
	working.can_be_stacked=true
	working.can_support_stack=false
	working.auto_stack_group=&""
	working.emit_changed()
	await process_frame
	check(fixture.get_preview_contract().storage_rotation_degrees==working.storage_rotation_degrees,"Live edit refresh uses external definition")
	fixture.apply_suggested_footprint()
	var footprint:=working.storage_footprint
	check(ResourceSaver.save(working,external_path)==OK,"Persist edited external .tres")
	fixture.free()
	var reopened: ItemDefinition=ResourceLoader.load(external_path,"",ResourceLoader.CACHE_MODE_IGNORE)
	check(reopened.storage_rotation_degrees==Vector3(90,45,0) and reopened.storage_footprint==footprint and reopened.can_be_stacked and not reopened.can_support_stack and reopened.auto_stack_group==&"","External pose/Footprint/stack/group persist on reopen")
	fixture=load("res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn").instantiate()
	root.add_child(fixture)
	fixture.item_definition=reopened
	fixture.refresh_preview()
	check(fixture.get_preview_contract().valid,"Reopened edited item previews in actual scene")
	if OS.get_cmdline_user_args().has("--capture"):
		# The editor workbench intentionally has no gameplay camera or lights.
		# Transient proof equipment does not modify the authored scene.
		var camera:=Camera3D.new()
		fixture.add_child(camera)
		camera.position=Vector3(1.8,1.8,2.4)
		camera.look_at(Vector3(0,0.15,0))
		camera.current=true
		var light:=DirectionalLight3D.new()
		light.rotation_degrees=Vector3(-55,-35,0)
		fixture.add_child(light)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("workbench-external-roundtrip.png"))
	fixture.free()
	check(FileAccess.get_sha256(source_path)==before,"Production proposal remains unchanged by isolated authoring test")
	print("PRE_M4_AUTHORING_COMPLETE failures=",failures)
	quit(1 if failures else 0)
