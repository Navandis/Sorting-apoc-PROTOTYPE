extends "res://tools/asset_pipeline/tests/expedition_physical_tests.gd"

const Codec = preload("res://gameplay/run/state_codec.gd")

var service: RefCounted
var runtime: ReceivingRuntime
var timeline: RefCounted
var panel: CanvasLayer
var checks := 0

func _run() -> void:
	create_timer(240).timeout.connect(func(): quit(3))
	var directory := OS.get_temp_dir().path_join("incinerator-continuation-" + Crypto.new().generate_random_bytes(8).hex_encode())
	open_shell(directory.path_join("run"))
	if not check(shell.start_new_run(), "isolated New Run starts"):
		finish()
		return
	bind_run()
	var schema_six := Snapshot.new().capture(wing)
	schema_six.schema = 6
	schema_six.erase("incinerator")
	schema_six.erase("kitchen")
	var supply: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/Food_DryGoodsA/WorldItem")
	check(supply.pickup_into(carry) and wing.expeditions.contribute(carry).ok, "a real contribution exists independently of disposal")
	var first := depart("Food", "Fuel")
	var second := depart("Hydration", "Medical")
	var third := depart("Morale", "Weapons")
	var waiting := depart("Protection", "Electronics")
	if [first, second, third, waiting].has(""):
		finish()
		return
	var returned_at: float = wing.expeditions.journeys[first].return_at
	timeline.advance(returned_at + 42.0 - timeline.clock.elapsed)
	var away := depart("Hydration", "Electronics")
	var batch := runtime.receiving_manager.get_active_batch()
	if not check(batch != null and batch.source_ref == first and runtime.lift_cycle.can_take_receiving()
			and wing.expeditions.journeys[waiting].status == Ops.WAITING and not away.is_empty(),
			"one OPEN batch, two deposits, one genuine Awaiting Lift crew and one Away trip"):
		finish()
		return
	var first_cargo := await take_exposed(runtime)
	if not check(first_cargo != null and not batch.is_drained(), "TAKE releases one exact cargo identity while more remains on the deck"):
		finish()
		return
	var captured := Snapshot.new().capture(wing)
	var missing := captured.duplicate(true)
	missing.items.erase(first_cargo.instance_id)
	missing.carry.slots.clear()
	missing.carry.selected = -1
	check(Snapshot.new().validate(missing).contains("no physical owner or receipt"), "truly missing released cargo still rejects")
	var before_totals: Dictionary = wing.collection_goal.totals.duplicate()
	var observed := []
	carry.item_removed.connect(func(_item: ItemInstance): observed.append(Snapshot.new().validate(Snapshot.new().capture(wing))),
		CONNECT_ONE_SHOT)
	open_machine()
	await key_tap(KEY_E)
	check(panel._warning.visible and carry.get_items() == [first_cargo], "initial cargo warning spends nothing")
	panel._continue_button.pressed.emit()
	check(carry.get_item_count() == 0 and wing.collection_goal.totals == before_totals,
		"confirmed disposal removes never-scored cargo without adjusting live totals")
	captured = Snapshot.new().capture(wing)
	var has_disposal := captured.has("incinerator")
	if not has_disposal:
		# Let the baseline validator encounter the genuine receipt for the RED check.
		captured.incinerator = wing.incinerator.capture_state()
	var error := Snapshot.new().validate(captured)
	if not check(error.is_empty(), "released OPEN cargo with a genuine disposal receipt is valid: " + error):
		finish()
		return
	check(has_disposal and observed == [""], "observer captures full removal plus receipt before carrying notifications")
	prove_rejections(captured, first, waiting)
	if not roundtrip("after Continue with released cargo and an OPEN deck"):
		finish()
		return
	check(not panel.is_open() and wing.incinerator.warning_shown and not Snapshot.new().capture(wing).items.has(first_cargo.instance_id),
		"Continue restores the warning, absent cargo and other owners with no pending command")

	if not await prove_congestion(waiting):
		finish()
		return
	if not await prove_goal():
		finish()
		return
	if not await prove_warning_saves():
		finish()
		return
	prove_compatibility(directory.path_join("legacy"), schema_six)
	finish()

func prove_rejections(state: Dictionary, first: String, waiting: String) -> void:
	var receipt: Dictionary = state.incinerator.receipts[0]
	var bad := state.duplicate(true)
	bad.incinerator.warning_shown = 1
	check(not Snapshot.new().validate(bad).is_empty(), "warning flag must be a boolean")
	bad.incinerator.warning_shown = false
	check(not Snapshot.new().validate(bad).is_empty(), "a receipt requires a shown warning")
	bad = state.duplicate(true)
	bad.incinerator.receipts.append(receipt)
	check(not Snapshot.new().validate(bad).is_empty(), "duplicate destruction receipt rejects")
	for wrong: Variant in ["loot_missing", "loot_000001", -1.0, 0.0, NAN, state.timeline.elapsed + 1.0]:
		bad = state.duplicate(true)
		var key := "definition_id" if wrong is String else "at"
		bad.incinerator.receipts[0][key] = wrong
		check(not Snapshot.new().validate(bad).is_empty(), "wrong definition or destruction timestamp rejects")
	var spent: Dictionary = state.expeditions.journeys[first].loadout.spent[0]
	bad = state.duplicate(true)
	bad.incinerator.receipts.append({"item_id": spent.item_id, "definition_id": spent.definition_id, "at": state.timeline.elapsed})
	check(not Snapshot.new().validate(bad).is_empty(), "disposal cannot also be loadout credit")
	var unclaimed: String = state.run.id + ":wing_seed_v1:NonexistentHost"
	bad = state.duplicate(true)
	bad.incinerator.receipts.append({"item_id": unclaimed, "definition_id": "loot_000001", "at": state.timeline.elapsed})
	check(not Snapshot.new().validate(bad).is_empty(), "a fabricated seed host is not a valid origin")
	var not_taken: Array = [state.receiving.manager.batches[0], state.receiving.manager.batches[1],
		state.expeditions.away_cargo.values()[0]]
	for pending: Dictionary in state.receiving.admission.pending:
		if pending.team == waiting:
			not_taken.append(pending.batch)
	for owner: Dictionary in not_taken:
		for entry: Dictionary in owner.entries:
			if not entry.remaining_in_batch:
				continue
			bad = state.duplicate(true)
			bad.incinerator.receipts.append({"item_id": entry.item_instance_id, "definition_id": String(entry.definition_id),
				"at": state.timeline.elapsed})
			check(not Snapshot.new().validate(bad).is_empty(), "a receipt cannot overlap a current physical owner")
			bad.items.erase(entry.item_instance_id)
			check(not Snapshot.new().validate(bad).is_empty(), "a receipt cannot excuse missing untaken cargo")
			break
	var pointer: String = service.directory.path_join(SaveService.POINTER)
	var hash := FileAccess.get_sha256(pointer)
	var saved: Dictionary = service.load_snapshot()
	var previous_hash := FileAccess.get_sha256(saved.path)
	check(not service.save_snapshot(bad).ok and FileAccess.get_sha256(pointer) == hash
		and FileAccess.get_sha256(saved.path) == previous_hash, "a failed disposal save preserves the pointer and prior snapshot")

func prove_congestion(waiting: String) -> bool:
	var batch := runtime.receiving_manager.get_active_batch()
	var retired_id := batch.batch_id
	var accounted: int = wing.expeditions.ready_count + wing.expeditions.medical.active_count()
	var deck_before: Dictionary = runtime.capture_state()
	for surface: StorageSurface in wing.get_functional_surfaces():
		surface.clear_all_zones()
	var stock: StorageSurface = wing.get_functional_surfaces()[1]
	stock.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, Vector2i.ZERO)
	for world: Node in wing.get_node("DevelopmentSetup/SeedItems").find_children("WorldItem", "", true, false):
		(world as WorldItem).pickup_into(carry)
		if carry.get_remaining_bulk() == 0:
			break
	var capacity := carry.get_effective_bulk_limit()
	if not check(carry.get_current_bulk() == capacity, "congestion fixture fills current carrying capacity with physical pickups"):
		return false
	placement.set_suppressed(false)
	check(not put(carry.get_selected_item(), stock), "one spare cell does not accept the selected bulky stock")
	await physics_frame
	await physics_frame
	var target := _nearest_exposed_candidate(player, player.camera, runtime.deck_presenter.get_materialized_world_items())
	if not check(not target.is_empty(), "blocked lift still exposes a reachable item"):
		return false
	_place_player_at_stance(player, target.stance_z)
	player.camera.look_at(target.target_position)
	player._attempt_pickup_click()
	check(carry.get_current_bulk() == capacity and runtime.capture_state() == deck_before,
		"full carrying rejects normal reticle TAKE without changing the lift")

	var required := 0
	for entry: LootBatchEntry in batch.entries:
		if entry.remaining_in_batch:
			required = maxi(required, PrototypeItemCatalog.get_definition_by_id(entry.definition_id).bulk)
	var totals: Dictionary = wing.collection_goal.totals.duplicate()
	var seed_receipt_ids: Array[String] = []
	open_machine()
	while carry.get_remaining_bulk() < required:
		var seed: ItemInstance = carry.get_selected_item()
		var count := carry.get_item_count()
		await key_tap(KEY_E)
		if not check(carry.get_item_count() == count - 1, "one chosen carried item frees space with each deliberate trip action"):
			return false
		seed_receipt_ids.append(seed.instance_id)
	panel.close_top()
	check(wing.collection_goal.totals == totals and runtime.capture_state() == deck_before
		and wing.expeditions.ready_count + wing.expeditions.medical.active_count() == accounted,
		"loose seed disposal neither changes score nor unloads cargo or releases the waiting crew")
	var retired_item: ItemInstance
	while not batch.is_drained():
		retired_item = await take_exposed(runtime)
		if retired_item == null:
			return false
		if not batch.is_drained():
			open_machine()
			await key_tap(KEY_E)
			if not check(not carry.get_items().has(retired_item), "disposing a taken item frees room for the next exact cargo item"):
				return false
			panel.close_top()
	check(runtime.lift_cycle.get_cycle_state() == ReceivingLiftCycle.State.CLOSING
		and wing.expeditions.ready_count + wing.expeditions.medical.active_count() == accounted,
		"last TAKE starts closing while the waiting crew stays unavailable")
	timeline.advance(runtime.lift_cycle.seconds_to_boundary() + 0.001)
	check(runtime.lift_cycle.is_busy() and runtime.receiving_manager.get_active_batch_id() == retired_id
		and wing.expeditions.ready_count + wing.expeditions.medical.active_count() == accounted, "no admission during outbound turnaround")
	timeline.advance(runtime.lift_cycle.seconds_to_boundary() + 0.01)
	check(runtime.receiving_manager.get_active_batch_id() != retired_id
		and wing.expeditions.ready_count + wing.expeditions.medical.active_count() == accounted + 1
		and wing.expeditions.journeys[waiting].status == Ops.COMPLETE, "full turnaround promotes FIFO and admission releases the waiting crew")
	open_machine()
	carry.select_index(carry.get_slots().find(retired_item))
	await key_tap(KEY_E)
	var state := Snapshot.new().capture(wing)
	check(not state.items.has(retired_item.instance_id) and state.incinerator.receipts.back().item_id == retired_item.instance_id,
		"new disposal after batch retirement is a separate receipt")
	var invalid := state.duplicate(true)
	invalid.incinerator.receipts.pop_back()
	check(Snapshot.new().validate(invalid).contains("no exact owner"), "retired cargo without its terminal receipt still rejects")
	invalid = state.duplicate(true)
	invalid.incinerator.receipts[1].definition_id = "loot_000001"
	check(not Snapshot.new().validate(invalid).is_empty(), "known but mismatched seed definition rejects")
	print("INCINERATOR_CONGESTION carry_start=20 free_for_take=", required, " destroyed_seed_count=", seed_receipt_ids.size(),
		" ready_or_recovering_before=", accounted, " ready_after_admission=", wing.expeditions.ready_count)
	return roundtrip("retired and newly disposed cargo with exact ongoing expedition history")

func prove_goal() -> bool:
	var shelves: Array[Node] = wing.get_functional_surfaces()
	for surface: StorageSurface in shelves:
		surface.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
	for item: ItemInstance in carry.get_items():
		check(store(item, shelves) != null, "remaining carried stock can use ordinary shelving")
	var goal: RefCounted = wing.collection_goal
	var last: ItemInstance
	var shelf: StorageSurface
	for world: Node in wing.get_node("DevelopmentSetup/SeedItems").find_children("WorldItem", "", true, false):
		var candidate := world as WorldItem
		var item := candidate.get_item_instance()
		if goal.totals[item.get_storage_category()] >= goal.target:
			continue
		if candidate.pickup_into(carry):
			shelf = store(item, shelves)
			if not check(shelf != null, "ordinary store retains space for authored goal stock"):
				return false
			last = item
		if goal.completed:
			break
	if not check(goal.completed and last != null, "authored stock reaches the same provisional victory target"):
		return false
	var won: float = goal.first_completion_at
	var totals: Dictionary = goal.totals.duplicate()
	var category := last.get_storage_category()
	check(stored_world(shelf, last).pickup_into(carry), "retrieve exact qualifying stock before disposal")
	totals[category] -= last.get_utility_value()
	check(goal.totals == totals, "only retrieval subtracts the item's Utility")
	open_machine()
	carry.select_index(carry.get_slots().find(last))
	await key_tap(KEY_E)
	check(goal.totals == totals and goal.completed and goal.first_completion_at == won, "incineration leaves all totals and first victory unchanged")
	return roundtrip("after victory and disposal of previously scored stock") \
		and check(wing.collection_goal.totals == totals and wing.collection_goal.first_completion_at == won,
			"Continue keeps live totals and original victory time")

func prove_warning_saves() -> bool:
	if not check(shell.start_new_run(), "another isolated New Run starts"):
		return false
	bind_run()
	check(not wing.incinerator.warning_shown and wing.incinerator.capture_state().receipts.is_empty(), "independent New Run resets both disposal fields")
	var world: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/Hydration_FoodCan/WorldItem")
	var item := world.get_item_instance()
	check(world.pickup_into(carry), "normal pickup for warning save")
	open_machine()
	await key_tap(KEY_E)
	timeline.advance(60.0)
	shell._process(0.0)
	var automatic: Dictionary = service.load_snapshot().snapshot
	check(panel._warning.visible and automatic.incinerator.warning_shown and automatic.incinerator.receipts.is_empty()
		and automatic.carry.slots == [item.instance_id] and automatic.timeline.last_auto_attempt_at == 60.0,
		"automatic snapshot under the live warning persists only the shown flag and intact carry")
	panel._back_button.pressed.emit()
	if not roundtrip("after Back"):
		return false
	check(not panel.is_open() and wing.incinerator.warning_shown and carry.get_selected_item().instance_id == item.instance_id,
		"Back restoration preserves the item and one-time flag")
	if not check(shell.save_and_exit() and service.save_snapshot(automatic).ok and shell.continue_run(),
			"Continue the isolated automatic snapshot captured while warning was visible"):
		return false
	bind_run()
	check(not panel.is_open() and not panel._warning.visible and panel._pending_item == null
		and carry.get_selected_item().instance_id == item.instance_id and wing.incinerator.warning_shown,
		"warning state restores without reopening or replaying the command")
	return true

func prove_compatibility(path: String, old: Dictionary) -> void:
	var collection := path.path_join("collection")
	DirAccess.make_dir_recursive_absolute(collection)
	var m4 := path.path_join("Save_m4.json")
	var five := collection.path_join("Save_foundation.json")
	var six := collection.path_join("Save_expedition.json")
	var pointer := collection.path_join(SaveService.POINTER)
	var files := {m4: Codec.new().stringify({"schema": 4}), five: Codec.new().stringify({"schema": 5}), six: Codec.new().stringify(old)}
	for file: String in files:
		write_text(file, files[file])
	write_text(path.path_join(SaveService.POINTER), JSON.stringify({"snapshot": m4.get_file()}))
	write_text(pointer, JSON.stringify({"snapshot": six.get_file()}))
	var original_pointer := FileAccess.get_sha256(pointer)
	shell.free()
	open_shell(collection)
	check(shell.continue_button.disabled and shell.status_label.text.contains("schema 6") and shell.status_label.text.contains("preserved"),
		"launch explains the incompatible expedition continuation")
	check(not shell.continue_run() and shell.wing == null and FileAccess.get_sha256(pointer) == original_pointer,
		"attempting Continue leaves the old pointer intact")
	shell.request_new_run()
	shell.cancel_new_run()
	check(FileAccess.get_sha256(pointer) == original_pointer, "canceling New Run preserves the incompatible pointer")
	shell.request_new_run()
	shell.confirm_new_run()
	check(shell.wing != null and FileAccess.get_sha256(pointer) != original_pointer and service.load_snapshot().snapshot.schema == Snapshot.SCHEMA,
		"confirmed New Run repoints to the current schema")
	for file: String in files:
		check(FileAccess.get_file_as_string(file) == files[file], "older snapshot remains byte-for-byte intact")

func depart(a: String, b: String) -> String:
	var ops: RefCounted = wing.expeditions
	check(ops.toggle_affinity(a) and ops.toggle_affinity(b), "select free expedition destination")
	ops.rng.seed = 8901
	var result: Dictionary = ops.dispatch(ops.revision)
	check(result.ok, "normal departure commits")
	return result.get("id", "")

func open_machine() -> void:
	player.global_position = wing.get_node("Environment/Greybox/Anchors/IncineratorFront").global_position
	player.camera.look_at(player.incinerator_station.global_position)
	player.incinerator_requested.emit() # Headless mouse capture is unavailable.
	check(panel.is_open(), "player at the station opens the Incinerator")

func store(item: ItemInstance, shelves: Array[Node]) -> StorageSurface:
	placement.set_suppressed(false)
	for surface: StorageSurface in shelves:
		if put(item, surface):
			return surface
	return null

func write_text(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value)
	file.close()

func open_shell(directory: String) -> void:
	service = SaveService.new(directory)
	shell = Shell.instantiate()
	shell.save_service = service
	root.add_child(shell)
	current_scene = shell
	shell.set_process(false)

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
	panel = wing.incinerator_panel

func roundtrip(label: String) -> bool:
	var before := Snapshot.new().capture(wing)
	if not check(shell.save_and_exit(), "Save & Exit " + label + " " + shell.pause_status.text):
		return false
	if not check(shell.continue_run(), "normal Continue " + label + " " + shell.status_label.text):
		return false
	bind_run()
	return check(Snapshot.new().capture(wing) == before, "exact logical round-trip " + label)

func check(ok: bool, message: String) -> bool:
	checks += 1
	return super.check(ok, message)

func finish() -> void:
	current_scene = null
	shell.free()
	print("incinerator_continuation_tests: ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(0 if failures == 0 else 1)
