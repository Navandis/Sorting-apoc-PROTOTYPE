extends SceneTree

const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const WorldItemScript = preload("res://world_item.gd")
const CarriedItemsScript = preload("res://carried_items.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")

const REPRESENTATIVE_PATHS: PackedStringArray = [
	"res://assets/props/Food/cereal_box.glb",
	"res://assets/props/medical/SM_MedKit_4.glb",
	"res://assets/props/Weapons/SM_Gun_Pistol.glb",
	"res://assets/props/Weapons/SM_Gun_AssaultRifle.glb",
	"res://assets/props/Weapons/SM_Hammer_3.glb",
	"res://assets/props/protection/SM_Pants_02.glb",
	"res://assets/props/Fuel/SM_FuelCanister.glb",
	"res://assets/props/electronics/SM_ComputerTower_01.glb",
	"res://assets/props/Food/SM_PigCarcass_1.glb"
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for source_path: String in REPRESENTATIVE_PATHS:
		_test_world_carry_store_and_retrieve(source_path)
	print("PASS: item interaction reviewability tests")
	quit(0)


# Catches catalogue definitions that resolve but cannot traverse the unchanged
# runtime ownership path from world loot to carry, reservation, stored loot,
# reservation release, and retrieval.
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
	surface.configure(
		StringName("smoke_%s" % String(definition.item_id)),
		float(footprint.x + 2) * cell_size,
		float(footprint.y + 2) * cell_size,
		cell_size
	)
	assert(surface.reserve_at(item.instance_id, Vector2i.ZERO, footprint))
	assert(surface.get_reservation_count() == 1)
	assert(carried_items.call("remove_selected") == item)
	assert(carried_items.call("get_item_count") == 0)

	var stored_host: Node3D = Node3D.new()
	surface.add_child(stored_host)
	var stored_visual: Node = definition.visual_scene.instantiate()
	stored_host.add_child(stored_visual)
	var stored_world_item: WorldItem = WorldItemScript.new()
	stored_host.add_child(stored_world_item)
	stored_world_item.configure_existing(stored_host, item, surface, item.instance_id)
	assert(stored_world_item.is_stored_item())
	assert(stored_world_item.pickup_into(carried_items))
	assert(surface.get_reservation_count() == 0)
	assert(carried_items.call("get_item_count") == 1)
	assert(carried_items.call("get_selected_item") == item)

	carried_items.free()
	surface.free()
