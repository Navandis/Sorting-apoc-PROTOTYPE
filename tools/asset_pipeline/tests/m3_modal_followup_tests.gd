extends "res://tools/asset_pipeline/tests/m3_rendered_tests.gd"

var save_captures := false
var completed_sections := 0

func physics_frames(count: int) -> void:
	for frame: int in count: await physics_frame

func check_borders(panel: CanvasLayer, red_lanes: Array) -> void:
	for lane: String in panel.lane_rows:
		for pip: Panel in panel.lane_rows[lane].pips.get_children():
			var style: StyleBoxFlat = pip.get_theme_stylebox("panel")
			check((style.border_color == Color(1,0.25,0.22)) == red_lanes.has(lane), "rejection border belongs to " + str(red_lanes) + ": " + lane)

func check_hints(panel: CanvasLayer) -> void:
	var labels := panel.find_children("*","Label",true,false)
	check(labels.any(func(label): return label.text.contains("[E] Submit selected item")), "selected-item instruction retained")
	check(not labels.any(func(label): return label.text.contains("[ESC] Close panel")), "redundant contribution close instruction absent")
	check(panel.find_children("*","Button",true,false).any(func(button): return button.text == "[F] Close"), "contribution Close button retained")

func capture_sizes(subject: CanvasLayer, label: String) -> void:
	if not save_captures: return
	for size: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
		DisplayServer.window_set_size(size)
		await frames(5)
		if subject.get("_card") != null: check_layout(subject)
		else:
			var close: Button = subject.find_children("*","Button",true,false).filter(func(button): return button.text == "CLOSE")[0]
			check(root.get_visible_rect().encloses(close.get_global_rect()) and close.is_visible_in_tree(), "zoning CLOSE remains reachable at " + str(size))
		await capture("%s-%d" % [label,size.x])

func feedback() -> void:
	# These assertions catch a wrong fallback-lane highlight, lane redirection,
	# consumption on rejection, or recoloring committed Utility as lost credit.
	for first_lane: String in ["Food","Hydration","Medical"]:
		var medical := first_lane == "Medical"
		var request = load("res://gameplay/requests/contribution_request.gd").new("followup-preview", "medical_bay" if medical else "kitchen", {"Medical":12} if medical else {"Food":6,"Hydration":3})
		var carry = load("res://carried_items.gd").new()
		root.add_child(carry)
		var panel = load("res://gameplay/requests/contribution_panel.gd").new()
		root.add_child(panel)
		panel.configure(request,carry,func(): return true)
		panel.open_panel()
		check(not panel.invalid_highlight, "no selection is neutral")
		check_hints(panel)
		var food := ItemInstance.new(load("res://data/items/definitions/loot_000006.tres"),"preview-food")
		var hydration := ItemInstance.new(load("res://data/items/definitions/loot_000019.tres"),"preview-water")
		var selected: ItemInstance = ItemInstance.new(load("res://data/items/definitions/loot_000026.tres"),"preview-medical") if medical else food if first_lane == "Food" else hydration
		carry.add_item(selected)
		check(panel.preview_state.status == "eligible", "correct Utility previews selected lane")
		check_borders(panel,[])
		check(panel.lane_rows.keys().all(func(lane): return lane == first_lane or panel.lane_rows[lane].states.count("projected") == 0), "other lanes retain committed display")
		check(panel.lane_rows[first_lane].states.count("projected") == (3 if medical else 6 if first_lane == "Food" else 3), "only selected lane projects its exact gain")
		panel.handle_e(false,false)
		panel.handle_e(true,false)
		check(request.spent.size() == 1 and carry.get_item_count() == 0, "one real transaction retains one receipt")
		if not medical:
			selected = ItemInstance.new(selected.definition,"preview-full-lane")
			carry.add_item(selected)
			check_borders(panel,[first_lane])
			panel.handle_e(false,false)
			panel.handle_e(true,false)
			check(carry.get_selected_item() == selected and request.spent.size() == 1, "full lane rejects without spending or redirecting")
			carry.remove_item(selected)
		var wood := ItemInstance.new(load("res://data/items/definitions/loot_000013.tres"),"preview-wood")
		carry.add_item(wood)
		check_borders(panel,["Medical"] if medical else ["Food","Hydration"])
		check(panel.gain_label.text.is_empty() and panel.lane_rows.values().all(func(row): return row.states.count("projected") == 0), "ineligible item invents no projected pips")
		var committed: Panel = panel.lane_rows[first_lane].pips.get_child(0)
		check(committed.get_theme_stylebox("panel").bg_color == Color(0.26,0.62,0.42), "committed fill stays green during rejection")
		panel.handle_e(false,false)
		panel.handle_e(true,false)
		check(carry.get_selected_item() == wood and request.spent.size() == 1, "global rejection preserves exact held item and receipts")
		if first_lane == "Food": await capture_sizes(panel,"kitchen-ineligible")
		if medical: await capture_sizes(panel,"medical-ineligible")
		panel.free()
		carry.free()
	completed_sections += 1

func fresh_wing(shell: Node) -> Node:
	if not check(shell.start_new_run(), "fresh isolated M3 fixture starts"): return null
	var wing = shell.wing
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	wing.run_schedule.advance(300.0)
	return wing

func movement(shell: Node, station_name: String, close_key: int, held: bool) -> void:
	var wing = fresh_wing(shell)
	if wing == null: return
	var player = wing.get_node("Player")
	var station = wing.get_node(station_name)
	player.rotation = Vector3.ZERO
	await aim_at(player,station)
	await key(KEY_W,true)
	player.set_physics_process(true)
	await physics_frames(4)
	check(Vector2(player.velocity.x,player.velocity.z).length() > 0.1, "walking W establishes actual velocity: " + station_name)
	await key(KEY_F,true)
	await key(KEY_F,false)
	if not check(station.panel.is_open() and not paused, "walking F opens non-pausing modal: " + station_name):
		await key(KEY_W,false)
		return
	print("MODAL_MOVEMENT station=",station_name," close=",close_key," held=",held," open_velocity=",player.velocity)
	check(player.velocity == Vector3.ZERO, "opening contribution modal halts locomotion")
	if not held: await key(KEY_W,false)
	await physics_frames(3)
	var position_before: Vector3 = player.global_position
	if close_key == 0: wing.run_schedule.advance(station.request.deadline-wing.run_schedule.clock.elapsed)
	else:
		await key(close_key,true)
		await key(close_key,false)
	await physics_frames(6)
	var translation := Vector2(player.global_position.x-position_before.x,player.global_position.z-position_before.z)
	print("MODAL_RESULT input_w=",Input.is_key_pressed(KEY_W)," translation=",translation," velocity=",player.velocity)
	check(not station.panel.is_open() and not paused and not shell.menu_open, "close releases only contribution modal")
	if held: check(translation.length() > 0.001 and Vector2(player.velocity.x,player.velocity.z).length() > 0.1, "W held across close resumes responsive movement")
	else: check(translation.length() < 0.00001 and Vector2(player.velocity.x,player.velocity.z).length() < 0.00001, "released W produces zero post-close horizontal movement over six physics frames")
	check(player.camera.rotation.x == player._pitch, "modal close does not jump camera pitch")
	check(wing.run_schedule.requests.all(func(request): return request.spent.is_empty()), "movement/target changes spend no items")
	await key(KEY_W,false)
	player.set_physics_process(false)
	completed_sections += 1

func zoning(shell: Node) -> void:
	var wing = shell.wing
	var player = wing.get_node("Player")
	var editor = player._zone_editor
	var surface = wing.get_functional_surfaces()[0]
	player._open_zone_editor_for_surface(surface)
	check(paused and editor.visible and shell.pause_owners.has("zoning"), "existing zoning interaction owns pause")
	check(not editor.find_children("*","Label",true,false).any(func(label): return label.text.contains("[O / ESC] CLOSE")), "redundant zoning hint absent")
	await capture_sizes(editor,"zoning")
	await key(KEY_ESCAPE,true)
	check(not editor.visible and not shell.menu_open and not paused and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "first ESC closes zoning only and restores capture")
	await key(KEY_ESCAPE,true,true)
	check(not shell.menu_open, "ESC echo cannot open underlying menu")
	# Clean up the reproduced RED state before the next independent assertion.
	editor.close_editor()
	shell.set_menu_open(false)
	await key(KEY_ESCAPE,false)
	await key(KEY_ESCAPE,true)
	check(shell.menu_open and paused, "second distinct ESC opens Game Menu")
	await key(KEY_ESCAPE,false)
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(not shell.menu_open and not paused, "next distinct ESC resumes")
	player._open_zone_editor_for_surface(surface)
	await key(KEY_O,true)
	await key(KEY_O,false)
	check(not editor.visible and not paused, "O remains a zoning close shortcut")
	shell.request_pause("followup-owner",true)
	player._open_zone_editor_for_surface(surface)
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(not editor.visible and paused and shell.pause_owners.has("followup-owner") and not shell.menu_open and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "zoning ESC preserves independent pause and mouse ownership")
	editor.close_editor()
	shell.set_menu_open(false)
	shell.request_pause("followup-owner",false)
	player._open_zone_editor_for_surface(surface)
	editor._on_clear_all_pressed()
	await frames(2)
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(not editor._clear_confirmation.visible and editor.visible and paused and not shell.menu_open, "ESC cancels clear confirmation before closing zoning")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(not editor.visible and not paused and not shell.menu_open, "next distinct ESC closes zoning after confirmation")
	editor.close_editor()
	shell.set_menu_open(false)
	completed_sections += 1

func pause_and_restore(shell: Node) -> void:
	var wing = fresh_wing(shell)
	if wing == null: return
	var player = wing.get_node("Player")
	await aim_at(player,wing.get_node("KitchenContribution"))
	await key(KEY_W,true)
	player.set_physics_process(true)
	await physics_frames(4)
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	await key(KEY_W,false)
	var position_before: Vector3 = player.global_position
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	await physics_frames(6)
	check(Vector2(player.global_position.x-position_before.x,player.global_position.z-position_before.z).length() < 0.00001, "W released during ordinary ESC pause does not leave stale locomotion")
	player.set_physics_process(false)
	player.velocity = Vector3(1.25,-0.2,2.5)
	var snapshots = load("res://gameplay/run/run_snapshot.gd").new()
	var saved: Dictionary = snapshots.capture(wing)
	check(shell.save_service.save_snapshot(saved).ok and shell.continue_run(), "production service restores isolated saved motion state")
	wing = shell.wing
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	check(wing.get_node("Player").velocity == Vector3(1.25,-0.2,2.5), "Continue does not discard authoritative saved velocity")
	await check_shelf_e(wing)
	wing.run_schedule.advance(2550.0-wing.run_schedule.clock.elapsed)
	var report: Dictionary = wing.run_schedule.report.duplicate(true)
	shell.set_menu_open(true)
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(paused and not shell.menu_open and shell.pause_owners.has("night_report") and report == wing.run_schedule.report, "report menu ESC retains report hold and facts")
	check(shell.save_and_exit() and shell.continue_run() and paused and shell.wing.run_schedule.report == report, "report pending Continue remains exact")
	completed_sections += 1

func run() -> void:
	create_timer(150).timeout.connect(func():
		push_error("M3 modal follow-up aborted; completion missing")
		quit(3))
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--followup-evidence="): evidence_dir = arg.trim_prefix("--followup-evidence=")
		if arg == "--followup-capture": save_captures = true
	if not check(evidence_dir.is_absolute_path() and not evidence_dir.begins_with(ProjectSettings.globalize_path("res://")), "explicit external evidence/save directory required"):
		finish()
		return
	DirAccess.make_dir_recursive_absolute(evidence_dir)
	await feedback()
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new(evidence_dir.path_join("slot"))
	root.add_child(shell)
	for station_name: String in ["MedicalContribution","KitchenContribution"]:
		for close_key: int in [KEY_F,KEY_ESCAPE,0]: await movement(shell,station_name,close_key,false)
		await movement(shell,station_name,KEY_F,true)
	await zoning(shell)
	await pause_and_restore(shell)
	shell.free()
	finish()

func finish() -> void:
	paused = false
	check(completed_sections == 11,"feedback, eight movement cases, zoning and pause/restore all completed")
	check(_pending_helpers == 0,"all inherited helpers completed")
	print("M3_MODAL_FOLLOWUP_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
