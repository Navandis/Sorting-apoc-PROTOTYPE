extends "res://tools/asset_pipeline/tests/receiving_queued_delivery_tests.gd"

const Batch = preload("res://receiving/loot_batch.gd")
var pending_helpers := 0


func run() -> void:
	await retained_first_haul()
	await repeated_two_batch()
	check(completed == 2 and pending_helpers == 0, "both repeat-delivery regressions and fixtures complete")
	print("receiving_debug_delivery_identity_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)


func new_wing() -> Node:
	pending_helpers += 1
	var wing := WingScene.instantiate()
	var player = wing.get_node("Player")
	player.enable_held_item_view = false
	player.set_physics_process(false)
	player.set_process(false)
	player.set_process_unhandled_input(false)
	root.add_child(wing)
	current_scene = wing
	wing.get_node("ReceivingRuntime/ReceivingLiftCycle").set_process(false)
	player.get_node("CarriedItems").max_bulk = 99999
	pending_helpers -= 1
	return wing


func arrangement(batch: LootBatch) -> Dictionary:
	pending_helpers += 1
	var snapshot := batch.to_snapshot()
	snapshot.erase("batch_id")
	for entry: Dictionary in snapshot.entries:
		entry.erase("item_instance_id")
		entry.erase("remaining_in_batch")
	pending_helpers -= 1
	return snapshot


func remember_ids(batch: LootBatch, seen: Dictionary) -> void:
	pending_helpers += 1
	check(not seen.has(batch.batch_id), "new delivery batch identity is distinct: " + batch.batch_id)
	seen[batch.batch_id] = true
	for entry: LootBatchEntry in batch.entries:
		check(not seen.has(entry.item_instance_id), "new delivery item identity is distinct: " + entry.item_instance_id)
		seen[entry.item_instance_id] = true
	pending_helpers -= 1


func retained_first_haul() -> void:
	pending_helpers += 1
	var wing := new_wing()
	var player = wing.get_node("Player")
	var runtime = wing.get_node("ReceivingRuntime")
	var manager: ReceivingManager = runtime.receiving_manager
	var presenter = runtime.deck_presenter
	var cycle = runtime.lift_cycle
	var carried: CarriedItems = player.get_node("CarriedItems")
	var ui = wing.get_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface")
	check(runtime.run_debug_delivery(1842, 9001, 4, 3), "first same-seed delivery starts")
	var first: LootBatch = manager.get_active_batch()
	var content := arrangement(first)
	var seen := {}
	remember_ids(first, seen)
	check(await open_batch(cycle, presenter, player), "first retained haul opens")
	var retained: Array[ItemInstance] = []
	for item: WorldItem in presenter.get_materialized_world_items():
		retained.append(item.get_item_instance())
		check(item.pickup_into(carried), "ordinary TAKE retains first-haul identity in actual carrying")
	check(retained.size() == first.entries.size() and first.is_drained(), "all first-haul objects survive TAKE")
	# Retain one item in real wing storage and the others in actual carrying.
	var surface: StorageSurface = wing.call("get_functional_surfaces")[0]
	surface.initialize_zones_if_needed("General")
	var controller = player.get_node("StoragePlacementController")
	controller.set("_current_surface", surface)
	controller.set("_manual_mode", false)
	var stored: ItemInstance = carried.get_selected_item()
	check(controller.place_selected(), "ordinary storage command retains one first-haul object")
	var stored_stack_id := surface.get_stack_id_for_item(stored.instance_id)
	var reservation := surface.get_reservation(stored_stack_id)
	var slots := carried.get_slots()
	await depart(cycle, manager, first, null, ui)
	await process_frame
	check(manager.get_active_batch() == null and not cycle.is_busy(), "full outbound retirement precedes repetition")
	check(runtime.run_debug_delivery(1842, 9001, 4, 3), "same-seed helper accepts a genuinely new delivery")
	var second: LootBatch = manager.get_active_batch()
	remember_ids(second, seen)
	check(second != first and arrangement(second) == content, "ordered definitions, Bulk, fixtures and every arrangement field stay seeded")
	check(carried.get_slots() == slots and surface.get_reservation(stored_stack_id) == reservation, "new delivery preserves earlier carrying and reservation")
	var stack := surface.get_storage_stack(stored_stack_id)
	check(stack != null and stack.entries[0].item == stored, "earlier storage owns the exact first-haul object")
	for item: ItemInstance in retained:
		check(item == stored or carried.get_items().has(item), "every retained old object keeps its owner")
	var restored := Batch.from_snapshot(second.to_snapshot())
	check(restored != null and restored.to_snapshot() == second.to_snapshot(), "reconstruction preserves existing commitment IDs")
	# Let scheduled reflection work settle before ordinary fixture teardown (R-04 deferred).
	await create_timer(.6).timeout
	wing.free()
	completed += 1
	pending_helpers -= 1


func repeated_two_batch() -> void:
	pending_helpers += 1
	var wing := new_wing()
	var player = wing.get_node("Player")
	var runtime = wing.get_node("ReceivingRuntime")
	var manager: ReceivingManager = runtime.receiving_manager
	var presenter = runtime.deck_presenter
	var cycle = runtime.lift_cycle
	var ui = wing.get_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface")
	var seen := {}
	var first_content: Array[Dictionary] = []
	var transferred := {}
	for repetition in 2:
		check(runtime.run_two_batch_debug_delivery(3), "two-batch helper starts repetition %d" % repetition)
		var a: LootBatch = manager.get_active_batch()
		var b: LootBatch = runtime._waiting_debug_batch
		remember_ids(a, seen)
		remember_ids(b, seen)
		var committed_b := b.to_snapshot()
		check(manager.get_deposited_batch(b.batch_id) == null, "prepared B waits upstream without a deposited slot")
		check(not runtime.run_two_batch_debug_delivery(3) and runtime._waiting_debug_batch == b, "busy guard preserves exact waiting B")
		if repetition == 0:
			first_content.assign([arrangement(a), arrangement(b)])
		else:
			check([arrangement(a), arrangement(b)] == first_content, "repeated A/B definitions, Bulk and arrangements remain seeded")
		check(await open_batch(cycle, presenter, player), "A opens and deposits prepared B")
		check(manager.get_deposited_batch(b.batch_id) == b and b.to_snapshot() == committed_b, "queue residence retains B object and full commitment")
		await unload(a, presenter, cycle, ui, player.get_node("CarriedItems"), "01", transferred)
		await depart(cycle, manager, a, b, ui)
		await process_frame
		check(manager.get_active_batch() == b and b.to_snapshot() == committed_b, "FIFO promotion keeps exact B identity and arrangement")
		check(await open_batch(cycle, presenter, player), "B opens independently")
		await unload(b, presenter, cycle, ui, player.get_node("CarriedItems"), "00", transferred)
		await depart(cycle, manager, b, null, ui)
		await process_frame
		check(manager.get_active_batch() == null and not cycle.is_busy(), "both full departures finish before repeat")
	await create_timer(.6).timeout
	wing.free()
	completed += 1
	pending_helpers -= 1
