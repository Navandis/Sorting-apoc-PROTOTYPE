extends Node

const PanelScript = preload("res://gameplay/requests/contribution_panel.gd")
var player: Node3D
var proxy: Node3D
var panel: CanvasLayer
var request: RefCounted
var action_label: Label3D

func configure(wing: Node, state: RefCounted) -> void:
	request = state
	player = wing.get_node("Player")
	proxy = wing.get_node("Environment/Greybox/Proxies/MedicalInterface")
	panel = PanelScript.new()
	panel.name = "ContributionPanel"
	add_child(panel)
	panel.configure(state, player.carried_items, is_targeted)
	panel.panel_closed.connect(_on_closed)
	player.medical_interface = self
	action_label = Label3D.new()
	action_label.font_size = 42
	action_label.pixel_size = 0.003
	action_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	action_label.no_depth_test = false
	proxy.add_child(action_label)
	action_label.position.y = 0.75
	_refresh_action_label()

func is_active() -> bool:
	return request != null and not request.closed

func _process(_delta: float) -> void:
	_refresh_action_label()

func _refresh_action_label() -> void:
	var text := "MEDICAL\n[F] Request / Contribute" if is_active() else "MEDICAL"
	if action_label.text != text:
		action_label.text = text

func is_targeted() -> bool:
	if not is_active():
		return false
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
	_refresh_action_label()
	player.set_world_input_blocked(get_tree().paused)
	player._update_interaction_target()
	if not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
