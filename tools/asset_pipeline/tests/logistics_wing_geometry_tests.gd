extends SceneTree

const REVIEW_PLAYER_PATH := "res://greybox/logistics_wing/review_player.tscn"
const WING_GEOMETRY_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const EXPECTED_MAIN_SCENE := "uid://drbkr86g3cxl1"

const REQUIRED_DISTRICTS := [
	"Receiving", "Backlog", "Sorting", "StorageSpine", "GalleryA",
	"GalleryB", "GalleryC", "GalleryD", "GalleryE", "MedicalApproach",
	"KitchenApproach", "WorkshopService", "Salvager", "DeeperApproach",
	"Incinerator", "BunkerOps",
]
const REQUIRED_ANCHORS := [
	"ReceivingApron", "SortingWork", "StorageNear", "GalleryA", "GalleryB",
	"GalleryC", "GalleryD", "GalleryE", "MedicalSafeSide",
	"KitchenSafeSide", "WorkshopSafeSide", "SalvagerFront",
	"BlockedContinuationSafeSide", "IncineratorFront", "BunkerOpsSafeSide",
	"DeeperClosureSafeSide", "CSecondaryWest", "DSecondaryEast",
]
const REQUIRED_EDGES := [
	"Receiving>Backlog", "Receiving>Dispatch", "Backlog>Sorting",
	"Sorting>StorageSpine", "Sorting>WorkshopService",
	"StorageSpine>GalleryA", "StorageSpine>GalleryB",
	"StorageSpine>GalleryC", "StorageSpine>GalleryD",
	"StorageSpine>GalleryE", "StorageSpine>MedicalApproach",
	"StorageSpine>KitchenApproach", "GalleryC>GalleryD",
	"StorageSpine>DeeperApproach", "WorkshopService>Salvager",
	"WorkshopService>BlockedContinuation", "DeeperApproach>Incinerator",
	"DeeperApproach>BunkerOps", "BunkerOps>DeeperSettlementClosure",
]
const FORBIDDEN_EDGES := [
	"GalleryE>DeeperApproach", "GalleryA>MedicalApproach",
	"GalleryB>KitchenApproach", "GalleryC>WorkshopService",
	"MedicalApproach>KitchenApproach", "Receiving>SurfaceRoute",
	"GalleryA>GalleryB", "GalleryA>GalleryC", "GalleryA>GalleryD",
	"GalleryA>GalleryE", "GalleryB>GalleryC", "GalleryB>GalleryD",
	"GalleryB>GalleryE", "GalleryC>GalleryE", "GalleryD>GalleryE",
]

var _failures := 0


func _init() -> void:
	_test_review_player_preserves_controller_contract()
	_test_complete_wing_geometry_contract()
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


# Catches omitted districts, accidental shortcuts, missing fixed boundaries,
# invisible runtime-only construction, and malformed primitive collision.
func _test_complete_wing_geometry_contract() -> void:
	if not _check(ResourceLoader.exists(WING_GEOMETRY_PATH), "wing geometry scene exists"):
		return
	var packed := load(WING_GEOMETRY_PATH) as PackedScene
	if not _check(packed != null, "wing geometry scene loads"):
		return
	var wing := packed.instantiate() as Node3D
	if not _check(wing != null, "wing geometry instantiates as Node3D"):
		return
	_check(String(wing.get_meta("layout_revision", "")) == "logistics-wing-greybox-v1", "layout revision is explicit")
	_check(wing.get_meta("regeneration_command", "") == "godot --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd", "single regeneration command is explicit")
	_check(wing.get_meta("overall_extents_m", Vector3.ZERO) == Vector3(104.0, 4.2, 53.0), "overall extents match the authored hypothesis")
	_check(is_equal_approx(float(wing.get_meta("wall_thickness_m", 0.0)), 0.30), "wall thickness metadata is 0.30 m")
	_check(is_equal_approx(float(wing.get_meta("clear_height_m", 0.0)), 3.40), "ordinary clear height metadata is 3.40 m")

	for district_name: String in REQUIRED_DISTRICTS:
		_check(wing.get_node_or_null("Districts/" + district_name) != null, "required district exists: " + district_name)
	for anchor_name: String in REQUIRED_ANCHORS:
		_check(wing.get_node_or_null("Anchors/" + anchor_name) is Marker3D, "required anchor exists: " + anchor_name)
	for required_path: String in [
		"Boundaries/FreightBarrier",
		"Boundaries/MedicalFrontageClosure",
		"Boundaries/KitchenFrontageClosure",
		"Boundaries/WorkshopFrontageClosure",
		"Boundaries/BlockedContinuation",
		"Boundaries/BunkerOpsFrontageClosure",
		"Boundaries/DeeperSettlementClosure",
		"Proxies/SortingTable",
		"Proxies/SalvagerMachine",
		"Proxies/IncineratorMachine",
	]:
		_check(wing.get_node_or_null(required_path) != null, "required boundary/proxy exists: " + required_path)

	# Catches a nominal safe-side marker that actually spawns the normal player
	# overlapping the retained blocked-continuation debris.
	var blocked_anchor := wing.get_node_or_null("Anchors/BlockedContinuationSafeSide") as Marker3D
	for debris_path: String in ["Boundaries/BlockedDebrisWest", "Boundaries/BlockedDebrisEast"]:
		var debris := wing.get_node_or_null(debris_path) as Node3D
		if blocked_anchor != null and debris != null:
			var collision := debris.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
			if collision != null and collision.shape is BoxShape3D:
				var clearance := _horizontal_point_to_box_distance(
					blocked_anchor.position,
					debris.position,
					(collision.shape as BoxShape3D).size
				)
				_check(clearance >= 0.39, "blocked-continuation safe anchor clears normal capsule at: " + debris_path)

	var topology_edges := wing.get_meta("topology_edges", PackedStringArray()) as PackedStringArray
	var forbidden_edges := wing.get_meta("forbidden_edges", PackedStringArray()) as PackedStringArray
	for edge: String in REQUIRED_EDGES:
		_check(topology_edges.has(edge), "required topology edge declared: " + edge)
		_check(not forbidden_edges.has(edge), "required edge is not forbidden: " + edge)
	for edge: String in FORBIDDEN_EDGES:
		_check(forbidden_edges.has(edge), "forbidden topology edge declared: " + edge)
		_check(not topology_edges.has(edge), "forbidden edge is absent: " + edge)

	var roof := wing.get_node_or_null("RoofVisuals") as Node3D
	_check(roof != null and roof.visible, "roof visuals exist and default visible")
	_check(_count_nodes_of_type(wing, StaticBody3D) > 50, "wing has authored static collision bodies")
	_check(_count_nodes_of_type(wing, MeshInstance3D) > 50, "wing has editor-visible primitive meshes")
	_validate_box_shapes(wing)
	wing.free()


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


func _count_nodes_of_type(node: Node, expected_type: Variant) -> int:
	var count := 1 if is_instance_of(node, expected_type) else 0
	for child in node.get_children():
		count += _count_nodes_of_type(child, expected_type)
	return count


func _validate_box_shapes(node: Node) -> void:
	if node is CollisionShape3D:
		var collision := node as CollisionShape3D
		if collision.shape is BoxShape3D:
			var size := (collision.shape as BoxShape3D).size
			_check(size.is_finite(), "box collision size is finite below: " + String(node.get_parent().get_parent().name))
			_check(size.x > 0.0 and size.y > 0.0 and size.z > 0.0, "box collision size is positive below: " + String(node.get_parent().get_parent().name))
	for child in node.get_children():
		_validate_box_shapes(child)


func _horizontal_point_to_box_distance(point: Vector3, center: Vector3, size: Vector3) -> float:
	var dx := maxf(absf(point.x - center.x) - size.x * 0.5, 0.0)
	var dz := maxf(absf(point.z - center.z) - size.z * 0.5, 0.0)
	return Vector2(dx, dz).length()


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failures += 1
	push_error("FAILED: " + message)
	return false
