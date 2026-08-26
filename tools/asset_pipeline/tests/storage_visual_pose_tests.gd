extends SceneTree

const StorageVisualPoseScript = preload("res://storage_visual_pose.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")
const ItemDefinitionScript = preload("res://item_definition.gd")
const ItemInstanceScript = preload("res://item_instance.gd")

const EPSILON: float = 0.0001


func _init() -> void:
	_test_authored_pose_is_applied_before_seating_and_centering()
	_test_zero_pose_preserves_canonical_alignment()
	_test_packing_yaw_rotates_only_the_outer_root()
	_test_parent_world_transform_does_not_change_stored_base_pose()
	_test_controller_delegates_manual_and_auto_to_the_same_base_pose()
	print("PASS: storage visual pose tests")
	quit(0)


# Catches seating canonical bounds first and rotating the already-seated visual.
func _test_authored_pose_is_applied_before_seating_and_centering() -> void:
	var packing_root: Node3D = Node3D.new()
	root.add_child(packing_root)
	var visual: Node3D = _asymmetric_visual()
	var result: Dictionary = StorageVisualPoseScript.build_visual(
		packing_root,
		visual,
		Vector3(0.0, 0.0, 90.0),
		false
	)

	assert(bool(result["valid"]))
	var posed_bounds: AABB = result["posed_bounds"] as AABB
	var aligned_bounds: AABB = result["aligned_bounds"] as AABB
	var seating_offset: Vector3 = result["seating_offset"] as Vector3
	assert(_vector3_approx(posed_bounds.position, Vector3(-4.0, 1.5, 2.5)))
	assert(_vector3_approx(posed_bounds.size, Vector3(2.0, 1.0, 3.0)))
	assert(_vector3_approx(seating_offset, Vector3(3.0, -1.494, -4.0)))
	assert(is_equal_approx(aligned_bounds.position.y, 0.006))
	assert(is_equal_approx(aligned_bounds.position.x + aligned_bounds.size.x * 0.5, 0.0))
	assert(is_equal_approx(aligned_bounds.position.z + aligned_bounds.size.z * 0.5, 0.0))
	packing_root.free()


# Catches regressions where the new hierarchy changes existing zero-rotation placement.
func _test_zero_pose_preserves_canonical_alignment() -> void:
	var packing_root: Node3D = Node3D.new()
	root.add_child(packing_root)
	var result: Dictionary = StorageVisualPoseScript.build_visual(
		packing_root,
		_asymmetric_visual(),
		Vector3.ZERO,
		false
	)

	var posed_bounds: AABB = result["posed_bounds"] as AABB
	var aligned_bounds: AABB = result["aligned_bounds"] as AABB
	assert(_vector3_approx(posed_bounds.position, Vector3(1.5, 2.0, 2.5)))
	assert(_vector3_approx(posed_bounds.size, Vector3(1.0, 2.0, 3.0)))
	assert(_vector3_approx(aligned_bounds.position, Vector3(-0.5, 0.006, -1.5)))
	packing_root.free()


# Catches counter-rotation or yaw being composed into the authored pose/seating roots.
func _test_packing_yaw_rotates_only_the_outer_root() -> void:
	var packing_root: Node3D = Node3D.new()
	root.add_child(packing_root)
	var result: Dictionary = StorageVisualPoseScript.build_visual(
		packing_root,
		_asymmetric_visual(),
		Vector3(10.0, 25.0, -35.0),
		true
	)

	var pose_root: Node3D = result["pose_root"] as Node3D
	var aligned_bounds: AABB = result["aligned_bounds"] as AABB
	var expected_pose: Basis = Basis.from_euler(Vector3(
		deg_to_rad(10.0), deg_to_rad(25.0), deg_to_rad(-35.0)
	)).orthonormalized()
	assert(_basis_approx(pose_root.basis, expected_pose))
	assert(_basis_approx(packing_root.basis, Basis(Vector3.UP, deg_to_rad(90.0))))
	assert(is_equal_approx(aligned_bounds.position.y, StorageVisualPoseScript.SHELF_CLEARANCE_M))
	packing_root.free()


# Catches deriving stored orientation from the particular receiving/world instance.
func _test_parent_world_transform_does_not_change_stored_base_pose() -> void:
	var parent_a: Node3D = Node3D.new()
	var parent_b: Node3D = Node3D.new()
	root.add_child(parent_a)
	root.add_child(parent_b)
	parent_a.transform = Transform3D(Basis.from_euler(Vector3(0.3, 0.7, -0.2)), Vector3(4.0, 8.0, -2.0))
	parent_b.transform = Transform3D(Basis.from_euler(Vector3(-1.1, 2.2, 0.9)), Vector3(-9.0, 1.0, 12.0))
	var packing_a: Node3D = Node3D.new()
	var packing_b: Node3D = Node3D.new()
	parent_a.add_child(packing_a)
	parent_b.add_child(packing_b)
	var result_a: Dictionary = StorageVisualPoseScript.build_visual(
		packing_a, _asymmetric_visual(), Vector3(90.0, 15.0, 0.0), false
	)
	var result_b: Dictionary = StorageVisualPoseScript.build_visual(
		packing_b, _asymmetric_visual(), Vector3(90.0, 15.0, 0.0), false
	)

	assert(_basis_approx(
		(result_a["pose_root"] as Node3D).basis,
		(result_b["pose_root"] as Node3D).basis
	))
	assert(_aabb_approx(result_a["posed_bounds"] as AABB, result_b["posed_bounds"] as AABB))
	assert(_vector3_approx(
		result_a["seating_offset"] as Vector3,
		result_b["seating_offset"] as Vector3
	))
	parent_a.free()
	parent_b.free()


# Catches ghost/final or manual/auto code paths applying different authored bases.
func _test_controller_delegates_manual_and_auto_to_the_same_base_pose() -> void:
	var controller: Node3D = StoragePlacementControllerScript.new()
	root.add_child(controller)
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.storage_rotation_degrees = Vector3(90.0, 15.0, 0.0)
	var item: ItemInstance = ItemInstanceScript.new(definition)
	var auto_root: Node3D = Node3D.new()
	var manual_root: Node3D = Node3D.new()
	controller.add_child(auto_root)
	controller.add_child(manual_root)
	var auto_result: Dictionary = controller.call(
		"build_visual_pose_for_item", auto_root, _asymmetric_visual(), item, false
	) as Dictionary
	var manual_result: Dictionary = controller.call(
		"build_visual_pose_for_item", manual_root, _asymmetric_visual(), item, true
	) as Dictionary

	assert(_basis_approx(
		(auto_result["pose_root"] as Node3D).basis,
		(manual_result["pose_root"] as Node3D).basis
	))
	assert(_aabb_approx(
		auto_result["posed_bounds"] as AABB,
		manual_result["posed_bounds"] as AABB
	))
	assert(_basis_approx(auto_root.basis, Basis.IDENTITY))
	assert(_basis_approx(manual_root.basis, Basis(Vector3.UP, deg_to_rad(90.0))))
	controller.free()


func _asymmetric_visual() -> Node3D:
	var visual: Node3D = Node3D.new()
	var contributor: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(1.0, 2.0, 3.0)
	contributor.mesh = mesh
	contributor.position = Vector3(2.0, 3.0, 4.0)
	visual.add_child(contributor)
	return visual


func _vector3_approx(left: Vector3, right: Vector3) -> bool:
	return left.is_equal_approx(right) or left.distance_to(right) <= EPSILON


func _basis_approx(left: Basis, right: Basis) -> bool:
	return (
		_vector3_approx(left.x, right.x)
		and _vector3_approx(left.y, right.y)
		and _vector3_approx(left.z, right.z)
	)


func _aabb_approx(left: AABB, right: AABB) -> bool:
	return _vector3_approx(left.position, right.position) and _vector3_approx(left.size, right.size)
