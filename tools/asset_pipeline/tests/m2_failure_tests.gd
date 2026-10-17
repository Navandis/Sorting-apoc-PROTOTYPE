extends SceneTree

class FixedStampService extends "res://gameplay/run/run_save_service.gd":
	var attempts := 0
	func save_snapshot(state: Dictionary, _local_time: Dictionary = {}) -> Dictionary:
		attempts += 1
		return super.save_snapshot(state, {"year":2026,"month":10,"day":17,"hour":12,"minute":34})

var checks := 0
var failures := 0
var external_dir := ""

func _init() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M2 failure helper aborted; completion missing")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m2-save-dir="): external_dir = arg.trim_prefix("--m2-save-dir=")
	if not check(external_dir.is_absolute_path() and not external_dir.begins_with(ProjectSettings.globalize_path("res://")), "mandatory isolated failure-test directory"):
		finish()
		return
	var service = FixedStampService.new(external_dir.path_join("failure-slot"))
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = service
	root.add_child(shell)
	if not check(shell.start_new_run(), "prior valid continuation established"):
		shell.free()
		finish()
		return
	shell.wing.set_process(false)
	shell.wing.get_node("Player").set_physics_process(false)
	var previous: Dictionary = service.load_snapshot()
	var previous_bytes := FileAccess.get_file_as_bytes(previous.path)
	var pointer_bytes := FileAccess.get_file_as_bytes(service.directory.path_join(service.POINTER))
	# A directory blocks the real rename after same-name snapshot installation.
	# No fake write implementation: production bounded rollback must restore bytes.
	var blocker: String = service.directory.path_join(".m1-old-pointer.tmp")
	check(DirAccess.make_dir_absolute(blocker) == OK, "ordinary pointer replacement obstruction created in isolated directory")
	shell.wing.run_schedule.advance(2550.0)
	check(paused and shell.wing.run_schedule.phase == "REPORT_PENDING" and shell.report_view.visible, "failed automatic save retains coherent prepared day/report")
	check(service.attempts == 2 and shell.midnight_save_status == "Automatic save failed. Progress since the last successful save is not saved.", "one automatic attempt warns without retry workflow")
	check(FileAccess.get_file_as_bytes(previous.path) == previous_bytes and FileAccess.get_file_as_bytes(service.directory.path_join(service.POINTER)) == pointer_bytes and service.load_snapshot().snapshot == previous.snapshot, "failed same-name replacement preserves previous snapshot and pointer byte-for-byte")
	shell.begin_next_day()
	check(not paused and shell.wing.run_schedule.clock.day == 2 and service.attempts == 2, "Begin Day remains available after save failure and does not retry")
	check(not shell.save_and_exit() and paused and shell.wing != null, "explicit Save & Exit keeps existing fail-paused behavior")
	check(DirAccess.remove_absolute(blocker) == OK, "remove only own empty obstruction")
	check(shell.save_and_exit(), "later ordinary Save & Exit succeeds through same service")
	var m2_snapshot: Dictionary = service.load_snapshot().snapshot
	shell.free()
	# An isolated M1-shaped fixture must be rejected before any reconstruction.
	var old_dir := external_dir.path_join("old-schema")
	DirAccess.make_dir_recursive_absolute(old_dir)
	var old := m2_snapshot.duplicate(true)
	old.schema = 1
	old.run.scenario = "m1_medical_v1"
	old.request = old.schedule.requests[0]
	old.erase("clock")
	old.erase("schedule")
	var text: String = load("res://gameplay/run/state_codec.gd").new().stringify(old)
	var file := FileAccess.open(old_dir.path_join("Save_m1_fixture.json"), FileAccess.WRITE)
	file.store_string(text)
	file.close()
	file = FileAccess.open(old_dir.path_join("active-slot.json"), FileAccess.WRITE)
	file.store_string('{"snapshot":"Save_m1_fixture.json"}')
	file.close()
	var old_bytes := FileAccess.get_file_as_bytes(old_dir.path_join("Save_m1_fixture.json"))
	var old_pointer := FileAccess.get_file_as_bytes(old_dir.path_join("active-slot.json"))
	shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new(old_dir)
	root.add_child(shell)
	check(shell.continue_button.disabled and shell.status_label.text.contains("M1 continuation is incompatible"), "old M1 Continue disabled with explicit incompatibility explanation")
	check(not shell.continue_run() and shell.wing == null, "old Continue never resets or converts")
	shell.request_new_run()
	check(shell.confirmation.visible, "replacement requires existing confirmation")
	shell.cancel_new_run()
	check(FileAccess.get_file_as_bytes(old_dir.path_join("Save_m1_fixture.json")) == old_bytes and FileAccess.get_file_as_bytes(old_dir.path_join("active-slot.json")) == old_pointer, "cancelled New Run leaves old slot untouched")
	# Invalid authored schedules cannot initialize a replacement snapshot.
	var candidate = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	var invalid: Dictionary = load("res://gameplay/run/run_scenario.gd").new().default_definition()
	invalid.events[0].deadline = 86400.0
	candidate.configure_new_run(invalid)
	candidate.get_node("Player").enable_held_item_view = false
	root.add_child(candidate)
	check(not candidate.get_initialization_error().is_empty() and load("res://gameplay/run/run_snapshot.gd").new().capture(candidate).is_empty(), "invalid scenario fails before save/publication")
	candidate.free()
	candidate = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	invalid = load("res://gameplay/run/run_scenario.gd").new().default_definition()
	invalid.events[1].manifest = []
	invalid.events[1].manifest.resize(2000)
	invalid.events[1].manifest.fill("loot_000028")
	candidate.configure_new_run(invalid)
	candidate.get_node("Player").enable_held_item_view = false
	root.add_child(candidate)
	check(not candidate.get_initialization_error().is_empty(), "unpresentable future exact manifest is rejected before replacement publication")
	candidate.free()
	shell.free()
	finish()

func finish() -> void:
	paused = false
	print("M2_FAILURE_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
