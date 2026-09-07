extends Node3D
class_name StoragePlacementController

## Carries the Step-5 bridge:
## CarriedItems -> deterministic StorageSurface reservation -> WorldItem.

const StorageSurfaceScript = preload("res://storage_surface.gd")
const StorageStackScript = preload("res://storage_stack.gd")
const WorldItemScript = preload("res://world_item.gd")
const StorageVisualPoseScript = preload("res://storage_visual_pose.gd")

const GHOST_VALID_COLOR := Color(0.20, 1.00, 0.48, 0.68)
const GHOST_BLOCKED_COLOR := Color(1.00, 0.22, 0.18, 0.68)
const GHOST_PAD_ALPHA: float = 0.22

var _camera: Camera3D = null
var _carried_items: Node = null
var _interaction_distance: float = 1.8

var _current_surface: Node = null
var _current_fit: Dictionary = {}
var _rotated: bool = false
var _suppressed: bool = false
var _manual_mode: bool = false
var _manual_debug_surface: Node = null

var _ghost_host: Node3D = null
var _ghost_packing_root: Node3D = null
var _ghost_visual: Node = null
var _ghost_item: Variant = null
var _ghost_material_valid: StandardMaterial3D = null
var _ghost_material_blocked: StandardMaterial3D = null
var _ghost_footprint: MeshInstance3D = null
var _pose_metrics_cache: Dictionary = {}


func configure(camera: Camera3D, carried_items: Node, interaction_distance: float) -> void:
	_camera = camera
	_carried_items = carried_items
	_interaction_distance = interaction_distance

	_ghost_material_valid = _make_ghost_material(GHOST_VALID_COLOR)
	_ghost_material_blocked = _make_ghost_material(GHOST_BLOCKED_COLOR)

	_ghost_host = Node3D.new()
	_ghost_host.name = "PlacementGhost"
	_ghost_host.visible = false

	# Keep the preview parented from the moment it is created. `_update_ghost()`
	# may run on the next process frame and needs a valid parent before it can
	# move the ghost onto a StorageSurface.
	add_child(_ghost_host)


func set_interaction_distance(value: float) -> void:
	_interaction_distance = value


func set_suppressed(value: bool) -> void:
	_suppressed = value
	if value:
		_hide_ghost()


func is_manual_mode() -> bool:
	return _manual_mode


func set_manual_mode(value: bool) -> void:
	if _manual_mode == value:
		return

	_manual_mode = value
	_rotated = false

	if not _manual_mode:
		_hide_ghost()
		_set_manual_debug_surface(null)

	update_target()


func toggle_manual_mode() -> bool:
	set_manual_mode(not _manual_mode)
	return _manual_mode


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

	var item_name: String = String(selected_item.get_display_name())

	if _manual_mode:
		var footprint: Vector2i = _selected_footprint(selected_item)
		if has_valid_placement():
			return "%s   •   %dx%d STORAGE\n[E] PLACE   •   [R] ROTATE   •   [M] AUTO" % [
				item_name,
				footprint.x,
				footprint.y
			]

		return "%s   •   %dx%d STORAGE\nNO VALID LOCAL SPACE   •   [R] ROTATE   •   [M] AUTO" % [
			item_name,
			footprint.x,
			footprint.y
		]

	var storage_category: String = ""
	if selected_item.has_method("get_storage_category"):
		storage_category = String(selected_item.get_storage_category())

	if has_valid_placement():
		var zone_kind: String = String(_current_fit.get("zone_kind", "matching"))
		var destination_text: String = _storage_category_display_text(storage_category)

		if zone_kind == "general":
			destination_text = "GENERAL"
		elif zone_kind == "unassigned":
			destination_text = "UNASSIGNED"

		return "%s   •   %s\n[E] AUTO-STORE → %s   •   [M] MANUAL" % [
			item_name,
			_storage_category_display_text(storage_category),
			destination_text
		]

	return "%s   •   %s\nNO MATCHING / GENERAL SPACE   •   [M] MANUAL" % [
		item_name,
		_storage_category_display_text(storage_category)
	]


func toggle_rotation() -> void:
	if not _manual_mode or _carried_items == null:
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
		_set_manual_debug_surface(null)
		return

	var selected_item: Variant = _carried_items.get_selected_item()
	if selected_item == null or _camera.get_world_3d() == null:
		_hide_ghost()
		_set_manual_debug_surface(null)
		return

	if _manual_mode:
		var stack_target: WorldItem = _get_looked_at_stored_world_item()
		if stack_target != null:
			var stack_surface: Node = stack_target.get_storage_surface()
			if stack_surface != null:
				_current_surface = stack_surface
				_set_manual_debug_surface(stack_surface)
				var stack_entry: StorageStack.Entry = _entry_for_item(
					selected_item,
					_rotated
				)
				_current_fit = stack_surface.find_manual_stack_fit(
					stack_target.get_storage_stack_id(),
					stack_entry
				)
				_update_ghost(selected_item)
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
		_set_manual_debug_surface(null)
		return

	var collider_value: Variant = result.get("collider")
	if not (collider_value is Node):
		_hide_ghost()
		_set_manual_debug_surface(null)
		return

	var surface: Node = _find_storage_surface(collider_value as Node)
	if surface == null:
		_hide_ghost()
		_set_manual_debug_surface(null)
		return

	_current_surface = surface

	if _manual_mode:
		_set_manual_debug_surface(surface)

		var position_value: Variant = result.get("position", Vector3.ZERO)
		var hit_world: Vector3 = position_value as Vector3
		var hit_local: Vector3 = surface.to_local(hit_world)
		var footprint: Vector2i = _selected_footprint(selected_item)

		_current_fit = surface.find_nearest_fit_to_local_point(
			hit_local,
			footprint
		)
		_current_fit["placement_kind"] = "empty"
		_current_fit["stack_id"] = _item_key(selected_item)
		_current_fit["insertion_index"] = 0
		_current_fit["base_footprint"] = footprint
		_current_fit["rotated"] = _rotated
		_current_fit["zone_kind"] = "manual"
		_current_fit["zone_category"] = ""
		var manual_origin: Vector2i = _current_fit.get("origin", Vector2i.ZERO) as Vector2i
		_current_fit["host_y_m"] = surface.get_local_placement_position(
			manual_origin,
			footprint
		).y
		_update_ghost(selected_item)
		return

	# Zone-auto mode is intentionally visually quiet: no grid, no footprint
	# overlays and no placement ghost.
	_hide_ghost()
	_set_manual_debug_surface(null)

	var storage_category: String = ""
	if selected_item.has_method("get_storage_category"):
		storage_category = String(selected_item.get_storage_category())

	var orientations: Array[StorageStack.Entry] = _entry_orientations_for_item(
		selected_item
	)
	var rotated_entry: StorageStack.Entry = null
	if orientations.size() > 1:
		rotated_entry = orientations[1]
	_current_fit = surface.find_zone_stack_or_empty_fit(
		storage_category,
		orientations[0],
		rotated_entry
	)


func _storage_category_display_text(category: String) -> String:
	var cleaned: String = category.strip_edges()
	return "UNCATEGORIZED" if cleaned.is_empty() else cleaned.to_upper()


func place_selected() -> bool:
	if not has_valid_placement() or _carried_items == null:
		return false

	var selected_item: Variant = _carried_items.get_selected_item()
	if selected_item == null:
		return false

	var removed_item: Variant = _carried_items.remove_selected()
	if removed_item == null:
		update_target()
		return false

	var item_key: String = _item_key(removed_item)
	var origin: Vector2i = _current_fit.get("origin", Vector2i.ZERO) as Vector2i
	var footprint: Vector2i = _current_fit.get("footprint", Vector2i.ONE) as Vector2i
	var placement_rotated: bool = bool(_current_fit.get("rotated", _rotated))

	var spawned: bool = _spawn_stored_world_item(
		removed_item,
		_current_surface,
		item_key,
		origin,
		footprint,
		placement_rotated,
		_current_fit
	)
	if not spawned:
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
	rotated: bool,
	placement_fit: Dictionary = {}
) -> bool:
	var visual_scene: PackedScene = item.get_visual_scene() as PackedScene
	if visual_scene == null:
		return false
	if surface == null or not surface.has_method("commit_stack_entry"):
		return false

	var effective_fit: Dictionary = placement_fit.duplicate(true)
	var previous_reservation: Dictionary = {}
	if effective_fit.is_empty():
		previous_reservation = surface.get_reservation(item_key)
		if bool(previous_reservation.get("valid", false)):
			surface.release(item_key)
		effective_fit = {
			"valid": true,
			"placement_kind": "empty",
			"stack_id": item_key,
			"insertion_index": 0,
			"origin": origin,
			"footprint": footprint,
			"base_footprint": footprint,
			"rotated": rotated,
			"zone_kind": "legacy",
			"zone_category": "",
			"host_y_m": surface.get_local_placement_position(origin, footprint).y
		}

	# StorageSurface is top-level/unit-scale, so stored visuals can safely be
	# children of it again. This restores the previously validated transform path
	# while keeping them isolated from the visible shelf's scale.
	var host: Node3D = Node3D.new()
	host.name = "Stored_%s" % _safe_node_name(String(item.get_display_name()))
	surface.add_child(host)
	host.transform = surface.get_stack_candidate_transform(effective_fit)

	var packing_root: Node3D = Node3D.new()
	packing_root.name = "StoredPackingYaw"
	host.add_child(packing_root)

	var visual: Node = visual_scene.instantiate()
	_disable_embedded_nodes(visual)
	var pose_result: Dictionary = build_visual_pose_for_item(
		packing_root,
		visual,
		item,
		rotated
	)
	if not bool(pose_result.get("valid", false)):
		host.free()
		_restore_reservation(surface, previous_reservation)
		return false

	var aligned_bounds: AABB = pose_result.get("aligned_bounds", AABB()) as AABB
	var expected_pose: Dictionary = _pose_metrics_for_item(item, rotated)
	var expected_bounds: AABB = expected_pose.get("aligned_bounds", AABB()) as AABB
	if (
		not bool(expected_pose.get("valid", false))
		or not aligned_bounds.position.is_equal_approx(expected_bounds.position)
		or not aligned_bounds.size.is_equal_approx(expected_bounds.size)
	):
		host.free()
		_restore_reservation(surface, previous_reservation)
		return false

	var entry: StorageStack.Entry = StorageStackScript.create_entry(
		item,
		footprint,
		rotated,
		aligned_bounds
	)
	entry.item_key = item_key
	entry.host = host

	var component: WorldItem = WorldItemScript.new()
	component.name = "WorldItem"
	host.add_child(component)
	component.configure_existing(
		host,
		item,
		surface,
		String(effective_fit.get("stack_id", item_key)),
		item_key
	)
	entry.world_item = component
	if not bool(surface.commit_stack_entry(entry, effective_fit)):
		host.free()
		_restore_reservation(surface, previous_reservation)
		return false
	return true


func _update_ghost(item) -> void:
	if _ghost_host == null or not is_instance_valid(_ghost_host):
		return

	if item != _ghost_item:
		_rebuild_ghost(item)

	if _ghost_visual == null or _current_surface == null or _current_fit.is_empty():
		_hide_ghost()
		return

	var origin_value: Variant = _current_fit.get("origin", Vector2i.ZERO)
	var footprint_value: Variant = _current_fit.get(
		"footprint",
		_selected_footprint(item)
	)
	var origin: Vector2i = origin_value as Vector2i
	var footprint: Vector2i = footprint_value as Vector2i

	var local_transform: Transform3D = (
		_current_surface.get_stack_candidate_transform(_current_fit)
		if _current_surface.has_method("get_stack_candidate_transform")
		else _current_surface.get_local_candidate_transform(origin, footprint)
	)

	# Keep the ghost in exactly the same coordinate system as the deterministic
	# cells it previews. StorageSurface has unit global scale, so the actual item
	# silhouette remains undistorted even on a squashed visual shelf.
	var ghost_parent: Node = _ghost_host.get_parent()
	if ghost_parent == null:
		# Defensive fallback. This should no longer be needed because configure()
		# parents the node immediately, but it prevents a lifecycle edge case from
		# making the preview disappear.
		_current_surface.add_child(_ghost_host)
	elif ghost_parent != _current_surface:
		_ghost_host.reparent(_current_surface, false)

	_ghost_host.transform = local_transform

	var preview_rotated: bool = bool(_current_fit.get("rotated", _rotated))
	StorageVisualPoseScript.apply_packing_yaw(
		_ghost_packing_root,
		preview_rotated
	)

	var valid: bool = has_valid_placement()
	var ghost_material: StandardMaterial3D = (
		_ghost_material_valid if valid else _ghost_material_blocked
	)
	_apply_ghost_material(_ghost_visual, ghost_material)
	_update_ghost_footprint(footprint, ghost_material)

	# The item model itself is the primary placement preview. The thin pad is
	# only a secondary footprint cue; unlike F7 it follows the currently
	# selected item and exists during normal manual placement.
	_ghost_host.visible = true


func _rebuild_ghost(item) -> void:
	_ghost_item = item

	if _ghost_packing_root != null and is_instance_valid(_ghost_packing_root):
		_ghost_packing_root.queue_free()

	if _ghost_footprint != null and is_instance_valid(_ghost_footprint):
		_ghost_footprint.queue_free()
		_ghost_footprint = null

	_ghost_packing_root = Node3D.new()
	_ghost_packing_root.name = "GhostPackingYaw"
	_ghost_host.add_child(_ghost_packing_root)
	_ghost_visual = null

	if item == null:
		return

	var visual_scene: PackedScene = item.get_visual_scene() as PackedScene
	if visual_scene == null:
		return

	_ghost_visual = visual_scene.instantiate()
	_disable_embedded_nodes(_ghost_visual)
	build_visual_pose_for_item(
		_ghost_packing_root,
		_ghost_visual,
		item,
		_rotated
	)

	_ghost_footprint = MeshInstance3D.new()
	_ghost_footprint.name = "GhostFootprint"
	_ghost_footprint.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ghost_host.add_child(_ghost_footprint)


func build_visual_pose_for_item(
	packing_root: Node3D,
	visual: Node,
	item,
	packing_rotated: bool
) -> Dictionary:
	var correction_degrees: Vector3 = Vector3.ZERO
	if item.has_method("get_storage_rotation_degrees"):
		correction_degrees = item.get_storage_rotation_degrees()
	return StorageVisualPoseScript.build_visual(
		packing_root,
		visual,
		correction_degrees,
		packing_rotated
	)


func _entry_for_item(item, packing_rotated: bool) -> StorageStack.Entry:
	if not (item is ItemInstance):
		return null
	var typed_item: ItemInstance = item as ItemInstance
	var pose_result: Dictionary = _pose_metrics_for_item(typed_item, packing_rotated)
	if not bool(pose_result.get("valid", false)):
		return null
	var footprint: Vector2i = _base_footprint(typed_item)
	if packing_rotated:
		footprint = Vector2i(footprint.y, footprint.x)
	var aligned_bounds: AABB = pose_result.get("aligned_bounds", AABB()) as AABB
	return StorageStackScript.create_entry(
		typed_item,
		footprint,
		packing_rotated,
		aligned_bounds
	)


func _entry_orientations_for_item(item) -> Array[StorageStack.Entry]:
	var orientations: Array[StorageStack.Entry] = []
	var native_entry: StorageStack.Entry = _entry_for_item(item, false)
	if native_entry == null:
		return orientations
	orientations.append(native_entry)
	var footprint: Vector2i = _base_footprint(item)
	if footprint.x != footprint.y:
		var rotated_entry: StorageStack.Entry = _entry_for_item(item, true)
		if rotated_entry != null:
			orientations.append(rotated_entry)
	return orientations


func _pose_metrics_for_item(item, packing_rotated: bool) -> Dictionary:
	if not (item is ItemInstance):
		return {"valid": false}
	var typed_item: ItemInstance = item as ItemInstance
	var definition_id: String = (
		String(typed_item.definition.item_id)
		if typed_item.definition != null
		else typed_item.instance_id
	)
	var cache_key: String = "%s:%s" % [definition_id, packing_rotated]
	if not _pose_metrics_cache.has(cache_key):
		_pose_metrics_cache[cache_key] = StorageVisualPoseScript.measure_item(
			typed_item,
			packing_rotated
		)
	var value: Variant = _pose_metrics_cache[cache_key]
	return (value as Dictionary).duplicate(true) if value is Dictionary else {"valid": false}


func _item_key(item) -> String:
	if item is ItemInstance:
		return (item as ItemInstance).instance_id
	return "%s-%d" % [String(item.get_display_name()), Time.get_ticks_usec()]


func _restore_reservation(surface: Node, reservation: Dictionary) -> void:
	if surface == null or not bool(reservation.get("valid", false)):
		return
	surface.reserve_at(
		String(reservation.get("item_key", "")),
		reservation.get("origin", Vector2i.ZERO) as Vector2i,
		reservation.get("footprint", Vector2i.ONE) as Vector2i,
		bool(reservation.get("rotated", false))
	)


func _get_looked_at_stored_world_item() -> WorldItem:
	if _camera == null or _camera.get_world_3d() == null:
		return null
	var ray_from: Vector3 = _camera.global_position
	var ray_to: Vector3 = ray_from + (
		-_camera.global_transform.basis.z.normalized() * _interaction_distance
	)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = ray_from
	query.to = ray_to
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = WorldItemScript.PICKUP_COLLISION_LAYER
	var result: Dictionary = _camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null
	var collider_value: Variant = result.get("collider")
	if not (collider_value is Node):
		return null
	var current: Node = collider_value as Node
	while current != null:
		if current is WorldItem:
			var world_item: WorldItem = current as WorldItem
			return world_item if world_item.is_stored_item() else null
		if current == get_tree().current_scene:
			break
		current = current.get_parent()
	return null


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


func _apply_ghost_material(node: Node, material: Material) -> void:
	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		mesh_instance.material_override = material
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh_instance.transparency = 0.0

	for child: Node in node.get_children():
		_apply_ghost_material(child, material)


func _make_ghost_material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = true
	material.render_priority = 120
	return material


func _update_ghost_footprint(
	footprint: Vector2i,
	source_material: StandardMaterial3D
) -> void:
	if _ghost_footprint == null or _current_surface == null:
		return

	var cell_size: float = float(_current_surface.get_cell_size_m())
	var pad_mesh: BoxMesh = BoxMesh.new()
	pad_mesh.size = Vector3(
		float(footprint.x) * cell_size * 0.94,
		0.008,
		float(footprint.y) * cell_size * 0.94
	)

	var pad_material: StandardMaterial3D = source_material.duplicate() as StandardMaterial3D
	var pad_color: Color = pad_material.albedo_color
	pad_color.a = GHOST_PAD_ALPHA
	pad_material.albedo_color = pad_color
	pad_material.no_depth_test = false
	pad_material.render_priority = 110
	pad_mesh.material = pad_material

	_ghost_footprint.mesh = pad_mesh
	_ghost_footprint.position = Vector3(0.0, 0.004, 0.0)


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


func _set_manual_debug_surface(surface: Node) -> void:
	if _manual_debug_surface == surface:
		return

	if (
		_manual_debug_surface != null
		and is_instance_valid(_manual_debug_surface)
		and _manual_debug_surface.has_method("set_debug_visible")
	):
		_manual_debug_surface.set_debug_visible(false)

	_manual_debug_surface = surface

	if (
		_manual_mode
		and _manual_debug_surface != null
		and is_instance_valid(_manual_debug_surface)
		and _manual_debug_surface.has_method("set_debug_visible")
	):
		_manual_debug_surface.set_debug_visible(true)


func _hide_ghost() -> void:
	if _ghost_host != null and is_instance_valid(_ghost_host):
		_ghost_host.visible = false


func _safe_node_name(value: String) -> String:
	var safe: String = value.strip_edges().replace(" ", "_")
	safe = safe.replace("/", "_").replace("\\", "_").replace(":", "_")
	return safe
