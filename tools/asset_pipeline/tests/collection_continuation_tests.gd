extends SceneTree

const ShellScene = preload("res://gameplay/run/run_shell.tscn")
# Keep the production scene cached across the in-process relaunch.
const WingScene = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
const SaveService = preload("res://gameplay/run/run_save_service.gd")
const Snapshot = preload("res://gameplay/run/run_snapshot.gd")
const Codec = preload("res://gameplay/run/state_codec.gd")

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
var player: CharacterBody3D
var carry: CarriedItems
var stock: StorageSurface
var service: MeasuredSaveService

func _initialize() -> void:
	create_timer(180).timeout.connect(func(): quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok

func run() -> void:
	var path := OS.get_temp_dir().path_join("collection-proof-" + Crypto.new().generate_random_bytes(8).hex_encode())
	DirAccess.make_dir_recursive_absolute(path)
	var pointer := path.path_join(SaveService.POINTER)
	var snapshot := path.path_join("Save_legacy_fixture.json")
	write(pointer, JSON.stringify({"snapshot": snapshot.get_file()}))
	write(snapshot, Codec.new().stringify({"schema": 4}))
	var pointer_hash := FileAccess.get_sha256(pointer)
	var snapshot_hash := FileAccess.get_sha256(snapshot)
	var rejected: Dictionary = SaveService.new(path).load_snapshot()
	check(not rejected.ok and rejected.error.contains("Legacy M4"), "schema 4 rejects with a clear M4 explanation")
	check(SaveService.new().directory.replace("\\", "/").ends_with("/saves/collection"), "default saves use collection namespace")
	service = MeasuredSaveService.new(path.path_join("collection"))
	open_shell()
	check(shell.continue_button.disabled and shell.status_label.text.contains("Legacy M4"), "launch explains preserved legacy continuation")
	var destination := service.directory
	service.directory = path
	check(not shell.continue_run() and shell.wing == null and shell.launch.visible, "failed Continue leaves launch usable without publishing a replacement")
	service.directory = snapshot.path_join("blocked")
	check(not shell.start_new_run() and shell.wing == null, "failed initial save never publishes candidate")
	service.directory = destination
	if not check(shell.start_new_run(), "normal New Run saves then publishes the wing"):
		print(shell.status_label.text)
		finish()
		return
	bind_run()
	check(timeline.clock.elapsed == 0.0 and timeline.next_arrival == 0 and cycle.get_cycle_state() == 0, "loading and first save leave a coherent t=0")
	var run_id: String = wing.run_identity.run_id
	shell.request_new_run()
	check(shell.confirmation.visible and shell.wing == wing, "replacement explicitly asks for confirmation")
	shell.cancel_new_run()

	timeline.advance(3.125)
	check(cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL and cycle.capture_state().elapsed == 0.125, "exact mid-arrival checkpoint")
	await physics_frame
	await process_frame
	shell.set_menu_open(true)
	var held := cycle.capture_state()
	player._open_zone_editor_for_surface(stock)
	shell.set_menu_open(false)
	timeline.advance(5.0)
	check(paused and player.world_input_blocked and cycle.capture_state() == held and timeline.clock.elapsed == 3.125, "zoning holds world and time after ESC releases")
	check(cycle.get_node("Arrival").stream_paused, "zoning holds the arrival audio stream")
	shell.set_menu_open(true)
	player._zone_editor.close_editor()
	check(paused and shell.pause_owners.has("menu"), "closing zoning retains ESC pause")
	shell.set_menu_open(false)
	check(not paused and not cycle.get_node("Arrival").stream_paused and player._require_e_release, "last owner resumes same phase and re-arms input")

	# Start a fresh shell from the explicit save and preserve a deliberately
	# different, valid saved target to catch re-reading the default on Continue.
	if not check(shell.save_and_exit(), "Save & Exit writes ARRIVAL"):
		print(shell.pause_status.text)
		finish()
		return
	var mid: Dictionary = service.load_snapshot().snapshot
	check(mid.schema == 5 and mid.timeline.next_arrival == 1, "schema 5 stores active fixture progress")
	mid.goal.target = 5
	check(service.save_snapshot(mid).ok, "saved run can have a distinct common target")
	shell.free()
	await process_frame
	open_shell()
	if not check(shell.continue_run(), "relaunched shell continues the same ARRIVAL"):
		print(shell.status_label.text)
		finish()
		return
	bind_run()
	check(Snapshot.new().capture(wing) == mid and cycle.capture_state() == held and wing.collection_goal.target == 5, "exact arrival, run ID, target and revisions restore before activation")
	var arrival_remaining := cycle.seconds_to_boundary()
	timeline.advance(arrival_remaining - 0.125)
	check(cycle.get_cycle_state() == ReceivingLiftCycle.State.ARRIVAL, "arrival deadline has not restarted or fired early")
	timeline.advance(0.125 + 6.0)
	check(cycle.can_take_receiving(), "arrival completes at original deadline")

	await capture_rendered("receiving-open", true)
	var first: WorldItem = runtime.deck_presenter.get_materialized_world_items()[0]
	var first_id := first.get_item_instance().instance_id
	check(take_and_store(first), "controlled cargo TAKE followed by ordinary shelf placement")
	stock.set_custom_display_name("Committed stock")
	stock.clear_all_zones()
	check(take_selected_seed("Book") and take_selected_seed("Book2"), "original seed hosts transfer to carrying")
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

	timeline.advance(59.75 - timeline.clock.elapsed)
	for index in 2:
		var id := "continuation_pressure_%d" % index
		var batch := runtime.prepare_manifest(["loot_000019"], id, 5300 + index)
		check(runtime.return_admission.submit_return(id, batch) == (1 if index == 0 else 2), "one extra deposit, one waiter")
	if not roundtrip("partially unloaded OPEN with two deposits and a waiter"):
		finish()
		return
	check(carry.get_selected_index() == 1 and player.is_ladder_attached(), "selected carry and exact ladder attachment restore")
	check(wing.get_node_or_null("DevelopmentSetup/SeedItems/Book") == null and stock.get_stored_items()[0].instance_id == first_id, "no reseed, exact stored identity")
	check(runtime.deck_presenter.get_materialized_world_items().size() == 5 and cycle.can_take_receiving() and cycle.get_queued_batch_count() == 2, "OPEN gate and remaining cargo restored")
	check(runtime.return_admission.get_awaiting_returns().size() == 1 and stock.get_zone_cells_copy().count("") == stock.get_grid_size().x * stock.get_grid_size().y, "waiter and erased stock zoning persist")
	var lost := Snapshot.new().capture(wing)
	var lost_shelf: Dictionary = lost.surfaces[String(wing.get_path_to(stock))]
	lost_shelf.stacks.clear()
	lost_shelf.reservations.clear()
	lost_shelf.cells.fill("")
	lost.items.erase(first_id)
	check(not Snapshot.new().validate(lost).is_empty(), "released active cargo must still have its exact physical owner")
	var attempts := service.attempts
	shell._process(0.0)
	check(service.attempts == attempts, "Save & Exit preserves elapsed progress toward next attempt")
	timeline.advance(0.25)
	shell._process(0.0)
	check(service.attempts == attempts + 1 and service.load_snapshot().snapshot.timeline.last_auto_attempt_at == 60.0, "one automatic attempt at 60 active seconds across Continue")

	stock.set_zone_rect(StorageCategories.GENERAL, Vector2i.ZERO, stock.get_grid_size() - Vector2i.ONE)
	for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
		check(take_and_store(world), "store another exact A member")
	timeline.advance(0.75)
	if not check(cycle.get_cycle_state() == ReceivingLiftCycle.State.CLOSING, "last TAKE starts closing") or not roundtrip("closing"):
		finish()
		return
	var closing_remaining := cycle.seconds_to_boundary()
	var first_batch := runtime.receiving_manager.get_active_batch_id()
	timeline.advance(closing_remaining - 0.125)
	check(cycle.get_cycle_state() == ReceivingLiftCycle.State.CLOSING, "closing retains original remaining duration")
	timeline.advance(0.375)
	if not check(cycle.get_cycle_state() == ReceivingLiftCycle.State.SEALED_EMPTY and cycle.is_busy(), "outbound still owns A") or not roundtrip("outbound"):
		finish()
		return
	var outbound_remaining := cycle.seconds_to_boundary()
	timeline.advance(outbound_remaining - 0.125)
	check(runtime.receiving_manager.get_active_batch_id() == first_batch, "no early FIFO promotion")
	timeline.advance(50.125)
	check(runtime.receiving_manager.get_active_batch_id() != first_batch and cycle.can_take_receiving(), "B opens after full outbound")
	check(runtime.return_admission.get_awaiting_returns().is_empty() and cycle.get_queued_batch_count() == 2, "D admits behind C after A retires")
	var second_items: Array = runtime.deck_presenter.get_materialized_world_items()
	var last: WorldItem
	for world: WorldItem in second_items:
		if world.get_definition().item_id == &"loot_000083":
			last = world
		else:
			check(take_and_store(world), "store exact B member before Weapons")
	if not check(last != null and not wing.collection_goal.completed, "only final category remains"):
		finish()
		return
	var before_victory := Snapshot.new().capture(wing)
	# Keep an independent temp slot for the first-victory-only proof below.
	var victory_only := SaveService.new(path.path_join("victory-only"))
	var solo := before_victory.duplicate(true)
	solo.timeline.last_auto_attempt_at = solo.timeline.elapsed
	check(victory_only.save_snapshot(solo).ok, "pre-victory checkpoint has a fresh interval")

	timeline.advance(maxf(0.0, 120.0 - timeline.clock.elapsed) + 0.125)
	check(take_and_store(last) and wing.collection_goal.completed, "exact two-haul collection wins through the normal wing")
	var won_at: float = timeline.clock.elapsed
	await capture_rendered("collection-complete")
	attempts = service.attempts
	shell._process(0.0)
	var won: Dictionary = service.load_snapshot().snapshot
	check(service.attempts == attempts + 1 and won.goal.first_completion_at == won_at and won.timeline.last_auto_attempt_at == won_at, "interval plus first victory coalesce into one coherent save")
	shell._process(0.0)
	check(service.attempts == attempts + 1, "victory is attempted once")

	var bad := won.duplicate(true)
	bad.carry.slots.append(first_id)
	check(not service.save_snapshot(bad).ok and service.load_snapshot().snapshot == won, "duplicate physical ownership cannot replace a valid save")
	bad = won.duplicate(true)
	bad.timeline.next_arrival = 0
	check(not service.save_snapshot(bad).ok and service.load_snapshot().snapshot == won, "issued cargo cannot be replayed by invalid progress")

	var active_path: String = service.load_snapshot().path
	var valid_hash := FileAccess.get_sha256(active_path)
	var blocker := service.directory.path_join(".m1-snapshot.tmp")
	write(blocker, "intentional isolated write blocker")
	timeline.advance(180.0)
	attempts = service.attempts
	shell._process(0.0)
	check(service.attempts == attempts + 1 and FileAccess.get_sha256(active_path) == valid_hash and wing._collection_hud._notice.visible, "one overdue failed attempt preserves last valid bytes and warns nonmodally")
	timeline.advance(1.0)
	shell._process(0.0)
	check(service.attempts == attempts + 1, "failure does not retry next frame")
	check(not shell.save_and_exit() and shell.wing == wing and paused and player.world_input_blocked, "failed Save & Exit leaves the run paused")
	DirAccess.remove_absolute(blocker)
	shell.set_menu_open(false)
	timeline.advance(59.0)
	shell._process(0.0)
	check(not wing._collection_hud._notice.visible and service.load_snapshot().ok, "next normal attempt clears warning")

	var weapons := stored_by_definition(&"loot_000083")
	check(weapons != null and weapons.pickup_into(carry) and wing.collection_goal.totals.Weapons == 0, "removal after victory updates live storage")
	if not roundtrip("completed run with a category below target"):
		finish()
		return
	attempts = service.attempts
	shell._process(0.0)
	check(wing.collection_goal.completed and wing.collection_goal.first_completion_at == won_at and wing.collection_goal.totals.Weapons == 0 and service.attempts == attempts, "completed-run restore derives live totals and never replays the first victory save")
	check(wing.run_identity.run_id == run_id and FileAccess.get_sha256(pointer) == pointer_hash and FileAccess.get_sha256(snapshot) == snapshot_hash, "same successor identity and byte-identical original pointer and snapshot")

	shell.free()
	service.directory = victory_only.directory
	open_shell()
	if check(shell.continue_run(), "reload pre-victory checkpoint"):
		bind_run()
		for world: WorldItem in runtime.deck_presenter.get_materialized_world_items():
			check(take_and_store(world), "final Weapons commit in a fresh interval")
		attempts = service.attempts
		shell._process(0.0)
		check(service.attempts == attempts + 1 and service.load_snapshot().snapshot.goal.completed, "first victory saves before the 60-second interval")
	print("COLLECTION_SAVE_WITNESS run=", run_id, " won_at=", won_at)
	finish()

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
	player = wing.get_node("Player")
	player.set_process(false)
	player.set_physics_process(false)
	carry = player.carried_items
	stock = wing.get_functional_surfaces()[1]

func roundtrip(phase: String) -> bool:
	var original := Snapshot.new().capture(wing)
	if not check(shell.save_and_exit() and shell.launch.visible and not shell.continue_button.disabled, "ordinary Save & Exit " + phase):
		print(shell.pause_status.text)
		return false
	if not check(shell.continue_run(), "ordinary Continue " + phase):
		print(shell.status_label.text)
		return false
	bind_run()
	var restored := Snapshot.new().capture(wing)
	if original != restored:
		for key: String in original:
			if original[key] != restored.get(key):
				print("ROUNDTRIP_DIFFERENCE ", phase, " key=", key)
	return check(original == restored, "exact owner, pose, time and continuation state " + phase)

func take_and_store(world: WorldItem) -> bool:
	var item := world.get_item_instance()
	if not world.pickup_into(carry):
		return false
	carry.select_index(carry.get_slots().find(item))
	var placement: StoragePlacementController = player._storage_placement
	stock.initialize_zones_if_needed(StorageCategories.GENERAL)
	placement._current_surface = stock
	placement.set_suppressed(false)
	return placement.place_selected()

func stored_by_definition(id: StringName) -> WorldItem:
	for stack: StorageStack in stock._stacks.values():
		for entry: StorageStack.Entry in stack.entries:
			if entry.item.definition.item_id == id:
				return entry.world_item
	return null

func take_selected_seed(host: String) -> bool:
	var world: WorldItem = wing.get_node("DevelopmentSetup/SeedItems/" + host + "/WorldItem")
	return world.pickup_into(carry)

func capture_rendered(label: String, view_receiving: bool = false) -> void:
	var evidence := OS.get_environment("SORTING_COLLECTION_RENDER_DIR")
	if DisplayServer.get_name() == "headless" or evidence.is_empty():
		return
	var previous: Transform3D = player.camera.global_transform
	if view_receiving:
		player.camera.global_position = Vector3(-32.6, 1.75, 2.85)
		player.camera.look_at(Vector3(-36.5, 1.65, -0.5))
		var crt := wing.get_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface")
		check(crt.get_node("Status").text.contains("OPEN"), "rendered Receiving readout is OPEN")
	await process_frame
	await RenderingServer.frame_post_draw
	var pixels := root.get_texture().get_image()
	check(pixels != null and not pixels.is_empty() and pixels.save_png(evidence.path_join(label + ".png")) == OK, "rendered proof " + label)
	player.camera.global_transform = previous

func write(path: String, data: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)
	file.close()

func finish() -> void:
	if is_instance_valid(shell):
		shell.free()
	print("collection_continuation_tests: ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(0 if failures == 0 else 1)
