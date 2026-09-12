extends Resource
class_name PrototypeLootPool

@export var pool_id: StringName = &"prototype_receiving_pool"
@export_range(1, 9999, 1) var revision: int = 1
@export var item_definition_ids: Array[StringName] = []


func validate_against_catalog(catalog: ItemCatalog) -> PackedStringArray:
	var errors := PackedStringArray()
	if catalog == null:
		errors.append("PrototypeLootPool requires an ItemCatalog.")
		return errors
	var seen: Dictionary = {}
	for item_id: StringName in item_definition_ids:
		if String(item_id).is_empty():
			errors.append("PrototypeLootPool contains an empty item ID.")
		elif seen.has(item_id):
			errors.append("PrototypeLootPool contains duplicate item ID '%s'." % String(item_id))
		elif catalog.get_definition_by_id(item_id) == null:
			errors.append("PrototypeLootPool item ID '%s' does not resolve." % String(item_id))
		seen[item_id] = true
	return errors


func resolve_definitions(catalog: ItemCatalog) -> Array[ItemDefinition]:
	if not validate_against_catalog(catalog).is_empty():
		return []
	var result: Array[ItemDefinition] = []
	for item_id: StringName in item_definition_ids:
		result.append(catalog.get_definition_by_id(item_id))
	return result
