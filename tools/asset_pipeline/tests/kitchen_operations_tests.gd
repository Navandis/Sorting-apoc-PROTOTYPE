extends SceneTree

const OperationsPath := "res://gameplay/kitchen/kitchen_operations.gd"
const ConfigPath := "res://gameplay/kitchen/kitchen_test_config.gd"
const Clock = preload("res://gameplay/run/run_clock.gd")

var checks := 0
var failures := 0
var observed_commit := false
var serial := 0

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	if check(FileAccess.file_exists(OperationsPath) and FileAccess.file_exists(ConfigPath), "dedicated Kitchen state owner and test configuration exist"):
		test_generation(load(ConfigPath))
		test_penalty_and_receipts(load(OperationsPath))
		test_hydration_first(load(OperationsPath))
		test_schedule(load(OperationsPath))
	print("kitchen_operations_tests: %s (%d checks, %d failures)" % ["PASS" if failures == 0 else "FAIL", checks, failures])
	quit(0 if failures == 0 else 1)

func test_generation(config: GDScript) -> void:
	for total in range(60, 81):
		var bounds: Vector2i = config.food_bounds(total)
		for food in range(total + 1):
			var hydration := total - food
			check((food >= bounds.x and food <= bounds.y) == (4 * maxi(food, hydration) <= 5 * mini(food, hydration)),
				"feasible split exactly matches the 1.25 ratio for %d/%d" % [food, hydration])
		for food in range(bounds.x, bounds.y + 1):
			var proposed := Vector2i(food, total - food)
			for room: int in [0, 1, 2, 30, total - 1, total, 150]:
				var clipped: Vector2i = config.clip(proposed, room, 1)
				var admitted := mini(total, room)
				check(clipped.x + clipped.y == admitted and abs(clipped.x * total - admitted * food) * 2 <= total,
					"integer clipping conserves admission and gives the larger remainder")
	check(config.food_bounds(72) == Vector2i(32, 40), "72 Utility permits exactly Food 32 through 40")
	check(config.clip(Vector2i(35, 40), 30, 1) == Vector2i(14, 16), "35/40 clips to 14/16 at 30 headroom")
	check(config.clip(Vector2i(36, 36), 1, 1) == Vector2i(1, 0)
		and config.clip(Vector2i(36, 36), 1, 2) == Vector2i(0, 1), "one-Utility exact ties alternate by event parity")
	var rng := RandomNumberGenerator.new()
	var reference := RandomNumberGenerator.new()
	rng.seed = 13019
	reference.seed = rng.seed
	for draw in range(100):
		var total := reference.randi_range(60, 80)
		var food := reference.randi_range(ceili(4.0 * total / 9), floori(5.0 * total / 9))
		check(config.draw_proposal(rng) == Vector2i(food, total - food) and rng.state == reference.state,
			"proposal uses a uniform total followed by one uniform feasible split")

func test_penalty_and_receipts(script: GDScript) -> void:
	var clock := Clock.new()
	var ops: RefCounted = script.new(clock, func(id: String): return id == "already-spent")
	ops.initialize(10, 20)
	var carry := CarriedItems.new()
	root.add_child(carry)
	ops._add_demand(Vector2i(50, 40), 0, 1)
	clock.elapsed = 59.9
	ops.settle_due()
	check(ops.sprint_allowed() and ops.effective_capacity(25) == 25, "open obligation gives one full grace period")
	var food := make_item("Food", 25)
	carry.add_item(food)
	var preview: Dictionary = ops.preview(food)
	check(preview.applied == 25 and preview.wasted == 0 and preview.before == 90 and preview.after == 65
		and ops.outstanding == Vector2i(50, 40) and carry.get_selected_item() == food, "grace preview is read-only and shows pending relief")
	clock.elapsed = 60.0
	ops.settle_due()
	check(not ops.sprint_allowed() and ops.effective_capacity(25) == 17, "90 overdue Utility costs 30% and floors 25 capacity to 17")
	var hyd := make_item("Hydration", 20)
	carry.add_item(hyd)
	check(not ops.contribute(carry, hyd, func(): return true).ok, "stale selection cannot be replaced")
	check(not ops.contribute(carry, food, func(): return false).ok, "inaccessible station spends nothing")
	carry.item_removed.connect(func(item: ItemInstance):
		var receipts: Array = ops.capture_state().receipts
		observed_commit = item == food and receipts.size() == 1 and receipts[0].item_id == food.instance_id \
			and ops.outstanding == Vector2i(25, 40) and carry.get_selected_item() == hyd
		check(not ops.contribute(carry, hyd, func(): return true).ok, "removal observer cannot reenter a contribution"),
		CONNECT_ONE_SHOT)
	check(ops.contribute(carry, food, func(): return true).ok and observed_commit, "item, credited balance and receipt commit before observers")
	check(ops.contribute(carry, hyd, func(): return true).ok and ops.outstanding == Vector2i(25, 20)
		and ops.effective_capacity(25) == 21 and not ops.sprint_allowed(), "45 remaining costs 15% and keeps sprint disabled")
	var partial: Dictionary = ops.capture_state()
	ops._add_demand(Vector2i(35, 40), 100, 2)
	check(ops.outstanding == Vector2i(60, 60) and ops.effective_capacity(25) == 15 and ops.deadline_at() == 60,
		"35/40 joins the 25/20 remainder at the original deadline")
	ops.restore_state(partial)
	submit(ops, carry, "Food", 9)
	check(ops.outstanding == Vector2i(16, 20) and ops.effective_capacity(25) == 22, "nine more credit gives 12% loss and capacity 22")
	ops._add_demand(Vector2i(44, 40), 100, 2)
	check(ops.outstanding == Vector2i(60, 60) and ops.effective_capacity(25) == 15 and ops.deadline_at() == 60,
		"later additions merge into the remainder without renewing grace")
	ops._add_demand(Vector2i(35, 40), 110, 3)
	check(ops.outstanding == Vector2i(74, 76) and ops.effective_capacity(20) == 10, "overdue addition clips at 150 and half capacity")
	submit(ops, carry, "Food", 71)
	var oversized: Dictionary = submit(ops, carry, "Food", 9)
	check(oversized.applied == 3 and oversized.wasted == 6 and oversized.before - oversized.after == 3
		and ops.outstanding == Vector2i(0, 76), "oversize credits only three Food and wastes six without Hydration spill")
	for item: ItemInstance in [make_item("Food", 1), make_item("Weapons", 5), make_item("Hydration", 5, "already-spent")]:
		carry.add_item(item)
		check(not ops.contribute(carry, item, func(): return true).ok and carry.get_selected_item() == item,
			"full lane, wrong category or another consumer's receipt rejects without spending")
		carry.remove_selected()
	submit(ops, carry, "Hydration", 75)
	check(ops.outstanding == Vector2i(0, 1) and ops.effective_capacity(25) == 24 and not ops.sprint_allowed(),
		"one Utility still costs a fractional point and disables sprint")
	submit(ops, carry, "Hydration", 1)
	check(ops.sprint_allowed() and ops.effective_capacity(25) == 25 and ops.capture_state().receipts.size() == 7,
		"clearance restores baseline and retains the closed receipts")
	ops._add_demand(Vector2i(30, 30), 120, 4)
	check(ops.sprint_allowed() and ops.deadline_at() == 180, "a later opening receives fresh grace")
	carry.free()

func test_hydration_first(script: GDScript) -> void:
	var clock := Clock.new()
	var ops: RefCounted = script.new(clock)
	ops.initialize(10, 20)
	var carry := CarriedItems.new()
	root.add_child(carry)
	ops._add_demand(Vector2i(30, 30), 0, 1)
	clock.elapsed = 60.0
	ops.settle_due()
	submit(ops, carry, "Hydration", 30)
	check(ops.outstanding == Vector2i(30, 0) and not ops.sprint_allowed(), "Hydration can clear first without ending Food demand")
	var extra := make_item("Hydration", 8)
	carry.add_item(extra)
	check(ops.preview(extra).reason == "Hydration is already supplied."
		and not ops.contribute(carry, extra, func(): return true).ok
		and carry.get_selected_item() == extra and ops.capture_state().receipts.size() == 1
		and ops.outstanding == Vector2i(30, 0), "a full Hydration lane rejects without redirecting credit or removing the item")
	carry.remove_selected()
	submit(ops, carry, "Food", 30)
	check(ops.outstanding == Vector2i.ZERO and ops.sprint_allowed() and ops.capture_state().receipts.size() == 2,
		"Food clearance closes the remaining obligation and keeps both receipts")
	carry.free()

func test_schedule(script: GDScript) -> void:
	var clock := Clock.new()
	var blocked: RefCounted = script.new(clock)
	var paid: RefCounted = script.new(clock)
	var other_amounts: RefCounted = script.new(clock)
	blocked.initialize(1501, 3205)
	paid.initialize(1501, 3205)
	other_amounts.initialize(1501, 5432)
	var closure_notices := []
	paid.notice.connect(func(message: String): closure_notices.append(message))
	var carry := CarriedItems.new()
	root.add_child(carry)
	var previous := 0.0
	var expedition_rng := RandomNumberGenerator.new()
	for event in range(1, 7):
		var due: float = blocked.next_boundary_at()
		check(due >= previous + 180 and due <= previous + 300 and due == paid.next_boundary_at(),
			"same timing stream picks the same bounded integer timestamp")
		clock.elapsed = due
		if event == 1:
			carry.add_item(make_item("Food", 100))
			check(paid.contribute(carry, carry.get_selected_item(), func(): return true).ok,
				"at the event timestamp, scheduled demand settles before input")
		blocked.settle_due()
		paid.settle_due()
		other_amounts.settle_due()
		var full: Dictionary = blocked.capture_state()
		var clear: Dictionary = paid.capture_state()
		check(full.event_index == event and full.next_at == clear.next_at and full.timing_state == clear.timing_state
			and full.amount_state == clear.amount_state, "processed event consumes identical draws even with different headroom")
		var different: Dictionary = other_amounts.capture_state()
		check(full.next_at == different.next_at and full.timing_state == different.timing_state
			and full.amount_state != different.amount_state, "changing the amount seed leaves the schedule unchanged")
		for draw in range(event * 7):
			expedition_rng.randi()
		if event > 3:
			check(blocked.outstanding.x + blocked.outstanding.y == 150, "fully capped event issues nothing")
		if paid.outstanding.x > 0:
			submit(paid, carry, "Food", 100)
		submit(paid, carry, "Hydration", 100)
		check(closure_notices.back() == "Kitchen supplied.", "clearance during grace reports supply without claiming an expired penalty")
		clock.elapsed = due + 60.0
		blocked.settle_due()
		paid.settle_due()
		other_amounts.settle_due()
		previous = due
	var next: float = blocked.next_boundary_at()
	submit(blocked, carry, "Food", 9)
	check(blocked.outstanding.x + blocked.outstanding.y == 141 and blocked.next_boundary_at() == next,
		"discarded overflow cannot refill credited Utility or move a trigger")
	carry.free()

func submit(ops: RefCounted, carry: CarriedItems, category: String, utility: int) -> Dictionary:
	var item := make_item(category, utility)
	check(carry.add_item(item), "fixture can carry a one-Bulk contribution")
	var result: Dictionary = ops.contribute(carry, item, func(): return true)
	check(result.ok, "eligible selected %s commits" % category)
	return result

func make_item(category: String, utility: int, id: String = "") -> ItemInstance:
	serial += 1
	var definition := ItemDefinition.new()
	definition.item_id = StringName("test_" + category)
	definition.storage_category = category
	definition.utility_id = StringName(category)
	definition.utility_value = utility
	definition.bulk = 1
	return ItemInstance.new(definition, "kitchen-test-%d" % serial if id.is_empty() else id)

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok
