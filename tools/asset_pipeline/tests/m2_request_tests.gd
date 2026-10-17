extends SceneTree

var failures := 0
var checks := 0
var now := 0.0
var _pending_helpers := 0

func _init() -> void:
	create_timer(30).timeout.connect(func(): quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	var script = load("res://gameplay/requests/contribution_request.gd")
	var request = script.new("timed", "medical_bay", {"Medical":12})
	if not check(request.has_method("expire"), "request supports zero/partial expiry without another consumption"):
		finish()
		return
	request.opened_at = 10.0
	request.deadline = 20.0
	request.time_source = func(): return now
	var carry = load("res://carried_items.gd").new()
	root.add_child(carry)
	var item = ItemInstance.new(load("res://prototype_item_catalog.gd").get_definition_by_id(&"loot_000026"), "bandage")
	carry.add_item(item)
	now = 9.0
	check(not request.submit(carry).ok and carry.get_item_count() == 1, "before opening rejects selected item")
	now = 19.999
	check(request.preview(item).status == "eligible", "strictly before deadline preview eligible")
	now = 20.0
	check(not request.submit(carry).ok and carry.get_selected_item() == item and request.spent.is_empty(), "stale eligible preview cannot consume at exact deadline")
	request.expire(now)
	check(request.closed and request.closure_reason == "expired" and request.result.Medical == {"required":12,"supplied":0,"unmet":12}, "zero expiry preserves actual unmet result")
	now = 21.0
	check(not request.submit(carry).ok and carry.get_selected_item() == item, "after expiry remains inert")
	request = script.new("partial", "medical_bay", {"Medical":12})
	request.opened_at = 0.0
	request.deadline = 30.0
	request.time_source = func(): return now
	check(request.submit(carry).ok and request.credited.Medical == 3, "whole selected item credits before expiry")
	now = 30.0
	request.expire(now)
	var saved: Dictionary = request.capture_state()
	request.expire(now + 1.0)
	check(saved == request.capture_state() and request.result.Medical.unmet == 9 and request.spent.size() == 1, "partial expiry retains receipt once; summary is inert")
	var copy = script.new()
	copy.restore_state(saved)
	check(copy.capture_state() == saved, "expired exact history round trip")
	request = script.new("fulfilled", "medical_bay", {"Medical":3})
	request.deadline = 50.0
	request.time_source = func(): return now
	carry.add_item(ItemInstance.new(item.definition, "second-bandage"))
	check(request.submit(carry).ok and request.closure_reason == "fulfilled", "full contribution closes early as fulfilled")
	saved = request.capture_state()
	request.expire(50.0)
	check(saved == request.capture_state(), "scheduled expiry cannot replace fulfilled result")
	carry.free()
	history_and_adjacent_windows()
	finish()

func history_and_adjacent_windows() -> void:
	_pending_helpers += 1
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	wing.configure_new_run()
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	var schedule = wing.run_schedule
	var carry = wing.get_node("Player/CarriedItems")
	check(wing.get_node("DevelopmentSetup/SeedItems/Medical_Bandages/WorldItem").pickup_into(carry) and wing.medical_request.submit(carry).ok, "real Day 1 partial contribution spends exact original host")
	schedule.advance(2550.0)
	schedule.begin_day()
	schedule.advance(300.0)
	check(schedule.requests.size() == 2 and schedule.requests[0].closure_reason == "expired" and schedule.requests[0].credited.Medical == 3, "later occurrence preserves earlier partial history")
	for host: String in ["Medical_Antibiotics", "MedKit_A"]:
		check(wing.get_node("DevelopmentSetup/SeedItems/" + host + "/WorldItem").pickup_into(carry) and wing.medical_request.submit(carry).ok, "Day 2 actual transaction uses remaining stock: " + host)
	check(schedule.requests[1].closed and schedule.requests[1].closure_reason == "fulfilled" and schedule.requests[1].spent[1].wasted == 1, "later occurrence fulfills early with whole-item cap/waste")
	var fulfilled: Dictionary = schedule.requests[1].capture_state()
	schedule.advance(450.0)
	check(schedule.requests[1].capture_state() == fulfilled, "real scheduled expiry is inert after early fulfillment")
	schedule.advance(1800.0)
	schedule.begin_day()
	schedule.advance(2550.0)
	var snapshot: Dictionary = load("res://gameplay/run/run_snapshot.gd").new().capture(wing)
	var validator = load("res://gameplay/run/run_snapshot.gd").new()
	check(validator.validate(snapshot).is_empty() and schedule.requests[2].closure_reason == "expired" and schedule.requests[2].spent.is_empty(), "partial/fulfilled/zero histories coexist in one valid continuing snapshot")
	var invalid := snapshot.duplicate(true)
	invalid.schedule.requests[2].spent = [invalid.schedule.requests[0].spent[0]]
	invalid.schedule.requests[2].credited.Medical = 3
	invalid.schedule.requests[2].result.Medical = {"required":12,"supplied":3,"unmet":9}
	check(validator.validate(invalid).contains("cross-history"), "same exact spent identity cannot be credited on two days")
	invalid = snapshot.duplicate(true)
	var receipt: Dictionary = invalid.schedule.requests[0].spent[0]
	invalid.items[receipt.item_id] = {"definition":receipt.definition_id,"contaminated":false}
	check(validator.validate(invalid).contains("cross-history"), "spent identity cannot retain live physical ownership")
	wing.free()
	var definition: Dictionary = load("res://gameplay/run/run_scenario.gd").new().default_definition()
	definition.events = [{"id":"medical_001","kind":"medical","day":1,"at":25200.0,"deadline":25224.0,"targets":{"Medical":12}},
		{"id":"medical_002","kind":"medical","day":1,"at":25224.0,"deadline":25248.0,"targets":{"Medical":12}}]
	wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	wing.configure_new_run(definition)
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	carry = wing.get_node("Player/CarriedItems")
	check(wing.get_node("DevelopmentSetup/SeedItems/Medical_Bandages/WorldItem").pickup_into(carry), "adjacent-window selected item exists")
	var panel = wing.get_node("MedicalContribution/ContributionPanel")
	panel.destination_valid = func(): return true
	panel.open_panel()
	wing.run_schedule.advance(1.0)
	check(wing.run_schedule.requests.size() == 2 and wing.run_schedule.requests[0].closed and not wing.run_schedule.requests[1].closed and not panel.is_open(), "adjacent boundary closes old panel before binding new occurrence")
	check(carry.get_item_count() == 1 and wing.get_node("MedicalContribution").is_active() and wing.run_schedule.requests[1].spent.is_empty(), "new request restores cues without reopening panel or consuming selected item")
	wing.free()
	_pending_helpers -= 1

func finish() -> void:
	check(_pending_helpers == 0, "all history/adjacency helper checks completed")
	print("M2_REQUEST_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
