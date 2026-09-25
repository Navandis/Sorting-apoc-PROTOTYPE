class_name EnvironmentMaterialReviewSet
extends Resource

@export var specs: Array[Resource] = []


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if specs.is_empty():
		errors.append("review set must have at least one spec")
	var seen := {}
	for index in specs.size():
		var spec := specs[index]
		if spec == null:
			errors.append("spec %d is null" % index)
			continue
		for error in spec.validate():
			errors.append("spec %d: %s" % [index, error])
		if seen.has(spec.material_id):
			errors.append("duplicate material_id: %s" % spec.material_id)
		seen[spec.material_id] = true
	return errors


func wrapped_index(index: int) -> int:
	return posmod(index, specs.size()) if not specs.is_empty() else -1


func get_spec(index: int) -> Resource:
	return specs[wrapped_index(index)] if not specs.is_empty() else null
