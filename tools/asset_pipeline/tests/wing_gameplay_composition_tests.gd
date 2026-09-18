extends SceneTree

const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const GEOMETRY_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const PLAYER_SCRIPT_PATH := "res://player_controller.gd"
const CARRIED_SCRIPT_PATH := "res://carried_items.gd"
const HUD_SCRIPT_PATH := "res://carried_items_hud.gd"

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check(ResourceLoader.exists(GAMEPLAY_PATH), "continuing gameplay scene exists"):
		_finish()
		return

	var packed := load(GAMEPLAY_PATH) as PackedScene
	if not _check(packed != null, "continuing gameplay scene loads"):
		_finish()
		return

	var direct := packed.instantiate()
	root.add_child(direct)
	current_scene = direct
	await process_frame
	await physics_frame
	_assert_composition(direct, "direct")
	root.remove_child(direct)
	direct.free()
	current_scene = null

	var host := Node3D.new()
	host.name = "IdentityHost"
	root.add_child(host)
	current_scene = host
	var parented := packed.instantiate()
	host.add_child(parented)
	await process_frame
	await physics_frame
	_assert_composition(parented, "parent-hosted")
	host.free()
	current_scene = null

	_finish()


func _assert_composition(scene: Node, context: String) -> void:
	var player := scene.get_node_or_null("Player") as CharacterBody3D
	var carried := scene.get_node_or_null("Player/CarriedItems")
	var hud := scene.get_node_or_null("HUD/CarriedItemsHUD")
	var environment := scene.get_node_or_null("Environment") as Node3D

	_check(player != null, "%s composition has full gameplay player" % context)
	_check(carried != null, "%s composition has carried-items container" % context)
	_check(hud != null, "%s composition has carried-items HUD" % context)
	_check(environment != null, "%s composition has environment wrapper" % context)
	if player == null or carried == null or hud == null or environment == null:
		return

	_check(
		player.get_script() != null
		and player.get_script().resource_path == PLAYER_SCRIPT_PATH,
		"%s player reuses the shared controller" % context
	)
	_check(
		carried.get_script() != null
		and carried.get_script().resource_path == CARRIED_SCRIPT_PATH,
		"%s player reuses the shared carried-items script" % context
	)
	_check(
		hud.get_script() != null
		and hud.get_script().resource_path == HUD_SCRIPT_PATH,
		"%s HUD reuses the shared carried-items HUD" % context
	)
	_check(
		is_equal_approx(float(player.get("interaction_distance")), 1.4),
		"%s pickup reach preserves main override" % context
	)
	_check(
		is_equal_approx(float(player.get("storage_interaction_distance")), 2.3),
		"%s storage reach preserves main override" % context
	)
	_check(
		player.get("prototype_auto_register_known_loot") == false,
		"%s raw-loot registration is disabled locally" % context
	)
	_check(
		player.get("print_loot_registration") == false,
		"%s registration logging is disabled locally" % context
	)
	_check(
		player.get("enable_held_item_view") == true,
		"%s held-item view remains enabled" % context
	)

	var collision := player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	var camera := player.get_node_or_null("Camera3D") as Camera3D
	_check(collision != null, "%s player has collision shape" % context)
	_check(camera != null, "%s player has direct camera" % context)
	if collision != null:
		var capsule := collision.shape as CapsuleShape3D
		_check(capsule != null, "%s player keeps capsule shape" % context)
		if capsule != null:
			_check(is_equal_approx(capsule.radius, 0.34), "%s capsule radius is preserved" % context)
			_check(is_equal_approx(capsule.height, 1.75), "%s capsule height is preserved" % context)
		_check(is_equal_approx(collision.position.y, 0.875), "%s capsule center is preserved" % context)
	if camera != null:
		_check(
			camera.position.is_equal_approx(Vector3(-0.00447291, 1.7162851, -0.13648391)),
			"%s camera position preserves main offsets" % context
		)
		_check(is_equal_approx(camera.fov, 75.0), "%s camera FOV is preserved" % context)
		_check(camera.current, "%s camera is current" % context)

	_check(
		hud.get("carried_items_path") == NodePath("../../Player/CarriedItems"),
		"%s HUD has explicit carried-items path" % context
	)
	_check(
		hud.get("_carried_items") == carried,
		"%s HUD resolves the gameplay player's container before readiness" % context
	)
	_check(_count_current_cameras(scene) == 1, "%s composition has exactly one current camera" % context)
	_check(
		scene.find_children("*", "WorldEnvironment", true, false).size() == 1,
		"%s composition has exactly one world environment" % context
	)

	var greybox := environment.get_node_or_null("Greybox") as Node3D
	_check(greybox != null, "%s environment instances accepted geometry" % context)
	if greybox != null:
		_check(
			greybox.scene_file_path == GEOMETRY_PATH,
			"%s environment references accepted geometry path" % context
		)
	_check(
		scene.find_child("ReviewPlayer", true, false) == null,
		"%s composition omits neutral-review player" % context
	)
	_check(
		not _instances_scene(scene, "res://main.tscn"),
		"%s composition does not embed historical main" % context
	)
	_check(
		not _instances_scene(scene, "res://greybox/logistics_wing/wing_review.tscn"),
		"%s composition does not embed neutral-review harness" % context
	)


func _count_current_cameras(root_node: Node) -> int:
	var count := 0
	for value: Node in root_node.find_children("*", "Camera3D", true, false):
		var camera := value as Camera3D
		if camera != null and camera.current:
			count += 1
	return count


func _instances_scene(root_node: Node, scene_path: String) -> bool:
	if root_node.scene_file_path == scene_path:
		return true
	for child: Node in root_node.find_children("*", "Node", true, false):
		if child.scene_file_path == scene_path:
			return true
	return false


func _finish() -> void:
	if _failed:
		push_error("FAIL: wing gameplay composition tests")
		quit(1)
		return
	print("PASS: wing gameplay composition tests")
	quit(0)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false
