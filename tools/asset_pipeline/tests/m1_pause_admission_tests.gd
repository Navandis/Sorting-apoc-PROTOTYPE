extends SceneTree
var failures := 0

func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func run() -> void:
	var wing: Node3D = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	# Standalone deferred-owner regression; M2 clock-bound cutoff is covered separately.
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.get_node("Player").set_physics_process(false)
	var runtime = wing.get_node("ReceivingRuntime")
	var cycle = runtime.lift_cycle
	cycle.set_process(false)
	check(runtime.run_awaiting_lift_debug_delivery(1,0), "real upstream commitments prepared")
	cycle._process(cycle._phase_duration)
	cycle._process(6.0)
	check(runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(wing.get_node("Player/CarriedItems")), "real TAKE drains A")
	cycle._process(cycle._phase_duration)
	cycle._process(cycle._phase_duration)
	paused = true
	await process_frame
	await process_frame
	check(runtime.return_admission.get_awaiting_returns().size() == 1 and runtime.receiving_manager.get_queued_batch_ids().size() == 1, "already-deferred admission cannot mutate logical ownership while menu is paused")
	paused = false
	if runtime.return_admission.has_method("resume_after_pause"):
		runtime.return_admission.resume_after_pause()
	await process_frame
	check(runtime.return_admission.get_awaiting_returns().is_empty() and runtime.receiving_manager.get_queued_batch_ids().size() == 2, "resume admits the original waiting commitment once")
	wing.free()
	print("M1_PAUSE_ADMISSION_COMPLETE failures=", failures)
	quit(1 if failures else 0)
