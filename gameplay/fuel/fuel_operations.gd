extends RefCounted

const Config := preload("res://gameplay/fuel/fuel_test_config.gd")

signal power_changed

var capacity: float
var _clock: RefCounted
var _other_consumer_has_spent: Callable
var _anchor_at := 0.0
var _anchor_reserve := 0.0
var _observed_band := 3
var _receipts: Dictionary = {}
var _transaction_active := false

func _init(clock: RefCounted, other_consumer_has_spent: Callable = Callable(), tank_capacity: float = Config.CAPACITY) -> void:
	_clock = clock
	_other_consumer_has_spent = other_consumer_has_spent
	capacity = tank_capacity

func initialize() -> void:
	_anchor_at = _clock.elapsed
	_anchor_reserve = Config.STARTING_RESERVE
	_observed_band = band()
	_receipts.clear()

func reserve() -> float:
	return Config.reserve_at(_anchor_reserve, _anchor_at, _clock.elapsed)

func band() -> int:
	return Config.band_at(_anchor_reserve, _anchor_at, _clock.elapsed)

func lift_emergency() -> bool:
	return band() == 3

func salvager_available() -> bool:
	return band() == 0

func workshop_available() -> bool:
	return band() <= 1

func lighting_multiplier() -> float:
	return Config.LIGHT_STRENGTH[band()]

func next_boundary_at() -> float:
	for threshold: float in Config.THRESHOLDS:
		var at := Config.crossing_at(_anchor_reserve, _anchor_at, threshold)
		if at > _clock.elapsed:
			return at
	var empty_at := Config.crossing_at(_anchor_reserve, _anchor_at, 0.0)
	return empty_at if empty_at > _clock.elapsed else INF

func settle_power() -> void:
	var current := band()
	if current != _observed_band:
		_observed_band = current
		power_changed.emit()

func has_spent_item(id: String) -> bool:
	return _receipts.has(id)

func preview(item: ItemInstance) -> Dictionary:
	if item == null:
		return {"ok": false, "reason": "Select a carried item."}
	var raw := item.get_utility_value()
	if item.get_utility_id() != &"Fuel" or item.get_storage_category() != "Fuel" or raw <= 0 or item.get_bulk() <= 0:
		return {"ok": false, "reason": "Select a Fuel item with Utility."}
	if item.definition.item_id.is_empty() or item.instance_id.is_empty() or has_spent_item(item.instance_id) \
			or (_other_consumer_has_spent.is_valid() and _other_consumer_has_spent.call(item.instance_id)):
		return {"ok": false, "reason": "This item is unavailable."}
	var before := reserve()
	var headroom := capacity - before
	if headroom <= 0.0:
		return {"ok": false, "reason": "Tank full."}
	var applied := minf(raw, headroom)
	var after := capacity if raw >= headroom else before + applied
	return {"ok": true, "raw": raw, "applied": applied, "wasted": raw - applied, "after": after}

func contribute(carry: CarriedItems, expected: ItemInstance, has_access: Callable) -> Dictionary:
	if _transaction_active or not is_instance_valid(carry):
		return {"ok": false, "reason": "A contribution is unavailable."}
	_transaction_active = true
	var quote: Dictionary = {}
	var accepted := carry.commit_selected_consumption(expected,
		func(): _commit(expected, quote),
		func():
			if not has_access.is_valid() or not bool(has_access.call()):
				return false
			var matches := 0
			for item: RefCounted in carry.get_items():
				if item is ItemInstance and item.instance_id == expected.instance_id:
					matches += 1
			if matches != 1:
				return false
			quote.assign(preview(expected))
			return quote.ok)
	_transaction_active = false
	if not accepted:
		return {"ok": false, "reason": quote.get("reason", "The original selection or station is unavailable.")}
	return quote

func _commit(item: ItemInstance, quote: Dictionary) -> void:
	_anchor_at = _clock.elapsed
	_anchor_reserve = quote.after
	_receipts[item.instance_id] = {"item_id": item.instance_id, "definition_id": String(item.definition.item_id),
		"contaminated": item.contaminated, "raw": quote.raw, "applied": quote.applied,
		"wasted": quote.wasted, "at": _anchor_at}
	settle_power()

func capture_state() -> Dictionary:
	return {"config": Config.capture(), "anchor_at": _anchor_at, "anchor_reserve": _anchor_reserve,
		"reserve": reserve(), "receipts": _receipts.values().duplicate(true)}

func restore_state(state: Dictionary) -> void:
	_anchor_at = state.anchor_at
	_anchor_reserve = state.anchor_reserve
	_observed_band = band()
	_receipts.clear()
	for receipt: Dictionary in state.receipts:
		_receipts[receipt.item_id] = receipt.duplicate(true)
