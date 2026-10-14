extends "res://tools/asset_pipeline/tests/receiving_queued_delivery_tests.gd"

# Reuses the accepted ordinary TAKE/open helpers against the actual production wing.
const AwaitingEvidence := "res://reports/receiving/stage_c_awaiting_2026-10-14/"
var demo_completed := false

func run() -> void:
	real_time = OS.get_cmdline_user_args().has("--awaiting-real-time")
	await awaiting_cycles()
	check(demo_completed, "real-scene scenario completes without runtime abort")
	print("receiving_awaiting_lift_integration_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL", failures])
	quit(0 if failures == 0 else 1)

func awaiting_cycles() -> void:
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
	if not runtime.has_method("run_awaiting_lift_debug_delivery"):
		check(false, "separate opt-in four-return helper exists")
		wing.free()
		return
	var manager: ReceivingManager = runtime.receiving_manager
	var presenter = runtime.deck_presenter
	var cycle = runtime.lift_cycle
	var owner = runtime.return_admission
	cycle.set_process(real_time)
	var ui = wing.get_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface")
	var events := {"states": [], "admissions": [], "activations": []}
	var start := Time.get_ticks_msec()
	cycle.state_changed.connect(func(state: int):
		events.states.append(state)
		print("AWAITING_SCENE active=", manager.get_active_batch_id(), " state=", state, " queue=", manager.get_queued_batch_ids(), " awaiting=", owner.get_awaiting_returns(), " elapsed_s=", (Time.get_ticks_msec() - start) / 1000.0)
	)
	owner.return_admitted_after_waiting.connect(func(team: String, batch: String): events.admissions.append([team, batch]))
	manager.active_batch_changed.connect(func(id: String): events.activations.append(id))
	# Presenter LAST exercises the published guarded handoff, followed by deferred admission.
	manager.active_batch_changed.disconnect(presenter._on_active_batch_changed)
	manager.active_batch_changed.connect(presenter._on_active_batch_changed)
	if OS.get_cmdline_user_args().has("--receiving-deck-debug"):
		await process_frame
		await process_frame
	else:
		check(not runtime.run_awaiting_lift_debug_delivery(4, -1) and manager.get_active_batch() == null, "invalid demo preparation is atomic")
		check(runtime.run_awaiting_lift_debug_delivery(4, 3), "four deterministic prepared returns start")
	var bulk: int = manager.get_active_batch().target_bulk
	var ids: Array[String] = []
	var commitments := {}
	for index in 4:
		var id := "receiving_debug_%d_%d_%d" % [1842 + index, 9001 + index, bulk]
		ids.append(id)
		var batch: LootBatch = manager.get_deposited_batch(id)
		if batch != null:
			commitments[id] = var_to_bytes(batch.to_snapshot())
	var expected_d: LootBatch = runtime._prepare_debug_batch(1845, 9004, bulk, 3)
	commitments[ids[3]] = var_to_bytes(expected_d.to_snapshot())
	var manifests: Array = []
	for index in 4:
		var comparison: LootBatch = runtime._prepare_debug_batch(1842 + index, 9001 + index, bulk, 3)
		var definitions := manifest(comparison)
		definitions.sort()
		check(not manifests.has(definitions), "seeds produce differentiated cargo multiplicities")
		manifests.append(definitions)
	check(manager.get_active_batch_id() == ids[0] and manager.get_queued_batch_ids() == PackedStringArray([ids[1], ids[2]]), "A active B/C queued")
	check(manager.get_deposited_batch(ids[3]) == null and owner.get_awaiting_returns() == [{"team_id": "prototype_team_D", "batch_id": ids[3], "status": &"AWAITING_LIFT"}], "D outside Receiving with exact identity")
	check(not runtime.run_awaiting_lift_debug_delivery(4, 3), "repeat cannot replace four commitments")
	readout(ui, "INCOMING", "CLEAR", "02")
	# Fifth waiter is deterministic integration only; human debug path remains four returns.
	if not real_time:
		var fifth: LootBatch = runtime._prepare_debug_batch(1846, 9005, bulk, 3)
		ids.append(fifth.batch_id)
		commitments[fifth.batch_id] = var_to_bytes(fifth.to_snapshot())
		check(owner.submit_return("prototype_team_E", fifth) == 2, "E waits after D")
	var transferred := {}
	for index in ids.size():
		var batch: LootBatch = manager.get_active_batch()
		check(batch != null and batch.batch_id == ids[index], "active progression uses exact FIFO batch")
		if commitments.has(batch.batch_id):
			check(var_to_bytes(batch.to_snapshot()) == commitments[batch.batch_id], "prepared snapshot unchanged by wait/promotion")
		check(await open_batch(cycle, presenter, player), "independent cycle opens")
		if cycle.get_cycle_state() != 4:
			wing.free()
			return
		var queue := "%02d" % manager.get_queued_batch_ids().size()
		await unload(batch, presenter, cycle, ui, player.get_node("CarriedItems"), queue, transferred)
		if index == 0:
			check(owner.get_return_status("prototype_team_D") == &"AWAITING_LIFT" and manager.get_deposited_batch(ids[3]) == null, "final TAKE cannot admit D")
		await awaiting_depart(cycle, manager, batch, owner, ids[3], index == 0)
		await process_frame
		await process_frame
		if index == 0:
			check(manager.get_active_batch_id() == ids[1] and manager.get_queued_batch_ids() == PackedStringArray([ids[2], ids[3]]), "full A departure promotes B then appends D after C")
			check(owner.get_return_status("prototype_team_D") == &"ADMITTED_RETURNED" and events.admissions == [["prototype_team_D", ids[3]]], "D resolves once after waiting")
			check(presenter.is_active_batch_staged() and cycle.get_cycle_state() == 1, "B staged and incoming without overlap")
			readout(ui, "INCOMING", "CLEAR", "02")
			await capture("four_return_unblocked")
			if real_time:
				print("AWAITING_REAL_TIME completed A full departure; B|C,D; D admitted elapsed_s=", (Time.get_ticks_msec() - start) / 1000.0)
				break
		elif index == 1:
			check(manager.get_active_batch_id() == ids[2] and manager.get_queued_batch_ids() == PackedStringArray([ids[3], ids[4]]), "B departure admits E behind D")
	if not real_time:
		check(manager.get_active_batch() == null and manager.get_queued_batch_ids().is_empty() and owner.get_awaiting_returns().is_empty(), "five ordinary cycles finish empty")
		check(events.states == [1,2,3,4,5,0, 1,2,3,4,5,0, 1,2,3,4,5,0, 1,2,3,4,5,0, 1,2,3,4,5,0], "five exact six-state cycles, no extra arrival")
		check(events.admissions == [["prototype_team_D", ids[3]], ["prototype_team_E", ids[4]]], "exactly two oldest-first unblock events")
		check(transferred.size() == bulk * 5, "every exact committed ItemInstance transferred once")
		check(events.activations == ids + [""], "each batch activates once; final empty notification")
		readout(ui, "IDLE", "CLEAR", "00")
	demo_completed = true
	await create_timer(.4).timeout
	wing.free()

func awaiting_depart(cycle: Node, manager: ReceivingManager, outgoing: LootBatch, owner: Node, fourth_id: String, first: bool) -> void:
	if real_time:
		check(await wait_state(cycle, 0, 12.0), "full close/latch before outbound")
	else:
		cycle.get_node("Closing").stop()
		cycle._process(3.4)
		check(manager.get_active_batch() == outgoing, "shutter contact does not retire")
		cycle._process(4.0)
	check(cycle.is_busy() and cycle.get_node("Departure").playing and not cycle.get_node("Arrival").playing, "outgoing journey owns installation")
	if first:
		check(manager.get_deposited_batch(fourth_id) == null and owner.get_return_status("prototype_team_D") == &"AWAITING_LIFT", "D still waiting during full outbound")
	if real_time:
		var start := Time.get_ticks_msec()
		while manager.get_active_batch() == outgoing and Time.get_ticks_msec() - start < 24000:
			check(not cycle.get_node("Arrival").playing and not cycle.can_take_receiving() and manager.get_deposited_batch(fourth_id) == null, "no incoming, TAKE or D admission during A outbound")
			await process_frame
		check(Time.get_ticks_msec() - start >= 18900, "accepted full outbound travel duration retained")
	else:
		cycle.get_node("Departure").stop()
		cycle._process(18.0)
		check(manager.get_active_batch() == outgoing, "full outbound budget retained")
		cycle._process(2.0)

func capture(label: String) -> void:
	if not real_time or DisplayServer.get_name() == "headless":
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var pixels := root.get_texture().get_image()
	check(pixels != null and not pixels.is_empty(), "actual OpenGL scene pixels")
	if pixels != null:
		pixels.save_png(AwaitingEvidence + label + ".png")
