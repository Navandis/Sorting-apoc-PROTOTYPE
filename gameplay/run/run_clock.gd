extends RefCounted

## Long gaps with no callbacks are treated as suspension on platforms that do
## not report it. Use the same sample for the score and every timed mechanism.
const DISCONTINUITY_USEC := 10_000_000
var elapsed := 0.0
var _previous_tick := -1

func sample_delta(tick_usec: int) -> float:
	var previous := _previous_tick
	_previous_tick = tick_usec
	var gap := tick_usec - previous
	if previous < 0 or gap <= 0 or gap >= DISCONTINUITY_USEC:
		return 0.0
	return gap / 1_000_000.0

func reset_sample() -> void:
	_previous_tick = -1

static func time_text(seconds: float) -> String:
	var whole := int(floor(seconds))
	@warning_ignore("integer_division")
	return "%02d:%02d:%02d" % [whole / 3600, (whole / 60) % 60, whole % 60]
