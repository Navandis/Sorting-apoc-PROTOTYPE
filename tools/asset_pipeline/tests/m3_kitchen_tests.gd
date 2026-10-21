extends SceneTree

var checks := 0
var failures := 0

func _init() -> void:
	create_timer(90).timeout.connect(func():
		push_error("M3 Kitchen helper aborted; completion missing")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	var scenario = load("res://gameplay/run/run_scenario.gd").new()
	var definition: Dictionary = scenario.default_definition()
	check(definition.revision == 3 and definition.events.size() == 24, "M3 revision captures 12 requests and 12 substantial returns")
	check(scenario.validate(definition).is_empty(), "approved M3 definition validates")
	var values := {6:6, 7:5, 8:3, 9:3, 10:3, 11:14, 12:7, 19:3, 20:4, 21:4, 22:3}
	for number: int in values:
		var item = load("res://data/items/definitions/loot_%06d.tres" % number)
		check(item.utility_value == values[number] and item.utility_id == (&"Food" if number < 19 else &"Hydration"), "approved static Utility: " + str(number))
	var can = load("res://data/items/definitions/loot_000019.tres")
	check(can.display_name == "Cola Can" and can.storage_category == "Hydration" and can.context_utility_overrides.is_empty(), "019 preserves developer-reviewed name, Hydration category and no compensating override")
	for number: int in [25,26,28]:
		check(load("res://data/items/definitions/loot_%06d.tres" % number).get_utility_for_context(&"medical_bay").value == {25:5,26:3,28:8}[number], "accepted Medical unchanged")
	var orders := [["A","B","C","D"],["C","D","A","B"],["B","A","D","C"]]
	var signatures := {}
	var return_index := 0
	for day: int in range(1,4):
		var meals: Array = definition.events.filter(func(e): return e.kind == "kitchen" and e.day == day)
		check(meals.size() == 3, "three meals day " + str(day))
		for index: int in meals.size():
			var meal: Dictionary = meals[index]
			check(meal.at == [32400.0,50400.0,64800.0][index] and meal.deadline == meal.at + 10800.0 and meal.targets == [{"Food":30,"Hydration":24},{"Food":36,"Hydration":24},{"Food":36,"Hydration":30}][index], "exact meal anchors and targets")
		var returns: Array = definition.events.filter(func(e): return e.kind == "return" and e.day == day)
		check(returns.size() == 4, "four return attempts day " + str(day))
		for index: int in returns.size():
			var event: Dictionary = returns[index]
			var basket: String = orders[day-1][index]
			var totals := {"Food":0,"Hydration":0,"Medical":0}
			var bulk := 0
			for id: String in event.manifest:
				var item: ItemDefinition = load("res://data/items/definitions/" + id + ".tres")
				bulk += item.bulk
				var utility: Dictionary = item.get_utility_for_context(&"medical_bay")
				if item.utility_value > 0: utility = item.get_utility_for_context(&"kitchen")
				if totals.has(String(utility.utility_id)): totals[String(utility.utility_id)] += int(utility.value)
			check(event.at == [30600.0,45900.0,63000.0,80100.0][index] and event.presentation_seed == 9101 + return_index, "ordered attempt times and seeds")
			check(event.manifest.size() == 16 and bulk == 16 and totals == {"A":{"Food":32,"Hydration":28,"Medical":5},"B":{"Food":36,"Hydration":24,"Medical":3},"C":{"Food":36,"Hydration":28,"Medical":8},"D":{"Food":35,"Hydration":24,"Medical":5}}[basket], "exact basket " + basket + " count/Bulk/lane arithmetic")
			if signatures.has(basket): check(signatures[basket] == event.manifest, "same ordered basket on later day")
			signatures[basket] = event.manifest
			return_index += 1
	check(return_index == 12, "all twelve baskets audited")
	var variant: Dictionary = definition.duplicate(true)
	variant.events.filter(func(e): return e.kind=="kitchen")[0].at=25200.0
	check(scenario.validate(variant).is_empty(),"cross-destination overlap allowed")
	variant.events.filter(func(e): return e.kind=="kitchen")[1].at=36000.0
	check(not scenario.validate(variant).is_empty(),"same-destination overlap rejected")
	variant=definition.duplicate(true)
	variant.events=variant.events.filter(func(e): return e.id!="kitchen_001")
	check(not scenario.validate(variant).is_empty(),"partial daily meal set cannot shrink coverage denominator")
	variant.events=variant.events.filter(func(e): return e.kind!="kitchen")
	check(scenario.validate(variant).is_empty(),"explicit synthetic no-Kitchen fixture allowed")
	print("M3_KITCHEN_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
