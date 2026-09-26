@tool
class_name EnvironmentSubstratePiece
extends Node3D

const Builder = preload("res://environment_authoring/substrate/environment_substrate_builder.gd")
const MaterialBuilder = preload("res://environment_authoring/environment_material_builder.gd")

@export var piece_spec: EnvironmentSubstratePieceSpec
@export_tool_button("Regenerate Substrate") var regenerate_action := regenerate

var generation_metadata: Dictionary = {}


func validate_authoring() -> PackedStringArray:
	var errors := PackedStringArray()
	if piece_spec == null:
		errors.append("piece_spec is required")
	else:
		errors.append_array(piece_spec.validate())
	if not scale.is_equal_approx(Vector3.ONE):
		errors.append("root scale must be Vector3.ONE; edit mesh dimensions in the spec")
	return errors


func regenerate() -> bool:
	var errors := validate_authoring()
	if not errors.is_empty():
		push_error("Cannot regenerate substrate: %s" % "; ".join(errors))
		return false
	var result: Dictionary = Builder.new().build(piece_spec)
	if result.is_empty():
		return false
	for child_name in ["GeneratedMesh", "SimpleCollision"]:
		var old := get_node_or_null(child_name)
		if old != null:
			remove_child(old)
			old.free()
	var instance := MeshInstance3D.new()
	instance.name = "GeneratedMesh"
	instance.mesh = result["mesh"]
	instance.material_override = MaterialBuilder.new().build(piece_spec.material_spec)
	add_child(instance)
	_own(instance)
	var boxes: Array = result["collision_boxes"]
	if not boxes.is_empty():
		var body := StaticBody3D.new()
		body.name = "SimpleCollision"
		add_child(body)
		_own(body)
		for i in boxes.size():
			var descriptor := boxes[i] as Dictionary
			var shape := BoxShape3D.new()
			shape.size = descriptor["size"]
			var collision := CollisionShape3D.new()
			collision.name = "Region_%02d" % i
			collision.shape = shape
			collision.position = descriptor["center"]
			body.add_child(collision)
			_own(collision)
	generation_metadata = result["metadata"]
	set_meta("eaf2_generation", generation_metadata)
	return true


func _own(node: Node) -> void:
	# Persist generated mesh/collision children when an authored scene is saved.
	if Engine.is_editor_hint():
		node.owner = owner if owner != null else self
