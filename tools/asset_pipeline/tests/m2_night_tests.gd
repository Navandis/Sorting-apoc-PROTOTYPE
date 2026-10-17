extends SceneTree

var failures := 0
var checks := 0
var external_dir := ""

func _init() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M2 night helper aborted; completion missing")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--m2-save-dir="): external_dir = argument.trim_prefix("--m2-save-dir=")
	if not check(external_dir.is_absolute_path() and not external_dir.begins_with(ProjectSettings.globalize_path("res://")), "isolated external save destination required"):
		finish()
		return
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new(external_dir)
	root.add_child(shell)
	if not check(shell.start_new_run(), "valid new M2 run saved before publication"):
		shell.free()
		finish()
		return
	var wing = shell.wing
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	wing.run_schedule.advance(2550.0)
	check(paused and shell.pause_owners.has("night_report"), "midnight acquires separate report pause")
	var saved: Dictionary = shell.save_service.load_snapshot()
	check(saved.ok and saved.snapshot.schedule.phase == "REPORT_PENDING" and saved.snapshot.clock.day == 2, "same production service auto-saves prepared next day with completed report")
	if not check(shell.has_method("begin_next_day"), "report acknowledgment releases prepared day"):
		shell.free()
		finish()
		return
	var report: Dictionary = wing.run_schedule.report.duplicate(true)
	var issued: Dictionary = wing.run_schedule.issued.duplicate(true)
	shell.set_menu_open(true)
	shell.set_menu_open(false)
	check(paused and shell.pause_owners.has("night_report"), "closing menu cannot release report hold")
	check(shell.save_and_exit(), "Save & Exit accessible while report pending")
	check(shell.continue_run() and paused and shell.pause_owners.has("night_report"), "Continue restores report hold before gameplay publication")
	wing = shell.wing
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	var before: Dictionary = wing.get_node("ReceivingRuntime/ReceivingLiftCycle").capture_state()
	await process_frame
	await process_frame
	check(wing.run_schedule.clock.elapsed == 2550.0 and wing.get_node("ReceivingRuntime/ReceivingLiftCycle").capture_state() == before, "no unpaused frame behind restored report")
	shell.request_pause("zoning", true)
	shell.begin_next_day()
	check(paused and wing.run_schedule.phase == "ACTIVE" and not shell.pause_owners.has("night_report"), "Begin Day releases only report reason")
	check(wing.run_schedule.report == report and wing.run_schedule.issued == issued and shell.save_service.load_snapshot().snapshot.schedule.phase == "REPORT_PENDING", "dismissal changes no outcomes/events and does not save again")
	shell.request_pause("zoning", false)
	check(not paused and not wing.get_node("Player").world_input_blocked, "last hold releases gameplay with command guards")
	check(shell.save_and_exit() and shell.continue_run() and not paused and shell.wing.run_schedule.phase == "ACTIVE", "Save & Exit after dismissal restores active next day")
	var snapshot: Dictionary = load("res://gameplay/run/run_snapshot.gd").new().capture(shell.wing)
	var invalid := snapshot.duplicate(true)
	invalid.clock.elapsed += 1.0
	check(not load("res://gameplay/run/run_snapshot.gd").new().validate(invalid).is_empty(), "clock/identity disagreement rejected")
	invalid = snapshot.duplicate(true)
	invalid.schedule.report.medical[0].result.Medical.unmet = 0
	check(not load("res://gameplay/run/run_snapshot.gd").new().validate(invalid).is_empty(), "report cannot disagree with applied historical result")
	shell.free()
	finish()

func finish() -> void:
	paused = false
	print("M2_NIGHT_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
