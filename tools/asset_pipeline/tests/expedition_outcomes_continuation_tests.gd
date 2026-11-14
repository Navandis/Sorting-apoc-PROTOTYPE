extends SceneTree

const Shell = preload("res://gameplay/run/run_shell.tscn")
const Snapshot = preload("res://gameplay/run/run_snapshot.gd")
const SaveService = preload("res://gameplay/run/run_save_service.gd")
const Codec = preload("res://gameplay/run/state_codec.gd")
const Ops = preload("res://gameplay/expeditions/expedition_operations.gd")
const TestSeeds = preload("res://tools/asset_pipeline/tests/expedition_test_support.gd")

var failures := 0
var shell: Node

func _initialize() -> void:
	create_timer(120).timeout.connect(func(): quit(3))
	call_deferred("run")

func run() -> void:
	check(Snapshot.SCHEMA == 11 and Snapshot.new().validate({"schema": 10}).contains("New Run"),
		"schema 10 is preserved behind the confirmed New Run boundary")
	if Snapshot.SCHEMA == 11:
		test_live_continuation()
	if is_instance_valid(shell):
		shell.free()
	print("expedition_outcomes_continuation_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)

func test_live_continuation() -> void:
	shell = Shell.instantiate()
	shell.save_service = SaveService.new("user://expedition-outcomes-test-%d" % OS.get_process_id())
	root.add_child(shell)
	if not check(shell.start_new_run(), "start an isolated production run"):
		return
	var wing: Node = shell.wing
	wing.set_process(false)
	var ops: RefCounted = wing.expeditions
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	ops.toggle_affinity("Food")
	if not roundtrip("unformed preference"):
		return
	wing = shell.wing
	ops = wing.expeditions
	carry = wing.get_node("Player/CarriedItems")
	runtime = wing.get_node("ReceivingRuntime")
	check(ops.affinities == ["Food"] and not ops.is_formed(), "Continue restores unformed affinity")
	if not check(supply(wing, carry, "Food_CerealBox") or supply_definition(wing, carry, &"loot_000007"), "take and submit authored Food"):
		return
	if not check(supply_definition(wing, carry, &"loot_000031"), "take and submit authored Morale"):
		return
	if not roundtrip("formed draft"):
		return
	wing = shell.wing
	ops = wing.expeditions
	runtime = wing.get_node("ReceivingRuntime")
	check(ops.ready_count == 7 and ops.is_formed() and ops.loadout.credited.Food == 10, "Continue restores paid draft and unavailable crew")
	ops.toggle_affinity("Weapons")
	var selected := TestSeeds.find_seed(ops, runtime, func(outcome: Dictionary):
		return outcome.originals[0].health != "healthy" and outcome.originals[0].recruited)
	if not check(selected >= 0, "find reproducible production seed with both injury and recruit"):
		return
	ops.rng.seed = selected
	var sent: Dictionary = ops.dispatch(ops.revision)
	if not check(sent.ok, "commit generated ordinary and Food bonus cargo"):
		return
	var id: String = sent.id
	var trip: Dictionary = ops.journeys[id]
	var saved := Snapshot.new().capture(wing)
	check(trip.ordinary_count > 0 and trip.ordinary_count < trip.manifest.size() and saved.expeditions.medical.is_empty(), "Away outcomes contain both portions and pending personnel")
	invalid(saved, func(s): s.expeditions.journeys[id].ordinary_count -= 1, "unfinished ordinary budget or impossible bonus count")
	invalid(saved, func(s): s.expeditions.journeys[id].ordinary_count += 1, "bonus cargo cannot be counted as ordinary")
	invalid(saved, func(s): s.expeditions.journeys[id].manifest.append("loot_000011"), "Food cannot award arbitrary extra cargo")
	invalid(saved, func(s): s.expeditions.journeys[id].duration += 0.125, "duration changes independently of commitment")
	invalid(saved, func(s): s.expeditions.journeys[id].originals.append({"health": "healthy", "recruited": true}), "newcomer cannot have a roll")
	invalid(saved, func(s): s.expeditions.journeys[id].originals[0].health = ["light", "severe"], "one severity per original")
	invalid(saved, func(s): s.expeditions.medical["future"] = {"severity": "light", "admitted_at": 0.0, "recovery_at": 120.0, "recovered": false}, "patient before handover")
	var batch_id: String = trip.batch_id
	var bonus_index: int = trip.ordinary_count
	invalid(saved, func(s): s.expeditions.away_cargo[batch_id].entries[bonus_index].item_instance_id = s.expeditions.away_cargo[batch_id].entries[0].item_instance_id, "duplicate bonus identity")
	invalid(saved, func(s): s.expeditions.away_cargo[batch_id].entries[0].erase("released_as_base"), "missing committed Receiving removal history")
	if not roundtrip("Away exact outcomes"):
		return
	wing = shell.wing
	ops = wing.expeditions
	var timeline: RefCounted = wing.run_timeline
	timeline.advance(trip.return_at - timeline.clock.elapsed)
	check(ops.journeys[id].status == Ops.COMPLETE and ops.ready_count == 8 and ops.medical.active_patients().size() == 1,
		"admission releases a recruit while injured original enters Medical")
	if not roundtrip("admitted cargo and active patient"):
		return
	wing = shell.wing
	ops = wing.expeditions
	timeline = wing.run_timeline
	var deadline: float = ops.medical.next_boundary_at()
	paused = true
	timeline.advance(30)
	paused = false
	check(timeline.clock.elapsed == trip.return_at and ops.medical.next_boundary_at() == deadline, "pause cannot advance recovery")
	timeline.advance(deadline - timeline.clock.elapsed)
	check(ops.ready_count == 9 and ops.medical.active_patients().is_empty(), "natural recovery restores original exactly once")
	saved = Snapshot.new().capture(wing)
	invalid(saved, func(s): s.expeditions.ready += 1, "duplicate recruit or recovery release")
	var patient_id: String = saved.expeditions.medical.keys()[0]
	invalid(saved, func(s):
		s.expeditions.medical[patient_id].recovered = false
		s.expeditions.ready -= 1, "a completed patient cannot become unavailable again")
	if roundtrip("completed recovery"):
		test_waiting_personnel()
		test_all_injured()
		test_mixed_cargo()

func roundtrip(label: String) -> bool:
	var before := Snapshot.new().capture(shell.wing)
	if not check(shell.save_and_exit() and shell.continue_run(), "Save & Exit and Continue: " + label + " " + shell.status_label.text):
		return false
	shell.wing.set_process(false)
	var after := Snapshot.new().capture(shell.wing)
	var codec := Codec.new()
	return check(codec.stringify(before.expeditions) == codec.stringify(after.expeditions), "exact Expedition state: " + label)

func test_waiting_personnel() -> void:
	var wing: Node = shell.wing
	var ops: RefCounted = wing.expeditions
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var timeline: RefCounted = wing.run_timeline
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	# The admitted first expedition from the preceding proof occupies the
	# active lift. Fill its two deposited slots with genuine seeded returns.
	for pair: Array in [["Food", "Medical"], ["Protection", "Weapons"]]:
		ops.toggle_affinity(pair[0])
		ops.toggle_affinity(pair[1])
		ops.rng.seed = TestSeeds.find_seed(ops, runtime, TestSeeds.all_healthy)
		if not check(ops.dispatch(ops.revision).ok, "dispatch a future deposited load"):
			return
	while is_finite(ops.next_return_at()):
		timeline.advance(ops.next_return_at() - timeline.clock.elapsed)
	if not check(runtime.lift_cycle.get_queued_batch_count() == 2 and supply(wing, carry, "CDStack_B"),
			"both deposited slots fill and the next crew receives Morale"):
		return
	ops.toggle_affinity("Food")
	ops.toggle_affinity("Weapons")
	ops.rng.seed = TestSeeds.find_seed(ops, runtime, func(outcome: Dictionary):
		return outcome.originals[0].health != "healthy" and outcome.originals[0].recruited)
	var sent: Dictionary = ops.dispatch(ops.revision)
	if not check(sent.ok, "dispatch a crew with an injured original and a recruit"):
		return
	var id: String = sent.id
	var trip: Dictionary = ops.journeys[id]
	var ready: int = ops.ready_count
	timeline.advance(trip.return_at - timeline.clock.elapsed + 301.0)
	check(trip.status == Ops.WAITING and trip.handover_at == -1.0 and not ops.destination_busy(trip.destination)
		and ops.medical.active_count() == 0 and ops.ready_count == ready, "waiting longer than recovery time releases neither person")
	if not roundtrip("Awaiting Lift with an injured original and a pending recruit"):
		return
	wing = shell.wing
	ops = wing.expeditions
	runtime = wing.get_node("ReceivingRuntime")
	timeline = wing.run_timeline
	carry = wing.get_node("Player/CarriedItems")
	var shelf: StorageSurface = wing.get_functional_surfaces()[1]
	shelf.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, shelf.grid_size - Vector2i.ONE)
	var placement: StoragePlacementController = wing.get_node("Player")._storage_placement
	placement.set_suppressed(false)
	for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		var item := world.get_item_instance()
		if not check(world.pickup_into(carry), "release an item from the active lift"):
			return
		carry.select_index(carry.get_slots().find(item))
		placement._current_surface = shelf
		if not check(placement.place_selected(), "store released cargo to make room"):
			return
	for phase in 2:
		timeline.advance(runtime.lift_cycle.seconds_to_boundary())
	trip = ops.journeys[id]
	check(trip.status == Ops.COMPLETE and ops.ready_count == ready + 1 and ops.medical.active_count() == 1
		and ops.medical.next_boundary_at() > trip.handover_at and trip.handover_at > trip.return_at + 300.0,
		"oldest admission releases the recruit and starts fresh natural recovery at handover")

func test_all_injured() -> void:
	if not check(shell.start_new_run(), "start separate all-injured boundary"):
		return
	var wing: Node = shell.wing
	wing.set_process(false)
	var ops: RefCounted = wing.expeditions
	var timeline: RefCounted = wing.run_timeline
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	timeline.advance(1770.0)
	for pair: Array in [["Food", "Weapons"], ["Fuel", "Medical"]]:
		ops.set_members(4)
		ops.toggle_affinity(pair[0])
		ops.toggle_affinity(pair[1])
		var seed_value := TestSeeds.find_seed(ops, runtime, func(outcome: Dictionary):
			return outcome.originals.all(func(member: Dictionary): return member.health != "healthy"))
		if not check(seed_value >= 0, "find an all-injured production crew"):
			return
		ops.rng.seed = seed_value
		if not check(ops.dispatch(ops.revision).ok, "dispatch all-injured production fixture"):
			return
	while is_finite(ops.next_return_at()):
		timeline.advance(ops.next_return_at() - timeline.clock.elapsed)
	check(ops.ready_count == 0 and ops.medical.active_count() == 8 and not ops.can_prepare_crew()
		and wing.fuel.reserve() == 0.0, "all eight originals can be in Medical with no Ready or Fuel")
	if not roundtrip("all originals recovering"):
		return
	wing = shell.wing
	ops = wing.expeditions
	timeline = wing.run_timeline
	var deadline: float = ops.medical.next_boundary_at()
	timeline.advance(deadline - timeline.clock.elapsed)
	check(ops.ready_count > 0 and ops.can_prepare_crew() and wing.fuel.reserve() == 0.0,
		"natural recovery restores dispatchability without supplies")
	timeline.advance(300)
	check(ops.ready_count == 8 and ops.medical.active_count() == 0 and timeline.error.is_empty(),
		"the full starting population recovers through active-time boundaries")

func test_mixed_cargo() -> void:
	if not check(shell.start_new_run(), "start separate mixed-cargo continuation"):
		return
	var wing: Node = shell.wing
	wing.set_process(false)
	var ops: RefCounted = wing.expeditions
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var timeline: RefCounted = wing.run_timeline
	ops.set_members(4)
	ops.toggle_affinity("Medical")
	ops.toggle_affinity("Protection")
	var pool := TestSeeds.Acquisition.build_pool(runtime.item_catalog)
	var seed_value := -1
	var mixed: Array[String] = []
	for candidate in 200:
		var outcome := TestSeeds.seeded_outcome(ops, pool, candidate)
		var prepared := runtime._prepare_exact_manifest(outcome.manifest, "mixed-witness", outcome.presentation_seed, "mixed-witness", false)
		if prepared == null:
			continue
		mixed = mixed_stack(prepared)
		if not mixed.is_empty():
			seed_value = candidate
			break
	if not check(seed_value >= 0, "find reproducible production mixed stack"):
		return
	ops.rng.seed = seed_value
	var sent: Dictionary = ops.dispatch(ops.revision)
	if not check(sent.ok, "Dispatch commits the exact generated mixed cargo"):
		return
	var trip: Dictionary = ops.journeys[sent.id]
	timeline.advance(trip.return_at - timeline.clock.elapsed + 50.0)
	var batch := runtime.receiving_manager.get_active_batch()
	if not check(batch != null and runtime.lift_cycle.can_take_receiving(), "mixed cargo reaches OPEN"):
		return
	mixed = mixed_stack(batch)
	if not check(mixed.size() == 2, "active batch contains a base and cap from different definitions"):
		return
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	var base: WorldItem
	var cap: WorldItem
	for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		if world.get_item_instance().instance_id == mixed[0]:
			base = world
		elif world.get_item_instance().instance_id == mixed[1]:
			cap = world
	if not check(base != null and cap != null and base.pickup_into(carry)
			and cap.get_storage_stack_id() == mixed[1], "production TAKE promotes the surviving mixed-stack cap"):
		return
	var saved := Snapshot.new().capture(wing)
	for index in batch.entries.size():
		if batch.entries[index].item_instance_id == mixed[0]:
			invalid(saved, func(s): s.receiving.manager.batches[0].entries[index].released_as_base = false,
				"corrupted mixed-stack base removal")
	var exact := roundtrip("partially unloaded mixed stack")
	check(exact and Snapshot.new().capture(shell.wing) == saved, "schema 11 restores live, stored and released cargo identities together")
	print("EXPEDITION_MIXED_CONTINUE seed=", seed_value, " base=", mixed[0], " cap=", mixed[1], " exact=", exact)

func mixed_stack(batch: LootBatch) -> Array[String]:
	var groups := {}
	for entry: LootBatchEntry in batch.entries:
		var key := entry.presentation_stack_group_id
		if not groups.has(key):
			groups[key] = []
		groups[key].append(entry)
	for group: Array in groups.values():
		if group.size() == 2 and group[0].definition_id != group[1].definition_id:
			group.sort_custom(func(a: LootBatchEntry, b: LootBatchEntry): return a.presentation_stack_index < b.presentation_stack_index)
			return [group[0].item_instance_id, group[1].item_instance_id]
	return []

func supply_definition(wing: Node, carry: CarriedItems, id: StringName) -> bool:
	for host: Node in wing.get_node("DevelopmentSetup/SeedItems").get_children():
		if host.get("item_id") == id and host.has_node("WorldItem"):
			return supply(wing, carry, host.name)
	return false

func supply(wing: Node, carry: CarriedItems, host: String) -> bool:
	var world := wing.get_node_or_null("DevelopmentSetup/SeedItems/" + host + "/WorldItem") as WorldItem
	if world == null:
		return false
	var item := world.get_item_instance()
	if not world.pickup_into(carry):
		return false
	carry.select_index(carry.get_slots().find(item))
	return wing.expeditions.contribute(carry).ok

func invalid(valid: Dictionary, mutate: Callable, label: String) -> void:
	var broken := valid.duplicate(true)
	mutate.call(broken)
	check(not Snapshot.new().validate(broken).is_empty(), "reject " + label)

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok
