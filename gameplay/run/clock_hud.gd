extends CanvasLayer

var schedule: RefCounted
var label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 90
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 22)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(margin)
	label = Label.new()
	label.add_theme_font_size_override("font_size", 24)
	margin.add_child(label)
	refresh()

func _process(_delta: float) -> void:
	refresh()

func refresh() -> void:
	var indication := "  ·  NIGHT REPORT / PAUSED" if schedule.phase == "REPORT_PENDING" else "  ·  PAUSED" if get_tree().paused else ""
	label.text = "DAY %d · %s%s" % [schedule.clock.day, schedule.clock.time_text(schedule.clock.calendar_seconds()), indication]
	if schedule.scenario_complete(): label.text += "\nAuthored scenario complete."
