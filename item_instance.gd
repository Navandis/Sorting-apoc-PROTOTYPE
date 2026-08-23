extends RefCounted
class_name ItemInstance

## Runtime identity/state for one physical item.
## Multiple ItemInstances may share the same ItemDefinition.

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


func get_utility_id() -> StringName:
	return definition.utility_id if definition != null else &"None"


func get_utility_value() -> int:
	if definition == null:
		return 0

	var value: int = definition.utility_value
	if not contaminated:
		return value

	# Deferred contamination rule from the GDD: Utility 1 -> 0; otherwise halve
	# and round up. This is inactive until something marks an item contaminated.
	if value <= 1:
		return 0
	return int(ceil(value / 2.0))


func get_visual_scene() -> PackedScene:
	return definition.visual_scene if definition != null else null


func get_preview_auto_orient() -> bool:
	return definition.preview_auto_orient if definition != null else true


func get_preview_rotation_degrees() -> Vector3:
	return definition.preview_rotation_degrees if definition != null else Vector3(-8.0, 12.0, 0.0)


func get_preview_zoom() -> float:
	return definition.preview_zoom if definition != null else 1.0


func utility_text() -> String:
	var value: int = get_utility_value()
	var utility: StringName = get_utility_id()
	if value <= 0 or utility == &"None":
		return "No utility"
	return "+%d %s" % [value, String(utility)]
