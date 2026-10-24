extends "res://gameplay/requests/contribution_request.gd"

## One concurrent team request. Inventory, receipts and the commit boundary are
## shared with Medical/Kitchen; a terminal result never produces return cargo.
const PER_MEMBER := {"Food":12,"Hydration":12,"Medical":6,"Weapons":12,"Protection":12}
const BULK_PER_MEMBER := 28
var members := 4
var display_index := 1
var outgoing_bulk := 0
var dispatch_result: Dictionary = {}

func _init(id: String = "", count: int = 4, index: int = 1) -> void:
	members = count
	display_index = index
	var required: Dictionary = {}
	for lane: String in PER_MEMBER: required[lane] = PER_MEMBER[lane] * count
	super(id, "dispatch", required)

static func form_members(ready: int) -> Array[int]:
	var teams: Array[int] = []
	for _full: int in maxi(0, ready) / 4: teams.append(4)
	if ready > 0 and ready % 4 > 0: teams.append(ready % 4)
	return teams

func raw_capacity() -> int:
	return BULK_PER_MEMBER * members

func return_capacity() -> int:
	return raw_capacity() - outgoing_bulk

func preview(item: ItemInstance) -> Dictionary:
	var state := super.preview(item)
	state["bulk"] = item.get_bulk() if item != null and item.definition != null else 0
	state["outgoing_bulk"] = outgoing_bulk
	state["capacity"] = raw_capacity()
	state["return_capacity"] = return_capacity()
	if closed:
		state.status = "dispatched"
	elif state.status == "eligible" and int(state.bulk) > return_capacity():
		state.status = "capacity"
		state.reason = "capacity"
		state.projected = state.committed
		state.applied = 0
		state.wasted = 0
	return state

func _record_contribution(item: ItemInstance, proposed: Dictionary) -> void:
	outgoing_bulk += item.get_bulk()
	super._record_contribution(item, proposed)

func dispatch_underprepared(recipient_valid: Callable = Callable()) -> bool:
	if transaction_active or not is_accepting(): return false
	if recipient_valid.is_valid() and not bool(recipient_valid.call()): return false
	if not is_accepting(): return false
	transaction_active = true
	_close("manual", current_time())
	transaction_active = false
	return true

func _close(reason: String, at: float) -> void:
	if closed: return
	var dispatch_reason: String = {"fulfilled":"full", "expired":"cutoff"}.get(reason, reason)
	super._close(dispatch_reason, at)
	dispatch_result = {"team_id":request_id,"display_index":display_index,"members":members,
		"day":day,"reason":dispatch_reason,"at":at,"capacity":raw_capacity(),
		"outgoing_bulk":outgoing_bulk,"return_capacity":return_capacity(),"lanes":result.duplicate(true)}

func capture_state() -> Dictionary:
	var state := super.capture_state()
	state.merge({"members":members,"display_index":display_index,"outgoing_bulk":outgoing_bulk,
		"dispatch_result":dispatch_result.duplicate(true)})
	return state

func restore_state(state: Dictionary) -> void:
	super.restore_state(state)
	members = state.members
	display_index = state.display_index
	outgoing_bulk = state.outgoing_bulk
	dispatch_result = state.dispatch_result.duplicate(true)
