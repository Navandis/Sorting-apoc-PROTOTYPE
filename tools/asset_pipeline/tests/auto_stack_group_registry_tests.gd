extends SceneTree

const AutoStackGroupRegistryScript = preload("res://tools/asset_pipeline/auto_stack_group_registry.gd")
const REGISTRY_PATH: String = "res://tools/asset_pipeline/auto_stack_group_registry.json"


func _init() -> void:
	_test_four_approved_classes_validate()
	_test_empty_reference_is_valid()
	_test_unknown_reference_fails()
	_test_multiple_references_fail()
	_test_invalid_registry_records_fail()
	_test_serialization_is_deterministic()
	_test_production_registry_is_exact()
	print("PASS: auto stack group registry tests")
	quit(0)


func _test_four_approved_classes_validate() -> void:
	assert(AutoStackGroupRegistryScript.validate_registry(_registry()).is_empty())


func _test_empty_reference_is_valid() -> void:
	assert(AutoStackGroupRegistryScript.validate_reference("", _registry()).is_empty())


func _test_unknown_reference_fails() -> void:
	var errors: PackedStringArray = AutoStackGroupRegistryScript.validate_reference(
		"silent_new_group", _registry()
	)
	assert(_errors_contain(errors, "Unknown auto stack group"))


func _test_multiple_references_fail() -> void:
	var errors: PackedStringArray = AutoStackGroupRegistryScript.validate_reference(
		["flat_media", "boxed_food"], _registry()
	)
	assert(_errors_contain(errors, "zero or one"))


func _test_invalid_registry_records_fail() -> void:
	var bad_id: Dictionary = _registry()
	var bad_id_classes: Dictionary = bad_id["classes"] as Dictionary
	bad_id_classes["Bad Group"] = (bad_id_classes["flat_media"] as Dictionary).duplicate(true)
	bad_id_classes.erase("flat_media")
	assert(_errors_contain(AutoStackGroupRegistryScript.validate_registry(bad_id), "class ID"))
	var bad_status: Dictionary = _registry()
	((bad_status["classes"] as Dictionary)["flat_media"] as Dictionary)["approval_status"] = "UNREVIEWED"
	assert(_errors_contain(AutoStackGroupRegistryScript.validate_registry(bad_status), "approval_status"))
	var bad_revision: Dictionary = _registry()
	((bad_revision["classes"] as Dictionary)["flat_media"] as Dictionary)["compatibility_revision"] = 0
	assert(_errors_contain(AutoStackGroupRegistryScript.validate_registry(bad_revision), "compatibility_revision"))
	var bad_description: Dictionary = _registry()
	((bad_description["classes"] as Dictionary)["flat_media"] as Dictionary)["description"] = ""
	assert(_errors_contain(AutoStackGroupRegistryScript.validate_registry(bad_description), "description"))


func _test_serialization_is_deterministic() -> void:
	var registry: Dictionary = _registry()
	assert(
		AutoStackGroupRegistryScript.serialize_registry(registry)
		== AutoStackGroupRegistryScript.serialize_registry(registry.duplicate(true))
	)


func _test_production_registry_is_exact() -> void:
	var registry: Dictionary = AutoStackGroupRegistryScript.load_registry(REGISTRY_PATH)
	assert(AutoStackGroupRegistryScript.validate_registry(registry).is_empty())
	assert(String(registry["schema_version"]) == "1.0")
	var classes: Dictionary = registry["classes"] as Dictionary
	assert(classes.keys().size() == 4)
	assert(classes.has("flat_media"))
	assert(classes.has("round_cans"))
	assert(classes.has("boxed_food"))
	assert(classes.has("medical_boxes"))
	for class_value: Variant in classes.values():
		var class_record: Dictionary = class_value as Dictionary
		assert(String(class_record["approval_status"]) == "APPROVED")
		assert(int(class_record["compatibility_revision"]) == 1)


func _registry() -> Dictionary:
	return {
		"schema_version": "1.0",
		"classes": {
			"flat_media": _class("Compatible flat media intended to form predictable narrowing automatic stacks."),
			"round_cans": _class("Standard cylindrical canned goods intended to stack vertically even across Storage Categories where zone policy permits."),
			"boxed_food": _class("Compatible rigid boxed-food packages intended to auto-stack."),
			"medical_boxes": _class("Compatible rigid medical packages intended to auto-stack.")
		}
	}


func _class(description: String) -> Dictionary:
	return {
		"approval_status": "APPROVED",
		"compatibility_revision": 1,
		"description": description
	}


func _errors_contain(errors: PackedStringArray, fragment: String) -> bool:
	for message: String in errors:
		if fragment in message:
			return true
	return false
