extends Node3D

const OUTPUT_PATH := "res://reports/logistics_wing/greybox/revision_04/traversal_results.json"
const RUN_FLAG := "--traversal-evidence"
const ARRIVAL_TOLERANCE := 0.45
const PHYSICS_TICKS_PER_SECOND := 60.0
const BOUNDARY_DRIVE_FRAMES := 180


func _ready() -> void:
	if should_run(OS.get_cmdline_user_args()):
		call_deferred("_run_evidence")


func should_run(arguments: PackedStringArray) -> bool:
	return arguments.has(RUN_FLAG)


func get_output_path() -> String:
	return OUTPUT_PATH


func get_route_records() -> Array:
	return [
		_route("receiving_to_sorting", "ReceivingApron", "SortingWork", [
			Vector3(-29.0, 0.05, 0.0), Vector3(-26.0, 0.05, 0.0),
			Vector3(-22.0, 0.05, -0.4), Vector3(-18.0, 0.05, -0.4),
			Vector3(-12.0, 0.05, -1.0), Vector3(-10.0, 0.05, -4.4),
		]),
		_route("receiving_to_dispatch", "ReceivingApron", "Dispatch", [
			Vector3(-33.0, 0.05, -4.2), Vector3(-33.0, 0.05, -5.8),
			Vector3(-33.0, 0.05, -6.75),
		]),
		_route("receiving_to_storage_near", "ReceivingApron", "StorageNear", [
			Vector3(-29.0, 0.05, 0.0), Vector3(-26.0, 0.05, 0.0),
			Vector3(-22.0, 0.05, -0.4), Vector3(-18.0, 0.05, -0.4),
			Vector3(-12.0, 0.05, 2.5), Vector3(-10.0, 0.05, 2.5),
			Vector3(-4.0, 0.05, 2.7), Vector3(-2.0, 0.05, 2.7),
		]),
		_route("sorting_to_shared_ab_junction", "SortingWork", "SharedABJunction", [
			Vector3(-10.0, 0.05, 2.5), Vector3(-4.0, 0.05, 2.7),
			Vector3(3.0, 0.05, 1.0), Vector3(6.75, 0.05, 0.0),
			Vector3(6.75, 0.05, -5.0), Vector3(6.75, 0.05, -8.2),
		]),
		_route("shared_junction_to_gallery_a_east", "SharedABJunction", "GalleryA", [
			Vector3(4.0, 0.05, -8.2), Vector3(1.5, 0.05, -8.0),
			Vector3(0.0, 0.05, -7.0),
		]),
		_route("shared_junction_to_gallery_b_west", "SharedABJunction", "GalleryB", [
			Vector3(9.5, 0.05, -8.2), Vector3(12.0, 0.05, -7.0),
			Vector3(12.0, 0.05, -5.0),
		]),
		_route("shared_junction_to_medical_anteroom", "SharedABJunction", "MedicalAnteroom", [
			Vector3(6.75, 0.05, -11.5), Vector3(7.0, 0.05, -15.0),
			Vector3(7.0, 0.05, -21.0), Vector3(7.0, 0.05, -24.0),
			Vector3(4.3, 0.05, -26.5),
		]),
		_route("gallery_b_to_kitchen_service", "GalleryB", "KitchenService", [
			Vector3(15.0, 0.05, -6.8), Vector3(18.0, 0.05, -6.8),
			Vector3(24.5, 0.05, -6.8), Vector3(25.0, 0.05, -10.0),
			Vector3(25.0, 0.05, -15.5), Vector3(25.0, 0.05, -19.0),
			Vector3(26.65, 0.05, -21.0),
		]),
		_route("sorting_to_workshop_service", "SortingWork", "WorkshopService", [
			Vector3(-10.0, 0.05, 3.0), Vector3(-10.0, 0.05, 8.0),
			Vector3(-10.0, 0.05, 13.0), Vector3(-11.0, 0.05, 16.0),
			Vector3(-11.0, 0.05, 19.0),
		]),
		_route("sorting_to_salvager", "SortingWork", "SalvagerFront", [
			Vector3(-10.0, 0.05, 3.0), Vector3(-10.0, 0.05, 8.0),
			Vector3(-10.0, 0.05, 16.0), Vector3(-7.0, 0.05, 21.5),
			Vector3(0.0, 0.05, 22.0), Vector3(3.0, 0.05, 22.5),
			Vector3(3.0, 0.05, 24.0),
			Vector3(5.0, 0.05, 24.5),
		]),
		_route("sorting_to_incinerator", "SortingWork", "IncineratorFront", [
			Vector3(-10.0, 0.05, 2.5), Vector3(-2.0, 0.05, 2.7),
			Vector3(10.0, 0.05, 2.0), Vector3(24.0, 0.05, 2.0),
			Vector3(28.0, 0.05, 2.0), Vector3(36.5, 0.05, 3.0),
			Vector3(36.5, 0.05, 6.0), Vector3(36.5, 0.05, 12.4),
		]),
		_route("sorting_to_bunker_ops", "SortingWork", "BunkerOpsSafeSide", [
			Vector3(-10.0, 0.05, 2.5), Vector3(-2.0, 0.05, 2.7),
			Vector3(10.0, 0.05, 2.0), Vector3(24.0, 0.05, 2.0),
			Vector3(28.0, 0.05, 2.0), Vector3(40.8, 0.05, 2.0),
			Vector3(41.0, 0.05, -5.5), Vector3(48.0, 0.05, -5.5),
			Vector3(58.0, 0.05, -5.5), Vector3(61.0, 0.05, -5.5),
			Vector3(62.5, 0.05, -8.5),
		]),
		_route("deeper_to_ops_landing", "IncineratorFront", "BunkerOpsLanding", [
			Vector3(36.5, 0.05, 7.0), Vector3(36.5, 0.05, 4.8),
			Vector3(40.8, 0.05, 2.0), Vector3(41.0, 0.05, -5.5),
			Vector3(48.0, 0.05, -5.5), Vector3(58.0, 0.05, -5.5),
			Vector3(62.5, 0.05, -6.0),
		]),
		_route("sorting_to_deeper_closure", "SortingWork", "DeeperClosureSafeSide", [
			Vector3(-10.0, 0.05, 2.5), Vector3(-2.0, 0.05, 2.7),
			Vector3(10.0, 0.05, 2.0), Vector3(24.0, 0.05, 2.0),
			Vector3(28.0, 0.05, 2.0), Vector3(40.8, 0.05, 2.0),
			Vector3(41.0, 0.05, -5.5), Vector3(48.0, 0.05, -5.5),
			Vector3(58.0, 0.05, -5.5), Vector3(64.5, 0.05, -6.8),
		]),
		_route("gallery_c_to_d_secondary", "GalleryC", "GalleryD", [
			Vector3(4.5, 0.05, 10.25), Vector3(7.0, 0.05, 10.25),
			Vector3(8.0, 0.05, 10.0), Vector3(10.0, 0.05, 9.0),
		]),
		_route("gallery_c_to_d_via_spine", "GalleryC", "GalleryD", [
			Vector3(2.0, 0.05, 6.0), Vector3(2.0, 0.05, 5.0),
			Vector3(2.0, 0.05, 3.0), Vector3(10.0, 0.05, 3.0),
			Vector3(10.0, 0.05, 6.0), Vector3(10.0, 0.05, 9.0),
		]),
		_route("storage_near_to_gallery_a", "StorageNear", "GalleryA", [
			Vector3(1.5, 0.05, 2.7), Vector3(1.5, 0.05, 0.0),
			Vector3(1.5, 0.05, -6.0), Vector3(0.0, 0.05, -7.0),
		]),
		_route("storage_near_to_gallery_b", "StorageNear", "GalleryB", [
			Vector3(3.0, 0.05, 1.0), Vector3(6.75, 0.05, 0.0),
			Vector3(6.75, 0.05, -8.2), Vector3(9.5, 0.05, -8.2),
			Vector3(12.0, 0.05, -5.0),
		]),
		_route("storage_near_to_gallery_c", "StorageNear", "GalleryC", [
			Vector3(2.0, 0.05, 3.0), Vector3(2.0, 0.05, 6.0),
			Vector3(2.0, 0.05, 8.0),
		]),
		_route("storage_near_to_gallery_d", "StorageNear", "GalleryD", [
			Vector3(5.0, 0.05, 2.7), Vector3(10.0, 0.05, 3.0),
			Vector3(10.0, 0.05, 6.0), Vector3(10.0, 0.05, 9.0),
		]),
		_route("storage_near_to_gallery_e", "StorageNear", "GalleryE", [
			Vector3(5.0, 0.05, 2.7), Vector3(13.0, 0.05, 2.7),
			Vector3(21.0, 0.05, 3.0), Vector3(21.0, 0.05, 6.0),
			Vector3(21.0, 0.05, 10.0),
		]),
	]


func get_boundary_records() -> Array:
	return [
		_boundary("freight_barrier", Vector3(-37.0, 0.05, 0.0), Vector3(-1, 0, 0), "x", "min", -38.75),
		_boundary("medical_inner_boundary", Vector3(4.3, 0.05, -28.0), Vector3(0, 0, -1), "z", "min", -29.70),
		_boundary("kitchen_inner_boundary", Vector3(26.65, 0.05, -22.0), Vector3(0, 0, -1), "z", "min", -24.70),
		_boundary("workshop_inner_boundary", Vector3(-15.5, 0.05, 20.0), Vector3(-1, 0, 0), "x", "min", -17.70),
		_boundary("workshop_south_wall", Vector3(-11.5, 0.05, 23.5), Vector3(0, 0, 1), "z", "max", 24.70),
		_boundary("bunker_ops_inner_boundary", Vector3(62.5, 0.05, -8.5), Vector3(0, 0, -1), "z", "min", -10.70),
		_boundary("deeper_settlement_door", Vector3(64.5, 0.05, -6.8), Vector3(1, 0, 0), "x", "max", 65.70),
		_boundary("kitchen_turn_return", Vector3(25.2, 0.05, -10.0), Vector3(-1, 0, 0), "x", "min", 23.30),
		_boundary("dogleg_return", Vector3(42.0, 0.05, -2.0), Vector3(1, 0, 0), "x", "max", 42.70),
		_boundary("shared_junction_return", Vector3(5.0, 0.05, -11.8), Vector3(0, 0, -1), "z", "min", -12.70),
		_boundary("gallery_cd_folded_outer_return", Vector3(8.0, 0.05, 15.0), Vector3(-1, 0, 0), "x", "min", 6.30),
		_boundary("incinerator_old_mouth_closure", Vector3(31.5, 0.05, 3.0), Vector3(0, 0, 1), "z", "max", 4.20),
	]


func _run_evidence() -> void:
	var player := get_node_or_null("Review/ReviewPlayer") as CharacterBody3D
	var anchors := get_node_or_null("Review/Geometry/Anchors") as Node3D
	if player == null or anchors == null:
		_fail_run("missing review player or geometry anchors")
		return
	await get_tree().physics_frame
	await get_tree().physics_frame

	var failures := 0
	var route_results: Array = []
	for record: Dictionary in get_route_records():
		var result := await _run_route(player, anchors, record)
		route_results.append(result)
		if not bool(result.get("passed", false)):
			failures += 1
		print("TRAVERSAL_ROUTE name=%s passed=%s seconds=%.3f distance_m=%.3f end_error_m=%.3f note=%s" % [
			result["name"], result["passed"], result["duration_seconds"],
			result["distance_m"], result["end_error_m"], result["note"],
		])

	var boundary_results: Array = []
	for record: Dictionary in get_boundary_records():
		var result := await _run_boundary(player, record)
		boundary_results.append(result)
		if not bool(result.get("passed", false)):
			failures += 1
		print("TRAVERSAL_BOUNDARY name=%s passed=%s final=%s displacement_m=%.3f stalled=%s" % [
			result["name"], result["passed"], result["final_position"],
			result["displacement_m"], result["stalled"],
		])

	var payload := {
		"layout_revision": "logistics-wing-greybox-medical-tuning-revision-04",
		"code_revision": _git_revision(),
		"deeper_authored_runs_m": {"pre_bend": 16.0, "post_bend": 16.0, "ratio": 1.0},
		"evidence_kind": "normal-controller-input-replay",
		"generated_utc": Time.get_datetime_string_from_system(true),
		"review_scene": "res://greybox/logistics_wing/wing_review.tscn",
		"player_scene": "res://greybox/logistics_wing/review_player.tscn",
		"controller_script": "res://player_controller.gd",
		"controller": {
			"move_speed_mps": float(player.get("move_speed")),
			"sprint_multiplier": float(player.get("sprint_multiplier")),
			"capsule_radius_m": 0.34,
			"capsule_height_m": 1.75,
			"fov_degrees": 75.0,
		},
		"method_notes": [
			"Each measurement resets the player to its named start anchor; no teleport occurs within a measured route.",
			"Movement is produced by injected physical W-key events read by the unchanged player_controller.gd physics loop.",
			"The runner sets yaw toward hand-authored waypoints; it is controller/collision evidence, not a human mouse-look walkthrough.",
			"Human spatial review remains pending because this session could not attach UI automation to the native Godot window.",
		],
		"route_results": route_results,
		"boundary_results": boundary_results,
		"failure_count": failures,
	}
	var save_error := _save_payload(payload)
	if save_error != OK:
		_fail_run("could not save traversal evidence: " + error_string(save_error))
		return
	print("TRAVERSAL_COMPLETE routes=%d boundaries=%d failures=%d output=%s" % [route_results.size(), boundary_results.size(), failures, OUTPUT_PATH])
	get_tree().quit(0 if failures == 0 else 1)


func _run_route(player: CharacterBody3D, anchors: Node3D, record: Dictionary) -> Dictionary:
	var start_anchor := anchors.get_node_or_null(String(record["start_anchor"])) as Marker3D
	var end_anchor := anchors.get_node_or_null(String(record["end_anchor"])) as Marker3D
	if start_anchor == null or end_anchor == null:
		return _failed_route_result(String(record["name"]), "missing start or end anchor")
	await _reset_player(player, start_anchor.global_position)
	var start_position := player.global_position
	var distance_m := 0.0
	var physics_frames := 0
	var collision_frames := 0
	var note := ""
	_set_key(KEY_W, true)
	for waypoint: Vector3 in record["waypoints"] as PackedVector3Array:
		var segment_result := await _walk_to_waypoint(player, waypoint)
		distance_m += float(segment_result["distance_m"])
		physics_frames += int(segment_result["physics_frames"])
		collision_frames += int(segment_result["collision_frames"])
		if not bool(segment_result["passed"]):
			note = String(segment_result["note"])
			break
	_set_key(KEY_W, false)
	await get_tree().physics_frame
	var end_error := _horizontal_distance(player.global_position, end_anchor.global_position)
	var passed := note.is_empty() and end_error <= ARRIVAL_TOLERANCE + 0.10 and player.global_position.y > -0.25
	if not passed and note.is_empty():
		note = "end anchor error exceeded tolerance"
	if passed:
		note = "arrived"
	return {
		"name": String(record["name"]),
		"start_anchor": String(record["start_anchor"]),
		"end_anchor": String(record["end_anchor"]),
		"passed": passed,
		"duration_seconds": snappedf(float(physics_frames) / PHYSICS_TICKS_PER_SECOND, 0.001),
		"distance_m": snappedf(distance_m, 0.001),
		"straight_line_m": snappedf(_horizontal_distance(start_position, end_anchor.global_position), 0.001),
		"end_error_m": snappedf(end_error, 0.001),
		"collision_frames": collision_frames,
		"final_position": _vector(player.global_position),
		"note": note,
	}


func _walk_to_waypoint(player: CharacterBody3D, waypoint: Vector3) -> Dictionary:
	var initial_distance := _horizontal_distance(player.global_position, waypoint)
	var maximum_frames := maxi(180, ceili(initial_distance / 4.0 * PHYSICS_TICKS_PER_SECOND * 3.0))
	var distance_m := 0.0
	var collision_frames := 0
	var last_progress_position := player.global_position
	for frame: int in maximum_frames:
		var remaining := _horizontal_distance(player.global_position, waypoint)
		if remaining <= ARRIVAL_TOLERANCE:
			return {
				"passed": true, "physics_frames": frame,
				"distance_m": distance_m, "collision_frames": collision_frames,
				"note": "arrived",
			}
		_face_direction(player, waypoint - player.global_position)
		var previous := player.global_position
		await get_tree().physics_frame
		distance_m += _horizontal_distance(previous, player.global_position)
		if player.get_slide_collision_count() > 0:
			collision_frames += 1
		if player.global_position.y < -0.25:
			return {
				"passed": false, "physics_frames": frame + 1,
				"distance_m": distance_m, "collision_frames": collision_frames,
				"note": "player fell below finished-floor tolerance",
			}
		if frame > 0 and frame % 120 == 0:
			if _horizontal_distance(last_progress_position, player.global_position) < 0.08:
				return {
					"passed": false, "physics_frames": frame + 1,
					"distance_m": distance_m, "collision_frames": collision_frames,
					"note": "movement stalled before waypoint %s" % waypoint,
				}
			last_progress_position = player.global_position
	return {
		"passed": false, "physics_frames": maximum_frames,
		"distance_m": distance_m, "collision_frames": collision_frames,
		"note": "timed out before waypoint %s" % waypoint,
	}


func _run_boundary(player: CharacterBody3D, record: Dictionary) -> Dictionary:
	var start := record["start"] as Vector3
	var direction := (record["direction"] as Vector3).normalized()
	await _reset_player(player, start)
	_face_direction(player, direction)
	_set_key(KEY_W, true)
	var distance_m := 0.0
	var late_position := player.global_position
	for frame: int in BOUNDARY_DRIVE_FRAMES:
		var previous := player.global_position
		await get_tree().physics_frame
		distance_m += _horizontal_distance(previous, player.global_position)
		if frame == BOUNDARY_DRIVE_FRAMES - 61:
			late_position = player.global_position
	_set_key(KEY_W, false)
	await get_tree().physics_frame
	var final_position := player.global_position
	var final_axis := _axis_value(final_position, String(record["axis"]))
	var limit := float(record["limit"])
	var within_limit := final_axis >= limit if String(record["comparison"]) == "min" else final_axis <= limit
	var stalled := _horizontal_distance(late_position, final_position) < 0.08
	var passed := within_limit and stalled and distance_m > 0.40 and final_position.y > -0.25
	return {
		"name": String(record["name"]),
		"passed": passed,
		"start_position": _vector(start),
		"final_position": _vector(final_position),
		"direction": _vector(direction),
		"axis": String(record["axis"]),
		"comparison": String(record["comparison"]),
		"limit": limit,
		"final_axis_value": snappedf(final_axis, 0.001),
		"displacement_m": snappedf(_horizontal_distance(start, final_position), 0.001),
		"travel_distance_m": snappedf(distance_m, 0.001),
		"stalled": stalled,
	}


func _reset_player(player: CharacterBody3D, position: Vector3) -> void:
	_set_key(KEY_W, false)
	player.velocity = Vector3.ZERO
	player.global_position = position
	player.rotation = Vector3.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
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


func _save_payload(payload: Dictionary) -> Error:
	var absolute_path := ProjectSettings.globalize_path(OUTPUT_PATH)
	var make_error := DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	if make_error != OK:
		return make_error
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(payload, "\t") + "\n")
	return OK


func _route(name_value: String, start_anchor: String, end_anchor: String, waypoints: Array[Vector3]) -> Dictionary:
	return {
		"name": name_value,
		"start_anchor": start_anchor,
		"end_anchor": end_anchor,
		"waypoints": PackedVector3Array(waypoints),
	}


func _boundary(name_value: String, start: Vector3, direction: Vector3, axis: String, comparison: String, limit: float) -> Dictionary:
	return {
		"name": name_value,
		"start": start,
		"direction": direction,
		"axis": axis,
		"comparison": comparison,
		"limit": limit,
	}


func _failed_route_result(route_name: String, note: String) -> Dictionary:
	return {
		"name": route_name, "passed": false, "duration_seconds": 0.0,
		"distance_m": 0.0, "straight_line_m": 0.0, "end_error_m": INF,
		"collision_frames": 0, "final_position": _vector(Vector3.ZERO), "note": note,
	}


func _horizontal_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


func _axis_value(value: Vector3, axis: String) -> float:
	return value.x if axis == "x" else value.z


func _vector(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


func _git_revision() -> String:
	var output: Array = []
	var exit_code := OS.execute("git", PackedStringArray(["rev-parse", "HEAD"]), output, true)
	if exit_code != 0 or output.is_empty():
		return "unavailable"
	return String(output[0]).strip_edges()


func _fail_run(message: String) -> void:
	_set_key(KEY_W, false)
	push_error("TRAVERSAL_FAILED: " + message)
	get_tree().quit(1)
