extends SceneTree

const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const ARRIVAL_TOLERANCE_M := 0.50
const PLAYER_FLOOR_Y := 0.05

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(GAMEPLAY_PATH) as PackedScene
	if not _check(packed != null, "continuing gameplay scene loads for navigation"):
		_finish()
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	current_scene = scene
	await physics_frame
	await physics_frame
	var player := scene.get_node("Player") as CharacterBody3D
	var routes := [
		_route("receiving_through_backlog", Vector3(-27.45, PLAYER_FLOOR_Y, 0.6), [
			Vector3(-22.45, PLAYER_FLOOR_Y, 0.6),
			Vector3(-19.95, PLAYER_FLOOR_Y, 0.6),
			Vector3(-16.0, PLAYER_FLOOR_Y, 0.375),
			Vector3(-13.65, PLAYER_FLOOR_Y, 0.375),
		]),
		_route("spawn_to_table_pickup", player.position, [
			Vector3(-11.6, PLAYER_FLOOR_Y, 1.5),
			Vector3(-12.5, PLAYER_FLOOR_Y, 2.15),
		]),
		_route("backlog_through_sorting_to_storage", Vector3(-16.7, PLAYER_FLOOR_Y, 0.375), [
			Vector3(-13.5, PLAYER_FLOOR_Y, 0.375),
			Vector3(-9.5, PLAYER_FLOOR_Y, 1.8),
			Vector3(-6.0, PLAYER_FLOOR_Y, 2.55),
			Vector3(-3.5, PLAYER_FLOOR_Y, 2.60),
		]),
		_route("sorting_through_workshop_threshold", Vector3(-10.0, PLAYER_FLOOR_Y, 1.0), [
			Vector3(-10.0, PLAYER_FLOOR_Y, 3.4),
			Vector3(-10.0, PLAYER_FLOOR_Y, 6.75),
		]),
		_route("sorting_to_workshop_interface", Vector3(-10.0, PLAYER_FLOOR_Y, 3.3), [
			Vector3(-10.0, PLAYER_FLOOR_Y, 7.5),
			Vector3(-10.0, PLAYER_FLOOR_Y, 11.3),
			Vector3(-9.48004, PLAYER_FLOOR_Y, 14.1833),
		]),
		_route("workshop_west_turn_to_salvager", Vector3(-9.48004, PLAYER_FLOOR_Y, 14.1833), [
			Vector3(-12.0, PLAYER_FLOOR_Y, 15.10),
			Vector3(-18.6, PLAYER_FLOOR_Y, 15.10),
			Vector3(-23.7, PLAYER_FLOOR_Y, 15.10),
			Vector3(-25.62, PLAYER_FLOOR_Y, 16.25),
			Vector3(-25.61996, PLAYER_FLOOR_Y, 17.8666),
		]),
		_route("salvager_return_to_sorting", Vector3(-25.61996, PLAYER_FLOOR_Y, 17.8666), [
			Vector3(-25.62, PLAYER_FLOOR_Y, 15.10),
			Vector3(-18.6, PLAYER_FLOOR_Y, 15.10),
			Vector3(-12.0, PLAYER_FLOOR_Y, 15.10),
			Vector3(-10.0, PLAYER_FLOOR_Y, 11.3),
			Vector3(-10.0, PLAYER_FLOOR_Y, 7.5),
			Vector3(-10.0, PLAYER_FLOOR_Y, 3.3),
		]),
		# The rack occupies the old diagonal through A. Walk around its south end.
		_route("gallery_a_fixture_front", Vector3(3.7, PLAYER_FLOOR_Y, -4.9), [
			Vector3(0.55, PLAYER_FLOOR_Y, -4.90),
			Vector3(0.55, PLAYER_FLOOR_Y, -2.70),
			Vector3(-2.65, PLAYER_FLOOR_Y, -2.70),
			Vector3(-2.65, PLAYER_FLOOR_Y, -2.62),
		]),
		_route("gallery_b_fixture_front", Vector3(5.9, PLAYER_FLOOR_Y, -4.9), [
			Vector3(8.80, PLAYER_FLOOR_Y, -4.90),
			Vector3(11.85, PLAYER_FLOOR_Y, -6.00),
			Vector3(12.00, PLAYER_FLOOR_Y, -8.30),
		]),
		_route("gallery_c_locker_front", Vector3(1.6, PLAYER_FLOOR_Y, 3.0), [
			Vector3(1.6, PLAYER_FLOOR_Y, 6.5),
			Vector3(0.0, PLAYER_FLOOR_Y, 7.75),
		]),
		_route("gallery_c_to_d_connection", Vector3(4.5, PLAYER_FLOOR_Y, 9.05), [
			Vector3(7.0, PLAYER_FLOOR_Y, 9.05),
			Vector3(8.0, PLAYER_FLOOR_Y, 8.80),
			Vector3(10.0, PLAYER_FLOOR_Y, 7.80),
		]),
		_route("storage_to_incinerator_front", Vector3(18.0, PLAYER_FLOOR_Y, 2.5), [
			Vector3(21.5, PLAYER_FLOOR_Y, 3.35),
			Vector3(21.5, PLAYER_FLOOR_Y, 6.3),
			Vector3(21.5, PLAYER_FLOOR_Y, 9.1),
			Vector3(21.5, PLAYER_FLOOR_Y, 11.2),
		]),
		_route("storage_through_link_to_ops", Vector3(17.5, PLAYER_FLOOR_Y, 2.50), [
			Vector3(24.70, PLAYER_FLOOR_Y, 2.30),
			Vector3(27.50, PLAYER_FLOOR_Y, 2.30),
			Vector3(32.50, PLAYER_FLOOR_Y, 2.30),
			Vector3(32.50, PLAYER_FLOOR_Y, -0.70),
		]),
	]
	for record: Dictionary in routes:
		var result := await _run_route(player, record)
		print("NAVIGATION_ROUTE ", record["name"], " ", result)
		_check(
			bool(result.get("passed", false)),
			"%s reaches its review stance (%s)" % [record["name"], result.get("note", "")]
		)
	_set_key(KEY_W, false)
	scene.free()
	current_scene = null
	_finish()


func _run_route(player: CharacterBody3D, record: Dictionary) -> Dictionary:
	await _reset_player(player, record["start"] as Vector3)
	_set_key(KEY_W, true)
	var note := ""
	var collision_frames := 0
	for waypoint: Vector3 in record["waypoints"] as PackedVector3Array:
		var segment := await _walk_to_waypoint(player, waypoint)
		collision_frames += int(segment["collision_frames"])
		if not bool(segment["passed"]):
			note = String(segment["note"])
			break
	_set_key(KEY_W, false)
	await physics_frame
	var waypoints := record["waypoints"] as PackedVector3Array
	var target := waypoints[waypoints.size() - 1]
	var end_error := _horizontal_distance(player.global_position, target)
	var passed := note.is_empty() and end_error <= ARRIVAL_TOLERANCE_M + 0.10 and player.global_position.y > -0.25
	if passed:
		note = "arrived"
	elif note.is_empty():
		note = "end error %.3f m" % end_error
	return {
		"passed": passed,
		"note": note,
		"end_error_m": end_error,
		"collision_frames": collision_frames,
	}


func _walk_to_waypoint(player: CharacterBody3D, waypoint: Vector3) -> Dictionary:
	var initial_distance := _horizontal_distance(player.global_position, waypoint)
	var maximum_frames := maxi(180, ceili(initial_distance / 4.0 * 60.0 * 3.0))
	var collision_frames := 0
	var last_progress := player.global_position
	for frame: int in maximum_frames:
		if _horizontal_distance(player.global_position, waypoint) <= ARRIVAL_TOLERANCE_M:
			return {"passed": true, "collision_frames": collision_frames, "note": "arrived"}
		_face_direction(player, waypoint - player.global_position)
		await physics_frame
		if player.get_slide_collision_count() > 0:
			collision_frames += 1
		if player.global_position.y < -0.25:
			return {"passed": false, "collision_frames": collision_frames, "note": "fell below floor tolerance"}
		if frame > 0 and frame % 120 == 0:
			if _horizontal_distance(last_progress, player.global_position) < 0.08:
				return {"passed": false, "collision_frames": collision_frames, "note": "stalled before %s" % waypoint}
			last_progress = player.global_position
	return {"passed": false, "collision_frames": collision_frames, "note": "timed out before %s" % waypoint}


func _reset_player(player: CharacterBody3D, position: Vector3) -> void:
	_set_key(KEY_W, false)
	player.velocity = Vector3.ZERO
	player.global_position = position
	player.rotation = Vector3.ZERO
	await physics_frame
	await physics_frame
	player.velocity = Vector3.ZERO


func _face_direction(player: CharacterBody3D, direction: Vector3) -> void:
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() <= 0.000001:
		return
	flat = flat.normalized()
	player.rotation.y = atan2(-flat.x, -flat.z)


func _set_key(keycode: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	Input.parse_input_event(event)


func _route(name_value: String, start: Vector3, waypoints: Array[Vector3]) -> Dictionary:
	return {
		"name": name_value,
		"start": start,
		"waypoints": PackedVector3Array(waypoints),
	}


func _horizontal_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func _finish() -> void:
	if _failed:
		push_error("FAIL: wing gameplay navigation tests")
		quit(1)
		return
	print("PASS: wing gameplay navigation tests")
	quit(0)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false
