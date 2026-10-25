extends CanvasLayer

signal panel_closed
var request: RefCounted
var carry: Node
var destination_valid: Callable
var teams: Array = []
var center_index := 0
var transitioning := false
var preview_state: Dictionary = {}
var lane_rows: Dictionary = {}
var _open := false
var _e_down := false
var _f_down := false
var _nav_down: Dictionary = {}
var _tween: Tween
var _stage: Control
var _card: PanelContainer
var previous_card: Button
var next_card: Button
var previous_arrow: Button
var next_arrow: Button
var position_label: Label
var title_label: Label
var deadline_label: Label
var item_label: Label
var bulk_label: Label
var status_label: Label
var hint_label: RichTextLabel
var manual_button: Button
var close_button: Button

const INK := Color(0.91,0.95,0.98)
const BLUE_INK := Color(0.06,0.17,0.24)
const REJECTED := Color(1.0,0.3,0.26)
const LANES := ["Food","Hydration","Medical","Weapons","Protection"]

func _ready() -> void:
	layer = 55
	visible = false
	var shade := ColorRect.new()
	shade.color = Color(0.005,0.01,0.02,0.58)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	_stage = Control.new()
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.size = Vector2(1100,570)
	add_child(_stage)
	previous_card = _button(_stage,"",func(): navigate(-1))
	previous_card.position = Vector2(15,90)
	previous_card.size = Vector2(245,370)
	previous_card.scale = Vector2(0.88,0.88)
	next_card = _button(_stage,"",func(): navigate(1))
	next_card.position = Vector2(870,90)
	next_card.size = Vector2(245,370)
	next_card.scale = Vector2(0.88,0.88)
	previous_card.modulate = Color(0.7,0.74,0.79)
	next_card.modulate = previous_card.modulate
	previous_arrow = _button(_stage,"◀",func(): navigate(-1))
	previous_arrow.position = Vector2(95,455)
	previous_arrow.size = Vector2(54,38)
	next_arrow = _button(_stage,"▶",func(): navigate(1))
	next_arrow.position = Vector2(950,455)
	next_arrow.size = Vector2(54,38)
	position_label = _label(_stage,16)
	position_label.position = Vector2(910,510)
	position_label.size = Vector2(140,30)
	position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card = PanelContainer.new()
	_card.position = Vector2(250,0)
	_card.size = Vector2(600,570)
	_card.z_index = 2
	_stage.add_child(_card)
	var margin := MarginContainer.new()
	for side: String in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,16)
	_card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",7)
	margin.add_child(column)
	title_label = _label(column,24)
	deadline_label = _label(column,14)
	item_label = _label(column,17)
	item_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation",7)
	column.add_child(rows)
	for lane: String in LANES:
		var row := VBoxContainer.new()
		row.add_theme_constant_override("separation",2)
		rows.add_child(row)
		var label := _rich_label(row,17)
		var track := Panel.new()
		track.custom_minimum_size.y = 8
		row.add_child(track)
		var committed := ColorRect.new()
		committed.mouse_filter = Control.MOUSE_FILTER_IGNORE
		track.add_child(committed)
		var projected := ColorRect.new()
		projected.mouse_filter = Control.MOUSE_FILTER_IGNORE
		track.add_child(projected)
		lane_rows[lane] = {"label":label,"track":track,"committed":committed,"projected":projected,"rejected":false}
	bulk_label = _label(column,17)
	bulk_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label = _label(column,23)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation",12)
	column.add_child(buttons)
	manual_button = _button(buttons,"Dispatch under-prepared",_dispatch_manual)
	manual_button.custom_minimum_size.y = 34
	manual_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button = _button(buttons,"[F] Close",close_panel)
	close_button.custom_minimum_size = Vector2(125,34)
	hint_label = _rich_label(column,13)
	_layout()

func _label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size",font_size)
	parent.add_child(label)
	return label

func _rich_label(parent: Node, font_size: int) -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("normal_font_size",font_size)
	label.add_theme_font_size_override("italics_font_size",font_size)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size",16)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func configure(_state: RefCounted, carried: Node, valid: Callable) -> void:
	carry = carried
	destination_valid = valid
	carry.contents_changed.connect(refresh)
	carry.selection_changed.connect(func(_index): refresh())

func set_teams(states: Array) -> void:
	if teams == states: return
	close_panel()
	teams = states.duplicate()
	center_index = 0
	request = teams[0] if not teams.is_empty() else null
	refresh()

func is_open() -> bool:
	return _open

func _any_accepting() -> bool:
	return teams.any(func(team): return team.is_accepting())

func open_panel() -> void:
	if _open or not _any_accepting(): return
	_open = true
	_e_down = Input.is_key_pressed(KEY_E)
	_f_down = Input.is_key_pressed(KEY_F)
	_nav_down.clear()
	for code: int in [KEY_A,KEY_D,KEY_LEFT,KEY_RIGHT]:
		if Input.is_key_pressed(code): _nav_down[code] = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	refresh()

func close_panel() -> void:
	if not _open: return
	_open = false
	visible = false
	if _tween != null: _tween.kill()
	transitioning = false
	_card.position.x = 250.0
	_card.modulate.a = 1.0
	panel_closed.emit()

func navigate(direction: int) -> void:
	if not _open or transitioning or teams.size() < 2: return
	center_index = posmod(center_index+direction, teams.size())
	request = teams[center_index]
	transitioning = true
	_card.position.x = 250.0 + direction * 34.0
	_card.modulate.a = 0.68
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_card,"position:x",250.0,0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_card,"modulate:a",1.0,0.18)
	_tween.chain().tween_callback(func():
		transitioning = false
		refresh())
	refresh()

func _recipient_valid(recipient: RefCounted) -> bool:
	return _open and not transitioning and request == recipient and teams[center_index] == recipient and destination_valid.is_valid() and bool(destination_valid.call())

func handle_e(pressed: bool, echo: bool) -> void:
	if not _open: return
	if not pressed:
		_e_down = false
		return
	if echo or _e_down: return
	_e_down = true
	if transitioning: return # Never buffer E; another press is required afterward.
	var recipient: RefCounted = request
	if not _recipient_valid(recipient): return
	recipient.submit(carry,func(): return _recipient_valid(recipient))
	refresh()
	if not _any_accepting(): close_panel()

func _dispatch_manual() -> void:
	var recipient: RefCounted = request
	if recipient == null or not _recipient_valid(recipient): return
	recipient.dispatch_underprepared(func(): return _recipient_valid(recipient))
	refresh()
	if not _any_accepting(): close_panel()

func _input(event: InputEvent) -> void:
	if not _open: return
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE: return # Shell retains panel-first priority.
		if event.keycode == KEY_E:
			handle_e(event.pressed,event.echo)
		elif event.keycode == KEY_F:
			if not event.pressed: _f_down = false
			elif not event.echo and not _f_down:
				_f_down = true
				close_panel()
		elif event.keycode in [KEY_A,KEY_D,KEY_LEFT,KEY_RIGHT]:
			if not event.pressed: _nav_down.erase(event.keycode)
			elif not event.echo and not _nav_down.has(event.keycode):
				_nav_down[event.keycode] = true
				navigate(-1 if event.keycode in [KEY_A,KEY_LEFT] else 1)
		else: carry._unhandled_input(event)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
		carry._unhandled_input(event)
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not _open: return
	if not _any_accepting() or not destination_valid.is_valid() or not destination_valid.call():
		close_panel()
		return
	_layout()
	refresh()

func _layout() -> void:
	var viewport := get_viewport().get_visible_rect().size
	var window := Vector2(get_window().size)
	if window.x < 320.0 or window.y < 240.0: window = viewport
	var pixels_per_unit := maxf(0.01,minf(window.x/viewport.x,window.y/viewport.y))
	var physical_factor := minf(1.0,minf((window.x-24.0)/1100.0,(window.y-170.0)/570.0))
	var factor := physical_factor/pixels_per_unit
	_stage.scale = Vector2.ONE * factor
	_stage.position = Vector2((viewport.x-1100.0*factor)/2.0,maxf(14.0/pixels_per_unit,(viewport.y-570.0*factor-150.0/pixels_per_unit)/2.0))

func _skin(control: Control, terminal: bool, rejected: bool = false) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.67,0.84,0.95,0.98) if terminal else Color(0.025,0.045,0.065,0.98)
	style.border_color = Color(0.3,0.57,0.76) if terminal else REJECTED if rejected else Color(0.35,0.62,0.77)
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	if control is Button:
		for state: String in ["normal","hover","pressed","disabled"]: control.add_theme_stylebox_override(state,style)
		control.add_theme_color_override("font_color",BLUE_INK if terminal else INK)
		control.add_theme_color_override("font_hover_color",BLUE_INK if terminal else INK)
	else: control.add_theme_stylebox_override("panel",style)

func _side(button: Button, offset: int) -> void:
	var team: RefCounted = teams[posmod(center_index+offset,teams.size())]
	button.text = "TEAM %d\n%d members\n\n" % [team.display_index,team.members]
	for lane: String in LANES: button.text += "%s  %d / %d\n" % [lane,team.credited[lane],team.targets[lane]]
	button.text += "\nOutgoing %d / %d\nReturn Capacity %d" % [team.outgoing_bulk,team.raw_capacity(),team.return_capacity()]
	if team.closed: button.text += "\n\nTeam Dispatched"
	_skin(button,team.closed)
	button.disabled = transitioning

func refresh() -> void:
	if request == null or carry == null or not is_instance_valid(_card): return
	var item: ItemInstance = carry.get_selected_item()
	preview_state = request.preview(item)
	var terminal: bool = request.closed
	var invalid: bool = preview_state.status in ["ineligible","capacity"]
	_skin(_card,terminal,invalid)
	for label: Label in _card.find_children("*","Label",true,false): label.add_theme_color_override("font_color",BLUE_INK if terminal else INK)
	for label: RichTextLabel in _card.find_children("*","RichTextLabel",true,false): label.add_theme_color_override("default_color",BLUE_INK if terminal else INK)
	title_label.text = "TEAM %d  ·  %d MEMBERS" % [request.display_index,request.members]
	title_label.tooltip_text = ""
	deadline_label.text = "Day %d" % request.day
	if request.deadline >= 0.0 and request.time_source.is_valid():
		var clock: RefCounted = request.time_source.get_object()
		var deadline_calendar: float = float(clock.config.day_start)+(request.deadline-(request.day-1)*clock.day_duration())*float(clock.config.rate)
		deadline_label.text += " · Deadline %s · %s remaining" % [clock.time_text(deadline_calendar),clock.time_text(maxf(0,request.deadline-request.current_time())*float(clock.config.rate))]
	item_label.text = "Committed loadout" if terminal else item.get_display_name() if item != null else "No carried item selected"
	item_label.tooltip_text = item.get_display_name() if not terminal and item != null else ""
	bulk_label.visible = not invalid
	bulk_label.text = "Outgoing %d / %d Bulk · Return Capacity %d" % [request.outgoing_bulk,request.raw_capacity(),request.return_capacity()]
	if preview_state.status == "eligible":
		bulk_label.text = "Outgoing %d (+%d) / %d Bulk · Return Capacity %d (-%d)" % [request.outgoing_bulk,preview_state.bulk,request.raw_capacity(),request.return_capacity(),preview_state.bulk]
	match preview_state.status:
		"dispatched": status_label.text = "Team Dispatched"
		"capacity": status_label.text = "Insufficient load capacity."
		"ineligible":
			match preview_state.reason:
				"full": status_label.text = "%s requirement already fulfilled." % preview_state.lane
				"spent": status_label.text = "Selected item already spent."
				_: status_label.text = "Selected item not eligible for Expeditions"
		"eligible": status_label.text = ""
		"closed":
			status_label.text = "Team no longer accepting supplies."
			bulk_label.visible = false
		_: status_label.text = "Carry an eligible item to provision this team"
	status_label.visible = not status_label.text.is_empty()
	status_label.add_theme_color_override("font_color",REJECTED if invalid else BLUE_INK if terminal else INK)
	hint_label.text = "[i]%s[/i]" % ("Read-only loadout · A/D or arrows change team" if terminal else "[E] Submit selected item · Wheel / 1–0 select · A/D or ←/→ change team")
	for lane: String in LANES:
		var row: Dictionary = lane_rows[lane]
		var committed: int = request.credited[lane]
		var target: int = request.targets[lane]
		var projected: int = preview_state.projected if preview_state.status == "eligible" and preview_state.lane == lane else committed
		row.rejected = invalid and (preview_state.reason in ["utility","spent","capacity"] or preview_state.lane == lane)
		row.label.text = "%s %d/%d" % [lane,committed,target]
		if preview_state.status == "eligible" and preview_state.lane == lane:
			var waste: String = "%d wasted" % preview_state.wasted
			if preview_state.wasted > 0: waste = "[color=#ff4d42]%s[/color]" % waste
			row.label.text = "%s [color=#a6f2c4]%d[/color]/%d ([color=#a6f2c4]+%d[/color] / %s)" % [lane,projected,target,preview_state.applied,waste]
		var track_style := StyleBoxFlat.new()
		track_style.bg_color = Color(0.47,0.65,0.77) if terminal else Color(0.07,0.12,0.17)
		track_style.border_color = REJECTED if row.rejected else Color(0.28,0.45,0.55)
		track_style.set_border_width_all(1)
		row.track.add_theme_stylebox_override("panel",track_style)
		var width: float = row.track.size.x
		row.committed.size = Vector2(width*committed/target,8)
		row.committed.color = Color(0.16,0.43,0.64) if terminal else Color(0.28,0.66,0.46)
		row.projected.position.x = row.committed.size.x
		row.projected.size = Vector2(width*(projected-committed)/target,8)
		row.projected.color = Color(0.65,0.95,0.77)
	manual_button.visible = not terminal
	manual_button.disabled = terminal or transitioning
	_skin(manual_button,terminal)
	_skin(close_button,terminal)
	previous_card.visible = teams.size() > 2
	next_card.visible = teams.size() > 1
	previous_arrow.disabled = teams.size() < 2 or transitioning
	next_arrow.disabled = previous_arrow.disabled
	position_label.text = "%d / %d" % [center_index+1,teams.size()]
	if previous_card.visible: _side(previous_card,-1)
	if next_card.visible: _side(next_card,1)
