extends "res://tools/asset_pipeline/tests/receiving_freight_reach_tests.gd"

func _run() -> void:
	create_timer(150).timeout.connect(func():
		push_error("M4 Receiving lifecycle helper incomplete")
		quit(3))
	var wing := WingScene.instantiate()
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.get_node("Player").set_physics_process(false)
	await physics_frame
	var runtime := wing.get_node("ReceivingRuntime")
	runtime.run_identity = load("res://gameplay/run/run_identity.gd").new()
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/scenarios/m4/Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json"))
	var batches: Array[LootBatch] = []
	for index: int in 4:
		var manifest: Dictionary = baseline.scenario.manifests[index]
		var batch: LootBatch = runtime.prepare_manifest(manifest.path,manifest.label,9400+index)
		if not _check(batch != null,"Exact 16-item lifecycle manifest prepares: " + manifest.label):
			wing.free()
			finish()
			return
		batches.append(batch)
		_check(runtime.return_admission.submit_return(manifest.label,batch) == (1 if index < 3 else 2),"Unchanged one-active/two-queued occupancy and upstream fourth return")
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	var cycle = runtime.lift_cycle
	var manager: ReceivingManager = runtime.receiving_manager
	var presenter = runtime.deck_presenter
	_check(carry.max_bulk == 20,"Lifecycle uses production 20 Bulk carrying capacity")
	var first: WorldItem = presenter.get_materialized_world_items()[0]
	_check(not first.pickup_into(carry),"ARRIVAL rejects TAKE intact")
	_open_cycle(runtime)
	var seen: Dictionary = {}
	drain(presenter,carry,seen)
	_check(batches[0].is_drained() and cycle.get_cycle_state() == 5,"Last exact TAKE starts closing once")
	cycle.get_node("Closing").stop()
	cycle.advance_time(3.4)
	_check(cycle.get_cycle_state() == 5 and manager.get_active_batch() == batches[0],"3.40-second contact retains batch through latch cue")
	cycle.advance_time(cycle.seconds_to_boundary())
	_check(cycle.is_busy() and manager.get_active_batch() == batches[0] and cycle.get_cycle_state() == 0,"Full latch starts outbound without early retirement")
	cycle.get_node("Departure").stop()
	cycle.advance_time(18.0)
	_check(manager.get_active_batch() == batches[0] and manager.get_queued_batch_ids() == PackedStringArray([batches[1].batch_id,batches[2].batch_id]),"Interrupted outbound retains A and exact FIFO B/C")
	cycle.advance_time(cycle.seconds_to_boundary())
	runtime.return_admission.settle_before_boundary()
	await process_frame
	_check(manager.get_active_batch() == batches[1] and manager.get_queued_batch_ids() == PackedStringArray([batches[2].batch_id,batches[3].batch_id]),"Completed outbound promotes B and fairly admits upstream D behind C")
	_check(runtime.return_admission.get_awaiting_returns().is_empty() and not cycle.can_take_receiving(),"No extra deposited slot or OPEN gate during new incoming journey")
	_open_cycle(runtime)
	drain(presenter,carry,seen)
	_check(seen.size() == 32 and batches[1].is_drained(),"Both exact mixed manifests transfer all 32 unique identities")
	wing.free()
	finish()

func drain(presenter: Node, carry: CarriedItems, seen: Dictionary) -> void:
	var worlds: Array = presenter.get_materialized_world_items().duplicate()
	_check(worlds.size() == 16,"Fully OPEN exact 16-item presentation")
	for world: WorldItem in worlds:
		var item: ItemInstance = world.get_item_instance()
		_check(not seen.has(item.instance_id) and world.pickup_into(carry) and carry.get_selected_item() == item,"Whole-item production TAKE preserves unique cargo identity")
		seen[item.instance_id] = true
		carry.remove_item(item)

func finish() -> void:
	print("M4_RECEIVING_LIFECYCLE_COMPLETE failures=",int(_failed))
	quit(1 if _failed else 0)
