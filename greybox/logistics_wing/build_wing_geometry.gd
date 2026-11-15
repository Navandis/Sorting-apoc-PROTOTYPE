@tool
extends SceneTree

const OUTPUT_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const FLOOR_THICKNESS := 0.30
const WALL_THICKNESS := 0.30
const CLEAR_HEIGHT := 3.40
const RECEIVING_HEIGHT := 4.20

const RECEIVING_SHIFT := Vector3(6.75, 0.0, 0.0)
const FREIGHT_FLOOR_WEST := -41.0
const BACKLOG_WEST := -28.5 + RECEIVING_SHIFT.x
const BACKLOG_EAST := -15.0
const BACKLOG_NORTH := -3.8
const BACKLOG_SOUTH := 1.9
# Keep the accepted Backlog-to-Sorting opening independent of the north wall.
const SORTING_OPEN_NORTH := -0.85
const SORTING_OPEN_SOUTH := 1.60
const SORTING_EAST := -5.0
const SORTING_NORTH := -2.0
const SORTING_SOUTH := 5.0
const SORTING_POCKET_NORTH := -3.32
const STORAGE_BANK_SHIFT := 1.20
const STORAGE_NORTH := -1.50 + STORAGE_BANK_SHIFT
const STORAGE_WEST_SOUTH := 5.50 - STORAGE_BANK_SHIFT
const STORAGE_EAST_SOUTH := 7.00 - STORAGE_BANK_SHIFT
const STORAGE_ENTRY_SOUTH := STORAGE_WEST_SOUTH - WALL_THICKNESS * 0.5
const STORAGE_ENTRY_NORTH := STORAGE_ENTRY_SOUTH - 3.20
const STORAGE_EAST := 26.0
const DEEPER_OPEN_NORTH := 0.80
const DEEPER_OPEN_SOUTH := 3.80
const DEEPER_LINK_NORTH := DEEPER_OPEN_NORTH - WALL_THICKNESS * 0.5
const DEEPER_LINK_SOUTH := DEEPER_OPEN_SOUTH + WALL_THICKNESS * 0.5
const BUNKER_OPS_WEST := STORAGE_EAST + 3.00
const BUNKER_OPS_EAST := BUNKER_OPS_WEST + 7.00
const BUNKER_OPS_NORTH := DEEPER_OPEN_NORTH - 4.00
const BUNKER_OPS_SOUTH := DEEPER_OPEN_SOUTH + 2.00
const BUNKER_OPS_CENTER_X := (BUNKER_OPS_WEST + BUNKER_OPS_EAST) * 0.5
const BUNKER_OPS_DOOR_Z := BUNKER_OPS_NORTH + 4.20
const INCINERATOR_CENTER_X := 21.50
const INCINERATOR_APPROACH_WEST := INCINERATOR_CENTER_X - 2.0
const INCINERATOR_APPROACH_EAST := INCINERATOR_CENTER_X + 2.0
const INCINERATOR_POCKET_WEST := INCINERATOR_CENTER_X - 3.50
const INCINERATOR_POCKET_EAST := INCINERATOR_CENTER_X + 3.50
const INCINERATOR_POCKET_NORTH := STORAGE_EAST_SOUTH + 3.00
const INCINERATOR_POCKET_SOUTH := INCINERATOR_POCKET_NORTH + 7.00
const INCINERATOR_MACHINE_Z := INCINERATOR_POCKET_SOUTH - 2.25
const NORTHERN_GALLERY_NORTH := -9.50
const GALLERY_A_ALCOVE_NORTH := -11.90
const GALLERY_B_BUMP_NORTH := -10.70
const GALLERY_A_EAST := 2.50
const GALLERY_B_WEST := 7.00
const GALLERY_B_EAST := 14.50
const GALLERY_SIDE_OPEN_NORTH := -6.10
const GALLERY_SIDE_OPEN_SOUTH := -3.70
const MEDICAL_CORRIDOR_WEST := 3.80
const MEDICAL_CORRIDOR_EAST := 6.20
const MEDICAL_CORRIDOR_SOUTH := NORTHERN_GALLERY_NORTH
const MEDICAL_ROOM_ENTRY_Z := MEDICAL_CORRIDOR_SOUTH - 5.0
const MEDICAL_ROOM_WEST := -1.60
const MEDICAL_ROOM_NORTH := MEDICAL_ROOM_ENTRY_Z - 7.0
const MEDICAL_ROOM_CENTER_X := (MEDICAL_ROOM_WEST + MEDICAL_CORRIDOR_EAST) * 0.5
const MEDICAL_ROOM_CENTER_Z := (MEDICAL_ROOM_NORTH + MEDICAL_ROOM_ENTRY_Z) * 0.5
# Keep the future rotated Kitchen 0.30 m clear of the north face of Storage.
const KITCHEN_ENTRY_Z := -7.80
const KITCHEN_ENTRY_HALF_SPAN := 1.40
const KITCHEN_APPROACH_NORTH := KITCHEN_ENTRY_Z - KITCHEN_ENTRY_HALF_SPAN
const KITCHEN_APPROACH_SOUTH := KITCHEN_ENTRY_Z + KITCHEN_ENTRY_HALF_SPAN
const KITCHEN_ROOM_WEST := GALLERY_B_EAST + 6.035
const KITCHEN_ROOM_EAST := KITCHEN_ROOM_WEST + 7.0
# The clockwise rotation retains the entry's 3.60 m offset from the north wall.
const KITCHEN_ROOM_NORTH := KITCHEN_ENTRY_Z - 3.60
const KITCHEN_ROOM_SOUTH := KITCHEN_ROOM_NORTH + 10.50
const KITCHEN_ROOM_CENTER_Z := (KITCHEN_ROOM_NORTH + KITCHEN_ROOM_SOUTH) * 0.5
const WORKSHOP_ENTRY_WEST := -12.0
const WORKSHOP_ENTRY_EAST := -8.0
const WORKSHOP_NORTH := SORTING_SOUTH + 5.0
const WORKSHOP_CENTER_X := -12.0
const WORKSHOP_ROOM_SCALE := 0.8366600265340756 # sqrt(0.70)
const WORKSHOP_WEST := WORKSHOP_CENTER_X - 6.0 * WORKSHOP_ROOM_SCALE
const WORKSHOP_EAST := WORKSHOP_CENTER_X + 6.0 * WORKSHOP_ROOM_SCALE
const WORKSHOP_SOUTH := WORKSHOP_NORTH + 10.0 * WORKSHOP_ROOM_SCALE
const WORKSHOP_CENTER_Z := (WORKSHOP_NORTH + WORKSHOP_SOUTH) * 0.5

const SALVAGER_NECK_NORTH := WORKSHOP_SOUTH - 5.0
const SALVAGER_NECK_SOUTH := WORKSHOP_SOUTH - 1.0
const SALVAGER_TURN_EAST := WORKSHOP_WEST - 5.60
const SALVAGER_TURN_WEST := SALVAGER_TURN_EAST - 6.0
const SALVAGER_TURN_SOUTH := SALVAGER_NECK_NORTH + 3.50
const SALVAGER_BACK := SALVAGER_TURN_SOUTH + 5.0
const SALVAGER_CENTER_X := (SALVAGER_TURN_EAST + SALVAGER_TURN_WEST) * 0.5

# Measure between the translated Freight floor and Ops, with Medical and Salvager on Z.
const FOOTPRINT_EXTENTS := Vector3(BUNKER_OPS_EAST - (FREIGHT_FLOOR_WEST + RECEIVING_SHIFT.x), RECEIVING_HEIGHT, SALVAGER_BACK - MEDICAL_ROOM_NORTH)

const TOPOLOGY_EDGES := [
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

var _root: Node3D
var _districts: Node3D
var _boundaries: Node3D
var _proxies: Node3D
var _anchors: Node3D
var _roof_visuals: Node3D
var _materials: Dictionary = {}


func _init() -> void:
	call_deferred("_build_and_save")


func _build_and_save() -> void:
	_create_roots()
	_create_materials()
	_build_floor_and_ceiling_plan()
	_build_structural_walls()
	_build_fixed_boundaries()
	_build_spatial_proxies()
	_build_anchors()
	_translate_receiving_and_dispatch()
	_translate_storage_banks()
	var packed := PackedScene.new()
	var pack_error := packed.pack(_root)
	if pack_error != OK:
		push_error("WING_GEOMETRY_FAILED pack: " + error_string(pack_error))
		quit(1)
		return
	var save_error := ResourceSaver.save(packed, OUTPUT_PATH)
	if save_error != OK:
		push_error("WING_GEOMETRY_FAILED save: " + error_string(save_error))
		quit(1)
		return
	print("WING_GEOMETRY_GENERATED path=%s floor_plan_extents=%sx%sm nodes=%d" % [OUTPUT_PATH, FOOTPRINT_EXTENTS.x, FOOTPRINT_EXTENTS.z, _count_nodes(_root)])
	_root.free()
	_root = null
	_materials.clear()
	packed = null
	await process_frame
	quit(0)


func _create_roots() -> void:
	_root = Node3D.new()
	_root.name = "WingGeometry"
	_root.set_meta("layout_revision", "logistics-wing-compact-layout-slice-9")
	_root.set_meta("regeneration_command", "godot --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd")
	_root.set_meta("overall_extents_m", FOOTPRINT_EXTENTS)
	_root.set_meta("shared_ab_measurement_group", "MainStorage")
	_root.set_meta("wall_thickness_m", WALL_THICKNESS)
	_root.set_meta("clear_height_m", CLEAR_HEIGHT)
	_root.set_meta("receiving_clear_height_m", RECEIVING_HEIGHT)
	_root.set_meta("topology_edges", PackedStringArray(TOPOLOGY_EDGES))
	_root.set_meta("forbidden_edges", PackedStringArray(FORBIDDEN_EDGES))
	_root.set_meta("coordinate_note", "+X east, +Z south, Y=0 finished floor")
	_districts = _owned_node(_root, Node3D.new(), "Districts") as Node3D
	_boundaries = _owned_node(_root, Node3D.new(), "Boundaries") as Node3D
	_proxies = _owned_node(_root, Node3D.new(), "Proxies") as Node3D
	_anchors = _owned_node(_root, Node3D.new(), "Anchors") as Node3D
	_roof_visuals = _owned_node(_root, Node3D.new(), "RoofVisuals") as Node3D
	for district_name: String in [
		"Receiving", "Backlog", "Sorting", "StorageSpine", "GalleryA",
		"GalleryB", "GalleryC", "GalleryD", "MedicalApproach",
		"KitchenApproach", "WorkshopService", "Salvager", "DeeperApproach",
		"Incinerator", "BunkerOps", "SharedABJunction",
	]:
		_owned_node(_districts, Node3D.new(), district_name)


func _create_materials() -> void:
	_materials["wall"] = _material("Greybox Wall", Color("8b9094"))
	_materials["floor_core"] = _material("Greybox Core Floor", Color("4a5258"))
	_materials["floor_storage"] = _material("Greybox Storage Floor", Color("57564f"))
	_materials["floor_shared"] = _material("Greybox Shared Floor", Color("505a55"))
	_materials["floor_service"] = _material("Greybox Service Floor", Color("5b5149"))
	_materials["ceiling"] = _material("Greybox Ceiling", Color("676c70"))
	_materials["proxy"] = _material("Greybox Proxy", Color("746b5b"))
	_materials["machine"] = _material("Greybox Machine", Color("605f68"))
	_materials["closure"] = _material("Greybox Fixed Boundary", Color("595157"))
	_materials["barrier"] = _material("Greybox Freight Barrier", Color("9b804b"))
	_materials["interface"] = _material("Greybox Interface Envelope", Color("557078"))


func _build_floor_and_ceiling_plan() -> void:
	# Western logistics core.
	_floor_zone("Receiving", "ReceivingApron", -36.0, -28.5, -4.0, 4.0, RECEIVING_HEIGHT, "floor_core")
	_floor_zone("Receiving", "FreightEnclosure", FREIGHT_FLOOR_WEST, -36.0, -3.5, 3.5, RECEIVING_HEIGHT, "floor_core")
	_floor_zone("Receiving", "DispatchAnnex", -35.0, -28.5, -7.5, -4.0, RECEIVING_HEIGHT, "floor_core")
	_floor_zone_with_ceiling_west("Backlog", "BacklogPassage", BACKLOG_WEST, BACKLOG_EAST, BACKLOG_WEST + WALL_THICKNESS * 0.5, BACKLOG_NORTH, BACKLOG_SOUTH, CLEAR_HEIGHT, "floor_core")
	_floor_zone("Sorting", "SortingPassage", BACKLOG_EAST, SORTING_EAST, SORTING_NORTH, SORTING_SOUTH, CLEAR_HEIGHT, "floor_core")
	_floor_zone("Sorting", "SortingPocket", -14.0, -6.0, SORTING_POCKET_NORTH, SORTING_NORTH, CLEAR_HEIGHT, "floor_core")

	# Bent, variable-width primary Storage spine and four galleries.
	_floor_zone("StorageSpine", "StorageSpineWest", SORTING_EAST, 4.5, STORAGE_NORTH, STORAGE_WEST_SOUTH, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("StorageSpine", "StorageSpineEast", 4.5, STORAGE_EAST, STORAGE_NORTH, STORAGE_EAST_SOUTH, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("SharedABJunction", "SharedABJunction", GALLERY_A_EAST, GALLERY_B_WEST, NORTHERN_GALLERY_NORTH, STORAGE_NORTH, CLEAR_HEIGHT, "floor_storage")
	_district("SharedABJunction").set_meta("diagnostic_classification", "Main Storage circulation")
	_district("SharedABJunction").set_meta("measurement_group", "MainStorage")
	_floor_zone("GalleryA", "GalleryAMain", SORTING_EAST, GALLERY_A_EAST, NORTHERN_GALLERY_NORTH, STORAGE_NORTH, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryA", "GalleryANorthWest", -7.0, -1.0, GALLERY_A_ALCOVE_NORTH, NORTHERN_GALLERY_NORTH, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryB", "GalleryBMain", GALLERY_B_WEST, GALLERY_B_EAST, NORTHERN_GALLERY_NORTH, STORAGE_NORTH, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryB", "GalleryBNorthBump", 10.0, GALLERY_B_EAST, GALLERY_B_BUMP_NORTH, NORTHERN_GALLERY_NORTH, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryC", "GalleryCMainNorth", -2.0, 4.5, 5.5, 7.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryC", "GalleryCMainBody", -2.0, 6.0, 7.0, 11.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryC", "GalleryCSouthWest", -2.0, 2.0, 11.5, 15.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryD", "GalleryDMain", 6.0, 15.5, 7.0, 17.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryD", "GalleryDSouthBump", 9.5, 12.5, 17.5, 19.0, CLEAR_HEIGHT, "floor_storage")

	# Protected approaches and distinct playable departmental support rooms.
	_floor_zone("MedicalApproach", "MedicalCorridor", MEDICAL_CORRIDOR_WEST, MEDICAL_CORRIDOR_EAST, MEDICAL_ROOM_ENTRY_Z, MEDICAL_CORRIDOR_SOUTH, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("MedicalApproach", "MedicalAnteroom", MEDICAL_ROOM_WEST, MEDICAL_CORRIDOR_EAST, MEDICAL_ROOM_NORTH, MEDICAL_ROOM_ENTRY_Z, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("KitchenApproach", "KitchenEastLeg", GALLERY_B_EAST, KITCHEN_ROOM_WEST, KITCHEN_APPROACH_NORTH, KITCHEN_APPROACH_SOUTH, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("KitchenApproach", "KitchenServiceRoom", KITCHEN_ROOM_WEST, KITCHEN_ROOM_EAST, KITCHEN_ROOM_NORTH, KITCHEN_ROOM_SOUTH, CLEAR_HEIGHT, "floor_shared")

	_floor_zone("WorkshopService", "WorkshopEntry", WORKSHOP_ENTRY_WEST, WORKSHOP_ENTRY_EAST, SORTING_SOUTH, WORKSHOP_NORTH, CLEAR_HEIGHT, "floor_service")
	_floor_zone("WorkshopService", "WorkshopServiceRoom", WORKSHOP_WEST, WORKSHOP_EAST, WORKSHOP_NORTH, WORKSHOP_SOUTH, CLEAR_HEIGHT, "floor_service")
	# Keep the saved floor paths. CrossLegWest is the straight neck, and CrossLegEast is the terminal turn.
	_floor_zone("Salvager", "SalvagerCrossLegWest", SALVAGER_TURN_EAST, WORKSHOP_WEST, SALVAGER_NECK_NORTH, SALVAGER_NECK_SOUTH, CLEAR_HEIGHT, "floor_service")
	_floor_zone("Salvager", "SalvagerCrossLegEast", SALVAGER_TURN_WEST, SALVAGER_TURN_EAST, SALVAGER_NECK_NORTH, SALVAGER_TURN_SOUTH, CLEAR_HEIGHT, "floor_service")
	_floor_zone("Salvager", "SalvagerPocket", SALVAGER_TURN_WEST, SALVAGER_TURN_EAST, SALVAGER_TURN_SOUTH, SALVAGER_BACK, CLEAR_HEIGHT, "floor_service")

	# The link connects the two doorway axes. Ops keeps its offset west entrance.
	_floor_zone("DeeperApproach", "DeeperLink", STORAGE_EAST, BUNKER_OPS_WEST, DEEPER_LINK_NORTH, DEEPER_LINK_SOUTH, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("BunkerOps", "BunkerOpsLanding", BUNKER_OPS_WEST, BUNKER_OPS_EAST, BUNKER_OPS_NORTH, BUNKER_OPS_SOUTH, CLEAR_HEIGHT, "floor_shared")

	# Direct service branch from the south face of Main Storage.
	_floor_zone("Incinerator", "IncineratorApproach", INCINERATOR_APPROACH_WEST, INCINERATOR_APPROACH_EAST, STORAGE_EAST_SOUTH, INCINERATOR_POCKET_NORTH, CLEAR_HEIGHT, "floor_service")
	_floor_zone("Incinerator", "IncineratorPocket", INCINERATOR_POCKET_WEST, INCINERATOR_POCKET_EAST, INCINERATOR_POCKET_NORTH, INCINERATOR_POCKET_SOUTH, CLEAR_HEIGHT, "floor_service")


func _build_structural_walls() -> void:
	var receiving := _district("Receiving")
	_wall_z(receiving, "ReceivingWestNorthReturn", -36.0, -4.0, -2.5, RECEIVING_HEIGHT)
	_wall_z(receiving, "ReceivingWestSouthReturn", -36.0, 2.5, 4.0, RECEIVING_HEIGHT)
	_wall_x_joined(receiving, "ReceivingSouth", -36.0, -28.5, 4.0, RECEIVING_HEIGHT)
	_wall_x_joined(receiving, "ReceivingNorthWest", -36.0, -35.0, -4.0, RECEIVING_HEIGHT, true, false)
	_wall_z(receiving, "ReceivingEastNorth", -28.5, -4.0, -1.42, RECEIVING_HEIGHT)
	_wall_z(receiving, "ReceivingEastSouth", -28.5, 1.42, 4.0, RECEIVING_HEIGHT)
	_wall_x_joined(receiving, "FreightNorth", -41.0, -36.0, -3.5, RECEIVING_HEIGHT, true, false)
	_wall_x_joined(receiving, "FreightSouth", -41.0, -36.0, 3.5, RECEIVING_HEIGHT, true, false)
	_wall_z(receiving, "FreightRear", -41.0, -3.5, 3.5, RECEIVING_HEIGHT)
	_wall_z_joined(receiving, "DispatchWest", -35.0, -7.5, -4.0, RECEIVING_HEIGHT)
	_wall_x_joined(receiving, "DispatchNorth", -35.0, -28.5, -7.5, RECEIVING_HEIGHT)
	_wall_z_joined(receiving, "DispatchEast", -28.5, -7.5, -4.0, RECEIVING_HEIGHT, true, false)
	_wall_x(receiving, "DispatchSouthWest", -35.0, -32.914285714286, -4.0, RECEIVING_HEIGHT)
	_wall_x_joined(receiving, "DispatchSouthEast", -30.514285714286, -28.5, -4.0, RECEIVING_HEIGHT, false, true)
	_box(receiving, "ReceivingCeilingTransition", Vector3(-28.5, 3.8, 0.0), Vector3(WALL_THICKNESS, 0.8, 2.84), _materials["wall"])

	var backlog := _district("Backlog")
	# Both side walls butt into the preserved Receiving wall's east face.
	var west_face := BACKLOG_WEST + WALL_THICKNESS * 0.5
	_wall_x_joined(backlog, "BacklogNorth", west_face, BACKLOG_EAST, BACKLOG_NORTH, CLEAR_HEIGHT, false, true)
	_wall_x_joined(backlog, "BacklogSouth", west_face, BACKLOG_EAST, BACKLOG_SOUTH, CLEAR_HEIGHT, false, true)
	# The coplanar Backlog and Sorting ceilings form the head of this opening.
	_wall_z(backlog, "BacklogEastNorth", BACKLOG_EAST, BACKLOG_NORTH, SORTING_OPEN_NORTH)
	_wall_z(backlog, "BacklogEastSouth", BACKLOG_EAST, SORTING_OPEN_SOUTH, BACKLOG_SOUTH)

	var sorting := _district("Sorting")
	var half_wall := WALL_THICKNESS * 0.5
	# The west shoulder joins the east face of the retained Backlog jamb.
	# The pocket returns butt into the shoulder and rear-wall faces.
	_wall_x_joined(sorting, "SortingNorthWestShoulder", BACKLOG_EAST + half_wall, -14.0, SORTING_NORTH, CLEAR_HEIGHT, false, true)
	_wall_z(sorting, "SortingPocketWest", -14.0, SORTING_POCKET_NORTH + half_wall, SORTING_NORTH - half_wall)
	_wall_x_joined(sorting, "SortingPocketNorth", -14.0, -6.0, SORTING_POCKET_NORTH)
	_wall_z(sorting, "SortingPocketEast", -6.0, SORTING_POCKET_NORTH + half_wall, SORTING_NORTH - half_wall)
	_wall_x_joined(sorting, "SortingNorthEastShoulder", -6.0, SORTING_EAST - half_wall, SORTING_NORTH, CLEAR_HEIGHT, true, false)
	_wall_x_joined(sorting, "SortingSouthWest", BACKLOG_EAST, -12.0, SORTING_SOUTH)
	_wall_x_joined(sorting, "SortingSouthEast", -8.0, SORTING_EAST, SORTING_SOUTH)
	_wall_z(sorting, "SortingWestSouthShoulder", BACKLOG_EAST, BACKLOG_SOUTH, SORTING_SOUTH)
	# Close the Sorting corner and keep the north face of the Storage doorway.
	_wall_z(sorting, "SortingEastNorth", SORTING_EAST, SORTING_NORTH - half_wall, STORAGE_ENTRY_NORTH)
	_wall_z(sorting, "SortingEastSouth", SORTING_EAST, STORAGE_ENTRY_SOUTH, SORTING_SOUTH)

	var spine := _district("StorageSpine")
	# The hall keeps its floor seam at X = 4.5. The shared junction spans it.
	# Its jambs meet the gallery side walls on the north face of the frontage.
	_wall_x(spine, "SpineWestNorthA", SORTING_EAST + half_wall, -2.0, STORAGE_NORTH)
	_wall_x(spine, "SpineWestNorthB", 1.0, GALLERY_A_EAST + half_wall, STORAGE_NORTH)
	_wall_x(spine, "SpineWestSouthA", SORTING_EAST + half_wall, 0.0, STORAGE_WEST_SOUTH)
	_wall_x(spine, "SpineWestSouthB", 3.0, 4.5, STORAGE_WEST_SOUTH)
	_wall_z(spine, "SpineWestEastClosure", 4.5, STORAGE_WEST_SOUTH, STORAGE_EAST_SOUTH)
	_wall_x(spine, "SpineEastNorthBWest", GALLERY_B_WEST - half_wall, 9.0, STORAGE_NORTH)
	_wall_x_joined(spine, "SpineEastNorthBEast", 12.0, STORAGE_EAST, STORAGE_NORTH, CLEAR_HEIGHT, false, true)
	_wall_x_joined(spine, "SpineEastSouthWest", 4.5, 9.0, STORAGE_EAST_SOUTH, CLEAR_HEIGHT, true, false)
	_wall_x(spine, "SpineEastSouthMid", 12.0, INCINERATOR_APPROACH_WEST - half_wall, STORAGE_EAST_SOUTH)
	_wall_x_joined(spine, "SpineEastSouthEast", INCINERATOR_APPROACH_EAST + half_wall, STORAGE_EAST, STORAGE_EAST_SOUTH, CLEAR_HEIGHT, false, true)
	_wall_z(spine, "SpineEastNorthReturn", STORAGE_EAST, STORAGE_NORTH, DEEPER_OPEN_NORTH)
	_wall_z(spine, "SpineEastSouthReturn", STORAGE_EAST, DEEPER_OPEN_SOUTH, STORAGE_EAST_SOUTH)

	var gallery_a := _district("GalleryA")
	# SortingEastNorth owns the southern part of this continuous west wall.
	_wall_z(gallery_a, "GalleryAWest", SORTING_EAST, NORTHERN_GALLERY_NORTH + half_wall, SORTING_NORTH - half_wall)
	_wall_x(gallery_a, "GalleryANorthWestShoulder", -7.0 + half_wall, SORTING_EAST + half_wall, NORTHERN_GALLERY_NORTH)
	_wall_z_joined(gallery_a, "GalleryANorthWestSide", -7.0, GALLERY_A_ALCOVE_NORTH, NORTHERN_GALLERY_NORTH)
	_wall_x(gallery_a, "GalleryANorthWest", -7.0 + half_wall, -1.0 - half_wall, GALLERY_A_ALCOVE_NORTH)
	_wall_z_joined(gallery_a, "GalleryANorthWestEast", -1.0, GALLERY_A_ALCOVE_NORTH, NORTHERN_GALLERY_NORTH)
	_wall_x(gallery_a, "GalleryANorthEastShoulder", -1.0 + half_wall, GALLERY_A_EAST - half_wall, NORTHERN_GALLERY_NORTH)
	_wall_z(gallery_a, "GalleryAEastNorth", GALLERY_A_EAST, NORTHERN_GALLERY_NORTH - half_wall, GALLERY_SIDE_OPEN_NORTH)
	_wall_z(gallery_a, "GalleryAEastSouth", GALLERY_A_EAST, GALLERY_SIDE_OPEN_SOUTH, STORAGE_NORTH - half_wall)

	var gallery_b := _district("GalleryB")
	_wall_z(gallery_b, "GalleryBWestNorth", GALLERY_B_WEST, NORTHERN_GALLERY_NORTH - half_wall, GALLERY_SIDE_OPEN_NORTH)
	_wall_z(gallery_b, "GalleryBWestSouth", GALLERY_B_WEST, GALLERY_SIDE_OPEN_SOUTH, STORAGE_NORTH - half_wall)
	_wall_x(gallery_b, "GalleryBNorthShoulder", GALLERY_B_WEST + half_wall, 10.0 - half_wall, NORTHERN_GALLERY_NORTH)
	_wall_z_joined(gallery_b, "GalleryBNorthBumpWest", 10.0, GALLERY_B_BUMP_NORTH, NORTHERN_GALLERY_NORTH)
	_wall_x(gallery_b, "GalleryBNorth", 10.0 + half_wall, GALLERY_B_EAST - half_wall, GALLERY_B_BUMP_NORTH)
	# The two Kitchen corridor walls cap the portal and set its clear width.
	_wall_z(gallery_b, "GalleryBEastNorth", GALLERY_B_EAST, GALLERY_B_BUMP_NORTH - half_wall, KITCHEN_ENTRY_Z - KITCHEN_ENTRY_HALF_SPAN - half_wall)
	_wall_z(gallery_b, "GalleryBEastSouth", GALLERY_B_EAST, KITCHEN_ENTRY_Z + KITCHEN_ENTRY_HALF_SPAN + half_wall, STORAGE_NORTH - half_wall)

	var junction := _district("SharedABJunction")
	_wall_x_joined(junction, "SharedJunctionNorthWest", GALLERY_A_EAST + half_wall, MEDICAL_CORRIDOR_WEST, MEDICAL_CORRIDOR_SOUTH, CLEAR_HEIGHT, false, true)
	_wall_x_joined(junction, "SharedJunctionNorthEast", MEDICAL_CORRIDOR_EAST, GALLERY_B_WEST - half_wall, MEDICAL_CORRIDOR_SOUTH, CLEAR_HEIGHT, true, false)

	var medical := _district("MedicalApproach")
	# The fixed shared-junction shoulders own the southern ends of the corridor walls.
	var shared_wall_face := MEDICAL_CORRIDOR_SOUTH - half_wall
	_wall_z(medical, "MedicalCorridorWest", MEDICAL_CORRIDOR_WEST, MEDICAL_ROOM_ENTRY_Z + half_wall, shared_wall_face)
	_wall_z(medical, "MedicalCorridorEast", MEDICAL_CORRIDOR_EAST, MEDICAL_ROOM_ENTRY_Z, shared_wall_face)
	# The room shoulder owns the west doorway corner. The east wall continues through the seam.
	_wall_x(medical, "MedicalRoomSouthWest", MEDICAL_ROOM_WEST + half_wall, MEDICAL_CORRIDOR_WEST + half_wall, MEDICAL_ROOM_ENTRY_Z)
	_wall_z_joined(medical, "MedicalRoomWest", MEDICAL_ROOM_WEST, MEDICAL_ROOM_NORTH, MEDICAL_ROOM_ENTRY_Z)
	_wall_z_joined(medical, "MedicalRoomEast", MEDICAL_CORRIDOR_EAST, MEDICAL_ROOM_NORTH, MEDICAL_ROOM_ENTRY_Z, CLEAR_HEIGHT, true, false)

	var kitchen := _district("KitchenApproach")
	# The corridor side walls own the caps at both portals. The adjoining
	# shoulders butt into their outer Z faces and leave a 2.50 m opening.
	_wall_x(kitchen, "KitchenEastLegNorth", GALLERY_B_EAST - half_wall, KITCHEN_ROOM_WEST + half_wall, KITCHEN_APPROACH_NORTH)
	_wall_x(kitchen, "KitchenEastLegSouth", GALLERY_B_EAST - half_wall, KITCHEN_ROOM_WEST + half_wall, KITCHEN_APPROACH_SOUTH)
	_wall_z(kitchen, "KitchenRoomWestNorth", KITCHEN_ROOM_WEST, KITCHEN_ROOM_NORTH + half_wall, KITCHEN_APPROACH_NORTH - half_wall)
	_wall_z(kitchen, "KitchenRoomWestSouth", KITCHEN_ROOM_WEST, KITCHEN_APPROACH_SOUTH + half_wall, KITCHEN_ROOM_SOUTH - half_wall)
	_wall_x_joined(kitchen, "KitchenRoomNorth", KITCHEN_ROOM_WEST, KITCHEN_ROOM_EAST, KITCHEN_ROOM_NORTH)
	_wall_x_joined(kitchen, "KitchenRoomSouth", KITCHEN_ROOM_WEST, KITCHEN_ROOM_EAST, KITCHEN_ROOM_SOUTH)

	var gallery_c := _district("GalleryC")
	_wall_z(gallery_c, "GalleryCWest", -2.0, 5.5, 15.0)
	_wall_x_joined(gallery_c, "GalleryCNorthEastReturn", 4.5, 6.0, 5.5, CLEAR_HEIGHT, false, true)
	_wall_x_joined(gallery_c, "GalleryCSouthWest", -2.0, 2.0, 15.0)
	_wall_z(gallery_c, "GalleryCDividerNorth", 6.0, 5.5, 9.0)
	_wall_z(gallery_c, "GalleryCInsetWest", 2.0, 11.5, 15.0)
	_wall_x_joined(gallery_c, "GalleryCInsetCap", 2.0, 6.0, 11.5)

	var gallery_d := _district("GalleryD")
	_wall_z(gallery_d, "GalleryDWestSouthReturn", 6.0, 11.5, 17.5)
	_wall_z_joined(gallery_d, "GalleryDEast", 15.5, 7.0, 17.5)
	_wall_x_joined(gallery_d, "GalleryDSouthWest", 6.0, 9.5, 17.5, CLEAR_HEIGHT, true, false)
	_wall_z_joined(gallery_d, "GalleryDBumpWest", 9.5, 17.5, 19.0)
	_wall_x_joined(gallery_d, "GalleryDBumpSouth", 9.5, 12.5, 19.0)
	_wall_z_joined(gallery_d, "GalleryDBumpEast", 12.5, 17.5, 19.0)
	_wall_x(gallery_d, "GalleryDSouthEast", 12.5, 15.5, 17.5)

	var workshop := _district("WorkshopService")
	# Each entry wall starts at the Sorting wall's south face.
	_wall_z(workshop, "WorkshopEntryWest", WORKSHOP_ENTRY_WEST, SORTING_SOUTH + half_wall, WORKSHOP_NORTH + half_wall)
	_wall_z(workshop, "WorkshopEntryEast", WORKSHOP_ENTRY_EAST, SORTING_SOUTH + half_wall, WORKSHOP_NORTH + half_wall)
	_wall_x_joined(workshop, "WorkshopRoomNorthWest", WORKSHOP_WEST, WORKSHOP_ENTRY_WEST - half_wall, WORKSHOP_NORTH, CLEAR_HEIGHT, true, false)
	_wall_x_joined(workshop, "WorkshopRoomNorthEast", WORKSHOP_ENTRY_EAST + half_wall, WORKSHOP_EAST, WORKSHOP_NORTH, CLEAR_HEIGHT, false, true)
	_wall_x_joined(workshop, "WorkshopRoomSouth", WORKSHOP_WEST, WORKSHOP_EAST, WORKSHOP_SOUTH)
	# These saved wall paths now flank the west exit. The staffed core closes the east side.
	_wall_z(workshop, "WorkshopRoomEastNorth", WORKSHOP_WEST, WORKSHOP_NORTH + half_wall, SALVAGER_NECK_NORTH + half_wall)
	_wall_z(workshop, "WorkshopRoomEastSouth", WORKSHOP_WEST, SALVAGER_NECK_SOUTH - half_wall, WORKSHOP_SOUTH - half_wall)

	var salvager := _district("Salvager")
	_wall_x_joined(salvager, "SalvagerCrossNorth", SALVAGER_TURN_WEST, WORKSHOP_WEST - half_wall, SALVAGER_NECK_NORTH, CLEAR_HEIGHT, true, false)
	_wall_x_joined(salvager, "SalvagerCrossSouth", SALVAGER_TURN_EAST, WORKSHOP_WEST - half_wall, SALVAGER_NECK_SOUTH, CLEAR_HEIGHT, true, false)
	# The old pocket-wall names identify the same inside and outside walls after the westward move.
	_wall_z(salvager, "SalvagerPocketWest", SALVAGER_TURN_EAST, SALVAGER_NECK_SOUTH + half_wall, SALVAGER_BACK - half_wall)
	_wall_z(salvager, "SalvagerEast", SALVAGER_TURN_WEST, SALVAGER_NECK_NORTH + half_wall, SALVAGER_BACK - half_wall)
	_wall_x_joined(salvager, "SalvagerBack", SALVAGER_TURN_WEST, SALVAGER_TURN_EAST, SALVAGER_BACK)

	var deeper := _district("DeeperApproach")
	# The existing hall and Ops jambs own the end caps at both mouths.
	_wall_x(deeper, "DeeperLinkNorth", STORAGE_EAST + half_wall, BUNKER_OPS_WEST - half_wall, DEEPER_LINK_NORTH)
	_wall_x(deeper, "DeeperLinkSouth", STORAGE_EAST + half_wall, BUNKER_OPS_WEST - half_wall, DEEPER_LINK_SOUTH)

	var incinerator := _district("Incinerator")
	# Side walls own the end caps; each perpendicular return meets their side face.
	_wall_z_joined(incinerator, "IncineratorApproachWest", INCINERATOR_APPROACH_WEST, STORAGE_EAST_SOUTH, INCINERATOR_POCKET_NORTH)
	_wall_z_joined(incinerator, "IncineratorApproachEast", INCINERATOR_APPROACH_EAST, STORAGE_EAST_SOUTH, INCINERATOR_POCKET_NORTH)
	_wall_x(incinerator, "IncineratorPocketNorthWest", INCINERATOR_POCKET_WEST + half_wall, INCINERATOR_APPROACH_WEST - half_wall, INCINERATOR_POCKET_NORTH)
	_wall_x(incinerator, "IncineratorPocketNorthEast", INCINERATOR_APPROACH_EAST + half_wall, INCINERATOR_POCKET_EAST - half_wall, INCINERATOR_POCKET_NORTH)
	_wall_z_joined(incinerator, "IncineratorPocketWest", INCINERATOR_POCKET_WEST, INCINERATOR_POCKET_NORTH, INCINERATOR_POCKET_SOUTH)
	_wall_z_joined(incinerator, "IncineratorPocketEast", INCINERATOR_POCKET_EAST, INCINERATOR_POCKET_NORTH, INCINERATOR_POCKET_SOUTH)
	_wall_x(incinerator, "IncineratorPocketBack", INCINERATOR_POCKET_WEST + half_wall, INCINERATOR_POCKET_EAST - half_wall, INCINERATOR_POCKET_SOUTH)

	var bunker_ops := _district("BunkerOps")
	_wall_z(bunker_ops, "BunkerWestNorth", BUNKER_OPS_WEST, BUNKER_OPS_NORTH, DEEPER_OPEN_NORTH)
	_wall_z(bunker_ops, "BunkerWestSouth", BUNKER_OPS_WEST, DEEPER_OPEN_SOUTH, BUNKER_OPS_SOUTH)
	_wall_x_joined(bunker_ops, "BunkerSouth", BUNKER_OPS_WEST, BUNKER_OPS_EAST, BUNKER_OPS_SOUTH)
	_wall_z_joined(bunker_ops, "BunkerEastNorth", BUNKER_OPS_EAST, BUNKER_OPS_NORTH, BUNKER_OPS_DOOR_Z - 1.20)
	_wall_z_joined(bunker_ops, "BunkerEastSouth", BUNKER_OPS_EAST, BUNKER_OPS_DOOR_Z + 1.20, BUNKER_OPS_SOUTH)
	_box(bunker_ops, "BunkerEastDoorLintel", Vector3(BUNKER_OPS_EAST, 3.15, BUNKER_OPS_DOOR_Z), Vector3(WALL_THICKNESS, 0.5, 2.4), _materials["wall"])


func _build_fixed_boundaries() -> void:
	var freight := _owned_node(_boundaries, Node3D.new(), "FreightBarrier") as Node3D
	_box(freight, "LowerRail", Vector3(-36.0, 0.35, 0.0), Vector3(0.32, 0.28, 4.8), _materials["barrier"])
	_box(freight, "UpperRail", Vector3(-36.0, 1.15, 0.0), Vector3(0.32, 0.24, 4.8), _materials["barrier"])
	for index: int in 4:
		_box(freight, "Post%02d" % index, Vector3(-36.0, 0.75, -2.25 + index * 1.5), Vector3(0.34, 1.5, 0.24), _materials["barrier"])

	# Each departmental support space has a traversable territorial entrance,
	# a separate neutral interface envelope, and this opaque staffed-core edge.
	_box(_boundaries, "MedicalInnerBoundary", Vector3(MEDICAL_ROOM_CENTER_X, CLEAR_HEIGHT * 0.5, MEDICAL_ROOM_NORTH), Vector3(MEDICAL_CORRIDOR_EAST - MEDICAL_ROOM_WEST, CLEAR_HEIGHT, WALL_THICKNESS), _materials["closure"])
	# The room perimeter owns the end caps of the east closure.
	_box(_boundaries, "KitchenInnerBoundary", Vector3(KITCHEN_ROOM_EAST, CLEAR_HEIGHT * 0.5, KITCHEN_ROOM_CENTER_Z), Vector3(WALL_THICKNESS, CLEAR_HEIGHT, KITCHEN_ROOM_SOUTH - KITCHEN_ROOM_NORTH - WALL_THICKNESS), _materials["closure"])
	_box(_boundaries, "WorkshopInnerBoundary", Vector3(WORKSHOP_EAST, CLEAR_HEIGHT * 0.5, WORKSHOP_CENTER_Z), Vector3(WALL_THICKNESS, CLEAR_HEIGHT, WORKSHOP_SOUTH - WORKSHOP_NORTH - WALL_THICKNESS), _materials["closure"])
	_box(_boundaries, "BunkerOpsInnerBoundary", Vector3(BUNKER_OPS_CENTER_X, CLEAR_HEIGHT * 0.5, BUNKER_OPS_NORTH), Vector3(BUNKER_OPS_EAST - BUNKER_OPS_WEST, CLEAR_HEIGHT, WALL_THICKNESS), _materials["closure"])
	_box(_boundaries, "DeeperSettlementDoor", Vector3(BUNKER_OPS_EAST, 1.45, BUNKER_OPS_DOOR_Z), Vector3(0.65, 2.90, 2.4), _materials["closure"])


func _build_spatial_proxies() -> void:
	_box(_proxies, "SortingTable", Vector3(-10.0, 0.45, SORTING_POCKET_NORTH + 0.52), Vector3(1.6, 0.90, 0.65), _materials["proxy"])
	_box(_proxies, "DispatchWorkSurface", Vector3(-31.75, 0.45, -6.8), Vector3(5.0, 0.90, 0.9), _materials["proxy"])

	# Wall-fitted shelf envelopes in the four galleries.
	_shelf("GalleryA_West", Vector3(-4.35, 1.35, -5.75), Vector3(0.9, 2.7, 7.0))
	_shelf("GalleryA_NorthWest", Vector3(-4.0, 1.35, -11.25), Vector3(5.0, 2.7, 0.9))
	_shelf("GalleryB_North", Vector3(12.0, 1.35, -10.05), Vector3(4.2, 2.7, 0.9))
	_shelf("GalleryB_EastSouth", Vector3(13.85, 1.35, -2.40), Vector3(0.9, 2.7, 3.0))
	_shelf("GalleryC_West", Vector3(-1.35, 1.35, 9.0), Vector3(0.9, 2.7, 6.0))
	_shelf("GalleryC_SouthWest", Vector3(0.0, 1.35, 14.35), Vector3(2.8, 2.7, 0.9))
	_shelf("GalleryD_East", Vector3(14.85, 1.35, 11.0), Vector3(0.9, 2.7, 7.5))
	_shelf("GalleryD_SouthEast", Vector3(14.0, 1.35, 16.85), Vector3(2.0, 2.7, 0.9))
	_box(_proxies, "GalleryD_LowIsland", Vector3(10.5, 0.65, 11.0), Vector3(3.0, 1.3, 1.1), _materials["proxy"])

	_box(_proxies, "MedicalInterface", Vector3(MEDICAL_ROOM_CENTER_X, 0.60, MEDICAL_ROOM_NORTH + 0.85), Vector3(3.6, 1.2, 0.6), _materials["interface"], false)
	var kitchen_interface := _box(_proxies, "KitchenInterface", Vector3(KITCHEN_ROOM_EAST - 0.85, 0.60, KITCHEN_ROOM_CENTER_Z), Vector3(6.0, 1.2, 0.6), _materials["interface"], false)
	kitchen_interface.rotation.y = -PI * 0.5
	_box(_proxies, "WorkshopInterface", Vector3(WORKSHOP_EAST - 0.85, 0.60, WORKSHOP_CENTER_Z), Vector3(0.6, 1.2, 3.2), _materials["interface"], false)
	_box(_proxies, "BunkerOpsInterface", Vector3(BUNKER_OPS_CENTER_X, 0.60, BUNKER_OPS_NORTH + 0.85), Vector3(4.0, 1.2, 0.6), _materials["interface"], false)
	_box(_proxies, "SalvagerMachine", Vector3(SALVAGER_CENTER_X, 1.45, SALVAGER_BACK - 2.0), Vector3(5.4, 2.9, 3.0), _materials["machine"])
	_box(_proxies, "IncineratorMachine", Vector3(INCINERATOR_CENTER_X, 1.45, INCINERATOR_MACHINE_Z), Vector3(6.2, 2.9, 3.5), _materials["machine"])


func _build_anchors() -> void:
	_anchor("ReceivingApron", Vector3(-31.714285714286, 0.05, 0.0), -90.0)
	_anchor("Dispatch", Vector3(-31.714285714286, 0.05, -5.75), 180.0)
	_anchor("SortingWork", Vector3(-10.0, 0.05, 0.10), 0.0)
	_anchor("StorageNear", Vector3(-2.0, 0.05, 2.7), -90.0)
	_anchor("GalleryA", Vector3(-0.4, 0.05, -4.9), 0.0)
	_anchor("GalleryB", Vector3(10.0, 0.05, -3.8), 0.0)
	_anchor("GalleryC", Vector3(2.0, 0.05, 8.0), 180.0)
	_anchor("GalleryD", Vector3(10.0, 0.05, 9.0), 180.0)
	_anchor("SharedABJunction", Vector3(4.75, 0.05, -4.9), 0.0)
	_anchor("MedicalAnteroom", Vector3(MEDICAL_ROOM_CENTER_X, 0.05, MEDICAL_ROOM_CENTER_Z), 0.0)
	_anchor("KitchenService", Vector3(KITCHEN_ROOM_EAST - 4.0, 0.05, KITCHEN_ROOM_CENTER_Z), -90.0)
	_anchor("WorkshopService", Vector3(-11.0, 0.05, WORKSHOP_CENTER_Z), -90.0)
	_anchor("BunkerOpsLanding", Vector3(BUNKER_OPS_CENTER_X, 0.05, DEEPER_OPEN_NORTH + 1.0), -90.0)
	_anchor("MedicalSafeSide", Vector3(MEDICAL_ROOM_CENTER_X, 0.05, MEDICAL_ROOM_NORTH + 2.0), 0.0)
	_anchor("KitchenSafeSide", Vector3(KITCHEN_ROOM_EAST - 3.0, 0.05, KITCHEN_ROOM_CENTER_Z), -90.0)
	_anchor("WorkshopSafeSide", Vector3(WORKSHOP_EAST - 2.5, 0.05, WORKSHOP_CENTER_Z), -90.0)
	_anchor("WorkshopApproach", Vector3(-10.0, 0.05, WORKSHOP_NORTH + 1.30), 180.0)
	_anchor("SalvagerFront", Vector3(SALVAGER_CENTER_X, 0.05, SALVAGER_BACK - 4.0), 180.0)
	_anchor("IncineratorFront", Vector3(INCINERATOR_CENTER_X, 0.05, INCINERATOR_MACHINE_Z - 2.35), 180.0)
	_anchor("BunkerOpsSafeSide", Vector3(BUNKER_OPS_CENTER_X, 0.05, BUNKER_OPS_NORTH + 2.50), 0.0)
	_anchor("DeeperClosureSafeSide", Vector3(BUNKER_OPS_EAST - 1.50, 0.05, BUNKER_OPS_DOOR_Z), -90.0)
	_anchor("CSecondaryWest", Vector3(5.0, 0.05, 10.25), -90.0)
	_anchor("DSecondaryEast", Vector3(7.0, 0.05, 10.25), 90.0)


func _translate_receiving_and_dispatch() -> void:
	# Preserve the generated pieces' existing parents and move each saved owner once.
	for part: Node3D in _district("Receiving").get_children():
		part.position += RECEIVING_SHIFT
	for part: Node3D in _boundaries.get_node("FreightBarrier").get_children():
		part.position += RECEIVING_SHIFT
	for part: Node3D in [
		_roof_visuals.get_node("Ceiling_ReceivingApron"),
		_roof_visuals.get_node("Ceiling_FreightEnclosure"),
		_roof_visuals.get_node("Ceiling_DispatchAnnex"),
		_proxies.get_node("DispatchWorkSurface"),
		_anchors.get_node("ReceivingApron"),
		_anchors.get_node("Dispatch"),
	]:
		part.position += RECEIVING_SHIFT


func _translate_storage_banks() -> void:
	_translate_storage_bank(Vector3(0.0, 0.0, -STORAGE_BANK_SHIFT),
		["GalleryC", "GalleryD"],
		["GalleryC", "GalleryD"],
		["GalleryC", "GalleryD"], [],
		["GalleryC", "GalleryD", "CSecondaryWest", "DSecondaryEast"])

func _translate_storage_bank(offset: Vector3, districts: Array[String], ceilings: Array[String], proxies: Array[String], boundaries: Array[String], anchors: Array[String]) -> void:
	for district_name: String in districts:
		for part: Node3D in _district(district_name).get_children():
			part.position += offset
	for ceiling: Node3D in _roof_visuals.get_children():
		for prefix: String in ceilings:
			if String(ceiling.name).begins_with("Ceiling_" + prefix):
				ceiling.position += offset
				break
	for proxy: Node3D in _proxies.get_children():
		for prefix: String in proxies:
			if String(proxy.name).begins_with(prefix):
				proxy.position += offset
				break
	for boundary_name: String in boundaries:
		var boundary := _boundaries.get_node(boundary_name) as Node3D
		boundary.position += offset
	for anchor_name: String in anchors:
		var anchor := _anchors.get_node(anchor_name) as Node3D
		anchor.position += offset


func _floor_zone(district_name: String, zone_name: String, x0: float, x1: float, z0: float, z1: float, height: float, floor_material_key: String) -> void:
	var district := _district(district_name)
	_box(district, "Floor_" + zone_name, Vector3((x0 + x1) * 0.5, -FLOOR_THICKNESS * 0.5, (z0 + z1) * 0.5), Vector3(x1 - x0, FLOOR_THICKNESS, z1 - z0), _materials[floor_material_key])
	_box(_roof_visuals, "Ceiling_" + zone_name, Vector3((x0 + x1) * 0.5, height + FLOOR_THICKNESS * 0.5, (z0 + z1) * 0.5), Vector3(x1 - x0, FLOOR_THICKNESS, z1 - z0), _materials["ceiling"])


func _floor_zone_with_ceiling_west(district_name: String, zone_name: String, floor_x0: float, x1: float, ceiling_x0: float, z0: float, z1: float, height: float, floor_material_key: String) -> void:
	var district := _district(district_name)
	_box(district, "Floor_" + zone_name, Vector3((floor_x0 + x1) * 0.5, -FLOOR_THICKNESS * 0.5, (z0 + z1) * 0.5), Vector3(x1 - floor_x0, FLOOR_THICKNESS, z1 - z0), _materials[floor_material_key])
	# Backlog keeps nominal support; its visible floor butts into the sill.
	var floor_mesh := district.get_node("Floor_" + zone_name + "/Mesh") as MeshInstance3D
	floor_mesh.mesh = floor_mesh.mesh.duplicate()
	(floor_mesh.mesh as BoxMesh).size.x = x1 - ceiling_x0
	floor_mesh.position.x = (ceiling_x0 - floor_x0) * 0.5
	_box(_roof_visuals, "Ceiling_" + zone_name, Vector3((ceiling_x0 + x1) * 0.5, height + FLOOR_THICKNESS * 0.5, (z0 + z1) * 0.5), Vector3(x1 - ceiling_x0, FLOOR_THICKNESS, z1 - z0), _materials["ceiling"])


func _wall_x(parent: Node3D, node_name: String, x0: float, x1: float, z: float, height: float = CLEAR_HEIGHT) -> void:
	_box(parent, node_name, Vector3((x0 + x1) * 0.5, height * 0.5, z), Vector3(x1 - x0, height, WALL_THICKNESS), _materials["wall"])


func _wall_z(parent: Node3D, node_name: String, x: float, z0: float, z1: float, height: float = CLEAR_HEIGHT) -> void:
	_box(parent, node_name, Vector3(x, height * 0.5, (z0 + z1) * 0.5), Vector3(WALL_THICKNESS, height, z1 - z0), _materials["wall"])


func _wall_x_joined(parent: Node3D, node_name: String, x0: float, x1: float, z: float, height: float = CLEAR_HEIGHT, join_start: bool = true, join_end: bool = true) -> void:
	var joined_x0 := x0 - (WALL_THICKNESS * 0.5 if join_start else 0.0)
	var joined_x1 := x1 + (WALL_THICKNESS * 0.5 if join_end else 0.0)
	_wall_x(parent, node_name, joined_x0, joined_x1, z, height)


func _wall_z_joined(parent: Node3D, node_name: String, x: float, z0: float, z1: float, height: float = CLEAR_HEIGHT, join_start: bool = true, join_end: bool = true) -> void:
	var joined_z0 := z0 - (WALL_THICKNESS * 0.5 if join_start else 0.0)
	var joined_z1 := z1 + (WALL_THICKNESS * 0.5 if join_end else 0.0)
	_wall_z(parent, node_name, x, joined_z0, joined_z1, height)


func _shelf(node_name: String, center: Vector3, size: Vector3) -> void:
	_box(_proxies, node_name, center, size, _materials["proxy"])


func _anchor(node_name: String, position: Vector3, facing_degrees: float) -> void:
	var marker := Marker3D.new()
	marker.position = position
	marker.rotation_degrees.y = facing_degrees
	_owned_node(_anchors, marker, node_name)


func _box(parent: Node3D, node_name: String, center: Vector3, size: Vector3, material: Material, collision: bool = true) -> Node3D:
	var container := Node3D.new()
	container.position = center
	_owned_node(parent, container, node_name)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	_owned_node(container, mesh_instance, "Mesh")
	if collision:
		var body := StaticBody3D.new()
		_owned_node(container, body, "StaticBody3D")
		var collision_shape := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision_shape.shape = shape
		_owned_node(body, collision_shape, "CollisionShape3D")
	return container


func _material(resource_name_value: String, color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = resource_name_value
	material.albedo_color = color
	material.roughness = 1.0
	material.metallic = 0.0
	return material


func _district(node_name: String) -> Node3D:
	return _districts.get_node(node_name) as Node3D


func _owned_node(parent: Node, child: Node, node_name: String) -> Node:
	child.name = node_name
	parent.add_child(child)
	child.owner = _root
	return child


func _count_nodes(node: Node) -> int:
	var count := 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count
