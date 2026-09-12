extends SceneTree

const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const ReceivingManagerScript = preload("res://receiving/receiving_manager.gd")

var _active_changed_ids: Array[String] = []
var _drained_ids: Array[String] = []
var _rejected_ids: Array[String] = []


# A runtime abort can return from a helper to its caller in Godot. Every
# test or fixture helper stays pending until its final statement is reached.
var _failures: int = 0
var _pending_helpers: int = 0


func _init() -> void:
	_run_suite()
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving manager tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving manager tests")
	quit(0)


func _run_suite() -> void:
	_pending_helpers += 1
	_test_only_prepared_batches_can_be_deposited()
	_test_drained_prepared_deposit_is_rejected_atomically()
	_test_prepared_batches_are_outside_manager_until_deposited()
	_test_three_slot_fifo_and_atomic_capacity_rejection()
	_test_duplicate_deposited_id_is_rejected()
	_test_only_active_matching_unreleased_entry_can_be_released()
	_test_draining_waits_for_close_before_fifo_promotion()
	_pending_helpers -= 1


func _prepared_batch(batch_id: String, entry_count: int = 1) -> LootBatch:
	_pending_helpers += 1
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
	_check(batch != null)
	_check(batch.commit_arrangement(transforms, &"synthetic_profile", 1))
	_pending_helpers -= 1
	return batch


func _committed_batch(batch_id: String) -> LootBatch:
	_pending_helpers += 1
	var entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new(
			"entry_0000", "%s:item_0000" % batch_id, &"loot_000001"
		),
	]
	var completed_result: LootBatch = LootBatchScript.create_committed(
		batch_id,
		&"synthetic_test",
		"receiving_manager_tests",
		1,
		1,
		101,
		201,
		entries
	)
	_pending_helpers -= 1
	return completed_result


func _manager() -> ReceivingManager:
	_pending_helpers += 1
	_active_changed_ids.clear()
	_drained_ids.clear()
	_rejected_ids.clear()
	var manager: ReceivingManager = ReceivingManagerScript.new()
	manager.active_batch_changed.connect(_on_active_batch_changed)
	manager.active_batch_drained.connect(_on_active_batch_drained)
	manager.deposit_rejected.connect(_on_deposit_rejected)
	var completed_result: ReceivingManager = manager
	_pending_helpers -= 1
	return completed_result


func _test_only_prepared_batches_can_be_deposited() -> void:
	_pending_helpers += 1
	var manager: ReceivingManager = _manager()
	var committed: LootBatch = _committed_batch("committed")
	_check(committed != null)
	_check(committed.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	_check(not manager.deposit_batch(committed))
	_check(manager.get_active_batch_id() == "")
	_check(manager.get_queued_batch_ids() == PackedStringArray())
	_check(manager.get_deposited_batch("committed") == null)
	_check(_rejected_ids == ["committed"])

	var empty_id_batch: LootBatch = LootBatchScript.new()
	_check(not manager.deposit_batch(empty_id_batch))
	_check(_rejected_ids == ["committed", ""])
	manager.free()
	_pending_helpers -= 1


# An exhausted restored batch cannot enter either an active or queued slot.
func _test_drained_prepared_deposit_is_rejected_atomically() -> void:
	_pending_helpers += 1
	var exhausted: LootBatch = _prepared_batch("drained", 2)
	for entry: LootBatchEntry in exhausted.entries:
		_check(exhausted.mark_entry_released(entry.entry_id, entry.item_instance_id))
	var exhausted_bytes: PackedByteArray = var_to_bytes(exhausted.to_snapshot())
	var restored: LootBatch = LootBatchScript.from_snapshot(bytes_to_var(exhausted_bytes) as Dictionary)
	_check(restored != null, "fully released PREPARED snapshot remains reconstructable")
	_check(restored.is_drained() and restored.preparation_state == LootBatchScript.STATE_PREPARED)
	_check(var_to_bytes(restored.to_snapshot()) == exhausted_bytes, "restored exhausted snapshot preserves all durable data")
	for occupied: bool in [false, true]:
		var manager: ReceivingManager = _manager()
		var active: LootBatch = _prepared_batch("active")
		var queued: LootBatch = _prepared_batch("queued")
		if occupied:
			_check(manager.deposit_batch(active))
			_check(manager.deposit_batch(queued))
		var batches: Array[LootBatch] = [active, queued, restored]
		var before: PackedByteArray = _ownership_snapshot(manager, batches)
		var changed_before: Array[String] = _active_changed_ids.duplicate()
		var drained_before: Array[String] = _drained_ids.duplicate()
		_check(not manager.deposit_batch(restored), "already-drained PREPARED deposit is rejected")
		_check(_ownership_snapshot(manager, batches) == before, "drained rejection preserves capacity, registrations and all batch data")
		_check(manager.get_active_batch() == (active if occupied else null), "rejection preserves active object")
		_check(manager.get_deposited_batch("queued") == (queued if occupied else null), "rejection preserves queued object")
		_check(manager.get_deposited_batch("drained") == null, "exhausted batch is not registered")
		_check(_active_changed_ids == changed_before and _drained_ids == drained_before, "rejection emits no active-change or drained event")
		_check(_rejected_ids == ["drained"], "exact rejection notification")
		manager.free()
	_pending_helpers -= 1


func _ownership_snapshot(manager: ReceivingManager, batches: Array[LootBatch]) -> PackedByteArray:
	_pending_helpers += 1
	var state: Dictionary = {"active": manager.get_active_batch_id(), "queue": manager.get_queued_batch_ids(), "batches": {}, "registered": {}}
	for batch: LootBatch in batches:
		state["batches"][batch.batch_id] = batch.to_snapshot()
		state["registered"][batch.batch_id] = manager.get_deposited_batch(batch.batch_id) != null
	var bytes: PackedByteArray = var_to_bytes(state)
	_pending_helpers -= 1
	return bytes


func _test_prepared_batches_are_outside_manager_until_deposited() -> void:
	_pending_helpers += 1
	var prepared: LootBatch = _prepared_batch("prepared_elsewhere")
	var manager: ReceivingManager = _manager()
	_check(prepared.preparation_state == LootBatchScript.STATE_PREPARED)
	_check(manager.get_active_batch_id() == "")
	_check(manager.get_active_batch() == null)
	_check(manager.get_queued_batch_ids() == PackedStringArray())
	_check(manager.get_deposited_batch("prepared_elsewhere") == null)
	manager.free()
	_pending_helpers -= 1


func _test_three_slot_fifo_and_atomic_capacity_rejection() -> void:
	_pending_helpers += 1
	var manager: ReceivingManager = _manager()
	var first: LootBatch = _prepared_batch("batch_first")
	var second: LootBatch = _prepared_batch("batch_second")
	var third: LootBatch = _prepared_batch("batch_third")
	var fourth: LootBatch = _prepared_batch("batch_fourth")

	_check(manager.deposit_batch(first))
	_check(manager.get_active_batch_id() == "batch_first")
	_check(manager.get_active_batch() == first)
	_check(manager.get_queued_batch_ids() == PackedStringArray())
	_check(_active_changed_ids == ["batch_first"])

	_check(manager.deposit_batch(second))
	_check(manager.deposit_batch(third))
	_check(manager.get_queued_batch_ids() == PackedStringArray([
		"batch_second", "batch_third"
	]))
	_check(manager.get_deposited_batch("batch_second") == second)
	_check(manager.get_deposited_batch("batch_third") == third)

	var state_before: PackedByteArray = var_to_bytes({
		"active": manager.get_active_batch_id(),
		"queued": manager.get_queued_batch_ids(),
	})
	_check(not manager.deposit_batch(fourth))
	var state_after: PackedByteArray = var_to_bytes({
		"active": manager.get_active_batch_id(),
		"queued": manager.get_queued_batch_ids(),
	})
	_check(state_after == state_before)
	_check(manager.get_deposited_batch("batch_first") == first)
	_check(manager.get_deposited_batch("batch_second") == second)
	_check(manager.get_deposited_batch("batch_third") == third)
	_check(manager.get_deposited_batch("batch_fourth") == null)
	_check(_rejected_ids == ["batch_fourth"])
	manager.free()
	_pending_helpers -= 1


func _test_duplicate_deposited_id_is_rejected() -> void:
	_pending_helpers += 1
	var manager: ReceivingManager = _manager()
	var deposited: LootBatch = _prepared_batch("duplicate")
	var same_id: LootBatch = _prepared_batch("duplicate")
	_check(manager.deposit_batch(deposited))
	var state_before: PackedByteArray = var_to_bytes({
		"active": manager.get_active_batch_id(),
		"queued": manager.get_queued_batch_ids(),
	})
	_check(not manager.deposit_batch(same_id))
	_check(var_to_bytes({
		"active": manager.get_active_batch_id(),
		"queued": manager.get_queued_batch_ids(),
	}) == state_before)
	_check(manager.get_deposited_batch("duplicate") == deposited)
	_check(_rejected_ids == ["duplicate"])
	manager.free()
	_pending_helpers -= 1


func _test_only_active_matching_unreleased_entry_can_be_released() -> void:
	_pending_helpers += 1
	var manager: ReceivingManager = _manager()
	var active: LootBatch = _prepared_batch("active", 2)
	var queued: LootBatch = _prepared_batch("queued")
	_check(manager.deposit_batch(active))
	_check(manager.deposit_batch(queued))

	_check(not manager.release_entry("queued", "entry_0000", "queued:item_0000"))
	_check(not manager.release_entry("active", "unknown", "active:item_0000"))
	_check(not manager.release_entry("active", "entry_0000", "active:item_0001"))
	_check(manager.release_entry("active", "entry_0000", "active:item_0000"))
	_check(not manager.release_entry("active", "entry_0000", "active:item_0000"))
	_check(not active.entries[0].remaining_in_batch)
	_check(active.entries[1].remaining_in_batch)
	_check(_drained_ids.is_empty())
	manager.free()
	_pending_helpers -= 1


func _test_draining_waits_for_close_before_fifo_promotion() -> void:
	_pending_helpers += 1
	var manager: ReceivingManager = _manager()
	var first: LootBatch = _prepared_batch("batch_first")
	var second: LootBatch = _prepared_batch("batch_second")
	var third: LootBatch = _prepared_batch("batch_third")
	_check(manager.deposit_batch(first))
	_check(manager.deposit_batch(second))
	_check(manager.deposit_batch(third))

	_check(manager.retire_drained_active_after_close() == "")
	_check(manager.release_entry("batch_first", "entry_0000", "batch_first:item_0000"))
	_check(_drained_ids == ["batch_first"])
	_check(manager.get_active_batch_id() == "batch_first")
	_check(manager.get_queued_batch_ids() == PackedStringArray([
		"batch_second", "batch_third"
	]))
	_check(not manager.release_entry(
		"batch_first", "entry_0000", "batch_first:item_0000"
	))
	_check(_drained_ids == ["batch_first"])

	_check(manager.retire_drained_active_after_close() == "batch_second")
	_check(manager.get_deposited_batch("batch_first") == null)
	_check(manager.get_active_batch_id() == "batch_second")
	_check(manager.get_queued_batch_ids() == PackedStringArray(["batch_third"]))
	_check(_active_changed_ids == ["batch_first", "batch_second"])

	_check(manager.release_entry(
		"batch_second", "entry_0000", "batch_second:item_0000"
	))
	_check(manager.retire_drained_active_after_close() == "batch_third")
	_check(manager.get_deposited_batch("batch_second") == null)
	_check(manager.get_active_batch_id() == "batch_third")
	_check(manager.get_queued_batch_ids() == PackedStringArray())
	_check(_active_changed_ids == ["batch_first", "batch_second", "batch_third"])
	manager.free()
	_pending_helpers -= 1


func _on_active_batch_changed(batch_id: String) -> void:
	_pending_helpers += 1
	_active_changed_ids.append(batch_id)
	_pending_helpers -= 1


func _on_active_batch_drained(batch_id: String) -> void:
	_pending_helpers += 1
	_drained_ids.append(batch_id)
	_pending_helpers -= 1


func _on_deposit_rejected(batch_id: String) -> void:
	_pending_helpers += 1
	_rejected_ids.append(batch_id)
	_pending_helpers -= 1


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition
