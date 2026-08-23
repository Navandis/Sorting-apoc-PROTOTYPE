extends SubViewportContainer
class_name ItemPreview3D

## Live 3D item preview used by the carried-items HUD.
## Each slot owns a very small isolated SubViewport. The actual item GLB is
## instantiated into that viewport and auto-framed from its mesh bounds.

@export var preview_size: Vector2i = Vector2i(96, 62)

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
	custom_minimum_size = Vector2(preview_size)
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

	var preview_rotation: Vector3 = Vector3(-15.0, 35.0, 0.0)
	var preview_zoom: float = 1.0
	if item.has_method("get_preview_rotation_degrees"):
		preview_rotation = item.get_preview_rotation_degrees()
	if item.has_method("get_preview_zoom"):
		preview_zoom = item.get_preview_zoom()

	_orientation_root.rotation_degrees = preview_rotation
	_frame_camera(_bounds.size, preview_zoom)


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
		_orientation_root.rotation = Vector3.ZERO


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


func _frame_camera(model_size: Vector3, zoom_multiplier: float) -> void:
	var largest_dimension: float = maxf(model_size.x, maxf(model_size.y, model_size.z))
	largest_dimension = maxf(largest_dimension, 0.05)

	var safe_zoom: float = maxf(zoom_multiplier, 0.1)
	_camera.size = (largest_dimension * 1.55) / safe_zoom
	_camera.position = Vector3(0.0, 0.0, largest_dimension * 3.0)
	_camera.look_at(Vector3.ZERO, Vector3.UP)
