extends RefCounted

const REVISION := 1
const INTERVAL := Vector2i(180, 300)
const PROPOSAL := Vector2i(60, 80)
const GRACE_SECONDS := 60
const UTILITY_PER_POINT := 3
const MAX_LOSS := 50
const CAP := UTILITY_PER_POINT * MAX_LOSS
const LANES := ["Food", "Hydration"]

static func capture() -> Dictionary:
	return {"revision": REVISION, "interval": INTERVAL, "proposal": PROPOSAL,
		"grace": GRACE_SECONDS, "utility_per_point": UTILITY_PER_POINT, "max_loss": MAX_LOSS}

static func food_bounds(total: int) -> Vector2i:
	# ceil(4*T/9) to floor(5*T/9) is exactly larger <= 1.25 * smaller.
	@warning_ignore("integer_division")
	return Vector2i((4 * total + 8) / 9, 5 * total / 9)

static func draw_proposal(rng: RandomNumberGenerator) -> Vector2i:
	var total := rng.randi_range(PROPOSAL.x, PROPOSAL.y)
	var bounds := food_bounds(total)
	var food := rng.randi_range(bounds.x, bounds.y)
	return Vector2i(food, total - food)

static func clip(proposed: Vector2i, headroom: int, event_index: int) -> Vector2i:
	var total := proposed.x + proposed.y
	if headroom >= total:
		return proposed
	if headroom <= 0:
		return Vector2i.ZERO
	var scaled := proposed * headroom
	var admitted := scaled / total
	if admitted.x + admitted.y < headroom:
		var food_remainder := scaled.x % total
		var hydration_remainder := scaled.y % total
		if food_remainder > hydration_remainder or (food_remainder == hydration_remainder and event_index % 2 == 1):
			admitted.x += 1
		else:
			admitted.y += 1
	return admitted
