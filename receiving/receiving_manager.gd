extends Node
class_name ReceivingManager

const MAX_QUEUED_BATCHES: int = 2

signal active_batch_changed(batch_id: String)
signal active_batch_drained(batch_id: String)
signal deposit_rejected(batch_id: String)

var _active_batch_id: String = ""
var _queued_batch_ids: Array[String] = []
var _deposited_batches: Dictionary = {}


func deposit_batch(batch: LootBatch) -> bool:
	var rejected_batch_id: String = "" if batch == null else batch.batch_id
	if (
		batch == null
		or batch.preparation_state != LootBatch.STATE_PREPARED
		or batch.is_drained()
		or batch.batch_id.is_empty()
		or _deposited_batches.has(batch.batch_id)
		or (
			not _active_batch_id.is_empty()
			and _queued_batch_ids.size() >= MAX_QUEUED_BATCHES
		)
	):
		deposit_rejected.emit(rejected_batch_id)
		return false

	_deposited_batches[batch.batch_id] = batch
	if _active_batch_id.is_empty():
		_active_batch_id = batch.batch_id
		active_batch_changed.emit(_active_batch_id)
	else:
		_queued_batch_ids.append(batch.batch_id)
	return true


func get_active_batch_id() -> String:
	return _active_batch_id


func get_queued_batch_ids() -> PackedStringArray:
	return PackedStringArray(_queued_batch_ids)


func get_active_batch() -> LootBatch:
	return get_deposited_batch(_active_batch_id)


func get_deposited_batch(batch_id: String) -> LootBatch:
	if not _deposited_batches.has(batch_id):
		return null
	return _deposited_batches[batch_id] as LootBatch


func release_entry(batch_id: String, entry_id: String, item_instance_id: String) -> bool:
	if batch_id != _active_batch_id:
		return false
	var active_batch: LootBatch = get_active_batch()
	if active_batch == null:
		return false
	if not active_batch.mark_entry_released(entry_id, item_instance_id):
		return false
	if active_batch.is_drained():
		active_batch_drained.emit(batch_id)
	return true


func retire_drained_active_after_close() -> String:
	var active_batch: LootBatch = get_active_batch()
	if active_batch == null or not active_batch.is_drained():
		return ""

	_deposited_batches.erase(_active_batch_id)
	_active_batch_id = ""
	if not _queued_batch_ids.is_empty():
		_active_batch_id = _queued_batch_ids[0]
		_queued_batch_ids.remove_at(0)
	active_batch_changed.emit(_active_batch_id)
	return _active_batch_id
