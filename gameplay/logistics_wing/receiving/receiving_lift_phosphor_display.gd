extends Node
# Static visual proof only: no game-state or input connection.
# The GLB has its own local-scene scope, so bind this viewport at runtime.
# Keep editor resources free of pathless live textures when the wing is saved.
func _ready() -> void:
	var mesh := get_node_or_null("../SM_KB3D_CPP_PropTV_A/Mesh") as MeshInstance3D
	if mesh == null:
		return # The UI scene can also be previewed on its own.
	var material := mesh.get_surface_override_material(1).duplicate() as StandardMaterial3D
	material.albedo_color = Color.WHITE
	material.albedo_texture = $ScreenViewport.get_texture()
	mesh.set_surface_override_material(1, material)
