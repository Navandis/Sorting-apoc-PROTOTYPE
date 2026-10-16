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

func check_layout(panel: CanvasLayer) -> void:
	var card: Rect2 = panel._card.get_global_rect()
	var viewport := root.get_visible_rect()
	print("PANEL_LAYOUT window=", root.size, " viewport=", viewport, " card=", card)
	check(absf(card.get_center().x - viewport.get_center().x) <= 1.0 and viewport.encloses(card), "panel centered and contained at " + str(root.size))
	check(card.size.x >= 600 and card.size.x <= 640, "panel width stays bounded")
	var contained := true
	for control: Control in panel._card.find_children("*", "Control", true, false):
		contained = contained and card.grow(1).encloses(control.get_global_rect())
	check(contained, "all panel controls fit inside card")

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
	await frames(2)
	print("TARGET_DIAGNOSTIC camera=", player.camera.global_position, " direction=", -player.camera.global_basis.z, " proxy=", proxy.global_position, " hit=", player.medical_interface.is_targeted())
	check(player.medical_interface.is_targeted(), "existing Medical proxy is locally targetable")
	check(player._interaction_prompt.visible and player._interaction_prompt.text.contains("[F] Request / Contribute") and player.medical_interface.action_label.text.contains("[F] Request / Contribute"), "both open-request cues advertise F")
	await key(KEY_E, true)
	check(not wing.get_node("MedicalContribution/ContributionPanel").is_open() and player.carried_items.get_item_count() == 1, "E outside panel neither opens nor contributes")
	await key(KEY_F, true)
	var panel = wing.get_node("MedicalContribution/ContributionPanel")
	if not check(panel.is_open() and wing.medical_request.credited.Medical == 0, "real input pipeline F opens without consumption"):
		await capture("targeting-failure")
		shell.free()
		finish()
		return
	await key(KEY_F, true, true)
	await key(KEY_F, true)
	await key(KEY_E, true, true)
	await key(KEY_E, true)
	check(panel.is_open() and wing.medical_request.credited.Medical == 0 and player.carried_items.get_item_count() == 1, "held/echo F cannot close opener and preheld E requires release")
	check(wing.find_children("ContributionPanel", "CanvasLayer", true, false).size() == 1 and not paused and player.world_input_blocked, "one non-pausing panel owns world input")
	await key(KEY_E, false)
	await key(KEY_F, false)
	await key(KEY_F, true)
	check(not panel.is_open() and wing.medical_request.spent.is_empty() and not player.world_input_blocked and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "next distinct F closes without spend and restores gameplay")
	await key(KEY_F, true)
	check(not panel.is_open(), "held close F cannot bleed into reopening")
	await key(KEY_F, false)
	await key(KEY_F, true)
	await key(KEY_F, false)
	await key(KEY_E, true)
	check(wing.medical_request.credited.Medical == 5 and player.carried_items.get_item_count() == 0, "first E after F commits immediately with no artificial release")
	check(seeds.get_node("Medical_Bandages/WorldItem").pickup_into(player.carried_items), "real TAKE provides preview item")
	await key(KEY_E, true, true)
	await key(KEY_E, true)
	check(wing.medical_request.spent.size() == 1 and player.carried_items.get_item_count() == 1, "held/echo E cannot consume next carried item")
	await key(KEY_E, false)
	check(panel.preview_state.projected == 8 and panel.preview_state.applied == 3, "rendered 5/12 +3 previews 8/12")
	check_layout(panel)
	await capture("02-valid-preview-5-plus-3")
	root.size = Vector2i(1280, 720)
	await frames(6)
	check_layout(panel)
	await capture("02b-valid-preview-1280x720")
	root.size = Vector2i(1920, 1080)
	await frames(6)
	check(seeds.get_node("Book/WorldItem").pickup_into(player.carried_items), "real ineligible item available")
	await key(KEY_2, true)
	await key(KEY_2, false)
	check(panel.invalid_highlight and panel.status_label.text == "Selected item not eligible", "selection updates actual ineligible binding")
	var before_reject: Dictionary = player.carried_items.capture_state()
	await key(KEY_E, true)
	await key(KEY_E, false)
	check(panel.is_open() and player.carried_items.capture_state() == before_reject and wing.medical_request.credited.Medical == 5 and wing.medical_request.spent.size() == 1 and panel.pip_states.count("projected") == 0, "ineligible E preserves owners/progress and open panel")
	await capture("03-ineligible-feedback")
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel.pressed = true
	Input.parse_input_event(wheel)
	await frames(2)
	check(player.carried_items.get_selected_index() == 0 and panel.preview_state.projected == 8, "wheel updates eligible preview without submission")
	check(seeds.get_node("MedKit_A/WorldItem").pickup_into(player.carried_items), "real +8 item available")
	await key(KEY_3, true)
	await key(KEY_3, false)
	check(panel.preview_state.applied == 7 and panel.preview_state.wasted == 1, "actual selected medkit previews whole-item waste")
	await capture("04-cap-and-waste")
	await key(KEY_ESCAPE, true)
	check(not panel.is_open() and not paused and not shell.menu_open and not player.world_input_blocked and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "first ESC closes panel only and captures cursor")
	await key(KEY_ESCAPE, true, true)
	await key(KEY_ESCAPE, true)
	check(not shell.menu_open and not paused, "held/echo ESC cannot immediately open menu")
	await key(KEY_ESCAPE, false)
	await key(KEY_ESCAPE, true)
	await key(KEY_ESCAPE, false)
	check(paused and shell.menu_open, "real ESC input owns full menu pause")
	await capture("05-paused-menu")
	await key(KEY_F, true)
	await key(KEY_E, true)
	await key(KEY_ESCAPE, true)
	await key(KEY_ESCAPE, false)
	check(not paused and not shell.menu_open and not panel.is_open() and wing.medical_request.credited.Medical == 5, "menu ESC resumes without queued F/E action")
	await key(KEY_F, true)
	await key(KEY_E, true, true)
	check(not panel.is_open() and wing.medical_request.spent.size() == 1, "held F/E remain suppressed after resume")
	await key(KEY_F, false)
	await key(KEY_E, false)
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
	await frames(6)
	player.camera.look_at(wing.get_node("Environment/Greybox/Proxies/MedicalInterface").global_position)
	await key(KEY_F, true)
	await key(KEY_F, false)
	panel = wing.get_node("MedicalContribution/ContributionPanel")
	check(panel.is_open(), "continued partial request still opens via F")
	panel.panel_closed.connect(func(): check(not wing.medical_request.transaction_active, "completion releases input after transaction returns"))
	await key(KEY_E, true)
	check(wing.medical_request.closed and wing.medical_request.credited.Medical == 12 and wing.medical_request.spent.size() == 2 and wing.medical_request.spent[1].wasted == 1, "continued run closes exactly once with capped waste")
	check(not panel.is_open() and not player.world_input_blocked and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "completion closes panel and restores input/cursor")
	check(not player.medical_interface.is_targeted() and player.medical_interface.action_label.text == "MEDICAL" and not player._interaction_prompt.visible, "closed request hides world and reticle action cues")
	await key(KEY_E, true, true)
	await key(KEY_F, true)
	await key(KEY_F, false)
	check(not panel.is_open() and player.carried_items.get_item_count() == 2 and wing.medical_request.spent.size() == 2, "closed request blocks F and held E without consumption")
	await key(KEY_E, false)
	await capture("07-closed-result")
	check(shell.save_and_exit() and shell.continue_run() and shell.wing.medical_request.closed, "closed request survives Save & Exit / Continue")
	player = shell.wing.get_node("Player")
	player.set_physics_process(false)
	await frames(6)
	await key(KEY_F, true)
	await key(KEY_F, false)
	check(not player.medical_interface.panel.is_open() and not player.medical_interface.is_targeted() and player.medical_interface.action_label.text == "MEDICAL" and not player._interaction_prompt.visible and shell.wing.medical_request.result.Medical.unmet == 0, "closed Continue retains receipt with no panel or action cues")
	check(shell.start_new_run(), "New Run after closed continuation succeeds")
	await frames(3)
	check(not shell.wing.medical_request.closed and shell.wing.get_node("Player").medical_interface.action_label.text.contains("[F] Request / Contribute"), "New Run reactivates request from state")
	await check_shelf_e(shell.wing)
	shell.free()
	finish()

func check_shelf_e(wing: Node3D) -> void:
	# Use the real player, carrying, shelf and E dispatch. Freeze only automatic
	# targeting/movement so hold timing can be advanced deterministically.
	var player = wing.get_node("Player")
	player.set_process(false)
	player.set_physics_process(false)
	player.global_position = Vector3(100, 10, 100)
	var surface = wing.get_functional_surfaces()[0]
	surface.initialize_zones_if_needed("General")
	var catalogue = load("res://data/items/item_catalog.tres")
	var definition: ItemDefinition
	for candidate: ItemDefinition in catalogue.definitions:
		if candidate.item_id == &"loot_000031": definition = candidate
	if not check(definition != null, "shelf regression uses actual CD definition"):
		return
	for i: int in 3:
		check(player.carried_items.add_item(ItemInstance.new(definition, "shelf-e-" + str(i))), "shelf fixture carries actual CD")
	player._process(0.0)
	prime_shelf(player, surface)
	await key(KEY_E, true)
	check(player.carried_items.get_item_count() == 2, "ordinary E immediately stores one whole item")
	prime_shelf(player, surface)
	player._update_store_hold(0.0)
	player._update_store_hold(player.auto_store_hold_delay + player.auto_store_repeat_interval)
	check(player.carried_items.get_item_count() == 1, "held E retains reversible shelf throughput")
	player.set_world_input_blocked(true)
	player.set_world_input_blocked(false)
	prime_shelf(player, surface)
	await key(KEY_E, true)
	player._update_store_hold(5.0)
	check(player.carried_items.get_item_count() == 1, "E held across modal close cannot bleed into shelf")
	await key(KEY_E, false)
	player._process(0.0)
	prime_shelf(player, surface)
	await key(KEY_E, true)
	check(player.carried_items.get_item_count() == 0, "fresh E after release resumes shelf storage")
	await key(KEY_E, false)

func prime_shelf(player: Node3D, surface: Node3D) -> void:
	var controller = player._storage_placement
	var item: ItemInstance = player.carried_items.get_selected_item()
	var entries: Array = controller._entry_orientations_for_item(item, surface.get_semantic_orientation_quarter_turns())
	controller.set_suppressed(false)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", surface.find_zone_stack_or_empty_fit(item.get_storage_category(), entries[0], null))

func finish() -> void:
	print("M1_RENDERED_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
