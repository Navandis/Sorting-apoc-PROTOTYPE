extends SceneTree

const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")

var _abort_requested: bool = false


func _init() -> void:
	_test_committed_content_is_immutable_from_arrangement_retries()
	_test_arrangement_commit_is_atomic()
	_test_snapshot_round_trip_preserves_identity_state_and_transform()
	_test_item_instance_reconstruction_preserves_durable_identity()
	_test_release_requires_matching_entry_and_identity()
	_test_drained_state_tracks_release_accounting()
	if _abort_requested:
		return
	_test_malformed_committed_content_is_rejected()
	_test_malformed_snapshots_are_rejected()
	_test_arrangement_rejects_non_finite_transforms_atomically()
	print("PASS: receiving loot batch tests")
	quit(0)


func _entries() -> Array[LootBatchEntry]:
	return [
		LootBatchEntryScript.new("entry_0000", "batch_a:item_0000", &"loot_000001"),
		LootBatchEntryScript.new("entry_0001", "batch_a:item_0001", &"loot_000002"),
	]


func _batch() -> LootBatch:
	return LootBatchScript.create_committed(
		"batch_a",
		&"prototype",
		"prototype_receiving_pool:1",
		5,
		6,
		1842,
		9001,
		_entries()
	)


func _transforms() -> Dictionary:
	return {
		"entry_0000": Transform3D(Basis.IDENTITY, Vector3(1.0, 2.0, 3.0)),
		"entry_0001": Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(-2.0, 0.5, 4.0)),
	}


func _test_committed_content_is_immutable_from_arrangement_retries() -> void:
	var batch: LootBatch = _batch()
	assert(batch != null)
	var original_entries: Array[LootBatchEntry] = batch.entries
	var original_snapshot: Dictionary = batch.to_snapshot()
	var incomplete: Dictionary = {
		"entry_0000": Transform3D(Basis.IDENTITY, Vector3.ONE),
	}
	assert(not batch.commit_arrangement(incomplete, &"profile_test", 1))
	assert(batch.batch_id == "batch_a")
	assert(batch.source_kind == &"prototype")
	assert(batch.source_ref == "prototype_receiving_pool:1")
	assert(batch.target_bulk == 5)
	assert(batch.actual_bulk == 6)
	assert(batch.content_seed == 1842)
	assert(batch.presentation_seed == 9001)
	assert(batch.entries == original_entries)
	assert(batch.to_snapshot() == original_snapshot)


func _test_arrangement_commit_is_atomic() -> void:
	var batch: LootBatch = _batch()
	var incomplete: Dictionary = {
		"entry_0000": Transform3D(Basis.IDENTITY, Vector3.ONE),
	}
	assert(not batch.commit_arrangement(incomplete, &"profile_test", 1))
	assert(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	assert(batch.presentation_profile_id == &"")
	assert(not batch.entries[0].has_frozen_transform)
	assert(not batch.entries[1].has_frozen_transform)

	var transforms: Dictionary = _transforms()
	assert(batch.commit_arrangement(transforms, &"profile_test", 3))
	assert(batch.entries[0].frozen_transform == transforms["entry_0000"])
	assert(batch.entries[1].frozen_transform == transforms["entry_0001"])
	assert(batch.entries[0].has_frozen_transform)
	assert(batch.entries[1].has_frozen_transform)
	assert(batch.presentation_profile_id == &"profile_test")
	assert(batch.presentation_profile_revision == 3)
	assert(batch.preparation_state == LootBatchScript.STATE_PREPARED)
	assert(not batch.commit_arrangement(transforms, &"profile_other", 4))


func _test_snapshot_round_trip_preserves_identity_state_and_transform() -> void:
	var batch: LootBatch = _batch()
	assert(batch.commit_arrangement(_transforms(), &"profile_test", 3))
	assert(batch.mark_entry_released("entry_0000", "batch_a:item_0000"))

	var snapshot: Dictionary = batch.to_snapshot()
	assert(snapshot.keys().size() == 11)
	assert(not snapshot.has("arranging"))
	assert(not snapshot.has("preparation_job"))
	assert(not snapshot.has("velocities"))
	var bytes: PackedByteArray = var_to_bytes(snapshot)
	var restored_snapshot: Variant = bytes_to_var(bytes)
	var restored: LootBatch = LootBatchScript.from_snapshot(restored_snapshot as Dictionary)

	assert(restored != null)
	assert(restored.batch_id == "batch_a")
	assert(restored.source_kind == &"prototype")
	assert(restored.source_ref == "prototype_receiving_pool:1")
	assert(restored.target_bulk == 5)
	assert(restored.actual_bulk == 6)
	assert(restored.content_seed == 1842)
	assert(restored.presentation_seed == 9001)
	assert(restored.preparation_state == LootBatchScript.STATE_PREPARED)
	assert(restored.presentation_profile_id == &"profile_test")
	assert(restored.presentation_profile_revision == 3)
	assert(restored.entries.size() == 2)
	assert(restored.entries[0].entry_id == "entry_0000")
	assert(restored.entries[0].item_instance_id == "batch_a:item_0000")
	assert(restored.entries[0].definition_id == &"loot_000001")
	assert(restored.entries[0].frozen_transform == _transforms()["entry_0000"])
	assert(restored.entries[0].has_frozen_transform)
	assert(not restored.entries[0].remaining_in_batch)
	assert(restored.entries[1].remaining_in_batch)
	assert(restored.to_snapshot() == restored_snapshot)


func _test_item_instance_reconstruction_preserves_durable_identity() -> void:
	var batch: LootBatch = _batch()
	var instance: ItemInstance = batch.create_item_instance(
		"entry_0001", PersistentItemCatalog
	)
	assert(instance != null)
	assert(instance.instance_id == "batch_a:item_0001")
	assert(instance.definition == PersistentItemCatalog.get_definition_by_id(&"loot_000002"))
	assert(batch.create_item_instance("missing", PersistentItemCatalog) == null)
	assert(batch.create_item_instance("entry_0001", null) == null)


func _test_release_requires_matching_entry_and_identity() -> void:
	var batch: LootBatch = _batch()
	assert(not batch.mark_entry_released("missing", "batch_a:item_0000"))
	assert(not batch.mark_entry_released("entry_0000", "batch_a:item_0001"))
	assert(batch.entries[0].remaining_in_batch)
	assert(batch.mark_entry_released("entry_0000", "batch_a:item_0000"))
	assert(not batch.entries[0].remaining_in_batch)
	assert(not batch.mark_entry_released("entry_0000", "batch_a:item_0000"))
	assert(batch.entries[1].remaining_in_batch)


func _test_drained_state_tracks_release_accounting() -> void:
	var batch: LootBatch = _batch()
	if not batch.has_method("is_drained"):
		push_error("LootBatch must expose is_drained() for release accounting.")
		_abort_requested = true
		quit(1)
		return
	assert(not batch.is_drained())
	assert(batch.mark_entry_released("entry_0000", "batch_a:item_0000"))
	assert(not batch.is_drained())
	assert(batch.mark_entry_released("entry_0001", "batch_a:item_0001"))
	assert(batch.is_drained())


func _test_malformed_committed_content_is_rejected() -> void:
	assert(LootBatchScript.create_committed(
		"", &"prototype", "pool:1", 1, 1, 1, 2, _entries()
	) == null)
	assert(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 0, 1, 1, 2, _entries()
	) == null)
	assert(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 1, 0, 1, 2, _entries()
	) == null)
	var duplicate_entry_ids: Array[LootBatchEntry] = _entries()
	duplicate_entry_ids[1].entry_id = duplicate_entry_ids[0].entry_id
	assert(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 1, 1, 1, 2, duplicate_entry_ids
	) == null)
	var duplicate_item_ids: Array[LootBatchEntry] = _entries()
	duplicate_item_ids[1].item_instance_id = duplicate_item_ids[0].item_instance_id
	assert(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 1, 1, 1, 2, duplicate_item_ids
	) == null)
	var empty_definition: Array[LootBatchEntry] = _entries()
	empty_definition[0].definition_id = &""
	assert(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 1, 1, 1, 2, empty_definition
	) == null)


func _test_malformed_snapshots_are_rejected() -> void:
	var committed_snapshot: Dictionary = _batch().to_snapshot()
	var malformed_state: Dictionary = committed_snapshot.duplicate(true)
	malformed_state["preparation_state"] = &"ARRANGING"
	assert(LootBatchScript.from_snapshot(malformed_state) == null)

	var duplicate_identity: Dictionary = committed_snapshot.duplicate(true)
	var duplicate_entries: Array = duplicate_identity["entries"] as Array
	var second: Dictionary = duplicate_entries[1] as Dictionary
	second["item_instance_id"] = "batch_a:item_0000"
	assert(LootBatchScript.from_snapshot(duplicate_identity) == null)

	var inconsistent_prepared: Dictionary = committed_snapshot.duplicate(true)
	inconsistent_prepared["preparation_state"] = LootBatchScript.STATE_PREPARED
	inconsistent_prepared["presentation_profile_id"] = &"profile_test"
	inconsistent_prepared["presentation_profile_revision"] = 1
	assert(LootBatchScript.from_snapshot(inconsistent_prepared) == null)

	var inconsistent_committed: Dictionary = committed_snapshot.duplicate(true)
	var first_entry: Dictionary = (inconsistent_committed["entries"] as Array)[0] as Dictionary
	first_entry["has_frozen_transform"] = true
	inconsistent_committed["presentation_profile_id"] = &"profile_test"
	inconsistent_committed["presentation_profile_revision"] = 1
	assert(LootBatchScript.from_snapshot(inconsistent_committed) == null)

	var non_finite_entry: Dictionary = committed_snapshot.duplicate(true)
	var non_finite_snapshot: Dictionary = (non_finite_entry["entries"] as Array)[0] as Dictionary
	non_finite_snapshot["frozen_transform"] = Transform3D(
		Basis(Vector3(INF, 0.0, 0.0), Vector3.UP, Vector3.BACK), Vector3.ZERO
	)
	assert(LootBatchScript.from_snapshot(non_finite_entry) == null)

	var wrong_entries_type: Dictionary = committed_snapshot.duplicate(true)
	wrong_entries_type["entries"] = "not an array"
	assert(LootBatchScript.from_snapshot(wrong_entries_type) == null)


func _test_arrangement_rejects_non_finite_transforms_atomically() -> void:
	var batch: LootBatch = _batch()
	var transforms: Dictionary = _transforms()
	transforms["entry_0001"] = Transform3D(
		Basis.IDENTITY, Vector3(INF, 0.0, 0.0)
	)
	assert(not batch.commit_arrangement(transforms, &"profile_test", 1))
	assert(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	assert(batch.presentation_profile_id == &"")
	assert(not batch.entries[0].has_frozen_transform)
	assert(not batch.entries[1].has_frozen_transform)

	transforms = _transforms()
	transforms["entry_0001"] = Transform3D(
		Basis(Vector3(INF, 0.0, 0.0), Vector3.UP, Vector3.BACK), Vector3.ZERO
	)
	assert(not batch.commit_arrangement(transforms, &"profile_test", 1))
	assert(not batch.entries[0].has_frozen_transform)
	assert(not batch.entries[1].has_frozen_transform)

	var unknown: Dictionary = _transforms()
	unknown["unknown"] = Transform3D.IDENTITY
	assert(not batch.commit_arrangement(unknown, &"profile_test", 1))
	assert(not batch.commit_arrangement(_transforms(), &"", 1))
	assert(not batch.commit_arrangement(_transforms(), &"profile_test", 0))
