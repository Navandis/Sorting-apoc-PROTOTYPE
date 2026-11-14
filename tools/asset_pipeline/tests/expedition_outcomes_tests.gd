extends SceneTree

const Config = preload("res://gameplay/expeditions/expedition_config.gd")
const Loadout = preload("res://gameplay/expeditions/expedition_loadout.gd")
const RULES_PATH := "res://gameplay/expeditions/expedition_outcomes.gd"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for members in range(1, 5):
		var loadout := Loadout.new(members)
		check(loadout.raw_capacity == 23 * members, "ordinary capacity for %d originals" % members)
		check(loadout.targets == {"Food": 10 * members, "Hydration": 5 * members,
			"Protection": 12 * members, "Weapons": 10 * members, "Morale": 15 * members},
			"five provision targets for %d originals" % members)
	if check(ResourceLoader.exists(RULES_PATH), "production Expedition effects are available"):
		test_effects(load(RULES_PATH))
	print("expedition_outcomes_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)

func test_effects(rules: GDScript) -> void:
	for members in range(1, 5):
		var zero: Dictionary = rules.effects(members, {})
		var full: Dictionary = rules.effects(members, Config.targets_for(members))
		var half: Dictionary = rules.effects(members, {"Protection": 6 * members})
		check(zero.duration_range == Vector2(210, 300) and full.duration_range == Vector2(157.5, 225),
			"Hydration bounds apply across crew sizes")
		check(zero.recruit_chance == 0.0 and full.recruit_chance == 0.05, "Morale goes from zero to 5% per original")
		check(zero.weapons_bias == 0.0 and full.weapons_bias == 0.5, "Weapons mixes at most half quality weighting")
		check(injury_rates(zero, 0.20, 0.10) and injury_rates(half, 0.15, 0.075)
			and injury_rates(full, 0.10, 0.05), "Protection proportionally reduces each severity")
	var partial: Dictionary = rules.effects(2, {"Hydration": 5})
	var diluted: Dictionary = rules.effects(4, {"Hydration": 5})
	check(partial.duration_range == Vector2(183.75, 262.5) and diluted.duration_range == Vector2(196.875, 281.25),
		"partial Hydration is linear and diluted by more originals")
	for pair in [[0, 0.0], [6, 0.75], [8, 1.0], [10, 1.25], [20, 2.5], [30, 3.75], [33, 4.125], [40, 5.0]]:
		var bonus: Dictionary = rules.food_bonus(pair[0])
		check(is_equal_approx(bonus.guaranteed + bonus.extra_chance, pair[1]), "Food expectation at %d" % pair[0])
	check(rules.bonus_count(33, 0.124) == 5 and rules.bonus_count(33, 0.125) == 4
		and rules.bonus_count(40, 0.0) == 5 and rules.bonus_count(0, 0.0) == 0, "exact Food rounding boundaries")
	check(rules.injury(0.20, 0.10, 0.199) == "light" and rules.injury(0.20, 0.10, 0.20) == "severe"
		and rules.injury(0.20, 0.10, 0.301) == "healthy", "one mutually exclusive injury draw")
	test_independent_rolls(rules)

func test_independent_rolls(rules: GDScript) -> void:
	var travel := RandomNumberGenerator.new()
	travel.seed = 1337
	var seeds: Array = rules.draw_seeds(travel)
	var low := {"Food": 0, "Morale": 60}
	var high := {"Food": 40, "Hydration": 20, "Weapons": 40, "Morale": 60}
	var item := ItemDefinition.new()
	item.item_id = &"small"
	item.utility_value = 1
	var pool := {"Food": [item]}
	var first: Dictionary = rules.resolve(4, low, 0, [], seeds, pool)
	var changed: Dictionary = rules.resolve(4, high, 40, ["Food", "Medical"], seeds, pool)
	check(first.originals == changed.originals and changed.manifest.size() == 45,
		"cargo count, duration, quality and affinity cannot move personnel draws")
	var recruit_stream := RandomNumberGenerator.new()
	for seed_value in 2000:
		recruit_stream.seed = seed_value
		var rolls: Array[bool] = []
		for original in 4:
			rolls.append(recruit_stream.randf() < 0.05)
		if rolls.count(true) >= 2:
			seeds[rules.Stream.RECRUIT] = seed_value
			var result: Dictionary = rules.resolve(4, low, 0, [], seeds, pool)
			check(result.originals.map(func(member: Dictionary): return member.recruited) == rolls,
				"each of four originals has an independent opportunity without a crew cap")
			return
	check(false, "seed witness includes multiple successful recruit rolls")

func injury_rates(effects: Dictionary, light: float, severe: float) -> bool:
	return is_equal_approx(effects.light_chance, light) and is_equal_approx(effects.severe_chance, severe)

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok
