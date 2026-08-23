extends Node
class_name CarriedItems

## Bulk-limited carried-item queue. This is intentionally not a conventional
## inventory: there are no grids, nested containers, or arbitrary hidden slots.
## It is simply the bundle of physical items the Quartermaster is carrying.

signal contents_changed
signal selection_changed(selected_index: int)
signal item_added(item)
signal item_removed(item)

@export_range(1, 999, 1) var max_bulk: int = 10

# Prototype-only switch so Step 2 can be evaluated before pickup exists.
# Turn this off when Step 3 world-item pickup is wired in.
@export var debug_seed_items: bool = true

const ItemDefinitionScript = preload("res://item_definition.gd")
const ItemInstanceScript = preload("res://item_instance.gd")

var _items: Array[RefCounted] = []
var _selected_index: int = -1


func _ready() -> void:
	if debug_seed_items and _items.is_empty():
		_seed_debug_items()


func _unhandled_input(event: InputEvent) -> void:
	if _items.is_empty():
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			select_previous()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select_next()
			get_viewport().set_input_as_handled()

	elif event is InputEventKey and event.pressed and not event.echo:
		var slot := _keycode_to_slot(event.keycode)
		if slot >= 0 and slot < _items.size():
			select_index(slot)
			get_viewport().set_input_as_handled()


func get_items() -> Array[RefCounted]:
	return _items.duplicate()


func get_selected_index() -> int:
	return _selected_index


func get_selected_item():
	if _selected_index < 0 or _selected_index >= _items.size():
		return null
	return _items[_selected_index]


func get_current_bulk() -> int:
	var total := 0
	for item in _items:
		if item != null and item.has_method("get_bulk"):
			total += item.get_bulk()
	return total


func get_remaining_bulk() -> int:
	return max(0, max_bulk - get_current_bulk())


func can_add(item) -> bool:
	if item == null or not item.has_method("get_bulk"):
		return false
	return get_current_bulk() + item.get_bulk() <= max_bulk


func add_item(item) -> bool:
	if not can_add(item):
		return false

	_items.append(item)
	if _selected_index == -1:
		_selected_index = 0

	item_added.emit(item)
	contents_changed.emit()
	selection_changed.emit(_selected_index)
	return true


func remove_item(item):
	var index := _items.find(item)
	if index == -1:
		return null
	return remove_at(index)


func remove_selected():
	if _selected_index < 0:
		return null
	return remove_at(_selected_index)


func remove_at(index: int):
	if index < 0 or index >= _items.size():
		return null

	var removed = _items[index]
	_items.remove_at(index)

	if _items.is_empty():
		_selected_index = -1
	else:
		_selected_index = min(index, _items.size() - 1)

	item_removed.emit(removed)
	contents_changed.emit()
	selection_changed.emit(_selected_index)
	return removed


func select_next() -> void:
	if _items.is_empty():
		return
	select_index((_selected_index + 1) % _items.size())


func select_previous() -> void:
	if _items.is_empty():
		return
	select_index((_selected_index - 1 + _items.size()) % _items.size())


func select_index(index: int) -> void:
	if index < 0 or index >= _items.size() or index == _selected_index:
		return
	_selected_index = index
	selection_changed.emit(_selected_index)


func _keycode_to_slot(keycode: int) -> int:
	match keycode:
		KEY_1: return 0
		KEY_2: return 1
		KEY_3: return 2
		KEY_4: return 3
		KEY_5: return 4
		KEY_6: return 5
		KEY_7: return 6
		KEY_8: return 7
		KEY_9: return 8
		KEY_0: return 9
		_: return -1


func _seed_debug_items() -> void:
	# 9/10 Bulk on purpose: enough variety to exercise cycling/highlighting while
	# also showing that capacity is Bulk-based rather than slot-based.
	_add_debug_item(&"canned_food", "Canned Food", &"Food", 6, 1, Vector3i(1, 1, 1), true)
	_add_debug_item(&"painkillers", "Painkillers", &"Medical", 4, 1, Vector3i(1, 1, 1), true)
	_add_debug_item(&"hammer", "Hammer", &"Weapons", 3, 2, Vector3i(1, 3, 1), false)
	_add_debug_item(&"tennis_racket", "Tennis Racket", &"Weapons", 1, 5, Vector3i(2, 5, 1), false)


func _add_debug_item(
	item_id: StringName,
	display_name: String,
	utility_id: StringName,
	utility_value: int,
	bulk: int,
	footprint: Vector3i,
	stackable: bool
) -> void:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.item_id = item_id
	definition.display_name = display_name
	definition.utility_id = utility_id
	definition.utility_value = utility_value
	definition.bulk = bulk
	definition.storage_footprint = footprint
	definition.stackable = stackable

	var item: ItemInstance = ItemInstanceScript.new(definition)
	add_item(item)
