extends "res://tools/asset_pipeline/tests/collection_goal_tests.gd"

const Shell = preload("res://gameplay/run/run_shell.tscn")
const SaveService = preload("res://gameplay/run/run_save_service.gd")
const Config = preload("res://gameplay/expeditions/expedition_test_config.gd")
const Ops = preload("res://gameplay/expeditions/expedition_operations.gd")
const Snapshot = preload("res://gameplay/run/run_snapshot.gd")

var shell: Node

func _run() -> void:
	create_timer(180).timeout.connect(func(): quit(3))
	var saves := OS.get_temp_dir().path_join("expedition-physical-" + Crypto.new().generate_random_bytes(8).hex_encode())
	shell = Shell.instantiate()
	shell.save_service = SaveService.new(saves)
	root.add_child(shell)
	shell.set_process(false)
	if not check(shell.start_new_run(), "normal New Run publishes the production wing and first save: " + shell.status_label.text):
		finish()
		return
	current_scene = shell
	bind_wing()
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var ops: RefCounted = wing.expeditions
	var timeline: RefCounted = wing.run_timeline
	var panel: CanvasLayer = wing.dispatch_panel
	var stock: StorageSurface = wing.get_functional_surfaces()[1]
	stock.initialize_zones_if_needed(StorageCategories.GENERAL)
	check(runtime.receiving_manager.get_active_batch_id().is_empty() and ops.journeys.is_empty(),
		"ordinary New Run starts without foundation cargo")

	# Exercise the F input, production physics ray and panel close order.
	var station: StaticBody3D = player.dispatch_station
	player.global_position = Vector3(station.global_position.x, 0.02, station.global_position.z + 1.5)
	player.camera.look_at(station.global_position + Vector3(0.0, 0.2, 0.0))
	await physics_frame
	await physics_frame
	check(player._looks_at_dispatch(), "the authored Dispatch counter is in reticle reach")
	await open_dispatch()
	if not check(panel.is_open() and player.world_input_blocked and not paused, "F opens Dispatch with the live clock and blocks world controls"):
		finish()
		return
	if OS.get_cmdline_user_args().has("--dispatch-no-ready"):
		await prove_empty_workforce()
		finish()
		return
	panel._members[2].pressed.emit()
	panel._affinities.Electronics.pressed.emit()
	check(panel._send.disabled and ops.members == 3 and ops.affinities == ["Electronics"], "incomplete pair disables visible Dispatch")
	await key_tap(KEY_F)
	check(not panel.is_open() and ops.ready_count == 8, "F closes without spending")
	await open_dispatch()
	check(panel.is_open() and ops.members == 3 and ops.affinities == ["Electronics"], "F reopen retains the exact unformed draft")
	panel._members[0].pressed.emit()
	panel._affinities.Food.pressed.emit()
	check(not panel._send.disabled, "valid pair enables Dispatch")
	ops.rng.seed = 9100
	panel._send.pressed.emit()
	check(ops.journeys.size() == 1 and ops.ready_count == 7 and panel.is_open(), "explicit zero-loadout Dispatch opens the next draft immediately")
	var first: String = ops.journeys.keys()[0]
	check(ops.journeys[first].status == Ops.AWAY and ops.journeys[first].members == 1, "first crew leaves at one-member capacity")
	panel._affinities.Electronics.pressed.emit()
	check(panel._affinities.Food.disabled and not panel._affinities.Fuel.disabled, "only currently available partners are selectable")

	var seed: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/Food_DryGoodsA/WorldItem")
	var hydration: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/Hydration_FoodCan/WorldItem")
	check(seed.pickup_into(carry) and hydration.pickup_into(carry), "two real selected supplies are carried")
	panel._members[3].pressed.emit()
	panel._affinities.Fuel.pressed.emit()
	await key_event(KEY_E, true)
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, true)
	await key_event(KEY_E, false)
	check(ops.is_formed() and ops.members == 4 and ops.loadout.spent.size() == 1 and carry.get_item_count() == 1,
		"one distinct E consumes a whole selected item, with no held repeat")
	check(panel._members.all(func(button: Button): return button.disabled), "formed crew count is visibly locked")
	check(ops.toggle_affinity("Fuel") and ops.toggle_affinity("Hydration"), "formed crew can edit affinity while supply stays spent")
	await observe_live_clock(timeline)
	await capture_render("dispatch-preparation")
	ops.rng.seed = 9311
	panel._send.pressed.emit()
	check(ops.journeys.size() == 2 and ops.ready_count == 3, "second crew commits a four-member budget")
	var second: String = ops.journeys.keys()[1]
	await key_tap(KEY_ESCAPE)
	check(not panel.is_open() and not paused, "ESC closes preparation before Pause")
	await key_tap(KEY_ESCAPE)
	check(shell.menu_open and paused, "next ESC opens the normal pause")
	await key_tap(KEY_ESCAPE)
	check(not shell.menu_open and not paused, "ESC resumes the normal world")
	var elapsed: float = timeline.clock.elapsed
	timeline.advance(maxf(ops.journeys[first].return_at, ops.journeys[second].return_at) - elapsed + 30.0)
	check(ops.ready_count == 8 and runtime.lift_cycle.can_take_receiving(), "both healthy crews are Ready on active and queued admission")
	var observed := []
	for index in 2:
		var batch := runtime.receiving_manager.get_active_batch()
		var trip: Dictionary = ops.journeys[batch.source_ref]
		observed.append(trip.members)
		var count := batch.entries.size()
		check(count > 0 and count <= trip.members * 4, "committed batch matches a bounded crew")
		if index == 0:
			await capture_receiving(runtime)
		if not await drain_into_stock(runtime, stock, count, true):
			finish()
			return
		timeline.advance(60.0)
		print("EXPEDITION_TAKE crew=", trip.members, " items=", count, " bulk=", batch.actual_bulk,
			" manifest=", trip.manifest)
	check(observed.has(1) and observed.has(4), "both one- and four-member journeys reached ordinary storage")
	check(wing.collection_goal.totals.values().max() > 0 and Snapshot.new().validate(Snapshot.new().capture(wing)).is_empty(),
		"live collection and exact retired cargo ownership validate")
	await prove_layout_extremes(runtime, timeline)
	print("EXPEDITION_REACH max_take_m=", max_take_reach)
	finish()

func bind_wing() -> void:
	wing = shell.wing
	wing.set_process(false)
	player = wing.get_node("Player")
	player.set_process(false)
	player.set_physics_process(false)
	carry = player.carried_items
	placement = player._storage_placement

func prove_empty_workforce() -> void:
	var ops: RefCounted = wing.expeditions
	var panel: CanvasLayer = wing.dispatch_panel
	for index in Config.CATEGORIES.size():
		var first: String = Config.CATEGORIES[index]
		var second: String = Config.CATEGORIES[(index + 1) % Config.CATEGORIES.size()]
		if not check(depart_pair(ops, first, second, 9100 + index), "ordinary one-person zero-loadout departure"):
			return
	if not check(ops.ready_count == 0 and not ops.is_formed() and ops.active_ids().size() == 8,
			"all eight scavengers are Away with an unformed draft"):
		return
	var food: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/Food_DryGoodsA/WorldItem")
	var hydration: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/Hydration_FoodCan/WorldItem")
	if not check(food.pickup_into(carry) and hydration.pickup_into(carry), "real eligible items are carried for both workforce cases"):
		return
	var empty := Snapshot.new().capture(wing)
	check_empty_panel(panel)
	check(panel._activity.text.count("Away") == 8, "the open panel lists all eight Away operations")
	await press_preparation_button(panel._affinities.Food)
	await press_preparation_button(panel._send)
	await key_tap(KEY_E)
	check(Snapshot.new().capture(wing) == empty, "empty panel click and E preserve the complete run snapshot")
	if failures != 0:
		return
	await capture_render("dispatch-no-ready")

	# Schema 9 allowed these dormant preferences to be written by the old panel.
	for saved_affinities: Array in [["Food"], ["Food", "Weapons"]]:
		var saved := empty.duplicate(true)
		saved.expeditions.draft.affinities = saved_affinities
		if not await continue_preparation(saved, "empty draft with %d stored affinities" % saved_affinities.size()):
			return
		ops = wing.expeditions
		panel = wing.dispatch_panel
		check_empty_panel(panel)
		var revision: int = ops.revision
		var removed: bool = ops.toggle_affinity("Food")
		var added: bool = ops.toggle_affinity("Morale")
		check(not removed and not added and not ops.set_members(1) and not ops.contribute(carry).ok
			and not ops.dispatch(revision).ok and ops.revision == revision and Snapshot.new().capture(wing) == saved,
			"direct edits, supply and departure leave dormant choices, inventory, receipts, RNG and identity intact")

	var timeline: RefCounted = wing.run_timeline
	timeline.advance(ops.next_return_at() - timeline.clock.elapsed)
	if not check(ops.ready_count == 1 and panel.is_open() and panel._crew.text.contains("1 selected")
			and panel._affinities.Food.button_pressed and panel._affinities.Weapons.button_pressed
			and not panel._send.disabled and ops.journeys.size() == 8,
			"admission re-enables the open draft with the same preferences and no auto-dispatch"):
		return
	await key_tap(KEY_E)
	if not check(ops.ready_count == 0 and ops.is_formed() and ops.loadout.spent.size() == 1,
			"first supply commits the final Ready scavenger"):
		return
	var formed_id: String = ops.loadout.request_id
	await key_tap(KEY_F)
	check(not panel.is_open(), "F closes the formed preparation")
	await open_dispatch()
	check(panel.is_open() and panel._crew.text.contains("1 selected") and not panel._send.disabled,
		"reopening keeps the formed zero-Ready crew visible and dispatchable")
	if not await continue_preparation(Snapshot.new().capture(wing), "formed draft at zero Ready", true):
		return
	ops = wing.expeditions
	panel = wing.dispatch_panel
	timeline = wing.run_timeline
	check(ops.ready_count == 0 and ops.loadout.request_id == formed_id and panel._crew.text.contains("1 selected")
		and panel._members.all(func(button: Button): return button.disabled),
		"Continue preserves the formed identity and the visible locked count")
	await press_preparation_button(panel._affinities.Weapons)
	await press_preparation_button(panel._affinities.Morale)
	check(ops.affinities == ["Food", "Morale"] and not panel._send.disabled, "formed zero-Ready crew can deselect and choose an available affinity")
	await key_tap(KEY_E)
	check(ops.loadout.spent.size() == 2 and carry.get_item_count() == 0, "formed zero-Ready crew accepts a second eligible supply")
	await capture_render("dispatch-formed-zero-ready")
	await press_preparation_button(panel._send)
	if not check(ops.journeys.size() == 9 and ops.journeys.has(formed_id) and not ops.is_formed() and ops.ready_count == 0,
			"the formed crew departs exactly once and leaves an empty preparation"):
		return
	check_empty_panel(panel)

	# The first three nonempty returns fill the active slot and two deposits.
	# Send each newly available member away so the fourth meets an empty roster.
	for index in 2:
		timeline.advance(ops.next_return_at() - timeline.clock.elapsed)
		if not check(ops.ready_count == 1 and panel.is_open(), "queued admission returns a scavenger to Ready"):
			return
		if not check(depart_pair(ops, "Fuel", "Weapons" if index == 0 else "Morale", 9200 + index), "send the newly available scavenger away"):
			return
	timeline.advance(ops.next_return_at() - timeline.clock.elapsed)
	check(ops.ready_count == 0 and panel._activity.text.contains("Awaiting Lift")
		and ops.journeys.values().any(func(trip: Dictionary): return trip.status == Ops.WAITING and not ops.destination_busy(trip.destination)),
		"a returned crew releases its destination while Awaiting Lift without releasing personnel")
	check_empty_panel(panel)
	print("DISPATCH_NO_READY_VIEWPORT ", root.size, " display=", DisplayServer.get_name())

func check_empty_panel(panel: CanvasLayer) -> void:
	check(panel.is_open() and panel._crew.text == "0 Ready  •  No crew available"
		and panel._members.all(func(button: Button): return button.disabled and not button.button_pressed),
		"empty roster shows no positive selection or pressed member button: " + panel._crew.text)
	check(panel._affinities.values().all(func(button: Button): return button.disabled and not button.button_pressed)
		and panel._send.disabled, "empty roster disables every affinity and Dispatch")
	check(panel._bulk.text.contains("unavailable") and not panel._destination.text.contains("Development destination"),
		"empty roster presents loadout, capacity and destination as unavailable")

func depart_pair(ops: RefCounted, first: String, second: String, seed_value: int) -> bool:
	if not ops.set_members(1) or not ops.toggle_affinity(first) or not ops.toggle_affinity(second):
		return false
	ops.rng.seed = seed_value
	return ops.dispatch(ops.revision).ok

func continue_preparation(saved: Dictionary, label: String, save_and_exit: bool = false) -> bool:
	var saved_ok: bool = shell.save_and_exit() if save_and_exit else shell.save_service.save_snapshot(saved).ok
	if not check(saved.schema == 9 and saved_ok and shell.continue_run(), "isolated schema-9 Continue: " + label + " " + shell.status_label.text):
		return false
	bind_wing()
	if not check(Snapshot.new().capture(wing) == saved, "exact run snapshot, including cargo, goal, Fuel and Kitchen: " + label):
		return false
	await open_dispatch()
	return check(wing.dispatch_panel.is_open(), "open restored preparation: " + label)

func press_preparation_button(button: Button) -> void:
	if DisplayServer.get_name() == "headless":
		button.pressed.emit()
		return
	await process_frame
	var center := button.get_global_rect().get_center()
	for pressed in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = center
		click.global_position = center
		click.pressed = pressed
		root.push_input(click, true)
		await process_frame

func prove_layout_extremes(runtime: ReceivingRuntime, timeline: RefCounted) -> void:
	var pool := Config.build_pool(runtime.item_catalog)
	var tested := 0
	# Maximum-count homogeneous cases bound each declared footprint and height.
	for category: String in Config.CATEGORIES:
		for definition: ItemDefinition in pool[category]:
			var copies := floori(float(Config.MAX_MEMBERS * Config.BULK_PER_MEMBER) / definition.bulk)
			var manifest: Array = []
			manifest.resize(copies)
			manifest.fill(String(definition.item_id))
			check(runtime.can_prepare_manifest(manifest, "extreme_" + String(definition.item_id), 8310 + tested),
				"deck prepares maximum homogeneous count for " + definition.display_name)
			tested += 1
	var rng := RandomNumberGenerator.new()
	for index in 16:
		rng.seed = 8200 + index
		var manifest := Config.sample_manifest(32, [Config.CATEGORIES[index % 8], Config.CATEGORIES[(index + 3) % 8]], rng, pool)
		check(runtime.can_prepare_manifest(manifest, "mixed_%d" % index, 8340 + index), "deck prepares bounded mixed haul %d" % index)
		tested += 1
	for id in ["loot_000084", "loot_000033", "loot_000007"]:
		var manifest: Array = []
		manifest.resize(16)
		manifest.fill(id)
		var batch := runtime.prepare_manifest(manifest, "reach_" + id, 8401)
		if not check(batch != null and runtime.return_admission.submit_return("reach_" + id, batch) != 0, "extreme delivery submits"):
			return
		timeline.advance(60.0)
		var identities := {}
		for entry: LootBatchEntry in batch.entries:
			identities[entry.item_instance_id] = true
		check(identities.size() == 16, "repeated types preserve distinct exact item identities")
		if not await drain_into_stock(runtime, null, 16, false):
			return
		timeline.advance(60.0)
	print("EXPEDITION_LAYOUT prepared_extremes_and_mixed=", tested, " progressive_extremes=3")

func drain_into_stock(runtime: ReceivingRuntime, stock: StorageSurface, count: int, use_input: bool) -> bool:
	for index in count:
		await physics_frame
		await physics_frame
		var candidate := _nearest_exposed_candidate(player, player.camera, runtime.deck_presenter.get_materialized_world_items())
		if not check(not candidate.is_empty(), "a progressive reticle target is available for " + runtime.receiving_manager.get_active_batch().source_ref):
			return false
		var hit: float = candidate.hit_distance_m
		max_take_reach = maxf(max_take_reach, hit)
		_place_player_at_stance(player, candidate.stance_z)
		player.camera.look_at(candidate.target_position)
		var world: WorldItem = candidate.world_item
		if not check(hit <= player.receiving_interaction_distance and player._get_looked_at_world_item() == world,
			"production ray reaches the exposed item"):
			return false
		var item := world.get_item_instance()
		if use_input and DisplayServer.get_name() != "headless":
			await mouse_take()
		else:
			player._attempt_pickup_click()
		if not check(carry.get_items().has(item), "TAKE transfers the exact item"):
			return false
		if stock != null:
			var stored := false
			placement.set_suppressed(false)
			for shelf: StorageSurface in [stock, wing.get_functional_surfaces()[2], wing.get_functional_surfaces()[3]]:
				shelf.initialize_zones_if_needed(StorageCategories.GENERAL)
				if put(item, shelf):
					stored = true
					break
			if not check(stored, "ordinary placement stores the expedition item"):
				return false
		else:
			carry.remove_item(item) # Test-only handoff to expose the next crate-free deck item.
	return check(runtime.receiving_manager.get_active_batch().is_drained(), "every committed item was taken")

func key_tap(code: Key) -> void:
	await key_event(code, true)
	await key_event(code, false)

func open_dispatch() -> void:
	if DisplayServer.get_name() == "headless":
		# The dummy display always reports a visible mouse. The native proof uses F.
		player.dispatch_requested.emit()
	else:
		await key_tap(KEY_F)

func key_event(code: Key, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await process_frame

func mouse_take() -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await process_frame

func observe_live_clock(timeline: RefCounted) -> void:
	var before: float = timeline.clock.elapsed
	var time_text: String = wing._collection_hud._time.text
	wing.set_process(true)
	await process_frame
	await process_frame
	var started := Time.get_ticks_usec()
	while Time.get_ticks_usec() - started < 1_200_000:
		await process_frame
	wing.set_process(false)
	var progress: float = timeline.clock.elapsed - before
	check(progress >= 1.0 and wing.dispatch_panel.is_open() and wing._collection_hud._time.text != time_text,
		"ordinary frames advance the visible clock with Dispatch open")
	print("DISPATCH_LIVE_CLOCK active_delta=", progress, " hud=", wing._collection_hud._time.text)

func capture_receiving(runtime: ReceivingRuntime) -> void:
	var crt := wing.get_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface")
	check(crt.get_node("Status").text.contains("OPEN") and crt.get_node("Queue").text.ends_with("01")
		and runtime.lift_cycle.can_take_receiving(), "CRT retains OPEN and counts only the other deposited haul")
	var previous: Transform3D = player.camera.global_transform
	var held: Node3D = player._held_item_view
	var held_visible := held != null and held.visible
	if held_visible:
		held.hide()
	player.camera.global_position = Vector3(-32.6, 1.75, 2.85)
	player.camera.look_at(Vector3(-36.5, 1.65, -0.5))
	await capture_render("receiving-expedition-open")
	player.camera.global_transform = previous
	if held_visible:
		held.show()

func capture_render(label: String) -> void:
	var evidence := OS.get_environment("SORTING_EXPEDITION_RENDER_DIR")
	if DisplayServer.get_name() == "headless" or evidence.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var pixels := root.get_texture().get_image()
	check(pixels != null and not pixels.is_empty() and pixels.save_png(evidence.path_join(label + ".png")) == OK, "native capture " + label)

func finish() -> void:
	current_scene = null
	shell.free()
	print("expedition_physical_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)
