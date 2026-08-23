extends RefCounted
class_name PrototypeItemCatalog

## Temporary prototype catalogue that turns a known visual scene into an
## ItemDefinition. This lets raw GLB instances already placed in main.tscn act
## as loot without authoring .tres resources yet. Production content should
## eventually use authored ItemDefinition resources directly.

const ItemDefinitionScript = preload("res://item_definition.gd")


static func create_definition_for_node(node: Node) -> ItemDefinition:
	if node == null:
		return null

	var scene_path: String = ""
	if node is Node3D:
		var node_3d: Node3D = node as Node3D
		scene_path = node_3d.scene_file_path

	if scene_path.is_empty():
		scene_path = _scene_path_from_name(String(node.name))

	if scene_path.is_empty():
		return null

	return create_definition_for_scene_path(scene_path)


static func create_definition_for_scene_path(scene_path: String) -> ItemDefinition:
	match scene_path:
		"res://assets/props/from_blender/cereal_box.glb":
			return _make_definition(
				&"cereal_box", "Cereal Box", &"Food", 6, 1,
				Vector3i(1, 1, 1), true, scene_path,
				Vector3(-8.0, 12.0, 0.0), 1.0,
				Vector3(-10.0, -18.0, -4.0), Vector3(0.28, -0.25, -0.58), 0.55
			)
		"res://assets/props/from_blender/pill_bottle.glb":
			return _make_definition(
				&"painkillers", "Painkillers", &"Medical", 4, 1,
				Vector3i(1, 1, 1), true, scene_path,
				Vector3(-8.0, 12.0, 0.0), 1.0,
				Vector3(-8.0, -15.0, -3.0), Vector3(0.24, -0.20, -0.44), 0.55
			)
		"res://assets/props/from_blender/hammer.glb":
			return _make_definition(
				&"hammer", "Hammer", &"Weapons", 3, 2,
				Vector3i(1, 3, 1), false, scene_path,
				Vector3(-8.0, 12.0, -35.0), 1.0,
				Vector3(-10.0, -18.0, -24.0), Vector3(0.30, -0.25, -0.58), 0.55
			)
		"res://assets/props/from_blender/soda_can.glb":
			return _make_definition(
				&"soda_can", "Soda Can", &"Hydration", 3, 1,
				Vector3i(1, 1, 1), true, scene_path,
				Vector3(-8.0, 12.0, 0.0), 1.0,
				Vector3(-8.0, -15.0, -3.0), Vector3(0.24, -0.20, -0.44), 0.55
			)
		"res://assets/props/from_blender/tennis_racket.glb":
			return _make_definition(
				&"tennis_racket", "Tennis Racket", &"Weapons", 1, 5,
				Vector3i(2, 5, 1), false, scene_path,
				Vector3(-8.0, 12.0, -18.0), 0.95,
				Vector3(-10.0, -18.0, -20.0), Vector3(0.31, -0.26, -0.66), 0.55
			)
		"res://assets/props/SM_Gun_AssaultRifle.glb":
			return _make_definition(
				&"assault_rifle", "Assault Rifle", &"Weapons", 12, 5,
				Vector3i(1, 5, 1), false, scene_path,
				Vector3(-7.0, 10.0, -8.0), 0.90,
				Vector3(-9.0, -20.0, -15.0), Vector3(0.34, -0.25, -0.70), 0.62
			)
		"res://assets/props/SM_Gun_Pistol.glb":
			return _make_definition(
				&"pistol", "Pistol", &"Weapons", 8, 2,
				Vector3i(2, 1, 1), false, scene_path,
				Vector3(-8.0, 12.0, -10.0), 1.0,
				Vector3(-10.0, -18.0, -12.0), Vector3(0.28, -0.22, -0.50), 0.55
			)
		"res://assets/props/SM_Gun_Shotgun.glb":
			return _make_definition(
				&"shotgun", "Shotgun", &"Weapons", 10, 4,
				Vector3i(1, 5, 1), false, scene_path,
				Vector3(-7.0, 10.0, -8.0), 0.90,
				Vector3(-9.0, -20.0, -15.0), Vector3(0.34, -0.25, -0.70), 0.62
			)
		"res://assets/props/SM_Metal_Can_01a.glb":
			return _make_definition(
				&"metal_food_can", "Food Can", &"Food", 4, 1,
				Vector3i(1, 1, 1), true, scene_path,
				Vector3(-8.0, 12.0, 0.0), 1.0,
				Vector3(-8.0, -15.0, -3.0), Vector3(0.24, -0.20, -0.44), 0.55
			)
		"res://assets/props/SM_Pill_Bottle_01a.glb":
			return _make_definition(
				&"pill_bottle_a", "Medicine Bottle", &"Medical", 3, 1,
				Vector3i(1, 1, 1), true, scene_path,
				Vector3(-8.0, 12.0, 0.0), 1.0,
				Vector3(-8.0, -15.0, -3.0), Vector3(0.24, -0.20, -0.44), 0.55
			)
		"res://assets/props/SM_Pill_Bottle_01b.glb":
			return _make_definition(
				&"pill_bottle_b", "Medicine Bottle", &"Medical", 5, 1,
				Vector3i(1, 1, 1), true, scene_path,
				Vector3(-8.0, 12.0, 0.0), 1.0,
				Vector3(-8.0, -15.0, -3.0), Vector3(0.24, -0.20, -0.44), 0.55
			)
		_:
			return null


static func _scene_path_from_name(node_name: String) -> String:
	if node_name.begins_with("cereal_box"):
		return "res://assets/props/from_blender/cereal_box.glb"
	if node_name.begins_with("pill_bottle"):
		return "res://assets/props/from_blender/pill_bottle.glb"
	if node_name.begins_with("hammer"):
		return "res://assets/props/from_blender/hammer.glb"
	if node_name.begins_with("soda_can"):
		return "res://assets/props/from_blender/soda_can.glb"
	if node_name.begins_with("tennis_racket"):
		return "res://assets/props/from_blender/tennis_racket.glb"
	if node_name.begins_with("SM_Gun_AssaultRifle"):
		return "res://assets/props/SM_Gun_AssaultRifle.glb"
	if node_name.begins_with("SM_Gun_Pistol"):
		return "res://assets/props/SM_Gun_Pistol.glb"
	if node_name.begins_with("SM_Gun_Shotgun"):
		return "res://assets/props/SM_Gun_Shotgun.glb"
	if node_name.begins_with("SM_Metal_Can_01a"):
		return "res://assets/props/SM_Metal_Can_01a.glb"
	if node_name.begins_with("SM_Pill_Bottle_01a"):
		return "res://assets/props/SM_Pill_Bottle_01a.glb"
	if node_name.begins_with("SM_Pill_Bottle_01b"):
		return "res://assets/props/SM_Pill_Bottle_01b.glb"
	return ""


static func _make_definition(
	item_id: StringName,
	display_name: String,
	utility_id: StringName,
	utility_value: int,
	bulk: int,
	footprint: Vector3i,
	stackable: bool,
	visual_scene_path: String,
	preview_rotation: Vector3,
	preview_zoom: float,
	held_rotation: Vector3,
	held_offset: Vector3,
	held_max_dimension: float
) -> ItemDefinition:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.item_id = item_id
	definition.display_name = display_name
	definition.utility_id = utility_id
	definition.utility_value = utility_value
	definition.bulk = bulk
	definition.storage_footprint = footprint
	definition.stackable = stackable
	definition.preview_auto_orient = true
	definition.preview_rotation_degrees = preview_rotation
	definition.preview_zoom = preview_zoom
	definition.held_auto_orient = true
	definition.held_rotation_degrees = held_rotation
	definition.held_offset = held_offset
	definition.held_max_dimension = held_max_dimension

	var visual_resource: Resource = load(visual_scene_path)
	if visual_resource is PackedScene:
		definition.visual_scene = visual_resource as PackedScene
	else:
		push_warning("Prototype item visual could not be loaded: %s" % visual_scene_path)

	return definition
