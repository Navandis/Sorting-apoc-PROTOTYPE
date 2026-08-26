extends RefCounted
class_name LootAuditCore


static func transform_bounds(bounds: AABB, transform: Transform3D) -> AABB:
	var points: Array[Vector3] = []
	for x_index: int in range(2):
		for y_index: int in range(2):
			for z_index: int in range(2):
				var point: Vector3 = Vector3(
					bounds.position.x + bounds.size.x * float(x_index),
					bounds.position.y + bounds.size.y * float(y_index),
					bounds.position.z + bounds.size.z * float(z_index)
				)
				points.append(transform * point)
	return _bounds_from_points(points)


static func aggregate_contributors(contributors: Array[Dictionary]) -> Dictionary:
	var valid: bool = false
	var aggregate: AABB = AABB()
	for contributor: Dictionary in contributors:
		var local_bounds: AABB = contributor["bounds"] as AABB
		var local_transform: Transform3D = contributor["transform"] as Transform3D
		var transformed: AABB = transform_bounds(local_bounds, local_transform)
		if valid:
			aggregate = aggregate.merge(transformed)
		else:
			aggregate = transformed
			valid = true
	return {
		"valid": valid,
		"bounds": aggregate,
		"mesh_count": contributors.size()
	}


static func raw_footprint(effective_size: Vector3, cell_size_m: float) -> Dictionary:
	var safe_cell_size_m: float = maxf(cell_size_m, 0.000001)
	var width_cells: int = maxi(1, int(ceil(effective_size.x / safe_cell_size_m)))
	var depth_cells: int = maxi(1, int(ceil(effective_size.z / safe_cell_size_m)))
	return {
		"width_cells": width_cells,
		"depth_cells": depth_cells,
		"orientation_a": "%dx%d" % [width_cells, depth_cells],
		"orientation_b": "%dx%d" % [depth_cells, width_cells]
	}


static func _bounds_from_points(points: Array[Vector3]) -> AABB:
	if points.is_empty():
		return AABB()

	var minimum: Vector3 = points[0]
	var maximum: Vector3 = points[0]
	for point: Vector3 in points:
		minimum = minimum.min(point)
		maximum = maximum.max(point)

	return AABB(minimum, maximum - minimum)
