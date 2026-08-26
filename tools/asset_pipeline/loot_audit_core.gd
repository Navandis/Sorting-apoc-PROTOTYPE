extends RefCounted
class_name LootAuditCore

const SCALE_TOLERANCE: float = 0.01
const VERY_SMALL_LONGEST_M: float = 0.05
const VERY_LARGE_LONGEST_M: float = 2.5
const EXTREME_ASPECT_RATIO: float = 8.0
const OFF_CENTER_MIN_M: float = 0.10
const OFF_CENTER_LONGEST_FRACTION: float = 0.25

const IRREGULAR_PATH_FAMILIES: PackedStringArray = [
	"rifle",
	"shotgun",
	"boots",
	"pants",
	"armor",
	"hardhat",
	"fuel",
	"gascan",
	"gascylinder",
	"propane",
	"firewood",
	"computer",
	"electronic",
	"pigcarcass",
	"pig_carcass"
]


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


static func folder_category_hint(source_path: String) -> String:
	var parts: PackedStringArray = source_path.split("/", false)
	for part_index: int in range(parts.size() - 1):
		if parts[part_index].to_lower() == "props":
			return parts[part_index + 1]
	return ""


static func threshold_metadata() -> Dictionary:
	return {
		"scale_tolerance": SCALE_TOLERANCE,
		"very_small_longest_m": VERY_SMALL_LONGEST_M,
		"very_large_longest_m": VERY_LARGE_LONGEST_M,
		"extreme_aspect_ratio": EXTREME_ASPECT_RATIO,
		"off_center_min_m": OFF_CENTER_MIN_M,
		"off_center_longest_fraction": OFF_CENTER_LONGEST_FRACTION
	}


static func audit_flags(input: Dictionary) -> PackedStringArray:
	var flags: PackedStringArray = []
	var root_scale_value: Variant = input.get("root_scale", Vector3.ONE)
	var root_scale: Vector3 = _absolute_scale(root_scale_value as Vector3)
	var instance_scales_value: Variant = input.get("instance_scales", [])
	var instance_scales: Array = instance_scales_value as Array
	var mesh_count: int = int(input.get("mesh_count", 0))
	var authored_category: String = String(input.get("authored_category", ""))
	var folder_category_hint: String = String(input.get("folder_category_hint", ""))
	var has_item_definition: bool = bool(input.get("has_item_definition", false))

	if _has_non_unit_scale(root_scale):
		flags.append("NON_UNIT_ROOT_SCALE")
	if _has_non_uniform_scale(root_scale):
		flags.append("NON_UNIFORM_SCALE")
	if _has_non_unit_instance_scale(instance_scales):
		flags.append("NON_UNIT_INSTANCE_SCALE")
	if _has_instance_scale_variance(instance_scales):
		flags.append("INSTANCE_SCALE_VARIANCE")
	if mesh_count > 1:
		flags.append("MULTI_MESH")
	if mesh_count <= 0:
		flags.append("NO_MESH_FOUND")

	if authored_category.strip_edges().is_empty() and folder_category_hint.strip_edges().is_empty():
		flags.append("CATEGORY_UNKNOWN")
	elif not authored_category.strip_edges().is_empty() and not folder_category_hint.strip_edges().is_empty():
		if authored_category.to_lower() != folder_category_hint.to_lower():
			flags.append("CATEGORY_FOLDER_MISMATCH")

	if not has_item_definition:
		flags.append("NO_ITEM_DEFINITION")

	if mesh_count > 0:
		var bounds_value: Variant = input.get("effective_bounds", AABB())
		var bounds: AABB = bounds_value as AABB
		var dimensions: Vector3 = bounds.size.abs()
		var longest_dimension: float = maxf(dimensions.x, maxf(dimensions.y, dimensions.z))
		var shortest_dimension: float = minf(dimensions.x, minf(dimensions.y, dimensions.z))
		var center: Vector3 = bounds.position + dimensions * 0.5
		var center_offset: float = center.length()

		if longest_dimension < VERY_SMALL_LONGEST_M:
			flags.append("VERY_SMALL")
		if longest_dimension > VERY_LARGE_LONGEST_M:
			flags.append("VERY_LARGE")
		if shortest_dimension > 0.000001:
			var aspect_ratio: float = longest_dimension / shortest_dimension
			if aspect_ratio >= EXTREME_ASPECT_RATIO:
				flags.append("EXTREME_ASPECT_RATIO")
		if center_offset > maxf(
			OFF_CENTER_MIN_M,
			longest_dimension * OFF_CENTER_LONGEST_FRACTION
		):
			flags.append("OFF_CENTER_BOUNDS")

		var footprint_value: Variant = input.get("existing_footprint", Vector3i.ZERO)
		var existing_footprint: Vector3i = footprint_value as Vector3i
		var raw_width_cells: int = int(input.get("raw_width_cells", 0))
		var raw_depth_cells: int = int(input.get("raw_depth_cells", 0))
		if has_item_definition and (
			existing_footprint.x < raw_width_cells
			or existing_footprint.y < raw_depth_cells
		):
			flags.append("EXISTING_FOOTPRINT_SMALLER_THAN_RAW_BOUNDS")

	var source_path: String = String(input.get("source_path", "")).to_lower()
	if _is_irregular_path(source_path):
		flags.append("IRREGULAR_REVIEW")

	return flags


static func sort_records(records: Array[Dictionary]) -> Array[Dictionary]:
	var ordered: Array[Dictionary] = []
	for record: Dictionary in records:
		ordered.append(record.duplicate(true))
	ordered.sort_custom(_record_path_less_than)
	return ordered


static func _bounds_from_points(points: Array[Vector3]) -> AABB:
	if points.is_empty():
		return AABB()

	var minimum: Vector3 = points[0]
	var maximum: Vector3 = points[0]
	for point: Vector3 in points:
		minimum = minimum.min(point)
		maximum = maximum.max(point)

	return AABB(minimum, maximum - minimum)


static func _absolute_scale(scale: Vector3) -> Vector3:
	return Vector3(absf(scale.x), absf(scale.y), absf(scale.z))


static func _has_non_unit_scale(scale: Vector3) -> bool:
	return (
		absf(scale.x - 1.0) > SCALE_TOLERANCE
		or absf(scale.y - 1.0) > SCALE_TOLERANCE
		or absf(scale.z - 1.0) > SCALE_TOLERANCE
	)


static func _has_non_uniform_scale(scale: Vector3) -> bool:
	return (
		absf(scale.x - scale.y) > SCALE_TOLERANCE
		or absf(scale.x - scale.z) > SCALE_TOLERANCE
		or absf(scale.y - scale.z) > SCALE_TOLERANCE
	)


static func _has_non_unit_instance_scale(instance_scales: Array) -> bool:
	for scale_value: Variant in instance_scales:
		if scale_value is Vector3 and _has_non_unit_scale(_absolute_scale(scale_value as Vector3)):
			return true
	return false


static func _has_instance_scale_variance(instance_scales: Array) -> bool:
	if instance_scales.size() < 2 or not (instance_scales[0] is Vector3):
		return false

	var baseline: Vector3 = _absolute_scale(instance_scales[0] as Vector3)
	for scale_index: int in range(1, instance_scales.size()):
		var scale_value: Variant = instance_scales[scale_index]
		if not (scale_value is Vector3):
			continue
		var current: Vector3 = _absolute_scale(scale_value as Vector3)
		if (
			absf(current.x - baseline.x) > SCALE_TOLERANCE
			or absf(current.y - baseline.y) > SCALE_TOLERANCE
			or absf(current.z - baseline.z) > SCALE_TOLERANCE
		):
			return true
	return false


static func _is_irregular_path(source_path: String) -> bool:
	for family: String in IRREGULAR_PATH_FAMILIES:
		if source_path.contains(family):
			return true
	return false


static func _record_path_less_than(left: Dictionary, right: Dictionary) -> bool:
	var left_path: String = String(left.get("source_path", ""))
	var right_path: String = String(right.get("source_path", ""))
	var left_normalized: String = left_path.to_lower()
	var right_normalized: String = right_path.to_lower()
	if left_normalized == right_normalized:
		return left_path < right_path
	return left_normalized < right_normalized
