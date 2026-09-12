extends RefCounted
class_name PilePreparationDiagnostics

var batch_id: String = ""
var content_seed: int = 0
var presentation_seed: int = 0
var target_bulk: int = 0
var actual_bulk: int = 0
var item_count: int = 0
var attempts_used: int = 0
var accepted_via_physics: bool = false
var fallback_used: bool = false
var preparation_duration_ms: int = 0
var rejection_counts_by_reason: Dictionary = {}
var accepted_drain_iterations: int = 0
var accepted_profile_revision: int = 0


func to_snapshot() -> Dictionary:
	return {
		"batch_id": batch_id,
		"content_seed": content_seed,
		"presentation_seed": presentation_seed,
		"target_bulk": target_bulk,
		"actual_bulk": actual_bulk,
		"item_count": item_count,
		"attempts_used": attempts_used,
		"accepted_via_physics": accepted_via_physics,
		"fallback_used": fallback_used,
		"preparation_duration_ms": preparation_duration_ms,
		"rejection_counts_by_reason": rejection_counts_by_reason.duplicate(true),
		"accepted_drain_iterations": accepted_drain_iterations,
		"accepted_profile_revision": accepted_profile_revision,
	}
