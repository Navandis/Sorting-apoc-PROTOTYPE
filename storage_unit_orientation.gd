@tool
extends Node
class_name StorageUnitOrientation

const StorageOrientationScript = preload("res://storage_orientation.gd")

@export_enum(
	"Front +Z / Right +X:0",
	"Front +X / Right -Z:1",
	"Front -Z / Right -X:2",
	"Front -X / Right +Z:3"
)
var storage_orientation_quarter_turns: int = 0:
	set(value):
		storage_orientation_quarter_turns = (
			StorageOrientationScript.normalize_quarter_turns(value)
		)

@export_tool_button("Rotate Storage Directions CW", "RotateRight")
var rotate_cw_action: Callable = rotate_storage_directions_cw

@export_tool_button("Rotate Storage Directions CCW", "RotateLeft")
var rotate_ccw_action: Callable = rotate_storage_directions_ccw


func get_storage_orientation_quarter_turns() -> int:
	return storage_orientation_quarter_turns


func rotate_storage_directions_cw() -> void:
	storage_orientation_quarter_turns = (
		StorageOrientationScript.normalize_quarter_turns(
			storage_orientation_quarter_turns + 1
		)
	)


func rotate_storage_directions_ccw() -> void:
	storage_orientation_quarter_turns = (
		StorageOrientationScript.normalize_quarter_turns(
			storage_orientation_quarter_turns - 1
		)
	)
