extends "res://tools/asset_pipeline/tests/receiving_freight_reach_tests.gd"

var checks := 0

func _run() -> void:
	create_timer(180).timeout.connect(func():
		push_error("M3 cargo helper aborted; completion missing")
		quit(3))
	var identities: Dictionary = {}
	var completed := 0
	var definition: Dictionary = load("res://gameplay/run/run_scenario.gd").new().default_definition()
	for event: Dictionary in definition.events:
		if event.kind != "return": continue
		var result := await _measure_case({"label":event.id,"content_seed":0,"fixture_mode":DeckPlannerScript.FixtureMode.BARE,"event":event})
		_check(result.drained and result.fixture_visuals_clean and result.records.size() == 16, "exact M3 basket progressively TAKES every physical item: " + event.id)
		for record: Dictionary in result.records:
			_check(not identities.has(record.instance_id) and record.hit_distance_m <= 3.4, "fresh identity and ordinary Receiving reach")
			identities[record.instance_id] = true
		_print_measurement_summary(result.records)
		completed += 1
	_check(completed == 12 and identities.size() == 192, "all twelve exact baskets and 192 unique physical items completed")
	_finish()

func _prepare_case(runtime: Node, case: Dictionary) -> bool:
	runtime.run_identity = load("res://gameplay/run/run_identity.gd").new()
	var event: Dictionary = case.event
	var started := Time.get_ticks_usec()
	var batch: LootBatch = runtime.prepare_manifest(event.manifest,event.id,event.presentation_seed)
	print("M3_PREPARATION_MS ",event.id," ",(Time.get_ticks_usec()-started)/1000.0)
	if batch == null: return false
	_check(batch.entries.map(func(e): return String(e.definition_id)) == event.manifest and batch.entries.size() == 16, "planner preserves exact ordered manifest")
	return runtime.return_admission.submit_return(event.id,batch) == AwaitingLiftAdmission.ReturnResult.ADMITTED

func _check(condition: bool, message: String) -> bool:
	checks += 1
	return super._check(condition,message)

func _finish() -> void:
	print("M3_CARGO_COMPLETE checks=",checks," failures=",int(_failed))
	quit(1 if _failed else 0)
