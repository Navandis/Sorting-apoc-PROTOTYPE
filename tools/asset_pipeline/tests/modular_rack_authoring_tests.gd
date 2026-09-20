extends SceneTree

const CarriedItemsScript = preload("res://carried_items.gd")
const FunctionalStorageManagerScript = preload("res://gameplay/logistics_wing/functional_storage_manager.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")

const RACK_SCENE := "res://gameplay/logistics_wing/storage/modular_rack.tscn"
const RACK02_SCENE := preload("res://assets/environment/furniture/storage/SM_Rack02.glb")
const POSITION_EPSILON_M := 0.002
const EXPECTED_DECK_LENGTH_AT_2_60_M := 2.440944
const EXPECTED_DECK_DEPTH_AT_0_72_M := 0.555012
const EXPECTED_DECK_THICKNESS_M := 0.023335
const EXPECTED_SURFACE_ORIGIN_Y_M := -0.012
const EXPECTED_GRID_LOCAL_Y_M := 0.012

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _test_scene_skeleton():
		_finish()
		return
	_test_authored_dimensions_and_collision()
	_test_stable_identity_and_physical_clearance()
	_test_asymmetric_insets_and_invalid_states()
	_test_save_reload_independence()
	_test_runtime_surfaces_and_world_transform()
	_test_grid_plane_is_contained_by_physical_deck()
	_test_item_scale_and_vertical_fit()
	await _test_manager_f6_f7()
	_finish()


func _test_scene_skeleton() -> bool:
	if not _check(ResourceLoader.exists(RACK_SCENE), "ModularRack scene exists"):
		return false
	var packed := load(RACK_SCENE) as PackedScene
	var rack := packed.instantiate() if packed != null else null
	if not _check(rack != null, "ModularRack scene instantiates"):
		return false
	root.add_child(rack)
	_check(
		rack.get_script() != null
		and String(rack.get_script().get_global_name()) == "ModularRack",
		"ModularRack scene instantiates as the global ModularRack class"
	)
	_check(rack.get_node_or_null("Frame/Visual") != null, "Rack01 visual exists")
	_check(rack.get_node_or_null("Levels") != null, "Levels root exists")
	_check(
		rack.get_node_or_null("MovementCollision/Shape") is CollisionShape3D,
		"movement collision exists"
	)
	var levels := rack.get_node_or_null("Levels")
	_check(
		levels != null and levels.get_child_count() == 0,
		"reusable rack scaffold owns no inherited shelf wrappers"
	)
	var empty_layout := rack.call("compute_layout") as Dictionary
	_check(bool(empty_layout.get("valid", false)), "shelf-empty rack scaffold remains a valid authoring state")
	_check((empty_layout.get("levels", []) as Array).is_empty(), "shelf-empty rack layout reports no authored levels")
	_check((rack.call("build_runtime_storage") as Array).is_empty(), "shelf-empty rack builds zero runtime surfaces")
	rack.free()
	return true


func _test_authored_dimensions_and_collision() -> void:
	var rack := _make_rack("GeometryRack")
	rack.set("rack_length_m", 2.60)
	rack.set("rack_depth_m", 0.72)
	rack.set("frame_height_m", 2.35)
	rack.call("refresh_authoring_state")

	var frame_bounds := _branch_local_bounds(rack.get_node("Frame") as Node3D)
	_check(_near(frame_bounds.size.x, 2.60), "frame length follows rack_length_m")
	_check(_near(frame_bounds.size.y, 2.35), "frame height follows frame_height_m")
	_check(_near(frame_bounds.size.z, 0.72), "frame depth follows rack_depth_m")
	_check(_near(frame_bounds.position.y, 0.0), "frame base is normalized to local Y zero")

	var shape_node := rack.get_node("MovementCollision/Shape") as CollisionShape3D
	var box := shape_node.shape as BoxShape3D
	_check(shape_node.scale.is_equal_approx(Vector3.ONE), "collision shape node stays unit scale")
	_check(box != null and _vector_near(box.size, Vector3(2.60, 2.35, 0.72)), "collision box follows authored envelope")
	_check(_vector_near(shape_node.position, Vector3(0.0, 1.175, 0.0)), "collision box is centered at half frame height")

	var layout := rack.call("compute_layout") as Dictionary
	var rack_record := layout.get("rack", {}) as Dictionary
	var platform_size := rack_record.get("platform_base_size", Vector2.ZERO) as Vector2
	_check(_near(platform_size.x, EXPECTED_DECK_LENGTH_AT_2_60_M), "Rack02 calibrated gray-deck length preserves source-family proportion")
	_check(_near(platform_size.y, EXPECTED_DECK_DEPTH_AT_0_72_M), "Rack02 calibrated gray-deck depth preserves source-family proportion")
	rack.free()


func _test_stable_identity_and_physical_clearance() -> void:
	var rack := _make_rack("IdentityRack")
	_set_level_y(rack, "Shelf_01", 0.25)
	_set_level_y(rack, "Shelf_02", 0.95)
	_set_level_y(rack, "Shelf_03", 1.65)
	rack.set("overhead_limit_local_y_m", 2.40)
	rack.call("refresh_authoring_state")
	var initial := rack.call("compute_layout") as Dictionary
	_check(bool(initial.get("valid", false)), "ordinary three-level rack layout is valid")
	var initial_ids := _surface_ids_by_level(initial)
	var initial_levels := initial.get("levels", []) as Array
	if initial_levels.size() >= 3:
		var lower := initial_levels[0] as Dictionary
		var upper := initial_levels[1] as Dictionary
		_check(
			_near(float(lower.get("clearance", -1.0)), 0.95 - EXPECTED_DECK_THICKNESS_M - (0.25 + EXPECTED_SURFACE_ORIGIN_Y_M)),
			"intermediate clearance uses the next Rack02 underside"
		)
		var top := initial_levels[2] as Dictionary
		_check(
			_near(float(top.get("clearance", -1.0)), 2.40 - (1.65 + EXPECTED_SURFACE_ORIGIN_Y_M)),
			"top clearance follows the authored overhead limit"
		)
		_check(String(lower.get("name", "")) == "Shelf_01" and String(upper.get("name", "")) == "Shelf_02", "initial levels sort by support height")

	_set_level_y(rack, "Shelf_01", 1.15)
	_set_level_y(rack, "Shelf_02", 0.45)
	rack.call("refresh_authoring_state")
	var crossed := rack.call("compute_layout") as Dictionary
	var crossed_levels := crossed.get("levels", []) as Array
	if crossed_levels.size() >= 3:
		_check(String((crossed_levels[0] as Dictionary).get("name", "")) == "Shelf_02", "crossed levels recalculate physical order")
		_check(String((crossed_levels[1] as Dictionary).get("name", "")) == "Shelf_01", "crossed levels keep identity independent of physical order")
	var crossed_ids := _surface_ids_by_level(crossed)
	_check(crossed_ids == initial_ids, "surface identity remains tied to rack and shelf names after crossing")
	rack.free()


func _test_asymmetric_insets_and_invalid_states() -> void:
	var rack := _make_rack("ValidationRack")
	rack.set("rack_length_m", 2.60)
	rack.set("rack_depth_m", 0.72)
	rack.set("usable_inset_left_m", 0.10)
	rack.set("usable_inset_right_m", 0.20)
	rack.set("usable_inset_front_m", 0.03)
	rack.set("usable_inset_back_m", 0.09)
	rack.call("refresh_authoring_state")
	var layout := rack.call("compute_layout") as Dictionary
	var levels := layout.get("levels", []) as Array
	if not levels.is_empty():
		var level := levels[0] as Dictionary
		_check(_vector2_near(level.get("usable_size", Vector2.ZERO) as Vector2, Vector2(2.140944, 0.435012)), "asymmetric insets reduce the calibrated gray-deck rectangle")
		_check(_vector2_near(level.get("usable_center", Vector2.ZERO) as Vector2, Vector2(-0.05, -0.03)), "asymmetric insets shift usable center in normalized local axes")

	var duplicate := Node3D.new()
	duplicate.name = "shelf_01"
	(rack.get_node("Levels") as Node3D).add_child(duplicate)
	duplicate.position.y = 2.0
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "case-insensitive duplicate shelf identity invalidates layout")
	duplicate.free()

	rack.set("usable_inset_left_m", 1.30)
	rack.set("usable_inset_right_m", 1.30)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "insets that erase usable width invalidate layout")
	rack.set("usable_inset_left_m", 0.04)
	rack.set("usable_inset_right_m", 0.04)

	rack.set("rack_length_m", 0.0)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "nonpositive rack dimensions invalidate layout")
	rack.set("rack_length_m", 2.60)

	_set_level_y(rack, "Shelf_01", 0.20)
	_set_level_y(rack, "Shelf_02", 0.20 + EXPECTED_SURFACE_ORIGIN_Y_M + EXPECTED_DECK_THICKNESS_M)
	_set_level_y(rack, "Shelf_03", 1.60)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "nonpositive physical opening invalidates layout")
	_set_level_y(rack, "Shelf_02", 0.20 + EXPECTED_SURFACE_ORIGIN_Y_M + EXPECTED_DECK_THICKNESS_M + 0.01)
	_check(bool((rack.call("compute_layout") as Dictionary).get("valid", false)), "small positive physical opening remains legal")

	rack.set("overhead_limit_local_y_m", 1.60 + EXPECTED_SURFACE_ORIGIN_Y_M)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "top level at the overhead limit invalidates layout")
	rack.set("overhead_limit_local_y_m", 3.40)
	rack.set("frame_height_m", 1.50)
	var above_frame := rack.call("compute_layout") as Dictionary
	_check(bool(above_frame.get("valid", false)), "highest level above frame remains functional")
	_check(not (above_frame.get("warnings", []) as Array).is_empty(), "highest level above frame produces a warning")

	rack.scale = Vector3(1.1, 1.0, 1.0)
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "non-unit root scale invalidates layout")
	rack.scale = Vector3.ONE
	rack.rotation.x = 0.1
	_check(not bool((rack.call("compute_layout") as Dictionary).get("valid", true)), "root pitch invalidates layout")
	rack.free()


func _test_save_reload_independence() -> void:
	var packed_rack := load(RACK_SCENE) as PackedScene
	var host := Node3D.new()
	host.name = "RoundTripHost"
	root.add_child(host)
	var rack_a := packed_rack.instantiate() as Node3D
	rack_a.name = "Rack_A"
	host.add_child(rack_a)
	rack_a.owner = host
	host.set_editable_instance(rack_a, true)
	_replace_with_local_test_levels(rack_a, host)
	rack_a.set("rack_length_m", 2.15)
	rack_a.set("rack_depth_m", 0.66)
	var rack_b := rack_a.duplicate(Node.DUPLICATE_USE_INSTANTIATION) as Node3D
	rack_b.name = "Rack_B"
	host.add_child(rack_b)
	rack_b.owner = host
	host.set_editable_instance(rack_b, true)
	_set_local_level_owners(rack_b, host)
	rack_b.set("rack_length_m", 3.05)
	rack_b.set("rack_depth_m", 0.91)
	_set_level_y(rack_b, "Shelf_02", 1.22)
	var duplicated_level := (rack_b.get_node("Levels/Shelf_02") as Node3D).duplicate() as Node3D
	duplicated_level.name = "Shelf_RoundTrip"
	(rack_b.get_node("Levels") as Node3D).add_child(duplicated_level)
	duplicated_level.owner = host
	for child: Node in duplicated_level.get_children():
		child.owner = host
	duplicated_level.position.y = 2.18
	var deleted_level := rack_b.get_node("Levels/Shelf_03")
	deleted_level.get_parent().remove_child(deleted_level)
	deleted_level.free()
	rack_a.call("refresh_authoring_state")
	rack_b.call("refresh_authoring_state")

	var round_trip := PackedScene.new()
	_check(round_trip.pack(host) == OK, "two authored racks pack for save/reload")
	var path := "user://modular_rack_round_trip.tscn"
	_check(ResourceSaver.save(round_trip, path) == OK, "authored rack round-trip scene saves")
	var reloaded_packed := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE) as PackedScene
	var reloaded := reloaded_packed.instantiate() as Node3D if reloaded_packed != null else null
	_check(reloaded != null, "authored rack round-trip scene reloads")
	if reloaded != null:
		root.add_child(reloaded)
		var loaded_a := reloaded.get_node("Rack_A") as Node3D
		var loaded_b := reloaded.get_node("Rack_B") as Node3D
		_check(_near(float(loaded_a.get("rack_length_m")), 2.15), "rack A root authoring property persists")
		_check(_near(float(loaded_b.get("rack_length_m")), 3.05), "rack B root authoring property persists independently")
		_check(_near((loaded_a.get_node("Levels/Shelf_02") as Node3D).position.y, 0.95), "original rack shelf transform remains unchanged")
		_check(_near((loaded_b.get_node("Levels/Shelf_02") as Node3D).position.y, 1.22), "rack B shelf transform persists independently")
		_check((loaded_a.get_node("Levels") as Node3D).get_child_count() == 3, "original rack keeps its three local shelf levels")
		_check((loaded_b.get_node("Levels") as Node3D).get_child_count() == 3, "duplicate add/delete sequence persists its resulting level count")
		_check(loaded_b.get_node_or_null("Levels/Shelf_03") == null, "deleted local shelf remains deleted after reload")
		_check(loaded_b.get_node_or_null("Levels/Shelf_RoundTrip") != null, "duplicated local shelf persists after reload")
		loaded_a.call("refresh_authoring_state")
		loaded_b.call("refresh_authoring_state")
		var shape_a := (loaded_a.get_node("MovementCollision/Shape") as CollisionShape3D).shape
		var shape_b := (loaded_b.get_node("MovementCollision/Shape") as CollisionShape3D).shape
		_check(shape_a != shape_b, "duplicated rack instances do not share mutable collision resources")
		reloaded.free()
	host.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _test_runtime_surfaces_and_world_transform() -> void:
	var rack := _make_rack("RuntimeRack")
	rack.position = Vector3(4.0, 0.35, -3.0)
	rack.rotation.y = PI * 0.5
	rack.call("refresh_authoring_state")
	var layout := rack.call("compute_layout") as Dictionary
	var levels := layout.get("levels", []) as Array
	var surfaces := rack.call("build_runtime_storage") as Array
	_check(surfaces.size() == levels.size(), "runtime build creates one StorageSurface per valid authored level")
	var second_build := rack.call("build_runtime_storage") as Array
	_check(second_build.size() == surfaces.size(), "runtime build is idempotent")
	if surfaces.size() == levels.size() and not surfaces.is_empty():
		for index: int in range(surfaces.size()):
			var surface := surfaces[index] as StorageSurface
			var level := levels[index] as Dictionary
			var expected_local := Vector3(
				(level.get("usable_center", Vector2.ZERO) as Vector2).x,
				float(level.get("surface_origin_y", 0.0)),
				(level.get("usable_center", Vector2.ZERO) as Vector2).y
			)
			var expected_global := rack.global_transform * expected_local
			var requested_size := level.get("usable_size", Vector2.ZERO) as Vector2
			var expected_grid := Vector2i(
				int(floor(requested_size.x / 0.10)),
				int(floor(requested_size.y / 0.10))
			)
			_check(String(surface.surface_id) == String(level.get("surface_id", "")), "runtime surface uses derived stable identity")
			_check(surface.get_grid_size() == expected_grid, "runtime surface quantizes the derived usable dimensions")
			_check(_near(surface.stack_clearance_m, float(level.get("clearance", -1.0))), "runtime surface uses derived physical clearance")
			_check(surface.global_position.distance_to(expected_global) <= POSITION_EPSILON_M, "runtime surface follows translated/yaw-rotated rack placement")
			_check(surface.global_basis.get_scale().is_equal_approx(Vector3.ONE), "runtime surface remains unit scale")
			_check(surface.get_parent() == level.get("node"), "runtime surface remains logically associated with its shelf level")
		_check(surfaces[0] == second_build[0], "idempotent runtime build returns the same installed surfaces")
	rack.free()


func _test_grid_plane_is_contained_by_physical_deck() -> void:
	var rack := _make_rack("DeckContainmentRack")
	rack.set("rack_length_m", 2.60)
	rack.set("rack_depth_m", 0.72)
	rack.set("usable_inset_left_m", 0.10)
	rack.set("usable_inset_right_m", 0.20)
	rack.set("usable_inset_front_m", 0.03)
	rack.set("usable_inset_back_m", 0.09)
	rack.call("refresh_authoring_state")
	var layout := rack.call("compute_layout") as Dictionary
	var surfaces := rack.call("build_runtime_storage") as Array
	var levels := layout.get("levels", []) as Array
	_check(surfaces.size() == 3 and levels.size() == 3, "calibrated rack builds each local shelf surface")
	if surfaces.size() == 3 and levels.size() == 3:
		for index: int in range(3):
			var surface := surfaces[index] as StorageSurface
			var level := levels[index] as Dictionary
			var level_node := level.get("node") as Node3D
			var actual_grid_size := surface.get_usable_size_m()
			var center := level.get("usable_center", Vector2.ZERO) as Vector2
			var min_x := center.x - actual_grid_size.x * 0.5
			var max_x := center.x + actual_grid_size.x * 0.5
			var min_z := center.y - actual_grid_size.y * 0.5
			var max_z := center.y + actual_grid_size.y * 0.5
			_check(min_x >= -EXPECTED_DECK_LENGTH_AT_2_60_M * 0.5 - POSITION_EPSILON_M, "quantized grid left edge stays within gray deck")
			_check(max_x <= EXPECTED_DECK_LENGTH_AT_2_60_M * 0.5 + POSITION_EPSILON_M, "quantized grid right edge stays within gray deck")
			_check(min_z >= -EXPECTED_DECK_DEPTH_AT_0_72_M * 0.5 - POSITION_EPSILON_M, "quantized grid front edge stays within gray deck")
			_check(max_z <= EXPECTED_DECK_DEPTH_AT_0_72_M * 0.5 + POSITION_EPSILON_M, "quantized grid back edge stays within gray deck")
			var surface_origin_in_level := level_node.to_local(surface.global_position).y
			_check(_near(surface_origin_in_level, EXPECTED_SURFACE_ORIGIN_Y_M), "StorageSurface origin compensates for its internal debug offset")
			_check(_near(surface_origin_in_level + EXPECTED_GRID_LOCAL_Y_M, 0.0), "F6 grid plane coincides with the physical deck top")
	rack.free()


func _test_item_scale_and_vertical_fit() -> void:
	var short_rack := _make_rack("ShortOpeningRack")
	_set_level_y(short_rack, "Shelf_01", 0.25)
	_set_level_y(short_rack, "Shelf_02", 0.25 + EXPECTED_SURFACE_ORIGIN_Y_M + EXPECTED_DECK_THICKNESS_M + 0.30)
	_set_level_y(short_rack, "Shelf_03", 1.60)
	short_rack.call("refresh_authoring_state")
	var short_surfaces := short_rack.call("build_runtime_storage") as Array
	_check(short_surfaces.size() == 3, "short-opening rack remains structurally valid")

	var context := _placement_context()
	var controller := context["controller"] as StoragePlacementController
	var tall_definition := load("res://data/items/definitions/loot_000002.tres") as ItemDefinition
	var tall_item := ItemInstanceScript.new(tall_definition)
	var orientations := controller.call("_entry_orientations_for_item", tall_item) as Array
	if not short_surfaces.is_empty() and not orientations.is_empty():
		var short_surface := short_surfaces[0] as StorageSurface
		short_surface.set_zone_rect(tall_item.get_storage_category(), Vector2i.ZERO, short_surface.grid_size - Vector2i.ONE)
		var rejected := short_surface.find_zone_stack_or_empty_fit(
			tall_item.get_storage_category(),
			orientations[0] as StorageStack.Entry,
			orientations[1] as StorageStack.Entry if orientations.size() > 1 else null
		)
		_check(not bool(rejected.get("valid", true)), "tall item fails in intentionally short modular opening")

	var open_rack := _make_rack("OpenRack")
	_set_level_y(open_rack, "Shelf_01", 0.25)
	_set_level_y(open_rack, "Shelf_02", 1.05)
	_set_level_y(open_rack, "Shelf_03", 1.75)
	open_rack.call("refresh_authoring_state")
	var open_surfaces := open_rack.call("build_runtime_storage") as Array
	_check(open_surfaces.size() == 3, "fresh rack with raised upper shelf builds all surfaces")
	if not open_surfaces.is_empty() and not orientations.is_empty():
		var open_surface := open_surfaces[0] as StorageSurface
		open_surface.set_zone_rect(tall_item.get_storage_category(), Vector2i.ZERO, open_surface.grid_size - Vector2i.ONE)
		var accepted := open_surface.find_zone_stack_or_empty_fit(
			tall_item.get_storage_category(),
			orientations[0] as StorageStack.Entry,
			orientations[1] as StorageStack.Entry if orientations.size() > 1 else null
		)
		_check(bool(accepted.get("valid", false)), "same tall item fits on a fresh rack after the upper shelf is raised")
		var carried := context["carried"] as CarriedItems
		_check(carried.add_item(tall_item), "real tall item enters carried storage fixture")
		controller.set("_current_surface", open_surface)
		controller.set("_current_fit", accepted)
		controller.set("_manual_mode", false)
		_check(controller.place_selected(), "real controller stores the tall item on modular surface")
		var stack_id := open_surface.get_stack_id_for_item(tall_item.instance_id)
		var stack := open_surface.get_storage_stack(stack_id)
		_check(stack != null and stack.entries.size() == 1, "modular surface owns the real stored stack")
		if stack != null and not stack.entries.is_empty():
			var entry := stack.entries[0] as StorageStack.Entry
			_check(entry.host.global_basis.get_scale().is_equal_approx(Vector3.ONE), "stored modular-rack loot remains canonical scale")
			_check(not bool(open_rack.call("clear_runtime_storage")), "occupied rack refuses runtime surface reconfiguration")
			_check(entry.world_item.pickup_into(carried), "stored modular-rack item retrieves through WorldItem")
			_check(carried.get_selected_item() == tall_item, "retrieval preserves exact ItemInstance identity")
			_check(bool(open_rack.call("clear_runtime_storage")), "empty rack permits test-lifecycle surface cleanup")

	_free_placement_context(context)
	short_rack.free()
	open_rack.free()


func _test_manager_f6_f7() -> void:
	var fixtures := Node3D.new()
	fixtures.name = "ManagerFixtures"
	root.add_child(fixtures)
	var rack := _make_rack("ManagedRack")
	root.remove_child(rack)
	fixtures.add_child(rack)
	var manager := FunctionalStorageManagerScript.new() as StoragePrototypeManager
	manager.name = "FunctionalStorageManager"
	fixtures.add_child(manager)
	manager.install(fixtures)
	manager.set_process_unhandled_input(true)
	var surfaces := manager.get_surfaces()
	_check(surfaces.size() == 3, "shared functional manager installs all direct-child modular levels")
	_check(_all_developer_visibility(surfaces, false), "managed modular grids start with developer visibility off")
	var before_f7 := _runtime_surface_snapshot(surfaces)
	await _send_key(KEY_F6)
	_check(bool(manager.call("is_developer_grid_visible")), "real F6 input enables manager developer-grid state")
	_check(_all_developer_visibility(surfaces, true), "F6 reaches every installed modular surface")
	await _send_key(KEY_F7)
	_check(_runtime_surface_snapshot(surfaces) == before_f7, "F7 leaves modular reservations, stacks, zones and transforms unchanged")
	await _send_key(KEY_F6)
	_check(_all_developer_visibility(surfaces, false), "second F6 press hides every modular grid")
	fixtures.free()


func _placement_context() -> Dictionary:
	var carried := CarriedItemsScript.new() as CarriedItems
	carried.max_bulk = 999
	root.add_child(carried)
	var controller := StoragePlacementControllerScript.new() as StoragePlacementController
	root.add_child(controller)
	controller.configure(null, carried, 1.8)
	return {"carried": carried, "controller": controller}


func _free_placement_context(context: Dictionary) -> void:
	(context["controller"] as Node).free()
	(context["carried"] as Node).free()


func _all_developer_visibility(surfaces: Array, expected: bool) -> bool:
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface == null or surface.is_developer_debug_visible() != expected:
			return false
	return true


func _runtime_surface_snapshot(surfaces: Array) -> Array:
	var result: Array = []
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		result.append({
			"surface_id": String(surface.surface_id),
			"global_transform": surface.global_transform,
			"reservations": surface.get_reservation_count(),
			"stacks": surface.get_stack_count(),
			"zones": surface.get_zone_cells_copy(),
		})
	return result


func _send_key(keycode: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.echo = false
	Input.parse_input_event(event)
	await process_frame
	await physics_frame


func _make_rack(rack_name: String) -> Node3D:
	var rack := (load(RACK_SCENE) as PackedScene).instantiate() as Node3D
	rack.name = rack_name
	root.add_child(rack)
	_replace_with_local_test_levels(rack)
	rack.call("refresh_authoring_state")
	return rack


func _replace_with_local_test_levels(rack: Node3D, scene_owner: Node = null) -> void:
	var levels := rack.get_node("Levels") as Node3D
	for child: Node in levels.get_children():
		levels.remove_child(child)
		child.free()
	_add_local_test_level(rack, "Shelf_01", 0.25, scene_owner)
	_add_local_test_level(rack, "Shelf_02", 0.95, scene_owner)
	_add_local_test_level(rack, "Shelf_03", 1.65, scene_owner)


func _add_local_test_level(rack: Node3D, level_name: String, support_y: float, scene_owner: Node = null) -> Node3D:
	var level := Node3D.new()
	level.name = level_name
	level.position.y = support_y
	(rack.get_node("Levels") as Node3D).add_child(level)
	var visual := RACK02_SCENE.instantiate() as Node3D
	visual.name = "Visual"
	level.add_child(visual)
	if scene_owner != null:
		level.owner = scene_owner
		visual.owner = scene_owner
	return level


func _set_local_level_owners(rack: Node3D, scene_owner: Node) -> void:
	for level: Node in (rack.get_node("Levels") as Node3D).get_children():
		level.owner = scene_owner
		for child: Node in level.get_children():
			child.owner = scene_owner


func _set_level_y(rack: Node3D, level_name: String, support_y: float) -> void:
	var level := rack.get_node("Levels/%s" % level_name) as Node3D
	level.position.y = support_y


func _surface_ids_by_level(layout: Dictionary) -> Dictionary:
	var result := {}
	for value: Variant in layout.get("levels", []) as Array:
		var level := value as Dictionary
		result[String(level.get("name", ""))] = String(level.get("surface_id", ""))
	return result


func _branch_local_bounds(branch: Node3D) -> AABB:
	var state := {"valid": false, "bounds": AABB()}
	for child: Node in branch.get_children():
		_scan_bounds(child, Transform3D.IDENTITY, state)
	return state["bounds"] as AABB


func _scan_bounds(node: Node, parent_transform: Transform3D, state: Dictionary) -> void:
	var transform_to_branch := parent_transform
	if node is Node3D:
		transform_to_branch = parent_transform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh != null:
			var bounds := transform_to_branch * mesh_node.get_aabb()
			if bool(state["valid"]):
				state["bounds"] = (state["bounds"] as AABB).merge(bounds)
			else:
				state["valid"] = true
				state["bounds"] = bounds
	for child: Node in node.get_children():
		_scan_bounds(child, transform_to_branch, state)


func _near(actual: float, expected: float) -> bool:
	return absf(actual - expected) <= POSITION_EPSILON_M


func _vector_near(actual: Vector3, expected: Vector3) -> bool:
	return _near(actual.x, expected.x) and _near(actual.y, expected.y) and _near(actual.z, expected.z)


func _vector2_near(actual: Vector2, expected: Vector2) -> bool:
	return _near(actual.x, expected.x) and _near(actual.y, expected.y)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false


func _finish() -> void:
	if _failed:
		push_error("FAIL: modular rack authoring tests")
		quit(1)
		return
	print("PASS: modular rack authoring tests")
	quit(0)
