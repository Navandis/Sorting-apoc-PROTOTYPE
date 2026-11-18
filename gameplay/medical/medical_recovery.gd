extends RefCounted

const Outcomes = preload("res://gameplay/expeditions/expedition_outcomes.gd")
const LIGHT_SECONDS := 120.0
const SEVERE_SECONDS := 300.0
const SECONDS_PER_UTILITY := 10.0

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

func admit_injured(expedition_id: String, originals: Array, at: float) -> void:
	for index in originals.size():
		var health: String = originals[index].health
		if health != Outcomes.HEALTHY:
			admit(expedition_id, index, health, at)

func active_patients() -> Array:
	var patients: Array = []
	for id: String in _ordered_ids():
		patients.append(_active[id])
	return patients

func active_count() -> int:
	return _active.size()

func next_boundary_at() -> float:
	var next := INF
	for record: Dictionary in _active.values():
		next = minf(next, record.recovery_at)
	return next

static func treatment_utility(item: ItemInstance) -> int:
	if item == null or item.get_storage_category() != "Medical" or item.get_utility_id() != &"Medical" or item.get_bulk() <= 0:
		return 0
	return item.get_utility_value()

func treatment_plan(at: float, seconds: float) -> Dictionary:
	var deadlines := {}
	var budget := seconds
	var applied := 0.0
	var recovered := 0
	for id: String in _ordered_ids():
		if budget <= 0.0:
			break
		var deadline: float = _active[id].recovery_at
		var remaining := deadline - at
		if remaining <= 0.0:
			continue
		var reduction := minf(budget, remaining)
		var after := at if reduction == remaining else maxf(at, deadline - reduction)
		deadlines[id] = after
		recovered += int(after == at)
		applied += reduction
		budget -= reduction
	return {"deadlines": deadlines, "applied": applied, "wasted": budget, "recovered": recovered}

func apply_treatment(plan: Dictionary) -> void:
	for id: String in plan.deadlines:
		_active[id].recovery_at = plan.deadlines[id]

func _ordered_ids() -> Array:
	var ids := _active.keys()
	ids.sort_custom(func(a: String, b: String) -> bool:
		var first: float = _active[a].recovery_at
		var second: float = _active[b].recovery_at
		return first < second or (first == second and a < b))
	return ids

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
