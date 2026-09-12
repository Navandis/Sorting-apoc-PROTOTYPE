extends SceneTree

const ItemCatalogScript = preload("res://item_catalog.gd")
const ItemDefinitionScript = preload("res://item_definition.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const PrototypeLootPoolScript = preload("res://receiving/prototype_loot_pool.gd")
const PrototypeLootSourceScript = preload("res://receiving/prototype_loot_source.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypePool = preload("res://data/receiving/prototype_loot_pool.tres")



# A runtime abort can return from a helper to its caller in Godot. Every
# test or fixture helper stays pending until its final statement is reached.
var _failures: int = 0
var _pending_helpers: int = 0


func _init() -> void:
	_run_suite()
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving prototype loot source tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving prototype loot source tests")
	quit(0)


func _run_suite() -> void:
	_pending_helpers += 1
	_test_same_seed_produces_same_ordered_content()
	_test_batch_identity_changes_only_item_instance_ids()
	_test_bulk_budget_has_strictly_bounded_overshoot()
	_test_generated_content_stays_in_explicit_pool()
	_test_generated_identity_is_ordered_and_provenance_defaults_to_pool()
	_test_invalid_inputs_are_rejected_before_commitment()
	_test_invalid_catalog_with_resolvable_pool_member_is_rejected()
	_pending_helpers -= 1


func _source() -> PrototypeLootSource:
	_pending_helpers += 1
	var completed_result: PrototypeLootSource = PrototypeLootSourceScript.new()
	_pending_helpers -= 1
	return completed_result


func _generate(batch_id: String) -> LootBatch:
	_pending_helpers += 1
	var completed_result: LootBatch = _source().generate_committed_batch(
		PersistentItemCatalog,
		PrototypePool,
		batch_id,
		1842,
		9001,
		24
	)
	_pending_helpers -= 1
	return completed_result


# Catches generation that uses global RNG state, changes pool sampling order,
# or fails to commit the summed Bulk stored with the generated definitions.
func _test_same_seed_produces_same_ordered_content() -> void:
	_pending_helpers += 1
	var first: LootBatch = _generate("batch_a")
	var second: LootBatch = _generate("batch_a")
	_check(first != null)
	_check(second != null)
	_check(_definition_sequence(first) == _definition_sequence(second))
	_check(first.actual_bulk == second.actual_bulk)
	_check(first.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	_check(second.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	_pending_helpers -= 1


# Catches accidental coupling of content sampling to batch identity or reused
# durable item-instance identities across separately committed batches.
func _test_batch_identity_changes_only_item_instance_ids() -> void:
	_pending_helpers += 1
	var first: LootBatch = _generate("batch_a")
	var second: LootBatch = _generate("batch_b")
	_check(_definition_sequence(first) == _definition_sequence(second))
	_check(first.actual_bulk == second.actual_bulk)
	_check(first.entries.size() == second.entries.size())
	_check(first.entries[0].item_instance_id != second.entries[0].item_instance_id)
	for ordinal: int in first.entries.size():
		_check(first.entries[ordinal].item_instance_id == "batch_a:item_%04d" % ordinal)
		_check(second.entries[ordinal].item_instance_id == "batch_b:item_%04d" % ordinal)
	_pending_helpers -= 1


# Catches stopping below the requested budget or sampling after the first item
# that reaches it. Positive integral Bulk makes max_bulk - 1 the true ceiling.
func _test_bulk_budget_has_strictly_bounded_overshoot() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _generate("batch_bulk")
	var max_bulk: int = 0
	for definition: ItemDefinition in PrototypePool.resolve_definitions(PersistentItemCatalog):
		max_bulk = maxi(max_bulk, definition.bulk)
	_check(batch.actual_bulk >= 24)
	_check(batch.actual_bulk - 24 < max_bulk)
	_check(_summed_bulk(batch) == batch.actual_bulk)
	_pending_helpers -= 1


# Catches generation from the full catalog or any implicit source other than
# the deliberately reviewed forty-definition prototype receiving pool.
func _test_generated_content_stays_in_explicit_pool() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _generate("batch_pool")
	_check(PrototypePool.item_definition_ids.size() == 40)
	for definition_id: StringName in _definition_sequence(batch):
		_check(PrototypePool.item_definition_ids.has(definition_id))
	_pending_helpers -= 1


# Catches unstable ordinal formatting and loss of the default pool revision
# provenance needed to explain persisted prototype batches.
func _test_generated_identity_is_ordered_and_provenance_defaults_to_pool() -> void:
	_pending_helpers += 1
	var batch: LootBatch = _generate("batch_identity")
	_check(batch.source_kind == &"prototype")
	_check(batch.source_ref == "prototype_receiving_pool:1")
	_check(batch.content_seed == 1842)
	_check(batch.presentation_seed == 9001)
	_check(batch.target_bulk == 24)
	for ordinal: int in batch.entries.size():
		_check(batch.entries[ordinal].entry_id == "entry_%04d" % ordinal)
		_check(
			batch.entries[ordinal].item_instance_id
			== "batch_identity:item_%04d" % ordinal
		)

	var explicit_ref: LootBatch = _source().generate_committed_batch(
		PersistentItemCatalog,
		PrototypePool,
		"batch_explicit_ref",
		1842,
		9001,
		24,
		&"prototype",
		"manual_debug_source"
	)
	_check(explicit_ref.source_ref == "manual_debug_source")
	_pending_helpers -= 1


# Catches validation after generation/commitment, unresolved catalog members,
# empty pools, and non-positive Bulk values that would defeat loop termination.
func _test_invalid_inputs_are_rejected_before_commitment() -> void:
	_pending_helpers += 1
	var source: PrototypeLootSource = _source()
	_check(source.generate_committed_batch(
		PersistentItemCatalog, PrototypePool, "batch", 1, 2, 0
	) == null)
	_check(source.generate_committed_batch(
		PersistentItemCatalog, PrototypePool, "batch", 1, 2, -1
	) == null)
	_check(source.generate_committed_batch(
		PersistentItemCatalog, PrototypePool, "", 1, 2, 1
	) == null)
	_check(source.generate_committed_batch(
		null, PrototypePool, "batch", 1, 2, 1
	) == null)
	_check(source.generate_committed_batch(
		PersistentItemCatalog, null, "batch", 1, 2, 1
	) == null)

	var empty_pool: PrototypeLootPool = PrototypeLootPoolScript.new()
	_check(source.generate_committed_batch(
		PersistentItemCatalog, empty_pool, "batch", 1, 2, 1
	) == null)

	var unresolved_pool: PrototypeLootPool = PrototypeLootPoolScript.new()
	unresolved_pool.item_definition_ids = [&"does_not_exist"]
	_check(source.generate_committed_batch(
		PersistentItemCatalog, unresolved_pool, "batch", 1, 2, 1
	) == null)

	var zero_bulk_definition: ItemDefinition = ItemDefinitionScript.new()
	zero_bulk_definition.item_id = &"zero_bulk"
	zero_bulk_definition.bulk = 0
	zero_bulk_definition.visual_scene = PersistentItemCatalog.get_definition_by_id(
		&"loot_000001"
	).visual_scene
	var zero_bulk_catalog: ItemCatalog = ItemCatalogScript.new()
	zero_bulk_catalog.set_definitions([zero_bulk_definition])
	var zero_bulk_pool: PrototypeLootPool = PrototypeLootPoolScript.new()
	zero_bulk_pool.item_definition_ids = [&"zero_bulk"]
	_check(source.generate_committed_batch(
		zero_bulk_catalog, zero_bulk_pool, "batch", 1, 2, 1
	) == null)
	_pending_helpers -= 1


# Catches validating only selected pool IDs while ignoring catalog-wide
# authoring errors that leave those IDs individually resolvable.
func _test_invalid_catalog_with_resolvable_pool_member_is_rejected() -> void:
	_pending_helpers += 1
	var shared_visual: PackedScene = PersistentItemCatalog.get_definition_by_id(
		&"loot_000001"
	).visual_scene
	var selected_definition: ItemDefinition = ItemDefinitionScript.new()
	selected_definition.item_id = &"selected_definition"
	selected_definition.visual_scene = shared_visual
	var conflicting_definition: ItemDefinition = ItemDefinitionScript.new()
	conflicting_definition.item_id = &"conflicting_definition"
	conflicting_definition.visual_scene = shared_visual
	var invalid_catalog: ItemCatalog = ItemCatalogScript.new()
	invalid_catalog.set_definitions([selected_definition, conflicting_definition])
	_check(
		invalid_catalog.get_definition_by_id(&"selected_definition") != null,
		"invalid catalog fixture keeps the selected pool member resolvable"
	)
	_check(
		not invalid_catalog.get_validation_errors().is_empty(),
		"invalid catalog fixture reports a catalog-wide validation error"
	)

	var resolvable_pool: PrototypeLootPool = PrototypeLootPoolScript.new()
	resolvable_pool.item_definition_ids = [&"selected_definition"]
	_check(
		_source().generate_committed_batch(
			invalid_catalog, resolvable_pool, "batch_invalid_catalog", 1, 2, 1
		) == null,
		"catalog-wide validation errors prevent generation"
	)
	_pending_helpers -= 1


func _definition_sequence(batch: LootBatch) -> Array[StringName]:
	_pending_helpers += 1
	var result: Array[StringName] = []
	for entry: LootBatchEntry in batch.entries:
		result.append(entry.definition_id)
	var completed_result: Array[StringName] = result
	_pending_helpers -= 1
	return completed_result


func _summed_bulk(batch: LootBatch) -> int:
	_pending_helpers += 1
	var result: int = 0
	for entry: LootBatchEntry in batch.entries:
		var definition: ItemDefinition = PersistentItemCatalog.get_definition_by_id(
			entry.definition_id
		)
		result += definition.bulk
	var completed_result: int = result
	_pending_helpers -= 1
	return completed_result


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition
