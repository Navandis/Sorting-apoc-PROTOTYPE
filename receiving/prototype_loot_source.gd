extends RefCounted
class_name PrototypeLootSource

const LootBatchScript = preload("res://receiving/loot_batch.gd")
const LootBatchEntryScript = preload("res://receiving/loot_batch_entry.gd")


func generate_committed_batch(
	catalog: ItemCatalog,
	pool: PrototypeLootPool,
	batch_id: String,
	content_seed: int,
	presentation_seed: int,
	target_bulk: int,
	source_kind: StringName = &"prototype",
	source_ref: String = "debug"
) -> LootBatch:
	if catalog == null or pool == null or batch_id.is_empty() or target_bulk <= 0:
		return null
	if not catalog.get_validation_errors().is_empty():
		return null
	if pool.pool_id == &"" or pool.revision <= 0:
		return null

	var definitions: Array[ItemDefinition] = pool.resolve_definitions(catalog)
	if definitions.is_empty():
		return null
	var max_bulk: int = 0
	for definition: ItemDefinition in definitions:
		if definition == null or definition.bulk <= 0:
			return null
		max_bulk = maxi(max_bulk, definition.bulk)

	var rng := RandomNumberGenerator.new()
	rng.seed = content_seed
	var entries: Array[LootBatchEntry] = []
	var actual_bulk: int = 0
	var ordinal: int = 0
	var maximum_ordinal: int = target_bulk + max_bulk
	while actual_bulk < target_bulk and ordinal < maximum_ordinal:
		var definition: ItemDefinition = definitions[
			rng.randi_range(0, definitions.size() - 1)
		]
		var entry_id := "entry_%04d" % ordinal
		var item_id := "%s:item_%04d" % [batch_id, ordinal]
		entries.append(LootBatchEntryScript.new(entry_id, item_id, definition.item_id))
		actual_bulk += definition.bulk
		ordinal += 1
	if actual_bulk < target_bulk:
		return null

	var committed_source_ref: String = source_ref
	if source_ref == "debug":
		committed_source_ref = "%s:%d" % [String(pool.pool_id), pool.revision]
	return LootBatchScript.create_committed(
		batch_id,
		source_kind,
		committed_source_ref,
		target_bulk,
		actual_bulk,
		content_seed,
		presentation_seed,
		entries
	)
