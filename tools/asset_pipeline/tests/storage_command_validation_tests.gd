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
