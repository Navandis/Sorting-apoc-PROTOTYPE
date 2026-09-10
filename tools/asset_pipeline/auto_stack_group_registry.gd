extends RefCounted
class_name AutoStackGroupRegistry

const SCHEMA_VERSION: String = "1.0"


static func empty_registry() -> Dictionary:
	return {"schema_version": SCHEMA_VERSION, "classes": {}}


static func load_registry(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Auto Stack Group registry does not exist: %s" % path)
		return empty_registry()
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Unable to read Auto Stack Group registry: %s" % path)
		return empty_registry()
	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not (parser.data is Dictionary):
		push_error("Invalid Auto Stack Group registry JSON: %s" % path)
		return empty_registry()
	var registry: Dictionary = parser.data as Dictionary
	var errors: PackedStringArray = validate_registry(registry)
	if not errors.is_empty():
		for message: String in errors:
			push_error(message)
		return empty_registry()
	return _normalized_registry(registry)


static func serialize_registry(registry: Dictionary) -> String:
	return JSON.stringify(_normalized_registry(registry), "\t", true) + "\n"


static func validate_registry(registry: Dictionary) -> PackedStringArray:
	var errors: PackedStringArray = []
	if String(registry.get("schema_version", "")) != SCHEMA_VERSION:
		errors.append("Unsupported Auto Stack Group registry schema_version.")
	var classes_value: Variant = registry.get("classes", {})
	if not (classes_value is Dictionary):
		errors.append("Auto Stack Group registry classes must be a Dictionary.")
		return errors
	var classes: Dictionary = classes_value as Dictionary
	for id_value: Variant in classes.keys():
		var group_id: String = String(id_value)
		if not _valid_class_id(group_id):
			errors.append("Invalid Auto Stack Group class ID: %s" % group_id)
		var class_value: Variant = classes[id_value]
		if not (class_value is Dictionary):
			errors.append("Auto Stack Group class '%s' must be a Dictionary." % group_id)
			continue
		var class_record: Dictionary = class_value as Dictionary
		if String(class_record.get("approval_status", "")) != "APPROVED":
			errors.append("Auto Stack Group class '%s' approval_status must be APPROVED." % group_id)
		var revision_value: Variant = class_record.get("compatibility_revision", 0)
		var revision_number: float = float(revision_value) if revision_value is int or revision_value is float else 0.0
		if revision_number <= 0.0 or revision_number != floorf(revision_number):
			errors.append("Auto Stack Group class '%s' compatibility_revision must be a positive integer." % group_id)
		var description_value: Variant = class_record.get("description", "")
		if not (description_value is String) or String(description_value).strip_edges().is_empty():
			errors.append("Auto Stack Group class '%s' description must be a non-empty String." % group_id)
	return errors


static func validate_reference(value: Variant, registry: Dictionary) -> PackedStringArray:
	var errors: PackedStringArray = []
	if value is Array:
		errors.append("An item must reference exactly zero or one Auto Stack Group.")
		return errors
	if not (value is String) and not (value is StringName):
		errors.append("An item Auto Stack Group reference must be a String.")
		return errors
	var group_id: String = String(value)
	if group_id.is_empty():
		return errors
	var classes_value: Variant = registry.get("classes", {})
	if not (classes_value is Dictionary) or not (classes_value as Dictionary).has(group_id):
		errors.append("Unknown auto stack group: %s" % group_id)
		return errors
	var class_value: Variant = (classes_value as Dictionary)[group_id]
	if not (class_value is Dictionary) or String((class_value as Dictionary).get("approval_status", "")) != "APPROVED":
		errors.append("Auto stack group is not approved: %s" % group_id)
	return errors


static func compatibility_revision(group_id: String, registry: Dictionary) -> int:
	if group_id.is_empty() or not validate_reference(group_id, registry).is_empty():
		return 0
	var classes: Dictionary = registry.get("classes", {}) as Dictionary
	var class_record: Dictionary = classes[group_id] as Dictionary
	return int(class_record.get("compatibility_revision", 0))


static func _normalized_registry(registry: Dictionary) -> Dictionary:
	var raw_classes_value: Variant = registry.get("classes", {})
	var raw_classes: Dictionary = raw_classes_value as Dictionary if raw_classes_value is Dictionary else {}
	var ids: Array[String] = []
	for id_value: Variant in raw_classes.keys():
		ids.append(String(id_value))
	ids.sort()
	var classes: Dictionary = {}
	for group_id: String in ids:
		var class_value: Variant = raw_classes[group_id]
		var class_record: Dictionary = class_value as Dictionary if class_value is Dictionary else {}
		classes[group_id] = {
			"approval_status": String(class_record.get("approval_status", "")),
			"compatibility_revision": int(class_record.get("compatibility_revision", 0)),
			"description": String(class_record.get("description", ""))
		}
	return {"schema_version": SCHEMA_VERSION, "classes": classes}


static func _valid_class_id(group_id: String) -> bool:
	if group_id.is_empty():
		return false
	var first: int = group_id.unicode_at(0)
	if first < 97 or first > 122:
		return false
	for index: int in range(group_id.length()):
		var character: int = group_id.unicode_at(index)
		if (character < 97 or character > 122) and (character < 48 or character > 57) and character != 95:
			return false
	return true
