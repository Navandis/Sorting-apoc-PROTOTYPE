extends RefCounted

const Clock = preload("res://gameplay/run/run_clock.gd")

var clock := Clock.new()
var last_auto_attempt_at := 0.0
var error := ""
var _runtime: ReceivingRuntime
var _expeditions: RefCounted
var _kitchen: RefCounted
var _fuel: RefCounted

func bind(runtime: ReceivingRuntime, expeditions: RefCounted, kitchen: RefCounted = null, fuel: RefCounted = null) -> void:
	_runtime = runtime
	_expeditions = expeditions
	_kitchen = kitchen
	_fuel = fuel
	error = _expeditions.bind(runtime)
	if error.is_empty():
		_runtime.lift_cycle.externally_driven = true
		if _fuel != null:
			_runtime.lift_cycle.bind_freight_clock(clock, _fuel.lift_emergency())
			_fuel.power_changed.connect(_update_freight_power)

func advance(delta: float) -> void:
	if not error.is_empty() or not is_instance_valid(_runtime) or not is_finite(delta) or delta <= 0.0:
		return
	if not _runtime.is_inside_tree() or _runtime.get_tree().paused:
		return
	var endpoint := clock.elapsed + delta
	var cycle: ReceivingLiftCycle = _runtime.lift_cycle
	var recovered: bool = _expeditions.settle_recovery()
	if _fuel != null:
		_fuel.settle_power()
	_settle_boundary()
	if recovered:
		_expeditions.changed.emit()
	while clock.elapsed < endpoint and error.is_empty():
		var return_at: float = _expeditions.next_return_at()
		var kitchen_at := _next_kitchen_boundary()
		var fuel_at := _next_fuel_boundary()
		var recovery_at: float = _expeditions.medical.next_boundary_at()
		var boundary := minf(endpoint, minf(recovery_at, minf(return_at, minf(kitchen_at, fuel_at))))
		var phase_left := cycle.seconds_to_boundary()
		var phase_at := clock.elapsed + phase_left
		# Keep the lift's exact remaining cue time when an absolute boundary rounds.
		var step := phase_left if phase_at <= boundary else boundary - clock.elapsed
		var elapsed_before: float = clock.elapsed
		var before := cycle.get_cycle_state()
		var was_waiting := cycle.is_waiting_to_start()
		var batch_id := _runtime.receiving_manager.get_active_batch_id()
		clock.elapsed = minf(boundary, phase_at)
		recovered = _expeditions.settle_recovery()
		# At equal timestamps, evaluate power before promotion or new return admission.
		if _fuel != null:
			_fuel.settle_power()
		cycle.advance_time(step)
		_settle_boundary()
		if recovered:
			_expeditions.changed.emit()
		if clock.elapsed == elapsed_before and cycle.get_cycle_state() == before and _runtime.receiving_manager.get_active_batch_id() == batch_id \
				and _expeditions.next_return_at() == return_at and _next_kitchen_boundary() == kitchen_at \
				and cycle.is_waiting_to_start() == was_waiting and _next_fuel_boundary() == fuel_at \
				and _expeditions.medical.next_boundary_at() == recovery_at:
			error = "An active-time boundary could not settle"
			push_error(error)

func _update_freight_power() -> void:
	_runtime.lift_cycle.set_emergency_mode(_fuel.lift_emergency())

func _next_fuel_boundary() -> float:
	return _fuel.next_boundary_at() if _fuel != null else INF

func _next_kitchen_boundary() -> float:
	return _kitchen.next_boundary_at() if _kitchen != null else INF

func _settle_boundary() -> void:
	# A just-freed slot first belongs to the oldest upstream waiter.
	_runtime.return_admission.settle_admission()
	_expeditions.return_due()
	error = _expeditions.error
	if error.is_empty() and _kitchen != null:
		_kitchen.settle_due()

func capture_state() -> Dictionary:
	return {"elapsed": clock.elapsed, "last_auto_attempt_at": last_auto_attempt_at}

func restore_state(state: Dictionary) -> void:
	clock.elapsed = state.elapsed
	last_auto_attempt_at = state.last_auto_attempt_at
