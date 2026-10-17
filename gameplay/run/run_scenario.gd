extends RefCounted

const Catalog = preload("res://prototype_item_catalog.gd")

func default_definition() -> Dictionary:
	return {"id":"m2_medical_supply", "revision":2,
		"config":{"rate":24.0, "day_start":25200.0, "latest_return":85200.0},
		"events":[
			{"id":"medical_001","kind":"medical","day":1,"at":25200.0,"deadline":36000.0,"targets":{"Medical":12}},
			{"id":"return_001","kind":"return","day":1,"at":28800.0,"departure":0.0,"manifest":["loot_000028"],"presentation_seed":9001},
			{"id":"medical_002","kind":"medical","day":2,"at":32400.0,"deadline":43200.0,"targets":{"Medical":12}},
			{"id":"return_002","kind":"return","day":2,"at":43200.0,"departure":2550.0,"manifest":["loot_000025","loot_000026"],"presentation_seed":9002},
			{"id":"medical_003","kind":"medical","day":3,"at":61200.0,"deadline":72000.0,"targets":{"Medical":12}},
			{"id":"return_003","kind":"return","day":3,"at":68400.0,"departure":5100.0,"manifest":["loot_000028"],"presentation_seed":9003}
		]}

func validate(definition: Dictionary) -> String:
	if not definition.get("id") is String or definition.id.is_empty() or definition.get("revision") != 2 or not definition.get("events") is Array or not definition.get("config") is Dictionary:
		return "Unsupported M2 scenario identity/revision"
	var config: Dictionary = definition.config
	for key: String in ["rate", "day_start", "latest_return"]:
		if typeof(config.get(key)) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(config[key])):
			return "Scenario configuration requires finite " + key
	if config.rate <= 0.0 or config.day_start < 0.0 or config.day_start >= 86400.0 or config.latest_return < config.day_start or config.latest_return >= 86400.0:
		return "Invalid day/rate/latest-return configuration"
	var ids: Dictionary = {}
	var medical: Array[Dictionary] = []
	var id_format := RegEx.create_from_string("^[A-Za-z]+_[0-9]{3}$")
	for event: Variant in definition.events:
		if not event is Dictionary or not event.get("id") is String or id_format.search(event.id) == null or ids.has(event.id):
			return "Events require unique case-sensitive zero-padded textual IDs"
		ids[event.id] = true
		if not event.get("day") is int or event.day < 1 or typeof(event.get("at")) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(event.at)) or event.at < config.day_start or event.at >= 86400.0:
			return "Invalid event day/time: " + event.id
		match event.get("kind"):
			"medical":
				if typeof(event.get("deadline")) not in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(event.deadline)) or event.deadline <= event.at or event.deadline >= 86400.0 or not event.get("targets") is Dictionary or event.targets.size() != 1 or not event.targets.get("Medical") is int or event.targets.Medical <= 0:
					return "Medical requires opening < deadline < midnight and positive Medical target: " + event.id
				for previous: Dictionary in medical:
					if previous.day == event.day and previous.at < event.deadline and event.at < previous.deadline:
						return "Overlapping Medical windows: " + previous.id + " / " + event.id
				medical.append(event)
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
