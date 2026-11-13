extends CanvasLayer

signal panel_toggled

var medical: RefCounted
var clock: RefCounted
var _view: CenterContainer
var _patients: Label
var _f_down := false

func _ready() -> void:
	layer = 55
	_view = CenterContainer.new()
	add_child(_view)
	_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_view.mouse_filter = Control.MOUSE_FILTER_STOP
	_view.hide()

	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 500
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.042, 0.048, 0.98)
	style.border_color = Color(0.63, 0.35, 0.40)
	style.set_border_width_all(2)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", style)
	_view.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var header := HBoxContainer.new()
	content.add_child(header)
	var title := _label(header, "MEDICAL  /  PATIENTS", 24)
	title.modulate = Color(1.0, 0.72, 0.75)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close := Button.new()
	close.text = "[F] Close"
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(close_top)
	header.add_child(close)
	_label(content, "Natural recovery · active time", 17)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.y = 144
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	_patients = _label(scroll, "", 20)
	_patients.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func is_open() -> bool:
	return _view.visible

func open_panel() -> void:
	if is_open():
		return
	_f_down = Input.is_key_pressed(KEY_F)
	_view.show()
	_refresh()
	panel_toggled.emit()

func close_top() -> bool:
	if not is_open():
		return false
	_view.hide()
	panel_toggled.emit()
	return true

func _input(event: InputEvent) -> void:
	if not is_open() or not event is InputEventKey or event.keycode == KEY_ESCAPE:
		return
	if event.keycode == KEY_F:
		if not event.pressed:
			_f_down = false
		elif not event.echo and not _f_down:
			_f_down = true
			close_top()
	get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if is_open():
		_refresh()

func _refresh() -> void:
	var active: Array = medical.active_patients()
	active.sort_custom(func(a: Dictionary, b: Dictionary): return a.recovery_at < b.recovery_at)
	var lines: Array[String] = []
	for patient: Dictionary in active:
		var seconds := ceili(maxf(0.0, patient.recovery_at - clock.elapsed))
		lines.append("%s injury  ·  %d:%02d remaining" % [patient.severity.capitalize(), seconds / 60.0, seconds % 60])
	var text := "\n".join(lines) if not lines.is_empty() else "No patients."
	if _patients.text != text:
		_patients.text = text

func _label(parent: Control, value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
