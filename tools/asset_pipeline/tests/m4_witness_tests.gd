extends SceneTree

## Isolated arithmetic replay of the approved manual example. This never runs
## from gameplay and does not allocate/provision supplies for the player.
var checks := 0
var failures := 0
func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func run() -> void:
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/scenarios/m4/Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json"))
	var catalog: ItemCatalog = load("res://data/items/item_catalog.tres")
	var carry := CarriedItems.new()
	root.add_child(carry)
	var supplies: Dictionary = {}
	var availability: Dictionary = {}
	var requests: Dictionary = {}
	var spent: Dictionary = {}
	var serial := 0
	for token: Dictionary in baseline.scenario.supply_tokens:
		serial += 1
		availability[token.token] = float(token.available)
		supplies[token.token] = ItemInstance.new(catalog.get_definition_by_id(StringName(token.item_id)),"replay-stock:%03d" % serial)
	var now := {"elapsed":0.0}
	var clock = load("res://gameplay/run/run_clock.gd").new()
	for event: Dictionary in baseline.scenario.runtime_events:
		serial += 1
		var request: RefCounted
		if int(event.members) > 0:
			request = load("res://gameplay/requests/dispatch_loadout.gd").new("replay-request:%03d" % serial,int(event.members),int(event.label.get_slice("T",1)))
		else:
			var targets: Dictionary = {}
			for lane: String in event.targets: targets[lane] = int(event.targets[lane])
			request = load("res://gameplay/requests/contribution_request.gd").new("replay-request:%03d" % serial,"medical_bay" if event.label.ends_with("Medical") else "kitchen",targets)
		request.day = int(event.day)
		request.opened_at = clock.timestamp(request.day,float(event.open_seconds_of_day))
		request.deadline = clock.timestamp(request.day,float(event.deadline_seconds_of_day))
		request.time_source = func(): return now.elapsed
		request.item_already_spent = func(id): return spent.has(id)
		requests[event.label] = request
	var rows: Array = baseline.scenario.witness.duplicate(true)
	rows.sort_custom(func(a,b): return a.deadline < b.deadline)
	var consumed := 0
	for row: Dictionary in rows:
		var request: RefCounted = requests[row.request]
		now.elapsed = request.deadline - 0.001
		var raw := 0
		var bulk := 0
		var applied := 0
		var waste := 0
		for token: String in row.supply_tokens:
			var supply: ItemInstance = supplies[token]
			check(availability[token] < float(row.deadline),"Analysis availability precedes deadline; half-hour allowance is test data only")
			check(not spent.has(supply.instance_id),"Example does not reuse a supply token")
			check(carry.add_item(supply),"Each whole example item respects 20-Bulk carrying capacity")
			var preview: Dictionary = request.preview(supply)
			check(preview.status == "eligible","Example item eligible at selected recipient before deadline")
			raw += int(preview.applied)+int(preview.wasted)
			bulk += supply.get_bulk()
			applied += int(preview.applied)
			waste += int(preview.wasted)
			check(request.submit(carry).ok,"Real irreversible request transaction accepts approved example item")
			spent[supply.instance_id] = true
			consumed += 1
		check(raw == int(row.raw) and applied == int(row.credited) and waste == int(row.waste) and bulk == int(row.bulk),"Approved lane obligation accounting: " + row.request + "/" + row.lane)
		if row.request == "D2-Lunch" and row.lane == "Food":
			check(row.supply_tokens == ["D2-B:001","SEED:020"] and raw == 70 and applied == 60 and waste == 10 and bulk == 18,"Day 2 lunch uses existing corn plus existing pumpkin, 70/60/10 and full 18 Bulk")
	var remaining := 0
	var remaining_bulk := 0
	for supply: ItemInstance in supplies.values():
		if not spent.has(supply.instance_id):
			remaining += 1
			remaining_bulk += supply.get_bulk()
	for request: RefCounted in requests.values(): check(request.closed,"Every approved example consumer fulfilled")
	for label: String in baseline.scenario.teams:
		check(requests[label].outgoing_bulk == int(baseline.scenario.teams[label].bulk) and requests[label].dispatch_result.return_capacity == 112-requests[label].outgoing_bulk,"Example retains full outgoing Bulk and immutable team result: " + label)
	check(rows.size() == 81 and consumed == 211 and spent.size() == 211 and remaining == 66 and remaining_bulk == 234,"Entire finite-stock example: 81 obligations / 211 unique spends / 66 items and 234 Bulk left")
	carry.free()
	print("M4_WITNESS_COMPLETE obligations=",rows.size()," consumed=",consumed," remaining=",remaining," bulk=",remaining_bulk," checks=",checks," failures=",failures)
	quit(1 if failures else 0)
