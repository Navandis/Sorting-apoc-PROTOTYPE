extends RefCounted

const Config := preload("res://gameplay/fuel/fuel_test_config.gd")
const Catalog := preload("res://prototype_item_catalog.gd")

var normal_freight_through := 0.0

func validate(state: Dictionary, elapsed: float, items: Dictionary, terminal: Dictionary,
		seed_prefix: String, seed_definition: Callable) -> String:
	if not _shape(state, {"config": TYPE_DICTIONARY, "anchor_at": TYPE_FLOAT,
			"anchor_reserve": TYPE_FLOAT, "reserve": TYPE_FLOAT, "receipts": TYPE_ARRAY}):
		return "Invalid Fuel state"
	if state.config != Config.capture():
		return "Incompatible Fuel test configuration"
	var anchor_at := 0.0
	var amount := Config.STARTING_RESERVE
	normal_freight_through = Config.crossing_at(amount, anchor_at, Config.NORMAL_LIFT_MINIMUM)
	for receipt: Variant in state.receipts:
		if not _shape(receipt, {"item_id": TYPE_STRING, "definition_id": TYPE_STRING,
				"contaminated": TYPE_BOOL, "raw": TYPE_INT, "applied": TYPE_FLOAT,
				"wasted": TYPE_FLOAT, "at": TYPE_FLOAT}):
			return "Invalid Fuel receipt"
		var id: String = receipt.item_id
		if id.is_empty() or items.has(id) or terminal.has(id):
			return "Fuel receipt duplicates a live item or terminal disposition: " + id
		if not is_finite(receipt.at) or receipt.at < anchor_at or receipt.at > elapsed:
			return "Invalid Fuel receipt time"
		var definition := Catalog.get_definition_by_id(StringName(receipt.definition_id))
		if definition == null or definition.storage_category != "Fuel" or definition.utility_id != &"Fuel" or definition.bulk <= 0:
			return "Invalid Fuel receipt definition: " + id
		if id.begins_with(seed_prefix) and receipt.definition_id != seed_definition.call(id.trim_prefix(seed_prefix)):
			return "Fuel receipt differs from its authored seed: " + id
		var item := ItemInstance.new(definition, id)
		item.contaminated = receipt.contaminated
		var raw := item.get_utility_value()
		var before := Config.reserve_at(amount, anchor_at, receipt.at)
		var headroom := Config.CAPACITY - before
		var applied := minf(raw, headroom)
		if applied <= 0.0 or raw != receipt.raw or applied != receipt.applied or raw - applied != receipt.wasted:
			return "Fuel receipt does not conserve credited and wasted Utility: " + id
		amount = Config.CAPACITY if raw >= headroom else before + applied
		anchor_at = receipt.at
		if amount >= Config.NORMAL_LIFT_MINIMUM:
			normal_freight_through = Config.crossing_at(amount, anchor_at, Config.NORMAL_LIFT_MINIMUM)
		terminal[id] = receipt
	if anchor_at != state.anchor_at or amount != state.anchor_reserve \
			or Config.reserve_at(amount, anchor_at, elapsed) != state.reserve:
		return "Fuel reserve does not match its receipt and active-time history"
	return ""

static func _shape(value: Variant, fields: Dictionary) -> bool:
	if not value is Dictionary:
		return false
	for key: String in fields:
		if not value.has(key) or typeof(value[key]) != fields[key]:
			return false
	return true
