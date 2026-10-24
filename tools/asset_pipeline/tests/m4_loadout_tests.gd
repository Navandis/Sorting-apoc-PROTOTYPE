extends SceneTree

var failures := 0
var checks := 0
var serial := 0

func _init() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M4 loadout helper incomplete")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func item(lane: String, value: int, bulk: int = 1, id: String = "") -> ItemInstance:
	serial += 1
	var definition := ItemDefinition.new()
	definition.utility_id = StringName(lane)
	definition.utility_value = value
	definition.bulk = bulk
	definition.item_id = StringName("test_%d" % serial)
	return ItemInstance.new(definition, "item_%d" % serial if id.is_empty() else id)

func select(carry: CarriedItems, supply: ItemInstance) -> void:
	check(carry.add_item(supply), "Real carry admits test supply within 20 Bulk")
	carry.select_index(carry.get_slots().find(supply))

func run() -> void:
	if not check(ResourceLoader.exists("res://gameplay/requests/dispatch_loadout.gd"), "Dispatch loadout owner exists"):
		finish()
		return
	var script = load("res://gameplay/requests/dispatch_loadout.gd")
	var cases := {0:[],1:[1],2:[2],3:[3],4:[4],12:[4,4,4],13:[4,4,4,1],14:[4,4,4,2],15:[4,4,4,3],16:[4,4,4,4],17:[4,4,4,4,1],21:[4,4,4,4,4,1]}
	for ready: int in cases:
		check(script.form_members(ready) == cases[ready], "Full-team-first formation Ready=%d" % ready)
	var team = script.new("durable-team-1", 1, 1)
	check(team.targets == {"Food":12,"Hydration":12,"Medical":6,"Weapons":12,"Protection":12} and team.raw_capacity() == 28, "Per-member targets and raw capacity")
	var large = script.new("durable-team-6", 4, 6)
	check(large.raw_capacity() == 112 and large.targets.Medical == 24 and large.display_index == 6, "Scaling and no team-count cap")
	var carry := CarriedItems.new()
	root.add_child(carry)
	var food := item("Food", 20, 20)
	select(carry, food)
	var preview: Dictionary = team.preview(food)
	check(preview.applied == 12 and preview.wasted == 8 and team.outgoing_bulk == 0, "Preview caps Utility without spending Bulk")
	var observer := {"seen":false}
	carry.item_removed.connect(func(removed):
		if removed == food:
			observer.seen = team.credited.Food == 12 and team.outgoing_bulk == 20 and team.spent[0].raw == 20 and team.spent[0].bulk == 20)
	check(team.submit(carry).ok and observer.seen, "Receipt, raw/wasted credit and full Bulk precede carry observers")
	check(large.credited.Food == 0 and large.outgoing_bulk == 0, "Other recipient remains untouched")
	var rejected := item("Hydration", 7, 9)
	select(carry, rejected)
	check(team.preview(rejected).status == "capacity" and not team.submit(carry).ok and carry.get_selected_item() == rejected and team.credited.Hydration == 0, "Over-Bulk rejection preserves exact item and progress")
	carry.remove_item(rejected)
	var exact := item("Hydration", 7, 8)
	select(carry, exact)
	check(team.submit(carry).ok and team.outgoing_bulk == 28 and not team.closed and team.return_capacity() == 0, "Exact remaining Bulk accepted; capacity full does not dispatch incomplete team")
	var saved: Dictionary = team.capture_state()
	var restored = script.new()
	restored.restore_state(saved)
	check(restored.capture_state() == saved, "Loadout state round trip retains all authoritative facts")
	check(team.dispatch_underprepared() and team.closed and team.closure_reason == "manual" and team.dispatch_result.outgoing_bulk == 28 and team.dispatch_result.return_capacity == 0, "Deliberate partial dispatch retains full outgoing cost")
	var terminal: Dictionary = team.capture_state()
	check(not team.dispatch_underprepared(), "Manual dispatch cannot repeat")
	team.expire(1000.0)
	check(team.capture_state() == terminal, "Cutoff cannot rewrite an earlier terminal dispatch")
	var empty = script.new("empty", 1, 2)
	check(empty.dispatch_underprepared() and empty.dispatch_result.return_capacity == 28, "Explicit empty dispatch is immediate")
	var cutoff = script.new("cutoff", 4, 3)
	cutoff.opened_at = 0.0
	cutoff.deadline = 600.0
	cutoff.expire(599.999)
	check(not cutoff.closed, "Half-open interval accepts before deadline")
	cutoff.expire(600.0)
	check(cutoff.closed and cutoff.closure_reason == "cutoff" and cutoff.closed_at == 600.0 and cutoff.dispatch_result.return_capacity == 112, "Cutoff dispatches an empty team once at exact deadline")
	var full = script.new("full", 1, 4)
	for lane: String in ["Food","Hydration","Medical","Weapons","Protection"]:
		var supply := item(lane, 99, 1)
		select(carry, supply)
		check(full.submit(carry).ok, "Independent capped lane: " + lane)
	check(full.closed and full.closure_reason == "full" and full.outgoing_bulk == 5 and full.dispatch_result.return_capacity == 23, "Fifth committed track dispatches once with final Bulk")
	var supplies := item("Food", 1)
	select(carry, supplies)
	check(not full.submit(carry).ok and carry.get_selected_item() == supplies, "Dispatched recipient rejects intact")
	carry.remove_item(supplies)
	var global = script.new("guard", 1, 5)
	global.item_already_spent = func(id): return full.spent.any(func(r): return r.item_id == id)
	var duplicate := item("Food", 3, 1, full.spent[0].item_id)
	select(carry, duplicate)
	check(not global.submit(carry).ok and carry.get_selected_item() == duplicate, "Global spent guard rejects a duplicate at a different team")
	carry.remove_item(duplicate)
	var invalid := item("Fuel", 3)
	select(carry, invalid)
	check(global.preview(invalid).status == "ineligible" and not global.submit(carry).ok and carry.get_selected_item() == invalid, "Globally ineligible item remains intact")
	carry.remove_item(invalid)
	var vetoed := item("Food", 3)
	select(carry, vetoed)
	check(not global.submit(carry, func(): return false).ok and carry.get_selected_item() == vetoed, "Commit recipient/time validator rejects intact")
	carry.remove_item(vetoed)
	var timed = script.new("commit-clock",1,7)
	var now := {"value":0.0}
	timed.deadline = 1.0
	timed.time_source = func(): return now.value
	var late := item("Food",3)
	select(carry,late)
	check(not timed.submit(carry,func():
		now.value = 1.0
		return true).ok and carry.get_selected_item() == late and timed.spent.is_empty(),"Time is revalidated at commit, after preview and recipient validation")
	carry.free()
	finish()

func finish() -> void:
	print("M4_LOADOUT_COMPLETE checks=",checks," failures=",failures)
	quit(1 if failures else 0)
