extends SceneTree

# Catches early reveal, stale TAKE, cue-driven closing, premature retirement,
# mock CRT counts, shared warning writes and moving authored art.
const WingScene = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
const CarriedScript = preload("res://carried_items.gd")
const SourceScript = preload("res://receiving/prototype_loot_source.gd")
const PlannerScript = preload("res://receiving/receiving_deck_layout_planner.gd")
const Lens = preload("res://gameplay/logistics_wing/receiving/lighting/warning_lens.tres")
var failures := 0
var states: Array[int] = []
var refreshes := 0
var drains := 0

func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	if OS.get_cmdline_user_args().has("--cycle-cli-startup"):
		await cli_startup()
		finish()
		return
	if OS.get_cmdline_user_args().has("--cycle-real-time"):
		await real_time_cycle()
		finish()
		return
	var wing := WingScene.instantiate()
	var door: Node3D = wing.get_node("ReceivingLiftInstallation/SM_KB3D_NWD_ReuGarageDoorBlue_B")
	var authored := door.transform
	check(is_equal_approx(authored.origin.y, 3.142), "saved human OPEN pose preserved")
	wing.get_node("Player").set_physics_process(false)
	root.add_child(wing)
	await process_frame
	var runtime = wing.get_node("ReceivingRuntime")
	var cycle = runtime.get_node_or_null("ReceivingLiftCycle")
	if not check(cycle != null, "playable runtime owns a lift-cycle coordinator"):
		wing.free()
		finish()
		return
	cycle.set_process(false) # Feed real logic bounded deltas; retain real cargo/art/audio.
	var manager: ReceivingManager = runtime.receiving_manager
	var presenter = runtime.deck_presenter
	var ui = wing.get_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface")
	var warning: StandardMaterial3D = wing.get_node("Environment/ReceivingLighting/WarningFixtures/W1/Fixture/Mesh").get_surface_override_material(1)
	check(manager.get_active_batch() == null and not cycle.is_busy(), "normal startup has no synthetic cargo")
	check(cycle.get_cycle_state() == 0 and is_equal_approx(door.position.y, .086), "SEALED_EMPTY closes runtime shutter")
	check_fitting(door, authored)
	check(ui.get_node("Identity").text == "FREIGHT LIFT" and ui.get_node("Online").text == "ONLINE", "only L-01 removed")
	check_display(ui, "IDLE", "CLEAR", "00", "AWAITING EXPEDITION LOOT")
	check(not warning.emission_enabled and not Lens.emission_enabled, "warning off; shared resource unchanged")
	for name in ["Arrival", "Opening", "Closing", "Departure"]:
		var audio: AudioStreamPlayer3D = cycle.get_node(name)
		check(audio.stream is AudioStreamWAV and audio.stream.get_length() > 5.0, name + " full supplied cue")
		check(audio.stream.loop_mode == AudioStreamWAV.LOOP_DISABLED and audio.stream.format == AudioStreamWAV.FORMAT_QOA, name + " non-looped QOA")
		check(audio.global_position.distance_to(Vector3(-36.165, 1.486, -.019)) < .001 and audio.max_distance <= 24, name + " positional bounded attenuation")
	cycle.state_changed.connect(func(state: int):
		states.append(state)
		if state == 2:
			check_blocked(presenter, wing, "SEALED_READY")
			check_display(ui, "INCOMING", "24", "00", "DELIVERING EXPEDITION LOOT")
	)
	manager.active_batch_drained.connect(func(_id: String): drains += 1)
	wing.get_node("Environment/ReceivingReflections").refresh_started.connect(func(): refreshes += 1)
	check(runtime.run_debug_delivery(1842, 9001, 24, 3), "explicit mixed delivery deposits")
	var batch: LootBatch = manager.get_active_batch()
	var commitment := batch.to_snapshot()
	check(cycle.get_cycle_state() == 1 and cycle.is_busy(), "deposit automatically enters ARRIVAL")
	check_display(ui, "INCOMING", "CLEAR", "00", "DELIVERING EXPEDITION LOOT")
	check(cycle.get_node("Arrival").playing, "arrival cue starts")
	check_blocked(presenter, wing, "ARRIVAL")
	check(not presenter.reveal_active_batch(), "direct reveal cannot bypass cycle")
	cycle.get_node("Arrival").stop()
	cycle._process(19.0)
	check(cycle.get_cycle_state() == 1 and is_equal_approx(door.position.y, .086), "interrupted audio cannot skip arrival")
	var amber_low := warning.emission_energy_multiplier
	var amber_tint_low := warning.albedo_color
	cycle._process(.5)
	check(warning.emission_enabled and warning.emission.r > warning.emission.g and not is_equal_approx(amber_low, warning.emission_energy_multiplier) and not amber_tint_low.is_equal_approx(warning.albedo_color), "slow pulsing amber including visible lens tint")
	cycle._process(1.0)
	check(cycle.get_cycle_state() == 3 and cycle.get_node("Opening").playing, "staged cargo automatically reveals")
	check_display(ui, "OPENING", "24", "00", "LIFT SHUTTER OPENING")
	cycle._process(2.5)
	check(door.position.y > .086 and door.position.y < 3.1416707, "real shutter moves")
	check_blocked(presenter, wing, "REVEALING")
	cycle._process(4.0)
	check(cycle.get_cycle_state() == 4 and is_equal_approx(door.position.y, 3.1416707), "fully-open-only OPEN")
	check_display(ui, "OPEN", "24", "00", "LOOT READY FOR PICK-UP")
	check(warning.emission.g > warning.emission.r and is_equal_approx(warning.emission_energy_multiplier, .35), "subdued steady green")
	check(Lens.emission_energy_multiplier == 0.0 and not Lens.emission_enabled, "shared warning resource immutable")
	await create_timer(.3).timeout
	var settled_refreshes := refreshes
	cycle._process(100.0)
	await create_timer(.3).timeout
	check(cycle.get_cycle_state() == 4 and refreshes == settled_refreshes, "OPEN indefinite; no per-frame recapture")
	check(wing.find_children("*", "ReflectionProbe", true, false).size() == 1, "one saved probe")
	var carried = CarriedScript.new()
	carried.max_bulk = 99999
	root.add_child(carried)
	var items: Array = presenter.get_materialized_world_items()
	var identities := {}
	var fixtures: Array = presenter.get_materialized_fixture_nodes()
	check(items.size() == 24 and fixtures.size() == 3, "every individual item and freight fixture staged")
	carried.max_bulk = 0
	check(not items[0].pickup_into(carried) and drains == 0 and cycle.get_cycle_state() == 4, "full carried bundle never closes")
	carried.max_bulk = 99999
	for index in items.size():
		var item: ItemInstance = items[index].get_item_instance()
		check(not identities.has(item.instance_id), "unique committed identity")
		identities[item.instance_id] = true
		check(items[index].pickup_into(carried) and carried.get_selected_item() == item, "TAKE transfers exact ItemInstance")
		check(not items[index].pickup_into(carried), "stale direct TAKE cannot duplicate in deletion frame")
		check(cycle.get_deck_item_count() == 23 - index, "live individual remaining count")
		if index < 23:
			check(ui.get_node("Deck").text == "DECK   : %02d" % (23 - index), "CRT counts all remaining items")
		carried.remove_item(item)
	check(drains == 1 and batch.is_drained() and cycle.get_cycle_state() == 5, "final successful TAKE drains once and closes")
	check_display(ui, "CLOSING", "CLEAR", "00", "LIFT SHUTTER CLOSING")
	check(not warning.emission_enabled and warning.albedo_color.is_equal_approx(Lens.albedo_color) and cycle.get_node("Closing").playing, "close restores unlit lens and starts latch cue")
	check(manager.get_active_batch() == batch and presenter.get_materialized_fixture_nodes() == fixtures, "fixtures/ownership retained during close")
	check(not runtime.run_debug_delivery(), "busy delivery cannot be interrupted")
	cycle.get_node("Closing").stop()
	cycle._process(3.0)
	check(door.position.y > .086 and door.position.y < 3.1416707 and cycle.get_cycle_state() == 5, "closing movement")
	cycle._process(3.0)
	check(is_equal_approx(door.position.y, .086) and cycle.get_cycle_state() == 5, "closed endpoint waits for full latch duration")
	cycle._process(2.0)
	check(cycle.get_cycle_state() == 0 and cycle.is_busy() and cycle.get_node("Departure").playing, "IDLE retains busy departure")
	check_display(ui, "IDLE", "CLEAR", "00", "AWAITING EXPEDITION LOOT")
	check(manager.get_active_batch() == batch, "departure retains drained active")
	cycle.get_node("Departure").stop()
	cycle._process(18.0)
	check(cycle.is_busy() and manager.get_active_batch() == batch, "interrupted departure retains full journey")
	cycle._process(2.0)
	await process_frame
	await create_timer(.3).timeout
	check(not cycle.is_busy() and manager.get_active_batch() == null and presenter.get_materialized_fixture_nodes().is_empty(), "completed turnaround retires concealed fixtures")
	check(states == [1, 2, 3, 4, 5, 0], "exact automatic state order")
	check_fitting(door, authored)
	for entry: LootBatchEntry in batch.entries:
		check(identities.has(entry.item_instance_id), "no lost or replaced committed identity")
	check(batch.to_snapshot()["presentation_fixtures"] == commitment["presentation_fixtures"], "no fixture reroll")
	await test_queue_readout(runtime, ui)
	carried.free()
	await create_timer(.6).timeout
	wing.free()
	await test_failed_staging()
	finish()

func check_fitting(door: Node3D, authored: Transform3D) -> void:
	check(door.basis.is_equal_approx(authored.basis) and door.position.x == authored.origin.x and door.position.z == authored.origin.z, "shutter basis/X/Z fitting preserved")

func check_display(ui: Node, status: String, deck: String, queue: String, footer: String) -> void:
	check(ui.get_node("Status").text == "STATUS : " + status, "CRT status " + status)
	check(ui.get_node("Deck").text == "DECK   : " + deck, "CRT deck " + deck)
	check(ui.get_node("Queue").text == "QUEUE  : " + queue, "CRT queue " + queue)
	check(ui.get_node("Waiting").text == footer, "CRT footer " + footer)

func check_blocked(presenter: Node, wing: Node, state: String) -> void:
	var player = wing.get_node("Player")
	var camera: Camera3D = player.get_node("Camera3D")
	var carried = player.get_node("CarriedItems")
	carried.max_bulk = 99999
	for item: WorldItem in presenter.get_materialized_world_items():
		check(not item.is_pickup_interaction_enabled() and not item.can_pickup_into(carried) and not item.pickup_into(carried), state + " rejects direct transfer")
		var shape: CollisionShape3D = item.get_node("PickupArea/PickupShape")
		camera.global_position = shape.global_position + Vector3(1, .3, 0)
		camera.look_at(shape.global_position)
		check(player._get_looked_at_world_item() == null, state + " has no Receiving ray target")

func test_queue_readout(runtime: Node, ui: Node) -> void:
	# Deposited queue readout only; no physical second delivery driven here.
	var batches: Array[LootBatch] = []
	for index in 4:
		var batch = SourceScript.new().generate_committed_batch(runtime.item_catalog, runtime.prototype_loot_pool, "queue_%d" % index, 1842, 9001, 24)
		check(PlannerScript.new().prepare(batch, runtime.item_catalog, runtime.deck_profile).succeeded, "queue control prepares")
		batches.append(batch)
	check(ui.get_node("Queue").text == "QUEUE  : 00", "prepared undelivered commitments excluded")
	check(runtime.receiving_manager.deposit_batch(batches[0]), "active admitted")
	check(runtime.receiving_manager.deposit_batch(batches[1]), "first waiting batch admitted")
	check(ui.get_node("Queue").text == "QUEUE  : 01", "queue excludes active")
	check(runtime.receiving_manager.deposit_batch(batches[2]), "second waiting batch admitted")
	check(ui.get_node("Queue").text == "QUEUE  : 02", "actual queue reaches two")
	check(not runtime.receiving_manager.deposit_batch(batches[3]) and ui.get_node("Queue").text == "QUEUE  : 02", "capacity rejection preserves readout")

func finish() -> void:
	print("receiving_lift_cycle_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)


func test_failed_staging() -> void:
	var wing := WingScene.instantiate()
	root.add_child(wing)
	var runtime = wing.get_node("ReceivingRuntime")
	var cycle = runtime.lift_cycle
	cycle.set_process(false)
	var other_profile = runtime.deck_profile.duplicate(true)
	other_profile.profile_id = &"incompatible_test_profile"
	var batch = SourceScript.new().generate_committed_batch(runtime.item_catalog, runtime.prototype_loot_pool, "unstaged", 1842, 9001, 24)
	check(PlannerScript.new().prepare(batch, runtime.item_catalog, other_profile).succeeded, "incompatible control retains exact prepared content")
	var commitment := var_to_bytes(batch.to_snapshot())
	check(runtime.receiving_manager.deposit_batch(batch), "manager admits prepared control")
	cycle.get_node("Arrival").stop()
	cycle._process(100.0)
	check(cycle.get_cycle_state() == 1 and not cycle.can_take_receiving() and runtime.deck_presenter.get_materialized_world_items().is_empty(), "cue completion cannot bypass failed staging")
	check(var_to_bytes(batch.to_snapshot()) == commitment and runtime.receiving_manager.get_active_batch() == batch, "failed staging never retires or rerolls cargo")
	await create_timer(.6).timeout
	wing.free()

func real_time_cycle() -> void:
	var wing := WingScene.instantiate()
	wing.get_node("Player").enable_held_item_view = false # Do not create and destroy a viewmodel within a single test frame.
	wing.get_node("Player").set_physics_process(false)
	root.add_child(wing)
	current_scene = wing
	var camera: Camera3D = wing.get_node("Player/Camera3D")
	camera.global_position = Vector3(-32.6, 1.75, 2.85)
	camera.look_at(Vector3(-36.5, 1.65, -.5))
	wing.get_node("Player").set_process_unhandled_input(false)
	var runtime = wing.get_node("ReceivingRuntime")
	var cycle = runtime.lift_cycle
	var start := Time.get_ticks_msec()
	cycle.state_changed.connect(func(state: int):
		print("CYCLE_REALTIME state=", state, " elapsed_s=", (Time.get_ticks_msec() - start) / 1000.0)
	)
	await capture("idle")
	check(runtime.run_debug_delivery(1842, 9001, 24, 3), "real-time prototype starts")
	await create_timer(1.0).timeout
	await capture("arrival")
	check(await wait_for_state(cycle, 3, 24.0), "actual authored journey reaches REVEALING")
	await create_timer(2.7).timeout
	await capture("opening")
	check(await wait_for_state(cycle, 4, 10.0), "actual shutter reaches OPEN")
	await capture("open")
	await create_timer(1.0).timeout
	check(cycle.get_cycle_state() == 4, "completed opening cue leaves OPEN awaiting unloading")
	var carried = wing.get_node("Player/CarriedItems")
	carried.max_bulk = 99999
	for item: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		var exact := item.get_item_instance()
		check(item.pickup_into(carried) and carried.get_selected_item() == exact, "real-time exact TAKE")
		carried.remove_item(exact)
		await physics_frame
	await create_timer(2.7).timeout
	await capture("closing")
	check(await wait_for_state(cycle, 0, 12.0), "actual close and latch return IDLE")
	check(cycle.is_busy() and cycle.get_node("Departure").playing, "actual departure retains turnaround")
	var deadline := Time.get_ticks_msec() + 24000
	while cycle.is_busy() and Time.get_ticks_msec() < deadline:
		await create_timer(.1).timeout
	check(not cycle.is_busy() and runtime.receiving_manager.get_active_batch() == null, "real playback completes departure and retirement")
	await capture("complete")
	print("CYCLE_REALTIME total_s=", (Time.get_ticks_msec() - start) / 1000.0)
	wing.free()
	current_scene = null

func wait_for_state(cycle: Node, state: int, seconds: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000)
	while cycle.get_cycle_state() != state and Time.get_ticks_msec() < deadline:
		await create_timer(.1).timeout
	return cycle.get_cycle_state() == state

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image != null and not image.is_empty(), "renderer produces cycle pixels")
	if image != null:
		image.save_png("res://reports/receiving/stage_c_2026-10-12/" + label + ".png")

func cli_startup() -> void:
	var wing = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
	root.add_child(wing)
	await process_frame
	await process_frame
	var runtime = wing.get_node("ReceivingRuntime")
	check(runtime.receiving_manager.get_active_batch() != null and runtime.deck_presenter.get_materialized_world_items().size() == 24, "actual CLI flags prepare and deposit exact prototype cargo")
	check(runtime.lift_cycle.get_cycle_state() == 1 and runtime.lift_cycle.is_busy(), "CLI delivery enters ARRIVAL")
	check(runtime.deck_presenter.get_presentation_state() == 0 and not runtime.lift_cycle.can_take_receiving(), "CLI cargo stays non-interactable")
	await create_timer(.6).timeout
	wing.free()