extends Node3D

const MaterialBuilder = preload("res://environment_authoring/environment_material_builder.gd")
const REVIEW_SET = preload("res://data/environment/lookdev/eaf1_review_set.tres")
const CAMERA_NAMES := ["Hero", "WallGrazing", "FloorGrazing", "Context"]
const LIGHT_NAMES := ["NEUTRAL_CALIBRATION", "RECEIVING_TARGET_PREVIEW"]
const REVIEW_SURFACES := ["Wall_A", "Wall_B_90Deg", "Floor", "Ceiling", "Column", "BeveledBlock"]

var material_index := 0
var light_mode := 0
var camera_index := 0
var _active_material: StandardMaterial3D
var _builder := MaterialBuilder.new()


func _ready() -> void:
	if not REVIEW_SET.validate().is_empty():
		push_error("Invalid EAF1 review set: %s" % str(REVIEW_SET.validate()))
		return
	_build_geometry()
	_configure_environment()
	_configure_cameras()
	_configure_lights()
	reset_review()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_L:
			toggle_light_mode()
		KEY_N, KEY_BRACKETRIGHT:
			next_material()
		KEY_P, KEY_BRACKETLEFT:
			previous_material()
		KEY_C:
			next_camera()
		KEY_R, KEY_HOME:
			reset_review()
		_:
			return
	get_viewport().set_input_as_handled()


func set_material_index(index: int) -> void:
	material_index = REVIEW_SET.wrapped_index(index)
	var spec: Resource = REVIEW_SET.get_spec(material_index)
	_active_material = _builder.build(spec)
	for surface_name in REVIEW_SURFACES:
		var mesh := get_node("ReviewGeometry/%s" % surface_name) as MeshInstance3D
		mesh.material_override = _active_material
	_update_hud()


func next_material() -> void:
	set_material_index(material_index + 1)


func previous_material() -> void:
	set_material_index(material_index - 1)


func set_light_mode(index: int) -> void:
	light_mode = posmod(index, LIGHT_NAMES.size())
	var neutral := get_node("NeutralLightingRig") as Node3D
	var receiving := get_node("ReceivingTargetLightingRig") as Node3D
	neutral.visible = light_mode == 0
	receiving.visible = light_mode == 1
	for rig in [neutral, receiving]:
		for child in rig.get_children():
			if child is Light3D:
				child.visible = rig.visible
	_update_hud()


func toggle_light_mode() -> void:
	set_light_mode(light_mode + 1)


func set_camera_index(index: int) -> void:
	camera_index = posmod(index, CAMERA_NAMES.size())
	get_active_camera().make_current()
	_update_hud()


func next_camera() -> void:
	set_camera_index(camera_index + 1)


func reset_review() -> void:
	set_material_index(0)
	set_light_mode(0)
	set_camera_index(0)


func get_camera_name() -> String:
	return CAMERA_NAMES[camera_index]


func get_active_camera() -> Camera3D:
	return get_node("Cameras/%s" % get_camera_name()) as Camera3D


func get_active_material() -> StandardMaterial3D:
	return _active_material


func get_active_spec() -> Resource:
	return REVIEW_SET.get_spec(material_index)


func geometry_snapshot() -> Dictionary:
	var result := {}
	for surface_name in REVIEW_SURFACES:
		result[surface_name] = (get_node("ReviewGeometry/%s" % surface_name) as Node3D).transform
	return result


func light_settings() -> Array:
	var rig := get_node("NeutralLightingRig" if light_mode == 0 else "ReceivingTargetLightingRig")
	var settings := []
	for child in rig.get_children():
		if child is Light3D:
			var forward: Vector3 = -(child as Light3D).global_transform.basis.z.normalized()
			var item := {
				"name": child.name,
				"type": child.get_class(),
				"position": [child.position.x, child.position.y, child.position.z],
				"direction": [forward.x, forward.y, forward.z],
				"color": child.light_color.to_html(),
				"energy": child.light_energy,
				"shadow": child.shadow_enabled,
			}
			if child is SpotLight3D:
				item["range"] = child.spot_range
				item["angle"] = child.spot_angle
			elif child is OmniLight3D:
				item["range"] = child.omni_range
			settings.append(item)
	return settings


func _build_geometry() -> void:
	var review := get_node("ReviewGeometry") as Node3D
	_add_box(review, "Floor", Vector3(4.8, 0.12, 4.8), Vector3(0, -0.06, 0))
	_add_box(review, "Wall_A", Vector3(4.8, 3.0, 0.12), Vector3(0, 1.5, -2.4))
	_add_box(review, "Wall_B_90Deg", Vector3(0.12, 3.0, 4.8), Vector3(-2.4, 1.5, 0))
	_add_box(review, "Ceiling", Vector3(4.8, 0.12, 2.6), Vector3(0, 3.0, -1.1))
	_add_box(review, "Column", Vector3(0.42, 2.7, 0.42), Vector3(1.7, 1.35, -1.7))
	var block := MeshInstance3D.new()
	block.name = "BeveledBlock"
	block.mesh = _box_mesh(Vector3(0.95, 0.95, 0.95), 0.08)
	block.position = Vector3(0.55, 0.475, 0.15)
	review.add_child(block)
	var shadow := get_node("ShadowStructure") as Node3D
	var neutral_dark := _plain_material(Color(0.28, 0.29, 0.30))
	_add_box(shadow, "OverheadBeam", Vector3(4.25, 0.32, 0.30), Vector3(0.15, 2.56, -0.52), neutral_dark)
	_add_box(shadow, "PartialReturn", Vector3(0.14, 2.5, 1.25), Vector3(2.32, 1.25, -1.45), neutral_dark)
	_build_references(review.get_node("ReferenceObjects") as Node3D)


func _build_references(parent: Node3D) -> void:
	var colors := [Color(0.5, 0.5, 0.5), Color(0.9, 0.9, 0.9), Color(0.08, 0.08, 0.08)]
	var names := ["MiddleGrey", "White", "Dark"]
	for index in 3:
		var sphere := MeshInstance3D.new()
		sphere.name = names[index]
		var sphere_mesh := SphereMesh.new()
		sphere_mesh.radius = 0.19
		sphere_mesh.height = 0.38
		sphere.mesh = sphere_mesh
		sphere.position = Vector3(-1.75 + index * 0.48, 0.24, 1.45)
		sphere.material_override = _plain_material(colors[index])
		parent.add_child(sphere)
	for segment in 4:
		_add_box(parent, "Ruler_%d" % segment, Vector3(0.09, 0.25, 0.09), Vector3(1.88, 0.125 + segment * 0.25, 1.56), _plain_material(Color(0.88, 0.88, 0.88) if segment % 2 == 0 else Color(0.08, 0.08, 0.08)))
	var label := Label3D.new()
	label.name = "OneMetreLabel"
	label.text = "1 m"
	label.font_size = 30
	label.pixel_size = 0.005
	label.position = Vector3(1.88, 1.13, 1.56)
	parent.add_child(label)


func _add_box(parent: Node3D, name: String, size: Vector3, location: Vector3, material: Material = null) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = name
	node.mesh = _box_mesh(size)
	node.position = location
	node.material_override = material
	parent.add_child(node)
	return node


func _box_mesh(size: Vector3, bevel: float = 0.0) -> ArrayMesh:
	var x := size.x * 0.5
	var y := size.y * 0.5
	var z := size.z * 0.5
	var faces := [
		[Vector3(-x,-y,z), Vector3(x,-y,z), Vector3(x,y,z), Vector3(-x,y,z)],
		[Vector3(x,-y,-z), Vector3(-x,-y,-z), Vector3(-x,y,-z), Vector3(x,y,-z)],
		[Vector3(x,-y,z), Vector3(x,-y,-z), Vector3(x,y,-z), Vector3(x,y,z)],
		[Vector3(-x,-y,-z), Vector3(-x,-y,z), Vector3(-x,y,z), Vector3(-x,y,-z)],
		[Vector3(-x,y,z), Vector3(x,y,z), Vector3(x,y,-z), Vector3(-x,y,-z)],
		[Vector3(-x,-y,-z), Vector3(x,-y,-z), Vector3(x,-y,z), Vector3(-x,-y,z)],
	]
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in faces:
		var a: Vector3 = face[0]
		var b: Vector3 = face[1]
		var d: Vector3 = face[3]
		var width := a.distance_to(b)
		var height := a.distance_to(d)
		var u_steps := [0.0, width] if bevel == 0.0 else [0.0, bevel, width - bevel, width]
		var v_steps := [0.0, height] if bevel == 0.0 else [0.0, bevel, height - bevel, height]
		for vi in v_steps.size() - 1:
			for ui in u_steps.size() - 1:
				var u0: float = u_steps[ui]
				var u1: float = u_steps[ui + 1]
				var v0: float = v_steps[vi]
				var v1: float = v_steps[vi + 1]
				var axis_u := (b - a).normalized()
				var axis_v := (d - a).normalized()
				var p0 := _bevel_point(a + axis_u * u0 + axis_v * v0, size, bevel)
				var p1 := _bevel_point(a + axis_u * u1 + axis_v * v0, size, bevel)
				var p2 := _bevel_point(a + axis_u * u1 + axis_v * v1, size, bevel)
				var p3 := _bevel_point(a + axis_u * u0 + axis_v * v1, size, bevel)
				_quad(tool, p0, p1, p2, p3, Vector2(u0, v0), Vector2(u1, v1))
	tool.generate_normals()
	tool.generate_tangents()
	return tool.commit()


func _bevel_point(point: Vector3, size: Vector3, bevel: float) -> Vector3:
	if bevel <= 0.0:
		return point
	var inset := size * 0.5 - Vector3.ONE * bevel
	var core := Vector3(clampf(point.x, -inset.x, inset.x), clampf(point.y, -inset.y, inset.y), clampf(point.z, -inset.z, inset.z))
	return core + (point - core).normalized() * bevel


func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, uv0: Vector2, uv1: Vector2) -> void:
	var corners := [a, b, c, a, c, d]
	var uvs := [uv0, Vector2(uv1.x, uv0.y), uv1, uv0, uv1, Vector2(uv0.x, uv1.y)]
	for i in 6:
		tool.set_uv(uvs[i])
		tool.add_vertex(corners[i])


func _plain_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	return material


func _configure_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.052, 0.056, 0.06)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.74, 0.75, 0.76)
	environment.ambient_light_energy = 0.16
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.0
	(get_node("WorldEnvironment") as WorldEnvironment).environment = environment


func _configure_cameras() -> void:
	_set_camera("Hero", Vector3(4.9, 3.22, 4.95), Vector3(-0.2, 1.38, -0.44), 53.0)
	_set_camera("WallGrazing", Vector3(1.95, 1.62, 1.85), Vector3(-0.84, 1.52, -2.32), 51.0)
	_set_camera("FloorGrazing", Vector3(0.55, 0.68, 2.26), Vector3(-0.10, 0.16, -1.40), 55.0)
	_set_camera("Context", Vector3(7.0, 5.1, 6.8), Vector3(0.0, 1.20, -0.45), 58.0)


func _set_camera(name: String, location: Vector3, target: Vector3, field_of_view: float) -> void:
	var camera := get_node("Cameras/%s" % name) as Camera3D
	camera.position = location
	camera.fov = field_of_view
	camera.look_at(target, Vector3.UP)


func _configure_lights() -> void:
	var neutral_key := get_node("NeutralLightingRig/WhiteKey") as SpotLight3D
	neutral_key.position = Vector3(1.1, 2.45, 1.45)
	neutral_key.look_at(Vector3(-0.55, 1.05, -1.55), Vector3.UP)
	var neutral_fill := get_node("NeutralLightingRig/WhiteFill") as OmniLight3D
	neutral_fill.position = Vector3(-1.35, 2.05, 0.8)
	var neutral_graze := get_node("NeutralLightingRig/WhiteGraze") as SpotLight3D
	neutral_graze.position = Vector3(1.8, 2.15, -1.3)
	neutral_graze.look_at(Vector3(-1.65, 1.42, -2.33), Vector3.UP)
	var warm_key := get_node("ReceivingTargetLightingRig/WarmPracticalKey") as SpotLight3D
	warm_key.position = Vector3(0.62, 2.48, 1.08)
	warm_key.look_at(Vector3(-0.42, 0.72, -1.05), Vector3.UP)
	var warm_side := get_node("ReceivingTargetLightingRig/WarmSidePool") as OmniLight3D
	warm_side.position = Vector3(-1.82, 1.86, -0.45)
	var support := get_node("ReceivingTargetLightingRig/NeutralWarmSupport") as SpotLight3D
	support.position = Vector3(1.96, 2.15, -0.92)
	support.look_at(Vector3(-1.0, 1.62, -2.32), Vector3.UP)


func _update_hud() -> void:
	var label := get_node_or_null("ReviewHUD/Panel/Label") as Label
	if label == null or _active_material == null:
		return
	var spec: Resource = get_active_spec()
	label.text = "EAF1 MATERIAL LOOKDEV\nMaterial: %s\nLighting: %s\nCamera: %s\nMapping: %s\nScale: %.2f m / repeat\nNormal Y: %s\n\nL light   N / ] next   P / [ previous\nC camera   R / Home reset" % [spec.display_name, LIGHT_NAMES[light_mode], get_camera_name(), spec.mapping_name(), spec.meters_per_repeat, "FLIPPED" if spec.normal_y_flip else "SOURCE"]
