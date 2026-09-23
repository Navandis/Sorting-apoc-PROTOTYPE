extends Node3D
class_name ReceivingPhysicsPileProof

const ItemInstanceScript = preload("res://item_instance.gd")
const WorldItemScript = preload("res://world_item.gd")
const ITEM_CATALOG: ItemCatalog = preload("res://data/items/item_catalog.tres")

const PROOF_DEPTH_M := 3.60
const PROOF_WIDTH_M := 4.80
const REVIEW_HEIGHT_M := 1.50
const CASE_B_RECESS_M := 0.45
const CASE_B_LIVE_DECK_TOP_Y := 0.82
const COMMON_PROOF_MASS_KG := 1.0
const STABLE_INTERVAL_S := 0.90
const SETTLE_TIMEOUT_S := 15.0
const LINEAR_SPEED_THRESHOLD_MPS := 0.04
const ANGULAR_SPEED_THRESHOLD_RPS := 0.08
const OOB_CONTACT_TOLERANCE_M := 0.02
const INITIAL_VERTICAL_GAP_M := 0.18
const INITIAL_BOTTOM_Y_M := 1.20
const SPAWN_STAGGER_S := 0.25
const RUN_ALL_FLAG := "--pile-proof-run-all"
const BATCH_ARGUMENT_PREFIX := "--pile-proof-batch="
const INSTANCE_ARGUMENT_PREFIX := "--pile-proof-instance="

const MANIFEST_SEEDS := {
	"A1": 230901,
	"A2": 230917,
	"A3": 230933,
	"B1": 231101,
	"B2": 231117,
	"B3": 231133,
	"C1": 231301,
	"C2": 231317,
	"C3": 231333,
	"D1": 231501,
	"D2": 231517,
	"D3": 231533,
}

const MANIFEST_ITEM_IDS := {
	"A1": ["loot_000001", "loot_000005", "loot_000011", "loot_000015", "loot_000019", "loot_000024", "loot_000028", "loot_000030", "loot_000032", "loot_000037", "loot_000038", "loot_000042"],
	"A2": ["loot_000002", "loot_000006", "loot_000012", "loot_000013", "loot_000016", "loot_000020", "loot_000025", "loot_000029", "loot_000031", "loot_000033", "loot_000039", "loot_000040"],
	"A3": ["loot_000003", "loot_000004", "loot_000007", "loot_000010", "loot_000014", "loot_000017", "loot_000018", "loot_000021", "loot_000026", "loot_000027", "loot_000035", "loot_000041"],
	"B1": ["loot_000002", "loot_000003", "loot_000011", "loot_000014", "loot_000015", "loot_000017", "loot_000028", "loot_000032", "loot_000038", "loot_000005", "loot_000019", "loot_000024"],
	"B2": ["loot_000002", "loot_000012", "loot_000014", "loot_000016", "loot_000018", "loot_000028", "loot_000033", "loot_000040", "loot_000042", "loot_000001", "loot_000020", "loot_000026"],
	"B3": ["loot_000003", "loot_000011", "loot_000013", "loot_000015", "loot_000017", "loot_000032", "loot_000035", "loot_000038", "loot_000040", "loot_000004", "loot_000022", "loot_000030"],
	"C1": ["loot_000013", "loot_000014", "loot_000037", "loot_000038", "loot_000040", "loot_000041", "loot_000042", "loot_000011", "loot_000005", "loot_000019", "loot_000024", "loot_000031"],
	"C2": ["loot_000013", "loot_000037", "loot_000038", "loot_000040", "loot_000041", "loot_000042", "loot_000033", "loot_000015", "loot_000006", "loot_000020", "loot_000027", "loot_000029"],
	"C3": ["loot_000011", "loot_000013", "loot_000014", "loot_000037", "loot_000038", "loot_000040", "loot_000041", "loot_000042", "loot_000004", "loot_000012", "loot_000026", "loot_000030"],
	"D1": ["loot_000001", "loot_000004", "loot_000005", "loot_000006", "loot_000019", "loot_000020", "loot_000022", "loot_000024", "loot_000025", "loot_000030", "loot_000002", "loot_000012"],
	"D2": ["loot_000001", "loot_000005", "loot_000007", "loot_000008", "loot_000009", "loot_000019", "loot_000021", "loot_000023", "loot_000026", "loot_000027", "loot_000028", "loot_000033"],
	"D3": ["loot_000004", "loot_000006", "loot_000008", "loot_000009", "loot_000010", "loot_000020", "loot_000022", "loot_000024", "loot_000025", "loot_000029", "loot_000015", "loot_000035"],
}

@export var auto_start := true

var _selected_batch := "A"
var _selected_instance := 1
var _run_all := false
var _last_build_error := ""


func _ready() -> void:
	_parse_arguments(OS.get_cmdline_user_args())
	if auto_start:
		call_deferred("_start_proof")


func get_all_manifests() -> Dictionary:
	var manifests := {}
	for run_key: String in MANIFEST_ITEM_IDS:
		manifests[run_key] = {
			"batch": run_key.left(1),
			"instance": int(run_key.right(1)),
			"seed": int(MANIFEST_SEEDS[run_key]),
			"items": PackedStringArray(MANIFEST_ITEM_IDS[run_key]),
		}
	return manifests


func get_proof_dimensions() -> Vector3:
	return Vector3(PROOF_DEPTH_M, REVIEW_HEIGHT_M, PROOF_WIDTH_M)


func get_last_build_error() -> String:
	return _last_build_error


func create_temporary_body(definition: ItemDefinition, body_name: String) -> RigidBody3D:
	_last_build_error = ""
	if definition == null:
		_last_build_error = "missing ItemDefinition"
		return null
	if definition.visual_scene == null:
		_last_build_error = "%s has no visual_scene" % String(definition.item_id)
		return null

	var visual := definition.visual_scene.instantiate() as Node3D
	if visual == null:
		_last_build_error = "%s visual_scene does not instantiate as Node3D" % String(definition.item_id)
		return null
	visual.name = "VisualRoot"

	var points := PackedVector3Array()
	_collect_mesh_vertices(visual, Transform3D.IDENTITY, points)
	if points.size() < 4:
		_last_build_error = "%s visual yields only %d usable mesh points" % [String(definition.item_id), points.size()]
		visual.free()
		return null

	var body := RigidBody3D.new()
	body.name = body_name
	body.mass = COMMON_PROOF_MASS_KG
	body.can_sleep = true
	body.collision_layer = 1
	body.collision_mask = 1
	body.add_child(visual)

	var hull := ConvexPolygonShape3D.new()
	hull.points = points
	var collision := CollisionShape3D.new()
	collision.name = "PhysicsHull"
	collision.shape = hull
	body.add_child(collision)
	body.set_meta(&"pile_proof_definition", definition)
	body.set_meta(&"pile_proof_item_id", String(definition.item_id))
	return body


func freeze_bodies_for_review(bodies: Array, run_key: String) -> void:
	for index: int in range(bodies.size()):
		var body := bodies[index] as RigidBody3D
		if body == null or not is_instance_valid(body):
			continue
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
		body.freeze = true
		body.collision_layer = 0
		body.collision_mask = 0
		if body.get_node_or_null("WorldItem") != null:
			continue
		var definition := body.get_meta(&"pile_proof_definition") as ItemDefinition
		if definition == null:
			continue
		var item_instance := ItemInstanceScript.new(
			definition,
			"pile-proof-%s-%02d-%s" % [run_key.to_lower(), index + 1, String(definition.item_id)]
		)
		var world_item := WorldItemScript.new() as WorldItem
		world_item.name = "WorldItem"
		body.add_child(world_item)
		world_item.configure_existing(body, item_instance)


func place_body_above_current_pile(
	body: RigidBody3D,
	existing_bodies: Array,
	horizontal_position: Vector2,
	rotation_basis: Basis
) -> Transform3D:
	var hull := (body.get_node("PhysicsHull") as CollisionShape3D).shape as ConvexPolygonShape3D
	var rotated_bounds := _points_aabb(hull.points, Transform3D(rotation_basis, Vector3.ZERO))
	var current_maximum_y := 0.0
	for value: Variant in existing_bodies:
		var existing := value as RigidBody3D
		if existing == null or not is_instance_valid(existing):
			continue
		current_maximum_y = maxf(current_maximum_y, _body_hull_aabb(existing).end.y)
	var spawn_bottom_y := maxf(INITIAL_BOTTOM_Y_M, current_maximum_y + INITIAL_VERTICAL_GAP_M)
	body.transform = Transform3D(
		rotation_basis,
		Vector3(
			horizontal_position.x,
			spawn_bottom_y - rotated_bounds.position.y,
			horizontal_position.y
		)
	)
	return body.transform


func _start_proof() -> void:
	await get_tree().physics_frame
	if _run_all:
		var run_keys := MANIFEST_ITEM_IDS.keys()
		run_keys.sort()
		var completed := 0
		var all_successful := true
		for value: Variant in run_keys:
			var metrics := await _run_manifest(String(value), false)
			print("PILE_PROOF_METRIC %s" % JSON.stringify(metrics))
			completed += 1
			all_successful = all_successful and is_successful_run_metrics(metrics)
		print(
			"PILE_PROOF_ALL_COMPLETE runs=%d status=%s"
			% [completed, "PASS" if all_successful else "FAIL"]
		)
		get_tree().quit(0 if all_successful else 1)
		return

	var run_key := "%s%d" % [_selected_batch, _selected_instance]
	var metrics := await _run_manifest(run_key, true)
	print("PILE_PROOF_METRIC %s" % JSON.stringify(metrics))
	_update_status_label(metrics)


func is_successful_run_metrics(metrics: Dictionary) -> bool:
	return (
		String(metrics.get("status", "")) == "SETTLED"
		and (metrics.get("escaped_or_oob", []) as Array).is_empty()
		and (metrics.get("invalid_items", []) as Array).is_empty()
	)


func _run_manifest(run_key: String, interactive: bool) -> Dictionary:
	_clear_pile_items()
	_set_front_wall_enabled(true)
	await get_tree().physics_frame

	var manifest := get_all_manifests().get(run_key, {}) as Dictionary
	if manifest.is_empty():
		return {"run": run_key, "status": "INVALID", "error": "unknown manifest"}
	var bodies: Array[RigidBody3D] = []
	var invalid_items := PackedStringArray()
	var generator := RandomNumberGenerator.new()
	generator.seed = int(manifest["seed"])
	var items := manifest["items"] as PackedStringArray
	var simulation_elapsed := 0.0
	var step := 1.0 / float(Engine.physics_ticks_per_second)
	var stagger_frames := maxi(1, ceili(SPAWN_STAGGER_S * float(Engine.physics_ticks_per_second)))

	for index: int in range(items.size()):
		var item_id := StringName(items[index])
		var definition := ITEM_CATALOG.get_definition_by_id(item_id)
		var body := create_temporary_body(definition, "%s_%02d_%s" % [run_key, index + 1, String(item_id)])
		if body == null:
			invalid_items.append("%s: %s" % [String(item_id), _last_build_error])
			continue
		body.set_meta(&"pile_proof_manifest_index", index)
		get_node("PileItems").add_child(body)

		var rotation := Vector3(
			generator.randf_range(-PI, PI),
			generator.randf_range(-PI, PI),
			generator.randf_range(-PI, PI)
		)
		var rotation_basis := Basis.from_euler(rotation)
		var hull := (body.get_node("PhysicsHull") as CollisionShape3D).shape as ConvexPolygonShape3D
		var rotated_bounds := _points_aabb(hull.points, Transform3D(rotation_basis, Vector3.ZERO))
		var x_min := -PROOF_DEPTH_M * 0.5 - rotated_bounds.position.x + 0.04
		var x_max := PROOF_DEPTH_M * 0.5 - rotated_bounds.end.x - 0.04
		var z_min := -PROOF_WIDTH_M * 0.5 - rotated_bounds.position.z + 0.04
		var z_max := PROOF_WIDTH_M * 0.5 - rotated_bounds.end.z - 0.04
		var x := clampf(generator.randf_range(-0.58, 0.58), x_min, x_max) if x_min <= x_max else 0.0
		var z := clampf(generator.randf_range(-0.82, 0.82), z_min, z_max) if z_min <= z_max else 0.0
		place_body_above_current_pile(body, bodies, Vector2(x, z), rotation_basis)
		bodies.append(body)
		for frame_index: int in range(stagger_frames):
			await get_tree().physics_frame
			simulation_elapsed += step

	var stable_elapsed := 0.0
	var settled := false
	while simulation_elapsed < SETTLE_TIMEOUT_S:
		await get_tree().physics_frame
		simulation_elapsed += step
		if _all_bodies_stable(bodies):
			stable_elapsed += step
			if stable_elapsed >= STABLE_INTERVAL_S:
				settled = true
				break
		else:
			stable_elapsed = 0.0

	var max_height := _maximum_pile_height(bodies)
	var escaped := _out_of_bounds_bodies(bodies)
	freeze_bodies_for_review(bodies, run_key)
	_set_front_wall_enabled(not interactive)

	return {
		"run": run_key,
		"batch": manifest["batch"],
		"instance": manifest["instance"],
		"seed": manifest["seed"],
		"items": Array(items),
		"status": "SETTLED" if settled else "NOT SETTLED",
		"settle_duration_s": snappedf(simulation_elapsed, 0.001),
		"max_height_m": snappedf(max_height, 0.001),
		"escaped_or_oob": Array(escaped),
		"invalid_items": Array(invalid_items),
	}


func _collect_mesh_vertices(node: Node, accumulated_transform: Transform3D, points: PackedVector3Array) -> void:
	var next_transform := accumulated_transform
	if node is Node3D:
		next_transform = accumulated_transform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.mesh != null:
			for surface_index: int in range(mesh_instance.mesh.get_surface_count()):
				var arrays := mesh_instance.mesh.surface_get_arrays(surface_index)
				if arrays.size() <= Mesh.ARRAY_VERTEX:
					continue
				var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
				for vertex: Vector3 in vertices:
					points.append(next_transform * vertex)
	for child: Node in node.get_children():
		_collect_mesh_vertices(child, next_transform, points)


func _points_aabb(points: PackedVector3Array, point_transform: Transform3D) -> AABB:
	if points.is_empty():
		return AABB()
	var first := point_transform * points[0]
	var bounds := AABB(first, Vector3.ZERO)
	for index: int in range(1, points.size()):
		bounds = bounds.expand(point_transform * points[index])
	return bounds


func _all_bodies_stable(bodies: Array[RigidBody3D]) -> bool:
	for body: RigidBody3D in bodies:
		if body.sleeping:
			continue
		if body.linear_velocity.length() > LINEAR_SPEED_THRESHOLD_MPS:
			return false
		if body.angular_velocity.length() > ANGULAR_SPEED_THRESHOLD_RPS:
			return false
	return not bodies.is_empty()


func _maximum_pile_height(bodies: Array[RigidBody3D]) -> float:
	var maximum := 0.0
	for body: RigidBody3D in bodies:
		var hull := (body.get_node("PhysicsHull") as CollisionShape3D).shape as ConvexPolygonShape3D
		for point: Vector3 in hull.points:
			maximum = maxf(maximum, (body.transform * point).y)
	return maximum


func _body_hull_aabb(body: RigidBody3D) -> AABB:
	var hull := (body.get_node("PhysicsHull") as CollisionShape3D).shape as ConvexPolygonShape3D
	return _points_aabb(hull.points, body.transform)


func _out_of_bounds_bodies(bodies: Array[RigidBody3D]) -> PackedStringArray:
	var escaped := PackedStringArray()
	for body: RigidBody3D in bodies:
		var hull := (body.get_node("PhysicsHull") as CollisionShape3D).shape as ConvexPolygonShape3D
		var bounds := _points_aabb(hull.points, body.transform)
		if is_bounds_out_of_bounds(bounds):
			escaped.append(String(body.get_meta(&"pile_proof_item_id", body.name)))
	return escaped


func is_bounds_out_of_bounds(bounds: AABB) -> bool:
	return (
		bounds.position.x < -PROOF_DEPTH_M * 0.5 - OOB_CONTACT_TOLERANCE_M
		or bounds.end.x > PROOF_DEPTH_M * 0.5 + OOB_CONTACT_TOLERANCE_M
		or bounds.position.z < -PROOF_WIDTH_M * 0.5 - OOB_CONTACT_TOLERANCE_M
		or bounds.end.z > PROOF_WIDTH_M * 0.5 + OOB_CONTACT_TOLERANCE_M
		or bounds.position.y < -OOB_CONTACT_TOLERANCE_M
	)


func _clear_pile_items() -> void:
	var pile_items := get_node_or_null("PileItems")
	if pile_items == null:
		return
	for child: Node in pile_items.get_children():
		pile_items.remove_child(child)
		child.free()


func _set_front_wall_enabled(enabled: bool) -> void:
	var front_shape := get_node_or_null("Containment/FrontWall/CollisionShape3D") as CollisionShape3D
	if front_shape != null:
		front_shape.disabled = not enabled


func _parse_arguments(arguments: PackedStringArray) -> void:
	_run_all = arguments.has(RUN_ALL_FLAG)
	for argument: String in arguments:
		if argument.begins_with(BATCH_ARGUMENT_PREFIX):
			var requested_batch := argument.trim_prefix(BATCH_ARGUMENT_PREFIX).to_upper()
			if requested_batch in ["A", "B", "C", "D"]:
				_selected_batch = requested_batch
		elif argument.begins_with(INSTANCE_ARGUMENT_PREFIX):
			var requested_instance := int(argument.trim_prefix(INSTANCE_ARGUMENT_PREFIX))
			if requested_instance in [1, 2, 3]:
				_selected_instance = requested_instance


func _update_status_label(metrics: Dictionary) -> void:
	var label := get_node_or_null("HUD/ProofStatus") as Label
	if label == null:
		return
	label.text = (
		"REAL-ITEM PILE PROOF  %s   seed %d\n%s in %.3f s   max height %.3f m   OOB %d\n"
		+ "Case B correspondence: recess %.2f m / live deck top Y %.2f m\n"
		+ "Frozen review: ordinary LMB TAKE; no re-settling after removal."
	) % [
		String(metrics.get("run", "?")),
		int(metrics.get("seed", 0)),
		String(metrics.get("status", "?")),
		float(metrics.get("settle_duration_s", 0.0)),
		float(metrics.get("max_height_m", 0.0)),
		(metrics.get("escaped_or_oob", []) as Array).size(),
		CASE_B_RECESS_M,
		CASE_B_LIVE_DECK_TOP_Y,
	]
