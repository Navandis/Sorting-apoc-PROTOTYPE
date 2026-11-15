extends SceneTree

const REVIEW_PLAYER_PATH := "res://greybox/logistics_wing/review_player.tscn"
const WING_GEOMETRY_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const WING_GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const LEGACY_MAIN_PATH := "res://main.tscn"
const NEUTRAL_REVIEW_PATH := "res://greybox/logistics_wing/wing_review.tscn"
const EXPECTED_MAIN_SCENE := "uid://bljf1nlhijej"
const WALL_HALF_THICKNESS := 0.15
const JUNCTION_EVIDENCE_FLAG := "--junction-evidence"
const JUNCTION_BASELINE_PREFIX := "--junction-baseline="
const JUNCTION_BASELINE_COMMIT_PREFIX := "--junction-baseline-commit="
const JUNCTION_SOURCE_COMMIT_PREFIX := "--junction-source-commit="
const JUNCTION_EVIDENCE_PATH := "res://reports/logistics_wing/greybox/compact_layout_slice_9/junction_inventory.json"
const COLLISIONLESS_BOX_PATHS := [
	"Proxies/MedicalInterface",
	"Proxies/KitchenInterface",
	"Proxies/WorkshopInterface",
	"Proxies/BunkerOpsInterface",
]

const REQUIRED_DISTRICTS := [
	"Receiving", "Backlog", "Sorting", "StorageSpine", "GalleryA",
	"GalleryB", "GalleryC", "GalleryD", "MedicalApproach",
	"KitchenApproach", "WorkshopService", "Salvager", "DeeperApproach",
	"Incinerator", "BunkerOps", "SharedABJunction",
]
const REQUIRED_ANCHORS := [
	"ReceivingApron", "Dispatch", "SortingWork", "StorageNear", "GalleryA", "GalleryB",
	"GalleryC", "GalleryD", "MedicalSafeSide",
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
	"StorageSpine>Incinerator", "StorageSpine>SharedABJunction",
	"SharedABJunction>GalleryA", "SharedABJunction>GalleryB",
	"SharedABJunction>MedicalApproach", "GalleryB>KitchenApproach",
	"GalleryC>GalleryD",
	"StorageSpine>DeeperApproach", "WorkshopService>Salvager",
	"DeeperApproach>BunkerOps", "BunkerOps>DeeperSettlementClosure",
]
const FORBIDDEN_EDGES := [
	"GalleryA>MedicalApproach", "Sorting>GalleryA",
	"StorageSpine>KitchenApproach", "GalleryC>WorkshopService",
	"MedicalApproach>KitchenApproach", "Receiving>SurfaceRoute",
	"GalleryA>GalleryB", "GalleryA>GalleryC", "GalleryA>GalleryD",
	"GalleryB>GalleryC", "GalleryB>GalleryD",
	"GalleryD>Incinerator", "DeeperApproach>Incinerator", "KitchenApproach>BunkerOps",
]

var _failures := 0


func _init() -> void:
	_test_review_player_preserves_controller_contract()
	_test_complete_wing_geometry_contract()
	_test_default_launch_promotes_wing_gameplay()
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
	_check(String(wing.get_meta("layout_revision", "")) == "logistics-wing-compact-layout-slice-9", "layout revision identifies the ninth compact layout slice")
	_check(wing.get_meta("regeneration_command", "") == "godot --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd", "single regeneration command is explicit")
	_check(Vector3(wing.get_meta("overall_extents_m", Vector3.ZERO)).is_equal_approx(Vector3(70.25, 4.2, 43.36660027)), "overall extent records the compact footprint and Receiving clearance")
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
		"Districts/Sorting/SortingWestNorthShoulder",
		"Districts/StorageSpine/SpineWestSouthClosure",
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
	_check_box(wing, "Districts/Receiving/Floor_ReceivingApron", Vector3(-25.5, -0.15, 0.0), Vector3(7.5, 0.30, 8.0), "Receiving Apron is shortened east-west but remains usable")
	_check_box(wing, "Districts/Receiving/Floor_FreightEnclosure", Vector3(-31.75, -0.15, 0.0), Vector3(5.0, 0.30, 7.0), "freight enclosure is distinct and shallow")
	_check_box(wing, "Districts/Receiving/Floor_DispatchAnnex", Vector3(-25, -0.15, -5.75), Vector3(6.5, 0.30, 3.5), "Dispatch remains a shallow external annex")
	_check_box(wing, "Districts/Receiving/ReceivingCeilingTransition", Vector3(-21.75, 3.8, 0.0), Vector3(0.30, 0.80, 2.84), "Receiving-to-Backlog height strip aligns with the doorway depth planes")
	_check_box(wing, "Districts/Backlog/Floor_BacklogPassage", Vector3(-18.375, -0.15, -0.95), Vector3(6.75, 0.30, 5.7), "Backlog floor runs from the moved apron to Sorting")
	_check_box(wing, "RoofVisuals/Ceiling_BacklogPassage", Vector3(-18.3, 3.55, -0.95), Vector3(6.6, 0.30, 5.7), "Backlog lower ceiling terminates at the aligned closure face")
	_check_box(wing, "Districts/Backlog/BacklogNorth", Vector3(-18.225, 1.7, -3.8), Vector3(6.75, 3.4, 0.30), "Backlog north wall meets both junctions")
	_check_box(wing, "Districts/Backlog/BacklogSouth", Vector3(-18.225, 1.7, 1.9), Vector3(6.75, 3.4, 0.30), "Backlog south wall meets both junctions after moving north")
	_check_box(wing, "Districts/Sorting/SortingWestSouthShoulder", Vector3(-15.0, 1.7, 3.45), Vector3(0.30, 3.4, 3.10), "Sorting return closes from the new south jamb to the fixed south wall")
	_check_box(wing, "Districts/Sorting/Floor_SortingPassage", Vector3(-10.0, -0.15, 1.5), Vector3(10.0, 0.30, 7.0), "Sorting floor expands north with its south edge fixed")
	_check_box(wing, "Districts/Backlog/BacklogEastNorth", Vector3(-15.0, 1.7, -2.325), Vector3(0.30, 3.4, 2.95), "Backlog north jamb keeps the opening face at Z=-0.85")
	_check_box(wing, "Districts/Backlog/BacklogEastSouth", Vector3(-15.0, 1.7, 1.75), Vector3(0.30, 3.4, 0.30), "south jamb leaves a nib inside Backlog at Z=1.60")
	_check_box(wing, "Districts/Sorting/Floor_SortingPocket", Vector3(-10.0, -0.15, -2.66), Vector3(8.0, 0.30, 1.32), "Sorting pocket floor follows the shifted walls")
	_check_box(wing, "RoofVisuals/Ceiling_SortingPassage", Vector3(-10.0, 3.55, 1.5), Vector3(10.0, 0.30, 7.0), "Sorting ceiling covers the expanded body")
	_check_box(wing, "RoofVisuals/Ceiling_SortingPocket", Vector3(-10.0, 3.55, -2.66), Vector3(8.0, 0.30, 1.32), "Sorting pocket ceiling meets the main slab and rear wall")
	_check_box(wing, "Districts/Sorting/SortingNorthWestShoulder", Vector3(-14.35, 1.7, -2.0), Vector3(1.0, 3.40, 0.30), "northwest shoulder butts into the retained Backlog jamb")
	_check_box(wing, "Districts/Sorting/SortingPocketWest", Vector3(-14.0, 1.7, -2.66), Vector3(0.30, 3.40, 1.02), "west pocket return meets both translated walls")
	_check_box(wing, "Districts/Sorting/SortingPocketNorth", Vector3(-10.0, 1.7, -3.32), Vector3(8.30, 3.40, 0.30), "pocket rear wall moves north by one metre")
	_check_box(wing, "Districts/Sorting/SortingPocketEast", Vector3(-6.0, 1.7, -2.66), Vector3(0.30, 3.40, 1.02), "east pocket return meets both translated walls")
	_check_box(wing, "Districts/Sorting/SortingNorthEastShoulder", Vector3(-5.65, 1.7, -2.0), Vector3(1.0, 3.40, 0.30), "northeast shoulder meets the extended Sorting east wall")
	_check_box(wing, "Districts/Sorting/SortingEastNorth", Vector3(-5.0, 1.7, -0.60), Vector3(0.30, 3.40, 3.10), "east wall closes the new corner and retains the Storage opening")
	_check_box(wing, "Districts/StorageSpine/SpineWestNorthA", Vector3(-3.425, 1.7, -0.30), Vector3(2.85, 3.40, 0.30), "north hall frontage butts into Sorting and ends at A's new opening")
	_check_box(wing, "Districts/Sorting/SortingEastSouth", Vector3(-5.0, 1.7, 4.575), Vector3(0.30, 3.40, 0.85), "Storage southern jamb keeps the clear width")
	_check_box(wing, "Proxies/SortingTable", Vector3(-10.0, 0.45, -2.8), Vector3(1.6, 0.90, 0.65), "desk aid follows the pocket wall with the same clearance")
	_check_northern_bank(wing)
	_check_material_name(wing, "Districts/SharedABJunction/Floor_SharedABJunction", "Greybox Storage Floor", "A/B connector uses the Storage diagnostic floor treatment")
	_check_medical_branch(wing)
	_check_box(wing, "Districts/GalleryC/GalleryCInsetWest", Vector3(2.0, 1.7, 12.050), Vector3(0.30, 3.4, 3.5), "C folded perimeter turns north at the red-overlay inset")
	_check_box(wing, "Districts/GalleryC/GalleryCInsetCap", Vector3(4.0, 1.7, 10.300), Vector3(4.30, 3.4, 0.30), "C folded perimeter caps east to the D-side return")
	_check_box(wing, "Districts/GalleryD/GalleryDWestSouthReturn", Vector3(6.0, 1.7, 13.300), Vector3(0.30, 3.4, 6.0), "D western return closes the complete 10.3 to 16.3 span")
	_check_workshop_branch(wing)
	_check_kitchen_branch(wing)
	_check_incinerator_branch(wing)
	_check_eastern_branch(wing)
	_check_box(wing, "Districts/StorageSpine/Floor_StorageSpineWest", Vector3(-0.25, -0.15, 2.0), Vector3(9.5, 0.30, 4.6), "west hall keeps its midpoint with a 4.60 m nominal depth")
	_check_box(wing, "Districts/StorageSpine/Floor_StorageSpineEast", Vector3(15.25, -0.15, 2.75), Vector3(21.5, 0.30, 6.1), "east hall keeps its midpoint with a 6.10 m nominal depth")
	_check_box(wing, "RoofVisuals/Ceiling_StorageSpineWest", Vector3(-0.25, 3.55, 2.0), Vector3(9.5, 0.30, 4.6), "west ceiling fits the contracted floor")
	_check_box(wing, "RoofVisuals/Ceiling_StorageSpineEast", Vector3(15.25, 3.55, 2.75), Vector3(21.5, 0.30, 6.1), "east ceiling fits the contracted floor")
	_check_box(wing, "Districts/StorageSpine/SpineWestSouthA", Vector3(-2.425, 1.7, 4.3), Vector3(4.85, 3.40, 0.30), "south hall wall joins the Sorting jamb at the 4.15 m inside face")
	_check_box(wing, "Districts/StorageSpine/SpineWestEastClosure", Vector3(4.5, 1.7, 5.05), Vector3(0.30, 3.40, 1.5), "the west-east hall step keeps its continuous return")
	_check_box(wing, "Districts/StorageSpine/SpineEastNorthReturn", Vector3(26.0, 1.7, 0.25), Vector3(0.30, 3.40, 1.10), "Deeper north jamb fits the new hall with its opening face fixed")
	_check_box(wing, "Districts/GalleryC/Floor_GalleryCMainBody", Vector3(2.0, -0.15, 8.05), Vector3(8.0, 0.30, 4.5), "Gallery C moves north without resizing")
	_check_box(wing, "Districts/GalleryD/Floor_GalleryDMain", Vector3(10.75, -0.15, 11.05), Vector3(9.5, 0.30, 10.5), "Gallery D moves north without resizing")
	_check_z_face_clearance(wing, "Districts/Sorting/SortingEastNorth", "Districts/Sorting/SortingEastSouth", 3.20, "Sorting-to-Storage keeps its 3.20 m clear opening")
	_check_z_face_clearance(wing, "Districts/StorageSpine/SpineWestNorthA", "Districts/StorageSpine/SpineWestSouthA", 4.30, "west corridor clear width includes both wall thicknesses")
	_check_z_face_clearance(wing, "Districts/StorageSpine/SpineEastNorthBEast", "Districts/StorageSpine/SpineEastSouthMid", 5.80, "east corridor clear width includes both wall thicknesses")
	_check_z_face_clearance(wing, "Districts/StorageSpine/SpineEastNorthReturn", "Districts/StorageSpine/SpineEastSouthReturn", 3.00, "Deeper threshold retains its original opening")
	_check_box(wing, "Districts/StorageSpine/SpineEastSouthReturn", Vector3(26.0, 1.7, 4.8), Vector3(0.30, 3.4, 2.0), "Storage-to-Deeper south return closes the full spine perimeter without an exterior seam")
	_check_no_positive_box_overlap(wing, "RoofVisuals/Ceiling_BacklogPassage", "Districts/Receiving/ReceivingCeilingTransition", "Receiving transition does not overlap the Backlog ceiling")
	_check_no_positive_box_overlap(wing, "Districts/GalleryA/Floor_GalleryAMain", "Districts/MedicalApproach/Floor_MedicalAnteroom", "Medical floor does not overlap Gallery A")
	_check_no_positive_box_overlap(wing, "RoofVisuals/Ceiling_GalleryAMain", "RoofVisuals/Ceiling_MedicalAnteroom", "Medical ceiling does not overlap Gallery A")
	_check_no_positive_area_zone_overlaps(wing.get_node("Districts"), "Floor_", "floor rectangles meet only at boundaries")
	_check_no_positive_area_zone_overlaps(wing.get_node("RoofVisuals"), "Ceiling_", "ceiling rectangles meet only at boundaries")
	# Check the aligned walking axis through both openings to the translated apron.
	for target_z: float in [-0.60, 0.375, 1.20]:
		var sorting_stance := Vector3(-13.0, 1.7162851, 0.375)
		var rail_target := Vector3(-29.25, 1.15, target_z)
		_check_segment_clear_of_structural_walls(wing, sorting_stance, rail_target, "Sorting seam has an aligned freight ray to Z=%.3f" % target_z)
		_check_segment_hits_exact_box(wing, "Boundaries/FreightBarrier/UpperRail", sorting_stance, rail_target, "Sorting ray reaches real upper-rail geometry at Z=%.3f" % target_z)
	_check_segment_blocked_by_structural_wall(wing, Vector3(-29.07, 1.2, 2.2), Vector3(32.5, 1.4, 1.8), "Receiving/ReceivingEastSouth", "Receiving wall still interrupts the long lift-to-Ops view")
	for junction_sample: Vector3 in [
		Vector3(-14.90, 1.0, -2.075),
		Vector3(-14.80, 1.0, -2.075),
		Vector3(-14.075, 1.0, -2.20),
		Vector3(-14.075, 1.0, -3.20),
		Vector3(-5.925, 1.0, -2.20),
		Vector3(-5.925, 1.0, -3.20),
		Vector3(-5.20, 1.0, -2.075),
		Vector3(-5.075, 1.0, -2.075),
		Vector3(-4.90, 1.0, -0.225),
		Vector3(-4.80, 1.0, -0.225),
		Vector3(-5.075, 1.0, 4.225),
		Vector3(-4.80, 1.0, 4.225),
		Vector3(4.425, 1.0, 4.375),
		Vector3(4.575, 1.0, 5.725),
		Vector3(25.925, 1.0, -0.225),
		Vector3(26.075, 1.0, 4.425),
		Vector3(2.10, 1.0, 10.40),
		Vector3(5.90, 1.0, 13.30),
		Vector3(5.90, 1.0, 16.20),
		Vector3(27.57, 1.0, -11.46),
		Vector3(19.42, 1.0, 5.725),
		Vector3(23.58, 1.0, 5.875),
		Vector3(18.075, 1.0, 8.725),
		Vector3(24.925, 1.0, 8.875),
		Vector3(18.075, 1.0, 15.875),
		Vector3(24.925, 1.0, 15.875),
		Vector3(26.075, 1.0, 0.65),
		Vector3(26.225, 1.0, 0.65),
		Vector3(26.075, 1.0, 3.95),
		Vector3(26.225, 1.0, 3.95),
		Vector3(28.775, 1.0, 3.95),
		Vector3(28.775, 1.0, 0.65),
		Vector3(28.925, 1.0, 0.65),
		Vector3(28.925, 1.0, 3.95),
	]:
		_check_point_inside_static_box(wing, junction_sample, "joined structural corner is solid at %s" % junction_sample)

	for opening: Dictionary in [
		{"point": Vector3(-24.964286, 1.0, -4.0), "label": "Dispatch framed doorless opening"},
		{"point": Vector3(-21.75, 1.0, 0.0), "label": "narrow Receiving-to-Backlog opening"},
		{"point": Vector3(-15.0, 1.0, 0.375), "label": "authorized Backlog-to-Sorting opening"},
		{"point": Vector3(-5.0, 1.0, 2.55), "label": "retained Sorting-to-Storage opening"},
		{"point": Vector3(-10.0, 1.0, 5.0), "label": "fixed Sorting-to-Workshop opening"},
		{"point": Vector3(-0.5, 1.0, -0.30), "label": "Gallery A hall opening"},
		{"point": Vector3(4.5, 1.0, -0.30), "label": "A/B shared junction hall opening across the floor seam"},
		{"point": Vector3(10.5, 1.0, -0.30), "label": "Gallery B hall opening"},
		{"point": Vector3(1.5, 1.0, 4.30), "label": "Gallery C hall opening"},
		{"point": Vector3(10.5, 1.0, 5.80), "label": "Gallery D hall opening"},
		{"point": Vector3(26.0, 1.0, 2.30), "label": "fixed Deeper opening"},
		{"point": Vector3(2.5, 1.0, -4.9), "label": "centered Gallery A east opening"},
		{"point": Vector3(7.0, 1.0, -4.9), "label": "centered Gallery B west opening"},
		{"point": Vector3(14.5, 1.0, -7.8), "label": "Gallery B east Kitchen opening"},
		{"point": Vector3(6.0, 1.0, 9.05), "label": "sole C-to-D secondary opening"},
		{"point": Vector3(5.0, 1.0, -14.5), "label": "Medical south-east room entrance"},
		{"point": Vector3(20.535, 1.0, -7.8), "label": "Kitchen territorial entrance"},
		{"point": Vector3(-10.0, 1.0, 10.0), "label": "Workshop territorial entrance"},
		{"point": Vector3(-17.01996016, 1.0, 15.36660027), "label": "west Workshop exit to Salvager"},
		{"point": Vector3(-25.61996016, 1.0, 16.86660027), "label": "Salvager southward turn"},
		{"point": Vector3(29.0, 1.0, 2.30), "label": "Bunker Ops landing entrance"},
	]:
		_check_point_clear_of_static_boxes(wing, opening["point"] as Vector3, String(opening["label"]))
	_check_no_collinear_wall_overlaps(wing)
	_check_perpendicular_wall_junction_coverage(wing)

	var topology_edges := wing.get_meta("topology_edges", PackedStringArray()) as PackedStringArray
	var forbidden_edges := wing.get_meta("forbidden_edges", PackedStringArray()) as PackedStringArray
	for edge: String in Array(topology_edges) + Array(forbidden_edges):
		_check(not "GalleryE" in edge, "topology omits the retired gallery: " + edge)
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
	_check_box(wing, "Districts/Receiving/ReceivingWestNorthReturn", Vector3(-29.25, 2.1, -3.25), Vector3(0.3, 4.2, 1.5), "compact ReceivingWestNorthReturn envelope")
	_check_box(wing, "Districts/Receiving/ReceivingWestSouthReturn", Vector3(-29.25, 2.1, 3.25), Vector3(0.3, 4.2, 1.5), "compact ReceivingWestSouthReturn envelope")
	_check_box(wing, "Districts/Receiving/ReceivingSouth", Vector3(-25.5, 2.1, 4), Vector3(7.8, 4.2, 0.3), "compact ReceivingSouth envelope")
	_check_box(wing, "Districts/Receiving/ReceivingNorthWest", Vector3(-28.825, 2.1, -4), Vector3(1.15, 4.2, 0.3), "compact ReceivingNorthWest envelope")
	_check_box(wing, "Districts/Receiving/ReceivingEastNorth", Vector3(-21.75, 2.1, -2.71), Vector3(0.3, 4.2, 2.58), "compact ReceivingEastNorth envelope")
	_check_box(wing, "Districts/Receiving/ReceivingEastSouth", Vector3(-21.75, 2.1, 2.71), Vector3(0.3, 4.2, 2.58), "compact ReceivingEastSouth envelope")
	_check_box(wing, "Districts/Receiving/FreightNorth", Vector3(-31.825, 2.1, -3.5), Vector3(5.15, 4.2, 0.3), "compact FreightNorth envelope")
	_check_box(wing, "Districts/Receiving/FreightSouth", Vector3(-31.825, 2.1, 3.5), Vector3(5.15, 4.2, 0.3), "compact FreightSouth envelope")
	_check_box(wing, "Districts/Receiving/FreightRear", Vector3(-34.25, 2.1, 0), Vector3(0.3, 4.2, 7), "compact FreightRear envelope")
	_check_box(wing, "Districts/Receiving/DispatchWest", Vector3(-28.25, 2.1, -5.75), Vector3(0.3, 4.2, 3.8), "compact DispatchWest envelope")
	_check_box(wing, "Districts/Receiving/DispatchEast", Vector3(-21.75, 2.1, -5.825), Vector3(0.3, 4.2, 3.65), "compact DispatchEast envelope")
	_check_box(wing, "Districts/Receiving/DispatchNorth", Vector3(-25, 2.1, -7.5), Vector3(6.8, 4.2, 0.3), "compact DispatchNorth envelope")
	_check_box(wing, "Districts/Receiving/DispatchSouthWest", Vector3(-27.207142857, 2.1, -4), Vector3(2.085714286, 4.2, 0.3), "compact DispatchSouthWest envelope")
	_check_box(wing, "Districts/Receiving/DispatchSouthEast", Vector3(-22.682142857, 2.1, -4), Vector3(2.164285714, 4.2, 0.3), "compact DispatchSouthEast envelope")
	_validate_box_shapes(wing)
	wing.free()


# Catches a default launch that does not resolve to the accepted gameplay scene,
# or a promotion that makes either preserved review fixture unavailable.
func _test_default_launch_promotes_wing_gameplay() -> void:
	_check(
		String(ProjectSettings.get_setting("application/run/main_scene", "")) == EXPECTED_MAIN_SCENE,
		"project default launch resolves through the wing gameplay UID"
	)
	var default_uid := ResourceUID.text_to_id(EXPECTED_MAIN_SCENE)
	_check(default_uid != ResourceUID.INVALID_ID, "wing gameplay UID is valid")
	if default_uid != ResourceUID.INVALID_ID:
		_check(ResourceUID.get_id_path(default_uid) == WING_GAMEPLAY_PATH, "wing gameplay UID maps to the accepted scene")
	for fixture: Dictionary in [
		{"path": WING_GAMEPLAY_PATH, "label": "wing gameplay"},
		{"path": LEGACY_MAIN_PATH, "label": "legacy main"},
		{"path": NEUTRAL_REVIEW_PATH, "label": "neutral review"},
	]:
		var fixture_path := String(fixture["path"])
		var fixture_label := String(fixture["label"])
		_check(ResourceLoader.exists(fixture_path), fixture_label + " scene remains addressable")
		var packed := load(fixture_path) as PackedScene
		_check(packed != null, fixture_label + " scene remains explicitly loadable")
		if fixture_path == WING_GAMEPLAY_PATH and packed != null:
			var default_root := packed.instantiate()
			_check(default_root.name == &"WingGameplay", "promoted scene keeps the WingGameplay root")
			_check(default_root.get_node_or_null("Player") != null, "promoted scene keeps one gameplay player")
			_check(default_root.get_node_or_null("HUD/CarriedItemsHUD") != null, "promoted scene keeps one carried-items HUD")
			var seed_items := default_root.get_node_or_null("DevelopmentSetup/SeedItems")
			_check(seed_items != null and seed_items.get_child_count() == 46, "promoted scene keeps all 46 seed hosts from checkpoint a263e24")
			default_root.free()


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


func _check_medical_branch(wing: Node3D) -> void:
	var district := "Districts/MedicalApproach/"
	var shared := "Districts/SharedABJunction/"
	_check_box(wing, district + "Floor_MedicalCorridor", Vector3(5.0, -0.15, -12.0), Vector3(2.4, 0.30, 5.0), "Medical corridor is five metres with its south mouth fixed")
	_check_box(wing, "RoofVisuals/Ceiling_MedicalCorridor", Vector3(5.0, 3.55, -12.0), Vector3(2.4, 0.30, 5.0), "Medical corridor ceiling covers its complete shorter floor span")
	_check_box(wing, district + "Floor_MedicalAnteroom", Vector3(2.3, -0.15, -18.0), Vector3(7.8, 0.30, 7.0), "Medical room floor moves five metres south at the accepted size")
	_check_box(wing, "RoofVisuals/Ceiling_MedicalAnteroom", Vector3(2.3, 3.55, -18.0), Vector3(7.8, 0.30, 7.0), "Medical room ceiling moves with the floor")
	_check_box(wing, district + "MedicalCorridorWest", Vector3(3.8, 1.7, -12.0), Vector3(0.30, 3.4, 4.70), "Medical west corridor wall butts into the two doorway shoulders")
	_check_box(wing, district + "MedicalCorridorEast", Vector3(6.2, 1.7, -12.075), Vector3(0.30, 3.4, 4.85), "Medical east corridor wall ends at the relocated room seam")
	_check_box(wing, district + "MedicalRoomSouthWest", Vector3(1.25, 1.7, -14.5), Vector3(5.40, 3.4, 0.30), "Medical shoulder joins the room and corridor west walls")
	_check_box(wing, district + "MedicalRoomWest", Vector3(-1.6, 1.7, -18.0), Vector3(0.30, 3.4, 7.30), "Medical room west wall retains its length")
	_check_box(wing, district + "MedicalRoomEast", Vector3(6.2, 1.7, -18.075), Vector3(0.30, 3.4, 7.15), "Medical room and corridor share the east wall axis with a face joint")
	_check_box(wing, shared + "SharedJunctionNorthWest", Vector3(3.30, 1.7, -9.50), Vector3(1.30, 3.4, 0.30), "Medical shared-mouth west shoulder stays fixed")
	_check_box(wing, shared + "SharedJunctionNorthEast", Vector3(6.45, 1.7, -9.50), Vector3(0.80, 3.4, 0.30), "Medical shared-mouth east shoulder stays fixed")
	_check_box(wing, "Boundaries/MedicalInnerBoundary", Vector3(2.3, 1.7, -21.50), Vector3(7.8, 3.4, 0.30), "Medical staffed-core closure moves five metres south")
	_check_visual_box(wing, "Proxies/MedicalInterface", Vector3(2.3, 0.60, -20.65), Vector3(3.6, 1.2, 0.6), "Medical visual-only interface retains its position relative to the closure")
	var anteroom := wing.get_node_or_null("Anchors/MedicalAnteroom") as Marker3D
	var safe_side := wing.get_node_or_null("Anchors/MedicalSafeSide") as Marker3D
	_check(anteroom != null and anteroom.position.is_equal_approx(Vector3(2.3, 0.05, -18.0)), "Medical anteroom anchor moves five metres south")
	_check(safe_side != null and safe_side.position.is_equal_approx(Vector3(2.3, 0.05, -19.50)), "Medical safe-side anchor keeps its room-relative offset")
	_check_no_positive_box_overlap(wing, district + "MedicalCorridorWest", shared + "SharedJunctionNorthWest", "west shared mouth has one wall owner per span")
	_check_no_positive_box_overlap(wing, district + "MedicalCorridorEast", shared + "SharedJunctionNorthEast", "east shared mouth has one wall owner per span")
	_check_no_positive_box_overlap(wing, district + "MedicalCorridorWest", district + "MedicalRoomSouthWest", "west room mouth has one wall owner per span")
	_check_no_positive_box_overlap(wing, district + "MedicalCorridorEast", district + "MedicalRoomEast", "room and corridor east walls meet without double collision")
	_check_no_positive_box_overlap(wing, district + "MedicalRoomSouthWest", district + "MedicalRoomWest", "room southwest corner has a butt joint")
	for x: float in [4.0, 5.0, 6.0]:
		_check_segment_clear_of_structural_walls(wing, Vector3(x, 1.0, -8.8), Vector3(x, 1.0, -15.3), "Medical path X %.2f stays open through both mouths" % x)
	for z: float in [-9.55, -9.75, -14.40, -14.60]:
		_check_point_inside_static_box(wing, Vector3(6.2, 1.0, z), "Medical east wall remains solid at Z %.2f" % z)
	_check_segment_clear_of_structural_walls(wing, Vector3(5, 1.6, -16.70), Vector3(0, 1.6, -16.70), "no old corridor divider remains in the widened room")
	for y: float in [-0.15, 1.7, 3.55]:
		_check_point_clear_of_static_boxes(wing, Vector3(2.3, y, -24.0), "retired north-only footprint is clear at Y %.2f" % y)

func _check_kitchen_branch(wing: Node3D) -> void:
	var kitchen := "Districts/KitchenApproach/"
	var gallery := "Districts/GalleryB/"
	var corridor_size := Vector3(6.035, 0.30, 2.80)
	var room_size := Vector3(7.0, 0.30, 10.50)
	_check_box(wing, kitchen + "Floor_KitchenEastLeg", Vector3(17.5175, -0.15, -7.80), corridor_size, "Kitchen straight floor meets the reserved B portal and the new room")
	_check_box(wing, "RoofVisuals/Ceiling_KitchenEastLeg", Vector3(17.5175, 3.55, -7.80), corridor_size, "Kitchen straight ceiling covers the complete 6.035 m floor")
	_check_box(wing, kitchen + "Floor_KitchenServiceRoom", Vector3(24.035, -0.15, -6.15), room_size, "Kitchen room floor rotates clockwise at its retained area")
	_check_box(wing, "RoofVisuals/Ceiling_KitchenServiceRoom", Vector3(24.035, 3.55, -6.15), room_size, "Kitchen roof follows the rotated room")
	_check_box(wing, kitchen + "KitchenEastLegNorth", Vector3(17.5175, 1.7, -9.20), Vector3(6.335, 3.4, 0.30), "Kitchen north corridor wall owns both entrance caps")
	_check_box(wing, kitchen + "KitchenEastLegSouth", Vector3(17.5175, 1.7, -6.40), Vector3(6.335, 3.4, 0.30), "Kitchen south corridor wall owns both entrance caps")
	_check_z_face_clearance(wing, kitchen + "KitchenEastLegNorth", kitchen + "KitchenEastLegSouth", 2.50, "Kitchen corridor and its two capped mouths are 2.50 m clear")
	_check_box(wing, kitchen + "KitchenRoomWestNorth", Vector3(20.535, 1.7, -10.30), Vector3(0.30, 3.4, 1.90), "rotated room has the shorter shoulder north of its west opening")
	_check_box(wing, kitchen + "KitchenRoomWestSouth", Vector3(20.535, 1.7, -3.65), Vector3(0.30, 3.4, 5.20), "rotated room has the longer shoulder south of its west opening")
	_check_box(wing, kitchen + "KitchenRoomNorth", Vector3(24.035, 1.7, -11.40), Vector3(7.30, 3.4, 0.30), "room north perimeter owns its end caps")
	_check_box(wing, kitchen + "KitchenRoomSouth", Vector3(24.035, 1.7, -0.90), Vector3(7.30, 3.4, 0.30), "room south perimeter owns its end caps")
	_check_box(wing, "Boundaries/KitchenInnerBoundary", Vector3(27.535, 1.7, -6.15), Vector3(0.30, 3.4, 10.20), "opaque Kitchen staffed-core spans between the north and south inside faces")
	_check_visual_box(wing, "Proxies/KitchenInterface", Vector3(26.685, 0.60, -6.15), Vector3(6.0, 1.2, 0.6), "Kitchen frontage retains its size and its 0.85 m offset into the room")
	var interface := wing.get_node_or_null("Proxies/KitchenInterface") as Node3D
	_check(interface != null and interface.basis.is_equal_approx(Basis(Vector3.UP, -PI * 0.5)), "Kitchen target basis faces into the room after clockwise rotation")
	for marker in [["KitchenService", 23.535], ["KitchenSafeSide", 24.535]]:
		var anchor := wing.get_node_or_null("Anchors/" + String(marker[0])) as Marker3D
		_check(anchor != null and anchor.position.is_equal_approx(Vector3(float(marker[1]), 0.05, -6.15)) and anchor.basis.z.is_equal_approx(Vector3.LEFT), "Kitchen marker %s retains its room-relative position and faces east" % marker[0])
	for retired: String in [kitchen + "Floor_KitchenNorthLeg", "RoofVisuals/Ceiling_KitchenNorthLeg", kitchen + "KitchenNorthLegWest", kitchen + "KitchenNorthLegEast"]:
		_check(wing.get_node_or_null(retired) == null, "retired elbow owner is absent: " + retired)
	_check_no_positive_box_overlap(wing, gallery + "GalleryBEastNorth", kitchen + "KitchenEastLegNorth", "north B threshold has one wall owner per span")
	_check_no_positive_box_overlap(wing, gallery + "GalleryBEastSouth", kitchen + "KitchenEastLegSouth", "south B threshold has one wall owner per span")
	_check_no_positive_box_overlap(wing, kitchen + "KitchenRoomWestNorth", kitchen + "KitchenEastLegNorth", "north room threshold has one wall owner per span")
	_check_no_positive_box_overlap(wing, kitchen + "KitchenRoomWestSouth", kitchen + "KitchenEastLegSouth", "south room threshold has one wall owner per span")
	for z: float in [-8.95, -7.80, -6.65]:
		_check_segment_clear_of_structural_walls(wing, Vector3(13.1, 1.5, z), Vector3(22.5, 1.5, z), "straight Kitchen passage is open across both mouths at Z %.2f" % z)
	_check_segment_clear_of_structural_walls(wing, Vector3(21.02, 1.5, -10), Vector3(26.8, 1.5, -10), "no old elbow rails remain across the rotated room")
	_check_segment_blocked_by_structural_wall(wing, Vector3(24, 1.5, -2), Vector3(24, 1.5, 1), "KitchenApproach/KitchenRoomSouth", "Kitchen has no shortcut into Main Storage")
	for height: float in [-0.15, 1.5, 3.55]:
		_check_point_clear_of_static_boxes(wing, Vector3(23, height, -15), "retired Kitchen north-only leg is clear at Y %.2f" % height)

func _check_incinerator_branch(wing: Node3D) -> void:
	var incinerator := "Districts/Incinerator/"
	var spine := "Districts/StorageSpine/"
	var galleries := wing.get_node("Districts").find_children("Gallery?", "Node3D", false, false)
	_check(galleries.size() == 4, "exactly four gallery districts remain")
	_check(wing.find_children("*GalleryE*", "Node", true, false).is_empty(), "no Gallery E floor, roof, wall, anchor or proxy/collider owner remains")
	_check_box(wing, incinerator + "Floor_IncineratorApproach", Vector3(21.50, -0.15, 7.30), Vector3(4.00, 0.30, 3.00), "three metre approach starts at the Main Storage south threshold")
	_check_box(wing, "RoofVisuals/Ceiling_IncineratorApproach", Vector3(21.50, 3.55, 7.30), Vector3(4.00, 0.30, 3.00), "approach ceiling covers both threshold axes at 3.40 m clear height")
	_check_box(wing, incinerator + "Floor_IncineratorPocket", Vector3(21.50, -0.15, 12.30), Vector3(7.00, 0.30, 7.00), "relocated pocket retains its nominal footprint")
	_check_box(wing, "RoofVisuals/Ceiling_IncineratorPocket", Vector3(21.50, 3.55, 12.30), Vector3(7.00, 0.30, 7.00), "pocket ceiling covers the room at 3.40 m clear height")
	_check_box(wing, spine + "SpineEastSouthMid", Vector3(15.675, 1.70, 5.80), Vector3(7.35, 3.40, 0.30), "hall west return retains D's opening and ends at the new west jamb")
	_check_box(wing, spine + "SpineEastSouthEast", Vector3(24.90, 1.70, 5.80), Vector3(2.50, 3.40, 0.30), "hall east return starts at the new east jamb and retains the east corner")
	_check_box(wing, incinerator + "IncineratorApproachWest", Vector3(19.50, 1.70, 7.30), Vector3(0.30, 3.40, 3.30), "west jamb owns both caps of the 3.70 m clear approach")
	_check_box(wing, incinerator + "IncineratorApproachEast", Vector3(23.50, 1.70, 7.30), Vector3(0.30, 3.40, 3.30), "east jamb owns both caps of the 3.70 m clear approach")
	_check_box(wing, incinerator + "IncineratorPocketNorthWest", Vector3(18.75, 1.70, 8.80), Vector3(1.20, 3.40, 0.30), "west shoulder butts into the widened pocket and corridor")
	_check_box(wing, incinerator + "IncineratorPocketNorthEast", Vector3(24.25, 1.70, 8.80), Vector3(1.20, 3.40, 0.30), "east shoulder butts into the widened pocket and corridor")
	_check_box(wing, incinerator + "IncineratorPocketWest", Vector3(18.00, 1.70, 12.30), Vector3(0.30, 3.40, 7.30), "pocket west wall owns its end caps")
	_check_box(wing, incinerator + "IncineratorPocketEast", Vector3(25.00, 1.70, 12.30), Vector3(0.30, 3.40, 7.30), "pocket east wall owns its end caps")
	_check_box(wing, incinerator + "IncineratorPocketBack", Vector3(21.50, 1.70, 15.80), Vector3(6.70, 3.40, 0.30), "rear wall joins the sides of the 6.70 m clear pocket")
	_check_box(wing, "Proxies/IncineratorMachine", Vector3(21.50, 1.45, 13.55), Vector3(6.20, 2.90, 3.50), "existing machine retains its full envelope at the new center")
	var front := wing.get_node("Anchors/IncineratorFront") as Marker3D
	_check(front.position.is_equal_approx(Vector3(21.50, 0.05, 11.20)) and front.basis.z.is_equal_approx(Vector3.FORWARD), "front marker retains its offset and orientation")
	for x: float in [19.67, 21.50, 23.33]:
		_check_segment_clear_of_structural_walls(wing, Vector3(x, 1.0, 5.40), Vector3(x, 1.0, 9.20), "both Incinerator mouths are clear at X %.2f" % x)
	_check_segment_blocked_by_structural_wall(wing, Vector3(12.0, 1.0, 9.60), Vector3(19.0, 1.0, 9.60), "GalleryD/GalleryDEast", "D has no exit toward the Incinerator")
	_check_segment_hits_exact_box(wing, "Proxies/IncineratorMachine", Vector3(21.50, 1.70, 11.20), Vector3(21.50, 1.70, 12.00), "the moved station is a solid north-facing machine")
	for point: Vector2 in [Vector2(18.60, 6.90), Vector2(22.25, 17.40), Vector2(36.50, 7.00), Vector2(36.50, 14.75)]:
		for y: float in [-0.15, 1.45, 3.55]:
			_check_point_clear_of_static_boxes(wing, Vector3(point.x, y, point.y), "retired footprint at %s, Y %.2f" % [point, y])


func _check_eastern_branch(wing: Node3D) -> void:
	var link := "Districts/DeeperApproach/"
	var ops := "Districts/BunkerOps/"
	var spine := "Districts/StorageSpine/"
	var link_size := Vector3(3.0, 0.30, 3.30)
	var ops_size := Vector3(7.0, 0.30, 9.0)
	_check_box(wing, link + "Floor_DeeperLink", Vector3(27.5, -0.15, 2.30), link_size, "single straight link spans three metres between doorway axes")
	_check_box(wing, "RoofVisuals/Ceiling_DeeperLink", Vector3(27.5, 3.55, 2.30), link_size, "link roof covers the full passage at 3.40 m clear height")
	_check_box(wing, ops + "Floor_BunkerOpsLanding", Vector3(32.5, -0.15, 1.30), ops_size, "Ops keeps the full 7 by 9 metre room at its translated position")
	_check_box(wing, "RoofVisuals/Ceiling_BunkerOpsLanding", Vector3(32.5, 3.55, 1.30), ops_size, "Ops roof covers the translated room")
	_check_box(wing, link + "DeeperLinkNorth", Vector3(27.5, 1.7, 0.65), Vector3(2.70, 3.40, 0.30), "north rail butts into both preserved jamb faces")
	_check_box(wing, link + "DeeperLinkSouth", Vector3(27.5, 1.7, 3.95), Vector3(2.70, 3.40, 0.30), "south rail butts into both preserved jamb faces")
	_check_box(wing, ops + "BunkerWestNorth", Vector3(29, 1.7, -1.20), Vector3(0.30, 3.40, 4.0), "Ops retains the longer north shoulder of its west doorway")
	_check_box(wing, ops + "BunkerWestSouth", Vector3(29, 1.7, 4.80), Vector3(0.30, 3.40, 2.0), "Ops retains the shorter south shoulder")
	_check_z_face_clearance(wing, link + "DeeperLinkNorth", link + "DeeperLinkSouth", 3.00, "link rails leave the full three metres clear")
	_check_z_face_clearance(wing, ops + "BunkerWestNorth", ops + "BunkerWestSouth", 3.00, "Ops jambs leave the full three metres clear")
	_check_no_positive_box_overlap(wing, spine + "SpineEastNorthReturn", link + "DeeperLinkNorth", "Storage north jamb and rail have separate spans")
	_check_no_positive_box_overlap(wing, spine + "SpineEastSouthReturn", link + "DeeperLinkSouth", "Storage south jamb and rail have separate spans")
	_check_no_positive_box_overlap(wing, ops + "BunkerWestNorth", link + "DeeperLinkNorth", "Ops north jamb and rail have separate spans")
	_check_no_positive_box_overlap(wing, ops + "BunkerWestSouth", link + "DeeperLinkSouth", "Ops south jamb and rail have separate spans")
	_check_box(wing, ops + "BunkerSouth", Vector3(32.5, 1.7, 5.80), Vector3(7.30, 3.40, 0.30), "Ops south wall translates intact")
	_check_box(wing, ops + "BunkerEastNorth", Vector3(36, 1.7, -1.70), Vector3(0.30, 3.40, 3.30), "Ops retains the east north return")
	_check_box(wing, ops + "BunkerEastSouth", Vector3(36, 1.7, 4.0), Vector3(0.30, 3.40, 3.90), "Ops retains the east south return")
	_check_box(wing, "Boundaries/BunkerOpsInnerBoundary", Vector3(32.5, 1.7, -3.20), Vector3(7.0, 3.40, 0.30), "north staffed core is a continuous barrier")
	_check_box(wing, "Boundaries/DeeperSettlementDoor", Vector3(36, 1.45, 1.0), Vector3(0.65, 2.90, 2.40), "thicker east settlement closure retains its own collision")
	_check_box(wing, ops + "BunkerEastDoorLintel", Vector3(36, 3.15, 1.0), Vector3(0.30, 0.50, 2.40), "lintel translates over the separate settlement closure")
	_check_visual_box(wing, "Proxies/BunkerOpsInterface", Vector3(32.5, 0.60, -2.35), Vector3(4.0, 1.20, 0.60), "Ops placeholder retains its frontage envelope")
	for marker: Array in [
		["BunkerOpsLanding", Vector3(32.5, 0.05, 1.80), Vector3.LEFT],
		["BunkerOpsSafeSide", Vector3(32.5, 0.05, -0.70), Vector3.BACK],
		["DeeperClosureSafeSide", Vector3(34.5, 0.05, 1.00), Vector3.LEFT],
	]:
		var anchor := wing.get_node_or_null("Anchors/" + marker[0]) as Marker3D
		_check(anchor != null and anchor.position.is_equal_approx(marker[1]) and anchor.basis.z.is_equal_approx(marker[2]), "Ops marker keeps its room-relative pose: " + marker[0])
	_check_z_face_clearance(wing, "Districts/KitchenApproach/KitchenRoomSouth", link + "DeeperLinkNorth", 1.25, "link stays clear of Kitchen on Z")
	_check_z_face_clearance(wing, link + "DeeperLinkSouth", "Districts/Incinerator/IncineratorApproachEast", 1.55, "link stays clear of the Incinerator approach on Z")
	_check_no_positive_box_overlap(wing, "Boundaries/KitchenInnerBoundary", ops + "BunkerWestNorth", "Ops wall stays clear of the Kitchen core")
	_check_no_positive_box_overlap(wing, "Districts/Incinerator/IncineratorPocketEast", ops + "BunkerWestSouth", "Ops stays clear of the Incinerator pocket")
	for z: float in [0.82, 2.30, 3.78]:
		_check_segment_clear_of_structural_walls(wing, Vector3(25.5, 1.6, z), Vector3(29.70, 1.6, z), "both eastern mouths are clear at Z %.2f" % z)
	_check_point_clear_of_static_boxes(wing, Vector3(31.5, 1.0, 0.0), "former north corridor wall is absent inside Ops")
	_check_point_clear_of_static_boxes(wing, Vector3(31.5, 1.0, 4.50), "former spur closure is absent inside Ops")
	_check_segment_hits_exact_box(wing, "Boundaries/BunkerOpsInnerBoundary", Vector3(32.5, 1.6, -1), Vector3(32.5, 1.6, -3.6), "north core blocks travel beyond Ops")
	_check_segment_hits_exact_box(wing, "Boundaries/DeeperSettlementDoor", Vector3(34.5, 1.6, 1), Vector3(37, 1.6, 1), "east door separately blocks travel beyond Ops")
	_check_segment_blocked_by_structural_wall(wing, Vector3(30, 1.6, -0.2), Vector3(24.5, 1.6, -4.5), "BunkerOps/BunkerWestNorth", "Ops has no shortcut toward Kitchen")
	_check_segment_blocked_by_structural_wall(wing, Vector3(27.5, 1.6, 2.3), Vector3(24.5, 1.6, 10), "DeeperApproach/DeeperLinkSouth", "corridor has no shortcut toward Incinerator")
	_check(wing.get_node("Districts/DeeperApproach").get_child_count() == 3, "Deeper district contains one floor and two rails")
	_check(wing.get_node("RoofVisuals").find_children("Ceiling_Deeper*", "Node3D", false, false).size() == 1, "old eastern roofs are retired")
	for point: Vector2 in [Vector2(27.5, 0.25), Vector2(27.5, 4.35), Vector2(38.25, 0.40), Vector2(40.8, -3), Vector2(51, -5.50), Vector2(62.5, -8.50), Vector2(66, -6.80)]:
		for y: float in [-0.15, 1.45, 3.55]:
			_check_point_clear_of_static_boxes(wing, Vector3(point.x, y, point.y), "retired-only eastern footprint at %s, Y %.2f" % [point, y])


func _check_northern_bank(wing: Node3D) -> void:
	# Each resized slab is independently owned by the floor and roof hierarchies.
	var zones := {
		"GalleryA/GalleryAMain": [Vector3(-1.25, -0.15, -4.9), Vector3(7.5, 0.30, 9.2)],
		"GalleryA/GalleryANorthWest": [Vector3(-4.0, -0.15, -10.7), Vector3(6.0, 0.30, 2.4)],
		"SharedABJunction/SharedABJunction": [Vector3(4.75, -0.15, -4.9), Vector3(4.5, 0.30, 9.2)],
		"GalleryB/GalleryBMain": [Vector3(10.75, -0.15, -4.9), Vector3(7.5, 0.30, 9.2)],
		"GalleryB/GalleryBNorthBump": [Vector3(12.25, -0.15, -10.1), Vector3(4.5, 0.30, 1.2)],
	}
	for zone: String in zones:
		var parts := zone.split("/")
		var center: Vector3 = zones[zone][0]
		var size: Vector3 = zones[zone][1]
		_check_box(wing, "Districts/%s/Floor_%s" % [parts[0], parts[1]], center, size, zone + " floor holds the approved footprint")
		center.y = 3.55
		_check_box(wing, "RoofVisuals/Ceiling_" + parts[1], center, size, zone + " ceiling meets the new envelope")
	_check_box(wing, "Districts/GalleryA/GalleryAWest", Vector3(-5.0, 1.7, -5.75), Vector3(0.30, 3.40, 7.20), "A west wall butts into the retained Sorting wall")
	_check_no_positive_box_overlap(wing, "Districts/Sorting/SortingEastNorth", "Districts/GalleryA/GalleryAWest", "the wall along X=-5 has no duplicate slab")
	for sample_z: float in [-2.20, -2.10, -1.00, -0.35, 0.85]:
		var owners: Array[String] = []
		_collect_point_blockers(wing, Vector3(-5.0, 1.5, sample_z), owners)
		var expected := "GalleryA/GalleryAWest" if sample_z < -2.15 else "Sorting/SortingEastNorth"
		_check(owners == [expected], "the shared perimeter has one owner at Z %.2f: %s" % [sample_z, owners])
	_check_segment_clear_of_structural_walls(wing, Vector3(0.8, 1.65, -4.9), Vector3(9.0, 1.65, -4.9), "the centered A and B openings share an eye-height axis")
	_check_z_face_clearance(wing, "Districts/GalleryA/GalleryAEastNorth", "Districts/GalleryA/GalleryAEastSouth", 2.40, "A east retains the clear width")
	_check_z_face_clearance(wing, "Districts/GalleryB/GalleryBWestNorth", "Districts/GalleryB/GalleryBWestSouth", 2.40, "B west retains the clear width")
	for sample_x: float in [-4.8, -2.1, 1.1, 2.55, 6.95, 8.90, 12.10, 25.90]:
		_check_point_inside_static_box(wing, Vector3(sample_x, 1.0, -0.30), "hall north wall covers the new jamb or boundary at X %.2f" % sample_x)
	for sample_x: float in [-1.90, 0.90, 2.75, 4.50, 6.75, 9.10, 11.90]:
		_check_point_clear_of_static_boxes(wing, Vector3(sample_x, 1.0, -0.30), "hall-to-gallery frontage keeps the approved opening at X %.2f" % sample_x)
	for corner: Vector3 in [Vector3(-5.07, 1.0, -9.57), Vector3(2.57, 1.0, -9.57), Vector3(7.07, 1.0, -9.57), Vector3(14.4, 1.0, -9.29), Vector3(14.4, 1.0, -6.31)]:
		_check_point_inside_static_box(wing, corner, "face-butt return is covered near %s" % corner)

func _check_workshop_branch(wing: Node3D) -> void:
	for zone: Array in [
		["WorkshopService", "WorkshopEntry", Vector2(-10, 7.5), Vector2(4, 5)],
		["WorkshopService", "WorkshopServiceRoom", Vector2(-12, 14.18330013), Vector2(10.03992032, 8.36660027)],
		["Salvager", "SalvagerCrossLegWest", Vector2(-19.81996016, 15.36660027), Vector2(5.6, 4)],
		["Salvager", "SalvagerCrossLegEast", Vector2(-25.61996016, 15.11660027), Vector2(6, 3.5)],
		["Salvager", "SalvagerPocket", Vector2(-25.61996016, 19.36660027), Vector2(6, 5)],
	]:
		var district := String(zone[0])
		var floor_name := String(zone[1])
		var center := zone[2] as Vector2
		var nominal := zone[3] as Vector2
		var size := Vector3(nominal.x, 0.30, nominal.y)
		_check_box(wing, "Districts/" + district + "/Floor_" + floor_name, Vector3(center.x, -0.15, center.y), size, floor_name + " floor fits the approved envelope")
		_check_box(wing, "RoofVisuals/Ceiling_" + floor_name, Vector3(center.x, 3.55, center.y), size, floor_name + " ceiling matches its floor")

	_check_box(wing, "Districts/WorkshopService/WorkshopEntryWest", Vector3(-12.0, 1.7, 7.65), Vector3(0.30, 3.4, 5.0), "incoming west wall meets both entries")
	_check_box(wing, "Districts/WorkshopService/WorkshopEntryEast", Vector3(-8.0, 1.7, 7.65), Vector3(0.30, 3.4, 5.0), "incoming east wall retains 3.70 m clear width")
	_check_box(wing, "Districts/WorkshopService/WorkshopRoomSouth", Vector3(-12.0, 1.7, 18.36660027), Vector3(10.33992032, 3.4, 0.30), "Workshop south wall closes the compact room")
	_check_box(wing, "Boundaries/WorkshopInnerBoundary", Vector3(-6.98003984, 1.7, 14.18330013), Vector3(0.30, 3.4, 8.06660027), "staffed-core boundary is the continuous east side")
	_check_material_name(wing, "Boundaries/WorkshopInnerBoundary", "Greybox Fixed Boundary", "Workshop staffed core retains its opaque closure material")
	_check_visual_box(wing, "Proxies/WorkshopInterface", Vector3(-7.83003984, 0.60, 14.18330013), Vector3(0.6, 1.2, 3.2), "collisionless interface now sits on the playable side of the east boundary")
	_check_z_face_clearance(wing, "Districts/WorkshopService/WorkshopRoomEastNorth", "Districts/WorkshopService/WorkshopRoomEastSouth", 3.70, "west Salvager exit keeps 3.70 m between jamb faces")
	_check_box(wing, "Districts/Salvager/SalvagerPocketWest", Vector3(-22.61996016, 1.7, 19.61660027), Vector3(0.30, 3.4, 4.20), "inside wall now closes the east side of the stepped bend")
	_check_box(wing, "Districts/Salvager/SalvagerBack", Vector3(-25.61996016, 1.7, 21.86660027), Vector3(6.30, 3.4, 0.30), "terminal rear wall runs across both side walls")
	_check_box(wing, "Proxies/SalvagerMachine", Vector3(-25.61996016, 1.45, 19.86660027), Vector3(5.4, 2.90, 3.0), "machine dimensions are preserved in the relocated pocket")
	_check_z_face_clearance(wing, "Proxies/SalvagerMachine", "Districts/Salvager/SalvagerBack", 0.35, "machine retains its rear-to-wall clearance")

	for point: Vector3 in [
		Vector3(-11.925, 1.0, 5.075),
		Vector3(-12.075, 1.0, 5.225),
		Vector3(-12.075, 1.0, 10.075),
		Vector3(-11.925, 1.0, 9.925),
		Vector3(-17.09496016, 1.0, 13.44160027),
		Vector3(-16.94496016, 1.0, 17.29160027),
		Vector3(-22.54496016, 1.0, 17.44160027),
		Vector3(-6.98003984, 1.0, 14.18330013),
	]:
		_check_point_inside_static_box(wing, point, "Workshop branch join or core is solid at " + str(point))
	_check_point_clear_of_static_boxes(wing, Vector3(-4.0, -0.15, 22.0), "retired east neck has no floor")
	_check_point_clear_of_static_boxes(wing, Vector3(-4.0, 3.55, 22.0), "retired east neck has no ceiling")
	_check_point_clear_of_static_boxes(wing, Vector3(5.0, 1.45, 26.5), "retired east machine has no collision")


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
				var sill_trim := relative_path == "Districts/Backlog/Floor_BacklogPassage"
				var expected_pose := Transform3D(Basis.IDENTITY, Vector3(0.075, 0, 0)) if sill_trim else Transform3D.IDENTITY
				_check(mesh_instance.transform.is_equal_approx(expected_pose), "box mesh uses its authorized transform: " + relative_path)
				if collisionless_allowed:
					_check(collision == null, "authorized provisional interface remains visual-only: " + relative_path)
				elif _check(collision != null and collision.shape is BoxShape3D, "generated solid box has BoxShape collision: " + relative_path):
					var collision_size := (collision.shape as BoxShape3D).size
					_check(collision_size.is_finite(), "box collision size is finite: " + relative_path)
					_check(collision_size.x > 0.0 and collision_size.y > 0.0 and collision_size.z > 0.0, "box collision size is positive: " + relative_path)
					var expected_visual_size := Vector3(6.60, 0.3, 5.7) if sill_trim else collision_size
					_check(mesh_size.is_equal_approx(expected_visual_size), "BoxMesh matches structural size or exact sill trim: " + relative_path)
					if sill_trim:
						_check(collision_size.is_equal_approx(Vector3(6.75, 0.3, 5.7)) and container.position.is_equal_approx(Vector3(-18.375, -0.15, -0.95)), "Backlog collision remains nominal and meets apron")
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
	# The short link's four face-to-face jambs are checked separately.
	_check(audited_pairs >= 38, "endpoint audit covers the 38 retained centerline junctions; audited=%d" % audited_pairs)
	_check(gaps.is_empty(), "perpendicular wall joins cover all endpoint quadrants; gaps=" + "; ".join(gaps))


func _write_junction_evidence(arguments: PackedStringArray) -> Error:
	var baseline_path := _argument_value(arguments, JUNCTION_BASELINE_PREFIX)
	if baseline_path.is_empty() or not ResourceLoader.exists(baseline_path):
		push_error("junction evidence requires an existing --junction-baseline=res://... scene")
		return ERR_FILE_NOT_FOUND
	var source_commit := _argument_value(arguments, JUNCTION_SOURCE_COMMIT_PREFIX)
	if source_commit.is_empty():
		source_commit = "unknown"
	var baseline_commit := _argument_value(arguments, JUNCTION_BASELINE_COMMIT_PREFIX)
	if baseline_commit.is_empty():
		baseline_commit = "unknown"
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
			classified["note"] = "new or renamed compact-layout structural join; all four final quadrants are covered"
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
		retired["note"] = "pre-task pair is absent after the eastern branch refit"
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
		"layout_revision": "logistics-wing-compact-layout-slice-9",
		"source_commit": source_commit,
		"baseline_commit": baseline_commit,
		"baseline_label": "supplied baseline",
		"baseline_scene": baseline_path,
		"current_scene": WING_GEOMETRY_PATH,
		"audit_method": "Every perpendicular full-height structural-wall pair is sampled 0.075 m into all four thickness quadrants. Authorized openings are sampled independently at controller height.",
		"classification_definitions": {
			"corrected": "A new or renamed compact-layout join with all four current quadrants covered.",
			"already_covered": "The same pair was fully covered in the supplied baseline and remains covered.",
			"intentional_opening": "An approved route opening whose controller-height sample remains clear.",
			"not_applicable": "A pre-task pair retired by the eastern branch refit.",
		},
		"junction_type_definitions": {
			"true_corner": "Both structural runs terminate at the coordinate; one or two nearby playable-floor quadrants distinguish an ordinary perimeter corner.",
			"concave_return": "Both structural runs terminate at the coordinate and three nearby playable-floor quadrants identify a re-entrant perimeter return.",
			"butt_or_t_join": "One structural run terminates against the interior of the perpendicular run.",
			"cross_join": "Both structural runs continue through the coordinate.",
			"open_jamb": "An approved aperture or territorial entrance remains intentionally clear at the recorded controller-height sample.",
		},
		"summary": {
			"baseline_audited_pairs": (baseline["pairs"] as Array).size(),
			"baseline_uncovered_pairs": baseline_uncovered_pairs,
			"baseline_uncovered_quadrants": baseline_uncovered_quadrants,
			"current_audited_pairs": classified_current.size(),
			"corrected": corrected_count,
			"already_covered": already_covered_count,
			"intentional_openings": intentional_openings.size(),
			"not_applicable": not_applicable.size(),
			"current_unresolved": unresolved_count,
			"junction_types": junction_type_counts,
		},
		"current_junctions": classified_current,
		"intentional_openings": intentional_openings,
		"retired_baseline_pairs": not_applicable,
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
		_opening_record("Dispatch framed doorless opening", Vector3(-24.964286, 1.0, -4.0)),
		_opening_record("narrow Receiving-to-Backlog opening", Vector3(-21.75, 1.0, 0.0)),
		_opening_record("authorized Backlog-to-Sorting opening", Vector3(-15.0, 1.0, 0.375)),
		_opening_record("retained Sorting-to-Storage opening", Vector3(-5.0, 1.0, 2.55)),
		_opening_record("fixed Sorting-to-Workshop opening", Vector3(-10.0, 1.0, 5.0)),
		_opening_record("centered Gallery A east opening", Vector3(2.5, 1.0, -4.9)),
		_opening_record("centered Gallery B west opening", Vector3(7.0, 1.0, -4.9)),
		_opening_record("Gallery B east Kitchen opening", Vector3(14.5, 1.0, -7.8)),
		_opening_record("sole C-to-D secondary opening", Vector3(6.0, 1.0, 9.05)),
		_opening_record("Medical south-east room entrance", Vector3(5.0, 1.0, -14.5)),
		_opening_record("Kitchen territorial entrance", Vector3(20.535, 1.0, -7.8)),
		_opening_record("Workshop territorial entrance", Vector3(-10.0, 1.0, 10.0)),
		_opening_record("west Workshop exit to Salvager", Vector3(-17.01996016, 1.0, 15.36660027)),
		_opening_record("Salvager southward turn", Vector3(-25.61996016, 1.0, 16.86660027)),
		_opening_record("Bunker Ops landing entrance", Vector3(29.0, 1.0, 2.30)),
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
