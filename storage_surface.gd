extends Node3D
class_name StorageSurface

## Deterministic 2D storage grid attached to one physical shelf level.
##
## The rendered shelf geometry, player movement collision, and this storage
## representation are deliberately independent. An item occupies authored
## grid cells even though its visual mesh may have an irregular shape.
##
## Footprint convention for the current prototype:
##   storage_footprint.x = width cells
##   storage_footprint.y = depth cells
##   storage_footprint.z = reserved for future vertical stacking/clearance
##
## Storage is scale-isolated from the visible furniture. A shelf may be
## visually stretched/squashed without stretching stored item models.

signal occupancy_changed

# Godot layer 9 / bit 8. Kept separate from:
# - player/environment collision
# - loot pickup interaction (currently layer 8 / bit 7)
const STORAGE_INTERACTION_LAYER: int = 1 << 8

const MIN_CELL_SIZE_M: float = 0.025
const INTERACTION_THICKNESS_M: float = 0.06
const DEBUG_Y_OFFSET_M: float = 0.012

var surface_id: StringName = &"storage_surface"
var cell_size_m: float = 0.10
var grid_size: Vector2i = Vector2i.ONE
var usable_size_m: Vector2 = Vector2(0.10, 0.10)

var _cells: Array[String] = []
var _reservations: Dictionary = {}

var _interaction_area: Area3D = null
var _debug_grid: MeshInstance3D = null
var _debug_occupancy_root: Node3D = null
var _debug_visible: bool = true


func configure(
	new_surface_id: StringName,
	requested_width_m: float,
	requested_depth_m: float,
	requested_cell_size_m: float = 0.10
) -> void:
	surface_id = new_surface_id

	# The prototype manager positions this surface as a normal child of the
	# shelf first. Capture that already-correct world transform while the
	# shelf's scale still participates.
	var captured_global: Transform3D = global_transform

	var parent_scale: Vector3 = Vector3.ONE
	var parent_node: Node = get_parent()
	if parent_node is Node3D:
		parent_scale = (parent_node as Node3D).global_transform.basis.get_scale()

	var scale_x: float = maxf(absf(parent_scale.x), 0.0001)
	var scale_y: float = maxf(absf(parent_scale.y), 0.0001)
	var scale_z: float = maxf(absf(parent_scale.z), 0.0001)
	var horizontal_scale: float = (scale_x + scale_z) * 0.5

	# storage_prototype_manager.gd supplies local dimensions and currently
	# compensates its requested cell size for the shelf's horizontal scale.
	# Convert those values into actual world metres once.
	var world_width_m: float = requested_width_m * scale_x
	var world_depth_m: float = requested_depth_m * scale_z
	var world_cell_size_m: float = requested_cell_size_m * horizontal_scale

	# Crucial Step 5.4 change:
	# remain logically parented to the shelf, but stop inheriting the shelf's
	# transform. The surface keeps the captured world position + rotation and
	# has unit scale. Children (ghosts, stored items, labels later) therefore
	# cannot be squashed by a visually non-uniformly scaled shelf.
	set_as_top_level(true)
	global_transform = Transform3D(
		captured_global.basis.orthonormalized(),
		captured_global.origin
	)
	scale = Vector3.ONE

	cell_size_m = maxf(world_cell_size_m, MIN_CELL_SIZE_M)

	var column_count: int = maxi(1, int(floor(world_width_m / cell_size_m)))
	var row_count: int = maxi(1, int(floor(world_depth_m / cell_size_m)))
	grid_size = Vector2i(column_count, row_count)
	usable_size_m = Vector2(
		float(grid_size.x) * cell_size_m,
		float(grid_size.y) * cell_size_m
	)

	_cells.clear()
	_cells.resize(grid_size.x * grid_size.y)
	for cell_index: int in range(_cells.size()):
		_cells[cell_index] = ""

	_reservations.clear()
	_rebuild_interaction_area()
	_rebuild_debug_grid()
	_refresh_debug_occupancy()


func get_grid_size() -> Vector2i:
	return grid_size


func get_cell_size_m() -> float:
	return cell_size_m


func get_usable_size_m() -> Vector2:
	return usable_size_m


func get_reservation_count() -> int:
	return _reservations.size()


func get_occupancy_ratio() -> float:
	if _cells.is_empty():
		return 0.0

	var occupied_count: int = 0
	for owner_id: String in _cells:
		if not owner_id.is_empty():
			occupied_count += 1

	return float(occupied_count) / float(_cells.size())


func can_place_at(origin: Vector2i, footprint: Vector2i) -> bool:
	var normalized: Vector2i = _normalize_footprint(footprint)
	if origin.x < 0 or origin.y < 0:
		return false
	if origin.x + normalized.x > grid_size.x:
		return false
	if origin.y + normalized.y > grid_size.y:
		return false

	for row: int in range(origin.y, origin.y + normalized.y):
		for column: int in range(origin.x, origin.x + normalized.x):
			var cell_index: int = _cell_index(Vector2i(column, row))
			if not _cells[cell_index].is_empty():
				return false

	return true


func find_first_fit(footprint: Vector2i, allow_rotate: bool = true) -> Dictionary:
	var primary: Vector2i = _normalize_footprint(footprint)
	var candidates: Array[Vector2i] = [primary]

	if allow_rotate and primary.x != primary.y:
		candidates.append(Vector2i(primary.y, primary.x))

	for candidate: Vector2i in candidates:
		if candidate.x > grid_size.x or candidate.y > grid_size.y:
			continue

		var max_row: int = grid_size.y - candidate.y
		var max_column: int = grid_size.x - candidate.x

		for row: int in range(max_row + 1):
			for column: int in range(max_column + 1):
				var origin: Vector2i = Vector2i(column, row)
				if can_place_at(origin, candidate):
					return {
						"valid": true,
						"origin": origin,
						"footprint": candidate,
						"rotated": candidate != primary
					}

	return {
		"valid": false,
		"origin": Vector2i(-1, -1),
		"footprint": primary,
		"rotated": false
	}


func find_nearest_fit_to_local_point(
	local_point: Vector3,
	footprint: Vector2i
) -> Dictionary:
	## Finds the valid deterministic origin whose footprint center is nearest
	## the cursor hit position.
	var normalized: Vector2i = _normalize_footprint(footprint)
	if normalized.x > grid_size.x or normalized.y > grid_size.y:
		return {
			"valid": false,
			"origin": get_clamped_origin_for_local_point(local_point, normalized),
			"footprint": normalized
		}

	var best_valid: bool = false
	var best_origin: Vector2i = Vector2i.ZERO
	var best_distance_squared: float = INF

	var max_row: int = grid_size.y - normalized.y
	var max_column: int = grid_size.x - normalized.x

	for row: int in range(max_row + 1):
		for column: int in range(max_column + 1):
			var origin: Vector2i = Vector2i(column, row)
			if not can_place_at(origin, normalized):
				continue

			var candidate_position: Vector3 = get_local_placement_position(origin, normalized)
			var delta_x: float = candidate_position.x - local_point.x
			var delta_z: float = candidate_position.z - local_point.z
			var distance_squared: float = delta_x * delta_x + delta_z * delta_z

			if not best_valid or distance_squared < best_distance_squared:
				best_valid = true
				best_distance_squared = distance_squared
				best_origin = origin

	return {
		"valid": best_valid,
		"origin": best_origin if best_valid else get_clamped_origin_for_local_point(local_point, normalized),
		"footprint": normalized
	}


func get_clamped_origin_for_local_point(
	local_point: Vector3,
	footprint: Vector2i
) -> Vector2i:
	var normalized: Vector2i = _normalize_footprint(footprint)
	var half_width: float = usable_size_m.x * 0.5
	var half_depth: float = usable_size_m.y * 0.5

	var center_column: float = (local_point.x + half_width) / cell_size_m
	var center_row: float = (local_point.z + half_depth) / cell_size_m

	var origin_x: int = int(round(center_column - float(normalized.x) * 0.5))
	var origin_y: int = int(round(center_row - float(normalized.y) * 0.5))

	var max_origin_x: int = maxi(0, grid_size.x - normalized.x)
	var max_origin_y: int = maxi(0, grid_size.y - normalized.y)

	return Vector2i(
		clampi(origin_x, 0, max_origin_x),
		clampi(origin_y, 0, max_origin_y)
	)


func get_local_candidate_transform(
	origin: Vector2i,
	footprint: Vector2i
) -> Transform3D:
	return Transform3D(
		Basis.IDENTITY,
		get_local_placement_position(origin, footprint)
	)


func reserve_first_fit(
	item_key: String,
	footprint: Vector2i,
	allow_rotate: bool = true
) -> Dictionary:
	if item_key.is_empty():
		return {"valid": false}

	# An ItemInstance may only own one reservation on a given surface.
	if _reservations.has(item_key):
		return get_reservation(item_key)

	var fit: Dictionary = find_first_fit(footprint, allow_rotate)
	var valid_value: Variant = fit.get("valid", false)
	if not bool(valid_value):
		return fit

	var origin_value: Variant = fit.get("origin", Vector2i(-1, -1))
	var footprint_value: Variant = fit.get("footprint", Vector2i.ONE)
	var rotated_value: Variant = fit.get("rotated", false)

	var origin: Vector2i = origin_value as Vector2i
	var fitted_footprint: Vector2i = footprint_value as Vector2i
	var rotated: bool = bool(rotated_value)

	var reserved: bool = reserve_at(
		item_key,
		origin,
		fitted_footprint,
		rotated
	)
	if not reserved:
		return {"valid": false}

	return get_reservation(item_key)


func reserve_at(
	item_key: String,
	origin: Vector2i,
	footprint: Vector2i,
	rotated: bool = false
) -> bool:
	if item_key.is_empty() or _reservations.has(item_key):
		return false

	var normalized: Vector2i = _normalize_footprint(footprint)
	if not can_place_at(origin, normalized):
		return false

	for row: int in range(origin.y, origin.y + normalized.y):
		for column: int in range(origin.x, origin.x + normalized.x):
			_cells[_cell_index(Vector2i(column, row))] = item_key

	_reservations[item_key] = {
		"valid": true,
		"item_key": item_key,
		"origin": origin,
		"footprint": normalized,
		"rotated": rotated
	}

	_refresh_debug_occupancy()
	occupancy_changed.emit()
	return true


func release(item_key: String) -> bool:
	if not _reservations.has(item_key):
		return false

	for cell_index: int in range(_cells.size()):
		if _cells[cell_index] == item_key:
			_cells[cell_index] = ""

	_reservations.erase(item_key)
	_refresh_debug_occupancy()
	occupancy_changed.emit()
	return true


func clear_all() -> void:
	for cell_index: int in range(_cells.size()):
		_cells[cell_index] = ""
	_reservations.clear()
	_refresh_debug_occupancy()
	occupancy_changed.emit()


func get_reservation(item_key: String) -> Dictionary:
	if not _reservations.has(item_key):
		return {"valid": false}

	var value: Variant = _reservations[item_key]
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {"valid": false}


func get_local_placement_position(origin: Vector2i, footprint: Vector2i) -> Vector3:
	# The grid origin is the back-left corner in local X/Z terms. Step 5 may
	# choose a player-facing scan order for the placement ghost, but stored
	# coordinates remain deterministic.
	var normalized: Vector2i = _normalize_footprint(footprint)
	var half_width: float = usable_size_m.x * 0.5
	var half_depth: float = usable_size_m.y * 0.5

	var local_x: float = (
		-half_width
		+ (float(origin.x) + float(normalized.x) * 0.5) * cell_size_m
	)
	var local_z: float = (
		-half_depth
		+ (float(origin.y) + float(normalized.y) * 0.5) * cell_size_m
	)

	return Vector3(local_x, DEBUG_Y_OFFSET_M, local_z)


func get_local_placement_transform(item_key: String) -> Transform3D:
	var reservation: Dictionary = get_reservation(item_key)
	var valid_value: Variant = reservation.get("valid", false)
	if not bool(valid_value):
		return Transform3D.IDENTITY

	var origin_value: Variant = reservation.get("origin", Vector2i.ZERO)
	var footprint_value: Variant = reservation.get("footprint", Vector2i.ONE)
	var rotated_value: Variant = reservation.get("rotated", false)

	var origin: Vector2i = origin_value as Vector2i
	var footprint: Vector2i = footprint_value as Vector2i
	var rotated: bool = bool(rotated_value)

	var basis: Basis = Basis.IDENTITY
	if rotated:
		basis = Basis(Vector3.UP, deg_to_rad(90.0))

	return Transform3D(basis, get_local_placement_position(origin, footprint))


func set_debug_visible(value: bool) -> void:
	_debug_visible = value
	if _debug_grid != null:
		_debug_grid.visible = value
	if _debug_occupancy_root != null:
		_debug_occupancy_root.visible = value


func is_debug_visible() -> bool:
	return _debug_visible


func debug_summary() -> String:
	return "%s: %dx%d cells, %.2fm cell, %d reservation(s), %.0f%% occupied" % [
		String(surface_id),
		grid_size.x,
		grid_size.y,
		cell_size_m,
		get_reservation_count(),
		get_occupancy_ratio() * 100.0
	]


func _normalize_footprint(footprint: Vector2i) -> Vector2i:
	return Vector2i(maxi(1, footprint.x), maxi(1, footprint.y))


func _cell_index(cell: Vector2i) -> int:
	return cell.y * grid_size.x + cell.x


func _rebuild_interaction_area() -> void:
	if _interaction_area != null and is_instance_valid(_interaction_area):
		_interaction_area.queue_free()

	_interaction_area = Area3D.new()
	_interaction_area.name = "StorageInteractionArea"
	_interaction_area.collision_layer = STORAGE_INTERACTION_LAYER
	_interaction_area.collision_mask = 0
	_interaction_area.monitoring = false
	_interaction_area.monitorable = true
	add_child(_interaction_area)

	var shape_node: CollisionShape3D = CollisionShape3D.new()
	shape_node.name = "StorageInteractionShape"

	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = Vector3(
		usable_size_m.x,
		INTERACTION_THICKNESS_M,
		usable_size_m.y
	)
	shape_node.shape = box_shape
	shape_node.position = Vector3(0.0, INTERACTION_THICKNESS_M * 0.5, 0.0)
	_interaction_area.add_child(shape_node)


func _rebuild_debug_grid() -> void:
	if _debug_grid != null and is_instance_valid(_debug_grid):
		_debug_grid.queue_free()

	var immediate_mesh: ImmediateMesh = ImmediateMesh.new()
	var grid_material: StandardMaterial3D = StandardMaterial3D.new()
	grid_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	grid_material.albedo_color = Color(0.20, 0.92, 0.78, 0.50)
	grid_material.no_depth_test = true

	var half_width: float = usable_size_m.x * 0.5
	var half_depth: float = usable_size_m.y * 0.5

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, grid_material)

	for column: int in range(grid_size.x + 1):
		var x_value: float = -half_width + float(column) * cell_size_m
		immediate_mesh.surface_add_vertex(Vector3(x_value, DEBUG_Y_OFFSET_M, -half_depth))
		immediate_mesh.surface_add_vertex(Vector3(x_value, DEBUG_Y_OFFSET_M, half_depth))

	for row: int in range(grid_size.y + 1):
		var z_value: float = -half_depth + float(row) * cell_size_m
		immediate_mesh.surface_add_vertex(Vector3(-half_width, DEBUG_Y_OFFSET_M, z_value))
		immediate_mesh.surface_add_vertex(Vector3(half_width, DEBUG_Y_OFFSET_M, z_value))

	immediate_mesh.surface_end()

	_debug_grid = MeshInstance3D.new()
	_debug_grid.name = "StorageDebugGrid"
	_debug_grid.mesh = immediate_mesh
	_debug_grid.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_debug_grid.visible = _debug_visible
	add_child(_debug_grid)

	if _debug_occupancy_root == null:
		_debug_occupancy_root = Node3D.new()
		_debug_occupancy_root.name = "StorageDebugOccupancy"
		_debug_occupancy_root.visible = _debug_visible
		add_child(_debug_occupancy_root)


func _refresh_debug_occupancy() -> void:
	if _debug_occupancy_root == null:
		return

	for existing_child: Node in _debug_occupancy_root.get_children():
		existing_child.queue_free()

	var item_keys: Array = _reservations.keys()
	var marker_index: int = 0

	for item_key_value: Variant in item_keys:
		var item_key: String = String(item_key_value)
		var reservation: Dictionary = get_reservation(item_key)
		var valid_value: Variant = reservation.get("valid", false)
		if not bool(valid_value):
			continue

		var origin_value: Variant = reservation.get("origin", Vector2i.ZERO)
		var footprint_value: Variant = reservation.get("footprint", Vector2i.ONE)
		var origin: Vector2i = origin_value as Vector2i
		var footprint: Vector2i = footprint_value as Vector2i

		var marker_mesh: BoxMesh = BoxMesh.new()
		marker_mesh.size = Vector3(
			float(footprint.x) * cell_size_m * 0.92,
			0.018,
			float(footprint.y) * cell_size_m * 0.92
		)

		var marker_material: StandardMaterial3D = StandardMaterial3D.new()
		marker_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		marker_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

		var hue: float = fmod(0.08 + float(marker_index) * 0.17, 1.0)
		var base_color: Color = Color.from_hsv(hue, 0.72, 1.0, 0.48)
		marker_material.albedo_color = base_color
		marker_material.no_depth_test = true
		marker_mesh.material = marker_material

		var marker: MeshInstance3D = MeshInstance3D.new()
		marker.name = "Occupied_%s" % item_key
		marker.mesh = marker_mesh
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		marker.position = get_local_placement_position(origin, footprint) + Vector3(0.0, 0.012, 0.0)
		_debug_occupancy_root.add_child(marker)

		marker_index += 1

	_debug_occupancy_root.visible = _debug_visible
