extends "res://tools/asset_pipeline/tests/pre_m4_receiving_tests.gd"

const BASELINE := "res://data/scenarios/m4/Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json"

func _run() -> void:
	create_timer(300).timeout.connect(func():
		push_error("M4 cargo helper incomplete")
		quit(3))
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASELINE))
	for index: int in baseline.scenario.manifests.size():
		var manifest: Dictionary = baseline.scenario.manifests[index]
		var result := await _measure_case({"label":manifest.label,"manifest":manifest.path,"index":index,"content_seed":0,"fixture_mode":DeckPlannerScript.FixtureMode.BARE})
		_check(result.drained and result.fixture_visuals_clean and result.records.size() == 16, "Exact 16-item M4 manifest drains: " + manifest.label)
		for record: Dictionary in result.records:
			_check(not identities.has(record.instance_id), "Distinct runtime identity across all manifests")
			identities[record.instance_id] = true
			takes += 1
		completed += 1
		print("M4_CARGO_MANIFEST label=",manifest.label," drained=",result.drained," takes=",result.records.size()," records=",JSON.stringify(result.records))
	_check(completed == 12 and takes == 192 and identities.size() == 192, "Every exact manifest and identity actually TAKEN")
	_check(handoffs == 192 and no_surface.is_empty(), "All 192 items use production shelf placement and retrieval")
	print("M4_CARGO_COMPLETE manifests=",completed," takes=",takes," shelf_handoffs=",handoffs," blockers=",no_surface," failures=",int(_failed))
	quit(1 if _failed else 0)

func _prepare_case(runtime: Node, case: Dictionary) -> bool:
	runtime.run_identity = load("res://gameplay/run/run_identity.gd").new()
	var batch: LootBatch = runtime.prepare_manifest(case.manifest, case.label, 9400 + case.index)
	if batch == null: return false
	_check(batch.entries.map(func(e): return String(e.definition_id)) == case.manifest, "Exact ordered identities retained")
	return runtime.return_admission.submit_return(case.label, batch) == AwaitingLiftAdmission.ReturnResult.ADMITTED
