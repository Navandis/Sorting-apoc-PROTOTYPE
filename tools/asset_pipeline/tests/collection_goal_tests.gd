extends "res://tools/asset_pipeline/tests/receiving_freight_reach_tests.gd"
var failures := 0
var wing: Node3D
var carry: CarriedItems
var placement: StoragePlacementController
var player: CharacterBody3D
var max_take_reach := 0.0

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok

func _run() -> void:
	create_timer(120).timeout.connect(func(): quit(3))
	wing = WingScene.instantiate()
	wing.configure_new_run()
	wing.get_node("Player").enable_held_item_view = DisplayServer.get_name() != "headless"
	root.add_child(wing)
	current_scene = wing
	wing.set_process(false)
	player = wing.get_node("Player")
	player.set_process(false)
	player.set_physics_process(false)
	carry = player.carried_items
	placement = player._storage_placement
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var timeline: RefCounted = wing.run_timeline
	var shelves: Array[Node] = wing.get_functional_surfaces()
	var stock: StorageSurface = shelves[1]
	var second: StorageSurface = shelves[5]
	stock.initialize_zones_if_needed(StorageCategories.GENERAL)
	second.initialize_zones_if_needed(StorageCategories.FOOD)

	var goal: RefCounted = wing.collection_goal
	check(goal.totals.values().count(0) == 8, "authored loose seed stock starts at zero")
	timeline.advance(44.0)
	var first_items: Array = runtime.deck_presenter.get_materialized_world_items()
	if not check(runtime.lift_cycle.can_take_receiving() and first_items.size() == 6, "first controlled haul is fully OPEN"):
		finish()
		return
	var staging := StorageSurface.new()
	wing.get_node("Environment/Greybox/Proxies/SortingTable").add_child(staging)
	staging.configure(&"test_staging", 2.0, 1.0, 0.10, 0.9)
	staging.initialize_zones_if_needed(StorageCategories.GENERAL)

	for index in first_items.size():
		var item := await take_exposed(runtime)
		if item == null:
			finish()
			return
		if item.definition.item_id != &"loot_000116":
			check(put(item, stock), "controlled A TAKE and normal placement: " + item.get_display_name())
			continue

		check(put(item, staging) and goal.totals.Electronics == 0, "stored but unclassified staging does not count")
		check(stored_world(staging, item).pickup_into(carry) and goal.totals.Electronics == 0, "carrying remains excluded")

		placement._manual_mode = true
		placement._manual_target = {"surface": second, "kind": "point", "hit_local": Vector3.ZERO}
		check(put(item, second) and goal.totals.Electronics == 14, "manual zone mismatch counts the authored category")
		second.clear_all_zones()
		check(goal.totals.Electronics == 14, "erasing a zone preserves committed score")
		placement._manual_mode = false
		check(stored_world(second, item).pickup_into(carry) and goal.totals.Electronics == 0, "retrieval takes Electronics below target")
		check(put(item, stock) and goal.totals.Electronics == 14, "moving between shelves counts the item once")
	check(goal.totals.Food == 6 and goal.totals.Hydration == 6 and goal.totals.Medical == 8, "both cans per category and primary Antibiotics Utility count")
	var food: ItemInstance
	for stack: StorageStack in stock._stacks.values():
		if stack.entries.size() > 1:
			for entry: StorageStack.Entry in stack.entries:
				if entry.item.get_utility_id() == &"Food":
					food = entry.item
	if not check(food != null, "representative Food stock fits as a stack member"):
		for stack: StorageStack in stock._stacks.values():
			print("STORAGE_PROOF ", stock.surface_id, " clearance=", stock.stack_clearance_m,
				" entries=", stack.entries.map(func(entry): return entry.item.get_display_name()))
		finish()
		return
	check(stored_world(stock, food).pickup_into(carry) and goal.totals.Food == 3, "taking one member leaves the other counted")

	timeline.advance(100.25)
	for index in 3:
		var id := "goal_pressure_%d" % index
		var batch := runtime.prepare_manifest(["loot_000019"], id, 5200 + index)
		check(runtime.return_admission.submit_return(id, batch) != AwaitingLiftAdmission.ReturnResult.INVALID, "exact pressure delivery commits")
	var second_items: Array = runtime.deck_presenter.get_materialized_world_items()
	if not check(runtime.lift_cycle.can_take_receiving() and second_items.size() == 6, "second controlled haul survives turnaround"):
		finish()
		return
	for index in second_items.size():
		var item := await take_exposed(runtime)
		if item == null:
			finish()
			return
		if item.definition.item_id != &"loot_000001":
			check(put(item, stock), "physically fits " + item.get_display_name())
	check(goal.totals == {"Electronics":14, "Food":3, "Fuel":6, "Hydration":6, "Medical":8, "Morale":8, "Protection":7, "Weapons":6}, "exact eight primary totals on ordinary shelving")
	check(not goal.completed, "earlier Food peak and Electronics surplus do not win")
	# Invalidate a real fit between removal and commit. Rollback must not win.
	second.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, second.get_grid_size() - Vector2i.ONE)
	var invalidate := func():
		second.clear_all_zones()
	carry.contents_changed.connect(invalidate, CONNECT_ONE_SHOT)
	check(not put(food, second) and carry.get_items().has(food) and goal.totals.Food == 3 and not goal.completed, "stale fit rejected after removal, with exact carry rollback")
	var before: float = timeline.clock.elapsed
	check(put(food, stock) and goal.completed and goal.first_completion_at == before, "final commit wins at the current fractional active time")
	check(carry.get_item_count() == 1 and runtime.return_admission.get_awaiting_returns().size() == 1, "victory allows held surplus and upstream waiting cargo")
	timeline.advance(2.75)
	check(stored_world(stock, food).pickup_into(carry) and goal.totals.Food == 3, "live totals drop after victory")
	check(goal.completed and goal.first_completion_at == before and timeline.clock.elapsed == before + 2.75, "completion stays frozen while play advances")
	print("COLLECTION_WITNESS shelf=", stock.surface_id, " target=", goal.target, " completion=", before, " max_take_reach_m=", max_take_reach)
	finish()

func take_exposed(runtime: ReceivingRuntime) -> ItemInstance:
	await physics_frame
	await physics_frame
	var camera: Camera3D = player.camera
	var candidate := _nearest_exposed_candidate(player, camera, runtime.deck_presenter.get_materialized_world_items())
	if not check(not candidate.is_empty(), "an exposed item is available from the normal Receiving stances"):
		return null
	var reach: float = candidate.hit_distance_m
	if not check(reach <= player.receiving_interaction_distance, "exact cargo is within the ordinary 3.4 m TAKE reach"):
		return null
	_place_player_at_stance(player, candidate.stance_z)
	camera.look_at(candidate.target_position)
	var world: WorldItem = candidate.world_item
	if not check(player._get_looked_at_world_item() == world, "production reticle resolves the exact cargo item"):
		return null
	var item := world.get_item_instance()
	player._attempt_pickup_click()
	if not check(carry.get_items().has(item), "player TAKE transfers the exact cargo identity"):
		return null
	max_take_reach = maxf(max_take_reach, reach)
	return item

func stored_world(surface: StorageSurface, item: ItemInstance) -> WorldItem:
	var stack := surface.get_storage_stack(surface.get_stack_id_for_item(item.instance_id))
	for entry: StorageStack.Entry in stack.entries:
		if entry.item == item:
			return entry.world_item
	return null

func put(item: ItemInstance, surface: StorageSurface) -> bool:
	var index := carry.get_slots().find(item)
	if index < 0:
		return false
	carry.select_index(index)
	placement._current_surface = surface
	return placement.place_selected()

func finish() -> void:
	wing.free()
	current_scene = null
	print("collection_goal_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)
