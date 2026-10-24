extends "res://tools/asset_pipeline/tests/m1_rendered_tests.gd"

const OUTPUT := "C:/Users/Boschetar/.codex/attachments/m4-2026-10-24/rendered"

func send_key(code: Key, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)

func click(button: Button) -> void:
	var point := button.get_global_rect().get_center()
	print("M4_CLICK text=",button.text," point=",point," visible=",button.is_visible_in_tree()," disabled=",button.disabled)
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion,true)
	for pressed: bool in [true,false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = point
		event.global_position = point
		event.pressed = pressed
		root.push_input(event,true)
		await frames(2)

func aim(player: Node3D, station: Node) -> void:
	player.rotation = Vector3.ZERO
	player.global_position = station.proxy.global_position + Vector3(0,-station.proxy.global_position.y,1.7)
	await frames(3)
	player.camera.look_at(station.proxy.global_position)
	player._pitch = player.camera.rotation.x
	await frames(3)
	check(station.is_targeted(),"Production reach and obstruction targeting for Dispatch")

func take_definition(wing: Node, id: String) -> ItemInstance:
	for surface: StorageSurface in wing.get_functional_surfaces():
		for stack: StorageStack in surface._stacks.values():
			var entry: StorageStack.Entry = stack.entries[-1]
			if String(entry.item.definition.item_id) == id:
				var item := entry.item
				check(entry.world_item.pickup_into(wing.get_node("Player/CarriedItems")),"Real seeded TAKE: " + id)
				return item
	check(false,"Seed lacks exposed definition " + id)
	return null

func capture_panel(panel: CanvasLayer, label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	for size: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
		DisplayServer.window_set_size(size)
		await frames(6)
		var viewport := root.get_visible_rect()
		var card: Rect2 = panel._card.get_global_rect()
		print("M4_LAYOUT window=",DisplayServer.window_get_size()," logical=",viewport," scale=",panel._stage.scale," card=",card)
		var pixel_ratio: float = float(size.x)/viewport.size.x
		check(card.size.x*pixel_ratio >= 560.0,"Central card retains readable physical size at " + str(size))
		check(viewport.encloses(card),"Carousel card contained: " + str(size))
		for control: Control in panel._card.find_children("*","Control",true,false):
			if control.is_visible_in_tree(): check(card.grow(1).encloses(control.get_global_rect()),"Readable central controls within card: " + control.name)
		await capture("%s-%d" % [label,size.x])

func seed_capture(wing: Node) -> void:
	if DisplayServer.get_name() == "headless": return
	var populated: Array = wing.get_functional_surfaces().filter(func(s): return not s._stacks.is_empty())
	print("M4_SEED_SURFACES ",populated.map(func(s): return {"path":String(wing.get_path_to(s)),"stacks":s._stacks.size()}))
	var surface: StorageSurface = populated[0]
	var center := Vector3.ZERO
	var count := 0
	for source: StorageSurface in populated:
		for stack: StorageStack in source._stacks.values():
			for entry: StorageStack.Entry in stack.entries:
				center += entry.host.global_position
				count += 1
	center /= count
	var normal: Vector3 = surface.global_basis * StorageOrientation.front_local_axis(surface.get_semantic_orientation_quarter_turns())
	var camera := Camera3D.new()
	wing.add_child(camera)
	camera.global_position = center + normal.normalized()*5.2 + Vector3.UP*1.5
	camera.look_at(center)
	camera.make_current()
	DisplayServer.window_set_size(Vector2i(1920,1080))
	await capture("seed-overview-1920")
	wing.get_node("Player/Camera3D").make_current()
	camera.free()

func run() -> void:
	create_timer(600).timeout.connect(func():
		push_error("M4 integrated input/render helper incomplete")
		quit(3))
	evidence_dir = OUTPUT
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m4-evidence-dir="): evidence_dir = arg.trim_prefix("--m4-evidence-dir=")
	DirAccess.make_dir_recursive_absolute(evidence_dir)
	var shell = load("res://gameplay/run/run_shell.tscn").instantiate()
	shell.save_service = load("res://gameplay/run/run_save_service.gd").new(evidence_dir.path_join("slot"))
	root.add_child(shell)
	if not check(shell.start_new_run(),"Integrated M4 starts through production menu/save path"):
		print("M4_START_ERROR ",shell.status_label.text)
		shell.free()
		finish()
		return
	var wing = shell.wing
	wing.set_process(false)
	var player = wing.get_node("Player")
	player.set_physics_process(false)
	var station = wing.get_node("DispatchContribution")
	var panel = station.panel
	var carry: CarriedItems = player.carried_items
	await seed_capture(wing)
	take_definition(wing,"loot_000006")
	await aim(player,station)
	await key(KEY_A,true)
	await key(KEY_E,true)
	await key(KEY_F,true)
	check(panel.is_open() and not paused and player.world_input_blocked,"F opens non-pausing Dispatch at existing proxy")
	await key(KEY_F,true,true)
	await key(KEY_E,true,true)
	await key(KEY_A,true)
	check(panel.center_index == 0 and panel.request.spent.is_empty(),"Held/echoed opening F/E/A cannot close, submit or navigate")
	await key(KEY_A,false)
	await key(KEY_E,false)
	await key(KEY_F,false)
	send_key(KEY_D,true)
	send_key(KEY_E,true)
	await frames(2)
	check(panel.center_index == 1 and panel.request.spent.is_empty(),"Controller navigation rejects same-transition E")
	await create_timer(0.25).timeout
	await key(KEY_E,true)
	check(panel.request.spent.is_empty(),"Held E remains unbuffered after transition")
	await key(KEY_E,false)
	await key(KEY_E,true)
	await key(KEY_E,false)
	await key(KEY_D,false)
	check(panel.request.credited.Food == 10 and panel.request.spent.size() == 1 and carry.get_item_count() == 0,"Fresh E submits one actual selected item only to team 2")
	await capture_panel(panel,"dispatch-partial")
	await click(panel.manual_button)
	await frames(3)
	check(panel.is_open() and panel.center_index == 1 and panel.request.closed and panel.status_label.text == "Team Dispatched","Mouse manual dispatch retains centered terminal card")
	await capture_panel(panel,"dispatch-terminal")
	await click(panel.next_arrow)
	await create_timer(0.25).timeout
	check(panel.center_index == 2 and panel.request.spent.is_empty(),"Arrowhead click selects next team without provisioning")
	await click(panel.previous_card)
	await create_timer(0.25).timeout
	check(panel.center_index == 1,"Side-card click selects only that stable recipient")
	var pitch: float = player._pitch
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(80,50)
	Input.parse_input_event(motion)
	await frames(2)
	check(player._pitch == pitch,"Mouse look stays blocked while carousel is open")
	await key(KEY_ESCAPE,true)
	check(not panel.is_open() and not shell.menu_open and not paused,"ESC closes Dispatch before menu")
	await key(KEY_ESCAPE,true,true)
	check(not shell.menu_open,"ESC echo cannot open underlying menu")
	await key(KEY_ESCAPE,false)
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(shell.menu_open and paused,"Distinct ESC opens existing pause menu")
	var saved_time: float = wing.run_schedule.current_time()
	wing.run_schedule.advance(1.0)
	check(wing.run_schedule.current_time() == saved_time,"Menu pause holds authoritative time")
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	await aim(player,station)
	player.set_physics_process(true)
	await key(KEY_W,true)
	for frame: int in 4: await physics_frame
	check(Vector2(player.velocity.x,player.velocity.z).length() > 0.1,"Real W/physics establishes movement before opening")
	await key(KEY_F,true)
	await key(KEY_F,false)
	check(panel.is_open() and player.velocity == Vector3.ZERO,"Opening clears stale movement through existing station path")
	await key(KEY_W,false)
	var before: Vector3 = player.global_position
	await key(KEY_F,true)
	await key(KEY_F,false)
	for frame: int in 6: await physics_frame
	check(Vector2(player.global_position.x-before.x,player.global_position.z-before.z).length() < 0.00001,"Released W does not drift after closing")
	player.set_physics_process(false)
	# Existing zoning and independent pause ownership remain authoritative.
	var surface = wing.get_functional_surfaces()[0]
	shell.request_pause("m4-independent",true)
	player._open_zone_editor_for_surface(surface)
	await key(KEY_ESCAPE,true)
	await key(KEY_ESCAPE,false)
	check(paused and shell.pause_owners.has("m4-independent") and not player._zone_editor.visible,"Zoning ESC retains independent pause owner")
	shell.request_pause("m4-independent",false)
	# Save/Continue must retain legitimate saved velocity (opening a panel alone clears it).
	shell.set_menu_open(true)
	check(player.velocity == Vector3.ZERO,"Opening the existing menu clears walking velocity")
	# Inject legitimate saved motion after acquiring the menu hold; Save & Exit
	# otherwise deliberately clears walking when it opens that menu.
	player.velocity = Vector3(0.2,0,0.1)
	check(shell.save_and_exit() and shell.continue_run(),"Production Save & Exit and staged Continue succeed")
	wing = shell.wing
	wing.set_process(false)
	player = wing.get_node("Player")
	player.set_physics_process(false)
	print("M4_CONTINUE_VELOCITY actual=",player.velocity," distance=",player.velocity.distance_to(Vector3(0.2,0,0.1)))
	check(player.velocity == Vector3(0.2,0,0.1),"Continue preserves legitimate saved velocity")
	station = wing.get_node("DispatchContribution")
	panel = station.panel
	await aim(player,station)
	await key(KEY_F,true)
	await key(KEY_F,false)
	wing.run_schedule.advance(600.0-wing.run_schedule.current_time())
	await frames(3)
	check(not panel.is_open() and not station.is_active() and not station.action_label.text.contains("[F]"),"Cutoff closes all teams and suppresses station interaction/cue")
	wing.run_schedule.advance(2100.0)
	await frames(4)
	check(paused and shell.pause_owners.has("night_report") and shell.report_view.visible and shell.report_view.body.text.contains("Team 4"),"Midnight autosave/report presents immutable completed-day Dispatch")
	check(shell.midnight_save_status.contains("saved"),"Midnight uses successful existing save path")
	if DisplayServer.get_name() != "headless":
		for size: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
			DisplayServer.window_set_size(size)
			shell.report_view.scroll.scroll_vertical = 0
			await frames(6)
			check(root.get_visible_rect().encloses(shell.report_view.card.get_global_rect()) and shell.report_view.begin_button.is_visible_in_tree(),"Report and controls reachable at " + str(size))
			await capture("report-%d" % size.x)
			shell.report_view.scroll.scroll_vertical = 10000
			await capture("report-existing-sections-%d" % size.x)
	var report: Dictionary = wing.run_schedule.report.duplicate(true)
	var request_count: int = wing.run_schedule.requests.size()
	check(shell.save_and_exit() and shell.continue_run(),"Report-pending production Save & Exit / Continue")
	check(paused and shell.wing.run_schedule.phase == "REPORT_PENDING" and shell.wing.run_schedule.report == report,"Report continuation neither resolves nor changes results")
	await click(shell.report_view.begin_button)
	check(not paused and shell.wing.run_schedule.clock.day == 2 and shell.wing.run_schedule.requests.size() == request_count,"Begin Day releases only report hold; daily teams already activated once")
	shell.wing.set_process(false)
	shell.free()
	paused = false
	var long_carry := CarriedItems.new()
	long_carry.name = "LongBundleFixture"
	root.add_child(long_carry)
	for index: int in 15: long_carry.add_item(ItemInstance.new(load("res://data/items/definitions/loot_000001.tres"),"display-fixture:%d" % index))
	long_carry.select_index(14)
	var strip := CarriedItemsHUD.new()
	strip.carried_items_path = NodePath("../LongBundleFixture")
	root.add_child(strip)
	if DisplayServer.get_name() != "headless":
		for size: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
			DisplayServer.window_set_size(size)
			await frames(6)
			check(strip._slot_row.find_children("*","Label",true,false).any(func(label): return label.text.begins_with("#15  ")),"Fifteenth selection remains visible at " + str(size))
			for slot: Control in strip._slot_row.get_children(): check(root.get_visible_rect().encloses(slot.get_global_rect()),"Carried strip remains within viewport")
			await capture("carried-strip-15-%d" % size.x)
	strip.free()
	long_carry.free()
	finish()

func finish() -> void:
	print("M4_RENDERED_COMPLETE display=",DisplayServer.get_name()," checks=",checks," failures=",failures)
	quit(1 if failures else 0)
