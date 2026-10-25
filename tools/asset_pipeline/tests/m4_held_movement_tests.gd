extends "res://tools/asset_pipeline/tests/m4_rendered_tests.gd"

func run() -> void:
	create_timer(120).timeout.connect(func():
		push_error("M4 held movement helper incomplete")
		quit(3))
	var slot := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m4-slot="): slot = arg.trim_prefix("--m4-slot=")
		if arg.begins_with("--m4-evidence-dir="): evidence_dir = arg.trim_prefix("--m4-evidence-dir=")
	if not check(slot.is_absolute_path() and evidence_dir.is_absolute_path(),"Explicit external slot/evidence required"):
		finish()
		return
	DirAccess.make_dir_recursive_absolute(evidence_dir)
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new(slot)
	root.add_child(shell)
	var first_draw := [false]
	shell.report_view.first_frame.connect(func():
		first_draw[0] = true
		var view = shell.report_view
		var bounds: Rect2 = root.get_visible_rect()
		check(bounds.encloses(view.card.get_global_rect()) and bounds.encloses(view.begin_button.get_global_rect()) and bounds.encloses(view.save_status.get_global_rect()),"Fresh Continue fixed report controls fit on first rendered frame")
		check(view.tabs.current_tab == 0 and view.tabs.get_tab_count() == 3,"Fresh Continue defaults to Expeditions")
		print("M4_FIRST_DRAW window=",root.size," bounds=",bounds," card=",view.card.get_global_rect()," begin=",view.begin_button.get_global_rect())
		check(root.get_texture().get_image().save_png(evidence_dir.path_join("fresh-continue-first-frame-1280.png")) == OK,"First rendered frame captured")
	,CONNECT_ONE_SHOT)
	if not check(shell.continue_run(),"Continue isolated M4 fixture for held movement"):
		shell.free()
		finish()
		return
	await frames(6)
	check(first_draw[0],"Fresh separate-process report actually rendered")
	var view = shell.report_view
	print("M4_FRESH_REPORT window=",root.size," logical=",root.get_visible_rect()," card=",view.card.get_global_rect()," size=",view.card.size," min=",view.card.get_combined_minimum_size()," scale=",view.card.scale," body=",view.body.size," body_min=",view.body.get_combined_minimum_size()," scroll=",view.scroll.size," begin=",view.begin_button.get_global_rect())
	if not check(root.get_visible_rect().encloses(view.card.get_global_rect()) and root.get_visible_rect().encloses(view.begin_button.get_global_rect()),"Fresh 1280 Continue report and Begin Day fit after initial layout"):
		shell.free()
		paused = false
		finish()
		return
	var snapshot_before: Dictionary = load("res://gameplay/run/run_snapshot.gd").new().capture(shell.wing)
	for index: int in [1,2,0]:
		view.tabs.current_tab = index
		await frames(2)
	check(load("res://gameplay/run/run_snapshot.gd").new().capture(shell.wing) == snapshot_before and paused,"Fresh report tabs retain exact gameplay snapshot and pause")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(shell.menu_open and shell.pause_owners.has("night_report"),"Fresh report ESC preserves report hold under menu")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	if shell.wing.run_schedule.phase == "REPORT_PENDING": await click(shell.report_view.begin_button)
	var accepted: Dictionary = shell.wing.run_schedule.capture_state()
	shell.begin_next_day()
	check(shell.wing.run_schedule.capture_state() == accepted,"Repeated Begin Day cannot resolve or instantiate twice")
	check(not paused,"Report hold releases before the movement test")
	var wing = shell.wing
	wing.set_process(false)
	var player = wing.get_node("Player")
	player.set_physics_process(false)
	var station = wing.get_node("DispatchContribution")
	await aim(player,station)
	await key(KEY_F,false)
	player.set_physics_process(true)
	await key(KEY_W,true)
	for frame: int in 4: await physics_frame
	check(Vector2(player.velocity.x,player.velocity.z).length() > 0.1,"Held W establishes real velocity")
	await key(KEY_F,true)
	await key(KEY_F,false)
	check(station.panel.is_open() and player.velocity == Vector3.ZERO,"Opening Dispatch halts held-W movement")
	var before: Vector3 = player.global_position
	for frame: int in 4: await physics_frame
	check(player.global_position.is_equal_approx(before),"Open carousel blocks physics movement while W remains held")
	await key(KEY_F,true)
	await key(KEY_F,false)
	for frame: int in 6: await physics_frame
	check(not station.panel.is_open() and Vector2(player.global_position.x-before.x,player.global_position.z-before.z).length() > 0.001 and Vector2(player.velocity.x,player.velocity.z).length() > 0.1,"W held across close resumes legitimate movement")
	await key(KEY_W,false)
	shell.free()
	paused = false
	finish()

func finish() -> void:
	print("M4_HELD_MOVEMENT_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
