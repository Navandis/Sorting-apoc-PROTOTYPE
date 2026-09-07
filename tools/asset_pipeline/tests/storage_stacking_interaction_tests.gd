extends SceneTree

const CarriedItemsScript = preload("res://carried_items.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
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
	var context: Dictionary = _context(Vector2i(5, 5), 1.0)
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

	var middle_world_item: WorldItem = stack.entries[1].world_item as WorldItem
	var top_y_before: float = stack.entries[2].host.position.y
	_check(middle_world_item.pickup_into(carried), "visible middle can retrieves through ordinary pickup")
	_check(carried.get_selected_item() == dry_middle, "retrieval preserves stable ItemInstance")
	_check(stack.entries.size() == 2, "middle retrieval removes only selected member")
	_check(stack.entries[1].item == metal_top, "upper can remains in relative order")
	_check(stack.entries[1].host.position.y < top_y_before, "upper can compresses deterministically")
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
