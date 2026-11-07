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
var item_already_spent: Callable

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
		"applied": 0, "wasted": 0, "reason":"", "remainder": maxi(0, int(targets[lane]) - int(credited[lane]))}
	if not is_accepting() or item == null or item.definition == null:
		return state
	var utility: Dictionary = item.definition.get_utility_for_context(StringName(destination))
	lane = String(utility.get("utility_id", "None"))
	var value := int(utility.get("value", 0))
	if item.contaminated:
		value = 0 if value <= 1 else int(ceil(value / 2.0))
	if not targets.has(lane) or value <= 0:
		state.status = "ineligible"
		state.reason = "utility"
		return state
	state.lane = lane
	state.target = targets[lane]
	state.committed = credited[lane]
	state.projected = credited[lane]
	state.remainder = int(targets[lane]) - int(credited[lane])
	if int(credited[lane]) >= int(targets[lane]):
		state.status = "ineligible"
		state.reason = "full"
		return state
	if spent.any(func(receipt): return receipt.item_id == item.instance_id) or (item_already_spent.is_valid() and item_already_spent.call(item.instance_id)):
		state.status = "ineligible"
		state.reason = "spent"
		return state
	state.applied = mini(value, int(targets[lane]) - int(credited[lane]))
	state.wasted = value - int(state.applied)
	state.projected = int(credited[lane]) + int(state.applied)
	state.remainder = int(targets[lane]) - int(state.projected)
	state.status = "eligible"
	return state

func submit(carry: Node, recipient_valid: Callable = Callable()) -> Dictionary:
	if transaction_active or carry == null:
		return {"ok": false}
	var item: ItemInstance = carry.get_selected_item()
	var proposed := preview(item)
	if proposed.status != "eligible":
		return {"ok": false, "reason": proposed.status}
	transaction_active = true
	# No callbacks occur between revalidation, removal and receipt publication.
	var accepted := bool(carry.commit_selected_consumption(item,
		func(): _record_contribution(item, proposed),
		func():
			if recipient_valid.is_valid() and not bool(recipient_valid.call()): return false
			var fresh := preview(item)
			if fresh.status != "eligible": return false
			proposed.assign(fresh)
			return true
	))
	transaction_active = false
	return {"ok": accepted}

func _record_contribution(item: ItemInstance, proposed: Dictionary) -> void:
	credited[proposed.lane] = proposed.projected
	spent.append({"item_id": item.instance_id, "definition_id": String(item.definition.item_id),
		"lane": proposed.lane, "raw": int(proposed.applied) + int(proposed.wasted),
		"applied": proposed.applied, "wasted": proposed.wasted, "bulk": item.get_bulk(), "contaminated": item.contaminated})
	var fulfilled := true
	for lane: String in targets:
		if int(credited[lane]) < int(targets[lane]): fulfilled = false
	if fulfilled: _close()

func capture_state() -> Dictionary:
	return {"id": request_id, "destination": destination, "targets": targets.duplicate(true),
		"credited": credited.duplicate(true), "spent": spent.duplicate(true), "closed": closed,
		"result": result.duplicate(true)}

func restore_state(state: Dictionary) -> void:
	request_id = state.id
	destination = state.destination
	targets = state.targets.duplicate(true)
	credited = state.credited.duplicate(true)
	spent.assign(state.spent)
	closed = state.closed
	result = state.result.duplicate(true)

func is_accepting() -> bool:
	return not closed

func _close() -> void:
	closed = true
	for lane: String in targets:
		result[lane] = {"required": targets[lane], "supplied": credited[lane],
			"unmet": int(targets[lane]) - int(credited[lane])}
