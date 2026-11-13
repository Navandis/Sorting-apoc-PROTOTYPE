extends "res://tools/asset_pipeline/tests/kitchen_interaction_tests.gd"

const FuelLighting := preload("res://gameplay/fuel/fuel_lighting.gd")
const Station := "ReceivingSetDressing/CollisionProxies/ElectricalCabinetMovement"
const WorkLight := "Environment/ReceivingLighting/GeneralFixtures/G1/Light"
const WarningLight := "Environment/ReceivingLighting/WarningFixtures/W1/Fixture/WarningLight"
const Readout := "ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface"

var fuel: RefCounted
var fuel_panel: CanvasLayer

func _run() -> void:
	create_timer(240).timeout.connect(func(): quit(3))
	shell = Shell.instantiate()
	shell.save_service = SaveService.new("user://fuel-interaction")
	root.add_child(shell)
	current_scene = shell
	shell.set_process(false)
	if new_run() and bind_fuel():
		await test_station()
		if failures == 0 and DisplayServer.get_name() != "headless" and new_run() and bind_fuel():
			await recover_freight()
	finish()

func bind_fuel() -> bool:
	fuel = wing.get("fuel")
	fuel_panel = wing.get("fuel_panel")
	return check(fuel != null and fuel_panel != null and player.get("fuel_station") == wing.get_node(Station),
		"New Run binds Fuel to the right-of-shutter authored electrical cabinet")

func test_station() -> void:
	var light: Light3D = wing.get_node(WorkLight)
	var normal := light.light_energy
	var strengths := {}
	for path: String in FuelLighting.WORK_LIGHTS:
		strengths[path] = wing.get_node(path).light_energy
	var ui := wing.get_node(Readout)
	var green: Color = ui.get_node("Status").get_theme_color("font_color")
	check(fuel.reserve() == 55.0 and ui.get_node("Mode").text.contains("NORMAL"), "new reserve and normal CRT agree")
	await capture_crt("freight-normal")
	await aim_at_fuel(3.5)
	await open_fuel()
	check(not fuel_panel.is_open(), "normal reach prevents remote Fuel access")
	await aim_at_fuel()
	var blocker := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var bounds := BoxShape3D.new()
	bounds.size = Vector3(0.3, 0.3, 0.3)
	shape.shape = bounds
	blocker.add_child(shape)
	wing.add_child(blocker)
	blocker.global_position = player.camera.global_position.lerp(fuel_target(), 0.45)
	await physics_frame
	await physics_frame
	check(not player.can_reach_fuel(), "ordinary occlusion prevents a Fuel ray through a wall")
	blocker.free()
	await physics_frame
	var wrong := take_authored("Electronics_ComputerMouse")
	var first := take_authored("Fuel_Canister")
	var later := take_authored("Fuel_Firewood")
	if not check(wrong != null and first != null and later != null, "real selected items fit the ordinary carry bundle"):
		return
	var shelf: StorageSurface = wing.get_functional_surfaces()[0]
	shelf.initialize_zones_if_needed(StorageCategories.GENERAL)
	placement.set_suppressed(false)
	check(put(later, shelf) and wing.collection_goal.totals.Fuel == later.get_utility_value(),
		"placing the Fuel on a qualifying shelf counts its actual Utility")
	var stored := stored_world(shelf, later)
	check(stored != null and stored.pickup_into(carry) and wing.collection_goal.totals.Fuel == 0,
		"retrieving the Fuel removes its live score once")
	carry.select_index(carry.get_slots().find(wrong))
	await open_fuel()
	if not check(fuel_panel.is_open() and not paused and player.world_input_blocked and fuel.reserve() == 55.0,
			"F opens a live panel without spending"):
		return
	await key_tap(KEY_E)
	check(carry.get_selected_item() == wrong and fuel.reserve() == 55.0, "wrong category stays selected after rejected E")
	player.kitchen_requested.emit()
	player.dispatch_requested.emit()
	check(not panel.is_open() and not wing.dispatch_panel.is_open(), "Fuel owns service input exclusively")
	await key_tap(KEY_2)
	check(carry.get_selected_item() == first, "number selection uses the carried strip")
	await key_event(KEY_E, true)
	await key_event(KEY_E, true, true)
	await key_event(KEY_E, true)
	check(fuel.reserve() == 60.0 and not carry.get_items().has(first) and carry.get_items().has(later),
		"one fresh E caps the tank and held or echoed E preserves the next item")
	await key_event(KEY_E, false)
	await key_tap(KEY_E)
	check(carry.get_items().has(later), "fresh E at a full tank preserves the Fuel")
	timeline.advance(15.0)
	await process_frame
	check(fuel_panel._action.text.contains("0.5") and fuel_panel._action.text.contains("3.5"),
		"live panel reports fractional credit and waste")
	check(not fuel_panel._result.text.contains("Tank full"), "current headroom clears the obsolete full-tank rejection")
	check(fuel_panel._permissions.text.contains("Future"), "power permissions identify the future facilities")
	await capture_fuel("fuel-fractional")
	await key_event(KEY_E, true)
	check(fuel.reserve() == 60.0 and fuel.has_spent_item(later.instance_id) and wing.collection_goal.totals.Fuel == 0,
		"fresh E commits fractional credit without another goal debit")
	var elapsed: float = timeline.clock.elapsed
	wing.set_process(true)
	await create_timer(0.30).timeout
	wing.set_process(false)
	check(timeline.clock.elapsed > elapsed and fuel.reserve() < 60.0, "the ordinary active clock advances while Fuel is open")
	var before_pause: float = fuel.reserve()
	await key_tap(KEY_ESCAPE)
	check(not fuel_panel.is_open() and not paused and player._require_e_release and carry.get_items() == [wrong],
		"first Escape closes Fuel and requires held E to be released before ordinary storage")
	await key_event(KEY_E, false)
	await key_tap(KEY_ESCAPE)
	timeline.advance(500.0)
	check(paused and fuel.reserve() == before_pause, "second Escape pauses consumption")
	await key_tap(KEY_ESCAPE)
	for tier: Array in [[451.0, 0.835], [450.0, 0.670], [450.0, 0.500]]:
		timeline.advance(tier[0])
		for path: String in strengths:
			check(is_equal_approx(wing.get_node(path).light_energy, strengths[path] * tier[1]),
				"working light %s scales its authored strength at %s" % [path, tier[1]])
	check(wing.get_node(WarningLight).light_energy == 0.0 and ui.get_node("Mode").text.contains("EMERGENCY"),
		"low power changes CRT mode and leaves idle W1 off")
	for host: String in ["Fuel_GasCylinder", "Fuel_FirewoodPile"]:
		var item := take_authored(host)
		if not check(item != null, "authored top-up fits at the Kitchen limit"):
			return
		carry.select_index(carry.get_slots().find(item))
		await aim_at_fuel()
		await open_fuel()
		await key_tap(KEY_E)
		await key_tap(KEY_ESCAPE)
	for path: String in strengths:
		check(wing.get_node(path).light_energy == strengths[path], "authored normal intensity returns exactly: " + path)
	check(ui.get_node("Status").get_theme_color("font_color") == green,
		"refuel restores the exact authored working light and green text")
	print("FUEL_STATION path=", player.fuel_station.get_path(), " viewport=", root.size,
		" light_normal=", normal, " restored=", light.light_energy)

func recover_freight() -> void:
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var cycle: ReceivingLiftCycle = runtime.lift_cycle
	timeline.advance(1770.0)
	if not check(fuel.reserve() == 0.0 and kitchen.total_outstanding() == 105 and carry.get_effective_bulk_limit() == 14,
			"ordinary active time reaches zero Fuel and maximum Kitchen penalty"):
		return
	var first := dispatch_fixture(runtime, ["Fuel", "Food"], 4, Vector2(214, 228), 20)
	if first.is_empty():
		return
	var at: float = wing.expeditions.journeys[first].return_at
	timeline.advance(at - timeline.clock.elapsed)
	check(cycle.is_waiting_to_start() and cycle.wait_remaining() == 60.0 and wing.expeditions.ready_count == 8,
		"real return hands crew over while its freight waits")
	var due: float = cycle.capture_state().start_due_at
	await capture_crt("freight-wait")
	timeline.advance(due - timeline.clock.elapsed)
	check(cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL, "empty reserve permits the ordinary arrival cue at the deadline")
	timeline.advance(cycle.seconds_to_boundary())
	timeline.advance(cycle.seconds_to_boundary())
	if not check(cycle.can_take_receiving() and cycle.is_emergency_mode(), "emergency cargo reaches fully OPEN"):
		return
	var second := dispatch_fixture(runtime, ["Medical", "Weapons"], 1, Vector2(229, 255))
	if second.is_empty():
		return
	var second_at: float = wing.expeditions.journeys[second].return_at
	timeline.advance(second_at - timeline.clock.elapsed)
	check(cycle.can_take_receiving() and cycle.get_queued_batch_count() == 1 and wing.expeditions.ready_count == 8,
		"next crew hands over to the deposit queue while emergency cargo stays OPEN")
	var warning: OmniLight3D = wing.get_node(WarningLight)
	check(warning.visible and is_equal_approx(warning.light_energy, cycle.green_light_energy),
		"W1 keeps its OPEN intensity and meaning in emergency power")
	await capture_crt("freight-open-emergency")
	var stock: Array[StorageSurface] = []
	for shelf: Node in wing.get_functional_surfaces().slice(0, 4):
		shelf.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, shelf.grid_size - Vector2i.ONE)
		stock.append(shelf)
	var credited := 0.0
	var count := 0
	while cycle.can_take_receiving() and cycle.is_emergency_mode():
		var item := await native_take(runtime)
		if item == null:
			return
		if item.get_utility_id() != &"Fuel":
			if not store_recovery_surplus(item, stock):
				return
			continue
		await aim_at_fuel()
		await open_fuel()
		await key_tap(KEY_E)
		if not check(fuel.has_spent_item(item.instance_id) and not carry.get_items().has(item), "native E spends the exact generated Fuel"):
			return
		credited += item.get_utility_value()
		count += 1
		await key_tap(KEY_ESCAPE)
	check(credited >= 15.0 and fuel.reserve() == credited and not cycle.is_emergency_mode()
		and carry.get_effective_bulk_limit() == 14, "generated Fuel alone recovers normal freight under maximum Kitchen penalty")
	while cycle.can_take_receiving():
		var surplus := await native_take(runtime)
		if surplus == null or not store_recovery_surplus(surplus, stock):
			return
	timeline.advance(cycle.seconds_to_boundary())
	check(cycle.capture_state().departing and not cycle.is_waiting_to_start(), "recovered freight keeps the full outbound leg")
	timeline.advance(cycle.seconds_to_boundary())
	check(runtime.receiving_manager.get_active_batch().source_ref == second and not cycle.is_waiting_to_start()
		and cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL,
		"the next FIFO delivery resumes normal freight directly after turnaround")
	print("FUEL_RECOVERY generated_items=", count, " credit=", credited, " reserve=", fuel.reserve(),
		" carry_limit=", carry.get_effective_bulk_limit(), " viewport=", root.size)

func dispatch_fixture(runtime: ReceivingRuntime, affinities: Array, members: int, duration: Vector2,
		required_fuel: int = 0, needs_subthreshold_fuel: bool = false) -> String:
	var ops: RefCounted = wing.expeditions
	if not check((ops.members == members or ops.set_members(members)) and ops.toggle_affinity(affinities[0]) and ops.toggle_affinity(affinities[1]),
			"real expedition draft selects a crew and pair"):
		return ""
	var matches := func(outcome: Dictionary):
		if outcome.duration < duration.x or outcome.duration > duration.y or not TestSeeds.all_healthy(outcome):
			return false
		var utility := 0
		var subthreshold := false
		for id: String in outcome.manifest:
			var definition := PrototypeItemCatalog.get_definition_by_id(StringName(id))
			if definition.utility_id == &"Fuel":
				utility += definition.utility_value
				subthreshold = subthreshold or definition.utility_value < 15
		return utility >= required_fuel and (not needs_subthreshold_fuel or subthreshold)
	var seed_value := TestSeeds.find_seed(ops, runtime, matches)
	if not check(seed_value >= 0, "find a reproducible production manifest for the freight regression"):
		return ""
	ops.rng.seed = seed_value
	var sent: Dictionary = ops.dispatch(ops.revision, ops.return_capacity() == 0)
	check(sent.ok, "ordinary dispatch commits the generated outcome")
	print("FUEL_TRIP seed=", seed_value, " duration_range=", duration)
	return sent.get("id", "")

func take_authored(host: String) -> ItemInstance:
	var world: WorldItem = wing.get_node_or_null("DevelopmentSetup/SeedItems/" + host + "/WorldItem")
	if world == null:
		return null
	var item := world.get_item_instance()
	return item if world.pickup_into(carry) else null

func fuel_target() -> Vector3:
	return player.fuel_station.get_node("Housing").global_position

func aim_at_fuel(distance: float = 1.25) -> void:
	var target := fuel_target()
	player.global_position = Vector3(target.x + distance, 0.02, target.z)
	player.camera.look_at(target)
	await physics_frame
	await physics_frame

func open_fuel() -> void:
	if DisplayServer.get_name() == "headless":
		player.fuel_requested.emit()
	else:
		await key_tap(KEY_F)

func capture_crt(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var crt: Node3D = wing.get_node("ReceivingLiftMonitor/SM_KB3D_CPP_PropTV_A")
	player.global_position = crt.global_position + Vector3(1.1, -1.82, 0.10)
	player.camera.look_at(crt.global_position + Vector3(0.08, 0.04, 0.0))
	await capture_fuel(label)

func capture_fuel(label: String) -> void:
	var directory := OS.get_environment("FUEL_TEST_EVIDENCE")
	if DisplayServer.get_name() == "headless" or directory.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var file := "%s-%dx%d.png" % [label, root.size.x, root.size.y]
	check(root.get_texture().get_image().save_png(directory.path_join(file)) == OK, "native scene capture " + file)

func finish() -> void:
	current_scene = null
	shell.free()
	print("fuel_interaction_tests: %s (%d checks, %d failures)" % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)
