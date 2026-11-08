extends CanvasLayer

const WARNING_TEXT := "Incinerated items are permanently destroyed! This is a one-time warning."
const DESTRUCTIVE := Color(1.0, 0.37, 0.34)
const MUTED := Color(0.76, 0.82, 0.80)

signal panel_toggled

var operations: RefCounted
var carry: CarriedItems
var station_reachable: Callable

var _panel: CenterContainer
var _warning: ColorRect
var _item: Label
var _action: Label
var _notice: Label
var _warning_text: Label
var _warning_item: Label
var _back_button: Button
var _continue_button: Button
var _pending_item: ItemInstance
var _e_down := false
var _f_down := false
var _accept_requires_release := false

func _ready() -> void:
	layer = 56
	_build_panel()
	_build_warning()
	carry.contents_changed.connect(_refresh)
	carry.selection_changed.connect(func(_index: int): _refresh())

func is_open() -> bool:
	return _panel.visible

func open_panel() -> void:
	if is_open():
		return
	refresh_key_guards()
	_notice.text = ""
	_panel.show()
	_refresh()
	panel_toggled.emit()

func close_top() -> bool:
	if _warning.visible:
		_back()
		return true
	if not is_open():
		return false
	_pending_item = null
	_panel.hide()
	refresh_key_guards()
	panel_toggled.emit()
	return true

func refresh_key_guards() -> void:
	_e_down = Input.is_key_pressed(KEY_E)
	_f_down = Input.is_key_pressed(KEY_F)
	_accept_requires_release = Input.is_action_pressed(&"ui_accept")

func _input(event: InputEvent) -> void:
	if not is_open():
		return
	if _warning.visible and event.is_action(&"ui_accept"):
		if _accept_requires_release or event.is_echo():
			get_viewport().set_input_as_handled()
		if event.is_released():
			_accept_requires_release = false
		return
	if event is InputEventKey:
		match event.keycode:
			KEY_E:
				if not event.pressed:
					_e_down = false
				elif not event.echo and not _e_down:
					_e_down = true
					if not _warning.visible:
						_attempt()
			KEY_F:
				if not event.pressed:
					_f_down = false
				elif not event.echo and not _f_down:
					_f_down = true
					close_top()
			_:
				if not _warning.visible and event.keycode != KEY_ESCAPE:
					carry._unhandled_input(event)
				return # The shell handles Escape. Warning buttons receive normal GUI navigation.
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		if not _warning.visible:
			carry._unhandled_input(event)
		get_viewport().set_input_as_handled()

func _attempt() -> void:
	var item := carry.get_selected_item() as ItemInstance
	if operations.warning_shown:
		_commit(item)
	elif operations.can_attempt(carry, item, _has_access):
		_pending_item = item
		_warning_item.text = item.get_display_name()
		_warning.show()
		_back_button.grab_focus()
		refresh_key_guards()
		operations.mark_warning_displayed()

func _back() -> void:
	_pending_item = null
	_warning.hide()
	refresh_key_guards()

func _confirm() -> void:
	if not _warning.visible:
		return
	var item := _pending_item
	_back()
	_commit(item)

func _commit(item: ItemInstance) -> void:
	if operations.incinerate(carry, item, _has_access):
		_notice.text = "Destroyed %s." % item.get_display_name()
	elif item != null:
		_notice.text = "No item destroyed. The original selection is unavailable."
	else:
		_notice.text = ""

func _has_access() -> bool:
	return _panel.is_visible_in_tree() and not get_tree().paused and bool(station_reachable.call())

func _refresh() -> void:
	if not is_open():
		return
	var item := carry.get_selected_item() as ItemInstance
	_item.text = "No carried item selected." if item == null else "%s\n%s  •  %s  •  %d Bulk" % [
		item.get_display_name(), item.get_storage_category(), item.utility_text(), item.get_bulk()]
	_action.modulate = DESTRUCTIVE if item != null else MUTED

func _build_panel() -> void:
	_panel = _center(self)
	_panel.hide()
	var column := _card(_panel)
	var title := HBoxContainer.new()
	column.add_child(title)
	var heading := _label(title, "INCINERATOR", 32)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(title, "[F] Close", close_top).focus_mode = Control.FOCUS_NONE
	_item = _label(column, "", 24)
	_item.custom_minimum_size.y = 70
	_label(column, "Wheel or 1–0 to select carried items", 20, MUTED)
	_action = _label(column, "[E] Incinerate — permanently destroy; no output", 27, DESTRUCTIVE)
	_notice = _label(column, "", 21, MUTED)
	_notice.custom_minimum_size.y = 30

func _build_warning() -> void:
	_warning = ColorRect.new()
	add_child(_warning)
	_warning.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_warning.color = Color(0.014, 0.012, 0.012, 0.78)
	_warning.mouse_filter = Control.MOUSE_FILTER_STOP
	_warning.hide()
	var column := _card(_center(_warning))
	_label(column, "PERMANENT DESTRUCTION", 29, DESTRUCTIVE)
	_warning_item = _label(column, "", 24)
	_warning_text = _label(column, WARNING_TEXT, 25)
	_warning_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	column.add_child(actions)
	_back_button = _button(actions, "Back", _back)
	_continue_button = _button(actions, "Continue", _confirm)

func _center(parent: Node) -> CenterContainer:
	var center := CenterContainer.new()
	parent.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return center

func _card(parent: Control) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 720
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.047, 0.047, 0.05, 0.98)
	style.border_color = Color(0.49, 0.30, 0.27)
	style.set_border_width_all(2)
	style.set_content_margin_all(28)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	return column

func _label(parent: Control, value: String, font_size: int, tint: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = value
	label.modulate = tint
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label

func _button(parent: Control, value: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size = Vector2(122, 46)
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(action)
	parent.add_child(button)
	return button
