extends RefCounted

## A disposal receipt is terminal ownership evidence. The machine keeps no items.
var warning_shown := false

var _clock: RefCounted
var _other_consumer_has_spent: Callable
var _receipts: Dictionary = {}
var _transaction_active := false

func _init(clock: RefCounted, other_consumer_has_spent: Callable = Callable()) -> void:
	_clock = clock
	_other_consumer_has_spent = other_consumer_has_spent

func has_spent_item(id: String) -> bool:
	return _receipts.has(id)

func can_attempt(carry: CarriedItems, expected: ItemInstance, has_access: Callable) -> bool:
	return not _transaction_active and _valid_selection(carry, expected, has_access)

func mark_warning_displayed() -> void:
	warning_shown = true

func incinerate(carry: CarriedItems, expected: ItemInstance, has_access: Callable) -> bool:
	if _transaction_active or not warning_shown or not is_instance_valid(carry):
		return false
	_transaction_active = true
	var accepted := carry.commit_selected_consumption(expected,
		func():
			_receipts[expected.instance_id] = {
				"item_id": expected.instance_id,
				"definition_id": String(expected.definition.item_id),
				"at": _clock.elapsed,
			},
		func(): return _valid_selection(carry, expected, has_access))
	_transaction_active = false
	return accepted

func _valid_selection(carry: CarriedItems, expected: ItemInstance, has_access: Callable) -> bool:
	if not is_instance_valid(carry) or expected == null or carry.get_selected_item() != expected:
		return false
	if expected.definition == null or expected.definition.item_id.is_empty() or expected.instance_id.is_empty() \
			or expected.get_bulk() <= 0 or _receipts.has(expected.instance_id):
		return false
	if _other_consumer_has_spent.is_valid() and _other_consumer_has_spent.call(expected.instance_id):
		return false
	var matches := 0
	for item: RefCounted in carry.get_items():
		if item is ItemInstance and item.instance_id == expected.instance_id:
			matches += 1
	return matches == 1 and has_access.is_valid() and bool(has_access.call())

func capture_state() -> Dictionary:
	return {"warning_shown": warning_shown, "receipts": _receipts.values().duplicate(true)}

func restore_state(state: Dictionary) -> void:
	warning_shown = state.warning_shown
	_receipts.clear()
	for receipt: Dictionary in state.receipts:
		_receipts[receipt.item_id] = receipt.duplicate(true)
