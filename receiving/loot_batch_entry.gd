extends RefCounted
class_name LootBatchEntry

var _entry_id: String = ""
var _item_instance_id: String = ""
var _definition_id: StringName = &""
var _frozen_transform: Transform3D = Transform3D.IDENTITY
var _has_frozen_transform: bool = false
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
		bool(snapshot["remaining_in_batch"])
	)
	return entry


func _commit_frozen_transform(value: Transform3D) -> void:
	_frozen_transform = value
	_has_frozen_transform = true


func _mark_released() -> void:
	_remaining_in_batch = false


func _restore_presentation_state(
	restored_transform: Transform3D,
	restored_has_transform: bool,
	restored_remaining: bool
) -> void:
	_frozen_transform = restored_transform
	_has_frozen_transform = restored_has_transform
	_remaining_in_batch = restored_remaining


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
	return _is_finite_transform(transform)


static func _is_finite_transform(value: Transform3D) -> bool:
	return (
		value.origin.is_finite()
		and value.basis.x.is_finite()
		and value.basis.y.is_finite()
		and value.basis.z.is_finite()
	)
