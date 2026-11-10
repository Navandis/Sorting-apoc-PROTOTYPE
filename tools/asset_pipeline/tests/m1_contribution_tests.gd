extends SceneTree

const Request = preload("res://gameplay/requests/contribution_request.gd")

var failures := 0
var checks := 0

func _init() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M1 helper aborted; completion missing")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func run() -> void:
	if OS.get_cmdline_user_args().has("--m1-abort"):
		print("M1 representative helper abort (no completion)")
		quit(2)
		return
	# Contextual accounting remains a property of the shared request owner.
	var request := Request.new("request-test", "medical_bay", {"Medical": 12})
	var carry := CarriedItems.new()
	root.add_child(carry)
	var definition := ItemDefinition.new()
	definition.utility_id = &"Food"
	definition.utility_value = 99
	definition.context_utility_overrides = {&"medical_bay": {"utility_id": &"Medical", "value": 3}}
	var item := ItemInstance.new(definition, "selected-3")
	check(carry.add_item(item), "contextual fixture carries the exact item")
	request.credited["Medical"] = 5
	var preview := request.preview(item)
	check(preview.projected == 8 and preview.applied == 3 and preview.wasted == 0 and preview.remainder == 4,
		"contextual 5/12 +3 projects 8/12 with remainder 4")
	check(request.credited.Medical == 5 and carry.get_selected_item() == item, "preview preserves both owners")
	var observed := []
	carry.contents_changed.connect(func():
		observed.append(request.credited.Medical == 8 and request.spent.size() == 1
			and request.spent[0].item_id == item.instance_id and not carry.get_items().has(item)),
		CONNECT_ONE_SHOT)
	check(request.submit(carry).ok and observed == [true], "exact contextual credit and receipt commit before notification")
	check(request.spent[0].applied == 3 and not request.transaction_active, "receipt preserves the applied credit")
	check(request.preview(null).status == "empty" and not request.submit(carry).ok
		and request.is_accepting() and request.spent.size() == 1, "empty submission keeps the open request intact")

	definition.context_utility_overrides[&"medical_bay"].value = 8
	var big := ItemInstance.new(definition, "selected-8")
	var bad := ItemInstance.new(ItemDefinition.new(), "ineligible")
	check(carry.add_item(big) and carry.add_item(bad), "oversized and ineligible selections coexist")
	request.credited.Medical = 11
	preview = request.preview(big)
	check(preview.projected == 12 and preview.applied == 1 and preview.wasted == 7, "11/12 +8 caps at 12 with 7 wasted")
	carry.select_index(1)
	check(request.preview(bad).status == "ineligible" and not request.submit(carry).ok
		and carry.get_slots() == [big, bad] and carry.get_selected_item() == bad
		and request.credited.Medical == 11 and request.spent.size() == 1,
		"ineligible selection keeps both exact slots and prior accounting")
	carry.select_index(0)
	check(request.submit(carry).ok and request.closed and request.credited.Medical == 12 and request.spent.size() == 2,
		"eligible selection completes the fixed target once")
	check(request.spent[1].item_id == big.instance_id and request.spent[1].wasted == 7
		and request.capture_state().result.Medical.unmet == 0, "captured result keeps the exact capped receipt")
	check(not request.is_accepting() and not request.submit(carry).ok and carry.get_selected_item() == bad
		and request.spent.size() == 2, "closed request preserves the remaining item")
	carry.free()
	check_all_lanes()
	finish()

func check_all_lanes() -> void:
	var request := Request.new("all-lanes", "medical_bay", {"Medical": 3, "Food": 2})
	var carry := CarriedItems.new()
	root.add_child(carry)
	for lane: String in ["Medical", "Food"]:
		var definition := ItemDefinition.new()
		definition.utility_id = StringName(lane)
		definition.utility_value = 3
		check(carry.add_item(ItemInstance.new(definition, lane)) and request.submit(carry).ok,
			"shared owner accepts the selected " + lane + " lane")
		check(request.closed == (lane == "Food"), "shared result closes only when every lane is satisfied")
	check(request.result.size() == 2 and request.spent.size() == 2, "all-lane result retains both receipts")
	carry.free()

func finish() -> void:
	print("M1_CONTRIBUTION_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
