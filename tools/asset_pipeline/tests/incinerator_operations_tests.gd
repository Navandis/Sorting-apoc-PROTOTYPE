extends SceneTree

const OperationsPath := "res://gameplay/disposal/incinerator_operations.gd"
const Clock = preload("res://gameplay/run/run_clock.gd")
const Config = preload("res://gameplay/expeditions/expedition_config.gd")

var failures := 0
var checks := 0
var access := true
var observed := false

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	if not check(FileAccess.file_exists(OperationsPath), "Incinerator has a dedicated transaction owner"):
		finish()
		return
	var clock := Clock.new()
	clock.elapsed = 12.5
	var operations: RefCounted = load(OperationsPath).new(clock, func(id: String): return id == "supplied")
	var carry := CarriedItems.new()
	root.add_child(carry)
	var can_reach := func(): return access
	check(not operations.can_attempt(carry, null, can_reach), "empty carry cannot attempt or use the warning")
	check(not operations.capture_state().warning_shown, "fresh run has not displayed the warning")

	var first := make_item("first", "Food", 11)
	var second := make_item("second", "Electronics", 9, 0)
	var extra := make_item("extra", "Fuel", 1)
	check(carry.add_item(first) and carry.add_item(second), "ordinary carrying can fill all 20 Bulk")
	check(not carry.add_item(extra), "ordinary pickup still rejects exceeding 20 Bulk")
	carry.select_index(1)
	var full := carry.capture_state()
	check(operations.can_attempt(carry, second, can_reach), "a carried item with zero Utility is eligible")
	check(not operations.incinerate(carry, second, can_reach), "destruction is gated until the warning is displayed")
	operations.mark_warning_displayed()
	access = false
	check(not operations.incinerate(carry, second, can_reach), "blocked station access rejects")
	access = true
	check(not operations.incinerate(carry, first, can_reach), "a stale exact item cannot be substituted for the selected item")
	check(carry.capture_state() == full and operations.capture_state().receipts.is_empty(),
		"rejected commands leave slots, selection and receipts intact")

	carry.item_removed.connect(func(item: ItemInstance):
		var receipt: Dictionary = {"item_id": second.instance_id, "definition_id": String(second.definition.item_id), "at": 12.5}
		observed = item == second and operations.capture_state().receipts == [receipt] and not carry.get_items().has(second)
		check(not operations.incinerate(carry, first, can_reach), "reentrant observer cannot consume the next selection"),
		CONNECT_ONE_SHOT)
	check(operations.incinerate(carry, second, can_reach), "commit destroys the exact item")
	check(observed, "removal observers see the receipt and reduced inventory together")
	check(carry.get_items() == [first] and carry.get_selected_item() == first and carry.get_remaining_bulk() == 9,
		"one item disappears, exactly its Bulk is freed and ordinary selection advances")
	check(not operations.incinerate(carry, second, can_reach), "replaying a successful command spends nothing")
	var state: Dictionary = operations.capture_state()
	var restored: RefCounted = load(OperationsPath).new(clock, func(id: String): return id == "supplied")
	restored.restore_state(state)
	check(restored.capture_state() == state, "warning and receipt round-trip without retaining an item")
	state.receipts.clear()
	check(restored.capture_state().receipts.size() == 1, "receipt capture and restore do not share mutable arrays")
	carry.remove_selected()
	for id: String in ["second", "supplied"]:
		var conflicting := make_item(id, "Food", 1)
		carry.add_item(conflicting)
		check(not restored.incinerate(carry, conflicting, can_reach) and carry.get_selected_item() == conflicting,
			"destruction and loadout receipts prevent duplicate consumption")
		carry.remove_selected()
	var duplicate := make_item("double", "Food", 1)
	carry.add_item(duplicate)
	carry.add_item(make_item("double", "Food", 1))
	check(not restored.incinerate(carry, duplicate, can_reach) and carry.get_item_count() == 2,
		"a multiply carried identity is ineligible")
	carry.remove_selected()
	carry.remove_selected()

	for category: String in Config.CATEGORIES:
		var item := make_item(category, category, 1)
		check(carry.add_item(item) and restored.incinerate(carry, item, can_reach),
			"portable " + category + " can be destroyed independently of the acquisition pool")
	check(carry.get_item_count() == 0 and carry.get_remaining_bulk() == 20 and restored.capture_state().receipts.size() == 9,
		"disposal yields no carried output or refund")
	carry.free()
	finish()

func make_item(id: String, category: String, bulk: int, utility: int = 1) -> ItemInstance:
	var definition := ItemDefinition.new()
	definition.item_id = StringName("test_" + category)
	definition.storage_category = category
	definition.utility_id = StringName(category)
	definition.utility_value = utility
	definition.bulk = bulk
	return ItemInstance.new(definition, id)

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok

func finish() -> void:
	print("incinerator_operations_tests: ", "PASS" if failures == 0 else "FAIL", " checks=", checks, " failures=", failures)
	quit(0 if failures == 0 else 1)
