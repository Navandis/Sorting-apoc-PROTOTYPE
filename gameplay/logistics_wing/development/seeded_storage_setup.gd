extends Node3D

var _initialized: bool = false
var restore_pending := false


func _ready() -> void:
	initialize_if_enabled()


func initialize_if_enabled() -> bool:
	if restore_pending:
		return true
	if _initialized:
		return true
	var registrar := get_node_or_null("SeedRegistrar")
	if registrar == null or not registrar.has_method("register_existing_hosts"):
		push_error("SeededStorageSetup requires its SeedRegistrar child")
		return false
	_initialized = bool(registrar.call("register_existing_hosts"))
	return _initialized


func initialize_manifest(wing: Node, manifest: Array) -> String:
	# New Run only. Continue reconstructs the existing surface/item snapshots.
	# Reuse actual carrying, fit, support and placement commits; no second stock.
	if _initialized: return "Initial manifest was already admitted"
	if not get_node("SeedRegistrar").register_existing_hosts(): return "Could not initialize the M4 seed registrar"
	var carry: CarriedItems = wing.get_node("Player/CarriedItems")
	var controller := StoragePlacementController.new()
	wing.add_child(controller)
	controller.configure(null, carry, 2.3)
	var supplies: Array[ItemInstance] = []
	for id: String in manifest:
		var definition := PrototypeItemCatalog.get_definition_by_id(StringName(id))
		supplies.append(ItemInstance.new(definition, wing.run_identity.allocate("seed")))
	# Large reservations first; repeated definitions remain separate instances.
	supplies.sort_custom(func(a,b):
		var af: Vector3i = a.get_storage_footprint()
		var bf: Vector3i = b.get_storage_footprint()
		if af.x * af.y != bf.x * bf.y: return af.x * af.y > bf.x * bf.y
		return int(a.instance_id.get_slice(":",2)) < int(b.instance_id.get_slice(":",2)))
	var surfaces: Array = wing.get_functional_surfaces()
	for surface: StorageSurface in surfaces: surface.initialize_zones_if_needed("General")
	for item: ItemInstance in supplies:
		if not carry.add_item(item):
			controller.free()
			return "M4 starting item exceeds player carrying capacity: " + String(item.definition.item_id)
		var placed := false
		for surface: StorageSurface in surfaces:
			controller.set("_current_surface",surface)
			controller.set("_manual_mode",false)
			if controller.place_selected():
				placed = true
				break
		if not placed:
			controller.free()
			return "No legal production storage placement for M4 seed " + String(item.definition.item_id) + " (" + item.instance_id + ")"
	controller.free()
	_initialized = true
	return ""
