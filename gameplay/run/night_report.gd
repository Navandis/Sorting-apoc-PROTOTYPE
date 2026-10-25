extends CanvasLayer

signal begin_day
signal first_frame
var title: Label
var body: Label
var save_status: Label
var begin_button: Button
var card: PanelContainer
var scroll: ScrollContainer
var tabs: TabContainer
var bodies: Array[Label] = []
var scenario_notice: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	visible = false
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.008, 0.013, 0.016, 0.86)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)
	var center := Control.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	card = PanelContainer.new()
	center.add_child(card)
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 24)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	title = Label.new()
	title.add_theme_font_size_override("font_size", 30)
	column.add_child(title)
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_theme_font_size_override("font_size", 20)
	column.add_child(tabs)
	for section: String in ["Expeditions", "Medical", "Meal Service"]:
		var region := ScrollContainer.new()
		region.name = section
		region.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		tabs.add_child(region)
		var content := Label.new()
		content.add_theme_font_size_override("font_size", 18)
		content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		region.add_child(content)
		bodies.append(content)
	# Retain the existing Expeditions body/scroll references used by callers.
	scroll = tabs.get_child(0)
	body = bodies[0]
	scenario_notice = Label.new()
	scenario_notice.text = "Authored scenario complete."
	column.add_child(scenario_notice)
	save_status = Label.new()
	save_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(save_status)
	begin_button = Button.new()
	begin_button.custom_minimum_size.y = 48
	begin_button.add_theme_font_size_override("font_size", 22)
	begin_button.pressed.connect(func(): begin_day.emit())
	column.add_child(begin_button)
	var hint := Label.new()
	hint.text = "[ESC] Menu / Save & Exit"
	column.add_child(hint)
	get_viewport().size_changed.connect(_layout)
	_layout()

func _layout() -> void:
	var viewport := get_viewport().get_visible_rect().size
	var window := Vector2(get_window().size)
	if window.x < 320.0 or window.y < 240.0: window = viewport
	var pixels_per_unit := maxf(0.01,minf(window.x/viewport.x,window.y/viewport.y))
	# Scroll bodies do not contribute a content-height minimum. Size immediately
	# from the window so fresh Continue has a bounded footer on its first draw.
	card.size = Vector2(minf(940,window.x-48),minf(900,window.y-60))
	card.scale = Vector2.ONE/pixels_per_unit
	card.position = (viewport-card.size/pixels_per_unit)/2.0

func _dispatch_text(report: Dictionary) -> String:
	var text := ""
	var config: Dictionary = report.get("clock_config",{"day_start":21600.0,"rate":24.0})
	var duration: float = (86400.0-float(config.day_start))/float(config.rate)
	if report.get("dispatch",[]).is_empty(): text = "No teams scheduled\n\n"
	for team: Dictionary in report.get("dispatch",[]):
		var result: Dictionary = team.dispatch_result
		var calendar: float = float(config.day_start)+(float(result.at)-(int(team.day)-1)*duration)*float(config.rate)
		text += "Team %d · %d members\n" % [team.display_index,team.members]
		text += "Dispatched %s\nOutgoing %d/%d Bulk · Return Capacity %d\n" % [load("res://gameplay/run/run_clock.gd").time_text(calendar),result.outgoing_bulk,result.capacity,result.return_capacity]
		var lanes: PackedStringArray = []
		for lane: String in ["Food","Hydration","Medical","Weapons","Protection"]:
			lanes.append("%s %d/%d" % [lane,team.credited[lane],team.targets[lane]])
		text += " · ".join(lanes) + "\n\n"
	return text + "Incoming supplies — scripted scenario\nHauls admitted %d · Midnight forfeits %d\nDeposited backlog carried forward %d" % [report.admitted.size(),report.forfeits.size(),report.backlog.size()]

func present(report: Dictionary, status: String) -> void:
	_layout()
	# A fresh hidden label otherwise measures wrapped text at width zero and
	# temporarily raises the container minimum before its first layout/draw.
	save_status.size.x = maxf(1.0,card.size.x-48.0)
	title.text = "End of Day %d" % report.day
	var required := 0
	var supplied := 0
	var unmet := 0
	var waste := 0
	var fulfilled := 0
	var expired := 0
	for request: Dictionary in report.medical:
		required += int(request.result.Medical.required)
		supplied += int(request.result.Medical.supplied)
		unmet += int(request.result.Medical.unmet)
		fulfilled += int(request.closure_reason == "fulfilled")
		expired += int(request.closure_reason == "expired")
		for receipt: Dictionary in request.spent: waste += int(receipt.wasted)
	body.text = _dispatch_text(report)
	bodies[1].text = "Required %d · Credited %d · Unmet %d\nFulfilled %d · Expired %d\nExcess discarded %d" % [required,supplied,unmet,fulfilled,expired,waste]
	if report.medical.is_empty(): bodies[1].text += "\n\nNo Medical activity"
	bodies[2].text = "Daily Meal Coverage: %s" % ("N/A" if report.meal_coverage == null else "%.1f%%" % report.meal_coverage)
	if report.meals.is_empty(): bodies[2].text += "\n\nNo Meal Service scheduled"
	for meal: Dictionary in report.meals:
		var outcome: String = meal.closure_reason.capitalize()
		if meal.closure_reason == "expired" and (int(meal.credited.Food) > 0 or int(meal.credited.Hydration) > 0): outcome = "Partially fulfilled"
		bodies[2].text += "\n\n%s · %s\nFood %d/%d · Hydration %d/%d" % [meal.meal,outcome,meal.credited.Food,meal.targets.Food,meal.credited.Hydration,meal.targets.Hydration]
	scenario_notice.visible = report.scenario_complete
	save_status.text = status
	begin_button.text = "Begin Day %d" % (int(report.day) + 1)
	tabs.current_tab = 0
	for region: ScrollContainer in tabs.get_children(): region.scroll_vertical = 0
	_layout()
	visible = true
	if DisplayServer.get_name() != "headless" and not RenderingServer.frame_post_draw.is_connected(_first_draw):
		RenderingServer.frame_post_draw.connect(_first_draw, CONNECT_ONE_SHOT)

func _first_draw() -> void:
	first_frame.emit()
