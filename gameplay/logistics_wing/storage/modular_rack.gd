@tool
extends Node3D
class_name ModularRack

const StorageSurfaceScript = preload("res://storage_surface.gd")

@export_range(0.10, 20.0, 0.01, "or_greater") var rack_length_m := 2.40:
	set(value):
		rack_length_m = maxf(value, 0.10)
		_request_refresh()

@export_range(0.10, 5.0, 0.01, "or_greater") var rack_depth_m := 0.80:
	set(value):
		rack_depth_m = maxf(value, 0.10)
		_request_refresh()

@export_range(0.10, 8.0, 0.01, "or_greater") var frame_height_m := 2.20:
	set(value):
		frame_height_m = maxf(value, 0.10)
		_request_refresh()

@export_range(0.0, 2.0, 0.005, "or_greater") var usable_inset_left_m := 0.04
@export_range(0.0, 2.0, 0.005, "or_greater") var usable_inset_right_m := 0.04
@export_range(0.0, 2.0, 0.005, "or_greater") var usable_inset_front_m := 0.00
@export_range(0.0, 2.0, 0.005, "or_greater") var usable_inset_back_m := 0.05
@export_range(0.01, 10.0, 0.01, "or_greater") var overhead_limit_local_y_m := 3.40
@export var show_authoring_preview := true

var _refresh_requested := true
var _last_authoring_fingerprint := ""
var _runtime_surfaces: Array[StorageSurface] = []


func _ready() -> void:
	_request_refresh()


func _process(_delta: float) -> void:
	if _refresh_requested:
		refresh_authoring_state()


func refresh_authoring_state() -> void:
	_refresh_requested = false


func compute_layout() -> Dictionary:
	return {
		"valid": false,
		"errors": ["Modular rack layout derivation is not implemented yet."],
		"warnings": [],
		"rack": {},
		"levels": [],
	}


func get_layout_contract() -> Dictionary:
	return compute_layout()


func build_runtime_storage() -> Array[StorageSurface]:
	return _runtime_surfaces.duplicate()


func clear_runtime_storage() -> bool:
	_runtime_surfaces.clear()
	return true


func _request_refresh() -> void:
	_refresh_requested = true
