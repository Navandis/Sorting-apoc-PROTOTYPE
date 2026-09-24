extends RefCounted
class_name ReceivingDeckLayoutDiagnostics

var succeeded: bool = false
var failure_reason: StringName = &""
var attempts_used: int = 0
var placements_by_entry_id: Dictionary = {}
var fixture_mode: int = 0
var crate_count: int = 0
var pallet_count: int = 0
var fixture_ids: Array[String] = []
var surface_item_counts: Dictionary = {}


func mark_success(
	attempt_count: int,
	placements: Dictionary,
	fixtures: Array = [],
	item_counts: Dictionary = {}
) -> void:
	succeeded = true
	failure_reason = &""
	attempts_used = attempt_count
	placements_by_entry_id = placements.duplicate(true)
	crate_count = 0
	pallet_count = 0
	fixture_ids.clear()
	for fixture_value: Variant in fixtures:
		var fixture = fixture_value
		fixture_ids.append(fixture.instance_id)
		if int(fixture.family) == 0:
			crate_count += 1
		else:
			pallet_count += 1
	surface_item_counts = item_counts.duplicate(true)


func mark_failure(reason: StringName, attempt_count: int) -> void:
	succeeded = false
	failure_reason = reason
	attempts_used = attempt_count
	placements_by_entry_id.clear()
	crate_count = 0
	pallet_count = 0
	fixture_ids.clear()
	surface_item_counts.clear()


func to_snapshot() -> Dictionary:
	return {
		"succeeded": succeeded,
		"failure_reason": failure_reason,
		"attempts_used": attempts_used,
		"placements_by_entry_id": placements_by_entry_id.duplicate(true),
		"fixture_mode": fixture_mode,
		"crate_count": crate_count,
		"pallet_count": pallet_count,
		"fixture_ids": fixture_ids.duplicate(),
		"surface_item_counts": surface_item_counts.duplicate(true),
	}
