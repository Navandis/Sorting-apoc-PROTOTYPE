extends SceneTree

const REVIEW_SCENE := "res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn"
const GAMEPLAY_SCENE := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const BLOCKED_ITEM_IDS: Array[StringName] = [&"loot_000034", &"loot_000036"]

var _failed := false


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_check(ResourceLoader.exists(REVIEW_SCENE), "shelf ergonomics review scene exists")
	_check(ResourceLoader.exists(GAMEPLAY_SCENE), "authoritative wing gameplay scene exists")
	if not _failed:
		for case_id: String in ["A", "B", "C"]:
			await _check_case(case_id)
	if _failed:
		push_error("FAIL: shelf ergonomics review tests")
		quit(1)
		return
	print("PASS: shelf ergonomics review tests")
	quit(0)


func _check_case(case_id: String) -> void:
	var scene := (load(REVIEW_SCENE) as PackedScene).instantiate()
	scene.set("case_override", case_id)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	_assert_authoritative_supply(scene, case_id)
	_check(scene.has_method("get_review_contract"), "%s exposes a review contract" % case_id)
	if scene.has_method("get_review_contract"):
		var contract: Dictionary = scene.call("get_review_contract") as Dictionary
		_check(contract.get("case") == case_id, "%s selects the requested preset" % case_id)
		_check(contract.get("functional_family_count") == 2, "%s has metal and locker storage only" % case_id)
		_check(contract.get("cabinet_surface_count") == 0, "%s cabinet remains TAKE-only" % case_id)
		_check(contract.get("surface_count") == 8, "%s exposes four metal and four locker supports" % case_id)
		_check(bool(contract.get("surfaces_unit_scale", false)), "%s storage and stored hosts keep unit scale" % case_id)
		_check(int(contract.get("stored_sample_count", 0)) >= 2, "%s reserves representative functional samples through real storage" % case_id)
		_check((contract.get("unfitted_samples", []) as Array).is_empty(), "%s seats every review functional sample after the height amendment" % case_id)
		_check(int(contract.get("cabinet_take_sample_count", -1)) == 0, "%s retires the cabinet sample fixture from the live review" % case_id)
		_check(bool(contract.get("f6_enabled", false)), "%s permits only the F6 storage presentation" % case_id)
		_check(bool(contract.get("f7_disabled", false)), "%s keeps F7 disabled" % case_id)
		_check(is_equal_approx(float(contract.get("ceiling_y_m", 0.0)), 2.80 if case_id == "C" else 3.40), "%s has its specified local ceiling" % case_id)
		_check(is_equal_approx(float(contract.get("eye_height_m", 0.0)), 1.80), "%s starts at the 1.80 m review eye height" % case_id)
		_check(String(contract.get("eye_toggle", "")) == "F5", "%s exposes the review-only eye-height toggle" % case_id)
		_check(is_equal_approx(float(contract.get("metal_x_m", 0.0)), 10.10), "%s uses the corrected metal-shelf X placement" % case_id)
		_check(is_equal_approx(float(contract.get("metal_z_m", 0.0)), -10.95), "%s uses the corrected metal-shelf Z placement" % case_id)
		_assert_metal_fixture_clearance_and_coherence(scene, case_id)
		if case_id == "B" or case_id == "C":
			_check(float(contract.get("metal_top_y_m", 99.0)) <= 1.75, "%s metal top usable plane is within the revised trial cap" % case_id)
			_check(float(contract.get("metal_top_y_m", 0.0)) >= 1.65, "%s metal top usable plane is within the revised trial floor" % case_id)
			_check(float(contract.get("locker_top_y_m", 99.0)) <= 1.75, "%s locker top usable plane is within the revised trial cap" % case_id)
			_check(float(contract.get("locker_top_y_m", 0.0)) >= 1.65, "%s locker top usable plane is within the revised trial floor" % case_id)
			await _exercise_review_storage(scene, case_id)
		if case_id == "B":
			await _exercise_reused_supply_pickup(scene, case_id)
			await _exercise_review_manual_and_stack(scene, case_id)
		await _exercise_eye_toggle(scene, case_id)
	scene.free()
	current_scene = null
	await process_frame


func _exercise_review_storage(scene: Node, case_id: String) -> void:
	var player := scene.get_node_or_null("Player")
	var carried := scene.get_node_or_null("Player/CarriedItems") as CarriedItems
	var controller := scene.get_node_or_null("Player/StoragePlacementController") as StoragePlacementController
	var surfaces := scene.find_children("*", "StorageSurface", true, false)
	_check(player != null and carried != null and controller != null, "%s has the normal player storage path" % case_id)
	if carried == null or controller == null:
		return
	var stored_world: WorldItem = null
	var stored_surface: StorageSurface = null
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface == null:
			continue
		for stack_value: Variant in (surface.get("_stacks") as Dictionary).values():
			var stack := stack_value as StorageStack
			if not stack.entries.is_empty():
				stored_world = stack.entries[0].world_item as WorldItem
				stored_surface = surface
				break
		if stored_world != null:
			break
	_check(stored_world != null, "%s has a real stored WorldItem to retrieve" % case_id)
	if stored_world == null or stored_surface == null:
		return
	var stored_item := stored_world.get_item_instance()
	_check(stored_world.pickup_into(carried), "%s retrieves its reserved review item through WorldItem" % case_id)
	_check(carried.get_selected_item() == stored_item, "%s retrieval preserves exact item identity" % case_id)
	var orientations: Array = controller.call("_entry_orientations_for_item", stored_item)
	stored_surface.set_zone_rect(stored_item.get_storage_category(), Vector2i.ZERO, stored_surface.grid_size - Vector2i.ONE)
	var alternate := orientations[1] as StorageStack.Entry if orientations.size() > 1 else null
	var fit := stored_surface.find_zone_stack_or_empty_fit(stored_item.get_storage_category(), orientations[0] as StorageStack.Entry, alternate)
	controller.set("_current_surface", stored_surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	_check(controller.place_selected(), "%s re-stores through the normal controller" % case_id)
	var tall := ItemInstance.new(load("res://data/items/definitions/loot_000032.tres") as ItemDefinition)
	var tall_entry := controller.call("_entry_for_item", tall, false) as StorageStack.Entry
	var narrow_surface := surfaces[1] as StorageSurface
	_check(
		tall_entry != null and bool(narrow_surface.get_singleton_clearance_result(tall_entry, 0.0).get("valid", false)),
		"%s accepts the revised opening's credible tall-item fit" % case_id
	)


func _exercise_eye_toggle(scene: Node, case_id: String) -> void:
	var player := scene.get_node_or_null("Player") as Node3D
	var camera := scene.get_node_or_null("Player/Camera3D") as Camera3D
	var carried := scene.get_node_or_null("Player/CarriedItems") as CarriedItems
	_check(player != null and camera != null and carried != null and scene.has_method("toggle_review_eye_height"), "%s provides a player-preserving eye toggle" % case_id)
	if player == null or camera == null or carried == null or not scene.has_method("toggle_review_eye_height"):
		return
	var player_xz := Vector2(player.global_position.x, player.global_position.z)
	var view_basis := camera.global_basis
	var selected_item := carried.get_selected_item() as ItemInstance
	scene.call("toggle_review_eye_height")
	await process_frame
	var toggled: Dictionary = scene.call("get_review_contract") as Dictionary
	_check(is_equal_approx(float(toggled.get("eye_height_m", 0.0)), 1.716), "%s toggles to the existing approximately 1.71 m eye height" % case_id)
	_check(Vector2(player.global_position.x, player.global_position.z).is_equal_approx(player_xz), "%s preserves player X/Z during eye toggle" % case_id)
	_check(camera.global_basis.is_equal_approx(view_basis), "%s preserves viewing direction during eye toggle" % case_id)
	_check(carried.get_selected_item() == selected_item, "%s preserves carried item state during eye toggle" % case_id)


func _assert_authoritative_supply(scene: Node, case_id: String) -> void:
	var setups := scene.find_children("DevelopmentSetup", "Node3D", true, false)
	_check(setups.size() == 1, "%s contains exactly one reused DevelopmentSetup" % case_id)
	var live_setup := scene.get_node_or_null("DevelopmentSetup") as Node3D
	_check(live_setup != null, "%s attaches the reused setup at the review root" % case_id)
	_check(scene.get_node_or_null("CabinetTakeSamples") == null, "%s has no live cabinet-only sample fixture" % case_id)
	_check(scene.find_child("WingGameplay", true, false) == null, "%s retains no temporary WingGameplay root" % case_id)
	for root_name: String in ["Player", "HUD", "Environment"]:
		var matches := scene.find_children(root_name, "", true, false)
		_check(matches.size() == 1, "%s retains exactly one %s subtree" % [case_id, root_name])
	_check(scene.find_child("FunctionalFixtures", true, false) == null, "%s retains no gameplay FunctionalFixtures subtree" % case_id)
	var status := scene.get_node_or_null("ReviewStatus")
	var label := status.find_child("*", true, false) as Label if status != null else null
	_check(label != null and not label.text.contains("cabinet TAKE only"), "%s status no longer advertises cabinet-only supply" % case_id)
	if live_setup == null:
		return

	var expected_root := (load(GAMEPLAY_SCENE) as PackedScene).instantiate()
	var expected_setup := expected_root.get_node_or_null("DevelopmentSetup") as Node3D
	_check(expected_setup != null, "%s authoritative gameplay composition exposes DevelopmentSetup" % case_id)
	if expected_setup == null:
		expected_root.free()
		return
	_assert_composed_children_match(expected_setup.get_node("Tables"), live_setup.get_node_or_null("Tables"), case_id, "table")
	_assert_composed_children_match(expected_setup.get_node("SeedItems"), live_setup.get_node_or_null("SeedItems"), case_id, "seed host")

	var seed_items := live_setup.get_node_or_null("SeedItems")
	var registrar := live_setup.get_node_or_null("SeedRegistrar")
	var registered_ids: Array = registrar.call("get_registered_instance_ids") as Array if registrar != null else []
	var hosts := seed_items.get_children() if seed_items != null else []
	_check(registrar != null, "%s reused setup retains its SeedRegistrar" % case_id)
	_check(registered_ids.size() == hosts.size(), "%s registers every authored host exactly once" % case_id)
	var unique_ids: Dictionary = {}
	var fuel_found := false
	for value: Variant in hosts:
		var host := value as Node3D
		if host == null:
			continue
		var item_id := StringName(host.get("item_id"))
		_check(not BLOCKED_ITEM_IDS.has(item_id), "%s reused supply excludes blocked item %s" % [case_id, item_id])
		fuel_found = fuel_found or item_id == &"loot_000015"
		var expected_id := "wing_seed_v1:%s" % host.name
		_check(registered_ids.has(expected_id), "%s registers %s with the authoritative namespace" % [case_id, host.name])
		unique_ids[expected_id] = true
		_check(host.find_children("WorldItem", "WorldItem", true, false).size() == 1, "%s host %s owns exactly one WorldItem" % [case_id, host.name])
	_check(unique_ids.size() == hosts.size(), "%s reused supply has no duplicate registered identities" % case_id)
	_check(fuel_found, "%s reused supply includes Fuel" % case_id)
	expected_root.free()


func _assert_composed_children_match(expected_parent: Node, live_parent: Node, case_id: String, label: String) -> void:
	_check(live_parent != null, "%s reused setup retains its %s root" % [case_id, label])
	if live_parent == null:
		return
	var expected_children := expected_parent.get_children()
	var live_children := live_parent.get_children()
	_check(live_children.size() == expected_children.size(), "%s reuses every composed %s" % [case_id, label])
	for value: Variant in expected_children:
		var expected := value as Node3D
		var live := live_parent.get_node_or_null(NodePath(String(expected.name))) as Node3D
		_check(live != null, "%s reuses composed %s %s" % [case_id, label, expected.name])
		if live == null:
			continue
		_check(live.transform.is_equal_approx(expected.transform), "%s preserves %s %s transform" % [case_id, label, expected.name])
		if label == "seed host":
			_check(live.get("item_id") == expected.get("item_id"), "%s preserves %s item identity" % [case_id, expected.name])


func _exercise_reused_supply_pickup(scene: Node, case_id: String) -> void:
	var carried := scene.get_node_or_null("Player/CarriedItems") as CarriedItems
	var fuel_host := scene.get_node_or_null("DevelopmentSetup/SeedItems/Fuel_Canister") as Node3D
	var world := fuel_host.get_node_or_null("WorldItem") as WorldItem if fuel_host != null else null
	var item := world.get_item_instance() as ItemInstance if world != null else null
	_check(carried != null and world != null and item != null, "%s exposes authoritative Fuel through the review player path" % case_id)
	if carried == null or world == null or item == null:
		return
	_check(world.pickup_into(carried), "%s picks up Fuel from the reused gameplay table" % case_id)
	_check(carried.get_selected_item() == item, "%s reused supply pickup preserves exact Fuel identity" % case_id)
	carried.call("remove_item", item)
	await process_frame


func _exercise_review_manual_and_stack(scene: Node, case_id: String) -> void:
	var carried := scene.get_node("Player/CarriedItems") as CarriedItems
	var controller := scene.get_node("Player/StoragePlacementController") as StoragePlacementController
	var surfaces := scene.find_children("*", "StorageSurface", true, false)
	var hammer_host := scene.get_node("DevelopmentSetup/SeedItems/Hammer") as Node3D
	var hammer_world := hammer_host.get_node("WorldItem") as WorldItem
	var hammer_item := hammer_world.get_item_instance() as ItemInstance
	_check(hammer_world.pickup_into(carried), "%s takes the irregular Hammer from reused supply" % case_id)
	var manual_surface := surfaces[3] as StorageSurface
	var hammer_entry := controller.call("_entry_for_item", hammer_item, true) as StorageStack.Entry
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
	_check(controller.place_selected(), "%s manually places and rotates reused Hammer on a review shelf" % case_id)
	var hammer_stack := manual_surface.get_storage_stack(hammer_item.instance_id)
	_check(hammer_stack != null and hammer_stack.entries.size() == 1, "%s manual PUT creates one real review-shelf entry" % case_id)
	if hammer_stack != null and not hammer_stack.entries.is_empty():
		_check(hammer_stack.entries[0].packing_rotated, "%s manual PUT preserves rotation" % case_id)
		_check((hammer_stack.entries[0].world_item as WorldItem).pickup_into(carried), "%s retrieves the manually placed Hammer" % case_id)
		carried.call("remove_item", hammer_item)
	controller.set_manual_mode(false)

	var stack_surface := surfaces[0] as StorageSurface
	var stacked_items: Array[ItemInstance] = []
	for host_name: String in ["Book2", "CDStack_B2"]:
		var host := scene.get_node("DevelopmentSetup/SeedItems/%s" % host_name) as Node3D
		var world := host.get_node("WorldItem") as WorldItem
		var item := world.get_item_instance() as ItemInstance
		_check(world.pickup_into(carried), "%s takes %s from reused supply" % [case_id, host_name])
		stack_surface.set_zone_rect(item.get_storage_category(), Vector2i.ZERO, stack_surface.grid_size - Vector2i.ONE)
		var orientations: Array = controller.call("_entry_orientations_for_item", item)
		var fit := stack_surface.find_zone_stack_or_empty_fit(
			item.get_storage_category(),
			orientations[0] as StorageStack.Entry,
			orientations[1] as StorageStack.Entry if orientations.size() > 1 else null
		)
		controller.set("_current_surface", stack_surface)
		controller.set("_current_fit", fit)
		controller.set("_manual_mode", false)
		_check(controller.place_selected(), "%s auto-places %s on a review shelf" % [case_id, host_name])
		stacked_items.append(item)
	var stack_id := stack_surface.get_stack_id_for_item(stacked_items[0].instance_id)
	var stack := stack_surface.get_storage_stack(stack_id)
	_check(stack != null and stack.entries.size() == 2, "%s stacks matching reused items on the functional review shelf" % case_id)
	for index: int in [1, 0]:
		var item := stacked_items[index]
		var current_stack := stack_surface.get_storage_stack(stack_surface.get_stack_id_for_item(item.instance_id))
		var stored_world: WorldItem = null
		if current_stack != null:
			for entry: StorageStack.Entry in current_stack.entries:
				if entry.item == item:
					stored_world = entry.world_item as WorldItem
					break
		_check(stored_world != null and stored_world.pickup_into(carried), "%s retrieves stacked reused item %s" % [case_id, item.instance_id])
		carried.call("remove_item", item)
	_check(stack_surface.get_stack_count() == 0, "%s stacked review shelf returns to empty after retrieval" % case_id)
	await process_frame


func _assert_metal_fixture_clearance_and_coherence(scene: Node, case_id: String) -> void:
	var metal := scene.get_node_or_null("ReviewFixtures/SM_MetalShelves_Ergonomics") as Node3D
	var collision := scene.get_node_or_null("ReviewFixtureCollision/SM_MetalShelves_Ergonomics_ReviewCollision") as StaticBody3D
	_check(metal != null and collision != null and scene.has_method("_global_bounds"), "%s has the complete moved metal fixture and collision" % case_id)
	if metal == null or collision == null or not scene.has_method("_global_bounds"):
		return
	var bounds := scene.call("_global_bounds", metal) as AABB
	_check(bounds.position.z > -12.85, "%s metal fixture clears Gallery B's north wall inner face" % case_id)
	var shape_node := collision.get_node_or_null("UnitScaleShape") as CollisionShape3D
	var box := shape_node.shape as BoxShape3D if shape_node != null else null
	_check(
		box != null and collision.global_position.is_equal_approx(bounds.get_center()) and box.size.is_equal_approx(bounds.size),
		"%s metal collision follows the moved fixture bounds" % case_id
	)
	var metal_surfaces := 0
	var metal_stored_samples := 0
	for value: Variant in scene.find_children("*", "StorageSurface", true, false):
		var surface := value as StorageSurface
		if surface == null or surface.get_parent() != metal:
			continue
		metal_surfaces += 1
		_check(bounds.has_point(surface.global_position), "%s metal support remains inside the moved fixture bounds" % case_id)
		for stack_value: Variant in (surface.get("_stacks") as Dictionary).values():
			metal_stored_samples += (stack_value as StorageStack).entries.size()
	_check(metal_surfaces == 4, "%s preserves all four moved metal supports" % case_id)
	_check(metal_stored_samples >= 2, "%s preserves the moved metal review samples" % case_id)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
