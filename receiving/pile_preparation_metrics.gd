extends RefCounted
class_name PilePreparationMetrics

var _batch_count: int = 0
var _physics_accept_count: int = 0
var _fallback_count: int = 0
var _attempts_total: int = 0
var _durations_ms: Array[int] = []
var _rejection_totals: Dictionary = {}


func record(diagnostics: PilePreparationDiagnostics) -> void:
	if diagnostics == null:
		return
	_batch_count += 1
	if diagnostics.accepted_via_physics:
		_physics_accept_count += 1
	if diagnostics.fallback_used:
		_fallback_count += 1
	_attempts_total += diagnostics.attempts_used
	_durations_ms.append(diagnostics.preparation_duration_ms)
	for reason_value: Variant in diagnostics.rejection_counts_by_reason:
		var count: int = int(diagnostics.rejection_counts_by_reason[reason_value])
		_rejection_totals[reason_value] = int(_rejection_totals.get(reason_value, 0)) + count


func snapshot() -> Dictionary:
	if _batch_count == 0:
		return {
			"batches_prepared": 0,
			"physics_accept_rate": 0.0,
			"fallback_rate": 0.0,
			"mean_attempts": 0.0,
			"p95_preparation_time": 0,
			"rejection_reason_distribution": {},
		}
	return {
		"batches_prepared": _batch_count,
		"physics_accept_rate": float(_physics_accept_count) / float(_batch_count),
		"fallback_rate": float(_fallback_count) / float(_batch_count),
		"mean_attempts": float(_attempts_total) / float(_batch_count),
		"p95_preparation_time": _p95_duration_ms(),
		"rejection_reason_distribution": _rejection_totals.duplicate(true),
	}


func _p95_duration_ms() -> int:
	var sorted_durations: Array[int] = _durations_ms.duplicate()
	sorted_durations.sort()
	var nearest_rank_index: int = int(ceil(float(sorted_durations.size()) * 0.95)) - 1
	return sorted_durations[nearest_rank_index]
