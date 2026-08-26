extends RefCounted
class_name PrototypeItemCatalog

## Compatibility facade for raw GLB instances already placed in main.tscn.
## Persistent ItemDefinition resources in ItemCatalog are the sole gameplay
## data source; node-name mapping remains a last-resort path hint only.

const ItemCatalogScript = preload("res://item_catalog.gd")
const CATALOGUE_PATH: String = "res://data/items/item_catalog.tres"

static var _persistent_item_catalogue: Resource = null


static func create_definition_for_node(node: Node) -> ItemDefinition:
	if node == null:
		return null

	var scene_path: String = ""
	if node is Node3D:
		scene_path = (node as Node3D).scene_file_path

	if scene_path.is_empty():
		scene_path = _scene_path_from_name(String(node.name))
	if scene_path.is_empty():
		return null

	return create_definition_for_scene_path(scene_path)


static func create_definition_for_scene_path(scene_path: String) -> ItemDefinition:
	var catalogue: Resource = _catalogue()
	if catalogue == null:
		return null
	return catalogue.call("get_definition_by_visual_path", scene_path) as ItemDefinition


static func get_definition_by_id(item_id: StringName) -> ItemDefinition:
	var catalogue: Resource = _catalogue()
	if catalogue == null:
		return null
	return catalogue.call("get_definition_by_id", item_id) as ItemDefinition


static func _catalogue() -> Resource:
	if _persistent_item_catalogue == null:
		_persistent_item_catalogue = load(CATALOGUE_PATH)
	if _persistent_item_catalogue == null:
		push_error("Persistent item catalogue could not be loaded: %s" % CATALOGUE_PATH)
		return null
	if _persistent_item_catalogue.get_script() != ItemCatalogScript:
		push_error("Persistent item catalogue has the wrong resource type.")
		return null
	return _persistent_item_catalogue


static func _scene_path_from_name(node_name: String) -> String:
	if node_name.begins_with("cereal_box"):
		return "res://assets/props/Food/cereal_box.glb"
	if node_name.begins_with("pill_bottle"):
		return "res://assets/props/medical/pill_bottle.glb"
	if node_name.begins_with("hammer"):
		return "res://assets/props/Weapons/hammer.glb"
	if node_name.begins_with("soda_can"):
		return "res://assets/props/Hydration/soda_can.glb"
	if node_name.begins_with("tennis_racket"):
		return "res://assets/props/Weapons/tennis_racket.glb"
	if node_name.begins_with("SM_Gun_AssaultRifle"):
		return "res://assets/props/Weapons/SM_Gun_AssaultRifle.glb"
	if node_name.begins_with("SM_Gun_Pistol"):
		return "res://assets/props/Weapons/SM_Gun_Pistol.glb"
	if node_name.begins_with("SM_Gun_Shotgun"):
		return "res://assets/props/Weapons/SM_Gun_Shotgun.glb"
	if node_name.begins_with("SM_Metal_Can_01a"):
		return "res://assets/props/Hydration/SM_Metal_Can_01a.glb"
	if node_name.begins_with("SM_Pill_Bottle_01a"):
		return "res://assets/props/medical/SM_CoughSyrup_01.glb"
	if node_name.begins_with("SM_Pill_Bottle_01b"):
		return "res://assets/props/medical/SM_Antibiotics_01.glb"
	return ""
