extends SceneTree

const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypePool = preload("res://data/receiving/prototype_loot_pool.tres")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const PrototypeLootSourceScript = preload("res://receiving/prototype_loot_source.gd")
const ProfileScript = preload("res://receiving/freight_bay_presentation_profile.gd")
const JobScript = preload("res://receiving/pile_preparation_job.gd")
const MetricsScript = preload("res://receiving/pile_preparation_metrics.gd")
const ReceivingManagerScript = preload("res://receiving/receiving_manager.gd")

# Fixed reproduction inputs for the Stage A validation record. All arrangements
# below are synthetic data fixtures; no physical preparation is claimed.
const INTEGRATION_CONTENT_SEED: int = 1842
const INTEGRATION_PRESENTATION_SEED: int = 9001
const INTEGRATION_TARGET_BULK: int = 24
const INTEGRATION_PROFILE_ID: StringName = &"stage_a_synthetic_integration"
const INTEGRATION_PROFILE_REVISION: int = 1

var _failures: int = 0
var _completed_sections: int = 0
var _active_changed_ids: Array[String] = []
var _drained_ids: Array[String] = []
var _rejected_ids: Array[String] = []


func _init() -> void:
	_test_real_catalog_and_pool_boundary()
	_test_reconstruction_deposit_release_and_post_close_fifo()
	_test_failed_preparation_is_disposable()
	_test_runtime_manifest_boundary()
	_check(_completed_sections == 4, "all integration sections completed without script errors")
	if _failures > 0:
		print("FAIL: receiving stage a integration tests (%d checks)" % _failures)
		quit(1)
		return
	print("PASS: receiving stage a integration tests")
	quit(0)


# Catches generation silently broadening the approved gameplay pool or losing
# a real catalog resource. This exact membership is an approved boundary.
func _test_real_catalog_and_pool_boundary() -> void:
	_check(PersistentItemCatalog.get_validation_errors().is_empty(), "valid real catalog")
	_check((PersistentItemCatalog.get("definitions") as Array).size() == 42, "42-definition catalog")
	_check(PrototypePool.pool_id == &"prototype_receiving_pool", "real pool identity")
	_check(PrototypePool.revision == 1, "real pool revision")
	var expected_ids: Array[StringName] = [
		&"loot_000001", &"loot_000002", &"loot_000003", &"loot_000004",
		&"loot_000005", &"loot_000006", &"loot_000007", &"loot_000008",
		&"loot_000009", &"loot_000010", &"loot_000011", &"loot_000012",
		&"loot_000013", &"loot_000014", &"loot_000015", &"loot_000016",
		&"loot_000017", &"loot_000018", &"loot_000019", &"loot_000020",
		&"loot_000021", &"loot_000022", &"loot_000023", &"loot_000024",
		&"loot_000025", &"loot_000026", &"loot_000027", &"loot_000028",
		&"loot_000029", &"loot_000030", &"loot_000031", &"loot_000032",
		&"loot_000033", &"loot_000035", &"loot_000037", &"loot_000038",
		&"loot_000039", &"loot_000040", &"loot_000041", &"loot_000042",
	]
	_check(PrototypePool.item_definition_ids == expected_ids, "exact ordered 40-ID pool")
	_check(PrototypePool.validate_against_catalog(PersistentItemCatalog).is_empty(), "pool resolves against catalog")
	_check(PrototypePool.resolve_definitions(PersistentItemCatalog).size() == 40, "40 resolved definitions")
	_completed_sections += 1


# Catches content/identity loss across persistence, partial arrangement writes,
# capacity mutation on rejection, imprecise ownership release, and early or
# non-FIFO promotion across the real public component boundaries.
func _test_reconstruction_deposit_release_and_post_close_fifo() -> void:
	var original: LootBatch = _generate("integration_first")
	var repeated: LootBatch = _generate("integration_first")
	var distinct: LootBatch = _generate("integration_distinct")
	if not _check(original != null and repeated != null and distinct != null, "generation helpers completed"):
		return
	_check(var_to_bytes(original.to_snapshot()) == var_to_bytes(repeated.to_snapshot()), "same inputs reproduce committed snapshot")
	_check(_definition_sequence(original) == _definition_sequence(distinct), "batch ID does not alter ordered content")
	_check(original.actual_bulk == distinct.actual_bulk, "batch ID does not alter Bulk")
	var original_ids: Dictionary = {}
	for entry: LootBatchEntry in original.entries:
		original_ids[entry.item_instance_id] = true
	for entry: LootBatchEntry in distinct.entries:
		_check(not original_ids.has(entry.item_instance_id), "distinct batches have disjoint item identities")

	var active: LootBatch = _round_trip(original)
	if not _check(active != null, "committed round-trip helper completed"):
		return
	_check(active.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED, "reconstructed content remains committed")
	var profile: FreightBayPresentationProfile = _profile()
	if not _check(profile != null, "profile helper completed"):
		return
	var transforms: Dictionary = _synthetic_transforms(active)
	var incomplete: Dictionary = transforms.duplicate()
	incomplete.erase(active.entries.back().entry_id)
	var before_arrangement: PackedByteArray = var_to_bytes(active.to_snapshot())
	_check(not active.commit_arrangement(incomplete, profile.profile_id, profile.revision), "partial arrangement rejected")
	_check(var_to_bytes(active.to_snapshot()) == before_arrangement, "partial arrangement rejection is atomic")
	_check(active.commit_arrangement(transforms, profile.profile_id, profile.revision), "complete arrangement accepted")
	_check(active.preparation_state == LootBatchScript.STATE_PREPARED, "complete arrangement prepares batch")
	_check(active.presentation_profile_id == INTEGRATION_PROFILE_ID, "profile identity committed")
	_check(active.presentation_profile_revision == INTEGRATION_PROFILE_REVISION, "profile revision committed")
	active = _round_trip(active)
	if not _check(active != null, "prepared round-trip helper completed"):
		return
	for entry: LootBatchEntry in active.entries:
		_check(entry.has_frozen_transform and entry.frozen_transform == transforms[entry.entry_id], "prepared transform survives bytes")
		var item: ItemInstance = active.create_item_instance(entry.entry_id, PersistentItemCatalog)
		if not _check(item != null, "real ItemInstance reconstruction"):
			continue
		_check(item.instance_id == entry.item_instance_id, "exact durable item identity reconstructed")
		_check(item.definition == PersistentItemCatalog.get_definition_by_id(entry.definition_id), "real definition reconstructed")

	# Three further prepared batches attempt physical deposit; a fifth prepared
	# batch is never offered to the manager and consumes no manager capacity.
	var second: LootBatch = _prepared("integration_second")
	var third: LootBatch = _prepared("integration_third")
	var fourth: LootBatch = _prepared("integration_fourth")
	var undelivered: LootBatch = _prepared("integration_undelivered")
	if not _check(second != null and third != null and fourth != null and undelivered != null, "preparation helpers completed"):
		return
	var undelivered_before: PackedByteArray = var_to_bytes(undelivered.to_snapshot())
	var manager: ReceivingManager = ReceivingManagerScript.new()
	manager.active_batch_changed.connect(func(id: String) -> void: _active_changed_ids.append(id))
	manager.active_batch_drained.connect(func(id: String) -> void: _drained_ids.append(id))
	manager.deposit_rejected.connect(func(id: String) -> void: _rejected_ids.append(id))
	_check(manager.get_active_batch() == null and manager.get_queued_batch_ids().is_empty(), "prepared work alone occupies no slots")
	_check(manager.get_deposited_batch(undelivered.batch_id) == null, "undelivered batch outside manager")
	_check(manager.deposit_batch(active), "first deposit accepted")
	_check(manager.deposit_batch(second), "second deposit accepted")
	_check(manager.deposit_batch(third), "third deposit accepted")
	var capacity_before: PackedByteArray = _manager_snapshot(manager, [active, second, third, fourth, undelivered])
	_check(not manager.deposit_batch(fourth), "fourth physical deposit rejected")
	_check(_manager_snapshot(manager, [active, second, third, fourth, undelivered]) == capacity_before, "capacity rejection leaves ownership and all batch data unchanged")
	_check(_rejected_ids == ["integration_fourth"], "exact rejection notification")
	_check(manager.get_active_batch() == active, "original active object preserved")
	_check(manager.get_deposited_batch(second.batch_id) == second, "second deposited object preserved")
	_check(manager.get_deposited_batch(third.batch_id) == third, "third deposited object preserved")
	_check(manager.get_deposited_batch(fourth.batch_id) == null, "rejected batch not registered")
	_check(manager.get_queued_batch_ids() == PackedStringArray(["integration_second", "integration_third"]), "two queued slots in FIFO order")
	_check(manager.retire_drained_active_after_close() == "", "non-drained batch cannot retire")
	var entry: LootBatchEntry = active.entries[0]
	var release_before: PackedByteArray = var_to_bytes(active.to_snapshot())
	_check(not manager.release_entry(second.batch_id, second.entries[0].entry_id, second.entries[0].item_instance_id), "queued entry cannot release")
	_check(not manager.release_entry(active.batch_id, entry.entry_id, distinct.entries[0].item_instance_id), "other batch item identity cannot release")
	_check(var_to_bytes(active.to_snapshot()) == release_before, "wrong release preserves active content")

	for batch: LootBatch in [active, second, third]:
		if not _check(_drain(manager, batch), "drain helper completed every assertion"):
			manager.free()
			return
		_check(manager.get_active_batch_id() == batch.batch_id, "drained batch remains active before close")
		_check(manager.get_deposited_batch(batch.batch_id) == batch, "drained batch still occupies slot before close")
		var expected_next: String = "integration_second" if batch == active else ("integration_third" if batch == second else "")
		_check(manager.retire_drained_active_after_close() == expected_next, "explicit post-close FIFO promotion")
		_check(manager.get_active_batch_id() == expected_next, "active identity after close")
		_check(manager.get_deposited_batch(batch.batch_id) == null, "retired batch removed from ownership")
	_check(_drained_ids == ["integration_first", "integration_second", "integration_third"], "one drained signal per batch")
	_check(_active_changed_ids == ["integration_first", "integration_second", "integration_third", ""], "FIFO signals include empty final active slot")
	_check(manager.get_active_batch() == null and manager.get_queued_batch_ids().is_empty(), "all deposited slots retired")
	_check(manager.get_deposited_batch(undelivered.batch_id) == null, "undelivered batch never entered manager")
	_check(var_to_bytes(undelivered.to_snapshot()) == undelivered_before, "undelivered prepared work untouched")
	manager.free()
	_completed_sections += 1


# Catches transient job status/diagnostics leaking into the persisted batch or
# failed work mutating committed content. A fresh job can consume reconstruction.
func _test_failed_preparation_is_disposable() -> void:
	var committed: LootBatch = _generate("integration_failed_job")
	if not _check(committed != null, "failed-job generation helper completed"):
		return
	var before: PackedByteArray = var_to_bytes(committed.to_snapshot())
	var profile: FreightBayPresentationProfile = _profile()
	if not _check(profile != null, "failed-job profile helper completed"):
		return
	var job: PilePreparationJob = JobScript.new(committed, profile)
	_check(job.begin(), "preparation job begins on committed data")
	job.diagnostics.attempts_used = 1
	job.diagnostics.preparation_duration_ms = 12
	_check(job.mark_failed(&"synthetic_rejection"), "running preparation job records failure")
	_check(job.state == JobScript.JobState.FAILED, "job failure is transient state")
	var diagnostics: Dictionary = job.diagnostics.to_snapshot()
	_check(diagnostics["batch_id"] == committed.batch_id, "diagnostics reference committed batch")
	_check(diagnostics["rejection_counts_by_reason"] == {&"synthetic_rejection": 1}, "diagnostics contain failure reason")
	var metrics: PilePreparationMetrics = MetricsScript.new()
	metrics.record(job.diagnostics)
	_check(metrics.snapshot()["rejection_reason_distribution"] == {&"synthetic_rejection": 1}, "metrics consume transient diagnostics")
	_check(var_to_bytes(committed.to_snapshot()) == before, "failed job leaves full durable snapshot unchanged")
	var durable_snapshot: Dictionary = committed.to_snapshot()
	for transient_key: String in ["job", "state", "diagnostics", "attempts_used", "rejection_counts_by_reason", "preparation_duration_ms"]:
		_check(not durable_snapshot.has(transient_key), "batch excludes transient key: " + transient_key)
	job = null
	var restored: LootBatch = _round_trip(committed)
	if not _check(restored != null, "failed-job round-trip helper completed"):
		return
	_check(restored.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED, "failed job reconstructs as committed")
	_check(var_to_bytes(restored.to_snapshot()) == before, "identity and content survive discarded failed job")
	var fresh_job: PilePreparationJob = JobScript.new(restored, profile)
	_check(fresh_job.state == JobScript.JobState.PENDING and fresh_job.diagnostics.rejection_counts_by_reason.is_empty(), "new job has no old failure state")
	_check(fresh_job.begin(), "fresh job can retry reconstructed content")
	_check(restored.commit_arrangement(_synthetic_transforms(restored), profile.profile_id, profile.revision), "retry commits synthetic arrangement")
	_check(fresh_job.mark_succeeded(), "transient retry completes")
	_check(restored.preparation_state == LootBatchScript.STATE_PREPARED, "retry produces prepared durable batch")
	_completed_sections += 1


# Mandated narrow architecture guard: receiving runtime must not consume the
# separate authoring review manifest. Only directly contained scripts are read.
func _test_runtime_manifest_boundary() -> void:
	var directory: DirAccess = DirAccess.open("res://receiving/")
	if not _check(directory != null, "runtime receiving directory exists"):
		return
	var scanned: int = 0
	for file_name: String in directory.get_files():
		if not file_name.ends_with(".gd"):
			continue
		var file: FileAccess = FileAccess.open("res://receiving/" + file_name, FileAccess.READ)
		if not _check(file != null, "read receiving script: " + file_name):
			continue
		var source: String = file.get_as_text()
		_check(not source.contains("item_authoring_review.json"), "runtime excludes manifest filename: " + file_name)
		_check(not source.contains("authoring_review_manifest"), "runtime excludes manifest symbol: " + file_name)
		scanned += 1
	_check(scanned > 0, "manifest guard scans runtime scripts")
	_completed_sections += 1


# Assertion-bearing helpers return their non-null result only after all checks.
# Callers must stop before section completion if a helper aborts and returns null.
func _generate(batch_id: String) -> LootBatch:
	var source: PrototypeLootSource = PrototypeLootSourceScript.new()
	var batch: LootBatch = source.generate_committed_batch(PersistentItemCatalog, PrototypePool, batch_id, INTEGRATION_CONTENT_SEED, INTEGRATION_PRESENTATION_SEED, INTEGRATION_TARGET_BULK)
	if not _check(batch != null, "generate real pooled batch: " + batch_id):
		return null
	_check(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED, "source returns committed content")
	_check(batch.source_ref == "prototype_receiving_pool:1" and batch.source_kind == &"prototype", "pool provenance retained")
	_check(not batch.entries.is_empty(), "generated batch contains items")
	var summed_bulk: int = 0
	for entry: LootBatchEntry in batch.entries:
		_check(PrototypePool.item_definition_ids.has(entry.definition_id), "generated item belongs to explicit pool")
		summed_bulk += PersistentItemCatalog.get_definition_by_id(entry.definition_id).bulk
	_check(batch.actual_bulk == summed_bulk and summed_bulk >= INTEGRATION_TARGET_BULK, "generated Bulk matches real content and reaches target")
	return batch


func _round_trip(batch: LootBatch) -> LootBatch:
	var bytes: PackedByteArray = var_to_bytes(batch.to_snapshot())
	var restored: LootBatch = LootBatchScript.from_snapshot(bytes_to_var(bytes) as Dictionary)
	if _check(restored != null, "Variant byte reconstruction"):
		_check(restored != batch, "reconstruction creates a separate batch")
		_check(var_to_bytes(restored.to_snapshot()) == bytes, "full durable snapshot preserved")
	return restored


func _profile() -> FreightBayPresentationProfile:
	var profile: FreightBayPresentationProfile = ProfileScript.new()
	profile.profile_id = INTEGRATION_PROFILE_ID
	profile.revision = INTEGRATION_PROFILE_REVISION
	_check(profile.validate_identity().is_empty(), "synthetic profile has valid identity")
	return profile


func _synthetic_transforms(batch: LootBatch) -> Dictionary:
	var transforms: Dictionary = {}
	for index: int in batch.entries.size():
		transforms[batch.entries[index].entry_id] = Transform3D(Basis.IDENTITY, Vector3(float(index), 0.5, -0.25))
	return transforms


func _prepared(batch_id: String) -> LootBatch:
	var batch: LootBatch = _generate(batch_id)
	if not _check(batch != null, "nested generation helper completed"):
		return null
	_check(batch.commit_arrangement(_synthetic_transforms(batch), INTEGRATION_PROFILE_ID, INTEGRATION_PROFILE_REVISION), "synthetically prepare: " + batch_id)
	return batch


func _definition_sequence(batch: LootBatch) -> Array[StringName]:
	var sequence: Array[StringName] = []
	for entry: LootBatchEntry in batch.entries:
		sequence.append(entry.definition_id)
	return sequence


func _manager_snapshot(manager: ReceivingManager, batches: Array[LootBatch]) -> PackedByteArray:
	var state: Dictionary = {"active": manager.get_active_batch_id(), "queue": manager.get_queued_batch_ids(), "batches": {}, "registered": {}}
	for batch: LootBatch in batches:
		state["batches"][batch.batch_id] = batch.to_snapshot()
		state["registered"][batch.batch_id] = manager.get_deposited_batch(batch.batch_id) != null
	return var_to_bytes(state)


# Unlike the object-returning helpers, draining needs an explicit completion
# result: a runtime abort must never be mistaken for completed release checks.
func _drain(manager: ReceivingManager, batch: LootBatch) -> bool:
	var previous_signal_count: int = _drained_ids.size()
	var entries: Array[LootBatchEntry] = batch.entries
	for index: int in entries.size():
		var entry: LootBatchEntry = entries[index]
		var item: ItemInstance = batch.create_item_instance(entry.entry_id, PersistentItemCatalog)
		if not _check(item != null, "reconstruct exact item before ownership transfer"):
			continue
		_check(manager.release_entry(batch.batch_id, entry.entry_id, item.instance_id), "release exact reconstructed active entry")
		_check(not batch.entries[index].remaining_in_batch, "release transfers entry ownership")
		_check(_drained_ids.size() == previous_signal_count + (1 if index == entries.size() - 1 else 0), "drained fires only on final release")
	_check(batch.is_drained(), "all reconstructed items released")
	_check(not manager.release_entry(batch.batch_id, entries[0].entry_id, entries[0].item_instance_id), "duplicate release rejected")
	_check(_drained_ids.size() == previous_signal_count + 1, "duplicate release emits no extra drained signal")
	return true


func _check(condition: bool, message: String) -> bool:
	if not condition:
		_failures += 1
		push_error("FAILED: " + message)
	return condition
