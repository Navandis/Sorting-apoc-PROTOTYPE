extends SceneTree

const RACK_SCENE := "res://gameplay/logistics_wing/storage/modular_rack.tscn"
const POSITION_EPSILON_M := 0.002
const EXPECTED_PLATFORM_LENGTH_AT_2_60_M := 2.469214
const EXPECTED_PLATFORM_DEPTH_AT_0_72_M := 0.672977
const EXPECTED_PLATFORM_THICKNESS_M := 0.205345
const EXPECTED_SURFACE_NUDGE_M := 0.018

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _test_scene_skeleton():
		_finish()
		return
	_test_authored_dimensions_and_collision()
	_test_stable_identity_and_physical_clearance()
	_test_asymmetric_insets_and_invalid_states()
	_test_save_reload_independence()
	_finish()


func _test_scene_skeleton() -> bool:
	if not _check(ResourceLoader.exists(RACK_SCENE), "ModularRack scene exists"):
		return false
	var packed := load(RACK_SCENE) as PackedScene
	var rack := packed.instantiate() if packed != null else null
	if not _check(rack != null, "ModularRack scene instantiates"):
		return false
	root.add_child(rack)
	_check(
		rack.get_script() != null
		and String(rack.get_script().get_global_name()) == "ModularRack",
		"ModularRack scene instantiates as the global ModularRack class"
	)
	_check(rack.get_node_or_null("Frame/Visual") != null, "Rack01 visual exists")
	_check(rack.get_node_or_null("Levels") != null, "Levels root exists")
	_check(
		rack.get_node_or_null("MovementCollision/Shape") is CollisionShape3D,
		"movement collision exists"
	)
	var levels := rack.get_node_or_null("Levels")
	_check(
		levels != null and levels.get_child_count() == 3,
		"starter component contains three authored level wrappers"
	)
	rack.free()
	return not _failed


func _test_authored_dimensions_and_collision() -> void:
	var rack := _make_rack("GeometryRack")
	rack.set("rack_length_m", 2.60)
	rack.set("rack_depth_m", 0.72)
	rack.set("frame_height_m", 2.35)
	rack.call("refresh_authoring_state")

	var frame_bounds := _branch_local_bounds(rack.get_node("Frame") as Node3D)
	_check(_near(frame_bounds.size.x, 2.60), "frame length follows rack_length_m")
	_check(_near(frame_bounds.size.y, 2.35), "frame height follows frame_height_m")
	_check(_near(frame_bounds.size.z, 0.72), "frame depth follows rack_depth_m")
	_check(_near(frame_bounds.position.y, 0.0), "frame base is normalized to local Y zero")

	var shape_node := rack.get_node("MovementCollision/Shape") as CollisionShape3D
	var box := shape_node.shape as BoxShape3D
	_check(shape_node.scale.is_equal_approx(Vector3.ONE), "collision shape node stays unit scale")
	_check(box != null and _vector_near(box.size, Vector3(2.60, 2.35, 0.72)), "collision box follows authored envelope")
	_check(_vector_near(shape_node.position, Vector3(0.0, 1.175, 0.0)), "collision box is centered at half frame height")

	var layout := rack.call("compute_layout") as Dictionary
	var rack_record := layout.get("rack", {}) as Dictionary
	var platform_size := rack_record.get("platform_base_size", Vector2.ZERO) as Vector2
	_check(_near(platform_size.x, EXPECTED_PLATFORM_LENGTH_AT_2_60_M), "Rack02 length preserves source-family proportion")
	_check(_near(platform_size.y, EXPECTED_PLATFORM_DEPTH_AT_0_72_M), "Rack02 depth preserves source-family proportion")
	rack.free()


func _test_stable_identity_and_physical_clearance() -> void:
	var rack := _make_rack("IdentityRack")
	_set_level_y(rack, "Shelf_01", 0.25)
	_set_level_y(rack, "Shelf_02", 0.95)
	_set_level_y(rack, "Shelf_03", 1.65)
	rack.set("overhead_limit_local_y_m", 2.40)
	rack.call("refresh_authoring_state")
	var initial := rack.call("compute_layout") as Dictionary
	_check(bool(initial.get("valid", false)), "ordinary three-level rack layout is valid")
	var initial_ids := _surface_ids_by_level(initial)
	var initial_levels := initial.get("levels", []) as Array
	if initial_levels.size() >= 3:
		var lower := initial_levels[0] as Dictionary
		var upper := initial_levels[1] as Dictionary
		_check(
			_near(float(lower.get("clearance", -1.0)), 0.95 - EXPECTED_PLATFORM_THICKNESS_M - (0.25 + EXPECTED_SURFACE_NUDGE_M)),
			"intermediate clearance uses the next Rack02 underside"
		)
		var top := initial_levels[2] as Dictionary
		_check(
			_near(float(top.get("clearance", -1.0)), 2.40 - (1.65 + EXPECTED_SURFACE_NUDGE_M)),
			"top clearance follows the authored overhead limit"
		)
		_check(String(lower.get("name", "")) == "Shelf_01" and String(upper.get("name", "")) == "Shelf_02", "initial levels sort by support height")

	_set_level_y(rack, "Shelf_01", 1.15)
	_set_level_y(rack, "Shelf_02", 0.45)
	rack.call("refresh_authoring_state")
	var crossed := rack.call("compute_layout") as Dictionary
	var crossed_levels := crossed.get("levels", []) as Array
	if crossed_levels.size() >= 3:
		_check(String((crossed_levels[0] as Dictionary).get("name", "")) == "Shelf_02", "crossed levels recalculate physical order")
		_check(String((crossed_levels[1] as Dictionary).get("name", "")) == "Shelf_01", "crossed levels keep identity independent of physical order")
	var crossed_ids := _surface_ids_by_level(crossed)
	_check(crossed_ids == initial_ids, "surface identity remains tied to rack and shelf names after crossing")
	rack.free()


func _test_asymmetric_insets_and_invalid_states() -> void:
	var rack := _make_rack("ValidationRack")
	rack.set("rack_length_m", 2.60)
	rack.set("rack_depth_m", 0.72)
	rack.set("usable_inset_left_m", 0.10)
	rack.set("usable_inset_right_m", 0.20)
	rack.set("usable_inset_front_m", 0.03)
	rack.set("usable_inset_back_m", 0.09)
	rack.call("refresh_authoring_state")
	var layout := rack.call("compute_layout") as Dictionary
	var levels := layout.get("levels", []) as Array
	if not levels.is_empty():
		var level := levels[0] as Dictionary
		_check(_vector2_near(level.get("usable_size", Vector2.ZERO) as Vector2, Vector2(2.169214, 0.552977)), "asymmetric insets reduce the calibrated platform rectangle")
		_check(_vector2_near(level.get("usable_center", Vector2.ZERO) as Vector2, Vector2(-0.05, -0.03)), "asymmetric insets shift usable center in normalized local axes")

	var duplicate := Node3D.new()
	duplicate.name = "shelf_01"
	(rack.get_node("Levels") as Node3D).add_child(duplicate)
	duplicate.position.y = 2.0
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "case-insensitive duplicate shelf identity invalidates layout")
	duplicate.free()

	rack.set("usable_inset_left_m", 1.30)
	rack.set("usable_inset_right_m", 1.30)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "insets that erase usable width invalidate layout")
	rack.set("usable_inset_left_m", 0.04)
	rack.set("usable_inset_right_m", 0.04)

	rack.set("rack_length_m", 0.0)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "nonpositive rack dimensions invalidate layout")
	rack.set("rack_length_m", 2.60)

	_set_level_y(rack, "Shelf_01", 0.20)
	_set_level_y(rack, "Shelf_02", 0.20 + EXPECTED_SURFACE_NUDGE_M + EXPECTED_PLATFORM_THICKNESS_M)
	_set_level_y(rack, "Shelf_03", 1.60)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "nonpositive physical opening invalidates layout")
	_set_level_y(rack, "Shelf_02", 0.20 + EXPECTED_SURFACE_NUDGE_M + EXPECTED_PLATFORM_THICKNESS_M + 0.01)
	_check(bool((rack.call("compute_layout") as Dictionary).get("valid", false)), "small positive physical opening remains legal")

	rack.set("overhead_limit_local_y_m", 1.60 + EXPECTED_SURFACE_NUDGE_M)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "top level at the overhead limit invalidates layout")
	rack.set("overhead_limit_local_y_m", 3.40)
	rack.set("frame_height_m", 1.50)
	var above_frame := rack.call("compute_layout") as Dictionary
	_check(bool(above_frame.get("valid", false)), "highest level above frame remains functional")
	_check(not (above_frame.get("warnings", []) as Array).is_empty(), "highest level above frame produces a warning")

	rack.scale = Vector3(1.1, 1.0, 1.0)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "non-unit root scale invalidates layout")
	rack.scale = Vector3.ONE
	rack.rotation.x = 0.1
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "root pitch invalidates layout")
	rack.free()


func _test_save_reload_independence() -> void:
	var packed_rack := load(RACK_SCENE) as PackedScene
	var host := Node3D.new()
	host.name = "RoundTripHost"
	root.add_child(host)
	var rack_a := packed_rack.instantiate() as Node3D
	var rack_b := packed_rack.instantiate() as Node3D
	rack_a.name = "Rack_A"
	rack_b.name = "Rack_B"
	host.add_child(rack_a)
	host.add_child(rack_b)
	rack_a.owner = host
	rack_b.owner = host
	host.set_editable_instance(rack_a, true)
	host.set_editable_instance(rack_b, true)
	rack_a.set("rack_length_m", 2.15)
	rack_a.set("rack_depth_m", 0.66)
	rack_b.set("rack_length_m", 3.05)
	rack_b.set("rack_depth_m", 0.91)
	_set_level_y(rack_a, "Shelf_02", 0.88)
	_set_level_y(rack_b, "Shelf_02", 1.22)
	rack_a.call("refresh_authoring_state")
	rack_b.call("refresh_authoring_state")

	var round_trip := PackedScene.new()
	_check(round_trip.pack(host) == OK, "two authored racks pack for save/reload")
	var path := "user://modular_rack_round_trip.tscn"
	_check(ResourceSaver.save(round_trip, path) == OK, "authored rack round-trip scene saves")
	var reloaded_packed := load(path) as PackedScene
	var reloaded := reloaded_packed.instantiate() as Node3D if reloaded_packed != null else null
	_check(reloaded != null, "authored rack round-trip scene reloads")
	if reloaded != null:
		root.add_child(reloaded)
		var loaded_a := reloaded.get_node("Rack_A") as Node3D
		var loaded_b := reloaded.get_node("Rack_B") as Node3D
		_check(_near(float(loaded_a.get("rack_length_m")), 2.15), "rack A root authoring property persists")
		_check(_near(float(loaded_b.get("rack_length_m")), 3.05), "rack B root authoring property persists independently")
		_check(_near((loaded_a.get_node("Levels/Shelf_02") as Node3D).position.y, 0.88), "rack A shelf transform persists")
		_check(_near((loaded_b.get_node("Levels/Shelf_02") as Node3D).position.y, 1.22), "rack B shelf transform persists independently")
		loaded_a.call("refresh_authoring_state")
		loaded_b.call("refresh_authoring_state")
		var shape_a := (loaded_a.get_node("MovementCollision/Shape") as CollisionShape3D).shape
		var shape_b := (loaded_b.get_node("MovementCollision/Shape") as CollisionShape3D).shape
		_check(shape_a != shape_b, "duplicated rack instances do not share mutable collision resources")
		reloaded.free()
	host.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _make_rack(rack_name: String) -> Node3D:
	var rack := (load(RACK_SCENE) as PackedScene).instantiate() as Node3D
	rack.name = rack_name
	root.add_child(rack)
	return rack


func _set_level_y(rack: Node3D, level_name: String, support_y: float) -> void:
	var level := rack.get_node("Levels/%s" % level_name) as Node3D
	level.position.y = support_y


func _surface_ids_by_level(layout: Dictionary) -> Dictionary:
	var result := {}
	for value: Variant in layout.get("levels", []) as Array:
		var level := value as Dictionary
		result[String(level.get("name", ""))] = String(level.get("surface_id", ""))
	return result


func _branch_local_bounds(branch: Node3D) -> AABB:
	var state := {"valid": false, "bounds": AABB()}
	for child: Node in branch.get_children():
		_scan_bounds(child, Transform3D.IDENTITY, state)
	return state["bounds"] as AABB


func _scan_bounds(node: Node, parent_transform: Transform3D, state: Dictionary) -> void:
	var transform_to_branch := parent_transform
	if node is Node3D:
		transform_to_branch = parent_transform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh != null:
			var bounds := transform_to_branch * mesh_node.get_aabb()
			if bool(state["valid"]):
				state["bounds"] = (state["bounds"] as AABB).merge(bounds)
			else:
				state["valid"] = true
				state["bounds"] = bounds
	for child: Node in node.get_children():
		_scan_bounds(child, transform_to_branch, state)


func _near(actual: float, expected: float) -> bool:
	return absf(actual - expected) <= POSITION_EPSILON_M


func _vector_near(actual: Vector3, expected: Vector3) -> bool:
	return _near(actual.x, expected.x) and _near(actual.y, expected.y) and _near(actual.z, expected.z)


func _vector2_near(actual: Vector2, expected: Vector2) -> bool:
	return _near(actual.x, expected.x) and _near(actual.y, expected.y)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false


func _finish() -> void:
	if _failed:
		push_error("FAIL: modular rack authoring tests")
		quit(1)
		return
	print("PASS: modular rack authoring tests")
	quit(0)
