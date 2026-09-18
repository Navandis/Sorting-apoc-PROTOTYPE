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
		_route("spawn_to_table_pickup", Vector3(-10.0, PLAYER_FLOOR_Y, -2.5), [
			Vector3(-10.0, PLAYER_FLOOR_Y, -0.2),
			Vector3(-9.6, PLAYER_FLOOR_Y, 1.3),
		]),
		_route("gallery_a_fixture_front", Vector3(4.0, PLAYER_FLOOR_Y, -8.2), [
			Vector3(1.5, PLAYER_FLOOR_Y, -8.0),
			Vector3(0.0, PLAYER_FLOOR_Y, -7.0),
			Vector3(-2.28, PLAYER_FLOOR_Y, -5.2),
		]),
		_route("gallery_b_fixture_front", Vector3(9.5, PLAYER_FLOOR_Y, -8.2), [
			Vector3(12.0, PLAYER_FLOOR_Y, -7.0),
			Vector3(14.0, PLAYER_FLOOR_Y, -10.7),
		]),
		_route("gallery_c_locker_front", Vector3(2.0, PLAYER_FLOOR_Y, 3.0), [
			Vector3(2.0, PLAYER_FLOOR_Y, 6.0),
			Vector3(-1.35, PLAYER_FLOOR_Y, 6.9),
		]),
		_route("gallery_c_to_d_connection", Vector3(4.5, PLAYER_FLOOR_Y, 10.25), [
			Vector3(7.0, PLAYER_FLOOR_Y, 10.25),
			Vector3(8.0, PLAYER_FLOOR_Y, 10.0),
			Vector3(10.0, PLAYER_FLOOR_Y, 9.0),
		]),
	]
	for record: Dictionary in routes:
		var result := await _run_route(player, record)
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
