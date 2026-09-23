extends RefCounted
class_name LootBatchEntry

var _entry_id: String = ""
var _item_instance_id: String = ""
var _definition_id: StringName = &""
var _frozen_transform: Transform3D = Transform3D.IDENTITY
var _has_frozen_transform: bool = false
var _has_deck_layout: bool = false
var _presentation_surface_id: StringName = &""
var _presentation_cell_origin: Vector2i = Vector2i(-1, -1)
var _presentation_quarter_turns: int = 0
var _presentation_stack_group_id: String = ""
var _presentation_stack_index: int = -1
var _remaining_in_batch: bool = true

var entry_id: String:
	set(_value):
		pass
	get:
		return _entry_id
var item_instance_id: String:
	set(_value):
		pass
	get:
		return _item_instance_id
var definition_id: StringName:
	set(_value):
		pass
	get:
		return _definition_id
var frozen_transform: Transform3D:
	set(_value):
		pass
	get:
		return _frozen_transform
var has_frozen_transform: bool:
	set(_value):
		pass
	get:
		return _has_frozen_transform
var has_deck_layout: bool:
	set(_value):
		pass
	get:
		return _has_deck_layout
var presentation_surface_id: StringName:
	set(_value):
		pass
	get:
		return _presentation_surface_id
var presentation_cell_origin: Vector2i:
	set(_value):
		pass
	get:
		return _presentation_cell_origin
var presentation_quarter_turns: int:
	set(_value):
		pass
	get:
		return _presentation_quarter_turns
var presentation_stack_group_id: String:
	set(_value):
		pass
	get:
		return _presentation_stack_group_id
var presentation_stack_index: int:
	set(_value):
		pass
	get:
		return _presentation_stack_index
var remaining_in_batch: bool:
	set(_value):
		pass
	get:
		return _remaining_in_batch


func _init(
	new_entry_id: String = "",
	new_item_instance_id: String = "",
	new_definition_id: StringName = &""
) -> void:
	_entry_id = new_entry_id
	_item_instance_id = new_item_instance_id
	_definition_id = new_definition_id


func to_snapshot() -> Dictionary:
	return {
		"entry_id": _entry_id,
		"item_instance_id": _item_instance_id,
		"definition_id": _definition_id,
		"frozen_transform": _frozen_transform,
		"has_frozen_transform": _has_frozen_transform,
		"has_deck_layout": _has_deck_layout,
		"presentation_surface_id": _presentation_surface_id,
		"presentation_cell_origin": _presentation_cell_origin,
		"presentation_quarter_turns": _presentation_quarter_turns,
		"presentation_stack_group_id": _presentation_stack_group_id,
		"presentation_stack_index": _presentation_stack_index,
		"remaining_in_batch": _remaining_in_batch,
	}


static func from_snapshot(snapshot: Dictionary) -> LootBatchEntry:
	if not _has_valid_snapshot_fields(snapshot):
		return null
	var entry: LootBatchEntry = LootBatchEntry.new(
		String(snapshot["entry_id"]),
		String(snapshot["item_instance_id"]),
		StringName(snapshot["definition_id"])
	)
	entry._restore_presentation_state(
		snapshot["frozen_transform"] as Transform3D,
		bool(snapshot["has_frozen_transform"]),
		bool(snapshot["remaining_in_batch"]),
		bool(snapshot.get("has_deck_layout", false)),
		StringName(snapshot.get("presentation_surface_id", &"")),
		snapshot.get("presentation_cell_origin", Vector2i(-1, -1)) as Vector2i,
		int(snapshot.get("presentation_quarter_turns", 0)),
		String(snapshot.get("presentation_stack_group_id", "")),
		int(snapshot.get("presentation_stack_index", -1))
	)
	return entry


func _commit_frozen_transform(value: Transform3D) -> void:
	_frozen_transform = value
	_has_frozen_transform = true


func _commit_deck_layout(
	surface_id: StringName,
	cell_origin: Vector2i,
	quarter_turns: int,
	stack_group_id: String,
	stack_index: int,
	value: Transform3D
) -> void:
	_presentation_surface_id = surface_id
	_presentation_cell_origin = cell_origin
	_presentation_quarter_turns = quarter_turns
	_presentation_stack_group_id = stack_group_id
	_presentation_stack_index = stack_index
	_has_deck_layout = true
	_commit_frozen_transform(value)


func _mark_released() -> void:
	_remaining_in_batch = false


func _restore_presentation_state(
	restored_transform: Transform3D,
	restored_has_transform: bool,
	restored_remaining: bool,
	restored_has_deck_layout: bool = false,
	restored_surface_id: StringName = &"",
	restored_cell_origin: Vector2i = Vector2i(-1, -1),
	restored_quarter_turns: int = 0,
	restored_stack_group_id: String = "",
	restored_stack_index: int = -1
) -> void:
	_frozen_transform = restored_transform
	_has_frozen_transform = restored_has_transform
	_remaining_in_batch = restored_remaining
	_has_deck_layout = restored_has_deck_layout
	_presentation_surface_id = restored_surface_id
	_presentation_cell_origin = restored_cell_origin
	_presentation_quarter_turns = restored_quarter_turns
	_presentation_stack_group_id = restored_stack_group_id
	_presentation_stack_index = restored_stack_index


static func _has_valid_snapshot_fields(snapshot: Dictionary) -> bool:
	if typeof(snapshot.get("entry_id")) != TYPE_STRING:
		return false
	if typeof(snapshot.get("item_instance_id")) != TYPE_STRING:
		return false
	var definition_value: Variant = snapshot.get("definition_id")
	if typeof(definition_value) != TYPE_STRING_NAME and typeof(definition_value) != TYPE_STRING:
		return false
	if typeof(snapshot.get("frozen_transform")) != TYPE_TRANSFORM3D:
		return false
	if typeof(snapshot.get("has_frozen_transform")) != TYPE_BOOL:
		return false
	if typeof(snapshot.get("remaining_in_batch")) != TYPE_BOOL:
		return false
	var transform: Transform3D = snapshot["frozen_transform"] as Transform3D
	if not _is_finite_transform(transform):
		return false

	var has_layout_value: Variant = snapshot.get("has_deck_layout", false)
	var surface_value: Variant = snapshot.get("presentation_surface_id", &"")
	var cell_value: Variant = snapshot.get("presentation_cell_origin", Vector2i(-1, -1))
	var quarter_turns_value: Variant = snapshot.get("presentation_quarter_turns", 0)
	var group_value: Variant = snapshot.get("presentation_stack_group_id", "")
	var stack_index_value: Variant = snapshot.get("presentation_stack_index", -1)
	if typeof(has_layout_value) != TYPE_BOOL:
		return false
	if typeof(surface_value) != TYPE_STRING_NAME and typeof(surface_value) != TYPE_STRING:
		return false
	if typeof(cell_value) != TYPE_VECTOR2I:
		return false
	if typeof(quarter_turns_value) != TYPE_INT:
		return false
	if typeof(group_value) != TYPE_STRING:
		return false
	if typeof(stack_index_value) != TYPE_INT:
		return false

	var has_layout: bool = bool(has_layout_value)
	var surface_id := StringName(surface_value)
	var cell_origin: Vector2i = cell_value as Vector2i
	var quarter_turns := int(quarter_turns_value)
	var stack_group_id := String(group_value)
	var stack_index := int(stack_index_value)
	if has_layout:
		return (
			restored_layout_values_are_valid(
				surface_id, cell_origin, quarter_turns, stack_group_id, stack_index
			)
			and bool(snapshot["has_frozen_transform"])
		)
	return (
		surface_id == &""
		and cell_origin == Vector2i(-1, -1)
		and quarter_turns == 0
		and stack_group_id.is_empty()
		and stack_index == -1
	)


static func restored_layout_values_are_valid(
	surface_id: StringName,
	cell_origin: Vector2i,
	quarter_turns: int,
	stack_group_id: String,
	stack_index: int
) -> bool:
	return (
		surface_id != &""
		and cell_origin.x >= 0
		and cell_origin.y >= 0
		and quarter_turns >= 0
		and quarter_turns <= 3
		and not stack_group_id.is_empty()
		and stack_index >= 0
	)


static func _is_finite_transform(value: Transform3D) -> bool:
	return (
		value.origin.is_finite()
		and value.basis.x.is_finite()
		and value.basis.y.is_finite()
		and value.basis.z.is_finite()
	)
