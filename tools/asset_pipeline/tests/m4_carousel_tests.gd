extends "res://tools/asset_pipeline/tests/m1_rendered_tests.gd"

func run() -> void:
	create_timer(60).timeout.connect(func():
		push_error("M4 carousel helper incomplete")
		quit(3))
	if not check(ResourceLoader.exists("res://gameplay/requests/dispatch_carousel.gd"), "Dispatch carousel exists"):
		finish()
		return
	var carry := CarriedItems.new()
	carry.name = "CarouselCarry"
	root.add_child(carry)
	var panel = load("res://gameplay/requests/dispatch_carousel.gd").new()
	root.add_child(panel)
	panel.configure(null,carry,func(): return true)
	var teams: Array = []
	for i: int in 6: teams.append(load("res://gameplay/requests/dispatch_loadout.gd").new("team-%d" % i,1,i+1))
	panel.set_teams(teams)
	var bread := ItemInstance.new(load("res://data/items/definitions/loot_000006.tres"),"carousel-bread")
	carry.add_item(bread)
	await key(KEY_A,true)
	await key(KEY_E,true)
	panel.open_panel()
	await key(KEY_A,true)
	await key(KEY_E,true,true)
	check(panel.is_open() and panel.center_index == 0 and carry.get_selected_item() == bread, "Opening preserves held A/E guards; no submission")
	await key(KEY_A,false)
	await key(KEY_E,false)
	await key(KEY_D,true)
	check(panel.transitioning and panel.center_index == 1, "Fresh D navigates stable six-team order")
	await key(KEY_E,true)
	check(teams[1].spent.is_empty(), "E during transition is rejected")
	await create_timer(0.25).timeout
	await key(KEY_E,true)
	check(teams[1].spent.is_empty(), "Transition cannot buffer a held submission")
	await key(KEY_E,false)
	await key(KEY_E,true)
	check(teams[1].credited.Food == 10 and teams[0].credited.Food == 0 and carry.get_item_count() == 0, "Fresh E commits only centered recipient")
	check(panel.center_index == 1 and panel.is_open(), "Partial contribution keeps recipient and interface")
	await key(KEY_E,false)
	await key(KEY_D,false)
	var extra := ItemInstance.new(load("res://data/items/definitions/loot_000006.tres"),"carousel-bread-2")
	carry.add_item(extra)
	await key(KEY_E,true)
	await key(KEY_E,false)
	carry.add_item(ItemInstance.new(extra.definition,"carousel-full-food"))
	panel.refresh()
	check(panel.preview_state.reason == "full" and panel.lane_rows.Food.rejected and not panel.lane_rows.Medical.rejected, "Full target rejection is lane-specific")
	carry.remove_selected()
	carry.add_item(ItemInstance.new(load("res://data/items/definitions/loot_000165.tres"),"carousel-ineligible"))
	panel.refresh()
	check(panel.lane_rows.values().all(func(row): return row.rejected), "Globally ineligible selection marks all five lanes")
	carry.remove_selected()
	check(teams[1].dispatch_underprepared(), "Partial dispatch commits backend result")
	panel.refresh()
	check(panel.is_open() and panel.center_index == 1 and panel.status_label.text == "Team Dispatched" and not panel.manual_button.visible, "Terminal centered card stays in place and read-only while others remain")
	var style: StyleBoxFlat = panel._card.get_theme_stylebox("panel")
	check(style.bg_color.b > 0.8 and panel.item_label.get_theme_color("font_color").r < 0.2, "Light-blue treatment includes whole background and readable card text")
	panel.navigate(1)
	panel.close_panel()
	panel.open_panel()
	check(panel._card.modulate.a == 1.0,"Closing during a transition does not leave reopened card dimmed")
	for count: int in [1,2,5,6]:
		panel.set_teams(teams.slice(0,count))
		panel.open_panel()
		panel.refresh()
		check(panel.previous_card.visible == (count > 2) and panel.next_card.visible == (count > 1), "No duplicate side recipients for %d teams" % count)
	var capacity_team = load("res://gameplay/requests/dispatch_loadout.gd").new("capacity",1,1)
	panel.set_teams([capacity_team])
	panel.open_panel()
	var large_definition := ItemDefinition.new()
	large_definition.utility_id = &"Food"
	large_definition.utility_value = 1
	large_definition.bulk = 20
	carry.add_item(ItemInstance.new(large_definition,"capacity-20"))
	panel.handle_e(false,false)
	panel.handle_e(true,false)
	var rejected_definition := ItemDefinition.new()
	rejected_definition.utility_id = &"Hydration"
	rejected_definition.utility_value = 1
	rejected_definition.bulk = 9
	carry.add_item(ItemInstance.new(rejected_definition,"capacity-9"))
	panel.refresh()
	check(panel.preview_state.status == "capacity" and panel.status_label.text == "Insufficient load capacity." and panel.lane_rows.values().all(func(row): return row.rejected and row.projected.size.x == 0),"Capacity rejection is explicit and invents no green projected contribution")
	carry.remove_selected()
	panel.set_teams(teams)
	panel.open_panel()
	carry.add_item(ItemInstance.new(load("res://data/items/definitions/loot_000001.tres"),"wheel-a"))
	carry.add_item(ItemInstance.new(load("res://data/items/definitions/loot_000006.tres"),"wheel-b"))
	carry.select_index(0)
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	Input.parse_input_event(wheel)
	await frames(2)
	check(carry.get_selected_index() == 1 and panel.center_index == 0,"Wheel changes carried selection once while retaining centered team")
	await key(KEY_1,true)
	await key(KEY_1,false)
	check(carry.get_selected_index() == 0 and panel.center_index == 0,"Number shortcuts continue selecting carried items, not teams")
	for supply: ItemInstance in carry.get_items(): carry.remove_item(supply)
	for team: RefCounted in teams:
		if not team.closed: team.dispatch_underprepared()
	await frames(3)
	check(not panel.is_open(), "All-done closes interface without auto-advancing recipient")
	await compact_checks(panel,carry)
	panel.free()
	for i: int in 15: carry.add_item(ItemInstance.new(load("res://data/items/definitions/loot_000001.tres"),"strip-%d" % i))
	carry.select_index(14)
	var hud := CarriedItemsHUD.new()
	hud.carried_items_path = NodePath("../CarouselCarry")
	root.add_child(hud)
	await frames(3)
	check(carry.get_item_count() == 15 and hud._slot_row.find_children("*","Label",true,false).any(func(label): return label.text.begins_with("#15  ")), "Selected fifteenth item remains visibly reachable beyond ten shortcuts")
	hud.free()
	carry.free()
	finish()

func capture_compact(panel: CanvasLayer, label: String) -> void:
	if DisplayServer.get_name() == "headless": return
	if evidence_dir.is_empty(): return
	for size: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
		DisplayServer.window_set_size(size)
		await frames(6)
		var card: Rect2 = panel._card.get_global_rect()
		check(root.get_visible_rect().encloses(card),"Compact card contained at " + str(size))
		for control: Control in panel._card.find_children("*","Control",true,false):
			if control.is_visible_in_tree(): check(card.grow(1).encloses(control.get_global_rect()),"Compact control contained: " + control.name)
		await capture("%s-%d" % [label,size.x])

func compact_checks(panel: CanvasLayer, carry: CarriedItems) -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m4-ui-evidence-dir="): evidence_dir = arg.trim_prefix("--m4-ui-evidence-dir=")
	if not evidence_dir.is_empty(): DirAccess.make_dir_recursive_absolute(evidence_dir)
	var team = load("res://gameplay/requests/dispatch_loadout.gd").new("opaque:dispatch:86",4,1)
	team.day = 1
	team.credited.Food = 12
	team.outgoing_bulk = 2
	panel.set_teams([team,load("res://gameplay/requests/dispatch_loadout.gd").new("other",4,2)])
	panel.open_panel()
	var definition := ItemDefinition.new()
	definition.display_name = "Food [color=red]literal[/color]"
	definition.utility_id = &"Food"
	definition.utility_value = 12
	definition.bulk = 6
	var item := ItemInstance.new(definition,"preview-12")
	carry.add_item(item)
	panel.refresh()
	var lane: Control = panel.lane_rows.Food.label
	check(lane is RichTextLabel,"Lane preview supports semantic substring styling")
	if lane is RichTextLabel:
		check(lane.get_parsed_text() == "Food 24/48 (+12 / 0 wasted)","Exact zero-waste projection")
		check(lane.text == "Food [color=#a6f2c4]24[/color]/48 ([color=#a6f2c4]+12[/color] / 0 wasted)","Only projected numerator and applied contribution green; zero waste normal")
		check(panel.lane_rows.Hydration.label.get_parsed_text() == "Hydration 0/48","Unaffected lane remains committed only")
	check(panel.bulk_label.text == "Outgoing 2 (+6) / 112 Bulk · Return Capacity 110 (-6)","Whole-item Bulk signed deltas retain committed totals")
	check(panel.title_label.tooltip_text.is_empty() and panel.deadline_label.text == "Day 1","Opaque request identities hidden")
	check(panel.status_label.text.is_empty() and panel.item_label.text == definition.display_name,"Eligible explanation removed; authored name remains literal")
	check(panel.hint_label.get_index() > panel.close_button.get_parent().get_index(),"Italic controls hint is last, after buttons")
	await capture_compact(panel,"eligible")
	team.credited.Food = 43
	panel.refresh()
	if lane is RichTextLabel:
		check(lane.get_parsed_text() == "Food 48/48 (+5 / 7 wasted)","Exact cap-and-waste projection")
		check(lane.text.contains("[color=#a6f2c4]+5[/color]") and lane.text.contains("[color=#ff4d42]7 wasted[/color]"),"Applied capped; positive waste value and word both red")
	await capture_compact(panel,"wasted")
	team.credited.Food = 48
	panel.refresh()
	check(panel.status_label.text == "Food requirement already fulfilled." and not panel.bulk_label.visible and panel.manual_button.visible and not panel.manual_button.disabled,"Full lane hides summary, retains manual dispatch")
	var full_colour: Color = panel.status_label.get_theme_color("font_color")
	check(full_colour.r > 0.9 and full_colour.g > 0.6 and full_colour.b < 0.4 and panel._card.get_theme_stylebox("panel").border_color == full_colour and panel.lane_rows.Food.track.get_theme_stylebox("panel").border_color == full_colour,"Full track text and borders are yellow")
	if lane is RichTextLabel: check(not lane.text.contains("[color="),"Rejecting a previously projected lane clears rich colours")
	var before: Dictionary = team.capture_state()
	panel.handle_e(false,false)
	panel.handle_e(true,false)
	check(team.capture_state() == before and carry.get_selected_item() == item,"E rejection preserves inventory/accounting")
	await capture_compact(panel,"full-lane")
	carry.remove_selected()
	carry.add_item(ItemInstance.new(load("res://data/items/definitions/loot_000165.tres"),"irrelevant"))
	panel.refresh()
	check(panel.status_label.text == "Selected item not eligible for Expeditions" and not panel.bulk_label.visible and panel.lane_rows.values().all(func(row): return row.rejected),"Irrelevant item has only centered error below bars")
	check(panel.status_label.get_theme_color("font_color").g < 0.5 and panel._card.get_theme_stylebox("panel").border_color.g < 0.5,"Changing from full track to unrelated item restores red rejection")
	await capture_compact(panel,"rejected")
	carry.remove_selected()
	team.credited.Food = 12
	team.outgoing_bulk = 111
	carry.add_item(item)
	panel.refresh()
	check(panel.status_label.text == "Insufficient load capacity." and not panel.bulk_label.visible,"Capacity error hides totals")
	await capture_compact(panel,"capacity")
	team.outgoing_bulk = 2
	team.item_already_spent = func(_id): return true
	panel.refresh()
	check(panel.status_label.text == "Selected item already spent." and not panel.bulk_label.visible,"Defensive spent rejection stays truthful")
	team.item_already_spent = Callable()
	carry.remove_selected()
	panel.refresh()
	check(panel.bulk_label.visible and panel.bulk_label.text == "Outgoing 2 / 112 Bulk · Return Capacity 110" and not panel.status_label.text.contains("not eligible"),"Empty hand restores neutral committed summary")
	await capture_compact(panel,"empty")
	carry.add_item(ItemInstance.new(load("res://data/items/definitions/loot_000165.tres"),"terminal-held"))
	var clock = load("res://gameplay/run/run_clock.gd").new()
	clock.config = {"day_start":28800.0,"rate":12.0,"latest_return":85200.0}
	clock.day = 2
	clock.elapsed = clock.day_duration()+300.0
	team.day = 2
	team.time_source = clock.current_time
	team.deadline = clock.timestamp(2,36000.0)
	panel.refresh()
	check(panel.deadline_label.text.contains("Deadline 10:00:00") and panel.deadline_label.text.contains("01:00:00 remaining"),"Active team retains real deadline/countdown")
	panel._dispatch_manual()
	panel.refresh()
	check(team.closed and panel.status_label.text == "Team Dispatched" and panel.bulk_label.visible and not panel.hint_label.text.contains("[E]"),"Ineligible item permits manual dispatch; terminal presentation is read-only")
	check(panel.deadline_label.text == "Day 2 · Dispatched 09:00:00","Terminal card replaces deadline with stored dispatch timestamp using configured day/rate")
	clock.elapsed += 30.0
	panel.refresh()
	check(panel.deadline_label.text == "Day 2 · Dispatched 09:00:00","Dispatch timestamp stays fixed as current time advances")
	await capture_compact(panel,"terminal")
	carry.remove_selected()

func finish() -> void:
	print("M4_CAROUSEL_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
