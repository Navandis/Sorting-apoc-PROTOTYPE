extends SceneTree

func _init() -> void:
	run.call_deferred()

func run() -> void:
	var out := ""
	var posed:=OS.get_cmdline_user_args().has("--posed")
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): out=arg.trim_prefix("--output=")
	if not out.is_absolute_path():
		quit(1)
		return
	root.size=Vector2i(1600,1000)
	var records: Array=JSON.parse_string(FileAccess.get_file_as_string(out.path_join("imported-inventory.json")))
	records=records.filter(func(r): return not r.has_item_definition)
	for page: int in ceili(records.size()/16.0):
		var scene:=Node3D.new()
		root.add_child(scene)
		var env:=WorldEnvironment.new()
		env.environment=Environment.new()
		env.environment.background_mode=Environment.BG_COLOR
		env.environment.background_color=Color(0.09,0.11,0.14)
		env.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
		env.environment.ambient_light_color=Color.WHITE
		env.environment.ambient_light_energy=0.6
		scene.add_child(env)
		var light:=DirectionalLight3D.new()
		light.rotation_degrees=Vector3(-50,-30,0)
		scene.add_child(light)
		var camera:=Camera3D.new()
		camera.projection=Camera3D.PROJECTION_ORTHOGONAL
		camera.size=6.0
		camera.position=Vector3(4.8,3.0,20)
		scene.add_child(camera)
		camera.current=true
		var overlay:=Control.new()
		root.add_child(overlay)
		for index: int in mini(16,records.size()-page*16):
			var record: Dictionary=records[page*16+index]
			var holder:=Node3D.new()
			scene.add_child(holder)
			var definition: ItemDefinition=load("res://prototype_item_catalog.gd").create_definition_for_scene_path(record.source_path)
			var rotation: Vector3=definition.storage_rotation_degrees if posed else Vector3.ZERO
			var pose=load("res://storage_visual_pose.gd").build_visual(holder,load(record.source_path).instantiate(),rotation,false)
			var bounds: AABB=pose.posed_bounds
			# Camera views +Z Front, with a slight downward tilt applied to each thumbnail.
			var factor:=1.08/maxf(bounds.size.x,maxf(bounds.size.y,bounds.size.z))
			holder.scale=Vector3.ONE*factor
			holder.rotation_degrees=Vector3(20,-20,0)
			holder.position=Vector3(1.2+(index%4)*2.4,(3-index/4)*1.5+0.25,0)
			var label:=Label.new()
			label.position=Vector2((index%4)*400+5,(index/4)*250+214)
			label.size=Vector2(395,36)
			label.add_theme_font_size_override("font_size",13)
			label.text=record.asset_key+"\n%.3f x %.3f x %.3f m" % [record.width_m,record.height_m,record.depth_m]
			overlay.add_child(label)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join(("proposals" if posed else "sources")+"-%02d.png" % page))
		overlay.free()
		scene.free()
	print("PROPS_CONTACT_CAPTURE_COMPLETE pages=",ceili(records.size()/16.0))
	quit()
