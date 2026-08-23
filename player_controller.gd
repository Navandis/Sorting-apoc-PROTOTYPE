extends CharacterBody3D

@export var move_speed: float = 4.0
@export var sprint_multiplier: float = 2.0
@export var acceleration: float = 18.0
@export var deceleration: float = 24.0
@export_range(0.0005, 0.02, 0.0005) var mouse_sensitivity: float = 0.002
@export_range(45.0, 89.0, 1.0) var max_look_angle_degrees: float = 89.0

@onready var camera: Camera3D = $Camera3D

var _pitch: float = 0.0
var _gravity: float = 9.8


func _ready() -> void:
	_pitch = camera.rotation.x
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)

		_pitch -= event.relative.y * mouse_sensitivity
		var max_pitch := deg_to_rad(max_look_angle_degrees)
		_pitch = clamp(_pitch, -max_pitch, max_pitch)
		camera.rotation.x = _pitch

	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		# Keep the body planted when it is already resting on a floor.
		velocity.y = -0.1

	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0
	input_vector = input_vector.normalized()

	var speed := move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= sprint_multiplier

	var local_direction := Vector3(input_vector.x, 0.0, input_vector.y)
	var world_direction := (global_transform.basis * local_direction)
	world_direction.y = 0.0
	world_direction = world_direction.normalized()

	var target_x := world_direction.x * speed
	var target_z := world_direction.z * speed
	var rate := acceleration if input_vector != Vector2.ZERO else deceleration

	velocity.x = move_toward(velocity.x, target_x, rate * delta)
	velocity.z = move_toward(velocity.z, target_z, rate * delta)

	move_and_slide()
