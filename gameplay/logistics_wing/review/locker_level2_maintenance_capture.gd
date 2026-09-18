extends Node3D

# Explicit, transient review only. No save paths or normal launch hooks.
const OUTPUT_ROOT := "res://reports/logistics_wing/content_maintenance/locker_fuel/initial/m01"
const GAMEPLAY := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const SIZE := Vector2i(1920, 1080)


func _ready() -> void:
	if OS.get_cmdline_user_args().has("--capture-m01"):
		_capture.call_deferred()


func _capture() -> void:
	var phase := ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--phase="):
			phase = argument.trim_prefix("--phase=")
	if phase not in ["before", "after"]:
		_fail("explicit --phase=before or --phase=after is required")
		return
	var directory := ProjectSettings.globalize_path(OUTPUT_ROOT.path_join(phase))
	var attempt := 1
	while DirAccess.dir_exists_absolute(directory):
		attempt += 1
		directory = ProjectSettings.globalize_path(OUTPUT_ROOT.path_join("%s_%02d" % [phase, attempt]))
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		_fail("cannot create evidence directory")
		return
	# Bounded even if a renderer callback fails to arrive.
	get_tree().create_timer(45.0).timeout.connect(func(): _fail("45-second capture deadline"))
	var gameplay := (load(GAMEPLAY) as PackedScene).instantiate()
	gameplay.get_node("Player").set("enable_held_item_view", false)
	add_child(gameplay)
	await get_tree().process_frame
	await get_tree().physics_frame
	var player := gameplay.get_node("Player")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	var controller := player.get_node("StoragePlacementController") as StoragePlacementController
	var carried := player.get_node("CarriedItems") as CarriedItems
	var surface := gameplay.get_node("FunctionalFixtures/SM_ventilated_locker_GalleryC_West/StorageSurface_02") as StorageSurface
	var records: Array[Dictionary] = []
	for far_end: bool in [false, true]:
		var definition := load("res://data/items/definitions/loot_000022.tres") as ItemDefinition
		var host := definition.visual_scene.instantiate() as Node3D
		add_child(host)
		var world := WorldItem.new()
		host.add_child(world)
		world.configure(host, definition)
		var item := world.get_item_instance()
		if not world.pickup_into(carried):
			_fail("review can pickup failed")
			return
		var entry := controller.call("_entry_for_item", item, far_end) as StorageStack.Entry
		var fit: Dictionary
		if far_end:
			fit = surface.find_manual_empty_fit(Vector3(-100, 0, 100), entry)
		else:
			surface.set_zone_rect("Hydration", Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
			fit = surface.find_zone_stack_or_empty_fit("Hydration", entry)
		controller.set("_current_surface", surface)
		controller.set("_current_fit", fit)
		controller.set("_manual_mode", far_end)
		controller.set("_rotated", far_end)
		if not controller.place_selected():
			_fail("review rear-row placement failed")
			return
		var stored := surface.get_storage_stack(item.instance_id).entries[0]
		var packing := stored.host.get_node("StoredPackingYaw") as Node3D
		var bounds: AABB = packing.global_transform * stored.aligned_bounds
		records.append({"mode": "manual_R90" if far_end else "auto_native", "origin": str(fit["origin"]), "bounds_world": str(bounds), "instance": item.instance_id, "world_scale": str(stored.host.global_basis.get_scale())})
	var key := InputEventKey.new()
	key.keycode = KEY_F6
	key.pressed = true
	Input.parse_input_event(key)
	await get_tree().process_frame
	await get_tree().physics_frame
	if not surface.is_developer_debug_visible():
		_fail("real F6 developer grid did not enable")
		return
	get_window().size = SIZE
	var camera := Camera3D.new()
	add_child(camera)
	camera.fov = 75.0
	camera.make_current()
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	layer.add_child(label)
	label.position = Vector2(24, 22)
	label.add_theme_font_size_override("font_size", 25)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	var views := [
		{"name": "player_eye", "label": "Ordinary player-eye stance, Y=1.72m", "position": Vector3(0.8, 1.72, 9), "target": Vector3(-1.35, 1.18, 9)},
		{"name": "diagnostic_rear", "label": "DIAGNOSTIC rear oblique (not player stance)", "position": Vector3(-1.95, 1.45, 7.55), "target": Vector3(-1.74, 1.20, 8.90)},
	]
	for view: Dictionary in views:
		camera.position = view["position"]
		camera.look_at(view["target"], Vector3.UP)
		label.text = "M01 %s | %s\nReal F6 grid; 2 Soda Cans at rear-row ends (auto/native + manual/R90)" % [phase.to_upper(), view["label"]]
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		if image.save_png(directory.path_join(view["name"] + ".png")) != OK:
			_fail("image save failed")
			return
		view["position"] = str(view["position"])
		view["target"] = str(view["target"])
		print("M01_CAPTURE %s %s" % [phase, view["name"]])
	var manifest := {"phase": phase, "scene": GAMEPLAY, "surface_world": str(surface.global_position), "grid": str(surface.grid_size), "usable_m": str(surface.usable_size_m), "items": records, "views": views, "fov": camera.fov, "source_sha256": FileAccess.get_sha256("res://storage_prototype_manager.gd"), "capture_sha256": FileAccess.get_sha256("res://gameplay/logistics_wing/review/locker_level2_maintenance_capture.gd")}
	var file := FileAccess.open(directory.path_join("manifest.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t") + "\n")
	file.close()
	print("PASS: M01 maintenance capture complete")
	get_tree().quit(0)


func _fail(message: String) -> void:
	push_error("M01 capture failed: " + message)
	get_tree().quit(1)
