extends SceneTree

const REVIEW_PLAYER_PATH := "res://greybox/logistics_wing/review_player.tscn"
const WING_GEOMETRY_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const EXPECTED_MAIN_SCENE := "uid://drbkr86g3cxl1"

const REQUIRED_DISTRICTS := [
	"Receiving", "Backlog", "Sorting", "StorageSpine", "GalleryA",
	"GalleryB", "GalleryC", "GalleryD", "GalleryE", "MedicalApproach",
	"KitchenApproach", "WorkshopService", "Salvager", "DeeperApproach",
	"Incinerator", "BunkerOps", "SharedABJunction",
]
const REQUIRED_ANCHORS := [
	"ReceivingApron", "Dispatch", "SortingWork", "StorageNear", "GalleryA", "GalleryB",
	"GalleryC", "GalleryD", "GalleryE", "MedicalSafeSide",
	"KitchenSafeSide", "WorkshopSafeSide", "SalvagerFront",
	"WorkshopApproach", "IncineratorFront", "BunkerOpsSafeSide",
	"DeeperClosureSafeSide", "CSecondaryWest", "DSecondaryEast",
	"SharedABJunction", "MedicalAnteroom", "KitchenService",
	"WorkshopService", "BunkerOpsLanding",
]
const REQUIRED_EDGES := [
	"Receiving>Backlog", "Receiving>Dispatch", "Backlog>Sorting",
	"Sorting>StorageSpine", "Sorting>WorkshopService",
	"StorageSpine>GalleryA", "StorageSpine>GalleryB",
	"StorageSpine>GalleryC", "StorageSpine>GalleryD",
	"StorageSpine>GalleryE", "StorageSpine>SharedABJunction",
	"SharedABJunction>GalleryA", "SharedABJunction>GalleryB",
	"SharedABJunction>MedicalApproach", "GalleryB>KitchenApproach",
	"GalleryC>GalleryD",
	"StorageSpine>DeeperApproach", "WorkshopService>Salvager",
	"DeeperApproach>Incinerator",
	"DeeperApproach>BunkerOps", "BunkerOps>DeeperSettlementClosure",
]
const FORBIDDEN_EDGES := [
	"GalleryE>DeeperApproach", "GalleryA>MedicalApproach",
	"StorageSpine>KitchenApproach", "GalleryC>WorkshopService",
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
	_check(String(wing.get_meta("layout_revision", "")) == "logistics-wing-greybox-round02-revision-02", "layout revision identifies the round-two correction")
	_check(wing.get_meta("regeneration_command", "") == "godot --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd", "single regeneration command is explicit")
	_check(wing.get_meta("overall_extents_m", Vector3.ZERO) == Vector3(110.0, 4.2, 55.0), "overall extents match the revised authored envelope")
	_check(is_equal_approx(float(wing.get_meta("wall_thickness_m", 0.0)), 0.30), "wall thickness metadata is 0.30 m")
	_check(is_equal_approx(float(wing.get_meta("clear_height_m", 0.0)), 3.40), "ordinary clear height metadata is 3.40 m")

	for district_name: String in REQUIRED_DISTRICTS:
		_check(wing.get_node_or_null("Districts/" + district_name) != null, "required district exists: " + district_name)
	for anchor_name: String in REQUIRED_ANCHORS:
		_check(wing.get_node_or_null("Anchors/" + anchor_name) is Marker3D, "required anchor exists: " + anchor_name)
	for required_path: String in [
		"Boundaries/FreightBarrier",
		"Boundaries/MedicalInnerBoundary",
		"Boundaries/KitchenInnerBoundary",
		"Boundaries/WorkshopInnerBoundary",
		"Boundaries/BunkerOpsInnerBoundary",
		"Boundaries/DeeperSettlementDoor",
		"Proxies/SortingTable",
		"Proxies/SalvagerMachine",
		"Proxies/IncineratorMachine",
		"Proxies/MedicalInterface",
		"Proxies/KitchenInterface",
		"Proxies/WorkshopInterface",
		"Proxies/BunkerOpsInterface",
	]:
		_check(wing.get_node_or_null(required_path) != null, "required boundary/proxy exists: " + required_path)
	for removed_path: String in [
		"Districts/WorkshopService/Floor_BlockedContinuationLip",
		"RoofVisuals/Ceiling_BlockedContinuationLip",
		"Districts/WorkshopService/ContinuationWest",
		"Districts/WorkshopService/ContinuationEast",
		"Districts/WorkshopService/ContinuationBack",
		"Boundaries/BlockedContinuation",
		"Boundaries/BlockedDebrisWest",
		"Boundaries/BlockedDebrisEast",
		"Anchors/BlockedContinuationSafeSide",
		"Districts/GalleryC/GalleryCDividerSouth",
	]:
		_check(wing.get_node_or_null(removed_path) == null, "superseded geometry is absent: " + removed_path)
	for removed_path: String in [
		"Boundaries/MedicalFrontageClosure",
		"Boundaries/KitchenFrontageClosure",
		"Boundaries/WorkshopFrontageClosure",
		"Boundaries/BunkerOpsFrontageClosure",
		"Boundaries/DeeperSettlementClosure",
	]:
		_check(wing.get_node_or_null(removed_path) == null, "obsolete frontage blocker is absent: " + removed_path)

	# These checks use the saved collision geometry rather than source text or
	# metadata, so an incorrect builder output cannot satisfy them nominally.
	_check_box(wing, "Districts/Receiving/Floor_ReceivingApron", Vector3(-33.75, -0.15, 0.0), Vector3(10.5, 0.30, 10.0), "Receiving Apron is shortened east-west but remains usable")
	_check_box(wing, "Districts/Receiving/Floor_FreightEnclosure", Vector3(-41.5, -0.15, 0.0), Vector3(5.0, 0.30, 7.0), "freight enclosure is distinct and shallow")
	_check_box(wing, "Districts/Receiving/Floor_DispatchAnnex", Vector3(-33.25, -0.15, -6.75), Vector3(9.5, 0.30, 3.5), "Dispatch remains a shallow external annex")
	_check_box(wing, "Districts/Receiving/ReceivingCeilingTransition", Vector3(-28.65, 3.8, 0.0), Vector3(0.30, 0.80, 3.84), "Receiving-to-Backlog height strip stays on the Receiving side")
	_check_box(wing, "Districts/Sorting/Floor_SortingPocket", Vector3(-10.0, -0.15, -6.1), Vector3(8.0, 0.30, 2.2), "Sorting work pocket extends north")
	_check_box(wing, "Proxies/SortingTable", Vector3(-10.0, 0.45, -6.18), Vector3(4.8, 0.90, 1.74), "Sorting table has revised depth and end access")
	_check_box(wing, "Districts/SharedABJunction/Floor_SharedABJunction", Vector3(6.75, -0.15, -7.25), Vector3(4.5, 0.30, 11.5), "shared A/B junction owns the run between the galleries")
	_check_box(wing, "Districts/MedicalApproach/Floor_MedicalCorridor", Vector3(7.0, -0.15, -14.5), Vector3(2.4, 0.30, 3.0), "Medical protected approach begins beyond A and B")
	_check_box(wing, "Districts/MedicalApproach/Floor_MedicalAnteroom", Vector3(6.9, -0.15, -19.5), Vector3(7.8, 0.30, 7.0), "Medical room moves north without changing its useful footprint")
	_check_box(wing, "Districts/GalleryC/GalleryCIrregularSouthMass", Vector3(4.0, 1.7, 13.25), Vector3(4.0, 3.4, 3.5), "C irregular solid performs the southern C-D separation")
	_check_box(wing, "Districts/GalleryE/Floor_GalleryEMain", Vector3(21.5, -0.15, 11.2), Vector3(8.0, 0.30, 8.4), "Gallery E main section is moved south")
	_check_box(wing, "Districts/GalleryE/Floor_GalleryESouthProjection", Vector3(22.25, -0.15, 18.2), Vector3(6.5, 0.30, 5.6), "Gallery E southern projection is forty percent of total length")
	_check_box(wing, "Districts/WorkshopService/WorkshopRoomSouth", Vector3(-12.0, 1.7, 25.0), Vector3(12.3, 3.4, 0.30), "Workshop ends at one continuous joined full-height south wall")
	_check_box(wing, "Proxies/SalvagerMachine", Vector3(5.0, 1.45, 26.5), Vector3(5.4, 2.90, 3.0), "Salvager machine and enclosure move toward the revised approach")
	_check_box(wing, "Districts/DeeperApproach/Floor_DeeperWide", Vector3(34.0, -0.15, 2.25), Vector3(16.0, 0.30, 4.5), "Deeper pre-bend authored run is sixteen metres")
	_check_box(wing, "Districts/StorageSpine/SpineEastSouthReturn", Vector3(26.0, 1.7, 5.4), Vector3(0.30, 3.4, 3.2), "Storage-to-Deeper south return closes the full spine perimeter without an exterior seam")
	_check_box(wing, "Districts/DeeperApproach/Floor_DeeperNarrow", Vector3(51.0, -0.15, -5.5), Vector3(16.0, 0.30, 3.0), "Deeper post-bend authored run is sixteen metres")
	_check_box(wing, "Districts/Incinerator/Floor_IncineratorPocket", Vector3(31.5, -0.15, 13.5), Vector3(7.0, 0.30, 7.0), "Incinerator pocket is approximately thirty percent narrower")
	_check_box(wing, "Boundaries/DeeperSettlementDoor", Vector3(66.0, 1.45, -6.8), Vector3(0.65, 2.90, 2.4), "deeper closure moves with the Ops terminal")
	_check_no_positive_box_overlap(wing, "RoofVisuals/Ceiling_BacklogPassage", "Districts/Receiving/ReceivingCeilingTransition", "Receiving transition does not overlap the Backlog ceiling")
	_check_no_positive_box_overlap(wing, "Districts/GalleryA/Floor_GalleryAMain", "Districts/MedicalApproach/Floor_MedicalAnteroom", "Medical floor does not overlap Gallery A")
	_check_no_positive_box_overlap(wing, "RoofVisuals/Ceiling_GalleryAMain", "RoofVisuals/Ceiling_MedicalAnteroom", "Medical ceiling does not overlap Gallery A")
	_check_segment_clear_of_structural_walls(wing, Vector3(-10.0, 1.7162851, -4.4), Vector3(-38.82, 1.7162851, 2.2), "Sorting work stance has a partial freight-aperture sightline")
	for junction_sample: Vector3 in [
		Vector3(-18.10, 1.0, 14.90),
		Vector3(18.90, 1.0, -25.10),
		Vector3(25.60, 1.0, 21.10),
	]:
		_check_point_inside_static_box(wing, junction_sample, "joined structural corner is solid at %s" % junction_sample)

	for opening: Dictionary in [
		{"point": Vector3(-33.0, 1.0, -5.0), "label": "Dispatch framed doorless opening"},
		{"point": Vector3(-28.5, 1.0, 0.0), "label": "narrow Receiving-to-Backlog opening"},
		{"point": Vector3(-21.0, 1.0, -0.48), "label": "narrow Backlog-to-Sorting opening"},
		{"point": Vector3(4.5, 1.0, -8.2), "label": "north-shifted Gallery A east opening"},
		{"point": Vector3(9.0, 1.0, -8.2), "label": "north-shifted Gallery B west opening"},
		{"point": Vector3(16.5, 1.0, -6.8), "label": "Gallery B east Kitchen opening"},
		{"point": Vector3(6.0, 1.0, 10.25), "label": "sole C-to-D secondary opening"},
		{"point": Vector3(7.0, 1.0, -16.0), "label": "Medical territorial entrance"},
		{"point": Vector3(22.6, 1.0, -18.0), "label": "Kitchen territorial entrance"},
		{"point": Vector3(-10.0, 1.0, 15.0), "label": "Workshop territorial entrance"},
		{"point": Vector3(59.0, 1.0, -5.5), "label": "Bunker Ops landing entrance"},
	]:
		_check_point_clear_of_static_boxes(wing, opening["point"] as Vector3, String(opening["label"]))
	_check_no_collinear_wall_overlaps(wing)

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


func _check_box(wing: Node3D, path: String, expected_center: Vector3, expected_size: Vector3, message: String) -> void:
	var box := wing.get_node_or_null(path) as Node3D
	if not _check(box != null, message + " exists"):
		return
	var collision := box.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
	if not _check(collision != null and collision.shape is BoxShape3D, message + " has box collision"):
		return
	_check(box.position.is_equal_approx(expected_center), message + " center is exact")
	_check((collision.shape as BoxShape3D).size.is_equal_approx(expected_size), message + " size is exact")


func _check_point_clear_of_static_boxes(wing: Node3D, point: Vector3, message: String) -> void:
	var blockers: Array[String] = []
	_collect_point_blockers(wing, point, blockers)
	_check(blockers.is_empty(), message + " is physically clear; blockers=" + ", ".join(blockers))


func _check_point_inside_static_box(wing: Node3D, point: Vector3, message: String) -> void:
	var blockers: Array[String] = []
	_collect_point_blockers(wing, point, blockers)
	_check(not blockers.is_empty(), message + "; no structural owner found")


func _check_no_positive_box_overlap(wing: Node3D, first_path: String, second_path: String, message: String) -> void:
	var first := wing.get_node_or_null(first_path) as Node3D
	var second := wing.get_node_or_null(second_path) as Node3D
	if not _check(first != null and second != null, message + " boxes exist"):
		return
	var first_shape := first.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
	var second_shape := second.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
	if not _check(first_shape != null and first_shape.shape is BoxShape3D and second_shape != null and second_shape.shape is BoxShape3D, message + " boxes have collision"):
		return
	var first_size := (first_shape.shape as BoxShape3D).size
	var second_size := (second_shape.shape as BoxShape3D).size
	var overlap := (first_size + second_size) * 0.5 - (first.position - second.position).abs()
	_check(overlap.x <= 0.001 or overlap.y <= 0.001 or overlap.z <= 0.001, message + "; overlap=%s" % overlap)


func _check_segment_clear_of_structural_walls(wing: Node3D, start: Vector3, finish: Vector3, message: String) -> void:
	var blockers: Array[String] = []
	_collect_segment_blockers(wing.get_node("Districts"), start, finish, blockers)
	_check(blockers.is_empty(), message + "; blockers=" + ", ".join(blockers))


func _collect_segment_blockers(node: Node, start: Vector3, finish: Vector3, blockers: Array[String]) -> void:
	if node is CollisionShape3D:
		var collision := node as CollisionShape3D
		if collision.shape is BoxShape3D:
			var size := (collision.shape as BoxShape3D).size
			if size.y >= 3.39:
				var container := collision.get_parent().get_parent() as Node3D
				if _segment_intersects_box_xz(start, finish, container.position, size):
					blockers.append("%s/%s" % [container.get_parent().name, container.name])
	for child in node.get_children():
		_collect_segment_blockers(child, start, finish, blockers)


func _segment_intersects_box_xz(start: Vector3, finish: Vector3, center: Vector3, size: Vector3) -> bool:
	var t_min := 0.0
	var t_max := 1.0
	var delta := finish - start
	for axis: String in ["x", "z"]:
		var origin := start.x if axis == "x" else start.z
		var direction := delta.x if axis == "x" else delta.z
		var half := (size.x if axis == "x" else size.z) * 0.5
		var box_center := center.x if axis == "x" else center.z
		var minimum := box_center - half
		var maximum := box_center + half
		if absf(direction) < 0.000001:
			if origin < minimum or origin > maximum:
				return false
			continue
		var first_t := (minimum - origin) / direction
		var second_t := (maximum - origin) / direction
		if first_t > second_t:
			var swap := first_t
			first_t = second_t
			second_t = swap
		t_min = maxf(t_min, first_t)
		t_max = minf(t_max, second_t)
		if t_min > t_max:
			return false
	return t_max > 0.001 and t_min < 0.999


func _collect_point_blockers(node: Node, point: Vector3, blockers: Array[String]) -> void:
	if node is CollisionShape3D:
		var collision := node as CollisionShape3D
		if collision.shape is BoxShape3D:
			var size := (collision.shape as BoxShape3D).size
			var container := collision.get_parent().get_parent() as Node3D
			var center := container.position
			var half := size * 0.5
			if (
				absf(point.x - center.x) < half.x - 0.01
				and absf(point.y - center.y) < half.y - 0.01
				and absf(point.z - center.z) < half.z - 0.01
			):
				blockers.append("%s/%s" % [container.get_parent().name, container.name])
	for child in node.get_children():
		_collect_point_blockers(child, point, blockers)


func _check_no_collinear_wall_overlaps(wing: Node3D) -> void:
	var districts := wing.get_node_or_null("Districts") as Node3D
	if not _check(districts != null, "district root exists for wall-ownership audit"):
		return
	var walls: Array[Dictionary] = []
	_collect_wall_records(districts, walls)
	var overlaps: Array[String] = []
	for first_index: int in walls.size():
		var first := walls[first_index]
		for second_index: int in range(first_index + 1, walls.size()):
			var second := walls[second_index]
			if first["axis"] != second["axis"]:
				continue
			if not is_equal_approx(float(first["line"]), float(second["line"])):
				continue
			var overlap := minf(float(first["end"]), float(second["end"])) - maxf(float(first["start"]), float(second["start"]))
			if overlap > 0.01:
				overlaps.append("%s <> %s (%.2f m)" % [first["path"], second["path"], overlap])
	_check(overlaps.is_empty(), "structural walls have one physical owner; overlaps=" + "; ".join(overlaps))


func _collect_wall_records(node: Node, records: Array[Dictionary]) -> void:
	if node is CollisionShape3D:
		var collision := node as CollisionShape3D
		if collision.shape is BoxShape3D:
			var size := (collision.shape as BoxShape3D).size
			if size.y >= 3.39:
				var container := collision.get_parent().get_parent() as Node3D
				var center := container.position
				var record_path := "%s/%s" % [container.get_parent().name, container.name]
				if is_equal_approx(size.z, 0.30) and size.x > 0.30:
					records.append({"axis": "x", "line": center.z, "start": center.x - size.x * 0.5, "end": center.x + size.x * 0.5, "path": record_path})
				elif is_equal_approx(size.x, 0.30) and size.z > 0.30:
					records.append({"axis": "z", "line": center.x, "start": center.z - size.z * 0.5, "end": center.z + size.z * 0.5, "path": record_path})
	for child in node.get_children():
		_collect_wall_records(child, records)


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
