extends Node
class_name AwaitingLiftAdmission

## Upstream prototype team-return seam. Only the manager owns deposited slots.
## Caller keeps no right to change/reuse a submitted commitment. No clock or roster.
const DeckProfileScript = preload("res://receiving/receiving_deck_profile.gd")
enum ReturnResult { INVALID, ADMITTED, AWAITING }
const AWAITING_LIFT: StringName = &"AWAITING_LIFT"
const ADMITTED_RETURNED: StringName = &"ADMITTED_RETURNED"
const FORFEITED_RETURNED: StringName = &"FORFEITED_RETURNED"
const INVALID_RETURN: StringName = &"INVALID_RETURN"

signal return_admitted(team_id: String, batch_id: String)
signal return_awaiting_lift(team_id: String, batch_id: String)
signal return_admitted_after_waiting(team_id: String, batch_id: String)
signal return_forfeited_at_midnight(team_id: String, batch_id: String)
signal return_invalidated(team_id: String, batch_id: String, reason: String)

var _manager: ReceivingManager
var _catalog: ItemCatalog
var _profile: Resource
# Terminal records retain identities/status only, never loot objects/layouts.
var _returns: Dictionary = {}
var _batch_teams: Dictionary = {}
var _awaiting: Array[Dictionary] = []
var _pass_scheduled := false
var _admitting := false


func capture_state() -> Dictionary:
	var pending: Array[Dictionary] = []
	for entry: Dictionary in _awaiting:
		pending.append({"team": entry.team_id, "batch": entry.batch.to_snapshot(), "commitment": bytes_to_var(entry.commitment)})
	return {"returns": _returns.duplicate(true), "batch_teams": _batch_teams.duplicate(), "pending": pending}


func restore_state(state: Dictionary, batches: Dictionary) -> void:
	_returns = state.returns.duplicate(true)
	_batch_teams = state.batch_teams.duplicate()
	_awaiting.clear()
	for entry: Dictionary in state.pending:
		_awaiting.append({"team_id": entry.team, "batch_id": entry.batch.batch_id,
			"batch": batches[entry.batch.batch_id], "commitment": var_to_bytes(batches[entry.batch.batch_id].to_snapshot())})
	_pass_scheduled = false
	_admitting = false
	# Deferred scheduling resumes ordinary fairness only after reconstruction.
	_schedule_admission.call_deferred()


func configure(manager: ReceivingManager, catalog: ItemCatalog, profile: Resource) -> bool:
	if _manager != null or manager == null or catalog == null or profile == null:
		return false
	if profile.get_script() != DeckProfileScript or not (profile.call("validate") as PackedStringArray).is_empty() or not catalog.get_validation_errors().is_empty():
		return false
	_manager = manager
	_catalog = catalog
	_profile = profile
	_manager.contents_changed.connect(_schedule_admission)
	return true


func submit_return(team_id: String, batch: LootBatch) -> ReturnResult:
	if not is_instance_valid(_manager) or team_id.is_empty() or _returns.has(team_id):
		return ReturnResult.INVALID
	if not _is_compatible_prepared(batch) or _batch_teams.has(batch.batch_id):
		return ReturnResult.INVALID
	var eligibility := _manager.get_deposit_eligibility(batch)
	if eligibility == ReceivingManager.DepositEligibility.INVALID:
		return ReturnResult.INVALID
	# Reserve both identities before any synchronous manager/lifecycle callback.
	_batch_teams[batch.batch_id] = team_id
	_returns[team_id] = {"team_id": team_id, "batch_id": batch.batch_id, "status": AWAITING_LIFT}
	if eligibility == ReceivingManager.DepositEligibility.CAPACITY_FULL or not _awaiting.is_empty() or _admitting:
		_awaiting.append({"team_id": team_id, "batch_id": batch.batch_id, "batch": batch, "commitment": var_to_bytes(batch.to_snapshot())})
		return_awaiting_lift.emit(team_id, batch.batch_id)
		_schedule_admission()
		return ReturnResult.AWAITING
	_admitting = true
	var admitted := _deposit(team_id, batch, false)
	_admitting = false
	_schedule_admission()
	return ReturnResult.ADMITTED if admitted else ReturnResult.INVALID


## Copies contain identities/status only; no mutable batch or FIFO access.
func get_awaiting_returns() -> Array[Dictionary]:
	var snapshot: Array[Dictionary] = []
	for pending: Dictionary in _awaiting:
		snapshot.append(get_return_snapshot(pending.team_id))
	return snapshot


func get_return_snapshot(team_id: String) -> Dictionary:
	return (_returns.get(team_id, {}) as Dictionary).duplicate()


func get_return_status(team_id: String) -> StringName:
	return StringName((_returns.get(team_id, {}) as Dictionary).get("status", &"UNKNOWN"))


## Explicit event ordering: never flush a deferred admission here. A completed
## admission wins; midnight before the pass wins for every still-pending record.
func resolve_awaiting_lift_at_midnight() -> Array[Dictionary]:
	var forfeits: Array[Dictionary] = []
	var pending_at_midnight := _awaiting
	_awaiting = []
	# Resolve all identities before emitting callbacks; reentrant midnight is inert.
	for pending: Dictionary in pending_at_midnight:
		_returns[pending.team_id].status = FORFEITED_RETURNED
		forfeits.append(get_return_snapshot(pending.team_id))
	pending_at_midnight.clear() # Drop the only upstream batch/layout references.
	for record: Dictionary in forfeits:
		return_forfeited_at_midnight.emit(record.team_id, record.batch_id)
	return forfeits


func resume_after_pause() -> void:
	_schedule_admission()


func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		_schedule_admission.call_deferred()


func _schedule_admission() -> void:
	if is_inside_tree() and get_tree().paused:
		return
	if _pass_scheduled or _admitting or _awaiting.is_empty() or not is_instance_valid(_manager) or not _manager.has_deposit_capacity():
		return
	_pass_scheduled = true
	_admit_awaiting.call_deferred()


func _admit_awaiting() -> void:
	_pass_scheduled = false
	if is_inside_tree() and get_tree().paused:
		return
	if _admitting or not is_instance_valid(_manager):
		return
	_admitting = true
	# Fixed starting budget: callbacks cannot grow this pass indefinitely.
	var budget := _awaiting.size()
	for attempt in budget:
		if _awaiting.is_empty() or not _manager.has_deposit_capacity():
			break
		var pending: Dictionary = _awaiting.pop_front()
		var batch: LootBatch = pending.batch
		if not _is_compatible_prepared(batch) or var_to_bytes(batch.to_snapshot()) != pending.commitment:
			_invalidate(pending.team_id, pending.batch_id, "awaiting commitment changed or became incompatible")
			continue
		_deposit(pending.team_id, batch, true)
	_admitting = false
	_schedule_admission()


func _deposit(team_id: String, batch: LootBatch, waited: bool) -> bool:
	# State is visible before the manager's synchronous contents callbacks.
	_returns[team_id].status = ADMITTED_RETURNED
	if not _manager.deposit_batch(batch):
		_invalidate(team_id, batch.batch_id, "eligible deposit unexpectedly rejected")
		return false
	if waited:
		return_admitted_after_waiting.emit(team_id, batch.batch_id)
	else:
		return_admitted.emit(team_id, batch.batch_id)
	return true


func _invalidate(team_id: String, batch_id: String, reason: String) -> void:
	_returns[team_id].status = INVALID_RETURN
	_returns[team_id]["reason"] = reason
	push_error("Awaiting Lift invalid return team=%s batch=%s: %s" % [team_id, batch_id, reason])
	return_invalidated.emit(team_id, batch_id, reason)


func _is_compatible_prepared(batch: LootBatch) -> bool:
	if batch == null or batch.preparation_state != LootBatch.STATE_PREPARED or batch.is_drained() or batch.batch_id.is_empty():
		return false
	if batch.presentation_profile_id != _profile.get("profile_id") or batch.presentation_profile_revision != int(_profile.get("revision")):
		return false
	var surface_ids: Dictionary = {}
	for surface: Resource in _profile.get("surfaces"):
		if bool(surface.get("enabled")):
			surface_ids[surface.get("surface_id")] = true
	for fixture: ReceivingFreightFixtureInstance in batch.presentation_fixtures:
		var compatible := false
		for definition: Resource in _profile.get("freight_fixture_definitions"):
			if bool(definition.get("enabled")) and definition.get("fixture_id") == fixture.fixture_definition_id:
				compatible = true
		if not compatible:
			return false
		surface_ids[fixture.surface_id] = true
	for entry: LootBatchEntry in batch.entries:
		if not entry.remaining_in_batch or not entry.has_deck_layout or not surface_ids.has(entry.presentation_surface_id) or _catalog.get_definition_by_id(entry.definition_id) == null:
			return false
	return true
