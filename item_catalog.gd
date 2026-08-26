extends Resource
class_name ItemCatalog

## Persistent registry for authored ItemDefinition resources. Visual paths are
## retained only for the current raw-GLB prototype registration path.

@export var definitions: Array[ItemDefinition] = []

var _definitions_by_id: Dictionary = {}
var _definitions_by_visual_path: Dictionary = {}
var _validation_errors: PackedStringArray = []
var _indexes_built: bool = false
var _index_build_count: int = 0


func set_definitions(value: Array[ItemDefinition]) -> void:
	definitions = value.duplicate()
	_invalidate_indexes()


func get_definition_by_id(item_id: StringName) -> ItemDefinition:
	_ensure_indexes()
	var value: Variant = _definitions_by_id.get(item_id)
	return value as ItemDefinition if value is ItemDefinition else null


func get_definition_by_visual_path(visual_path: String) -> ItemDefinition:
	_ensure_indexes()
	var normalized_path: String = _normalize_path(visual_path)
	var value: Variant = _definitions_by_visual_path.get(normalized_path)
	return value as ItemDefinition if value is ItemDefinition else null


func get_validation_errors() -> PackedStringArray:
	_ensure_indexes()
	return _validation_errors.duplicate()


func get_index_build_count() -> int:
	return _index_build_count


func _invalidate_indexes() -> void:
	_definitions_by_id.clear()
	_definitions_by_visual_path.clear()
	_validation_errors.clear()
	_indexes_built = false


func _ensure_indexes() -> void:
	if _indexes_built:
		return

	_index_build_count += 1
	var duplicate_ids: Dictionary = {}
	var duplicate_visual_paths: Dictionary = {}

	for definition: ItemDefinition in definitions:
		if definition == null:
			_record_error("ItemCatalog contains a null ItemDefinition reference.")
			continue

		var item_id: StringName = definition.item_id
		if String(item_id).strip_edges().is_empty():
			_record_error("ItemCatalog contains an ItemDefinition with an empty ID.")
		elif duplicate_ids.has(item_id):
			pass
		elif _definitions_by_id.has(item_id):
			_definitions_by_id.erase(item_id)
			duplicate_ids[item_id] = true
			_record_error("Duplicate ItemDefinition ID '%s'." % String(item_id))
		else:
			_definitions_by_id[item_id] = definition

		if definition.visual_scene == null:
			_record_error(
				"ItemDefinition '%s' has no visual scene." % String(item_id)
			)
			continue

		var visual_path: String = _normalize_path(definition.visual_scene.resource_path)
		if visual_path.is_empty():
			_record_error(
				"ItemDefinition '%s' has a visual scene without a resource path."
				% String(item_id)
			)
		elif duplicate_visual_paths.has(visual_path):
			pass
		elif _definitions_by_visual_path.has(visual_path):
			_definitions_by_visual_path.erase(visual_path)
			duplicate_visual_paths[visual_path] = true
			_record_error("Duplicate ItemDefinition visual path '%s'." % visual_path)
		else:
			_definitions_by_visual_path[visual_path] = definition

	_indexes_built = true


func _record_error(message: String) -> void:
	_validation_errors.append(message)
	push_error(message)


func _normalize_path(path: String) -> String:
	return path.strip_edges().replace("\\", "/")
