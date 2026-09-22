extends SceneTree

const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const DEVELOPMENT_SETUP_PATH := "res://gameplay/logistics_wing/development/seeded_storage_setup.tscn"
const StorageCategoriesScript = preload("res://storage_categories.gd")
const StorageItemOrientationScript = preload("res://storage_item_orientation.gd")
const LEGACY_SURFACE_COUNT := 12
const BRIDGE_RACK_NAME := "ModularRack_GalleryB_Initial"
const BRIDGE_LADDER_NAME := "FixedLadder_GalleryB_Initial"

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check(ResourceLoader.exists(GAMEPLAY_PATH), "continuing gameplay scene exists"):
		_finish()
		return
	var packed := load(GAMEPLAY_PATH) as PackedScene
	if not _check(packed != null, "continuing gameplay scene loads"):
		_finish()
		return
	await _test_semantic_orientation_handling(packed)
	await _test_gallery_b_ladder_bridge(packed)
	await _test_identity_stack_and_transfer_loop(packed)
	await _test_rejection_and_rollback_loop(packed)
	_finish()


func _test_semantic_orientation_handling(packed: PackedScene) -> void:
	var scene := _instantiate_with_regression_seed_fixture(packed)
	var orientation := scene.get_node(
		"FunctionalFixtures/SM_MetalShelves_GalleryA_West/StorageUnitOrientation"
	)
	orientation.set("storage_orientation_quarter_turns", 1)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	var player := scene.get_node("Player")
	var carried := scene.get_node("Player/CarriedItems")
	var controller := scene.get_node("Player/StoragePlacementController") as StoragePlacementController
	var seeds := scene.get_node("DevelopmentSetup/SeedItems")
	var surfaces := scene.call("get_functional_surfaces") as Array
	var surface := surfaces[0] as StorageSurface
	_check(surface.get_semantic_orientation_quarter_turns() == 1, "continuing Metal Shelf inherits authored state 1")
	var physical_before := _surface_physical_signature(surface)
	var semantic_size := surface.get_semantic_grid_size()
	var zone_first := Vector2i(0, semantic_size.y - 3)
	var zone_second := Vector2i(2, semantic_size.y - 1)
	surface.set_semantic_zone_rect(StorageCategoriesScript.FOOD, zone_first, zone_second)

	var stored_items: Array[ItemInstance] = []
	for index: int in range(2):
		var host := _host_for_item_id(seeds, &"loot_000005")
		_check(host != null, "semantic Food fixture finds cereal host %d" % index)
		if host == null:
			break
		var world_item := host.get_node("WorldItem") as WorldItem
		var item: ItemInstance = world_item.get_item_instance()
		player.call("_attempt_pickup", world_item)
		_check(carried.get_selected_item() == item, "semantic Food pickup preserves identity %d" % index)
		_check(_auto_place_selected(controller, carried, surface), "semantic front-left Food zone accepts item %d" % index)
		stored_items.append(item)

	_check(surface.get_stack_count() == 1, "semantic Food zone preserves normal compatible stacking")
	if stored_items.size() == 2:
		var stack_id := surface.get_stack_id_for_item(stored_items[0].instance_id)
		var stack := surface.get_storage_stack(stack_id)
		_check(stack != null and stack.entries.size() == 2, "semantic Food zone keeps two cereal identities in one stack")
		var reservation := surface.get_reservation(stack_id)
		var origin := reservation.get("origin", Vector2i(-1, -1)) as Vector2i
		var footprint := reservation.get("footprint", Vector2i.ZERO) as Vector2i
		for z: int in range(origin.y, origin.y + footprint.y):
			for x: int in range(origin.x, origin.x + footprint.x):
				_check(
					surface.get_zone_category(Vector2i(x, z)) == StorageCategoriesScript.FOOD,
					"auto-placement reservation stays inside mapped physical Food cells"
				)
		if stack != null and stack.entries.size() == 2:
			var top_entry = stack.entries[1]
			_check(top_entry.host.global_basis.get_scale().is_equal_approx(Vector3.ONE), "semantic auto-placement keeps canonical stored scale")
			var top_item: ItemInstance = top_entry.item
			_check((top_entry.world_item as WorldItem).pickup_into(carried), "semantic-zone stacked item retrieves normally")
			_check(carried.get_selected_item() == top_item, "semantic-zone retrieval preserves exact identity")
			_check(stack.entries.size() == 1, "semantic-zone retrieval preserves remaining stack ownership")
	_check(_surface_physical_signature(surface) == physical_before, "semantic zoning and storage leave physical Metal surface unchanged")
	scene.free()
	current_scene = null
	await process_frame


func _test_gallery_b_ladder_bridge(packed: PackedScene) -> void:
	var scene := _instantiate_with_regression_seed_fixture(packed)
	# The held-item clone is unrelated to climbing and queries a dummy-renderer
	# material in headless mode; the real carried-item state remains exercised.
	scene.get_node("Player").set("enable_held_item_view", false)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	var player := scene.get_node("Player") as CharacterBody3D
	var carried := scene.get_node("Player/CarriedItems") as CarriedItems
	var rack := scene.get_node_or_null("FunctionalFixtures/%s" % BRIDGE_RACK_NAME) as ModularRack
	var ladder := scene.get_node_or_null("FunctionalFixtures/%s" % BRIDGE_LADDER_NAME) as FixedLadder
	var surfaces := scene.call("get_functional_surfaces") as Array
	var upper_surface := _surface_for_rack_level(surfaces, rack, "Shelf_03")
	_check(player != null and carried != null, "Gallery B bridge keeps the normal player and carried-items path")
	_check(rack != null and ladder != null, "Gallery B bridge keeps the intended sibling rack and ladder")
	_check(upper_surface != null, "Gallery B bridge builds a reachable upper rack surface")
	if player == null or carried == null or rack == null or ladder == null or upper_surface == null:
		scene.free()
		current_scene = null
		return

	player.set_process(false)
	player.set_physics_process(false)
	var carried_item := ItemInstance.new(load("res://data/items/definitions/loot_000037.tres") as ItemDefinition)
	_check(carried.add_item(carried_item), "Gallery B ladder check carries an existing item definition")
	var anchor := ladder.get_climb_anchor_world_position()
	var ladder_forward := ladder.get_ladder_forward_world()
	player.global_position = anchor + ladder_forward * 0.04
	player.rotation.y = ladder.get_ladder_yaw_world()
	await physics_frame
	await physics_frame
	player.call("_step_movement", 0.10, Vector2(0.0, -1.0), false)
	_check(player.is_ladder_attached(), "Gallery B ladder attaches through the normal player path")
	var climb_start_y := player.global_position.y
	player.call("_step_movement", 0.20, Vector2(0.0, -1.0), false)
	_check(player.global_position.y > climb_start_y, "Gallery B ladder climbs at the promoted movement path")
	_check(carried.get_selected_item() == carried_item, "carried item identity survives Gallery B ladder climbing")

	var camera := player.get_node("Camera3D") as Camera3D
	player.global_position.y = 0.0
	camera.look_at(upper_surface.global_position, Vector3.UP)
	await physics_frame
	_check(
		player.call("_get_looked_at_storage_surface") == upper_surface,
		"attached player ray reaches the upper ModularRack surface through ladder collision"
	)
	player.call("_open_zone_editor_for_surface", upper_surface)
	await process_frame
	_check(bool(player.get("_zone_editor_open")), "attached player can interact with the upper ModularRack surface")
	(player.get_node("StorageZoneEditor") as CanvasLayer).call("close_editor")
	carried.remove_item(carried_item)
	scene.free()
	current_scene = null
	await process_frame


func _test_identity_stack_and_transfer_loop(packed: PackedScene) -> void:
	var scene := _instantiate_with_regression_seed_fixture(packed)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	if not _check(
		scene.has_method("get_functional_surfaces"),
		"composition exposes its functional surfaces"
	):
		scene.free()
		current_scene = null
		return

	var player := scene.get_node("Player")
	var carried := scene.get_node("Player/CarriedItems")
	var controller := scene.get_node("Player/StoragePlacementController") as StoragePlacementController
	var seeds := scene.get_node("DevelopmentSetup/SeedItems")
	var surfaces := scene.call("get_functional_surfaces") as Array
	var rack := scene.get_node_or_null("FunctionalFixtures/%s" % BRIDGE_RACK_NAME) as ModularRack
	var authored_levels := rack.get_layout_contract().get("levels", []) as Array if rack != null else []
	_check(rack != null, "interaction loop finds the intended wing ModularRack")
	_check(
		surfaces.size() == LEGACY_SURFACE_COUNT + authored_levels.size(),
		"interaction loop sees legacy plus authored ModularRack surfaces"
	)
	if rack == null or surfaces.size() != LEGACY_SURFACE_COUNT + authored_levels.size():
		scene.free()
		current_scene = null
		return

	var boxed_items: Array[ItemInstance] = await _pickup_and_auto_store_family(
		player, carried, controller, seeds, surfaces[0] as StorageSurface,
		[&"loot_000005", &"loot_000005", &"loot_000007"], "Food"
	)
	var can_items: Array[ItemInstance] = await _pickup_and_auto_store_family(
		player, carried, controller, seeds, surfaces[4] as StorageSurface,
		[&"loot_000022", &"loot_000022", &"loot_000023"], "Hydration"
	)
	var media_items: Array[ItemInstance] = await _pickup_and_auto_store_family(
		player, carried, controller, seeds, surfaces[1] as StorageSurface,
		[&"loot_000030", &"loot_000031", &"loot_000031"], "Morale"
	)
	var medical_items: Array[ItemInstance] = await _pickup_and_auto_store_family(
		player, carried, controller, seeds, surfaces[8] as StorageSurface,
		[&"loot_000028", &"loot_000028"], "Medical"
	)
	_check(boxed_items.size() == 3, "boxed-food family preserves three identities")
	_check(can_items.size() == 3, "round-can family preserves three identities")
	_check(media_items.size() == 3, "flat-media family preserves three identities")
	_check(medical_items.size() == 2, "medical-box family preserves two identities")
	_assert_family_storage(surfaces[0] as StorageSurface, boxed_items, "boxed food", 2, 2)
	_assert_family_storage(surfaces[4] as StorageSurface, can_items, "round cans", 1, 3)
	_assert_family_storage(surfaces[1] as StorageSurface, media_items, "flat media", 1, 3)
	_assert_family_storage(surfaces[8] as StorageSurface, medical_items, "medical boxes", 1, 2)
	var rack_surface := _first_surface_for_rack(surfaces, rack)
	_check(rack_surface != null, "interaction loop finds an installed ModularRack surface")
	if rack_surface != null and not boxed_items.is_empty():
		var source_stack_id := (surfaces[0] as StorageSurface).get_stack_id_for_item(boxed_items[0].instance_id)
		var source_stack := (surfaces[0] as StorageSurface).get_storage_stack(source_stack_id)
		_check(source_stack != null and not source_stack.entries.is_empty(), "legacy loop leaves a real palette item available for rack transfer")
		if source_stack != null and not source_stack.entries.is_empty():
			var rack_item: ItemInstance = source_stack.entries[0].item
			var source_world := source_stack.entries[0].world_item as WorldItem
			_check(source_world.pickup_into(carried), "existing palette item retrieves before ModularRack transfer")
			_check(carried.get_selected_item() == rack_item, "palette item carry state survives transfer to ModularRack")
			rack_surface.set_zone_rect("Food", Vector2i.ZERO, rack_surface.get_grid_size() - Vector2i.ONE)
			_check(_auto_place_selected(controller, carried, rack_surface), "existing palette item auto-stores on the ModularRack")
			var rack_stack_id := rack_surface.get_stack_id_for_item(rack_item.instance_id)
			var rack_stack := rack_surface.get_storage_stack(rack_stack_id)
			_check(rack_stack != null and rack_stack.entries.size() == 1, "ModularRack owns the stored palette item")
			if rack_stack != null and not rack_stack.entries.is_empty():
				var rack_world := rack_stack.entries[0].world_item as WorldItem
				_check(rack_world.pickup_into(carried), "ModularRack stored item retrieves through WorldItem")
				_check(carried.get_selected_item() == rack_item, "ModularRack retrieval preserves exact identity")
				_check(
					_auto_place_selected(controller, carried, surfaces[0] as StorageSurface),
					"retrieved ModularRack item returns through the established legacy storage loop"
				)

	var media_surface := surfaces[1] as StorageSurface
	var media_stack_id := media_surface.get_stack_id_for_item(media_items[0].instance_id)
	var media_stack := media_surface.get_storage_stack(media_stack_id)
	_check(media_stack != null and media_stack.entries.size() == 3, "flat-media stack has three members")
	if media_stack != null and media_stack.entries.size() == 3:
		var middle_item: ItemInstance = media_stack.entries[1].item
		var upper_y_before: float = media_stack.entries[2].host.position.y
		var middle_world: WorldItem = media_stack.entries[1].world_item as WorldItem
		_check(middle_world.pickup_into(carried), "middle flat-media item retrieves through WorldItem")
		_check(carried.get_selected_item() == middle_item, "middle retrieval preserves exact ItemInstance")
		_check(media_stack.entries.size() == 2, "middle retrieval removes only selected entry")
		_check(media_stack.entries[1].host.position.y < upper_y_before, "upper entry compresses after middle retrieval")

		var transfer_surface := surfaces[2] as StorageSurface
		transfer_surface.set_zone_rect("Morale", Vector2i.ZERO, transfer_surface.get_grid_size() - Vector2i.ONE)
		_check(
			_auto_place_selected(controller, carried, transfer_surface),
			"retrieved middle item transfers to a second shelf"
		)
		_check(
			transfer_surface.get_stack_id_for_item(middle_item.instance_id) == middle_item.instance_id,
			"cross-shelf transfer preserves identity"
		)

	var hammer_host := _host_for_item_id(seeds, &"loot_000037")
	_check(hammer_host != null, "hammer seed remains available for manual loop")
	if hammer_host != null:
		var hammer_world := hammer_host.get_node("WorldItem") as WorldItem
		var hammer_item: ItemInstance = hammer_world.get_item_instance()
		player.call("_attempt_pickup", hammer_world)
		_check(carried.get_selected_item() == hammer_item, "hammer pickup preserves identity")
		var manual_surface := surfaces[9] as StorageSurface
		var manual_physical_before := _surface_physical_signature(manual_surface)
		manual_surface.set_semantic_orientation_quarter_turns(0)
		var packing_before := _packing_orientation_signatures(
			controller.call("_entry_orientations_for_item", hammer_item, 0) as Array
		)
		manual_surface.set_semantic_orientation_quarter_turns(3)
		var packing_after := _packing_orientation_signatures(
			controller.call("_entry_orientations_for_item", hammer_item, 3) as Array
		)
		_check(
			packing_before[0]["footprint"] != packing_after[0]["footprint"],
			"canonical physical footprint follows unit orientation parity"
		)
		_check(
			not bool(packing_before[0]["packing_rotated"])
			and not bool(packing_after[0]["packing_rotated"]),
			"front-facing candidate remains packing_rotated=false"
		)
		controller.set_manual_mode(true)
		_check(not bool(controller.get("_rotated")), "Manual mode starts with native packing orientation")
		controller.toggle_rotation()
		_check(bool(controller.get("_rotated")), "Manual R rotation still selects the 90-degree packing entry")
		var hammer_entry = controller.call("_entry_for_item", hammer_item, true, 3)
		var manual_origin := Vector2i(1, 1)
		var manual_fit := {
			"valid": manual_surface.can_place_at(manual_origin, hammer_entry.footprint),
			"placement_kind": "empty",
			"stack_id": hammer_item.instance_id,
			"insertion_index": 0,
			"origin": manual_origin,
			"footprint": hammer_entry.footprint,
			"base_footprint": hammer_entry.footprint,
			"rotated": true,
			"zone_kind": "manual",
			"zone_category": "",
			"host_y_m": manual_surface.get_local_placement_position(manual_origin, hammer_entry.footprint).y,
		}
		controller.set("_current_surface", manual_surface)
		controller.set("_current_fit", manual_fit)
		_check(controller.place_selected(), "hammer commits through manual rotated placement")
		var hammer_stack := manual_surface.get_storage_stack(hammer_item.instance_id)
		_check(hammer_stack != null, "manual hammer creates one stored stack")
		if hammer_stack != null:
			_check(hammer_stack.entries[0].item == hammer_item, "manual placement keeps exact hammer instance")
			_check(hammer_stack.entries[0].packing_rotated, "manual placement records R rotation")
			var stored_host: Node3D = hammer_stack.entries[0].host
			var unit_yaw := stored_host.get_node("StoredUnitOrientationYaw") as Node3D
			var packing_yaw := unit_yaw.get_node("StoredPackingYaw") as Node3D
			_check(
				unit_yaw.basis.is_equal_approx(Basis(
					Vector3.UP,
					StorageItemOrientationScript.unit_yaw_radians(3)
				)),
				"manual stored unit root records state 3"
			)
			_check(
				packing_yaw.basis.is_equal_approx(Basis(Vector3.UP, deg_to_rad(90.0))),
				"manual stored packing root records the additional turn"
			)
			_check(
				manual_surface.get_reservation(hammer_item.instance_id).get("footprint")
				== hammer_entry.footprint,
				"manual reservation matches combined visual parity"
			)
			_check(
				manual_surface.get_reservation(hammer_item.instance_id).get("origin") == manual_origin,
				"manual placement keeps the physical nearest-cell origin under semantic state 3"
			)
		_check(_surface_physical_signature(manual_surface) == manual_physical_before, "semantic state 3 leaves manual target physical surface unchanged")
		controller.set_manual_mode(false)

	await process_frame
	_check(carried.get_item_count() == 0, "full handling loop ends with no carried items")
	var owner_census := _owner_census(scene)
	_check(owner_census["total"] == 12, "full handling loop preserves total item count")
	_check(owner_census["unique_ids"] == 12, "full handling loop preserves twelve unique identities")
	_check(owner_census["loose"] == 0, "all seed supplies moved off tables in interaction loop")
	_check(owner_census["stored"] == 12, "all seed supplies have one stored owner")

	scene.free()
	current_scene = null


func _test_rejection_and_rollback_loop(packed: PackedScene) -> void:
	var scene := _instantiate_with_regression_seed_fixture(packed)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	if not scene.has_method("get_functional_surfaces"):
		scene.free()
		current_scene = null
		return

	var player := scene.get_node("Player")
	var carried := scene.get_node("Player/CarriedItems")
	var controller := scene.get_node("Player/StoragePlacementController") as StoragePlacementController
	var seeds := scene.get_node("DevelopmentSetup/SeedItems")
	var surfaces := scene.call("get_functional_surfaces") as Array
	var cereal_host := _host_for_item_id(seeds, &"loot_000005")
	var cereal_world := cereal_host.get_node("WorldItem") as WorldItem
	var cereal_item: ItemInstance = cereal_world.get_item_instance()
	player.call("_attempt_pickup", cereal_world)
	_check(carried.get_selected_item() == cereal_item, "rollback fixture carries exact cereal item")

	var current_bulk := int(carried.get_current_bulk())
	carried.set("max_bulk", current_bulk)
	var second_host := _host_for_item_id(seeds, &"loot_000022")
	var second_world := second_host.get_node("WorldItem") as WorldItem
	_check(not second_world.pickup_into(carried), "full carry rejects second pickup")
	_check(second_host.get_node_or_null("WorldItem") == second_world, "full-carry rejection preserves world owner")
	carried.set("max_bulk", 999)

	var surface := surfaces[0] as StorageSurface
	surface.set_zone_rect("Hydration", Vector2i.ZERO, surface.get_grid_size() - Vector2i.ONE)
	var orientations: Array = controller.call("_entry_orientations_for_item", cereal_item)
	var mismatch_fit: Dictionary = surface.find_zone_stack_or_empty_fit(
		cereal_item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", mismatch_fit)
	controller.set("_manual_mode", false)
	_check(not controller.place_selected(), "mismatched zoning rejects auto placement")
	_check(carried.get_selected_item() == cereal_item, "mismatched rejection preserves carried identity")

	surface.clear_all_zones()
	var disabled_fit: Dictionary = surface.find_zone_stack_or_empty_fit(
		cereal_item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	controller.set("_current_fit", disabled_fit)
	_check(not controller.place_selected(), "erased/disabled cells reject auto placement")
	_check(carried.get_selected_item() == cereal_item, "disabled-cell rejection preserves carried identity")

	surface.set_zone_rect("Food", Vector2i.ZERO, surface.get_grid_size() - Vector2i.ONE)
	_check(
		surface.reserve_at("full_surface_block", Vector2i.ZERO, surface.get_grid_size()),
		"rollback fixture fills target surface"
	)
	var full_fit: Dictionary = surface.find_zone_stack_or_empty_fit(
		cereal_item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	controller.set("_current_fit", full_fit)
	_check(not controller.place_selected(), "full surface rejects placement")
	_check(carried.get_selected_item() == cereal_item, "full-surface rejection preserves carried identity")
	_check(surface.release("full_surface_block"), "rollback fixture releases temporary full-surface block")

	var valid_fit: Dictionary = surface.find_zone_stack_or_empty_fit(
		cereal_item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	_check(bool(valid_fit.get("valid", false)), "rollback fixture obtains a valid pre-commit fit")
	var race_origin := valid_fit.get("origin", Vector2i.ZERO) as Vector2i
	var race_footprint := valid_fit.get("footprint", Vector2i.ONE) as Vector2i
	_check(
		surface.reserve_at("late_commit_block", race_origin, race_footprint),
		"rollback fixture invalidates the chosen fit after selection"
	)
	var slot_before := int(carried.get_selected_index())
	var owner_census_before := _owner_census(scene)
	controller.set("_current_fit", valid_fit)
	_check(not controller.place_selected(), "stale commit rolls back after carried removal")
	_check(carried.get_selected_item() == cereal_item, "failed commit restores exact ItemInstance")
	_check(carried.get_selected_index() == slot_before, "failed commit restores selected slot")
	_check(surface.get_stack_count() == 0, "failed commit leaves no stored stack")
	_check(surface.get_reservation_count() == 1, "failed commit leaves only the deliberate late blocker")
	_check(surface.release("late_commit_block"), "rollback fixture releases its late blocker")
	_check(surface.get_reservation_count() == 0, "rollback fixture returns to zero reservations")
	var owner_census_after := _owner_census(scene)
	_check(owner_census_after == owner_census_before, "failed commit preserves all owner counts and IDs")

	await process_frame
	scene.free()
	current_scene = null


func _pickup_and_auto_store_family(
	player: Node,
	carried: Node,
	controller: StoragePlacementController,
	seeds: Node,
	surface: StorageSurface,
	item_ids: Array[StringName],
	category: String
) -> Array[ItemInstance]:
	surface.set_zone_rect(category, Vector2i.ZERO, surface.get_grid_size() - Vector2i.ONE)
	var items: Array[ItemInstance] = []
	for item_id: StringName in item_ids:
		var host := _host_for_item_id(seeds, item_id)
		_check(host != null, "seed host remains for %s" % item_id)
		if host == null:
			continue
		var world_item := host.get_node("WorldItem") as WorldItem
		var item: ItemInstance = world_item.get_item_instance()
		player.call("_attempt_pickup", world_item)
		_check(carried.get_selected_item() == item, "%s pickup preserves exact identity" % item_id)
		var placed := _auto_place_selected(controller, carried, surface)
		_check(placed, "%s auto-stores through real controller" % item_id)
		if not placed:
			break
		items.append(item)
	return items


func _auto_place_selected(
	controller: StoragePlacementController,
	carried: Node,
	surface: StorageSurface
) -> bool:
	var item: ItemInstance = carried.get_selected_item() as ItemInstance
	if item == null:
		return false
	var orientations: Array = controller.call(
		"_entry_orientations_for_item",
		item,
		surface.get_semantic_orientation_quarter_turns()
	)
	var fit: Dictionary = surface.find_zone_stack_or_empty_fit(
		item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	return controller.place_selected()


func _first_surface_for_rack(surfaces: Array, rack: Node) -> StorageSurface:
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface != null and rack.is_ancestor_of(surface):
			return surface
	return null


func _surface_for_rack_level(surfaces: Array, rack: Node, level_name: String) -> StorageSurface:
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if (
			surface != null
			and rack.is_ancestor_of(surface)
			and String(surface.get_parent().name) == level_name
		):
			return surface
	return null


func _assert_family_storage(
	surface: StorageSurface,
	items: Array[ItemInstance],
	label: String,
	expected_stack_count: int,
	expected_largest_stack: int
) -> void:
	_check(
		surface.get_stack_count() == expected_stack_count,
		"%s forms %d clearance-valid stack(s)" % [label, expected_stack_count]
	)
	if items.is_empty():
		return
	var stored_ids: Dictionary = {}
	var largest_stack := 0
	for value: Variant in (surface.get("_stacks") as Dictionary).values():
		var stack := value as StorageStack
		largest_stack = maxi(largest_stack, stack.entries.size())
		for entry in stack.entries:
			stored_ids[entry.item.instance_id] = entry.item
	_check(largest_stack == expected_largest_stack, "%s reaches its expected compatible stack depth" % label)
	_check(stored_ids.size() == items.size(), "%s stores every family member exactly once" % label)
	for item: ItemInstance in items:
		_check(stored_ids.get(item.instance_id) == item, "%s preserves identity %s" % [label, item.instance_id])


func _surface_physical_signature(surface: StorageSurface) -> Dictionary:
	return {
		"global_transform": surface.global_transform,
		"grid_size": surface.get_grid_size(),
		"usable_size_m": surface.get_usable_size_m(),
		"stack_clearance_m": surface.stack_clearance_m,
	}


func _packing_orientation_signatures(orientations: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in orientations:
		var entry := value as StorageStack.Entry
		result.append({
			"footprint": entry.footprint,
			"packing_rotated": entry.packing_rotated,
			"aligned_bounds": entry.aligned_bounds,
		})
	return result


func _host_for_item_id(seeds: Node, item_id: StringName) -> Node3D:
	for child: Node in seeds.get_children():
		if (
			StringName(child.get("item_id")) == item_id
			and not child.is_queued_for_deletion()
			and child.get_node_or_null("WorldItem") != null
		):
			return child as Node3D
	return null


func _owner_census(scene: Node) -> Dictionary:
	var ids: Dictionary = {}
	var loose := 0
	var carried_count := 0
	var stored := 0
	var seeds := scene.get_node_or_null("DevelopmentSetup/SeedItems")
	if seeds != null:
		for host: Node in seeds.get_children():
			var world_item := host.get_node_or_null("WorldItem") as WorldItem
			if world_item == null or host.is_queued_for_deletion():
				continue
			var item := world_item.get_item_instance()
			ids[item.instance_id] = true
			loose += 1
	var carried := scene.get_node("Player/CarriedItems")
	for value: Variant in carried.get_items():
		var item := value as ItemInstance
		ids[item.instance_id] = true
		carried_count += 1
	if scene.has_method("get_functional_surfaces"):
		for value: Variant in scene.call("get_functional_surfaces") as Array:
			var surface := value as StorageSurface
			for stack_value: Variant in (surface.get("_stacks") as Dictionary).values():
				var stack := stack_value as StorageStack
				for entry in stack.entries:
					ids[entry.item.instance_id] = true
					stored += 1
	return {
		"loose": loose,
		"carried": carried_count,
		"stored": stored,
		"total": loose + carried_count + stored,
		"unique_ids": ids.size(),
	}


func _instantiate_with_regression_seed_fixture(gameplay_packed: PackedScene) -> Node:
	var scene := gameplay_packed.instantiate()
	var live_setup := scene.get_node_or_null("DevelopmentSetup")
	if live_setup != null:
		scene.remove_child(live_setup)
		live_setup.free()
	var setup_packed := load(DEVELOPMENT_SETUP_PATH) as PackedScene
	var regression_setup := setup_packed.instantiate()
	regression_setup.name = "DevelopmentSetup"
	scene.add_child(regression_setup)
	return scene


func _finish() -> void:
	if _failed:
		push_error("FAIL: wing storage bridge interaction tests")
		quit(1)
		return
	print("PASS: wing storage bridge interaction tests")
	quit(0)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false
