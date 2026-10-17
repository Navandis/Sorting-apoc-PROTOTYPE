extends SceneTree

var failures := 0
var checks := 0

func _init() -> void:
	create_timer(30).timeout.connect(func():
		push_error("M2 clock helper aborted; completion missing")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	if not check(ResourceLoader.exists("res://gameplay/run/run_clock.gd"), "run has an authoritative calendar clock"):
		finish()
		return
	var clock = load("res://gameplay/run/run_clock.gd").new()
	clock.advance(150.0)
	check(clock.elapsed == 150.0 and clock.calendar_seconds() == 28800.0, "150 unpaused seconds advances 07:00 to 08:00")
	check(clock.until_midnight() == 2400.0, "full active day lasts 2550 seconds")
	clock.advance(9999.0)
	check(clock.elapsed == 2550.0 and clock.calendar_seconds() == 86400.0, "clock cannot run beyond midnight")
	clock.begin_next_day()
	check(clock.day == 2 and clock.elapsed == 2550.0 and clock.calendar_seconds() == 25200.0, "night jumps calendar without seven hours of active work")
	var saved: Dictionary = clock.capture_state()
	var copy = load("res://gameplay/run/run_clock.gd").new()
	copy.config.rate = 48.0
	copy.restore_state(saved)
	copy.advance(1.25)
	check(copy.elapsed == 2551.25 and copy.calendar_seconds() == 25230.0, "exact restored coordinates use saved rate")
	var scenario = load("res://gameplay/run/run_scenario.gd").new()
	var definition: Dictionary = load("res://tools/asset_pipeline/tests/m2_mechanical_fixture.gd").new().definition()
	check(scenario.validate(definition).is_empty(), "approved finite scenario is valid")
	var late := definition.duplicate(true)
	late.events[0].at = 75540.0
	late.events[0].deadline = 86340.0
	check(scenario.validate(late).is_empty(), "20:59 plus three hours is valid")
	late.events[0].at = 75600.0
	late.events[0].deadline = 86400.0
	check(not scenario.validate(late).is_empty(), "21:00 plus three hours cannot close at midnight")
	var overlap := definition.duplicate(true)
	var second: Dictionary = overlap.events[0].duplicate(true)
	second.id = "medical_004"
	second.at = 30000.0
	second.deadline = 40000.0
	overlap.events.append(second)
	check(not scenario.validate(overlap).is_empty(), "overlapping Medical windows rejected")
	second.at = 36000.0
	check(scenario.validate(overlap).is_empty(), "adjacent Medical windows accepted")
	var invalid := definition.duplicate(true)
	invalid.events[1].manifest = ["loot_000034"]
	check(not scenario.validate(invalid).is_empty(), "unsupported manifest rejected before run publication")
	invalid = definition.duplicate(true)
	invalid.events[1].at = 85201.0
	check(not scenario.validate(invalid).is_empty(), "new controlled returns after 23:40 rejected")
	var events := [{"id":"return_003","kind":"return","departure":5.0}, {"id":"return_002","kind":"return","departure":1.0}, {"id":"return_001","kind":"return","departure":1.0}]
	events.sort_custom(scenario.activation_before)
	check(events.map(func(e): return e.id) == ["return_001","return_002","return_003"], "return order uses actual departure then ordinal stable ID")
	var closures := [{"id":"medical_002","opened_at":3.0}, {"id":"medical_003","opened_at":1.0}, {"id":"medical_001","opened_at":1.0}]
	closures.sort_custom(scenario.closure_before)
	check(closures.map(func(e): return e.id) == ["medical_001","medical_003","medical_002"], "closure order uses actual initiation then ordinal ID")
	finish()

func finish() -> void:
	print("M2_CLOCK_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
