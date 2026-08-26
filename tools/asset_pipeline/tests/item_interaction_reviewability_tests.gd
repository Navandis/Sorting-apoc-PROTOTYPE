extends SceneTree

const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const WorldItemScript = preload("res://world_item.gd")
const CarriedItemsScript = preload("res://carried_items.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")

const REPRESENTATIVE_PATHS: PackedStringArray = [
	"res://assets/props/Hydration/SM_SodaCan.glb",
	"res://assets/props/Hydration/SM_Metal_Can_01a.glb",
	"res://assets/props/Weapons/SM_Gun_AssaultRifle.glb",
	"res://assets/props/Weapons/SM_Gun_Pistol.glb",
	"res://assets/props/Weapons/SM_Gun_Shotgun.glb",
	"res://assets/props/protection/SM_Gloves_02.glb",
	"res://assets/props/Weapons/SM_Hammer_3.glb",
	"res://assets/props/protection/SM_Pants_02.glb"
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for source_path: String in REPRESENTATIVE_PATHS:
		_test_world_carry_store_and_retrieve(source_path)
	print("PASS: item interaction reviewability tests")
	quit(0)


# Catches catalogue definitions that resolve but cannot traverse the unchanged
# runtime ownership path from world loot to carry, zone-auto fit, posed stored
# loot, manual ghost/packing yaw, reservation release, and retrieval.
func _test_world_carry_store_and_retrieve(source_path: String) -> void:
	var definition: ItemDefinition = (
		PrototypeItemCatalogScript.create_definition_for_scene_path(source_path)
	)
	assert(definition != null)

	var carried_items: Node = CarriedItemsScript.new()
	carried_items.set("max_bulk", 999)
	root.add_child(carried_items)

	var loose_host: Node3D = definition.visual_scene.instantiate() as Node3D
	assert(loose_host != null)
	root.add_child(loose_host)
	var loose_world_item: WorldItem = WorldItemScript.new()
	loose_host.add_child(loose_world_item)
	loose_world_item.configure(loose_host, definition)
	var item: ItemInstance = loose_world_item.get_item_instance()
	assert(item != null)
	assert(loose_world_item.pickup_into(carried_items))
	assert(carried_items.call("get_item_count") == 1)
	assert(carried_items.call("get_selected_item") == item)

	var footprint: Vector2i = Vector2i(
		definition.storage_footprint.x,
		definition.storage_footprint.y
	)
	var surface: StorageSurface = StorageSurfaceScript.new()
	root.add_child(surface)
	var cell_size: float = 0.10
	var longest_side: int = maxi(footprint.x, footprint.y)
	surface.configure(
		StringName("smoke_%s" % String(definition.item_id)),
		float(longest_side + 4) * cell_size,
		float(longest_side + 4) * cell_size,
		cell_size
	)

	var controller: StoragePlacementController = StoragePlacementControllerScript.new()
	root.add_child(controller)
	controller.configure(null, carried_items, 1.8)

	var auto_fit: Dictionary = surface.find_zone_auto_fit(
		definition.storage_category,
		footprint,
		true
	)
	assert(bool(auto_fit["valid"]))
	var auto_origin: Vector2i = auto_fit["origin"] as Vector2i
	var auto_footprint: Vector2i = auto_fit["footprint"] as Vector2i
	var auto_rotated: bool = bool(auto_fit["rotated"])
	assert(surface.reserve_at(item.instance_id, auto_origin, auto_footprint, auto_rotated))
	assert(surface.get_reservation_count() == 1)
	assert(carried_items.call("remove_selected") == item)
	assert(carried_items.call("get_item_count") == 0)
	assert(bool(controller.call(
		"_spawn_stored_world_item",
		item,
		surface,
		item.instance_id,
		auto_origin,
		auto_footprint,
		auto_rotated
	)))
	var stored_host: Node3D = _newest_stored_host(surface)
	assert(stored_host != null)
	var stored_packing_root: Node3D = stored_host.get_node("StoredPackingYaw") as Node3D
	var stored_pose_root: Node3D = stored_packing_root.get_node(
		"StorageSeating/AuthoredStoragePose"
	) as Node3D
	assert(_packing_yaw_matches(stored_packing_root, auto_rotated))
	assert(stored_pose_root.rotation_degrees.is_equal_approx(definition.storage_rotation_degrees))
	var stored_world_item: WorldItem = stored_host.get_node("WorldItem") as WorldItem
	assert(stored_world_item.is_stored_item())
	assert(stored_world_item.pickup_into(carried_items))
	assert(surface.get_reservation_count() == 0)
	assert(carried_items.call("get_item_count") == 1)
	assert(carried_items.call("get_selected_item") == item)

	var manual_rotated: bool = footprint.x != footprint.y
	controller.set("_rotated", manual_rotated)
	controller.call("_rebuild_ghost", item)
	var ghost_packing_root: Node3D = controller.get("_ghost_packing_root") as Node3D
	var ghost_pose_root: Node3D = ghost_packing_root.get_node(
		"StorageSeating/AuthoredStoragePose"
	) as Node3D
	var ghost_seating_root: Node3D = ghost_packing_root.get_node("StorageSeating") as Node3D
	assert(_packing_yaw_matches(ghost_packing_root, manual_rotated))
	assert(ghost_packing_root.rotation.x == 0.0)
	assert(ghost_packing_root.rotation.z == 0.0)

	var manual_footprint: Vector2i = (
		Vector2i(footprint.y, footprint.x) if manual_rotated else footprint
	)
	var manual_fit: Dictionary = surface.find_nearest_fit_to_local_point(
		Vector3.ZERO,
		manual_footprint
	)
	assert(bool(manual_fit["valid"]))
	var manual_origin: Vector2i = manual_fit["origin"] as Vector2i
	var manual_key: String = item.instance_id + "_manual"
	assert(surface.reserve_at(manual_key, manual_origin, manual_footprint, manual_rotated))
	assert(carried_items.call("remove_selected") == item)
	assert(bool(controller.call(
		"_spawn_stored_world_item",
		item,
		surface,
		manual_key,
		manual_origin,
		manual_footprint,
		manual_rotated
	)))
	var manual_host: Node3D = _newest_stored_host(surface)
	var manual_packing_root: Node3D = manual_host.get_node("StoredPackingYaw") as Node3D
	var manual_seating_root: Node3D = manual_packing_root.get_node("StorageSeating") as Node3D
	var manual_pose_root: Node3D = manual_seating_root.get_node("AuthoredStoragePose") as Node3D
	assert(manual_pose_root.basis.is_equal_approx(ghost_pose_root.basis))
	assert(manual_seating_root.position.is_equal_approx(ghost_seating_root.position))
	assert(manual_packing_root.basis.is_equal_approx(ghost_packing_root.basis))
	var manual_world_item: WorldItem = manual_host.get_node("WorldItem") as WorldItem
	assert(manual_world_item.pickup_into(carried_items))
	assert(surface.get_reservation_count() == 0)
	assert(carried_items.call("get_selected_item") == item)

	if source_path.ends_with("SM_Pants_02.glb"):
		assert(definition.storage_rotation_degrees == Vector3.ZERO)

	controller.free()
	carried_items.free()
	surface.free()


func _newest_stored_host(surface: StorageSurface) -> Node3D:
	var newest: Node3D = null
	for child: Node in surface.get_children():
		if (
			child is Node3D
			and not child.is_queued_for_deletion()
			and child.has_node("WorldItem")
		):
			newest = child as Node3D
	return newest


func _packing_yaw_matches(root_node: Node3D, rotated: bool) -> bool:
	var expected: Basis = Basis(Vector3.UP, deg_to_rad(90.0)) if rotated else Basis.IDENTITY
	return root_node.basis.is_equal_approx(expected)
