extends SceneTree

const ItemDefinitionScript = preload("res://item_definition.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const CATALOG_PATH: String = "res://data/items/item_catalog.tres"

const EXPECTED: Dictionary = {
	"loot_000002": [false, true, &""],
	"loot_000005": [true, true, &"boxed_food"],
	"loot_000006": [true, false, &""],
	"loot_000009": [true, true, &"round_cans"],
	"loot_000019": [true, true, &"round_cans"],
	"loot_000028": [true, true, &"medical_boxes"],
	"loot_000030": [true, true, &"flat_media"],
	"loot_000031": [true, true, &"flat_media"],
	"loot_000039": [true, false, &""]
}

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	var item: ItemInstance = ItemInstanceScript.new(definition)
	if not _has_property(definition, &"can_be_stacked"):
		push_error("ItemDefinition.can_be_stacked is missing")
		quit(1)
		return
	if not _has_property(definition, &"can_support_stack"):
		push_error("ItemDefinition.can_support_stack is missing")
		quit(1)
		return
	if not _has_property(definition, &"auto_stack_group"):
		push_error("ItemDefinition.auto_stack_group is missing")
		quit(1)
		return
	for method_name: StringName in [
		&"can_be_stacked", &"can_support_stack", &"get_auto_stack_group"
	]:
		if not item.has_method(method_name):
			push_error("ItemInstance.%s is missing" % method_name)
			quit(1)
			return
	_test_role_combinations_through_item_instance()
	_test_exact_spike_content_and_ordinary_defaults()
	if _failed:
		quit(1)
		return
	print("PASS: support stacking metadata tests")
	quit(0)


func _test_role_combinations_through_item_instance() -> void:
	var roles: Array[Array] = [
		[false, false],
		[true, false],
		[false, true],
		[true, true]
	]
	for role: Array in roles:
		var definition: ItemDefinition = ItemDefinitionScript.new()
		definition.can_be_stacked = bool(role[0])
		definition.can_support_stack = bool(role[1])
		definition.auto_stack_group = &"synthetic"
		var item: ItemInstance = ItemInstanceScript.new(definition)
		_check(item.can_be_stacked() == bool(role[0]), "stacked role getter")
		_check(item.can_support_stack() == bool(role[1]), "support role getter")
		_check(item.get_auto_stack_group() == &"synthetic", "group getter")

	var missing_definition: ItemInstance = ItemInstanceScript.new()
	_check(not missing_definition.can_be_stacked(), "null definition stacked default")
	_check(not missing_definition.can_support_stack(), "null definition support default")
	_check(missing_definition.get_auto_stack_group().is_empty(), "null definition group default")


func _test_exact_spike_content_and_ordinary_defaults() -> void:
	var catalogue: Resource = load(CATALOG_PATH)
	_check(catalogue != null, "catalogue loads")
	if catalogue == null:
		return
	var definitions: Array = catalogue.get("definitions") as Array
	_check(definitions.size() == 42, "catalogue remains 42 items")
	var spike_count: int = 0
	for value: Variant in definitions:
		var definition: ItemDefinition = value as ItemDefinition
		_check(definition != null, "catalogue entry is ItemDefinition")
		if definition == null:
			continue
		var item: ItemInstance = ItemInstanceScript.new(definition)
		var item_id: String = String(definition.item_id)
		if EXPECTED.has(item_id):
			spike_count += 1
			var expected: Array = EXPECTED[item_id] as Array
			_check(item.can_be_stacked() == bool(expected[0]), "%s stackable role" % item_id)
			_check(item.can_support_stack() == bool(expected[1]), "%s support role" % item_id)
			_check(item.get_auto_stack_group() == StringName(expected[2]), "%s group" % item_id)
		else:
			_check(not item.can_be_stacked(), "%s ordinary stackable default" % item_id)
			_check(not item.can_support_stack(), "%s ordinary support default" % item_id)
			_check(item.get_auto_stack_group().is_empty(), "%s ordinary group default" % item_id)
	_check(spike_count == 9, "exactly nine spike definitions")


func _has_property(object: Object, property_name: StringName) -> bool:
	for property: Dictionary in object.get_property_list():
		if property.get("name", &"") as StringName == property_name:
			return true
	return false


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
