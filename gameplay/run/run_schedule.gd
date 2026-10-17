extends RefCounted

signal night_started
signal night_ready

const Clock = preload("res://gameplay/run/run_clock.gd")
const Scenario = preload("res://gameplay/run/run_scenario.gd")
const Request = preload("res://gameplay/requests/contribution_request.gd")
var clock = Clock.new()
var definition: Dictionary = {}
var requests: Array = []
var issued: Dictionary = {}
var admissions: Array = []
var phase := "ACTIVE"
var resolved_day := 0
var report: Dictionary = {}
var error := ""
var transition_metrics: Dictionary = {}
var _wing: Node
var _runtime: Node

func initialize(authored: Dictionary = {}) -> String:
	definition = (Scenario.new().default_definition() if authored.is_empty() else authored).duplicate(true)
	error = Scenario.new().validate(definition)
	if error.is_empty(): clock.config = definition.config.duplicate(true)
	return error

func bind(wing: Node) -> void:
	_wing = wing
	_runtime = wing.get_node("ReceivingRuntime")
	_runtime.lift_cycle.externally_driven = true
	_runtime.return_admission.return_admitted.connect(_record_admission)
	_runtime.return_admission.return_admitted_after_waiting.connect(_record_admission)
	if not wing.restoring and error.is_empty():
		for event: Dictionary in definition.events:
			if event.kind == "return" and not _runtime.can_prepare_manifest(event.manifest, event.id, event.presentation_seed):
				error = "Authored cargo cannot be prepared: " + event.id
				return
	for request: RefCounted in requests:
		request.time_source = clock.current_time
		request.item_already_spent = has_spent_item
	if not wing.restoring and error.is_empty(): _activate_due()
	_bind_stations()

func current_time() -> float:
	return clock.elapsed

func latest_request(destination: String = "medical_bay") -> RefCounted:
	for index: int in range(requests.size()-1,-1,-1):
		if requests[index].destination == destination: return requests[index]
	return null

func active_request(destination: String = "medical_bay") -> RefCounted:
	for request: RefCounted in requests:
		if request.destination == destination and request.is_accepting(): return request
	return null

func has_spent_item(id: String) -> bool:
	for request: RefCounted in requests:
		for receipt: Dictionary in request.spent:
			if receipt.item_id == id: return true
	return false

func _bind_stations() -> void:
	_wing.medical_request = latest_request()
	var interface := _wing.get_node_or_null("MedicalContribution")
	if interface != null: interface.bind_request(active_request())
	interface = _wing.get_node_or_null("KitchenContribution")
	if interface != null: interface.bind_request(active_request("kitchen"))

func advance(delta: float) -> void:
	if phase != "ACTIVE" or not error.is_empty() or not is_finite(delta) or delta < 0.0: return
	if _wing.is_inside_tree() and _wing.get_tree().paused: return
	# Anchor the final calendar coordinate once, while preserving the exact
	# remaining delta for mechanics. Repeated subtraction can undershoot an
	# authored time; subtracting a rounded calendar endpoint can shorten a phase.
	var endpoint: float = minf(clock.elapsed + delta, clock.day * clock.day_duration())
	var remaining := delta
	# Deferred vacancy work from the preceding frame belongs to the current time.
	_runtime.return_admission.settle_before_boundary()
	while remaining > 0.0 and phase == "ACTIVE" and error.is_empty():
		_close_due()
		_activate_due()
		var until_night: float = clock.until_midnight()
		var step := minf(remaining, until_night)
		step = minf(step, _until_event())
		step = minf(step, _runtime.lift_cycle.seconds_to_boundary())
		clock.advance(step)
		if step == remaining: clock.elapsed = endpoint
		_runtime.lift_cycle.advance_time(step, false)
		remaining = maxf(0.0, remaining-step)
		if clock.until_midnight() == 0.0:
			_resolve_midnight()
			return
		var before: Dictionary = _runtime.lift_cycle.capture_state()
		_runtime.lift_cycle.settle_boundary()
		_runtime.return_admission.settle_before_boundary()
		_close_due()
		_activate_due()
		if step == 0.0 and before == _runtime.lift_cycle.capture_state():
			_fail("A mechanical boundary could not settle; simulation held")
			return
	_bind_stations()

func _until_event() -> float:
	var until := INF
	for event: Dictionary in definition.events:
		if not issued.has(event.id):
			until = minf(until, maxf(0.0, clock.timestamp(event.day, event.at) - clock.elapsed))
	for request: RefCounted in requests:
		if not request.closed: until = minf(until, maxf(0.0, request.deadline - clock.elapsed))
	return until

func _close_due() -> void:
	var due: Array = []
	for request: RefCounted in requests:
		if not request.closed and request.deadline <= clock.elapsed:
			due.append({"id":request.occurrence_id, "opened_at":request.opened_at, "request":request})
	due.sort_custom(Scenario.new().closure_before)
	for entry: Dictionary in due: entry.request.expire(clock.elapsed)
	_bind_stations()

func _activate_due() -> void:
	var due: Array = []
	for event: Dictionary in definition.events:
		if not issued.has(event.id) and clock.timestamp(event.day, event.at) <= clock.elapsed: due.append(event)
	due.sort_custom(Scenario.new().activation_before)
	for event: Dictionary in due:
		if event.kind in ["medical","kitchen"]:
			var request = Request.new(_wing.run_identity.allocate(event.kind), Scenario.new().destination_for(event.kind), event.targets)
			request.occurrence_id = event.id
			request.day = event.day
			request.opened_at = clock.elapsed
			request.deadline = clock.timestamp(event.day, event.deadline)
			request.time_source = clock.current_time
			request.item_already_spent = has_spent_item
			requests.append(request)
			issued[event.id] = {"at":clock.elapsed, "request":request.request_id}
		else:
			var batch: LootBatch = _runtime.prepare_manifest(event.manifest, event.id, event.presentation_seed)
			if batch == null:
				_fail("Authored manifest could not be prepared: " + event.id)
				return
			issued[event.id] = {"at":clock.elapsed, "batch":batch.batch_id}
			if _runtime.return_admission.submit_return(event.id, batch) == AwaitingLiftAdmission.ReturnResult.INVALID:
				_fail("Prepared authored return was rejected: " + event.id)
				return
	_bind_stations()

func _record_admission(team: String, batch: String) -> void:
	admissions.append({"team":team, "batch":batch, "day":clock.day, "at":clock.elapsed})

func _resolve_midnight() -> void:
	var started := Time.get_ticks_usec()
	night_started.emit() # Shell blocks input/acquires hold before exact-time mechanics.
	_wing.get_node("Player").set_world_input_blocked(true)
	_runtime.return_admission.admission_open = false
	var forfeits: Array = _runtime.return_admission.resolve_awaiting_lift_at_midnight()
	_runtime.lift_cycle.settle_boundary()
	_close_due()
	var medical: Array = []
	for request: RefCounted in requests:
		if request.day == clock.day and request.destination == "medical_bay": medical.append(request.capture_state())
	var meals := meal_records_for_day(clock.day)
	var admitted: Array = []
	for entry: Dictionary in admissions:
		if entry.day == clock.day: admitted.append(entry.duplicate(true))
	var manager = _runtime.receiving_manager
	var backlog: Array = []
	if not manager.get_active_batch_id().is_empty(): backlog.append(manager.get_active_batch_id())
	backlog.append_array(Array(manager.get_queued_batch_ids()))
	report = {"day":clock.day, "medical":medical, "meals":meals, "meal_coverage":meal_coverage(meals), "admitted":admitted,
		"forfeits":forfeits.duplicate(true), "backlog":backlog, "scenario_complete":scenario_complete_at(clock.day + 1)}
	resolved_day = clock.day
	clock.begin_next_day()
	_runtime.return_admission.admission_open = true
	_activate_due()
	_runtime.return_admission.admission_open = false
	phase = "REPORT_PENDING"
	transition_metrics = {"resolution_ms":(Time.get_ticks_usec() - started) / 1000.0}
	night_ready.emit()

func begin_day() -> void:
	if phase != "REPORT_PENDING": return
	phase = "ACTIVE"
	_runtime.return_admission.admission_open = true
	# The shell releases only its report pause. Ordinary unpause schedules admission.
	if not _wing.get_tree().paused:
		_wing.get_node("Player").set_world_input_blocked(false)
		_runtime.return_admission.resume_after_pause()

func scenario_complete_at(day: int) -> bool:
	for event: Dictionary in definition.events:
		if event.day >= day: return false
	return true

func meal_records_for_day(day: int) -> Array:
	var meals: Array = []
	for event: Dictionary in definition.events:
		if event.kind != "kitchen" or event.day != day: continue
		for request: RefCounted in requests:
			if request.occurrence_id == event.id:
				var record: Dictionary = request.capture_state()
				record["meal"] = event.meal
				meals.append(record)
	meals.sort_custom(func(a,b): return a.opened_at < b.opened_at)
	return meals

static func meal_coverage(meals: Array) -> Variant:
	if meals.is_empty(): return null
	var coverage := 0.0
	for meal: Dictionary in meals:
		for lane: String in ["Food","Hydration"]:
			coverage += minf(1.0,float(meal.credited[lane])/float(meal.targets[lane]))
	return 100.0*coverage/(meals.size()*2)

func scenario_complete() -> bool:
	return scenario_complete_at(clock.day)

func _fail(message: String) -> void:
	error = message
	_wing.get_node("Player").set_world_input_blocked(true)
	push_error(message)

func capture_state() -> Dictionary:
	var history: Array = []
	for request: RefCounted in requests: history.append(request.capture_state())
	return {"definition":definition.duplicate(true), "requests":history, "issued":issued.duplicate(true),
		"admissions":admissions.duplicate(true), "phase":phase, "resolved_day":resolved_day,
		"report":report.duplicate(true), "error":error}

func restore_state(state: Dictionary) -> void:
	definition = state.definition.duplicate(true)
	requests.clear()
	for record: Dictionary in state.requests:
		var request = Request.new()
		request.restore_state(record)
		request.time_source = clock.current_time
		request.item_already_spent = has_spent_item
		requests.append(request)
	issued = state.issued.duplicate(true)
	admissions = state.admissions.duplicate(true)
	phase = state.phase
	resolved_day = state.resolved_day
	report = state.report.duplicate(true)
	error = state.error
