extends Control
class_name CarriedItemsHUD

## Minimal persistent HUD for the carried-item bundle.
## Runtime 3D SubViewport previews are intentionally disabled after they were
## shown to alter main-scene brightness in the current Godot build. Slots use
## ItemDefinition.icon when available and a neutral fallback otherwise.

@export var carried_items_path: NodePath = NodePath("../../CharacterBody3D/CarriedItems")
@export_range(1, 20, 1) var max_visible_slots: int = 10
var _carried_items: Node
var _slot_row: HBoxContainer
var _bulk_label: Label
var _bottom: VBoxContainer

const SELECTED_BG := Color(0.14, 0.18, 0.16, 0.96)
const NORMAL_BG := Color(0.055, 0.06, 0.06, 0.88)
const EMPTY_BG := Color(0.035, 0.04, 0.04, 0.55)
const SELECTED_BORDER := Color(0.52, 0.88, 0.62, 1.0)
const NORMAL_BORDER := Color(0.24, 0.27, 0.27, 0.95)
const EMPTY_BORDER := Color(0.16, 0.18, 0.18, 0.65)
const PRIMARY_TEXT := Color(0.92, 0.94, 0.92, 1.0)
const SECONDARY_TEXT := Color(0.68, 0.73, 0.70, 1.0)
const SELECTED_TEXT := Color(0.72, 1.0, 0.78, 1.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	resized.connect(_refresh)
	get_window().size_changed.connect(_refresh)

	_carried_items = get_node_or_null(carried_items_path)
	if _carried_items == null:
		push_warning("CarriedItemsHUD could not find CarriedItems at %s" % carried_items_path)
		return

	_carried_items.contents_changed.connect(_refresh)
	_carried_items.capacity_changed.connect(_refresh)
	_carried_items.selection_changed.connect(_on_selection_changed)
	_refresh()


func _build_ui() -> void:
	_bottom = VBoxContainer.new()
	var bottom: VBoxContainer = _bottom
	bottom.name = "BottomStrip"
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(bottom)

	_bulk_label = Label.new()
	_bulk_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bulk_label.add_theme_color_override("font_color", SECONDARY_TEXT)
	_bulk_label.add_theme_font_size_override("font_size", 15)
	bottom.add_child(_bulk_label)

	_slot_row = HBoxContainer.new()
	_slot_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_slot_row.add_theme_constant_override("separation", 6)
	_slot_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.add_child(_slot_row)


func _refresh() -> void:
	if _carried_items == null:
		return

	for child in _slot_row.get_children():
		child.queue_free()

	var viewport := get_viewport().get_visible_rect().size
	var window := Vector2(get_window().size)
	if window.x < 320.0 or window.y < 240.0: window = viewport
	var pixels_per_unit := maxf(0.01,minf(window.x/viewport.x,window.y/viewport.y))
	_bottom.size = Vector2(window.x-32.0,140.0)
	_bottom.scale = Vector2.ONE/pixels_per_unit
	_bottom.position = Vector2(viewport.x/2.0-_bottom.size.x/(2.0*pixels_per_unit),viewport.y-154.0/pixels_per_unit)
	var slots: Array = _carried_items.get_slots()
	var selected_index: int = _carried_items.get_selected_index()
	var available: int = maxi(1, int((window.x - 32.0) / 124.0))
	var visible_count: int = mini(slots.size(), mini(max_visible_slots, available))
	var first: int = clampi(selected_index - visible_count + 1, 0, maxi(0, slots.size()-visible_count))

	for index in range(first, first+visible_count):
		var slot_item: Variant = slots[index]
		if slot_item == null:
			_slot_row.add_child(_make_empty_slot(index))
		else:
			_slot_row.add_child(_make_slot(slot_item, index, index == selected_index))


	if _carried_items.get_item_count() == 0:
		var empty: Label = Label.new()
		empty.text = "CARRIED — EMPTY"
		empty.add_theme_color_override("font_color", SECONDARY_TEXT)
		empty.add_theme_font_size_override("font_size", 16)
		_slot_row.add_child(empty)

	_bulk_label.text = "CARRIED   BULK %d / %d   •   Mouse wheel / 1–0 to select" % [
		_carried_items.get_current_bulk(),
		_carried_items.get_effective_bulk_limit()
	]
	if slots.size() > visible_count:
		_bulk_label.text += "   •   Showing %d–%d / %d" % [first+1,first+visible_count,slots.size()]
	var active: ItemInstance = _carried_items.get_selected_item()
	if active != null: _bulk_label.text += "   ·   " + active.get_display_name()


func _on_selection_changed(_selected_index: int) -> void:
	_refresh()


func _make_slot(item, index: int, selected: bool) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "Slot_%d" % index
	panel.custom_minimum_size = Vector2(118.0, 108.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = SELECTED_BG if selected else NORMAL_BG
	style.border_color = SELECTED_BORDER if selected else NORMAL_BORDER
	style.set_border_width_all(3 if selected else 1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 3
	style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)

	var column: VBoxContainer = VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 0)
	panel.add_child(column)

	column.add_child(_make_icon_area(item))

	var name_label: Label = Label.new()
	var number_text: String = "0" if index == 9 else str(index + 1) if index < 9 else "#%d" % (index+1)
	name_label.text = "%s  %s" % [number_text, _shorten(String(item.get_display_name()), 13)]
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", SELECTED_TEXT if selected else PRIMARY_TEXT)
	name_label.add_theme_font_size_override("font_size", 12)
	column.add_child(name_label)

	var stats_label: Label = Label.new()
	stats_label.text = "%s   •   B%d" % [String(item.utility_text()), int(item.get_bulk())]
	stats_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.add_theme_color_override("font_color", SECONDARY_TEXT)
	stats_label.add_theme_font_size_override("font_size", 10)
	column.add_child(stats_label)

	return panel


func _make_icon_area(item) -> Control:
	var holder: CenterContainer = CenterContainer.new()
	holder.custom_minimum_size = Vector2(106.0, 58.0)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var icon_texture: Texture2D = null
	if item != null and item.has_method("get_icon"):
		icon_texture = item.get_icon() as Texture2D

	if icon_texture != null:
		var icon_rect: TextureRect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(102.0, 54.0)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_rect.texture = icon_texture
		holder.add_child(icon_rect)
		return holder

	# Temporary fallback until the planned editor/offline thumbnail baker writes
	# real model thumbnails into ItemDefinition.icon.
	var fallback: PanelContainer = PanelContainer.new()
	fallback.custom_minimum_size = Vector2(86.0, 52.0)
	fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var fallback_style: StyleBoxFlat = StyleBoxFlat.new()
	fallback_style.bg_color = Color(0.085, 0.095, 0.095, 0.92)
	fallback_style.border_color = Color(0.25, 0.29, 0.28, 0.9)
	fallback_style.set_border_width_all(1)
	fallback_style.corner_radius_top_left = 4
	fallback_style.corner_radius_top_right = 4
	fallback_style.corner_radius_bottom_left = 4
	fallback_style.corner_radius_bottom_right = 4
	fallback.add_theme_stylebox_override("panel", fallback_style)

	var fallback_label: Label = Label.new()
	var initial: String = "?"
	if item != null and item.has_method("get_display_name"):
		var display_name: String = String(item.get_display_name()).strip_edges()
		if not display_name.is_empty():
			initial = display_name.left(1).to_upper()
	fallback_label.text = initial
	fallback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fallback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fallback_label.add_theme_color_override("font_color", SECONDARY_TEXT)
	fallback_label.add_theme_font_size_override("font_size", 28)
	fallback.add_child(fallback_label)

	holder.add_child(fallback)
	return holder


func _make_empty_slot(index: int) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(118.0, 108.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = EMPTY_BG
	style.border_color = EMPTY_BORDER
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)

	var label: Label = Label.new()
	var number_text: String = "0" if index == 9 else str(index + 1) if index < 9 else "#%d" % (index+1)
	label.text = "%s\nEMPTY" % number_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", EMPTY_BORDER)
	label.add_theme_font_size_override("font_size", 12)
	panel.add_child(label)
	return panel


func _shorten(value: String, max_length: int) -> String:
	if value.length() <= max_length:
		return value
	return value.left(max_length - 1) + "…"
