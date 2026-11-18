extends SceneTree

const Shell = preload("res://gameplay/run/run_shell.tscn")
const SaveService = preload("res://gameplay/run/run_save_service.gd")
const TestSeeds = preload("res://tools/asset_pipeline/tests/expedition_test_support.gd")

var shell: Node
var wing: Node3D
var player: Node3D
var carry: CarriedItems
var panel: CanvasLayer
var timeline: RefCounted
var ops: RefCounted
var failures := 0

func _initialize() -> void:
	create_timer(150).timeout.connect(func(): quit(3))
	call_deferred("run")

func run() -> void:
	shell = Shell.instantiate()
	shell.save_service = SaveService.new("user://medical-interaction-%d" % OS.get_process_id())
	root.add_child(shell)
	shell.set_process(false)
	if check(shell.start_new_run(), "start the isolated production wing"):
		bind_wing()
		if check(panel.has_method("refresh_key_guards"), "Medical has the live contribution interaction"):
			await exercise_station()
	shell.free()
	print("medical_interaction_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)

func bind_wing() -> void:
	wing = shell.wing
	player = wing.get_node("Player")
	carry = player.carried_items
	panel = wing.medical_panel
	timeline = wing.run_timeline
	ops = wing.expeditions
	wing.set_process(false)
	player.set_process(false)
	player.set_physics_process(false)

func exercise_station() -> void:
	await aim_at_medical(3.0)
	await open_medical()
	check(not panel.is_open(), "out-of-reach frontage rejects opening")
	await aim_at_medical()
	var wrong := take_authored("Electronics_ComputerMouse")
	var bandages := take_authored("Medical_Bandages")
	var antibiotics := take_authored("Medical_Antibiotics")
	var spare := take_authored("Medical_CoughSyrup")
	if not check(wrong != null and bandages != null and antibiotics != null and spare != null, "pick up four real authored objects"):
		return
	carry.select_index(carry.get_slots().find(bandages))
	await open_medical()
	if not check(panel.is_open() and not paused and carry.get_items().has(bandages), "F opens without spending"):
		return
	await key_tap(KEY_E)
	check(carry.get_selected_item() == bandages and panel._action.text == "No patients need treatment.",
		"empty Ward preserves the selected Medical object")
	await key_tap(KEY_F)
	check(not panel.is_open(), "F closes without spending")
	carry.select_index(carry.get_slots().find(wrong))

	ops.set_members(2)
	ops.toggle_affinity("Medical")
	ops.toggle_affinity("Food")
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var seed_value := TestSeeds.find_seed(ops, runtime, func(outcome: Dictionary) -> bool:
		return outcome.originals.all(func(member: Dictionary): return member.health == "light" and not member.recruited))
	if not check(seed_value >= 0, "find genuine Light outcomes for the walkthrough"):
		return
	ops.rng.seed = seed_value
	var sent: Dictionary = ops.dispatch(ops.revision)
	if not check(sent.ok, "dispatch a normal crew for the controlled setup"):
		return
	var trip: Dictionary = ops.journeys[sent.id]
	carry.select_index(carry.get_slots().find(bandages))
	var away: Dictionary = timeline.contribute_medical(carry, bandages, player.can_reach_medical)
	check(not away.ok and carry.get_selected_item() == bandages and ops.medical.active_count() == 0,
		"injured originals still away cannot receive treatment")
	carry.select_index(carry.get_slots().find(wrong))
	timeline.advance(trip.return_at + 70.0 - timeline.clock.elapsed)
	print("MEDICAL_SETUP expedition_seed=", seed_value, " handover=", trip.handover_at, " at=", timeline.clock.elapsed)
	if not check(ops.medical.active_count() == 2 and ops.ready_count == 6, "two Light patients admitted through normal handover"):
		return
	await open_medical()
	await key_tap(KEY_E)
	check(carry.get_selected_item() == wrong and ops.medical.next_boundary_at() == trip.handover_at + 120.0,
		"a non-Medical selection cannot spend or shorten anyone's timer")
	await key_tap(KEY_2)
	check(carry.get_selected_item() == bandages, "number keys select the carried medicine in Medical")
	var stale: Dictionary = timeline.contribute_medical(carry, antibiotics, player.can_reach_medical)
	check(not stale.ok and carry.get_items().has(antibiotics), "a changed selection cannot spend the original item")
	await aim_at_medical(3.0)
	await key_tap(KEY_E)
	check(carry.get_selected_item() == bandages, "loss of actual frontage reach rejects at commit")
	await aim_at_medical()
	await key_event(KEY_E, true, true)
	check(carry.get_selected_item() == bandages, "an echoed E cannot submit")
	await key_event(KEY_E, false)
	# Preserve the held-E state across closing and opening, as in the real input path.
	await aim_at_medical(3.0)
	await key_event(KEY_E, true)
	await key_tap(KEY_F)
	await aim_at_medical()
	await open_medical()
	await key_event(KEY_E, true)
	check(carry.get_selected_item() == bandages, "opening with E already held requires release")
	await key_event(KEY_E, false)
	await key_event(KEY_E, true)
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, true)
	check(not carry.get_items().has(bandages) and carry.get_items().has(antibiotics)
		and ops.ready_count == 6 and ops.medical.next_boundary_at() == trip.handover_at + 80.0,
		"one fresh E consumes Bandages and applies 40 seconds to just one patient")
	await key_event(KEY_E, false)
	await capture_panel("01-partial")
	await key_tap(KEY_ESCAPE)
	check(not panel.is_open() and not paused, "first Escape closes Medical with the run live")
	await key_tap(KEY_ESCAPE)
	var stopped_at: float = timeline.clock.elapsed
	timeline.advance(300.0)
	check(paused and stopped_at == timeline.clock.elapsed, "the next Escape pauses all recovery")
	if not check(shell.save_and_exit() and shell.continue_run(), "Save & Exit and Continue through the production shell"):
		return
	bind_wing()
	if not check(not panel.is_open() and timeline.clock.elapsed == stopped_at and ops.ready_count == 6
			and ops.medical.next_boundary_at() == trip.handover_at + 80.0 and carry.get_item_count() == 3,
			"Continue preserves the exact shortened timer, spent item and Ready"):
		return
	await aim_at_medical()
	await open_medical()
	await key_tap(KEY_1)
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	Input.parse_input_event(wheel)
	Input.flush_buffered_events()
	await process_frame
	check(carry.get_selected_item().definition.item_id == &"loot_000025", "the wheel selects Antibiotics")
	var preview: String = panel._action.text
	var rows: String = panel._patients.text
	wing.set_process(true)
	await create_timer(1.2).timeout
	wing.set_process(false)
	check(panel._patients.text != rows and panel._action.text != preview and timeline.clock.elapsed > stopped_at,
		"the active clock updates countdowns and the waste forecast with Medical open")
	await capture_panel("02-preview-after-continue")
	var removed: Array[bool] = []
	carry.item_removed.connect(func(item: RefCounted):
		removed.append(ops.has_spent_item(item.instance_id) and ops.ready_count == 8 and ops.medical.active_count() == 0))
	await key_tap(KEY_E)
	check(removed == [true] and panel.is_open() and panel._result.text.contains("Waste")
		and panel._result.text.contains("2 Ready") and panel._action.text == "No patients need treatment.",
		"spillover returns both to Ready before item observers run and leaves the result visible")
	print("MEDICAL_FINAL ", panel._result.text, " carried=", carry.get_item_count(), " ready=", ops.ready_count)
	await key_tap(KEY_E)
	check(carry.get_item_count() == 2 and wing.collection_goal.totals.Medical == 0,
		"terminal excess is discarded and further medicine stays carried without awarding stored Utility")
	await capture_panel("03-spillover-and-waste")

func aim_at_medical(offset: float = 0.0) -> void:
	var anchor: Marker3D = wing.get_node("Environment/Greybox/Anchors/MedicalSafeSide")
	player.global_position = anchor.global_position + Vector3.BACK * offset
	player.camera.look_at(player.medical_station.global_position + Vector3.UP * 0.35)
	await physics_frame
	await physics_frame

func take_authored(host: String) -> ItemInstance:
	var world: WorldItem = wing.get_node_or_null("DevelopmentSetup/SeedItems/" + host + "/WorldItem")
	if world == null:
		return null
	var item := world.get_item_instance()
	return item if world.pickup_into(carry) else null

func open_medical() -> void:
	if DisplayServer.get_name() == "headless":
		player.medical_requested.emit()
		await process_frame
	else:
		await key_tap(KEY_F)

func key_tap(code: Key) -> void:
	await key_event(code, true)
	await key_event(code, false)

func key_event(code: Key, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await process_frame

func capture_panel(label: String) -> void:
	var directory := OS.get_environment("MEDICAL_TEST_EVIDENCE")
	if directory.is_empty() or DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(directory.path_join(label + ".png")) == OK, "native capture " + label)

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok
