extends CanvasLayer

const Config = preload("res://gameplay/expeditions/expedition_test_config.gd")
const Ops = preload("res://gameplay/expeditions/expedition_operations.gd")
const MUTED := Color(0.72, 0.82, 0.79)
const ACCENT := Color(0.62, 0.95, 0.74)

signal panel_toggled

var operations: RefCounted
var carry: CarriedItems
var clock: RefCounted

var _preparation: CenterContainer
var _warning: CenterContainer
var _members: Array[Button] = []
var _affinities: Dictionary = {}
var _lanes: Dictionary = {}
var _crew: Label
var _bulk: Label
var _item: Label
var _destination: Label
var _reason: Label
var _activity: Label
var _summary: Label
var _send: Button
var _confirmation_revision := -1
var _failure := ""
var _e_down := false
var _f_down := false

func _ready() -> void:
	layer = 55
	_build_status()
	_build_preparation()
	_build_warning()
	operations.changed.connect(_on_operation_changed)
	carry.contents_changed.connect(refresh)
	carry.selection_changed.connect(_on_selection_changed)
	refresh()

func is_open() -> bool:
	return _preparation.visible

func open_panel() -> void:
	if is_open():
		return
	_e_down = Input.is_key_pressed(KEY_E)
	_f_down = Input.is_key_pressed(KEY_F)
	_failure = ""
	_preparation.show()
	refresh()
	panel_toggled.emit()

func close_top() -> bool:
	if _warning.visible:
		_back()
		return true
	if not is_open():
		return false
	_preparation.hide()
	panel_toggled.emit()
	return true

func _input(event: InputEvent) -> void:
	if not is_open():
		return
	if event is InputEventKey:
		match event.keycode:
			KEY_F:
				if not event.pressed:
					_f_down = false
				elif not event.echo and not _f_down:
					_f_down = true
					close_top()
			KEY_E:
				if not event.pressed:
					_e_down = false
				elif not event.echo and not _e_down:
					_e_down = true
					if not _warning.visible:
						operations.contribute(carry)
			KEY_ESCAPE:
				return # The shell owns the pause and Escape order.
			_:
				if not _warning.visible:
					carry._unhandled_input(event)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and not _warning.visible:
		carry._unhandled_input(event)

func _dispatch() -> void:
	if _warning.visible:
		return
	var revision: int = operations.revision
	var sent: Dictionary = operations.dispatch(revision)
	if sent.get("confirm", false):
		_confirmation_revision = revision
		_warning.show()
		return
	_show_dispatch_result(sent)

func _back() -> void:
	_confirmation_revision = -1
	_warning.hide()

func _confirm() -> void:
	if not _warning.visible or _confirmation_revision < 0:
		return
	var revision := _confirmation_revision
	_back()
	_show_dispatch_result(operations.dispatch(revision, true))

func _show_dispatch_result(result: Dictionary) -> void:
	_failure = result.get("error", "")
	refresh()

func _on_operation_changed() -> void:
	_failure = ""
	refresh()

func _on_selection_changed(_index: int) -> void:
	refresh()

func refresh() -> void:
	_refresh_activity()
	if not is_open():
		return
	var locked: bool = operations.is_formed()
	_crew.text = "%d Ready  •  %d selected%s" % [operations.ready_count, operations.members,
		"  •  Crew formed, count locked" if locked else ""]
	for index in _members.size():
		_members[index].disabled = locked or index + 1 > operations.ready_count
		_members[index].set_pressed_no_signal(index + 1 == operations.members)
	var loadout: RefCounted = operations.loadout
	var item: ItemInstance = carry.get_selected_item()
	var preview: Dictionary = operations.preview(item)
	for lane: String in _lanes:
		var row: Dictionary = _lanes[lane]
		row.bar.max_value = loadout.targets[lane]
		row.bar.value = loadout.credited[lane]
		row.value.text = "%d / %d" % [loadout.credited[lane], loadout.targets[lane]]
		if preview.status == "eligible" and preview.lane == lane:
			row.value.text += "  →  %d" % preview.projected
	_bulk.text = "%d / %d Bulk outgoing   •   %d Bulk for loot" % [
		loadout.submitted_bulk(), loadout.raw_capacity, operations.return_capacity()]
	_item.text = _selected_item_text(item, preview)
	for category: String in _affinities:
		var button: Button = _affinities[category]
		var selected: bool = operations.affinities.has(category)
		button.set_pressed_no_signal(selected)
		button.disabled = not operations.can_toggle_affinity(category)
		button.tooltip_text = _affinity_hint(category, selected, button.disabled)
	var pair: String = operations.selected_destination()
	_destination.text = "Select two categories for a destination." if pair.is_empty() else (
		"Development destination\n%s\nReturns may favor these supplies." % Config.destination_label(pair))
	var reason: String = operations.dispatch_error()
	_send.disabled = not reason.is_empty()
	_reason.text = _failure if not _failure.is_empty() else (
		reason if not reason.is_empty() else "Crew can depart with this loadout.")

func _selected_item_text(item: ItemInstance, preview: Dictionary) -> String:
	if item == null:
		return "No carried item selected."
	var heading := "%s   •   %d Bulk" % [item.get_display_name(), preview.bulk]
	if preview.status == "eligible":
		return heading + "\n+%d %s applied   •   %d Utility wasted" % [preview.applied, preview.lane, preview.wasted]
	if preview.status == "closed":
		return heading + "\nAll supply lanes are complete."
	var explanations := {"capacity": "This item exceeds remaining carrying capacity.",
		"crew": "Choose an available crew before contributing.", "full": preview.lane + " lane is already full.",
		"spent": "This item has already been spent.", "utility": "This item supplies none of the five lanes."}
	return heading + "\n" + explanations.get(preview.reason, "Selected item unavailable.")

func _affinity_hint(category: String, selected: bool, disabled: bool) -> String:
	if selected:
		return "Deselect " + category
	if not disabled:
		return "Select " + category
	if operations.affinities.size() == 2:
		return "Deselect one affinity to change the pair."
	if operations.affinities.size() == 1:
		return "A crew is already away at this pair."
	return "Every destination with this affinity has a crew away."

func _process(_delta: float) -> void:
	_refresh_activity()

func _refresh_activity() -> void:
	var away := 0
	var waiting := 0
	var lines: Array[String] = []
	for id: String in operations.active_ids():
		var trip: Dictionary = operations.journeys[id]
		var stage := "Awaiting Lift"
		if trip.status == Ops.AWAY:
			away += 1
			stage = "Away  ·  %ds" % ceili(maxf(0.0, trip.return_at - clock.elapsed))
		else:
			waiting += 1
		if is_open():
			lines.append("%02d  %s  ·  %s" % [Ops.sequence(id), stage, Config.destination_label(trip.destination)])
	var summary := "Ready %d    Away %d    Awaiting Lift %d" % [operations.ready_count, away, waiting]
	if clock.elapsed - operations.last_empty_return_at < 12.0:
		summary += "\nCrew returned without loot"
	if _summary.text != summary:
		_summary.text = summary
	if is_open():
		var activity := "\n".join(lines) if not lines.is_empty() else "No crews away or awaiting handover."
		if _activity.text != activity:
			_activity.text = activity

func _build_status() -> void:
	var anchor := MarginContainer.new()
	add_child(anchor)
	anchor.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	anchor.offset_left = -392
	anchor.offset_right = -24
	anchor.offset_top = 22
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var column := _card(anchor, 0, 12)
	column.get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label(column, "EXPEDITIONS", 16, ACCENT)
	_summary = _label(column, "", 19)

func _build_preparation() -> void:
	_preparation = _center()
	_preparation.hide()
	var column := _card(_preparation, 1210)
	var title := HBoxContainer.new()
	column.add_child(title)
	var heading := _label(title, "DISPATCH  /  PREPARE EXPEDITION", 32, ACCENT)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(title, "[F] Close", close_top)
	var sections := HBoxContainer.new()
	sections.add_theme_constant_override("separation", 34)
	column.add_child(sections)
	var supplies := _column(sections, 535)
	var routing := _column(sections, 560)
	_crew = _label(supplies, "", 21)
	var counts := HBoxContainer.new()
	supplies.add_child(counts)
	var member_group := ButtonGroup.new()
	for count in range(1, Config.MAX_MEMBERS + 1):
		var button := _button(counts, str(count), operations.set_members.bind(count), true)
		button.button_group = member_group
		button.custom_minimum_size.x = 62
		_members.append(button)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	supplies.add_child(grid)
	for lane: String in Config.PER_MEMBER_TARGETS:
		_label(grid, lane, 22)
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(255, 14)
		grid.add_child(bar)
		_lanes[lane] = {"bar": bar, "value": _label(grid, "", 20)}
	_bulk = _label(supplies, "", 21, ACCENT)
	_item = _label(supplies, "", 20)
	_item.custom_minimum_size.y = 58
	_label(supplies, "[E] Contribute whole item  •  Wheel / 1–0 select", 19, MUTED)
	_label(routing, "DESTINATION AFFINITIES", 22, ACCENT)
	var choices := GridContainer.new()
	choices.columns = 4
	choices.add_theme_constant_override("h_separation", 6)
	choices.add_theme_constant_override("v_separation", 6)
	routing.add_child(choices)
	for category: String in Config.CATEGORIES:
		var button := _button(choices, category, operations.toggle_affinity.bind(category), true)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_affinities[category] = button
	_destination = _label(routing, "", 22)
	_destination.custom_minimum_size.y = 84
	_reason = _label(routing, "", 20, MUTED)
	_reason.custom_minimum_size.y = 52
	_send = _button(routing, "Dispatch", _dispatch)
	_label(routing, "OPERATIONS", 18, ACCENT)
	_activity = _label(routing, "", 19)

func _build_warning() -> void:
	_warning = _center()
	_warning.mouse_filter = Control.MOUSE_FILTER_STOP
	_warning.hide()
	var column := _card(_warning, 630)
	_label(column, "NO RETURN CAPACITY", 27, Color(1, 0.79, 0.44))
	_label(column, "The crew’s supplies occupy its entire carrying capacity.\nIt will return without loot.", 23)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	column.add_child(actions)
	_button(actions, "Back to preparation", _back)
	_button(actions, "Dispatch anyway", _confirm)

func _center() -> CenterContainer:
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return center

func _card(parent: Control, width: int, margin: int = 25) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = width
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.034, 0.054, 0.055, 0.98)
	style.border_color = Color(0.33, 0.57, 0.47)
	style.set_border_width_all(2)
	style.set_content_margin_all(margin)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return _column(panel, 0)

func _column(parent: Control, width: int) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = width
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 12)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(column)
	return column

func _label(parent: Control, value: String, font: int, tint: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font)
	label.modulate = tint
	label.text = value
	parent.add_child(label)
	return label

func _button(parent: Control, value: String, pressed: Callable, toggle: bool = false) -> Button:
	var button := Button.new()
	button.text = value
	button.toggle_mode = toggle
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 21)
	button.custom_minimum_size.y = 42
	button.pressed.connect(pressed)
	parent.add_child(button)
	return button
