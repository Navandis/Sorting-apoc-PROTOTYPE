extends CanvasLayer

signal begin_day
signal first_frame
var title: Label
var body: Label
var save_status: Label
var begin_button: Button
var card: PanelContainer
var scroll: ScrollContainer

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
	card.custom_minimum_size = Vector2(940, 600)
	center.add_child(card)
	# Initial wrapped-text layout can temporarily grow the card before its
	# minimum shrinks. Reapply the bounded size after that layout settles.
	card.minimum_size_changed.connect(func(): _layout.call_deferred())
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 24)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	title = Label.new()
	title.add_theme_font_size_override("font_size", 30)
	column.add_child(title)
	scroll = ScrollContainer.new()
	scroll.custom_minimum_size.y = 300
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	body = Label.new()
	body.add_theme_font_size_override("font_size", 18)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
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
	card.custom_minimum_size = Vector2(minf(940,window.x-48),minf(900,window.y-60))
	card.size = card.custom_minimum_size
	card.scale = Vector2.ONE/pixels_per_unit
	card.position = (viewport-card.size/pixels_per_unit)/2.0

func _dispatch_text(report: Dictionary) -> String:
	if not report.has("dispatch"): return ""
	var text := "DISPATCH\n"
	if report.dispatch.is_empty(): return text + "No teams scheduled\n\n"
	var config: Dictionary = report.get("clock_config",{"day_start":21600.0,"rate":24.0})
	var duration: float = (86400.0-float(config.day_start))/float(config.rate)
	for team: Dictionary in report.dispatch:
		var result: Dictionary = team.dispatch_result
		var calendar: float = float(config.day_start)+(float(result.at)-(int(team.day)-1)*duration)*float(config.rate)
		text += "Team %d · %d members · %s\n" % [team.display_index,team.members,team.id]
		text += "%s · %s · Outgoing %d/%d Bulk · Return Capacity %d\n" % [String(result.reason).capitalize(),load("res://gameplay/run/run_clock.gd").time_text(calendar),result.outgoing_bulk,result.capacity,result.return_capacity]
		var lanes: PackedStringArray = []
		for lane: String in team.targets:
			lanes.append("%s %d/%d (%d unmet)" % [lane,team.credited[lane],team.targets[lane],team.result[lane].unmet])
		text += " · ".join(lanes) + "\n\n"
	return text

func present(report: Dictionary, status: String) -> void:
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
	body.text = _dispatch_text(report) + "MEDICAL\nRequired %d  ·  Credited %d  ·  Unmet %d\nFulfilled %d  ·  Expired %d  ·  Excess discarded %d\n\nMEAL SERVICE\nDaily Meal Coverage: %s" % [required, supplied, unmet, fulfilled, expired, waste, "N/A" if report.meal_coverage == null else "%.1f%%" % report.meal_coverage]
	if report.meals.is_empty(): body.text += "\nNo Meal Service scheduled"
	for meal: Dictionary in report.meals:
		body.text += "\n%s  ·  Food %d/%d  ·  Hydration %d/%d  ·  %s" % [meal.meal,meal.credited.Food,meal.targets.Food,meal.credited.Hydration,meal.targets.Hydration,meal.closure_reason.capitalize()]
	body.text += "\n\nRECEIVING\nHauls admitted %d  ·  Midnight forfeits %d\nDeposited backlog carried forward %d" % [report.admitted.size(), report.forfeits.size(), report.backlog.size()]
	if report.scenario_complete: body.text += "\n\nAuthored scenario complete."
	save_status.text = status
	begin_button.text = "Begin Day %d" % (int(report.day) + 1)
	scroll.scroll_vertical = 0
	_layout()
	visible = true
	if DisplayServer.get_name() != "headless" and not RenderingServer.frame_post_draw.is_connected(_first_draw):
		RenderingServer.frame_post_draw.connect(_first_draw, CONNECT_ONE_SHOT)

func _first_draw() -> void:
	first_frame.emit()
