extends SceneTree

const PLAYER_SCENE := preload("res://gameplay/player/gameplay_player.tscn")
const LADDER_SCENE := preload("res://gameplay/traversal/fixed_ladder/fixed_ladder.tscn")
const WorldItemScript := preload("res://world_item.gd")
const StorageSurfaceScript := preload("res://storage_surface.gd")
const ItemInstanceScript := preload("res://item_instance.gd")

const EPSILON := 0.003

var _failed := false
var _host: Node3D
var _player: CharacterBody3D
var _ladder: Node3D


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_host = Node3D.new()
	_host.name = "FixedLadderPlayerTest"
	root.add_child(_host)
	_ladder = LADDER_SCENE.instantiate() as Node3D
	_player = PLAYER_SCENE.instantiate() as CharacterBody3D
	_player.set("enable_held_item_view", false)
	_host.add_child(_ladder)
	_host.add_child(_player)
	_player.set_physics_process(false)
	_player.set_process(false)
	_player.position = Vector3(0.0, 0.0, 0.46)
	_player.rotation.y = 0.0
	_ladder.set("ladder_height_m", 2.60)
	_ladder.set("overhead_limit_local_y_m", 3.40)
	_ladder.call("refresh_authoring_state")
	await physics_frame
	await physics_frame

	if not _check(
		_player.has_method("_step_movement")
		and _player.has_method("is_ladder_attached")
		and _player.has_method("_apply_mouse_look"),
		"player exposes the bounded ladder movement branch"
	):
		_finish()
		return

	await _test_attachment_conditions()
	_test_attached_movement_and_yaw()
	_test_top_limit_uses_actual_player_body()
	await _test_bottom_release_and_suppression()
	_test_carried_identity_and_zoning_hold()
	await _test_interaction_rays_ignore_ladder_body()
	_finish()


func _test_attachment_conditions() -> void:
	_check(_ladder.call("is_player_in_approach_area", _player), "real ApproachArea overlaps the player at the front anchor")
	var anchor := _ladder.call("get_climb_anchor_world_position") as Vector3
	var capsule := (_player.get_node("CollisionShape3D") as CollisionShape3D).shape as CapsuleShape3D
	var movement_box := (_ladder.get_node("MovementCollision/Shape") as CollisionShape3D).shape as BoxShape3D
	var approach_shape := _ladder.get_node("ApproachArea/Shape") as CollisionShape3D
	_check(_near(approach_shape.position.x, 0.0), "ApproachArea stays centred on ladder local X")
	_player.velocity = Vector3.ZERO
	_player.position = Vector3(0.85, 0.0, 0.46)
	await physics_frame
	await physics_frame
	_check(_ladder.call("is_player_in_approach_area", _player), "wider ApproachArea recognizes a real player near its lateral candidate edge")
	_player.velocity = Vector3.ZERO
	_player.position = Vector3(0.0, 0.0, 0.46)
	await physics_frame
	await physics_frame
	var standoff_clearance := anchor.z - (movement_box.size.z * 0.5 + capsule.radius)
	_check(
		standoff_clearance >= 0.02 and standoff_clearance <= 0.10,
		"climb anchor leaves only a small safety margin beyond ladder collision plus capsule radius"
	)
	_player.call("_step_movement", 0.05, Vector2.ZERO, false)
	_check(not bool(_player.call("is_ladder_attached")), "overlap without forward input does not attach")
	_player.call("_step_movement", 0.05, Vector2(1.0, 0.0), false)
	_check(not bool(_player.call("is_ladder_attached")), "lateral crossing intent does not attach")
	_player.rotation.y = PI * 0.5
	_player.call("_step_movement", 0.05, Vector2(0.0, -1.0), false)
	_check(not bool(_player.call("is_ladder_attached")), "forward input while facing sideways does not attach")
	_player.rotation.y = 0.0
	_ladder.scale = Vector3(1.1, 1.0, 1.0)
	_player.call("_step_movement", 0.05, Vector2(0.0, -1.0), false)
	var invalid_attached := bool(_player.call("is_ladder_attached"))
	_check(not invalid_attached, "invalid root transform cannot become an active ladder")
	if invalid_attached:
		_player.call("_detach_from_ladder", false)
	_ladder.scale = Vector3.ONE
	_player.velocity = Vector3.ZERO
	_player.position = Vector3(0.0, 0.0, 0.85)
	_player.rotation.y = 0.0
	await physics_frame
	await physics_frame
	_check(_ladder.call("is_player_in_approach_area", _player), "outer ApproachArea remains broad candidate context")
	_player.call("_step_movement", 0.05, Vector2(0.0, -1.0), false)
	_check(not bool(_player.call("is_ladder_attached")), "frontal W cannot attach from a visibly large X/Z correction")

	_player.velocity = Vector3.ZERO
	_player.position = Vector3(0.10, 0.0, 0.50)
	_player.rotation.y = 0.0
	await physics_frame
	await physics_frame
	var pre_attach_correction := Vector2(
		_player.global_position.x - anchor.x,
		_player.global_position.z - anchor.z
	).length()
	_player.call("_step_movement", 0.05, Vector2(0.0, -1.0), false)
	_check(bool(_player.call("is_ladder_attached")), "near-edge frontal W input attaches within the snap-safe correction cap")
	var maximum_correction := 0.12
	_check(_ladder.has_method("get_max_attach_correction_m"), "ladder publishes its attach-correction bound")
	if _ladder.has_method("get_max_attach_correction_m"):
		maximum_correction = float(_ladder.call("get_max_attach_correction_m"))
	_check(
		pre_attach_correction <= maximum_correction + EPSILON,
		"successful attachment starts within the bounded X/Z correction distance"
	)
	print(
		"ATTACH_CORRECTION_METRIC accepted=%.4fm bound=%.4fm standoff_clearance=%.4fm"
		% [pre_attach_correction, maximum_correction, standoff_clearance]
	)
	_check(_near(_player.global_position.x, anchor.x) and _near(_player.global_position.z, anchor.z), "attach fixes X/Z to the climb line")


func _test_attached_movement_and_yaw() -> void:
	var anchor := _ladder.call("get_climb_anchor_world_position") as Vector3
	_player.global_position.y = 0.25
	(_player.get_node("Camera3D") as Camera3D).rotation.x = deg_to_rad(70.0)
	var start_y := _player.global_position.y
	_player.call("_step_movement", 0.10, Vector2(0.0, -1.0), false)
	var rise_looking_up := _player.global_position.y - start_y
	_player.global_position.y = 0.25
	(_player.get_node("Camera3D") as Camera3D).rotation.x = deg_to_rad(-70.0)
	_player.call("_step_movement", 0.10, Vector2(0.0, -1.0), false)
	var rise_looking_down := _player.global_position.y - 0.25
	_check(rise_looking_up > 0.0 and _near(rise_looking_up, rise_looking_down), "W climb speed is independent of camera pitch")

	var before_down := _player.global_position.y
	_player.call("_step_movement", 0.05, Vector2(0.0, 1.0), false)
	_check(_player.global_position.y < before_down, "S moves down while attached")
	var hold_y := _player.global_position.y
	_player.call("_step_movement", 0.20, Vector2.ZERO, false)
	_check(_near(_player.global_position.y, hold_y), "release-to-hold preserves Y")
	_player.call("_step_movement", 0.20, Vector2(1.0, 0.0), false)
	_check(
		_near(_player.global_position.x, anchor.x)
		and _near(_player.global_position.z, anchor.z)
		and _near(_player.global_position.y, hold_y),
		"A/D cannot move the attached player"
	)

	_player.global_position.y = 0.30
	_player.call("_step_movement", 0.10, Vector2(0.0, -1.0), false)
	var normal_rise := _player.global_position.y - 0.30
	_player.global_position.y = 0.30
	_player.call("_step_movement", 0.10, Vector2(0.0, -1.0), true)
	var sprint_rise := _player.global_position.y - 0.30
	_check(_near(normal_rise, sprint_rise), "Shift does not modify climb speed")

	var centre := float(_player.call("get_ladder_yaw_center"))
	var functional_forward := _ladder.call("get_ladder_forward_world") as Vector3
	var functional_centre := atan2(functional_forward.x, functional_forward.z)
	var maximum := float(_ladder.call("get_yaw_clamp_radians"))
	var camera := _player.get_node("Camera3D") as Camera3D
	_check(_near(maximum, deg_to_rad(70.0)), "attached yaw clamp is the reviewed +/-70 degrees")
	_check(absf(angle_difference(functional_centre, centre)) <= EPSILON, "yaw centre comes from functional root +Z rather than visual normalization")
	var endpoint_mouse_motion := deg_to_rad(100.0) / float(_player.get("mouse_sensitivity"))
	_player.rotation.y = centre
	_player.call("_apply_mouse_look", Vector2(-endpoint_mouse_motion, 0.0))
	var right_relative := wrapf(_camera_back_yaw_world(camera) - centre, -PI, PI)
	_player.rotation.y = centre
	_player.call("_apply_mouse_look", Vector2(endpoint_mouse_motion, 0.0))
	var left_relative := wrapf(_camera_back_yaw_world(camera) - centre, -PI, PI)
	print("YAW_SYMMETRY_METRIC centre=%.3f left=%.3f right=%.3f" % [rad_to_deg(centre), rad_to_deg(left_relative), rad_to_deg(right_relative)])
	_check(_near(left_relative, -deg_to_rad(70.0)) and _near(right_relative, deg_to_rad(70.0)), "visible left and right yaw endpoints are exactly centre -/+70 degrees")
	_check(_near(absf(left_relative), absf(right_relative)) and _near((left_relative + right_relative) * 0.5, 0.0), "visible yaw endpoints have equal magnitude and a zero-offset midpoint")
	_player.rotation.y = centre


func _test_top_limit_uses_actual_player_body() -> void:
	_player.rotation.y = float(_player.call("get_ladder_yaw_center"))
	var eye_offset := float(_player.call("get_player_eye_offset_from_root"))
	var body_top_offset := float(_player.call("get_player_body_top_offset_from_root"))
	_check(_near(eye_offset, 1.7162851, 0.01), "eye offset is derived from the current player camera")
	_check(_near(body_top_offset, 1.75, 0.01), "body top is derived from the current player collision")
	var limits := _ladder.call("get_player_root_climb_limits", eye_offset, body_top_offset) as Dictionary
	var preferred := float(limits.get("preferred_player_root_y", INF))
	var ceiling_safe := float(limits.get("ceiling_safe_player_root_y", INF))
	var expected_max := minf(preferred, ceiling_safe)
	var physics_delta: float = 1.0 / float(Engine.physics_ticks_per_second)
	_player.global_position.y = expected_max - 0.01
	_player.call("_step_movement", physics_delta, Vector2(0.0, -1.0), false)
	_check(_near(_player.global_position.y, expected_max), "top clamp uses the lower of visual and ceiling-safe targets")
	_check(
		_player.global_position.y + body_top_offset
		<= float(_ladder.call("get_overhead_limit_world_y")) - 0.039,
		"complete player body remains below the authored overhead"
	)
	var clamped_y := _player.global_position.y
	_player.call("_step_movement", physics_delta, Vector2(0.0, -1.0), false)
	_check(_near(_player.global_position.y, clamped_y), "continued W at the top cannot climb higher")

	_ladder.set("overhead_limit_local_y_m", 2.55)
	var ceiling_limits := _ladder.call("get_player_root_climb_limits", eye_offset, body_top_offset) as Dictionary
	var ceiling_preferred := float(ceiling_limits.get("preferred_player_root_y", INF))
	var low_ceiling_safe := float(ceiling_limits.get("ceiling_safe_player_root_y", INF))
	var ceiling_max := float(ceiling_limits.get("maximum_y", INF))
	_check(low_ceiling_safe < ceiling_preferred, "low-overhead fixture makes body safety the limiting branch")
	_player.global_position.y = ceiling_max - 0.01
	_player.call("_step_movement", physics_delta, Vector2(0.0, -1.0), false)
	_check(_near(_player.global_position.y, low_ceiling_safe), "low overhead clamps at the body-safe ceiling target")
	_check(
		_player.global_position.y + body_top_offset
		<= float(_ladder.call("get_overhead_limit_world_y")) - 0.039,
		"low-overhead branch keeps the full capsule below the authored limit"
	)
	_ladder.set("overhead_limit_local_y_m", 3.40)


func _test_bottom_release_and_suppression() -> void:
	var anchor := _ladder.call("get_climb_anchor_world_position") as Vector3
	_player.rotation.y = float(_player.call("get_ladder_yaw_center"))
	_player.global_position = Vector3(anchor.x, float(_ladder.call("get_bottom_player_root_world_y")) + 0.01, anchor.z)
	_player.call("_step_movement", 0.10, Vector2(0.0, 1.0), false)
	_check(not bool(_player.call("is_ladder_attached")), "descending through the bottom returns to normal movement")
	_check(_player.velocity.z > 0.0 and _player.global_position.z > anchor.z, "continuing S begins normal backward movement immediately")
	_check(bool(_ladder.call("is_attach_suppressed_for", _player)), "bottom release suppresses immediate recapture")
	_player.global_position = Vector3(0.0, 0.0, 0.46)
	_player.rotation.y = 0.0
	_player.call("_step_movement", 0.05, Vector2(0.0, -1.0), false)
	_check(not bool(_player.call("is_ladder_attached")), "suppressed ladder cannot immediately reattach")

	_player.velocity = Vector3.ZERO
	_player.global_position = Vector3(anchor.x, 0.0, anchor.z + 0.205)
	await physics_frame
	await physics_frame
	_check(_ladder.call("is_player_in_approach_area", _player), "modest back-away remains inside the outer ApproachArea")
	_check(not bool(_ladder.call("is_attach_suppressed_for", _player)), "90%-of-prior inner back-away threshold rearms before outer ApproachArea exit")
	_player.rotation.y = 0.0
	for attempt: int in range(12):
		_player.call("_step_movement", 0.05, Vector2(0.0, -1.0), false)
		if bool(_player.call("is_ladder_attached")):
			break
		await physics_frame
	_check(bool(_player.call("is_ladder_attached")), "W reapproach can attach again after inner-distance rearm")


func _test_carried_identity_and_zoning_hold() -> void:
	var carried := _player.get_node("CarriedItems") as CarriedItems
	var definition := load("res://data/items/definitions/loot_000037.tres") as ItemDefinition
	var item := ItemInstanceScript.new(definition)
	_check(carried.add_item(item), "test item enters carried inventory")
	_check(carried.get_selected_item() == item, "carried item identity is established before ladder movement")
	var preserved_y := 0.35
	_player.global_position.y = preserved_y
	_player.set("_zone_editor_open", true)
	_player.call("_step_movement", 0.50, Vector2(0.0, -1.0), false)
	_check(bool(_player.call("is_ladder_attached")), "zoning modal leaves attachment logically active")
	_check(_near(_player.global_position.y, preserved_y), "zoning modal prevents vertical ladder movement")
	_player.set("_zone_editor_open", false)
	_check(carried.get_selected_item() == item, "carried item identity survives attach, climb, release, and reattach")
	carried.remove_item(item)


func _test_interaction_rays_ignore_ladder_body() -> void:
	_player.global_position.y = 0.0
	_player.rotation.y = float(_player.call("get_ladder_yaw_center"))
	var camera := _player.get_node("Camera3D") as Camera3D
	var item_host := Node3D.new()
	item_host.name = "RayTargetItem"
	_host.add_child(item_host)
	item_host.global_position = Vector3(0.0, camera.global_position.y, -0.72)
	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.12, 0.12, 0.12)
	mesh.material = StandardMaterial3D.new()
	mesh_node.mesh = mesh
	item_host.add_child(mesh_node)
	var world_item := WorldItemScript.new() as WorldItem
	world_item.name = "WorldItem"
	item_host.add_child(world_item)
	world_item.configure(item_host, load("res://data/items/definitions/loot_000037.tres") as ItemDefinition)
	await physics_frame
	camera.look_at(item_host.global_position, Vector3.UP)
	await physics_frame
	_check(_body_ray_hits_ladder(camera.global_position, item_host.global_position), "ladder movement body lies between camera and item target")
	_check(_player.call("_get_looked_at_world_item") == world_item, "WorldItem pickup ray reaches through ladder movement collision")

	var surface := StorageSurfaceScript.new() as StorageSurface
	surface.name = "RayTargetSurface"
	_host.add_child(surface)
	surface.global_position = Vector3(0.0, 1.12, -0.70)
	surface.configure(&"fixed_ladder_ray_surface", 0.60, 0.60, 0.10, 0.80)
	await physics_frame
	camera.look_at(surface.global_position, Vector3.UP)
	await physics_frame
	_check(_body_ray_hits_ladder(camera.global_position, surface.global_position), "ladder movement body lies between camera and storage target")
	_check(_player.call("_get_looked_at_storage_surface") == surface, "StorageSurface ray reaches through ladder movement collision")


func _body_ray_hits_ladder(ray_from: Vector3, ray_to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.new()
	query.from = ray_from
	query.to = ray_to
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 1
	query.exclude = [_player.get_rid()]
	var result := _host.get_world_3d().direct_space_state.intersect_ray(query)
	return result.get("collider") == _ladder.get_node("MovementCollision")


func _near(actual: float, expected: float, epsilon: float = EPSILON) -> bool:
	return absf(actual - expected) <= epsilon


func _camera_back_yaw_world(camera: Camera3D) -> float:
	var camera_back := camera.global_basis.z
	return atan2(camera_back.x, camera_back.z)


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
		print("PASS: fixed ladder player tests")
		quit(0)
