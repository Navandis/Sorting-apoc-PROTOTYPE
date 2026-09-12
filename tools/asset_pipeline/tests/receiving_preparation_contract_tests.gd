extends SceneTree

const FreightBayPresentationProfileScript = preload(
	"res://receiving/freight_bay_presentation_profile.gd"
)
const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const PilePreparationDiagnosticsScript = preload(
	"res://receiving/pile_preparation_diagnostics.gd"
)
const PilePreparationJobScript = preload("res://receiving/pile_preparation_job.gd")
const PilePreparationMetricsScript = preload("res://receiving/pile_preparation_metrics.gd")


func _init() -> void:
	_test_profile_requires_identity_but_not_stage_b_geometry()
	_test_job_cannot_skip_begin_or_mutate_committed_batch()
	_test_failed_job_preserves_batch_content_and_state()
	_test_diagnostics_snapshot_stores_every_stage_a_field()
	_test_metrics_aggregate_evidence_without_mutating_gameplay_state()
	print("PASS: receiving preparation contract tests")
	quit(0)


func _batch() -> LootBatch:
	var entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("entry_0000", "batch_a:item_0000", &"loot_000001"),
		LootBatchEntryScript.new("entry_0001", "batch_a:item_0001", &"loot_000002"),
	]
	return LootBatchScript.create_committed(
		"batch_a", &"prototype", "prototype_receiving_pool:1", 5, 6, 1842, 9001, entries
	)


func _profile() -> FreightBayPresentationProfile:
	var profile: FreightBayPresentationProfile = FreightBayPresentationProfileScript.new()
	profile.profile_id = &"freight_bay_default"
	profile.revision = 3
	return profile


func _diagnostics(
	batch: LootBatch,
	attempts: int,
	physics_accepted: bool,
	fallback: bool,
	duration_ms: int,
	rejections: Dictionary
) -> PilePreparationDiagnostics:
	var diagnostics: PilePreparationDiagnostics = PilePreparationDiagnosticsScript.new()
	diagnostics.batch_id = batch.batch_id
	diagnostics.content_seed = batch.content_seed
	diagnostics.presentation_seed = batch.presentation_seed
	diagnostics.target_bulk = batch.target_bulk
	diagnostics.actual_bulk = batch.actual_bulk
	diagnostics.item_count = batch.entries.size()
	diagnostics.attempts_used = attempts
	diagnostics.accepted_via_physics = physics_accepted
	diagnostics.fallback_used = fallback
	diagnostics.preparation_duration_ms = duration_ms
	diagnostics.rejection_counts_by_reason = rejections
	diagnostics.accepted_drain_iterations = 4
	diagnostics.accepted_profile_revision = 3
	return diagnostics


func _test_profile_requires_identity_but_not_stage_b_geometry() -> void:
	var profile: FreightBayPresentationProfile = FreightBayPresentationProfileScript.new()
	var missing_id_errors: PackedStringArray = profile.validate_identity()
	assert(missing_id_errors.size() == 1)
	assert(missing_id_errors[0] == "FreightBayPresentationProfile requires profile_id.")

	profile.profile_id = &"freight_bay_default"
	profile.revision = 0
	var invalid_revision_errors: PackedStringArray = profile.validate_identity()
	assert(invalid_revision_errors.size() == 1)
	assert(
		invalid_revision_errors[0]
		== "FreightBayPresentationProfile revision must be positive."
	)

	profile.revision = 1
	assert(profile.validate_identity().is_empty())
	assert(profile.pile_bounds == AABB())
	assert(profile.deck_support_y_m == 0.0)
	assert(profile.settle_spawn_volume == AABB())
	assert(profile.temporary_proxy_collision_envelope == AABB())
	assert(profile.barrier_side_reach_envelope == AABB())
	assert(profile.drainability_viewpoints.is_empty())
	assert(profile.containment_tolerance_m == 0.01)
	assert(profile.penetration_tolerance_m == 0.01)
	assert(profile.fallback_layout_version == 1)


func _test_job_cannot_skip_begin_or_mutate_committed_batch() -> void:
	var batch: LootBatch = _batch()
	var original_snapshot: Dictionary = batch.to_snapshot()
	var job: PilePreparationJob = PilePreparationJobScript.new(batch, _profile())

	assert(job.state == PilePreparationJobScript.JobState.PENDING)
	assert(not job.mark_succeeded())
	assert(job.state == PilePreparationJobScript.JobState.PENDING)
	assert(batch.to_snapshot() == original_snapshot)
	assert(job.begin())
	assert(job.state == PilePreparationJobScript.JobState.RUNNING)
	assert(batch.to_snapshot() == original_snapshot)
	assert(job.mark_succeeded())
	assert(job.state == PilePreparationJobScript.JobState.SUCCEEDED)
	assert(batch.to_snapshot() == original_snapshot)
	assert(not job.begin())
	assert(not job.mark_failed(&"other"))

	var invalid_profile: FreightBayPresentationProfile = FreightBayPresentationProfileScript.new()
	var invalid_job: PilePreparationJob = PilePreparationJobScript.new(batch, invalid_profile)
	assert(not invalid_job.begin())
	assert(invalid_job.state == PilePreparationJobScript.JobState.PENDING)
	assert(batch.to_snapshot() == original_snapshot)


func _test_failed_job_preserves_batch_content_and_state() -> void:
	var batch: LootBatch = _batch()
	var original_snapshot: Dictionary = batch.to_snapshot()
	var job: PilePreparationJob = PilePreparationJobScript.new(batch, _profile())

	assert(job.begin())
	assert(job.mark_failed(&"unstable_timeout"))
	assert(job.state == PilePreparationJobScript.JobState.FAILED)
	assert(job.diagnostics.rejection_counts_by_reason == {&"unstable_timeout": 1})
	assert(batch.to_snapshot() == original_snapshot)
	assert(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	assert(not job.mark_failed(&"other"))
	assert(not job.mark_succeeded())


func _test_diagnostics_snapshot_stores_every_stage_a_field() -> void:
	var diagnostics: PilePreparationDiagnostics = PilePreparationDiagnosticsScript.new()
	diagnostics.batch_id = "batch_evidence"
	diagnostics.content_seed = 101
	diagnostics.presentation_seed = 202
	diagnostics.target_bulk = 12
	diagnostics.actual_bulk = 13
	diagnostics.item_count = 5
	diagnostics.attempts_used = 3
	diagnostics.accepted_via_physics = true
	diagnostics.fallback_used = false
	diagnostics.preparation_duration_ms = 47
	diagnostics.rejection_counts_by_reason = {
		&"escaped_bounds": 2,
		&"invalid_penetration": 1,
	}
	diagnostics.accepted_drain_iterations = 6
	diagnostics.accepted_profile_revision = 4

	var snapshot: Dictionary = diagnostics.to_snapshot()
	assert(snapshot.size() == 13)
	assert(snapshot == {
		"batch_id": "batch_evidence",
		"content_seed": 101,
		"presentation_seed": 202,
		"target_bulk": 12,
		"actual_bulk": 13,
		"item_count": 5,
		"attempts_used": 3,
		"accepted_via_physics": true,
		"fallback_used": false,
		"preparation_duration_ms": 47,
		"rejection_counts_by_reason": {
			&"escaped_bounds": 2,
			&"invalid_penetration": 1,
		},
		"accepted_drain_iterations": 6,
		"accepted_profile_revision": 4,
	})
	var snapshot_rejections: Dictionary = snapshot["rejection_counts_by_reason"] as Dictionary
	snapshot_rejections[&"other"] = 99
	assert(not diagnostics.rejection_counts_by_reason.has(&"other"))


func _test_metrics_aggregate_evidence_without_mutating_gameplay_state() -> void:
	var batch: LootBatch = _batch()
	var original_snapshot: Dictionary = batch.to_snapshot()
	var metrics: PilePreparationMetrics = PilePreparationMetricsScript.new()
	var empty_snapshot: Dictionary = metrics.snapshot()
	assert(empty_snapshot == {
		"batches_prepared": 0,
		"physics_accept_rate": 0.0,
		"fallback_rate": 0.0,
		"mean_attempts": 0.0,
		"p95_preparation_time": 0,
		"rejection_reason_distribution": {},
	})

	metrics.record(_diagnostics(
		batch, 1, true, false, 10, {&"escaped_bounds": 1}
	))
	metrics.record(_diagnostics(
		batch, 2, true, false, 20, {&"escaped_bounds": 2, &"other": 1}
	))
	metrics.record(_diagnostics(
		batch, 3, false, true, 30, {&"unstable_timeout": 3}
	))
	metrics.record(_diagnostics(
		batch, 4, false, true, 100, {&"other": 2}
	))

	var snapshot: Dictionary = metrics.snapshot()
	assert(snapshot["batches_prepared"] == 4)
	assert(is_equal_approx(float(snapshot["physics_accept_rate"]), 0.5))
	assert(is_equal_approx(float(snapshot["fallback_rate"]), 0.5))
	assert(is_equal_approx(float(snapshot["mean_attempts"]), 2.5))
	assert(snapshot["p95_preparation_time"] == 100)
	assert(snapshot["rejection_reason_distribution"] == {
		&"escaped_bounds": 3,
		&"unstable_timeout": 3,
		&"other": 3,
	})
	assert(not snapshot.has("fallback_rate_threshold"))
	assert(batch.to_snapshot() == original_snapshot)
