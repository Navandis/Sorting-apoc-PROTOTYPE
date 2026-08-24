extends CanvasLayer
class_name StorageZoneEditor

signal editor_closed

const StorageCategoriesScript = preload("res://storage_categories.gd")
const StorageZoneCanvasScript = preload("res://storage_zone_canvas.gd")

const PANEL_BG := Color(0.035, 0.042, 0.045, 0.98)
const CARD_BG := Color(0.075, 0.085, 0.088, 0.98)
const TEXT_MAIN := Color(0.92, 0.94, 0.92, 1.0)
const TEXT_MUTED := Color(0.67, 0.71, 0.69, 1.0)

var _surface: Node = null
var _root: Control = null
var _title: Label = null
var _status: Label = null
var _coverage: Label = null
var _canvas: StorageZoneCanvas = null
var _category_buttons: Dictionary = {}
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
	_active_category = StorageCategoriesScript.FOOD
	_canvas.set_surface(surface)
	_canvas.set_category(_active_category)
	_sync_category_buttons()

	var surface_name: String = "STORAGE SURFACE"
	var surface_id_value: Variant = surface.get("surface_id")
	if surface_id_value != null:
		surface_name = String(surface_id_value).replace("_", " ").to_upper()
	_title.text = "STORAGE ZONES  /  %s" % surface_name

	_status.text = "Choose a category, then drag a rectangle. New zones overwrite cells they cover."
	_update_coverage()

	visible = true
	_was_tree_paused = get_tree().paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true


func close_editor() -> void:
	if not visible:
		return

	_canvas.cancel_drag()
	visible = false

	# Restore simulation first so the receiving player controller can react to
	# the close signal even though it does not process while paused.
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
	backdrop.color = Color(0.005, 0.008, 0.010, 0.90)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(backdrop)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 46)
	margin.add_theme_constant_override("margin_right", 46)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 34)
	_root.add_child(margin)

	var shell: PanelContainer = PanelContainer.new()
	var shell_style: StyleBoxFlat = StyleBoxFlat.new()
	shell_style.bg_color = PANEL_BG
	shell_style.border_color = Color(0.28, 0.32, 0.31, 1.0)
	shell_style.set_border_width_all(1)
	shell_style.corner_radius_top_left = 8
	shell_style.corner_radius_top_right = 8
	shell_style.corner_radius_bottom_left = 8
	shell_style.corner_radius_bottom_right = 8
	shell.add_theme_stylebox_override("panel", shell_style)
	margin.add_child(shell)

	var main_row: HBoxContainer = HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 22)
	shell.add_child(main_row)

	var side_panel: PanelContainer = PanelContainer.new()
	side_panel.custom_minimum_size = Vector2(220.0, 0.0)
	var side_style: StyleBoxFlat = StyleBoxFlat.new()
	side_style.bg_color = CARD_BG
	side_style.corner_radius_top_left = 6
	side_style.corner_radius_top_right = 6
	side_style.corner_radius_bottom_left = 6
	side_style.corner_radius_bottom_right = 6
	side_panel.add_theme_stylebox_override("panel", side_style)
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
		var button: Button = Button.new()
		button.text = category.to_upper()
		button.toggle_mode = true
		button.button_group = group
		button.custom_minimum_size = Vector2(0.0, 34.0)
		button.pressed.connect(_on_category_pressed.bind(category))
		side.add_child(button)
		_category_buttons[category] = button

	var separator_one: HSeparator = HSeparator.new()
	side.add_child(separator_one)

	var erase_button: Button = Button.new()
	erase_button.text = "ERASE"
	erase_button.toggle_mode = true
	erase_button.button_group = group
	erase_button.custom_minimum_size = Vector2(0.0, 34.0)
	erase_button.pressed.connect(_on_category_pressed.bind(""))
	side.add_child(erase_button)
	_category_buttons[""] = erase_button

	var clear_button: Button = Button.new()
	clear_button.text = "CLEAR ALL ZONES"
	clear_button.custom_minimum_size = Vector2(0.0, 34.0)
	clear_button.pressed.connect(_on_clear_all_pressed)
	side.add_child(clear_button)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_child(spacer)

	_coverage = Label.new()
	_coverage.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_coverage.add_theme_color_override("font_color", TEXT_MUTED)
	_coverage.add_theme_font_size_override("font_size", 13)
	side.add_child(_coverage)

	var close_hint: Label = Label.new()
	close_hint.text = "[O / ESC] CLOSE"
	close_hint.add_theme_color_override("font_color", TEXT_MUTED)
	close_hint.add_theme_font_size_override("font_size", 13)
	side.add_child(close_hint)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	main_row.add_child(content)

	_title = Label.new()
	_title.text = "STORAGE ZONES"
	_title.add_theme_color_override("font_color", TEXT_MAIN)
	_title.add_theme_font_size_override("font_size", 20)
	content.add_child(_title)

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

	_sync_category_buttons()


func _on_category_pressed(category: String) -> void:
	_active_category = category
	_canvas.set_category(category)

	var label: String = "ERASE" if category.is_empty() else category.to_upper()
	_status.text = "%s selected. Drag over the shelf map to apply." % label
	_sync_category_buttons()


func _on_clear_all_pressed() -> void:
	if _surface == null:
		return
	_surface.clear_all_zones()
	_status.text = "All zones cleared."
	_update_coverage()


func _on_drag_percentage_changed(percent: float) -> void:
	if percent <= 0.0:
		return
	var label: String = "ERASE" if _active_category.is_empty() else _active_category.to_upper()
	_status.text = "%s selection: %.1f%% of this storage surface." % [label, percent]


func _on_zone_applied() -> void:
	_update_coverage()
	var label: String = "ERASE" if _active_category.is_empty() else _active_category.to_upper()
	_status.text = "%s zone updated. Draw another rectangle or choose another category." % label


func _update_coverage() -> void:
	if _surface == null:
		_coverage.text = ""
		return

	var total_ratio: float = float(_surface.get_zone_coverage_ratio())
	_coverage.text = "ALLOCATED\n%.1f%% of surface" % (total_ratio * 100.0)


func _sync_category_buttons() -> void:
	for category_value: Variant in _category_buttons.keys():
		var category: String = String(category_value)
		var button_value: Variant = _category_buttons[category]
		if button_value is Button:
			var button: Button = button_value as Button
			button.button_pressed = category == _active_category
