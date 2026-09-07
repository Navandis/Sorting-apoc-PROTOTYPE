extends RefCounted
class_name StorageVisualPose

## Visual-only storage pose construction and posed-bounds alignment.
## Reservation, zoning, fit selection, and inventory transfer remain owned by
## StoragePlacementController and StorageSurface.

const SHELF_CLEARANCE_M: float = 0.006


static func measure_item(item: ItemInstance, packing_rotated: bool) -> Dictionary:
	if item == null:
		return _invalid_result()
	var visual_scene: PackedScene = item.get_visual_scene()
	if visual_scene == null:
		return _invalid_result()

	var packing_root: Node3D = Node3D.new()
	var visual: Node = visual_scene.instantiate()
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
