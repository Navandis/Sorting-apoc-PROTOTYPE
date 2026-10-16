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

func _init(id: String = "", context: String = "medical_bay", lanes: Dictionary = {"Medical": 12}) -> void:
	request_id = id
	destination = context
	targets = lanes.duplicate(true)
	for lane: String in targets:
		credited[lane] = 0

func preview(item: ItemInstance) -> Dictionary:
	var lane := String(targets.keys()[0])
	var state := {"status": "closed" if closed else "empty", "lane": lane,
		"target": targets[lane], "committed": credited[lane], "projected": credited[lane],
		"applied": 0, "wasted": 0, "remainder": maxi(0, int(targets[lane]) - int(credited[lane]))}
	if closed or item == null or item.definition == null:
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
		closed = true
		for lane: String in targets:
			if int(credited[lane]) < int(targets[lane]):
				closed = false
		if closed:
			for lane: String in targets:
				result[lane] = {"required": targets[lane], "supplied": credited[lane],
					"unmet": int(targets[lane]) - int(credited[lane])}
	))
	transaction_active = false
	return {"ok": accepted}

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
