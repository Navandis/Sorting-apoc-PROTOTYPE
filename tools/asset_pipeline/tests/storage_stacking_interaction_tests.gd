extends SceneTree

const CarriedItemsScript = preload("res://carried_items.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const PlayerControllerScript = preload("res://player_controller.gd")
const StorageCategoriesScript = preload("res://storage_categories.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")

const CATALOG_PATH: String = "res://data/items/item_catalog.tres"

var _failed: bool = false
var _definitions: Dictionary = {}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var probe: StoragePlacementController = StoragePlacementControllerScript.new()
	for method_name: StringName in [&"_entry_for_item", &"_entry_orientations_for_item"]:
		if not probe.has_method(method_name):
			push_error("StoragePlacementController.%s is missing" % method_name)
			probe.free()
			quit(1)
			return
	probe.free()
	_definitions = _definitions_by_id()
	_test_flat_media_and_pose_cache()
	_test_general_round_cans_and_visible_middle_retrieval()
	_test_removed_base_manual_empty_placement_on_same_surface()
	_test_removed_base_auto_empty_placement_on_same_surface()
	_test_removed_base_placement_with_multiple_carried_items()
	_test_contextual_manual_orientation_preserves_preference()
	_test_manual_terminal_and_ghost_final_parity(&"loot_000039")
	_test_manual_terminal_and_ghost_final_parity(&"loot_000006")
	if _failed:
		quit(1)
		return
	print("PASS: storage stacking interaction tests")
	quit(0)


func _test_flat_media_and_pose_cache() -> void:
	var context: Dictionary = _context(Vector2i(8, 8), 1.0)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var carried: CarriedItems = context["carried"] as CarriedItems
	surface.set_zone_rect(StorageCategoriesScript.MORALE, Vector2i.ZERO, Vector2i(7, 7))

	var book: ItemInstance = _item(&"loot_000030")
	var first = controller.call("_entry_for_item", book, false)
	var second = controller.call("_entry_for_item", book, false)
	_check(first != null and second != null, "real Book entry descriptors build")
	_check((controller.get("_pose_metrics_cache") as Dictionary).size() == 1, "posed metrics cache reuses item orientation")
	controller.call("_entry_for_item", book, true)
	_check((controller.get("_pose_metrics_cache") as Dictionary).size() == 2, "rotated pose metric has deterministic cache key")

	_check(_place_auto(controller, carried, surface, book), "Book auto base placement")
	var cd: ItemInstance = _item(&"loot_000031")
	_check(_place_auto(controller, carried, surface, cd), "CD automatically joins Book")
	var stack_id: String = surface.get_stack_id_for_item(book.instance_id)
	var stack: StorageStack = surface.get_storage_stack(stack_id)
	_check(stack.entries.size() == 2, "flat-media stack has two entries")
	_check(stack.entries[0].item == book and stack.entries[1].item == cd, "flat-media order is deterministic")
	_check(stack.is_auto_coherent(), "Book/CD stack remains auto coherent")
	_check(surface.get_reservation_count() == 1, "flat-media upper item owns no cells")
	_check(_targetable(stack.entries[0]) and _targetable(stack.entries[1]), "both flat-media members are individually targetable")
	_free_context(context)


func _test_general_round_cans_and_visible_middle_retrieval() -> void:
	var context: Dictionary = _context(Vector2i(5, 5), 0.40)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var carried: CarriedItems = context["carried"] as CarriedItems
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(4, 4))
	var metal_bottom: ItemInstance = _item(&"loot_000019")
	var dry_middle: ItemInstance = _item(&"loot_000009")
	var metal_top: ItemInstance = _item(&"loot_000019")
	_check(_place_auto(controller, carried, surface, metal_bottom), "metal can base in General")
	_check(_place_auto(controller, carried, surface, dry_middle), "cross-category dry goods can joins in General")
	_check(_place_auto(controller, carried, surface, metal_top), "repeated round can joins")
	var stack_id: String = surface.get_stack_id_for_item(metal_bottom.instance_id)
	var stack: StorageStack = surface.get_storage_stack(stack_id)
	_check(stack.entries.size() == 3, "repeated can stack accumulates")
	for entry in stack.entries:
		_check(_targetable(entry), "%s has an independent pickup area" % entry.item_key)
		_check(is_equal_approx(entry.host.position.x, stack.entries[0].host.position.x), "can centers share X")
		_check(is_equal_approx(entry.host.position.z, stack.entries[0].host.position.z), "can centers share Z")
	_check(stack.entries[1].host.position.y > stack.entries[0].host.position.y, "can height accumulates after base")
	_check(stack.entries[2].host.position.y > stack.entries[1].host.position.y, "can height accumulates repeatedly")
	for index: int in range(1, stack.entries.size()):
		var lower = stack.entries[index - 1]
		var upper = stack.entries[index]
		var lower_top_y: float = lower.host.position.y + lower.aligned_bounds.end.y
		var upper_bottom_y: float = upper.host.position.y + upper.aligned_bounds.position.y
		_check(is_equal_approx(lower_top_y, upper_bottom_y), "round cans use posed contact with no gameplay air gap")
	var fourth_can: ItemInstance = _item(&"loot_000009")
	var fourth_entry = controller.call("_entry_for_item", fourth_can, false)
	var base_host_y_m: float = surface.get_local_placement_position(stack.surface_origin, stack.base_footprint).y
	var over_clearance: Dictionary = stack.find_auto_insertion(
		[fourth_entry],
		surface.get_maximum_stack_top_y_m(),
		base_host_y_m
	)
	_check(not bool(over_clearance.get("valid", true)), "repeated real can stacking stops at 95-percent clearance")
	_check(not bool(over_clearance.get("clearance_ok", true)), "real can rejection reports clearance cause")

	var middle_world_item: WorldItem = stack.entries[1].world_item as WorldItem
	var top_y_before: float = stack.entries[2].host.position.y
	_check(middle_world_item.pickup_into(carried), "visible middle can retrieves through ordinary pickup")
	_check(carried.get_selected_item() == dry_middle, "retrieval preserves stable ItemInstance")
	_check(stack.entries.size() == 2, "middle retrieval removes only selected member")
	_check(stack.entries[1].item == metal_top, "upper can remains in relative order")
	_check(stack.entries[1].host.position.y < top_y_before, "upper can compresses deterministically")
	_free_context(context)


func _test_removed_base_manual_empty_placement_on_same_surface() -> void:
	var context: Dictionary = _context(Vector2i(10, 6), 1.0)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var carried: CarriedItems = context["carried"] as CarriedItems
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(9, 5))
	var base: ItemInstance = _build_book_cd_stack(controller, carried, surface)
	var original_stack_id: String = base.instance_id
	var original_stack: StorageStack = surface.get_storage_stack(original_stack_id)
	var base_world: WorldItem = original_stack.entries[0].world_item as WorldItem
	_check(base_world.pickup_into(carried), "removed base enters carried strip")
	_check(surface.get_stack_id_for_item(original_stack.entries[0].item_key) == original_stack.entries[0].item_key, "survivor is authoritative before removed-base placement")
	_check(not (surface.get("_stacks") as Dictionary).has(original_stack_id), "removed base ID is absent before placement dispatch")

	controller.set_manual_mode(true)
	controller.set("_rotated", false)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", _manual_empty_fit(controller, base, surface, Vector2i(5, 2), false))
	var player: Node = _player_for_storage_dispatch(carried, controller)
	player.call("_attempt_store")
	_check(carried.get_item_count() == 0, "single carried placement removes the stored item rather than rotating it")
	_check(surface.get_stack_id_for_item(base.instance_id) == base.instance_id, "removed base owns a new ordinary one-entry stack")
	var placed_stack: StorageStack = surface.get_storage_stack(base.instance_id)
	_check(placed_stack != null and not placed_stack.entries[0].packing_rotated, "same-surface return preserves effective unrotated placement")
	player.free()
	_free_context(context)


func _test_removed_base_auto_empty_placement_on_same_surface() -> void:
	var context: Dictionary = _context(Vector2i(10, 6), 1.0)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var carried: CarriedItems = context["carried"] as CarriedItems
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(9, 5))
	var base: ItemInstance = _build_book_cd_stack(controller, carried, surface)
	var original_stack: StorageStack = surface.get_storage_stack(base.instance_id)
	var base_world: WorldItem = original_stack.entries[0].world_item as WorldItem
	_check(base_world.pickup_into(carried), "auto regression removed base enters carried strip")
	var orientations: Array = controller.call("_entry_orientations_for_item", base)
	var fit: Dictionary = surface.find_zone_stack_or_empty_fit(
		base.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	_check(fit.get("placement_kind", "") == "empty", "larger removed base remains an empty-placement candidate, not base insertion")
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	_check(controller.place_selected(), "removed base auto-places normally while promoted stack survives")
	_check(carried.get_item_count() == 0, "auto placement consumes exactly the removed base")
	_check(surface.get_stack_count() == 2, "auto placement creates an ordinary separate stack without base promotion")
	_free_context(context)


func _test_removed_base_placement_with_multiple_carried_items() -> void:
	var context: Dictionary = _context(Vector2i(10, 6), 1.0)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var carried: CarriedItems = context["carried"] as CarriedItems
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(9, 5))
	var base: ItemInstance = _build_book_cd_stack(controller, carried, surface)
	var other: ItemInstance = _item(&"loot_000022")
	_check(carried.add_item(other), "additional carried item enters first slot")
	var original_stack: StorageStack = surface.get_storage_stack(base.instance_id)
	var base_world: WorldItem = original_stack.entries[0].world_item as WorldItem
	_check(base_world.pickup_into(carried), "multi-carried removed base enters carried strip")
	var base_slot: int = carried.get_slots().find(base)
	carried.select_index(base_slot)
	_check(carried.get_selected_item() == base, "removed base selected before placement dispatch")

	controller.set_manual_mode(true)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", _manual_empty_fit(controller, base, surface, Vector2i(5, 2), false))
	var player: Node = _player_for_storage_dispatch(carried, controller)
	player.call("_attempt_store")
	_check(not carried.get_items().has(base), "placed base leaves carried ownership")
	_check(carried.get_selected_item() == other, "selection advances only after successful placement to the remaining item")
	_check(surface.get_stack_id_for_item(base.instance_id) == base.instance_id, "multi-carried base has active same-surface placement")
	player.free()
	_free_context(context)


func _test_contextual_manual_orientation_preserves_preference() -> void:
	var context: Dictionary = _context(Vector2i(10, 8), 1.0)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var carried: CarriedItems = context["carried"] as CarriedItems
	surface.set_zone_rect(StorageCategoriesScript.GENERAL, Vector2i.ZERO, Vector2i(9, 7))
	var base: ItemInstance = _item(&"loot_000028")
	_check(_place_manual_empty(controller, carried, surface, base, Vector2i(1, 1)), "contextual orientation MedKit base placement")
	var incoming: ItemInstance = _item(&"loot_000028")
	_check(carried.add_item(incoming), "contextual orientation incoming MedKit carried")
	controller.set_manual_mode(true)
	controller.set("_rotated", true)

	var stack_id: String = surface.get_stack_id_for_item(base.instance_id)
	var fit: Dictionary = controller.call(
		"_find_manual_stack_target_fit",
		surface,
		stack_id,
		incoming
	) as Dictionary
	_check(bool(fit.get("valid", false)), "invalid preferred MedKit orientation uses valid 90-degree alternative")
	_check(not bool(fit.get("rotated", true)), "effective targeted orientation is separate from rotated preference")
	_check(bool(controller.get("_rotated")), "contextual fit does not mutate player R preference")
	var normal_preferred = controller.call("_entry_for_item", incoming, bool(controller.get("_rotated")))
	_check(normal_preferred.packing_rotated, "leaving target resumes the unchanged manual orientation preference")

	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.call("_update_ghost", incoming)
	var ghost_host: Node3D = controller.get("_ghost_host") as Node3D
	var ghost_packing: Node3D = controller.get("_ghost_packing_root") as Node3D
	var ghost_transform: Transform3D = ghost_host.transform
	var ghost_packing_basis: Basis = ghost_packing.basis
	_check(controller.place_selected(), "contextual orientation placement commits")
	var stack: StorageStack = surface.get_storage_stack(stack_id)
	var committed = stack.entries[stack.entries.size() - 1]
	var final_packing: Node3D = committed.host.get_node("StoredPackingYaw") as Node3D
	_check(committed.host.transform.is_equal_approx(ghost_transform), "contextual orientation ghost and final host match")
	_check(final_packing.basis.is_equal_approx(ghost_packing_basis), "contextual effective packing yaw matches ghost and final")
	_check(not committed.packing_rotated, "committed entry records contextual effective orientation")
	_free_context(context)


func _test_manual_terminal_and_ghost_final_parity(terminal_id: StringName) -> void:
	var context: Dictionary = _context(Vector2i(12, 8), 1.0)
	var surface: StorageSurface = context["surface"] as StorageSurface
	var controller: StoragePlacementController = context["controller"] as StoragePlacementController
	var carried: CarriedItems = context["carried"] as CarriedItems
	var medkit: ItemInstance = _item(&"loot_000028")
	_check(_place_manual_empty(controller, carried, surface, medkit, Vector2i(1, 1)), "MedKit manual base placement")
	var terminal: ItemInstance = _item(terminal_id)
	_check(carried.add_item(terminal), "terminal enters carried strip")
	controller.set_manual_mode(true)
	controller.set("_rotated", true)
	var terminal_entry = controller.call("_entry_for_item", terminal, true)
	var stack_id: String = surface.get_stack_id_for_item(medkit.instance_id)
	var fit: Dictionary = surface.find_manual_stack_fit(stack_id, terminal_entry)
	_check(bool(fit.get("valid", false)), "manual terminal ignores empty auto group")
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.call("_update_ghost", terminal)
	var ghost_host: Node3D = controller.get("_ghost_host") as Node3D
	var ghost_packing: Node3D = controller.get("_ghost_packing_root") as Node3D
	var ghost_transform: Transform3D = ghost_host.transform
	var ghost_packing_basis: Basis = ghost_packing.basis
	var ghost_pose: Node3D = ghost_packing.get_node("StorageSeating/AuthoredStoragePose") as Node3D
	var ghost_pose_basis: Basis = ghost_pose.basis
	_check(controller.place_selected(), "manual terminal commits")
	var stack: StorageStack = surface.get_storage_stack(stack_id)
	var committed = stack.entries[stack.entries.size() - 1]
	var packing: Node3D = committed.host.get_node("StoredPackingYaw") as Node3D
	var pose: Node3D = packing.get_node("StorageSeating/AuthoredStoragePose") as Node3D
	_check(committed.host.transform.is_equal_approx(ghost_transform), "stack ghost transform equals final host")
	_check(packing.basis.is_equal_approx(ghost_packing_basis), "manual R packing yaw preview equals final")
	_check(pose.basis.is_equal_approx(ghost_pose_basis), "authored pose preview equals final")
	_check(committed.packing_rotated, "resolved manual rotation is recorded")
	_check(not stack.is_auto_coherent(), "manual terminal makes stack non-auto-coherent")
	var later = controller.call("_entry_for_item", _item(&"loot_000030"), false)
	_check(not bool(surface.find_manual_stack_fit(stack_id, later).get("valid", true)), "terminal accepts no further item")
	_free_context(context)


func _place_auto(controller: StoragePlacementController, carried: CarriedItems, surface: StorageSurface, item: ItemInstance) -> bool:
	if not carried.add_item(item):
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


func _build_book_cd_stack(
	controller: StoragePlacementController,
	carried: CarriedItems,
	surface: StorageSurface
) -> ItemInstance:
	var base: ItemInstance = _item(&"loot_000030")
	var middle: ItemInstance = _item(&"loot_000031")
	var top: ItemInstance = _item(&"loot_000031")
	_check(_place_auto(controller, carried, surface, base), "removed-base fixture Book placed")
	_check(_place_auto(controller, carried, surface, middle), "removed-base fixture middle CD stacked")
	_check(_place_auto(controller, carried, surface, top), "removed-base fixture top CD stacked")
	return base


func _manual_empty_fit(
	controller: StoragePlacementController,
	item: ItemInstance,
	surface: StorageSurface,
	origin: Vector2i,
	rotated: bool
) -> Dictionary:
	var entry = controller.call("_entry_for_item", item, rotated)
	return {
		"valid": surface.can_place_at(origin, entry.footprint),
		"placement_kind": "empty",
		"stack_id": item.instance_id,
		"insertion_index": 0,
		"origin": origin,
		"footprint": entry.footprint,
		"base_footprint": entry.footprint,
		"rotated": rotated,
		"zone_kind": "manual",
		"zone_category": "",
		"host_y_m": surface.get_local_placement_position(origin, entry.footprint).y
	}


func _player_for_storage_dispatch(
	carried: CarriedItems,
	controller: StoragePlacementController
) -> Node:
	var player: Node = PlayerControllerScript.new()
	var prompt: Label = Label.new()
	player.add_child(prompt)
	player.set("carried_items", carried)
	player.set("_storage_placement", controller)
	player.set("_interaction_prompt", prompt)
	return player


func _place_manual_empty(
	controller: StoragePlacementController,
	carried: CarriedItems,
	surface: StorageSurface,
	item: ItemInstance,
	origin: Vector2i
) -> bool:
	if not carried.add_item(item):
		return false
	var entry = controller.call("_entry_for_item", item, false)
	var fit: Dictionary = {
		"valid": true,
		"placement_kind": "empty",
		"stack_id": item.instance_id,
		"insertion_index": 0,
		"origin": origin,
		"footprint": entry.footprint,
		"base_footprint": entry.footprint,
		"rotated": false,
		"zone_kind": "manual",
		"zone_category": "",
		"host_y_m": surface.get_local_placement_position(origin, entry.footprint).y
	}
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", true)
	controller.set("_rotated", false)
	return controller.place_selected()


func _context(size: Vector2i, clearance_m: float) -> Dictionary:
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.configure(&"interaction_stack", float(size.x) * 0.10 + 0.001, float(size.y) * 0.10 + 0.001, 0.10, clearance_m)
	var carried: CarriedItems = CarriedItemsScript.new()
	carried.max_bulk = 999
	root.add_child(carried)
	var controller: StoragePlacementController = StoragePlacementControllerScript.new()
	root.add_child(controller)
	controller.configure(null, carried, 1.8)
	return {"surface": surface, "carried": carried, "controller": controller}


func _free_context(context: Dictionary) -> void:
	(context["controller"] as Node).free()
	(context["carried"] as Node).free()
	(context["surface"] as Node).free()


func _item(item_id: StringName) -> ItemInstance:
	return ItemInstanceScript.new(_definitions[String(item_id)] as ItemDefinition)


func _definitions_by_id() -> Dictionary:
	var catalogue: Resource = load(CATALOG_PATH)
	var result: Dictionary = {}
	for value: Variant in catalogue.get("definitions") as Array:
		var definition: ItemDefinition = value as ItemDefinition
		result[String(definition.item_id)] = definition
	return result


func _targetable(entry) -> bool:
	if entry.world_item == null or not is_instance_valid(entry.world_item):
		return false
	var area: Area3D = entry.world_item.get_node_or_null("PickupArea") as Area3D
	return area != null and area.collision_layer != 0 and area.monitorable


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
