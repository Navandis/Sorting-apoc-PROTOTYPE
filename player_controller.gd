extends CharacterBody3D

@export var move_speed: float = 4.0
@export var sprint_multiplier: float = 2.0
@export var acceleration: float = 18.0
@export var deceleration: float = 24.0
@export_range(0.0005, 0.02, 0.0005) var mouse_sensitivity: float = 0.002
@export_range(45.0, 89.0, 1.0) var max_look_angle_degrees: float = 89.0

# Step 3 interaction prototype.
@export_range(0.5, 6.0, 0.1) var interaction_distance: float = 1.5
@export var prototype_auto_register_known_loot: bool = true
@export var prototype_require_loot_group: bool = false
@export var print_loot_registration: bool = true
@export var enable_held_item_view: bool = true
@export_range(0.5, 4.0, 0.1) var storage_interaction_distance: float = 1.8

@onready var camera: Camera3D = $Camera3D
@onready var carried_items: Node = $CarriedItems

const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const WorldItemScript = preload("res://world_item.gd")
const HeldItemViewScript = preload("res://held_item_view.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")

var _pitch: float = 0.0
var _gravity: float = 9.8
var _current_world_item: WorldItem = null
var _held_item_view: Node3D
var _storage_placement: Node = null

var _interaction_hud: CanvasLayer
var _aim_dot: Panel
var _aim_dot_style: StyleBoxFlat
var _interaction_prompt: Label

const DOT_IDLE := Color(0.90, 0.93, 0.90, 0.95)
const DOT_PICKUP := Color(0.48, 1.00, 0.62, 1.0)
const DOT_BLOCKED := Color(1.00, 0.48, 0.38, 1.0)
const DOT_PLACE := Color(0.35, 0.84, 1.00, 1.0)


func _ready() -> void:
	_pitch = camera.rotation.x
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.near = minf(camera.near, 0.02)
	_build_interaction_hud()
	if enable_held_item_view:
		_build_held_item_view()
	_build_storage_placement_controller()

	if carried_items != null:
		carried_items.contents_changed.connect(_refresh_held_item)
		carried_items.selection_changed.connect(_on_carried_selection_changed)
		_refresh_held_item()

	if prototype_auto_register_known_loot:
		call_deferred("_register_prototype_world_items")


func _process(_delta: float) -> void:
	_update_interaction_target()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

		_pitch -= event.relative.y * mouse_sensitivity
		var max_pitch: float = deg_to_rad(max_look_angle_degrees)
		_pitch = clampf(_pitch, -max_pitch, max_pitch)
		camera.rotation.x = _pitch

	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_E and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_attempt_interact()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_R and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if _storage_placement != null:
				_storage_placement.call("toggle_rotation")
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			_attempt_interact()
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = -0.1

	var input_vector: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0
	input_vector = input_vector.normalized()

	var speed: float = move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= sprint_multiplier

	var local_direction: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	var world_direction: Vector3 = global_transform.basis * local_direction
	world_direction.y = 0.0
	world_direction = world_direction.normalized()

	var target_x: float = world_direction.x * speed
	var target_z: float = world_direction.z * speed
	var rate: float = acceleration if input_vector != Vector2.ZERO else deceleration

	velocity.x = move_toward(velocity.x, target_x, rate * delta)
	velocity.z = move_toward(velocity.z, target_z, rate * delta)

	move_and_slide()


func _register_prototype_world_items() -> void:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		return

	var registered_count: int = 0
	for child in current_scene.get_children():
		if not child is Node3D:
			continue
		if child == self:
			continue
		if prototype_require_loot_group and not child.is_in_group("loot_item"):
			continue
		if child.get_node_or_null("WorldItem") != null:
			continue

		var definition: ItemDefinition = PrototypeItemCatalogScript.create_definition_for_node(child)
		if definition == null:
			continue

		var host: Node3D = child as Node3D
		var component: WorldItem = WorldItemScript.new()
		component.name = "WorldItem"
		host.add_child(component)
		component.configure(host, definition)
		registered_count += 1

	if print_loot_registration:
		print("Prototype loot registered: ", registered_count, " world item(s).")


func _attempt_interact() -> void:
	var target: WorldItem = _get_looked_at_world_item()
	if target != null:
		_attempt_pickup(target)
		return

	if _storage_placement != null:
		var placed: bool = bool(_storage_placement.call("place_selected"))
		if placed:
			_update_interaction_target()


func _attempt_pickup(target: WorldItem) -> void:
	if target == null or carried_items == null:
		return
	if target.pickup_into(carried_items):
		_current_world_item = null
		_update_interaction_target()


func _update_interaction_target() -> void:
	_current_world_item = _get_looked_at_world_item()

	if _storage_placement != null:
		_storage_placement.call("set_suppressed", _current_world_item != null)
		_storage_placement.call("update_target")

	if _current_world_item != null:
		var can_pickup: bool = _current_world_item.can_pickup_into(carried_items)
		_set_aim_dot_color(DOT_PICKUP if can_pickup else DOT_BLOCKED)
		_interaction_prompt.visible = true

		if can_pickup:
			_interaction_prompt.text = "%s   •   %s   •   B%d\n[E / LMB] PICK UP" % [
				_current_world_item.get_display_name(),
				_current_world_item.utility_text(),
				_current_world_item.get_bulk()
			]
		else:
			_interaction_prompt.text = "%s   •   B%d\nNOT ENOUGH CARRY CAPACITY" % [
				_current_world_item.get_display_name(),
				_current_world_item.get_bulk()
			]
		return

	if _storage_placement != null and bool(_storage_placement.call("is_targeting_surface")):
		var can_place: bool = bool(_storage_placement.call("has_valid_placement"))
		_set_aim_dot_color(DOT_PLACE if can_place else DOT_BLOCKED)
		_interaction_prompt.visible = true
		_interaction_prompt.text = String(_storage_placement.call("get_prompt_text"))
		return

	_set_aim_dot_color(DOT_IDLE)
	_interaction_prompt.visible = false


func _get_looked_at_world_item() -> WorldItem:
	if camera == null or get_world_3d() == null:
		return null

	var from: Vector3 = camera.global_position
	var forward: Vector3 = -camera.global_transform.basis.z.normalized()
	var to: Vector3 = from + (forward * interaction_distance)

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	# Pickup selection deliberately queries only dedicated WorldItem areas.
	# Coarse player-movement colliders on shelves/crates must not occlude loot
	# visibly resting on those storage objects.
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = WorldItemScript.PICKUP_COLLISION_LAYER
	query.exclude = [get_rid()]

	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	var collider_value: Variant = result.get("collider")
	if not collider_value is Node:
		return null

	var node: Node = collider_value as Node
	while node != null:
		if node is WorldItem:
			return node as WorldItem
		if node == get_tree().current_scene:
			break
		node = node.get_parent()
	return null


func _build_storage_placement_controller() -> void:
	_storage_placement = StoragePlacementControllerScript.new()
	_storage_placement.name = "StoragePlacementController"
	add_child(_storage_placement)
	_storage_placement.call(
		"configure",
		camera,
		carried_items,
		storage_interaction_distance
	)


func _build_held_item_view() -> void:
	# Step 3.6: no runtime SubViewport. The held prop is a visual-only child of
	# the actual player camera. Its materials are cloned and configured by
	# held_item_view.gd so it cannot cast shadows or alter bunker lighting.
	_held_item_view = HeldItemViewScript.new()
	_held_item_view.name = "HeldItemView"
	camera.add_child(_held_item_view)


func _refresh_held_item() -> void:
	if _held_item_view == null or carried_items == null:
		return
	_held_item_view.call("set_item", carried_items.get_selected_item())


func _on_carried_selection_changed(_selected_index: int) -> void:
	_refresh_held_item()
	if _storage_placement != null:
		_storage_placement.call("reset_rotation")


func _build_interaction_hud() -> void:
	_interaction_hud = CanvasLayer.new()
	_interaction_hud.name = "InteractionHUD"
	_interaction_hud.layer = 20
	add_child(_interaction_hud)

	var root: Control = Control.new()
	root.name = "InteractionRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_interaction_hud.add_child(root)

	var outer: Panel = Panel.new()
	outer.name = "AimDotOuter"
	outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.anchor_left = 0.5
	outer.anchor_right = 0.5
	outer.anchor_top = 0.5
	outer.anchor_bottom = 0.5
	outer.offset_left = -6.0
	outer.offset_right = 6.0
	outer.offset_top = -6.0
	outer.offset_bottom = 6.0
	var outer_style: StyleBoxFlat = StyleBoxFlat.new()
	outer_style.bg_color = Color(0.0, 0.0, 0.0, 0.72)
	outer_style.corner_radius_top_left = 6
	outer_style.corner_radius_top_right = 6
	outer_style.corner_radius_bottom_left = 6
	outer_style.corner_radius_bottom_right = 6
	outer.add_theme_stylebox_override("panel", outer_style)
	root.add_child(outer)

	_aim_dot = Panel.new()
	_aim_dot.name = "AimDot"
	_aim_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_aim_dot.anchor_left = 0.5
	_aim_dot.anchor_right = 0.5
	_aim_dot.anchor_top = 0.5
	_aim_dot.anchor_bottom = 0.5
	_aim_dot.offset_left = -3.5
	_aim_dot.offset_right = 3.5
	_aim_dot.offset_top = -3.5
	_aim_dot.offset_bottom = 3.5
	_aim_dot_style = StyleBoxFlat.new()
	_aim_dot_style.bg_color = DOT_IDLE
	_aim_dot_style.corner_radius_top_left = 4
	_aim_dot_style.corner_radius_top_right = 4
	_aim_dot_style.corner_radius_bottom_left = 4
	_aim_dot_style.corner_radius_bottom_right = 4
	_aim_dot.add_theme_stylebox_override("panel", _aim_dot_style)
	outer.add_child(_aim_dot)

	_interaction_prompt = Label.new()
	_interaction_prompt.name = "InteractionPrompt"
	_interaction_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_interaction_prompt.anchor_left = 0.5
	_interaction_prompt.anchor_right = 0.5
	_interaction_prompt.anchor_top = 0.5
	_interaction_prompt.anchor_bottom = 0.5
	_interaction_prompt.offset_left = -300.0
	_interaction_prompt.offset_right = 300.0
	_interaction_prompt.offset_top = 15.0
	_interaction_prompt.offset_bottom = 70.0
	_interaction_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_interaction_prompt.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_interaction_prompt.add_theme_color_override("font_color", Color(0.93, 0.95, 0.93, 1.0))
	_interaction_prompt.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	_interaction_prompt.add_theme_constant_override("outline_size", 5)
	_interaction_prompt.add_theme_font_size_override("font_size", 15)
	_interaction_prompt.visible = false
	root.add_child(_interaction_prompt)


func _set_aim_dot_color(color: Color) -> void:
	if _aim_dot_style != null:
		_aim_dot_style.bg_color = color
