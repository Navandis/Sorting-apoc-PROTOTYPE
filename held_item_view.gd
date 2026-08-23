extends Node3D
class_name HeldItemView

## Camera-attached visual representation of the currently selected carried item.
## This is not a physics object and has no gameplay collision.

const ELONGATED_RATIO: float = 2.0
const FLAT_RATIO: float = 1.8

var _orientation_root: Node3D
var _center_root: Node3D
var _current_visual: Node
var _pending_item: RefCounted = null
var _bounds: AABB = AABB()
var _bounds_valid: bool = false


func _ready() -> void:
	_orientation_root = Node3D.new()
	_orientation_root.name = "OrientationRoot"
	add_child(_orientation_root)

	_center_root = Node3D.new()
	_center_root.name = "CenterRoot"
	_orientation_root.add_child(_center_root)

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
	_disable_embedded_gameplay_nodes(_current_visual)

	_bounds = AABB()
	_bounds_valid = false
	_scan_mesh_bounds(_current_visual, Transform3D.IDENTITY)
	if not _bounds_valid:
		return

	var center: Vector3 = _bounds.position + (_bounds.size * 0.5)
	_center_root.position = -center

	var auto_orient: bool = true
	var held_rotation: Vector3 = Vector3(-10.0, -18.0, -8.0)
	var held_offset: Vector3 = Vector3(0.28, -0.24, -0.58)
	var held_max_dimension: float = 0.55

	if item.has_method("get_held_auto_orient"):
		auto_orient = bool(item.get_held_auto_orient())
	if item.has_method("get_held_rotation_degrees"):
		held_rotation = item.get_held_rotation_degrees()
	if item.has_method("get_held_offset"):
		held_offset = item.get_held_offset()
	if item.has_method("get_held_max_dimension"):
		held_max_dimension = float(item.get_held_max_dimension())

	var base_basis: Basis = Basis.IDENTITY
	if auto_orient:
		base_basis = _make_auto_orientation_basis(_bounds.size)

	var correction_radians: Vector3 = Vector3(
		deg_to_rad(held_rotation.x),
		deg_to_rad(held_rotation.y),
		deg_to_rad(held_rotation.z)
	)
	var correction_basis: Basis = Basis.from_euler(correction_radians)
	_orientation_root.basis = (correction_basis * base_basis).orthonormalized()

	var largest_dimension: float = maxf(_bounds.size.x, maxf(_bounds.size.y, _bounds.size.z))
	var scale_factor: float = 1.0
	if largest_dimension > held_max_dimension and largest_dimension > 0.0001:
		scale_factor = held_max_dimension / largest_dimension
	_orientation_root.scale = Vector3.ONE * scale_factor
	position = held_offset


func _clear_visual() -> void:
	if _current_visual != null and is_instance_valid(_current_visual):
		_current_visual.queue_free()
	_current_visual = null
	if _center_root != null:
		_center_root.position = Vector3.ZERO
	if _orientation_root != null:
		_orientation_root.basis = Basis.IDENTITY
		_orientation_root.scale = Vector3.ONE


func _disable_embedded_gameplay_nodes(node: Node) -> void:
	if node is CollisionObject3D:
		var collision_object: CollisionObject3D = node as CollisionObject3D
		collision_object.collision_layer = 0
		collision_object.collision_mask = 0
	if node is Camera3D:
		var embedded_camera: Camera3D = node as Camera3D
		embedded_camera.current = false
	if node is Light3D:
		var embedded_light: Light3D = node as Light3D
		embedded_light.visible = false

	for child in node.get_children():
		_disable_embedded_gameplay_nodes(child)


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

	for child in node.get_children():
		_scan_mesh_bounds(child, next_transform)


func _make_auto_orientation_basis(model_size: Vector3) -> Basis:
	var axis_order: Array[int] = [0, 1, 2]

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
		horizontal_axis = largest_axis
		vertical_axis = middle_axis
		depth_axis = smallest_axis
	elif middle_to_smallest >= FLAT_RATIO:
		horizontal_axis = middle_axis
		vertical_axis = largest_axis
		depth_axis = smallest_axis
	else:
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
