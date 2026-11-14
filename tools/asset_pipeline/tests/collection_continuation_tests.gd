extends SceneTree

const ShellScene = preload("res://gameplay/run/run_shell.tscn")
const SaveService = preload("res://gameplay/run/run_save_service.gd")
const Snapshot = preload("res://gameplay/run/run_snapshot.gd")
const TestSeeds = preload("res://tools/asset_pipeline/tests/expedition_test_support.gd")
const Codec = preload("res://gameplay/run/state_codec.gd")
const Ops = preload("res://gameplay/expeditions/expedition_operations.gd")

class MeasuredSaveService extends "res://gameplay/run/run_save_service.gd":
	var attempts := 0
	func save_snapshot(state: Dictionary, local_time: Dictionary = {}) -> Dictionary:
		attempts += 1
		return super.save_snapshot(state, local_time)

var failures := 0
var checks := 0
var shell: Node
var wing: Node3D
var runtime: ReceivingRuntime
var cycle: ReceivingLiftCycle
var timeline: RefCounted
var ops: RefCounted
var player: CharacterBody3D
var carry: CarriedItems
var stock: StorageSurface
var service: MeasuredSaveService

func _initialize() -> void:
	create_timer(180).timeout.connect(func(): quit(3))
	run.call_deferred()

func run() -> void:
	var path := OS.get_temp_dir().path_join("expedition-continuation-" + Crypto.new().generate_random_bytes(8).hex_encode())
	var older := path.path_join("Save_m4.json")
	var directory := path.path_join("collection")
	var foundation := directory.path_join("Save_receiving.json")
	var pointer := directory.path_join(SaveService.POINTER)
	DirAccess.make_dir_recursive_absolute(directory)
	write(path.path_join(SaveService.POINTER), JSON.stringify({"snapshot": older.get_file()}))
	write(older, Codec.new().stringify({"schema": 4}))
	write(pointer, JSON.stringify({"snapshot": foundation.get_file()}))
	write(foundation, Codec.new().stringify({"schema": 10}))
	var foundation_hash := FileAccess.get_sha256(foundation)
	var pointer_hash := FileAccess.get_sha256(pointer)
	var legacy_hash := FileAccess.get_sha256(older)
	service = MeasuredSaveService.new(directory)
	open_shell()
	check(shell.continue_button.disabled and shell.status_label.text.contains("schema 10") and shell.status_label.text.contains("Legacy M4"),
		"launch explains both incompatible continuations")
	check(not shell.continue_run() and shell.wing == null and shell.launch.visible and FileAccess.get_sha256(pointer) == pointer_hash
		and FileAccess.get_sha256(foundation) == foundation_hash, "failed Continue preserves the older slot exactly")
	check(SaveService.new().directory.replace("\\", "/").ends_with("/saves/collection"), "normal namespace is unchanged")
	var blocked := foundation.path_join("blocked")
	service.directory = blocked
	check(not shell.start_new_run() and shell.wing == null, "failed initial save never publishes a candidate")
	service.directory = directory
	shell.request_new_run()
	check(shell.confirmation.visible and shell.wing == null, "an existing slot requires New Run confirmation")
	shell.cancel_new_run()
	check(FileAccess.get_sha256(pointer) == pointer_hash, "cancelling New Run leaves the original pointer")
	shell.request_new_run()
	shell.confirm_new_run()
	if not check(shell.wing != null and FileAccess.get_sha256(foundation) == foundation_hash, "confirmed New Run preserves the incompatible snapshot file"):
		finish()
		return
	bind_run()
	var run_id: String = wing.run_identity.run_id
	check(timeline.clock.elapsed == 0.0 and ops.ready_count == 8 and cycle.get_cycle_state() == 0, "normal New Run starts with an unreserved roster and sealed lift")
	ops.set_members(3)
	ops.toggle_affinity("Morale")
	timeline.advance(59.75)
	if not roundtrip("uncommitted single-affinity draft"):
		finish()
		return
	check(ops.members == 3 and ops.affinities == ["Morale"] and not ops.is_formed() and ops.ready_count == 8,
		"Continue restores draft exactly without forming it")
	var attempts := service.attempts
	shell._process(0.0)
	check(service.attempts == attempts, "manual save preserves the automatic interval")
	timeline.advance(0.25)
	shell._process(0.0)
	check(service.attempts == attempts + 1 and service.load_snapshot().snapshot.timeline.last_auto_attempt_at == 60.0,
		"one automatic attempt at 60 active seconds")
	check(runtime.receiving_manager.get_active_batch() == null, "no automatic foundation hauls in normal play")

	ops.set_members(1)
	check(supply("loot_000008"), "a real palette item forms the first crew")
	if not roundtrip("locked partial preparation"):
		finish()
		return
	check(ops.ready_count == 7 and ops.is_formed() and ops.loadout.spent.size() == 1 and ops.return_capacity() == 22,
		"formation, whole receipt and partial capacity survive Continue")
	var first := depart("Food", "Fuel", 8901, true)
	var second := depart("Hydration", "Medical", 8901, true)
	var third := depart("Morale", "Weapons", 8901, true)
	var fourth := depart("Protection", "Electronics", 8901, true)
	if [first, second, third, fourth].has(""):
		finish()
		return
	var away := Snapshot.new().capture(wing)
	check(away.expeditions.away_cargo.size() == 4 and away.receiving.admission.returns.is_empty() and ops.ready_count == 4,
		"four exact Away commitments are owned by Expedition before return")
	var malformed := away.duplicate(true)
	malformed.expeditions.ready += 1
	check(not Snapshot.new().validate(malformed).is_empty(), "malformed personnel ledger is rejected")
	malformed = away.duplicate(true)
	malformed.expeditions.journeys[second].destination = away.expeditions.journeys[first].destination
	check(not Snapshot.new().validate(malformed).is_empty(), "overlapping destination occupancies are rejected")
	malformed = away.duplicate(true)
	malformed.expeditions.config.bulk_per_member += 1
	check(not Snapshot.new().validate(malformed).is_empty(), "old commitments cannot adopt changed test parameters")
	malformed = away.duplicate(true)
	malformed.receiving.manager.batches.append(away.expeditions.away_cargo[ops.journeys[first].batch_id])
	check(not Snapshot.new().validate(malformed).is_empty(), "Away cargo cannot also appear as a deposit")
	if not roundtrip("four Away journeys"):
		finish()
		return
	check(ops.destination_busy(ops.journeys[fourth].destination), "restored Away journey still occupies its destination")
	var return_at: float = ops.journeys[first].return_at
	var arrival_at := return_at + 0.125
	while timeline.clock.elapsed < arrival_at:
		timeline.advance(minf(0.25, arrival_at - timeline.clock.elapsed))
	var ordinary: Dictionary = ops.capture_state()
	var queue: PackedStringArray = runtime.receiving_manager.get_queued_batch_ids()
	var active: String = runtime.receiving_manager.get_active_batch_id()
	check(shell.save_and_exit() and service.save_snapshot(away).ok and shell.continue_run(), "isolated rewind repeats the same committed timing test")
	bind_run()
	var observed_errors: Array[String] = []
	runtime.receiving_manager.contents_changed.connect(func():
		observed_errors.append(Snapshot.new().validate(Snapshot.new().capture(wing))))
	timeline.advance(arrival_at - timeline.clock.elapsed)
	check(observed_errors == ["", "", ""], "active and queued deposit observers see valid snapshots during tied returns")
	check(ops.capture_state() == ordinary and runtime.receiving_manager.get_active_batch_id() == active
		and runtime.receiving_manager.get_queued_batch_ids() == queue, "large step and ordinary frames agree on the tied return order")
	check(active == ops.journeys[first].batch_id and queue == PackedStringArray([ops.journeys[second].batch_id, ops.journeys[third].batch_id])
		and ops.journeys[fourth].status == Ops.WAITING, "ties admit by dispatch identity, with the fourth crew Awaiting Lift")
	check(ops.ready_count + ops.medical.active_count() == 7
		and ops.journeys[first].handover_at == return_at and ops.journeys[third].handover_at == return_at,
		"active and queued deposits release personnel at the committed timestamp")
	var held := cycle.capture_state()
	check(cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL and absf(held.elapsed - 0.125) < 0.00001,
		"split time preserves fractional mid-arrival")
	await physics_frame
	await process_frame
	shell.set_menu_open(true)
	player._open_zone_editor_for_surface(stock)
	shell.set_menu_open(false)
	timeline.advance(5.0)
	check(paused and player.world_input_blocked and cycle.capture_state() == held and timeline.clock.elapsed == arrival_at,
		"zoning holds lift and expedition time after menu pause releases")
	check(cycle.get_node("Arrival").stream_paused, "nested pause holds arrival audio")
	shell.set_menu_open(true)
	player._zone_editor.close_editor()
	check(paused and shell.pause_owners.has("menu"), "closing zoning retains the other pause owner")
	shell.set_menu_open(false)
	check(not paused and not cycle.get_node("Arrival").stream_paused, "last pause owner resumes audio and time")
	if not roundtrip("mid-ARRIVAL with a waiter"):
		finish()
		return
	check(cycle.capture_state() == held, "mid-arrival lift deadline restores exactly")

	var same_pair: String = ops.journeys[fourth].destination
	check(not ops.destination_busy(same_pair), "return releases destination while the crew waits")
	var repeated := depart("Electronics", "Protection", 8902)
	if repeated.is_empty():
		finish()
		return
	timeline.advance(ops.journeys[repeated].return_at - timeline.clock.elapsed)
	check(ops.journeys[repeated].status == Ops.WAITING and ops.journeys[fourth].status == Ops.WAITING
		and ops.journeys[repeated].destination == same_pair and ops.ready_count + ops.medical.active_count() == 6,
		"two distinct crews can await handover from the same destination")
	if not roundtrip("two same-destination waiters and two deposited crews"):
		finish()
		return
	check(cycle.can_take_receiving() and runtime.return_admission.get_awaiting_returns().size() == 2, "deposited and upstream owners restore separately")

	var lift_before := runtime.capture_state()
	for definition in ["loot_000010", "loot_000020", "loot_000035"]:
		check(supply(definition), "partial-provision recipe uses authored item " + definition)
	check(ops.return_capacity() == 18, "partial provisions charge the full outgoing Bulk")
	var supplied := depart("Food", "Weapons", 8903)
	if supplied.is_empty() or not roundtrip("supplied crew Away while lift is congested"):
		finish()
		return
	timeline.advance(ops.journeys[supplied].return_at - timeline.clock.elapsed)
	check(ops.journeys[supplied].status == Ops.WAITING and not ops.destination_busy(ops.journeys[supplied].destination),
		"later supplied return joins the waiting queue and frees its destination")
	check(runtime.capture_state().manager == lift_before.manager and cycle.can_take_receiving(),
		"additional waiters leave the occupied lift and deposited queue intact")

	var first_world: WorldItem = runtime.deck_presenter.get_materialized_world_items()[0]
	var released_id := first_world.get_item_instance().instance_id
	check(take_and_store(first_world), "an actual expedition item transfers into qualifying stock")
	var consumed := ""
	for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		var item := world.get_item_instance()
		if ops.preview(item).status == "eligible" and world.pickup_into(carry):
			carry.select_index(carry.get_slots().find(item))
			if ops.contribute(carry).ok:
				consumed = item.instance_id
			break
	check(not consumed.is_empty(), "a released expedition item is spent while its batch is still present")
	stock.set_custom_display_name("Committed stock")
	stock.clear_all_zones()
	check(take_seed("Book") and take_seed("Book2"), "loose starting palette still supplies carried items")
	carry.select_index(1)
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
	if not roundtrip("released cargo, receipt, zoning and ladder pose"):
		finish()
		return
	check(carry.get_selected_index() == 1 and player.is_ladder_attached(), "selected carry and ladder pose restore")
	check(wing.get_node_or_null("DevelopmentSetup/SeedItems/Book") == null and stock.get_stored_items()[0].instance_id == released_id,
		"Continue keeps stored identity and does not reseed carried hosts")
	var saved := Snapshot.new().capture(wing)
	var malformed_owner := saved.duplicate(true)
	var shelf: Dictionary = malformed_owner.surfaces[String(wing.get_path_to(stock))]
	shelf.stacks.clear()
	shelf.reservations.clear()
	shelf.cells.fill("")
	malformed_owner.items.erase(released_id)
	check(not Snapshot.new().validate(malformed_owner).is_empty(), "a released item with neither a live owner nor a receipt is rejected")
	if not consumed.is_empty():
		var duplicate := saved.duplicate(true)
		duplicate.expeditions.draft.loadout.spent.append(duplicate.expeditions.draft.loadout.spent[0])
		check(not Snapshot.new().validate(duplicate).is_empty(), "duplicate consumption receipt is rejected")
		var resurrected := saved.duplicate(true)
		resurrected.items[consumed] = {"definition": ops.loadout.spent[0].definition_id, "contaminated": false}
		resurrected.carry.slots.append(consumed)
		check(not Snapshot.new().validate(resurrected).is_empty(), "spent cargo cannot reappear in carrying")
	stock.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, stock.get_grid_size() - Vector2i.ONE)
	for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		check(take_and_store(world), "take remaining active cargo into normal storage")
	if not check(cycle.get_cycle_state() == ReceivingLiftCycle.State.CLOSING, "last TAKE starts closing") or not roundtrip("closing"):
		finish()
		return
	var closing_remaining := cycle.seconds_to_boundary()
	timeline.advance(closing_remaining - 0.125)
	check(cycle.get_cycle_state() == ReceivingLiftCycle.State.CLOSING, "closing keeps its original deadline")
	timeline.advance(0.375)
	if not check(cycle.get_cycle_state() == ReceivingLiftCycle.State.SEALED_EMPTY and cycle.is_busy(), "outbound retains active ownership") or not roundtrip("outbound"):
		finish()
		return
	timeline.advance(cycle.seconds_to_boundary() - 0.125)
	check(runtime.receiving_manager.get_active_batch_id() == active, "no promotion before full outbound")
	var available_or_recovering: int = ops.ready_count + ops.medical.active_count()
	var observed_delayed: Array[String] = []
	runtime.receiving_manager.contents_changed.connect(func():
		if runtime.return_admission.get_return_status(fourth) == AwaitingLiftAdmission.ADMITTED_RETURNED:
			observed_delayed.append(Snapshot.new().validate(Snapshot.new().capture(wing))))
	timeline.advance(50.125)
	check(observed_delayed == [""], "delayed deposit notification sees settled cargo and personnel")
	check(runtime.receiving_manager.get_active_batch_id() == ops.journeys[second].batch_id and cycle.can_take_receiving()
		and runtime.receiving_manager.get_queued_batch_ids() == PackedStringArray([ops.journeys[third].batch_id, ops.journeys[fourth].batch_id]),
		"oldest waiter admits behind existing deposits after the full outbound")
	check(ops.ready_count + ops.medical.active_count() == available_or_recovering + 1
		and ops.journeys[fourth].status == Ops.COMPLETE and ops.journeys[repeated].status == Ops.WAITING,
		"delayed deposited admission releases only the oldest crew")
	var before_duplicate: Dictionary = ops.capture_state()
	runtime.return_admission.return_admitted_after_waiting.emit(fourth, ops.journeys[fourth].batch_id)
	check(ops.capture_state() == before_duplicate, "duplicate handover callback is inert")
	if not roundtrip("completed nonempty handover after waiting"):
		finish()
		return

	if not prove_victory_and_failed_save(path):
		finish()
		return
	check(wing.run_identity.run_id == run_id and FileAccess.get_sha256(foundation) == foundation_hash
		and FileAccess.get_sha256(older) == legacy_hash, "successor identity stable and incompatible save files byte-identical")
	finish()

func prove_victory_and_failed_save(path: String) -> bool:
	for item: ItemInstance in carry.get_items():
		check(put_carried(item), "carry proof items move to qualifying stock")
	var goal: RefCounted = wing.collection_goal
	var categories: Array = goal.CATEGORIES
	var last: WorldItem
	for category: String in categories:
		if goal.totals[category] >= goal.target:
			continue
		var choices: Array[WorldItem] = []
		for world: Node in wing.get_node("DevelopmentSetup/SeedItems").find_children("WorldItem", "", true, false):
			var candidate := world as WorldItem
			if candidate != null and candidate.get_item_instance().get_storage_category() == category:
				choices.append(candidate)
		choices.sort_custom(func(a: WorldItem, b: WorldItem): return a.get_bulk() < b.get_bulk())
		for candidate: WorldItem in choices:
			if last == null and candidate.get_item_instance().get_utility_value() + goal.totals[category] >= goal.target:
				last = candidate
				break
			if take_and_store(candidate) and goal.totals[category] >= goal.target:
				break
	if not check(last != null and not goal.completed, "ordinary storage leaves a final qualifying contribution"):
		return false
	var final_item := last.get_item_instance()
	var final_id := final_item.instance_id
	var final_category := final_item.get_storage_category()
	var final_host := String(last.get_parent().name)
	var solo := Snapshot.new().capture(wing)
	solo.timeline.last_auto_attempt_at = solo.timeline.elapsed
	var victory_only := SaveService.new(path.path_join("victory-only"))
	check(victory_only.save_snapshot(solo).ok, "pre-victory isolated save starts a new interval")
	timeline.advance(61.0)
	var won_at: float = timeline.clock.elapsed
	if not check(take_and_store(last) and goal.completed, "storing the last category wins with live stock"):
		return false
	var attempts := service.attempts
	shell._process(0.0)
	var won: Dictionary = service.load_snapshot().snapshot
	check(service.attempts == attempts + 1 and won.goal.first_completion_at == won_at and won.timeline.last_auto_attempt_at == won_at,
		"first victory and overdue interval coalesce")
	shell._process(0.0)
	check(service.attempts == attempts + 1, "victory is attempted once")
	var active_path: String = service.load_snapshot().path
	var valid_hash := FileAccess.get_sha256(active_path)
	var blocker := service.directory.path_join(".m1-snapshot.tmp")
	write(blocker, "intentional isolated write blocker")
	timeline.advance(61.0)
	attempts = service.attempts
	shell._process(0.0)
	check(service.attempts == attempts + 1 and FileAccess.get_sha256(active_path) == valid_hash and wing._collection_hud._notice.visible,
		"failed automatic save preserves the last valid continuation")
	timeline.advance(1.0)
	shell._process(0.0)
	check(service.attempts == attempts + 1 and not shell.save_and_exit() and shell.wing == wing and paused,
		"failure waits for the normal interval and failed Save & Exit keeps the run paused")
	DirAccess.remove_absolute(blocker)
	shell.set_menu_open(false)
	timeline.advance(59.0)
	shell._process(0.0)
	check(not wing._collection_hud._notice.visible and service.load_snapshot().ok, "next normal attempt clears the save warning")
	check(retrieve_stored(final_id) and goal.totals[final_category] < goal.target and goal.first_completion_at == won_at,
		"stock removal lowers a live category while keeping the first completion")
	if not roundtrip("completed run below a live target"):
		return false
	attempts = service.attempts
	shell._process(0.0)
	check(wing.collection_goal.completed and wing.collection_goal.first_completion_at == won_at and service.attempts == attempts,
		"completed run does not replay first-victory saving")
	if not check(shell.save_and_exit(), "save completed run before the isolated first-victory check"):
		return false
	service.directory = victory_only.directory
	if not check(shell.continue_run(), "restore isolated pre-victory checkpoint"):
		return false
	bind_run()
	var final_world := wing.get_node("DevelopmentSetup/SeedItems/" + final_host + "/WorldItem") as WorldItem
	check(final_world.get_item_instance().instance_id == final_id and take_and_store(final_world), "same final item completes the isolated run")
	attempts = service.attempts
	shell._process(0.0)
	check(service.attempts == attempts + 1 and service.load_snapshot().snapshot.goal.completed, "first victory saves inside the 60-second interval")
	var after_victory := depart("Food", "Hydration", 9050)
	if after_victory.is_empty() or not roundtrip("post-victory departure"):
		return false
	timeline.advance(ops.journeys[after_victory].return_at - timeline.clock.elapsed)
	check(wing.collection_goal.completed and ops.journeys[after_victory].status != Ops.AWAY,
		"post-victory active time still settles real expedition returns")
	print("EXPEDITION_SAVE_WITNESS won_at=", won_at, " validation_ms=", service.last_validation_ms)
	return true

func retrieve_stored(id: String) -> bool:
	for surface: StorageSurface in wing.get_functional_surfaces():
		var stack := surface.get_storage_stack(surface.get_stack_id_for_item(id))
		if stack == null:
			continue
		for entry: StorageStack.Entry in stack.entries:
			if entry.item.instance_id == id:
				return entry.world_item.pickup_into(carry)
	return false

func open_shell() -> void:
	shell = ShellScene.instantiate()
	shell.save_service = service
	root.add_child(shell)
	shell.set_process(false)

func bind_run() -> void:
	wing = shell.wing
	wing.set_process(false)
	runtime = wing.get_node("ReceivingRuntime")
	cycle = runtime.lift_cycle
	timeline = wing.run_timeline
	ops = wing.expeditions
	player = wing.get_node("Player")
	player.set_process(false)
	player.set_physics_process(false)
	carry = player.carried_items
	stock = wing.get_functional_surfaces()[1]

func roundtrip(phase: String) -> bool:
	var original := Snapshot.new().capture(wing)
	if not check(shell.save_and_exit() and not shell.continue_button.disabled, "Save & Exit " + phase + " " + shell.pause_status.text):
		return false
	if not check(shell.continue_run(), "Continue " + phase + " " + shell.status_label.text):
		return false
	bind_run()
	var restored := Snapshot.new().capture(wing)
	if original != restored:
		for key: String in original:
			if original[key] != restored.get(key):
				print("ROUNDTRIP_DIFFERENCE ", phase, " key=", key)
	return check(original == restored, "exact ownership and continuation " + phase)

func select_pair(first: String, second: String) -> void:
	for category: String in ops.affinities.duplicate():
		ops.toggle_affinity(category)
	check(ops.toggle_affinity(first) and ops.toggle_affinity(second), "select available pair " + first + " + " + second)

func depart(first: String, second: String, seed: int, tied: bool = false) -> String:
	select_pair(first, second)
	if tied:
		ops.rng.seed = seed
	else:
		ops.rng.seed = TestSeeds.find_seed(ops, runtime, TestSeeds.all_healthy, seed)
	var result: Dictionary = ops.dispatch(ops.revision)
	check(result.ok, "departure commits: " + str(result.get("error", "")))
	return result.get("id", "")

func supply(definition: String) -> bool:
	for world: Node in wing.get_node("DevelopmentSetup/SeedItems").find_children("WorldItem", "", true, false):
		var item := (world as WorldItem).get_item_instance()
		if String(item.definition.item_id) != definition:
			continue
		if (world as WorldItem).pickup_into(carry):
			carry.select_index(carry.get_slots().find(item))
			return ops.contribute(carry).ok
	return false

func take_seed(host: String) -> bool:
	var world := wing.get_node_or_null("DevelopmentSetup/SeedItems/" + host + "/WorldItem") as WorldItem
	return world != null and world.pickup_into(carry)

func take_and_store(world: WorldItem) -> bool:
	var item := world.get_item_instance()
	return world.pickup_into(carry) and put_carried(item)

func put_carried(item: ItemInstance) -> bool:
	carry.select_index(carry.get_slots().find(item))
	var placement: StoragePlacementController = player._storage_placement
	placement.set_suppressed(false)
	for surface: StorageSurface in [stock, wing.get_functional_surfaces()[2], wing.get_functional_surfaces()[3]]:
		surface.initialize_zones_if_needed(StorageCategories.GENERAL)
		placement._current_surface = surface
		if placement.place_selected():
			return true
	return false

func escape_event(pressed: bool) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = pressed
	return event

func write(path: String, data: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)
	file.close()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok

func finish() -> void:
	if is_instance_valid(shell):
		shell.free()
	print("collection_continuation_tests: ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(0 if failures == 0 else 1)
