extends SceneTree

const Snapshots = preload("res://gameplay/run/run_snapshot.gd")
const Service = preload("res://gameplay/run/run_save_service.gd")
var failures := 0
var checks := 0
var external_dir := ""

func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M1 continuation helper aborted; completion missing")
		quit(3))
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m1-save-dir="): external_dir = arg.trim_prefix("--m1-save-dir=")
	if not check(external_dir.is_absolute_path() and not external_dir.begins_with(ProjectSettings.globalize_path("res://")), "external save destination required"):
		finish()
		return
	var service := Service.new(external_dir)
	var snapshots := Snapshots.new()
	var wing: Node3D = load(Snapshots.WING).instantiate()
	wing.get_node("Player").enable_held_item_view = false
	if OS.get_cmdline_user_args().has("--m1-read"):
		var loaded := service.load_snapshot()
		if not check(loaded.ok, "separate process loads production slot"):
			finish()
			return
		wing.configure_continue(loaded.snapshot)
		root.add_child(wing)
		wing.set_process(false)
		wing.get_node("Player").set_physics_process(false)
		wing.get_node("ReceivingRuntime/ReceivingLiftCycle").set_process(false)
		check(snapshots.restore(wing, loaded.snapshot).is_empty(), "new process restores complete physical owner state")
		check(snapshots.capture(wing) == loaded.snapshot, "all IDs/owners/slots/stacks/reservations/zones/player/ladder/Receiving/timing exactly match across process")
		check(wing.medical_request.credited.Medical == 3, "historical contribution retained after restart")
		var previous_ids: Array = loaded.snapshot.items.keys()
		var runtime = wing.get_node("ReceivingRuntime")
		var fresh: LootBatch = runtime._prepare_debug_batch(1842, 9001, 4, 0)
		check(fresh != null and not loaded.snapshot.receiving.manager.batches.any(func(batch): return batch.batch_id == fresh.batch_id), "persisted allocator produces a new commitment after restart")
		for entry: LootBatchEntry in fresh.entries:
			check(not previous_ids.has(entry.item_instance_id), "new cargo identity is disjoint: " + entry.item_instance_id)
		var surface = wing.get_functional_surfaces()[0]
		var stored_before: Dictionary = surface.capture_state()
		check(surface.are_zones_initialized() and surface.get_zone_cells_copy().count("") == surface.get_zone_cells_copy().size() and surface.get_reservation_count() == 1, "erased zones retain committed stored stack")
		var carry = wing.get_node("Player/CarriedItems")
		var controller = wing.get_node("Player")._storage_placement
		controller._current_surface = surface
		controller._suppressed = false
		check(not controller.place_selected() and surface.capture_state() == stored_before, "new automatic placement still rejects erased zones")
		var invalid: Dictionary = loaded.snapshot.duplicate(true)
		invalid.carry.slots.append(invalid.carry.slots[invalid.carry.selected])
		check(not snapshots.validate(invalid).is_empty(), "duplicate physical ownership rejected before restore")
		var rewind: Dictionary = loaded.snapshot.duplicate(true)
		rewind.run.next_sequence = 1
		check(not snapshots.validate(rewind).is_empty(), "allocation sequence rewind rejected before new cargo can collide")
		var profile_change: Dictionary = loaded.snapshot.duplicate(true)
		profile_change.receiving.manager.batches[0].presentation_profile_revision += 1
		check(not snapshots.validate(profile_change).is_empty(), "incompatible Receiving profile rejected before Continue")
		wing.free()
		finish()
		return
	wing.configure_new_run()
	root.add_child(wing)
	wing.set_process(false)
	var player = wing.get_node("Player")
	player.set_physics_process(false)
	var cycle = wing.get_node("ReceivingRuntime/ReceivingLiftCycle")
	cycle.set_process(false)
	var carry = player.carried_items
	carry.max_bulk = 100
	var seeds = wing.get_node("DevelopmentSetup/SeedItems")
	check(seeds.get_node("Medical_Bandages/WorldItem").pickup_into(carry), "real TAKE of spent Medical fixture")
	check(wing.medical_request.submit(carry).ok, "one committed contribution before physical save")
	var controller = player._storage_placement
	var surface = wing.get_functional_surfaces()[0]
	surface.initialize_zones_if_needed("General")
	surface.set_custom_display_name("Supplies after zone erase")
	surface.set_semantic_orientation_quarter_turns(3)
	for host_name: String in ["MedKit_A", "MedKit_B"]:
		check(seeds.get_node(host_name + "/WorldItem").pickup_into(carry), "TAKE stack fixture " + host_name)
		controller._current_surface = surface
		controller._suppressed = false
		check(controller.place_selected(), "real storage command commits " + host_name)
	check(surface.get_stack_count() == 1 and surface._stacks.values()[0].entries.size() == 2, "ordered stack created through real placement")
	surface.clear_all_zones()
	for host_name: String in ["Book", "Book2", "Medical_Antibiotics"]:
		check(seeds.get_node(host_name + "/WorldItem").pickup_into(carry), "TAKE retained carrying " + host_name)
	# Spend the middle item into a second legal storage owner, leaving an actual gap.
	carry.select_index(1)
	var other = wing.get_functional_surfaces()[1]
	other.initialize_zones_if_needed("General")
	controller._current_surface = other
	controller._suppressed = false
	check(controller.place_selected(), "real transfer leaves a carried slot gap")
	carry.select_index(2)
	check(carry.get_slots().size() == 3 and carry.get_slots()[1] == null and carry.get_selected_index() == 2, "slot gaps and nonzero selection present")
	var ladder: Node3D = get_nodes_in_group("fixed_ladders").filter(wing.is_ancestor_of)[0]
	var anchor: Vector3 = ladder.get_climb_anchor_world_position()
	player.global_position = Vector3(anchor.x, ladder.global_position.y + 0.8, anchor.z)
	player.rotation.y = ladder.get_ladder_yaw_world()
	player._attached_ladder = ladder
	player._movement_state = 1
	player._ladder_anchor_xz = Vector2(anchor.x, anchor.z)
	player._ladder_yaw_center = ladder.get_ladder_yaw_world()
	player._pitch = -0.22
	player.camera.rotation.x = -0.22
	player.velocity = Vector3.ZERO
	var runtime = wing.get_node("ReceivingRuntime")
	check(runtime.run_awaiting_lift_debug_delivery(4, 3), "real upstream route owns active + two FIFO + one waiting")
	cycle._process(1.2345678912345)
	await process_frame
	var snapshot := snapshots.capture(wing)
	var validation := snapshots.validate(snapshot)
	check(validation.is_empty(), "full physical snapshot validates: " + validation)
	var written := service.save_snapshot(snapshot)
	check(written.ok, "production service saves cross-process fixture: " + written.get("error", ""))
	print("M1_PROCESS_SAVE ", written.get("path", ""), " run=", snapshot.run.id)
	wing.free()
	finish()

func finish() -> void:
	print("M1_CONTINUATION_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
