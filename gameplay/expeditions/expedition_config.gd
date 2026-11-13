extends RefCounted

## First-iteration settings. The saved signature pins these values per run.
const REVISION := 2
const READY_START := 8
const DEFAULT_MEMBERS := 1
const MAX_MEMBERS := 4
const BULK_PER_MEMBER := 23
const MIN_DURATION := 210.0
const MAX_DURATION := 300.0
const COLLECTION_TARGET := 6
const AFFINITY_WEIGHT := 9
const OTHER_WEIGHT := 7
const FOOD_PER_BONUS := 8
const MAX_HYDRATION_REDUCTION := 0.25
const MAX_WEAPONS_BIAS := 0.5
const BASE_LIGHT_CHANCE := 0.20
const BASE_SEVERE_CHANCE := 0.10
const MAX_PROTECTION_REDUCTION := 0.50
const MAX_RECRUIT_CHANCE := 0.05
const CATEGORIES: Array[String] = [
	"Electronics", "Food", "Fuel", "Hydration", "Medical", "Morale", "Protection", "Weapons",
]
const PER_MEMBER_TARGETS := {"Food": 10, "Hydration": 5, "Protection": 12, "Weapons": 10, "Morale": 15}

static func signature() -> Dictionary:
	return {"revision": REVISION, "roster": READY_START, "default_members": DEFAULT_MEMBERS,
		"max_members": MAX_MEMBERS, "bulk_per_member": BULK_PER_MEMBER, "targets": PER_MEMBER_TARGETS.duplicate(),
		"categories": CATEGORIES.duplicate(), "duration": [MIN_DURATION, MAX_DURATION],
		"weights": [AFFINITY_WEIGHT, OTHER_WEIGHT], "food_per_bonus": FOOD_PER_BONUS,
		"max_hydration_reduction": MAX_HYDRATION_REDUCTION, "max_weapons_bias": MAX_WEAPONS_BIAS,
		"injury": [BASE_LIGHT_CHANCE, BASE_SEVERE_CHANCE, MAX_PROTECTION_REDUCTION],
		"max_recruit_chance": MAX_RECRUIT_CHANCE}

static func targets_for(members: int) -> Dictionary:
	var targets := {}
	for lane: String in PER_MEMBER_TARGETS:
		targets[lane] = PER_MEMBER_TARGETS[lane] * members
	return targets

static func pair_id(first: String, second: String) -> String:
	var a := CATEGORIES.find(first)
	var b := CATEGORIES.find(second)
	if a < 0 or b < 0 or a == b:
		return ""
	return CATEGORIES[mini(a, b)] + "|" + CATEGORIES[maxi(a, b)]

static func valid_destination(id: String) -> bool:
	var pair := id.split("|")
	return pair.size() == 2 and pair_id(pair[0], pair[1]) == id

static func destination_label(id: String) -> String:
	return id.replace("|", " + ")

static func category_weights(affinities: Array, fitting: Array = CATEGORIES) -> Dictionary:
	var weights := {}
	for category: String in fitting:
		weights[category] = AFFINITY_WEIGHT if affinities.has(category) else OTHER_WEIGHT
	return weights
