extends SceneTree

# Real wing integration: catches early promotion, missing automatic arrival,
# rerolls, signal-order dependence, stale TAKE and incomplete turnaround.
const WingScene = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
const Source = preload("res://receiving/prototype_loot_source.gd")
const Planner = preload("res://receiving/receiving_deck_layout_planner.gd")
const Evidence = "res://reports/receiving/stage_c_queue_2026-10-14/"
var failures := 0
var completed := 0
var real_time := false

func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func run() -> void:
	real_time = OS.get_cmdline_user_args().has("--queue-real-time")
	await queued_cycles(false)
	if not real_time:
		await queued_cycles(true)
	check(completed == (1 if real_time else 2), "all integration paths complete without script abort")
	print("receiving_queued_delivery_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)

func queued_cycles(incompatible: bool) -> void:
	var wing := WingScene.instantiate()
	var player = wing.get_node("Player")
	player.enable_held_item_view = false
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	root.add_child(wing)
	current_scene = wing
	var camera: Camera3D = player.get_node("Camera3D")
	camera.global_position = Vector3(-32.6, 1.75, 2.85)
	camera.look_at(Vector3(-36.5, 1.65, -.5))
	var runtime = wing.get_node("ReceivingRuntime")
	var manager: ReceivingManager = runtime.receiving_manager
	var presenter = runtime.deck_presenter
	var cycle = runtime.lift_cycle
	cycle.set_process(real_time)
	var ui = wing.get_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface")
	var warning: OmniLight3D = wing.get_node("Environment/ReceivingLighting/WarningFixtures/W1/Fixture/WarningLight")
	var events := {"states": [], "drains": [], "activations": [], "refreshes": 0}
	var start := Time.get_ticks_msec()
	cycle.state_changed.connect(func(state: int):
		events.states.append(state)
		print("QUEUE_CYCLE batch=", manager.get_active_batch_id(), " state=", state, " queue=", manager.get_queued_batch_ids(), " elapsed_s=", (Time.get_ticks_msec() - start) / 1000.0)
	)
	manager.active_batch_drained.connect(func(id: String): events.drains.append(id))
	manager.active_batch_changed.connect(func(id: String): events.activations.append(id))
	wing.get_node("Environment/ReceivingReflections").refresh_started.connect(func(): events.refreshes += 1)
	# Presenter LAST: all synchronous staging handlers must complete before
	# the explicit post-retirement handoff starts the promoted arrival.
	manager.active_batch_changed.disconnect(presenter._on_active_batch_changed)
	manager.active_batch_changed.connect(presenter._on_active_batch_changed)
	readout(ui, "IDLE", "CLEAR", "00")
	if not incompatible and not runtime.has_method("run_two_batch_debug_delivery"):
		check(false, "explicit two-batch debug helper exists")
		wing.free()
		return
	if incompatible:
		check(runtime.run_debug_delivery(1842, 9001, 24, 3), "A starts through ordinary debug route")
	elif OS.get_cmdline_user_args().has("--receiving-deck-debug"):
		await process_frame
		await process_frame
		check(manager.get_active_batch() != null, "actual two-batch CLI starts A")
	else:
		check(not runtime.run_two_batch_debug_delivery(-1) and manager.get_active_batch() == null, "invalid fixture mode rejects without admission")
		check(runtime.run_two_batch_debug_delivery(3), "explicit two-batch helper starts A")
	var a: LootBatch = manager.get_active_batch()
	var profile = runtime.deck_profile
	if incompatible:
		profile = profile.duplicate(true)
		profile.profile_id = &"incompatible_queued_profile"
	var b: LootBatch
	if incompatible:
		b = Source.new().generate_committed_batch(runtime.item_catalog, runtime.prototype_loot_pool, "queued_manifest_b", 1843, 9002, 24)
		check(Planner.new().prepare(b, runtime.item_catalog, profile, 3).succeeded, "incompatible queued B prepares")
	else:
		b = runtime._waiting_debug_batch
		check(b != null and b.preparation_state == LootBatch.STATE_PREPARED, "B separately committed and prepared before A opens")
		check(manager.get_deposited_batch(b.batch_id) == null and manager.get_queued_batch_ids().is_empty(), "prepared B consumes no deposited slot before A OPEN")
		check(not runtime.run_two_batch_debug_delivery(3) and runtime._waiting_debug_batch == b, "busy repeat cannot replace pending B")
	var commitment := var_to_bytes(b.to_snapshot())
	print("QUEUE_MANIFEST A=", a.batch_id, " seeds=1842/9001 entries=", manifest(a))
	print("QUEUE_MANIFEST B=", b.batch_id, " seeds=1843/9002 entries=", manifest(b))
	var contents_a := manifest(a)
	var contents_b := manifest(b)
	contents_a.sort()
	contents_b.sort()
	check(contents_a != contents_b, "actual definition multiplicities differ, not just manifest order")
	blocked(presenter, player, "A ARRIVAL")
	check(await open_batch(cycle, presenter, player), "A opens automatically")
	if cycle.get_cycle_state() != 4:
		wing.free()
		return
	if incompatible:
		check(manager.deposit_batch(b), "B deposited while A OPEN")
	else:
		check(runtime._waiting_debug_batch == null and manager.get_deposited_batch(b.batch_id) == b, "OPEN signal automatically deposits B exactly once")
	check(manager.get_active_batch() == a and manager.get_queued_batch_ids() == PackedStringArray([b.batch_id]), "exact B queued behind authoritative A")
	readout(ui, "OPEN", str(a.entries.size()), "01")
	check(not runtime.run_debug_delivery(), "single-delivery helper retains busy rejection")
	var fixtures: Array = presenter.get_materialized_fixture_nodes()
	var fixture_ids: Array[int] = []
	for fixture: Node in fixtures:
		fixture_ids.append(fixture.get_instance_id())
	var transferred := {}
	await unload(a, presenter, cycle, ui, player.get_node("CarriedItems"), "01", transferred)
	check(events.drains == [a.batch_id], "A drains exactly once")
	check(presenter.get_materialized_fixture_nodes() == fixtures, "A drained fixtures retained until safe concealment")
	check(var_to_bytes(b.to_snapshot()) == commitment, "B unchanged through A unloading")
	await depart(cycle, manager, a, b, ui)
	await process_frame
	check(manager.get_active_batch() == b and manager.get_deposited_batch(a.batch_id) == null, "full departure promotes exact B object and retires A")
	check(manager.get_queued_batch_ids().is_empty(), "active B excluded from queue")
	check(var_to_bytes(b.to_snapshot()) == commitment, "promotion preserves exact B content and layout")
	check(cycle.get_cycle_state() == 1 and cycle.is_busy() and cycle.get_node("Arrival").playing, "B automatically starts independent ARRIVAL")
	readout(ui, "INCOMING", "CLEAR", "00")
	check(not cycle.get_node("Departure").playing and warning.visible and warning.light_color.r > warning.light_color.g, "outbound ends before B inbound and amber restarts")
	blocked(presenter, player, "B ARRIVAL")
	if incompatible:
		cycle.get_node("Arrival").stop()
		cycle._process(100.0)
		check(cycle.get_cycle_state() == 1 and not cycle.can_take_receiving() and not presenter.is_active_batch_staged(), "failed promoted staging stays closed and noninteractive")
		check(presenter.get_materialized_world_items().is_empty() and var_to_bytes(b.to_snapshot()) == commitment, "failed staging cannot leak A cargo or reroll B")
	else:
		check(presenter.is_active_batch_staged(), "B staged despite reversed signal order")
		for fixture: Node in presenter.get_materialized_fixture_nodes():
			check(not fixture_ids.has(fixture.get_instance_id()), "B owns fresh fixtures")
		for surface: StorageSurface in presenter.get_private_storage_surfaces():
			for entry: LootBatchEntry in a.entries:
				check(surface.get_stack_id_for_item(entry.item_instance_id).is_empty(), "no A stack reservations survive promotion")
		check(await open_batch(cycle, presenter, player), "B independently opens automatically")
		if cycle.get_cycle_state() == 4:
			readout(ui, "OPEN", str(b.entries.size()), "00")
			await unload(b, presenter, cycle, ui, player.get_node("CarriedItems"), "00", transferred)
			await depart(cycle, manager, b, null, ui)
			await process_frame
			check(events.drains == [a.batch_id, b.batch_id] and events.activations == [a.batch_id, b.batch_id, ""], "each batch drains/activates once")
			check(events.states == [1, 2, 3, 4, 5, 0, 1, 2, 3, 4, 5, 0], "two exact autonomous six-state cycles")
			check(not cycle.is_busy() and manager.get_active_batch() == null and manager.get_queued_batch_ids().is_empty(), "final empty idle installation")
			check(presenter.get_materialized_world_items().is_empty() and presenter.get_materialized_fixture_nodes().is_empty(), "no lingering cargo or fixtures")
			check(transferred.size() == a.entries.size() + b.entries.size(), "all committed identities transferred once")
			readout(ui, "IDLE", "CLEAR", "00")
			await create_timer(.3).timeout
			var refresh_count: int = events.refreshes
			cycle._process(100.0)
			await create_timer(.3).timeout
			check(cycle.get_cycle_state() == 0 and not cycle.get_node("Arrival").playing and events.refreshes == refresh_count, "no third journey or periodic reflection refresh")
			await capture("final_idle")
	print("QUEUE_CYCLE complete incompatible=", incompatible, " elapsed_s=", (Time.get_ticks_msec() - start) / 1000.0)
	completed += 1
	await create_timer(.6).timeout
	wing.free()

func manifest(batch: LootBatch) -> Array[String]:
	var result: Array[String] = []
	for entry: LootBatchEntry in batch.entries:
		result.append(String(entry.definition_id))
	return result

func readout(ui: Node, status: String, deck: String, queue: String) -> void:
	check(ui.get_node("Status").text == "STATUS : " + status and ui.get_node("Deck").text == "DECK   : " + deck and ui.get_node("Queue").text == "QUEUE  : " + queue, "CRT " + status + "/" + deck + "/" + queue)

func blocked(presenter: Node, player: Node, phase: String) -> void:
	var carried = player.get_node("CarriedItems")
	for item: WorldItem in presenter.get_materialized_world_items():
		check(not item.is_pickup_interaction_enabled() and not item.can_pickup_into(carried) and not item.pickup_into(carried), phase + " rejects direct TAKE")

func open_batch(cycle: Node, presenter: Node, player: Node) -> bool:
	if real_time:
		if not await wait_state(cycle, 3, 27.0):
			return false
		blocked(presenter, player, "REVEALING")
		await capture(cycle._cycle_batch_id + "_opening")
		if not await wait_state(cycle, 4, 10.0):
			return false
		await capture(cycle._cycle_batch_id + "_open")
	else:
		cycle.get_node("Arrival").stop()
		cycle._process(21.0)
		check(cycle.get_cycle_state() == 3, "SEALED_READY/REVEALING before OPEN")
		blocked(presenter, player, "REVEALING")
		cycle._process(6.0)
	return cycle.get_cycle_state() == 4 and cycle.can_take_receiving()

func unload(batch: LootBatch, presenter: Node, cycle: Node, ui: Node, carried: Node, queue: String, transferred: Dictionary) -> void:
	var items: Array = presenter.get_materialized_world_items()
	check(items.size() == batch.entries.size(), "only current batch materializes")
	carried.max_bulk = 0
	check(not items[0].pickup_into(carried) and not batch.is_drained() and cycle.get_cycle_state() == 4, "full carrying capacity leaves this batch OPEN")
	carried.max_bulk = 99999
	for index in items.size():
		var exact: ItemInstance = items[index].get_item_instance()
		var entries := batch.entries.filter(func(e: LootBatchEntry): return e.item_instance_id == exact.instance_id)
		check(entries.size() == 1 and exact.definition.item_id == entries[0].definition_id and not transferred.has(exact.instance_id), "exact batch identity/definition, no cross-batch leak")
		check(items[index].pickup_into(carried) and carried.get_selected_item() == exact, "ordinary TAKE transfers exact ItemInstance")
		transferred[exact.instance_id] = exact
		check(not items[index].pickup_into(carried), "stale direct TAKE rejected")
		check(cycle.get_deck_item_count() == items.size() - index - 1 and ui.get_node("Queue").text == "QUEUE  : " + queue, "DECK decrement excludes waiting cargo")
		carried.remove_item(exact)
		if real_time:
			await physics_frame
	check(batch.is_drained() and cycle.get_cycle_state() == 5, "final TAKE starts one closing cycle")
	readout(ui, "CLOSING", "CLEAR", queue)

func depart(cycle: Node, manager: ReceivingManager, outgoing: LootBatch, waiting: LootBatch, ui: Node) -> void:
	var queue := "01" if waiting != null else "00"
	if real_time:
		check(await wait_state(cycle, 0, 12.0), "full closing cue reaches departure")
	else:
		cycle.get_node("Closing").stop()
		cycle._process(3.4)
		check(cycle.get_cycle_state() == 5 and manager.get_active_batch() == outgoing, "contact retains ownership through full latch cue")
		cycle._process(4.0)
	readout(ui, "IDLE", "CLEAR", queue)
	check(cycle.is_busy() and manager.get_active_batch() == outgoing and cycle.get_node("Departure").playing and not cycle.get_node("Arrival").playing, "only outgoing owns departure")
	var start := Time.get_ticks_msec()
	if real_time:
		var deadline := start + 24000
		while manager.get_active_batch() == outgoing and Time.get_ticks_msec() < deadline:
			check(not cycle.get_node("Arrival").playing and not cycle.can_take_receiving(), "no incoming or TAKE during actual outbound")
			if waiting != null:
				check(manager.get_queued_batch_ids() == PackedStringArray([waiting.batch_id]), "B stays FIFO queued throughout outbound")
			await process_frame
		check((Time.get_ticks_msec() - start) / 1000.0 >= 18.9, "full-length outbound finishes before handoff")
	else:
		cycle.get_node("Departure").stop()
		cycle._process(18.0)
		check(manager.get_active_batch() == outgoing and cycle.is_busy(), "interrupted outbound retains full journey budget")
		cycle._process(2.0)

func wait_state(cycle: Node, state: int, seconds: float) -> bool:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000)
	while cycle.get_cycle_state() != state and Time.get_ticks_msec() < deadline:
		await create_timer(.05).timeout
	return cycle.get_cycle_state() == state

func capture(label: String) -> void:
	if not real_time or DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image != null and not image.is_empty(), "actual OpenGL scene produces pixels")
	if image != null:
		image.save_png(Evidence + label + ".png")
