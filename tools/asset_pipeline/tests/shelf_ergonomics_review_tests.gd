extends SceneTree

const REVIEW_SCENE := "res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn"
const GAMEPLAY_SCENE := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const FIXED_LADDER_SCENE := "res://gameplay/traversal/fixed_ladder/fixed_ladder.tscn"
const METAL_SCENE := "res://assets/environment/furniture/storage/SM_MetalShelves.glb"
const LOCKER_SCENE := "res://assets/environment/furniture/storage/SM_ventilated_locker.glb"
const BLOCKED_ITEM_IDS: Array[StringName] = [&"loot_000034", &"loot_000036"]
const StorageItemOrientationScript = preload("res://storage_item_orientation.gd")

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
	var saved_fixtures := scene.get_node_or_null("ReviewFixtures") as Node3D
	_check(saved_fixtures != null, "%s review scene saves its ReviewFixtures root" % case_id)
	var authored_racks := _direct_modular_racks(saved_fixtures)
	var starter := saved_fixtures.get_node_or_null("ModularRack_Starter") as ModularRack
	var proof_rack := saved_fixtures.get_node_or_null("ModularRack_LadderProof") as ModularRack
	var proof_ladder := saved_fixtures.get_node_or_null("FixedLadder_LadderProof") as Node3D
	_check(starter != null, "%s retains the promoted ModularRack_Starter" % case_id)
	_check(
		starter != null and (starter.get_node("Levels") as Node3D).get_child_count() == 3,
		"%s ground-access starter retains its three authored levels" % case_id
	)
	_check(proof_rack != null and proof_rack != starter, "%s saves one separate ladder-proof ModularRack" % case_id)
	_check(
		proof_rack != null and (proof_rack.get_node("Levels") as Node3D).get_child_count() > 0,
		"%s ladder-proof rack owns ordinary scene-local levels" % case_id
	)
	_check(
		proof_ladder != null and proof_ladder.scene_file_path == FIXED_LADDER_SCENE,
		"%s saves one reusable FixedLadder proof instance" % case_id
	)
	_check(authored_racks.size() == 2, "%s contains only the starter and dedicated proof racks" % case_id)
	if proof_rack != null and proof_ladder != null:
		var proof_levels := proof_rack.get_node("Levels") as Node3D
		var highest_support := _highest_level_y(proof_levels)
		_check(highest_support > 2.0, "%s proof rack highest support is beyond comfortable standing access" % case_id)
		_check(
			float(proof_ladder.get("ladder_height_m")) > highest_support,
			"%s proof ladder extends above the highest proof shelf" % case_id
		)
		_check(
			is_equal_approx(float(proof_ladder.get("overhead_limit_local_y_m")), 3.40),
			"%s proof ladder authors the 3.40 m overhead limit" % case_id
		)
		_check(is_zero_approx(proof_ladder.position.y), "%s proof ladder root is authored at floor level" % case_id)
	var authored_legacy := _assert_saved_legacy_orientation_fixtures(
		saved_fixtures,
		authored_racks,
		case_id
	)
	var expected_metal_state := 0
	var expected_locker_state := 0
	if case_id == "A" and not authored_legacy.is_empty():
		var metal_context := authored_legacy.get("metal_context") as StorageUnitOrientation
		var locker_context := authored_legacy.get("locker_context") as StorageUnitOrientation
		var rack := authored_racks[0] if not authored_racks.is_empty() else null
		metal_context.storage_orientation_quarter_turns = 2
		_check(locker_context.get_storage_orientation_quarter_turns() == 0, "changing saved Metal Shelf orientation leaves Locker unchanged")
		_check(rack == null or rack.get_storage_orientation_quarter_turns() == 0, "changing saved Metal Shelf orientation leaves ModularRack unchanged")
		locker_context.storage_orientation_quarter_turns = 3
		_check(metal_context.get_storage_orientation_quarter_turns() == 2, "changing saved Locker orientation leaves Metal Shelf unchanged")
		_check(rack == null or rack.get_storage_orientation_quarter_turns() == 0, "changing saved Locker orientation leaves ModularRack unchanged")
		expected_metal_state = 2
		expected_locker_state = 3
	scene.set("case_override", case_id)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	_assert_runtime_legacy_orientation_fixtures(
		scene,
		case_id,
		expected_metal_state,
		expected_locker_state
	)
	_assert_authoritative_supply(scene, case_id)
	_assert_modular_review_scene(scene, case_id)
	_assert_ladder_proof_runtime(scene, case_id)
	if case_id == "A":
		_assert_existing_review_entry_orientation_parity(scene)
		_assert_cross_family_item_orientation(scene)
	_check(scene.has_method("get_review_contract"), "%s exposes a review contract" % case_id)
	if scene.has_method("get_review_contract"):
		var contract: Dictionary = scene.call("get_review_contract") as Dictionary
		var current_racks := _direct_modular_racks(scene.get_node_or_null("ReviewFixtures") as Node3D)
		var current_level_count := _authored_modular_level_count(current_racks)
		_check(contract.get("case") == case_id, "%s selects the requested preset" % case_id)
		_check(contract.get("functional_family_count") == 2, "%s has metal and locker storage only" % case_id)
		_check(contract.get("cabinet_surface_count") == 0, "%s cabinet remains TAKE-only" % case_id)
		_check(int(contract.get("legacy_surface_count", -1)) == 8, "%s preserves four metal and four locker supports" % case_id)
		_check(int(contract.get("modular_rack_count", -1)) == current_racks.size(), "%s reports the current authored modular-rack count" % case_id)
		_check(int(contract.get("modular_level_count", -1)) == current_level_count, "%s reports the current authored modular-level count" % case_id)
		_check(int(contract.get("modular_surface_count", -1)) == current_level_count, "%s installs one modular surface per valid authored level" % case_id)
		_check(int(contract.get("surface_count", -1)) == 8 + current_level_count, "%s derives total surfaces from legacy plus current modular levels" % case_id)
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


func _assert_saved_legacy_orientation_fixtures(
	fixtures: Node3D,
	authored_racks: Array[ModularRack],
	case_id: String
) -> Dictionary:
	var metal_instances := _direct_scene_instances(fixtures, METAL_SCENE)
	var locker_instances := _direct_scene_instances(fixtures, LOCKER_SCENE)
	_check(metal_instances.size() == 1, "%s review scene saves exactly one functional Metal Shelf" % case_id)
	_check(locker_instances.size() == 1, "%s review scene saves exactly one functional Ventilated Locker" % case_id)
	if metal_instances.size() != 1 or locker_instances.size() != 1:
		return {}

	var metal := metal_instances[0]
	var locker := locker_instances[0]
	var metal_context := metal.get_node_or_null("StorageUnitOrientation") as StorageUnitOrientation
	var locker_context := locker.get_node_or_null("StorageUnitOrientation") as StorageUnitOrientation
	_check(metal.name == &"SM_MetalShelves_Ergonomics", "%s saved Metal Shelf retains its functional review identity" % case_id)
	_check(locker.name == &"SM_ventilated_locker_Ergonomics", "%s saved Locker retains its functional review identity" % case_id)
	_check(metal_context != null, "%s saved Metal Shelf exposes an editable StorageUnitOrientation" % case_id)
	_check(locker_context != null, "%s saved Locker exposes an editable StorageUnitOrientation" % case_id)
	if metal_context == null or locker_context == null:
		return {}
	_check(metal_context.get_storage_orientation_quarter_turns() == 0, "%s saved Metal Shelf defaults to orientation state 0" % case_id)
	_check(locker_context.get_storage_orientation_quarter_turns() == 0, "%s saved Locker defaults to orientation state 0" % case_id)
	if not authored_racks.is_empty():
		_check(authored_racks[0].get_storage_orientation_quarter_turns() == 0, "%s delivered ModularRack starter remains orientation state 0" % case_id)
	return {
		"metal": metal,
		"locker": locker,
		"metal_context": metal_context,
		"locker_context": locker_context,
	}


func _assert_runtime_legacy_orientation_fixtures(
	scene: Node,
	case_id: String,
	expected_metal_state: int,
	expected_locker_state: int
) -> void:
	var fixtures := scene.get_node_or_null("ReviewFixtures") as Node3D
	var metal_instances := _direct_scene_instances(fixtures, METAL_SCENE)
	var locker_instances := _direct_scene_instances(fixtures, LOCKER_SCENE)
	_check(metal_instances.size() == 1, "%s runtime setup does not duplicate the saved Metal Shelf" % case_id)
	_check(locker_instances.size() == 1, "%s runtime setup does not duplicate the saved Locker" % case_id)
	if metal_instances.size() != 1 or locker_instances.size() != 1:
		return

	var metal_surfaces := _direct_storage_surfaces(metal_instances[0])
	var locker_surfaces := _direct_storage_surfaces(locker_instances[0])
	_check(metal_surfaces.size() == 4, "%s saved Metal Shelf still generates four legacy surfaces" % case_id)
	_check(locker_surfaces.size() == 4, "%s saved Locker still generates four legacy surfaces" % case_id)
	_check(metal_surfaces.size() + locker_surfaces.size() == 8, "%s saved legacy fixtures still generate eight surfaces total" % case_id)
	for surface: StorageSurface in metal_surfaces:
		_check(surface.get_semantic_orientation_quarter_turns() == expected_metal_state, "%s every Metal Shelf surface inherits its saved unit orientation" % case_id)
	for surface: StorageSurface in locker_surfaces:
		_check(surface.get_semantic_orientation_quarter_turns() == expected_locker_state, "%s every Locker surface inherits its saved unit orientation" % case_id)


func _direct_scene_instances(fixtures: Node3D, scene_path: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	if fixtures == null:
		return result
	for child: Node in fixtures.get_children():
		if child is Node3D and String(child.scene_file_path) == scene_path:
			result.append(child as Node3D)
	return result


func _direct_storage_surfaces(unit: Node3D) -> Array[StorageSurface]:
	var result: Array[StorageSurface] = []
	if unit == null:
		return result
	for child: Node in unit.get_children():
		if child is StorageSurface:
			result.append(child as StorageSurface)
	return result


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
	var orientations: Array = controller.call(
		"_entry_orientations_for_item",
		stored_item,
		stored_surface.get_semantic_orientation_quarter_turns()
	)
	stored_surface.set_zone_rect(stored_item.get_storage_category(), Vector2i.ZERO, stored_surface.grid_size - Vector2i.ONE)
	var alternate := orientations[1] as StorageStack.Entry if orientations.size() > 1 else null
	var fit := stored_surface.find_zone_stack_or_empty_fit(stored_item.get_storage_category(), orientations[0] as StorageStack.Entry, alternate)
	controller.set("_current_surface", stored_surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	_check(controller.place_selected(), "%s re-stores through the normal controller" % case_id)
	var narrow_surface := _surface_by_id(surfaces, "SM_MetalShelves_Ergonomics_level_2")
	var tall := ItemInstance.new(load("res://data/items/definitions/loot_000032.tres") as ItemDefinition)
	var tall_entry := controller.call(
		"_entry_for_item",
		tall,
		false,
		narrow_surface.get_semantic_orientation_quarter_turns() if narrow_surface != null else 0
	) as StorageStack.Entry
	_check(
		tall_entry != null and narrow_surface != null and bool(narrow_surface.get_singleton_clearance_result(tall_entry, 0.0).get("valid", false)),
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
	var surfaces := _modular_surfaces(scene)
	_check(surfaces.size() >= 2, "%s exposes enough modular surfaces for manual and stacking checks" % case_id)
	if surfaces.size() < 2:
		return
	var hammer_host := scene.get_node("DevelopmentSetup/SeedItems/Hammer") as Node3D
	var hammer_world := hammer_host.get_node("WorldItem") as WorldItem
	var hammer_item := hammer_world.get_item_instance() as ItemInstance
	_check(hammer_world.pickup_into(carried), "%s takes the irregular Hammer from reused supply" % case_id)
	var manual_surface := surfaces[1] as StorageSurface
	var hammer_entry := controller.call(
		"_entry_for_item",
		hammer_item,
		true,
		manual_surface.get_semantic_orientation_quarter_turns()
	) as StorageStack.Entry
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
		_check(hammer_stack.entries[0].host.global_basis.get_scale().is_equal_approx(Vector3.ONE), "%s manual modular PUT preserves canonical item scale" % case_id)
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
		var orientations: Array = controller.call(
			"_entry_orientations_for_item",
			item,
			stack_surface.get_semantic_orientation_quarter_turns()
		)
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
	if stack != null:
		for entry: StorageStack.Entry in stack.entries:
			_check(entry.host.global_basis.get_scale().is_equal_approx(Vector3.ONE), "%s stacked modular loot remains canonical scale" % case_id)
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


func _assert_modular_review_scene(scene: Node, case_id: String) -> void:
	_check(scene.get_node_or_null("Control") == null, "%s removes obsolete Control rack/static-loot experiment" % case_id)
	_check(scene.get_node_or_null("Control2") == null, "%s removes obsolete Control2 rack/static-loot experiment" % case_id)
	var fixtures := scene.get_node_or_null("ReviewFixtures") as Node3D
	var racks := _direct_modular_racks(fixtures)
	_check(not racks.is_empty(), "%s retains at least one saved modular rack" % case_id)
	for rack: ModularRack in racks:
		var contract := rack.get_layout_contract()
		_check(bool(contract.get("valid", false)), "%s authored rack %s has a valid derived contract" % [case_id, rack.name])
		_check((rack.get_node("Levels") as Node3D).get_child_count() > 0, "%s authored rack %s derives levels from current children" % [case_id, rack.name])
		var rack_surfaces: Array[StorageSurface] = []
		for value: Variant in scene.find_children("*", "StorageSurface", true, false):
			var surface := value as StorageSurface
			if surface != null and _modular_rack_ancestor(surface) == rack:
				rack_surfaces.append(surface)
		var authored_state := rack.get_storage_orientation_quarter_turns()
		for surface: StorageSurface in rack_surfaces:
			_check(
				surface.get_semantic_orientation_quarter_turns() == authored_state,
				"%s rack %s propagates one root orientation to every level" % [case_id, rack.name]
			)
		var physical_before := _modular_physical_records(rack_surfaces)
		var alternate_state := (authored_state + 1) % 4
		for surface: StorageSurface in rack_surfaces:
			surface.set_semantic_orientation_quarter_turns(alternate_state)
		_check(
			_modular_physical_records(rack_surfaces) == physical_before,
			"%s rack %s semantic state leaves calibrated physical decks unchanged" % [case_id, rack.name]
		)
		for surface: StorageSurface in rack_surfaces:
			surface.set_semantic_orientation_quarter_turns(authored_state)
	for node: Node in scene.find_children("SM_Rack*", "", true, false):
		_check(_modular_rack_ancestor(node) != null, "%s has no raw Rack01/Rack02 experiment outside a ModularRack" % case_id)


func _assert_cross_family_item_orientation(scene: Node) -> void:
	var fixtures := scene.get_node("ReviewFixtures") as Node3D
	var racks := _direct_modular_racks(fixtures)
	var metal_units := _direct_scene_instances(fixtures, METAL_SCENE)
	var locker_units := _direct_scene_instances(fixtures, LOCKER_SCENE)
	var rack_surfaces := _modular_surfaces(scene)
	var metal_surfaces := (
		_direct_storage_surfaces(metal_units[0])
		if not metal_units.is_empty()
		else []
	)
	var locker_surfaces := (
		_direct_storage_surfaces(locker_units[0])
		if not locker_units.is_empty()
		else []
	)
	_check(
		not racks.is_empty()
		and not rack_surfaces.is_empty()
		and not metal_surfaces.is_empty()
		and not locker_surfaces.is_empty(),
		"cross-family pose fixture exposes ModularRack, Metal Shelf, and Locker"
	)
	if (
		racks.is_empty()
		or rack_surfaces.is_empty()
		or metal_surfaces.is_empty()
		or locker_surfaces.is_empty()
	):
		return
	var controller := scene.get_node("Player/StoragePlacementController") as StoragePlacementController
	var carried := scene.get_node("Player/CarriedItems") as CarriedItems
	var definition := load(
		"res://data/items/definitions/loot_000037.tres"
	) as ItemDefinition
	var cases := [
		{
			"label": "ModularRack",
			"surface": rack_surfaces[0],
			"state": racks[0].get_storage_orientation_quarter_turns(),
		},
		{
			"label": "Metal Shelf",
			"surface": metal_surfaces[0],
			"state": 2,
		},
		{
			"label": "Ventilated Locker",
			"surface": locker_surfaces[0],
			"state": 3,
		},
	]
	for family: Dictionary in cases:
		var surface := family["surface"] as StorageSurface
		var state := int(family["state"])
		var label := String(family["label"])
		_check(
			surface.get_semantic_orientation_quarter_turns() == state,
			"%s cross-family surface uses state %d" % [label, state]
		)
		for packing_rotated: bool in [false, true]:
			var item := ItemInstance.new(definition)
			_assert_family_item_placement(
				controller,
				carried,
				surface,
				item,
				state,
				packing_rotated,
				label
			)
	controller.set_manual_mode(false)


func _assert_existing_review_entry_orientation_parity(scene: Node) -> void:
	for value: Variant in scene.find_children("*", "StorageSurface", true, false):
		var surface := value as StorageSurface
		if surface == null:
			continue
		var state := surface.get_semantic_orientation_quarter_turns()
		for stack_value: Variant in (surface.get("_stacks") as Dictionary).values():
			var stack := stack_value as StorageStack
			if stack == null or stack.entries.is_empty():
				continue
			var base := stack.entries[0] as StorageStack.Entry
			var canonical_3d := base.item.get_storage_footprint()
			var expected := StorageItemOrientationScript.physical_footprint(
				Vector2i(canonical_3d.x, canonical_3d.y),
				state,
				base.packing_rotated
			)
			_check(
				stack.base_footprint == expected,
				"existing review sample reservation follows unit state %d" % state
			)
			var unit_root := base.host.get_node("StoredUnitOrientationYaw") as Node3D
			_check(
				unit_root.basis.is_equal_approx(Basis(
					Vector3.UP,
					StorageItemOrientationScript.unit_yaw_radians(state)
				)),
				"existing review sample visual follows unit state %d" % state
			)


func _assert_family_item_placement(
	controller: StoragePlacementController,
	carried: CarriedItems,
	surface: StorageSurface,
	item: ItemInstance,
	state: int,
	packing_rotated: bool,
	label: String
) -> void:
	var entry := controller.call(
		"_entry_for_item",
		item,
		packing_rotated,
		state
	) as StorageStack.Entry
	_check(entry != null, "%s builds %s entry" % [label, "packing" if packing_rotated else "canonical"])
	if entry == null:
		return
	var origin := _first_free_origin(surface, entry.footprint)
	_check(origin.x >= 0, "%s has room for %s pose" % [label, "packing" if packing_rotated else "canonical"])
	if origin.x < 0:
		return
	_check(carried.add_item(item), "%s item enters carry for pose verification" % label)
	var fit := {
		"valid": true,
		"placement_kind": "empty",
		"stack_id": item.instance_id,
		"insertion_index": 0,
		"origin": origin,
		"footprint": entry.footprint,
		"base_footprint": entry.footprint,
		"rotated": packing_rotated,
		"zone_kind": "manual",
		"zone_category": "",
		"host_y_m": surface.get_local_placement_position(origin, entry.footprint).y,
	}
	controller.set_manual_mode(true)
	controller.set("_rotated", packing_rotated)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	_check(controller.place_selected(), "%s commits %s pose" % [label, "packing" if packing_rotated else "canonical"])
	var stack := surface.get_storage_stack(item.instance_id)
	_check(stack != null and stack.entries.size() == 1, "%s stores one verified item" % label)
	if stack == null or stack.entries.is_empty():
		return
	var committed := stack.entries[0] as StorageStack.Entry
	var unit_root := committed.host.get_node("StoredUnitOrientationYaw") as Node3D
	var packing_root := unit_root.get_node("StoredPackingYaw") as Node3D
	_check(
		unit_root.basis.is_equal_approx(Basis(
			Vector3.UP,
			StorageItemOrientationScript.unit_yaw_radians(state)
		)),
		"%s unit-yaw root matches state %d" % [label, state]
	)
	_check(
		packing_root.basis.is_equal_approx(Basis(
			Vector3.UP,
			deg_to_rad(90.0) if packing_rotated else 0.0
		)),
		"%s packing root matches the placement choice" % label
	)
	_check(
		committed.host.global_basis.get_scale().is_equal_approx(Vector3.ONE),
		"%s canonical item scale remains one" % label
	)
	_check(
		surface.get_reservation(item.instance_id).get("footprint") == entry.footprint,
		"%s reservation matches combined quarter-turn parity" % label
	)
	_check(
		(committed.world_item as WorldItem).pickup_into(carried),
		"%s verified item retrieves after %s pose" % [label, "packing" if packing_rotated else "canonical"]
	)
	carried.call("remove_item", item)


func _first_free_origin(surface: StorageSurface, footprint: Vector2i) -> Vector2i:
	var size := surface.get_grid_size()
	for z: int in range(size.y - footprint.y + 1):
		for x: int in range(size.x - footprint.x + 1):
			var origin := Vector2i(x, z)
			if surface.can_place_at(origin, footprint):
				return origin
	return Vector2i(-1, -1)


func _modular_physical_records(surfaces: Array[StorageSurface]) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for surface: StorageSurface in surfaces:
		records.append({
			"surface_id": String(surface.surface_id),
			"global_transform": surface.global_transform,
			"grid_size": surface.get_grid_size(),
			"usable_size_m": surface.get_usable_size_m(),
			"stack_clearance_m": surface.stack_clearance_m,
		})
	records.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			return String(a.get("surface_id", "")) < String(b.get("surface_id", ""))
	)
	return records


func _direct_modular_racks(fixtures: Node3D) -> Array[ModularRack]:
	var result: Array[ModularRack] = []
	if fixtures == null:
		return result
	for child: Node in fixtures.get_children():
		if child is ModularRack:
			result.append(child as ModularRack)
	return result


func _highest_level_y(levels: Node3D) -> float:
	var result := -INF
	if levels == null:
		return result
	for child: Node in levels.get_children():
		if child is Node3D:
			result = maxf(result, (child as Node3D).position.y)
	return result


func _assert_ladder_proof_runtime(scene: Node, case_id: String) -> void:
	var proof_rack := scene.get_node_or_null("ReviewFixtures/ModularRack_LadderProof") as ModularRack
	var proof_ladder := scene.get_node_or_null("ReviewFixtures/FixedLadder_LadderProof") as Node3D
	var player := scene.get_node_or_null("Player") as CharacterBody3D
	var camera := scene.get_node_or_null("Player/Camera3D") as Camera3D
	_check(proof_rack != null and proof_ladder != null, "%s keeps the ladder proof installed at runtime" % case_id)
	_check(player != null and camera != null, "%s ladder proof uses the normal player camera" % case_id)
	if player != null and camera != null:
		var camera_local_yaw := wrapf(camera.rotation.y, -PI, PI)
		print(
			"REVIEW_VIEW_YAW_METRIC case=%s player=%.3f camera_local=%.3f"
			% [case_id, rad_to_deg(player.rotation.y), rad_to_deg(camera_local_yaw)]
		)
		_check(
			absf(camera_local_yaw) <= deg_to_rad(0.1),
			"%s keeps horizontal review yaw on the player body so the attached visible view remains symmetric" % case_id
		)
	if proof_rack == null or proof_ladder == null:
		return
	var authored_levels := (proof_rack.get_node("Levels") as Node3D).get_child_count()
	var proof_surfaces := 0
	for value: Variant in scene.find_children("*", "StorageSurface", true, false):
		var surface := value as StorageSurface
		if surface != null and _modular_rack_ancestor(surface) == proof_rack:
			proof_surfaces += 1
	_check(proof_surfaces == authored_levels, "%s proof rack builds one real StorageSurface per authored level" % case_id)
	_check(
		(proof_ladder.get_node("MovementCollision") as StaticBody3D).collision_layer != 0,
		"%s proof ladder retains ordinary movement collision" % case_id
	)


func _authored_modular_level_count(racks: Array[ModularRack]) -> int:
	var result := 0
	for rack: ModularRack in racks:
		var levels := rack.get_node_or_null("Levels")
		if levels != null:
			result += levels.get_child_count()
	return result


func _modular_surfaces(scene: Node) -> Array:
	var result: Array = []
	for value: Variant in scene.find_children("*", "StorageSurface", true, false):
		var surface := value as StorageSurface
		if surface != null and _modular_rack_ancestor(surface) != null:
			result.append(surface)
	return result


func _modular_rack_ancestor(node: Node) -> ModularRack:
	var current := node
	while current != null:
		if current is ModularRack:
			return current as ModularRack
		current = current.get_parent()
	return null


func _surface_by_id(surfaces: Array, requested_id: String) -> StorageSurface:
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface != null and String(surface.surface_id) == requested_id:
			return surface
	return null


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
