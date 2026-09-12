extends SceneTree

const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const PrototypePool = preload("res://data/receiving/prototype_loot_pool.tres")


func _init() -> void:
	assert(PrototypePool.pool_id == &"prototype_receiving_pool")
	assert(PrototypePool.revision == 1)
	assert(PrototypePool.item_definition_ids.size() == 40)
	assert(not PrototypePool.item_definition_ids.has(&"loot_000034"))
	assert(not PrototypePool.item_definition_ids.has(&"loot_000036"))
	assert(PrototypePool.validate_against_catalog(PersistentItemCatalog).is_empty())
	assert(PrototypePool.resolve_definitions(PersistentItemCatalog).size() == 40)
	assert((PersistentItemCatalog.get("definitions") as Array).size() == 42)
	_assert_exact_expected_ids()
	print("PASS: receiving prototype loot pool tests")
	quit(0)


# Catches a pool membership regression such as accidentally including Gloves
# or Pants, omitting a catalog item, or reordering the intentional sequence.
func _assert_exact_expected_ids() -> void:
	var expected_ids: Array[StringName] = [
		&"loot_000001", &"loot_000002", &"loot_000003", &"loot_000004",
		&"loot_000005", &"loot_000006", &"loot_000007", &"loot_000008",
		&"loot_000009", &"loot_000010", &"loot_000011", &"loot_000012",
		&"loot_000013", &"loot_000014", &"loot_000015", &"loot_000016",
		&"loot_000017", &"loot_000018", &"loot_000019", &"loot_000020",
		&"loot_000021", &"loot_000022", &"loot_000023", &"loot_000024",
		&"loot_000025", &"loot_000026", &"loot_000027", &"loot_000028",
		&"loot_000029", &"loot_000030", &"loot_000031", &"loot_000032",
		&"loot_000033", &"loot_000035", &"loot_000037", &"loot_000038",
		&"loot_000039", &"loot_000040", &"loot_000041", &"loot_000042",
	]
	assert(PrototypePool.item_definition_ids == expected_ids)
