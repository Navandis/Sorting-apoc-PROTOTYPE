extends SceneTree

const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const ReceivingManagerScript = preload("res://receiving/receiving_manager.gd")

var _active_changed_ids: Array[String] = []
var _drained_ids: Array[String] = []
var _rejected_ids: Array[String] = []


func _init() -> void:
	_test_only_prepared_batches_can_be_deposited()
	_test_prepared_batches_are_outside_manager_until_deposited()
	_test_three_slot_fifo_and_atomic_capacity_rejection()
	_test_duplicate_deposited_id_is_rejected()
	_test_only_active_matching_unreleased_entry_can_be_released()
	_test_draining_waits_for_close_before_fifo_promotion()
	print("PASS: receiving manager tests")
	quit(0)


func _prepared_batch(batch_id: String, entry_count: int = 1) -> LootBatch:
	var entries: Array[LootBatchEntry] = []
	var transforms: Dictionary = {}
	for index: int in range(entry_count):
		var entry_id: String = "entry_%04d" % index
		entries.append(LootBatchEntryScript.new(
			entry_id,
			"%s:item_%04d" % [batch_id, index],
			StringName("loot_%06d" % (index + 1))
		))
		transforms[entry_id] = Transform3D(
			Basis.IDENTITY,
			Vector3(float(index), 0.0, 0.0)
		)
	var batch: LootBatch = LootBatchScript.create_committed(
		batch_id,
		&"synthetic_test",
		"receiving_manager_tests",
		entry_count,
		entry_count,
		100 + entry_count,
		200 + entry_count,
		entries
	)
	assert(batch != null)
	assert(batch.commit_arrangement(transforms, &"synthetic_profile", 1))
	return batch


func _committed_batch(batch_id: String) -> LootBatch:
	var entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new(
			"entry_0000", "%s:item_0000" % batch_id, &"loot_000001"
		),
	]
	return LootBatchScript.create_committed(
		batch_id,
		&"synthetic_test",
		"receiving_manager_tests",
		1,
		1,
		101,
		201,
		entries
	)


func _manager() -> ReceivingManager:
	_active_changed_ids.clear()
	_drained_ids.clear()
	_rejected_ids.clear()
	var manager: ReceivingManager = ReceivingManagerScript.new()
	manager.active_batch_changed.connect(_on_active_batch_changed)
	manager.active_batch_drained.connect(_on_active_batch_drained)
	manager.deposit_rejected.connect(_on_deposit_rejected)
	return manager


func _test_only_prepared_batches_can_be_deposited() -> void:
	var manager: ReceivingManager = _manager()
	var committed: LootBatch = _committed_batch("committed")
	assert(committed != null)
	assert(committed.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	assert(not manager.deposit_batch(committed))
	assert(manager.get_active_batch_id() == "")
	assert(manager.get_queued_batch_ids() == PackedStringArray())
	assert(manager.get_deposited_batch("committed") == null)
	assert(_rejected_ids == ["committed"])

	var empty_id_batch: LootBatch = LootBatchScript.new()
	assert(not manager.deposit_batch(empty_id_batch))
	assert(_rejected_ids == ["committed", ""])
	manager.free()


func _test_prepared_batches_are_outside_manager_until_deposited() -> void:
	var prepared: LootBatch = _prepared_batch("prepared_elsewhere")
	var manager: ReceivingManager = _manager()
	assert(prepared.preparation_state == LootBatchScript.STATE_PREPARED)
	assert(manager.get_active_batch_id() == "")
	assert(manager.get_active_batch() == null)
	assert(manager.get_queued_batch_ids() == PackedStringArray())
	assert(manager.get_deposited_batch("prepared_elsewhere") == null)
	manager.free()


func _test_three_slot_fifo_and_atomic_capacity_rejection() -> void:
	var manager: ReceivingManager = _manager()
	var first: LootBatch = _prepared_batch("batch_first")
	var second: LootBatch = _prepared_batch("batch_second")
	var third: LootBatch = _prepared_batch("batch_third")
	var fourth: LootBatch = _prepared_batch("batch_fourth")

	assert(manager.deposit_batch(first))
	assert(manager.get_active_batch_id() == "batch_first")
	assert(manager.get_active_batch() == first)
	assert(manager.get_queued_batch_ids() == PackedStringArray())
	assert(_active_changed_ids == ["batch_first"])

	assert(manager.deposit_batch(second))
	assert(manager.deposit_batch(third))
	assert(manager.get_queued_batch_ids() == PackedStringArray([
		"batch_second", "batch_third"
	]))
	assert(manager.get_deposited_batch("batch_second") == second)
	assert(manager.get_deposited_batch("batch_third") == third)

	var state_before: PackedByteArray = var_to_bytes({
		"active": manager.get_active_batch_id(),
		"queued": manager.get_queued_batch_ids(),
	})
	assert(not manager.deposit_batch(fourth))
	var state_after: PackedByteArray = var_to_bytes({
		"active": manager.get_active_batch_id(),
		"queued": manager.get_queued_batch_ids(),
	})
	assert(state_after == state_before)
	assert(manager.get_deposited_batch("batch_first") == first)
	assert(manager.get_deposited_batch("batch_second") == second)
	assert(manager.get_deposited_batch("batch_third") == third)
	assert(manager.get_deposited_batch("batch_fourth") == null)
	assert(_rejected_ids == ["batch_fourth"])
	manager.free()


func _test_duplicate_deposited_id_is_rejected() -> void:
	var manager: ReceivingManager = _manager()
	var deposited: LootBatch = _prepared_batch("duplicate")
	var same_id: LootBatch = _prepared_batch("duplicate")
	assert(manager.deposit_batch(deposited))
	var state_before: PackedByteArray = var_to_bytes({
		"active": manager.get_active_batch_id(),
		"queued": manager.get_queued_batch_ids(),
	})
	assert(not manager.deposit_batch(same_id))
	assert(var_to_bytes({
		"active": manager.get_active_batch_id(),
		"queued": manager.get_queued_batch_ids(),
	}) == state_before)
	assert(manager.get_deposited_batch("duplicate") == deposited)
	assert(_rejected_ids == ["duplicate"])
	manager.free()


func _test_only_active_matching_unreleased_entry_can_be_released() -> void:
	var manager: ReceivingManager = _manager()
	var active: LootBatch = _prepared_batch("active", 2)
	var queued: LootBatch = _prepared_batch("queued")
	assert(manager.deposit_batch(active))
	assert(manager.deposit_batch(queued))

	assert(not manager.release_entry("queued", "entry_0000", "queued:item_0000"))
	assert(not manager.release_entry("active", "unknown", "active:item_0000"))
	assert(not manager.release_entry("active", "entry_0000", "active:item_0001"))
	assert(manager.release_entry("active", "entry_0000", "active:item_0000"))
	assert(not manager.release_entry("active", "entry_0000", "active:item_0000"))
	assert(not active.entries[0].remaining_in_batch)
	assert(active.entries[1].remaining_in_batch)
	assert(_drained_ids.is_empty())
	manager.free()


func _test_draining_waits_for_close_before_fifo_promotion() -> void:
	var manager: ReceivingManager = _manager()
	var first: LootBatch = _prepared_batch("batch_first")
	var second: LootBatch = _prepared_batch("batch_second")
	var third: LootBatch = _prepared_batch("batch_third")
	assert(manager.deposit_batch(first))
	assert(manager.deposit_batch(second))
	assert(manager.deposit_batch(third))

	assert(manager.retire_drained_active_after_close() == "")
	assert(manager.release_entry("batch_first", "entry_0000", "batch_first:item_0000"))
	assert(_drained_ids == ["batch_first"])
	assert(manager.get_active_batch_id() == "batch_first")
	assert(manager.get_queued_batch_ids() == PackedStringArray([
		"batch_second", "batch_third"
	]))
	assert(not manager.release_entry(
		"batch_first", "entry_0000", "batch_first:item_0000"
	))
	assert(_drained_ids == ["batch_first"])

	assert(manager.retire_drained_active_after_close() == "batch_second")
	assert(manager.get_deposited_batch("batch_first") == null)
	assert(manager.get_active_batch_id() == "batch_second")
	assert(manager.get_queued_batch_ids() == PackedStringArray(["batch_third"]))
	assert(_active_changed_ids == ["batch_first", "batch_second"])

	assert(manager.release_entry(
		"batch_second", "entry_0000", "batch_second:item_0000"
	))
	assert(manager.retire_drained_active_after_close() == "batch_third")
	assert(manager.get_deposited_batch("batch_second") == null)
	assert(manager.get_active_batch_id() == "batch_third")
	assert(manager.get_queued_batch_ids() == PackedStringArray())
	assert(_active_changed_ids == ["batch_first", "batch_second", "batch_third"])
	manager.free()


func _on_active_batch_changed(batch_id: String) -> void:
	_active_changed_ids.append(batch_id)


func _on_active_batch_drained(batch_id: String) -> void:
	_drained_ids.append(batch_id)


func _on_deposit_rejected(batch_id: String) -> void:
	_rejected_ids.append(batch_id)
