extends CanvasLayer

signal panel_closed
var request: RefCounted
var carry: Node
var destination_valid: Callable
var preview_state: Dictionary = {}
var pip_states: Array[String] = []
var invalid_highlight := false
var total_label: Label
var gain_label: Label
var status_label: Label
var item_label: Label
var _card: PanelContainer
var _pips: HBoxContainer
var _open := false
var _e_down := false
var _f_down := false

func _ready() -> void:
	layer = 55
	visible = false
	var root := CenterContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_card = PanelContainer.new()
	_card.custom_minimum_size = Vector2(600, 440)
	root.add_child(_card)
	var margin := MarginContainer.new()
	for side: String in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	_card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	var title := Label.new()
	title.text = "MEDICAL  /  CONTRIBUTION"
	title.add_theme_font_size_override("font_size", 28)
	column.add_child(title)
	item_label = Label.new()
	item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(item_label)
	total_label = Label.new()
	total_label.add_theme_font_size_override("font_size", 24)
	column.add_child(total_label)
	_pips = HBoxContainer.new()
	_pips.add_theme_constant_override("separation", 5)
	column.add_child(_pips)
	gain_label = Label.new()
	column.add_child(gain_label)
	status_label = Label.new()
	column.add_child(status_label)
	var hint := Label.new()
	hint.text = "[E] Submit selected item  •  Wheel / 1–0 select\n[F] Close  •  [ESC] Close panel"
	column.add_child(hint)
	var close := Button.new()
	close.text = "[F] Close"
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(close_panel)
	column.add_child(close)

func configure(state: RefCounted, carried: Node, valid: Callable) -> void:
	request = state
	carry = carried
	destination_valid = valid
	carry.contents_changed.connect(refresh)
	carry.selection_changed.connect(func(_index: int): refresh())

func is_open() -> bool:
	return _open

func open_panel() -> void:
	if _open or request == null or request.closed:
		return
	_open = true
	_e_down = Input.is_key_pressed(KEY_E)
	_f_down = Input.is_key_pressed(KEY_F)
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	refresh()

func close_panel() -> void:
	if not _open:
		return
	_open = false
	visible = false
	panel_closed.emit()

func handle_e(pressed: bool, echo: bool) -> void:
	if not _open:
		return
	if not pressed:
		_e_down = false
		return
	if echo or _e_down:
		return
	_e_down = true
	if not destination_valid.is_valid() or not destination_valid.call():
		close_panel()
		return
	var submitted: Dictionary = request.submit(carry)
	refresh()
	# Carry notifications run inside submit; release world input only afterward.
	if submitted.ok and request.closed:
		close_panel()

func _process(_delta: float) -> void:
	if _open and (not destination_valid.is_valid() or not destination_valid.call()):
		close_panel()

func _input(event: InputEvent) -> void:
	if not _open:
		return
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		return # Run shell explicitly closes this panel before toggling its menu.
	if event is InputEventKey and event.keycode == KEY_E:
		handle_e(event.pressed, event.echo)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.keycode == KEY_F:
		if not event.pressed:
			_f_down = false
		elif not event.echo and not _f_down:
			_f_down = true
			close_panel()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey or event is InputEventMouseButton:
		# Carry selection remains live; world input is separately suppressed.
		carry._unhandled_input(event)
		if event is InputEventKey:
			get_viewport().set_input_as_handled()

func refresh() -> void:
	if request == null or carry == null:
		return
	var item: ItemInstance = carry.get_selected_item()
	preview_state = request.preview(item)
	invalid_highlight = preview_state.status == "ineligible"
	item_label.text = item.get_display_name() if item != null else "No carried item selected"
	total_label.text = "%s   %d / %d  →  %d / %d" % [preview_state.lane, preview_state.committed,
		preview_state.target, preview_state.projected, preview_state.target]
	gain_label.text = "+%d applied  /  %d wasted" % [preview_state.applied, preview_state.wasted] if preview_state.status == "eligible" else ""
	match preview_state.status:
		"eligible": status_label.text = "After submission: %d remaining" % preview_state.remainder
		"ineligible": status_label.text = "Selected item not eligible"
		"closed": status_label.text = "Request complete — supplies received"
		_: status_label.text = "Carry an eligible item to contribute"
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.035, 0.038, 0.97)
	style.border_color = Color(1, 0.25, 0.22) if invalid_highlight else Color(0.35, 0.65, 0.48)
	style.set_border_width_all(2)
	_card.add_theme_stylebox_override("panel", style)
	for child: Node in _pips.get_children():
		child.free()
	pip_states.clear()
	for i: int in range(int(preview_state.target)):
		var state := "committed" if i < int(preview_state.committed) else "projected" if i < int(preview_state.projected) else "empty"
		pip_states.append(state)
		var pip := Panel.new()
		pip.custom_minimum_size = Vector2(36, 24)
		var pip_style := StyleBoxFlat.new()
		pip_style.bg_color = Color(0.26, 0.62, 0.42) if state == "committed" else Color(0.05, 0.12, 0.11)
		pip_style.border_color = Color(0.7, 1, 0.72) if state == "projected" else style.border_color if invalid_highlight else Color(0.22, 0.3, 0.27)
		pip_style.set_border_width_all(3 if state == "projected" else 1)
		pip.add_theme_stylebox_override("panel", pip_style)
		_pips.add_child(pip)
