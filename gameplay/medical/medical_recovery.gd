extends RefCounted

const Outcomes = preload("res://gameplay/expeditions/expedition_outcomes.gd")
const LIGHT_SECONDS := 120.0
const SEVERE_SECONDS := 300.0

var _patients: Dictionary = {}
var _active: Dictionary = {}

static func patient_id(expedition_id: String, member_index: int) -> String:
	return "%s:patient:%d" % [expedition_id, member_index]

static func patient_record(severity: String, admitted_at: float) -> Dictionary:
	var duration := LIGHT_SECONDS if severity == Outcomes.LIGHT else SEVERE_SECONDS
	return {"severity": severity, "admitted_at": admitted_at, "recovery_at": admitted_at + duration, "recovered": false}

func admit(expedition_id: String, member_index: int, severity: String, at: float) -> void:
	var id := patient_id(expedition_id, member_index)
	assert(not _patients.has(id) and severity in [Outcomes.LIGHT, Outcomes.SEVERE])
	var record := patient_record(severity, at)
	_patients[id] = record
	_active[id] = record

func active_patients() -> Array:
	return _active.values()

func active_count() -> int:
	return _active.size()

func next_boundary_at() -> float:
	var next := INF
	for record: Dictionary in _active.values():
		next = minf(next, record.recovery_at)
	return next

func settle_due(elapsed: float) -> int:
	var recovered := 0
	for id: String in _active.keys():
		var record: Dictionary = _active[id]
		if record.recovery_at <= elapsed:
			record.recovered = true
			_active.erase(id)
			recovered += 1
	return recovered

func capture_state() -> Dictionary:
	return _patients.duplicate(true)

func restore_state(state: Dictionary) -> void:
	_patients = state.duplicate(true)
	_active.clear()
	for id: String in _patients:
		var record: Dictionary = _patients[id]
		if not record.recovered:
			_active[id] = record
