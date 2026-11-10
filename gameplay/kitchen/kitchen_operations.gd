extends RefCounted

const Config = preload("res://gameplay/kitchen/kitchen_test_config.gd")

signal changed
signal notice(message: String)

var outstanding := Vector2i.ZERO
var _issued := Vector2i.ZERO
var _opened_at := 0
var _opening_event := 0
var _overdue := false
var _first_at := 0
var _last_at := 0
var _next_at := 0
var _event_index := 0
var _timing := RandomNumberGenerator.new()
var _amount := RandomNumberGenerator.new()
var _clock: RefCounted
var _other_consumer_has_spent: Callable
var _receipts: Dictionary = {}
var _transaction_active := false

func _init(clock: RefCounted, other_consumer_has_spent: Callable = Callable()) -> void:
	_clock = clock
	_other_consumer_has_spent = other_consumer_has_spent

func initialize(timing_seed: int, amount_seed: int) -> void:
	assert(_first_at == 0)
	_timing.seed = timing_seed
	_amount.seed = amount_seed
	_first_at = _timing.randi_range(Config.INTERVAL.x, Config.INTERVAL.y)
	_next_at = _first_at

func deadline_at() -> int:
	return _opened_at + Config.GRACE_SECONDS if _opening_event != 0 else 0

func next_boundary_at() -> float:
	var scheduled := float(_next_at) if _next_at != 0 else INF
	if _opening_event != 0 and not _overdue:
		return minf(scheduled, deadline_at())
	return scheduled

func settle_due() -> void:
	var boundary := next_boundary_at()
	while boundary <= _clock.elapsed:
		var message := ""
		if _opening_event != 0 and not _overdue and deadline_at() == boundary:
			_overdue = true
			message = "Kitchen grace expired. Sprint unavailable."
		if _next_at == boundary:
			_last_at = _next_at
			_event_index += 1
			_next_at = _last_at + _timing.randi_range(Config.INTERVAL.x, Config.INTERVAL.y)
			var admitted := _add_demand(Config.draw_proposal(_amount), _last_at, _event_index)
			if admitted != Vector2i.ZERO:
				if not message.is_empty():
					message += "\n"
				message += "Kitchen added %d Food / %d Hydration." % [admitted.x, admitted.y]
		if not message.is_empty():
			changed.emit()
			notice.emit(message)
		boundary = next_boundary_at()

func _add_demand(proposed: Vector2i, at: int, event_index: int) -> Vector2i:
	var admitted := Config.clip(proposed, Config.CAP - total_outstanding(), event_index)
	if admitted == Vector2i.ZERO:
		return admitted
	if _opening_event == 0:
		_opening_event = event_index
		_opened_at = at
	_issued += admitted
	outstanding += admitted
	return admitted

func total_outstanding() -> int:
	return outstanding.x + outstanding.y

func effective_capacity(normal: int) -> int:
	var scale := 100 * Config.UTILITY_PER_POINT
	@warning_ignore("integer_division")
	return normal * (scale - total_outstanding()) / scale if _overdue else normal

func sprint_allowed() -> bool:
	return not _overdue

func has_spent_item(id: String) -> bool:
	return _receipts.has(id)

func preview(item: ItemInstance) -> Dictionary:
	if _opening_event == 0:
		return {"ok": false, "reason": "No outstanding demand."}
	if item == null:
		return {"ok": false, "reason": "Select a carried item."}
	var lane := Config.LANES.find(item.get_storage_category())
	var raw := item.get_utility_value()
	if lane < 0 or raw <= 0 or item.get_bulk() <= 0:
		return {"ok": false, "reason": "Kitchen accepts Food or Hydration with Utility."}
	if outstanding[lane] == 0:
		return {"ok": false, "reason": "%s is already supplied." % Config.LANES[lane]}
	if item.definition.item_id.is_empty() or item.instance_id.is_empty() or has_spent_item(item.instance_id) \
			or (_other_consumer_has_spent.is_valid() and _other_consumer_has_spent.call(item.instance_id)):
		return {"ok": false, "reason": "This item is unavailable."}
	var applied := mini(raw, outstanding[lane])
	return {"ok": true, "lane": Config.LANES[lane], "applied": applied, "wasted": raw - applied,
		"before": total_outstanding(), "after": total_outstanding() - applied}

func contribute(carry: CarriedItems, expected: ItemInstance, has_access: Callable) -> Dictionary:
	if _transaction_active or not is_instance_valid(carry):
		return {"ok": false}
	_transaction_active = true
	settle_due()
	var was_overdue := _overdue
	var quote: Dictionary = {}
	var accepted := carry.commit_selected_consumption(expected,
		func(): _commit(expected, quote),
		func():
			if not has_access.is_valid() or not bool(has_access.call()) or not _uniquely_carried(carry, expected):
				return false
			quote.assign(preview(expected))
			return quote.ok)
	_transaction_active = false
	if not accepted:
		return {"ok": false, "reason": quote.get("reason", "The original selection or station is unavailable.")}
	changed.emit()
	if outstanding == Vector2i.ZERO:
		notice.emit("Kitchen supplied. Capacity and sprint restored." if was_overdue else "Kitchen supplied.")
	return quote

func _uniquely_carried(carry: CarriedItems, expected: ItemInstance) -> bool:
	var matches := 0
	for item: RefCounted in carry.get_items():
		if item is ItemInstance and item.instance_id == expected.instance_id:
			matches += 1
	return matches == 1

func _commit(item: ItemInstance, quote: Dictionary) -> void:
	var lane := Config.LANES.find(quote.lane)
	_receipts[item.instance_id] = {"item_id": item.instance_id, "definition_id": String(item.definition.item_id),
		"lane": quote.lane, "contaminated": item.contaminated, "applied": quote.applied, "wasted": quote.wasted,
		"opening_event": _opening_event, "opened_at": _opened_at, "event_index": _event_index,
		"issued": _issued, "at": _clock.elapsed}
	outstanding[lane] -= quote.applied
	if outstanding == Vector2i.ZERO:
		_issued = Vector2i.ZERO
		_opening_event = 0
		_opened_at = 0
		_overdue = false

func capture_state() -> Dictionary:
	var obligation := {}
	if _opening_event != 0:
		obligation = {"opening_event": _opening_event, "opened_at": _opened_at, "overdue": _overdue,
			"issued": _issued, "outstanding": outstanding}
	return {"config": Config.capture(), "first_at": _first_at, "last_at": _last_at, "next_at": _next_at,
		"event_index": _event_index, "timing_state": _timing.state, "amount_state": _amount.state,
		"obligation": obligation, "receipts": _receipts.values().duplicate(true)}

func restore_state(state: Dictionary) -> void:
	_first_at = state.first_at
	_last_at = state.last_at
	_next_at = state.next_at
	_event_index = state.event_index
	_timing.state = state.timing_state
	_amount.state = state.amount_state
	var obligation: Dictionary = state.obligation
	_opening_event = obligation.get("opening_event", 0)
	_opened_at = obligation.get("opened_at", 0)
	_overdue = obligation.get("overdue", false)
	_issued = obligation.get("issued", Vector2i.ZERO)
	outstanding = obligation.get("outstanding", Vector2i.ZERO)
	_receipts.clear()
	for receipt: Dictionary in state.receipts:
		_receipts[receipt.item_id] = receipt.duplicate(true)
