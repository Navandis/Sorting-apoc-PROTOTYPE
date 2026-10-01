extends SceneTree

const DeckPlannerScript = preload("res://receiving/receiving_deck_layout_planner.gd")
const WingScene = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
const WorldItemScript = preload("res://world_item.gd")

const PRESENTATION_SEED := 9001
const TARGET_BULK := 24
const DIAGNOSTIC_REACH_M := 4.0
const REQUIRED_HEADROOM_M := 0.10
const STANCE_Z_VALUES: Array[float] = [-1.2, 0.0, 1.2]
const CASES: Array[Dictionary] = [
	{"label": "bare", "content_seed": 1842, "fixture_mode": DeckPlannerScript.FixtureMode.BARE},
	{"label": "legal_extents", "content_seed": 0, "fixture_mode": DeckPlannerScript.FixtureMode.BARE, "legal_extents": true},
	{"label": "mixed", "content_seed": 1842, "fixture_mode": DeckPlannerScript.FixtureMode.MIXED},
	{"label": "crates", "content_seed": 249, "fixture_mode": DeckPlannerScript.FixtureMode.CRATES_ALLOWED},
	{"label": "pallets", "content_seed": 142, "fixture_mode": DeckPlannerScript.FixtureMode.PALLETS_ALLOWED},
]

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var all_records: Array[Dictionary] = []
	var configured_reach := -1.0
	for case: Dictionary in CASES:
		var result := await _measure_case(case)
		all_records.append_array(result.get("records", []) as Array)
		if configured_reach < 0.0:
			configured_reach = float(result.get("configured_reach", -1.0))
		_check(bool(result.get("drained", false)), "%s delivery drains through exposed production rays" % String(case["label"]))
		_check(bool(result.get("fixture_visuals_clean", false)), "%s fixture visuals never own pickup-layer interaction" % String(case["label"]))

	_check(not all_records.is_empty(), "required reach scenarios produce measured TAKE records")
	if all_records.is_empty():
		_finish()
		return
	var limiting := all_records[0]
	for record: Dictionary in all_records:
		_check(int(record["pickup_reach_kind"]) == WorldItemScript.PickupReachKind.RECEIVING, "%s remains classified as RECEIVING" % String(record["instance_id"]))
		if float(record["hit_distance_m"]) > float(limiting["hit_distance_m"]):
			limiting = record

	_assert_required_coverage(all_records)
	_print_measurement_summary(all_records)
	var dmax := float(limiting["hit_distance_m"])
	var selected_reach := ceilf((dmax + REQUIRED_HEADROOM_M) * 10.0) / 10.0
	_check(selected_reach <= DIAGNOSTIC_REACH_M, "derived Receiving reach stays within the 4.0 m controller bound")
	_check(is_equal_approx(configured_reach, 3.4) and configured_reach >= selected_reach, "saved 3.4 m Receiving reach covers the authored installation with headroom")
	await _replay_limiting_boundary(limiting, selected_reach)
	_finish()


func _measure_case(case: Dictionary) -> Dictionary:
	var scene := WingScene.instantiate()
	var player := scene.get_node("Player") as CharacterBody3D
	player.set("enable_held_item_view", false)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	await physics_frame
	var configured_reach := float(player.get("receiving_interaction_distance"))
	_check(is_equal_approx(float(player.get("interaction_distance")), 1.4), "%s keeps loose reach at 1.4 m" % String(case["label"]))
	_check(is_equal_approx(float(player.get("storage_interaction_distance")), 2.3), "%s keeps storage reach at 2.3 m" % String(case["label"]))

	var runtime := scene.get_node("ReceivingRuntime")
	var delivery_ok := _prepare_case(runtime, case)
	_check(delivery_ok, "%s debug delivery prepares" % String(case["label"]))
	if not delivery_ok:
		scene.free()
		current_scene = null
		return {"records": [], "configured_reach": configured_reach, "drained": false, "fixture_visuals_clean": false}
	await physics_frame
	await physics_frame

	var presenter := runtime.get_node("ReceivingDeckPresenter")
	var manager := runtime.get_node("ReceivingManager")
	var batch = manager.call("get_active_batch")
	var entries_by_item: Dictionary = {}
	for entry in batch.entries:
		entries_by_item[entry.item_instance_id] = entry
	var initial_count := (presenter.call("get_materialized_world_items") as Array).size()
	_check(initial_count == batch.entries.size(), "every legal prepared entry materializes before drain")
	var metric_frame := Transform3D((presenter as Node3D).global_basis.orthonormalized(), (presenter as Node3D).global_position)
	_assert_production_seating(presenter)
	var fixture_visuals_clean := _fixture_visuals_expose_no_pickup_layer(presenter, String(case["label"]))

	player.set_physics_process(false)
	player.set_process_input(false)
	player.set("receiving_interaction_distance", configured_reach)
	var camera := player.get_node("Camera3D") as Camera3D
	var carried = player.get_node("CarriedItems")
	carried.set("max_bulk", 99999)
	var records: Array[Dictionary] = []
	while not (presenter.call("get_materialized_world_items") as Array).is_empty():
		var candidate := _nearest_exposed_candidate(
			player,
			camera,
			presenter.call("get_materialized_world_items") as Array
		)
		if candidate.is_empty():
			var blocked_ids: PackedStringArray = []
			for blocked_world: WorldItem in presenter.call("get_materialized_world_items") as Array[WorldItem]:
				blocked_ids.append(blocked_world.get_item_instance().instance_id)
			_check(false, "%s has no exposed target from normal lateral stances: %s" % [String(case["label"]), ", ".join(blocked_ids)])
			break
		if float(candidate["hit_distance_m"]) > configured_reach:
			var unreachable := candidate["world_item"] as WorldItem
			print("UNREACHABLE ", JSON.stringify({"scenario": case["label"], "item": unreachable.get_item_instance().instance_id, "surface": unreachable.get_storage_surface().surface_id, "required_hit_m": candidate["hit_distance_m"], "stance_z": candidate["stance_z"], "player_position": candidate["player_position"], "camera_position": candidate["camera_position"], "target_position": candidate["target_position"]}))
			_check(false, "legal cargo requires more than saved 3.4 m Receiving reach")
			break
		var world_item := candidate["world_item"] as WorldItem
		var item = world_item.get_item_instance()
		var surface = world_item.get_storage_surface()
		var entry = entries_by_item.get(item.instance_id)
		var footprint_3d: Vector3i = item.get_storage_footprint()
		var record := {
			"scenario": String(case["label"]),
			"legal_extents": bool(case.get("legal_extents", false)),
			"content_seed": int(case["content_seed"]),
			"fixture_mode": int(case["fixture_mode"]),
			"take_index": records.size(),
			"entry_id": entry.entry_id,
			"instance_id": item.instance_id,
			"item_id": String(item.definition.item_id),
			"item_name": item.get_display_name(),
			"surface_id": String(surface.surface_id),
			"cell_origin": entry.presentation_cell_origin,
			"item_footprint": Vector2i(footprint_3d.x, footprint_3d.y),
			"stance_z": float(candidate["stance_z"]),
			"player_position": candidate["player_position"],
			"camera_position": candidate["camera_position"],
			"target_position": candidate["target_position"],
			"metric_host_position": metric_frame.affine_inverse() * (world_item.get_parent() as Node3D).global_position,
			"ray_hit_position": candidate["ray_hit_position"],
			"hit_distance_m": float(candidate["hit_distance_m"]),
			"pickup_reach_kind": int(world_item.get_pickup_reach_kind()),
		}
		records.append(record)

		_place_player_at_stance(player, float(candidate["stance_z"]))
		camera.look_at(candidate["target_position"] as Vector3)
		# Visual lining must also stay clear of every successful legal TAKE ray.
		for wall: Node3D in scene.get_node("ReceivingLiftInstallation/ShaftWalls").get_children():
			var mesh := wall.get_node("GeneratedMesh") as MeshInstance3D
			var bounds := mesh.global_transform * mesh.get_aabb()
			_check(not bounds.intersects_segment(camera.global_position, candidate["ray_hit_position"] as Vector3), "%s cargo ray clears %s visual lining" % [String(case["label"]), wall.name])
		# Validate geometric clearance as well as the production pickup-area ray.
		# The movement proxy must not form an invisible obstruction above the visual.
		var clearance := PhysicsRayQueryParameters3D.create(camera.global_position, candidate["ray_hit_position"] as Vector3, 1)
		_check(camera.get_world_3d().direct_space_state.intersect_ray(clearance).is_empty(), "%s cargo ray clears final production barrier" % String(case["label"]))
		_check(player.call("_get_looked_at_world_item") == world_item, "%s step %d production ray resolves measured target" % [String(case["label"]), records.size() - 1])
		player.call("_attempt_pickup_click")
		if carried.get_selected_item() != item:
			_check(false, "production TAKE failed; stop rather than repeat the same blocked target")
			break
		_check(carried.get_selected_item() == item, "%s step %d TAKE transfers the measured item" % [String(case["label"]), records.size() - 1])
		carried.call("remove_item", item)
		await physics_frame

	var drained: bool = records.size() == initial_count and bool(batch.is_drained())
	_check(records.size() == initial_count, "%s exposes all %d persisted entries through progressive TAKE" % [String(case["label"]), initial_count])
	scene.free()
	current_scene = null
	await process_frame
	return {
		"records": records,
		"configured_reach": configured_reach,
		"drained": drained,
		"fixture_visuals_clean": fixture_visuals_clean,
	}


func _assert_production_seating(presenter: Node) -> void:
	for world_item: WorldItem in presenter.call("get_materialized_world_items") as Array[WorldItem]:
		var host := world_item.get_parent() as Node3D
		var surface := world_item.get_storage_surface()
		var bottom := INF
		for mesh: MeshInstance3D in host.find_children("*", "MeshInstance3D", true, false):
			for index: int in range(mesh.mesh.get_surface_count()):
				for vertex: Vector3 in mesh.mesh.surface_get_arrays(index)[Mesh.ARRAY_VERTEX]:
					bottom = minf(bottom, (mesh.global_transform * vertex).y)
		_check(absf(bottom - host.global_position.y - 0.006) < 0.0001, "production cargo retains 6 mm visual seating offset without inherited vertical stretch")
		_check(bottom >= surface.global_position.y, "production cargo does not penetrate its support surface")
		_check(surface.global_basis.get_scale().is_equal_approx(Vector3.ONE), "private metric cargo surfaces remain scale-isolated")
		if surface.surface_id == &"MainDeck":
			_check(is_equal_approx(surface.global_position.y, 0.82), "MainDeck cargo shares the physical platform top datum at Y 0.82")

func _nearest_exposed_candidate(
	player: CharacterBody3D,
	camera: Camera3D,
	world_items: Array
) -> Dictionary:
	var best: Dictionary = {}
	for world_value: Variant in world_items:
		var world_item := world_value as WorldItem
		if world_item == null:
			continue
		var shape := world_item.get_node_or_null("PickupArea/PickupShape") as CollisionShape3D
		if shape == null:
			continue
		var target_position := shape.global_position
		for stance_z: float in STANCE_Z_VALUES:
			_place_player_at_stance(player, stance_z)
			camera.look_at(target_position)
			var hit := _pickup_ray(camera, DIAGNOSTIC_REACH_M)
			if _world_item_for_collider(hit.get("collider") as Node) != world_item:
				continue
			var hit_position := hit.get("position", camera.global_position) as Vector3
			var distance := camera.global_position.distance_to(hit_position)
			if best.is_empty() or distance < float(best["hit_distance_m"]):
				best = {
					"world_item": world_item,
					"stance_z": stance_z,
					"player_position": player.global_position,
					"camera_position": camera.global_position,
					"target_position": target_position,
					"ray_hit_position": hit_position,
					"hit_distance_m": distance,
				}
	return best


func _place_player_at_stance(player: CharacterBody3D, stance_z: float) -> void:
	player.rotation = Vector3.ZERO
	player.velocity = Vector3.ZERO
	player.global_position = Vector3(-37.8, 0.05, stance_z)
	player.move_and_collide(Vector3(-3.0, 0.0, 0.0))
	player.move_and_collide(Vector3(0.0, -1.0, 0.0))


func _pickup_ray(camera: Camera3D, reach: float) -> Dictionary:
	var ray_from := camera.global_position
	var query := PhysicsRayQueryParameters3D.new()
	query.from = ray_from
	query.to = ray_from - camera.global_transform.basis.z.normalized() * reach
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = WorldItemScript.PICKUP_COLLISION_LAYER
	return camera.get_world_3d().direct_space_state.intersect_ray(query)


func _world_item_for_collider(collider: Node) -> WorldItem:
	var current := collider
	while current != null:
		if current is WorldItem:
			return current as WorldItem
		current = current.get_parent()
	return null


func _fixture_visuals_expose_no_pickup_layer(presenter: Node, scenario: String) -> bool:
	var clean := true
	for fixture_root: Node3D in presenter.call("get_materialized_fixture_nodes") as Array[Node3D]:
		for node: Node in fixture_root.find_children("*", "", true, false):
			if node is WorldItem:
				clean = false
				_check(false, "%s fixture visual owns no WorldItem" % scenario)
			if node is Area3D and node.name == "PickupArea":
				clean = false
				_check(false, "%s fixture visual owns no loot PickupArea" % scenario)
			if node is CollisionObject3D:
				var collision_object := node as CollisionObject3D
				if collision_object.collision_layer & WorldItemScript.PICKUP_COLLISION_LAYER != 0:
					clean = false
					_check(false, "%s fixture visual collision never occupies the pickup layer" % scenario)
	return clean


func _assert_required_coverage(records: Array[Dictionary]) -> void:
	var coverage := {
		"bare_main": false,
		"left_edge": false, "right_edge": false, "rear_edge": false, "front_edge": false, "middle": false,
		"mixed_main": false,
		"mixed_crate": false,
		"mixed_pallet": false,
		"crates_small": false,
		"pallets_rear": false,
	}
	for record: Dictionary in records:
		var scenario := String(record["scenario"])
		var surface_id := String(record["surface_id"])
		var origin := record["cell_origin"] as Vector2i
		var footprint := record["item_footprint"] as Vector2i
		if scenario == "bare" and surface_id == "MainDeck":
			coverage["bare_main"] = true
		if scenario == "legal_extents":
			var pos: Vector3 = record["metric_host_position"]
			coverage["left_edge"] = bool(coverage["left_edge"]) or pos.x < -1.5
			coverage["right_edge"] = bool(coverage["right_edge"]) or pos.x > 1.5
			coverage["rear_edge"] = bool(coverage["rear_edge"]) or pos.z < -0.85
			coverage["front_edge"] = bool(coverage["front_edge"]) or pos.z > 0.85
			coverage["middle"] = bool(coverage["middle"]) or (absf(pos.x) < 0.15 and absf(pos.z) < 0.15)
		if scenario == "mixed" and surface_id == "MainDeck":
			coverage["mixed_main"] = true
		elif scenario == "mixed" and surface_id.begins_with("Crate_"):
			coverage["mixed_crate"] = true
		elif scenario == "mixed" and surface_id.begins_with("Pallet_"):
			coverage["mixed_pallet"] = true
		if scenario == "crates" and surface_id.begins_with("Crate_") and maxi(footprint.x, footprint.y) <= 2:
			coverage["crates_small"] = true
		if scenario == "pallets" and surface_id.begins_with("Pallet_") and origin.y <= 1:
			coverage["pallets_rear"] = true
	for key: String in ["bare_main", "left_edge", "right_edge", "rear_edge", "front_edge", "middle"]:
		_check(bool(coverage[key]), "successful production TAKE covers " + key)
	_check(bool(coverage["mixed_main"]), "mixed case exercises loose MainDeck cargo")
	_check(bool(coverage["mixed_crate"]), "mixed case exercises crate cargo")
	_check(bool(coverage["mixed_pallet"]), "mixed case exercises pallet cargo")
	_check(bool(coverage["crates_small"]), "crate case TAKES a small bottle/can-scale item")
	_check(bool(coverage["pallets_rear"]), "pallet case exercises rear-interior pallet cargo")


func _print_measurement_summary(records: Array[Dictionary]) -> void:
	var summaries: Dictionary = {}
	for record: Dictionary in records:
		var surface_id := String(record["surface_id"])
		var category := "main" if surface_id == "MainDeck" else "crate" if surface_id.begins_with("Crate_") else "pallet"
		var key := "%s/%s" % [String(record["scenario"]), category]
		if not summaries.has(key) or float(record["hit_distance_m"]) > float((summaries[key] as Dictionary)["hit_distance_m"]):
			summaries[key] = record
	var keys := summaries.keys()
	keys.sort()
	for key: String in keys:
		print("REACH_MEASUREMENT %s" % JSON.stringify(summaries[key]))


func _replay_limiting_boundary(limiting: Dictionary, selected_reach: float) -> void:
	var scene := WingScene.instantiate()
	var player := scene.get_node("Player") as CharacterBody3D
	player.set("enable_held_item_view", false)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	await physics_frame
	var runtime := scene.get_node("ReceivingRuntime")
	_check(_prepare_case(runtime, limiting), "limiting replay delivery prepares")
	await physics_frame
	await physics_frame
	player.set_physics_process(false)
	player.set_process_input(false)
	var presenter := runtime.get_node("ReceivingDeckPresenter")
	var camera := player.get_node("Camera3D") as Camera3D
	var carried = player.get_node("CarriedItems")
	carried.set("max_bulk", 99999)
	player.set("receiving_interaction_distance", DIAGNOSTIC_REACH_M)
	for take_index: int in range(int(limiting["take_index"])):
		var candidate := _nearest_exposed_candidate(player, camera, presenter.call("get_materialized_world_items") as Array)
		_check(not candidate.is_empty(), "limiting replay preserves progressive exposure before step %d" % take_index)
		if candidate.is_empty():
			break
		var world_item := candidate["world_item"] as WorldItem
		var item = world_item.get_item_instance()
		_place_player_at_stance(player, float(candidate["stance_z"]))
		camera.look_at(candidate["target_position"] as Vector3)
		player.call("_attempt_pickup_click")
		carried.call("remove_item", item)
		await physics_frame
	var limiting_world: WorldItem = null
	for world_item: WorldItem in presenter.call("get_materialized_world_items") as Array[WorldItem]:
		if world_item.get_item_instance().instance_id == String(limiting["instance_id"]):
			limiting_world = world_item
			break
	_check(limiting_world != null, "limiting replay resolves the same durable item")
	if limiting_world != null:
		var shape := limiting_world.get_node("PickupArea/PickupShape") as CollisionShape3D
		_place_player_at_stance(player, float(limiting["stance_z"]))
		camera.look_at(shape.global_position)
		var replay_hit := _pickup_ray(camera, DIAGNOSTIC_REACH_M)
		var replay_distance := camera.global_position.distance_to(replay_hit.get("position", camera.global_position) as Vector3)
		_check(is_equal_approx(replay_distance, float(limiting["hit_distance_m"])), "limiting hit distance replays deterministically")
		var lower_reach := selected_reach - 0.1
		player.set("receiving_interaction_distance", lower_reach)
		var lower_target = player.call("_get_looked_at_world_item")
		var lower_headroom := lower_reach - replay_distance
		_check(lower_target == null or lower_headroom < REQUIRED_HEADROOM_M, "immediately lower reach fails or lacks the agreed 0.10 m headroom")
		player.set("receiving_interaction_distance", selected_reach)
		_check(player.call("_get_looked_at_world_item") == limiting_world, "selected Receiving reach resolves the limiting pickup Area")
		print("REACH_LIMIT %s" % JSON.stringify({
			"dmax_m": replay_distance,
			"selected_reach_m": selected_reach,
			"lower_reach_m": lower_reach,
			"lower_succeeds": lower_target == limiting_world,
			"lower_headroom_m": lower_headroom,
			"limiting": limiting,
		}))
	scene.free()
	current_scene = null
	await process_frame


func _finish() -> void:
	if _failed:
		push_error("FAIL: Receiving freight reach tests")
		quit(1)
		return
	print("PASS: Receiving freight reach tests")
	quit(0)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false

# Bounded legal corner/middle controls use planner-authored singleton poses,
# normal batch commit, production materialization and the same real TAKE rays.
func _prepare_case(runtime: Node, case: Dictionary) -> bool:
	if not bool(case.get("legal_extents", false)):
		return bool(runtime.call("run_debug_delivery", int(case["content_seed"]), PRESENTATION_SEED, TARGET_BULK, int(case["fixture_mode"])))
	var catalog: ItemCatalog = runtime.get("item_catalog")
	var profile: Resource = runtime.get("deck_profile")
	var entries: Array[LootBatchEntry] = []
	var placements := {}
	var origins := [Vector2i(0, 0), Vector2i(32, 0), Vector2i(0, 18), Vector2i(32, 18), Vector2i(16, 9)]
	for index in origins.size():
		var entry := LootBatchEntry.new("edge_%d" % index, "legal_extents:item_%d" % index, &"loot_000001")
		entries.append(entry)
		var single := LootBatch.create_committed("single_%d" % index, &"test", "legal extent", 1, 1, 0, PRESENTATION_SEED, [entry])
		var result = DeckPlannerScript.new().prepare(single, catalog, profile)
		if not result.succeeded:
			return false
		var placement: Dictionary = result.placements_by_entry_id[entry.entry_id].duplicate(true)
		var old_origin: Vector2i = placement["cell_origin"]
		var measured: Dictionary = ReceivingDeckItemPose.measure_item(single.create_item_instance(entry.entry_id, catalog), int(placement["quarter_turns"]))
		var footprint: Vector2i = measured["footprint"]
		if origins[index].x == 32:
			origins[index].x = 33 - footprint.x
		if origins[index].y == 18:
			origins[index].y = 20 - footprint.y
		var pose: Transform3D = placement["frozen_transform"]
		pose.origin += Vector3(float(origins[index].x - old_origin.x) * 0.10, 0, float(origins[index].y - old_origin.y) * 0.10)
		placement["cell_origin"] = origins[index]
		placement["stack_group_id"] = "MainDeck:extent_%d" % index
		placement["frozen_transform"] = pose
		placements[entry.entry_id] = placement
	var batch := LootBatch.create_committed("legal_extents", &"test", "widened corners/middle", 5, 5, 0, PRESENTATION_SEED, entries)
	if not batch.commit_deck_layout(placements, profile.profile_id, profile.revision, [], profile):
		return false
	if not runtime.get_node("ReceivingManager").deposit_batch(batch):
		return false
	var presenter = runtime.get_node("ReceivingDeckPresenter")
	if not presenter.present_active_batch():
		return false
	return bool(presenter.reveal_active_batch())
