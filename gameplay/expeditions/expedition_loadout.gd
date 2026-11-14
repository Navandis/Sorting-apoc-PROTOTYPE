extends "res://gameplay/requests/contribution_request.gd"

const Config = preload("res://gameplay/expeditions/expedition_config.gd")
const CONTEXT := "expedition"

var raw_capacity: int

func _init(members: int = 1) -> void:
	super("", CONTEXT, Config.targets_for(members))
	raw_capacity = members * Config.BULK_PER_MEMBER

func submitted_bulk() -> int:
	var total := 0
	for receipt: Dictionary in spent:
		total += receipt.bulk
	return total

func preview(item: ItemInstance) -> Dictionary:
	var state := super.preview(item)
	state.bulk = item.get_bulk() if item != null else 0
	if state.status == "eligible" and state.bulk > raw_capacity - submitted_bulk():
		state.status = "ineligible"
		state.reason = "capacity"
		state.projected = state.committed
		state.remainder = state.target - state.committed
		state.applied = 0
		state.wasted = 0
	return state

func _utility_for_item(item: ItemInstance) -> Dictionary:
	return {"utility_id": item.get_storage_category(), "value": item.get_utility_value()}
