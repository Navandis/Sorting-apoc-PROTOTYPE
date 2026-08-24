extends Control
class_name StorageZoneCanvas

signal drag_percentage_changed(percent: float)
signal zone_applied

const StorageCategoriesScript = preload("res://storage_categories.gd")

const SURFACE_BG := Color(0.055, 0.065, 0.070, 1.0)
const SURFACE_BORDER := Color(0.70, 0.74, 0.72, 0.92)
const FRONT_BACK_TEXT := Color(0.68, 0.72, 0.70, 0.82)
const PREVIEW_BORDER := Color(1.0, 1.0, 1.0, 0.95)
const MIN_MARGIN: float = 34.0

var _surface: Node = null
var _category: String = StorageCategoriesScript.FOOD
var _dragging: bool = false
var _drag_start: Vector2i = Vector2i.ZERO
var _drag_current: Vector2i = Vector2i.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(900.0, 500.0)


func set_surface(surface: Node) -> void:
	var zone_callable: Callable = Callable(self, "_on_zones_changed")

	if _surface != null and is_instance_valid(_surface):
		if _surface.has_signal("zones_changed") and _surface.is_connected("zones_changed", zone_callable):
			_surface.disconnect("zones_changed", zone_callable)

	_surface = surface
	_dragging = false

	if _surface != null and is_instance_valid(_surface):
		if _surface.has_signal("zones_changed") and not _surface.is_connected("zones_changed", zone_callable):
			_surface.connect("zones_changed", zone_callable)

	queue_redraw()


func set_category(category: String) -> void:
	_category = category
	queue_redraw()


func cancel_drag() -> void:
	_dragging = false
	drag_percentage_changed.emit(0.0)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if _surface == null:
		return

	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event as InputEventMouseButton
		if button_event.button_index == MOUSE_BUTTON_LEFT:
			if button_event.pressed:
				var start_cell: Vector2i = _cell_from_position(button_event.position)
				if start_cell.x < 0:
					return
				_drag_start = start_cell
				_drag_current = start_cell
				_dragging = true
				_emit_drag_percentage()
				queue_redraw()
				accept_event()
			elif _dragging:
				var end_cell: Vector2i = _cell_from_position(button_event.position)
				if end_cell.x >= 0:
					_drag_current = end_cell

				if _category.is_empty():
					_surface.clear_zone_rect(_drag_start, _drag_current)
				else:
					_surface.set_zone_rect(_category, _drag_start, _drag_current)

				_dragging = false
				drag_percentage_changed.emit(0.0)
				zone_applied.emit()
				queue_redraw()
				accept_event()

	elif event is InputEventMouseMotion and _dragging:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		var motion_cell: Vector2i = _cell_from_position(motion_event.position)
		if motion_cell.x >= 0 and motion_cell != _drag_current:
			_drag_current = motion_cell
			_emit_drag_percentage()
			queue_redraw()
		accept_event()


func _draw() -> void:
	if _surface == null:
		return

	var grid_value: Variant = _surface.get_grid_size()
	var grid: Vector2i = grid_value as Vector2i
	if grid.x <= 0 or grid.y <= 0:
		return

	var surface_rect: Rect2 = _get_surface_rect(grid)
	draw_rect(surface_rect, SURFACE_BG, true)
	draw_rect(surface_rect, SURFACE_BORDER, false, 2.0)

	# Existing zones are drawn without cell borders. Adjacent cells of the same
	# category visually merge into a continuous rectangle/shape, keeping the
	# hidden deterministic grid out of the player's face.
	for row: int in range(grid.y):
		for column: int in range(grid.x):
			var cell: Vector2i = Vector2i(column, row)
			var category: String = String(_surface.get_zone_category(cell))
			if category.is_empty():
				continue
			var cell_rect: Rect2 = _cell_rect(cell, grid, surface_rect)
			var zone_color: Color = StorageCategoriesScript.color_for(category)
			draw_rect(cell_rect, zone_color, true)

	_draw_orientation_labels(surface_rect)

	if _dragging:
		_draw_drag_preview(grid, surface_rect)


func _draw_orientation_labels(surface_rect: Rect2) -> void:
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 13

	draw_string(
		font,
		Vector2(surface_rect.position.x + 6.0, surface_rect.position.y - 9.0),
		"BACK",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size,
		FRONT_BACK_TEXT
	)

	draw_string(
		font,
		Vector2(surface_rect.position.x + 6.0, surface_rect.end.y + 20.0),
		"FRONT",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size,
		FRONT_BACK_TEXT
	)


func _draw_drag_preview(grid: Vector2i, surface_rect: Rect2) -> void:
	var min_cell: Vector2i = Vector2i(
		mini(_drag_start.x, _drag_current.x),
		mini(_drag_start.y, _drag_current.y)
	)
	var max_cell: Vector2i = Vector2i(
		maxi(_drag_start.x, _drag_current.x),
		maxi(_drag_start.y, _drag_current.y)
	)

	var first_rect: Rect2 = _cell_rect(min_cell, grid, surface_rect)
	var last_rect: Rect2 = _cell_rect(max_cell, grid, surface_rect)

	var preview_rect: Rect2 = Rect2(
		first_rect.position,
		last_rect.end - first_rect.position
	)

	var preview_color: Color = (
		Color(0.78, 0.82, 0.82, 0.40)
		if _category.is_empty()
		else StorageCategoriesScript.color_for(_category)
	)
	preview_color.a = 0.72

	draw_rect(preview_rect, preview_color, true)
	draw_rect(preview_rect, PREVIEW_BORDER, false, 3.0)

	var ratio: float = float(_surface.get_zone_rect_percentage(_drag_start, _drag_current))
	var percent: float = ratio * 100.0
	var category_text: String = "ERASE" if _category.is_empty() else StorageCategoriesScript.short_name(_category)
	var label_text: String = "%s  %.1f%%" % [category_text, percent]

	var font: Font = ThemeDB.fallback_font
	var font_size: int = 16
	var label_position: Vector2 = preview_rect.position + Vector2(8.0, 22.0)
	draw_string(
		font,
		label_position,
		label_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		maxf(80.0, preview_rect.size.x - 16.0),
		font_size,
		Color.WHITE
	)


func _get_surface_rect(grid: Vector2i) -> Rect2:
	var available: Vector2 = Vector2(
		maxf(size.x - MIN_MARGIN * 2.0, 10.0),
		maxf(size.y - MIN_MARGIN * 2.0, 10.0)
	)
	var grid_aspect: float = float(grid.x) / float(maxi(grid.y, 1))
	var available_aspect: float = available.x / available.y

	var draw_size: Vector2
	if available_aspect > grid_aspect:
		draw_size.y = available.y
		draw_size.x = draw_size.y * grid_aspect
	else:
		draw_size.x = available.x
		draw_size.y = draw_size.x / grid_aspect

	var origin: Vector2 = (size - draw_size) * 0.5
	return Rect2(origin, draw_size)


func _cell_rect(
	cell: Vector2i,
	grid: Vector2i,
	surface_rect: Rect2
) -> Rect2:
	var cell_size: Vector2 = Vector2(
		surface_rect.size.x / float(grid.x),
		surface_rect.size.y / float(grid.y)
	)
	return Rect2(
		surface_rect.position + Vector2(
			float(cell.x) * cell_size.x,
			float(cell.y) * cell_size.y
		),
		cell_size + Vector2(0.5, 0.5)
	)


func _cell_from_position(position: Vector2) -> Vector2i:
	if _surface == null:
		return Vector2i(-1, -1)

	var grid_value: Variant = _surface.get_grid_size()
	var grid: Vector2i = grid_value as Vector2i
	var surface_rect: Rect2 = _get_surface_rect(grid)

	if not surface_rect.has_point(position):
		return Vector2i(-1, -1)

	var normalized: Vector2 = (position - surface_rect.position) / surface_rect.size
	var column: int = clampi(int(floor(normalized.x * float(grid.x))), 0, grid.x - 1)
	var row: int = clampi(int(floor(normalized.y * float(grid.y))), 0, grid.y - 1)
	return Vector2i(column, row)


func _emit_drag_percentage() -> void:
	if not _dragging or _surface == null:
		drag_percentage_changed.emit(0.0)
		return

	var ratio: float = float(_surface.get_zone_rect_percentage(_drag_start, _drag_current))
	drag_percentage_changed.emit(ratio * 100.0)


func _on_zones_changed() -> void:
	queue_redraw()
