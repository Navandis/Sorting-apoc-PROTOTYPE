extends SceneTree

const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")



# A runtime abort can return from a helper to its caller in Godot. Every
# test or fixture helper stays pending until its final statement is reached.
var _failures: int = 0
var _pending_helpers: int = 0


func _init() -> void:
	_run_suite()
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving loot batch tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving loot batch tests")
	quit(0)


func _run_suite() -> void:
	_pending_helpers += 1
	_test_committed_content_is_immutable_from_arrangement_retries()
	_test_arrangement_commit_is_atomic()
	_test_snapshot_round_trip_preserves_identity_state_and_transform()
	_test_item_instance_reconstruction_preserves_durable_identity()
	_test_release_requires_matching_entry_and_identity()
	_test_drained_state_tracks_release_accounting()
	_test_committed_batch_owns_isolated_entry_records()
	_test_exposed_batch_content_is_protected()
	_test_fresh_commit_normalizes_presentation_and_round_trips()
	_test_malformed_committed_content_is_rejected()
	_test_fresh_empty_content_is_rejected_atomically()
	_test_fully_released_snapshots_still_reconstruct()
	_test_malformed_snapshots_are_rejected()
	_test_arrangement_rejects_non_finite_transforms_atomically()
	_pending_helpers -= 1


func _entries() -> Array[LootBatchEntry]:
	_pending_helpers += 1
	var completed_result: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("entry_0000", "batch_a:item_0000", &"loot_000001"),
		LootBatchEntryScript.new("entry_0001", "batch_a:item_0001", &"loot_000002"),
	]
	_pending_helpers -= 1
	return completed_result


func _batch() -> LootBatch:
	_pending_helpers += 1
	var completed_result: LootBatch = _batch_from_entries(_entries())
	_pending_helpers -= 1
	return completed_result


func _batch_from_entries(input_entries: Array[LootBatchEntry]) -> LootBatch:
	_pending_helpers += 1
	var completed_result: LootBatch = LootBatchScript.create_committed(
		"batch_a",
		&"prototype",
		"prototype_receiving_pool:1",
		5,
		6,
		1842,
		9001,
		input_entries
	)
	_pending_helpers -= 1
	return completed_result


func _transforms() -> Dictionary:
	_pending_helpers += 1
	var completed_result: Dictionary = {
		"entry_0000": Transform3D(Basis.IDENTITY, Vector3(1.0, 2.0, 3.0)),
		"entry_0001": Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(-2.0, 0.5, 4.0)),
	}
	_pending_helpers -= 1
	return completed_result


func _test_committed_content_is_immutable_from_arrangement_retries() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	_check(batch != null)
	var original_snapshot: Dictionary = batch.to_snapshot()
	var incomplete: Dictionary = {
		"entry_0000": Transform3D(Basis.IDENTITY, Vector3.ONE),
	}
	_check(not batch.commit_arrangement(incomplete, &"profile_test", 1))
	_check(batch.batch_id == "batch_a")
	_check(batch.source_kind == &"prototype")
	_check(batch.source_ref == "prototype_receiving_pool:1")
	_check(batch.target_bulk == 5)
	_check(batch.actual_bulk == 6)
	_check(batch.content_seed == 1842)
	_check(batch.presentation_seed == 9001)
	_check(batch.to_snapshot() == original_snapshot)
	_pending_helpers -= 1


func _test_arrangement_commit_is_atomic() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var incomplete: Dictionary = {
		"entry_0000": Transform3D(Basis.IDENTITY, Vector3.ONE),
	}
	_check(not batch.commit_arrangement(incomplete, &"profile_test", 1))
	_check(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	_check(batch.presentation_profile_id == &"")
	_check(not batch.entries[0].has_frozen_transform)
	_check(not batch.entries[1].has_frozen_transform)

	var transforms: Dictionary = _transforms()
	_check(batch.commit_arrangement(transforms, &"profile_test", 3))
	_check(batch.entries[0].frozen_transform == transforms["entry_0000"])
	_check(batch.entries[1].frozen_transform == transforms["entry_0001"])
	_check(batch.entries[0].has_frozen_transform)
	_check(batch.entries[1].has_frozen_transform)
	_check(batch.presentation_profile_id == &"profile_test")
	_check(batch.presentation_profile_revision == 3)
	_check(batch.preparation_state == LootBatchScript.STATE_PREPARED)
	_check(not batch.commit_arrangement(transforms, &"profile_other", 4))
	_pending_helpers -= 1


func _test_snapshot_round_trip_preserves_identity_state_and_transform() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	_check(batch.commit_arrangement(_transforms(), &"profile_test", 3))
	_check(batch.mark_entry_released("entry_0000", "batch_a:item_0000"))

	var snapshot: Dictionary = batch.to_snapshot()
	_check(snapshot.keys().size() == 11)
	_check(not snapshot.has("arranging"))
	_check(not snapshot.has("preparation_job"))
	_check(not snapshot.has("velocities"))
	var bytes: PackedByteArray = var_to_bytes(snapshot)
	var restored_snapshot: Variant = bytes_to_var(bytes)
	var restored: LootBatch = LootBatchScript.from_snapshot(restored_snapshot as Dictionary)

	_check(restored != null)
	_check(restored.batch_id == "batch_a")
	_check(restored.source_kind == &"prototype")
	_check(restored.source_ref == "prototype_receiving_pool:1")
	_check(restored.target_bulk == 5)
	_check(restored.actual_bulk == 6)
	_check(restored.content_seed == 1842)
	_check(restored.presentation_seed == 9001)
	_check(restored.preparation_state == LootBatchScript.STATE_PREPARED)
	_check(restored.presentation_profile_id == &"profile_test")
	_check(restored.presentation_profile_revision == 3)
	_check(restored.entries.size() == 2)
	_check(restored.entries[0].entry_id == "entry_0000")
	_check(restored.entries[0].item_instance_id == "batch_a:item_0000")
	_check(restored.entries[0].definition_id == &"loot_000001")
	_check(restored.entries[0].frozen_transform == _transforms()["entry_0000"])
	_check(restored.entries[0].has_frozen_transform)
	_check(not restored.entries[0].remaining_in_batch)
	_check(restored.entries[1].remaining_in_batch)
	_check(restored.to_snapshot() == restored_snapshot)
	_pending_helpers -= 1


func _test_item_instance_reconstruction_preserves_durable_identity() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var instance: ItemInstance = batch.create_item_instance(
		"entry_0001", PersistentItemCatalog
	)
	_check(instance != null)
	_check(instance.instance_id == "batch_a:item_0001")
	_check(instance.definition == PersistentItemCatalog.get_definition_by_id(&"loot_000002"))
	_check(batch.create_item_instance("missing", PersistentItemCatalog) == null)
	_check(batch.create_item_instance("entry_0001", null) == null)
	_pending_helpers -= 1


func _test_release_requires_matching_entry_and_identity() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	_check(not batch.mark_entry_released("missing", "batch_a:item_0000"))
	_check(not batch.mark_entry_released("entry_0000", "batch_a:item_0001"))
	_check(batch.entries[0].remaining_in_batch)
	_check(batch.mark_entry_released("entry_0000", "batch_a:item_0000"))
	_check(not batch.entries[0].remaining_in_batch)
	_check(not batch.mark_entry_released("entry_0000", "batch_a:item_0000"))
	_check(batch.entries[1].remaining_in_batch)
	_pending_helpers -= 1


func _test_drained_state_tracks_release_accounting() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	_check(not batch.is_drained())
	_check(batch.mark_entry_released("entry_0000", "batch_a:item_0000"))
	_check(not batch.is_drained())
	_check(batch.mark_entry_released("entry_0001", "batch_a:item_0001"))
	_check(batch.is_drained())
	_pending_helpers -= 1


func _test_committed_batch_owns_isolated_entry_records() -> void:
	_pending_helpers += 1
	var input_entries: Array[LootBatchEntry] = _entries()
	var first: LootBatch = _batch_from_entries(input_entries)
	var second: LootBatch = _batch_from_entries(input_entries)
	_check(first.entries[0] != input_entries[0], "batch owns a copy of each input entry")
	_check(first.entries[0] != second.entries[0], "batches do not share entry records")

	input_entries[0].item_instance_id = "tampered:item"
	input_entries[0].remaining_in_batch = false
	_check(
		first.entries[0].item_instance_id == "batch_a:item_0000",
		"retained input identity cannot mutate committed content"
	)
	_check(
		first.entries[0].remaining_in_batch,
		"retained input ownership cannot mutate committed content"
	)

	_check(first.commit_arrangement(_transforms(), &"profile_test", 1))
	_check(first.mark_entry_released("entry_0000", "batch_a:item_0000"))
	_check(
		not second.entries[0].has_frozen_transform,
		"arranging one batch does not mutate another batch"
	)
	_check(
		second.entries[0].remaining_in_batch,
		"releasing from one batch does not mutate another batch"
	)
	_pending_helpers -= 1


func _test_exposed_batch_content_is_protected() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var exposed_entries: Array[LootBatchEntry] = batch.entries
	var exposed_entry: LootBatchEntry = exposed_entries[0]
	exposed_entries.clear()
	_check(batch.entries.size() == 2, "entries exposes a detached collection view")
	_check(batch.entries[0] != exposed_entry, "entries exposes detached entry views")

	exposed_entry.entry_id = "tampered_entry"
	exposed_entry.item_instance_id = "tampered:item"
	exposed_entry.definition_id = &"tampered_definition"
	exposed_entry.frozen_transform = Transform3D(Basis.IDENTITY, Vector3.ONE)
	exposed_entry.has_frozen_transform = true
	exposed_entry.remaining_in_batch = false
	batch.batch_id = "tampered_batch"
	batch.source_kind = &"tampered_source"
	batch.source_ref = "tampered_ref"
	batch.target_bulk = 999
	batch.actual_bulk = 999
	batch.content_seed = 999
	batch.presentation_seed = 999
	batch.preparation_state = LootBatchScript.STATE_PREPARED
	batch.presentation_profile_id = &"tampered_profile"
	batch.presentation_profile_revision = 999
	var replacement_entries: Array[LootBatchEntry] = []
	batch.entries = replacement_entries

	var snapshot: Dictionary = batch.to_snapshot()
	var first_snapshot: Dictionary = (snapshot["entries"] as Array)[0] as Dictionary
	_check(snapshot["batch_id"] == "batch_a", "batch identity is read-only")
	_check(snapshot["source_kind"] == &"prototype", "source kind is read-only")
	_check(snapshot["source_ref"] == "prototype_receiving_pool:1", "source ref is read-only")
	_check(snapshot["target_bulk"] == 5, "target Bulk is read-only")
	_check(snapshot["actual_bulk"] == 6, "committed Bulk is read-only")
	_check(snapshot["content_seed"] == 1842, "content seed is read-only")
	_check(snapshot["presentation_seed"] == 9001, "presentation seed is read-only")
	_check(
		snapshot["preparation_state"] == LootBatchScript.STATE_CONTENT_COMMITTED,
		"preparation state changes only through atomic commit"
	)
	_check(snapshot["presentation_profile_id"] == &"", "profile ID is protected")
	_check(snapshot["presentation_profile_revision"] == 0, "profile revision is protected")
	_check(first_snapshot["entry_id"] == "entry_0000", "entry identity is protected")
	_check(
		first_snapshot["item_instance_id"] == "batch_a:item_0000",
		"item identity is protected"
	)
	_check(first_snapshot["definition_id"] == &"loot_000001", "definition is protected")
	_check(
		first_snapshot["frozen_transform"] == Transform3D.IDENTITY,
		"frozen transform changes only through atomic commit"
	)
	_check(not first_snapshot["has_frozen_transform"], "transform flag is protected")
	_check(first_snapshot["remaining_in_batch"], "ownership changes only through release")
	_pending_helpers -= 1


func _test_fresh_commit_normalizes_presentation_and_round_trips() -> void:
	_pending_helpers += 1
	var dirty_snapshot: Dictionary = LootBatchEntryScript.new(
		"entry_0000", "batch_a:item_0000", &"loot_000001"
	).to_snapshot()
	dirty_snapshot["frozen_transform"] = Transform3D(Basis.IDENTITY, Vector3.ONE)
	dirty_snapshot["has_frozen_transform"] = true
	dirty_snapshot["remaining_in_batch"] = false
	var dirty_entry: LootBatchEntry = LootBatchEntryScript.from_snapshot(dirty_snapshot)
	_check(dirty_entry != null and dirty_entry.to_snapshot() == dirty_snapshot, "fixture really contains persisted presentation and released ownership")
	var second_entry: LootBatchEntry = LootBatchEntryScript.new(
		"entry_0001", "batch_a:item_0001", &"loot_000002"
	)
	var dirty_entries: Array[LootBatchEntry] = [dirty_entry, second_entry]
	var batch: LootBatch = _batch_from_entries(dirty_entries)
	_check(batch != null, "valid committed identity survives dirty input presentation")
	if batch != null:
		_check(not batch.entries[0].has_frozen_transform, "fresh commit clears transform flag")
		_check(batch.entries[0].frozen_transform == Transform3D.IDENTITY, "fresh commit resets transform")
		_check(batch.entries[0].remaining_in_batch, "fresh commit establishes batch ownership")
		_check(
			LootBatchScript.from_snapshot(batch.to_snapshot()) != null,
			"fresh factory output always round-trips"
		)

	# Public snapshot input can actually supply non-finite presentation state;
	# read-only entry setters cannot construct that fixture.
	dirty_snapshot["frozen_transform"] = Transform3D(Basis.IDENTITY, Vector3(INF, 0.0, 0.0))
	_check(not (dirty_snapshot["frozen_transform"] as Transform3D).origin.is_finite(), "snapshot fixture contains a non-finite origin")
	_check(LootBatchEntryScript.from_snapshot(dirty_snapshot) == null, "entry reconstruction rejects non-finite persisted presentation")
	_pending_helpers -= 1


func _test_malformed_committed_content_is_rejected() -> void:
	_pending_helpers += 1
	_check(LootBatchScript.create_committed(
		"", &"prototype", "pool:1", 1, 1, 1, 2, _entries()
	) == null)
	_check(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 0, 1, 1, 2, _entries()
	) == null)
	_check(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 1, 0, 1, 2, _entries()
	) == null)
	var duplicate_entry_ids: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("entry_0000", "batch_a:item_0000", &"loot_000001"),
		LootBatchEntryScript.new("entry_0000", "batch_a:item_0001", &"loot_000002"),
	]
	_check(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 1, 1, 1, 2, duplicate_entry_ids
	) == null)
	var duplicate_item_ids: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("entry_0000", "batch_a:item_0000", &"loot_000001"),
		LootBatchEntryScript.new("entry_0001", "batch_a:item_0000", &"loot_000002"),
	]
	_check(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 1, 1, 1, 2, duplicate_item_ids
	) == null)
	var empty_definition: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("entry_0000", "batch_a:item_0000", &""),
		LootBatchEntryScript.new("entry_0001", "batch_a:item_0001", &"loot_000002"),
	]
	_check(LootBatchScript.create_committed(
		"batch_a", &"prototype", "pool:1", 1, 1, 1, 2, empty_definition
	) == null)
	_pending_helpers -= 1


# An empty array must not escape as a committed positive-Bulk batch.
func _test_fresh_empty_content_is_rejected_atomically() -> void:
	_pending_helpers += 1
	var retained: LootBatch = _batch()
	var retained_before: PackedByteArray = var_to_bytes(retained.to_snapshot())
	var empty_entries: Array[LootBatchEntry] = []
	var input_before: PackedByteArray = var_to_bytes(empty_entries)
	_check(_batch_from_entries(empty_entries) == null, "fresh empty content is rejected before commitment")
	_check(var_to_bytes(empty_entries) == input_before, "empty rejection leaves caller input unchanged")
	_check(var_to_bytes(retained.to_snapshot()) == retained_before, "empty rejection leaves existing commitment unchanged")
	_pending_helpers -= 1


# Rejection of empty creation must not discard durable records after release.
func _test_fully_released_snapshots_still_reconstruct() -> void:
	_pending_helpers += 1
	for prepared: bool in [false, true]:
		var batch: LootBatch = _batch()
		if prepared:
			_check(batch.commit_arrangement(_transforms(), &"profile_test", 3))
		for entry: LootBatchEntry in batch.entries:
			_check(batch.mark_entry_released(entry.entry_id, entry.item_instance_id))
		_check(batch.is_drained(), "fixture releases every committed entry")
		var bytes: PackedByteArray = var_to_bytes(batch.to_snapshot())
		var restored: LootBatch = LootBatchScript.from_snapshot(bytes_to_var(bytes) as Dictionary)
		_check(restored != null, "fully released durable batch reconstructs")
		_check(restored.is_drained() and restored.entries.size() == 2, "reconstruction retains released item records")
		_check(var_to_bytes(restored.to_snapshot()) == bytes, "released identity, transforms, state and ownership survive exactly")
	_pending_helpers -= 1


func _test_malformed_snapshots_are_rejected() -> void:
	_pending_helpers += 1
	var committed_snapshot: Dictionary = _batch().to_snapshot()
	var malformed_state: Dictionary = committed_snapshot.duplicate(true)
	malformed_state["preparation_state"] = &"ARRANGING"
	_check(LootBatchScript.from_snapshot(malformed_state) == null)

	var duplicate_identity: Dictionary = committed_snapshot.duplicate(true)
	var duplicate_entries: Array = duplicate_identity["entries"] as Array
	var second: Dictionary = duplicate_entries[1] as Dictionary
	second["item_instance_id"] = "batch_a:item_0000"
	_check(LootBatchScript.from_snapshot(duplicate_identity) == null)

	var inconsistent_prepared: Dictionary = committed_snapshot.duplicate(true)
	inconsistent_prepared["preparation_state"] = LootBatchScript.STATE_PREPARED
	inconsistent_prepared["presentation_profile_id"] = &"profile_test"
	inconsistent_prepared["presentation_profile_revision"] = 1
	_check(LootBatchScript.from_snapshot(inconsistent_prepared) == null)

	var inconsistent_committed: Dictionary = committed_snapshot.duplicate(true)
	var first_entry: Dictionary = (inconsistent_committed["entries"] as Array)[0] as Dictionary
	first_entry["has_frozen_transform"] = true
	inconsistent_committed["presentation_profile_id"] = &"profile_test"
	inconsistent_committed["presentation_profile_revision"] = 1
	_check(LootBatchScript.from_snapshot(inconsistent_committed) == null)

	var non_finite_entry: Dictionary = committed_snapshot.duplicate(true)
	var non_finite_snapshot: Dictionary = (non_finite_entry["entries"] as Array)[0] as Dictionary
	non_finite_snapshot["frozen_transform"] = Transform3D(
		Basis(Vector3(INF, 0.0, 0.0), Vector3.UP, Vector3.BACK), Vector3.ZERO
	)
	_check(LootBatchScript.from_snapshot(non_finite_entry) == null)

	var wrong_entries_type: Dictionary = committed_snapshot.duplicate(true)
	wrong_entries_type["entries"] = "not an array"
	_check(LootBatchScript.from_snapshot(wrong_entries_type) == null)
	_pending_helpers -= 1


func _test_arrangement_rejects_non_finite_transforms_atomically() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var transforms: Dictionary = _transforms()
	transforms["entry_0001"] = Transform3D(
		Basis.IDENTITY, Vector3(INF, 0.0, 0.0)
	)
	_check(not batch.commit_arrangement(transforms, &"profile_test", 1))
	_check(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	_check(batch.presentation_profile_id == &"")
	_check(not batch.entries[0].has_frozen_transform)
	_check(not batch.entries[1].has_frozen_transform)

	transforms = _transforms()
	transforms["entry_0001"] = Transform3D(
		Basis(Vector3(INF, 0.0, 0.0), Vector3.UP, Vector3.BACK), Vector3.ZERO
	)
	_check(not batch.commit_arrangement(transforms, &"profile_test", 1))
	_check(not batch.entries[0].has_frozen_transform)
	_check(not batch.entries[1].has_frozen_transform)

	var unknown: Dictionary = _transforms()
	unknown["unknown"] = Transform3D.IDENTITY
	_check(not batch.commit_arrangement(unknown, &"profile_test", 1))
	_check(not batch.commit_arrangement(_transforms(), &"", 1))
	_check(not batch.commit_arrangement(_transforms(), &"profile_test", 0))
	_pending_helpers -= 1


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition
