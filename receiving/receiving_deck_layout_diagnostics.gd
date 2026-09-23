extends RefCounted
class_name ReceivingDeckLayoutDiagnostics

var succeeded: bool = false
var failure_reason: StringName = &""
var attempts_used: int = 0
var placements_by_entry_id: Dictionary = {}


func mark_success(attempt_count: int, placements: Dictionary) -> void:
	succeeded = true
	failure_reason = &""
	attempts_used = attempt_count
	placements_by_entry_id = placements.duplicate(true)


func mark_failure(reason: StringName, attempt_count: int) -> void:
	succeeded = false
	failure_reason = reason
	attempts_used = attempt_count
	placements_by_entry_id.clear()


func to_snapshot() -> Dictionary:
	return {
		"succeeded": succeeded,
		"failure_reason": failure_reason,
		"attempts_used": attempts_used,
		"placements_by_entry_id": placements_by_entry_id.duplicate(true),
	}
