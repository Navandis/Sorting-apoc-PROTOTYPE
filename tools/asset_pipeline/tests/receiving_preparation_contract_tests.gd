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


# A runtime abort can return from a helper to its caller in Godot. Every
# test or fixture helper stays pending until its final statement is reached.
var _failures: int = 0
var _pending_helpers: int = 0


func _init() -> void:
	_run_suite()
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving preparation contract tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving preparation contract tests")
	quit(0)


func _run_suite() -> void:
	_pending_helpers += 1
	_test_profile_requires_identity_but_not_stage_b_geometry()
	_test_job_cannot_skip_begin_or_mutate_committed_batch()
	_test_failed_job_preserves_batch_content_and_state()
	_test_diagnostics_snapshot_stores_every_stage_a_field()
	_test_metrics_aggregate_evidence_without_mutating_gameplay_state()
	_test_metrics_p95_uses_sorted_nearest_rank_below_maximum()
	_pending_helpers -= 1


func _batch() -> LootBatch:
	_pending_helpers += 1
	var entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("entry_0000", "batch_a:item_0000", &"loot_000001"),
		LootBatchEntryScript.new("entry_0001", "batch_a:item_0001", &"loot_000002"),
	]
	var completed_result: LootBatch = LootBatchScript.create_committed(
		"batch_a", &"prototype", "prototype_receiving_pool:1", 5, 6, 1842, 9001, entries
	)
	_pending_helpers -= 1
	return completed_result


func _profile() -> FreightBayPresentationProfile:
	_pending_helpers += 1
	var profile: FreightBayPresentationProfile = FreightBayPresentationProfileScript.new()
	profile.profile_id = &"freight_bay_default"
	profile.revision = 3
	var completed_result: FreightBayPresentationProfile = profile
	_pending_helpers -= 1
	return completed_result


func _diagnostics(
	batch: LootBatch,
	attempts: int,
	physics_accepted: bool,
	fallback: bool,
	duration_ms: int,
	rejections: Dictionary
) -> PilePreparationDiagnostics:
	_pending_helpers += 1
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
	var completed_result: PilePreparationDiagnostics = diagnostics
	_pending_helpers -= 1
	return completed_result


func _test_profile_requires_identity_but_not_stage_b_geometry() -> void:
	_pending_helpers += 1
	var profile: FreightBayPresentationProfile = FreightBayPresentationProfileScript.new()
	var missing_id_errors: PackedStringArray = profile.validate_identity()
	_check(missing_id_errors.size() == 1)
	_check(missing_id_errors[0] == "FreightBayPresentationProfile requires profile_id.")

	profile.profile_id = &"freight_bay_default"
	profile.revision = 0
	var invalid_revision_errors: PackedStringArray = profile.validate_identity()
	_check(invalid_revision_errors.size() == 1)
	_check(
		invalid_revision_errors[0]
		== "FreightBayPresentationProfile revision must be positive."
	)

	profile.revision = 1
	_check(profile.validate_identity().is_empty())
	_check(profile.pile_bounds == AABB())
	_check(profile.deck_support_y_m == 0.0)
	_check(profile.settle_spawn_volume == AABB())
	_check(profile.temporary_proxy_collision_envelope == AABB())
	_check(profile.barrier_side_reach_envelope == AABB())
	_check(profile.drainability_viewpoints.is_empty())
	_check(profile.containment_tolerance_m == 0.01)
	_check(profile.penetration_tolerance_m == 0.01)
	_check(profile.fallback_layout_version == 1)
	_pending_helpers -= 1


func _test_job_cannot_skip_begin_or_mutate_committed_batch() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var original_snapshot: Dictionary = batch.to_snapshot()
	var job: PilePreparationJob = PilePreparationJobScript.new(batch, _profile())

	_check(job.state == PilePreparationJobScript.JobState.PENDING)
	_check(not job.mark_succeeded())
	_check(job.state == PilePreparationJobScript.JobState.PENDING)
	_check(batch.to_snapshot() == original_snapshot)
	_check(job.begin())
	_check(job.state == PilePreparationJobScript.JobState.RUNNING)
	_check(batch.to_snapshot() == original_snapshot)
	_check(job.mark_succeeded())
	_check(job.state == PilePreparationJobScript.JobState.SUCCEEDED)
	_check(batch.to_snapshot() == original_snapshot)
	_check(not job.begin())
	_check(not job.mark_failed(&"other"))

	var invalid_profile: FreightBayPresentationProfile = FreightBayPresentationProfileScript.new()
	var invalid_job: PilePreparationJob = PilePreparationJobScript.new(batch, invalid_profile)
	_check(not invalid_job.begin())
	_check(invalid_job.state == PilePreparationJobScript.JobState.PENDING)
	_check(batch.to_snapshot() == original_snapshot)
	_pending_helpers -= 1


func _test_failed_job_preserves_batch_content_and_state() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var original_snapshot: Dictionary = batch.to_snapshot()
	var job: PilePreparationJob = PilePreparationJobScript.new(batch, _profile())

	_check(job.begin())
	_check(job.mark_failed(&"unstable_timeout"))
	_check(job.state == PilePreparationJobScript.JobState.FAILED)
	_check(job.diagnostics.rejection_counts_by_reason == {&"unstable_timeout": 1})
	_check(batch.to_snapshot() == original_snapshot)
	_check(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	_check(not job.mark_failed(&"other"))
	_check(not job.mark_succeeded())
	_pending_helpers -= 1


func _test_diagnostics_snapshot_stores_every_stage_a_field() -> void:
	_pending_helpers += 1
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
	_check(snapshot.size() == 13)
	_check(snapshot == {
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
	_check(not diagnostics.rejection_counts_by_reason.has(&"other"))
	_pending_helpers -= 1


func _test_metrics_aggregate_evidence_without_mutating_gameplay_state() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var original_snapshot: Dictionary = batch.to_snapshot()
	var metrics: PilePreparationMetrics = PilePreparationMetricsScript.new()
	var empty_snapshot: Dictionary = metrics.snapshot()
	_check(empty_snapshot == {
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
	_check(snapshot["batches_prepared"] == 4)
	_check(is_equal_approx(float(snapshot["physics_accept_rate"]), 0.5))
	_check(is_equal_approx(float(snapshot["fallback_rate"]), 0.5))
	_check(is_equal_approx(float(snapshot["mean_attempts"]), 2.5))
	_check(snapshot["p95_preparation_time"] == 100)
	_check(snapshot["rejection_reason_distribution"] == {
		&"escaped_bounds": 3,
		&"unstable_timeout": 3,
		&"other": 3,
	})
	_check(not snapshot.has("fallback_rate_threshold"))
	_check(batch.to_snapshot() == original_snapshot)
	_pending_helpers -= 1


# Catches replacing p95 with maximum, omitting sorting, or choosing rank 20.
func _test_metrics_p95_uses_sorted_nearest_rank_below_maximum() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var metrics: PilePreparationMetrics = PilePreparationMetricsScript.new()
	var durations: Array[int] = [120, 30, 200, 60, 10, 180, 90, 150, 40, 110, 170, 20, 140, 80, 190, 50, 130, 100, 70, 160]
	for duration: int in durations:
		metrics.record(_diagnostics(batch, 1, true, false, duration, {}))
	var snapshot: Dictionary = metrics.snapshot()
	_check(snapshot["batches_prepared"] == 20)
	# Sorted values are 10..200 by tens; nearest rank ceil(20 * .95) is 19.
	_check(snapshot["p95_preparation_time"] == 190, "p95 is the nineteenth sorted observation, below maximum 200")
	_pending_helpers -= 1


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition
