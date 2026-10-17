extends "res://tools/asset_pipeline/tests/m1_continuation_tests.gd"

class HeadlessShell extends "res://gameplay/run/run_shell.gd":
	func _candidate() -> Node3D:
		var candidate := super._candidate()
		candidate.get_node("Player").enable_held_item_view = false
		return candidate

func run() -> void:
	create_timer(55).timeout.connect(func():
		push_error("M2 cross-process helper aborted; completion missing")
		quit(3))
	var mode := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m2-save-dir="): external_dir = arg.trim_prefix("--m2-save-dir=")
		if arg.begins_with("--m2-mode="): mode = arg.trim_prefix("--m2-mode=")
	if not check(external_dir.is_absolute_path() and not external_dir.begins_with(ProjectSettings.globalize_path("res://")) and mode in ["write-pre","read-pre","write-report","read-report","write-active","read-active"], "external directory and explicit process mode required"):
		finish()
		return
	var shell := HeadlessShell.new()
	shell.save_service = Service.new(external_dir.path_join("slot"))
	root.add_child(shell)
	var snapshots := Snapshots.new()
	var codec = load("res://gameplay/run/state_codec.gd").new()
	var expected_path := external_dir.path_join("expected.json")
	if mode.begins_with("write"):
		if not check(shell.start_new_run(), "writer starts real canonical run via production shell/service"):
			shell.free()
			finish()
			return
		var wing = shell.wing
		wing.set_process(false)
		await populate_physical_fixture(wing)
		var runtime = wing.get_node("ReceivingRuntime")
		var cycle = runtime.lift_cycle
		var closing: float = maxf(cycle._cue_duration(cycle.get_node("Closing")), cycle.closing_motion_delay_s + cycle.closing_motion_duration_s)
		var departure: float = cycle._cue_duration(cycle.get_node("Departure"))
		wing.run_schedule.advance(2550.0 - closing - departure - 0.5 - wing.run_schedule.clock.elapsed)
		for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
			check(world.pickup_into(wing.get_node("Player/CarriedItems")), "real last-TAKE/full-turnaround chain prepares mid-phase night continuation")
		wing.run_schedule.advance(2549.75 - wing.run_schedule.clock.elapsed)
		# Cue lengths are binary floats; calendar subtraction can differ by a few
		# ulps. Ideal phase assertions allow 1 ns; saved/load comparisons stay exact.
		check(cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL and absf(cycle.capture_state().elapsed - 0.25) <= 1e-9, "pre-midnight save retains newly promoted incoming progress")
		var physical_before: Dictionary = snapshots.capture(wing)
		if mode != "write-pre":
			wing.run_schedule.advance(1.0)
			check(paused and wing.run_schedule.phase == "REPORT_PENDING", "writer resolves midnight and auto-saves report through shell")
			var after: Dictionary = snapshots.capture(wing)
			check(after.player == physical_before.player and after.carry == physical_before.carry and after.surfaces == physical_before.surfaces and after.hosts == physical_before.hosts and after.receiving.manager == physical_before.receiving.manager, "night preserves physical organization, exact ladder pose and deposited cargo")
			check(after.receiving.cycle.state == ReceivingLiftCycle.State.ARRIVAL and absf(after.receiving.cycle.elapsed - 0.5) <= 1e-9, "night calendar jump adds no mechanical time beyond last quarter second")
			if mode == "write-active": shell.begin_next_day()
		var expected := snapshots.capture(wing)
		var file := FileAccess.open(expected_path, FileAccess.WRITE)
		file.store_string(codec.stringify(expected))
		file.close()
		check(shell.save_and_exit(), "writer Save & Exit uses same production service")
		check(shell.save_service.load_snapshot().snapshot == expected, "writer slot logically equals captured expected state")
		if mode == "write-pre":
			check(shell.continue_run(), "writer restores isolated pre-resolution reference")
			shell.wing.set_process(false)
			shell.wing.get_node("Player").set_physics_process(false)
			shell.save_service = Service.new(external_dir.path_join("reference-slot"))
			shell.wing.run_schedule.advance(1.0)
			file = FileAccess.open(external_dir.path_join("expected-resolution.json"), FileAccess.WRITE)
			file.store_string(codec.stringify(snapshots.capture(shell.wing)))
			file.close()
	else:
		var expected: Dictionary = codec.parse(FileAccess.get_file_as_string(expected_path))
		if not check(shell.continue_run(), "independent reader process Continues production slot"):
			shell.free()
			finish()
			return
		var wing = shell.wing
		wing.set_process(false)
		wing.get_node("Player").set_physics_process(false)
		check(snapshots.capture(wing) == expected, "all saved chronology/history/identities/physical owners exactly match in independent process")
		check(paused == (mode == "read-report"), "reader restores report pause before any play frame")
		await process_frame
		await process_frame
		check(snapshots.capture(wing) == expected, "loaded callbacks do not replay events or alter report-held state")
		if mode == "read-pre":
			var resolved: Dictionary = codec.parse(FileAccess.get_file_as_string(external_dir.path_join("expected-resolution.json")))
			wing.run_schedule.advance(1.0)
			check(snapshots.capture(wing) == resolved and shell.save_service.load_snapshot().snapshot == resolved, "recovered pre-midnight snapshot deterministically resolves again and auto-saves identical logical state")
		if wing.run_schedule.phase == "REPORT_PENDING": shell.begin_next_day()
		await exercise_restored_owners(wing)
		var runtime = wing.get_node("ReceivingRuntime")
		check(not runtime.lift_cycle.can_take_receiving(), "restored mid-phase cargo retains its closed TAKE gate")
		wing.run_schedule.advance(30.0)
		check(runtime.lift_cycle.can_take_receiving() and runtime.deck_presenter.get_materialized_world_items()[0].pickup_into(wing.get_node("Player/CarriedItems")), "restored journey completes at remaining duration and permits actual cargo TAKE")
		var previous_ids: Array = expected.items.keys()
		var fresh: LootBatch = runtime.prepare_manifest(["loot_000028"], "new_after_restart", 9001)
		check(fresh != null and not runtime.return_admission.capture_state().batch_teams.has(fresh.batch_id), "persisted allocator produces fresh batch after independent restart")
		for entry: LootBatchEntry in fresh.entries: check(not previous_ids.has(entry.item_instance_id), "fresh post-load item namespace cannot collide")
	shell.free()
	finish()

func exercise_restored_owners(wing: Node) -> void:
	_pending_helpers += 1
	# A report-pending load has not yet registered an unpaused physics frame.
	# Let the actual Area3D overlap notifications settle before testing rearm.
	await physics_frame
	await process_frame
	await physics_frame
	await process_frame
	var player = wing.get_node("Player")
	var carry = player.carried_items
	var surface = wing.get_functional_surfaces()[0]
	var stack: StorageStack = surface._stacks.values()[0]
	var bottom: StorageStack.Entry = stack.entries[0]
	var taken_id: String = bottom.item.instance_id
	var successor_id: String = stack.entries[1].item.instance_id
	check(bottom.world_item.pickup_into(carry), "actual restored stack base TAKE succeeds after continuation")
	check(surface._stacks.values()[0].entries[0].item.instance_id == successor_id and surface.get_reservation_count() == 1, "restored base removal promotes remaining member and preserves reservation")
	carry.select_index(carry.get_slots().find(carry.get_items().filter(func(item): return item.instance_id == taken_id)[0]))
	var controller = player._storage_placement
	controller._current_surface = surface
	controller._suppressed = false
	check(not controller.place_selected(), "erased zoning still rejects new restorage after actual retrieval")
	surface.set_zone_rect("General", Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
	controller._current_surface = surface
	controller._suppressed = false
	check(controller.place_selected() and surface._stacks.values()[0].entries.size() == 2, "actual restored item can be stored again after deliberate legal zoning")
	var ladder: Node3D = player._attached_ladder
	var y: float = player.global_position.y
	player._step_movement(0.05, Vector2(0.0,-1.0), false)
	check(player.is_ladder_attached() and player.global_position.y > y, "restored attached ladder climbs at ordinary speed")
	var anchor: Vector3 = ladder.get_climb_anchor_world_position()
	player.global_position.y = ladder.get_bottom_player_root_world_y() + 0.01
	await physics_frame
	await physics_frame
	player._step_movement(0.1, Vector2(0.0,1.0), false)
	print("M2_LADDER_RELEASE position=", player.global_position, " anchor=", anchor, " front=", ladder.get_ladder_forward_world(), " in_area=", ladder.is_player_in_approach_area(player), " suppressed=", ladder.is_attach_suppressed_for(player))
	check(not player.is_ladder_attached() and ladder.is_attach_suppressed_for(player), "actual bottom release preserves rearm guard after load")
	player.velocity = Vector3.ZERO
	player.global_position = Vector3(anchor.x, ladder.get_bottom_player_root_world_y(), anchor.z) + ladder.get_ladder_forward_world() * 0.205
	await physics_frame
	await physics_frame
	check(not ladder.is_attach_suppressed_for(player), "back-away rearms the same restored ladder")
	player.rotation.y = ladder.get_ladder_yaw_world()
	for attempt in 12:
		player._step_movement(0.05, Vector2(0.0,-1.0), false)
		if player.is_ladder_attached(): break
		await physics_frame
	check(player.is_ladder_attached(), "actual reapproach attaches after restored ladder rearm")
	_pending_helpers -= 1

func finish() -> void:
	paused = false
	check(_pending_helpers == 0, "all cross-process helpers reached completion")
	print("M2_CONTINUATION_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
