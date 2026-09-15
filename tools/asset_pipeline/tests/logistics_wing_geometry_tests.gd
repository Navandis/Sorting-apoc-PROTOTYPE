extends SceneTree

const REVIEW_PLAYER_PATH := "res://greybox/logistics_wing/review_player.tscn"
const EXPECTED_MAIN_SCENE := "uid://drbkr86g3cxl1"

var _failures := 0


func _init() -> void:
	_test_review_player_preserves_controller_contract()
	_test_default_launch_remains_the_storage_fixture()
	if _failures > 0:
		push_error("FAIL: logistics wing geometry contract (%d checks)" % _failures)
		quit(1)
		return
	print("PASS: logistics wing geometry contract")
	quit(0)


# Catches a review harness that makes the wing seem usable by changing the
# controller speed, view, or collision envelope instead of fixing geometry.
func _test_review_player_preserves_controller_contract() -> void:
	if not _check(ResourceLoader.exists(REVIEW_PLAYER_PATH), "review player scene exists"):
		return
	var packed := load(REVIEW_PLAYER_PATH) as PackedScene
	if not _check(packed != null, "review player scene loads"):
		return
	var player := packed.instantiate() as CharacterBody3D
	if not _check(player != null, "review player instantiates as CharacterBody3D"):
		return
	_check(player.get_script() != null, "review player has controller script")
	if player.get_script() != null:
		_check(player.get_script().resource_path == "res://player_controller.gd", "review player reuses the original controller")
	_check(is_equal_approx(float(player.get("move_speed")), 4.0), "walk speed remains 4.0 m/s")
	_check(is_equal_approx(float(player.get("sprint_multiplier")), 2.0), "sprint multiplier remains 2.0")
	_check(is_equal_approx(float(player.get("acceleration")), 18.0), "acceleration remains 18.0")
	_check(is_equal_approx(float(player.get("deceleration")), 24.0), "deceleration remains 24.0")
	_check(player.get("prototype_auto_register_known_loot") == false, "review scene disables prototype loot registration locally")
	_check(player.get("print_loot_registration") == false, "review scene disables registration logging locally")
	_check(player.get("enable_held_item_view") == false, "review scene disables held-item presentation locally")

	var collision := player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	_check(collision != null, "review player has CollisionShape3D")
	if collision != null:
		var capsule := collision.shape as CapsuleShape3D
		_check(capsule != null, "review player uses a capsule")
		if capsule != null:
			_check(is_equal_approx(capsule.radius, 0.34), "capsule radius remains 0.34 m")
			_check(is_equal_approx(capsule.height, 1.75), "capsule height remains 1.75 m")
		_check(is_equal_approx(collision.position.y, 0.875), "capsule center remains 0.875 m high")

	var camera := player.get_node_or_null("Camera3D") as Camera3D
	_check(camera != null, "review player has Camera3D")
	if camera != null:
		_check(is_equal_approx(camera.position.y, 1.7162851), "camera eye height matches main.tscn")
		_check(is_equal_approx(camera.fov, 75.0), "camera FOV remains the Godot 75 degree default")
		_check(camera.current, "review camera is current")
	_check(_count_cameras(player) == 1, "review player contains exactly one camera")

	var carried := player.get_node_or_null("CarriedItems")
	_check(carried != null, "review player keeps required CarriedItems child")
	if carried != null:
		_check(carried.get_script() != null, "CarriedItems has its script")
		if carried.get_script() != null:
			_check(carried.get_script().resource_path == "res://carried_items.gd", "review player reuses original CarriedItems script")
	player.free()


# Catches accidental replacement of the project's default launch scene.
func _test_default_launch_remains_the_storage_fixture() -> void:
	_check(
		String(ProjectSettings.get_setting("application/run/main_scene", "")) == EXPECTED_MAIN_SCENE,
		"project default launch remains main.tscn"
	)


func _count_cameras(node: Node) -> int:
	var count := 1 if node is Camera3D else 0
	for child in node.get_children():
		count += _count_cameras(child)
	return count


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failures += 1
	push_error("FAILED: " + message)
	return false
