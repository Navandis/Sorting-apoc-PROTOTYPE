extends Node

const PanelScript = preload("res://gameplay/requests/contribution_panel.gd")
var player: Node3D
var proxy: Node3D
var panel: CanvasLayer

func configure(wing: Node, state: RefCounted) -> void:
	player = wing.get_node("Player")
	proxy = wing.get_node("Environment/Greybox/Proxies/MedicalInterface")
	panel = PanelScript.new()
	panel.name = "ContributionPanel"
	add_child(panel)
	panel.configure(state, player.carried_items, is_targeted)
	panel.panel_closed.connect(_on_closed)
	player.medical_interface = self
	var label := Label3D.new()
	label.text = "MEDICAL\n[E] Request / Contribute"
	label.font_size = 42
	label.pixel_size = 0.003
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = false
	proxy.add_child(label)
	label.position.y = 0.75

func is_targeted() -> bool:
	if not is_instance_valid(player) or not is_instance_valid(proxy) or not proxy.is_inside_tree() or not proxy.is_visible_in_tree():
		return false
	var camera: Camera3D = player.camera
	var from := camera.global_position
	var to: Vector3 = from - camera.global_basis.z.normalized() * float(player.storage_interaction_distance)
	var mesh := proxy.get_node("Mesh") as MeshInstance3D
	var inverse := mesh.global_transform.affine_inverse()
	var bounds := mesh.get_aabb().grow(0.12)
	if not bounds.intersects_segment(inverse * from, inverse * to):
		return false
	var query := PhysicsRayQueryParameters3D.create(from, to, 1, [player.get_rid()])
	var obstruction := player.get_world_3d().direct_space_state.intersect_ray(query)
	return obstruction.is_empty() or from.distance_to(obstruction.position) + 0.15 >= from.distance_to(proxy.global_position)

func open_panel() -> void:
	if not is_targeted():
		return
	player.set_world_input_blocked(true)
	panel.open_panel()

func _on_closed() -> void:
	player.set_world_input_blocked(false)
	if not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
