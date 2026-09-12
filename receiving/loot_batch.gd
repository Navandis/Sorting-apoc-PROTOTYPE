extends RefCounted
class_name LootBatch

const ItemInstanceScript = preload("res://item_instance.gd")
const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")

const STATE_CONTENT_COMMITTED: StringName = &"CONTENT_COMMITTED"
const STATE_PREPARED: StringName = &"PREPARED"

var batch_id: String = ""
var source_kind: StringName = &""
var source_ref: String = ""
var target_bulk: int = 0
var actual_bulk: int = 0
var content_seed: int = 0
var presentation_seed: int = 0
var preparation_state: StringName = STATE_CONTENT_COMMITTED
var presentation_profile_id: StringName = &""
var presentation_profile_revision: int = 0
var entries: Array[LootBatchEntry] = []


static func create_committed(
	new_batch_id: String,
	new_source_kind: StringName,
	new_source_ref: String,
	new_target_bulk: int,
	new_actual_bulk: int,
	new_content_seed: int,
	new_presentation_seed: int,
	new_entries: Array[LootBatchEntry]
) -> LootBatch:
	if not _has_valid_content(
		new_batch_id, new_target_bulk, new_actual_bulk, new_entries
	):
		return null
	var batch: LootBatch = LootBatch.new()
	batch.batch_id = new_batch_id
	batch.source_kind = new_source_kind
	batch.source_ref = new_source_ref
	batch.target_bulk = new_target_bulk
	batch.actual_bulk = new_actual_bulk
	batch.content_seed = new_content_seed
	batch.presentation_seed = new_presentation_seed
	batch.preparation_state = STATE_CONTENT_COMMITTED
	batch.entries = new_entries.duplicate()
	return batch


func commit_arrangement(
	transforms_by_entry_id: Dictionary,
	profile_id: StringName,
	profile_revision: int
) -> bool:
	if preparation_state != STATE_CONTENT_COMMITTED:
		return false
	if profile_id == &"" or profile_revision <= 0:
		return false

	var remaining_count: int = 0
	var remaining_by_id: Dictionary = {}
	for entry: LootBatchEntry in entries:
		if entry.remaining_in_batch:
			remaining_count += 1
			remaining_by_id[entry.entry_id] = entry
	if transforms_by_entry_id.size() != remaining_count:
		return false

	var validated_transforms: Dictionary = {}
	for key_value: Variant in transforms_by_entry_id:
		if typeof(key_value) != TYPE_STRING and typeof(key_value) != TYPE_STRING_NAME:
			return false
		var entry_id: String = String(key_value)
		if not remaining_by_id.has(entry_id):
			return false
		var transform_value: Variant = transforms_by_entry_id[key_value]
		if typeof(transform_value) != TYPE_TRANSFORM3D:
			return false
		var transform: Transform3D = transform_value as Transform3D
		if not _is_finite_transform(transform):
			return false
		validated_transforms[entry_id] = transform
	if validated_transforms.size() != remaining_count:
		return false

	for entry: LootBatchEntry in entries:
		if not entry.remaining_in_batch:
			continue
		entry.frozen_transform = validated_transforms[entry.entry_id] as Transform3D
		entry.has_frozen_transform = true
	presentation_profile_id = profile_id
	presentation_profile_revision = profile_revision
	preparation_state = STATE_PREPARED
	return true


func create_item_instance(entry_id: String, catalog: ItemCatalog) -> ItemInstance:
	if catalog == null:
		return null
	var entry: LootBatchEntry = _find_entry(entry_id)
	if entry == null:
		return null
	var definition: ItemDefinition = catalog.get_definition_by_id(entry.definition_id)
	if definition == null:
		return null
	return ItemInstanceScript.new(definition, entry.item_instance_id)


func mark_entry_released(entry_id: String, item_instance_id: String) -> bool:
	var entry: LootBatchEntry = _find_entry(entry_id)
	if entry == null:
		return false
	if entry.item_instance_id != item_instance_id or not entry.remaining_in_batch:
		return false
	entry.remaining_in_batch = false
	return true


func is_drained() -> bool:
	for entry: LootBatchEntry in entries:
		if entry.remaining_in_batch:
			return false
	return true


func to_snapshot() -> Dictionary:
	var entry_snapshots: Array[Dictionary] = []
	for entry: LootBatchEntry in entries:
		entry_snapshots.append(entry.to_snapshot())
	return {
		"batch_id": batch_id,
		"source_kind": source_kind,
		"source_ref": source_ref,
		"target_bulk": target_bulk,
		"actual_bulk": actual_bulk,
		"content_seed": content_seed,
		"presentation_seed": presentation_seed,
		"preparation_state": preparation_state,
		"presentation_profile_id": presentation_profile_id,
		"presentation_profile_revision": presentation_profile_revision,
		"entries": entry_snapshots,
	}


static func from_snapshot(snapshot: Dictionary) -> LootBatch:
	if not _has_valid_batch_snapshot_fields(snapshot):
		return null

	var restored_entries: Array[LootBatchEntry] = []
	var entry_values: Array = snapshot["entries"] as Array
	for entry_value: Variant in entry_values:
		if typeof(entry_value) != TYPE_DICTIONARY:
			return null
		var entry: LootBatchEntry = LootBatchEntryScript.from_snapshot(
			entry_value as Dictionary
		)
		if entry == null:
			return null
		restored_entries.append(entry)

	var restored: LootBatch = create_committed(
		String(snapshot["batch_id"]),
		StringName(snapshot["source_kind"]),
		String(snapshot["source_ref"]),
		int(snapshot["target_bulk"]),
		int(snapshot["actual_bulk"]),
		int(snapshot["content_seed"]),
		int(snapshot["presentation_seed"]),
		restored_entries
	)
	if restored == null:
		return null

	var restored_state: StringName = StringName(snapshot["preparation_state"])
	var restored_profile_id: StringName = StringName(snapshot["presentation_profile_id"])
	var restored_profile_revision: int = int(snapshot["presentation_profile_revision"])
	if not _has_consistent_preparation_snapshot(
		restored_state, restored_profile_id, restored_profile_revision, restored_entries
	):
		return null
	restored.preparation_state = restored_state
	restored.presentation_profile_id = restored_profile_id
	restored.presentation_profile_revision = restored_profile_revision
	return restored


func _find_entry(wanted_entry_id: String) -> LootBatchEntry:
	for entry: LootBatchEntry in entries:
		if entry.entry_id == wanted_entry_id:
			return entry
	return null


static func _has_valid_content(
	wanted_batch_id: String,
	wanted_target_bulk: int,
	wanted_actual_bulk: int,
	wanted_entries: Array[LootBatchEntry]
) -> bool:
	if wanted_batch_id.is_empty() or wanted_target_bulk <= 0 or wanted_actual_bulk <= 0:
		return false
	var entry_ids: Dictionary = {}
	var item_ids: Dictionary = {}
	for entry: LootBatchEntry in wanted_entries:
		if entry == null:
			return false
		if entry.entry_id.is_empty() or entry_ids.has(entry.entry_id):
			return false
		if entry.item_instance_id.is_empty() or item_ids.has(entry.item_instance_id):
			return false
		if entry.definition_id == &"":
			return false
		entry_ids[entry.entry_id] = true
		item_ids[entry.item_instance_id] = true
	return true


static func _has_valid_batch_snapshot_fields(snapshot: Dictionary) -> bool:
	if typeof(snapshot.get("batch_id")) != TYPE_STRING:
		return false
	var source_kind_value: Variant = snapshot.get("source_kind")
	if typeof(source_kind_value) != TYPE_STRING_NAME and typeof(source_kind_value) != TYPE_STRING:
		return false
	if typeof(snapshot.get("source_ref")) != TYPE_STRING:
		return false
	if typeof(snapshot.get("target_bulk")) != TYPE_INT:
		return false
	if typeof(snapshot.get("actual_bulk")) != TYPE_INT:
		return false
	if typeof(snapshot.get("content_seed")) != TYPE_INT:
		return false
	if typeof(snapshot.get("presentation_seed")) != TYPE_INT:
		return false
	var state_value: Variant = snapshot.get("preparation_state")
	if typeof(state_value) != TYPE_STRING_NAME and typeof(state_value) != TYPE_STRING:
		return false
	var profile_id_value: Variant = snapshot.get("presentation_profile_id")
	if typeof(profile_id_value) != TYPE_STRING_NAME and typeof(profile_id_value) != TYPE_STRING:
		return false
	if typeof(snapshot.get("presentation_profile_revision")) != TYPE_INT:
		return false
	return typeof(snapshot.get("entries")) == TYPE_ARRAY


static func _has_consistent_preparation_snapshot(
	state: StringName,
	profile_id: StringName,
	profile_revision: int,
	restored_entries: Array[LootBatchEntry]
) -> bool:
	if state == STATE_CONTENT_COMMITTED:
		if profile_id != &"" or profile_revision != 0:
			return false
		for entry: LootBatchEntry in restored_entries:
			if entry.has_frozen_transform:
				return false
		return true
	if state != STATE_PREPARED or profile_id == &"" or profile_revision <= 0:
		return false
	for entry: LootBatchEntry in restored_entries:
		if entry.remaining_in_batch and not entry.has_frozen_transform:
			return false
	return true


static func _is_finite_transform(value: Transform3D) -> bool:
	return (
		value.origin.is_finite()
		and value.basis.x.is_finite()
		and value.basis.y.is_finite()
		and value.basis.z.is_finite()
	)
