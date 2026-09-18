extends Node3D

@export var development_setup_enabled: bool = true


func _enter_tree() -> void:
	var hud := get_node_or_null("HUD/CarriedItemsHUD")
	if hud != null:
		hud.set("carried_items_path", NodePath("../../Player/CarriedItems"))

	if not development_setup_enabled:
		var setup := get_node_or_null("DevelopmentSetup")
		if setup != null:
			remove_child(setup)
			setup.queue_free()
