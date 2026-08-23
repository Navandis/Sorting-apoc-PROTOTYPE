extends Node3D
class_name WorldItem

## Runtime component attached to a prototype loot visual already placed in the
## scene. It adds a simple interaction collider and owns the ItemInstance that
## moves into the carried-item strip when picked up.

const ItemInstanceScript = preload("res://item_instance.gd")

# Dedicated loot interaction layer (Godot layer 8 / bit 7).
# Player pickup rays query only this layer so coarse shelf/furniture movement
# colliders do not block interaction with loot resting on storage surfaces.
const PICKUP_COLLISION_LAYER: int = 1 << 7

var _host: Node3D
var _definition: ItemDefinition
var _item_instance: ItemInstance
var _interaction_area: Area3D
var _bounds: AABB = AABB()
var _bounds_valid: bool = false
var _storage_surface: Node = null
var _storage_key: String = ""


func configure(host: Node3D, definition: ItemDefinition) -> void:
	_host = host
	_definition = definition
	_item_instance = ItemInstanceScript.new(definition)
	_build_interaction_area()


func configure_existing(
	host: Node3D,
	item_instance: ItemInstance,
	storage_surface: Node = null,
	storage_key: String = ""
) -> void:
	## Reuses the exact carried ItemInstance when it is placed on a shelf.
	_host = host
	_item_instance = item_instance
	_definition = item_instance.definition if item_instance != null else null
	_storage_surface = storage_surface
	_storage_key = storage_key
	_build_interaction_area()


func get_item_instance() -> ItemInstance:
	return _item_instance


func get_definition() -> ItemDefinition:
	return _definition


func get_display_name() -> String:
	return _item_instance.get_display_name() if _item_instance != null else "Item"


func get_bulk() -> int:
	return _item_instance.get_bulk() if _item_instance != null else 0


func utility_text() -> String:
	return _item_instance.utility_text() if _item_instance != null else "No utility"


func can_pickup_into(carried_items: Node) -> bool:
	if carried_items == null or _item_instance == null:
		return false
	if not carried_items.has_method("can_add"):
		return false
	return bool(carried_items.can_add(_item_instance))


func pickup_into(carried_items: Node) -> bool:
	if not can_pickup_into(carried_items):
		return false
	if not carried_items.has_method("add_item"):
		return false

	var added: bool = bool(carried_items.add_item(_item_instance))
	if not added:
		return false

	if _storage_surface != null and is_instance_valid(_storage_surface):
		if _storage_surface.has_method("release") and not _storage_key.is_empty():
			_storage_surface.release(_storage_key)
	_storage_surface = null
	_storage_key = ""

	# Remove the interaction target immediately so repeated clicks cannot duplicate
	# the item while queue_free waits for the end of the frame.
	if _interaction_area != null:
		_interaction_area.collision_layer = 0
		_interaction_area.monitorable = false

	if _host != null and is_instance_valid(_host):
		_host.queue_free()
	return true


func _build_interaction_area() -> void:
	if _host == null or _definition == null:
		return

	_bounds = AABB()
	_bounds_valid = false

	for child in _host.get_children():
		if child == self:
			continue
		_scan_mesh_bounds(child, Transform3D.IDENTITY)

	if not _bounds_valid:
		push_warning("WorldItem could not determine mesh bounds for %s" % _host.name)
		return

	_interaction_area = Area3D.new()
	_interaction_area.name = "PickupArea"
	# Use a dedicated layer in addition to the normal environment layers. The
	# player's interaction ray still queries bodies too, so walls can occlude loot.
	_interaction_area.collision_layer = PICKUP_COLLISION_LAYER
	_interaction_area.collision_mask = 0
	_interaction_area.monitoring = false
	_interaction_area.monitorable = true
	add_child(_interaction_area)

	var shape_node: CollisionShape3D = CollisionShape3D.new()
	shape_node.name = "PickupShape"
	var box_shape: BoxShape3D = BoxShape3D.new()
	var padded_size: Vector3 = _bounds.size + Vector3(0.025, 0.025, 0.025)
	box_shape.size = Vector3(
		maxf(padded_size.x, 0.035),
		maxf(padded_size.y, 0.035),
		maxf(padded_size.z, 0.035)
	)
	shape_node.shape = box_shape
	shape_node.position = _bounds.position + (_bounds.size * 0.5)
	_interaction_area.add_child(shape_node)


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
