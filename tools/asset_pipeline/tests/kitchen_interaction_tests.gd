extends "res://tools/asset_pipeline/tests/expedition_physical_tests.gd"

var kitchen: RefCounted
var panel: CanvasLayer
var timeline: RefCounted
var checks := 0

func _run() -> void:
	create_timer(180).timeout.connect(func(): quit(3))
	shell = Shell.instantiate()
	shell.save_service = SaveService.new("user://kitchen-interaction")
	root.add_child(shell)
	current_scene = shell
	shell.set_process(false)
	if not new_run():
		finish()
		return
	if not check(kitchen != null and panel != null and player.get("kitchen_station") != null,
			"New Run binds a live service at the authored Kitchen frontage"):
		finish()
		return
	await test_live_panel()
	test_over_capacity_rollback()
	if DisplayServer.get_name() != "headless" and failures == 0 and new_run():
		await recover_from_generated_cargo()
	finish()

func new_run() -> bool:
	if not check(shell.start_new_run(), "ordinary New Run succeeds: " + shell.status_label.text):
		return false
	wing = shell.wing
	wing.set_process(false)
	player = wing.get_node("Player")
	player.set_process(false)
	player.set_physics_process(false)
	carry = player.carried_items
	placement = player._storage_placement
	timeline = wing.run_timeline
	kitchen = wing.get("kitchen")
	panel = wing.get("kitchen_panel")
	return true

func test_live_panel() -> void:
	var native := DisplayServer.get_name() != "headless"
	var station: StaticBody3D = player.kitchen_station
	check((station.collision_layer & player.collision_mask) == 0, "Kitchen ray target adds no movement obstruction")
	var wall: Node3D = wing.get_node("Environment/Greybox/Boundaries/KitchenInnerBoundary")
	player.global_position = Vector3(wall.global_position.x, 0.05, wall.global_position.z - 0.8)
	player.camera.look_at(station.global_position)
	await physics_frame
	check(not player.can_reach_kitchen(), "the authored inner wall occludes an otherwise in-range Kitchen ray")
	var start: Marker3D = wing.get_node("Environment/Greybox/Anchors/KitchenService")
	player.global_position = start.global_position
	player.rotation.y = 0.0
	player.camera.look_at(station.global_position)
	await physics_frame
	await open_kitchen()
	check(not panel.is_open(), "out-of-range Kitchen F does not open the panel")
	if native:
		var approach := player.global_position
		player.set_physics_process(true)
		await key_event(KEY_W, true)
		var timeout := Time.get_ticks_msec() + 2500
		while approach.z - player.global_position.z < 1.5 and Time.get_ticks_msec() < timeout:
			await physics_frame
		await key_event(KEY_W, false)
		player.set_physics_process(false)
		player._update_interaction_target()
		check(player._interaction_prompt.text == "[F] OPEN KITCHEN", "native walking reaches the existing frontage and shows the F cue")
		print("KITCHEN_APPROACH metres=", approach.distance_to(player.global_position), " viewport=", root.size)
	else:
		await aim_at_kitchen()
	await open_kitchen()
	if not check(panel.is_open() and player.world_input_blocked and not paused, "F opens Kitchen and blocks world input while the clock stays live"):
		return
	await key_tap(KEY_E)
	check(kitchen.outstanding == Vector2i.ZERO and kitchen.capture_state().receipts.is_empty(), "E with no demand is inert")
	player.incinerator_requested.emit()
	player.dispatch_requested.emit()
	check(not wing.incinerator_panel.is_open() and not wing.dispatch_panel.is_open(), "other service panels cannot share input")
	var first_at: int = kitchen.capture_state().first_at
	timeline.advance(first_at - timeline.clock.elapsed)
	check(kitchen.outstanding.x + kitchen.outstanding.y in range(60, 81) and kitchen.sprint_allowed()
		and timeline.error.is_empty(), "live Kitchen issues demand at a timeline-only boundary and grants grace")
	var elapsed: float = timeline.clock.elapsed
	wing.set_process(true)
	await create_timer(0.7).timeout
	wing.set_process(false)
	check(timeline.clock.elapsed > elapsed + 0.15, "regular frames advance active time with Kitchen open")
	check(panel._phase.text.contains("Grace") and panel._phase.text.contains("0%") and panel._phase.text.contains("pending"),
		"grace feedback distinguishes pending and active penalty")
	await key_tap(KEY_ESCAPE)
	check(not panel.is_open() and not paused, "first Escape closes Kitchen before pause")
	await key_tap(KEY_ESCAPE)
	var paused_at: float = timeline.clock.elapsed
	timeline.advance(100.0)
	check(paused and shell.menu_open and timeline.clock.elapsed == paused_at and kitchen.sprint_allowed(), "second Escape pauses active chronology")
	await key_tap(KEY_ESCAPE)
	check(not paused and not shell.menu_open, "Escape resumes normally")

func test_over_capacity_rollback() -> void:
	var real := PrototypeItemCatalog.get_definition_by_id(&"loot_000007")
	var items: Array[ItemInstance] = []
	for bulk in [9, 1, 10]:
		var definition := real.duplicate() as ItemDefinition
		definition.bulk = bulk
		var item := ItemInstance.new(definition, "rollback-%d" % bulk)
		check(carry.add_item(item), "controlled pre-penalty bundle fits")
		items.append(item)
	var full := carry.capture_state()
	advance_to_cap()
	check(carry.capture_state() == full and carry.get_current_bulk() == 20 and carry.get_effective_bulk_limit() == 10,
		"20/10 is legal and grace/additions preserve all slots")
	check(wing.get_node("HUD/CarriedItemsHUD")._bulk_label.text.contains("20 / 10"), "HUD reflects capacity without a contents mutation")
	check(not carry.can_add(ItemInstance.new(real, "new")) and not carry.add_item(ItemInstance.new(real, "new")),
		"new ownership still enforces effective capacity")
	carry.remove_item(items[1]) # Leave a gap immediately before the selected tail slot.
	carry.select_index(2)
	var before := carry.capture_state()
	var surface: StorageSurface = wing.get_functional_surfaces()[1]
	surface.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
	var contents := surface.get_stored_items()
	# Invalidate a valid addressed fit at the existing removal notification boundary.
	var removed := []
	carry.item_removed.connect(func(item: ItemInstance):
		removed.append(item)
		surface.clear_all_zones(), CONNECT_ONE_SHOT)
	placement.set_suppressed(false)
	check(not put(items[2], surface) and removed == [items[2]] and carry.capture_state() == before
		and carry.get_slots() == [items[0], null, items[2]],
		"failed placement restores the exact over-limit tail slot, gap, and selection")
	check(surface.get_stored_items() == contents, "rejected transfer has no destination owner")

func recover_from_generated_cargo() -> void:
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var ops: RefCounted = wing.expeditions
	var pool := Config.build_pool(runtime.item_catalog)
	var definitions := 0
	var largest := 0
	for lane: Array in pool.values():
		definitions += lane.size()
		for definition: ItemDefinition in lane:
			largest = maxi(largest, definition.bulk)
	check(definitions == 16 and largest <= 8, "unchanged generated pool contains sixteen items bounded by 8 Bulk")
	for affinities in [["Food", "Hydration"], ["Food", "Medical"]]:
		var seed := recovery_seed(affinities, pool)
		if not check(seed >= 0 and ops.set_members(4) and ops.toggle_affinity(affinities[0]) and ops.toggle_affinity(affinities[1]),
				"controlled recovery seed and ordinary four-member draft"):
			return
		ops.rng.seed = seed
		var result: Dictionary = ops.dispatch(ops.revision)
		if not check(result.ok, "controlled seed dispatches an unmodified generated haul"):
			return
		print("KITCHEN_RECOVERY dispatch_seed=", seed, " affinities=", affinities)
	advance_to_cap()
	if not check(runtime.lift_cycle.can_take_receiving() and carry.get_effective_bulk_limit() == 10 and not kitchen.sprint_allowed(),
			"actual Kitchen schedule reaches maximum loss with genuine OPEN cargo"):
		return
	var walk := await walk_at_kitchen(false)
	var blocked_sprint := await walk_at_kitchen(true)
	check(walk > 0.4 and absf(walk - blocked_sprint) < 0.18, "Shift moves at ordinary walking speed under maximum penalty")
	print("KITCHEN_RECOVERY overdue_walk_m=", walk, " overdue_shift_m=", blocked_sprint, " balances=", kitchen.outstanding)

	var stock: Array[StorageSurface] = []
	for index in [1, 2, 3, 5, 6]:
		var surface: StorageSurface = wing.get_functional_surfaces()[index]
		surface.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
		stock.append(surface)
	var cargo_taken := 0
	var credited := Vector2i.ZERO
	var starting_supply: Dictionary = {}
	while starting_supply.size() < 2:
		var item := await native_take(runtime)
		if item == null:
			return
		cargo_taken += 1
		var lane := item.get_storage_category()
		if lane in ["Food", "Hydration"] and not starting_supply.has(lane):
			starting_supply[lane] = item
		elif not store_recovery_surplus(item, stock):
			return
	check(carry.get_effective_bulk_limit() == 10 and carry.get_items().size() == 2,
		"real Food and Hydration both enter carrying under the 10-Bulk limit")
	await aim_at_kitchen()
	await key_event(KEY_E, true)
	await open_kitchen()
	if not check(panel.is_open() and carry.get_item_count() == 2, "F opens the real service without spending either item while E is held"):
		return
	await key_event(KEY_E, false)
	await key_tap(KEY_2)
	var selected := carry.get_selected_item() as ItemInstance
	var other := carry.get_slots()[0] as ItemInstance
	check(selected == carry.get_slots()[1] and panel._item.text.contains(selected.get_display_name()),
		"native number selection updates the exact item and credit preview")
	await capture_kitchen("kitchen-overdue")
	var opening_total: int = kitchen.total_outstanding()
	await key_event(KEY_E, true)
	var after: int = kitchen.total_outstanding()
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, true)
	check(after < opening_total and after == kitchen.total_outstanding() and carry.get_items() == [other],
		"held E and key echo cannot spend the next eligible selection")
	check(carry.get_effective_bulk_limit() == floori(20.0 * (300 - after) / 300.0) and not kitchen.sprint_allowed(),
		"real credit changes loss proportionally even if the whole-Bulk limit is unchanged")
	credited[0 if selected.get_storage_category() == "Food" else 1] += opening_total - after
	await key_tap(KEY_ESCAPE)
	await prove_held_e_release(other, stock[0])
	await aim_at_kitchen()
	await open_kitchen()
	var other_quote: Dictionary = kitchen.preview(other)
	await key_tap(KEY_E)
	check(not carry.get_items().has(other) and kitchen.has_spent_item(other.instance_id)
		and carry.get_effective_bulk_limit() > 10 and not kitchen.sprint_allowed(), "fresh native E credits the other lane and frees whole-Bulk capacity")
	credited[0 if other.get_storage_category() == "Food" else 1] += other_quote.applied
	await key_tap(KEY_ESCAPE)
	for haul in 2:
		while runtime.lift_cycle.can_take_receiving() and kitchen.total_outstanding() > 0:
			if runtime.deck_presenter.get_materialized_world_items().is_empty():
				break
			var item := await native_take(runtime)
			if item == null:
				return
			cargo_taken += 1
			var category := item.get_storage_category()
			var preview: Dictionary = kitchen.preview(item)
			if preview.ok:
				var before: int = kitchen.total_outstanding()
				await aim_at_kitchen()
				await open_kitchen()
				if not check(panel.is_open(), "native F opens actual Kitchen from the front"):
					return
				await key_tap(KEY_E)
				check(kitchen.total_outstanding() == before - preview.applied and not carry.get_items().has(item)
					and kitchen.has_spent_item(item.instance_id), "native E spends precisely the taken cargo once")
				credited[0 if category == "Food" else 1] += preview.applied
				if kitchen.total_outstanding() == 0:
					check(panel.is_open() and panel._phase.text.contains("No outstanding"), "clearance leaves panel open with no outstanding demand")
					await key_tap(KEY_E)
					await capture_kitchen("kitchen-cleared")
				await key_tap(KEY_ESCAPE)
			elif not store_recovery_surplus(item, stock):
				return
		if kitchen.total_outstanding() > 0:
			timeline.advance(60.0)
	var sprint := await walk_at_kitchen(true)
	check(credited.x > 0 and credited.y > 0 and kitchen.outstanding == Vector2i.ZERO and carry.get_effective_bulk_limit() == 20
		and kitchen.sprint_allowed() and sprint > walk * 1.5, "both real cargo lanes clear and actual Shift sprint returns")
	print("KITCHEN_RECOVERY taken=", cargo_taken, " credited=", credited, " final_shift_m=", sprint)

func store_recovery_surplus(item: ItemInstance, stock: Array[StorageSurface]) -> bool:
	placement.set_suppressed(false)
	for surface in stock:
		if put(item, surface):
			return true
	return check(false, "ordinary storage can clear unrelated or surplus cargo")

func prove_held_e_release(item: ItemInstance, shelf: StorageSurface) -> void:
	var at := shelf.global_position
	var reachable := false
	for outward: Vector3 in [Vector3.BACK, Vector3.FORWARD, Vector3.RIGHT, Vector3.LEFT]:
		player.global_position = Vector3(at.x, 0.04, at.z) + outward
		player.camera.look_at(at)
		if player._get_looked_at_storage_surface() == shelf:
			reachable = true
			break
	check(reachable and player._require_e_release, "closing Kitchen with E held re-arms ordinary storage input")
	player.set_process(true)
	await create_timer(0.65).timeout
	player.set_process(false)
	check(carry.get_items() == [item], "held E through panel close cannot enter the ordinary auto-store loop")
	await key_event(KEY_E, false)

func advance_to_cap() -> void:
	for boundary in 4: # First trigger, grace expiry, then two more scheduled additions.
		timeline.advance(kitchen.next_boundary_at() - timeline.clock.elapsed)

func recovery_seed(affinities: Array, pool: Dictionary) -> int:
	var rng := RandomNumberGenerator.new()
	for seed in range(20000):
		rng.seed = seed
		rng.randf_range(Config.MIN_DURATION, Config.MAX_DURATION) # The draw before the normal manifest.
		var totals := Vector2i.ZERO
		for id: String in Config.sample_manifest(32, affinities, rng, pool):
			var definition := PrototypeItemCatalog.get_definition_by_id(StringName(id))
			if definition.storage_category == "Food":
				totals.x += definition.utility_value
			elif definition.storage_category == "Hydration":
				totals.y += definition.utility_value
		if totals.x >= 45 and totals.y >= 44:
			return seed
	return -1

func native_take(runtime: ReceivingRuntime) -> ItemInstance:
	await physics_frame
	await physics_frame
	var candidate := _nearest_exposed_candidate(player, player.camera, runtime.deck_presenter.get_materialized_world_items())
	if not check(not candidate.is_empty(), "a genuine generated item is exposed within Receiving reach"):
		return null
	_place_player_at_stance(player, candidate.stance_z)
	player.camera.look_at(candidate.target_position)
	var world: WorldItem = candidate.world_item
	var item := world.get_item_instance()
	if not check(player._get_looked_at_world_item() == world, "the normal reticle addresses the exact cargo"):
		return null
	await mouse_take()
	return item if check(carry.get_items().has(item), "native click takes through ordinary capacity validation") else null

func walk_at_kitchen(shift: bool) -> float:
	await aim_at_kitchen()
	player.rotation.y = 0.0
	player.velocity = Vector3.ZERO
	var start := player.global_position.x
	if shift:
		await key_event(KEY_SHIFT, true)
	await key_event(KEY_D, true)
	# Count controller steps rather than render frames. Native input still
	# supplies the keys and the real collision/acceleration path moves the player.
	for frame in 42:
		await physics_frame
		player._physics_process(1.0 / Engine.physics_ticks_per_second)
	await key_event(KEY_D, false)
	if shift:
		await key_event(KEY_SHIFT, false)
	return absf(player.global_position.x - start)

func open_kitchen() -> void:
	if DisplayServer.get_name() == "headless":
		player.kitchen_requested.emit()
	else:
		await key_tap(KEY_F)

func aim_at_kitchen() -> void:
	var station: StaticBody3D = player.kitchen_station
	var front: Marker3D = wing.get_node("Environment/Greybox/Anchors/KitchenSafeSide")
	player.global_position = front.global_position + Vector3(0.0, 0.0, -0.5)
	player.camera.look_at(station.global_position + Vector3.UP * 0.4)
	await physics_frame
	await physics_frame

func capture_kitchen(label: String) -> void:
	var evidence := OS.get_environment("KITCHEN_TEST_EVIDENCE")
	if evidence.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var file := "%s-%dx%d.png" % [label, root.size.x, root.size.y]
	check(root.get_texture().get_image().save_png(evidence.path_join(file)) == OK, "native Kitchen capture " + file)

func check(ok: bool, message: String) -> bool:
	checks += 1
	return super.check(ok, message)

func finish() -> void:
	current_scene = null
	shell.free()
	print("kitchen_interaction_tests: %s (%d checks, %d failures)" % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)
