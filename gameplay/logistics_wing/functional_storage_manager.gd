extends "res://storage_prototype_manager.gd"


func _unhandled_input(_event: InputEvent) -> void:
	# The continuing game never exposes the historical occupancy-demo controls.
	return


func _print_summary() -> void:
	print(
		"Wing functional storage: installed ",
		get_surfaces().size(),
		" empty deterministic surface(s); F6/F7 fixture demos disabled."
	)
