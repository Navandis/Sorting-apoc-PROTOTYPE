extends SceneTree

const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const MAIN_PATH := "res://main.tscn"

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(GAMEPLAY_PATH) as PackedScene
	if not _check(packed != null, "continuing gameplay scene loads"):
		_finish()
		return

	var scene := packed.instantiate()
	# The held-item clone is unrelated to grid presentation and triggers a
	# dummy-renderer material query in headless mode. Existing handling suites
	# cover it with their own renderer-appropriate setup.
	scene.get_node("Player").set("enable_held_item_view", false)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame

	var fixtures := scene.get_node("FunctionalFixtures")
	var manager := fixtures.get_node("StoragePrototypeManager")
	var surfaces := scene.call("get_functional_surfaces") as Array
	var player := scene.get_node("Player")
	var carried := scene.get_node("Player/CarriedItems")
	var controller := scene.get_node("Player/StoragePlacementController") as StoragePlacementController

	_check(surfaces.size() == 12, "F6 test sees the twelve functional shelf surfaces")
	_check(carried.get_item_count() == 0, "F6 starts with an empty carried bundle")
	_check(fixtures.call("is_storage_debug_input_enabled"), "continuing fixtures route F6 input")
	_check(manager.is_processing_unhandled_input(), "F6 manager receives real unhandled input")
	_check(manager.has_method("is_developer_grid_visible"), "F6 manager exposes its developer override state")
	_check(_all_surface_visuals_match(surfaces, false), "fresh continuing scene starts with every grid OFF")
	_check(
		scene.get_node("DevelopmentSetup/Tables").find_children("*", "StorageSurface", true, false).is_empty(),
		"ordinary tables acquire no storage grid"
	)

	await _send_key(KEY_F6, true, false)
	_check(_manager_override(manager), "non-repeat F6 key-down enables the developer override")
	_check(_all_surface_visuals_match(surfaces, true), "empty-hand F6 shows all real surface visuals")

	await _send_key(KEY_F6, true, true)
	_check(_manager_override(manager), "F6 echo does not toggle the developer override")
	await _send_key(KEY_F6, false, false)
	_check(_manager_override(manager), "F6 key-up does not toggle the developer override")
	await _send_key(KEY_F6, true, false)
	_check(not _manager_override(manager), "second intentional F6 press disables the developer override")
	_check(_all_surface_visuals_match(surfaces, false), "F6 OFF restores quiet empty-hand Auto presentation")

	await _assert_manual_target_coexistence(player, controller, manager, surfaces)
	await _assert_populated_state_isolation(scene, player, carried, controller, manager, surfaces)
	await _assert_zoning_round_trip(player, manager, surfaces)

	# Leave the first instance ON to prove a fresh parent-hosted, setup-free
	# composition does not inherit session state.
	if not _manager_override(manager):
		await _send_key(KEY_F6, true, false)
	_check(_manager_override(manager), "first instance ends with its local override ON")
	scene.free()
	current_scene = null
	await process_frame

	var host := Node3D.new()
	host.name = "F6ParentHost"
	root.add_child(host)
	current_scene = host
	var fresh_scene := packed.instantiate()
	fresh_scene.set("development_setup_enabled", false)
	host.add_child(fresh_scene)
	await process_frame
	await physics_frame
	var fresh_fixtures := fresh_scene.get_node("FunctionalFixtures")
	var fresh_manager := fresh_fixtures.get_node("StoragePrototypeManager")
	var fresh_surfaces := fresh_scene.call("get_functional_surfaces") as Array
	_check(
		fresh_scene.get_node_or_null("DevelopmentSetup") == null,
		"F6 does not depend on the optional development setup"
	)
	_check(not _manager_override(fresh_manager), "fresh parent-hosted composition resets F6 to OFF")
	_check(_all_surface_visuals_match(fresh_surfaces, false), "fresh setup-free composition starts with grids OFF")
	await _send_key(KEY_F6, true, false)
	_check(_manager_override(fresh_manager), "parent-hosted setup-free composition receives F6")
	_check(_all_surface_visuals_match(fresh_surfaces, true), "parent-hosted F6 reveals all real grids")

	host.free()
	current_scene = null
	await process_frame
	await _assert_legacy_main_controls()
	_finish()


func _assert_manual_target_coexistence(
	player: Node,
	controller: StoragePlacementController,
	manager: Node,
	surfaces: Array
) -> void:
	var surface_a := surfaces[0] as StorageSurface
	var surface_b := surfaces[1] as StorageSurface
	# The controller API is the behavior under test here. Pause only the
	# player's continuous ray refresh so an intentionally injected target is
	# not replaced by the empty-hand/no-ray state during the key event.
	player.set_process(false)
	controller.set_manual_mode(true)
	controller.call("_set_manual_debug_surface", surface_a)
	await process_frame
	_check(_surface_visuals_visible(surface_a), "Manual target A shows its normal grid while F6 is OFF")
	_check(not _surface_visuals_visible(surface_b), "non-target B stays hidden while F6 is OFF")

	await _send_key(KEY_F6, true, false)
	_check(_manager_override(manager), "F6 enables override while Manual target A is active")
	_check(_all_surface_visuals_match(surfaces, true), "F6 ON coexists with Manual target A")
	controller.call("_set_manual_debug_surface", surface_b)
	await process_frame
	_check(_all_surface_visuals_match(surfaces, true), "switching Manual target A to B cannot erase F6")
	controller.call("_set_manual_debug_surface", null)
	await process_frame
	_check(_all_surface_visuals_match(surfaces, true), "looking away in Manual cannot erase F6")
	controller.set_manual_mode(false)
	await process_frame
	_check(_all_surface_visuals_match(surfaces, true), "returning to Auto cannot erase F6")

	controller.set_manual_mode(true)
	controller.call("_set_manual_debug_surface", surface_a)
	await process_frame
	await _send_key(KEY_F6, true, false)
	_check(not _manager_override(manager), "F6 OFF releases only the developer request")
	_check(_surface_visuals_visible(surface_a), "F6 OFF retains the legitimate Manual target grid")
	_check(not _surface_visuals_visible(surface_b), "F6 OFF hides non-target surfaces")
	controller.call("_set_manual_debug_surface", surface_b)
	await process_frame
	_check(not _surface_visuals_visible(surface_a), "Manual target A hides after switching to B")
	_check(_surface_visuals_visible(surface_b), "Manual target B remains visible after F6 OFF")
	controller.call("_set_manual_debug_surface", null)
	controller.set_manual_mode(false)
	await process_frame
	_check(_all_surface_visuals_match(surfaces, false), "leaving Manual restores quiet Auto after F6 OFF")
	player.set_process(true)


func _assert_populated_state_isolation(
	scene: Node,
	player: Node,
	carried: Node,
	controller: StoragePlacementController,
	manager: Node,
	surfaces: Array
) -> void:
	await _send_key(KEY_F6, true, false)
	_check(_manager_override(manager), "populated-state test begins with F6 ON")
	var surface := surfaces[0] as StorageSurface
	var host := scene.get_node("DevelopmentSetup/SeedItems/CerealBox_A") as Node3D
	var world_item := host.get_node("WorldItem") as WorldItem
	var item := world_item.get_item_instance()
	player.call("_attempt_pickup", world_item)
	_check(carried.get_selected_item() == item, "populated-state fixture carries the exact live item")
	surface.set_zone_rect(item.get_storage_category(), Vector2i.ZERO, surface.get_grid_size() - Vector2i.ONE)
	_check(_auto_place_selected(controller, carried, surface), "populated-state fixture stores through the real controller")
	_check(surface.get_stack_count() == 1, "populated-state fixture creates one real stack")
	_check(_surface_visuals_visible(surface), "occupancy rebuild respects F6 ON")
	await process_frame
	await physics_frame

	var state_before := _gameplay_state_snapshot(scene, surfaces)
	await _send_key(KEY_F7, true, false)
	await _send_key(KEY_F7, false, false)
	_check(
		_gameplay_state_snapshot(scene, surfaces) == state_before,
		"F7 leaves populated ownership, zones, reservations, stacks and transforms unchanged while F6 is ON"
	)

	await _send_key(KEY_F6, true, false)
	_check(not _manager_override(manager), "F6 can turn OFF with populated surfaces")
	_check(
		_gameplay_state_snapshot(scene, surfaces) == state_before,
		"F6 OFF is presentation-only for populated state"
	)
	await _send_key(KEY_F7, true, false)
	await _send_key(KEY_F7, false, false)
	_check(
		_gameplay_state_snapshot(scene, surfaces) == state_before,
		"F7 remains inert with grids OFF and a real stack present"
	)

	await _send_key(KEY_F6, true, false)
	var stack_id := surface.get_stack_id_for_item(item.instance_id)
	var stack := surface.get_storage_stack(stack_id)
	var stored_world := stack.entries[0].world_item as WorldItem
	_check(stored_world.pickup_into(carried), "stored item retrieves through its real WorldItem")
	_check(carried.get_selected_item() == item, "retrieval preserves exact ItemInstance identity")
	await process_frame
	_check(_surface_visuals_visible(surface), "retrieval occupancy refresh respects F6 ON")
	_check(_all_surface_visuals_match(surfaces, true), "retrieval cannot erase the developer override")


func _assert_zoning_round_trip(player: Node, manager: Node, surfaces: Array) -> void:
	var surface := surfaces[2] as StorageSurface
	player.call("_open_zone_editor_for_surface", surface)
	await process_frame
	_check(bool(player.get("_zone_editor_open")), "existing zoning modal opens normally while F6 is ON")
	var zone_editor := player.get_node("StorageZoneEditor")
	zone_editor.call("close_editor")
	await process_frame
	_check(not bool(player.get("_zone_editor_open")), "existing zoning modal closes normally")
	_check(_manager_override(manager), "F6 override survives zoning close")
	_check(_all_surface_visuals_match(surfaces, true), "zoning close preserves all developer grids")


func _assert_legacy_main_controls() -> void:
	var packed := load(MAIN_PATH) as PackedScene
	if not _check(packed != null, "legacy main scene loads for scoped input regression"):
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	var manager := scene.find_child("StoragePrototypeManager", true, false)
	if not _check(manager != null, "legacy main retains its historical storage manager"):
		scene.free()
		current_scene = null
		return
	var surfaces := manager.call("get_surfaces") as Array
	_check(surfaces.size() == 16, "legacy main retains its sixteen historical surfaces")
	_check(
		_all_normal_visibility_matches(surfaces, true),
		"legacy main grids retain their historical visible startup"
	)
	await _send_key(KEY_F6, true, false)
	_check(
		_all_normal_visibility_matches(surfaces, false),
		"legacy main still routes F6 through its historical manager"
	)
	await _send_key(KEY_F6, true, false)
	_check(
		_all_normal_visibility_matches(surfaces, true),
		"legacy main F6 still restores its historical grid presentation"
	)
	var demo_surface := manager.get("_demo_surface") as StorageSurface
	var reservation_count_before := demo_surface.get_reservation_count()
	await _send_key(KEY_F7, true, false)
	_check(int(manager.get("_demo_state")) == 1, "legacy main still routes F7 to its occupancy demo")
	_check(
		demo_surface.get_reservation_count() > reservation_count_before,
		"legacy main F7 still creates its historical demo reservations"
	)
	scene.free()
	current_scene = null
	await process_frame


func _auto_place_selected(
	controller: StoragePlacementController,
	carried: Node,
	surface: StorageSurface
) -> bool:
	var item := carried.get_selected_item() as ItemInstance
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


func _gameplay_state_snapshot(scene: Node, surfaces: Array) -> Dictionary:
	var surface_records: Array = []
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		var reservation_keys: Array = (surface.get("_reservations") as Dictionary).keys()
		reservation_keys.sort()
		var reservation_records: Array = []
		for reservation_key: Variant in reservation_keys:
			reservation_records.append(
				surface.get_reservation(String(reservation_key)).duplicate(true)
			)
		var stack_records: Array = []
		var stack_ids: Array = (surface.get("_stacks") as Dictionary).keys()
		stack_ids.sort()
		for stack_id: Variant in stack_ids:
			var stack := surface.get_storage_stack(String(stack_id))
			var entry_records: Array = []
			for entry in stack.entries:
				entry_records.append({
					"instance_id": entry.item.instance_id,
					"packing_rotated": entry.packing_rotated,
					"host_transform": entry.host.transform,
					"host_global_transform": entry.host.global_transform,
					"host_parent": String(entry.host.get_parent().get_path()),
					"world_item_instance_id": entry.world_item.get_item_instance().instance_id,
					"world_item_parent": String(entry.world_item.get_parent().get_path()),
				})
			stack_records.append({"stack_id": String(stack_id), "entries": entry_records})
		surface_records.append({
			"node_name": String(surface.name),
			"surface_id": String(surface.surface_id),
			"global_transform": surface.global_transform,
			"visible": surface.visible,
			"grid_size": surface.get_grid_size(),
			"capacity_cells": surface.get_grid_size().x * surface.get_grid_size().y,
			"cell_size_m": surface.get_cell_size_m(),
			"usable_size_m": surface.get_usable_size_m(),
			"stack_clearance_m": surface.stack_clearance_m,
			"reservations": reservation_records,
			"cells": (surface.get("_cells") as Array).duplicate(true),
			"item_to_stack": (surface.get("_item_to_stack") as Dictionary).duplicate(true),
			"zone_cells": surface.get_zone_cells_copy(),
			"zones_initialized": surface.are_zones_initialized(),
			"stacks": stack_records,
			"collision": _surface_collision_snapshot(surface),
		})

	var seed_records: Array = []
	var seeds := scene.get_node_or_null("DevelopmentSetup/SeedItems")
	if seeds != null:
		for host: Node in seeds.get_children():
			var registered_world := host.get_node_or_null("WorldItem") as WorldItem
			seed_records.append({
				"name": String(host.name),
				"transform": (host as Node3D).transform,
				"instance_id": (
					registered_world.get_item_instance().instance_id
					if registered_world != null and registered_world.get_item_instance() != null
					else ""
				),
			})

	var carried_ids: Array[String] = []
	var carried := scene.get_node("Player/CarriedItems")
	for carried_value: Variant in carried.get_items():
		carried_ids.append((carried_value as ItemInstance).instance_id)
	return {
		"fixture_transform": (scene.get_node("FunctionalFixtures") as Node3D).transform,
		"surfaces": surface_records,
		"seeds": seed_records,
		"carried_ids": carried_ids,
		"selected_index": carried.get_selected_index(),
	}


func _surface_collision_snapshot(surface: StorageSurface) -> Dictionary:
	var area := surface.get_node_or_null("StorageInteractionArea") as Area3D
	if area == null:
		return {"present": false}
	var shape_node := area.get_node_or_null("StorageInteractionShape") as CollisionShape3D
	var shape_size := Vector3.ZERO
	if shape_node != null and shape_node.shape is BoxShape3D:
		shape_size = (shape_node.shape as BoxShape3D).size
	return {
		"present": true,
		"area_transform": area.transform,
		"collision_layer": area.collision_layer,
		"collision_mask": area.collision_mask,
		"monitoring": area.monitoring,
		"monitorable": area.monitorable,
		"shape_disabled": shape_node.disabled if shape_node != null else true,
		"shape_transform": shape_node.transform if shape_node != null else Transform3D.IDENTITY,
		"shape_size": shape_size,
	}


func _manager_override(manager: Node) -> bool:
	return bool(manager.call("is_developer_grid_visible")) if manager.has_method("is_developer_grid_visible") else false


func _surface_visuals_visible(surface: StorageSurface) -> bool:
	var grid := surface.get_node_or_null("StorageDebugGrid") as MeshInstance3D
	var occupancy := surface.get_node_or_null("StorageDebugOccupancy") as Node3D
	return grid != null and occupancy != null and grid.visible and occupancy.visible


func _all_surface_visuals_match(surfaces: Array, expected_visible: bool) -> bool:
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if _surface_visuals_visible(surface) != expected_visible:
			return false
	return true


func _all_normal_visibility_matches(surfaces: Array, expected_visible: bool) -> bool:
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface == null or surface.is_normal_debug_visible() != expected_visible:
			return false
		if _surface_visuals_visible(surface) != expected_visible:
			return false
	return true


func _send_key(keycode: Key, pressed: bool, echo: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	await process_frame
	await physics_frame


func _finish() -> void:
	if _failed:
		push_error("FAIL: wing storage debug F6 tests")
		quit(1)
		return
	print("PASS: wing storage debug F6 tests")
	quit(0)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false
