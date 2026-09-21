extends SceneTree

const Orientation = preload("res://storage_orientation.gd")

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_normalization()
	for size: Vector2i in [Vector2i(8, 3), Vector2i(3, 8), Vector2i(7, 7)]:
		for state: int in range(4):
			_check_dimensions(size, state)
			_check_round_trip(size, state)
	_check_exact_corners(Vector2i(8, 3))
	_check_axes_and_labels()
	_finish()


func _check_normalization() -> void:
	_check(Orientation.normalize_quarter_turns(-1) == 3, "-1 normalizes to 3")
	_check(Orientation.normalize_quarter_turns(4) == 0, "4 normalizes to 0")
	_check(Orientation.normalize_quarter_turns(9) == 1, "9 normalizes to 1")


func _check_dimensions(size: Vector2i, state: int) -> void:
	var expected := size if state in [0, 2] else Vector2i(size.y, size.x)
	_check(
		Orientation.semantic_grid_size(size, state) == expected,
		"state %d semantic size %s -> %s" % [state, size, expected]
	)


func _check_round_trip(size: Vector2i, state: int) -> void:
	var semantic_size: Vector2i = Orientation.semantic_grid_size(size, state)
	for z: int in range(size.y):
		for x: int in range(size.x):
			var physical := Vector2i(x, z)
			var semantic: Vector2i = Orientation.physical_to_semantic_cell(
				physical,
				size,
				state
			)
			_check(
				Orientation.semantic_to_physical_cell(semantic, size, state) == physical,
				"physical round-trip %s state %d" % [physical, state]
			)
	for v: int in range(semantic_size.y):
		for u: int in range(semantic_size.x):
			var semantic := Vector2i(u, v)
			var physical: Vector2i = Orientation.semantic_to_physical_cell(
				semantic,
				size,
				state
			)
			_check(
				Orientation.physical_to_semantic_cell(physical, size, state) == semantic,
				"semantic round-trip %s state %d" % [semantic, state]
			)


func _check_exact_corners(size: Vector2i) -> void:
	var w := size.x
	var d := size.y
	var semantic_sizes := [
		Vector2i(w, d),
		Vector2i(d, w),
		Vector2i(w, d),
		Vector2i(d, w),
	]
	var expected_back_left := [
		Vector2i(0, 0),
		Vector2i(0, d - 1),
		Vector2i(w - 1, d - 1),
		Vector2i(w - 1, 0),
	]
	var expected_front_right := [
		Vector2i(w - 1, d - 1),
		Vector2i(w - 1, 0),
		Vector2i(0, 0),
		Vector2i(0, d - 1),
	]
	for state: int in range(4):
		var semantic_size: Vector2i = semantic_sizes[state]
		_check(
			Orientation.semantic_to_physical_cell(Vector2i.ZERO, size, state)
			== expected_back_left[state],
			"state %d back-left mapping" % state
		)
		_check(
			Orientation.semantic_to_physical_cell(
				semantic_size - Vector2i.ONE,
				size,
				state
			) == expected_front_right[state],
			"state %d front-right mapping" % state
		)


func _check_axes_and_labels() -> void:
	var expected_fronts := [
		Vector3(0, 0, 1),
		Vector3(1, 0, 0),
		Vector3(0, 0, -1),
		Vector3(-1, 0, 0),
	]
	var expected_rights := [
		Vector3(1, 0, 0),
		Vector3(0, 0, -1),
		Vector3(-1, 0, 0),
		Vector3(0, 0, 1),
	]
	var expected_labels := [
		"Front +Z / Right +X",
		"Front +X / Right -Z",
		"Front -Z / Right -X",
		"Front -X / Right +Z",
	]
	for state: int in range(4):
		_check(
			Orientation.front_local_axis(state) == expected_fronts[state],
			"state %d front axis" % state
		)
		_check(
			Orientation.right_local_axis(state) == expected_rights[state],
			"state %d right axis" % state
		)
		_check(
			Orientation.orientation_label(state) == expected_labels[state],
			"state %d orientation label" % state
		)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)


func _finish() -> void:
	if _failed:
		push_error("FAIL: storage orientation tests")
		quit(1)
		return
	print("PASS: storage orientation tests")
	quit(0)
