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

	var value := definition.utility_value
	if not contaminated:
		return value

	# Deferred contamination rule from the GDD: Utility 1 -> 0; otherwise halve
	# and round up. This is inactive until something marks an item contaminated.
	if value <= 1:
		return 0
	return int(ceil(value / 2.0))


func utility_text() -> String:
	var value := get_utility_value()
	var utility := get_utility_id()
	if value <= 0 or utility == &"None":
		return "No utility"
	return "+%d %s" % [value, String(utility)]
