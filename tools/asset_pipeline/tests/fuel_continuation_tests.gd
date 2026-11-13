extends "res://tools/asset_pipeline/tests/fuel_interaction_tests.gd"

const Codec := preload("res://gameplay/run/state_codec.gd")
const FuelConfig := preload("res://gameplay/fuel/fuel_test_config.gd")

var runtime: ReceivingRuntime
var service: RefCounted

func _run() -> void:
	create_timer(240).timeout.connect(func(): quit(3))
	open_shell("user://fuel-continuation")
	if not new_run():
		finish()
		return
	var initial := capture()
	if check(initial.schema == Snapshot.SCHEMA and initial.has("fuel"), "current collection snapshot records Fuel") and bind_saved():
		if await roundtrip("new 55/60") and await prove_wait_and_receipts():
			prove_compatibility(initial)
	finish()

func prove_wait_and_receipts() -> bool:
	timeline.advance(1770.25)
	if not check(fuel.reserve() == 0.0 and carry.get_effective_bulk_limit() == 14, "empty reserve and maximum Kitchen loss before freight"):
		return false
	var allowed := func(): return true
	var supplied := take_authored("Food_DryGoodsA")
	check(supplied != null and kitchen.contribute(carry, supplied, allowed).ok, "genuine Kitchen receipt shares the run")
	var waste := take_authored("Electronics_ComputerMouse")
	wing.incinerator.mark_warning_displayed()
	check(waste != null and wing.incinerator.incinerate(carry, waste, allowed), "genuine Incinerator receipt and warning share the run")
	var first := dispatch_fixture(runtime, ["Fuel", "Food"], 4, Vector2(214, 228), 20, true)
	var second := dispatch_fixture(runtime, ["Food", "Medical"], 1, Vector2(229, 239))
	var third := dispatch_fixture(runtime, ["Medical", "Morale"], 1, Vector2(241, 255))
	var fourth := dispatch_fixture(runtime, ["Protection", "Weapons"], 1, Vector2(257, 265))
	if [first, second, third, fourth].has(""):
		return false
	for host: String in ["Food_Bread", "Protection_Boots", "Weapons_Pistol", "CDStack_A"]:
		if not check(take_authored(host) != null and wing.expeditions.contribute(carry).ok, "real loadout keeps its terminal identity"):
			return false
	if not check(wing.expeditions.return_capacity() == 15, "whole-item loadout leaves 15 ordinary Bulk"):
		return false
	var fifth := dispatch_fixture(runtime, ["Food", "Hydration"], 1, Vector2(266, 269))
	if fifth.is_empty():
		return false
	advance_to(wing.expeditions.journeys[fifth].return_at)
	var cycle: ReceivingLiftCycle = runtime.lift_cycle
	check(cycle.is_waiting_to_start() and cycle.get_queued_batch_count() == 2 and wing.expeditions.ready_count == 6
		and wing.expeditions.journeys[fifth].status == Ops.WAITING
		and wing.expeditions.journeys[fourth].status == Ops.WAITING,
		"held start, two deposits and two upstream waiters coexist")
	var waiting := capture()
	prove_invalid_waits(waiting)
	if not await roundtrip("partway through emergency wait with full admitted capacity"):
		return false
	cycle = runtime.lift_cycle
	check(not cycle.get_node("Arrival").playing and not cycle.can_take_receiving(), "restored pending start has no cue or TAKE")
	advance_to(waiting.receiving.cycle.start_due_at)
	timeline.advance(cycle.seconds_to_boundary())
	timeline.advance(cycle.seconds_to_boundary())
	var source := runtime.receiving_manager.get_active_batch()
	var credited := ""
	while cycle.can_take_receiving() and credited.is_empty():
		var item := await take_exposed(runtime)
		if item == null:
			return false
		if item.get_utility_id() == &"Fuel" and item.get_utility_value() < 15 and not source.is_drained():
			var observed: Array[String] = []
			carry.item_removed.connect(func(_item): observed.append(Snapshot.new().validate(capture())), CONNECT_ONE_SHOT)
			var totals: Dictionary = wing.collection_goal.totals.duplicate()
			check(fuel.contribute(carry, item, allowed).ok and observed == [""] and wing.collection_goal.totals == totals,
				"receipt, reserve and exact terminal owner validate while the source is still OPEN")
			credited = item.instance_id
		elif not store_item(item):
			return false
	if not check(not credited.is_empty() and cycle.can_take_receiving(), "real Fuel receipt is from a still-OPEN source"):
		return false
	var open := capture()
	prove_invalid_receipts(open)
	if not await roundtrip("active emergency cycle and genuine Fuel/Kitchen/Incinerator/loadout histories"):
		return false
	while runtime.lift_cycle.can_take_receiving():
		var item := await take_exposed(runtime)
		if item == null or not store_item(item):
			return false
	cycle = runtime.lift_cycle
	timeline.advance(cycle.seconds_to_boundary())
	timeline.advance(cycle.seconds_to_boundary() + 3.25)
	check(runtime.receiving_manager.get_active_batch().source_ref == second and cycle.is_waiting_to_start()
		and wing.expeditions.journeys[fourth].status == Ops.COMPLETE, "retirement promotes FIFO and admits the waiting crew before next start")
	var shortened := capture()
	shortened.receiving.cycle.start_due_at = shortened.timeline.elapsed + 1.0
	check(Snapshot.new().validate(shortened).contains("deadline"),
		"an early deadline cannot count deposited time before the last complete outbound turnaround")
	if not await roundtrip("Fuel receipt after its source retired, fractional reserve and next wait"):
		return false
	var before_refill := capture()
	var top_up := take_authored("Fuel_Canister")
	check(top_up != null and fuel.contribute(carry, top_up, allowed).ok and not runtime.lift_cycle.is_waiting_to_start()
		and runtime.lift_cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL, "real refill cancels pending wait and starts exactly once")
	var forged_wait := capture()
	forced_wait_at_normal_power(forged_wait, before_refill.receiving.cycle)
	if not await roundtrip("after refill starts the waiting load"):
		return false
	var path: String = service.load_snapshot().path
	var pointer: String = service.directory.path_join(SaveService.POINTER)
	var hashes := [FileAccess.get_sha256(path), FileAccess.get_sha256(pointer)]
	write_text(service.directory.path_join(".m1-snapshot.tmp"), "isolated write blocker")
	return check(not shell.save_and_exit() and shell.wing == wing and FileAccess.get_sha256(path) == hashes[0]
		and FileAccess.get_sha256(pointer) == hashes[1] and service.load_snapshot().ok, "failed save keeps the prior valid pointer and bytes")

func forced_wait_at_normal_power(snapshot: Dictionary, waiting_cycle: Dictionary) -> void:
	snapshot.receiving.cycle = waiting_cycle
	check(Snapshot.new().validate(snapshot).contains("deadline or power"), "settled normal reserve cannot retain a pending start")

func prove_invalid_waits(valid: Dictionary) -> void:
	var early_take := valid.duplicate(true)
	for batch: Dictionary in early_take.receiving.manager.batches:
		if batch.batch_id == early_take.receiving.manager.active:
			var entry: Dictionary = batch.entries.back()
			entry.remaining_in_batch = false
			entry.released_as_base = entry.presentation_stack_index == 0
			early_take.carry.slots = [entry.item_instance_id]
			early_take.carry.selected = 0
			break
	var early_error := Snapshot.new().validate(early_take)
	check(early_error.contains("released cargo"),
		"an otherwise exactly owned item cannot leave a pending-start load: " + early_error)
	for edit: Callable in [
		func(state): state.receiving.cycle.start_due_at = state.timeline.elapsed,
		func(state): state.receiving.cycle.start_due_at = state.timeline.elapsed + 60.01,
		func(state): state.receiving.cycle.batch = state.receiving.manager.queue[0],
		func(state): state.receiving.cycle.shutter_y = 3.1416707,
		func(state): state.receiving.cycle.departing = true,
		func(state): state.receiving.cycle.state = ReceivingLiftCycle.State.OPEN,
		func(state): state.receiving.manager.queue.reverse(),
		func(state): state.receiving.cycle.start_due_at = -1.0,
	]:
		var invalid := valid.duplicate(true)
		edit.call(invalid)
		check(not Snapshot.new().validate(invalid).is_empty(), "inconsistent emergency waiting snapshot is rejected")

func prove_invalid_receipts(valid: Dictionary) -> void:
	var receipt: Dictionary = valid.fuel.receipts[0]
	var early := valid.duplicate(true)
	var team: String = early.receiving.admission.batch_teams[early.receiving.manager.active]
	var forged_at: float = early.expeditions.journeys[team].handover_at - 0.5
	early.fuel.receipts[0].at = forged_at
	early.fuel.anchor_at = forged_at
	early.fuel.reserve = FuelConfig.reserve_at(early.fuel.anchor_reserve, forged_at, early.timeline.elapsed)
	check(Snapshot.new().validate(early).contains("prior handover"),
		"arithmetically coherent generated credit before handover is rejected")
	for edit: Callable in [
		func(state): state.fuel.reserve += 1.0,
		func(state): state.fuel.anchor_reserve += 1.0,
		func(state): state.fuel.config.capacity = 90.0,
		func(state): state.fuel.receipts[0].wasted += 1.0,
		func(state): state.fuel.receipts.append(receipt.duplicate()),
		func(state): state.fuel.receipts[0].definition_id = "loot_000015",
		func(state): state.fuel.receipts[0].item_id = state.kitchen.receipts[0].item_id,
		func(state): state.fuel.receipts[0].item_id = state.expeditions.journeys.values().filter(
			func(trip: Dictionary): return not trip.loadout.spent.is_empty())[0].loadout.spent[0].item_id,
		func(state): state.incinerator.receipts.append({"item_id": receipt.item_id, "definition_id": receipt.definition_id, "at": receipt.at}),
	]:
		var invalid := valid.duplicate(true)
		edit.call(invalid)
		check(not Snapshot.new().validate(invalid).is_empty(), "forged credit or overlapping terminal disposition is rejected")

func store_item(item: ItemInstance) -> bool:
	placement.set_suppressed(false)
	for surface: StorageSurface in wing.get_functional_surfaces():
		surface.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
		if put(item, surface):
			return true
	return check(false, "ordinary storage fits the released cargo")

func open_shell(directory: String) -> void:
	service = SaveService.new(directory)
	shell = Shell.instantiate()
	shell.save_service = service
	root.add_child(shell)
	current_scene = shell
	shell.set_process(false)

func bind_saved() -> bool:
	wing = shell.wing
	wing.set_process(false)
	player = wing.get_node("Player")
	player.set_process(false)
	player.set_physics_process(false)
	carry = player.carried_items
	placement = player._storage_placement
	runtime = wing.get_node("ReceivingRuntime")
	timeline = wing.run_timeline
	kitchen = wing.kitchen
	panel = wing.kitchen_panel
	return bind_fuel()

func capture() -> Dictionary:
	return Snapshot.new().capture(wing)

func advance_to(at: float) -> void:
	timeline.advance(at - timeline.clock.elapsed)

func roundtrip(label: String) -> bool:
	var before := capture()
	if not check(shell.save_and_exit(), "Save & Exit " + label + ": " + shell.pause_status.text):
		return false
	await create_timer(0.05).timeout
	if not check(shell.continue_run(), "Continue " + label + ": " + shell.status_label.text) or not bind_saved():
		return false
	return check(before == capture() and not fuel_panel.is_open() and not panel.is_open(),
		"Continue preserves exact snapshot with panels closed: " + label)

func prove_compatibility(initial: Dictionary) -> void:
	initial.schema = 8
	initial.erase("fuel")
	initial.receiving.cycle.erase("start_due_at")
	initial.receiving.cycle.erase("last_turnaround_at")
	current_scene = null
	shell.free()
	var directory := ProjectSettings.globalize_path("user://fuel-legacy/collection")
	DirAccess.make_dir_recursive_absolute(directory)
	var old := directory.path_join("Save_kitchen.json")
	var pointer := directory.path_join(SaveService.POINTER)
	write_text(old, Codec.new().stringify(initial))
	write_text(pointer, JSON.stringify({"snapshot": old.get_file()}))
	var hashes := [FileAccess.get_sha256(old), FileAccess.get_sha256(pointer)]
	open_shell(directory)
	check(shell.continue_button.disabled and shell.status_label.text.contains("schema 8") and not shell.continue_run(),
		"schema 8 cannot Continue or initialize missing Fuel")
	shell.request_new_run()
	shell.cancel_new_run()
	check(FileAccess.get_sha256(pointer) == hashes[1], "failed Continue and canceled New Run retain schema 8 pointer")
	shell.request_new_run()
	shell.confirm_new_run()
	var loaded: Dictionary = service.load_snapshot()
	check(loaded.ok and loaded.snapshot.schema == Snapshot.SCHEMA and FileAccess.get_sha256(old) == hashes[0]
		and FileAccess.get_sha256(pointer) != hashes[1], "confirmed New Run repoints to the current schema and keeps incompatible bytes")

func write_text(path: String, data: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if check(file != null, "isolated fixture file opens"):
		file.store_string(data)
		file.close()

func finish() -> void:
	current_scene = null
	shell.free()
	print("fuel_continuation_tests: %s (%d checks, %d failures)" % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)
