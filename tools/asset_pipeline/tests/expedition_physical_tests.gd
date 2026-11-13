extends "res://tools/asset_pipeline/tests/collection_goal_tests.gd"

const Shell = preload("res://gameplay/run/run_shell.tscn")
const SaveService = preload("res://gameplay/run/run_save_service.gd")
const Config = preload("res://gameplay/expeditions/expedition_config.gd")
const Ops = preload("res://gameplay/expeditions/expedition_operations.gd")
const TestSeeds = preload("res://tools/asset_pipeline/tests/expedition_test_support.gd")
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
	await key_tap(KEY_ESCAPE)
	await prove_generated_outcomes()
	finish()

func prove_generated_outcomes() -> void:
	var ops: RefCounted = wing.expeditions
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var timeline: RefCounted = wing.run_timeline
	var panel: CanvasLayer = wing.dispatch_panel
	timeline.advance(1770.0)
	check(wing.fuel.reserve() == 0.0 and carry.get_effective_bulk_limit() == 14,
		"active timeline reaches zero Fuel and 14-Bulk pickup capacity")
	ops.set_members(1)
	ops.toggle_affinity("Electronics")
	for host in ["CerealBox_A", "Hydration_MilkCarton", "Weapons_Pistol", "Protection_Boots", "CDStack_A"]:
		if not await take_supply(host):
			return
		await aim_dispatch()
		await open_dispatch()
		if not check(panel.is_open(), "Dispatch opens from its authored counter"):
			return
		var supplies: int = ops.loadout.spent.size()
		if supplies == 4:
			await capture_render("dispatch-projected-morale")
		await key_event(KEY_E, true)
		await key_event(KEY_E, true, true)
		await key_event(KEY_E, false)
		if not check(ops.loadout.spent.size() == supplies + 1 and carry.get_item_count() == 0,
				"one fresh E spends the exact selected " + host):
			return
		if supplies < 4:
			await key_tap(KEY_F)
			if not check(not panel.is_open(), "F closes the live panel"):
				return
	check(ops.loadout.credited == {"Food": 10, "Hydration": 5, "Protection": 7, "Weapons": 10, "Morale": 12},
		"all five real lanes applied their canonical Utility and caps")
	check(panel._crew.text.contains("locked") and panel._lanes.Protection.effect.text.contains("per original"),
		"Dispatch shows formed crew and per-original effect")
	await press_preparation_button(panel._affinities.Food)
	await press_preparation_button(panel._affinities.Weapons)
	var matches := func(outcome: Dictionary):
		return outcome.originals[0].health != "healthy" and outcome.originals[0].recruited \
			and outcome.duration >= 205.0 and outcome.manifest.size() > outcome.ordinary_count
	var seed_value := TestSeeds.find_seed(ops, runtime, matches)
	if not check(seed_value >= 0 and not panel._send.disabled, "seeded production outcome and available destination"):
		return
	ops.rng.seed = seed_value
	await observe_live_clock(timeline)
	await capture_render("dispatch-five-lanes")
	await press_preparation_button(panel._send)
	if not check(ops.journeys.size() == 1, "native Dispatch commits the staged result"):
		return
	var id: String = ops.journeys.keys()[0]
	var trip: Dictionary = ops.journeys[id]
	check(not panel._activity.text.contains("recruits"), "Away hides committed personnel outcomes")
	print("EXPEDITION_GENERATED seed=", seed_value, " original=", trip.originals, " duration=", trip.duration,
		" ordinary_count=", trip.ordinary_count, " manifest=", trip.manifest)
	await key_tap(KEY_ESCAPE)
	check(not paused and not panel.is_open(), "Escape closes Dispatch before pause")
	for pair: Array in [["Food", "Medical"], ["Hydration", "Protection"], ["Electronics", "Fuel"]]:
		if not depart_pair(ops, pair[0], pair[1], 9100, Vector2(229, 253)):
			check(false, "dispatch a genuine later return to exercise freight congestion")
			return
	timeline.advance(trip.return_at - timeline.clock.elapsed)
	check(trip.status == Ops.COMPLETE and ops.medical.active_count() == 1 and ops.ready_count == 5
		and runtime.lift_cycle.is_waiting_to_start() and wing.fuel.reserve() == 0.0,
		"zero-Fuel pending start already handed over recruit and injured original")
	var medical_deadline: float = ops.medical.next_boundary_at()
	var last: float = trip.return_at
	for departure: Dictionary in ops.journeys.values():
		last = maxf(last, departure.return_at)
	timeline.advance(last - timeline.clock.elapsed)
	var waiting: Array = ops.journeys.keys().filter(func(key): return ops.journeys[key].status == Ops.WAITING)
	if not check(waiting.size() == 1, "one upstream waiter remains"):
		return
	var waiter: String = waiting[0]
	check(runtime.lift_cycle.get_queued_batch_count() == 2 and ops.ready_count == 7
		and not ops.destination_busy(ops.journeys[waiter].destination), "two deposits and one upstream waiter preserve exact ownership")
	if not resume_exact("emergency pending, active patient and upstream waiter"):
		return
	ops = wing.expeditions
	runtime = wing.get_node("ReceivingRuntime")
	timeline = wing.run_timeline
	trip = ops.journeys[id]
	var station: StaticBody3D = player.medical_station
	if not await aim_at_medical(station):
		return
	if DisplayServer.get_name() == "headless":
		player.medical_requested.emit()
	else:
		await key_tap(KEY_F)
	var medical_panel: CanvasLayer = wing.medical_panel
	if not check(medical_panel.is_open() and player.world_input_blocked and not paused
			and medical_panel._patients.text.contains(trip.originals[0].health.capitalize()),
			"authored frontage opens a live natural-recovery view"):
		return
	var before_e := Snapshot.new().capture(wing)
	await key_tap(KEY_E)
	check(Snapshot.new().capture(wing) == before_e, "Medical input leaves ownership, patient and draft unchanged")
	await capture_render("medical-natural-recovery")
	await key_tap(KEY_ESCAPE)
	check(not medical_panel.is_open() and not paused, "Escape closes Medical before pause")
	var cycle: ReceivingLiftCycle = runtime.lift_cycle
	timeline.advance(cycle.wait_remaining())
	for phase in 3:
		if not cycle.can_take_receiving():
			timeline.advance(cycle.seconds_to_boundary())
	if not check(cycle.can_take_receiving(), "emergency freight reaches fully OPEN"):
		return
	var batch := runtime.receiving_manager.get_active_batch()
	var batch_id := batch.batch_id
	check(batch.source_ref == id and batch.entries.size() == trip.manifest.size(), "both portions are one exact active cargo batch")
	var before_camera: Transform3D = player.camera.global_transform
	player.camera.global_position = Vector3(-32.6, 1.75, 2.85)
	player.camera.look_at(Vector3(-36.5, 1.65, -0.5))
	await capture_render("expedition-native-open")
	player.camera.global_transform = before_camera
	if not await take_and_shelve(runtime):
		return
	if not resume_exact("partially unloaded generated haul"):
		return
	ops = wing.expeditions
	timeline = wing.run_timeline
	runtime = wing.get_node("ReceivingRuntime")
	cycle = runtime.lift_cycle
	batch = runtime.receiving_manager.get_active_batch()
	check(batch.batch_id == batch_id and not batch.entries.all(func(entry: LootBatchEntry): return entry.remaining_in_batch),
		"Continue keeps the taken entry and remaining layout")
	while cycle.can_take_receiving():
		if not await take_and_shelve(runtime):
			return
	check(batch.is_drained(), "every ordinary and bonus item was taken and stored")
	for phase in 2:
		timeline.advance(cycle.seconds_to_boundary())
	check(ops.journeys[waiter].status == Ops.COMPLETE and ops.ready_count == 8, "oldest waiter hands over after full outbound")
	if not await aim_at_medical(player.medical_station):
		return
	if DisplayServer.get_name() == "headless":
		player.medical_requested.emit()
	else:
		await key_tap(KEY_F)
	timeline.advance(medical_deadline - timeline.clock.elapsed)
	await process_frame
	check(ops.ready_count == 9 and ops.medical.active_count() == 0 and wing.fuel.reserve() == 0.0,
		"exact natural deadline releases the original under zero Fuel and congestion")
	check(wing.medical_panel.is_open() and wing.medical_panel._patients.text == "No patients."
		and wing.dispatch_panel._summary.text.contains("Ready 9"), "open Medical view and workforce display refresh on recovery")
	await capture_render("medical-recovered")
	check(Snapshot.new().validate(Snapshot.new().capture(wing)).is_empty(), "combined return and recovery continuation is coherent")
	print("EXPEDITION_NATIVE display=", DisplayServer.get_name(), " viewport=", root.size, " max_take_m=", max_take_reach,
		" returned_items=", trip.manifest.size(), " handover=", trip.handover_at, " recovery=", medical_deadline,
		" ready=", ops.ready_count, " fuel=", wing.fuel.reserve())

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
		# Disjoint seed ranges keep this single-handover witness distinct
		# from the simultaneous-return cases in collection continuation.
		if not check(depart_pair(ops, first, second, 9100 + index * 2000), "ordinary one-person zero-loadout departure"):
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

	# Controlled dormant preferences exercise restoration with no Ready crew.
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
			"admission re-enables the open draft with the same preferences and no auto-dispatch. Ready=%d, draft=%s" % [ops.ready_count, panel._crew.text]):
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
	ops.rng.seed = TestSeeds.find_seed(ops, wing.get_node("ReceivingRuntime"), TestSeeds.all_healthy)
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

func depart_pair(ops: RefCounted, first: String, second: String, first_seed: int, duration: Vector2 = Vector2(0, INF)) -> bool:
	if not ops.set_members(1) or not ops.toggle_affinity(first) or not ops.toggle_affinity(second):
		return false
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var seed_value := TestSeeds.find_seed(ops, runtime, func(outcome: Dictionary):
		return TestSeeds.all_healthy(outcome) and outcome.duration >= duration.x and outcome.duration <= duration.y, first_seed)
	if seed_value < 0:
		return false
	ops.rng.seed = seed_value
	return ops.dispatch(ops.revision).ok

func continue_preparation(saved: Dictionary, label: String, save_and_exit: bool = false) -> bool:
	var saved_ok: bool = shell.save_and_exit() if save_and_exit else shell.save_service.save_snapshot(saved).ok
	if not check(saved.schema == Snapshot.SCHEMA and saved_ok and shell.continue_run(), "isolated current-build Continue: " + label + " " + shell.status_label.text):
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

func resume_exact(label: String) -> bool:
	var saved := Snapshot.new().capture(wing)
	if not check(shell.save_and_exit() and shell.continue_run(), "Save & Exit / Continue " + label + " " + shell.status_label.text):
		return false
	bind_wing()
	return check(Snapshot.new().capture(wing) == saved and not wing.medical_panel.is_open(), "exact resume " + label)

func aim_dispatch() -> void:
	var station: StaticBody3D = player.dispatch_station
	player.global_position = Vector3(station.global_position.x, 0.02, station.global_position.z + 1.5)
	player.camera.look_at(station.global_position + Vector3(0.0, 0.2, 0.0))
	await physics_frame
	await physics_frame

func aim_at_medical(station: StaticBody3D) -> bool:
	var at := station.global_position
	for outward: Vector3 in [Vector3.BACK, Vector3.FORWARD, Vector3.RIGHT, Vector3.LEFT]:
		player.global_position = Vector3(at.x, 0.04, at.z) + outward * 1.4
		player.camera.look_at(at)
		await physics_frame
		if player.can_reach_medical():
			return true
	return check(false, "real reticle reaches the Medical frontage")

func take_supply(host: String) -> bool:
	var world := wing.get_node_or_null("DevelopmentSetup/SeedItems/" + host + "/WorldItem") as WorldItem
	if not check(world != null, "authored supply present: " + host):
		return false
	var target: Vector3 = world.get_node("PickupArea/PickupShape").global_position
	var item := world.get_item_instance()
	for direction: Vector3 in [Vector3.BACK, Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT,
			Vector3(0.7, 0, 0.7), Vector3(-0.7, 0, -0.7)]:
		player.global_position = Vector3(target.x, 0.04, target.z) + direction * 0.95
		player.camera.look_at(target)
		await physics_frame
		if player._get_looked_at_world_item() != world:
			continue
		if DisplayServer.get_name() == "headless":
			player._attempt_pickup_click()
		else:
			await mouse_take()
		return check(carry.get_selected_item() == item, "ordinary reticle pickup transfers " + host)
	return check(false, "real pickup target is reachable from a controlled stance: " + host)

func take_and_shelve(runtime: ReceivingRuntime) -> bool:
	await physics_frame
	await physics_frame
	var target := _nearest_exposed_candidate(player, player.camera, runtime.deck_presenter.get_materialized_world_items())
	if not check(not target.is_empty(), "progressive Receiving target exists"):
		return false
	_place_player_at_stance(player, target.stance_z)
	player.camera.look_at(target.target_position)
	var world: WorldItem = target.world_item
	if not check(player._get_looked_at_world_item() == world, "production reticle reaches the generated cargo"):
		return false
	max_take_reach = maxf(max_take_reach, target.hit_distance_m)
	var item := world.get_item_instance()
	if DisplayServer.get_name() == "headless":
		player._attempt_pickup_click()
	else:
		await mouse_take()
	if not check(carry.get_items().has(item), "TAKE transfers the exact generated item"):
		return false
	placement.set_suppressed(false)
	for shelf: StorageSurface in wing.get_functional_surfaces():
		shelf.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, shelf.grid_size - Vector2i.ONE)
		if put(item, shelf):
			return true
	return check(false, "ordinary placement accepts the generated item")
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
