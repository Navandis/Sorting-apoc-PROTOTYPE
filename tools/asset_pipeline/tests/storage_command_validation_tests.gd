extends "res://tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd"


func _run() -> void:
	await _run_regressions()
	_check(_pending_helpers == 0, "%d command regression helpers did not complete" % _pending_helpers)
	print("storage_command_validation_tests: %s" % ("FAIL" if _failed else "PASS"))
	quit(1 if _failed else 0)


func _run_regressions() -> void:
	_pending_helpers += 1
	_definitions = _definitions_by_id()
	_test_selection_command(Vector2i(2, 2), false)
	_test_selection_command(Vector2i(4, 4), true)
	_test_selection_command(Vector2i(4, 4), true, true)
	_test_stale_support_commit()
	_test_wrong_authored_footprint_commit()
	await _test_manual_stack_address(true)
	await _test_manual_stack_address(false)
	await _test_manual_point_selection(true)
	await _test_manual_point_selection(false)
	_pending_helpers -= 1


func _test_selection_command(size: Vector2i, should_store: bool, refresh_on_remove: bool = false) -> void:
	_pending_helpers += 1
	var context := _context(size, 2.0)
	var surface: StorageSurface = context.surface
	var carried: CarriedItems = context.carried
	var controller: StoragePlacementController = context.controller
	surface.initialize_zones_if_needed("General")
	var cd := _item(&"loot_000031")
	var armor := _item(&"loot_000032")
	_check(cd.get_storage_footprint().x == 2 and cd.get_storage_footprint().y == 2, "authored CD is 2x2")
	_check(armor.get_storage_footprint().x == 3 and armor.get_storage_footprint().y == 3, "authored Armor is 3x3")
	_check(carried.add_item(cd) and carried.add_item(armor), "both actual items enter carrying")
	var entries: Array = controller.call("_entry_orientations_for_item", cd, 0)
	var preview := surface.find_zone_stack_or_empty_fit(cd.get_storage_category(), entries[0], null)
	_check(preview.valid and preview.footprint == Vector2i(2, 2), "A has a valid 2x2 preview")
	controller.set("_current_surface", surface)
	controller.set("_current_fit", preview)
	var player := _player_for_storage_dispatch(carried, controller)
	carried.selection_changed.connect(player._on_carried_selection_changed)
	var selection := InputEventKey.new()
	selection.keycode = KEY_2
	selection.pressed = true
	carried._unhandled_input(selection)
	_check(carried.get_selected_item() == armor, "number selection selects B before a process refresh")
	var before := carried.get_slots()
	if refresh_on_remove:
		carried.contents_changed.connect(controller.update_target)
	player.call("_attempt_store")
	if should_store:
		_check(carried.get_items() == [cd], "legal command transfers B exactly once and retains A")
		_check(surface.get_stack_id_for_item(armor.instance_id) == armor.instance_id, "empty stack belongs to B")
		var reservation := surface.get_reservation(armor.instance_id)
		_check(reservation.get("footprint") == Vector2i(3, 3), "B reserves its authored 3x3 footprint")
		var stack := surface.get_storage_stack(armor.instance_id)
		_check(stack != null and stack.entries.size() == 1 and stack.entries[0].item == armor, "destination owns actual B once")
	else:
		_check(carried.get_slots() == before and carried.get_selected_index() == 1, "rejection preserves exact slots and selection")
		_check(surface.get_stack_count() == 0 and surface.get_reservation_count() == 0, "rejection leaves destination empty")
	_check(surface.get_stack_id_for_item(cd.instance_id).is_empty(), "A is never committed under its old preview key")
	player.free()
	_free_context(context)
	_pending_helpers -= 1


func _test_stale_support_commit() -> void:
	_pending_helpers += 1
	var context := _context(Vector2i(4, 4), 1.0)
	var surface: StorageSurface = context.surface
	var controller: StoragePlacementController = context.controller
	surface.initialize_zones_if_needed("General")
	var base := _item(&"loot_000031")
	_check(_place_auto(controller, context.carried, surface, base), "stale support fixture owns a real CD base")
	var incoming := _item(&"loot_000031")
	var entry: StorageStack.Entry = controller.call("_entry_for_item", incoming, false, 0)
	var fit := surface.find_manual_stack_fit(base.instance_id, entry)
	_check(fit.valid, "incoming CD initially has legal support")
	var reservation := surface.get_reservation(base.instance_id)
	var stack := surface.get_storage_stack(base.instance_id)
	surface.stack_clearance_m = stack.entries[0].posed_height_m * 1.1
	_check(not surface.commit_stack_entry(entry, fit), "commit rejects stale support/clearance data")
	_check(stack.entries.size() == 1 and stack.entries[0].item == base, "stale rejection preserves existing owner")
	_check(surface.get_reservation(base.instance_id) == reservation and surface.get_stack_id_for_item(incoming.instance_id).is_empty(), "stale rejection preserves reservations and lookup")
	_free_context(context)
	_pending_helpers -= 1



func _test_wrong_authored_footprint_commit() -> void:
	_pending_helpers += 1
	var context := _context(Vector2i(2, 2), 2.0)
	var surface: StorageSurface = context.surface
	var armor := _item(&"loot_000032")
	var entry: StorageStack.Entry = context.controller.call("_entry_for_item", armor, false, 0)
	# Simulate a caller supplying matching stale entry/fit dimensions. The
	# ordinary surface must still enforce the actual item's authored footprint.
	entry.footprint = Vector2i(2, 2)
	var fit := _manual_empty_fit(context.controller, armor, surface, Vector2i.ZERO, false)
	fit["footprint"] = Vector2i(2, 2)
	fit["base_footprint"] = Vector2i(2, 2)
	fit["valid"] = true
	_check(not surface.commit_stack_entry(entry, fit), "commit independently rejects Armor under-reservation")
	_check(surface.get_stack_count() == 0 and surface.get_reservation_count() == 0, "under-reservation rejection has no destination mutation")
	_free_context(context)
	_pending_helpers -= 1


func _test_manual_stack_address(disable_zone: bool) -> void:
	_pending_helpers += 1
	var context := _context(Vector2i(8, 8), 1.0)
	var surface: StorageSurface = context.surface
	var controller: StoragePlacementController = context.controller
	var carried: CarriedItems = context.carried
	surface.initialize_zones_if_needed("General")
	var base := _item(&"loot_000031")
	_check(_place_manual_empty(controller, carried, surface, base, Vector2i(3, 3)), "address fixture stores a real CD before changing zoning")
	var stack := surface.get_storage_stack(base.instance_id)
	var original_entry: StorageStack.Entry = stack.entries[0]
	var world_item: WorldItem = original_entry.world_item
	var shape: CollisionShape3D = world_item.get_node("PickupArea/PickupShape")
	var camera := Camera3D.new()
	root.add_child(camera)
	controller.set("_camera", camera)
	camera.global_position = shape.global_position + Vector3(0.0, 0.15, 1.0)
	camera.look_at(shape.global_position)
	var incoming := _item(&"loot_000031")
	_check(carried.add_item(incoming), "incoming CD is carried for addressed append")
	if disable_zone:
		surface.clear_zone_rect(Vector2i(3, 3), Vector2i(4, 4))
	await physics_frame
	await physics_frame
	_check(controller.call("_get_looked_at_stored_world_item") == world_item, "real ray addresses the stored WorldItem")
	controller.update_target()
	_check(controller.get("_current_surface") == surface and controller.has_valid_placement() != disable_zone, "addressed stack preview reflects enabled cells")
	var slots := carried.get_slots()
	var selected := carried.get_selected_index()
	var reservation := surface.get_reservation(base.instance_id)
	var player := _player_for_storage_dispatch(carried, controller)
	player.call("_attempt_store")
	_check(surface.get_storage_stack(base.instance_id) == stack and stack.entries[0] == original_entry, "addressed stack and original entry retain exact ownership")
	_check(surface.get_stack_count() == 1 and surface.get_reservation_count() == 1 and surface.get_reservation(base.instance_id) == reservation, "append never creates an unrelated stack or reservation")
	if disable_zone:
		_check(carried.get_slots() == slots and carried.get_selected_index() == selected, "disabled-stack E preserves exact carrying slots and selection")
		_check(stack.entries.size() == 1 and surface.get_stack_id_for_item(incoming.instance_id).is_empty(), "invalid addressed append leaves destination lookup unchanged")
	else:
		_check(carried.get_item_count() == 0 and stack.entries.size() == 2 and stack.entries[1].item == incoming, "valid addressed append transfers the selected item exactly once")
		_check(surface.get_stack_id_for_item(incoming.instance_id) == base.instance_id, "append retains destination stack identity")
	player.free()
	_free_context(context)
	camera.free()
	await physics_frame
	_pending_helpers -= 1


func _test_manual_point_selection(distant_armor_island: bool) -> void:
	_pending_helpers += 1
	var context := _context(Vector2i(12, 8), 2.0)
	var surface: StorageSurface = context.surface
	var controller: StoragePlacementController = context.controller
	var carried: CarriedItems = context.carried
	surface.initialize_zones_if_needed("General")
	surface.clear_all_zones()
	surface.set_zone_rect("General", Vector2i.ZERO, Vector2i(1, 1))
	if distant_armor_island:
		surface.set_zone_rect("General", Vector2i(8, 4), Vector2i(10, 6))
	var armor := _item(&"loot_000032")
	var cd := _item(&"loot_000031")
	_check(carried.add_item(armor) and carried.add_item(cd), "manual selection fixture carries authored Armor and CD")
	var camera := Camera3D.new()
	root.add_child(camera)
	controller.set("_camera", camera)
	var aimed_point := surface.get_local_placement_position(Vector2i.ZERO, Vector2i(2, 2))
	camera.global_position = surface.to_global(aimed_point) + Vector3(0.0, 0.7, 0.3)
	camera.look_at(surface.to_global(aimed_point))
	await physics_frame
	await physics_frame
	controller.set_manual_mode(true)
	controller.update_target()
	var preview: Dictionary = controller.get("_current_fit").duplicate(true)
	_check(controller.get("_current_surface") == surface, "actual surface ray addresses the near 2x2 island")
	if distant_armor_island:
		_check(preview.get("valid", false) and preview.get("origin") == Vector2i(8, 4), "Armor preview snaps to its only legal distant 3x3 island")
	else:
		_check(not preview.get("valid", true), "Armor preview is invalid when only the near CD island is enabled")
	var player := _player_for_storage_dispatch(carried, controller)
	carried.selection_changed.connect(player._on_carried_selection_changed)
	var selection := InputEventKey.new()
	selection.keycode = KEY_2
	selection.pressed = true
	carried._unhandled_input(selection)
	_check(carried.get_selected_item() == cd, "number callback selects CD with no target/process refresh")
	# The expected origin is the authored near island, not another production fit.
	player.call("_attempt_store")
	var reservation := surface.get_reservation(cd.instance_id)
	_check(reservation.get("valid", false) and reservation.get("origin") == Vector2i.ZERO and reservation.get("footprint") == Vector2i(2, 2), "CD uses the original near hit point with its authored 2x2 reservation")
	var stack := surface.get_storage_stack(cd.instance_id)
	_check(stack != null and stack.entries.size() == 1 and stack.entries[0].item == cd, "point placement stores the exact selected CD once under its own identity")
	_check(carried.get_items() == [armor] and surface.get_stack_count() == 1 and surface.get_reservation_count() == 1, "point placement retains Armor and transfers only CD")
	player.free()
	_free_context(context)
	camera.free()
	await physics_frame
	_pending_helpers -= 1
