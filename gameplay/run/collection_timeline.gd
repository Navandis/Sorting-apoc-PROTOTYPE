extends RefCounted

const Clock = preload("res://gameplay/run/run_clock.gd")
const FIXTURE_PATH := "res://data/scenarios/collection_foundation/supply.json"
const FIXTURE_ID := "collection_foundation"
const FIXTURE_REVISION := 1

var clock := Clock.new()
var fixture: Dictionary
var next_arrival := 0
var last_auto_attempt_at := 0.0
var error := ""
var _runtime: ReceivingRuntime

static func default_fixture() -> Dictionary:
	var definition: Variant = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE_PATH))
	if not definition is Dictionary:
		return {}
	return definition

static func validate_fixture(definition: Dictionary) -> String:
	if definition.get("id") != FIXTURE_ID or definition.get("revision") != FIXTURE_REVISION or not definition.get("arrivals") is Array or definition.arrivals.is_empty():
		return "Unsupported collection supply fixture"
	var ids: Dictionary = {}
	var previous_at := 0.0
	for arrival: Variant in definition.arrivals:
		if not arrival is Dictionary or not arrival.get("id") is String or arrival.id.is_empty() or ids.has(arrival.id):
			return "Collection arrivals require distinct occurrence IDs"
		if not arrival.get("at") is float or not is_finite(arrival.at) or arrival.at <= 0.0 or arrival.at < previous_at:
			return "Collection arrival offsets must be positive, finite and in active-time order"
		if typeof(arrival.get("seed")) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(arrival.seed)) or float(arrival.seed) != int(arrival.seed):
			return "Collection arrival requires a presentation seed: " + arrival.id
		if not arrival.get("manifest") is Array or arrival.manifest.is_empty():
			return "Collection arrival requires exact cargo: " + arrival.id
		for id: Variant in arrival.manifest:
			if not id is String or PrototypeItemCatalog.get_definition_by_id(StringName(id)) == null:
				return "Unknown collection supply item: " + str(id)
		ids[arrival.id] = true
		previous_at = arrival.at
	return ""

func initialize(definition: Dictionary) -> void:
	fixture = definition.duplicate(true)
	error = validate_fixture(fixture)

func bind(runtime: ReceivingRuntime, restoring: bool) -> void:
	if runtime.return_admission == null or not runtime.lift_cycle.is_configured():
		error = "Receiving failed to initialize"
		return
	_runtime = runtime
	_runtime.lift_cycle.externally_driven = true
	_runtime.return_admission.return_invalidated.connect(_on_invalid_return)
	if restoring or not error.is_empty():
		return
	for arrival: Dictionary in fixture.arrivals:
		if not _runtime.can_prepare_manifest(arrival.manifest, arrival.id, int(arrival.seed)):
			error = "Controlled cargo cannot be prepared: " + arrival.id
			return

func advance(delta: float) -> void:
	if not error.is_empty() or not is_instance_valid(_runtime) or not is_finite(delta) or delta <= 0.0:
		return
	if not _runtime.is_inside_tree() or _runtime.get_tree().paused:
		return
	var endpoint := clock.elapsed + delta
	var cycle: ReceivingLiftCycle = _runtime.lift_cycle
	_runtime.return_admission.settle_admission()
	_issue_due()
	var remaining := delta
	while remaining > 0.0 and error.is_empty():
		var arrival_at := _next_arrival_time()
		var until_arrival := maxf(0.0, arrival_at - clock.elapsed)
		var step := minf(remaining, minf(until_arrival, cycle.seconds_to_boundary()))
		var before := cycle.get_cycle_state()
		var batch_id := _runtime.receiving_manager.get_active_batch_id()
		clock.elapsed = minf(endpoint, arrival_at) if step == until_arrival else (
			endpoint if step == remaining else clock.elapsed + step
		)
		cycle.advance_time(step)
		_runtime.return_admission.settle_admission()
		_issue_due()
		if step == 0.0 and cycle.get_cycle_state() == before and _runtime.receiving_manager.get_active_batch_id() == batch_id:
			_fail("A lift boundary could not settle")
		remaining = maxf(0.0, remaining - step)

func _next_arrival_time() -> float:
	return fixture.arrivals[next_arrival].at if next_arrival < fixture.arrivals.size() else INF

func _issue_due() -> void:
	while error.is_empty() and _next_arrival_time() <= clock.elapsed:
		var arrival: Dictionary = fixture.arrivals[next_arrival]
		var batch := _runtime.prepare_manifest(arrival.manifest, arrival.id, int(arrival.seed))
		if batch == null or _runtime.return_admission.submit_return(arrival.id, batch) == AwaitingLiftAdmission.ReturnResult.INVALID:
			_fail("Controlled cargo failed preparation or admission: " + arrival.id)
			return
		next_arrival += 1

func _on_invalid_return(occurrence: String, batch: String, reason: String) -> void:
	_fail("Cargo admission failed for %s (%s). %s" % [occurrence, batch, reason])

func _fail(message: String) -> void:
	if not error.is_empty():
		return
	error = message
	push_error(message)

func capture_state() -> Dictionary:
	return {"elapsed": clock.elapsed, "fixture": fixture.duplicate(true),
		"next_arrival": next_arrival, "last_auto_attempt_at": last_auto_attempt_at}

func restore_state(state: Dictionary) -> void:
	initialize(state.fixture)
	clock.elapsed = state.elapsed
	next_arrival = state.next_arrival
	last_auto_attempt_at = state.last_auto_attempt_at
