extends RefCounted

const Catalog = preload("res://prototype_item_catalog.gd")
const Loadout = preload("res://gameplay/requests/dispatch_loadout.gd")
const BASELINE := "res://data/scenarios/m4/Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json"

func default_definition() -> Dictionary:
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASELINE))
	var events: Array = []
	for day: int in range(1, 4):
		events.append({"id":"dispatch_%03d" % day,"kind":"dispatch","day":day,
			"at":21600.0,"deadline":36000.0,"ready":16})
	for row: Dictionary in baseline.scenario.runtime_events:
		if int(row.members) > 0: continue
		var medical: bool = row.label.ends_with("Medical")
		var day := int(row.day)
		var targets: Dictionary = {}
		for lane: String in row.targets: targets[lane] = int(row.targets[lane])
		var event := {"id":"medical_%03d" % day if medical else "kitchen_%03d" % ((day-1)*3 + ["Breakfast","Lunch","Dinner"].find(row.label.get_slice("-",1)) + 1),
			"kind":"medical" if medical else "kitchen", "day":day,
			"at":float(row.open_seconds_of_day), "deadline":float(row.deadline_seconds_of_day), "targets":targets}
		if not medical: event["meal"] = row.label.get_slice("-",1)
		events.append(event)
	for index: int in baseline.scenario.manifests.size():
		var manifest: Dictionary = baseline.scenario.manifests[index]
		var parts: PackedStringArray = String(manifest.time).split(":")
		events.append({"id":"return_%03d" % (index+1),"kind":"return","day":int(manifest.day),
			"at":float(int(parts[0])*3600+int(parts[1])*60),"departure":float((int(manifest.day)-1)*2700),
			"manifest":manifest.path.duplicate(),"presentation_seed":9400+index})
	return {"id":"m4_expedition_loadout","revision":4,
		"config":{"rate":24.0,"day_start":21600.0,"latest_return":85200.0},
		"initial_seed":baseline.scenario.seed.duplicate(),"events":events}

func legacy_m3_definition() -> Dictionary:
	# Fixed approved group order; instances are allocated only when issued.
	var baskets := {
		"A":[7,7,6,8,8,9,12,20,20,21,21,22,22,22,22,25],
		"B":[6,6,7,8,9,9,10,12,19,20,21,21,22,22,22,26],
		"C":[7,7,8,8,10,10,11,20,20,21,21,22,22,22,22,28],
		"D":[6,8,8,9,9,10,12,12,20,20,21,22,22,22,22,25]}
	var orders := [["A","B","C","D"],["C","D","A","B"],["B","A","D","C"]]
	var events: Array = []
	for day: int in range(1,4):
		var medical_at: float = [25200.0,32400.0,61200.0][day-1]
		events.append({"id":"medical_%03d" % day,"kind":"medical","day":day,"at":medical_at,"deadline":medical_at+10800.0,"targets":{"Medical":12}})
		for index: int in 3:
			var at: float = [32400.0,50400.0,64800.0][index]
			events.append({"id":"kitchen_%03d" % ((day-1)*3+index+1),"kind":"kitchen","meal":["Breakfast","Lunch","Dinner"][index],"day":day,"at":at,"deadline":at+10800.0,"targets":{"Food":[30,36,36][index],"Hydration":[24,24,30][index]}})
		for index: int in 4:
			var sequence := (day-1)*4+index+1
			var manifest: Array = []
			for number: int in baskets[orders[day-1][index]]: manifest.append("loot_%06d" % number)
			events.append({"id":"return_%03d" % sequence,"kind":"return","day":day,"at":[30600.0,45900.0,63000.0,80100.0][index],"departure":float((day-1)*2550),"manifest":manifest,"presentation_seed":9100+sequence})
	return {"id":"m3_kitchen_meal_service","revision":3,
		"config":{"rate":24.0,"day_start":25200.0,"latest_return":85200.0},"events":events}

func destination_for(kind: String) -> String:
	return {"medical":"medical_bay", "kitchen":"kitchen", "dispatch":"dispatch"}.get(kind, "")

func validate(definition: Dictionary) -> String:
	if not definition.get("id") is String or definition.id.is_empty() or definition.get("revision") not in [3,4] or not definition.get("events") is Array or not definition.get("config") is Dictionary:
		return "Unsupported scenario identity/revision"
	if definition.revision == 4:
		if not definition.get("initial_seed") is Array or definition.initial_seed.size() != 85: return "M4 requires its complete 85-item initial manifest"
		for id: Variant in definition.initial_seed:
			if not id is String or Catalog.get_definition_by_id(StringName(id)) == null: return "Unknown M4 starting supply"
	var config: Dictionary = definition.config
	for key: String in ["rate", "day_start", "latest_return"]:
		if typeof(config.get(key)) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(config[key])):
			return "Scenario configuration requires finite " + key
	if config.rate <= 0.0 or config.day_start < 0.0 or config.day_start >= 86400.0 or config.latest_return < config.day_start or config.latest_return >= 86400.0:
		return "Invalid day/rate/latest-return configuration"
	var ids: Dictionary = {}
	var windows: Array[Dictionary] = []
	var meals_by_day: Dictionary = {}
	var id_format := RegEx.create_from_string("^[A-Za-z]+_[0-9]{3,}$")
	for event: Variant in definition.events:
		if not event is Dictionary or not event.get("id") is String or id_format.search(event.id) == null or ids.has(event.id):
			return "Events require unique case-sensitive zero-padded textual IDs"
		ids[event.id] = true
		if not event.get("day") is int or event.day < 1 or typeof(event.get("at")) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(event.at)) or event.at < config.day_start or event.at >= 86400.0:
			return "Invalid event day/time: " + event.id
		match event.get("kind"):
			"dispatch":
				if definition.revision != 4 or not event.get("ready") is int or event.ready < 0 or typeof(event.get("deadline")) not in [TYPE_FLOAT,TYPE_INT] or not is_finite(float(event.deadline)) or event.at != config.day_start or event.deadline <= event.at or event.deadline >= 86400.0:
					return "Invalid authored Ready roster/preparation interval: " + event.id
				for previous: Dictionary in windows:
					if previous.kind == "dispatch" and previous.day == event.day: return "Duplicate daily Dispatch roster"
				windows.append(event)
			"medical", "kitchen":
				if typeof(event.get("deadline")) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(event.deadline)) or event.deadline <= event.at or event.deadline >= 86400.0 or not event.get("targets") is Dictionary:
					return "Request requires opening < deadline < midnight and positive targets: " + event.id
				var lanes: Array = ["Medical"] if event.kind == "medical" else ["Food","Hydration"]
				if event.targets.size() != lanes.size(): return "Unexpected request lanes: " + event.id
				for lane: String in lanes:
					if not event.targets.get(lane) is int or event.targets[lane] <= 0: return "Invalid positive lane target: " + event.id
				for previous: Dictionary in windows:
					if previous.kind == event.kind and previous.day == event.day and previous.at < event.deadline and event.at < previous.deadline:
						return "Overlapping destination windows: " + previous.id + " / " + event.id
				windows.append(event)
				if event.kind == "kitchen":
					if event.get("meal") not in ["Breakfast","Lunch","Dinner"]: return "Unknown meal: " + event.id
					if not meals_by_day.has(event.day): meals_by_day[event.day] = []
					if meals_by_day[event.day].has(event.meal): return "Duplicate daily meal: " + event.id
					meals_by_day[event.day].append(event.meal)
			"return":
				if event.at > config.latest_return or not event.get("manifest") is Array or event.manifest.is_empty() or not event.get("presentation_seed") is int or typeof(event.get("departure")) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(event.departure)) or event.departure < 0.0:
					return "Invalid controlled return time/manifest/departure: " + event.id
				var arrival: float = (event.day - 1) * (86400.0 - config.day_start) / config.rate + (event.at - config.day_start) / config.rate
				if event.departure > arrival: return "Return departure follows its attempt: " + event.id
				for id: Variant in event.manifest:
					if not id is String or id in ["loot_000034", "loot_000036"] or Catalog.get_definition_by_id(StringName(id)) == null:
						return "Unsupported controlled cargo: " + str(id)
			_:
				return "Unsupported event kind: " + event.id
	for day: int in meals_by_day:
		if meals_by_day[day].size() != 3: return "Kitchen day requires all three meals"
	return ""

func activation_before(a: Dictionary, b: Dictionary) -> bool:
	# Keep return ordering a total order even when other event kinds coincide.
	if (a.kind == "return") != (b.kind == "return"): return a.kind != "return"
	if a.kind == "return" and b.kind == "return" and a.departure != b.departure:
		return a.departure < b.departure
	return String(a.id).casecmp_to(String(b.id)) < 0

func closure_before(a: Dictionary, b: Dictionary) -> bool:
	if a.opened_at != b.opened_at: return a.opened_at < b.opened_at
	return String(a.id).casecmp_to(String(b.id)) < 0
