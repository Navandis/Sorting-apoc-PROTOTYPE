extends SceneTree

const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const DEVELOPMENT_SETUP_PATH := "res://gameplay/logistics_wing/development/seeded_storage_setup.tscn"
const StorageCategoriesScript = preload("res://storage_categories.gd")

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
	await _test_identity_stack_and_transfer_loop(packed)
	await _test_rejection_and_rollback_loop(packed)
	_finish()


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
	_check(surfaces.size() == 12, "interaction loop sees twelve functional surfaces")
	if surfaces.size() != 12:
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
		var hammer_entry = controller.call("_entry_for_item", hammer_item, true)
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
		controller.set_manual_mode(true)
		controller.set("_rotated", true)
		controller.set("_current_surface", manual_surface)
		controller.set("_current_fit", manual_fit)
		_check(controller.place_selected(), "hammer commits through manual rotated placement")
		var hammer_stack := manual_surface.get_storage_stack(hammer_item.instance_id)
		_check(hammer_stack != null, "manual hammer creates one stored stack")
		if hammer_stack != null:
			_check(hammer_stack.entries[0].item == hammer_item, "manual placement keeps exact hammer instance")
			_check(hammer_stack.entries[0].packing_rotated, "manual placement records R rotation")
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
	var orientations: Array = controller.call("_entry_orientations_for_item", item)
	var fit: Dictionary = surface.find_zone_stack_or_empty_fit(
		item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	return controller.place_selected()


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
