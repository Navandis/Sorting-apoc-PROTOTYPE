extends SceneTree

const LADDER_SCENE := "res://gameplay/traversal/fixed_ladder/fixed_ladder.tscn"
const LADDER_VISUAL := "res://assets/environment/furniture/storage/SM_Ind_War_Equipment_Ladder_Metal_Worn_01.glb"
const EPSILON := 0.003

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check(ResourceLoader.exists(LADDER_SCENE), "FixedLadder scene exists"):
		_finish()
		return
	var packed := load(LADDER_SCENE) as PackedScene
	var ladder := packed.instantiate() as Node3D if packed != null else null
	if not _check(ladder != null, "FixedLadder scene instantiates"):
		_finish()
		return
	root.add_child(ladder)
	_test_scene_contract(ladder)
	_test_height_drives_visual_collision_and_markers(ladder)
	_test_invalid_authoring_states_report(ladder)
	ladder.free()
	_test_instance_independence(packed)
	_finish()


func _test_scene_contract(ladder: Node3D) -> void:
	_check(
		ladder.get_script() != null
		and String(ladder.get_script().get_global_name()) == "FixedLadder",
		"root is the global FixedLadder class"
	)
	for path: String in [
		"Visual/Source",
		"MovementCollision/Shape",
		"ApproachArea/Shape",
		"ClimbAnchor",
		"LadderTop",
		"OverheadLimit",
		"AuthoringPreview",
	]:
		_check(ladder.get_node_or_null(path) != null, "FixedLadder owns %s" % path)
	var source := ladder.get_node_or_null("Visual/Source") as Node
	_check(
		source != null and source.scene_file_path == LADDER_VISUAL,
		"current ladder GLB is normalized beneath Visual"
	)
	var movement := ladder.get_node("MovementCollision") as StaticBody3D
	var approach := ladder.get_node("ApproachArea") as Area3D
	_check(
		movement.collision_layer != 0
		and (movement.collision_layer & ((1 << 7) | (1 << 8))) == 0,
		"movement collider stays off item and storage interaction layers"
	)
	_check(
		(approach.collision_layer & ((1 << 7) | (1 << 8))) == 0,
		"approach area stays off item and storage interaction layers"
	)


func _test_height_drives_visual_collision_and_markers(ladder: Node3D) -> void:
	ladder.set("show_authoring_preview", true)
	ladder.set("overhead_limit_local_y_m", 3.40)
	ladder.set("ladder_height_m", 2.20)
	ladder.call("refresh_authoring_state")
	var short_bounds := _branch_bounds(ladder, ladder.get_node("Visual") as Node3D)
	var short_box := (ladder.get_node("MovementCollision/Shape") as CollisionShape3D).shape as BoxShape3D
	var short_size := short_box.size
	var approach_shape := ladder.get_node("ApproachArea/Shape") as CollisionShape3D
	var approach_box := approach_shape.shape as BoxShape3D
	var short_approach_size := approach_box.size
	var short_approach_position := approach_shape.position

	_check(_near(short_bounds.position.y, 0.0, 0.01), "normalized visual begins at floor level")
	_check(_near(short_bounds.size.y, 2.20, 0.01), "visual height follows ladder_height_m")
	_check(_near(short_size.y, 2.20), "movement-collision height follows ladder_height_m")
	_check(_near((ladder.get_node("LadderTop") as Marker3D).position.y, 2.20), "top marker follows ladder height")
	_check(_near((ladder.get_node("OverheadLimit") as Marker3D).position.y, 3.40), "overhead marker follows authored overhead")
	var preview_mesh := (ladder.get_node("AuthoringPreview/LadderEnvelope") as MeshInstance3D).mesh as BoxMesh
	_check(_near(preview_mesh.size.y, 2.20), "authoring preview follows ladder height")

	ladder.set("ladder_height_m", 3.05)
	ladder.call("refresh_authoring_state")
	var tall_bounds := _branch_bounds(ladder, ladder.get_node("Visual") as Node3D)
	var tall_box := (ladder.get_node("MovementCollision/Shape") as CollisionShape3D).shape as BoxShape3D
	var tall_approach_shape := ladder.get_node("ApproachArea/Shape") as CollisionShape3D
	var tall_approach_box := tall_approach_shape.shape as BoxShape3D
	_check(_near(tall_bounds.size.y, 3.05, 0.01), "changed height resizes the visual")
	_check(_near(tall_box.size.y, 3.05), "changed height resizes movement collision")
	_check(_near(tall_bounds.size.x, short_bounds.size.x), "functional visual width stays common across heights")
	_check(_near(tall_bounds.size.z, short_bounds.size.z), "functional visual depth stays common across heights")
	_check(_near(tall_box.size.x, short_size.x) and _near(tall_box.size.z, short_size.z), "movement width/depth stay common across heights")
	_check(tall_approach_box.size.is_equal_approx(short_approach_size), "approach region does not grow with ladder height")
	_check(tall_approach_shape.position.is_equal_approx(short_approach_position), "approach region remains at the bottom/front")
	_check(tall_approach_shape.position.z > 0.0, "approach region is on normalized +Z front")


func _test_invalid_authoring_states_report(ladder: Node3D) -> void:
	ladder.scale = Vector3(1.1, 1.0, 1.0)
	_check(not (ladder.call("_get_configuration_warnings") as PackedStringArray).is_empty(), "non-unit root scale warns")
	ladder.scale = Vector3.ONE
	ladder.rotation.x = 0.1
	_check(not (ladder.call("_get_configuration_warnings") as PackedStringArray).is_empty(), "root pitch warns")
	ladder.rotation.x = 0.0
	ladder.rotation.z = 0.1
	_check(not (ladder.call("_get_configuration_warnings") as PackedStringArray).is_empty(), "root roll warns")
	ladder.rotation.z = 0.0
	ladder.set("ladder_height_m", 2.60)
	ladder.set("overhead_limit_local_y_m", 1.00)
	var limits := ladder.call("get_player_root_climb_limits", 1.716, 1.75) as Dictionary
	_check(not bool(limits.get("valid", true)), "body-sized unusable climb range reports invalid")
	_check(not String(limits.get("reason", "")).is_empty(), "unusable climb range reports a clear reason")


func _test_instance_independence(packed: PackedScene) -> void:
	var first := packed.instantiate() as Node3D
	var second := packed.instantiate() as Node3D
	root.add_child(first)
	root.add_child(second)
	first.set("ladder_height_m", 2.10)
	second.set("ladder_height_m", 3.00)
	first.call("refresh_authoring_state")
	second.call("refresh_authoring_state")
	var first_shape := (first.get_node("MovementCollision/Shape") as CollisionShape3D).shape as BoxShape3D
	var second_shape := (second.get_node("MovementCollision/Shape") as CollisionShape3D).shape as BoxShape3D
	_check(first_shape != second_shape, "instances own independent collision resources")
	_check(_near(first_shape.size.y, 2.10) and _near(second_shape.size.y, 3.00), "instances retain independent authored heights")
	first.free()
	second.free()


func _branch_bounds(owner: Node3D, branch: Node3D) -> AABB:
	var result := AABB()
	var valid := false
	for value: Node in branch.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := value as MeshInstance3D
		if mesh_node.mesh == null:
			continue
		var bounds := owner.global_transform.affine_inverse() * (mesh_node.global_transform * mesh_node.get_aabb())
		result = result.merge(bounds) if valid else bounds
		valid = true
	return result


func _near(actual: float, expected: float, epsilon: float = EPSILON) -> bool:
	return absf(actual - expected) <= epsilon


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false


func _finish() -> void:
	if _failed:
		quit(1)
	else:
		print("PASS: fixed ladder authoring tests")
		quit(0)
