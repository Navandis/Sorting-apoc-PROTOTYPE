extends SceneTree

const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const DeckProfileScript = preload("res://receiving/receiving_deck_profile.gd")
const DeckPoseScript = preload("res://receiving/receiving_deck_item_pose.gd")
const DeckPlannerScript = preload("res://receiving/receiving_deck_layout_planner.gd")
const DeckSurfaceSpecScript = preload("res://receiving/receiving_deck_surface_spec.gd")
const PrototypeLootSourceScript = preload("res://receiving/prototype_loot_source.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypePool = preload("res://data/receiving/prototype_loot_pool.tres")
const ProofProfile = preload("res://data/receiving/receiving_deck_stage_b_proof.tres")

var _failures: int = 0
var _pending_helpers: int = 0


func _init() -> void:
	_run_suite()
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving deck layout tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving deck layout tests")
	quit(0)


func _run_suite() -> void:
	_pending_helpers += 1
	_test_legacy_entry_snapshot_restores_deck_defaults()
	_test_deck_snapshot_round_trip_and_atomic_commit()
	_test_generic_arrangement_remains_valid()
	_test_proof_profile_is_exact_30_by_20()
	_test_four_quarter_turns_preserve_two_physical_footprints()
	_test_same_seed_reproduces_and_alternate_seed_changes_only_layout()
	_test_front_to_rear_scan_starts_at_frontmost_legal_row()
	_test_legal_append_stack_and_incompatible_fallback()
	_test_capacity_failure_is_explicit_and_byte_atomic()
	_pending_helpers -= 1


func _entries() -> Array[LootBatchEntry]:
	_pending_helpers += 1
	var result: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("entry_0000", "deck_batch:item_0000", &"loot_000001"),
		LootBatchEntryScript.new("entry_0001", "deck_batch:item_0001", &"loot_000002"),
	]
	_pending_helpers -= 1
	return result


func _batch() -> LootBatch:
	_pending_helpers += 1
	var result: LootBatch = LootBatchScript.create_committed(
		"deck_batch", &"prototype", "prototype_receiving_pool:1",
		5, 6, 1842, 9001, _entries()
	)
	_pending_helpers -= 1
	return result


func _placements() -> Dictionary:
	_pending_helpers += 1
	var result: Dictionary = {
		"entry_0000": {
			"surface_id": &"MainDeck",
			"cell_origin": Vector2i(2, 18),
			"quarter_turns": 0,
			"stack_group_id": "MainDeck:stack_0000",
			"stack_index": 0,
			"frozen_transform": Transform3D(Basis.IDENTITY, Vector3(-1.25, 0.012, 0.85)),
		},
		"entry_0001": {
			"surface_id": "MainDeck",
			"cell_origin": Vector2i(2, 18),
			"quarter_turns": 5,
			"stack_group_id": "MainDeck:stack_0000",
			"stack_index": 1,
			"frozen_transform": Transform3D(Basis.IDENTITY, Vector3(-1.25, 0.22, 0.85)),
		},
	}
	_pending_helpers -= 1
	return result


func _test_legacy_entry_snapshot_restores_deck_defaults() -> void:
	_pending_helpers += 1
	var legacy: Dictionary = LootBatchEntryScript.new(
		"entry_legacy", "legacy:item", &"loot_000001"
	).to_snapshot()
	for key: String in [
		"has_deck_layout", "presentation_surface_id", "presentation_cell_origin",
		"presentation_quarter_turns", "presentation_stack_group_id",
		"presentation_stack_index",
	]:
		legacy.erase(key)
	var restored: LootBatchEntry = LootBatchEntryScript.from_snapshot(legacy)
	_check(restored != null, "historical entry snapshot reconstructs")
	if restored != null:
		_check(not restored.has_deck_layout, "legacy entry has no deck layout")
		_check(restored.presentation_surface_id == &"", "legacy surface defaults empty")
		_check(restored.presentation_cell_origin == Vector2i(-1, -1), "legacy cell defaults invalid")
		_check(restored.presentation_quarter_turns == 0, "legacy quarter turn defaults zero")
		_check(restored.presentation_stack_group_id == "", "legacy group defaults empty")
		_check(restored.presentation_stack_index == -1, "legacy stack index defaults invalid")
	_pending_helpers -= 1


func _test_deck_snapshot_round_trip_and_atomic_commit() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var original_bytes: PackedByteArray = var_to_bytes(batch.to_snapshot())
	var invalid: Dictionary = _placements()
	invalid["entry_0001"]["stack_index"] = 2
	_check(not batch.commit_deck_layout(invalid, &"receiving_deck_stage_b_proof", 1), "non-contiguous stack indices rejected")
	_check(var_to_bytes(batch.to_snapshot()) == original_bytes, "failed deck commit is byte-atomic")
	invalid = _placements()
	invalid["entry_0001"]["cell_origin"] = Vector2i(3, 18)
	_check(not batch.commit_deck_layout(invalid, &"receiving_deck_stage_b_proof", 1), "one stable stack group cannot span base cells")
	_check(var_to_bytes(batch.to_snapshot()) == original_bytes, "incoherent group rejection is byte-atomic")

	var content_before: Dictionary = batch.to_snapshot()
	_check(batch.commit_deck_layout(_placements(), &"receiving_deck_stage_b_proof", 1), "complete valid deck layout commits")
	_check(batch.preparation_state == LootBatchScript.STATE_PREPARED, "deck commit prepares batch")
	_check(batch.presentation_profile_id == &"receiving_deck_stage_b_proof", "profile ID committed")
	var committed_entries: Array[LootBatchEntry] = batch.entries
	_check(committed_entries[0].has_deck_layout and committed_entries[1].has_deck_layout, "all remaining entries receive deck metadata")
	_check(committed_entries[1].presentation_surface_id == &"MainDeck", "surface ID normalized")
	_check(committed_entries[1].presentation_quarter_turns == 1, "quarter turns normalized to 0..3")
	_check(committed_entries[1].presentation_stack_group_id == "MainDeck:stack_0000", "stable group committed")
	_check(committed_entries[1].presentation_stack_index == 1, "stable stack order committed")
	for key: String in ["batch_id", "source_kind", "source_ref", "target_bulk", "actual_bulk", "content_seed", "presentation_seed"]:
		_check(batch.to_snapshot()[key] == content_before[key], "layout preserves content field " + key)

	var bytes: PackedByteArray = var_to_bytes(batch.to_snapshot())
	var restored: LootBatch = LootBatchScript.from_snapshot(bytes_to_var(bytes) as Dictionary)
	_check(restored != null, "deck snapshot reconstructs")
	if restored != null:
		_check(var_to_bytes(restored.to_snapshot()) == bytes, "deck snapshot round-trips byte-identically")
	var malformed_group: Dictionary = batch.to_snapshot().duplicate(true)
	var malformed_entries: Array = malformed_group["entries"] as Array
	(malformed_entries[1] as Dictionary)["presentation_stack_index"] = 0
	_check(LootBatchScript.from_snapshot(malformed_group) == null, "persisted deck group rejects duplicate stack indices")
	_pending_helpers -= 1


func _test_generic_arrangement_remains_valid() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _batch()
	var transforms: Dictionary = {
		"entry_0000": Transform3D(Basis.IDENTITY, Vector3.ZERO),
		"entry_0001": Transform3D(Basis.IDENTITY, Vector3.ONE),
	}
	_check(batch.commit_arrangement(transforms, &"historical_profile", 3), "historical commit path remains accepted")
	for entry: LootBatchEntry in batch.entries:
		_check(entry.has_frozen_transform, "historical arrangement still freezes transforms")
		_check(not entry.has_deck_layout, "historical arrangement does not invent deck metadata")
	_pending_helpers -= 1


func _test_proof_profile_is_exact_30_by_20() -> void:
	_pending_helpers += 1
	_check(ProofProfile.get_script() == DeckProfileScript, "proof resource has deck profile type")
	if ProofProfile.get_script() == DeckProfileScript:
		var profile: Resource = ProofProfile
		_check(profile.validate().is_empty(), "proof profile validates")
		_check(profile.profile_id == &"receiving_deck_stage_b_proof", "proof profile ID")
		_check(profile.revision == 1 and profile.layout_version == 1, "proof profile versions")
		_check(is_equal_approx(profile.cell_size_m, 0.10), "proof cell size")
		_check(profile.max_layout_attempts == 4, "proof attempt bound")
		_check(profile.surfaces.size() == 1, "proof uses one surface")
		var surface = profile.surfaces[0]
		_check(surface.surface_id == &"MainDeck", "proof main surface identity")
		_check(is_equal_approx(surface.usable_width_m, 3.0), "proof width is approved 3.00 m")
		_check(is_equal_approx(surface.usable_depth_m, 2.0), "proof depth is provisional 2.00 m")
		_check(Vector2i(floori(surface.usable_width_m / profile.cell_size_m), floori(surface.usable_depth_m / profile.cell_size_m)) == Vector2i(30, 20), "proof grid is exactly 30 by 20")
		_check(is_equal_approx(surface.stack_clearance_m, 1.5), "proof stack clearance")
	_pending_helpers -= 1


func _test_four_quarter_turns_preserve_two_physical_footprints() -> void:
	_pending_helpers += 1
	var definition: ItemDefinition = PersistentItemCatalog.get_definition_by_id(&"loot_000002")
	var item: ItemInstance = ItemInstance.new(definition, "pose:item")
	var expected: Array[Vector2i] = [
		Vector2i(3, 5), Vector2i(5, 3), Vector2i(3, 5), Vector2i(5, 3),
	]
	for quarter_turns: int in range(4):
		var measured: Dictionary = DeckPoseScript.measure_item(item, quarter_turns)
		_check(bool(measured.get("valid", false)), "quarter turn %d measures real visual" % quarter_turns)
		_check(measured.get("footprint", Vector2i.ZERO) == expected[quarter_turns], "quarter turn %d footprint parity" % quarter_turns)
		_check(int(measured.get("quarter_turns", -1)) == quarter_turns, "quarter turn %d metadata" % quarter_turns)
		_check(bool(measured.get("packing_rotated", false)) == (quarter_turns % 2 == 1), "quarter turn %d delegates odd parity to StorageVisualPose" % quarter_turns)
		_check(is_equal_approx(float(measured.get("outer_yaw_radians", -1.0)), PI if quarter_turns >= 2 else 0.0), "quarter turn %d outer yaw" % quarter_turns)
	_pending_helpers -= 1


func _test_same_seed_reproduces_and_alternate_seed_changes_only_layout() -> void:
	_pending_helpers += 1
	var first: LootBatch = _generated_batch("seeded_batch", 9001)
	var repeated: LootBatch = _generated_batch("seeded_batch", 9001)
	var alternate: LootBatch = _generated_batch("seeded_batch", 9002)
	var first_content: Array = _content_signature(first)
	_check(_content_signature(repeated) == first_content, "same content seed reproduces exact content and identity")
	_check(_content_signature(alternate) == first_content, "presentation seed cannot alter content or identity")
	var first_result = DeckPlannerScript.new().prepare(first, PersistentItemCatalog, ProofProfile)
	var repeated_result = DeckPlannerScript.new().prepare(repeated, PersistentItemCatalog, ProofProfile)
	var alternate_result = DeckPlannerScript.new().prepare(alternate, PersistentItemCatalog, ProofProfile)
	_check(first_result.succeeded and repeated_result.succeeded and alternate_result.succeeded, "representative proof batches all fit")
	_check(_layout_signature(first) == _layout_signature(repeated), "same content/profile/presentation seed reproduces layout")
	_check(_layout_signature(first) != _layout_signature(alternate), "alternate presentation seed changes valid layout")
	_check(_content_signature(first) == first_content and _content_signature(alternate) == first_content, "planning leaves committed content fields unchanged")
	_pending_helpers -= 1


func _test_front_to_rear_scan_starts_at_frontmost_legal_row() -> void:
	_pending_helpers += 1
	var entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("front_entry", "front_batch:item", &"loot_000002"),
	]
	var batch: LootBatch = LootBatchScript.create_committed(
		"front_batch", &"test", "front-scan", 1, 1, 11, 29, entries
	)
	var result = DeckPlannerScript.new().prepare(batch, PersistentItemCatalog, ProofProfile)
	_check(result.succeeded, "single real item plans")
	var entry: LootBatchEntry = batch.entries[0]
	var item: ItemInstance = batch.create_item_instance(entry.entry_id, PersistentItemCatalog)
	var footprint: Vector2i = DeckPoseScript.footprint_for(item, entry.presentation_quarter_turns)
	_check(entry.presentation_cell_origin.y == 20 - footprint.y, "first empty placement uses frontmost legal row")
	_pending_helpers -= 1


func _test_legal_append_stack_and_incompatible_fallback() -> void:
	_pending_helpers += 1
	var stack_entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("flat_a", "stack_batch:a", &"loot_000030"),
		LootBatchEntryScript.new("flat_b", "stack_batch:b", &"loot_000031"),
	]
	var stack_batch: LootBatch = LootBatchScript.create_committed(
		"stack_batch", &"test", "stack", 2, 2, 1, 7, stack_entries
	)
	var stack_result = DeckPlannerScript.new().prepare(stack_batch, PersistentItemCatalog, ProofProfile)
	_check(stack_result.succeeded, "compatible flat-media batch plans")
	var planned_stack: Array[LootBatchEntry] = stack_batch.entries
	_check(planned_stack[0].presentation_stack_group_id == planned_stack[1].presentation_stack_group_id, "coherent supported items append to one stable group")
	var stack_indices: Array[int] = [planned_stack[0].presentation_stack_index, planned_stack[1].presentation_stack_index]
	stack_indices.sort()
	_check(stack_indices == [0, 1], "append-only stack indices are stable and contiguous")

	var incompatible_entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("flat", "fallback_batch:flat", &"loot_000030"),
		LootBatchEntryScript.new("mouse", "fallback_batch:mouse", &"loot_000001"),
	]
	var fallback_batch: LootBatch = LootBatchScript.create_committed(
		"fallback_batch", &"test", "fallback", 2, 2, 1, 7, incompatible_entries
	)
	var fallback_result = DeckPlannerScript.new().prepare(fallback_batch, PersistentItemCatalog, ProofProfile)
	_check(fallback_result.succeeded, "failed append falls back to empty placement")
	_check(fallback_batch.entries[0].presentation_stack_group_id != fallback_batch.entries[1].presentation_stack_group_id, "incompatible/unsupported item is not stacked")
	_check(fallback_batch.entries[0].presentation_stack_index == 0 and fallback_batch.entries[1].presentation_stack_index == 0, "new fallback bases remain base index zero")
	_pending_helpers -= 1


func _test_capacity_failure_is_explicit_and_byte_atomic() -> void:
	_pending_helpers += 1
	var entries: Array[LootBatchEntry] = [
		LootBatchEntryScript.new("too_large_a", "capacity_batch:a", &"loot_000002"),
		LootBatchEntryScript.new("too_large_b", "capacity_batch:b", &"loot_000003"),
	]
	var batch: LootBatch = LootBatchScript.create_committed(
		"capacity_batch", &"test", "capacity", 2, 2, 1, 9, entries
	)
	var before: PackedByteArray = var_to_bytes(batch.to_snapshot())
	var profile: Resource = DeckProfileScript.new()
	profile.set("profile_id", &"tiny_deck")
	profile.set("revision", 1)
	profile.set("layout_version", 1)
	profile.set("cell_size_m", 0.10)
	profile.set("max_layout_attempts", 4)
	var surface: Resource = DeckSurfaceSpecScript.new()
	surface.set("surface_id", &"Tiny")
	surface.set("usable_width_m", 0.10)
	surface.set("usable_depth_m", 0.10)
	surface.set("stack_clearance_m", 1.0)
	var tiny_surfaces: Array[Resource] = [surface]
	profile.set("surfaces", tiny_surfaces)
	var result = DeckPlannerScript.new().prepare(batch, PersistentItemCatalog, profile)
	_check(not result.succeeded, "impossible exact batch fails")
	_check(result.failure_reason == &"insufficient_layout_capacity", "capacity failure is explicit")
	_check(result.attempts_used == 4, "capacity failure consumes only bounded deterministic attempts")
	_check(batch.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED, "failed batch stays committed")
	_check(var_to_bytes(batch.to_snapshot()) == before, "capacity failure leaves batch byte-equivalent")
	_pending_helpers -= 1


func _generated_batch(batch_id: String, presentation_seed: int) -> LootBatch:
	_pending_helpers += 1
	var source: PrototypeLootSource = PrototypeLootSourceScript.new()
	var result: LootBatch = source.generate_committed_batch(
		PersistentItemCatalog, PrototypePool, batch_id, 1842, presentation_seed, 24
	)
	_check(result != null, "generated real prototype batch")
	_pending_helpers -= 1
	return result


func _content_signature(batch: LootBatch) -> Array:
	_pending_helpers += 1
	var result: Array = []
	for entry: LootBatchEntry in batch.entries:
		result.append([entry.entry_id, entry.item_instance_id, entry.definition_id])
	_pending_helpers -= 1
	return result


func _layout_signature(batch: LootBatch) -> Array:
	_pending_helpers += 1
	var result: Array = []
	for entry: LootBatchEntry in batch.entries:
		result.append([
			entry.entry_id,
			entry.presentation_surface_id,
			entry.presentation_cell_origin,
			entry.presentation_quarter_turns,
			entry.presentation_stack_group_id,
			entry.presentation_stack_index,
			entry.frozen_transform,
		])
	_pending_helpers -= 1
	return result


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition
