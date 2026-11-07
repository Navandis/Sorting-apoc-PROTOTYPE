extends CanvasLayer

var goal: RefCounted
var clock: RefCounted
var _time: Label
var _result: Label
var _notice: Label
var _rows: Dictionary = {}
var _displayed_second := -1

func _ready() -> void:
	layer = 40
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 22)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.05, 0.052, 0.92)
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(column)
	_time = Label.new()
	_time.add_theme_font_size_override("font_size", 21)
	column.add_child(_time)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 16)
	column.add_child(grid)
	for category: String in goal.CATEGORIES:
		var row := Label.new()
		row.custom_minimum_size.x = 160
		grid.add_child(row)
		_rows[category] = row
	var supply := Label.new()
	supply.text = "Development supply at Receiving"
	supply.modulate = Color(0.72, 0.81, 0.79)
	column.add_child(supply)
	_result = Label.new()
	_result.modulate = Color(0.57, 1.0, 0.68)
	column.add_child(_result)
	_notice = Label.new()
	_notice.modulate = Color(1.0, 0.8, 0.45)
	_notice.hide()
	column.add_child(_notice)
	goal.changed.connect(_refresh_totals)
	_refresh_totals()
	_process(0.0)

func _process(_delta: float) -> void:
	var elapsed: float = clock.elapsed
	var whole := int(elapsed)
	if whole != _displayed_second:
		_displayed_second = whole
		_time.text = "Collection  •  Active " + clock.time_text(elapsed)

func _refresh_totals() -> void:
	for category: String in goal.CATEGORIES:
		var current: int = goal.totals[category]
		var row: Label = _rows[category]
		row.text = "%s   %d / %d" % [category, current, goal.target]
		row.modulate = Color(0.57, 1.0, 0.68) if current >= goal.target else Color.WHITE
	_result.visible = goal.completed
	if goal.completed:
		var at: float = goal.first_completion_at
		_result.text = "Collection complete at %s.%02d" % [clock.time_text(at), int(fmod(at, 1.0) * 100.0)]

func show_notice(message: String) -> void:
	_notice.text = message
	_notice.visible = not message.is_empty()
