extends "res://tools/asset_pipeline/tests/expedition_physical_tests.gd"

const WarningText := "Incinerated items are permanently destroyed! This is a one-time warning."
const MachinePath := "Environment/Greybox/Proxies/IncineratorMachine/StaticBody3D"

var panel: CanvasLayer
var checks := 0

func _run() -> void:
	create_timer(120).timeout.connect(func(): quit(3))
	var saves := OS.get_temp_dir().path_join("incinerator-interaction-" + Crypto.new().generate_random_bytes(8).hex_encode())
	shell = Shell.instantiate()
	shell.save_service = SaveService.new(saves)
	root.add_child(shell)
	current_scene = shell
	shell.set_process(false)
	if not await new_run():
		finish()
		return

	var station: StaticBody3D = wing.get_node(MachinePath)
	player.global_position = Vector3(32.6, 0.02, 13.3)
	player.camera.look_at(Vector3(station.global_position.x, player.camera.global_position.y, 13.3))
	await open_station()
	check(not panel.is_open(), "the authored west wall blocks Incinerator access")
	var front: Marker3D = wing.get_node("Environment/Greybox/Anchors/IncineratorFront")
	player.global_position = front.global_position + Vector3(1.15, 0, -2.6)
	player.rotation.y = PI
	player.camera.rotation = Vector3.ZERO
	player._pitch = 0.0
	await open_station()
	check(not panel.is_open(), "F is out of reach at the start of the approach")
	if DisplayServer.get_name() != "headless":
		var start: float = player.global_position.z
		player.set_physics_process(true)
		await key_event(KEY_W, true)
		var deadline := Time.get_ticks_msec() + 2200
		while player.global_position.z < start + 1.4 and Time.get_ticks_msec() < deadline:
			await physics_frame
		await key_event(KEY_W, false)
		player.set_physics_process(false)
		player._update_interaction_target()
		check(player.global_position.z > start + 1.0 and player._interaction_prompt.text == "[F] OPEN INCINERATOR",
			"native W approach reaches the authored front and shows the F cue")
		print("INCINERATOR_NATIVE viewport=", root.size, " approach_m=", player.global_position.z - start)
		await capture_render("incinerator-front")
	else:
		player.global_position = front.global_position
		player.camera.look_at(station.global_position)

	check(player.can_reach_incinerator(), "the ordinary ray reaches the machine from the front")
	await open_station()
	if not check(panel.is_open() and player.world_input_blocked and not paused, "F opens a live service panel"):
		finish()
		return
	await key_tap(KEY_E)
	check(not panel._warning.visible and not wing.incinerator.warning_shown, "empty E does not use the warning")
	await key_event(KEY_F, true)
	await key_event(KEY_F, true)
	check(not panel.is_open(), "holding F to close cannot reopen the panel")
	await key_event(KEY_F, false)
	var first := take_seed("Food_DryGoodsA")
	var second := take_seed("Hydration_FoodCan")
	check(first != null and second != null, "normal pickup supplies two authored items")
	var ops: RefCounted = wing.expeditions
	ops.rng.seed = 9100
	ops.toggle_affinity("Electronics")
	ops.toggle_affinity("Food")
	check(ops.dispatch(ops.revision).ok, "a real expedition leaves before the live panel check")
	var id: String = ops.journeys.keys()[0]
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var timeline: RefCounted = wing.run_timeline
	timeline.advance(ops.journeys[id].return_at - timeline.clock.elapsed - 0.15)

	await key_event(KEY_E, true)
	await open_station()
	check(panel.is_open() and carry.get_item_count() == 2 and not wing.incinerator.warning_shown,
		"opening with E already held neither destroys nor shows a warning")
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, false)
	await key_tap(KEY_2)
	check(carry.get_selected_item() == second and panel._item.text.contains(second.get_display_name())
		and panel._item.text.contains(second.get_storage_category()) and panel._item.text.contains(second.utility_text())
		and panel._item.text.contains(str(second.get_bulk())), "ordinary selection updates the item name, category, Utility and Bulk")
	check(panel._action.text.contains("permanently destroy") and panel._action.modulate.r > panel._action.modulate.g,
		"explicit red destructive action stays legible on the panel")
	await capture_render("incinerator-panel")
	player.dispatch_requested.emit()
	check(not wing.dispatch_panel.is_open(), "Dispatch cannot open behind Incinerator")

	await key_event(KEY_E, true)
	check(panel._warning.visible and panel._warning_text.text == WarningText and wing.incinerator.warning_shown,
		"first valid E displays the exact warning and marks it shown")
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, true)
	await key_tap(KEY_1)
	check(carry.get_item_count() == 2 and carry.get_selected_item() == second, "warning blocks held E and underlying selection")
	await capture_render("incinerator-warning")
	var before: float = timeline.clock.elapsed
	wing.set_process(true)
	await create_timer(0.85).timeout
	wing.set_process(false)
	check(timeline.clock.elapsed > before + 0.2 and ops.journeys[id].status == Ops.COMPLETE
		and runtime.lift_cycle.capture_state().elapsed > 0.0, "real time, expedition handover and lift advance under the warning")
	await press_button(panel._back_button)
	check(panel.is_open() and not panel._warning.visible and carry.get_items().has(second)
		and wing.incinerator.warning_shown, "Back consumes the warning and retains the item")
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, true)
	check(carry.get_items().has(second), "E held through Back cannot spend")
	await key_event(KEY_E, false)
	await key_event(KEY_E, true)
	check(carry.get_items() == [first] and not panel._warning.visible and ops.loadout.spent.is_empty(),
		"next distinct E destroys just the selected item and gives no loadout credit")
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, false)
	check(carry.get_items() == [first], "holding E after success does not destroy the next selection")

	if not await new_run():
		finish()
		return
	first = take_seed("Food_DryGoodsA")
	second = take_seed("Hydration_FoodCan")
	await aim_front_and_open()
	var native := DisplayServer.get_name() != "headless"
	if native:
		await key_event(KEY_ENTER, true)
	await key_tap(KEY_E)
	carry.select_index(1) # An external selection change simulates a stale confirmation.
	if native:
		await key_tap(KEY_TAB)
		check(root.gui_get_focus_owner() == panel._continue_button, "normal keyboard navigation can focus Continue")
		await key_event(KEY_ENTER, true, true)
		await key_event(KEY_ENTER, false)
		check(panel._warning.visible and carry.get_item_count() == 2, "Enter held across warning display cannot activate Continue")
		await key_tap(KEY_ENTER)
	else:
		await press_button(panel._continue_button)
	check(not panel._warning.visible and carry.get_items() == [first, second]
		and wing.incinerator.capture_state().receipts.is_empty(), "Continue rejects a stale exact-item command")
	await key_tap(KEY_ESCAPE)
	var dispatch: StaticBody3D = player.dispatch_station
	player.global_position = dispatch.global_position + Vector3(0, -dispatch.global_position.y + 0.02, 1.5)
	player.camera.look_at(dispatch.global_position)
	await open_dispatch()
	player.incinerator_requested.emit()
	check(wing.dispatch_panel.is_open() and not panel.is_open(), "ordinary Dispatch opens and excludes Incinerator")
	carry.select_index(0)
	await key_tap(KEY_E)
	check(wing.expeditions.loadout.spent.size() == 1 and wing.incinerator.capture_state().receipts.is_empty(),
		"ordinary Dispatch E still contributes to its own receipt collection")

	if not await new_run():
		finish()
		return
	first = take_seed("Food_DryGoodsA")
	second = take_seed("Hydration_FoodCan")
	await aim_front_and_open()
	await key_event(KEY_E, true)
	await press_button(panel._continue_button)
	await key_event(KEY_E, true)
	check(carry.get_items() == [second] and panel.is_open() and not panel._warning.visible,
		"separate Continue destroys the original once and held opening E cannot replay")
	if native:
		await prove_storage_release(second)
	else:
		await key_event(KEY_E, false)

	if not await new_run():
		finish()
		return
	first = take_seed("Food_DryGoodsA")
	await aim_front_and_open()
	await key_tap(KEY_E)
	await key_event(KEY_ESCAPE, true)
	await key_event(KEY_ESCAPE, true, true)
	check(panel.is_open() and not panel._warning.visible and not paused and carry.get_items() == [first],
		"first Escape backs out of warning without spending or pausing")
	await key_event(KEY_ESCAPE, false)
	await key_tap(KEY_ESCAPE)
	check(not panel.is_open() and not paused, "second Escape closes only the panel")
	await key_tap(KEY_ESCAPE)
	var before_pause: float = wing.run_timeline.clock.elapsed
	wing.set_process(true)
	await key_event(KEY_E, true)
	await create_timer(0.2).timeout
	check(shell.menu_open and paused and wing.run_timeline.clock.elapsed == before_pause, "third Escape freezes the active timeline")
	await key_tap(KEY_ESCAPE)
	await open_station()
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, false)
	check(panel.is_open() and carry.get_items() == [first] and not paused,
		"resuming and reopening while E is held does not replay it")
	finish()

func prove_storage_release(item: ItemInstance) -> void:
	await key_tap(KEY_ESCAPE)
	var shelf: StorageSurface = wing.get_functional_surfaces()[1]
	shelf.initialize_zones_if_needed(StorageCategories.GENERAL)
	var at := shelf.global_position
	var reachable := false
	for outward: Vector3 in [Vector3.BACK, Vector3.FORWARD, Vector3.RIGHT, Vector3.LEFT]:
		player.global_position = Vector3(at.x, 0.04, at.z) + outward
		player.camera.look_at(at)
		if player._get_looked_at_storage_surface() == shelf:
			reachable = true
			break
	if not check(reachable, "native probe aims at a reachable ordinary shelf"):
		await key_event(KEY_E, false)
		return
	player.set_process(true)
	await create_timer(0.65).timeout
	check(carry.get_items() == [item] and shelf.get_stored_items().is_empty(),
		"held E through panel close cannot enter the ordinary auto-store loop")
	await key_event(KEY_E, false)
	await key_tap(KEY_E)
	if check(shelf.get_stored_items().has(item), "a fresh ordinary E places on the shelf"):
		var world := stored_world(shelf, item)
		await physics_frame
		await physics_frame
		var pickup_shape: CollisionShape3D = world.get_node("PickupArea/PickupShape")
		var pickup_at := pickup_shape.global_position
		player.camera.look_at(pickup_at)
		# Auto placement may choose a cell away from the original viewing side.
		for outward: Vector3 in [Vector3.BACK, Vector3.FORWARD, Vector3.RIGHT, Vector3.LEFT]:
			if player._get_looked_at_world_item() == world:
				break
			var stance := Vector3(pickup_at.x, 0.04, pickup_at.z) + outward
			if not player.test_move(Transform3D(Basis.IDENTITY, stance), Vector3.ZERO, null, 0.001, true):
				player.global_position = stance
				player.camera.look_at(pickup_at)
		if check(player._get_looked_at_world_item() == world, "ordinary reticle reaches the placed item"):
			await mouse_take()
			check(carry.get_items() == [item], "native mouse TAKE retrieves the exact stored item")
	player.set_process(false)

func new_run() -> bool:
	if not check(shell.start_new_run(), "isolated New Run starts: " + shell.status_label.text):
		return false
	wing = shell.wing
	if not check("incinerator_panel" in wing and wing.incinerator_panel != null, "New Run binds the existing Incinerator"):
		return false
	panel = wing.incinerator_panel
	player = wing.get_node("Player")
	carry = player.carried_items
	placement = player._storage_placement
	player.set_process(false)
	player.set_physics_process(false)
	wing.set_process(false)
	await physics_frame
	await physics_frame
	return true

func aim_front_and_open() -> void:
	player.global_position = wing.get_node("Environment/Greybox/Anchors/IncineratorFront").global_position
	player.camera.look_at(wing.get_node(MachinePath).global_position)
	await open_station()

func open_station() -> void:
	if DisplayServer.get_name() == "headless":
		# The dummy display cannot capture the mouse. The wing still checks the station ray.
		player.incinerator_requested.emit()
	else:
		await key_tap(KEY_F)

func take_seed(host: String) -> ItemInstance:
	var world: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/" + host + "/WorldItem")
	var item := world.get_item_instance()
	return item if world.pickup_into(carry) else null

func press_button(button: Button) -> void:
	if DisplayServer.get_name() == "headless":
		button.pressed.emit()
		return
	await process_frame
	var center := button.get_global_rect().get_center()
	for pressed in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = center
		click.global_position = center
		click.pressed = pressed
		root.push_input(click, true)
		await process_frame

func check(ok: bool, message: String) -> bool:
	checks += 1
	return super.check(ok, message)

func finish() -> void:
	current_scene = null
	shell.free()
	print("incinerator_interaction_tests: ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(0 if failures == 0 else 1)
