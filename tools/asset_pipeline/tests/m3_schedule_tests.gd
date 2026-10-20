extends "res://tools/asset_pipeline/tests/m2_schedule_tests.gd"

func run() -> void:
	var authored: Dictionary = load("res://gameplay/run/run_scenario.gd").new().default_definition()
	if OS.get_cmdline_user_args().has("--m3-mechanical-only"):
		mechanical_endpoint(authored)
		finish()
		return
	var wing = new_wing(authored)
	if not check(wing.has_node("KitchenContribution"), "canonical wing registers Kitchen station alongside Medical"):
		wing.free()
		finish()
		return
	var schedule = wing.run_schedule
	var snapshot = load("res://gameplay/run/run_snapshot.gd").new()
	check(wing.get_initialization_error().is_empty(), "all twelve future manifests prevalidated before run publication")
	schedule.advance(1.2345678912345)
	schedule.advance(300.0-schedule.clock.elapsed)
	check(schedule.clock.elapsed == 300.0,"fractional approach reaches exact authored boundary: %.17f" % schedule.clock.elapsed)
	var medical = schedule.active_request("medical_bay")
	var kitchen = schedule.active_request("kitchen")
	if not check(medical != null and kitchen != null and medical != kitchen, "Medical and breakfast simultaneously active at 09:00"):
		wing.free()
		finish()
		return
	check(wing.get_node("MedicalContribution").request == medical and wing.get_node("KitchenContribution").request == kitchen and wing.medical_request == medical, "independent occurrence binding")
	var carry = wing.get_node("Player/CarriedItems")
	for pair: Array in [["loot_000025",medical],["loot_000007",kitchen],["loot_000019",kitchen]]:
		var worlds: Array = wing.get_node("DevelopmentSetup/SeedItems").get_children().filter(func(host): return String(host.item_id) == pair[0])
		var item: ItemInstance = worlds[0].get_node("WorldItem").get_item_instance()
		check(worlds[0].get_node("WorldItem").pickup_into(carry), "real seed TAKE for contribution")
		carry.select_index(carry.get_slots().find(item))
		check(pair[1].submit(carry).ok, "real selected item transaction")
	check(medical.credited.Medical == 5 and kitchen.credited == {"Food":5,"Hydration":3}, "simultaneous partial histories")
	var duplicate := ItemInstance.new(load("res://data/items/definitions/loot_000007.tres"),medical.spent[0].item_id)
	carry.add_item(duplicate)
	check(not kitchen.submit(carry).ok and carry.get_selected_item()==duplicate,"runtime rejects already-spent identity from other department")
	carry.remove_item(duplicate)
	var state: Dictionary = snapshot.capture(wing)
	check(state.schema == 3 and snapshot.validate(state).is_empty(), "schema 3 validates coherent concurrent physical/request state: " + snapshot.validate(state))
	var corrupt: Dictionary = state.duplicate(true)
	corrupt.schedule.definition.events.filter(func(e): return e.kind=="return")[0].manifest[0]="loot_000006"
	check(not snapshot.validate(corrupt).is_empty(),"live cargo must match captured exact manifest")
	corrupt = state.duplicate(true)
	corrupt.schedule.requests[1].spent[0].item_id = corrupt.schedule.requests[0].spent[0].item_id
	check(not snapshot.validate(corrupt).is_empty(), "cross-department duplicate spent identity rejected")
	corrupt = state.duplicate(true)
	corrupt.schedule.requests[1].credited.Hydration += 1
	check(not snapshot.validate(corrupt).is_empty(), "credit must equal exact per-lane receipt sums")
	var record := [{"targets":{"Food":30,"Hydration":24},"credited":{"Food":30,"Hydration":12}}, {"targets":{"Food":36,"Hydration":24},"credited":{"Food":18,"Hydration":24}}, {"targets":{"Food":36,"Hydration":30},"credited":{"Food":0,"Hydration":0}}]
	check(schedule.meal_coverage(record) == 50.0 and schedule.meal_coverage([]) == null, "six equal fractions give 50%, absent meals N/A")
	for meal: Dictionary in record: meal.credited=meal.targets.duplicate()
	check(schedule.meal_coverage(record)==100.0,"all six lanes full is 100%")
	for meal: Dictionary in record: meal.credited.Hydration=0
	check(schedule.meal_coverage(record)==50.0,"three full Food and three empty Hydration lanes have equal weights")
	for meal: Dictionary in record: meal.credited.Food=0
	check(schedule.meal_coverage(record)==0.0,"ignored scheduled meals count six zeros")
	schedule.advance(2250.0)
	check(schedule.report.meals.size() == 3 and is_equal_approx(schedule.report.meal_coverage,100.0*(5.0/30.0+3.0/24.0)/6.0), "midnight captures all six lanes including ignored meals")
	check(schedule.report.backlog.size() == 3 and schedule.report.forfeits.size() == 1 and schedule.report.admitted.size() == 3, "fourth exact 16-item return forfeits upstream under 1+2 pressure")
	state = snapshot.capture(wing)
	check(snapshot.validate(state).is_empty(), "report-pending snapshot validates: " + snapshot.validate(state))
	corrupt = state.duplicate(true)
	corrupt.schedule.report.meal_coverage = 46.7
	check(not snapshot.validate(corrupt).is_empty(), "report coverage tampering rejected")
	var report: Dictionary = schedule.report.duplicate(true)
	schedule.advance(100.0)
	check(report == schedule.report and schedule.clock.elapsed == 2550.0, "report hold is read-only")
	for day: int in [2,3,4]:
		schedule.begin_day()
		schedule.advance(2550.0)
		check(snapshot.validate(snapshot.capture(wing)).is_empty(), "coherent saved day " + str(day))
	check(schedule.requests.size() == 12 and schedule.issued.size() == 24 and schedule.report.meals.is_empty() and schedule.report.meal_coverage == null, "finite scenario has no replenishment or invented deprivation after day 3")
	wing.free()
	var full_lane_wing = new_wing(authored)
	full_lane_wing.run_schedule.advance(300.0)
	var full_lane = full_lane_wing.run_schedule.active_request("kitchen")
	for id: String in ["loot_000007","loot_000006","loot_000007","loot_000011"]:
		var host = full_lane_wing.get_node("DevelopmentSetup/SeedItems").get_children().filter(func(h): return String(h.item_id)==id and not h.is_queued_for_deletion())[0]
		var held = full_lane_wing.get_node("Player/CarriedItems")
		check(host.get_node("WorldItem").pickup_into(held) and full_lane.submit(held).ok,"actual whole-item contribution to one-full-lane fixture")
	check(not full_lane.closed and full_lane.credited=={"Food":30,"Hydration":0} and snapshot.validate(snapshot.capture(full_lane_wing)).is_empty(),"full Food/empty Hydration is a valid open persisted occurrence")
	full_lane_wing.free()
	await compare_m3_segments(authored)
	mechanical_endpoint(authored)
	finish()

func mechanical_endpoint(authored: Dictionary) -> void:
	var fixture: Dictionary = authored.duplicate(true)
	fixture.events=[{"id":"return_001","kind":"return","day":1,"at":25200.0,"departure":0.0,"manifest":["loot_000026"],"presentation_seed":9001}]
	var wing = new_wing(fixture)
	var schedule = wing.run_schedule
	var cycle = wing.get_node("ReceivingRuntime/ReceivingLiftCycle")
	schedule.advance(1.2345678912345)
	schedule.advance(cycle._phase_duration-cycle._elapsed)
	schedule.advance(0.73123456789)
	schedule.advance(6.0)
	schedule.advance(123.456)
	check(wing.get_node("ReceivingRuntime/ReceivingDeckPresenter").get_materialized_world_items()[0].pickup_into(wing.get_node("Player/CarriedItems")),"actual TAKE starts mechanical endpoint regression")
	schedule.advance(1.123456789)
	var remaining: float = cycle._phase_duration-cycle._elapsed
	print("M3_MECHANICAL_ENDPOINT clock=%.17f remaining=%.17f" % [schedule.clock.elapsed,remaining])
	schedule.advance(remaining)
	print("M3_MECHANICAL_RESULT ",cycle.capture_state())
	check(cycle.get_cycle_state()==0 and cycle.is_busy(),"exact remaining closing duration settles outbound after fractional calendar history")
	wing.free()

func compare_m3_segments(authored: Dictionary) -> void:
	var first = new_wing(authored)
	first.run_schedule.advance(2550.0)
	var expected: Dictionary = first.run_schedule.capture_state()
	var cycle: Dictionary = first.get_node("ReceivingRuntime/ReceivingLiftCycle").capture_state()
	first.free()
	var second = new_wing(authored)
	while second.run_schedule.clock.elapsed < 2549.9: second.run_schedule.advance(0.077)
	second.run_schedule.advance(2550.0-second.run_schedule.clock.elapsed)
	var actual: Dictionary = second.run_schedule.capture_state()
	check(actual.issued.keys()==expected.issued.keys() and actual.requests.size()==4,"bulk/fractional advances issue each destination/return once")
	for index: int in actual.requests.size():
		var a: Dictionary = actual.requests[index]
		var b: Dictionary = expected.requests[index]
		check([a.occurrence_id,a.opened_at,a.deadline,a.closed_at,a.result]==[b.occurrence_id,b.opened_at,b.deadline,b.closed_at,b.result],"bulk/fractional request chronology exact")
	var phase: Dictionary = second.get_node("ReceivingRuntime/ReceivingLiftCycle").capture_state()
	check(phase.state==cycle.state and absf(phase.elapsed-cycle.elapsed)<1e-9 and actual.report.meal_coverage==expected.report.meal_coverage,"bulk/fractional mechanics and six-lane report agree")
	second.free()

func finish() -> void:
	paused = false
	print("M3_SCHEDULE_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
