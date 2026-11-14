extends SceneTree

const CATALOGUE = preload("res://data/items/item_catalog.tres")
const CONFIG = preload("res://gameplay/expeditions/expedition_config.gd")
const GENERATOR_PATH := "res://gameplay/expeditions/expedition_acquisition.gd"

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if check(ResourceLoader.exists(GENERATOR_PATH), "production full-catalogue generator is available"):
		test_acquisition(load(GENERATOR_PATH))
	print("expedition_acquisition_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)

func test_acquisition(generator: GDScript) -> void:
	var pool: Dictionary = generator.build_pool(CATALOGUE)
	var count := 0
	var largest := 0
	for options: Array in pool.values():
		count += options.size()
		for definition: ItemDefinition in options:
			largest = maxi(largest, definition.bulk)
	check(pool.size() == 8 and count == 167 and largest == 14, "full adopted catalogue and maximum item Bulk")
	var fedora := CATALOGUE.get_definition_by_id(&"loot_000172")
	check(fedora.bulk == 2 and fedora.storage_footprint == Vector3i(3, 3, 1)
		and is_equal_approx(fedora.visual_scale, 0.897) and pool.get("Protection", []).has(fedora),
		"Fedora participates with its adopted fields")
	var weights := CONFIG.category_weights(["Food", "Fuel"])
	check(weights.values().reduce(func(total: int, weight: int): return total + weight, 0) == 60
		and weights.Food == 9 and weights.Fuel == 9 and weights.Morale == 7, "two affinities at 15% each")
	var rng := RandomNumberGenerator.new()
	rng.seed = 72
	var ordinary: Array = generator.sample_ordinary(23, ["Food", "Weapons"], 0.0, rng, pool)
	var bulk := 0
	for id: String in ordinary:
		bulk += CATALOGUE.get_definition_by_id(StringName(id)).bulk
	check(bulk == 23, "ordinary haul fills including Bulk-1 candidates")
	var fitted: Array = generator.sample_ordinary(1, ["Food", "Weapons"], 0.0, rng, pool)
	check(fitted.size() == 1 and CATALOGUE.get_definition_by_id(StringName(fitted[0])).bulk == 1,
		"positive one-Bulk residual is usable")
	var quality: Array[ItemDefinition] = []
	for utility in [1, 3, 5, 7]:
		var definition := ItemDefinition.new()
		definition.utility_value = utility
		quality.append(definition)
	check(generator.item_probabilities(quality, 0.0) == [0.25, 0.25, 0.25, 0.25], "unprovisioned Weapons draw is uniform")
	check(generator.item_probabilities(quality, 0.5) == [0.15625, 0.21875, 0.28125, 0.34375], "full Weapons uses the specified mixture")
	var equal_quality: Array[ItemDefinition] = [quality[1], quality[1]]
	check(generator.item_probabilities(equal_quality, 0.5) == [0.5, 0.5], "equal ratios have equal probability")
	var large := ItemDefinition.new()
	large.item_id = &"test_large"
	large.bulk = 14
	var isolated := {"Food": [large]}
	check(generator.sample_ordinary(0, [], 0.5, rng, isolated).is_empty()
		and generator.sample_bonus(2, [], 0.5, rng, isolated) == ["test_large", "test_large"],
		"bonus can return repeated 14-Bulk items with zero ordinary room")

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok
