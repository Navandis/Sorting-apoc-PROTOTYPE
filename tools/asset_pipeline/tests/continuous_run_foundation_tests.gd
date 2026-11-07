extends SceneTree

const WING = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)

func run() -> void:
	var wing := WING.instantiate()
	wing.configure_new_run()
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.set_process(false)
	var timeline: RefCounted = wing.run_timeline
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var manager := runtime.receiving_manager
	var admission: AwaitingLiftAdmission = runtime.return_admission
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	check(wing.get_initialization_error().is_empty(), "canonical wing initializes")
	var batches: Array[LootBatch] = []
	for index in 4:
		var id := "pressure_%03d" % index
		var batch := runtime.prepare_manifest(["loot_000019"], id, index)
		if batch == null:
			check(false, "exact pressure manifest prepares")
			break
		batches.append(batch)
		check(admission.submit_return(id, batch) == (1 if index < 3 else 2), "one active, two deposited, then awaiting")
	if batches.size() == 4:
		var cycle: ReceivingLiftCycle = runtime.lift_cycle
		var first: WorldItem = runtime.deck_presenter.get_materialized_world_items()[0]
		check(not first.pickup_into(carry), "ARRIVAL rejects TAKE")
		timeline.advance(0.125)
		check(timeline.clock.elapsed == 0.125 and cycle.capture_state().elapsed == 0.125, "clock and arrival share one fractional delta")
		paused = true
		timeline.advance(20.0)
		check(timeline.clock.elapsed == 0.125 and cycle.capture_state().elapsed == 0.125, "pause holds both run and lift")
		paused = false
		for index in 600:
			timeline.advance(1.0)
		check(timeline.clock.elapsed == 600.125, "normal steps cross the former cutoff")
		check(wing.get_node_or_null("MedicalContribution") == null and wing.get_node_or_null("KitchenContribution") == null and wing.get_node_or_null("DispatchContribution") == null, "no daily service producers are installed")
		for index in 2100:
			timeline.advance(1.0)
		check(timeline.clock.elapsed == 2700.125 and not paused, "ordinary steps cross the first former midnight")
		timeline.advance(2700.25)
		check(timeline.clock.elapsed == 5400.375 and not paused and not wing.get_node("Player").world_input_blocked, "repeated former midnight boundaries neither clamp nor block play")
		check(admission.get_return_status("pressure_003") == &"AWAITING_LIFT", "oldest waiting cargo survives former midnight boundaries")
		check(manager.get_active_batch() == batches[0] and cycle.get_queued_batch_count() == 2, "OPEN retains A, CRT counts only two deposits")
		if timeline.clock.elapsed > 5400.0:
			check(first.pickup_into(carry) and cycle.get_cycle_state() == ReceivingLiftCycle.State.CLOSING, "successful last TAKE starts closing")
			timeline.advance(3.4)
			check(manager.get_active_batch() == batches[0], "closed contact retains cargo through outbound")
			timeline.advance(100.0)
			check(manager.get_active_batch() == batches[1] and cycle.can_take_receiving(), "large advance retires A then opens B exactly once")
			check(manager.get_queued_batch_ids() == PackedStringArray([batches[2].batch_id, batches[3].batch_id]), "queued C precedes admitted D")
			check(admission.get_return_status("pressure_003") == &"ADMITTED_RETURNED", "waiting cargo admits without changing identity")
	var clock: RefCounted = timeline.clock
	check(clock.sample_delta(2_000_000) == 0.0, "first frame establishes a monotonic baseline")
	wing.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(clock.sample_delta(3_000_000) == 1.0 and not paused, "focus loss preserves the active clock")
	check(clock.sample_delta(13_000_000) == 0.0 and clock.sample_delta(13_125_000) == 0.125, "long silent suspension gap is discarded before sampling resumes")
	wing.notification(Node.NOTIFICATION_APPLICATION_RESUMED)
	check(clock.sample_delta(13_250_000) == 0.0, "explicit application resume rebases sampling")
	clock.reset_sample()
	wing.get_node("Player").set_physics_process(false)
	wing.set_process(true)
	await process_frame
	await process_frame
	var before: float = clock.elapsed
	var started := Time.get_ticks_usec()
	while Time.get_ticks_usec() - started < 250_000:
		await process_frame
	var wall := (Time.get_ticks_usec() - started) / 1_000_000.0
	print("ACTIVE_TIME_SAMPLE wall=", wall, " active=", clock.elapsed - before, " paused=", paused, " fault=", timeline.error)
	check(absf(clock.elapsed - before - wall) < 0.08 and clock.elapsed > before + 0.15, "ordinary running frames track elapsed real seconds")
	wing.free()
	print("continuous_run_foundation_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)
