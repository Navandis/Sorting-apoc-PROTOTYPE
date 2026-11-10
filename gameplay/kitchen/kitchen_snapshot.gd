extends RefCounted

const Config = preload("res://gameplay/kitchen/kitchen_test_config.gd")

func validate(state: Dictionary, elapsed: float, items: Dictionary, terminal: Dictionary,
		seed_prefix: String, seed_definition: Callable) -> String:
	if not _valid_schedule(state, elapsed):
		return "Invalid Kitchen configuration or schedule"
	var opening_event := 0
	var opened_at := 0
	var event_index := 0
	var issued := Vector2i.ZERO
	var credited := Vector2i.ZERO
	var previous_at := -1.0
	for receipt: Variant in state.receipts:
		if not _shape(receipt, {"item_id": TYPE_STRING, "definition_id": TYPE_STRING, "lane": TYPE_STRING,
				"contaminated": TYPE_BOOL, "applied": TYPE_INT, "wasted": TYPE_INT, "at": TYPE_FLOAT,
				"opening_event": TYPE_INT, "opened_at": TYPE_INT, "event_index": TYPE_INT, "issued": TYPE_VECTOR2I}):
			return "Invalid Kitchen receipt shape"
		var id: String = receipt.item_id
		if id.is_empty() or items.has(id) or terminal.has(id):
			return "Missing or multiply owned Kitchen identity: " + id
		if receipt.opening_event != opening_event:
			if credited != issued or receipt.opening_event != event_index + 1 or receipt.opened_at <= previous_at \
					or not _valid_opening(state, receipt.opening_event, receipt.opened_at):
				return "Invalid Kitchen obligation history"
			opening_event = receipt.opening_event
			opened_at = receipt.opened_at
			event_index = opening_event - 1
			issued = Vector2i.ZERO
			credited = Vector2i.ZERO
		elif credited == issued:
			return "A cleared Kitchen obligation received another contribution"
		if receipt.opened_at != opened_at or receipt.event_index < event_index \
				or not _valid_receipt_time(state, receipt, previous_at, elapsed) \
				or not _valid_issuance(receipt.issued, issued, credited, receipt.event_index - event_index,
					receipt.event_index == opening_event):
			return "Inconsistent Kitchen receipt chronology or issuance"
		var definition := PrototypeItemCatalog.get_definition_by_id(StringName(receipt.definition_id))
		var lane := Config.LANES.find(receipt.lane)
		if definition == null or lane < 0 or definition.storage_category != receipt.lane or definition.bulk <= 0:
			return "Invalid Kitchen receipt definition or lane: " + id
		if id.begins_with(seed_prefix) and receipt.definition_id != seed_definition.call(id.trim_prefix(seed_prefix)):
			return "Kitchen receipt differs from its authored seed: " + id
		var item := ItemInstance.new(definition, id)
		item.contaminated = receipt.contaminated
		var raw := item.get_utility_value()
		var applied := mini(raw, receipt.issued[lane] - credited[lane])
		if applied <= 0 or receipt.applied != applied or receipt.wasted != raw - applied:
			return "Invalid Kitchen credit or waste: " + id
		credited[lane] += applied
		issued = receipt.issued
		previous_at = receipt.at
		event_index = receipt.event_index
		terminal[id] = receipt

	var obligation: Dictionary = state.obligation
	if obligation.is_empty():
		return "" if credited == issued and event_index == state.event_index else "Missing uncleared Kitchen obligation"
	if not _shape(obligation, {"opening_event": TYPE_INT, "opened_at": TYPE_INT, "overdue": TYPE_BOOL,
			"issued": TYPE_VECTOR2I, "outstanding": TYPE_VECTOR2I}) \
			or not _valid_opening(state, obligation.opening_event, obligation.opened_at) \
			or obligation.overdue != (elapsed >= obligation.opened_at + Config.GRACE_SECONDS):
		return "Invalid Kitchen obligation or grace"
	if obligation.opening_event != opening_event:
		if credited != issued or obligation.opening_event != event_index + 1 or obligation.opened_at <= previous_at:
			return "Kitchen opened before its previous obligation cleared"
		event_index = obligation.opening_event - 1
		issued = Vector2i.ZERO
		credited = Vector2i.ZERO
	elif obligation.opened_at != opened_at or credited == issued:
		return "Invalid live Kitchen obligation identity"
	if not _valid_issuance(obligation.issued, issued, credited, state.event_index - event_index,
			state.event_index == obligation.opening_event) \
			or obligation.outstanding != obligation.issued - credited or obligation.outstanding == Vector2i.ZERO:
		return "Inconsistent Kitchen balances"
	return ""

func _valid_schedule(state: Dictionary, elapsed: float) -> bool:
	if not _shape(state, {"config": TYPE_DICTIONARY, "first_at": TYPE_INT, "last_at": TYPE_INT, "next_at": TYPE_INT,
			"event_index": TYPE_INT, "timing_state": TYPE_INT, "amount_state": TYPE_INT,
			"obligation": TYPE_DICTIONARY, "receipts": TYPE_ARRAY}):
		return false
	if state.config != Config.capture() or state.first_at < Config.INTERVAL.x or state.first_at > Config.INTERVAL.y \
			or state.next_at <= elapsed or state.event_index < 0:
		return false
	if state.event_index == 0:
		return state.last_at == 0 and state.next_at == state.first_at and state.obligation.is_empty() and state.receipts.is_empty()
	return state.last_at >= state.first_at and state.last_at <= elapsed \
		and _valid_interval_span(state.last_at - state.first_at, state.event_index - 1) \
		and _valid_interval_span(state.next_at - state.last_at, 1)

func _valid_opening(state: Dictionary, event: int, at: int) -> bool:
	return event > 0 and event <= state.event_index and at >= state.first_at and at <= state.last_at \
		and _valid_interval_span(at - state.first_at, event - 1) \
		and _valid_interval_span(state.last_at - at, state.event_index - event)

func _valid_receipt_time(state: Dictionary, receipt: Dictionary, previous: float, elapsed: float) -> bool:
	if not is_finite(receipt.at) or receipt.at < previous or receipt.at > elapsed \
			or receipt.event_index < receipt.opening_event or receipt.event_index > state.event_index:
		return false
	var additions: int = receipt.event_index - receipt.opening_event
	var since_open: float = receipt.at - receipt.opened_at
	if since_open < float(additions) * Config.INTERVAL.x or since_open >= (float(additions) + 1.0) * Config.INTERVAL.y:
		return false
	return receipt.at >= state.last_at if receipt.event_index == state.event_index else receipt.at < state.last_at

func _valid_interval_span(seconds: int, intervals: int) -> bool:
	return seconds >= float(intervals) * Config.INTERVAL.x and seconds <= float(intervals) * Config.INTERVAL.y

func _valid_issuance(issued: Vector2i, previous: Vector2i, credited: Vector2i, events: int, first_event: bool) -> bool:
	if issued.x < previous.x or issued.y < previous.y or issued.x < credited.x or issued.y < credited.y:
		return false
	var growth := issued - previous
	var remaining := issued - credited
	var minimum_lane := Config.food_bounds(Config.PROPOSAL.x).x
	if growth.x + growth.y > float(events) * Config.PROPOSAL.y or remaining.x + remaining.y > Config.CAP \
			or issued.x < minimum_lane or issued.y < minimum_lane:
		return false
	if first_event:
		var total := issued.x + issued.y
		if total < Config.PROPOSAL.x or total > Config.PROPOSAL.y:
			return false
		var bounds := Config.food_bounds(total)
		return issued.x >= bounds.x and issued.x <= bounds.y
	return true

func _shape(value: Variant, fields: Dictionary) -> bool:
	if not value is Dictionary:
		return false
	for key: String in fields:
		if not value.has(key) or typeof(value[key]) != fields[key]:
			return false
	return true
