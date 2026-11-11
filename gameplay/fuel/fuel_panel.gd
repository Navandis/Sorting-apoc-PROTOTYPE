extends CanvasLayer

const Config := preload("res://gameplay/fuel/fuel_test_config.gd")
const MUTED := Color(0.76, 0.82, 0.80)
const CREDIT := Color(1.0, 0.8, 0.45)

signal panel_toggled

var operations: RefCounted
var carry: CarriedItems
var station_reachable: Callable
var _panel: CenterContainer
var _reserve: Label
var _permissions: Label
var _item: Label
var _action: Label
var _result: Label
var _e_down := false
var _f_down := false

func _ready() -> void:
	layer = 56
	_build_panel()
	set_process(false)

func is_open() -> bool:
	return _panel.visible

func open_panel() -> void:
	if is_open():
		return
	refresh_key_guards()
	_result.text = ""
	_panel.show()
	_refresh()
	set_process(true)
	panel_toggled.emit()

func close_top() -> bool:
	if not is_open():
		return false
	_panel.hide()
	set_process(false)
	refresh_key_guards()
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
				if event.keycode != KEY_ESCAPE:
					carry._unhandled_input(event)
				return
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		carry._unhandled_input(event)
		get_viewport().set_input_as_handled()

func _attempt() -> void:
	var item := carry.get_selected_item() as ItemInstance
	var result: Dictionary = operations.contribute(carry, item, _has_access)
	if result.ok:
		_result.text = "Supplied %s   •   Wasted %s" % [_amount(result.applied), _amount(result.wasted)]
	elif operations.preview(item).ok:
		_result.text = "Last attempt   " + result.reason
	else:
		# The live preview already describes an ineligible item or a full tank.
		_result.text = ""
	_refresh()

func _has_access() -> bool:
	return _panel.is_visible_in_tree() and not get_tree().paused and bool(station_reachable.call())

func _process(_delta: float) -> void:
	_refresh()

func _refresh() -> void:
	var band: int = operations.band()
	_reserve.text = "%s / %s Fuel Utility   •   %s" % [
		_amount(operations.reserve()), _amount(operations.capacity), Config.BAND_NAMES[band]]
	_permissions.text = "Future services   •   Salvager %s   •   Workshop %s" % [
		"powered" if operations.salvager_available() else "unpowered",
		"powered" if operations.workshop_available() else "unpowered"]
	var item := carry.get_selected_item() as ItemInstance
	_item.text = "No carried item selected." if item == null else "%s   •   %s   •   %d Bulk" % [
		item.get_display_name(), item.utility_text(), item.get_bulk()]
	var preview: Dictionary = operations.preview(item)
	_action.modulate = CREDIT if preview.ok else MUTED
	if preview.ok:
		var projected := Config.band_at(preview.after, 0.0, 0.0)
		_action.text = "[E] Supply %s   •   Waste %s\nProjected power   %s" % [
			_amount(preview.applied), _amount(preview.wasted), Config.BAND_NAMES[projected]]
	else:
		_action.text = preview.reason

static func _amount(value: float) -> String:
	if value > 0.0 and value < 0.01:
		return "<0.01"
	return ("%.2f" % (floorf(value * 100.0) / 100.0)).rstrip("0").trim_suffix(".")

func _build_panel() -> void:
	_panel = CenterContainer.new()
	add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.hide()
	var card := PanelContainer.new()
	card.custom_minimum_size.x = 600
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.047, 0.047, 0.05, 0.98)
	style.border_color = Color(0.47, 0.40, 0.24)
	style.set_border_width_all(2)
	style.set_content_margin_all(24)
	card.add_theme_stylebox_override("panel", style)
	_panel.add_child(card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	card.add_child(column)
	var title := HBoxContainer.new()
	column.add_child(title)
	_label(title, "FUEL RESERVE", 30).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close := Button.new()
	close.text = "[F] Close"
	close.focus_mode = Control.FOCUS_NONE
	close.custom_minimum_size = Vector2(120, 40)
	close.pressed.connect(close_top)
	title.add_child(close)
	_reserve = _label(column, "", 25)
	_label(column, "Consumes 1 Utility every %d active seconds" % Config.SECONDS_PER_UTILITY, 19, MUTED)
	_permissions = _label(column, "", 19, MUTED)
	_item = _label(column, "", 22)
	_label(column, "Wheel or 1–0 to select carried items", 18, MUTED)
	_action = _label(column, "", 22)
	_action.custom_minimum_size.y = 58
	_result = _label(column, "", 19, MUTED)
	_result.custom_minimum_size.y = 26

func _label(parent: Control, value: String, size: int, tint: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = value
	label.modulate = tint
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label
