extends SceneTree

var checks := 0
var failures := 0
var _pending_helpers := 0

func _init() -> void:
	create_timer(50).timeout.connect(func():
		push_error("M2 Receiving boundary helper aborted; completion missing")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func fixture(parent: Node = null) -> Node:
	var definition: Dictionary = load("res://gameplay/run/run_scenario.gd").new().default_definition()
	definition.events = []
	# Deliberately reversed authoring order; actual departure, then stable ID wins.
	for index: int in [4,3,2,1]:
		definition.events.append({"id":"return_%03d" % index,"kind":"return","day":1,"at":25200.0,
			"departure":0.0,"manifest":["loot_000026"],"presentation_seed":9000+index})
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	wing.process_mode = Node.PROCESS_MODE_PAUSABLE # Same contract as RunShell._candidate().
	wing.configure_new_run(definition)
	wing.get_node("Player").enable_held_item_view = false
	(root if parent == null else parent).add_child(wing)
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	return wing

func run() -> void:
	await midnight_edge(0.25)
	await midnight_edge(0.0)
	await actual_pause_resume()
	await report_audio_hold()
	check(_pending_helpers == 0, "all Receiving boundary helpers completed")
	print("M2_RECEIVING_BOUNDARY_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)

func midnight_edge(before_midnight: float) -> void:
	_pending_helpers += 1
	var wing = fixture()
	var schedule = wing.run_schedule
	var runtime = wing.get_node("ReceivingRuntime")
	var cycle = runtime.lift_cycle
	var owner = runtime.return_admission
	var manager = runtime.receiving_manager
	check(owner.get_awaiting_returns().size() == 1 and manager.get_queued_batch_ids().size() == 2, "exact full 1+2 slots retain fourth return upstream")
	check(schedule.admissions.map(func(a): return a.team) == ["return_001","return_002","return_003"], "actual same-time submissions follow ID order independent of authoring")
	var close_duration: float = maxf(cycle._cue_duration(cycle.get_node("Closing")), cycle.closing_motion_delay_s + cycle.closing_motion_duration_s)
	var departure_duration: float = cycle._cue_duration(cycle.get_node("Departure"))
	schedule.advance(2550.0 - close_duration - departure_duration - before_midnight)
	check(cycle.can_take_receiving(), "full day advancement retains OPEN until actual TAKE")
	check(runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(wing.get_node("Player/CarriedItems")), "last actual TAKE starts closing without retiring")
	check(manager.get_queued_batch_ids().size() == 2 and owner.get_awaiting_returns().size() == 1, "last TAKE does not create early capacity")
	schedule.advance(close_duration + departure_duration + before_midnight)
	var status: StringName = owner.get_return_status("return_004")
	if before_midnight > 0.0:
		check(status == &"ADMITTED_RETURNED" and schedule.report.admitted.size() == 4 and schedule.report.forfeits.is_empty(), "pre-midnight vacancy settles deferred admission at logical time, without another rendered frame")
		check(manager.get_queued_batch_ids().size() == 2 and cycle.capture_state().elapsed == before_midnight, "deposited FIFO and successor's exact remaining phase preserved through night")
	else:
		check(status == &"FORFEITED_RETURNED" and schedule.report.forfeits.size() == 1 and schedule.report.admitted.size() == 3, "exact-midnight vacancy cannot rescue waiter")
		check(manager.get_queued_batch_ids().size() == 1 and cycle.capture_state().elapsed == 0.0 and cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL, "same-time mechanics may promote deposited successor without advancing it")
	var before: Dictionary = cycle.capture_state()
	await process_frame
	await process_frame
	check(owner.get_return_status("return_004") == status and cycle.capture_state() == before, "deferred callbacks cannot resurrect forfeits or advance report-held mechanics")
	var snapshot: Dictionary = load("res://gameplay/run/run_snapshot.gd").new().capture(wing)
	check(load("res://gameplay/run/run_snapshot.gd").new().validate(snapshot).is_empty(), "boundary ownership and admission report snapshot validate")
	wing.free()
	_pending_helpers -= 1

func report_audio_hold() -> void:
	_pending_helpers += 1
	var directory := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m2-save-dir="): directory = arg.trim_prefix("--m2-save-dir=")
	if not check(directory.is_absolute_path() and not directory.begins_with(ProjectSettings.globalize_path("res://")), "isolated directory required for real shell/audio midnight check"):
		_pending_helpers -= 1
		return
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new(directory)
	root.add_child(shell)
	var wing = fixture(shell)
	shell._publish_run(wing)
	var runtime = wing.get_node("ReceivingRuntime")
	var cycle = runtime.lift_cycle
	var closing: float = maxf(cycle._cue_duration(cycle.get_node("Closing")), cycle.closing_motion_delay_s + cycle.closing_motion_duration_s)
	var departure: float = cycle._cue_duration(cycle.get_node("Departure"))
	wing.run_schedule.advance(2550.0 - closing - departure)
	check(runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(wing.get_node("Player/CarriedItems")), "real shell cutoff fixture drains actual cargo")
	wing.run_schedule.advance(closing + departure)
	check(paused and shell.report_view.visible and cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL, "exact-midnight promoted successor is behind actual shell report hold")
	print("M2_BOUNDARY_AUDIO immediate playing=", cycle.get_node("Arrival").playing, " paused=", cycle.get_node("Arrival").stream_paused, " position=", cycle.get_node("Arrival").get_playback_position(), " can_process=", cycle.get_node("Arrival").can_process())
	check(not cycle.get_node("Arrival").can_process(), "newly queued same-time arrival cue inherits production report hold")
	var before: Dictionary = cycle.capture_state()
	var playback_before: float = cycle.get_node("Arrival").get_playback_position()
	await create_timer(0.1).timeout
	print("M2_BOUNDARY_AUDIO held playing=", cycle.get_node("Arrival").playing, " paused=", cycle.get_node("Arrival").stream_paused, " position=", cycle.get_node("Arrival").get_playback_position(), " can_process=", cycle.get_node("Arrival").can_process())
	check(cycle.capture_state() == before, "real production report hold prevents successor mechanical progress")
	check(cycle.get_node("Arrival").get_playback_position() == playback_before, "queued successor cue cannot advance audio behind report")
	shell.begin_next_day()
	check(not paused and not cycle.get_node("Arrival").stream_paused, "Begin Day resumes same cue through production pause owner")
	shell.free()
	_pending_helpers -= 1

func actual_pause_resume() -> void:
	_pending_helpers += 1
	var wing = fixture()
	var runtime = wing.get_node("ReceivingRuntime")
	var cycle = runtime.lift_cycle
	wing.run_schedule.advance(30.0)
	check(cycle.can_take_receiving(), "ordinary real-second theatre opens before first calendar hour")
	# Exercise production NOTIFICATION_UNPAUSED/deferred rescheduling without a test resume helper.
	check(runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(wing.get_node("Player/CarriedItems")), "drain active for pause-bound vacancy")
	cycle.advance_time(cycle._phase_duration)
	cycle.advance_time(cycle._phase_duration)
	paused = true
	await process_frame
	await process_frame
	check(runtime.return_admission.get_awaiting_returns().size() == 1, "already-deferred vacancy stays held while paused")
	paused = false
	await process_frame
	await process_frame
	check(runtime.return_admission.get_awaiting_returns().is_empty() and runtime.return_admission.get_return_status("return_004") == &"ADMITTED_RETURNED", "actual unpause notification resumes admission once without explicit helper")
	wing.free()
	_pending_helpers -= 1
