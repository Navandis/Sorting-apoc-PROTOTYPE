extends SceneTree

const ItemCatalogScript = preload("res://item_catalog.gd")
const ItemDefinitionScript = preload("res://item_definition.gd")
const LootBatchScript = preload("res://receiving/loot_batch.gd")
const PrototypeLootPoolScript = preload("res://receiving/prototype_loot_pool.gd")
const PrototypeLootSourceScript = preload("res://receiving/prototype_loot_source.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypePool = preload("res://data/receiving/prototype_loot_pool.tres")


func _init() -> void:
	_test_same_seed_produces_same_ordered_content()
	_test_batch_identity_changes_only_item_instance_ids()
	_test_bulk_budget_has_strictly_bounded_overshoot()
	_test_generated_content_stays_in_explicit_pool()
	_test_generated_identity_is_ordered_and_provenance_defaults_to_pool()
	_test_invalid_inputs_are_rejected_before_commitment()
	print("PASS: receiving prototype loot source tests")
	quit(0)


func _source() -> PrototypeLootSource:
	return PrototypeLootSourceScript.new()


func _generate(batch_id: String) -> LootBatch:
	return _source().generate_committed_batch(
		PersistentItemCatalog,
		PrototypePool,
		batch_id,
		1842,
		9001,
		24
	)


# Catches generation that uses global RNG state, changes pool sampling order,
# or fails to commit the summed Bulk stored with the generated definitions.
func _test_same_seed_produces_same_ordered_content() -> void:
	var first: LootBatch = _generate("batch_a")
	var second: LootBatch = _generate("batch_a")
	assert(first != null)
	assert(second != null)
	assert(_definition_sequence(first) == _definition_sequence(second))
	assert(first.actual_bulk == second.actual_bulk)
	assert(first.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)
	assert(second.preparation_state == LootBatchScript.STATE_CONTENT_COMMITTED)


# Catches accidental coupling of content sampling to batch identity or reused
# durable item-instance identities across separately committed batches.
func _test_batch_identity_changes_only_item_instance_ids() -> void:
	var first: LootBatch = _generate("batch_a")
	var second: LootBatch = _generate("batch_b")
	assert(_definition_sequence(first) == _definition_sequence(second))
	assert(first.actual_bulk == second.actual_bulk)
	assert(first.entries.size() == second.entries.size())
	assert(first.entries[0].item_instance_id != second.entries[0].item_instance_id)
	for ordinal: int in first.entries.size():
		assert(first.entries[ordinal].item_instance_id == "batch_a:item_%04d" % ordinal)
		assert(second.entries[ordinal].item_instance_id == "batch_b:item_%04d" % ordinal)


# Catches stopping below the requested budget or sampling after the first item
# that reaches it. Positive integral Bulk makes max_bulk - 1 the true ceiling.
func _test_bulk_budget_has_strictly_bounded_overshoot() -> void:
	var batch: LootBatch = _generate("batch_bulk")
	var max_bulk: int = 0
	for definition: ItemDefinition in PrototypePool.resolve_definitions(PersistentItemCatalog):
		max_bulk = maxi(max_bulk, definition.bulk)
	assert(batch.actual_bulk >= 24)
	assert(batch.actual_bulk - 24 < max_bulk)
	assert(_summed_bulk(batch) == batch.actual_bulk)


# Catches generation from the full catalog or any implicit source other than
# the deliberately reviewed forty-definition prototype receiving pool.
func _test_generated_content_stays_in_explicit_pool() -> void:
	var batch: LootBatch = _generate("batch_pool")
	assert(PrototypePool.item_definition_ids.size() == 40)
	for definition_id: StringName in _definition_sequence(batch):
		assert(PrototypePool.item_definition_ids.has(definition_id))


# Catches unstable ordinal formatting and loss of the default pool revision
# provenance needed to explain persisted prototype batches.
func _test_generated_identity_is_ordered_and_provenance_defaults_to_pool() -> void:
	var batch: LootBatch = _generate("batch_identity")
	assert(batch.source_kind == &"prototype")
	assert(batch.source_ref == "prototype_receiving_pool:1")
	assert(batch.content_seed == 1842)
	assert(batch.presentation_seed == 9001)
	assert(batch.target_bulk == 24)
	for ordinal: int in batch.entries.size():
		assert(batch.entries[ordinal].entry_id == "entry_%04d" % ordinal)
		assert(
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
	assert(explicit_ref.source_ref == "manual_debug_source")


# Catches validation after generation/commitment, unresolved catalog members,
# empty pools, and non-positive Bulk values that would defeat loop termination.
func _test_invalid_inputs_are_rejected_before_commitment() -> void:
	var source: PrototypeLootSource = _source()
	assert(source.generate_committed_batch(
		PersistentItemCatalog, PrototypePool, "batch", 1, 2, 0
	) == null)
	assert(source.generate_committed_batch(
		PersistentItemCatalog, PrototypePool, "batch", 1, 2, -1
	) == null)
	assert(source.generate_committed_batch(
		PersistentItemCatalog, PrototypePool, "", 1, 2, 1
	) == null)
	assert(source.generate_committed_batch(
		null, PrototypePool, "batch", 1, 2, 1
	) == null)
	assert(source.generate_committed_batch(
		PersistentItemCatalog, null, "batch", 1, 2, 1
	) == null)

	var empty_pool: PrototypeLootPool = PrototypeLootPoolScript.new()
	assert(source.generate_committed_batch(
		PersistentItemCatalog, empty_pool, "batch", 1, 2, 1
	) == null)

	var unresolved_pool: PrototypeLootPool = PrototypeLootPoolScript.new()
	unresolved_pool.item_definition_ids = [&"does_not_exist"]
	assert(source.generate_committed_batch(
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
	assert(source.generate_committed_batch(
		zero_bulk_catalog, zero_bulk_pool, "batch", 1, 2, 1
	) == null)


func _definition_sequence(batch: LootBatch) -> Array[StringName]:
	var result: Array[StringName] = []
	for entry: LootBatchEntry in batch.entries:
		result.append(entry.definition_id)
	return result


func _summed_bulk(batch: LootBatch) -> int:
	var result: int = 0
	for entry: LootBatchEntry in batch.entries:
		var definition: ItemDefinition = PersistentItemCatalog.get_definition_by_id(
			entry.definition_id
		)
		result += definition.bulk
	return result
