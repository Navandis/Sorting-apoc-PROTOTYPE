extends RefCounted

## Persistent accounting; presentation and supply generation are separate owners.
var request_id: String
var destination: String
var targets: Dictionary
var credited: Dictionary = {}
var spent: Array[Dictionary] = []
var closed := false
var result: Dictionary = {}
var transaction_active := false
var occurrence_id := ""
var day := 0
var opened_at := 0.0
var deadline := -1.0 # Untimed standalone prototype/test consumers retain M1 behavior.
var closed_at := -1.0
var closure_reason := ""
var time_source: Callable

func _init(id: String = "", context: String = "medical_bay", lanes: Dictionary = {"Medical": 12}) -> void:
	request_id = id
	destination = context
	targets = lanes.duplicate(true)
	for lane: String in targets:
		credited[lane] = 0

func preview(item: ItemInstance) -> Dictionary:
	var lane := String(targets.keys()[0])
	var state := {"status": "closed" if not is_accepting() else "empty", "lane": lane,
		"target": targets[lane], "committed": credited[lane], "projected": credited[lane],
		"applied": 0, "wasted": 0, "remainder": maxi(0, int(targets[lane]) - int(credited[lane]))}
	if not is_accepting() or item == null or item.definition == null:
		return state
	var utility: Dictionary = item.definition.get_utility_for_context(StringName(destination))
	lane = String(utility.get("utility_id", "None"))
	var value := int(utility.get("value", 0))
	if item.contaminated:
		value = 0 if value <= 1 else int(ceil(value / 2.0))
	if not targets.has(lane) or value <= 0 or int(credited[lane]) >= int(targets[lane]):
		state.status = "ineligible"
		return state
	state.lane = lane
	state.target = targets[lane]
	state.committed = credited[lane]
	state.applied = mini(value, int(targets[lane]) - int(credited[lane]))
	state.wasted = value - int(state.applied)
	state.projected = int(credited[lane]) + int(state.applied)
	state.remainder = int(targets[lane]) - int(state.projected)
	state.status = "eligible"
	return state

func submit(carry: Node) -> Dictionary:
	if transaction_active or carry == null:
		return {"ok": false}
	var item: ItemInstance = carry.get_selected_item()
	var proposed := preview(item)
	if proposed.status != "eligible":
		return {"ok": false, "reason": proposed.status}
	transaction_active = true
	# No callbacks occur between revalidation, removal and receipt publication.
	var accepted := bool(carry.commit_selected_consumption(item, func():
		credited[proposed.lane] = proposed.projected
		spent.append({"item_id": item.instance_id, "definition_id": String(item.definition.item_id),
			"lane": proposed.lane, "applied": proposed.applied, "wasted": proposed.wasted})
		var fulfilled := true
		for lane: String in targets:
			if int(credited[lane]) < int(targets[lane]):
				fulfilled = false
		if fulfilled:
			_close("fulfilled", current_time())
	))
	transaction_active = false
	return {"ok": accepted}

func capture_state() -> Dictionary:
	return {"id": request_id, "destination": destination, "targets": targets.duplicate(true),
		"credited": credited.duplicate(true), "spent": spent.duplicate(true), "closed": closed,
		"result": result.duplicate(true), "occurrence_id": occurrence_id, "day": day,
		"opened_at": opened_at, "deadline": deadline, "closed_at": closed_at, "closure_reason": closure_reason}

func restore_state(state: Dictionary) -> void:
	request_id = state.id
	destination = state.destination
	targets = state.targets.duplicate(true)
	credited = state.credited.duplicate(true)
	spent.assign(state.spent)
	closed = state.closed
	result = state.result.duplicate(true)
	occurrence_id = state.occurrence_id
	day = state.day
	opened_at = state.opened_at
	deadline = state.deadline
	closed_at = state.closed_at
	closure_reason = state.closure_reason

func current_time() -> float:
	return float(time_source.call()) if time_source.is_valid() else 0.0

func is_accepting() -> bool:
	var now := current_time()
	return not closed and (deadline < 0.0 or (opened_at <= now and now < deadline))

func expire(now: float) -> void:
	if not closed and deadline >= 0.0 and now >= deadline:
		_close("expired", deadline)

func _close(reason: String, at: float) -> void:
	closed = true
	closed_at = at
	closure_reason = reason
	for lane: String in targets:
		result[lane] = {"required": targets[lane], "supplied": credited[lane],
			"unmet": int(targets[lane]) - int(credited[lane])}
