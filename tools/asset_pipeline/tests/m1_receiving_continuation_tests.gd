extends SceneTree

const Snapshots = preload("res://gameplay/run/run_snapshot.gd")
var failures := 0
var checks := 0
var refreshes := 0

func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func fresh_wing() -> Node3D:
	var wing: Node3D = load(Snapshots.WING).instantiate()
	wing.configure_new_run()
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	wing.get_node("ReceivingRuntime/ReceivingLiftCycle").set_process(false)
	wing.get_node("Player/CarriedItems").max_bulk = 1000
	return wing

func round_trip(wing: Node3D, label: String) -> Node3D:
	var snapshot := Snapshots.new().capture(wing)
	var error := Snapshots.new().validate(snapshot)
	check(error.is_empty(), label + " snapshot validation: " + error)
	var codec = load("res://gameplay/run/state_codec.gd").new()
	var decoded: Dictionary = codec.parse(codec.stringify(snapshot))
	check(decoded == snapshot, label + " exact logical numeric decoding")
	wing.free()
	var restored: Node3D = load(Snapshots.WING).instantiate()
	restored.configure_continue(decoded)
	restored.get_node("Player").enable_held_item_view = false
	root.add_child(restored)
	restored.set_process(false)
	restored.get_node("Player").set_physics_process(false)
	restored.get_node("ReceivingRuntime/ReceivingLiftCycle").set_process(false)
	error = Snapshots.new().restore(restored, decoded)
	check(error.is_empty(), label + " restore: " + error)
	check(Snapshots.new().capture(restored) == snapshot, label + " owners and phase unchanged after load")
	return restored

func run() -> void:
	create_timer(60).timeout.connect(func():
		push_error("M1 Receiving helper aborted; completion missing")
		quit(3))
	var wing := fresh_wing()
	var runtime = wing.get_node("ReceivingRuntime")
	check(runtime.run_awaiting_lift_debug_delivery(4,3), "four committed returns use upstream contract")
	var cycle = runtime.lift_cycle
	cycle._process(1.2345678912345)
	for i: int in 3:
		wing = round_trip(wing, "incoming repeated %d" % i)
		runtime = wing.get_node("ReceivingRuntime")
		cycle = runtime.lift_cycle
		check(not runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(wing.get_node("Player/CarriedItems")), "incoming TAKE fails closed after load")
	var original_active: String = runtime.receiving_manager.get_active_batch_id()
	var queue: PackedStringArray = runtime.receiving_manager.get_queued_batch_ids()
	var remaining: float = cycle._phase_duration - cycle._elapsed
	cycle._process(remaining)
	cycle._process(0.73123456789)
	wing = round_trip(wing, "opening")
	runtime = wing.get_node("ReceivingRuntime")
	cycle = runtime.lift_cycle
	check(not cycle.can_take_receiving(), "opening remains gated")
	cycle._process(6.0)
	check(cycle.can_take_receiving(), "fully OPEN gate restored from actual shutter endpoint")
	var take: WorldItem = runtime.deck_presenter.get_materialized_world_items()[0]
	check(take.pickup_into(wing.get_node("Player/CarriedItems")), "real OPEN TAKE changes live cargo")
	wing = round_trip(wing, "partly unloaded OPEN")
	runtime = wing.get_node("ReceivingRuntime")
	cycle = runtime.lift_cycle
	check(runtime.deck_presenter.get_materialized_world_items().size() == 3 and cycle.can_take_receiving(), "remaining OPEN cargo resumes indefinitely")
	cycle._process(123.456)
	check(cycle.get_cycle_state() == 4, "OPEN has no deadline")
	for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		check(world.pickup_into(wing.get_node("Player/CarriedItems")), "drain through actual TAKE")
	cycle._process(1.123456789)
	wing = round_trip(wing, "closing")
	runtime = wing.get_node("ReceivingRuntime")
	cycle = runtime.lift_cycle
	check(cycle.get_cycle_state() == 5 and runtime.receiving_manager.get_active_batch_id() == original_active, "closing retains drained active ownership")
	cycle._process(cycle._phase_duration - cycle._elapsed)
	check(cycle.get_cycle_state() == 0 and cycle.is_busy(), "IDLE outbound remains busy")
	cycle._process(1.0000000123)
	for i: int in 2:
		wing = round_trip(wing, "busy outbound repeated %d" % i)
		runtime = wing.get_node("ReceivingRuntime")
		cycle = runtime.lift_cycle
		check(runtime.receiving_manager.get_active_batch_id() == original_active, "load does not retire or admit early")
	var outbound_remaining: float = cycle._phase_duration - cycle._elapsed
	cycle._process(outbound_remaining - 0.001)
	check(runtime.receiving_manager.get_active_batch_id() == original_active, "capacity retained until full logical outbound")
	cycle._process(0.00101)
	check(runtime.receiving_manager.get_active_batch_id() == queue[0] and cycle.get_cycle_state() == 1, "exactly one FIFO promotion starts next incoming")
	await process_frame
	check(runtime.receiving_manager.get_queued_batch_ids().size() == 2 and runtime.return_admission.get_awaiting_returns().is_empty(), "upstream oldest waiting admitted only after genuine capacity release")
	wing = round_trip(wing, "terminal admitted return")
	wing.free()
	wing = fresh_wing()
	runtime = wing.get_node("ReceivingRuntime")
	check(runtime.run_awaiting_lift_debug_delivery(1,0), "prepare a return with a terminal midnight disposition")
	check(runtime.return_admission.resolve_awaiting_lift_at_midnight().size() == 1, "explicit existing hook forfeits only upstream waiting cargo")
	wing = round_trip(wing, "terminal forfeited return")
	runtime = wing.get_node("ReceivingRuntime")
	check(runtime.return_admission.get_return_status("prototype_team_D") == &"FORFEITED_RETURNED" and runtime.return_admission.get_awaiting_returns().is_empty(), "forfeited commitment remains terminal after load")
	wing.free()
	# Pending prepared debug B is owned by the helper before A becomes OPEN.
	wing = fresh_wing()
	runtime = wing.get_node("ReceivingRuntime")
	check(runtime.run_two_batch_debug_delivery(0), "explicit two-batch helper prepares pending B")
	var pending_id: String = runtime._waiting_debug_batch.batch_id
	wing = round_trip(wing, "pending helper B")
	runtime = wing.get_node("ReceivingRuntime")
	cycle = runtime.lift_cycle
	cycle._process(cycle._phase_duration)
	cycle._process(6.0)
	check(runtime._waiting_debug_batch == null and runtime.receiving_manager.get_queued_batch_ids() == PackedStringArray([pending_id]), "restored helper deposits exact pending B once at A OPEN")
	wing.free()
	# Deletion in BOTH global-frame waits, then normal latest-state coalescing.
	for frames_before_delete: int in [1,2]:
		wing = fresh_wing()
		var reflections = wing.get_node("Environment/ReceivingReflections")
		reflections.request_refresh()
		for frame: int in frames_before_delete: await process_frame
		wing.free()
		for frame: int in 4: await process_frame
		check(true, "reflection owner deleted during frame wait %d without resumed freed owner" % frames_before_delete)
	wing = fresh_wing()
	var reflections = wing.get_node("Environment/ReceivingReflections")
	reflections.refresh_started.connect(func(): refreshes += 1)
	for i: int in 3: reflections.request_refresh()
	for i: int in 5: await process_frame
	reflections.request_refresh()
	await create_timer(0.5).timeout
	check(refreshes == 2 and reflections.get_node("InteriorProbe").update_mode == ReflectionProbe.UPDATE_ONCE, "coalescing preserves one probe and legitimate latest-state follow-up")
	wing.free()
	finish()

func finish() -> void:
	print("M1_RECEIVING_CONTINUATION_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
