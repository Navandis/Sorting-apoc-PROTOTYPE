@tool
extends Node3D

@export var item_id: StringName = &"":
	set(value):
		item_id = value
		update_configuration_warnings()


func get_authored_visual() -> Node3D:
	var authored_visual: Node3D = null
	for child: Node in get_children():
		if not (child is Node3D):
			continue
		var candidate := child as Node3D
		if candidate.scene_file_path.is_empty():
			continue
		if authored_visual != null:
			return null
		authored_visual = candidate
	return authored_visual


func get_authored_visual_count() -> int:
	var count := 0
	for child: Node in get_children():
		if child is Node3D and not (child as Node3D).scene_file_path.is_empty():
			count += 1
	return count


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if item_id == &"":
		warnings.append("Seed host requires a catalogue item_id.")
	var visual_count := get_authored_visual_count()
	if visual_count != 1:
		warnings.append("Seed host requires exactly one editor-visible imported visual child; found %d." % visual_count)
	return warnings
