extends SceneTree

const FixtureInstanceScript = preload("res://receiving/receiving_freight_fixture_instance.gd")
const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const DeckPlannerScript = preload("res://receiving/receiving_deck_layout_planner.gd")
const DeckPoseScript = preload("res://receiving/receiving_deck_item_pose.gd")
const PrototypeLootSourceScript = preload("res://receiving/prototype_loot_source.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypePool = preload("res://data/receiving/prototype_loot_pool.tres")
const ProofProfile = preload("res://data/receiving/receiving_deck_stage_b_proof.tres")

var _failures: int = 0


func _init() -> void:
	_test_fixture_instance_round_trip()
	_test_historical_batch_defaults_to_no_fixtures()
	_test_fixture_layout_round_trip_and_atomic_rejections()
	_test_fixture_modes_preserve_exact_content()
	_test_lazy_activation_and_surface_preferences()
	_test_large_priority_preserves_non_large_positions()
	if _failures > 0:
		print("FAIL: receiving freight fixture runtime tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving freight fixture runtime tests")
	quit(0)


func _test_fixture_instance_round_trip() -> void:
	var fixture = FixtureInstanceScript.create(
		"fixture:crate:0",
		&"crate_plastic_01",
		0,
		&"crate_front_left",
		&"Crate_00",
		Vector2i(1, 13),
		0,
		Vector2i(5, 6),
		Transform3D(Basis.IDENTITY, Vector3(-1.15, 0.0, 0.6))
	)
	_check(fixture != null, "valid fixture instance is created")
	if fixture == null:
		return
	var bytes := var_to_bytes(fixture.to_snapshot())
	var restored = FixtureInstanceScript.from_snapshot(bytes_to_var(bytes) as Dictionary)
	_check(restored != null, "fixture instance snapshot restores")
	if restored != null:
		_check(var_to_bytes(restored.to_snapshot()) == bytes, "fixture instance round-trips byte-identically")


func _test_historical_batch_defaults_to_no_fixtures() -> void:
	var batch := _batch()
	var historical: Dictionary = batch.to_snapshot()
	historical.erase("presentation_fixtures")
	var restored: LootBatch = LootBatchScript.from_snapshot(historical)
	_check(restored != null, "historical batch without fixture key restores")
	if restored != null:
		_check(restored.presentation_fixtures.is_empty(), "historical batch defaults to an empty fixture list")
	var illegal_content: Dictionary = batch.to_snapshot()
	illegal_content["presentation_fixtures"] = [_proof_crate_fixture().to_snapshot()]
	_check(LootBatchScript.from_snapshot(illegal_content) == null, "CONTENT_COMMITTED snapshot cannot contain committed fixtures")


func _test_fixture_layout_round_trip_and_atomic_rejections() -> void:
	var batch := _batch()
	var fixture = _proof_crate_fixture()
	var placements := _placements(&"Crate_00")
	var before := var_to_bytes(batch.to_snapshot())
	_check(
		not batch.commit_deck_layout(placements, ProofProfile.profile_id, int(ProofProfile.revision), [], ProofProfile),
		"item placement cannot reference an inactive fixture surface"
	)
	_check(var_to_bytes(batch.to_snapshot()) == before, "inactive fixture surface rejection is byte-atomic")
	var second_fixture = _second_proof_crate_fixture()
	var two_fixture_placements := _two_fixture_placements()
	var duplicate_instance: Array = [fixture, _second_proof_crate_fixture(fixture.instance_id)]
	_check(
		not batch.commit_deck_layout(two_fixture_placements, ProofProfile.profile_id, int(ProofProfile.revision), duplicate_instance, ProofProfile),
		"duplicate fixture instance ID is rejected"
	)
	_check(var_to_bytes(batch.to_snapshot()) == before, "duplicate instance rejection is byte-atomic")
	var duplicate_surface: Array = [fixture, _second_proof_crate_fixture("fixture:crate:1", &"Crate_00")]
	_check(
		not batch.commit_deck_layout(two_fixture_placements, ProofProfile.profile_id, int(ProofProfile.revision), duplicate_surface, ProofProfile),
		"duplicate fixture surface ID is rejected"
	)
	_check(var_to_bytes(batch.to_snapshot()) == before, "duplicate surface rejection is byte-atomic")
	var duplicate_socket: Array = [fixture, FixtureInstanceScript.create(
		"fixture:crate:1", &"crate_plastic_06", 0, &"crate_front_left", &"Crate_01",
		Vector2i(1, 13), 0, Vector2i(5, 7), Transform3D.IDENTITY
	)]
	_check(
		not batch.commit_deck_layout(two_fixture_placements, ProofProfile.profile_id, int(ProofProfile.revision), duplicate_socket, ProofProfile),
		"duplicate fixture socket ID is rejected"
	)
	_check(var_to_bytes(batch.to_snapshot()) == before, "duplicate socket rejection is byte-atomic")

	var empty_fixture_placements := _placements(&"MainDeck")
	_check(
		not batch.commit_deck_layout(empty_fixture_placements, ProofProfile.profile_id, int(ProofProfile.revision), [fixture], ProofProfile),
		"fixture with no assigned item is rejected"
	)
	_check(var_to_bytes(batch.to_snapshot()) == before, "empty fixture rejection is byte-atomic")

	_check(
		batch.commit_deck_layout(placements, ProofProfile.profile_id, int(ProofProfile.revision), [fixture], ProofProfile),
		"valid fixture-aware layout commits"
	)
	_check(batch.presentation_fixtures.size() == 1, "committed fixture is exposed through a read copy")
	var fixture_read_copy := batch.presentation_fixtures
	fixture_read_copy.clear()
	_check(batch.presentation_fixtures.size() == 1, "fixture read view cannot mutate batch state")
	var bytes := var_to_bytes(batch.to_snapshot())
	var restored: LootBatch = LootBatchScript.from_snapshot(bytes_to_var(bytes) as Dictionary)
	_check(restored != null, "fixture-aware prepared batch restores")
	if restored != null:
		_check(var_to_bytes(restored.to_snapshot()) == bytes, "fixture-aware batch round-trips byte-identically")


func _batch() -> LootBatch:
	var entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("entry_0000", "fixture_batch:item_0000", &"loot_000001"),
		LootBatchEntryScript.new("entry_0001", "fixture_batch:item_0001", &"loot_000002"),
	]
	return LootBatchScript.create_committed(
		"fixture_batch", &"test", "fixture-runtime", 2, 2, 1842, 9001, entries
	)


func _proof_crate_fixture(
	instance_id: String = "fixture:crate:0",
	surface_id: StringName = &"Crate_00"
):
	return FixtureInstanceScript.create(
		instance_id,
		&"crate_plastic_01",
		0,
		&"crate_front_left",
		surface_id,
		Vector2i(1, 13),
		0,
		Vector2i(5, 6),
		Transform3D(Basis.IDENTITY, Vector3(-1.15, 0.0, 0.6))
	)


func _second_proof_crate_fixture(
	instance_id: String = "fixture:crate:1",
	surface_id: StringName = &"Crate_01"
):
	return FixtureInstanceScript.create(
		instance_id,
		&"crate_plastic_06",
		0,
		&"crate_middle_center",
		surface_id,
		Vector2i(12, 13),
		0,
		Vector2i(5, 7),
		Transform3D(Basis.IDENTITY, Vector3(-0.05, 0.0, 0.65))
	)


func _placements(first_surface: StringName) -> Dictionary:
	return {
		"entry_0000": {
			"surface_id": first_surface,
			"cell_origin": Vector2i.ZERO,
			"quarter_turns": 0,
			"stack_group_id": "%s:stack_0000" % String(first_surface),
			"stack_index": 0,
			"frozen_transform": Transform3D.IDENTITY,
		},
		"entry_0001": {
			"surface_id": &"MainDeck",
			"cell_origin": Vector2i(20, 10),
			"quarter_turns": 0,
			"stack_group_id": "MainDeck:stack_0000",
			"stack_index": 0,
			"frozen_transform": Transform3D.IDENTITY,
		},
	}


func _two_fixture_placements() -> Dictionary:
	var placements := _placements(&"Crate_00")
	placements["entry_0001"]["surface_id"] = &"Crate_01"
	placements["entry_0001"]["cell_origin"] = Vector2i.ZERO
	placements["entry_0001"]["stack_group_id"] = "Crate_01:stack_0000"
	return placements


func _test_fixture_modes_preserve_exact_content() -> void:
	var batches: Array[LootBatch] = []
	var diagnostics_by_mode: Array = []
	for mode: int in [
		DeckPlannerScript.FixtureMode.BARE,
		DeckPlannerScript.FixtureMode.CRATES_ALLOWED,
		DeckPlannerScript.FixtureMode.PALLETS_ALLOWED,
		DeckPlannerScript.FixtureMode.MIXED,
	]:
		var batch: LootBatch = PrototypeLootSourceScript.new().generate_committed_batch(
			PersistentItemCatalog, PrototypePool, "mode_batch", 1842, 9001, 24
		)
		_check(batch != null, "representative exact batch generates")
		if batch == null:
			return
		var result = DeckPlannerScript.new().prepare(batch, PersistentItemCatalog, ProofProfile, mode)
		_check(result.succeeded, "fixture proof mode %d plans" % mode)
		batches.append(batch)
		diagnostics_by_mode.append(result)
	var expected_content := _content_signature(batches[0])
	for batch: LootBatch in batches:
		_check(_content_signature(batch) == expected_content, "fixture mode changes presentation only")
	_check(batches[0].presentation_fixtures.is_empty(), "bare mode creates no fixtures")
	_check(not batches[1].presentation_fixtures.is_empty(), "representative crate mode activates demand-driven crates")
	_check(not batches[2].presentation_fixtures.is_empty(), "representative pallet mode activates demand-driven pallets")
	_check(not batches[3].presentation_fixtures.is_empty(), "representative mixed mode activates demand-driven fixtures")
	for fixture in batches[1].presentation_fixtures:
		_check(fixture.family == 0, "crate mode creates no pallets")
	for fixture in batches[2].presentation_fixtures:
		_check(fixture.family == 1, "pallet mode creates no crates")
	_check(diagnostics_by_mode[3].fixture_ids.size() == batches[3].presentation_fixtures.size(), "diagnostics report committed fixture IDs")
	_check(diagnostics_by_mode[3].crate_count <= 3 and diagnostics_by_mode[3].pallet_count <= 2, "diagnostics report enforced family limits")
	_assert_unique_fixture_assets_and_clear_bases(batches[3])

	var repeated: LootBatch = PrototypeLootSourceScript.new().generate_committed_batch(
		PersistentItemCatalog, PrototypePool, "mode_batch", 1842, 9001, 24
	)
	var repeated_result = DeckPlannerScript.new().prepare(
		repeated, PersistentItemCatalog, ProofProfile, DeckPlannerScript.FixtureMode.MIXED
	)
	_check(repeated_result.succeeded, "repeated mixed batch plans")
	_check(_fixture_signature(repeated) == _fixture_signature(batches[3]), "same seed selects the same definitions and sockets")
	var alternate: LootBatch = PrototypeLootSourceScript.new().generate_committed_batch(
		PersistentItemCatalog, PrototypePool, "mode_batch", 1842, 9002, 24
	)
	var alternate_result = DeckPlannerScript.new().prepare(
		alternate, PersistentItemCatalog, ProofProfile, DeckPlannerScript.FixtureMode.MIXED
	)
	_check(alternate_result.succeeded, "alternate-seed mixed batch plans")
	_check(_fixture_signature(alternate) != _fixture_signature(batches[3]), "representative alternate seed can select another valid fixture composition")


func _content_signature(batch: LootBatch) -> Array:
	var result: Array = [
		batch.batch_id, batch.target_bulk, batch.actual_bulk, batch.content_seed,
	]
	for entry: LootBatchEntry in batch.entries:
		result.append([entry.entry_id, entry.item_instance_id, entry.definition_id])
	return result


func _fixture_signature(batch: LootBatch) -> Array:
	var result: Array = []
	for fixture in batch.presentation_fixtures:
		result.append([fixture.surface_id, fixture.fixture_definition_id, fixture.socket_id])
	return result


func _assert_unique_fixture_assets_and_clear_bases(batch: LootBatch) -> void:
	var definition_keys: Dictionary = {}
	var fixture_rects: Array[Rect2i] = []
	for fixture in batch.presentation_fixtures:
		var key := "%d:%s" % [fixture.family, String(fixture.fixture_definition_id)]
		_check(not definition_keys.has(key), "fixture definitions are selected without replacement per family")
		definition_keys[key] = true
		var rect := Rect2i(fixture.main_deck_origin, fixture.base_footprint)
		for other: Rect2i in fixture_rects:
			_check(not rect.intersects(other), "fixture base reservations do not overlap")
		fixture_rects.append(rect)
	for entry: LootBatchEntry in batch.entries:
		if entry.presentation_surface_id != &"MainDeck" or entry.presentation_stack_index != 0:
			continue
		var item := batch.create_item_instance(entry.entry_id, PersistentItemCatalog)
		var measured := DeckPoseScript.measure_item(item, entry.presentation_quarter_turns)
		var item_rect := Rect2i(entry.presentation_cell_origin, measured["footprint"] as Vector2i)
		for fixture_rect: Rect2i in fixture_rects:
			_check(not item_rect.intersects(fixture_rect), "MainDeck item base cannot occupy reserved fixture cells")


func _test_lazy_activation_and_surface_preferences() -> void:
	var eligible := _controlled_batch("eligible", [&"loot_000022", &"loot_000022"])
	var eligible_result = DeckPlannerScript.new().prepare(
		eligible, PersistentItemCatalog, ProofProfile, DeckPlannerScript.FixtureMode.CRATES_ALLOWED
	)
	_check(eligible_result.succeeded, "eligible Small controls plan in crate mode")
	_check(eligible.presentation_fixtures.size() == 1, "second crate stays inactive while first crate accepts the current item")
	for entry: LootBatchEntry in eligible.entries:
		_check(String(entry.presentation_surface_id).begins_with("Crate_"), "eligible Small prefers crate")

	for blacklisted_id: StringName in [&"loot_000001", &"loot_000025", &"loot_000030"]:
		var blacklisted := _controlled_batch("blacklisted_%s" % String(blacklisted_id), [blacklisted_id])
		var result = DeckPlannerScript.new().prepare(
			blacklisted, PersistentItemCatalog, ProofProfile, DeckPlannerScript.FixtureMode.CRATES_ALLOWED
		)
		_check(result.succeeded, "blacklisted Small remains present and plans")
		_check(blacklisted.presentation_fixtures.is_empty(), "blacklisted Small alone does not activate crate")
		_check(blacklisted.entries[0].presentation_surface_id == &"MainDeck", "blacklisted Small uses MainDeck fallback")
	var small_pallet_fallback := _controlled_batch("small_pallet_fallback", [&"loot_000001"])
	var small_pallet_result = DeckPlannerScript.new().prepare(
		small_pallet_fallback, PersistentItemCatalog, ProofProfile,
		DeckPlannerScript.FixtureMode.PALLETS_ALLOWED
	)
	_check(small_pallet_result.succeeded, "Small pallet-fallback control plans")
	_check(small_pallet_fallback.presentation_fixtures.is_empty(), "Small does not activate pallet while MainDeck accepts it")
	_check(small_pallet_fallback.entries[0].presentation_surface_id == &"MainDeck", "Small pallet fallback keeps MainDeck preference")

	var medium := _controlled_batch("medium", [&"loot_000005"])
	var medium_result = DeckPlannerScript.new().prepare(
		medium, PersistentItemCatalog, ProofProfile, DeckPlannerScript.FixtureMode.PALLETS_ALLOWED
	)
	_check(medium_result.succeeded, "Medium control plans")
	_check(medium.presentation_fixtures.is_empty(), "Medium does not activate pallet while MainDeck accepts it")
	_check(medium.entries[0].presentation_surface_id == &"MainDeck", "Medium prefers MainDeck")

	var large := _controlled_batch("large", [&"loot_000014", &"loot_000013"])
	var large_result = DeckPlannerScript.new().prepare(
		large, PersistentItemCatalog, ProofProfile, DeckPlannerScript.FixtureMode.PALLETS_ALLOWED
	)
	_check(large_result.succeeded, "Large controls plan")
	_check(large.presentation_fixtures.size() == 1, "second pallet stays inactive while first pallet accepts the current item")
	for entry: LootBatchEntry in large.entries:
		_check(String(entry.presentation_surface_id).begins_with("Pallet_"), "Large prefers pallet")


func _test_large_priority_preserves_non_large_positions() -> void:
	var ids: Array[StringName] = [
		&"loot_000022", # Small
		&"loot_000013", # Large 4x1
		&"loot_000005", # Medium 3x1
		&"loot_000014", # Large 6x4
		&"loot_000026", # Small
	]
	var batch := _controlled_batch("priority", ids)
	var reordered := batch.entries
	DeckPlannerScript.new().call(
		"_prioritize_large_positions", reordered, batch, PersistentItemCatalog, 9001
	)
	var reordered_ids: Array[StringName] = []
	for entry: LootBatchEntry in reordered:
		reordered_ids.append(entry.definition_id)
	_check(
		reordered_ids == [&"loot_000022", &"loot_000014", &"loot_000005", &"loot_000013", &"loot_000026"],
		"bulky Large moves ahead only within pre-existing Large positions"
	)


func _controlled_batch(batch_id: String, definition_ids: Array[StringName]) -> LootBatch:
	var entries: Array[LootBatchEntry] = []
	for index: int in range(definition_ids.size()):
		entries.append(LootBatchEntryScript.new(
			"entry_%04d" % index,
			"%s:item_%04d" % [batch_id, index],
			definition_ids[index]
		))
	return LootBatchScript.create_committed(
		batch_id, &"test", "controlled", definition_ids.size(), definition_ids.size(),
		1842, 9001, entries
	)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	var caller: Dictionary = get_stack()[1]
	push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
