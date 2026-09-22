@tool
extends Node3D
class_name FixedLadder

const FUNCTIONAL_WIDTH_M := 0.42
const FUNCTIONAL_DEPTH_M := 0.14
const PLAYER_STANDOFF_M := 0.46
const MAX_ATTACH_CORRECTION_M := 0.12
const REARM_AWAY_DISTANCE_M := 0.198
const APPROACH_WIDTH_M := 1.12
const APPROACH_DEPTH_M := 0.62
const APPROACH_HEIGHT_M := 1.85
const TOP_VIEW_MARGIN_M := 0.10
const CEILING_SAFETY_MARGIN_M := 0.04
const YAW_CLAMP_DEGREES := 70.0
const CLIMB_SPEED_M_S := 1.65
const MIN_CLIMB_RANGE_M := 0.05
const ROOT_TRANSFORM_EPSILON := 0.0001
const DIMENSION_EPSILON_M := 0.0001

@export_range(0.10, 8.0, 0.01, "or_greater", "or_less") var ladder_height_m := 2.60:
	set(value):
		ladder_height_m = value
		_request_refresh()

@export_range(0.10, 10.0, 0.01, "or_greater", "or_less") var overhead_limit_local_y_m := 3.40:
	set(value):
		overhead_limit_local_y_m = value
		_request_refresh()

@export var show_authoring_preview := true:
	set(value):
		show_authoring_preview = value
		_request_refresh()

var _refresh_requested := true
var _last_authoring_fingerprint := ""
var _approach_players: Dictionary = {}
var _suppressed_players: Dictionary = {}


func _ready() -> void:
	add_to_group(&"fixed_ladders")
	var approach := get_node_or_null("ApproachArea") as Area3D
	if approach != null:
		if not approach.body_entered.is_connected(_on_approach_body_entered):
			approach.body_entered.connect(_on_approach_body_entered)
		if not approach.body_exited.is_connected(_on_approach_body_exited):
			approach.body_exited.connect(_on_approach_body_exited)
	_ensure_instance_shape_resources()
	refresh_authoring_state()


func _process(_delta: float) -> void:
	var fingerprint := _authoring_fingerprint()
	if _refresh_requested or fingerprint != _last_authoring_fingerprint:
		refresh_authoring_state()


func refresh_authoring_state() -> void:
	_ensure_instance_shape_resources()
	_update_normalized_visual()
	_update_movement_collision()
	_update_approach_area()
	_update_markers()
	_rebuild_authoring_preview()
	_refresh_requested = false
	_last_authoring_fingerprint = _authoring_fingerprint()
	update_configuration_warnings()


func get_climb_anchor_world_position() -> Vector3:
	var anchor := get_node_or_null("ClimbAnchor") as Marker3D
	return anchor.global_position if anchor != null else global_position


func get_ladder_top_world_y() -> float:
	return (global_transform * Vector3(0.0, ladder_height_m, 0.0)).y


func get_overhead_limit_world_y() -> float:
	return (global_transform * Vector3(0.0, overhead_limit_local_y_m, 0.0)).y


func get_ladder_forward_world() -> Vector3:
	return global_transform.basis.z.normalized()


func get_ladder_right_world() -> Vector3:
	return global_transform.basis.x.normalized()


func get_ladder_yaw_world() -> float:
	return global_rotation.y


func get_bottom_player_root_world_y() -> float:
	return global_position.y


func get_climb_speed_m_s() -> float:
	return CLIMB_SPEED_M_S


func get_yaw_clamp_radians() -> float:
	return deg_to_rad(YAW_CLAMP_DEGREES)


func get_max_attach_correction_m() -> float:
	return MAX_ATTACH_CORRECTION_M


func get_rearm_away_distance_m() -> float:
	return REARM_AWAY_DISTANCE_M


func get_horizontal_climb_anchor_distance_m(player: Node3D) -> float:
	if player == null or not is_instance_valid(player):
		return INF
	var player_local := to_local(player.global_position)
	return Vector2(player_local.x, player_local.z - PLAYER_STANDOFF_M).length()


func is_player_close_enough_to_attach(player: Node3D) -> bool:
	return get_horizontal_climb_anchor_distance_m(player) <= MAX_ATTACH_CORRECTION_M


func get_player_root_climb_limits(
	player_eye_offset_from_root: float,
	player_body_top_offset: float
) -> Dictionary:
	var preferred_player_root_y := (
		get_ladder_top_world_y()
		+ TOP_VIEW_MARGIN_M
		- player_eye_offset_from_root
	)
	var ceiling_safe_player_root_y := (
		get_overhead_limit_world_y()
		- player_body_top_offset
		- CEILING_SAFETY_MARGIN_M
	)
	var minimum_y := get_bottom_player_root_world_y()
	var maximum_y := minf(preferred_player_root_y, ceiling_safe_player_root_y)
	var valid := maximum_y >= minimum_y + MIN_CLIMB_RANGE_M
	return {
		"valid": valid,
		"minimum_y": minimum_y,
		"maximum_y": maximum_y,
		"preferred_player_root_y": preferred_player_root_y,
		"ceiling_safe_player_root_y": ceiling_safe_player_root_y,
		"reason": "" if valid else "Authored ladder and overhead leave no usable player climb range.",
	}


func is_player_in_approach_area(player: Node3D) -> bool:
	if player == null or not is_instance_valid(player):
		return false
	var instance_id := player.get_instance_id()
	if _approach_players.has(instance_id):
		return true
	var approach := get_node_or_null("ApproachArea") as Area3D
	return approach != null and approach.overlaps_body(player)


func is_player_on_front_side(player: Node3D) -> bool:
	if player == null:
		return false
	var relative := player.global_position - global_position
	return relative.dot(get_ladder_forward_world()) > 0.0


func is_attach_suppressed_for(player: Node3D) -> bool:
	if player == null or not is_instance_valid(player):
		return false
	var instance_id := player.get_instance_id()
	if not _suppressed_players.has(instance_id):
		return false
	if (
		not is_player_in_approach_area(player)
		or get_horizontal_climb_anchor_distance_m(player) >= REARM_AWAY_DISTANCE_M
	):
		_suppressed_players.erase(instance_id)
		return false
	return true


func suppress_until_approach_exit(player: Node3D) -> void:
	if player != null:
		_suppressed_players[player.get_instance_id()] = true


func is_authoring_valid() -> bool:
	if (
		ladder_height_m <= DIMENSION_EPSILON_M
		or overhead_limit_local_y_m <= CEILING_SAFETY_MARGIN_M + MIN_CLIMB_RANGE_M
		or not transform.basis.get_scale().is_equal_approx(Vector3.ONE)
		or absf(rotation.x) > ROOT_TRANSFORM_EPSILON
		or absf(rotation.z) > ROOT_TRANSFORM_EPSILON
	):
		return false
	var visual_bounds := _get_source_bounds(get_node_or_null("Visual"))
	if not bool(visual_bounds.get("valid", false)):
		return false
	var bounds := visual_bounds.get("bounds", AABB()) as AABB
	return minf(bounds.size.x, minf(bounds.size.y, bounds.size.z)) > DIMENSION_EPSILON_M


func _on_approach_body_entered(body: Node3D) -> void:
	_approach_players[body.get_instance_id()] = weakref(body)


func _on_approach_body_exited(body: Node3D) -> void:
	var instance_id := body.get_instance_id()
	_approach_players.erase(instance_id)
	_suppressed_players.erase(instance_id)


func _get_configuration_warnings() -> PackedStringArray:
	var result := PackedStringArray()
	if ladder_height_m <= DIMENSION_EPSILON_M:
		result.append("ERROR: Ladder height must be positive.")
	if overhead_limit_local_y_m <= DIMENSION_EPSILON_M:
		result.append("ERROR: Overhead limit must be above the ladder root.")
	if not transform.basis.get_scale().is_equal_approx(Vector3.ONE):
		result.append("ERROR: FixedLadder root scale must remain (1, 1, 1); use ladder_height_m instead.")
	if absf(rotation.x) > ROOT_TRANSFORM_EPSILON or absf(rotation.z) > ROOT_TRANSFORM_EPSILON:
		result.append("ERROR: FixedLadder supports translation and yaw only; pitch and roll must remain zero.")
	if overhead_limit_local_y_m <= CEILING_SAFETY_MARGIN_M + MIN_CLIMB_RANGE_M:
		result.append("ERROR: Authored overhead leaves no positive climb range above the root.")
	var visual_bounds := _get_source_bounds(get_node_or_null("Visual"))
	if not bool(visual_bounds.get("valid", false)):
		result.append("ERROR: Visual must contain a normalized mesh source.")
	return result


func _ensure_instance_shape_resources() -> void:
	for path: String in ["MovementCollision/Shape", "ApproachArea/Shape"]:
		var shape_node := get_node_or_null(path) as CollisionShape3D
		if shape_node == null or shape_node.shape == null:
			continue
		if not shape_node.shape.resource_local_to_scene:
			shape_node.shape = shape_node.shape.duplicate()
			shape_node.shape.resource_local_to_scene = true


func _update_normalized_visual() -> void:
	var visual := get_node_or_null("Visual") as Node3D
	if visual == null:
		return
	visual.scale = Vector3.ONE
	var result := _get_source_bounds(visual)
	if not bool(result.get("valid", false)):
		return
	var bounds := result.get("bounds", AABB()) as AABB
	if minf(bounds.size.x, minf(bounds.size.y, bounds.size.z)) <= DIMENSION_EPSILON_M:
		return
	visual.scale = Vector3(
		FUNCTIONAL_WIDTH_M / bounds.size.x,
		maxf(ladder_height_m, DIMENSION_EPSILON_M) / bounds.size.y,
		FUNCTIONAL_DEPTH_M / bounds.size.z
	)


func _get_source_bounds(branch: Node) -> Dictionary:
	if not (branch is Node3D):
		return {"valid": false, "bounds": AABB()}
	var state := {"valid": false, "bounds": AABB()}
	for child: Node in branch.get_children():
		_scan_source_bounds(child, Transform3D.IDENTITY, state)
	return state


func _scan_source_bounds(
	node: Node,
	parent_transform: Transform3D,
	state: Dictionary
) -> void:
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
		_scan_source_bounds(child, transform_to_branch, state)


func _update_movement_collision() -> void:
	var shape_node := get_node_or_null("MovementCollision/Shape") as CollisionShape3D
	if shape_node == null:
		return
	var box := shape_node.shape as BoxShape3D
	if box == null:
		return
	var height := maxf(ladder_height_m, DIMENSION_EPSILON_M)
	box.size = Vector3(FUNCTIONAL_WIDTH_M, height, FUNCTIONAL_DEPTH_M)
	shape_node.position = Vector3(0.0, height * 0.5, 0.0)


func _update_approach_area() -> void:
	var shape_node := get_node_or_null("ApproachArea/Shape") as CollisionShape3D
	if shape_node == null:
		return
	var box := shape_node.shape as BoxShape3D
	if box == null:
		return
	box.size = Vector3(APPROACH_WIDTH_M, APPROACH_HEIGHT_M, APPROACH_DEPTH_M)
	shape_node.position = Vector3(
		0.0,
		APPROACH_HEIGHT_M * 0.5,
		FUNCTIONAL_DEPTH_M * 0.5 + APPROACH_DEPTH_M * 0.5 + 0.02
	)


func _update_markers() -> void:
	var anchor := get_node_or_null("ClimbAnchor") as Marker3D
	if anchor != null:
		anchor.position = Vector3(0.0, 0.0, PLAYER_STANDOFF_M)
	var top := get_node_or_null("LadderTop") as Marker3D
	if top != null:
		top.position = Vector3(0.0, ladder_height_m, 0.0)
	var overhead := get_node_or_null("OverheadLimit") as Marker3D
	if overhead != null:
		overhead.position = Vector3(0.0, overhead_limit_local_y_m, 0.0)


func _rebuild_authoring_preview() -> void:
	var preview := get_node_or_null("AuthoringPreview") as Node3D
	if preview == null:
		return
	for child: Node in preview.get_children():
		child.free()
	preview.visible = show_authoring_preview and Engine.is_editor_hint()
	if not show_authoring_preview:
		return
	var envelope := MeshInstance3D.new()
	envelope.name = "LadderEnvelope"
	var envelope_mesh := BoxMesh.new()
	envelope_mesh.size = Vector3(FUNCTIONAL_WIDTH_M, maxf(ladder_height_m, DIMENSION_EPSILON_M), FUNCTIONAL_DEPTH_M)
	envelope_mesh.material = _preview_material(Color(0.20, 0.78, 1.0, 0.16))
	envelope.mesh = envelope_mesh
	envelope.position.y = maxf(ladder_height_m, DIMENSION_EPSILON_M) * 0.5
	preview.add_child(envelope)
	var overhead_line := MeshInstance3D.new()
	overhead_line.name = "OverheadLimitLine"
	var overhead_mesh := BoxMesh.new()
	overhead_mesh.size = Vector3(FUNCTIONAL_WIDTH_M + 0.20, 0.015, 0.03)
	overhead_mesh.material = _preview_material(Color(1.0, 0.42, 0.16, 0.72))
	overhead_line.mesh = overhead_mesh
	overhead_line.position.y = overhead_limit_local_y_m
	preview.add_child(overhead_line)


func _preview_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material


func _authoring_fingerprint() -> String:
	return "|".join([
		str(ladder_height_m),
		str(overhead_limit_local_y_m),
		str(show_authoring_preview),
		str(transform.basis.get_scale()),
		str(rotation.x),
		str(rotation.z),
	])


func _request_refresh() -> void:
	_refresh_requested = true
