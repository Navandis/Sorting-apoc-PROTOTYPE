extends SceneTree

const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const WorldItemScript = preload("res://world_item.gd")

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene: PackedScene = load("res://main.tscn") as PackedScene
	_check(packed_scene != null, "main scene loads")
	if packed_scene == null:
		quit(1)
		return

	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame

	var registered_props: int = 0
	for node: Node in scene.find_children("*", "Node3D", true, false):
		var host: Node3D = node as Node3D
		if not host.scene_file_path.begins_with("res://assets/props/"):
			continue
		var definition: ItemDefinition = (
			PrototypeItemCatalogScript.create_definition_for_node(host)
		)
		if definition == null:
			continue
		registered_props += 1
		var world_item: WorldItem = host.get_node_or_null("WorldItem") as WorldItem
		_check(
			world_item != null,
			"%s receives WorldItem registration" % host.get_path()
		)
		if world_item == null:
			continue
		var pickup_area: Area3D = world_item.get_node_or_null("PickupArea") as Area3D
		_check(
			pickup_area != null,
			"%s receives pickup interaction geometry" % host.get_path()
		)
		if pickup_area != null:
			_check(
				pickup_area.collision_layer == WorldItemScript.PICKUP_COLLISION_LAYER,
				"%s is targetable on the pickup layer" % host.get_path()
			)

	_check(registered_props > 0, "main scene contains catalogued prop instances")
	if _failed:
		quit(1)
		return
	print("PASS: main scene pickup registration tests")
	quit(0)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
