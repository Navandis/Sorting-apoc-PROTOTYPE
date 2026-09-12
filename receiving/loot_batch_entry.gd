extends RefCounted
class_name LootBatchEntry

var entry_id: String = ""
var item_instance_id: String = ""
var definition_id: StringName = &""
var frozen_transform: Transform3D = Transform3D.IDENTITY
var has_frozen_transform: bool = false
var remaining_in_batch: bool = true


func _init(
	new_entry_id: String = "",
	new_item_instance_id: String = "",
	new_definition_id: StringName = &""
) -> void:
	entry_id = new_entry_id
	item_instance_id = new_item_instance_id
	definition_id = new_definition_id


func to_snapshot() -> Dictionary:
	return {
		"entry_id": entry_id,
		"item_instance_id": item_instance_id,
		"definition_id": definition_id,
		"frozen_transform": frozen_transform,
		"has_frozen_transform": has_frozen_transform,
		"remaining_in_batch": remaining_in_batch,
	}


static func from_snapshot(snapshot: Dictionary) -> LootBatchEntry:
	if not _has_valid_snapshot_fields(snapshot):
		return null
	var entry: LootBatchEntry = LootBatchEntry.new(
		String(snapshot["entry_id"]),
		String(snapshot["item_instance_id"]),
		StringName(snapshot["definition_id"])
	)
	entry.frozen_transform = snapshot["frozen_transform"] as Transform3D
	entry.has_frozen_transform = bool(snapshot["has_frozen_transform"])
	entry.remaining_in_batch = bool(snapshot["remaining_in_batch"])
	return entry


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
