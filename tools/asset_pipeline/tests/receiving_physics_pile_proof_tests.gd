extends SceneTree

const PROOF_SCENE_PATH := "res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.tscn"
const PROOF_SCRIPT_PATH := "res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.gd"
const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const CATALOG_PATH := "res://data/items/item_catalog.tres"
const BLOCKED_IDS: Array[StringName] = [&"loot_000034", &"loot_000036"]
const EXPECTED_CONTAINMENT := Vector3(3.6, 1.5, 4.8)
const EXPECTED_SEEDS := {
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
const EXPECTED_ITEMS := {
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

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check(ResourceLoader.exists(PROOF_SCENE_PATH), "isolated physics-pile proof scene exists"):
		_finish()
		return
	_check(ResourceLoader.exists(PROOF_SCRIPT_PATH), "physics-pile proof script exists")

	var packed := load(PROOF_SCENE_PATH) as PackedScene
	if not _check(packed != null, "physics-pile proof scene loads"):
		_finish()
		return
	var proof := packed.instantiate() as Node3D
	if not _check(proof != null, "physics-pile proof scene instantiates"):
		_finish()
		return
	proof.set("auto_start", false)
	root.add_child(proof)
	await process_frame

	_assert_manifests(proof)
	_assert_cli_selection(proof)
	_assert_runner_failure_classification(proof)
	_assert_oob_boundaries(proof)
	_assert_containment(proof)
	await _assert_real_visual_hulls(proof)
	_assert_spawn_separation(proof)
	await _assert_freeze_and_ordinary_take(proof)
	_assert_isolation_from_gameplay()
	proof.free()
	_finish()


func _assert_cli_selection(proof: Node) -> void:
	proof.call(
		"_parse_arguments",
		PackedStringArray(["--pile-proof-batch=C", "--pile-proof-instance=3"])
	)
	_check(String(proof.get("_selected_batch")) == "C", "CLI selects the requested batch family")
	_check(int(proof.get("_selected_instance")) == 3, "CLI selects the requested batch instance")


func _assert_runner_failure_classification(proof: Node) -> void:
	if not _check(
		proof.has_method("is_successful_run_metrics"),
		"batch runner exposes its technical success classification"
	):
		return
	var settled := {
		"status": "SETTLED",
		"escaped_or_oob": [],
		"invalid_items": [],
	}
	_check(proof.call("is_successful_run_metrics", settled), "clean settled metrics are successful")
	var timed_out := settled.duplicate(true)
	timed_out["status"] = "NOT SETTLED"
	_check(not proof.call("is_successful_run_metrics", timed_out), "timeout metrics fail the batch runner")
	var escaped := settled.duplicate(true)
	escaped["escaped_or_oob"] = ["loot_000001"]
	_check(not proof.call("is_successful_run_metrics", escaped), "OOB metrics fail the batch runner")
	var invalid := settled.duplicate(true)
	invalid["invalid_items"] = ["loot_000001: missing mesh"]
	_check(not proof.call("is_successful_run_metrics", invalid), "invalid-item metrics fail the batch runner")


func _assert_oob_boundaries(proof: Node) -> void:
	if not _check(proof.has_method("is_bounds_out_of_bounds"), "proof exposes its OOB boundary rule"):
		return
	_check(
		not proof.call("is_bounds_out_of_bounds", AABB(Vector3(-1.7, 0.0, -2.3), Vector3(3.4, 0.5, 4.6))),
		"a hull wholly inside the usable floor is in bounds"
	)
	_check(
		not proof.call("is_bounds_out_of_bounds", AABB(Vector3(-1.81, -0.01, -2.41), Vector3(3.62, 0.5, 4.82))),
		"small contact-tolerance penetration is not reported as OOB"
	)
	_check(
		proof.call("is_bounds_out_of_bounds", AABB(Vector3(-1.84, 0.0, -0.1), Vector3(0.2, 0.2, 0.2))),
		"a partially escaped X extent is OOB"
	)
	_check(
		proof.call("is_bounds_out_of_bounds", AABB(Vector3(-0.1, 0.0, 2.25), Vector3(0.2, 0.2, 0.2))),
		"a partially escaped Z extent is OOB"
	)
	_check(
		proof.call("is_bounds_out_of_bounds", AABB(Vector3(-0.1, -0.04, -0.1), Vector3(0.2, 0.2, 0.2))),
		"a hull penetrating below the floor tolerance is OOB"
	)


func _assert_manifests(proof: Node) -> void:
	var manifests := proof.call("get_all_manifests") as Dictionary
	_check(manifests.size() == 12, "proof owns exactly twelve fixed manifests")
	var catalog := load(CATALOG_PATH) as ItemCatalog
	_check(catalog != null, "authoritative item catalogue loads")
	if catalog == null:
		return
	for run_key: String in EXPECTED_ITEMS:
		_check(manifests.has(run_key), "%s manifest exists" % run_key)
		if not manifests.has(run_key):
			continue
		var manifest := manifests[run_key] as Dictionary
		var items := manifest.get("items", PackedStringArray()) as PackedStringArray
		_check(items.size() == 12, "%s manifest has exactly twelve IDs" % run_key)
		_check(int(manifest.get("seed", -1)) == int(EXPECTED_SEEDS[run_key]), "%s seed is stable" % run_key)
		_check(Array(items) == EXPECTED_ITEMS[run_key], "%s exact manifest is frozen" % run_key)
		_check(String(manifest.get("batch", "")) == run_key.left(1), "%s records its batch family" % run_key)
		_check(int(manifest.get("instance", 0)) == int(run_key.right(1)), "%s records its instance" % run_key)
		for item_id: String in items:
			_check(not BLOCKED_IDS.has(StringName(item_id)), "%s excludes blocked %s" % [run_key, item_id])
			var definition := catalog.get_definition_by_id(StringName(item_id))
			_check(definition != null, "%s resolves %s" % [run_key, item_id])
			if definition != null:
				_check(definition.visual_scene != null, "%s has an authoritative visual scene" % item_id)
				var visual := definition.visual_scene.instantiate()
				_check(visual != null, "%s visual scene instantiates" % item_id)
				if visual != null:
					visual.free()


func _assert_containment(proof: Node3D) -> void:
	var dimensions := proof.call("get_proof_dimensions") as Vector3
	_check(dimensions.is_equal_approx(EXPECTED_CONTAINMENT), "proof exposes the Case-B 3.60 by 1.50 by 4.80 envelope")
	var floor_shape_node := proof.get_node_or_null("Containment/Floor/CollisionShape3D") as CollisionShape3D
	_check(floor_shape_node != null, "proof has a static containment floor")
	if floor_shape_node != null:
		var floor_shape := floor_shape_node.shape as BoxShape3D
		_check(floor_shape != null, "containment floor uses a plain box")
		if floor_shape != null:
			_check(is_equal_approx(floor_shape.size.x, 3.6), "containment floor depth matches Case B")
			_check(is_equal_approx(floor_shape.size.z, 4.8), "containment floor width matches Case B")
	for wall_name: String in ["FrontWall", "RearWall", "LeftWall", "RightWall"]:
		_check(proof.get_node_or_null("Containment/%s/CollisionShape3D" % wall_name) is CollisionShape3D, "%s provides plain static containment" % wall_name)


func _assert_real_visual_hulls(proof: Node) -> void:
	var catalog := load(CATALOG_PATH) as ItemCatalog
	var unique_ids: Dictionary = {}
	for run_key: String in EXPECTED_ITEMS:
		for item_id: String in EXPECTED_ITEMS[run_key]:
			unique_ids[item_id] = true
	_check(unique_ids.size() == 40, "locked manifests exercise all forty currently eligible definitions")

	for item_id: String in unique_ids:
		var definition := catalog.get_definition_by_id(StringName(item_id))
		var body := proof.call("create_temporary_body", definition, "HullTest_%s" % item_id) as RigidBody3D
		_check(body != null, "%s produces a temporary rigid body" % item_id)
		if body == null:
			continue
		proof.get_node("PileItems").add_child(body)
		var collision_shapes := body.find_children("*", "CollisionShape3D", true, false)
		_check(collision_shapes.size() == 1, "%s produces exactly one collision shape" % item_id)
		if collision_shapes.size() == 1:
			var hull := (collision_shapes[0] as CollisionShape3D).shape as ConvexPolygonShape3D
			_check(hull != null, "%s uses one ConvexPolygonShape3D" % item_id)
			if hull != null:
				_check(hull.points.size() > 8, "%s hull contains real mesh vertices rather than pickup-AABB corners" % item_id)
		_check(body.get_node_or_null("VisualRoot") is Node3D, "%s keeps its authoritative visual under the temporary body" % item_id)
		_check(body.find_children("*", "WorldItem", true, false).is_empty(), "%s has no pickup component during temporary settling" % item_id)
		body.free()
	await process_frame


func _assert_spawn_separation(proof: Node) -> void:
	if not _check(proof.has_method("place_body_above_current_pile"), "proof provides deterministic non-overlapping spawn placement"):
		return
	var catalog := load(CATALOG_PATH) as ItemCatalog
	var first := proof.call("create_temporary_body", catalog.get_definition_by_id(&"loot_000011"), "SpawnFirst") as RigidBody3D
	var second := proof.call("create_temporary_body", catalog.get_definition_by_id(&"loot_000038"), "SpawnSecond") as RigidBody3D
	if not _check(first != null and second != null, "spawn-separation fixtures build from real bulky visuals"):
		return
	proof.get_node("PileItems").add_child(first)
	proof.get_node("PileItems").add_child(second)
	proof.call("place_body_above_current_pile", first, [], Vector2.ZERO, Basis.IDENTITY)
	proof.call("place_body_above_current_pile", second, [first], Vector2.ZERO, Basis.from_euler(Vector3(0.4, -0.8, 0.25)))
	var first_bounds := _body_hull_aabb(first)
	var second_bounds := _body_hull_aabb(second)
	_check(not first_bounds.intersects(second_bounds), "successive initial spawn hulls do not overlap")
	_check(second_bounds.position.y > first_bounds.end.y, "successive spawn starts above the current pile with a gap")
	first.free()
	second.free()


func _assert_freeze_and_ordinary_take(proof: Node) -> void:
	var catalog := load(CATALOG_PATH) as ItemCatalog
	var definition := catalog.get_definition_by_id(&"loot_000015")
	var body := proof.call("create_temporary_body", definition, "FreezeTakeTest") as RigidBody3D
	if not _check(body != null, "freeze/TAKE fixture builds from a real Fuel Canister visual"):
		return
	proof.get_node("PileItems").add_child(body)
	body.collision_layer = 1
	body.collision_mask = 1
	body.linear_velocity = Vector3(1, 2, 3)
	body.angular_velocity = Vector3(0.5, 0.25, 0.75)
	proof.call("freeze_bodies_for_review", [body], "TEST1")

	_check(body.freeze, "freeze transition freezes the rigid body")
	_check(body.linear_velocity.is_zero_approx(), "freeze transition zeros linear velocity")
	_check(body.angular_velocity.is_zero_approx(), "freeze transition zeros angular velocity")
	_check(body.collision_layer == 0 and body.collision_mask == 0, "freeze transition disables temporary rigid-body collision")
	var world_item := body.get_node_or_null("WorldItem") as WorldItem
	_check(world_item != null, "frozen host receives the ordinary WorldItem component")
	if world_item != null:
		_check(world_item.get_definition() == definition, "WorldItem keeps the authoritative ItemDefinition")
		var player_carried := proof.get_node_or_null("Player/CarriedItems")
		_check(player_carried != null, "proof includes the normal player carried-items container")
		var hud := proof.get_node_or_null("HUD/CarriedItemsHUD")
		_check(hud != null, "proof includes the normal carried-items HUD")
		# Exercise the same production CarriedItems class without renderer-bound
		# HUD/held-view listeners; the scene assertions above separately prove that
		# the interactive proof includes the normal player and HUD.
		var carried := CarriedItems.new()
		proof.add_child(carried)
		_check(world_item.pickup_into(carried), "frozen proof item supports ordinary TAKE")
		_check(carried.get_item_count() == 1, "ordinary TAKE moves the proof item into carried state")
	await process_frame


func _body_hull_aabb(body: RigidBody3D) -> AABB:
	var hull := (body.get_node("PhysicsHull") as CollisionShape3D).shape as ConvexPolygonShape3D
	var first := body.transform * hull.points[0]
	var bounds := AABB(first, Vector3.ZERO)
	for index: int in range(1, hull.points.size()):
		bounds = bounds.expand(body.transform * hull.points[index])
	return bounds


func _assert_isolation_from_gameplay() -> void:
	var packed := load(GAMEPLAY_PATH) as PackedScene
	if not _check(packed != null, "normal wing gameplay still loads"):
		return
	var gameplay := packed.instantiate()
	_check(gameplay.find_children("*", "ReceivingPhysicsPileProof", true, false).is_empty(), "normal gameplay has no production pile proof node")
	_check(not _instances_scene(gameplay, PROOF_SCENE_PATH), "normal gameplay does not instance the isolated proof scene")
	gameplay.free()


func _instances_scene(root_node: Node, scene_path: String) -> bool:
	if root_node.scene_file_path == scene_path:
		return true
	for child: Node in root_node.find_children("*", "Node", true, false):
		if child.scene_file_path == scene_path:
			return true
	return false


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false


func _finish() -> void:
	if _failed:
		push_error("FAIL: receiving physics pile proof tests")
		quit(1)
		return
	print("PASS: receiving physics pile proof tests")
	quit(0)
