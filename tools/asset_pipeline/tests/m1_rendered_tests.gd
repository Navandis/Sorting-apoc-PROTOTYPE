extends SceneTree

var failures := 0
var checks := 0
var evidence_dir := ""

func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func frames(count: int) -> void:
	for frame: int in count: await process_frame

func key(code: Key, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	await frames(2)

func capture(name: String) -> void:
	await frames(3)
	await RenderingServer.frame_post_draw
	var pixels := root.get_texture().get_image()
	check(pixels != null and pixels.save_png(evidence_dir.path_join(name + ".png")) == OK, "rendered capture " + name)

func run() -> void:
	create_timer(90).timeout.connect(func():
		push_error("M1 rendered helper aborted; completion missing")
		quit(3))
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m1-evidence-dir="): evidence_dir = arg.trim_prefix("--m1-evidence-dir=")
	if not check(evidence_dir.is_absolute_path() and not evidence_dir.begins_with(ProjectSettings.globalize_path("res://")), "external render/save destination required"):
		finish()
		return
	var service_script = load("res://gameplay/run/run_save_service.gd")
	print("M1_NORMAL_SAVE_DIRECTORY ", service_script.new().directory)
	print("M1_RENDERER ", RenderingServer.get_current_rendering_method(), " display=", DisplayServer.get_name())
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = service_script.new(evidence_dir.path_join("rendered-slot"))
	root.add_child(shell)
	await capture("01-launch-no-save")
	if not check(shell.start_new_run(), "rendered New Run starts canonical wing"):
		shell.free()
		finish()
		return
	var wing = shell.wing
	var player = wing.get_node("Player")
	player.set_physics_process(false)
	check(player.enable_held_item_view and player._held_item_view != null, "real held view remains enabled")
	var seeds = wing.get_node("DevelopmentSetup/SeedItems")
	check(seeds.get_node("Medical_Antibiotics/WorldItem").pickup_into(player.carried_items), "actual TAKE provides +5 item")
	player.global_position = Vector3(4.3, 0.0, -27.45)
	var proxy: Node3D = wing.get_node("Environment/Greybox/Proxies/MedicalInterface")
	await frames(6)
	player.camera.look_at(proxy.global_position)
	player._pitch = player.camera.rotation.x
	print("TARGET_DIAGNOSTIC camera=", player.camera.global_position, " direction=", -player.camera.global_basis.z, " proxy=", proxy.global_position, " hit=", player.medical_interface.is_targeted())
	check(player.medical_interface.is_targeted(), "existing Medical proxy is locally targetable")
	await key(KEY_E, false)
	await key(KEY_E, true)
	var panel = wing.get_node("MedicalContribution/ContributionPanel")
	if not check(panel.is_open() and wing.medical_request.credited.Medical == 0, "real input pipeline first E opens without consumption"):
		await capture("targeting-failure")
		shell.free()
		finish()
		return
	await key(KEY_E, true, true)
	check(wing.medical_request.credited.Medical == 0, "echo cannot submit through real input pipeline")
	await key(KEY_E, false)
	await key(KEY_E, true)
	check(wing.medical_request.credited.Medical == 5 and player.carried_items.get_item_count() == 0, "distinct E commits exactly one item")
	await key(KEY_E, false)
	check(seeds.get_node("Medical_Bandages/WorldItem").pickup_into(player.carried_items), "real TAKE provides preview item")
	check(panel.preview_state.projected == 8 and panel.preview_state.applied == 3, "rendered 5/12 +3 previews 8/12")
	await capture("02-valid-preview-5-plus-3")
	check(seeds.get_node("Book/WorldItem").pickup_into(player.carried_items), "real ineligible item available")
	await key(KEY_2, true)
	await key(KEY_2, false)
	check(panel.invalid_highlight and panel.status_label.text == "Selected item not eligible", "selection updates actual ineligible binding")
	await capture("03-ineligible-feedback")
	check(seeds.get_node("MedKit_A/WorldItem").pickup_into(player.carried_items), "real +8 item available")
	await key(KEY_3, true)
	await key(KEY_3, false)
	check(panel.preview_state.applied == 7 and panel.preview_state.wasted == 1, "actual selected medkit previews whole-item waste")
	await capture("04-cap-and-waste")
	await key(KEY_ESCAPE, true)
	await key(KEY_ESCAPE, false)
	check(paused and shell.menu_open, "real ESC input owns full menu pause")
	await capture("05-paused-menu")
	shell.set_menu_open(false)
	player._open_zone_editor_for_surface(wing.get_functional_surfaces()[0])
	await key(KEY_ESCAPE, true)
	await key(KEY_ESCAPE, false)
	player._zone_editor.close_editor()
	check(paused and shell.menu_open and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "native nested menu retains visible cursor when zoning closes beneath it")
	check(shell.save_and_exit(), "rendered partial run saves before unload")
	await capture("06-launch-continue")
	check(not shell.continue_button.disabled and shell.continue_run(), "rendered Continue loads partial run")
	wing = shell.wing
	player = wing.get_node("Player")
	player.set_physics_process(false)
	check(wing.medical_request.credited.Medical == 5 and player.carried_items.get_selected_index() == 2, "rendered continuation preserves request and selected held medkit")
	await key(KEY_E, false)
	await key(KEY_E, true)
	await key(KEY_E, false)
	await key(KEY_E, true)
	await key(KEY_E, false)
	check(wing.medical_request.closed and wing.medical_request.credited.Medical == 12, "continued run closes exactly once through E")
	await capture("07-closed-result")
	check(shell.save_and_exit() and shell.continue_run() and shell.wing.medical_request.closed, "closed request survives Save & Exit / Continue")
	shell.free()
	finish()

func finish() -> void:
	print("M1_RENDERED_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
