extends CanvasLayer
class_name StorageZoneEditor

signal editor_closed

const StorageCategoriesScript = preload("res://storage_categories.gd")
const StorageZoneCanvasScript = preload("res://storage_zone_canvas.gd")

const PANEL_BG := Color(0.035, 0.042, 0.045, 0.78)
const CARD_BG := Color(0.075, 0.085, 0.088, 0.94)
const TEXT_MAIN := Color(0.92, 0.94, 0.92, 1.0)
const TEXT_MUTED := Color(0.67, 0.71, 0.69, 1.0)
const MODAL_BACKDROP := Color(0.005, 0.008, 0.010, 0.70)

var _surface: Node = null
var _root: Control = null
var _title: Label = null
var _name_edit: LineEdit = null
var _status: Label = null
var _canvas: StorageZoneCanvas = null
var _category_buttons: Dictionary = {}
var _allocation_list: VBoxContainer = null
var _clear_confirmation: ConfirmationDialog = null
var _active_category: String = StorageCategoriesScript.FOOD
var _was_tree_paused: bool = false


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()


func open_for_surface(surface: Node) -> void:
	if surface == null:
		return

	_surface = surface

	var was_initialized: bool = true
	if surface.has_method("are_zones_initialized"):
		was_initialized = bool(surface.call("are_zones_initialized"))

	if surface.has_method("initialize_zones_if_needed"):
		surface.call(
			"initialize_zones_if_needed",
			StorageCategoriesScript.GENERAL
		)

	# A brand-new surface opens as 100% General and has General preselected.
	# Reopening an authored surface preserves the editor's last category.
	if not was_initialized:
		_active_category = StorageCategoriesScript.GENERAL

	_canvas.set_surface(surface)
	_canvas.set_category(_active_category)
	_sync_category_buttons()

	var surface_name: String = "Storage Surface"
	if surface.has_method("get_display_name"):
		surface_name = String(surface.call("get_display_name"))
	else:
		var surface_id_value: Variant = surface.get("surface_id")
		if surface_id_value != null:
			surface_name = String(surface_id_value).replace("_", " ").capitalize()

	if _name_edit != null:
		_name_edit.text = surface_name

	if not was_initialized:
		_status.text = "First use: this surface starts as GENERAL. Paint over it to specialize storage."
	else:
		_status.text = "Choose a category, then drag a rectangle. New zones overwrite cells they cover."

	_update_allocation_list()

	visible = true
	_was_tree_paused = get_tree().paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true


func close_editor() -> void:
	if not visible:
		return

	_canvas.cancel_drag()
	visible = false

	get_tree().paused = _was_tree_paused
	editor_closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if key_event.keycode == KEY_ESCAPE or key_event.keycode == KEY_O:
				close_editor()
				get_viewport().set_input_as_handled()


func _build_ui() -> void:
	_root = Control.new()
	_root.name = "ZoneEditorRoot"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = MODAL_BACKDROP
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(backdrop)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	_root.add_child(margin)

	var shell: PanelContainer = PanelContainer.new()
	var shell_style: StyleBoxFlat = StyleBoxFlat.new()
	shell_style.bg_color = PANEL_BG
	shell_style.border_color = Color(0.28, 0.32, 0.31, 0.82)
	shell_style.set_border_width_all(1)
	shell_style.corner_radius_top_left = 8
	shell_style.corner_radius_top_right = 8
	shell_style.corner_radius_bottom_left = 8
	shell_style.corner_radius_bottom_right = 8
	shell.add_theme_stylebox_override("panel", shell_style)
	margin.add_child(shell)

	var main_row: HBoxContainer = HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 18)
	shell.add_child(main_row)

	_build_category_panel(main_row)
	_build_center_panel(main_row)
	_build_allocation_panel(main_row)
	_build_clear_confirmation()

	_sync_category_buttons()


func _build_category_panel(main_row: HBoxContainer) -> void:
	var side_panel: PanelContainer = PanelContainer.new()
	side_panel.custom_minimum_size = Vector2(220.0, 0.0)
	side_panel.add_theme_stylebox_override("panel", _card_style())
	main_row.add_child(side_panel)

	var side_margin: MarginContainer = MarginContainer.new()
	side_margin.add_theme_constant_override("margin_left", 14)
	side_margin.add_theme_constant_override("margin_right", 14)
	side_margin.add_theme_constant_override("margin_top", 14)
	side_margin.add_theme_constant_override("margin_bottom", 14)
	side_panel.add_child(side_margin)

	var side: VBoxContainer = VBoxContainer.new()
	side.add_theme_constant_override("separation", 7)
	side_margin.add_child(side)

	var category_title: Label = Label.new()
	category_title.text = "ZONE CATEGORY"
	category_title.add_theme_color_override("font_color", TEXT_MAIN)
	category_title.add_theme_font_size_override("font_size", 16)
	side.add_child(category_title)

	var group: ButtonGroup = ButtonGroup.new()

	for category: String in StorageCategoriesScript.EDITOR_CATEGORIES:
		var button: Button = _make_category_button(category, group)
		side.add_child(button)
		_category_buttons[category] = button

	var separator_one: HSeparator = HSeparator.new()
	side.add_child(separator_one)

	var erase_button: Button = _make_category_button("", group)
	erase_button.text = "ERASE"
	side.add_child(erase_button)
	_category_buttons[""] = erase_button

	var clear_button: Button = Button.new()
	clear_button.text = "CLEAR ALL ZONES"
	clear_button.custom_minimum_size = Vector2(0.0, 36.0)
	clear_button.pressed.connect(_on_clear_all_pressed)
	clear_button.add_theme_color_override("font_color", Color(1.0, 0.82, 0.82))
	side.add_child(clear_button)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)

	var close_hint: Label = Label.new()
	close_hint.text = "[O / ESC] CLOSE"
	close_hint.add_theme_color_override("font_color", TEXT_MUTED)
	close_hint.add_theme_font_size_override("font_size", 13)
	side.add_child(close_hint)


func _build_center_panel(main_row: HBoxContainer) -> void:
	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	main_row.add_child(content)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	content.add_child(title_row)

	_title = Label.new()
	_title.text = "STORAGE ZONES /"
	_title.add_theme_color_override("font_color", TEXT_MAIN)
	_title.add_theme_font_size_override("font_size", 20)
	title_row.add_child(_title)

	_name_edit = LineEdit.new()
	_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_edit.custom_minimum_size = Vector2(260.0, 36.0)
	_name_edit.placeholder_text = "Surface name"
	_name_edit.tooltip_text = "Name this individual shelf surface."
	_name_edit.text_submitted.connect(_on_surface_name_submitted)
	_name_edit.focus_exited.connect(_on_surface_name_focus_exited)
	_name_edit.add_theme_font_size_override("font_size", 18)
	title_row.add_child(_name_edit)

	_status = Label.new()
	_status.text = "Drag a rectangle."
	_status.add_theme_color_override("font_color", TEXT_MUTED)
	_status.add_theme_font_size_override("font_size", 13)
	content.add_child(_status)

	_canvas = StorageZoneCanvasScript.new()
	_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_canvas.drag_percentage_changed.connect(_on_drag_percentage_changed)
	_canvas.zone_applied.connect(_on_zone_applied)
	content.add_child(_canvas)


func _build_allocation_panel(main_row: HBoxContainer) -> void:
	var right_panel: PanelContainer = PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(220.0, 0.0)
	right_panel.add_theme_stylebox_override("panel", _card_style())
	main_row.add_child(right_panel)

	var right_margin: MarginContainer = MarginContainer.new()
	right_margin.add_theme_constant_override("margin_left", 14)
	right_margin.add_theme_constant_override("margin_right", 14)
	right_margin.add_theme_constant_override("margin_top", 14)
	right_margin.add_theme_constant_override("margin_bottom", 14)
	right_panel.add_child(right_margin)

	var right: VBoxContainer = VBoxContainer.new()
	right.add_theme_constant_override("separation", 8)
	right_margin.add_child(right)

	var title: Label = Label.new()
	title.text = "SURFACE ALLOCATION"
	title.add_theme_color_override("font_color", TEXT_MAIN)
	title.add_theme_font_size_override("font_size", 16)
	right.add_child(title)

	var hint: Label = Label.new()
	hint.text = "Share of the whole shelf assigned to each zone type."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", TEXT_MUTED)
	hint.add_theme_font_size_override("font_size", 12)
	right.add_child(hint)

	var separator: HSeparator = HSeparator.new()
	right.add_child(separator)

	_allocation_list = VBoxContainer.new()
	_allocation_list.add_theme_constant_override("separation", 7)
	right.add_child(_allocation_list)

	var lower_spacer: Control = Control.new()
	lower_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(lower_spacer)

	var close_button: Button = Button.new()
	close_button.text = "CLOSE"
	close_button.custom_minimum_size = Vector2(0.0, 58.0)
	close_button.tooltip_text = "Close zoning editor (O / Esc)"
	close_button.pressed.connect(close_editor)

	var close_normal: StyleBoxFlat = _close_button_style(
		Color(0.20, 0.25, 0.24, 1.0),
		Color(0.55, 0.64, 0.61, 1.0),
		3
	)
	var close_hover: StyleBoxFlat = _close_button_style(
		Color(0.27, 0.34, 0.32, 1.0),
		Color(0.72, 0.82, 0.78, 1.0),
		3
	)
	var close_pressed: StyleBoxFlat = _close_button_style(
		Color(0.12, 0.16, 0.15, 1.0),
		Color(0.42, 0.50, 0.47, 1.0),
		2
	)

	close_button.add_theme_stylebox_override("normal", close_normal)
	close_button.add_theme_stylebox_override("hover", close_hover)
	close_button.add_theme_stylebox_override("pressed", close_pressed)
	close_button.add_theme_stylebox_override("focus", close_hover)
	close_button.add_theme_font_size_override("font_size", 18)
	close_button.add_theme_color_override("font_color", TEXT_MAIN)
	close_button.add_theme_color_override("font_hover_color", Color.WHITE)
	close_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	right.add_child(close_button)


func _build_clear_confirmation() -> void:
	_clear_confirmation = ConfirmationDialog.new()
	_clear_confirmation.title = "Clear all storage zones?"
	_clear_confirmation.dialog_text = (
		"This removes every category zone from this shelf surface.\n" +
		"Existing stored items will not move."
	)
	_clear_confirmation.ok_button_text = "CLEAR ALL"
	_clear_confirmation.process_mode = Node.PROCESS_MODE_ALWAYS
	_clear_confirmation.confirmed.connect(_on_clear_all_confirmed)
	add_child(_clear_confirmation)


func _make_category_button(
	category: String,
	group: ButtonGroup
) -> Button:
	var button: Button = Button.new()
	button.text = (
		"ERASE"
		if category.is_empty()
		else category.to_upper()
	)
	button.toggle_mode = true
	button.button_group = group
	button.custom_minimum_size = Vector2(0.0, 36.0)
	button.pressed.connect(_on_category_pressed.bind(category))
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)

	var base_color: Color = (
		Color(0.46, 0.49, 0.50, 1.0)
		if category.is_empty()
		else StorageCategoriesScript.color_for(category)
	)

	var normal_style: StyleBoxFlat = _button_style(
		base_color.darkened(0.45),
		0.86
	)
	var hover_style: StyleBoxFlat = _button_style(
		base_color.darkened(0.25),
		0.94
	)
	var pressed_style: StyleBoxFlat = _button_style(
		base_color.darkened(0.08),
		1.0
	)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", pressed_style)
	return button


func _button_style(color: Color, alpha: float) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var styled_color: Color = color
	styled_color.a = alpha
	style.bg_color = styled_color
	style.border_color = color.lightened(0.20)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style


func _close_button_style(
	background: Color,
	border: Color,
	border_width: int
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.48)
	style.shadow_size = 5
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style


func _card_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = CARD_BG
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style


func _on_surface_name_submitted(value: String) -> void:
	_apply_surface_name(value)
	if _name_edit != null:
		_name_edit.release_focus()


func _on_surface_name_focus_exited() -> void:
	if _name_edit == null:
		return
	_apply_surface_name(_name_edit.text)


func _apply_surface_name(value: String) -> void:
	if _surface == null:
		return

	if _surface.has_method("set_custom_display_name"):
		_surface.call("set_custom_display_name", value)

	if _name_edit != null and _surface.has_method("get_display_name"):
		_name_edit.text = String(_surface.call("get_display_name"))


func _on_category_pressed(category: String) -> void:
	_active_category = category
	_canvas.set_category(category)

	var label: String = "ERASE" if category.is_empty() else category.to_upper()
	_status.text = "%s selected. Drag over the shelf map to apply." % label
	_sync_category_buttons()


func _on_clear_all_pressed() -> void:
	if _surface == null or _clear_confirmation == null:
		return
	_clear_confirmation.popup_centered(Vector2i(430, 170))


func _on_clear_all_confirmed() -> void:
	if _surface == null:
		return
	_surface.clear_all_zones()
	_status.text = "All zones cleared. This surface remains initialized."
	_update_allocation_list()


func _on_drag_percentage_changed(percent: float) -> void:
	if percent <= 0.0:
		return
	var label: String = "ERASE" if _active_category.is_empty() else _active_category.to_upper()
	_status.text = "%s selection: %.1f%% of this storage surface." % [label, percent]


func _on_zone_applied() -> void:
	_update_allocation_list()
	var label: String = "ERASE" if _active_category.is_empty() else _active_category.to_upper()
	_status.text = "%s zone updated. Draw another rectangle or choose another category." % label


func _update_allocation_list() -> void:
	if _allocation_list == null:
		return

	for child: Node in _allocation_list.get_children():
		_allocation_list.remove_child(child)
		child.queue_free()

	if _surface == null:
		return

	var any_zone: bool = false
	for category: String in StorageCategoriesScript.EDITOR_CATEGORIES:
		var ratio: float = float(
			_surface.get_zone_coverage_ratio(category)
		)
		if ratio <= 0.0001:
			continue

		any_zone = true
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var swatch: ColorRect = ColorRect.new()
		swatch.custom_minimum_size = Vector2(16.0, 16.0)
		var swatch_color: Color = StorageCategoriesScript.color_for(category)
		swatch_color.a = 1.0
		swatch.color = swatch_color
		row.add_child(swatch)

		var label: Label = Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = StorageCategoriesScript.short_name(category)
		label.add_theme_color_override("font_color", TEXT_MAIN)
		row.add_child(label)

		var percent_label: Label = Label.new()
		percent_label.text = "%.1f%%" % (ratio * 100.0)
		percent_label.add_theme_color_override("font_color", TEXT_MAIN)
		percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(percent_label)

		_allocation_list.add_child(row)

	if not any_zone:
		var empty_label: Label = Label.new()
		empty_label.text = "No zones assigned."
		empty_label.add_theme_color_override("font_color", TEXT_MUTED)
		_allocation_list.add_child(empty_label)


func _sync_category_buttons() -> void:
	for category_value: Variant in _category_buttons.keys():
		var category: String = String(category_value)
		var button_value: Variant = _category_buttons[category]
		if button_value is Button:
			var button: Button = button_value as Button
			button.button_pressed = category == _active_category
