extends SceneTree

const ItemInstanceScript = preload("res://item_instance.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")

# A runtime abort can return from a helper to its caller in Godot. Every
# test or fixture helper stays pending until its final statement is reached.
var _failures: int = 0
var _pending_helpers: int = 0


func _init() -> void:
	_run_suite()
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving item identity tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving item identity tests")
	quit(0)


func _run_suite() -> void:
	_pending_helpers += 1
	_test_explicit_identity_is_preserved()
	_test_legacy_identity_path_remains_non_empty()
	_test_two_explicit_instances_of_same_definition_remain_distinct()
	_pending_helpers -= 1

func _definition() -> ItemDefinition:
	_pending_helpers += 1
	var completed_result: ItemDefinition = PersistentItemCatalog.get_definition_by_id(&"loot_000001")
	_pending_helpers -= 1
	return completed_result

func _test_explicit_identity_is_preserved() -> void:
	_pending_helpers += 1
	var instance: ItemInstance = ItemInstanceScript.new(
		_definition(),
		"batch_alpha:item_0000"
	)
	_check(instance.instance_id == "batch_alpha:item_0000")
	_check(instance.definition == _definition())
	_pending_helpers -= 1

func _test_legacy_identity_path_remains_non_empty() -> void:
	_pending_helpers += 1
	var first: ItemInstance = ItemInstanceScript.new(_definition())
	var second: ItemInstance = ItemInstanceScript.new(_definition())
	_check(not first.instance_id.is_empty())
	_check(not second.instance_id.is_empty())
	_check(first.instance_id != second.instance_id)
	_pending_helpers -= 1

func _test_two_explicit_instances_of_same_definition_remain_distinct() -> void:
	_pending_helpers += 1
	var first: ItemInstance = ItemInstanceScript.new(_definition(), "batch_a:item_0000")
	var second: ItemInstance = ItemInstanceScript.new(_definition(), "batch_b:item_0000")
	_check(first.definition == second.definition)
	_check(first.instance_id != second.instance_id)
	_pending_helpers -= 1


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition
