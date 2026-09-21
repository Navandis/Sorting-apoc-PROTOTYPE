extends RefCounted
class_name StorageOrientation


static func normalize_quarter_turns(value: int) -> int:
	return posmod(value, 4)


static func semantic_grid_size(
	physical_size: Vector2i,
	quarter_turns: int
) -> Vector2i:
	var state := normalize_quarter_turns(quarter_turns)
	return (
		physical_size
		if state == 0 or state == 2
		else Vector2i(physical_size.y, physical_size.x)
	)


static func semantic_to_physical_cell(
	semantic_cell: Vector2i,
	physical_size: Vector2i,
	quarter_turns: int
) -> Vector2i:
	var state := normalize_quarter_turns(quarter_turns)
	var w := physical_size.x
	var d := physical_size.y
	var u := semantic_cell.x
	var v := semantic_cell.y
	match state:
		0:
			return Vector2i(u, v)
		1:
			return Vector2i(v, d - 1 - u)
		2:
			return Vector2i(w - 1 - u, d - 1 - v)
		3:
			return Vector2i(w - 1 - v, u)
	return Vector2i(-1, -1)


static func physical_to_semantic_cell(
	physical_cell: Vector2i,
	physical_size: Vector2i,
	quarter_turns: int
) -> Vector2i:
	var state := normalize_quarter_turns(quarter_turns)
	var w := physical_size.x
	var d := physical_size.y
	var x := physical_cell.x
	var z := physical_cell.y
	match state:
		0:
			return Vector2i(x, z)
		1:
			return Vector2i(d - 1 - z, x)
		2:
			return Vector2i(w - 1 - x, d - 1 - z)
		3:
			return Vector2i(z, w - 1 - x)
	return Vector2i(-1, -1)


static func front_local_axis(quarter_turns: int) -> Vector3:
	return [
		Vector3(0, 0, 1),
		Vector3(1, 0, 0),
		Vector3(0, 0, -1),
		Vector3(-1, 0, 0),
	][normalize_quarter_turns(quarter_turns)]


static func right_local_axis(quarter_turns: int) -> Vector3:
	return [
		Vector3(1, 0, 0),
		Vector3(0, 0, -1),
		Vector3(-1, 0, 0),
		Vector3(0, 0, 1),
	][normalize_quarter_turns(quarter_turns)]


static func orientation_label(quarter_turns: int) -> String:
	return [
		"Front +Z / Right +X",
		"Front +X / Right -Z",
		"Front -Z / Right -X",
		"Front -X / Right +Z",
	][normalize_quarter_turns(quarter_turns)]
