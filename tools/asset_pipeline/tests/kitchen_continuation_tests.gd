extends "res://tools/asset_pipeline/tests/kitchen_interaction_tests.gd"

const Codec = preload("res://gameplay/run/state_codec.gd")
const Clock = preload("res://gameplay/run/run_clock.gd")
const Kitchen = preload("res://gameplay/kitchen/kitchen_operations.gd")

var service: RefCounted
var runtime: ReceivingRuntime
var shelves: Array[Node]

func _run() -> void:
	create_timer(240).timeout.connect(func(): quit(3))
	open_shell("user://kitchen-continuation")
	if not new_run():
		finish()
		return
	var original := capture()
	if not check(original.has("kitchen") and original.schema == Snapshot.SCHEMA, "current snapshot captures Kitchen"):
		finish()
		return
	bind_run()
	if not await roundtrip("before first trigger") or not await prove_continuation():
		finish()
		return
	prove_compatibility(original)
	finish()

func prove_continuation() -> bool:
	var first := depart(["Food", "Hydration"])
	if first.is_empty():
		return false
	advance_to(kitchen.capture_state().first_at + 0.25)
	var second := depart(["Food", "Medical"])
	if second.is_empty():
		return false
	var supply: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/Food_DryGoodsA/WorldItem")
	var selected := supply.get_item_instance()
	check(supply.pickup_into(carry), "an authored Food seed enters the pre-penalty bundle")
	for world: WorldItem in wing.get_node("DevelopmentSetup/SeedItems").find_children("WorldItem", "", true, false):
		world.pickup_into(carry)
		if carry.get_remaining_bulk() == 0:
			break
	check(carry.get_current_bulk() == 22 and kitchen.sprint_allowed(), "grace preserves a legitimate full bundle")
	if not await roundtrip("during grace with a full bundle"):
		return false
	var grace: Dictionary = kitchen.capture_state()
	shell.request_pause("zoning", true)
	timeline.advance(1000)
	await create_timer(0.08).timeout
	check(grace == kitchen.capture_state(), "zoning pause advances neither schedule nor RNG")
	shell.request_pause("zoning", false)
	advance_to(kitchen.deadline_at())
	if not await roundtrip("overdue with grandfathered carrying"):
		return false
	check(carry.get_current_bulk() == 22 and carry.get_effective_bulk_limit() < 22 and not kitchen.sprint_allowed(),
		"Continue applies overdue effects while preserving the exact full bundle")
	var old: int = kitchen.total_outstanding()
	var food := carry.get_selected_item() as ItemInstance
	check(food.instance_id == selected.instance_id and kitchen.contribute(carry, food, func(): return true).ok,
		"restored selected authored seed contributes from over capacity")
	check(kitchen.total_outstanding() < old and not kitchen.sprint_allowed(), "seed receipt relieves capacity without restoring sprint")
	if not await roundtrip("partial relief and original seed receipt"):
		return false
	wing.incinerator.mark_warning_displayed()
	check(wing.incinerator.incinerate(carry, carry.get_selected_item(), func(): return true), "independent Incinerator receipt and warning are present")
	for item: ItemInstance in carry.get_items():
		if not store(item):
			return false

	for event in 3:
		if kitchen.total_outstanding() < 105:
			advance_to(kitchen.capture_state().next_at)
	if not check(kitchen.total_outstanding() == 105 and runtime.lift_cycle.can_take_receiving(),
			"actual active chronology reaches the cap and a fully OPEN genuine return"):
		return false
	var before_cap_event := capture()
	advance_to(before_cap_event.kitchen.next_at)
	check(kitchen.outstanding == before_cap_event.kitchen.obligation.outstanding, "fully capped trigger admits no additional demand")
	if not await roundtrip("after a fully capped scheduled event"):
		return false
	prove_diverged_schedule(before_cap_event, kitchen.capture_state())

	var away := wing.expeditions as RefCounted
	check(away.toggle_affinity("Electronics") and away.toggle_affinity("Weapons") and away.dispatch(away.revision).ok,
		"third real journey leaves while the first haul is OPEN and the second queued")
	var batch := runtime.receiving_manager.get_active_batch()
	if not check(batch.source_ref == first and runtime.lift_cycle.get_queued_batch_count() == 1,
			"genuine OPEN and queued cargo share the overdue continuation"):
		return false
	var released: ItemInstance
	while not batch.is_drained():
		var item := await take_exposed(runtime)
		if item == null:
			return false
		if kitchen.preview(item).ok and not batch.is_drained():
			released = item
			break
		if not store(item):
			return false
	if not check(released != null, "a genuine Kitchen lane item was released while its source is still OPEN"):
		return false
	var observed := []
	carry.item_removed.connect(func(_item: ItemInstance): observed.append(Snapshot.new().validate(capture())), CONNECT_ONE_SHOT)
	var totals: Dictionary = wing.collection_goal.totals.duplicate()
	var outcome: Dictionary = kitchen.contribute(carry, released, func(): return true)
	check(outcome.ok and observed == [""] and wing.collection_goal.totals == totals, "observer sees exact receipt and no second goal debit")
	var open_state := capture()
	if not check(Snapshot.new().validate(open_state).is_empty(), "released OPEN cargo, queued haul and Away trip validate with the Kitchen receipt"):
		return false
	prove_invalid_snapshots(open_state, released.instance_id)
	if not await roundtrip("with Kitchen receipt and genuine OPEN, queued and Away cargo"):
		return false
	var source_id := runtime.receiving_manager.get_active_batch_id()
	if not await drain_current():
		return false
	timeline.advance(60.0)
	check(runtime.receiving_manager.get_active_batch_id() != source_id and runtime.receiving_manager.get_active_batch().source_ref == second
		and runtime.lift_cycle.can_take_receiving(),
		"normal outbound turnaround retires the first receipt's source and promotes the queue")
	if not await roundtrip("with Kitchen receipt after source retirement") or not await drain_current():
		return false
	if not check(kitchen.outstanding == Vector2i.ZERO and kitchen.sprint_allowed(), "genuine cargo clears both lanes"):
		return false
	if not await roundtrip("after clearance"):
		return false
	if not prove_victory():
		return false
	var won: float = wing.collection_goal.first_completion_at
	await aim_at_kitchen()
	player.kitchen_requested.emit()
	check(panel.is_open(), "Kitchen remains available after victory")
	advance_to(kitchen.capture_state().next_at)
	shell._process(0.0)
	var saved: Dictionary = service.load_snapshot()
	check(saved.ok and saved.snapshot.kitchen == kitchen.capture_state() and saved.snapshot.goal.first_completion_at == won,
		"automatic save under a live Kitchen panel includes new demand and original victory")
	if not await roundtrip("after victory with a fresh obligation"):
		return false
	var path: String = service.load_snapshot().path
	var pointer: String = service.directory.path_join(SaveService.POINTER)
	var hashes := [FileAccess.get_sha256(path), FileAccess.get_sha256(pointer)]
	write_text(service.directory.path_join(".m1-snapshot.tmp"), "test blocker")
	check(not shell.save_and_exit() and shell.wing == wing and FileAccess.get_sha256(path) == hashes[0]
		and FileAccess.get_sha256(pointer) == hashes[1] and service.load_snapshot().ok, "failed Save & Exit keeps the prior valid continuation")
	return true

func prove_diverged_schedule(before: Dictionary, capped: Dictionary) -> void:
	var clock := Clock.new()
	clock.elapsed = before.timeline.elapsed
	var branch := Kitchen.new(clock)
	branch.restore_state(before.kitchen)
	var branch_carry := CarriedItems.new()
	var definition := PrototypeItemCatalog.get_definition_by_id(&"loot_000007")
	var item := ItemInstance.new(definition, "timing-branch-item")
	branch_carry.add_item(item)
	check(branch.contribute(branch_carry, item, func(): return true).ok, "restored branch pays before the same event")
	clock.elapsed = before.kitchen.next_at
	branch.settle_due()
	var paid := branch.capture_state()
	check(paid.next_at == capped.next_at and paid.timing_state == capped.timing_state and paid.amount_state == capped.amount_state
		and paid.obligation.issued.x + paid.obligation.issued.y > capped.obligation.issued.x + capped.obligation.issued.y,
		"continued cap and paid histories draw identical timestamps and amounts with different admitted Utility")
	branch_carry.free()

func prove_invalid_snapshots(valid: Dictionary, id: String) -> void:
	var malformed := valid.duplicate(true)
	malformed.kitchen.next_at = int(valid.timeline.elapsed)
	check(rejects(malformed), "an already due unprocessed event rejects")
	malformed = valid.duplicate(true)
	malformed.kitchen.obligation.overdue = false
	check(rejects(malformed), "an expired grace marked as live rejects")
	malformed = valid.duplicate(true)
	malformed.kitchen.obligation.outstanding.x += 1
	check(rejects(malformed), "balance inconsistent with issued demand and credits rejects")
	malformed = valid.duplicate(true)
	malformed.kitchen.obligation.clear()
	malformed.kitchen.receipts.clear()
	check(rejects(malformed), "a processed event cannot lose both its obligation and its history")
	malformed = valid.duplicate(true)
	malformed.carry.max_bulk = 25
	check(rejects(malformed), "a forged normal upgrade cannot legitimize carrying")
	malformed = valid.duplicate(true)
	var receipt: Dictionary = valid.kitchen.receipts.back()
	malformed.kitchen.receipts.append(receipt)
	check(rejects(malformed), "duplicate terminal Kitchen identity rejects")
	malformed = valid.duplicate(true)
	malformed.items[id] = {"definition": receipt.definition_id, "contaminated": receipt.contaminated}
	check(rejects(malformed), "live and Kitchen ownership of one identity rejects")
	malformed = valid.duplicate(true)
	malformed.incinerator.receipts.append({"item_id": id, "definition_id": receipt.definition_id, "at": receipt.at})
	check(rejects(malformed), "Kitchen and Incinerator receipt of one identity rejects")
	malformed = valid.duplicate(true)
	malformed.kitchen.receipts.back().wasted += 1
	check(rejects(malformed), "receipt credit and waste must match exact item Utility")
	malformed = valid.duplicate(true)
	malformed.kitchen.receipts.pop_back()
	check(rejects(malformed), "released cargo with no terminal or physical owner rejects")
	malformed = valid.duplicate(true)
	for batch: Dictionary in malformed.receiving.manager.batches:
		for entry: Dictionary in batch.entries:
			if entry.item_instance_id == id:
				entry.remaining_in_batch = true
	check(rejects(malformed), "terminal receipt cannot excuse cargo still on the manifest as untaken")

func prove_victory() -> bool:
	for world: WorldItem in wing.get_node("DevelopmentSetup/SeedItems").find_children("WorldItem", "", true, false):
		var item := world.get_item_instance()
		var goal: RefCounted = wing.collection_goal
		if goal.completed:
			break
		if goal.totals[item.get_storage_category()] < goal.target and world.pickup_into(carry) and not store(item):
			return false
	return check(wing.collection_goal.completed, "ordinary stored authored stock reaches the unchanged goal")

func depart(affinities: Array) -> String:
	var ops: RefCounted = wing.expeditions
	if not check(ops.set_members(4) and ops.toggle_affinity(affinities[0]) and ops.toggle_affinity(affinities[1]),
			"genuine four-member expedition uses a bounded, repeatable manifest"):
		return ""
	var seed := recovery_seed(ops, runtime)
	if not check(seed >= 0, "find seeded return for Kitchen"):
		return ""
	ops.rng.seed = seed
	var result: Dictionary = ops.dispatch(ops.revision)
	check(result.ok, "normal departure commits")
	return result.get("id", "")

func drain_current() -> bool:
	while runtime.lift_cycle.can_take_receiving():
		var item := await take_exposed(runtime)
		if item == null:
			return false
		if kitchen.preview(item).ok:
			if not check(kitchen.contribute(carry, item, func(): return true).ok, "consume exact returned supply"):
				return false
		elif not store(item):
			return false
	return true

func store(item: ItemInstance) -> bool:
	placement.set_suppressed(false)
	for surface: StorageSurface in shelves:
		surface.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
		if put(item, surface):
			return true
	return check(false, "fixture storage cannot fit " + item.get_display_name())

func advance_to(at: float) -> void:
	timeline.advance(at - timeline.clock.elapsed)

func capture() -> Dictionary:
	return Snapshot.new().capture(wing)

func rejects(state: Dictionary) -> bool:
	return not Snapshot.new().validate(state).is_empty()

func bind_run() -> void:
	wing = shell.wing
	wing.set_process(false)
	player = wing.get_node("Player")
	player.set_process(false)
	player.set_physics_process(false)
	carry = player.carried_items
	placement = player._storage_placement
	runtime = wing.get_node("ReceivingRuntime")
	timeline = wing.run_timeline
	kitchen = wing.kitchen
	panel = wing.kitchen_panel
	shelves = wing.get_functional_surfaces()

func roundtrip(label: String) -> bool:
	var before := capture()
	if not check(shell.save_and_exit(), "Save & Exit " + label + " " + shell.pause_status.text):
		return false
	await create_timer(0.05).timeout
	if not check(shell.continue_run(), "Continue " + label + " " + shell.status_label.text):
		return false
	bind_run()
	return check(capture() == before and not panel.is_open() and not wing.dispatch_panel.is_open() and not wing.incinerator_panel.is_open(),
		"exact state after offline pause, with service panels closed: " + label)

func open_shell(directory: String) -> void:
	service = SaveService.new(directory)
	shell = Shell.instantiate()
	shell.save_service = service
	root.add_child(shell)
	current_scene = shell
	shell.set_process(false)

func prove_compatibility(schema_seven: Dictionary) -> void:
	schema_seven.schema = 7
	schema_seven.erase("kitchen")
	schema_seven.erase("fuel")
	schema_seven.receiving.cycle.erase("start_due_at")
	schema_seven.receiving.cycle.erase("last_turnaround_at")
	current_scene = null
	shell.free()
	var directory := ProjectSettings.globalize_path("user://kitchen-legacy/collection")
	DirAccess.make_dir_recursive_absolute(directory)
	var old := directory.path_join("Save_incinerator.json")
	var pointer := directory.path_join(SaveService.POINTER)
	write_text(old, Codec.new().stringify(schema_seven))
	write_text(pointer, JSON.stringify({"snapshot": old.get_file()}))
	var old_hash := FileAccess.get_sha256(old)
	var pointer_hash := FileAccess.get_sha256(pointer)
	open_shell(directory)
	check(shell.continue_button.disabled and shell.status_label.text.contains("schema 7")
		and not shell.continue_run() and FileAccess.get_sha256(pointer) == pointer_hash, "schema 7 is incompatible without changing its active pointer")
	shell.request_new_run()
	shell.cancel_new_run()
	check(FileAccess.get_sha256(pointer) == pointer_hash, "cancel New Run keeps the old pointer")
	shell.request_new_run()
	shell.confirm_new_run()
	check(service.load_snapshot().ok and service.load_snapshot().snapshot.schema == Snapshot.SCHEMA and FileAccess.get_sha256(old) == old_hash
		and FileAccess.get_sha256(pointer) != pointer_hash, "confirmed New Run repoints to the current schema and retains schema 7 bytes")

func write_text(path: String, data: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if check(file != null, "isolated fixture file opens for writing"):
		file.store_string(data)
		file.close()

func finish() -> void:
	current_scene = null
	shell.free()
	print("kitchen_continuation_tests: %s (%d checks, %d failures)" % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)
