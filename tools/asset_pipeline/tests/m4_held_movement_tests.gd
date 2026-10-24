extends "res://tools/asset_pipeline/tests/m4_rendered_tests.gd"

func run() -> void:
	create_timer(120).timeout.connect(func():
		push_error("M4 held movement helper incomplete")
		quit(3))
	# Read the already-verified isolated continuation. Never touch the player's slot.
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new("C:/Users/Boschetar/.codex/attachments/m4-2026-10-24/native-final/slot")
	root.add_child(shell)
	if not check(shell.continue_run(),"Continue isolated M4 fixture for held movement"):
		shell.free()
		finish()
		return
	await frames(6) # Newly created report controls must complete their first layout before a pointer event.
	var view = shell.report_view
	print("M4_FRESH_REPORT window=",root.size," logical=",root.get_visible_rect()," card=",view.card.get_global_rect()," size=",view.card.size," min=",view.card.get_combined_minimum_size()," scale=",view.card.scale," body=",view.body.size," body_min=",view.body.get_combined_minimum_size()," scroll=",view.scroll.size," begin=",view.begin_button.get_global_rect())
	if not check(root.get_visible_rect().encloses(view.card.get_global_rect()) and root.get_visible_rect().encloses(view.begin_button.get_global_rect()),"Fresh 1280 Continue report and Begin Day fit after initial layout"):
		shell.free()
		paused = false
		finish()
		return
	if shell.wing.run_schedule.phase == "REPORT_PENDING": await click(shell.report_view.begin_button)
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
