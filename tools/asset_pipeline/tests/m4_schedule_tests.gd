extends SceneTree

var checks := 0
var failures := 0
func _init() -> void:
	create_timer(180).timeout.connect(func():
		push_error("M4 schedule helper incomplete")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	var scenario = load("res://gameplay/run/run_scenario.gd").new()
	var authored: Dictionary = scenario.default_definition()
	if not check(authored.id == "m4_expedition_loadout" and authored.revision == 4, "Default scenario is approved M4"):
		finish()
		return
	check(scenario.validate(authored).is_empty(), "M4 authored scenario validates")
	check(authored.config == {"rate":24.0,"day_start":21600.0,"latest_return":85200.0}, "06:00 day at 2.5 real minutes per game hour")
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/scenarios/m4/Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json"))
	var returns: Array = authored.events.filter(func(e): return e.kind == "return")
	check(returns.size() == 12 and authored.initial_seed == baseline.scenario.seed, "Exact finite fixture, complete seed replaces old stock")
	for i: int in returns.size():
		check(returns[i].manifest == baseline.scenario.manifests[i].path and returns[i].at == [30600.0,45900.0,63000.0,80100.0][i % 4], "Exact ordered delivery and time: %d" % i)
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	wing.configure_new_run(authored)
	wing.set_process(false)
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	await process_frame
	wing.get_node("Player").set_physics_process(false)
	var schedule = wing.run_schedule
	check(wing.get_initialization_error().is_empty(), "Production wing initializes: " + wing.get_initialization_error())
	var teams: Array = schedule.dispatch_requests()
	check(teams.size() == 4 and teams.map(func(t): return t.members) == [4,4,4,4], "Daily 16 Ready activates four separate concurrent requests")
	var ids := teams.map(func(t): return t.request_id)
	check(ids.size() == 4 and ids[0] != ids[1] and teams[0].request_id != teams[0].occurrence_id, "Durable allocated team identities distinct from display/occurrence")
	schedule.advance(1.2345678912345)
	schedule.advance(600.0 - schedule.clock.elapsed)
	check(schedule.clock.elapsed == 600.0 and schedule.clock.calendar_seconds() == 36000.0, "Fractional advance lands exactly at 10:00")
	check(teams.all(func(t): return t.closed and t.closure_reason == "cutoff" and t.closed_at == 600.0), "Cutoff settles all empty teams once")
	var breakfast = schedule.active_request("kitchen")
	check(breakfast != null and breakfast.targets == {"Food":48,"Hydration":40} and schedule.active_request("medical_bay") == null, "Breakfast opens after dispatch and Medical closure at 10:00")
	var terminal: Array = teams.map(func(t): return t.capture_state())
	schedule.advance(2100.0)
	check(schedule.phase == "REPORT_PENDING" and schedule.clock.day == 2 and schedule.clock.calendar_seconds() == 21600.0, "Midnight resolves then holds next day at 06:00")
	check(schedule.report.dispatch == terminal and schedule.report.meals.size() == 3 and schedule.report.medical[0].targets.Medical == 24, "Completed-day dispatch retained alongside existing consumers")
	check(schedule.dispatch_requests().size() == 4 and schedule.requests.filter(func(t): return t.destination == "dispatch").size() == 8, "New daily teams once; previous immutable results retained")
	schedule.begin_day()
	schedule.advance(2700.0)
	check(schedule.report.medical[0].targets.Medical == 36 and schedule.report.dispatch.size() == 4, "Day 2 demands and roster")
	schedule.begin_day()
	schedule.advance(2700.0)
	check(schedule.report.medical[0].targets.Medical == 48 and schedule.report.scenario_complete and schedule.dispatch_requests().is_empty(), "Day 3 resolution; no invented Day 4 teams/supply")
	schedule.begin_day()
	schedule.advance(2700.0)
	check(schedule.report.dispatch.is_empty() and schedule.report.meal_coverage == null, "Exhausted scenario explicitly continues without new demand")
	wing.free()
	finish()

func finish() -> void:
	print("M4_SCHEDULE_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
