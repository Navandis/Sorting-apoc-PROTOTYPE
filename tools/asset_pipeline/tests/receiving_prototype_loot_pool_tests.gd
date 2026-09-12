extends SceneTree

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
		print("FAIL: receiving prototype loot pool tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving prototype loot pool tests")
	quit(0)


func _run_suite() -> void:
	_pending_helpers += 1
	_check(PrototypePool.pool_id == &"prototype_receiving_pool")
	_check(PrototypePool.revision == 1)
	_check(PrototypePool.item_definition_ids.size() == 40)
	_check(not PrototypePool.item_definition_ids.has(&"loot_000034"))
	_check(not PrototypePool.item_definition_ids.has(&"loot_000036"))
	_check(PrototypePool.validate_against_catalog(PersistentItemCatalog).is_empty())
	_check(PrototypePool.resolve_definitions(PersistentItemCatalog).size() == 40)
	_check((PersistentItemCatalog.get("definitions") as Array).size() == 42)
	_assert_exact_expected_ids()
	_pending_helpers -= 1


# Catches a pool membership regression such as accidentally including Gloves
# or Pants, omitting a catalog item, or reordering the intentional sequence.
func _assert_exact_expected_ids() -> void:
	_pending_helpers += 1
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
	_check(PrototypePool.item_definition_ids == expected_ids)
	_pending_helpers -= 1


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition
