extends RefCounted
class_name StorageItemOrientation

const StorageOrientationScript = preload("res://storage_orientation.gd")


static func placement_quarter_turns(
	unit_orientation_quarter_turns: int,
	packing_rotated: bool
) -> int:
	return StorageOrientationScript.normalize_quarter_turns(
		unit_orientation_quarter_turns + (1 if packing_rotated else 0)
	)


static func physical_footprint(
	canonical_footprint: Vector2i,
	unit_orientation_quarter_turns: int,
	packing_rotated: bool
) -> Vector2i:
	var normalized := Vector2i(
		maxi(1, canonical_footprint.x),
		maxi(1, canonical_footprint.y)
	)
	var turns := placement_quarter_turns(
		unit_orientation_quarter_turns,
		packing_rotated
	)
	return (
		normalized
		if turns % 2 == 0
		else Vector2i(normalized.y, normalized.x)
	)


static func unit_yaw_radians(unit_orientation_quarter_turns: int) -> float:
	return deg_to_rad(float(
		StorageOrientationScript.normalize_quarter_turns(
			unit_orientation_quarter_turns
		) * 90
	))


static func placement_yaw_radians(
	unit_orientation_quarter_turns: int,
	packing_rotated: bool
) -> float:
	return deg_to_rad(float(
		placement_quarter_turns(
			unit_orientation_quarter_turns,
			packing_rotated
		) * 90
	))
