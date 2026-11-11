extends SceneTree

const Path := "res://gameplay/fuel/fuel_operations.gd"
const Clock := preload("res://gameplay/run/run_clock.gd")

var checks := 0
var failures := 0
var serial := 0

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	if check(FileAccess.file_exists(Path), "continuous Fuel reserve owner exists"):
		var script: GDScript = load(Path)
		test_depletion(script)
		test_top_ups(script)
		test_partitioning(script)
	print("fuel_operations_tests: %s (%d checks, %d failures)" % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)

func test_depletion(script: GDScript) -> void:
	var clock := Clock.new()
	var fuel: RefCounted = script.new(clock)
	fuel.initialize()
	check(fuel.reserve() == 55.0 and fuel.capacity == 60.0, "new run starts at 55/60")
	clock.elapsed = 15.0
	check(fuel.reserve() == 54.5, "consumption is fractional after 15 seconds")
	var cases := [[300.0, 45.0, 1.0, 0.835], [750.0, 30.0, 0.835, 0.670], [1200.0, 15.0, 0.670, 0.500]]
	for test: Array in cases:
		check(fuel.next_boundary_at() == test[0], "next threshold occurs at %s" % test[0])
		clock.elapsed = test[0]
		check(fuel.reserve() == test[1] and fuel.lighting_multiplier() == test[2],
			"threshold equality retains the higher power tier")
		clock.elapsed += 0.03
		check(is_equal_approx(fuel.reserve(), test[1] - 0.001) and fuel.lighting_multiplier() == test[3],
			"one thousandth below a threshold uses the next tier")
	check(fuel.lift_emergency() and not fuel.salvager_available() and not fuel.workshop_available(),
		"emergency power restrictions follow the lower tier")
	clock.elapsed = 1650.0
	check(fuel.reserve() == 0.0 and fuel.next_boundary_at() == INF, "depletion settles once and floors at zero")
	clock.elapsed = 6000.0
	var carry := CarriedItems.new()
	var item := make_item("Fuel", 6)
	carry.add_item(item)
	check(fuel.contribute(carry, item, func(): return true).ok and fuel.reserve() == 6.0,
		"refuel at zero credits the full item without empty-time debt")
	carry.free()
	var bigger_clock := Clock.new()
	var bigger: RefCounted = script.new(bigger_clock, Callable(), 90.0)
	bigger.initialize()
	bigger_clock.elapsed = 450.0
	check(bigger.reserve() == 40.0 and not bigger.salvager_available() and bigger.workshop_available()
		and bigger.lighting_multiplier() == 0.835 and not bigger.lift_emergency(), "extra capacity only adds headroom")

func test_top_ups(script: GDScript) -> void:
	var clock := Clock.new()
	var fuel: RefCounted = script.new(clock, func(id: String): return id == "other-terminal")
	fuel.initialize()
	var carry := CarriedItems.new()
	carry.add_item(make_item("Fuel", 6))
	fuel.contribute(carry, carry.get_selected_item(), func(): return true)
	clock.elapsed = 15.0
	var item := make_item("Fuel", 6)
	var wrong := make_item("Food", 6)
	carry.add_item(item)
	carry.add_item(wrong)
	var preview: Dictionary = fuel.preview(item)
	check(preview.applied == 0.5 and preview.wasted == 5.5 and carry.get_selected_item() == item,
		"preview preserves selected item and quotes fractional cap and waste")
	check(not fuel.contribute(carry, wrong, func(): return true).ok and not fuel.contribute(carry, item, func(): return false).ok,
		"stale selection and inaccessible station preserve Fuel")
	carry.item_removed.connect(func(removed: ItemInstance):
		var receipts: Array = fuel.capture_state().receipts
		check(removed == item and carry.get_selected_item() == wrong and fuel.reserve() == 60.0 \
			and receipts.size() == 2 and receipts.back().item_id == item.instance_id,
			"removal observers see coherent Fuel credit and receipt")
		check(not fuel.contribute(carry, item, func(): return true).ok, "reentrant duplicate contribution rejects"),
		CONNECT_ONE_SHOT)
	var applied: Dictionary = fuel.contribute(carry, item, func(): return true)
	check(applied.ok and applied.applied == 0.5 and applied.wasted == 5.5, "accepted top-up consumes one whole item")
	carry.remove_selected()
	carry.add_item(make_item("Fuel", 3))
	check(not fuel.contribute(carry, carry.get_selected_item(), func(): return true).ok and carry.get_item_count() == 1,
		"full tank preserves the selected item")
	carry.remove_selected()
	clock.elapsed = 45.0
	for rejected: ItemInstance in [wrong, make_item("Fuel", 0), item, make_item("Fuel", 3, "other-terminal")]:
		carry.add_item(rejected)
		check(not fuel.contribute(carry, rejected, func(): return true).ok and carry.get_selected_item() == rejected,
			"wrong category, zero Utility and either terminal history reject")
		carry.remove_selected()
	var contaminated := make_item("Fuel", 5)
	contaminated.contaminated = true
	carry.add_item(contaminated)
	check(fuel.contribute(carry, contaminated, func(): return true).raw == 3, "credit uses per-instance Utility")
	carry.free()

func test_partitioning(script: GDScript) -> void:
	var states: Array[Dictionary] = []
	for steps: int in [1, 1700]:
		var clock := Clock.new()
		var fuel: RefCounted = script.new(clock)
		fuel.initialize()
		var carry := CarriedItems.new()
		for i in range(1, steps + 1):
			clock.elapsed = 1700.0 * i / steps
			fuel.settle_power()
		carry.add_item(make_item("Fuel", 6, "same-test-item"))
		fuel.contribute(carry, carry.get_selected_item(), func(): return true)
		clock.elapsed = 1752.5
		states.append(fuel.capture_state())
		carry.free()
	check(states[0] == states[1] and states[0].reserve == 4.25, "partitioning leaves the same reserve, anchor and receipt")

func make_item(category: String, value: int, id: String = "") -> ItemInstance:
	var definition := ItemDefinition.new()
	definition.item_id = &"fixture"
	definition.storage_category = category
	definition.utility_id = StringName(category)
	definition.utility_value = value
	definition.bulk = 1
	serial += 1
	return ItemInstance.new(definition, id if not id.is_empty() else "test-%s" % serial)

func check(condition: bool, message: String) -> bool:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)
	return condition
