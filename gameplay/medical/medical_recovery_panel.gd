extends CanvasLayer

const Recovery = preload("res://gameplay/medical/medical_recovery.gd")
const MUTED := Color(0.84, 0.76, 0.79)
const TREATMENT := Color(1.0, 0.72, 0.75)

signal panel_toggled

var operations: RefCounted
var timeline: RefCounted
var carry: CarriedItems
var station_reachable: Callable
var _view: CenterContainer
var _patients: Label
var _patient_scroll: ScrollContainer
var _item: Label
var _action: Label
var _result: Label
var _e_down := false
var _f_down := false

func _ready() -> void:
	layer = 55
	set_process(false)
	_view = CenterContainer.new()
	add_child(_view)
	_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_view.mouse_filter = Control.MOUSE_FILTER_STOP
	_view.hide()

	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 590
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
	title.modulate = TREATMENT
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close := Button.new()
	close.text = "[F] Close"
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(close_top)
	header.add_child(close)
	_label(content, "Natural recovery · active time", 17)
	_patient_scroll = ScrollContainer.new()
	_patient_scroll.custom_minimum_size.y = 120
	_patient_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(_patient_scroll)
	_patients = _label(_patient_scroll, "", 20)
	_patients.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_item = _label(content, "", 21)
	_label(content, "%s seconds per Medical Utility" % _amount(Recovery.SECONDS_PER_UTILITY), 17).modulate = MUTED
	_action = _label(content, "", 19)
	_result = _label(content, "", 19)
	_result.custom_minimum_size.y = 24
	_result.modulate = MUTED

func is_open() -> bool:
	return _view.visible

func open_panel() -> void:
	if is_open():
		return
	refresh_key_guards()
	_result.text = ""
	_view.show()
	_refresh()
	set_process(true)
	panel_toggled.emit()

func close_top() -> bool:
	if not is_open():
		return false
	_view.hide()
	set_process(false)
	panel_toggled.emit()
	return true

func refresh_key_guards() -> void:
	_e_down = Input.is_key_pressed(KEY_E)
	_f_down = Input.is_key_pressed(KEY_F)

func _input(event: InputEvent) -> void:
	if not is_open():
		return
	if event is InputEventKey:
		match event.keycode:
			KEY_ESCAPE:
				return
			KEY_E:
				if not event.pressed:
					_e_down = false
				elif not event.echo and not _e_down:
					_e_down = true
					_attempt()
			KEY_F:
				if not event.pressed:
					_f_down = false
				elif not event.echo and not _f_down:
					_f_down = true
					close_top()
			_:
				carry._unhandled_input(event)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		carry._unhandled_input(event)
		get_viewport().set_input_as_handled()

func _attempt() -> void:
	var item := carry.get_selected_item() as ItemInstance
	var result: Dictionary = timeline.contribute_medical(carry, item, _has_access)
	if result.ok:
		_result.text = "Treated   •   Applied %s s   •   Waste %s s   •   +%d Ready" % [
			_amount(result.applied), _amount(result.wasted), result.recovered]
	elif operations.preview_treatment(item).ok:
		_result.text = result.reason
	_refresh()

func _has_access() -> bool:
	return _view.is_visible_in_tree() and not get_tree().paused and bool(station_reachable.call())

func _process(_delta: float) -> void:
	_refresh()

func _refresh() -> void:
	var at: float = timeline.clock.elapsed
	var lines: Array[String] = []
	for patient: Dictionary in operations.medical.active_patients():
		var seconds := ceili(maxf(0.0, patient.recovery_at - at))
		if seconds > 0:
			lines.append("%s injury  ·  %d:%02d remaining" % [patient.severity.capitalize(), seconds / 60.0, seconds % 60])
	_patients.text = "\n".join(lines)
	_patient_scroll.visible = not lines.is_empty()
	var item := carry.get_selected_item() as ItemInstance
	_item.text = "No carried item selected." if item == null else "%s   •   %s" % [
		item.get_display_name(), "%d Medical Utility" % item.get_utility_value() if item.get_utility_id() == &"Medical" else item.utility_text()]
	var preview: Dictionary = operations.preview_treatment(item)
	_action.modulate = TREATMENT if preview.ok else MUTED
	_action.text = "[E] Treat  •  Apply %s s  •  Waste %s s  •  +%d Ready" % [
		_amount(preview.applied), _amount(preview.wasted), preview.recovered] if preview.ok else preview.reason

static func _amount(value: float) -> String:
	if value > 0.0 and value < 0.01:
		return "<0.01"
	return ("%.2f" % (floorf(value * 100.0) / 100.0)).rstrip("0").trim_suffix(".")

func _label(parent: Control, value: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
