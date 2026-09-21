extends SceneTree

const StorageItemOrientation = preload("res://storage_item_orientation.gd")

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_asymmetric_footprints()
	_check_square_footprints()
	_check_yaws()
	_finish()


func _check_asymmetric_footprints() -> void:
	var cases := [
		{
			"canonical": Vector2i(2, 1),
			"expected": [
				[Vector2i(2, 1), Vector2i(1, 2)],
				[Vector2i(1, 2), Vector2i(2, 1)],
				[Vector2i(2, 1), Vector2i(1, 2)],
				[Vector2i(1, 2), Vector2i(2, 1)],
			],
		},
		{
			"canonical": Vector2i(3, 2),
			"expected": [
				[Vector2i(3, 2), Vector2i(2, 3)],
				[Vector2i(2, 3), Vector2i(3, 2)],
				[Vector2i(3, 2), Vector2i(2, 3)],
				[Vector2i(2, 3), Vector2i(3, 2)],
			],
		},
	]
	for case: Dictionary in cases:
		var canonical: Vector2i = case["canonical"]
		var expected: Array = case["expected"]
		for state: int in range(4):
			_check(
				StorageItemOrientation.physical_footprint(
					canonical,
					state,
					false
				) == expected[state][0],
				"state %d canonical footprint %s" % [state, canonical]
			)
			_check(
				StorageItemOrientation.physical_footprint(
					canonical,
					state,
					true
				) == expected[state][1],
				"state %d packing footprint %s" % [state, canonical]
			)
			_check(
				StorageItemOrientation.placement_quarter_turns(
					state,
					false
				) == state,
				"state %d canonical quarter-turn" % state
			)
			_check(
				StorageItemOrientation.placement_quarter_turns(
					state,
					true
				) == ((state + 1) % 4),
				"state %d packing quarter-turn" % state
			)


func _check_square_footprints() -> void:
	for state: int in range(4):
		for packing_rotated: bool in [false, true]:
			_check(
				StorageItemOrientation.physical_footprint(
					Vector2i(2, 2),
					state,
					packing_rotated
				) == Vector2i(2, 2),
				"square footprint remains square for state %d packing %s"
				% [state, packing_rotated]
			)


func _check_yaws() -> void:
	for state: int in range(4):
		var canonical_degrees := rad_to_deg(
			StorageItemOrientation.placement_yaw_radians(state, false)
		)
		var packing_degrees := rad_to_deg(
			StorageItemOrientation.placement_yaw_radians(state, true)
		)
		_check(
			is_equal_approx(canonical_degrees, float(state * 90)),
			"state %d canonical yaw" % state
		)
		_check(
			is_equal_approx(packing_degrees, float(((state + 1) % 4) * 90)),
			"state %d packing yaw" % state
		)
		_check(
			is_equal_approx(
				rad_to_deg(StorageItemOrientation.unit_yaw_radians(state)),
				float(state * 90)
			),
			"state %d unit yaw" % state
		)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)


func _finish() -> void:
	if _failed:
		push_error("FAIL: storage item orientation tests")
		quit(1)
		return
	print("PASS: storage item orientation tests")
	quit(0)
