extends SceneTree

var failures := 0
var checks := 0
var _pending_helpers := 0

func _init() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M2 schedule helper aborted; completion missing")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func new_wing(definition: Dictionary = {}) -> Node:
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	wing.get_node("Player").enable_held_item_view = false
	wing.configure_new_run(load("res://tools/asset_pipeline/tests/m2_mechanical_fixture.gd").new().definition() if definition.is_empty() else definition)
	root.add_child(wing)
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	return wing

func run() -> void:
	if not check(ResourceLoader.exists("res://gameplay/run/run_schedule.gd"), "production run coordinates calendar events and mechanics"):
		finish()
		return
	var wing = new_wing()
	var schedule = wing.run_schedule
	var runtime = wing.get_node("ReceivingRuntime")
	check(wing.get_initialization_error().is_empty() and wing.medical_request.day == 1, "day-one start occurrence prepared exactly once")
	schedule.advance(150.0)
	var batch: LootBatch = runtime.receiving_manager.get_active_batch()
	check(batch != null and batch.entries.size() == 1 and batch.entries[0].definition_id == &"loot_000028", "08:00 commits exact medkit via admission")
	check(runtime.return_admission.get_return_status("return_001") == &"ADMITTED_RETURNED" and runtime.lift_cycle.capture_state().elapsed == 0.0, "return starts lift at actual timestamp, with no previous-frame progress")
	schedule.advance(300.0)
	check(wing.medical_request.closed and wing.medical_request.result.Medical.unmet == 12, "10:00 zero request expired during large advance")
	check(runtime.lift_cycle.get_cycle_state() == ReceivingLiftCycle.State.OPEN, "large advance settles complete causal arrival/open chain")
	schedule.advance(9999.0)
	check(schedule.phase == "REPORT_PENDING" and schedule.clock.day == 2 and schedule.clock.elapsed == 2550.0, "large advance stops at report, discarding leftover next-day play")
	check(schedule.report.day == 1 and schedule.report.medical[0].result.Medical.unmet == 12 and schedule.report.admitted.size() == 1 and schedule.report.backlog.size() == 1, "report uses closed results, actual admission and deposited backlog")
	var report: Dictionary = schedule.report.duplicate(true)
	schedule.advance(1000.0)
	check(schedule.clock.elapsed == 2550.0 and schedule.report == report, "report hold cannot queue active time")
	schedule.begin_day()
	schedule.advance(750.0)
	check(schedule.requests.size() == 2 and schedule.requests[1].closed and schedule.requests[1].credited.Medical == 0 and runtime.receiving_manager.get_queued_batch_ids().size() == 1, "Day 2 noon closure precedes incoming antibiotics/bandages")
	var second: LootBatch = runtime.receiving_manager.get_deposited_batch(runtime.receiving_manager.get_queued_batch_ids()[0])
	check(second.entries.map(func(e): return String(e.definition_id)) == ["loot_000025","loot_000026"], "Day 2 manifest has exact ordered entries")
	schedule.advance(1800.0)
	schedule.begin_day()
	schedule.advance(2550.0)
	check(schedule.clock.day == 4 and schedule.requests.size() == 3 and schedule.issued.size() == 6 and schedule.scenario_complete(), "all three days fire finite content once")
	schedule.begin_day()
	schedule.advance(2550.0)
	check(schedule.clock.day == 5 and schedule.requests.size() == 3 and schedule.issued.size() == 6, "Day 4 continues night/save without new supplies")
	wing.free()
	await compare_segments()
	next_day_start()
	finish()

func next_day_start() -> void:
	_pending_helpers += 1
	var definition: Dictionary = load("res://tools/asset_pipeline/tests/m2_mechanical_fixture.gd").new().definition()
	definition.events = [definition.events[0], definition.events[1]]
	definition.events[1].day = 2
	definition.events[1].at = 25200.0
	var wing = new_wing(definition)
	wing.run_schedule.advance(2550.0)
	check(wing.run_schedule.error.is_empty() and wing.run_schedule.issued.size() == 2, "next-day start return is prepared once while report remains held")
	check(wing.run_schedule.report.admitted.is_empty() and wing.run_schedule.admissions.size() == 1 and wing.run_schedule.admissions[0].day == 2, "next-day start admission cannot enter old-day report")
	wing.free()
	_pending_helpers -= 1

func compare_segments() -> void:
	_pending_helpers += 1
	var a = new_wing()
	a.run_schedule.advance(2550.0)
	var expected: Dictionary = a.run_schedule.capture_state()
	var expected_cycle: Dictionary = a.get_node("ReceivingRuntime/ReceivingLiftCycle").capture_state()
	a.free()
	var b = new_wing()
	for i in 2550:
		b.run_schedule.advance(1.0)
	var actual: Dictionary = b.run_schedule.capture_state()
	# Namespace allocation differs across new runs; compare authored chronology/results.
	check(actual.report.medical[0].result == expected.report.medical[0].result and actual.report.day == expected.report.day and actual.issued.keys() == expected.issued.keys(), "large/segmented advancement yields same logical events and results")
	var cycle: Dictionary = b.get_node("ReceivingRuntime/ReceivingLiftCycle").capture_state()
	check(cycle.state == expected_cycle.state and cycle.elapsed == expected_cycle.elapsed and cycle.warning_elapsed == expected_cycle.warning_elapsed, "large/segmented advancement preserves mechanical phase progress")
	b.free()
	_pending_helpers -= 1

func finish() -> void:
	paused = false
	check(_pending_helpers == 0, "all chronology helpers completed")
	print("M2_SCHEDULE_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
