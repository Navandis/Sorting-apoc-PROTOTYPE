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

# Zone-auto throughput tuning. The first E press acts immediately; if the key
# remains held, repeated storage begins after this delay.
@export_range(0.05, 1.0, 0.05) var auto_store_hold_delay: float = 0.25
@export_range(0.05, 0.50, 0.01) var auto_store_repeat_interval: float = 0.12

@onready var camera: Camera3D = $Camera3D
@onready var carried_items: Node = $CarriedItems

const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const WorldItemScript = preload("res://world_item.gd")
const HeldItemViewScript = preload("res://held_item_view.gd")
const StoragePlacementControllerScript = preload("res://storage_placement_controller.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")
const StorageZoneEditorScript = preload("res://storage_zone_editor.gd")
const FixedLadderScript = preload("res://gameplay/traversal/fixed_ladder/fixed_ladder.gd")

enum MovementState {
	NORMAL,
	LADDER_ATTACHED,
}

const LADDER_FACING_DOT_MIN := 0.45
const LADDER_INTENT_DOT_MIN := 0.50
const LADDER_LATERAL_INTENT_RATIO_MAX := 0.75
const LADDER_BOTTOM_RELEASE_EPSILON_M := 0.02

var _pitch: float = 0.0
var _gravity: float = 9.8
var _current_world_item: WorldItem = null
var _held_item_view: Node3D
var _storage_placement: Node = null
var _zone_editor: CanvasLayer = null
var _zone_editor_open: bool = false

var _movement_state: MovementState = MovementState.NORMAL
var _attached_ladder: Node3D = null
var _ladder_yaw_center: float = 0.0
var _ladder_anchor_xz := Vector2.ZERO

var _store_hold_elapsed: float = 0.0
var _store_repeat_elapsed: float = 0.0
var _store_was_held: bool = false

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
	_build_storage_zone_editor()

	if carried_items != null:
		carried_items.contents_changed.connect(_refresh_held_item)
		carried_items.selection_changed.connect(_on_carried_selection_changed)
		_refresh_held_item()

	if prototype_auto_register_known_loot:
		call_deferred("_register_prototype_world_items")


func _process(delta: float) -> void:
	if _zone_editor_open:
		_reset_store_hold_state()
		return

	_update_interaction_target()
	_update_store_hold(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_apply_mouse_look(event.relative)

	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_O and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_try_open_zone_editor()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_M and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if _storage_placement != null:
				_storage_placement.call("toggle_manual_mode")
				_update_interaction_target()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_attempt_store()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_R and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if _storage_placement != null:
				_storage_placement.call("toggle_rotation")
			get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			_attempt_pickup_click()
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	var input_vector := _read_movement_input()
	_step_movement(delta, input_vector, Input.is_key_pressed(KEY_SHIFT))


func _read_movement_input() -> Vector2:
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0
	return input_vector.normalized()


func _step_movement(
	delta: float,
	input_vector: Vector2,
	sprint_pressed: bool
) -> void:
	if input_vector.length_squared() > 1.0:
		input_vector = input_vector.normalized()
	if is_ladder_attached():
		_step_ladder_movement(delta, input_vector, sprint_pressed)
		return
	if _try_attach_nearby_ladder(input_vector):
		_step_ladder_movement(delta, input_vector, sprint_pressed)
		return
	_step_normal_movement(delta, input_vector, sprint_pressed)


func _step_normal_movement(
	delta: float,
	input_vector: Vector2,
	sprint_pressed: bool
) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = -0.1

	var speed: float = move_speed
	if sprint_pressed:
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


func is_ladder_attached() -> bool:
	return (
		_movement_state == MovementState.LADDER_ATTACHED
		and _attached_ladder != null
		and is_instance_valid(_attached_ladder)
	)


func get_attached_ladder() -> Node3D:
	return _attached_ladder if is_ladder_attached() else null


func get_ladder_yaw_center() -> float:
	return _ladder_yaw_center


func get_player_eye_offset_from_root() -> float:
	if camera == null:
		return 0.0
	return camera.global_position.y - global_position.y


func get_player_body_top_offset_from_root() -> float:
	var highest := 0.0
	for value: Node in find_children("*", "CollisionShape3D", true, false):
		var shape_node := value as CollisionShape3D
		if shape_node == null or shape_node.disabled or shape_node.shape == null:
			continue
		var relative := global_transform.affine_inverse() * shape_node.global_transform
		var centre_y := relative.origin.y
		var scale_y := relative.basis.y.length()
		var half_height := 0.0
		if shape_node.shape is CapsuleShape3D:
			half_height = (shape_node.shape as CapsuleShape3D).height * 0.5
		elif shape_node.shape is BoxShape3D:
			half_height = (shape_node.shape as BoxShape3D).size.y * 0.5
		elif shape_node.shape is CylinderShape3D:
			half_height = (shape_node.shape as CylinderShape3D).height * 0.5
		elif shape_node.shape is SphereShape3D:
			half_height = (shape_node.shape as SphereShape3D).radius
		else:
			var debug_mesh := shape_node.shape.get_debug_mesh()
			if debug_mesh != null:
				var bounds := relative * debug_mesh.get_aabb()
				highest = maxf(highest, bounds.end.y)
			continue
		highest = maxf(highest, centre_y + half_height * scale_y)
	return highest


func _try_attach_nearby_ladder(input_vector: Vector2) -> bool:
	if _zone_editor_open or input_vector.y >= -0.5:
		return false
	for value: Node in get_tree().get_nodes_in_group(&"fixed_ladders"):
		var ladder := value as Node3D
		if _try_attach_to_ladder(ladder, input_vector):
			return true
	return false


func _try_attach_to_ladder(ladder: Node3D, input_vector: Vector2) -> bool:
	if (
		ladder == null
		or ladder.get_script() != FixedLadderScript
		or not bool(ladder.call("is_authoring_valid"))
		or not bool(ladder.call("is_player_in_approach_area", self))
		or not bool(ladder.call("is_player_on_front_side", self))
		or bool(ladder.call("is_attach_suppressed_for", self))
	):
		return false

	var ladder_forward := ladder.call("get_ladder_forward_world") as Vector3
	var ladder_right := ladder.call("get_ladder_right_world") as Vector3
	var toward_ladder := -ladder_forward
	var player_forward := -global_transform.basis.z.normalized()
	if player_forward.dot(toward_ladder) < LADDER_FACING_DOT_MIN:
		return false

	var local_direction := Vector3(input_vector.x, 0.0, input_vector.y)
	var world_direction := global_transform.basis * local_direction
	world_direction.y = 0.0
	if world_direction.length_squared() <= 0.0001:
		return false
	world_direction = world_direction.normalized()
	var forward_intent := world_direction.dot(toward_ladder)
	var lateral_intent := absf(world_direction.dot(ladder_right))
	if (
		forward_intent < LADDER_INTENT_DOT_MIN
		or lateral_intent > forward_intent * LADDER_LATERAL_INTENT_RATIO_MAX
	):
		return false

	var limits := ladder.call(
		"get_player_root_climb_limits",
		get_player_eye_offset_from_root(),
		get_player_body_top_offset_from_root()
	) as Dictionary
	if not bool(limits.get("valid", false)):
		return false

	var anchor := ladder.call("get_climb_anchor_world_position") as Vector3
	_ladder_anchor_xz = Vector2(anchor.x, anchor.z)
	global_position = Vector3(
		_ladder_anchor_xz.x,
		clampf(
			global_position.y,
			float(limits.get("minimum_y", global_position.y)),
			float(limits.get("maximum_y", global_position.y))
		),
		_ladder_anchor_xz.y
	)
	velocity = Vector3.ZERO
	_attached_ladder = ladder
	_movement_state = MovementState.LADDER_ATTACHED
	_ladder_yaw_center = float(ladder.call("get_ladder_yaw_world"))
	rotation.y = _clamp_ladder_yaw(rotation.y)
	return true


func _step_ladder_movement(
	delta: float,
	input_vector: Vector2,
	_sprint_pressed: bool
) -> void:
	if not is_ladder_attached():
		_detach_from_ladder(false)
		_step_normal_movement(delta, input_vector, false)
		return
	_lock_ladder_xz()
	velocity = Vector3.ZERO
	if _zone_editor_open:
		return

	var eye_offset := get_player_eye_offset_from_root()
	var body_top_offset := get_player_body_top_offset_from_root()
	var limits := _attached_ladder.call(
		"get_player_root_climb_limits",
		eye_offset,
		body_top_offset
	) as Dictionary
	if not bool(limits.get("valid", false)):
		_detach_from_ladder(false)
		return
	var minimum_y := float(limits.get("minimum_y", global_position.y))
	var maximum_y := float(limits.get("maximum_y", global_position.y))
	var vertical_intent := -input_vector.y
	var climb_speed := float(_attached_ladder.call("get_climb_speed_m_s"))
	if (
		vertical_intent < -0.001
		and global_position.y <= minimum_y + maxf(LADDER_BOTTOM_RELEASE_EPSILON_M, climb_speed * delta)
	):
		global_position.y = minimum_y
		_detach_from_ladder(true)
		_step_normal_movement(delta, input_vector, false)
		return

	var target_y := clampf(
		global_position.y + vertical_intent * climb_speed * delta,
		minimum_y,
		maximum_y
	)
	velocity.y = (target_y - global_position.y) / delta if delta > 0.0 else 0.0
	move_and_slide()
	global_position.y = clampf(global_position.y, minimum_y, maximum_y)
	_lock_ladder_xz()


func _lock_ladder_xz() -> void:
	global_position.x = _ladder_anchor_xz.x
	global_position.z = _ladder_anchor_xz.y
	velocity.x = 0.0
	velocity.z = 0.0


func _detach_from_ladder(suppress_reattach: bool) -> void:
	if suppress_reattach and is_ladder_attached():
		_attached_ladder.call("suppress_until_approach_exit", self)
	_attached_ladder = null
	_movement_state = MovementState.NORMAL
	velocity = Vector3.ZERO


func _apply_mouse_look(relative: Vector2) -> void:
	var desired_yaw := rotation.y - relative.x * mouse_sensitivity
	rotation.y = _clamp_ladder_yaw(desired_yaw) if is_ladder_attached() else desired_yaw
	_pitch -= relative.y * mouse_sensitivity
	var max_pitch: float = deg_to_rad(max_look_angle_degrees)
	_pitch = clampf(_pitch, -max_pitch, max_pitch)
	if camera != null:
		camera.rotation.x = _pitch


func _clamp_ladder_yaw(desired_yaw: float) -> float:
	if not is_ladder_attached():
		return desired_yaw
	var relative := wrapf(desired_yaw - _ladder_yaw_center, -PI, PI)
	var maximum := float(_attached_ladder.call("get_yaw_clamp_radians"))
	return _ladder_yaw_center + clampf(relative, -maximum, maximum)


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


func _attempt_store() -> void:
	## E is the left-hand logistics action: place/store/submit.
	##
	## AUTO MODE:
	## The first E interaction with an uninitialized shelf introduces zoning.
	##
	## MANUAL MODE:
	## The player explicitly opted out of zoning/automatic policy for this
	## placement action, so E is allowed to place directly even if the shelf
	## has never been initialized in the zoning editor.
	var manual_mode: bool = false
	if _storage_placement != null:
		manual_mode = bool(_storage_placement.call("is_manual_mode"))

	if not manual_mode:
		var surface: Node = _get_looked_at_storage_surface()
		if surface != null and surface.has_method("are_zones_initialized"):
			var initialized: bool = bool(surface.call("are_zones_initialized"))
			if not initialized:
				_open_zone_editor_for_surface(surface)
				return

	if _storage_placement == null:
		return

	var placed: bool = bool(_storage_placement.call("place_selected"))
	if placed:
		_update_interaction_target()


func _update_store_hold(delta: float) -> void:
	# Initial key-down is handled immediately by _unhandled_input().
	# This method only generates subsequent auto-store repeats.
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		_reset_store_hold_state()
		return

	var e_held: bool = Input.is_key_pressed(KEY_E)
	if not e_held:
		_reset_store_hold_state()
		return

	# Manual placement remains one-confirmation-per-press. Continuous placement
	# is specifically a throughput feature of zone-auto mode.
	if _storage_placement == null:
		_reset_store_hold_state()
		return

	var manual_mode: bool = bool(_storage_placement.call("is_manual_mode"))
	if manual_mode:
		_reset_store_hold_state()
		return

	if not _store_was_held:
		_store_was_held = true
		_store_hold_elapsed = 0.0
		_store_repeat_elapsed = 0.0
		return

	_store_hold_elapsed += delta
	if _store_hold_elapsed < auto_store_hold_delay:
		return

	_store_repeat_elapsed += delta
	if _store_repeat_elapsed < auto_store_repeat_interval:
		return

	# Preserve any fractional overflow instead of accumulating timing drift.
	_store_repeat_elapsed = fmod(
		_store_repeat_elapsed,
		auto_store_repeat_interval
	)

	_attempt_store()


func _reset_store_hold_state() -> void:
	_store_was_held = false
	_store_hold_elapsed = 0.0
	_store_repeat_elapsed = 0.0


func _attempt_pickup_click() -> void:
	## Left Mouse Button is the right-hand object-selection action: identify
	## and retrieve the object currently under the reticle.
	var target: WorldItem = _get_looked_at_world_item()
	if target == null:
		return
	_attempt_pickup(target)


func _attempt_pickup(target: WorldItem) -> void:
	if target == null or carried_items == null:
		return
	if target.pickup_into(carried_items):
		_current_world_item = null
		_update_interaction_target()


func _update_interaction_target() -> void:
	_current_world_item = _get_looked_at_world_item()

	if _storage_placement != null:
		# Pickup and placement are now separate controls, so a visible loot item
		# no longer suppresses the storage surface behind it.
		_storage_placement.call("set_suppressed", false)
		_storage_placement.call("update_target")

	var has_loot_target: bool = _current_world_item != null
	var has_storage_target: bool = (
		_storage_placement != null
		and bool(_storage_placement.call("is_targeting_surface"))
	)

	if not has_loot_target and not has_storage_target:
		_set_aim_dot_color(DOT_IDLE)
		_interaction_prompt.visible = false
		return

	var prompt_lines: Array[String] = []
	var loot_pickable: bool = false
	var storage_placeable: bool = false

	if has_loot_target:
		loot_pickable = _current_world_item.can_pickup_into(carried_items)
		if loot_pickable:
			prompt_lines.append("%s   •   %s   •   B%d" % [
				_current_world_item.get_display_name(),
				_current_world_item.utility_text(),
				_current_world_item.get_bulk()
			])
			prompt_lines.append("[LMB] PICK UP")
		else:
			prompt_lines.append("%s   •   B%d" % [
				_current_world_item.get_display_name(),
				_current_world_item.get_bulk()
			])
			prompt_lines.append("[LMB] NOT ENOUGH CARRY CAPACITY")

	if has_storage_target:
		storage_placeable = bool(_storage_placement.call("has_valid_placement"))
		var storage_prompt: String = String(_storage_placement.call("get_prompt_text"))
		if not storage_prompt.is_empty():
			if not prompt_lines.is_empty():
				prompt_lines.append("")
			prompt_lines.append(storage_prompt)

	if has_loot_target and loot_pickable:
		_set_aim_dot_color(DOT_PICKUP)
	elif has_storage_target and storage_placeable:
		_set_aim_dot_color(DOT_PLACE)
	else:
		_set_aim_dot_color(DOT_BLOCKED)

	_interaction_prompt.visible = true
	_interaction_prompt.text = "\n".join(prompt_lines)


func _get_looked_at_world_item() -> WorldItem:
	if camera == null or get_world_3d() == null:
		return null

	var ray_from: Vector3 = camera.global_position
	var forward: Vector3 = -camera.global_transform.basis.z.normalized()

	# Stored items deliberately share the more generous shelf interaction reach.
	# Loose/Receiving loot remains limited to the shorter normal pickup reach.
	var maximum_reach: float = maxf(
		interaction_distance,
		storage_interaction_distance
	)
	var ray_to: Vector3 = ray_from + (forward * maximum_reach)

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = ray_from
	query.to = ray_to
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

	var world_item: WorldItem = null
	var node: Node = collider_value as Node
	while node != null:
		if node is WorldItem:
			world_item = node as WorldItem
			break
		if node == get_tree().current_scene:
			break
		node = node.get_parent()

	if world_item == null:
		return null

	var hit_position_value: Variant = result.get("position", ray_from)
	var hit_position: Vector3 = hit_position_value as Vector3
	var hit_distance: float = ray_from.distance_to(hit_position)

	var allowed_distance: float = interaction_distance
	if world_item.is_stored_item():
		allowed_distance = storage_interaction_distance

	if hit_distance > allowed_distance:
		return null

	return world_item


func _try_open_zone_editor() -> void:
	if _zone_editor == null or _zone_editor_open:
		return

	var surface: Node = _get_looked_at_storage_surface()
	if surface == null:
		return

	_open_zone_editor_for_surface(surface)


func _open_zone_editor_for_surface(surface: Node) -> void:
	if (
		surface == null
		or _zone_editor == null
		or _zone_editor_open
	):
		return

	_zone_editor_open = true

	if _interaction_hud != null:
		_interaction_hud.visible = false

	if _held_item_view != null:
		_held_item_view.visible = false

	if _storage_placement != null:
		_storage_placement.call("set_suppressed", true)

	_zone_editor.call("open_for_surface", surface)


func _get_looked_at_storage_surface() -> Node:
	if camera == null or get_world_3d() == null:
		return null

	var ray_from: Vector3 = camera.global_position
	var forward: Vector3 = -camera.global_transform.basis.z.normalized()
	var ray_to: Vector3 = ray_from + forward * storage_interaction_distance

	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	query.from = ray_from
	query.to = ray_to
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = StorageSurfaceScript.STORAGE_INTERACTION_LAYER

	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return null

	var collider_value: Variant = result.get("collider")
	if not (collider_value is Node):
		return null

	var current: Node = collider_value as Node
	while current != null:
		if current is StorageSurface:
			return current
		if current == get_tree().current_scene:
			break
		current = current.get_parent()

	return null


func _build_storage_zone_editor() -> void:
	_zone_editor = StorageZoneEditorScript.new()
	_zone_editor.name = "StorageZoneEditor"
	add_child(_zone_editor)
	_zone_editor.editor_closed.connect(_on_zone_editor_closed)


func _on_zone_editor_closed() -> void:
	_zone_editor_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if _interaction_hud != null:
		_interaction_hud.visible = true

	if _held_item_view != null:
		_held_item_view.visible = true
		_refresh_held_item()

	if _storage_placement != null:
		_storage_placement.call("set_suppressed", false)
		_storage_placement.call("update_target")

	_update_interaction_target()


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
