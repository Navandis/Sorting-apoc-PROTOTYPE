extends RefCounted

## Historical small Medical/Receiving assertions, expressed as a fresh schema-3
## synthetic fixture. This is not an M2 save migration or player scenario.
func definition() -> Dictionary:
	return {"id":"medical_mechanical_fixture","revision":3,
		"config":{"rate":24.0,"day_start":25200.0,"latest_return":85200.0},
		"events":[
			{"id":"medical_001","kind":"medical","day":1,"at":25200.0,"deadline":36000.0,"targets":{"Medical":12}},
			{"id":"return_001","kind":"return","day":1,"at":28800.0,"departure":0.0,"manifest":["loot_000028"],"presentation_seed":9001},
			{"id":"medical_002","kind":"medical","day":2,"at":32400.0,"deadline":43200.0,"targets":{"Medical":12}},
			{"id":"return_002","kind":"return","day":2,"at":43200.0,"departure":2550.0,"manifest":["loot_000025","loot_000026"],"presentation_seed":9002},
			{"id":"medical_003","kind":"medical","day":3,"at":61200.0,"deadline":72000.0,"targets":{"Medical":12}},
			{"id":"return_003","kind":"return","day":3,"at":68400.0,"departure":5100.0,"manifest":["loot_000028"],"presentation_seed":9003}]}
