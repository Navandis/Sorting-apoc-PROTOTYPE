extends Node3D

const Piece = preload("res://environment_authoring/substrate/environment_substrate_piece.gd")
const SEED_ROOT := "res://data/environment/substrate/seed/"
const CAMERA_NAMES := ["SeedOverview", "DimensionUVComparison", "OpeningDetail_LeftJamb", "OpeningDetail_RightJamb", "Composition", "ExtensibilityProof"]

var camera_index := 0
var pieces: Array[Node3D] = []


func _ready() -> void:
	_configure_environment()
	_configure_lighting()
	_build_review()
	_configure_cameras()
	set_camera_index(0)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			set_camera_index(camera_index + 1)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_R or event.keycode == KEY_HOME:
			set_camera_index(0)
			get_viewport().set_input_as_handled()


func set_camera_index(index: int) -> void:
	camera_index = posmod(index, CAMERA_NAMES.size())
	for piece in pieces:
		piece.visible = _visible_in_view(piece.name, camera_index)
		(piece.get_node("Label") as Label3D).visible = camera_index != 4
	get_active_camera().make_current()
	var label := get_node_or_null("ReviewHUD/Label") as Label
	if label != null:
		label.text = "EAF2 STRUCTURAL SUBSTRATE  |  " + CAMERA_NAMES[camera_index] + "\nC next view    R reset    Red/blue grid edges = 1 m repeat"


func _visible_in_view(piece_name: String, view: int) -> bool:
	match view:
		0: return true
		1: return piece_name.begins_with("wall_")
		2, 3: return piece_name == "asymmetric_opening"
		4: return piece_name.begins_with("composition_")
		5: return piece_name == "two_opening_extension"
	return false


func get_active_camera() -> Camera3D:
	return get_node("Cameras/%s" % CAMERA_NAMES[camera_index]) as Camera3D


func get_capture_records() -> Array:
	var records := []
	for index in CAMERA_NAMES.size():
		records.append({"camera_index": index, "camera": CAMERA_NAMES[index], "filename": CAMERA_NAMES[index].to_snake_case() + ".png"})
	return records


func generation_records() -> Array:
	var result := []
	for piece in pieces:
		result.append({"piece_id": piece.piece_spec.piece_id, "root_scale": _v3(piece.scale), "transform_origin": _v3(piece.position), "rotation_y": piece.rotation.y, "metadata": piece.generation_metadata})
	return result


func _build_review() -> void:
	# Each item is a generated substrate piece. The review scene is dev tooling only.
	_add("wall_standard", "wall_short_2m", Vector3(2.0, 3.2, 0.30), Vector3(-6.6, 1.6, -4.5), 0.0)
	_add("wall_standard", "wall_long_7_35m", Vector3(7.35, 3.2, 0.30), Vector3(-0.7, 1.6, -4.5), 0.0)
	_add("wall_standard", "wall_thin", Vector3(1.8, 3.2, 0.15), Vector3(5.0, 1.6, -4.5), 0.0)
	_add("wall_standard", "wall_thick", Vector3(1.8, 3.2, 0.45), Vector3(7.6, 1.6, -4.5), 0.0)
	_add("floor_slab", "floor_slab", Vector3(2.5, 0.18, 2.5), Vector3(-7.0, 0.09, 1.5), 0.0)
	_add("ceiling_slab", "ceiling_slab", Vector3(2.5, 0.20, 2.5), Vector3(-3.8, 3.1, 1.5), 0.0)
	_add("beam_standard", "beam", Vector3(2.8, 0.35, 0.35), Vector3(-0.35, 2.8, 1.5), 0.0)
	_add("column_standard", "column", Vector3(0.42, 3.0, 0.42), Vector3(2.4, 1.5, 1.5), 0.0)
	_add("threshold_standard", "threshold", Vector3(1.4, 0.08, 0.45), Vector3(4.1, 0.04, 1.5), 0.0)
	_add("opening_return_standard", "opening_return", Vector3(0.30, 3.2, 0.55), Vector3(6.2, 1.6, 1.5), 0.0)
	_add("wall_opening_standard", "asymmetric_opening", Vector3(5.5, 3.2, 0.30), Vector3(-5.3, 1.6, 8.0), 0.0)
	_add("wall_standard", "composition_wall_front", Vector3(3.2, 3.2, 0.30), Vector3(2.3, 1.6, 8.0), 0.0)
	_add("wall_standard", "composition_wall_side", Vector3(3.2, 3.2, 0.30), Vector3(4.05, 1.6, 9.45), PI * 0.5)
	_add("column_standard", "composition_column", Vector3(0.42, 3.2, 0.42), Vector3(3.78, 1.6, 8.27), 0.0)
	_add("beam_standard", "composition_beam", Vector3(3.08, 0.35, 0.35), Vector3(2.24, 3.025, 8.14), 0.0)
	_add("threshold_standard", "composition_threshold", Vector3(1.4, 0.08, 0.45), Vector3(2.3, 0.04, 8.375), 0.0)
	_add("wall_two_openings_extension", "two_opening_extension", Vector3(7.0, 3.2, 0.30), Vector3(0.0, 1.6, -12.0), 0.0)


func _add(seed_name: String, id: String, dimensions: Vector3, position_m: Vector3, yaw: float) -> void:
	var source := load(SEED_ROOT + seed_name + ".tres") as Resource
	var spec: Resource = source.duplicate()
	spec.piece_id = id
	spec.dimensions_m = dimensions
	var piece := Piece.new() as Node3D
	piece.name = id
	piece.piece_spec = spec
	piece.position = position_m
	piece.rotation.y = yaw
	(get_node("ReviewGeometry") as Node3D).add_child(piece)
	if not piece.regenerate():
		push_error("Review piece did not regenerate: " + id)
	pieces.append(piece)
	var label := Label3D.new()
	label.name = "Label"
	label.text = id.replace("_", " ") + "\n" + ("%0.2f × %0.2f × %0.2f m" % [dimensions.x, dimensions.y, dimensions.z])
	label.position = Vector3(0.0, dimensions.y * 0.5 + 0.32, 0.0)
	label.font_size = 26
	label.pixel_size = 0.0035
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	piece.add_child(label)


func _configure_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.18, 0.20, 0.22)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.80, 0.82)
	environment.ambient_light_energy = 0.34
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.0
	(get_node("WorldEnvironment") as WorldEnvironment).environment = environment


func _configure_lighting() -> void:
	var key := get_node("WhiteKey") as DirectionalLight3D
	key.rotation_degrees = Vector3(-45, -35, 0)
	key.light_color = Color.WHITE
	key.light_energy = 0.9
	key.shadow_enabled = true
	var fill := get_node("WhiteFill") as OmniLight3D
	fill.position = Vector3(0, 8, 2)
	fill.light_color = Color.WHITE
	fill.light_energy = 0.7
	fill.omni_range = 35.0


func _configure_cameras() -> void:
	_camera("SeedOverview", Vector3(2, 16, 19), Vector3(-0.3, 1.4, -1.0), 55.0)
	_camera("DimensionUVComparison", Vector3(-0.2, 5.1, 4.7), Vector3(-0.1, 1.6, -4.5), 68.0)
	_camera("OpeningDetail_LeftJamb", Vector3(-3.3, 3.2, 12.3), Vector3(-5.3, 1.6, 8.0), 54.0)
	_camera("OpeningDetail_RightJamb", Vector3(-7.3, 3.2, 12.3), Vector3(-5.3, 1.6, 8.0), 54.0)
	_camera("Composition", Vector3(1.2, 4.1, 13.2), Vector3(2.7, 1.5, 9.0), 54.0)
	_camera("ExtensibilityProof", Vector3(1.0, 4.0, -5.6), Vector3(0, 1.6, -12.0), 62.0)


func _camera(name: String, location: Vector3, target: Vector3, field_of_view: float) -> void:
	var camera := get_node("Cameras/" + name) as Camera3D
	camera.position = location
	camera.fov = field_of_view
	camera.look_at(target, Vector3.UP)


func _v3(value: Vector3) -> Array:
	return [value.x, value.y, value.z]
