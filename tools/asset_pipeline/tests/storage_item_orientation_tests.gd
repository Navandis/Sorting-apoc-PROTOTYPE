extends SceneTree

const StorageItemOrientation = preload("res://storage_item_orientation.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")
const ItemDefinitionScript = preload("res://item_definition.gd")
const ItemInstanceScript = preload("res://item_instance.gd")

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_asymmetric_footprints()
	_check_square_footprints()
	_check_yaws()
	_check_controller_entries_follow_unit_state()
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


# Catches the controller reserving canonical dimensions in physical X/Z at
# odd unit orientations while the visual receives an outer quarter-turn.
func _check_controller_entries_follow_unit_state() -> void:
	var controller := StoragePlacementControllerScript.new()
	root.add_child(controller)
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.storage_footprint = Vector3i(2, 1, 1)
	definition.visual_scene = _packed_asymmetric_visual()
	var item: ItemInstance = ItemInstanceScript.new(definition)
	var entry_argument_count := -1
	for method: Dictionary in controller.get_method_list():
		if String(method.get("name", "")) == "_entry_for_item":
			entry_argument_count = (method.get("args", []) as Array).size()
			break
	_check(
		entry_argument_count == 3,
		"controller entry builder accepts unit orientation state"
	)
	if entry_argument_count != 3:
		controller.free()
		return

	var state0: Variant = controller.call("_entry_for_item", item, false, 0)
	var state1: Variant = controller.call("_entry_for_item", item, false, 1)
	var state1_rotated: Variant = controller.call("_entry_for_item", item, true, 1)
	_check(state0 != null, "state 0 controller entry exists")
	_check(state1 != null, "state 1 controller entry exists")
	_check(state1_rotated != null, "state 1 packing controller entry exists")
	if state0 != null and state1 != null and state1_rotated != null:
		_check(state0.footprint == Vector2i(2, 1), "state 0 entry is 2x1")
		_check(state1.footprint == Vector2i(1, 2), "state 1 entry is 1x2")
		_check(
			state1_rotated.footprint == Vector2i(2, 1),
			"state 1 packing entry returns to 2x1"
		)
		_check(not state1.packing_rotated, "canonical entry remains unrotated")
		_check(state1_rotated.packing_rotated, "packing entry records rotation")
	controller.free()


func _packed_asymmetric_visual() -> PackedScene:
	var visual := Node3D.new()
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.2, 0.4, 0.1)
	mesh_instance.mesh = mesh
	visual.add_child(mesh_instance)
	mesh_instance.owner = visual
	var packed := PackedScene.new()
	var result := packed.pack(visual)
	assert(result == OK)
	visual.free()
	return packed


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
