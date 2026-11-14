extends RefCounted

const Config = preload("res://gameplay/expeditions/expedition_config.gd")
const Acquisition = preload("res://gameplay/expeditions/expedition_acquisition.gd")

const HEALTHY := "healthy"
const LIGHT := "light"
const SEVERE := "severe"
enum Stream { TRAVEL, FOOD_COUNT, ORDINARY, BONUS, INJURY, RECRUIT, PRESENTATION }

static func effects(members: int, credits: Dictionary) -> Dictionary:
	var targets := Config.targets_for(members)
	var travel_scale := 1.0 - Config.MAX_HYDRATION_REDUCTION * _fraction(credits, targets, "Hydration")
	var injury_scale := 1.0 - Config.MAX_PROTECTION_REDUCTION * _fraction(credits, targets, "Protection")
	return {"duration_range": Vector2(Config.MIN_DURATION, Config.MAX_DURATION) * travel_scale, "travel_scale": travel_scale,
		"food": food_bonus(int(credits.get("Food", 0))),
		"weapons_bias": Config.MAX_WEAPONS_BIAS * _fraction(credits, targets, "Weapons"),
		"light_chance": Config.BASE_LIGHT_CHANCE * injury_scale,
		"severe_chance": Config.BASE_SEVERE_CHANCE * injury_scale,
		"recruit_chance": Config.MAX_RECRUIT_CHANCE * _fraction(credits, targets, "Morale")}

static func _fraction(credits: Dictionary, targets: Dictionary, lane: String) -> float:
	return clampf(float(credits.get(lane, 0)) / float(targets[lane]), 0.0, 1.0)

static func food_bonus(credit: int) -> Dictionary:
	@warning_ignore("integer_division")
	var guaranteed := credit / Config.FOOD_PER_BONUS
	return {"guaranteed": guaranteed, "extra_chance": float(credit % Config.FOOD_PER_BONUS) / Config.FOOD_PER_BONUS}

static func bonus_count(credit: int, roll: float) -> int:
	var bonus := food_bonus(credit)
	return bonus.guaranteed + int(roll < bonus.extra_chance)

static func injury(light: float, severe: float, roll: float) -> String:
	if roll < light:
		return LIGHT
	if roll < light + severe:
		return SEVERE
	return HEALTHY

## One departure draws a fixed set of seeds from the owning stream. Each seed has a
## dedicated consumer so loot draws and person counts cannot move other rolls.
## Replay constructs local RNGs and never changes the live stream.
static func draw_seeds(stream: RandomNumberGenerator) -> Array[int]:
	var seeds: Array[int] = []
	for family in Stream.size():
		seeds.append(stream.randi())
	return seeds

static func resolve(members: int, credits: Dictionary, capacity: int, affinities: Array,
		seeds: Array, pool: Dictionary) -> Dictionary:
	var modifiers := effects(members, credits)
	var base_duration := _stream(seeds[Stream.TRAVEL]).randf_range(Config.MIN_DURATION, Config.MAX_DURATION)
	var food_ticket := _stream(seeds[Stream.FOOD_COUNT]).randi_range(0, Config.FOOD_PER_BONUS - 1)
	var count := bonus_count(credits.Food, float(food_ticket) / Config.FOOD_PER_BONUS)
	var manifest := Acquisition.sample_ordinary(capacity, affinities, modifiers.weapons_bias, _stream(seeds[Stream.ORDINARY]), pool)
	var ordinary_count := manifest.size()
	manifest.append_array(Acquisition.sample_bonus(count, affinities, modifiers.weapons_bias, _stream(seeds[Stream.BONUS]), pool))
	var injury_rng := _stream(seeds[Stream.INJURY])
	var recruit_rng := _stream(seeds[Stream.RECRUIT])
	var originals: Array[Dictionary] = []
	for member in members:
		originals.append({"health": injury(modifiers.light_chance, modifiers.severe_chance, injury_rng.randf()),
			"recruited": recruit_rng.randf() < modifiers.recruit_chance})
	return {"duration": base_duration * modifiers.travel_scale, "manifest": manifest, "ordinary_count": ordinary_count,
		"originals": originals, "presentation_seed": 0 if manifest.is_empty() else seeds[Stream.PRESENTATION]}

static func summarize(originals: Array) -> Dictionary:
	var counts := {"healthy": 0, "light": 0, "severe": 0, "recruits": 0}
	for member: Dictionary in originals:
		counts[member.health] += 1
		counts.recruits += int(member.recruited)
	return counts

static func _stream(seed: int) -> RandomNumberGenerator:
	var stream := RandomNumberGenerator.new()
	stream.seed = seed
	return stream
