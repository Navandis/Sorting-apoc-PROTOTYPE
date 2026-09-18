extends Node

const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const WorldItemScript = preload("res://world_item.gd")
const SeedHostScript = preload("res://gameplay/logistics_wing/development/seed_host.gd")

const BLOCKED_ITEM_IDS: Array[StringName] = [
	&"loot_000034",
	&"loot_000036",
]

static var _active_namespace_owners: Dictionary = {}

@export var seed_items_path: NodePath = NodePath("../SeedItems")
@export var fixture_namespace: String = "wing_seed_v1"

var _validation_failures: Array[String] = []
var _registered_instance_ids: Array[String] = []
var _registration_completed: bool = false


func register_existing_hosts() -> bool:
	if _registration_completed:
		return true

	_validation_failures.clear()
	_registered_instance_ids.clear()
	if not _claim_fixture_namespace():
		_report_failures()
		return false
	var seed_items := get_node_or_null(seed_items_path)
	if seed_items == null:
		_record_failure("missing SeedItems root at %s" % seed_items_path)
		_report_failures()
		return false

	var declarations: Array[Dictionary] = []
	var seen_instance_ids: Dictionary = {}
	for child: Node in seed_items.get_children():
		_validate_host(child, declarations, seen_instance_ids)

	if not _validation_failures.is_empty():
		_report_failures()
		return false

	for declaration: Dictionary in declarations:
		var host := declaration["host"] as Node3D
		var definition := declaration["definition"] as ItemDefinition
		var instance_id := String(declaration["instance_id"])
		var item_instance: ItemInstance = ItemInstanceScript.new(definition, instance_id)
		var world_item: WorldItem = WorldItemScript.new()
		world_item.name = "WorldItem"
		host.add_child(world_item)
		world_item.configure_existing(host, item_instance)
		_registered_instance_ids.append(instance_id)

	_registration_completed = true
	return true


func get_validation_failures() -> Array[String]:
	return _validation_failures.duplicate()


func get_registered_instance_ids() -> Array[String]:
	return _registered_instance_ids.duplicate()


func _claim_fixture_namespace() -> bool:
	if fixture_namespace.strip_edges().is_empty():
		_record_failure("empty seed identity namespace")
		return false
	var owner_ref := _active_namespace_owners.get(fixture_namespace) as WeakRef
	var owner := owner_ref.get_ref() as Node if owner_ref != null else null
	if owner != null and owner != self:
		var owner_label := String(owner.get_path()) if owner.is_inside_tree() else String(owner.name)
		_record_failure(
			"duplicate seed identity namespace %s already active at %s"
			% [fixture_namespace, owner_label]
		)
		return false
	_active_namespace_owners[fixture_namespace] = weakref(self)
	return true


func _validate_host(
	host_node: Node,
	declarations: Array[Dictionary],
	seen_instance_ids: Dictionary
) -> void:
	var host_name := String(host_node.name)
	if not (host_node is Node3D) or host_node.get_script() != SeedHostScript:
		_record_failure("%s is not a declared SeedHost" % host_name)
		return

	var host := host_node as Node3D
	var item_id := StringName(host.get("item_id"))
	if item_id == &"":
		_record_failure("%s has an empty item ID" % host_name)
		return
	if BLOCKED_ITEM_IDS.has(item_id):
		_record_failure("%s uses blocked item ID %s" % [host_name, item_id])
		return

	var definition := PrototypeItemCatalogScript.get_definition_by_id(item_id)
	if definition == null:
		_record_failure("%s has unknown item ID %s" % [host_name, item_id])
		return

	var visual_count := int(host.call("get_authored_visual_count"))
	var visual := host.call("get_authored_visual") as Node3D
	if visual_count != 1 or visual == null:
		_record_failure("%s has missing authored visual (found %d)" % [host_name, visual_count])
		return

	var expected_visual_path := definition.visual_scene.resource_path
	if visual.scene_file_path != expected_visual_path:
		_record_failure(
			"%s visual mismatch: expected %s, found %s"
			% [host_name, expected_visual_path, visual.scene_file_path]
		)
		return

	var instance_id := "%s:%s" % [fixture_namespace, host_name]
	if seen_instance_ids.has(instance_id):
		_record_failure("duplicate seed identity %s" % instance_id)
		return
	seen_instance_ids[instance_id] = true
	declarations.append({
		"host": host,
		"definition": definition,
		"instance_id": instance_id,
	})


func _record_failure(message: String) -> void:
	_validation_failures.append(message)


func _report_failures() -> void:
	for failure: String in _validation_failures:
		push_error("Wing seed validation failed: %s" % failure)
