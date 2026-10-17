extends RefCounted

## Only active simulation advances elapsed. Calendar gaps never advance mechanics.
var config := {"rate": 24.0, "day_start": 25200.0, "latest_return": 85200.0}
var elapsed := 0.0
var day := 1

func day_duration() -> float:
	return (86400.0 - float(config.day_start)) / float(config.rate)

func current_time() -> float:
	return elapsed

func day_elapsed() -> float:
	return elapsed - (day - 1) * day_duration()

func calendar_seconds() -> float:
	return float(config.day_start) + day_elapsed() * float(config.rate)

func until_midnight() -> float:
	return maxf(0.0, day * day_duration() - elapsed)

func advance(delta: float) -> void:
	if is_finite(delta) and delta > 0.0:
		elapsed = minf(elapsed + delta, day * day_duration())

func begin_next_day() -> void:
	assert(until_midnight() == 0.0)
	day += 1

func timestamp(event_day: int, seconds: float) -> float:
	return (event_day - 1) * day_duration() + (seconds - float(config.day_start)) / float(config.rate)

static func time_text(seconds: float) -> String:
	var whole := int(floor(seconds))
	return "%02d:%02d:%02d" % [whole / 3600, (whole / 60) % 60, whole % 60]

func capture_state() -> Dictionary:
	return {"config": config.duplicate(true), "elapsed": elapsed, "day": day}

func restore_state(state: Dictionary) -> void:
	config = state.config.duplicate(true)
	elapsed = state.elapsed
	day = state.day
