extends Camera3D

@export var move_speed: float = 4.0
@export var sprint_multiplier: float = 2.5
@export_range(0.0005, 0.02, 0.0005) var mouse_sensitivity: float = 0.002

var _yaw: float
var _pitch: float


func _ready() -> void:
	# Preserve the camera's starting orientation from the scene.
	_yaw = rotation.y
	_pitch = rotation.x
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_pitch = clamp(_pitch, deg_to_rad(-89.0), deg_to_rad(89.0))
		rotation = Vector3(_pitch, _yaw, 0.0)

	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Click the game window to capture the mouse again after pressing Esc.
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	var move_direction := Vector3.ZERO

	# Keep WASD movement parallel to the floor even when looking up/down.
	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right := global_transform.basis.x
	right.y = 0.0
	right = right.normalized()

	if Input.is_key_pressed(KEY_W):
		move_direction += forward
	if Input.is_key_pressed(KEY_S):
		move_direction -= forward
	if Input.is_key_pressed(KEY_D):
		move_direction += right
	if Input.is_key_pressed(KEY_A):
		move_direction -= right

	# Optional fly-camera controls for inspecting imported assets.
	if Input.is_key_pressed(KEY_SPACE):
		move_direction += Vector3.UP
	if Input.is_key_pressed(KEY_CTRL):
		move_direction += Vector3.DOWN

	if move_direction.length_squared() == 0.0:
		return

	var speed := move_speed
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= sprint_multiplier

	global_position += move_direction.normalized() * speed * delta
