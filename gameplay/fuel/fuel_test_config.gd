extends RefCounted

const CAPACITY := 60.0
const STARTING_RESERVE := 55.0
const SECONDS_PER_UTILITY := 30.0
const EMERGENCY_WAIT := 60.0
const THRESHOLDS := [45.0, 30.0, 15.0]
const LIGHT_STRENGTH := [1.0, 0.835, 0.670, 0.5]
const BAND_NAMES := ["Full power", "Salvager offline", "Workshop offline", "Emergency freight"]

static func capture() -> Dictionary:
	return {"capacity": CAPACITY, "starting_reserve": STARTING_RESERVE,
		"seconds_per_utility": SECONDS_PER_UTILITY, "thresholds": THRESHOLDS.duplicate(),
		"lighting": LIGHT_STRENGTH.duplicate(), "emergency_wait": EMERGENCY_WAIT}

static func crossing_at(amount: float, at: float, threshold: float) -> float:
	return at + (amount - threshold) * SECONDS_PER_UTILITY

static func reserve_at(amount: float, at: float, now: float) -> float:
	for threshold: float in THRESHOLDS:
		if amount >= threshold and now == crossing_at(amount, at, threshold):
			return threshold
	return maxf(0.0, amount - (now - at) / SECONDS_PER_UTILITY) if now < crossing_at(amount, at, 0.0) else 0.0

static func band_at(amount: float, at: float, now: float) -> int:
	# A crossing timestamp itself still belongs to the higher tier.
	for index in THRESHOLDS.size():
		var threshold: float = THRESHOLDS[index]
		if amount >= threshold and now <= crossing_at(amount, at, threshold):
			return index
	return THRESHOLDS.size()
