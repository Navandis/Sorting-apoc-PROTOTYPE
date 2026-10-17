extends RefCounted

## Value/reference validation only; reconstruction never replays scenario commands.
const Scenario = preload("res://gameplay/run/run_scenario.gd")
const Clock = preload("res://gameplay/run/run_clock.gd")
const Catalog = preload("res://prototype_item_catalog.gd")
var _error := ""

func fields(value: Variant, shape: Dictionary, label: String) -> bool:
	if not value is Dictionary:
		_error = label + " must be a record"
		return false
	for key: String in shape:
		if not value.has(key) or typeof(value[key]) != shape[key]:
			_error = label + ": missing or invalid " + key
			return false
	return true

func validate(state: Dictionary) -> String:
	_error = ""
	if not fields(state.clock, {"config":TYPE_DICTIONARY,"elapsed":TYPE_FLOAT,"day":TYPE_INT}, "Clock"): return _error
	var saved: Dictionary = state.schedule
	if not fields(saved, {"definition":TYPE_DICTIONARY,"requests":TYPE_ARRAY,"issued":TYPE_DICTIONARY,
		"admissions":TYPE_ARRAY,"phase":TYPE_STRING,"resolved_day":TYPE_INT,"report":TYPE_DICTIONARY,"error":TYPE_STRING}, "Schedule"): return _error
	var invalid := Scenario.new().validate(saved.definition)
	if not invalid.is_empty(): return invalid
	if state.run.scenario != saved.definition.id or state.clock.config != saved.definition.config: return "Saved scenario/clock configuration mismatch"
	var clock = Clock.new()
	clock.restore_state(state.clock)
	if not is_finite(clock.elapsed) or clock.day < 1 or clock.day_elapsed() < 0.0 or clock.until_midnight() == 0.0 or state.run.gameplay_seconds != clock.elapsed:
		return "Inconsistent active elapsed/calendar coordinates"
	if saved.phase not in ["ACTIVE", "REPORT_PENDING"] or saved.resolved_day != clock.day - 1 or not saved.error.is_empty(): return "Inconsistent day resolution/phase"
	if saved.phase == "REPORT_PENDING" and clock.day_elapsed() != 0.0: return "Report-pending state advanced behind report"
	var events: Dictionary = {}
	for event: Dictionary in saved.definition.events: events[event.id] = event
	for id: String in saved.issued:
		if not events.has(id) or not saved.issued[id] is Dictionary: return "Unknown issued occurrence"
		var issued: Dictionary = saved.issued[id]
		var event: Dictionary = events[id]
		if not issued.get("at") is float or issued.at != clock.timestamp(event.day, event.at) or issued.at > clock.elapsed: return "Occurrence timestamp mismatch"
		var reference := "request" if event.kind == "medical" else "batch"
		if not issued.get(reference) is String or not issued[reference].begins_with(state.run.id + (":medical:" if event.kind == "medical" else ":cargo:")): return "Invalid occurrence identity"
	for event: Dictionary in saved.definition.events:
		if (clock.timestamp(event.day, event.at) <= clock.elapsed) != saved.issued.has(event.id): return "Missed or premature scenario occurrence"
	var spent: Dictionary = {}
	var ids: Dictionary = {}
	var occurrences: Dictionary = {}
	var active := 0
	for request: Variant in saved.requests:
		if not fields(request, {"id":TYPE_STRING,"destination":TYPE_STRING,"targets":TYPE_DICTIONARY,"credited":TYPE_DICTIONARY,"spent":TYPE_ARRAY,"closed":TYPE_BOOL,"result":TYPE_DICTIONARY,
			"occurrence_id":TYPE_STRING,"day":TYPE_INT,"opened_at":TYPE_FLOAT,"deadline":TYPE_FLOAT,"closed_at":TYPE_FLOAT,"closure_reason":TYPE_STRING}, "Timed request"): return _error
		if ids.has(request.id) or occurrences.has(request.occurrence_id) or not events.has(request.occurrence_id): return "Duplicate or unknown request occurrence"
		ids[request.id] = true
		occurrences[request.occurrence_id] = request
		var event: Dictionary = events[request.occurrence_id]
		if event.kind != "medical" or not saved.issued.has(event.id) or saved.issued[event.id].request != request.id or request.day != event.day or request.destination != "medical_bay" or request.targets != event.targets or request.opened_at != clock.timestamp(event.day, event.at) or request.deadline != clock.timestamp(event.day, event.deadline): return "Request/definition binding mismatch"
		if not fields(request.credited, {"Medical":TYPE_INT}, "Medical credit"): return _error
		var total := 0
		for receipt: Variant in request.spent:
			if not fields(receipt, {"item_id":TYPE_STRING,"definition_id":TYPE_STRING,"lane":TYPE_STRING,"applied":TYPE_INT,"wasted":TYPE_INT}, "Contribution receipt"): return _error
			if receipt.item_id.is_empty() or spent.has(receipt.item_id) or state.items.has(receipt.item_id) or receipt.lane != "Medical" or receipt.applied <= 0 or receipt.wasted < 0 or receipt.definition_id in ["loot_000034","loot_000036"] or Catalog.get_definition_by_id(StringName(receipt.definition_id)) == null: return "Inconsistent cross-history spent-item receipt"
			spent[receipt.item_id] = true
			total += int(receipt.applied)
		var target: int = request.targets.Medical
		if total != request.credited.Medical or total > target: return "Inconsistent historical Medical credit"
		if request.closed:
			if request.result != {"Medical":{"required":target,"supplied":total,"unmet":target-total}}: return "Inconsistent request result"
			if request.closure_reason == "fulfilled":
				if total != target or request.closed_at < request.opened_at or request.closed_at >= request.deadline: return "Invalid fulfilled request timing"
			elif request.closure_reason == "expired":
				if total >= target or request.closed_at != request.deadline: return "Invalid expired request timing"
			else: return "Unsupported request closure reason"
			if request.closed_at > clock.elapsed: return "Request closed in the future"
		else:
			active += 1
			if not request.result.is_empty() or not request.closure_reason.is_empty() or request.closed_at != -1.0 or total >= target or request.opened_at > clock.elapsed or request.deadline <= clock.elapsed: return "Invalid active request"
	if active > 1: return "Multiple active Medical requests"
	for id: String in saved.issued:
		if events[id].kind == "medical" and not occurrences.has(id): return "Issued Medical occurrence has no history"
	var receiving: Dictionary = state.receiving
	if not receiving.get("admission") is Dictionary or not receiving.admission.get("returns") is Dictionary: return "Missing timed Receiving owner"
	for id: String in saved.issued:
		if events[id].kind == "return":
			var record: Variant = receiving.admission.returns.get(id)
			if not record is Dictionary or record.get("batch_id") != saved.issued[id].batch: return "Issued return has no retained admission identity"
	var admitted_ids: Dictionary = {}
	for entry: Variant in saved.admissions:
		if not fields(entry, {"team":TYPE_STRING,"batch":TYPE_STRING,"day":TYPE_INT,"at":TYPE_FLOAT}, "Admission fact"): return _error
		var record: Variant = receiving.admission.returns.get(entry.team)
		if admitted_ids.has(entry.batch) or not record is Dictionary or record.get("batch_id") != entry.batch or record.get("status") != &"ADMITTED_RETURNED" or entry.day < 1 or entry.day > clock.day or entry.at < clock.timestamp(entry.day, clock.config.day_start) or entry.at >= entry.day * clock.day_duration() or entry.at > clock.elapsed: return "Inconsistent actual admission history"
		admitted_ids[entry.batch] = true
	if saved.resolved_day == 0:
		if not saved.report.is_empty(): return "Report exists before first resolution"
	else:
		if not fields(saved.report, {"day":TYPE_INT,"medical":TYPE_ARRAY,"admitted":TYPE_ARRAY,"forfeits":TYPE_ARRAY,"backlog":TYPE_ARRAY,"scenario_complete":TYPE_BOOL}, "Night report"): return _error
		if saved.report.day != saved.resolved_day: return "Report/resolved day mismatch"
		var expected_medical: Array = []
		for request: Dictionary in saved.requests:
			if request.day == saved.resolved_day: expected_medical.append(request)
		if saved.report.medical != expected_medical: return "Report differs from retained closed results"
		var expected_admitted: Array = []
		for entry: Dictionary in saved.admissions:
			if entry.day == saved.resolved_day: expected_admitted.append(entry)
		if saved.report.admitted != expected_admitted: return "Report admission totals differ from actual facts"
		for entry: Variant in saved.report.forfeits:
			if not entry is Dictionary or receiving.admission.returns.get(entry.get("team_id")) != entry or entry.get("status") != &"FORFEITED_RETURNED": return "Invalid report forfeiture"
		var backlog_ids: Dictionary = {}
		for id: Variant in saved.report.backlog:
			if not id is String or id.is_empty() or backlog_ids.has(id): return "Invalid report backlog"
			backlog_ids[id] = true
		var complete := true
		for event: Dictionary in saved.definition.events:
			if event.day > saved.resolved_day: complete = false
		if saved.report.scenario_complete != complete: return "Invalid scenario completion report"
	return ""
