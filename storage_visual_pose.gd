extends RefCounted
class_name StorageVisualPose

## Visual-only storage pose construction and posed-bounds alignment.
## Reservation, zoning, fit selection, and inventory transfer remain owned by
## StoragePlacementController and StorageSurface.

const SHELF_CLEARANCE_M: float = 0.006

# Only immutable imported runtime loot participates. Editor authoring and
# procedural meshes always scan. Keep resources alive to prevent identity reuse;
# neither an item ID nor a path identifies geometry. The complete local transform
# includes authored pose/scale and every nested node, before outer packing yaw.
const MIN_Y_CACHE_LIMIT: int = 512
static var _mesh_min_y_cache: Dictionary = {}
static var _measurement_entries: int = 0
static var _measurement_hits: int = 0
static var _measurement_misses: int = 0
static var _measurement_vertex_visits: int = 0
static var _measurement_bypasses: int = 0


static func measure_item(item: ItemInstance, packing_rotated: bool) -> Dictionary:
	if item == null:
		return _invalid_result()
	var visual_scene: PackedScene = item.get_visual_scene()
	if visual_scene == null:
		return _invalid_result()

	var packing_root: Node3D = Node3D.new()
	var visual: Node = visual_scene.instantiate()
	item.definition.apply_visual_scale(visual)
	var result: Dictionary = build_visual(
		packing_root,
		visual,
		item.get_storage_rotation_degrees(),
		packing_rotated
	)
	var snapshot: Dictionary = {
		"valid": bool(result.get("valid", false)),
		"posed_bounds": result.get("posed_bounds", AABB()),
		"aligned_bounds": result.get("aligned_bounds", AABB()),
		"seating_offset": result.get("seating_offset", Vector3.ZERO),
		"packing_basis": result.get("packing_basis", Basis.IDENTITY)
	}
	packing_root.free()
	return snapshot


static func build_visual(
	packing_root: Node3D,
	visual: Node,
	storage_rotation_degrees: Vector3,
	packing_rotated: bool
) -> Dictionary:
	if packing_root == null or visual == null:
		return _invalid_result()

	apply_packing_yaw(packing_root, packing_rotated)

	var seating_root: Node3D = Node3D.new()
	seating_root.name = "StorageSeating"
	packing_root.add_child(seating_root)

	var pose_root: Node3D = Node3D.new()
	pose_root.name = "AuthoredStoragePose"
	pose_root.rotation = Vector3(
		deg_to_rad(storage_rotation_degrees.x),
		deg_to_rad(storage_rotation_degrees.y),
		deg_to_rad(storage_rotation_degrees.z)
	)
	seating_root.add_child(pose_root)
	pose_root.add_child(visual)

	var state: Dictionary = {"valid": false, "bounds": AABB()}
	_scan_bounds_recursive(pose_root, Transform3D.IDENTITY, state)
	if not bool(state["valid"]):
		return {
			"valid": false,
			"posed_bounds": AABB(),
			"aligned_bounds": AABB(),
			"seating_offset": Vector3.ZERO,
			"packing_basis": packing_root.basis,
			"seating_root": seating_root,
			"pose_root": pose_root
		}

	var posed_bounds: AABB = state["bounds"] as AABB
	# A rotated mesh's enclosing box can contain empty space below every vertex.
	# Seat actual geometry vertically while retaining the accepted conservative
	# horizontal bounds/centering, authored pose, scale and reservation.
	if state.has("mesh_min_y"):
		var conservative_top := posed_bounds.end.y
		posed_bounds.position.y = float(state.mesh_min_y)
		posed_bounds.size.y = conservative_top - posed_bounds.position.y
	var posed_center: Vector3 = posed_bounds.position + posed_bounds.size * 0.5
	var seating_offset: Vector3 = Vector3(
		-posed_center.x,
		-posed_bounds.position.y + SHELF_CLEARANCE_M,
		-posed_center.z
	)
	seating_root.position = seating_offset

	return {
		"valid": true,
		"posed_bounds": posed_bounds,
		"aligned_bounds": AABB(posed_bounds.position + seating_offset, posed_bounds.size),
		"seating_offset": seating_offset,
		"packing_basis": packing_root.basis,
		"seating_root": seating_root,
		"pose_root": pose_root
	}


static func apply_packing_yaw(packing_root: Node3D, packing_rotated: bool) -> void:
	if packing_root == null:
		return
	packing_root.rotation = Vector3(
		0.0,
		deg_to_rad(90.0) if packing_rotated else 0.0,
		0.0
	)


static func _scan_bounds_recursive(
	node: Node,
	accumulated_transform: Transform3D,
	state: Dictionary
) -> void:
	var next_transform: Transform3D = accumulated_transform
	if node is Node3D:
		next_transform = accumulated_transform * (node as Node3D).transform

	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh != null:
			var minimum_y := _mesh_minimum_y(mesh_instance.mesh, next_transform)
			if minimum_y != INF:
				state["mesh_min_y"] = minf(float(state.get("mesh_min_y", INF)), minimum_y)
			var transformed_bounds: AABB = _transform_bounds(
				mesh_instance.mesh.get_aabb(),
				next_transform
			)
			if bool(state["valid"]):
				state["bounds"] = (state["bounds"] as AABB).merge(transformed_bounds)
			else:
				state["bounds"] = transformed_bounds
				state["valid"] = true

	for child: Node in node.get_children():
		_scan_bounds_recursive(child, next_transform, state)


static func _mesh_minimum_y(mesh: Mesh, transform: Transform3D) -> float:
	var reusable := (
		not Engine.is_editor_hint()
		and mesh is ArrayMesh
		and mesh.resource_path.get_slice("::", 0).get_extension().to_lower() == "glb"
		and mesh.resource_path.contains("::")
	)
	var mesh_id := mesh.get_instance_id()
	if reusable and _mesh_min_y_cache.has(mesh_id):
		var measurements: Dictionary = _mesh_min_y_cache[mesh_id].measurements
		if measurements.has(transform):
			_measurement_hits += 1
			return float(measurements[transform])
	_measurement_misses += 1
	if not reusable:
		_measurement_bypasses += 1
	var minimum_y := INF
	for surface: int in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		_measurement_vertex_visits += vertices.size()
		for vertex: Vector3 in vertices:
			minimum_y = minf(minimum_y, (transform * vertex).y)
	if reusable:
		if _measurement_entries >= MIN_Y_CACHE_LIMIT:
			clear_measurement_cache(false)
		if not _mesh_min_y_cache.has(mesh_id):
			_mesh_min_y_cache[mesh_id] = {"mesh": mesh, "measurements": {}}
			mesh.changed.connect(_invalidate_mesh_measurements.bind(mesh_id))
		_mesh_min_y_cache[mesh_id].measurements[transform] = minimum_y
		_measurement_entries += 1
	return minimum_y


static func _invalidate_mesh_measurements(mesh_id: int) -> void:
	if not _mesh_min_y_cache.has(mesh_id):
		return
	var entry: Dictionary = _mesh_min_y_cache[mesh_id]
	var mesh: Mesh = entry.mesh
	mesh.changed.disconnect(_invalidate_mesh_measurements.bind(mesh_id))
	_measurement_entries -= entry.measurements.size()
	_mesh_min_y_cache.erase(mesh_id)


static func clear_measurement_cache(reset_statistics: bool = true) -> void:
	# Runtime owners changing imported geometry must emit Resource.changed or clear
	# before reuse. GPU-only deformation without that signal is outside this static
	# loot contract. Editor/reimport work never uses this cache.
	for mesh_id: int in _mesh_min_y_cache.keys():
		_invalidate_mesh_measurements(mesh_id)
	if reset_statistics:
		_measurement_hits = 0
		_measurement_misses = 0
		_measurement_vertex_visits = 0
		_measurement_bypasses = 0


static func get_measurement_cache_stats() -> Dictionary:
	return {
		"entries": _measurement_entries,
		"meshes": _mesh_min_y_cache.size(),
		"hits": _measurement_hits,
		"misses": _measurement_misses,
		"vertex_visits": _measurement_vertex_visits,
		"bypasses": _measurement_bypasses,
	}


static func _transform_bounds(bounds: AABB, transform: Transform3D) -> AABB:
	var valid: bool = false
	var minimum: Vector3 = Vector3.ZERO
	var maximum: Vector3 = Vector3.ZERO
	for x_index: int in range(2):
		for y_index: int in range(2):
			for z_index: int in range(2):
				var corner: Vector3 = Vector3(
					bounds.position.x + bounds.size.x * float(x_index),
					bounds.position.y + bounds.size.y * float(y_index),
					bounds.position.z + bounds.size.z * float(z_index)
				)
				var transformed_corner: Vector3 = transform * corner
				if valid:
					minimum = minimum.min(transformed_corner)
					maximum = maximum.max(transformed_corner)
				else:
					minimum = transformed_corner
					maximum = transformed_corner
					valid = true
	return AABB(minimum, maximum - minimum)


static func _invalid_result() -> Dictionary:
	return {
		"valid": false,
		"posed_bounds": AABB(),
		"aligned_bounds": AABB(),
		"seating_offset": Vector3.ZERO,
		"packing_basis": Basis.IDENTITY,
		"seating_root": null,
		"pose_root": null
	}
