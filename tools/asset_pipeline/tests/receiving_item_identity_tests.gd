extends SceneTree

const ItemInstanceScript = preload("res://item_instance.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")

func _init() -> void:
	_test_explicit_identity_is_preserved()
	_test_legacy_identity_path_remains_non_empty()
	_test_two_explicit_instances_of_same_definition_remain_distinct()
	print("PASS: receiving item identity tests")
	quit(0)

func _definition() -> ItemDefinition:
	return PersistentItemCatalog.get_definition_by_id(&"loot_000001")

func _test_explicit_identity_is_preserved() -> void:
	var instance: ItemInstance = ItemInstanceScript.new(
		_definition(),
		"batch_alpha:item_0000"
	)
	assert(instance.instance_id == "batch_alpha:item_0000")
	assert(instance.definition == _definition())

func _test_legacy_identity_path_remains_non_empty() -> void:
	var first: ItemInstance = ItemInstanceScript.new(_definition())
	var second: ItemInstance = ItemInstanceScript.new(_definition())
	assert(not first.instance_id.is_empty())
	assert(not second.instance_id.is_empty())
	assert(first.instance_id != second.instance_id)

func _test_two_explicit_instances_of_same_definition_remain_distinct() -> void:
	var first: ItemInstance = ItemInstanceScript.new(_definition(), "batch_a:item_0000")
	var second: ItemInstance = ItemInstanceScript.new(_definition(), "batch_b:item_0000")
	assert(first.definition == second.definition)
	assert(first.instance_id != second.instance_id)
