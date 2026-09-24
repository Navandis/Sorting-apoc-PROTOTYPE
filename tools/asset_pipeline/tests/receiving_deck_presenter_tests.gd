extends SceneTree

const CarriedItemsScript = preload("res://carried_items.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const PlayerControllerScript = preload("res://player_controller.gd")
const DeckSurfaceScript = preload("res://gameplay/logistics_wing/receiving/receiving_deck_surface.gd")
const DeckPresenterScript = preload("res://gameplay/logistics_wing/receiving/receiving_deck_presenter.gd")
const DeckPlannerScript = preload("res://receiving/receiving_deck_layout_planner.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootSourceScript = preload("res://receiving/prototype_loot_source.gd")
const ReceivingManagerScript = preload("res://receiving/receiving_manager.gd")
const StorageStackScript = preload("res://storage_stack.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")
const WorldItemScript = preload("res://world_item.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypeLootPool = preload("res://data/receiving/prototype_loot_pool.tres")
const ProofProfile = preload("res://data/receiving/receiving_deck_stage_b_proof.tres")
const RuntimeScene = preload("res://gameplay/logistics_wing/receiving/receiving_runtime.tscn")

class RejectingSurface extends Node:
	func remove_stack_entry(_stack_id: String, _item_key: String) -> bool:
		return false

var _failures: int = 0
var _pending_helpers: int = 0


func _init() -> void:
	call_deferred("_run_suite")


func _run_suite() -> void:
	_pending_helpers += 1
	_test_private_surface_disables_player_storage_interaction()
	_test_world_item_reach_kinds_and_success_signal()
	await _test_real_camera_ray_uses_receiving_range()
	await _test_presenter_exact_identity_visibility_release_and_close_boundary()
	await _test_reconstruction_after_released_base_compacts_without_replanning()
	await _test_fixture_reconstruction_reservation_and_empty_persistence()
	await _test_actual_main_deck_and_fixture_stacks_reject_manual_put()
	_test_fixture_stack_base_take_compacts()
	await _test_runtime_debug_delivery_is_explicit()
	_pending_helpers -= 1
	_finish()


func _test_private_surface_disables_player_storage_interaction() -> void:
	_pending_helpers += 1
	var ordinary: StorageSurface = StorageSurfaceScript.new()
	root.add_child(ordinary)
	ordinary.configure(&"ordinary", 1.0, 1.0, 0.10, 1.0)
	_check(ordinary.is_player_storage_interaction_enabled(), "ordinary storage interaction remains enabled by default")
	var ordinary_area := ordinary.get_node_or_null("StorageInteractionArea") as Area3D
	_check(ordinary_area != null and ordinary_area.collision_layer == StorageSurfaceScript.STORAGE_INTERACTION_LAYER, "ordinary storage target layer remains unchanged")
	ordinary.set_player_storage_interaction_enabled(false)
	_check(not ordinary.is_player_storage_interaction_enabled(), "generic storage opt-out records disabled state")
	_check(ordinary_area.collision_layer == 0 and not ordinary_area.monitorable, "disabled storage area cannot be targeted")

	var private_surface = DeckSurfaceScript.new()
	root.add_child(private_surface)
	var spec: Resource = ProofProfile.get("surfaces")[0]
	_check(private_surface.configure_from_spec(spec, float(ProofProfile.get("cell_size_m"))), "private proof surface configures")
	var backend: StorageSurface = private_surface.get_storage_surface()
	_check(backend != null, "private wrapper owns an ordinary StorageSurface backend")
	if backend != null:
		_check(not backend.is_player_storage_interaction_enabled(), "private backend opts out of PUT targeting")
		_check(not backend.is_normal_debug_visible() and not backend.is_developer_debug_visible(), "private backend exposes no normal or F6 grid")
		_check(not backend.are_zones_initialized(), "private backend has no zones")
		var area := backend.get_node_or_null("StorageInteractionArea") as Area3D
		_check(area != null and area.collision_layer == 0 and not area.monitorable, "private interaction area stays non-targetable")
	private_surface.free()
	ordinary.free()
	_pending_helpers -= 1


func _test_world_item_reach_kinds_and_success_signal() -> void:
	_pending_helpers += 1
	var definition: ItemDefinition = PersistentItemCatalog.get_definition_by_id(&"loot_000030")
	var loose_context: Dictionary = _world_item_host(definition, "Loose")
	var loose: WorldItem = loose_context["world_item"] as WorldItem
	loose.configure(loose_context["host"] as Node3D, definition)
	_check(loose.get_pickup_reach_kind() == WorldItemScript.PickupReachKind.LOOSE, "configure defaults to LOOSE reach")
	(loose_context["host"] as Node3D).free()

	var stored_item: ItemInstance = ItemInstanceScript.new(definition, "stored:item")
	var rejecting := RejectingSurface.new()
	root.add_child(rejecting)
	var stored_context: Dictionary = _world_item_host(definition, "Stored")
	var stored: WorldItem = stored_context["world_item"] as WorldItem
	stored.configure_existing(stored_context["host"], stored_item, rejecting, "stored_stack", stored_item.instance_id)
	_check(stored.get_pickup_reach_kind() == WorldItemScript.PickupReachKind.STORAGE, "configure_existing defaults to STORAGE reach")
	var received_signals: Array[ItemInstance] = []
	stored.picked_up.connect(func(item: ItemInstance) -> void: received_signals.append(item))
	var carried := CarriedItemsScript.new()
	carried.max_bulk = 999
	root.add_child(carried)
	_check(not stored.pickup_into(carried), "failed storage removal rolls carried transfer back")
	_check(carried.get_item_count() == 0 and received_signals.is_empty(), "failed pickup emits no success signal")
	(stored_context["host"] as Node3D).free()
	rejecting.free()

	var private_surface = DeckSurfaceScript.new()
	root.add_child(private_surface)
	var spec: Resource = ProofProfile.get("surfaces")[0]
	_check(private_surface.configure_from_spec(spec, float(ProofProfile.get("cell_size_m"))), "pickup private surface configures")
	var backend: StorageSurface = private_surface.get_storage_surface()
	var receiving_item: ItemInstance = ItemInstanceScript.new(definition, "receiving:item")
	var receiving_context: Dictionary = _world_item_host(definition, "Receiving")
	var receiving: WorldItem = receiving_context["world_item"] as WorldItem
	var pose := preload("res://storage_visual_pose.gd").measure_item(receiving_item, false)
	var stack_entry = StorageStackScript.create_entry(receiving_item, Vector2i(2, 2), false, pose["aligned_bounds"])
	stack_entry.host = receiving_context["host"]
	stack_entry.world_item = receiving
	var fit: Dictionary = {
		"valid": true, "placement_kind": "empty", "stack_id": "MainDeck:stack_0000",
		"origin": Vector2i(0, 0), "footprint": Vector2i(2, 2), "rotated": false,
		"host_y_m": backend.get_local_placement_position(Vector2i(0, 0), Vector2i(2, 2)).y,
	}
	_check(backend.commit_stack_entry(stack_entry, fit), "real private stack entry commits")
	receiving.configure_receiving(receiving_context["host"], receiving_item, backend, "MainDeck:stack_0000", receiving_item.instance_id)
	_check(receiving.is_stored_item(), "Receiving member remains mechanically stored")
	_check(receiving.get_pickup_reach_kind() == WorldItemScript.PickupReachKind.RECEIVING, "Receiving reach is independent from storage ownership")
	var receiving_signals: Array[ItemInstance] = []
	receiving.picked_up.connect(func(item: ItemInstance) -> void: receiving_signals.append(item))
	_check(receiving.pickup_into(carried), "real Receiving pickup succeeds")
	_check(carried.get_selected_item() == receiving_item, "pickup transfers exact ItemInstance")
	_check(receiving_signals == [receiving_item], "success signal emits exact identity once")
	_check(backend.get_stack_count() == 0, "success removes private stack entry before notification returns")
	private_surface.free()
	carried.free()
	_pending_helpers -= 1


func _test_real_camera_ray_uses_receiving_range() -> void:
	_pending_helpers += 1
	var player: CharacterBody3D = PlayerControllerScript.new()
	player.name = "Player"
	player.set("prototype_auto_register_known_loot", false)
	player.set("print_loot_registration", false)
	player.set("enable_held_item_view", false)
	player.set("interaction_distance", 1.4)
	player.set("storage_interaction_distance", 2.3)
	player.set("receiving_interaction_distance", 3.0)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	player.add_child(camera)
	var carried := CarriedItemsScript.new()
	carried.name = "CarriedItems"
	carried.max_bulk = 999
	player.add_child(carried)
	root.add_child(player)

	var definition: ItemDefinition = PersistentItemCatalog.get_definition_by_id(&"loot_000001")
	var item: ItemInstance = ItemInstanceScript.new(definition, "ray:item")
	var rejecting := RejectingSurface.new()
	root.add_child(rejecting)
	var context: Dictionary = _box_world_item_host("ReceivingRayTarget")
	var host: Node3D = context["host"] as Node3D
	host.position = Vector3(0.0, 0.0, -2.6)
	root.add_child(host)
	var world_item: WorldItem = context["world_item"] as WorldItem
	world_item.configure_receiving(host, item, rejecting, "ray_stack", item.instance_id)
	await physics_frame
	await physics_frame
	_check(player.call("_get_looked_at_world_item") == world_item, "real camera ray reaches Receiving target beyond normal storage reach")
	player.set("receiving_interaction_distance", 2.0)
	_check(player.call("_get_looked_at_world_item") == null, "same Receiving hit is rejected beyond configured Receiving range")
	host.free()
	rejecting.free()
	player.free()
	_pending_helpers -= 1


func _test_presenter_exact_identity_visibility_release_and_close_boundary() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _generated_prepared_batch("presenter_exact", 1842, 9001, 24)
	_check(batch != null, "presenter fixture prepares")
	if batch == null:
		_pending_helpers -= 1
		return
	var manager: ReceivingManager = ReceivingManagerScript.new()
	root.add_child(manager)
	var presenter = DeckPresenterScript.new()
	root.add_child(presenter)
	_check(presenter.configure(manager, PersistentItemCatalog, ProofProfile), "presenter configures real profile")
	_check(manager.deposit_batch(batch), "prepared fixture deposits")
	_check(presenter.present_active_batch(), "active fixture materializes")
	var remaining_before := _remaining_count(batch)
	var world_items: Array[WorldItem] = presenter.get_materialized_world_items()
	_check(world_items.size() == remaining_before, "every exact remaining entry materializes")
	_check(presenter.get_presentation_state() == DeckPresenterScript.PresentationState.HIDDEN, "materialized deck starts HIDDEN")
	var expected_ids: Dictionary = {}
	for entry: LootBatchEntry in batch.entries:
		if entry.remaining_in_batch:
			expected_ids[entry.item_instance_id] = true
	for world_item: WorldItem in world_items:
		var item := world_item.get_item_instance()
		_check(item != null and expected_ids.has(item.instance_id), "materialization preserves a durable identity")
		var area := world_item.get_node_or_null("PickupArea") as Area3D
		_check(area != null and area.collision_layer == 0 and not area.monitorable, "HIDDEN disables pickup target")
		var matching_entry := _entry_for_item(batch, item.instance_id)
		if matching_entry != null:
			var relative: Transform3D = presenter.global_transform.affine_inverse() * world_item.get_parent_node_3d().global_transform
			_check(relative.is_equal_approx(matching_entry.frozen_transform), "unreleased materialization matches frozen transform")

	presenter.reveal_active_batch()
	_check(presenter.get_presentation_state() == DeckPresenterScript.PresentationState.AVAILABLE, "reveal enters AVAILABLE")
	for world_item: WorldItem in world_items:
		var area := world_item.get_node_or_null("PickupArea") as Area3D
		_check(area != null and area.collision_layer == WorldItemScript.PICKUP_COLLISION_LAYER and area.monitorable, "AVAILABLE enables ordinary pickup target")

	var carried := CarriedItemsScript.new()
	carried.max_bulk = 99999
	root.add_child(carried)
	var first := world_items[0]
	var exact_first := first.get_item_instance()
	_check(first.pickup_into(carried), "first Receiving TAKE succeeds")
	_check(carried.get_selected_item() == exact_first, "TAKE transfers exact durable ItemInstance")
	_check(_remaining_count(batch) == remaining_before - 1, "successful TAKE releases one manager entry")
	_check(not presenter.call("_release_picked_entry", batch.batch_id, _entry_for_item(batch, exact_first.instance_id).entry_id, exact_first.instance_id), "duplicate callback cannot double-release")
	carried.remove_item(exact_first)

	for world_item: WorldItem in world_items.slice(1):
		var exact_item := world_item.get_item_instance()
		_check(world_item.pickup_into(carried), "remaining Receiving TAKE succeeds")
		carried.remove_item(exact_item)
	_check(batch.is_drained(), "final TAKE drains batch exactly once")
	_check(presenter.get_presentation_state() == DeckPresenterScript.PresentationState.DRAINED_WAITING_CLOSE, "final TAKE waits for explicit close")
	_check(manager.get_active_batch_id() == batch.batch_id, "drained active remains deposited")
	_check(presenter.retire_drained_active_after_close() == "", "explicit close retires drained active")
	_check(manager.get_active_batch() == null, "no automatic next reveal occurs")
	presenter.free()
	manager.free()
	carried.free()
	_pending_helpers -= 1


func _test_reconstruction_after_released_base_compacts_without_replanning() -> void:
	_pending_helpers += 1
	var entries: Array[LootBatchEntry] = []
	for index: int in range(3):
		entries.append(LootBatchEntryScript.new("entry_%04d" % index, "reconstruct:item_%04d" % index, &"loot_000030"))
	var batch: LootBatch = LootBatchScript.create_committed("reconstruct", &"test", "stack", 3, 3, 7, 9001, entries)
	var diagnostics = DeckPlannerScript.new().prepare(batch, PersistentItemCatalog, ProofProfile)
	_check(diagnostics.succeeded, "stack reconstruction fixture prepares")
	var ordered := batch.entries
	ordered.sort_custom(func(a: LootBatchEntry, b: LootBatchEntry) -> bool: return a.presentation_stack_index < b.presentation_stack_index)
	_check(ordered[0].presentation_stack_group_id == ordered[1].presentation_stack_group_id, "fixture forms one stable stack")
	var released_id := ordered[0].item_instance_id
	_check(batch.mark_entry_released(ordered[0].entry_id, released_id), "fixture releases original base before reconstruction")

	var manager: ReceivingManager = ReceivingManagerScript.new()
	root.add_child(manager)
	var presenter = DeckPresenterScript.new()
	root.add_child(presenter)
	presenter.configure(manager, PersistentItemCatalog, ProofProfile)
	_check(manager.deposit_batch(batch), "partially released fixture deposits")
	_check(presenter.present_active_batch(), "partially released stack reconstructs")
	var surfaces: Array[StorageSurface] = presenter.get_private_storage_surfaces()
	_check(surfaces.size() == 1, "proof reconstruction owns one private surface")
	if not surfaces.is_empty():
		var surface := surfaces[0]
		_check(surface.get_stack_count() == 1, "survivors reconstruct as one compact stack")
		var survivor_items: Array[WorldItem] = presenter.get_materialized_world_items()
		_check(survivor_items.size() == 2, "released leader is not rematerialized")
		if survivor_items.size() == 2:
			var runtime_stack_id := surface.get_stack_id_for_item(survivor_items[0].get_item_instance().instance_id)
			var stack := surface.get_storage_stack(runtime_stack_id)
			_check(stack != null and stack.entries.size() == 2, "stable group reconstructs into current runtime stack")
			if stack != null:
				var base_y := surface.get_local_placement_position(stack.surface_origin, stack.base_footprint).y
				_check(is_equal_approx(stack.entries[1].host.position.y, stack.entry_host_y(1, base_y)), "survivor vertical positions compact without a gap")
				var carried := CarriedItemsScript.new()
				carried.max_bulk = 999
				root.add_child(carried)
				presenter.reveal_active_batch()
				_check((stack.entries[0].world_item as WorldItem).pickup_into(carried), "reconstructed base TAKE succeeds")
				_check(stack.entries.size() == 1 and stack.stack_id == stack.entries[0].item_key, "base TAKE safely rekeys promoted survivor")
				carried.free()
	presenter.free()
	manager.free()
	_pending_helpers -= 1


func _test_runtime_debug_delivery_is_explicit() -> void:
	_pending_helpers += 1
	var runtime := RuntimeScene.instantiate()
	root.add_child(runtime)
	await process_frame
	var manager := runtime.get_node("ReceivingManager") as ReceivingManager
	var presenter := runtime.get_node("ReceivingDeckPresenter")
	_check(manager.get_active_batch() == null, "normal runtime creates no synthetic batch without CLI flag")
	_check(runtime.call("run_debug_delivery", 1842, 9002, 24), "explicit debug delivery prepares, deposits, and reveals")
	var batch := manager.get_active_batch()
	_check(batch != null and batch.content_seed == 1842 and batch.presentation_seed == 9002 and batch.target_bulk == 24, "debug delivery preserves requested seeds and Bulk")
	_check(presenter.call("get_presentation_state") == DeckPresenterScript.PresentationState.AVAILABLE, "debug delivery is immediately available")
	_check(not (presenter.call("get_materialized_world_items") as Array).is_empty(), "debug delivery materializes real items")
	runtime.free()

	var mode_runtime := RuntimeScene.instantiate()
	root.add_child(mode_runtime)
	await process_frame
	_check(mode_runtime.call("_fixture_mode_flag", PackedStringArray()) == DeckPlannerScript.FixtureMode.BARE, "missing fixture flag defaults to bare")
	_check(mode_runtime.call("_fixture_mode_flag", PackedStringArray(["--receiving-fixture-mode=crates"])) == DeckPlannerScript.FixtureMode.CRATES_ALLOWED, "crate CLI mode parses")
	_check(mode_runtime.call("_fixture_mode_flag", PackedStringArray(["--receiving-fixture-mode=pallets"])) == DeckPlannerScript.FixtureMode.PALLETS_ALLOWED, "pallet CLI mode parses")
	_check(mode_runtime.call("_fixture_mode_flag", PackedStringArray(["--receiving-fixture-mode=mixed"])) == DeckPlannerScript.FixtureMode.MIXED, "mixed CLI mode parses")
	_check(mode_runtime.call("_fixture_mode_flag", PackedStringArray(["--receiving-fixture-mode=unknown"])) == -1, "unknown fixture CLI mode is rejected")
	_check(mode_runtime.call("run_debug_delivery", 1842, 9001, 24, DeckPlannerScript.FixtureMode.MIXED), "explicit mixed debug delivery prepares and reveals")
	var mixed_manager := mode_runtime.get_node("ReceivingManager") as ReceivingManager
	_check(not mixed_manager.get_active_batch().presentation_fixtures.is_empty(), "mixed debug delivery persists fixtures")
	mode_runtime.free()
	_pending_helpers -= 1


func _test_fixture_reconstruction_reservation_and_empty_persistence() -> void:
	_pending_helpers += 1
	var batch: LootBatch = LootSourceScript.new().generate_committed_batch(
		PersistentItemCatalog, PrototypeLootPool, "fixture_presenter", 1842, 9001, 24
	)
	var diagnostics = DeckPlannerScript.new().prepare(
		batch, PersistentItemCatalog, ProofProfile, DeckPlannerScript.FixtureMode.MIXED
	)
	_check(diagnostics.succeeded, "mixed fixture batch prepares")
	var fixtures := batch.presentation_fixtures
	_check(not fixtures.is_empty(), "mixed fixture batch persists at least one fixture")
	if fixtures.is_empty():
		_pending_helpers -= 1
		return
	var emptied_surface: StringName = fixtures[0].surface_id
	var released_fixture_items := 0
	for entry: LootBatchEntry in batch.entries:
		if entry.presentation_surface_id == emptied_surface:
			_check(batch.mark_entry_released(entry.entry_id, entry.item_instance_id), "fixture entry can be released before reconstruction")
			released_fixture_items += 1
	_check(released_fixture_items > 0, "selected persisted fixture initially owned an item")

	var manager: ReceivingManager = ReceivingManagerScript.new()
	root.add_child(manager)
	var presenter = DeckPresenterScript.new()
	root.add_child(presenter)
	_check(presenter.configure(manager, PersistentItemCatalog, ProofProfile), "fixture presenter configures")
	_check(manager.deposit_batch(batch), "partially drained fixture batch deposits")
	_check(presenter.present_active_batch(), "persisted fixtures reconstruct without planner")
	_check((presenter.get_materialized_fixture_nodes() as Array).size() == fixtures.size(), "every persisted fixture visual reconstructs, including empty fixture")
	var surfaces: Array[StorageSurface] = presenter.get_private_storage_surfaces()
	_check(surfaces.size() == fixtures.size() + 1, "MainDeck plus every fixture private surface reconstructs")
	var surfaces_by_id: Dictionary = {}
	for surface: StorageSurface in surfaces:
		surfaces_by_id[surface.surface_id] = surface
		_check(not surface.is_player_storage_interaction_enabled(), "fixture presentation surfaces disable PUT")
		_check(not surface.are_zones_initialized(), "fixture presentation surfaces have no zoning")
		_check(not surface.is_debug_visible(), "fixture presentation surfaces hide normal and F6 grids")
	var main_surface := surfaces_by_id.get(&"MainDeck") as StorageSurface
	_check(main_surface != null, "runtime MainDeck reconstructs")
	for fixture in fixtures:
		_check(surfaces_by_id.has(fixture.surface_id), "persisted fixture surface ID resolves")
		if main_surface != null:
			var reservation := main_surface.get_reservation("__fixture__:%s" % fixture.instance_id)
			_check(bool(reservation.get("valid", false)), "fixture base reservation reconstructs on MainDeck")
			_check(reservation.get("origin") == fixture.main_deck_origin, "fixture reservation preserves calibrated socket origin")
	for fixture_root: Node3D in presenter.get_materialized_fixture_nodes():
		_check(fixture_root.find_children("*", "WorldItem", true, false).is_empty(), "fixture visual has no WorldItem interaction")
	_check((surfaces_by_id[emptied_surface] as StorageSurface).get_stack_count() == 0, "now-empty fixture surface persists without rematerializing released items")
	presenter.free()
	manager.free()
	_pending_helpers -= 1


func _test_actual_main_deck_and_fixture_stacks_reject_manual_put() -> void:
	_pending_helpers += 1
	var runtime := RuntimeScene.instantiate()
	root.add_child(runtime)
	await process_frame
	_check(
		runtime.call("run_debug_delivery", 1842, 9001, 24, DeckPlannerScript.FixtureMode.MIXED),
		"private PUT regression mixed delivery prepares"
	)
	await physics_frame
	await physics_frame
	var presenter = runtime.get_node("ReceivingDeckPresenter")
	var carried := CarriedItemsScript.new()
	carried.max_bulk = 99999
	root.add_child(carried)
	var camera := Camera3D.new()
	root.add_child(camera)
	var controller: StoragePlacementController = StoragePlacementControllerScript.new()
	root.add_child(controller)
	controller.configure(camera, carried, 2.3)
	controller.set_manual_mode(true)

	for surface_kind: String in ["MainDeck", "Fixture"]:
		var target_context := await _compatible_private_stack_target(
			presenter.call("get_materialized_world_items") as Array,
			controller,
			camera,
			surface_kind
		)
		_check(not target_context.is_empty(), "%s exposes a ray-hit stack with a valid compatible append" % surface_kind)
		if target_context.is_empty():
			continue
		var target := target_context["world_item"] as WorldItem
		var surface := target.get_storage_surface() as StorageSurface
		var incoming := target_context["incoming"] as ItemInstance
		var stack: StorageStack = surface.get_storage_stack(target.get_storage_stack_id())
		var stack_size_before := stack.entries.size()
		_check(not surface.is_player_storage_interaction_enabled(), "%s target uses a private opt-out surface" % surface_kind)
		_check(carried.add_item(incoming), "%s compatible item enters carry" % surface_kind)
		controller.update_target()
		_check(not controller.is_targeting_surface(), "%s stack cannot become a PUT target" % surface_kind)
		_check(not controller.has_valid_placement(), "%s stack exposes no valid PUT fit" % surface_kind)
		var ghost := controller.get("_ghost_host") as Node3D
		_check(ghost != null and not ghost.visible, "%s stack exposes no placement ghost" % surface_kind)
		_check(not surface.is_debug_visible(), "%s stack exposes no private debug grid" % surface_kind)
		_check(controller.get_prompt_text().is_empty(), "%s stack exposes no PUT prompt" % surface_kind)
		_check(not controller.place_selected(), "%s stack rejects manual PUT" % surface_kind)
		_check(carried.get_selected_item() == incoming, "%s rejected PUT retains carried identity" % surface_kind)
		_check(stack.entries.size() == stack_size_before, "%s rejected PUT leaves its stack unchanged" % surface_kind)
		carried.remove_item(incoming)

	controller.free()
	camera.free()
	carried.free()
	runtime.free()
	_pending_helpers -= 1


func _compatible_private_stack_target(
	world_items: Array,
	controller: StoragePlacementController,
	camera: Camera3D,
	surface_kind: String
) -> Dictionary:
	for world_value: Variant in world_items:
		var candidate := world_value as WorldItem
		if candidate == null:
			continue
		var surface := candidate.get_storage_surface() as StorageSurface
		if surface == null:
			continue
		var is_main := surface.surface_id == &"MainDeck"
		if (surface_kind == "MainDeck") != is_main:
			continue
		var shape := candidate.get_node_or_null("PickupArea/PickupShape") as CollisionShape3D
		if shape == null:
			continue
		camera.global_position = shape.global_position + Vector3(0.0, 0.12, 0.8)
		camera.look_at(shape.global_position)
		await physics_frame
		var looked_at := controller.call("_get_looked_at_stored_world_item") as WorldItem
		if looked_at == null or looked_at.get_storage_surface() != surface:
			continue
		var source_item := looked_at.get_item_instance()
		var incoming := ItemInstanceScript.new(
			source_item.definition,
			"private_put_regression:%s" % surface_kind.to_lower()
		)
		var unit_state := surface.get_semantic_orientation_quarter_turns()
		var preferred = controller.call("_entry_for_item", incoming, false, unit_state)
		var alternate = null
		var footprint: Vector3i = incoming.get_storage_footprint()
		if footprint.x != footprint.y:
			alternate = controller.call("_entry_for_item", incoming, true, unit_state)
		var fit: Dictionary = surface.find_manual_stack_fit(
			looked_at.get_storage_stack_id(),
			preferred,
			alternate
		)
		if bool(fit.get("valid", false)):
			return {"world_item": looked_at, "incoming": incoming}
	return {}


func _test_fixture_stack_base_take_compacts() -> void:
	_pending_helpers += 1
	var entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("soda_0", "fixture_stack:soda_0", &"loot_000022"),
		LootBatchEntryScript.new("soda_1", "fixture_stack:soda_1", &"loot_000022"),
	]
	var batch: LootBatch = LootBatchScript.create_committed(
		"fixture_stack", &"test", "fixture-stack", 2, 2, 1842, 9001, entries
	)
	var diagnostics = DeckPlannerScript.new().prepare(
		batch, PersistentItemCatalog, ProofProfile, DeckPlannerScript.FixtureMode.CRATES_ALLOWED
	)
	_check(diagnostics.succeeded, "stackable eligible Small fixture prepares")
	_check(batch.presentation_fixtures.size() == 1, "one crate serves the stackable pair")
	var planned := batch.entries
	_check(planned[0].presentation_surface_id == planned[1].presentation_surface_id, "stackable pair uses one fixture surface")
	_check(planned[0].presentation_stack_group_id == planned[1].presentation_stack_group_id, "stackable pair uses one fixture stack")

	var manager: ReceivingManager = ReceivingManagerScript.new()
	root.add_child(manager)
	var presenter = DeckPresenterScript.new()
	root.add_child(presenter)
	presenter.configure(manager, PersistentItemCatalog, ProofProfile)
	manager.deposit_batch(batch)
	_check(presenter.present_active_batch(), "fixture stack reconstructs")
	presenter.reveal_active_batch()
	var fixture_surface_id: StringName = batch.presentation_fixtures[0].surface_id
	var fixture_surface: StorageSurface = null
	for surface: StorageSurface in presenter.get_private_storage_surfaces():
		if surface.surface_id == fixture_surface_id:
			fixture_surface = surface
			break
	_check(fixture_surface != null and fixture_surface.get_stack_count() == 1, "fixture surface owns one live stack")
	if fixture_surface != null:
		var runtime_stack_id := fixture_surface.get_stack_id_for_item(planned[0].item_instance_id)
		var stack := fixture_surface.get_storage_stack(runtime_stack_id)
		_check(stack != null and stack.entries.size() == 2, "fixture stack materializes both entries")
		if stack != null and stack.entries.size() == 2:
			var promoted_item_id: String = stack.entries[1].item_key
			var carried := CarriedItemsScript.new()
			carried.max_bulk = 99
			root.add_child(carried)
			_check((stack.entries[0].world_item as WorldItem).pickup_into(carried), "fixture stack base TAKE succeeds")
			_check(stack.entries.size() == 1 and stack.stack_id == promoted_item_id, "fixture stack base TAKE compacts and rekeys survivor")
			_check((presenter.get_materialized_fixture_nodes() as Array).size() == 1, "fixture visual persists after stack base TAKE")
			carried.free()
	presenter.free()
	manager.free()
	_pending_helpers -= 1


func _generated_prepared_batch(batch_id: String, content_seed: int, presentation_seed: int, target_bulk: int) -> LootBatch:
	var batch: LootBatch = LootSourceScript.new().generate_committed_batch(
		PersistentItemCatalog, PrototypeLootPool, batch_id, content_seed, presentation_seed, target_bulk
	)
	if batch == null:
		return null
	var diagnostics = DeckPlannerScript.new().prepare(batch, PersistentItemCatalog, ProofProfile)
	return batch if diagnostics.succeeded else null


func _remaining_count(batch: LootBatch) -> int:
	var count := 0
	for entry: LootBatchEntry in batch.entries:
		if entry.remaining_in_batch:
			count += 1
	return count


func _entry_for_item(batch: LootBatch, item_instance_id: String) -> LootBatchEntry:
	for entry: LootBatchEntry in batch.entries:
		if entry.item_instance_id == item_instance_id:
			return entry
	return null


func _world_item_host(definition: ItemDefinition, host_name: String) -> Dictionary:
	_pending_helpers += 1
	var host := Node3D.new()
	host.name = host_name
	root.add_child(host)
	var visual: Node = definition.visual_scene.instantiate()
	host.add_child(visual)
	var world_item: WorldItem = WorldItemScript.new()
	world_item.name = "WorldItem"
	host.add_child(world_item)
	_pending_helpers -= 1
	return {"host": host, "world_item": world_item}


func _box_world_item_host(host_name: String) -> Dictionary:
	_pending_helpers += 1
	var host := Node3D.new()
	host.name = host_name
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.2, 0.2, 0.2)
	mesh_instance.mesh = box
	host.add_child(mesh_instance)
	var world_item: WorldItem = WorldItemScript.new()
	world_item.name = "WorldItem"
	host.add_child(world_item)
	_pending_helpers -= 1
	return {"host": host, "world_item": world_item}


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition


func _finish() -> void:
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving deck presenter tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving deck presenter tests")
	quit(0)
