extends "res://storage_prototype_manager.gd"

var _developer_grid_visible: bool = false


func install(scene_root: Node) -> void:
	# The historical fixture starts visible. The continuing scene starts quiet;
	# Manual targeting can still request its normal presentation independently.
	_debug_visible = false
	_developer_grid_visible = false
	super.install(scene_root)
	_apply_developer_grid_visibility()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or key_event.keycode != KEY_F6:
		return
	_developer_grid_visible = not _developer_grid_visible
	_apply_developer_grid_visibility()
	get_viewport().set_input_as_handled()


func is_developer_grid_visible() -> bool:
	return _developer_grid_visible


func _apply_developer_grid_visibility() -> void:
	for surface_node: Node in get_surfaces():
		if surface_node.has_method("set_developer_debug_visible"):
			surface_node.call("set_developer_debug_visible", _developer_grid_visible)


func _print_summary() -> void:
	print(
		"Wing functional storage: installed ",
		get_surfaces().size(),
		" empty deterministic surface(s); F6 developer grids default OFF, F7 demo disabled."
	)
