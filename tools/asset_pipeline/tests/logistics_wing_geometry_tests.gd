extends SceneTree

const REVIEW_PLAYER_PATH := "res://greybox/logistics_wing/review_player.tscn"
const WING_GEOMETRY_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const EXPECTED_MAIN_SCENE := "uid://drbkr86g3cxl1"
const WALL_HALF_THICKNESS := 0.15
const JUNCTION_EVIDENCE_FLAG := "--junction-evidence"
const JUNCTION_BASELINE_PREFIX := "--junction-baseline="
const JUNCTION_SOURCE_COMMIT_PREFIX := "--junction-source-commit="
const JUNCTION_EVIDENCE_PATH := "res://reports/logistics_wing/greybox/revision_04/junction_inventory.json"
const ROUND_TWO_FINAL_COMMIT := "66b7c18f54c45c6b682970b1971dd2bc6e5f099a"
const COLLISIONLESS_BOX_PATHS := [
	"Proxies/MedicalInterface",
	"Proxies/KitchenInterface",
	"Proxies/WorkshopInterface",
	"Proxies/BunkerOpsInterface",
]

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
	if OS.get_cmdline_user_args().has(JUNCTION_EVIDENCE_FLAG):
		var evidence_error := _write_junction_evidence(OS.get_cmdline_user_args())
		if evidence_error != OK:
			push_error("FAIL: could not write junction inventory: " + error_string(evidence_error))
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
	_check(String(wing.get_meta("layout_revision", "")) == "logistics-wing-greybox-medical-tuning-revision-04", "layout revision identifies the Medical-only tuning")
	_check(wing.get_meta("regeneration_command", "") == "godot --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd", "single regeneration command is explicit")
	_check(wing.get_meta("overall_extents_m", Vector3.ZERO) == Vector3(110.0, 4.2, 58.5), "overall extents include the north-translated Medical room")
	_check(String(wing.get_meta("shared_ab_measurement_group", "")) == "MainStorage", "shared A/B connector belongs to the Main Storage measurement group")
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
		"Districts/GalleryC/GalleryCIrregularSouthMass",
		"Districts/MedicalApproach/MedicalRoomSouthEast",
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
	_check_box(wing, "Districts/Receiving/ReceivingCeilingTransition", Vector3(-28.5, 3.8, 0.0), Vector3(0.30, 0.80, 3.84), "Receiving-to-Backlog height strip aligns with the doorway depth planes")
	_check_box(wing, "Districts/Backlog/Floor_BacklogPassage", Vector3(-21.75, -0.15, 0.0), Vector3(13.5, 0.30, 7.6), "Backlog regains its approved 13.5 m nominal span")
	_check_box(wing, "RoofVisuals/Ceiling_BacklogPassage", Vector3(-21.675, 3.55, 0.0), Vector3(13.35, 0.30, 7.6), "Backlog lower ceiling terminates at the aligned closure face")
	_check_box(wing, "Districts/Sorting/Floor_SortingPassage", Vector3(-10.0, -0.15, 0.0), Vector3(10.0, 0.30, 10.0), "Sorting returns to its approved 10 m nominal span")
	_check_box(wing, "Districts/Backlog/BacklogEastNorth", Vector3(-15.0, 1.7, -3.6), Vector3(0.30, 3.4, 0.4), "authorized northern jamb creates the real desk sightline bundle")
	_check_box(wing, "Districts/Backlog/BacklogEastSouth", Vector3(-15.0, 1.7, 2.62), Vector3(0.30, 3.4, 2.36), "Backlog/Sorting southern jamb remains at Z=1.44")
	_check_box(wing, "Districts/Sorting/Floor_SortingPocket", Vector3(-10.0, -0.15, -6.1), Vector3(8.0, 0.30, 2.2), "Sorting work pocket extends north")
	_check_box(wing, "Proxies/SortingTable", Vector3(-10.0, 0.45, -6.18), Vector3(4.8, 0.90, 1.74), "Sorting table has revised depth and end access")
	_check_box(wing, "Districts/SharedABJunction/Floor_SharedABJunction", Vector3(6.75, -0.15, -7.25), Vector3(4.5, 0.30, 11.5), "Main Storage A/B connector retains its accepted footprint")
	_check_material_name(wing, "Districts/SharedABJunction/Floor_SharedABJunction", "Greybox Storage Floor", "A/B connector uses the Storage diagnostic floor treatment")
	_check_box(wing, "Districts/MedicalApproach/Floor_MedicalCorridor", Vector3(7.0, -0.15, -18.0), Vector3(2.4, 0.30, 10.0), "Medical-exclusive corridor doubles from five to ten nominal metres")
	_check_box(wing, "Districts/MedicalApproach/Floor_MedicalAnteroom", Vector3(4.3, -0.15, -26.5), Vector3(7.8, 0.30, 7.0), "Medical room translates north-west without changing its footprint")
	_check_box(wing, "Districts/MedicalApproach/MedicalCorridorWest", Vector3(5.8, 1.7, -18.0), Vector3(0.30, 3.4, 10.0), "Medical corridor west wall follows the doubled exclusive run")
	_check_box(wing, "Districts/MedicalApproach/MedicalCorridorEast", Vector3(8.2, 1.7, -18.0), Vector3(0.30, 3.4, 10.0), "Medical corridor east wall follows the doubled exclusive run")
	_check_box(wing, "Districts/MedicalApproach/MedicalRoomSouthWest", Vector3(3.1, 1.7, -23.0), Vector3(5.70, 3.4, 0.30), "Medical room has only the west shoulder at its south-east entrance")
	_check_box(wing, "Districts/MedicalApproach/MedicalRoomWest", Vector3(0.4, 1.7, -26.5), Vector3(0.30, 3.4, 7.30), "Medical room west wall translates without changing nominal depth")
	_check_box(wing, "Districts/MedicalApproach/MedicalRoomEast", Vector3(8.2, 1.7, -26.575), Vector3(0.30, 3.4, 7.15), "Medical room east wall is collinear and face-continuous with the corridor east wall")
	_check_box(wing, "Boundaries/MedicalInnerBoundary", Vector3(4.3, 1.7, -30.0), Vector3(7.8, 3.4, 0.30), "Medical staffed-core boundary translates with the unchanged room")
	_check_visual_box(wing, "Proxies/MedicalInterface", Vector3(4.3, 0.60, -29.15), Vector3(3.6, 1.2, 0.6), "Medical provisional interface translates with the room")
	var medical_anteroom_anchor := wing.get_node_or_null("Anchors/MedicalAnteroom") as Marker3D
	var medical_safe_anchor := wing.get_node_or_null("Anchors/MedicalSafeSide") as Marker3D
	_check(medical_anteroom_anchor != null and medical_anteroom_anchor.position == Vector3(4.3, 0.05, -26.5), "Medical anteroom anchor translates with the room")
	_check(medical_safe_anchor != null and medical_safe_anchor.position == Vector3(4.3, 0.05, -28.0), "Medical safe-side anchor remains inside the moved room")
	_check_box(wing, "Districts/GalleryC/GalleryCInsetWest", Vector3(2.0, 1.7, 13.25), Vector3(0.30, 3.4, 3.5), "C folded perimeter turns north at the red-overlay inset")
	_check_box(wing, "Districts/GalleryC/GalleryCInsetCap", Vector3(4.0, 1.7, 11.5), Vector3(4.30, 3.4, 0.30), "C folded perimeter caps east to the D-side return")
	_check_box(wing, "Districts/GalleryD/GalleryDWestSouthReturn", Vector3(6.0, 1.7, 14.5), Vector3(0.30, 3.4, 6.0), "D western return closes the complete 11.5 to 17.5 span")
	_check_box(wing, "Districts/GalleryE/Floor_GalleryEMain", Vector3(21.5, -0.15, 11.2), Vector3(8.0, 0.30, 8.4), "Gallery E main section is moved south")
	_check_box(wing, "Districts/GalleryE/Floor_GalleryESouthProjection", Vector3(22.25, -0.15, 18.2), Vector3(6.5, 0.30, 5.6), "Gallery E southern projection is forty percent of total length")
	_check_box(wing, "Districts/WorkshopService/WorkshopRoomSouth", Vector3(-12.0, 1.7, 25.0), Vector3(12.3, 3.4, 0.30), "Workshop ends at one continuous joined full-height south wall")
	_check_box(wing, "Districts/Salvager/Floor_SalvagerPocket", Vector3(5.0, -0.15, 26.0), Vector3(6.0, 0.30, 5.0), "Salvager pocket ends with the tightened rear enclosure")
	_check_box(wing, "Districts/Salvager/SalvagerPocketWest", Vector3(2.0, 1.7, 26.25), Vector3(0.30, 3.4, 4.80), "Salvager pocket west wall begins flush at the elbow and joins the rear wall")
	_check_box(wing, "Districts/Salvager/SalvagerBack", Vector3(5.0, 1.7, 28.5), Vector3(6.30, 3.4, 0.30), "Salvager back wall leaves only 0.35 m behind the unchanged machine")
	_check_box(wing, "Proxies/SalvagerMachine", Vector3(5.0, 1.45, 26.5), Vector3(5.4, 2.90, 3.0), "Salvager machine stays fixed while its enclosure tightens")
	_check_z_face_clearance(wing, "Proxies/SalvagerMachine", "Districts/Salvager/SalvagerBack", 0.35, "Salvager machine rear-to-wall inside-face clearance is exact and intentionally non-traversable")
	_check_box(wing, "Districts/KitchenApproach/Floor_KitchenEastLeg", Vector3(21.45, -0.15, -6.8), Vector3(9.9, 0.30, 2.8), "Kitchen initial eastbound floor reaches the translated elbow")
	_check_box(wing, "Districts/KitchenApproach/Floor_KitchenNorthLeg", Vector3(25.0, -0.15, -13.1), Vector3(2.8, 0.30, 9.8), "Kitchen north leg translates coherently without changing width or length")
	_check_box(wing, "Districts/KitchenApproach/Floor_KitchenServiceRoom", Vector3(26.65, -0.15, -21.5), Vector3(10.5, 0.30, 7.0), "Kitchen room translates east without changing size")
	_check_box(wing, "Districts/DeeperApproach/Floor_DeeperWide", Vector3(34.0, -0.15, 2.25), Vector3(16.0, 0.30, 4.5), "Deeper pre-bend authored run is sixteen metres")
	_check_box(wing, "Districts/StorageSpine/SpineEastSouthReturn", Vector3(26.0, 1.7, 5.4), Vector3(0.30, 3.4, 3.2), "Storage-to-Deeper south return closes the full spine perimeter without an exterior seam")
	_check_box(wing, "Districts/DeeperApproach/Floor_DeeperNarrow", Vector3(51.0, -0.15, -5.5), Vector3(16.0, 0.30, 3.0), "Deeper post-bend authored run is sixteen metres")
	_check_box(wing, "Districts/Incinerator/Floor_IncineratorPocket", Vector3(36.5, -0.15, 13.5), Vector3(7.0, 0.30, 7.0), "Incinerator pocket moves east as one unchanged installation")
	_check_box(wing, "Districts/Incinerator/IncineratorApproachWest", Vector3(34.5, 1.7, 7.25), Vector3(0.30, 3.4, 5.5), "Incinerator new mouth west side follows the translated approach")
	_check_box(wing, "Districts/Incinerator/IncineratorApproachEast", Vector3(38.5, 1.7, 7.25), Vector3(0.30, 3.4, 5.5), "Incinerator new mouth east side follows the translated approach")
	_check_box(wing, "Districts/Incinerator/IncineratorPocketNorthWest", Vector3(33.75, 1.7, 10.0), Vector3(1.80, 3.4, 0.30), "Incinerator west front shoulder leaves only the intended translated entrance")
	_check_box(wing, "Districts/Incinerator/IncineratorPocketNorthEast", Vector3(39.25, 1.7, 10.0), Vector3(1.80, 3.4, 0.30), "Incinerator east front shoulder leaves only the intended translated entrance")
	_check_box(wing, "Districts/Incinerator/IncineratorPocketWest", Vector3(33.0, 1.7, 13.5), Vector3(0.30, 3.4, 7.0), "Incinerator west side wall translates intact")
	_check_box(wing, "Districts/Incinerator/IncineratorPocketEast", Vector3(40.0, 1.7, 13.5), Vector3(0.30, 3.4, 7.0), "Incinerator east side wall translates intact")
	_check_box(wing, "Districts/Incinerator/IncineratorPocketBack", Vector3(36.5, 1.7, 17.0), Vector3(7.30, 3.4, 0.30), "Incinerator rear wall translates intact and remains joined")
	_check_box(wing, "Proxies/IncineratorMachine", Vector3(36.5, 1.45, 14.75), Vector3(6.2, 2.9, 3.5), "Incinerator machine translates with its pocket")
	_check_box(wing, "Boundaries/DeeperSettlementDoor", Vector3(66.0, 1.45, -6.8), Vector3(0.65, 2.90, 2.4), "deeper closure moves with the Ops terminal")
	_check_no_positive_box_overlap(wing, "RoofVisuals/Ceiling_BacklogPassage", "Districts/Receiving/ReceivingCeilingTransition", "Receiving transition does not overlap the Backlog ceiling")
	_check_no_positive_box_overlap(wing, "Districts/GalleryA/Floor_GalleryAMain", "Districts/MedicalApproach/Floor_MedicalAnteroom", "Medical floor does not overlap Gallery A")
	_check_no_positive_box_overlap(wing, "RoofVisuals/Ceiling_GalleryAMain", "RoofVisuals/Ceiling_MedicalAnteroom", "Medical ceiling does not overlap Gallery A")
	_check_no_positive_area_zone_overlaps(wing.get_node("Districts"), "Floor_", "floor rectangles meet only at boundaries")
	_check_no_positive_area_zone_overlaps(wing.get_node("RoofVisuals"), "Ceiling_", "ceiling rectangles meet only at boundaries")
	for target_z: float in [1.95, 2.075, 2.2]:
		var rail_target := Vector3(-39.0, 1.15, target_z)
		_check_segment_clear_of_structural_walls(wing, Vector3(-10.0, 1.7162851, -4.4), rail_target, "Sorting work stance has a clear freight ray to Z=%.3f" % target_z)
		_check_segment_hits_exact_box(wing, "Boundaries/FreightBarrier/UpperRail", Vector3(-10.0, 1.7162851, -4.4), rail_target, "Sorting ray reaches real upper-rail geometry at Z=%.3f" % target_z)
	_check_segment_blocked_by_structural_wall(wing, Vector3(-38.82, 1.2, 2.2), Vector3(40.0, 1.4, 1.5), "Receiving/ReceivingEastSouth", "lift-to-Deeper long vista is interrupted")
	_check_segment_blocked_by_structural_wall(wing, Vector3(24.0, 1.7162851, 2.5), Vector3(62.5, 1.4, -6.8), "DeeperApproach/DeeperWideNorth", "Storage-to-Ops long vista is interrupted")
	for junction_sample: Vector3 in [
		Vector3(-14.90, 1.0, -4.90),
		Vector3(2.10, 1.0, 11.60),
		Vector3(5.90, 1.0, 14.50),
		Vector3(5.90, 1.0, 17.40),
		Vector3(21.30, 1.0, -25.10),
		Vector3(25.60, 1.0, 21.10),
	]:
		_check_point_inside_static_box(wing, junction_sample, "joined structural corner is solid at %s" % junction_sample)

	for opening: Dictionary in [
		{"point": Vector3(-33.0, 1.0, -5.0), "label": "Dispatch framed doorless opening"},
		{"point": Vector3(-28.5, 1.0, 0.0), "label": "narrow Receiving-to-Backlog opening"},
		{"point": Vector3(-15.0, 1.0, -0.98), "label": "authorized Backlog-to-Sorting opening"},
		{"point": Vector3(4.5, 1.0, -8.2), "label": "north-shifted Gallery A east opening"},
		{"point": Vector3(9.0, 1.0, -8.2), "label": "north-shifted Gallery B west opening"},
		{"point": Vector3(16.5, 1.0, -6.8), "label": "Gallery B east Kitchen opening"},
		{"point": Vector3(6.0, 1.0, 10.25), "label": "sole C-to-D secondary opening"},
		{"point": Vector3(7.0, 1.0, -23.0), "label": "Medical south-east room entrance"},
		{"point": Vector3(25.0, 1.0, -18.0), "label": "Kitchen territorial entrance"},
		{"point": Vector3(-10.0, 1.0, 15.0), "label": "Workshop territorial entrance"},
		{"point": Vector3(59.0, 1.0, -5.5), "label": "Bunker Ops landing entrance"},
	]:
		_check_point_clear_of_static_boxes(wing, opening["point"] as Vector3, String(opening["label"]))
	_check_no_collinear_wall_overlaps(wing)
	_check_perpendicular_wall_junction_coverage(wing)
	_check_point_inside_static_box(wing, Vector3(31.5, 1.7, 4.5), "vacated Incinerator mouth is closed by ordinary wide-run wall")

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


func _validate_box_shapes(node: Node, wing_root: Node = null) -> void:
	if wing_root == null:
		wing_root = node
	if node is Node3D:
		var container := node as Node3D
		var mesh_instance := container.get_node_or_null("Mesh") as MeshInstance3D
		var collision := container.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
		if mesh_instance != null or collision != null:
			var relative_path := String(wing_root.get_path_to(container))
			var collisionless_allowed := relative_path in COLLISIONLESS_BOX_PATHS
			if _check(mesh_instance != null and mesh_instance.mesh is BoxMesh, "generated box has a BoxMesh: " + relative_path):
				var mesh_size := (mesh_instance.mesh as BoxMesh).size
				_check(mesh_size.is_finite(), "box mesh size is finite: " + relative_path)
				_check(mesh_size.x > 0.0 and mesh_size.y > 0.0 and mesh_size.z > 0.0, "box mesh size is positive: " + relative_path)
				_check(mesh_instance.transform.is_equal_approx(Transform3D.IDENTITY), "box mesh uses its container transform: " + relative_path)
				if collisionless_allowed:
					_check(collision == null, "authorized provisional interface remains visual-only: " + relative_path)
				elif _check(collision != null and collision.shape is BoxShape3D, "generated solid box has BoxShape collision: " + relative_path):
					var collision_size := (collision.shape as BoxShape3D).size
					_check(collision_size.is_finite(), "box collision size is finite: " + relative_path)
					_check(collision_size.x > 0.0 and collision_size.y > 0.0 and collision_size.z > 0.0, "box collision size is positive: " + relative_path)
					_check(collision_size.is_equal_approx(mesh_size), "BoxMesh and BoxShape sizes match: " + relative_path)
					_check(collision.transform.is_equal_approx(Transform3D.IDENTITY), "box collision uses its container transform: " + relative_path)
					var body := collision.get_parent() as StaticBody3D
					_check(body.transform.is_equal_approx(Transform3D.IDENTITY), "box body uses its container transform: " + relative_path)
	for child in node.get_children():
		_validate_box_shapes(child, wing_root)


func _check_box(wing: Node3D, path: String, expected_center: Vector3, expected_size: Vector3, message: String) -> void:
	var box := wing.get_node_or_null(path) as Node3D
	if not _check(box != null, message + " exists"):
		return
	var collision := box.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
	if not _check(collision != null and collision.shape is BoxShape3D, message + " has box collision"):
		return
	_check(box.position.is_equal_approx(expected_center), message + " center is exact")
	_check((collision.shape as BoxShape3D).size.is_equal_approx(expected_size), message + " size is exact")


func _check_visual_box(wing: Node3D, path: String, expected_center: Vector3, expected_size: Vector3, message: String) -> void:
	var box := wing.get_node_or_null(path) as Node3D
	if not _check(box != null, message + " exists"):
		return
	var mesh_instance := box.get_node_or_null("Mesh") as MeshInstance3D
	if not _check(mesh_instance != null and mesh_instance.mesh is BoxMesh, message + " has a box mesh"):
		return
	_check(box.position.is_equal_approx(expected_center), message + " center is exact")
	_check((mesh_instance.mesh as BoxMesh).size.is_equal_approx(expected_size), message + " size is exact")


func _check_material_name(wing: Node3D, path: String, expected_name: String, message: String) -> void:
	var box := wing.get_node_or_null(path) as Node3D
	if not _check(box != null, message + " box exists"):
		return
	var mesh_instance := box.get_node_or_null("Mesh") as MeshInstance3D
	if not _check(mesh_instance != null and mesh_instance.material_override != null, message + " has a material"):
		return
	_check(mesh_instance.material_override.resource_name == expected_name, message)


func _check_z_face_clearance(wing: Node3D, south_path: String, north_path: String, expected_clearance: float, message: String) -> void:
	var south_box := wing.get_node_or_null(south_path) as Node3D
	var north_box := wing.get_node_or_null(north_path) as Node3D
	if not _check(south_box != null and north_box != null, message + " boxes exist"):
		return
	var south_collision := south_box.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
	var north_collision := north_box.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
	if not _check(south_collision != null and south_collision.shape is BoxShape3D and north_collision != null and north_collision.shape is BoxShape3D, message + " boxes have collision"):
		return
	var south_rear_face := south_box.position.z + (south_collision.shape as BoxShape3D).size.z * 0.5
	var north_inside_face := north_box.position.z - (north_collision.shape as BoxShape3D).size.z * 0.5
	_check(is_equal_approx(north_inside_face - south_rear_face, expected_clearance), message)


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


func _check_no_positive_area_zone_overlaps(root: Node, prefix: String, message: String) -> void:
	var zones: Array[Dictionary] = []
	_collect_zone_records(root, prefix, zones)
	var overlaps: Array[String] = []
	for first_index: int in zones.size():
		var first := zones[first_index]
		for second_index: int in range(first_index + 1, zones.size()):
			var second := zones[second_index]
			var overlap_x := minf(float(first["max_x"]), float(second["max_x"])) - maxf(float(first["min_x"]), float(second["min_x"]))
			var overlap_z := minf(float(first["max_z"]), float(second["max_z"])) - maxf(float(first["min_z"]), float(second["min_z"]))
			if overlap_x > 0.001 and overlap_z > 0.001:
				overlaps.append("%s <> %s (%.2f x %.2f m)" % [first["path"], second["path"], overlap_x, overlap_z])
	_check(overlaps.is_empty(), message + "; overlaps=" + "; ".join(overlaps))


func _collect_zone_records(node: Node, prefix: String, records: Array[Dictionary]) -> void:
	if node is Node3D and String(node.name).begins_with(prefix):
		var zone := node as Node3D
		var collision := zone.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
		if collision != null and collision.shape is BoxShape3D:
			var size := (collision.shape as BoxShape3D).size
			var parent_name := String(zone.get_parent().name)
			records.append({
				"path": parent_name + "/" + String(zone.name),
				"min_x": zone.position.x - size.x * 0.5,
				"max_x": zone.position.x + size.x * 0.5,
				"min_z": zone.position.z - size.z * 0.5,
				"max_z": zone.position.z + size.z * 0.5,
			})
	for child in node.get_children():
		_collect_zone_records(child, prefix, records)


func _check_segment_clear_of_structural_walls(wing: Node3D, start: Vector3, finish: Vector3, message: String) -> void:
	var blockers: Array[String] = []
	_collect_segment_blockers(wing.get_node("Districts"), start, finish, blockers)
	_check(blockers.is_empty(), message + "; blockers=" + ", ".join(blockers))


func _check_segment_blocked_by_structural_wall(wing: Node3D, start: Vector3, finish: Vector3, expected_blocker: String, message: String) -> void:
	var blockers: Array[String] = []
	_collect_segment_blockers(wing.get_node("Districts"), start, finish, blockers)
	_check(blockers.has(expected_blocker), message + "; expected=" + expected_blocker + "; blockers=" + ", ".join(blockers))


func _check_segment_hits_exact_box(wing: Node3D, path: String, start: Vector3, finish: Vector3, message: String) -> void:
	var box := wing.get_node_or_null(path) as Node3D
	if not _check(box != null, message + " target exists"):
		return
	var collision := box.get_node_or_null("StaticBody3D/CollisionShape3D") as CollisionShape3D
	if not _check(collision != null and collision.shape is BoxShape3D, message + " target has box collision"):
		return
	_check(_segment_intersects_box_3d(start, finish, box.position, (collision.shape as BoxShape3D).size), message)


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


func _segment_intersects_box_3d(start: Vector3, finish: Vector3, center: Vector3, size: Vector3) -> bool:
	var t_min := 0.0
	var t_max := 1.0
	var delta := finish - start
	for axis: int in 3:
		var origin := start[axis]
		var direction := delta[axis]
		var half := size[axis] * 0.5
		var minimum := center[axis] - half
		var maximum := center[axis] + half
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
	return t_max >= 0.0 and t_min <= 1.0


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


func _check_perpendicular_wall_junction_coverage(wing: Node3D) -> void:
	var districts := wing.get_node_or_null("Districts") as Node3D
	if not _check(districts != null, "district root exists for endpoint-junction audit"):
		return
	var walls: Array[Dictionary] = []
	_collect_wall_records(districts, walls)
	var gaps: Array[String] = []
	var audited_pairs := 0
	for first_index: int in walls.size():
		var first := walls[first_index]
		for second_index: int in range(first_index + 1, walls.size()):
			var second := walls[second_index]
			if first["axis"] == second["axis"]:
				continue
			var horizontal := first if first["axis"] == "x" else second
			var vertical := second if first["axis"] == "x" else first
			var intersection := Vector2(float(vertical["line"]), float(horizontal["line"]))
			if (
				intersection.x < float(horizontal["start"]) - 0.001
				or intersection.x > float(horizontal["end"]) + 0.001
				or intersection.y < float(vertical["start"]) - 0.001
				or intersection.y > float(vertical["end"]) + 0.001
			):
				continue
			audited_pairs += 1
			for x_sign: float in [-1.0, 1.0]:
				for z_sign: float in [-1.0, 1.0]:
					var sample := intersection + Vector2(x_sign, z_sign) * 0.075
					if not _point_inside_any_wall_record(sample, walls):
						gaps.append("%s <> %s at %s misses %s" % [horizontal["path"], vertical["path"], intersection, sample])
	_check(audited_pairs >= 39, "endpoint audit covers at least the 39 round-two candidate junctions; audited=%d" % audited_pairs)
	_check(gaps.is_empty(), "perpendicular wall joins cover all endpoint quadrants; gaps=" + "; ".join(gaps))


func _write_junction_evidence(arguments: PackedStringArray) -> Error:
	var baseline_path := _argument_value(arguments, JUNCTION_BASELINE_PREFIX)
	if baseline_path.is_empty() or not ResourceLoader.exists(baseline_path):
		push_error("junction evidence requires an existing --junction-baseline=res://... scene")
		return ERR_FILE_NOT_FOUND
	var source_commit := _argument_value(arguments, JUNCTION_SOURCE_COMMIT_PREFIX)
	if source_commit.is_empty():
		source_commit = "unknown"
	var baseline := _collect_junction_snapshot(baseline_path)
	var current := _collect_junction_snapshot(WING_GEOMETRY_PATH)
	if baseline.is_empty() or current.is_empty():
		return ERR_PARSE_ERROR
	var baseline_by_key: Dictionary = {}
	for pair: Dictionary in baseline["pairs"]:
		baseline_by_key[String(pair["key"])] = pair
	var current_by_key: Dictionary = {}
	var classified_current: Array[Dictionary] = []
	var junction_type_counts: Dictionary = {}
	var corrected_count := 0
	var already_covered_count := 0
	var unresolved_count := 0
	for pair: Dictionary in current["pairs"]:
		var classified := pair.duplicate(true)
		var key := String(pair["key"])
		current_by_key[key] = true
		if not (pair["gap_samples"] as Array).is_empty():
			classified["disposition"] = "unresolved"
			unresolved_count += 1
		elif baseline_by_key.has(key):
			var baseline_pair := baseline_by_key[key] as Dictionary
			classified["baseline_gap_samples"] = baseline_pair["gap_samples"]
			if (baseline_pair["gap_samples"] as Array).is_empty():
				classified["disposition"] = "already_covered"
				already_covered_count += 1
			else:
				classified["disposition"] = "corrected"
				corrected_count += 1
		else:
			classified["disposition"] = "corrected"
			classified["note"] = "new or renamed round-three structural join; all four final quadrants are covered"
			corrected_count += 1
		var junction_type := String(classified["junction_type"])
		junction_type_counts[junction_type] = int(junction_type_counts.get(junction_type, 0)) + 1
		classified_current.append(classified)

	var not_applicable: Array[Dictionary] = []
	for pair: Dictionary in baseline["pairs"]:
		if current_by_key.has(String(pair["key"])):
			continue
		var retired := pair.duplicate(true)
		retired["disposition"] = "not_applicable"
		retired["note"] = "round-two pair is absent after an approved round-three wall replacement or extent change"
		not_applicable.append(retired)

	var baseline_uncovered_pairs := 0
	var baseline_uncovered_quadrants := 0
	for pair: Dictionary in baseline["pairs"]:
		var gap_count := (pair["gap_samples"] as Array).size()
		if gap_count > 0:
			baseline_uncovered_pairs += 1
			baseline_uncovered_quadrants += gap_count
	var intentional_openings := _junction_opening_records()
	var payload := {
		"layout_revision": "logistics-wing-greybox-round03-revision-03",
		"source_commit": source_commit,
		"baseline_commit": ROUND_TWO_FINAL_COMMIT,
		"baseline_scene": baseline_path,
		"current_scene": WING_GEOMETRY_PATH,
		"audit_method": "Every perpendicular full-height structural-wall pair is sampled 0.075 m into all four thickness quadrants. Authorized openings are sampled independently at controller height.",
		"classification_definitions": {
			"corrected": "A round-two uncovered pair, or a new/renamed round-three join, with all four final quadrants covered.",
			"already_covered": "The same pair was fully covered in round two and remains covered.",
			"intentional_opening": "An approved route opening whose controller-height sample remains clear.",
			"not_applicable": "A round-two pair retired by an approved wall replacement or extent change.",
		},
		"junction_type_definitions": {
			"true_corner": "Both structural runs terminate at the coordinate; one or two nearby playable-floor quadrants distinguish an ordinary perimeter corner.",
			"concave_return": "Both structural runs terminate at the coordinate and three nearby playable-floor quadrants identify a re-entrant perimeter return.",
			"butt_or_t_join": "One structural run terminates against the interior of the perpendicular run.",
			"cross_join": "Both structural runs continue through the coordinate.",
			"open_jamb": "An approved aperture or territorial entrance remains intentionally clear at the recorded controller-height sample.",
		},
		"summary": {
			"round_two_seed_candidates": 39,
			"round_two_audited_pairs": (baseline["pairs"] as Array).size(),
			"round_two_uncovered_pairs": baseline_uncovered_pairs,
			"round_two_uncovered_quadrants": baseline_uncovered_quadrants,
			"round_three_audited_pairs": classified_current.size(),
			"corrected": corrected_count,
			"already_covered": already_covered_count,
			"intentional_openings": intentional_openings.size(),
			"not_applicable": not_applicable.size(),
			"round_three_unresolved": unresolved_count,
			"junction_types": junction_type_counts,
		},
		"current_junctions": classified_current,
		"intentional_openings": intentional_openings,
		"retired_round_two_pairs": not_applicable,
	}
	var absolute_path := ProjectSettings.globalize_path(JUNCTION_EVIDENCE_PATH)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	if directory_error != OK:
		return directory_error
	var output := FileAccess.open(absolute_path, FileAccess.WRITE)
	if output == null:
		return FileAccess.get_open_error()
	output.store_string(JSON.stringify(payload, "\t") + "\n")
	output.close()
	print("JUNCTION_INVENTORY path=%s current_pairs=%d corrected=%d already_covered=%d intentional_openings=%d retired=%d unresolved=%d" % [
		absolute_path, classified_current.size(), corrected_count, already_covered_count,
		intentional_openings.size(), not_applicable.size(), unresolved_count,
	])
	return OK


func _collect_junction_snapshot(scene_path: String) -> Dictionary:
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("could not load junction scene: " + scene_path)
		return {}
	var wing := packed.instantiate() as Node3D
	if wing == null:
		push_error("could not instantiate junction scene: " + scene_path)
		return {}
	var districts := wing.get_node_or_null("Districts") as Node3D
	if districts == null:
		wing.free()
		push_error("junction scene has no Districts node: " + scene_path)
		return {}
	var walls: Array[Dictionary] = []
	_collect_wall_records(districts, walls)
	var floor_zones: Array[Dictionary] = []
	_collect_zone_records(districts, "Floor_", floor_zones)
	var pairs: Array[Dictionary] = []
	for first_index: int in walls.size():
		var first := walls[first_index]
		for second_index: int in range(first_index + 1, walls.size()):
			var second := walls[second_index]
			if first["axis"] == second["axis"]:
				continue
			var horizontal := first if first["axis"] == "x" else second
			var vertical := second if first["axis"] == "x" else first
			var intersection := Vector2(float(vertical["line"]), float(horizontal["line"]))
			if (
				intersection.x < float(horizontal["start"]) - 0.001
				or intersection.x > float(horizontal["end"]) + 0.001
				or intersection.y < float(vertical["start"]) - 0.001
				or intersection.y > float(vertical["end"]) + 0.001
			):
				continue
			var gap_samples: Array[Array] = []
			var covered_quadrants := 0
			for x_sign: float in [-1.0, 1.0]:
				for z_sign: float in [-1.0, 1.0]:
					var sample := intersection + Vector2(x_sign, z_sign) * 0.075
					if _point_inside_any_wall_record(sample, walls):
						covered_quadrants += 1
					else:
						gap_samples.append([sample.x, sample.y])
			var key := "%s <> %s @ %.3f,%.3f" % [horizontal["path"], vertical["path"], intersection.x, intersection.y]
			var floor_quadrants := _count_playable_floor_quadrants(intersection, floor_zones)
			pairs.append({
				"key": key,
				"coordinate_group": "%.3f,%.3f" % [intersection.x, intersection.y],
				"horizontal_wall": horizontal["path"],
				"vertical_wall": vertical["path"],
				"coordinate": [intersection.x, intersection.y],
				"junction_type": _classify_junction_type(horizontal, vertical, intersection, floor_quadrants),
				"playable_floor_quadrants": floor_quadrants,
				"covered_quadrants": covered_quadrants,
				"required_quadrants": 4,
				"gap_samples": gap_samples,
			})
	pairs.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a["key"]) < String(b["key"]))
	wing.free()
	return {"walls": walls.size(), "pairs": pairs}


func _classify_junction_type(horizontal: Dictionary, vertical: Dictionary, intersection: Vector2, floor_quadrants: int) -> String:
	var endpoint_tolerance := WALL_HALF_THICKNESS + 0.002
	var horizontal_ends_here := minf(
		absf(intersection.x - float(horizontal["start"])),
		absf(intersection.x - float(horizontal["end"]))
	) <= endpoint_tolerance
	var vertical_ends_here := minf(
		absf(intersection.y - float(vertical["start"])),
		absf(intersection.y - float(vertical["end"]))
	) <= endpoint_tolerance
	if horizontal_ends_here and vertical_ends_here:
		return "concave_return" if floor_quadrants >= 3 else "true_corner"
	if horizontal_ends_here or vertical_ends_here:
		return "butt_or_t_join"
	return "cross_join"


func _count_playable_floor_quadrants(intersection: Vector2, floor_zones: Array[Dictionary]) -> int:
	var count := 0
	for x_sign: float in [-1.0, 1.0]:
		for z_sign: float in [-1.0, 1.0]:
			var sample := intersection + Vector2(x_sign, z_sign) * 0.35
			for zone: Dictionary in floor_zones:
				if (
					sample.x > float(zone["min_x"]) + 0.001
					and sample.x < float(zone["max_x"]) - 0.001
					and sample.y > float(zone["min_z"]) + 0.001
					and sample.y < float(zone["max_z"]) - 0.001
				):
					count += 1
					break
	return count


func _junction_opening_records() -> Array[Dictionary]:
	return [
		_opening_record("Dispatch framed doorless opening", Vector3(-33.0, 1.0, -5.0)),
		_opening_record("narrow Receiving-to-Backlog opening", Vector3(-28.5, 1.0, 0.0)),
		_opening_record("authorized Backlog-to-Sorting opening", Vector3(-15.0, 1.0, -0.98)),
		_opening_record("north-shifted Gallery A east opening", Vector3(4.5, 1.0, -8.2)),
		_opening_record("north-shifted Gallery B west opening", Vector3(9.0, 1.0, -8.2)),
		_opening_record("Gallery B east Kitchen opening", Vector3(16.5, 1.0, -6.8)),
		_opening_record("sole C-to-D secondary opening", Vector3(6.0, 1.0, 10.25)),
		_opening_record("Medical south-east room entrance", Vector3(7.0, 1.0, -23.0)),
		_opening_record("Kitchen territorial entrance", Vector3(25.0, 1.0, -18.0)),
		_opening_record("Workshop territorial entrance", Vector3(-10.0, 1.0, 15.0)),
		_opening_record("Bunker Ops landing entrance", Vector3(59.0, 1.0, -5.5)),
	]


func _opening_record(label: String, point: Vector3) -> Dictionary:
	return {
		"label": label,
		"sample": [point.x, point.y, point.z],
		"disposition": "intentional_opening",
		"junction_type": "open_jamb",
		"controller_height_sample_clear": true,
	}


func _argument_value(arguments: PackedStringArray, prefix: String) -> String:
	for argument: String in arguments:
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _point_inside_wall_record(point: Vector2, wall: Dictionary) -> bool:
	if wall["axis"] == "x":
		return (
			point.x >= float(wall["start"]) - 0.001
			and point.x <= float(wall["end"]) + 0.001
			and absf(point.y - float(wall["line"])) <= WALL_HALF_THICKNESS + 0.001
		)
	return (
		absf(point.x - float(wall["line"])) <= WALL_HALF_THICKNESS + 0.001
		and point.y >= float(wall["start"]) - 0.001
		and point.y <= float(wall["end"]) + 0.001
	)


func _point_inside_any_wall_record(point: Vector2, walls: Array[Dictionary]) -> bool:
	for wall: Dictionary in walls:
		if _point_inside_wall_record(point, wall):
			return true
	return false


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
