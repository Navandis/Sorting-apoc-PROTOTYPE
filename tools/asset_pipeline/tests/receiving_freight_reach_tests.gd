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
	_check(is_equal_approx(configured_reach, selected_reach), "saved wing Receiving reach matches the measured %.1f m requirement" % selected_reach)
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
	var delivery_ok := bool(runtime.call(
		"run_debug_delivery",
		int(case["content_seed"]),
		PRESENTATION_SEED,
		TARGET_BULK,
		int(case["fixture_mode"])
	))
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
	var fixture_visuals_clean := _fixture_visuals_expose_no_pickup_layer(presenter, String(case["label"]))

	player.set_physics_process(false)
	player.set_process_input(false)
	player.set("receiving_interaction_distance", DIAGNOSTIC_REACH_M)
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
		var world_item := candidate["world_item"] as WorldItem
		var item = world_item.get_item_instance()
		var surface = world_item.get_storage_surface()
		var entry = entries_by_item.get(item.instance_id)
		var footprint_3d: Vector3i = item.get_storage_footprint()
		var record := {
			"scenario": String(case["label"]),
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
			"ray_hit_position": candidate["ray_hit_position"],
			"hit_distance_m": float(candidate["hit_distance_m"]),
			"pickup_reach_kind": int(world_item.get_pickup_reach_kind()),
		}
		records.append(record)

		_place_player_at_stance(player, float(candidate["stance_z"]))
		camera.look_at(candidate["target_position"] as Vector3)
		_check(player.call("_get_looked_at_world_item") == world_item, "%s step %d production ray resolves measured target" % [String(case["label"]), records.size() - 1])
		player.call("_attempt_pickup_click")
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
	_check(bool(runtime.call("run_debug_delivery", int(limiting["content_seed"]), PRESENTATION_SEED, TARGET_BULK, int(limiting["fixture_mode"]))), "limiting replay delivery prepares")
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
