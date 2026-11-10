extends CanvasLayer

const Config = preload("res://gameplay/kitchen/kitchen_test_config.gd")
const MUTED := Color(0.76, 0.82, 0.80)
const ATTENTION := Color(1.0, 0.8, 0.45)

signal panel_toggled

var operations: RefCounted
var carry: CarriedItems
var clock: RefCounted
var station_reachable: Callable
var _panel: CenterContainer
var _balances: Label
var _phase: Label
var _item: Label
var _action: Label
var _last_credit: Label
var _grace_left := -1
var _e_down := false
var _f_down := false

func _ready() -> void:
	layer = 56
	_build_panel()
	operations.changed.connect(_refresh)
	carry.contents_changed.connect(_refresh)
	carry.selection_changed.connect(func(_index: int): _refresh())

func is_open() -> bool:
	return _panel.visible

func open_panel() -> void:
	if is_open():
		return
	refresh_key_guards()
	_last_credit.text = ""
	_panel.show()
	_refresh()
	panel_toggled.emit()

func close_top() -> bool:
	if not is_open():
		return false
	_panel.hide()
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
		_last_credit.text = "Supplied %d %s. Wasted %d Utility." % [result.applied, result.lane, result.wasted]
	elif operations.total_outstanding() > 0:
		_last_credit.text = result.reason

func _has_access() -> bool:
	return _panel.is_visible_in_tree() and not get_tree().paused and bool(station_reachable.call())

func _process(_delta: float) -> void:
	if is_open() and operations.deadline_at() != 0 and operations.sprint_allowed():
		var seconds := maxi(0, ceili(operations.deadline_at() - clock.elapsed))
		if seconds != _grace_left:
			_update_phase(seconds)

func _refresh() -> void:
	if not is_open():
		return
	var remaining: Vector2i = operations.outstanding
	_balances.text = "Outstanding Utility   Food %d   •   Hydration %d" % [remaining.x, remaining.y]
	_update_phase(maxi(0, ceili(operations.deadline_at() - clock.elapsed)))
	var item := carry.get_selected_item() as ItemInstance
	_item.text = "No carried item selected." if item == null else "%s   •   %s   •   %d Bulk" % [
		item.get_display_name(), item.utility_text(), item.get_bulk()]
	var preview: Dictionary = operations.preview(item)
	_action.modulate = ATTENTION if preview.ok else MUTED
	if preview.ok:
		var loss := "Pending loss" if operations.sprint_allowed() else "Capacity loss"
		_action.text = "[E] Supply %d %s   •   Waste %d Utility\n%s   %s → %s" % [
			preview.applied, preview.lane, preview.wasted, loss, percent_text(preview.before), percent_text(preview.after)]
	else:
		_action.text = preview.reason

func _update_phase(seconds: int) -> void:
	_grace_left = seconds
	var total: int = operations.total_outstanding()
	if total == 0:
		_phase.text = "No outstanding demand   •   0% capacity loss   •   Sprint available"
	elif operations.sprint_allowed():
		_phase.text = "Grace %ds   •   0%% capacity loss (%s pending)   •   Sprint available" % [seconds, percent_text(total)]
	else:
		_phase.text = "Overdue   •   %s capacity loss   •   Sprint unavailable" % percent_text(total)

static func percent_text(utility: int) -> String:
	var value := "%.2f" % (float(utility) / Config.UTILITY_PER_POINT)
	var approximation := "≈" if utility % Config.UTILITY_PER_POINT != 0 else ""
	return approximation + value.rstrip("0").trim_suffix(".") + "%"

func _build_panel() -> void:
	_panel = CenterContainer.new()
	add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.hide()
	var card := PanelContainer.new()
	card.custom_minimum_size.x = 750
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.047, 0.047, 0.05, 0.98)
	style.border_color = Color(0.47, 0.40, 0.24)
	style.set_border_width_all(2)
	style.set_content_margin_all(24)
	card.add_theme_stylebox_override("panel", style)
	_panel.add_child(card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	card.add_child(column)
	var title := HBoxContainer.new()
	column.add_child(title)
	_label(title, "KITCHEN", 32).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close := Button.new()
	close.text = "[F] Close"
	close.focus_mode = Control.FOCUS_NONE
	close.custom_minimum_size = Vector2(120, 42)
	close.pressed.connect(close_top)
	title.add_child(close)
	_balances = _label(column, "", 25)
	_phase = _label(column, "", 22, MUTED)
	_item = _label(column, "", 22)
	_label(column, "Wheel or 1–0 to select carried items", 18, MUTED)
	_action = _label(column, "", 23)
	_action.custom_minimum_size.y = 60
	_last_credit = _label(column, "", 20, MUTED)
	_last_credit.custom_minimum_size.y = 28

func _label(parent: Control, value: String, size: int, tint: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = value
	label.modulate = tint
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label
