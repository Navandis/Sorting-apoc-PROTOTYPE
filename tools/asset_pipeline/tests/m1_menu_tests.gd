extends SceneTree

class BrokenSeedShell extends "res://gameplay/run/run_shell.gd":
	func _candidate() -> Node3D:
		var candidate := super._candidate()
		candidate.get_node("DevelopmentSetup/SeedItems/Medical_Bandages").item_id = &"missing_seed_definition"
		return candidate

var failures := 0
var checks := 0
var external_dir := ""

func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func key(code: Key, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	await process_frame
	await process_frame

func run() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M1 menu helper aborted; completion missing")
		quit(3))
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m1-save-dir="): external_dir = arg.trim_prefix("--m1-save-dir=")
	if not check(external_dir.is_absolute_path() and not external_dir.begins_with(ProjectSettings.globalize_path("res://")), "external menu-save destination required"):
		finish()
		return
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new(external_dir)
	root.add_child(shell)
	check(shell.continue_button.disabled and shell.launch.visible and shell.wing == null, "no-save Continue greyed and non-interactive at launch")
	DirAccess.make_dir_recursive_absolute(external_dir)
	var launch_blocker := external_dir.path_join("launch-write-blocker")
	var launch_file := FileAccess.open(launch_blocker, FileAccess.WRITE)
	launch_file.store_string("ordinary test fixture")
	launch_file.close()
	shell.save_service.directory = launch_blocker.path_join("saves")
	check(not shell.start_new_run() and shell.wing == null and shell.launch.visible and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "failed initialization keeps launch usable and leaves no partial published run")
	shell.save_service.directory = external_dir
	check(shell.start_new_run(), "New Run initializes and publishes one valid initial slot")
	var wing = shell.wing
	var player = wing.get_node("Player")
	player.set_physics_process(false)
	player.global_position = Vector3(4.3, 0.0, -27.45)
	await physics_frame
	await physics_frame
	player.camera.look_at(wing.get_node("Environment/Greybox/Proxies/MedicalInterface").global_position)
	var panel = wing.get_node("MedicalContribution/ContributionPanel")
	player.medical_interface.open_panel()
	check(panel.is_open(), "ESC fixture targets active Medical panel")
	await key(KEY_ESCAPE, true)
	check(not panel.is_open() and not paused and not shell.menu_open, "first ESC closes contribution without menu pause")
	await key(KEY_ESCAPE, false)
	shell.set_menu_open(false)
	# Headless menu checks retain the scene's ordinary held view but keep it empty.
	var cycle = wing.get_node("ReceivingRuntime/ReceivingLiftCycle")
	check(wing.get_node("ReceivingRuntime").run_debug_delivery(1842,9001,4,0), "live cue starts through normal debug route")
	await physics_frame
	await physics_frame
	await process_frame
	var before: Dictionary = cycle.capture_state()
	var logical_before: float = wing.run_identity.gameplay_seconds
	shell.set_menu_open(true)
	for i: int in 5: await process_frame
	check(paused and shell.pause_menu.visible and cycle.capture_state() == before and wing.run_identity.gameplay_seconds == logical_before, "ESC menu suspends logical progression and shutter")
	print("PAUSE_DIAGNOSTIC playing=", cycle.get_node("Arrival").playing, " stream_paused=", cycle.get_node("Arrival").stream_paused, " blocked=", player.world_input_blocked)
	check(cycle.get_node("Arrival").stream_paused and player.world_input_blocked, "ESC suspends associated audio and polled world commands")
	var key := InputEventKey.new()
	key.keycode = KEY_E
	key.pressed = true
	Input.parse_input_event(key)
	shell.set_menu_open(false)
	check(not paused and not cycle.get_node("Arrival").stream_paused and cycle._elapsed == before.elapsed and player._require_e_release, "Resume keeps same theatre and rejects queued E")
	var release := InputEventKey.new()
	release.keycode = KEY_E
	release.pressed = false
	Input.parse_input_event(release)
	player._open_zone_editor_for_surface(wing.get_functional_surfaces()[0])
	check(paused and shell.pause_owners.has("zoning"), "zoning owns its existing full pause")
	shell.set_menu_open(true)
	player._zone_editor.close_editor()
	check(paused and shell.pause_owners.has("menu") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "closing zoning cannot unpause or capture mouse beneath menu")
	shell.set_menu_open(false)
	check(not paused, "last pause owner releases simulation")
	player._open_zone_editor_for_surface(wing.get_functional_surfaces()[1])
	shell.set_menu_open(true)
	shell.set_menu_open(false)
	check(paused and shell.pause_owners.has("zoning"), "closing menu retains zoning pause")
	player._zone_editor.close_editor()
	shell.set_menu_open(true)
	var run_id: String = wing.run_identity.run_id
	shell.request_new_run()
	check(shell.confirmation.visible and shell.wing == wing, "New Run asks before replacement")
	shell.cancel_new_run()
	check(shell.wing.run_identity.run_id == run_id and shell.save_service.inspect_slot().ok, "reset cancellation preserves live run and continuation")
	var ordinary_directory: String = shell.save_service.directory
	var blocker := ordinary_directory.path_join("ordinary-write-blocker")
	var file := FileAccess.open(blocker, FileAccess.WRITE)
	file.store_string("ordinary test fixture")
	file.close()
	shell.save_service.directory = blocker.path_join("saves")
	check(not shell.save_and_exit() and shell.wing == wing and paused and shell.pause_status.text.begins_with("Save failed:"), "ordinary write failure leaves current run paused with explanation")
	shell.save_service.directory = ordinary_directory
	check(shell.save_service.inspect_slot().ok, "write failure retains previous successful slot")
	check(shell.save_and_exit() and shell.wing == null and shell.launch.visible and not shell.continue_button.disabled and not paused, "Save & Exit writes before unloading to launch")
	check(shell.continue_run() and shell.wing.run_identity.run_id == run_id and not paused, "Continue restores same run without persistent menu pause")
	shell.set_menu_open(true)
	shell.request_new_run()
	shell.confirm_new_run()
	check(shell.wing.run_identity.run_id != run_id and shell.wing.medical_request.credited.Medical == 0, "confirmed reset creates one new open request")
	var good_service = shell.save_service
	var good_id: String = good_service.load_snapshot().snapshot.run.id
	shell.free()
	var broken := BrokenSeedShell.new()
	broken.save_service = good_service
	root.add_child(broken)
	check(not broken.start_new_run() and broken.wing == null, "failed seed initialization never publishes an empty replacement run")
	check(good_service.load_snapshot().snapshot.run.id == good_id, "failed initialization preserves previous successful continuation")
	broken.free()
	paused = false
	finish()

func finish() -> void:
	print("M1_MENU_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
