extends "res://tools/asset_pipeline/tests/m1_contribution_tests.gd"

func run() -> void:
	for order: Array in [["Food","Hydration"],["Hydration","Food"]]:
		var request = load("res://gameplay/requests/contribution_request.gd").new("meal", "kitchen", {"Food":6,"Hydration":3})
		var carry = load("res://carried_items.gd").new()
		root.add_child(carry)
		var panel = load("res://gameplay/requests/contribution_panel.gd").new()
		root.add_child(panel)
		panel.configure(request, carry, func(): return true)
		panel.open_panel()
		for lane: String in order:
			var item := ItemInstance.new(load("res://data/items/definitions/" + ("loot_000006" if lane == "Food" else "loot_000019") + ".tres"), "spent-" + lane)
			carry.add_item(item)
			panel.refresh()
			check(panel.get("lane_rows") is Dictionary and panel.get("lane_rows").size() == 2, "both lane rows visible together")
			var notifications: Array = []
			var observe := func(): notifications.append(request.spent.any(func(r): return r.item_id==item.instance_id) and request.credited[lane]==request.targets[lane] and not carry.get_items().has(item))
			carry.contents_changed.connect(observe)
			panel.handle_e(false,false)
			panel.handle_e(true,false)
			carry.contents_changed.disconnect(observe)
			check(notifications==[true],"receipt and lane credit publish before carrying notification")
			check(request.credited[lane] == request.targets[lane], "selected eligible lane credited exactly")
			check(request.closed == (lane == order.back()), "closure requires both lanes")
			if not request.closed:
				var full := ItemInstance.new(item.definition,"full-" + lane)
				carry.add_item(full)
				var preview: Dictionary = request.preview(full)
				check(preview.lane == lane and preview.status == "ineligible" and preview.get("reason") == "full", "full-lane rejection identifies actual lane")
				panel.refresh()
				check(panel.status_label.text == lane + " requirement already met", "full lane explained without redirect")
				panel.handle_e(false,false)
				panel.handle_e(true,false)
				check(carry.get_selected_item() == full and request.spent.size() == 1, "full lane retains whole item")
				carry.remove_item(full)
		check(request.result.Food.unmet == 0 and request.result.Hydration.unmet == 0 and request.spent.size() == 2, "both receipts and result retained")
		panel.free()
		carry.free()
	finish()

func finish() -> void:
	print("M3_CONTRIBUTION_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
