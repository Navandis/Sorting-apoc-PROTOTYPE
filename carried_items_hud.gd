extends Control
class_name CarriedItemsHUD

## Minimal persistent HUD for the carried-item bundle.
## Slots use live 3D previews and preserve temporary gaps after an item leaves
## the strip; future pickups fill the first gap.

@export var carried_items_path: NodePath = NodePath("../../CharacterBody3D/CarriedItems")
@export_range(1, 20, 1) var max_visible_slots: int = 10
## Diagnostic/runtime switch. When false, HUD slots never instantiate ItemPreview3D/SubViewport nodes.
@export var enable_live_previews: bool = true

const ItemPreview3DScript = preload("res://item_preview_3d.gd")

var _carried_items: Node
var _slot_row: HBoxContainer
var _bulk_label: Label

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

	_carried_items = get_node_or_null(carried_items_path)
	if _carried_items == null:
		push_warning("CarriedItemsHUD could not find CarriedItems at %s" % carried_items_path)
		return

	_carried_items.contents_changed.connect(_refresh)
	_carried_items.selection_changed.connect(_on_selection_changed)
	_refresh()


func _build_ui() -> void:
	var bottom: VBoxContainer = VBoxContainer.new()
	bottom.name = "BottomStrip"
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.anchor_left = 0.5
	bottom.anchor_right = 0.5
	bottom.anchor_top = 1.0
	bottom.anchor_bottom = 1.0
	bottom.offset_left = -650.0
	bottom.offset_right = 650.0
	bottom.offset_top = -166.0
	bottom.offset_bottom = -14.0
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

	var slots: Array = _carried_items.get_slots()
	var selected_index: int = _carried_items.get_selected_index()
	var visible_count: int = slots.size()
	if visible_count > max_visible_slots:
		visible_count = max_visible_slots

	for index in range(visible_count):
		var slot_item: Variant = slots[index]
		if slot_item == null:
			_slot_row.add_child(_make_empty_slot(index))
		else:
			_slot_row.add_child(_make_slot(slot_item, index, index == selected_index))

	if slots.size() > max_visible_slots:
		var extra: Label = Label.new()
		extra.text = "+%d" % (slots.size() - max_visible_slots)
		extra.add_theme_color_override("font_color", SECONDARY_TEXT)
		extra.add_theme_font_size_override("font_size", 16)
		_slot_row.add_child(extra)

	if _carried_items.get_item_count() == 0:
		var empty: Label = Label.new()
		empty.text = "CARRIED — EMPTY"
		empty.add_theme_color_override("font_color", SECONDARY_TEXT)
		empty.add_theme_font_size_override("font_size", 16)
		_slot_row.add_child(empty)

	_bulk_label.text = "CARRIED   BULK %d / %d   •   Mouse wheel / 1–0 to select" % [
		_carried_items.get_current_bulk(),
		_carried_items.max_bulk
	]


func _on_selection_changed(_selected_index: int) -> void:
	_refresh()


func _make_slot(item, index: int, selected: bool) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(118.0, 132.0)
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

	if enable_live_previews:
		var preview: ItemPreview3D = ItemPreview3DScript.new()
		preview.set_item(item)
		column.add_child(preview)
	else:
		# Keep slot geometry stable while ensuring absolutely no 3D preview
		# viewport, lights, or environment are created.
		var preview_placeholder: Control = Control.new()
		preview_placeholder.custom_minimum_size = Vector2(106.0, 80.0)
		preview_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(preview_placeholder)

	var name_label: Label = Label.new()
	var number_text: String = "0" if index == 9 else str(index + 1)
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


func _make_empty_slot(index: int) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(118.0, 132.0)
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
	var number_text: String = "0" if index == 9 else str(index + 1)
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
