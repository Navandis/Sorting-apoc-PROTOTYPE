extends RefCounted

## Provisional acquisition fixture. The saved signature pins these rules per run.
const REVISION := 1
const READY_START := 8
const DEFAULT_MEMBERS := 1
const MAX_MEMBERS := 4
const BULK_PER_MEMBER := 8
const MIN_POOL_BULK := 2
const MIN_DURATION := 90.0
const MAX_DURATION := 180.0
const COLLECTION_TARGET := 6
const AFFINITY_WEIGHT := 9
const OTHER_WEIGHT := 7
const CATEGORIES: Array[String] = [
	"Electronics", "Food", "Fuel", "Hydration", "Medical", "Morale", "Protection", "Weapons",
]
const PER_MEMBER_TARGETS := {"Food": 5, "Hydration": 3, "Medical": 4, "Weapons": 4, "Protection": 6}
const POOL_IDS := {
	"Electronics": ["loot_000004", "loot_000122"],
	"Food": ["loot_000007", "loot_000045"],
	"Fuel": ["loot_000013", "loot_000164"],
	"Hydration": ["loot_000020", "loot_000075"],
	"Medical": ["loot_000127", "loot_000028"],
	"Morale": ["loot_000031", "loot_000129"],
	"Protection": ["loot_000033", "loot_000035"],
	"Weapons": ["loot_000039", "loot_000084"],
}

static func signature() -> Dictionary:
	return {"revision": REVISION, "roster": READY_START, "default_members": DEFAULT_MEMBERS,
		"max_members": MAX_MEMBERS, "bulk_per_member": BULK_PER_MEMBER, "targets": PER_MEMBER_TARGETS.duplicate(),
		"pool": POOL_IDS.duplicate(true), "duration": [MIN_DURATION, MAX_DURATION],
		"weights": [AFFINITY_WEIGHT, OTHER_WEIGHT]}

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

static func build_pool(catalog: ItemCatalog) -> Dictionary:
	var pool := {}
	var minimum_bulk := BULK_PER_MEMBER
	for category: String in CATEGORIES:
		var options: Array[ItemDefinition] = []
		for id: String in POOL_IDS[category]:
			var definition := catalog.get_definition_by_id(StringName(id))
			if definition == null or definition.storage_category != category or String(definition.utility_id) != category \
					or definition.bulk < MIN_POOL_BULK or definition.bulk > BULK_PER_MEMBER or definition.utility_value <= 0:
				return {}
			minimum_bulk = mini(minimum_bulk, definition.bulk)
			options.append(definition)
		pool[category] = options
	return pool if minimum_bulk == MIN_POOL_BULK else {}

static func category_weights(affinities: Array, fitting: Array = CATEGORIES) -> Dictionary:
	var weights := {}
	for category: String in fitting:
		weights[category] = AFFINITY_WEIGHT if affinities.has(category) else OTHER_WEIGHT
	return weights

static func sample_manifest(budget: int, affinities: Array, rng: RandomNumberGenerator, pool: Dictionary) -> Array[String]:
	var manifest: Array[String] = []
	while budget >= MIN_POOL_BULK:
		var fitting := {}
		for category: String in CATEGORIES:
			var options: Array = pool[category].filter(func(item: ItemDefinition): return item.bulk <= budget)
			if not options.is_empty():
				fitting[category] = options
		if fitting.is_empty():
			break
		var weights := category_weights(affinities, fitting.keys())
		var total := 0
		for weight: int in weights.values():
			total += weight
		var ticket := rng.randi_range(0, total - 1)
		for category: String in weights:
			ticket -= weights[category]
			if ticket < 0:
				var options: Array = fitting[category]
				var item: ItemDefinition = options[rng.randi_range(0, options.size() - 1)]
				manifest.append(String(item.item_id))
				budget -= item.bulk
				break
	return manifest
