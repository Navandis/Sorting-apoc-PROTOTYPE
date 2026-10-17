extends "res://tools/asset_pipeline/tests/m1_rendered_tests.gd"
var _pending_helpers := 0

func run() -> void:
	create_timer(90).timeout.connect(func():
		push_error("M2 rendered helper aborted; completion missing")
		quit(3))
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m2-evidence-dir="): evidence_dir = arg.trim_prefix("--m2-evidence-dir=")
	if not check(evidence_dir.is_absolute_path() and not evidence_dir.begins_with(ProjectSettings.globalize_path("res://")), "external rendered/save directory required"):
		finish()
		return
	DirAccess.make_dir_recursive_absolute(evidence_dir)
	print("M2_RENDERER ", RenderingServer.get_current_rendering_method(), " display=", DisplayServer.get_name())
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new(evidence_dir.path_join("slot"))
	root.add_child(shell)
	if not check(shell.start_new_run(), "rendered M2 New Run uses isolated production save service"):
		shell.free()
		finish()
		return
	var wing = shell.wing
	wing.set_process(false)
	var player = wing.get_node("Player")
	player.set_physics_process(false)
	check(player.enable_held_item_view and player._held_item_view != null, "real held view enabled")
	check(wing.get_node("DevelopmentSetup/SeedItems/Medical_Antibiotics/WorldItem").pickup_into(player.carried_items), "real seed TAKE selects +5 antibiotics")
	player.global_position = Vector3(4.3, 0.0, -27.45)
	await frames(4)
	player.camera.look_at(wing.get_node("Environment/Greybox/Proxies/MedicalInterface").global_position)
	player._pitch = player.camera.rotation.x
	await frames(3)
	await key(KEY_F, false)
	await key(KEY_F, true)
	await key(KEY_F, false)
	var panel = player.medical_interface.panel
	check(panel.is_open() and panel.deadline_label.text.contains("10:00:00") and panel.deadline_label.text.contains("remaining"), "F opens non-pausing panel with shared-clock deadline")
	check_layout(panel)
	await capture("01-deadline-preview-1920")
	DisplayServer.window_set_size(Vector2i(1280,720))
	await frames(5)
	check_layout(panel)
	await capture("02-deadline-preview-1280")
	wing.run_schedule.advance(449.99)
	await key(KEY_E, false)
	await key(KEY_E, true)
	check(wing.medical_request.credited.Medical == 5 and panel.is_open(), "distinct E just before deadline credits once")
	wing.run_schedule.advance(0.01)
	await frames(3)
	check(not panel.is_open() and not player.medical_interface.is_active() and not player.medical_interface.action_label.text.contains("[F]") and not player._interaction_prompt.visible, "expiry while open closes panel and suppresses both station cues")
	await key(KEY_E, true, true)
	await key(KEY_E, false)
	check(wing.medical_request.spent.size() == 1 and wing.medical_request.result.Medical.unmet == 7, "held expiry input cannot recredit or execute later")
	await capture("03-expired-cues-1280")
	player.global_position = Vector3(-14.5,0.0,-0.4)
	await frames(3)
	var hud = wing.get_children().filter(func(child): return child.get_script() == load("res://gameplay/run/clock_hud.gd"))[0]
	check(hud.visible and hud.label.text.contains("DAY 1 · 10:00:00"), "persistent clock remains accurate away from Medical")
	await capture("04-clock-away-1280")
	wing.run_schedule.advance(2100.0)
	await frames(4)
	check(paused and shell.report_view.visible and shell.report_view.title.text == "End of Day 1" and shell.report_view.body.text.contains("Credited 5") and shell.report_view.body.text.contains("Unmet 7"), "read-only rendered report shows already-applied partial result")
	check(hud.label.text.contains("DAY 2 · 07:00:00") and hud.label.text.contains("NIGHT REPORT / PAUSED"), "report clock displays prepared next day with pause indication")
	check_report_layout(shell.report_view)
	await capture("05-report-1280")
	DisplayServer.window_set_size(Vector2i(1920,1080))
	await frames(5)
	check_report_layout(shell.report_view)
	await capture("06-report-1920")
	print("M2_RENDERED_TIMING ", wing.run_schedule.transition_metrics)
	await key(KEY_ESCAPE, true)
	await key(KEY_ESCAPE, false)
	check(shell.menu_open and paused and shell.pause_owners.has("night_report"), "actual synthetic ESC accesses menu over report")
	await capture("07-report-menu")
	check(shell.save_and_exit() and shell.continue_run() and paused and shell.report_view.visible, "rendered Save & Exit and Continue restore pending report")
	wing = shell.wing
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	await capture("08-report-restored")
	shell.begin_next_day()
	var original_directory: String = shell.save_service.directory
	var blocker: String = evidence_dir.path_join("blocked-save-root")
	var file := FileAccess.open(blocker, FileAccess.WRITE)
	file.store_string("isolated ordinary write failure")
	file.close()
	shell.save_service.directory = blocker.path_join("saves")
	wing.run_schedule.advance(2550.0)
	await frames(4)
	check(shell.report_view.save_status.text == "Automatic save failed. Progress since the last successful save is not saved." and not shell.report_view.begin_button.disabled, "save warning is readable without blocking Begin Day")
	check_report_layout(shell.report_view)
	await capture("09-warning-1920")
	DisplayServer.window_set_size(Vector2i(1280,720))
	await frames(5)
	check_report_layout(shell.report_view)
	await capture("10-warning-1280")
	shell.save_service.directory = original_directory
	shell.begin_next_day()
	check(not paused and not wing.get_node("Player").world_input_blocked, "report dismissal restores playable state with held-action guards")
	shell.free()
	finish()

func check_report_layout(report: CanvasLayer) -> void:
	_pending_helpers += 1
	var card: Rect2 = report.card.get_global_rect()
	var viewport := root.get_visible_rect()
	var contained := viewport.encloses(card)
	for control: Control in report.card.find_children("*", "Control", true, false):
		contained = contained and card.grow(1).encloses(control.get_global_rect())
	check(contained and absf(card.get_center().x - viewport.get_center().x) <= 1.0, "report and warning controls centered/contained at " + str(root.size))
	_pending_helpers -= 1

func finish() -> void:
	paused = false
	check(_pending_helpers == 0, "all rendered layout helpers completed")
	print("M2_RENDERED_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
