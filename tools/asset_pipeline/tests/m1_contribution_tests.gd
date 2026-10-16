extends SceneTree

var failures := 0
var checks := 0

func _init() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M1 helper aborted; completion missing" )
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	if OS.get_cmdline_user_args().has("--m1-abort"):
		print("M1 representative helper abort (no completion)")
		quit(2)
		return
	if not check(ResourceLoader.exists("res://gameplay/requests/contribution_request.gd"), "shared contribution request exists"):
		finish()
		return
	var request_script = load("res://gameplay/requests/contribution_request.gd")
	var request = request_script.new("request-test", "medical_bay", {"Medical": 12})
	var carry = load("res://carried_items.gd").new()
	root.add_child(carry)
	var definition = load("res://item_definition.gd").new()
	definition.utility_id = &"Food"
	definition.utility_value = 99
	definition.context_utility_overrides = {&"medical_bay": {"utility_id": &"Medical", "value": 3}}
	var item = load("res://item_instance.gd").new(definition, "selected-3")
	carry.add_item(item)
	request.credited["Medical"] = 5
	var preview: Dictionary = request.preview(item)
	check(preview.projected == 8 and preview.applied == 3 and preview.wasted == 0 and preview.remainder == 4, "contextual 5/12 +3 projects 8/12 with remainder 4")
	check(request.credited.Medical == 5 and carry.get_selected_item() == item, "preview preserves both owners")
	var panel = load("res://gameplay/requests/contribution_panel.gd").new()
	root.add_child(panel)
	panel.configure(request, carry, func(): return true)
	panel.open_panel()
	check(carry.get_item_count() == 1 and panel.is_open(), "panel opening spends nothing")
	await process_frame
	await process_frame
	var bounds: Rect2 = panel._card.get_global_rect()
	check(absf(bounds.get_center().x - root.get_visible_rect().get_center().x) <= 1.0, "panel is horizontally centered")
	check(panel.preview_state.projected == 8 and panel.total_label.text.contains("8 / 12"), "actual UI binds projected total")
	check(panel.pip_states.count("committed") == 5 and panel.pip_states.count("projected") == 3, "actual UI separates solid and projected pips")
	panel.handle_e(true, false)
	panel.handle_e(true, true)
	check(request.credited.Medical == 8 and carry.get_item_count() == 0, "first E after non-E opening commits immediately; echo cannot repeat")
	check(request.spent[0].item_id == "selected-3" and request.spent[0].applied == 3, "receipt retains exact spent ID and historical credit")
	panel.handle_e(true, false)
	check(request.spent.size() == 1, "held E never repeats")
	check(panel.preview_state.status == "empty" and panel.gain_label.text == "", "empty UI has no misleading gain")
	panel.handle_e(false, false)
	panel.handle_e(true, false)
	check(panel.is_open() and request.spent.size() == 1 and request.credited.Medical == 8, "empty submission preserves open request and receipt")
	definition.context_utility_overrides[&"medical_bay"].value = 8
	var big = load("res://item_instance.gd").new(definition, "selected-8")
	carry.add_item(big)
	request.credited.Medical = 11
	panel.refresh()
	check(panel.preview_state.projected == 12 and panel.preview_state.applied == 1 and panel.preview_state.wasted == 7, "11/12 +8 caps at 12 with 7 wasted")
	check(panel.gain_label.text.contains("1 applied") and panel.gain_label.text.contains("7 wasted"), "UI exposes cap and waste before submission")
	var bad_definition = load("res://item_definition.gd").new()
	var bad = load("res://item_instance.gd").new(bad_definition, "ineligible")
	carry.add_item(bad)
	carry.select_index(1)
	panel.refresh()
	check(panel.status_label.text == "Selected item not eligible" and panel.gain_label.text == "" and panel.invalid_highlight, "ineligible UI has text/red highlight and no gain")
	panel.handle_e(false, false)
	panel.handle_e(true, false)
	check(request.credited.Medical == 11 and carry.get_selected_item() == bad and carry.get_slots() == [big, bad], "selection at commit governs rejection, preserving original carrying")
	check(panel.is_open() and panel.pip_states.count("projected") == 0, "ineligible rejection keeps panel open without projected pips")
	carry.select_index(0)
	panel.panel_closed.connect(func(): check(not request.transaction_active, "completion closes after transaction returns"))
	panel.handle_e(false, false)
	panel.handle_e(true, false)
	check(request.closed and request.credited.Medical == 12 and request.spent.size() == 2, "eligible selection closes request exactly once")
	check(request.spent[1].wasted == 7 and request.result.Medical.unmet == 0, "durable capped result records waste")
	var rejected: Dictionary = request.submit(carry)
	check(not rejected.ok and carry.get_selected_item() == bad and request.spent.size() == 2, "closed request preserves remaining item")
	check(not panel.is_open() and request.capture_state().result.Medical.unmet == 0, "completion closes panel and retains inspectable persisted result")
	panel.open_panel()
	check(not panel.is_open(), "closed request cannot reopen")
	panel.close_panel()
	check(not panel.is_open(), "visible Close affords no submission")
	panel.free()
	carry.free()
	await check_all_lanes()
	finish()

func check_all_lanes() -> void:
	var request = load("res://gameplay/requests/contribution_request.gd").new("all-lanes", "medical_bay", {"Medical": 3, "Food": 2})
	var carry = load("res://carried_items.gd").new()
	root.add_child(carry)
	var panel = load("res://gameplay/requests/contribution_panel.gd").new()
	root.add_child(panel)
	panel.configure(request, carry, func(): return true)
	panel.open_panel()
	for lane: String in ["Medical", "Food"]:
		var definition = load("res://item_definition.gd").new()
		definition.utility_id = StringName(lane)
		definition.utility_value = 3
		carry.add_item(load("res://item_instance.gd").new(definition, lane))
		panel.handle_e(false, false)
		panel.handle_e(true, false)
		check(panel.is_open() == (lane == "Medical") and request.closed == (lane == "Food"), "panel closes only when all lanes are satisfied: " + lane)
	check(request.result.size() == 2 and request.spent.size() == 2, "all-lane result retains both receipts")
	panel.free()
	carry.free()

func finish() -> void:
	print("M1_CONTRIBUTION_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
