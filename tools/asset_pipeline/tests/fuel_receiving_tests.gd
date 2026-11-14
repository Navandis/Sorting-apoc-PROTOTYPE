extends SceneTree

const Wing := preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
const Lift := ReceivingLiftCycle.State
const Kitchen := preload("res://gameplay/kitchen/kitchen_operations.gd")
const ExpeditionSeeds := preload("res://tools/asset_pipeline/tests/expedition_test_support.gd")

var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var wing := make_wing()
	if check("fuel" in wing and wing.fuel != null, "collection timeline owns and binds Fuel power"):
		test_emergency_gate(wing)
		test_crossing()
		test_crossing_after_arrival()
		test_simultaneous_boundary()
	wing.free()
	print("fuel_receiving_tests: %s (%d checks, %d failures)" % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)

func make_wing(kitchen_seed: int = -1) -> Node:
	var wing := Wing.instantiate()
	wing.configure_new_run()
	if kitchen_seed >= 0:
		wing.kitchen = Kitchen.new(wing.run_timeline.clock)
		wing.kitchen.initialize(kitchen_seed, 29)
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.set_process(false)
	return wing

func test_emergency_gate(wing: Node) -> void:
	var timeline: RefCounted = wing.run_timeline
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var cycle: ReceivingLiftCycle = runtime.lift_cycle
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	var starts: Array[float] = []
	cycle.state_changed.connect(func(state):
		if state == Lift.ARRIVAL:
			starts.append(timeline.clock.elapsed))
	timeline.advance(1770.0)
	check(wing.fuel.reserve() == 0.0 and cycle.is_emergency_mode() and not cycle.is_busy() \
		and cycle.wait_remaining() == 0.0, "120 empty seconds after depletion bank no wait")
	var first := deposit(runtime, "first")
	check(cycle.is_waiting_to_start() and cycle.wait_remaining() == 60.0 and not cycle.can_take_receiving() \
		and not cycle.get_node("Arrival").playing, "closed admitted load waits a full minute before cue or TAKE")
	var cargo: WorldItem = runtime.deck_presenter.get_materialized_world_items()[0]
	check(not cargo.pickup_into(carry), "hidden staged cargo rejects TAKE")
	timeline.advance(10.0)
	var second := deposit(runtime, "second")
	var third := deposit(runtime, "third")
	var fourth := deposit(runtime, "fourth")
	check(cycle.wait_remaining() == 50.0 and cycle.get_queued_batch_count() == 2 \
		and runtime.return_admission.get_return_status("fourth") == &"AWAITING_LIFT", "one active plus two deposits leaves fourth upstream")
	timeline.advance(10.0)
	refuel(wing, 6)
	check(cycle.wait_remaining() == 40.0 and starts.is_empty(), "below-threshold top-up preserves deadline")
	paused = true
	timeline.advance(120.0)
	check(cycle.wait_remaining() == 40.0 and wing.fuel.reserve() == 6.0, "pause holds reserve and wait")
	paused = false
	timeline.advance(39.0)
	check(cycle.wait_remaining() == 1.0 and starts.is_empty(), "no start at 59 seconds")
	timeline.advance(1.0)
	check(starts == [1830.0] and cycle.get_cycle_state() == Lift.ARRIVAL, "one ordinary ARRIVAL at the original deadline")
	timeline.advance(100.0)
	check(cycle.can_take_receiving() and runtime.receiving_manager.get_active_batch() == first,
		"emergency cycle stays OPEN while its cargo remains")
	check(cargo.pickup_into(carry) and cycle.get_cycle_state() == Lift.CLOSING, "last TAKE starts unchanged closing")
	timeline.advance(cycle.seconds_to_boundary())
	check(cycle.capture_state().departing and not cycle.is_waiting_to_start() \
		and runtime.receiving_manager.get_active_batch() == first, "full outbound retains drained cargo without starting a wait")
	var promoted_at: float = timeline.clock.elapsed + cycle.seconds_to_boundary()
	timeline.advance(cycle.seconds_to_boundary() + 7.0)
	check(runtime.receiving_manager.get_active_batch() == second and is_equal_approx(cycle.wait_remaining(), 53.0) \
		and is_equal_approx(cycle.capture_state().start_due_at, promoted_at + 60.0), "new wait starts at promotion within a large advance")
	check(runtime.receiving_manager.get_queued_batch_ids() == PackedStringArray([third.batch_id, fourth.batch_id]) \
		and runtime.return_admission.get_return_status("fourth") == &"ADMITTED_RETURNED", "completed outbound promotes FIFO and admits oldest waiting")
	timeline.advance(1980.0 - timeline.clock.elapsed)
	check(wing.fuel.reserve() == 0.0 and cycle.is_waiting_to_start(), "depletion during the next wait preserves the pending start")
	refuel(wing, 15)
	check(starts.size() == 2 and starts.back() == timeline.clock.elapsed and not cycle.is_waiting_to_start() \
		and cycle.get_cycle_state() == Lift.ARRIVAL and not cycle.is_emergency_mode(), "refuelling to exact threshold starts pending delivery exactly once")
	timeline.advance(160.0)
	check(cycle.can_take_receiving() and cycle.is_emergency_mode() and starts.size() == 2 and timeline.error.is_empty(),
		"next power loss leaves the started delivery uninterrupted")

func test_crossing() -> void:
	for step_count: int in [1, 137]:
		var wing := make_wing()
		var timeline: RefCounted = wing.run_timeline
		var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
		var cycle: ReceivingLiftCycle = runtime.lift_cycle
		timeline.advance(1200.0)
		deposit(runtime, "at-threshold")
		check(wing.fuel.reserve() == 15.0 and not cycle.is_emergency_mode() \
			and cycle.get_cycle_state() == Lift.ARRIVAL, "arrival at exact threshold starts normally")
		for index in step_count:
			timeline.advance(137.0 / step_count)
		check(is_equal_approx(timeline.clock.elapsed, 1337.0) and timeline.error.is_empty() \
			and cycle.is_emergency_mode() and cycle.can_take_receiving(), "partitioned and large advances cross during ARRIVAL and finish OPEN")
		wing.free()

func test_crossing_after_arrival() -> void:
	for phase: String in ["REVEALING", "OPEN", "CLOSING", "OUTBOUND"]:
		var wing := make_wing()
		var timeline: RefCounted = wing.run_timeline
		var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
		var cycle: ReceivingLiftCycle = runtime.lift_cycle
		var carry: CarriedItems = wing.get_node("Player/CarriedItems")
		if phase == "REVEALING":
			var arrival: AudioStreamPlayer3D = cycle.get_node("Arrival")
			var duration := arrival.stream.get_length() / arrival.pitch_scale - cycle.arrival_open_overlap_s
			timeline.advance(1199.0 - duration)
			deposit(runtime, "reveal")
			timeline.advance(cycle.seconds_to_boundary())
		else:
			timeline.advance(1099.0)
			deposit(runtime, "first")
			deposit(runtime, "next")
			timeline.advance(100.0 if phase != "OUTBOUND" else 60.0)
			if phase == "OUTBOUND":
				var closing: AudioStreamPlayer3D = cycle.get_node("Closing")
				var duration := maxf(closing.stream.get_length() / closing.pitch_scale,
					cycle.closing_motion_delay_s + cycle.closing_motion_duration_s)
				timeline.advance(1199.0 - duration - timeline.clock.elapsed)
			if phase in ["CLOSING", "OUTBOUND"]:
				var cargo: WorldItem = runtime.deck_presenter.get_materialized_world_items()[0]
				check(cargo.pickup_into(carry), "last TAKE is ordinary before crossing during " + phase)
				if phase == "OUTBOUND":
					timeline.advance(cycle.seconds_to_boundary())
		var before: Dictionary = cycle.capture_state()
		var remaining := cycle.seconds_to_boundary()
		check(not cycle.is_emergency_mode() and not cycle.is_waiting_to_start(), "cycle is committed under normal power before " + phase)
		timeline.advance(1.1)
		check(cycle.is_emergency_mode() and not cycle.is_waiting_to_start() and cycle.get_cycle_state() == before.state,
			"emergency begins without holding or restarting " + phase)
		check(remaining == INF or is_equal_approx(cycle.seconds_to_boundary(), remaining - 1.1),
			"cue and motion retain their scheduled endpoint during " + phase)
		if phase == "OUTBOUND":
			timeline.advance(cycle.seconds_to_boundary())
			check(cycle.is_waiting_to_start() and is_equal_approx(cycle.wait_remaining(), 60.0),
				"emergency wait starts only after the outbound cue finishes")
		wing.free()

func test_simultaneous_boundary() -> void:
	var rng := RandomNumberGenerator.new()
	var timing_seed := -1
	for seed in range(10000):
		rng.seed = seed
		if rng.randi_range(180, 300) == 240:
			timing_seed = seed
			break
	if not check(timing_seed >= 0, "seeded Kitchen grace can expire at the first Fuel threshold"):
		return
	var wing := make_wing(timing_seed)
	var timeline: RefCounted = wing.run_timeline
	var runtime: ReceivingRuntime = wing.get_node("ReceivingRuntime")
	var operations: RefCounted = wing.expeditions
	var cycle: ReceivingLiftCycle = runtime.lift_cycle
	var starts := [0]
	var expires := [0]
	cycle.state_changed.connect(func(state):
		if state == Lift.ARRIVAL:
			starts[0] += 1)
	wing.kitchen.notice.connect(func(message: String):
		if message.contains("grace expired"):
			expires[0] += 1)
	operations.toggle_affinity("Food")
	operations.toggle_affinity("Fuel")
	var seed_value := ExpeditionSeeds.find_seed(operations, runtime, ExpeditionSeeds.all_healthy, 27)
	var pool := ExpeditionSeeds.Acquisition.build_pool(runtime.item_catalog)
	var duration: float = ExpeditionSeeds.seeded_outcome(operations, pool, seed_value).duration
	timeline.advance(300.0 - duration)
	operations.rng.seed = seed_value
	var sent: Dictionary = operations.dispatch(operations.revision)
	check(sent.ok and operations.journeys[sent.id].return_at == 300.0, "real nonempty return shares the grace and threshold endpoint")
	timeline.advance(300.0 - timeline.clock.elapsed)
	check(starts[0] == 1 and expires[0] == 1 and operations.ready_count == 8 and wing.fuel.reserve() == 45.0 		and wing.fuel.salvager_available() and not wing.kitchen.sprint_allowed(),
		"the three owners settle once with higher-band equality and immediate handover")
	timeline.advance(0.1)
	check(starts[0] == 1 and expires[0] == 1 and not wing.fuel.salvager_available() and cycle.get_cycle_state() == Lift.ARRIVAL,
		"next positive time changes permission without replaying a boundary")
	wing.free()

func deposit(runtime: ReceivingRuntime, id: String) -> LootBatch:
	var batch := runtime.prepare_manifest(["loot_000019"], id, 4444)
	runtime.return_admission.submit_return(id, batch)
	return batch

func refuel(wing: Node, utility: int) -> void:
	var definition := ItemDefinition.new()
	definition.item_id = &"fixture"
	definition.storage_category = "Fuel"
	definition.utility_id = &"Fuel"
	definition.utility_value = utility
	definition.bulk = 1
	var item := ItemInstance.new(definition)
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	check(carry.add_item(item), "controlled Fuel top-up fits ordinary carry")
	carry.select_index(carry.get_slots().find(item))
	check(wing.fuel.contribute(carry, item, func(): return true).ok, "controlled top-up commits")

func check(condition: bool, message: String) -> bool:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)
	return condition
