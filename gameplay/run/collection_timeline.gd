extends RefCounted

const Clock = preload("res://gameplay/run/run_clock.gd")

var clock := Clock.new()
var last_auto_attempt_at := 0.0
var error := ""
var _runtime: ReceivingRuntime
var _expeditions: RefCounted

func bind(runtime: ReceivingRuntime, expeditions: RefCounted) -> void:
	_runtime = runtime
	_expeditions = expeditions
	error = _expeditions.bind(runtime)
	if error.is_empty():
		_runtime.lift_cycle.externally_driven = true

func advance(delta: float) -> void:
	if not error.is_empty() or not is_instance_valid(_runtime) or not is_finite(delta) or delta <= 0.0:
		return
	if not _runtime.is_inside_tree() or _runtime.get_tree().paused:
		return
	var endpoint := clock.elapsed + delta
	var cycle: ReceivingLiftCycle = _runtime.lift_cycle
	_settle_boundary()
	while clock.elapsed < endpoint and error.is_empty():
		var return_at: float = _expeditions.next_return_at()
		var boundary := minf(endpoint, return_at)
		var step := minf(boundary - clock.elapsed, cycle.seconds_to_boundary())
		var before := cycle.get_cycle_state()
		var batch_id := _runtime.receiving_manager.get_active_batch_id()
		clock.elapsed = boundary if step == boundary - clock.elapsed else clock.elapsed + step
		cycle.advance_time(step)
		_settle_boundary()
		if step == 0.0 and cycle.get_cycle_state() == before and _runtime.receiving_manager.get_active_batch_id() == batch_id:
			error = "A lift boundary could not settle"
			push_error(error)

func _settle_boundary() -> void:
	# A just-freed slot first belongs to the oldest upstream waiter.
	_runtime.return_admission.settle_admission()
	_expeditions.return_due()
	error = _expeditions.error

func capture_state() -> Dictionary:
	return {"elapsed": clock.elapsed, "last_auto_attempt_at": last_auto_attempt_at}

func restore_state(state: Dictionary) -> void:
	clock.elapsed = state.elapsed
	last_auto_attempt_at = state.last_auto_attempt_at
