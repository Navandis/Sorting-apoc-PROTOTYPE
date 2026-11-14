extends RefCounted

const Config = preload("res://gameplay/expeditions/expedition_config.gd")

static func build_pool(catalog: ItemCatalog) -> Dictionary:
	if catalog == null or not catalog.get_validation_errors().is_empty():
		return {}
	var pool := {}
	for category: String in Config.CATEGORIES:
		var options: Array[ItemDefinition] = []
		pool[category] = options
	for definition: ItemDefinition in catalog.definitions:
		var category := definition.storage_category
		if not pool.has(category) or String(definition.utility_id) != category \
				or definition.bulk < 1 or definition.utility_value < 0 \
				or catalog.get_definition_by_id(definition.item_id) != definition:
			push_error("Invalid active Expedition definition: %s" % definition.item_id)
			return {}
		pool[category].append(definition)
	for category: String in Config.CATEGORIES:
		if pool[category].is_empty():
			push_error("Active Expedition category has no definitions: " + category)
			return {}
		pool[category].sort_custom(func(a: ItemDefinition, b: ItemDefinition): return String(a.item_id) < String(b.item_id))
	return pool

static func sample_ordinary(budget: int, affinities: Array, bias: float,
		rng: RandomNumberGenerator, pool: Dictionary) -> Array[String]:
	var manifest: Array[String] = []
	while budget > 0:
		var fitting := {}
		for category: String in Config.CATEGORIES:
			var options: Array = pool.get(category, []).filter(func(item: ItemDefinition): return item.bulk <= budget)
			if not options.is_empty():
				fitting[category] = options
		if fitting.is_empty():
			break
		var item := _draw(fitting, affinities, bias, rng)
		manifest.append(String(item.item_id))
		budget -= item.bulk
	return manifest

static func sample_bonus(count: int, affinities: Array, bias: float,
		rng: RandomNumberGenerator, pool: Dictionary) -> Array[String]:
	var manifest: Array[String] = []
	for index in count:
		manifest.append(String(_draw(pool, affinities, bias, rng).item_id))
	return manifest

static func item_probabilities(options: Array, bias: float) -> Array[float]:
	var quality: Array[float] = []
	var total := 0.0
	for item: ItemDefinition in options:
		var ratio := float(item.utility_value) / item.bulk
		quality.append(ratio)
		total += ratio
	var probabilities: Array[float] = []
	for ratio: float in quality:
		var probability := 1.0 / options.size()
		if total > 0.0:
			probability = (1.0 - bias) * probability + bias * ratio / total
		probabilities.append(probability)
	return probabilities

static func _draw(candidates: Dictionary, affinities: Array, bias: float, rng: RandomNumberGenerator) -> ItemDefinition:
	var weights := Config.category_weights(affinities, candidates.keys())
	var total := 0
	for weight: int in weights.values():
		total += weight
	var ticket := rng.randi_range(0, total - 1)
	for category: String in weights:
		ticket -= weights[category]
		if ticket < 0:
			return _draw_item(candidates[category], bias, rng)
	assert(false, "Expected a weighted Expedition category")
	return null

static func _draw_item(options: Array, bias: float, rng: RandomNumberGenerator) -> ItemDefinition:
	if bias == 0.0:
		return options[rng.randi_range(0, options.size() - 1)]
	var probabilities := item_probabilities(options, bias)
	var roll := rng.randf()
	for index in options.size() - 1:
		roll -= probabilities[index]
		if roll < 0.0:
			return options[index]
	return options.back()
