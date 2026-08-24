extends RefCounted
class_name ItemInstance

## Runtime identity/state for one physical item.
## Multiple ItemInstances may share one ItemDefinition.

var instance_id: String
var definition: ItemDefinition
var contaminated: bool = false


func _init(item_definition: ItemDefinition = null) -> void:
	definition = item_definition
	instance_id = "%s-%s" % [
		String(definition.item_id) if definition != null else "item",
		str(Time.get_ticks_usec())
	]


func get_display_name() -> String:
	if definition == null:
		return "Unknown Item"
	return ("Contaminated " if contaminated else "") + definition.display_name


func get_bulk() -> int:
	return definition.bulk if definition != null else 0



func get_storage_category() -> String:
	if definition == null:
		return "General"
	var category: String = definition.storage_category.strip_edges()
	return "General" if category.is_empty() else category



func get_storage_footprint() -> Vector3i:
	return definition.storage_footprint if definition != null else Vector3i.ONE


func is_stackable() -> bool:
	return definition.stackable if definition != null else false


func get_utility_id() -> StringName:
	return definition.utility_id if definition != null else &"None"


func get_utility_value() -> int:
	if definition == null:
		return 0

	var value: int = definition.utility_value
	if not contaminated:
		return value

	if value <= 1:
		return 0
	return int(ceil(value / 2.0))


func get_visual_scene() -> PackedScene:
	return definition.visual_scene if definition != null else null



func get_icon() -> Texture2D:
	return definition.icon if definition != null else null


func get_preview_auto_orient() -> bool:
	return definition.preview_auto_orient if definition != null else true


func get_preview_rotation_degrees() -> Vector3:
	return definition.preview_rotation_degrees if definition != null else Vector3(-8.0, 12.0, 0.0)


func get_preview_zoom() -> float:
	return definition.preview_zoom if definition != null else 1.0


func get_held_auto_orient() -> bool:
	return definition.held_auto_orient if definition != null else true


func get_held_rotation_degrees() -> Vector3:
	return definition.held_rotation_degrees if definition != null else Vector3(-10.0, -18.0, -8.0)


func get_held_offset() -> Vector3:
	return definition.held_offset if definition != null else Vector3(0.28, -0.24, -0.58)


func get_held_max_dimension() -> float:
	return definition.held_max_dimension if definition != null else 0.55



func get_storage_rotation_degrees() -> Vector3:
	return definition.storage_rotation_degrees if definition != null else Vector3.ZERO


func utility_text() -> String:
	var value: int = get_utility_value()
	var utility: StringName = get_utility_id()
	if value <= 0 or utility == &"None":
		return "No utility"
	return "+%d %s" % [value, String(utility)]
