extends Node
class_name CarriedItems

## Bulk-limited carried-item strip. Slots may contain gaps after items are
## placed/removed; new pickups fill the first empty slot before extending the
## strip to the right.

signal contents_changed
signal selection_changed(selected_index: int)
signal item_added(item)
signal item_removed(item)

@export_range(1, 999, 1) var max_bulk: int = 10

# Retained only so older prototype scenes load cleanly. Step 3 intentionally
# starts empty; world pickup now supplies the test items.
@export var debug_seed_items: bool = false

var _slots: Array[RefCounted] = []
var _selected_index: int = -1


func _ready() -> void:
	# Step 3 disables debug seeding even if an older scene still serialized the
	# previous property as true.
	debug_seed_items = false


func _unhandled_input(event: InputEvent) -> void:
	if get_item_count() == 0:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			select_previous()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select_next()
			get_viewport().set_input_as_handled()

	elif event is InputEventKey and event.pressed and not event.echo:
		var slot: int = _keycode_to_slot(event.keycode)
		if slot >= 0 and slot < _slots.size() and _slots[slot] != null:
			select_index(slot)
			get_viewport().set_input_as_handled()


func get_slots() -> Array[RefCounted]:
	return _slots.duplicate()


func get_items() -> Array[RefCounted]:
	var items: Array[RefCounted] = []
	for item in _slots:
		if item != null:
			items.append(item)
	return items


func get_item_count() -> int:
	var count: int = 0
	for item in _slots:
		if item != null:
			count += 1
	return count


func get_selected_index() -> int:
	return _selected_index


func get_selected_item():
	if _selected_index < 0 or _selected_index >= _slots.size():
		return null
	return _slots[_selected_index]


func get_current_bulk() -> int:
	var total: int = 0
	for item in _slots:
		if item != null and item.has_method("get_bulk"):
			total += int(item.get_bulk())
	return total


func get_remaining_bulk() -> int:
	return maxi(0, max_bulk - get_current_bulk())


func can_add(item) -> bool:
	if item == null or not item.has_method("get_bulk"):
		return false
	return get_current_bulk() + int(item.get_bulk()) <= max_bulk


func add_item(item) -> bool:
	if not can_add(item):
		return false

	var target_slot: int = _first_empty_slot()
	if target_slot == -1:
		_slots.append(item)
		target_slot = _slots.size() - 1
	else:
		_slots[target_slot] = item

	if _selected_index == -1:
		_selected_index = target_slot

	item_added.emit(item)
	contents_changed.emit()
	selection_changed.emit(_selected_index)
	return true


func remove_item(item):
	var index: int = _slots.find(item)
	if index == -1:
		return null
	return remove_at(index)


func remove_selected():
	if _selected_index < 0:
		return null
	return remove_at(_selected_index)


func remove_at(index: int):
	if index < 0 or index >= _slots.size():
		return null

	var removed: RefCounted = _slots[index]
	if removed == null:
		return null

	_slots[index] = null
	_trim_empty_tail()

	if get_item_count() == 0:
		_selected_index = -1
	else:
		_selected_index = _nearest_occupied_slot(index)

	item_removed.emit(removed)
	contents_changed.emit()
	selection_changed.emit(_selected_index)
	return removed


func select_next() -> void:
	if get_item_count() == 0:
		return
	var start: int = _selected_index
	if start < 0:
		start = 0
	for offset in range(1, _slots.size() + 1):
		var candidate: int = (start + offset) % _slots.size()
		if _slots[candidate] != null:
			select_index(candidate)
			return


func select_previous() -> void:
	if get_item_count() == 0:
		return
	var start: int = _selected_index
	if start < 0:
		start = 0
	for offset in range(1, _slots.size() + 1):
		var candidate: int = (start - offset + _slots.size()) % _slots.size()
		if _slots[candidate] != null:
			select_index(candidate)
			return


func select_index(index: int) -> void:
	if index < 0 or index >= _slots.size():
		return
	if _slots[index] == null or index == _selected_index:
		return
	_selected_index = index
	selection_changed.emit(_selected_index)


func _first_empty_slot() -> int:
	for index in range(_slots.size()):
		if _slots[index] == null:
			return index
	return -1


func _trim_empty_tail() -> void:
	while not _slots.is_empty() and _slots[_slots.size() - 1] == null:
		_slots.remove_at(_slots.size() - 1)


func _nearest_occupied_slot(preferred_index: int) -> int:
	if _slots.is_empty():
		return -1

	# remove_at() trims empty slots from the right before asking for the next
	# selection. The removed slot's old index can therefore now be beyond the
	# end of the shortened array. Clamp it back into the surviving strip first.
	var search_index: int = clampi(preferred_index, 0, _slots.size() - 1)

	# Prefer the same surviving slot/index if it is occupied.
	if _slots[search_index] != null:
		return search_index

	# Then prefer occupied slots to the right, which preserves the normal
	# "continue forward through the strip" behaviour after placing an item.
	for right_index: int in range(search_index + 1, _slots.size()):
		if _slots[right_index] != null:
			return right_index

	# If there is nothing to the right, walk back to the nearest surviving item.
	# This is the case that previously left the selector at -1 after the player
	# placed all items to the right of the remaining leftmost item.
	for left_index: int in range(search_index - 1, -1, -1):
		if _slots[left_index] != null:
			return left_index

	return -1


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
