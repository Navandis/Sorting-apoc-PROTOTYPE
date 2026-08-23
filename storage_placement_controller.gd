extends Node3D
class_name StoragePlacementController

## Carries the Step-5 bridge:
## CarriedItems -> deterministic StorageSurface reservation -> WorldItem.

const StorageSurfaceScript = preload("res://storage_surface.gd")
const WorldItemScript = preload("res://world_item.gd")

const GHOST_VALID_COLOR := Color(0.22, 0.95, 0.58, 0.42)

var _camera: Camera3D = null
var _carried_items: Node = null
var _interaction_distance: float = 1.8

var _current_surface: Node = null
var _current_fit: Dictionary = {}
var _rotated: bool = false
var _suppressed: bool = false

var _ghost_host: Node3D = null
var _ghost_orientation_root: Node3D = null
var _ghost_visual: Node = null
var _ghost_item: Variant = null
var _ghost_material: StandardMaterial3D = null


func configure(camera: Camera3D, carried_items: Node, interaction_distance: float) -> void:
	_camera = camera
	_carried_items = carried_items
	_interaction_distance = interaction_distance

	_ghost_material = StandardMaterial3D.new()
	_ghost_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ghost_material.albedo_color = GHOST_VALID_COLOR
	_ghost_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	_ghost_host = Node3D.new()
	_ghost_host.name = "PlacementGhost"
	_ghost_host.visible = false
	get_tree().current_scene.add_child(_ghost_host)


func set_interaction_distance(value: float) -> void:
	_interaction_distance = value


func set_suppressed(value: bool) -> void:
	_suppressed = value
	if value:
		_hide_ghost()


func is_targeting_surface() -> bool:
	return _current_surface != null


func has_valid_placement() -> bool:
	if _current_surface == null or _current_fit.is_empty():
		return false
	var valid_value: Variant = _current_fit.get("valid", false)
	return bool(valid_value)


func get_prompt_text() -> String:
	if _carried_items == null or _current_surface == null:
		return ""

	var selected_item: Variant = _carried_items.get_selected_item()
	if selected_item == null:
		return ""

	var footprint: Vector2i = _selected_footprint(selected_item)
	var item_name: String = String(selected_item.get_display_name())

	if has_valid_placement():
		return "%s   •   %dx%d STORAGE\n[E / LMB] PLACE   •   [R] ROTATE" % [
			item_name,
			footprint.x,
			footprint.y
		]

	return "%s   •   %dx%d STORAGE\nNO VALID SPACE   •   [R] ROTATE" % [
		item_name,
		footprint.x,
		footprint.y
	]


func toggle_rotation() -> void:
	if _carried_items == null:
		return

	var selected_item: Variant = _carried_items.get_selected_item()
	if selected_item == null:
		return

	var base_footprint: Vector2i = _base_footprint(selected_item)
	if base_footprint.x == base_footprint.y:
		return

	_rotated = not _rotated
	update_target()


func reset_rotation() -> void:
	_rotated = false


func update_target() -> void:
	_current_surface = null
	_current_fit = {}

	if _suppressed or _camera == null or _carried_items == null:
		_hide_ghost()
		return

	var selected_item: Variant = _carried_items.get_selected_item()
	if selected_item == null or _camera.get_world_3d() == null:
		_hide_ghost()
		return

	var ray_from: Vector3 = _camera.global_position
	var forward: Vector3 = -_camera.global_transform.basis.z.normalized()
	var ray_to: Vector3 = ray_from + forward * _interaction_distance

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = ray_from
	query.to = ray_to
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = StorageSurfaceScript.STORAGE_INTERACTION_LAYER

	var result: Dictionary = _camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		_hide_ghost()
		return

	var collider_value: Variant = result.get("collider")
	if not (collider_value is Node):
		_hide_ghost()
		return

	var surface: Node = _find_storage_surface(collider_value as Node)
	if surface == null:
		_hide_ghost()
		return

	var position_value: Variant = result.get("position", Vector3.ZERO)
	var hit_world: Vector3 = position_value as Vector3
	var hit_local: Vector3 = surface.to_local(hit_world)
	var footprint: Vector2i = _selected_footprint(selected_item)

	_current_surface = surface
	_current_fit = surface.find_nearest_fit_to_local_point(hit_local, footprint)
	_update_ghost(selected_item)


func place_selected() -> bool:
	if not has_valid_placement() or _carried_items == null:
		return false

	var selected_item: Variant = _carried_items.get_selected_item()
	if selected_item == null:
		return false

	var origin_value: Variant = _current_fit.get("origin", Vector2i.ZERO)
	var footprint_value: Variant = _current_fit.get("footprint", Vector2i.ONE)
	var origin: Vector2i = origin_value as Vector2i
	var footprint: Vector2i = footprint_value as Vector2i

	var item_key: String = ""
	if selected_item is ItemInstance:
		var typed_item: ItemInstance = selected_item as ItemInstance
		item_key = typed_item.instance_id
	if item_key.is_empty():
		item_key = "%s-%d" % [String(selected_item.get_display_name()), Time.get_ticks_usec()]

	var placement_rotated: bool = _rotated
	var reserved: bool = bool(
		_current_surface.reserve_at(item_key, origin, footprint, placement_rotated)
	)
	if not reserved:
		update_target()
		return false

	var removed_item: Variant = _carried_items.remove_selected()
	if removed_item == null:
		_current_surface.release(item_key)
		update_target()
		return false

	var spawned: bool = _spawn_stored_world_item(
		removed_item,
		_current_surface,
		item_key,
		origin,
		footprint,
		placement_rotated
	)
	if not spawned:
		_current_surface.release(item_key)
		_carried_items.add_item(removed_item)
		update_target()
		return false

	reset_rotation()
	call_deferred("update_target")
	return true


func _spawn_stored_world_item(
	item,
	surface: Node,
	item_key: String,
	origin: Vector2i,
	footprint: Vector2i,
	rotated: bool
) -> bool:
	var visual_scene: PackedScene = item.get_visual_scene() as PackedScene
	if visual_scene == null:
		return false

	var host: Node3D = Node3D.new()
	host.name = "Stored_%s" % _safe_node_name(String(item.get_display_name()))
	surface.add_child(host)
	host.transform = surface.get_local_candidate_transform(origin, footprint)

	var orientation_root: Node3D = Node3D.new()
	orientation_root.name = "StoredOrientation"
	host.add_child(orientation_root)
	_apply_storage_rotation(orientation_root, item, rotated)

	var visual: Node = visual_scene.instantiate()
	orientation_root.add_child(visual)
	_disable_embedded_nodes(visual)
	_align_visual_to_plane(visual)

	var component: WorldItem = WorldItemScript.new()
	component.name = "WorldItem"
	host.add_child(component)
	component.configure_existing(host, item, surface, item_key)
	return true


func _update_ghost(item) -> void:
	if _ghost_host == null or not is_instance_valid(_ghost_host):
		return

	if item != _ghost_item:
		_rebuild_ghost(item)

	if _ghost_visual == null or _current_surface == null or not has_valid_placement():
		_hide_ghost()
		return

	var origin_value: Variant = _current_fit.get("origin", Vector2i.ZERO)
	var footprint_value: Variant = _current_fit.get("footprint", _selected_footprint(item))
	var origin: Vector2i = origin_value as Vector2i
	var footprint: Vector2i = footprint_value as Vector2i

	var local_transform: Transform3D = _current_surface.get_local_candidate_transform(
		origin,
		footprint
	)
	_ghost_host.global_transform = _current_surface.global_transform * local_transform
	_apply_storage_rotation(_ghost_orientation_root, item, _rotated)
	_ghost_host.visible = true


func _rebuild_ghost(item) -> void:
	_ghost_item = item

	if _ghost_orientation_root != null and is_instance_valid(_ghost_orientation_root):
		_ghost_orientation_root.queue_free()

	_ghost_orientation_root = Node3D.new()
	_ghost_orientation_root.name = "GhostOrientation"
	_ghost_host.add_child(_ghost_orientation_root)
	_ghost_visual = null

	if item == null:
		return

	var visual_scene: PackedScene = item.get_visual_scene() as PackedScene
	if visual_scene == null:
		return

	_ghost_visual = visual_scene.instantiate()
	_ghost_orientation_root.add_child(_ghost_visual)
	_disable_embedded_nodes(_ghost_visual)
	_apply_ghost_material(_ghost_visual)
	_align_visual_to_plane(_ghost_visual)


func _apply_storage_rotation(root: Node3D, item, rotated: bool) -> void:
	var correction_degrees: Vector3 = Vector3.ZERO
	if item.has_method("get_storage_rotation_degrees"):
		correction_degrees = item.get_storage_rotation_degrees()

	root.rotation = Vector3(
		deg_to_rad(correction_degrees.x),
		deg_to_rad(correction_degrees.y),
		deg_to_rad(correction_degrees.z)
	)
	if rotated:
		root.rotate_y(deg_to_rad(90.0))


func _align_visual_to_plane(visual: Node) -> void:
	var state: Dictionary = {"valid": false, "bounds": AABB()}
	_scan_bounds_recursive(visual, Transform3D.IDENTITY, state)

	var valid_value: Variant = state.get("valid", false)
	if not bool(valid_value) or not (visual is Node3D):
		return

	var bounds_value: Variant = state.get("bounds", AABB())
	var bounds: AABB = bounds_value as AABB
	var center: Vector3 = bounds.position + bounds.size * 0.5
	var visual_3d: Node3D = visual as Node3D

	visual_3d.position += Vector3(
		-center.x,
		-bounds.position.y + 0.006,
		-center.z
	)


func _scan_bounds_recursive(
	node: Node,
	accumulated_transform: Transform3D,
	state: Dictionary
) -> void:
	var next_transform: Transform3D = accumulated_transform
	if node is Node3D:
		var node_3d: Node3D = node as Node3D
		next_transform = accumulated_transform * node_3d.transform

	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh != null:
			var transformed_bounds: AABB = next_transform * mesh_instance.get_aabb()
			var valid_value: Variant = state.get("valid", false)
			if bool(valid_value):
				var current_value: Variant = state.get("bounds", AABB())
				var current_bounds: AABB = current_value as AABB
				state["bounds"] = current_bounds.merge(transformed_bounds)
			else:
				state["bounds"] = transformed_bounds
				state["valid"] = true

	for child: Node in node.get_children():
		_scan_bounds_recursive(child, next_transform, state)


func _disable_embedded_nodes(node: Node) -> void:
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

	if node is WorldEnvironment:
		var embedded_environment: WorldEnvironment = node as WorldEnvironment
		embedded_environment.environment = null

	if node is GeometryInstance3D:
		var geometry: GeometryInstance3D = node as GeometryInstance3D
		geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	for child: Node in node.get_children():
		_disable_embedded_nodes(child)


func _apply_ghost_material(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		mesh_instance.material_override = _ghost_material
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	for child: Node in node.get_children():
		_apply_ghost_material(child)


func _selected_footprint(item) -> Vector2i:
	var footprint: Vector2i = _base_footprint(item)
	if _rotated:
		return Vector2i(footprint.y, footprint.x)
	return footprint


func _base_footprint(item) -> Vector2i:
	var footprint_3d: Vector3i = item.get_storage_footprint()
	return Vector2i(maxi(1, footprint_3d.x), maxi(1, footprint_3d.y))


func _find_storage_surface(node: Node) -> Node:
	var current: Node = node
	while current != null:
		if current is StorageSurface:
			return current
		if current == get_tree().current_scene:
			break
		current = current.get_parent()
	return null


func _hide_ghost() -> void:
	if _ghost_host != null and is_instance_valid(_ghost_host):
		_ghost_host.visible = false


func _safe_node_name(value: String) -> String:
	var safe: String = value.strip_edges().replace(" ", "_")
	safe = safe.replace("/", "_").replace("\\", "_").replace(":", "_")
	return safe
