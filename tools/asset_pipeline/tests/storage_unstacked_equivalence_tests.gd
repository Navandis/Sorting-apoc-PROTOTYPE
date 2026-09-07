extends SceneTree

const CarriedItemsScript = preload("res://carried_items.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")

const CATALOG_PATH: String = "res://data/items/item_catalog.tres"
const ORDINARY_ITEM_ID: StringName = &"loot_000003"

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var definition: ItemDefinition = _definition_by_id(ORDINARY_ITEM_ID)
	_check(definition != null, "ordinary definition loads")
	if definition == null:
		quit(1)
		return
	_check(not definition.can_be_stacked, "ordinary item remains non-stack-enabled")
	_check(not definition.can_support_stack, "ordinary item remains non-supporting")
	_check(definition.auto_stack_group.is_empty(), "ordinary item retains empty group")

	var item: ItemInstance = ItemInstanceScript.new(definition)
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	surface.configure(&"ordinary_equivalence", 0.801, 0.801, 0.10, 1.0)
	var carried: CarriedItems = CarriedItemsScript.new()
	carried.max_bulk = 999
	root.add_child(carried)
	var controller: StoragePlacementController = StoragePlacementControllerScript.new()
	root.add_child(controller)
	controller.configure(null, carried, 1.8)
	_check(carried.add_item(item), "ordinary item enters carry strip")

	var origin: Vector2i = Vector2i(1, 2)
	var footprint: Vector2i = Vector2i(5, 3)
	var fit: Dictionary = {
		"valid": true,
		"placement_kind": "empty",
		"stack_id": item.instance_id,
		"insertion_index": 0,
		"origin": origin,
		"footprint": footprint,
		"base_footprint": footprint,
		"rotated": true,
		"zone_kind": "manual",
		"zone_category": "",
		"host_y_m": 0.012
	}
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", true)
	controller.set("_rotated", true)
	_check(controller.place_selected(), "ordinary manual placement succeeds")

	_check(surface.get_reservation_count() == 1, "ordinary placement owns one reservation")
	_check(surface.get_stack_count() == 1, "ordinary placement has one internal stack record")
	var stack_id: String = surface.get_stack_id_for_item(item.instance_id)
	_check(stack_id == item.instance_id, "ordinary reservation key remains stable item identity")
	var stack: StorageStack = surface.get_storage_stack(stack_id)
	_check(stack != null and stack.entries.size() == 1, "ordinary internal record has exactly one entry")
	var reservation: Dictionary = surface.get_reservation(item.instance_id)
	_check(reservation.get("origin", Vector2i.ZERO) == origin, "ordinary origin is unchanged")
	_check(reservation.get("footprint", Vector2i.ZERO) == footprint, "ordinary oriented footprint is unchanged")
	_check(bool(reservation.get("rotated", false)), "ordinary packing rotation is unchanged")

	var stored_host: Node3D = stack.entries[0].host
	var expected_position: Vector3 = Vector3(-0.05, 0.012, -0.05)
	_check(stored_host.position.is_equal_approx(expected_position), "ordinary stored transform matches pre-spike cell centering")
	var packing_root: Node3D = stored_host.get_node("StoredPackingYaw") as Node3D
	_check(packing_root.basis.is_equal_approx(Basis(Vector3.UP, deg_to_rad(90.0))), "ordinary packing yaw remains 90 degrees")
	var seating_root: Node3D = packing_root.get_node("StorageSeating") as Node3D
	var pose_root: Node3D = seating_root.get_node("AuthoredStoragePose") as Node3D
	_check(pose_root.rotation_degrees.is_equal_approx(definition.storage_rotation_degrees), "ordinary authored pose hierarchy is unchanged")
	_check(seating_root.position.y > 0.0, "ordinary posed-bounds seating remains active")

	var stored_world_item: WorldItem = stack.entries[0].world_item as WorldItem
	var pickup_area: Area3D = stored_world_item.get_node_or_null("PickupArea") as Area3D
	_check(stored_world_item.is_stored_item(), "ordinary item remains a stored target")
	_check(pickup_area != null and pickup_area.collision_layer != 0 and pickup_area.monitorable, "ordinary item remains independently targetable")
	_check(stored_world_item.pickup_into(carried), "ordinary retrieval uses unchanged pickup action")
	_check(carried.get_selected_item() == item, "ordinary retrieval preserves exact ItemInstance")
	_check(surface.get_reservation_count() == 0, "ordinary retrieval releases reservation")
	_check(surface.get_stack_count() == 0, "ordinary retrieval leaves no internal stack record")
	_check(is_zero_approx(surface.get_occupancy_ratio()), "ordinary retrieval leaves no occupied cell")
	await process_frame
	_check(not is_instance_valid(stored_host), "ordinary retrieved host is removed")

	controller.free()
	carried.free()
	surface.free()
	if _failed:
		quit(1)
		return
	print("PASS: storage unstacked equivalence tests")
	quit(0)


func _definition_by_id(item_id: StringName) -> ItemDefinition:
	var catalogue: Resource = load(CATALOG_PATH)
	for value: Variant in catalogue.get("definitions") as Array:
		var definition: ItemDefinition = value as ItemDefinition
		if definition.item_id == item_id:
			return definition
	return null


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
