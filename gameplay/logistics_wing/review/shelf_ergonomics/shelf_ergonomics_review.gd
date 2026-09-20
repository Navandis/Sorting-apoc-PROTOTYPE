extends Node3D

const StorageManagerScript = preload("res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_storage_manager.gd")
const ClearanceContextScript = preload("res://storage_shelf_clearance_context.gd")
const MetalScene = preload("res://assets/environment/furniture/storage/SM_MetalShelves.glb")
const LockerScene = preload("res://assets/environment/furniture/storage/SM_ventilated_locker.glb")
const CabinetScene = preload("res://assets/environment/furniture/storage/SM_ClothesCabinet.glb")
const WingGameplayScene = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")

const GALLERY_CEILING_Y_A_B := 3.40
const GALLERY_CEILING_Y_C := 2.80
const LOWER_METAL_Y_SCALE := 0.592
const LOWER_LOCKER_Y_SCALE := 0.760
const LOWER_CABINET_Y_SCALE := 0.62
const METAL_REVIEW_POSITION := Vector3(10.10, 0.0, -10.95)
const REVIEW_EYE_HEIGHTS_M := [1.80, 1.716]
const GALLERY_B_CENTRE := Vector3(12.75, 0.0, -7.25)
const GALLERY_B_SIZE := Vector3(7.50, 0.20, 11.50)

@export var case_override := ""

var _case := "A"
var _ceiling_y_m := GALLERY_CEILING_Y_A_B
var _fixtures: Node3D
var _collision_root: Node3D
var _manager: StoragePrototypeManager
var _metal: Node3D
var _locker: Node3D
var _cabinet: Node3D
var _development_setup: Node3D
var _eye_height_m := 1.80
var _status_label: Label
var _unfitted_samples: Array[String] = []


func _ready() -> void:
	_assemble.call_deferred()


func _assemble() -> void:
	_case = _resolve_case()
	_ceiling_y_m = GALLERY_CEILING_Y_C if _case == "C" else GALLERY_CEILING_Y_A_B
	_configure_local_environment()
	if _case == "C":
		_replace_gallery_b_ceiling()
	_build_fixtures()
	_install_functional_storage()
	_seed_review_samples()
	_install_authoritative_supply()
	_place_player_at_review_entry()
	_add_status_label()
	print("Shelf ergonomics review ready: case=%s ceiling=%.2fm surfaces=%d" % [_case, _ceiling_y_m, _manager.get_surfaces().size()])
	_capture_if_requested.call_deferred()
	_report_if_requested.call_deferred()


func _resolve_case() -> String:
	var requested := case_override.to_upper()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--ergonomics-case="):
			requested = arg.trim_prefix("--ergonomics-case=").to_upper()
	return requested if requested in ["A", "B", "C"] else "A"


func _configure_local_environment() -> void:
	var environment_root := get_node_or_null("Environment") as Node3D
	if environment_root == null:
		return
	for light: Node in environment_root.find_children("*", "Light3D", true, false):
		(light as Light3D).visible = false
	var world := environment_root.get_node_or_null("GameplayEnvironment") as WorldEnvironment
	if world != null and world.environment != null:
		var local_environment := world.environment.duplicate() as Environment
		local_environment.ambient_light_energy = 0.24
		local_environment.ambient_light_color = Color(0.80, 0.79, 0.74)
		world.environment = local_environment
	_add_review_light("ReviewKey", Vector3(11.0, 2.45, -8.4), Color(1.0, 0.94, 0.84), 2.15, 9.0)
	_add_review_light("ReviewFill", Vector3(15.2, 2.35, -6.2), Color(0.88, 0.93, 1.0), 1.20, 7.0)


func _add_review_light(light_name: String, position_m: Vector3, color: Color, energy: float, range_m: float) -> void:
	var light := OmniLight3D.new()
	light.name = light_name
	light.position = position_m
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_m
	light.shadow_enabled = true
	add_child(light)


func _replace_gallery_b_ceiling() -> void:
	var roof := get_node_or_null("Environment/Greybox/RoofVisuals")
	for segment_name: String in ["Ceiling_GalleryBMain", "Ceiling_GalleryBNorthBump"]:
		var segment := roof.get_node_or_null(segment_name) if roof != null else null
		if segment != null:
			_disable_roof_segment(segment)
	_add_ceiling_slab("GalleryBLowerCeiling", GALLERY_B_CENTRE, GALLERY_B_SIZE)
	_add_ceiling_slab(
		"GalleryBNorthBumpLowerCeiling",
		Vector3(14.25, 0.0, -13.75),
		Vector3(4.50, 0.20, 1.50)
	)


func _disable_roof_segment(node: Node) -> void:
	if node is Node3D:
		(node as Node3D).visible = false
	if node is CollisionObject3D:
		var collider := node as CollisionObject3D
		collider.collision_layer = 0
		collider.collision_mask = 0
	for child: Node in node.get_children():
		_disable_roof_segment(child)


func _add_ceiling_slab(slab_name: String, centre: Vector3, size: Vector3) -> void:
	var root := Node3D.new()
	root.name = slab_name
	root.position = Vector3(centre.x, _ceiling_y_m + size.y * 0.5, centre.z)
	add_child(root)
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.40, 0.43, 0.45)
	material.roughness = 0.88
	cube.material = material
	mesh.mesh = cube
	root.add_child(mesh)
	var body := StaticBody3D.new()
	body.name = "CeilingCollision"
	root.add_child(body)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)


func _build_fixtures() -> void:
	_fixtures = Node3D.new()
	_fixtures.name = "ReviewFixtures"
	add_child(_fixtures)
	_collision_root = Node3D.new()
	_collision_root.name = "ReviewFixtureCollision"
	add_child(_collision_root)
	var y_scale := 1.0 if _case == "A" else LOWER_METAL_Y_SCALE
	_metal = MetalScene.instantiate() as Node3D
	_metal.name = "SM_MetalShelves_Ergonomics"
	_metal.position = METAL_REVIEW_POSITION
	_metal.scale = Vector3(1.0, y_scale, 1.0)
	_fixtures.add_child(_metal)
	_add_clearance_context(_metal, maxf(0.05, _ceiling_y_m - 2.86 * y_scale))

	y_scale = 1.0 if _case == "A" else LOWER_LOCKER_Y_SCALE
	_locker = LockerScene.instantiate() as Node3D
	_locker.name = "SM_ventilated_locker_Ergonomics"
	_locker.position = Vector3(13.15, 0.0, -11.90)
	_locker.scale = Vector3(1.0, y_scale, 1.0)
	_fixtures.add_child(_locker)
	_add_clearance_context(_locker, 0.519 * y_scale)

	y_scale = 1.0 if _case == "A" else LOWER_CABINET_Y_SCALE
	_cabinet = CabinetScene.instantiate() as Node3D
	_cabinet.name = "SM_ClothesCabinet_Ergonomics"
	_cabinet.position = Vector3(15.20, 0.0, -11.90)
	_cabinet.scale = Vector3(1.0, y_scale, 1.0)
	_fixtures.add_child(_cabinet)

	for fixture: Node3D in [_metal, _locker, _cabinet]:
		_add_unit_scale_collision(fixture)


func _add_clearance_context(fixture: Node3D, clearance_m: float) -> void:
	var context := ClearanceContextScript.new()
	context.name = "StorageShelfClearanceContext"
	context.open_top_clearance_world_m = clearance_m
	fixture.add_child(context)


func _add_unit_scale_collision(fixture: Node3D) -> void:
	var bounds := _global_bounds(fixture)
	if bounds.size.length_squared() <= 0.0001:
		return
	var body := StaticBody3D.new()
	body.name = "%s_ReviewCollision" % fixture.name
	_collision_root.add_child(body)
	body.global_position = bounds.get_center()
	var shape := CollisionShape3D.new()
	shape.name = "UnitScaleShape"
	var box := BoxShape3D.new()
	box.size = bounds.size
	shape.shape = box
	body.add_child(shape)


func _global_bounds(root: Node3D) -> AABB:
	var state := {"valid": false, "bounds": AABB()}
	_scan_global_bounds(root, state)
	return state["bounds"] as AABB


func _scan_global_bounds(node: Node, state: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh != null:
			var bounds := mesh_node.global_transform * mesh_node.get_aabb()
			if bool(state["valid"]):
				state["bounds"] = (state["bounds"] as AABB).merge(bounds)
			else:
				state["bounds"] = bounds
				state["valid"] = true
	for child: Node in node.get_children():
		_scan_global_bounds(child, state)


func _install_functional_storage() -> void:
	_manager = StorageManagerScript.new() as StoragePrototypeManager
	_manager.name = "ReviewStorageManager"
	_manager.configure_review(_case, _ceiling_y_m)
	_fixtures.add_child(_manager)
	_manager.install(_fixtures)
	_manager.set_process_unhandled_input(true)


func _seed_review_samples() -> void:
	var player := get_node_or_null("Player") as Node3D
	if player == null or _manager == null:
		return
	var carried := player.get_node_or_null("CarriedItems") as CarriedItems
	var controller := player.get_node_or_null("StoragePlacementController") as StoragePlacementController
	if carried == null or controller == null:
		return
	var surfaces := _manager.get_surfaces()
	# Each legal functional sample is placed by the real controller, creating a
	# reservation and WorldItem through the established storage path.
	_store_sample(carried, controller, surfaces[1] as StorageSurface, &"loot_000024")
	_store_sample(carried, controller, surfaces[2] as StorageSurface, &"loot_000030")
	_store_sample(carried, controller, surfaces[5] as StorageSurface, &"loot_000001")
	_store_sample(carried, controller, surfaces[4] as StorageSurface, &"loot_000015")


func _store_sample(carried: CarriedItems, controller: StoragePlacementController, surface: StorageSurface, item_id: StringName) -> void:
	if surface == null:
		_unfitted_samples.append(String(item_id))
		return
	var definition := load("res://data/items/definitions/%s.tres" % item_id) as ItemDefinition
	if definition == null:
		_unfitted_samples.append(String(item_id))
		return
	var item := ItemInstance.new(definition)
	if not carried.add_item(item):
		_unfitted_samples.append(String(item_id))
		return
	surface.set_zone_rect(item.get_storage_category(), Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
	var orientations: Array = controller.call("_entry_orientations_for_item", item)
	if orientations.is_empty():
		carried.remove_selected()
		_unfitted_samples.append(String(item_id))
		return
	var alternate := orientations[1] as StorageStack.Entry if orientations.size() > 1 else null
	var fit := surface.find_zone_stack_or_empty_fit(item.get_storage_category(), orientations[0] as StorageStack.Entry, alternate)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	if not controller.place_selected():
		carried.remove_selected()
		_unfitted_samples.append("%s on %s" % [item_id, surface.surface_id])
		push_warning("Shelf ergonomics review: %s does not fit %s" % [item_id, surface.surface_id])


func _install_authoritative_supply() -> void:
	var gameplay_root := WingGameplayScene.instantiate() as Node3D
	_development_setup = gameplay_root.get_node_or_null("DevelopmentSetup") as Node3D
	if _development_setup == null:
		gameplay_root.free()
		push_error("Shelf ergonomics review could not extract WingGameplay/DevelopmentSetup")
		return
	gameplay_root.remove_child(_development_setup)
	gameplay_root.free()
	add_child(_development_setup)


func _place_player_at_review_entry() -> void:
	var player := get_node_or_null("Player") as Node3D
	if player == null:
		return
	var camera := player.get_node_or_null("Camera3D") as Camera3D
	player.global_position = Vector3(12.90, 0.05, -8.65)
	if camera != null:
		camera.look_at(Vector3(13.20, 1.15, -11.90), Vector3.UP)
		player.set("_pitch", camera.rotation.x)
		_set_review_eye_height(REVIEW_EYE_HEIGHTS_M[0])


func _add_status_label() -> void:
	var layer := CanvasLayer.new()
	layer.name = "ReviewStatus"
	add_child(layer)
	var label := Label.new()
	label.position = Vector2(20, 18)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.92))
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	_status_label = label
	_refresh_status_label()
	layer.add_child(label)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F5:
		toggle_review_eye_height()
		get_viewport().set_input_as_handled()


func toggle_review_eye_height() -> void:
	var next_height := REVIEW_EYE_HEIGHTS_M[1] if is_equal_approx(_eye_height_m, REVIEW_EYE_HEIGHTS_M[0]) else REVIEW_EYE_HEIGHTS_M[0]
	_set_review_eye_height(next_height)


func _set_review_eye_height(target_height_m: float) -> void:
	var camera := get_node_or_null("Player/Camera3D") as Camera3D
	if camera == null:
		return
	var preserved_view := camera.global_transform
	preserved_view.origin.y = target_height_m
	camera.global_transform = preserved_view
	_eye_height_m = camera.global_position.y
	_refresh_status_label()


func _refresh_status_label() -> void:
	if _status_label != null:
		_status_label.text = "Shelf ergonomics review — Case %s | ceiling %.2fm | eye %.3fm (F5) | F6 grids | wing palette TAKE" % [_case, _ceiling_y_m, _eye_height_m]


func _capture_if_requested() -> void:
	if not OS.get_cmdline_user_args().has("--capture-ergonomics"):
		return
	var directory := ProjectSettings.globalize_path("res://reports/logistics_wing/shelf_ergonomics/%s" % _case.to_lower())
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		push_error("Shelf ergonomics capture could not create output directory")
		get_tree().quit(1)
		return
	var camera := get_node_or_null("Player/Camera3D") as Camera3D
	if camera == null:
		push_error("Shelf ergonomics capture has no player camera")
		get_tree().quit(1)
		return
	get_window().size = Vector2i(1920, 1080)
	var views := [
		{"name": "front", "position": Vector3(12.9, _eye_height_m, -8.65), "target": Vector3(13.2, 1.12, -11.9)},
		{"name": "right_front", "position": Vector3(14.25, _eye_height_m, -9.15), "target": Vector3(14.65, 0.82, -11.85)},
		{"name": "cabinet_front", "position": Vector3(13.85, 1.10, -11.90), "target": Vector3(15.15, 0.95, -11.90)},
	]
	for view: Dictionary in views:
		camera.global_position = view["position"] as Vector3
		camera.look_at(view["target"] as Vector3, Vector3.UP)
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		var path := directory.path_join("%s_%s.png" % [_case.to_lower(), view["name"]])
		if image == null or image.is_empty() or image.save_png(path) != OK:
			push_error("Shelf ergonomics capture could not save %s" % path)
			get_tree().quit(1)
			return
		print("ERGONOMICS_CAPTURE %s" % path)
	get_tree().quit(0)


func _report_if_requested() -> void:
	if not OS.get_cmdline_user_args().has("--report-ergonomics"):
		return
	print("ERGONOMICS_METRICS " + JSON.stringify(get_review_contract()))
	get_tree().quit(0)


func get_review_contract() -> Dictionary:
	var surfaces := _manager.get_surfaces() if _manager != null else []
	var unit_scale := true
	var locker_top := 0.0
	var metal_top := 0.0
	var stored_sample_count := 0
	var level_metrics := {}
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface == null:
			unit_scale = false
			continue
		unit_scale = unit_scale and surface.global_basis.get_scale().is_equal_approx(Vector3.ONE)
		var parent := surface.get_parent() as Node3D
		var family_name := String(parent.name) if parent != null else "unknown"
		if not level_metrics.has(family_name):
			level_metrics[family_name] = []
		(level_metrics[family_name] as Array).append({
			"surface": String(surface.surface_id),
			"y_m": snappedf(surface.global_position.y, 0.001),
			"clearance_m": snappedf(surface.stack_clearance_m, 0.001),
			"usable_m": [snappedf(surface.usable_size_m.x, 0.001), snappedf(surface.usable_size_m.y, 0.001)],
		})
		if parent == _locker:
			locker_top = maxf(locker_top, surface.global_position.y)
		if parent == _metal:
			metal_top = maxf(metal_top, surface.global_position.y)
		for stack_value: Variant in (surface.get("_stacks") as Dictionary).values():
			var stack := stack_value as StorageStack
			for entry in stack.entries:
				stored_sample_count += 1
				unit_scale = unit_scale and entry.host.global_basis.get_scale().is_equal_approx(Vector3.ONE)
	return {
		"case": _case,
		"ceiling_y_m": _ceiling_y_m,
		"functional_family_count": 2,
		"cabinet_surface_count": 0,
		"surface_count": surfaces.size(),
		"surfaces_unit_scale": unit_scale,
		"stored_sample_count": stored_sample_count,
		"cabinet_take_sample_count": 0,
		"unfitted_samples": _unfitted_samples.duplicate(),
		"level_metrics": level_metrics,
		"f6_enabled": _manager != null and _manager.is_processing_unhandled_input(),
		"f7_disabled": true,
		"locker_top_y_m": locker_top,
		"metal_top_y_m": metal_top,
		"metal_x_m": _metal.global_position.x if _metal != null else 0.0,
		"metal_z_m": _metal.global_position.z if _metal != null else 0.0,
		"eye_height_m": snappedf(_eye_height_m, 0.001),
		"eye_toggle": "F5",
	}
