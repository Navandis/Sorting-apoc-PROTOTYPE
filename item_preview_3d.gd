extends SubViewportContainer
class_name ItemPreview3D

## Live 3D item preview used by the carried-items HUD.
## Each slot owns a small isolated SubViewport. The actual item GLB is
## instantiated into that viewport, auto-oriented from its mesh bounds, and
## framed with an orthographic camera.

@export var preview_size: Vector2i = Vector2i(106, 80)

# Shape heuristics for automatic presentation. Long objects (rifles, hammers,
# rackets) are laid horizontally; flat/slab objects (boxes, books) present
# their broad face while keeping the longest broad-face axis vertical.
const ELONGATED_RATIO: float = 2.0
const FLAT_RATIO: float = 1.8
const FRAME_MARGIN: float = 1.16

var _viewport: SubViewport
var _orientation_root: Node3D
var _center_root: Node3D
var _camera: Camera3D
var _current_visual: Node
var _bounds: AABB = AABB()
var _bounds_valid: bool = false
var _pending_item: RefCounted = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_configure_transparent_compositing()
	custom_minimum_size = Vector2(preview_size)
	stretch = true
	_build_preview_world()
	if _pending_item != null:
		_apply_item(_pending_item)


func set_item(item) -> void:
	_pending_item = item
	if not is_node_ready():
		return
	_apply_item(item)


func _apply_item(item) -> void:
	_clear_visual()

	if item == null or not item.has_method("get_visual_scene"):
		return

	var visual_scene: PackedScene = item.get_visual_scene() as PackedScene
	if visual_scene == null:
		return

	_current_visual = visual_scene.instantiate()
	_center_root.add_child(_current_visual)

	_bounds = AABB()
	_bounds_valid = false
	_scan_mesh_bounds(_current_visual, Transform3D.IDENTITY)

	if not _bounds_valid:
		return

	var center: Vector3 = _bounds.position + (_bounds.size * 0.5)
	_center_root.position = -center

	var auto_orient: bool = true
	var preview_rotation: Vector3 = Vector3.ZERO
	var preview_zoom: float = 1.0

	if item.has_method("get_preview_auto_orient"):
		auto_orient = item.get_preview_auto_orient()
	if item.has_method("get_preview_rotation_degrees"):
		preview_rotation = item.get_preview_rotation_degrees()
	if item.has_method("get_preview_zoom"):
		preview_zoom = item.get_preview_zoom()

	var base_basis: Basis = Basis.IDENTITY
	if auto_orient:
		base_basis = _make_auto_orientation_basis(_bounds.size)

	var correction_radians: Vector3 = Vector3(
		deg_to_rad(preview_rotation.x),
		deg_to_rad(preview_rotation.y),
		deg_to_rad(preview_rotation.z)
	)
	var correction_basis: Basis = Basis.from_euler(correction_radians)
	var final_basis: Basis = correction_basis * base_basis
	_orientation_root.basis = final_basis.orthonormalized()

	_frame_camera(_bounds.size, _orientation_root.basis, preview_zoom)



func _configure_transparent_compositing() -> void:
	# Transparent SubViewport textures are premultiplied-alpha render targets.
	# Godot's default CanvasItem blend mode assumes straight alpha, which can
	# visibly alter the underlying scene as soon as the viewport becomes visible.
	# Use the matching premultiplied-alpha blend mode for correct compositing.
	var canvas_material: CanvasItemMaterial = CanvasItemMaterial.new()
	canvas_material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	canvas_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = canvas_material

func _build_preview_world() -> void:
	_viewport = SubViewport.new()
	_viewport.name = "PreviewViewport"
	_viewport.size = preview_size
	_viewport.transparent_bg = true
	_viewport.own_world_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.msaa_3d = Viewport.MSAA_2X
	add_child(_viewport)

	_orientation_root = Node3D.new()
	_orientation_root.name = "OrientationRoot"
	_viewport.add_child(_orientation_root)

	_center_root = Node3D.new()
	_center_root.name = "CenterRoot"
	_orientation_root.add_child(_center_root)

	_camera = Camera3D.new()
	_camera.name = "PreviewCamera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.near = 0.01
	_camera.far = 100.0
	_camera.current = true
	_viewport.add_child(_camera)

	var key_light: DirectionalLight3D = DirectionalLight3D.new()
	key_light.name = "KeyLight"
	key_light.light_energy = 1.35
	key_light.rotation_degrees = Vector3(-35.0, -35.0, 0.0)
	_viewport.add_child(key_light)

	var fill_light: DirectionalLight3D = DirectionalLight3D.new()
	fill_light.name = "FillLight"
	fill_light.light_energy = 0.65
	fill_light.rotation_degrees = Vector3(25.0, 145.0, 0.0)
	_viewport.add_child(fill_light)

	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.75, 0.78, 1.0)
	environment.ambient_light_energy = 0.55

	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.name = "PreviewEnvironment"
	world_environment.environment = environment
	_viewport.add_child(world_environment)


func _clear_visual() -> void:
	if _current_visual != null and is_instance_valid(_current_visual):
		_current_visual.queue_free()
	_current_visual = null
	if _center_root != null:
		_center_root.position = Vector3.ZERO
	if _orientation_root != null:
		_orientation_root.basis = Basis.IDENTITY


func _scan_mesh_bounds(node: Node, accumulated_transform: Transform3D) -> void:
	var next_transform: Transform3D = accumulated_transform
	if node is Node3D:
		var node_3d: Node3D = node as Node3D
		next_transform = accumulated_transform * node_3d.transform

	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh != null:
			var transformed_bounds: AABB = next_transform * mesh_instance.get_aabb()
			if _bounds_valid:
				_bounds = _bounds.merge(transformed_bounds)
			else:
				_bounds = transformed_bounds
				_bounds_valid = true

	for child_node in node.get_children():
		_scan_mesh_bounds(child_node, next_transform)


func _make_auto_orientation_basis(model_size: Vector3) -> Basis:
	var axis_order: Array[int] = [0, 1, 2]

	# Sort axis indices from largest dimension to smallest without Variant-heavy
	# helpers; the project treats warnings as errors.
	for i in range(axis_order.size() - 1):
		for j in range(i + 1, axis_order.size()):
			var size_i: float = _axis_size(model_size, axis_order[i])
			var size_j: float = _axis_size(model_size, axis_order[j])
			if size_j > size_i:
				var temp_axis: int = axis_order[i]
				axis_order[i] = axis_order[j]
				axis_order[j] = temp_axis

	var largest_axis: int = axis_order[0]
	var middle_axis: int = axis_order[1]
	var smallest_axis: int = axis_order[2]

	var largest_size: float = maxf(_axis_size(model_size, largest_axis), 0.0001)
	var middle_size: float = maxf(_axis_size(model_size, middle_axis), 0.0001)
	var smallest_size: float = maxf(_axis_size(model_size, smallest_axis), 0.0001)

	var largest_to_middle: float = largest_size / middle_size
	var middle_to_smallest: float = middle_size / smallest_size

	var horizontal_axis: int = 0
	var vertical_axis: int = 1
	var depth_axis: int = 2

	if largest_to_middle >= ELONGATED_RATIO:
		# Long tools/weapons: recognizable long axis is horizontal.
		horizontal_axis = largest_axis
		vertical_axis = middle_axis
		depth_axis = smallest_axis
	elif middle_to_smallest >= FLAT_RATIO:
		# Broad/flat items: show the broad face and keep it upright.
		horizontal_axis = middle_axis
		vertical_axis = largest_axis
		depth_axis = smallest_axis
	else:
		# Ordinary volumetric items (cans/bottles): preserve source Y as up.
		vertical_axis = 1
		if model_size.x >= model_size.z:
			horizontal_axis = 0
			depth_axis = 2
		else:
			horizontal_axis = 2
			depth_axis = 0

	return _basis_for_axis_mapping(horizontal_axis, vertical_axis, depth_axis)


func _basis_for_axis_mapping(horizontal_axis: int, vertical_axis: int, depth_axis: int) -> Basis:
	var targets: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO, Vector3.ZERO]
	targets[horizontal_axis] = Vector3.RIGHT
	targets[vertical_axis] = Vector3.UP
	targets[depth_axis] = Vector3.BACK

	var result: Basis = Basis(targets[0], targets[1], targets[2])
	if result.determinant() < 0.0:
		# Avoid introducing a mirrored basis. Which side faces the camera is not
		# important for the automatic pass, so flip only the depth axis.
		targets[depth_axis] = -targets[depth_axis]
		result = Basis(targets[0], targets[1], targets[2])

	return result.orthonormalized()


func _axis_size(model_size: Vector3, axis: int) -> float:
	match axis:
		0:
			return absf(model_size.x)
		1:
			return absf(model_size.y)
		_:
			return absf(model_size.z)


func _frame_camera(model_size: Vector3, orientation: Basis, zoom_multiplier: float) -> void:
	var half_size: Vector3 = model_size * 0.5
	var max_x: float = 0.0
	var max_y: float = 0.0

	# Calculate the projected XY extents after preview orientation. This frames
	# long/flat objects much more tightly than using the largest raw AABB axis.
	for x_index in range(2):
		var x_sign: float = -1.0 if x_index == 0 else 1.0
		for y_index in range(2):
			var y_sign: float = -1.0 if y_index == 0 else 1.0
			for z_index in range(2):
				var z_sign: float = -1.0 if z_index == 0 else 1.0
				var corner: Vector3 = Vector3(
					half_size.x * x_sign,
					half_size.y * y_sign,
					half_size.z * z_sign
				)
				var oriented_corner: Vector3 = orientation * corner
				max_x = maxf(max_x, absf(oriented_corner.x))
				max_y = maxf(max_y, absf(oriented_corner.y))

	var projected_width: float = maxf(max_x * 2.0, 0.01)
	var projected_height: float = maxf(max_y * 2.0, 0.01)
	var aspect: float = float(preview_size.x) / maxf(float(preview_size.y), 1.0)
	var required_vertical_size: float = maxf(projected_height, projected_width / aspect)
	var safe_zoom: float = maxf(zoom_multiplier, 0.1)

	_camera.size = (required_vertical_size * FRAME_MARGIN) / safe_zoom

	var largest_dimension: float = maxf(model_size.x, maxf(model_size.y, model_size.z))
	largest_dimension = maxf(largest_dimension, 0.05)
	_camera.position = Vector3(0.0, 0.0, largest_dimension * 3.0)
	_camera.look_at(Vector3.ZERO, Vector3.UP)
