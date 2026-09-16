@tool
extends SceneTree

const OUTPUT_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const FLOOR_THICKNESS := 0.30
const WALL_THICKNESS := 0.30
const CLEAR_HEIGHT := 3.40
const RECEIVING_HEIGHT := 4.20

const TOPOLOGY_EDGES := [
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
	print("WING_GEOMETRY_GENERATED path=%s extents=110x55m nodes=%d" % [OUTPUT_PATH, _count_nodes(_root)])
	_root.free()
	_root = null
	_materials.clear()
	packed = null
	await process_frame
	quit(0)


func _create_roots() -> void:
	_root = Node3D.new()
	_root.name = "WingGeometry"
	_root.set_meta("layout_revision", "logistics-wing-greybox-round02-revision-02")
	_root.set_meta("regeneration_command", "godot --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd")
	_root.set_meta("overall_extents_m", Vector3(110.0, 4.2, 55.0))
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
		"GalleryB", "GalleryC", "GalleryD", "GalleryE", "MedicalApproach",
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
	_materials["backlog"] = _material("Greybox Backlog", Color("6c6259"))
	_materials["interface"] = _material("Greybox Interface Envelope", Color("557078"))


func _build_floor_and_ceiling_plan() -> void:
	# Western logistics core.
	_floor_zone("Receiving", "ReceivingApron", -39.0, -28.5, -5.0, 5.0, RECEIVING_HEIGHT, "floor_core")
	_floor_zone("Receiving", "FreightEnclosure", -44.0, -39.0, -3.5, 3.5, RECEIVING_HEIGHT, "floor_core")
	_floor_zone("Receiving", "DispatchAnnex", -38.0, -28.5, -8.5, -5.0, RECEIVING_HEIGHT, "floor_core")
	_floor_zone("Backlog", "BacklogPassage", -28.5, -21.0, -3.8, 3.8, CLEAR_HEIGHT, "floor_core")
	_floor_zone("Sorting", "SortingPassage", -21.0, -5.0, -5.0, 5.0, CLEAR_HEIGHT, "floor_core")
	_floor_zone("Sorting", "SortingPocket", -14.0, -6.0, -7.2, -5.0, CLEAR_HEIGHT, "floor_core")

	# Bent, variable-width primary Storage spine and five galleries.
	_floor_zone("StorageSpine", "StorageSpineWest", -5.0, 4.5, -1.5, 5.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("StorageSpine", "StorageSpineEast", 4.5, 26.0, -1.5, 7.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("SharedABJunction", "SharedABJunction", 4.5, 9.0, -13.0, -1.5, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("GalleryA", "GalleryAMain", -3.0, 4.5, -13.0, -1.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryA", "GalleryANorthWest", -5.0, 1.0, -16.0, -13.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryB", "GalleryBMain", 9.0, 16.5, -13.0, -1.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryB", "GalleryBNorthBump", 12.0, 16.5, -14.5, -13.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryC", "GalleryCMain", -2.0, 6.0, 5.5, 11.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryC", "GalleryCSouthWest", -2.0, 2.0, 11.5, 15.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryD", "GalleryDMain", 6.0, 15.5, 7.0, 17.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryD", "GalleryDSouthBump", 9.5, 12.5, 17.5, 19.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryE", "GalleryEMain", 17.5, 25.5, 7.0, 15.4, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryE", "GalleryESouthProjection", 19.0, 25.5, 15.4, 21.0, CLEAR_HEIGHT, "floor_storage")

	# Protected approaches and distinct playable departmental support rooms.
	_floor_zone("MedicalApproach", "MedicalCorridor", 5.8, 8.2, -16.0, -13.0, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("MedicalApproach", "MedicalAnteroom", 3.0, 10.8, -23.0, -16.0, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("KitchenApproach", "KitchenEastLeg", 16.5, 24.0, -8.2, -5.4, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("KitchenApproach", "KitchenNorthLeg", 21.2, 24.0, -18.0, -8.2, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("KitchenApproach", "KitchenServiceRoom", 19.0, 29.5, -25.0, -18.0, CLEAR_HEIGHT, "floor_shared")

	# Workshop room and retained bent Salvager spur. The abandoned continuation
	# is removed rather than blocked or reserved.
	_floor_zone("WorkshopService", "WorkshopEntry", -12.0, -8.0, 5.0, 15.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("WorkshopService", "WorkshopServiceRoom", -18.0, -6.0, 15.0, 25.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("Salvager", "SalvagerCrossLeg", -6.0, 8.0, 20.0, 24.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("Salvager", "SalvagerPocket", 2.0, 8.0, 23.5, 29.5, CLEAR_HEIGHT, "floor_service")

	# Wide-to-narrow dog-leg, Incinerator spur, and Bunker Ops terminus.
	_floor_zone("DeeperApproach", "DeeperWide", 26.0, 42.0, 0.0, 4.5, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("DeeperApproach", "DeeperDogLeg", 39.0, 43.0, -7.0, 4.5, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("DeeperApproach", "DeeperNarrow", 43.0, 59.0, -7.0, -4.0, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("Incinerator", "IncineratorApproach", 29.5, 33.5, 4.5, 10.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("Incinerator", "IncineratorPocket", 28.0, 35.0, 10.0, 17.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("BunkerOps", "BunkerOpsLanding", 59.0, 66.0, -11.0, -2.0, CLEAR_HEIGHT, "floor_shared")


func _build_structural_walls() -> void:
	var receiving := _district("Receiving")
	_wall_z(receiving, "ReceivingWestNorthReturn", -39.0, -5.0, -2.5, RECEIVING_HEIGHT)
	_wall_z(receiving, "ReceivingWestSouthReturn", -39.0, 2.5, 5.0, RECEIVING_HEIGHT)
	_wall_x_joined(receiving, "ReceivingSouth", -39.0, -28.5, 5.0, RECEIVING_HEIGHT)
	_wall_x(receiving, "ReceivingNorthWest", -39.0, -38.0, -5.0, RECEIVING_HEIGHT)
	_wall_z(receiving, "ReceivingEastNorth", -28.5, -5.0, -1.92, RECEIVING_HEIGHT)
	_wall_z(receiving, "ReceivingEastSouth", -28.5, 1.92, 5.0, RECEIVING_HEIGHT)
	_wall_x(receiving, "FreightNorth", -44.0, -39.0, -3.5, RECEIVING_HEIGHT)
	_wall_x(receiving, "FreightSouth", -44.0, -39.0, 3.5, RECEIVING_HEIGHT)
	_wall_z(receiving, "FreightRear", -44.0, -3.5, 3.5, RECEIVING_HEIGHT)
	_wall_z_joined(receiving, "DispatchWest", -38.0, -8.5, -5.0, RECEIVING_HEIGHT)
	_wall_x_joined(receiving, "DispatchNorth", -38.0, -28.5, -8.5, RECEIVING_HEIGHT)
	_wall_z_joined(receiving, "DispatchEast", -28.5, -8.5, -5.0, RECEIVING_HEIGHT, true, false)
	_wall_x(receiving, "DispatchSouthWest", -38.0, -34.2, -5.0, RECEIVING_HEIGHT)
	_wall_x(receiving, "DispatchSouthEast", -31.8, -28.5, -5.0, RECEIVING_HEIGHT)
	_box(receiving, "ReceivingCeilingTransition", Vector3(-28.65, 3.8, 0.0), Vector3(WALL_THICKNESS, 0.8, 3.84), _materials["wall"])

	var backlog := _district("Backlog")
	_wall_x(backlog, "BacklogNorth", -28.5, -21.0, -3.8)
	_wall_x(backlog, "BacklogSouth", -28.5, -21.0, 3.8)
	_wall_z(backlog, "BacklogEastNorth", -21.0, -3.8, -2.4)
	_wall_z(backlog, "BacklogEastSouth", -21.0, 1.44, 3.8)

	var sorting := _district("Sorting")
	_wall_x(sorting, "SortingNorthWestShoulder", -21.0, -14.0, -5.0)
	_wall_z(sorting, "SortingPocketWest", -14.0, -7.2, -5.0)
	_wall_x_joined(sorting, "SortingPocketNorth", -14.0, -6.0, -7.2)
	_wall_z(sorting, "SortingPocketEast", -6.0, -7.2, -5.0)
	_wall_x(sorting, "SortingNorthEastShoulder", -6.0, -5.0, -5.0)
	_wall_x(sorting, "SortingSouthWest", -21.0, -12.0, 5.0)
	_wall_x(sorting, "SortingSouthEast", -8.0, -5.0, 5.0)
	_wall_z(sorting, "SortingWestNorthShoulder", -21.0, -5.0, -3.8)
	_wall_z(sorting, "SortingWestSouthShoulder", -21.0, 3.8, 5.0)
	_wall_z(sorting, "SortingEastNorth", -5.0, -5.0, 1.0)
	_wall_z(sorting, "SortingEastSouth", -5.0, 4.2, 5.0)

	var spine := _district("StorageSpine")
	_wall_x(spine, "SpineWestNorthA", -5.0, 0.0, -1.5)
	_wall_x(spine, "SpineWestNorthB", 3.0, 4.5, -1.5)
	_wall_x(spine, "SpineWestSouthA", -5.0, 0.0, 5.5)
	_wall_x(spine, "SpineWestSouthB", 3.0, 4.5, 5.5)
	_wall_z(spine, "SpineWestSouthClosure", -5.0, 5.0, 5.5)
	_wall_z(spine, "SpineWestEastClosure", 4.5, 5.5, 7.0)
	_wall_x(spine, "SpineEastNorthBWest", 9.0, 11.0, -1.5)
	_wall_x(spine, "SpineEastNorthBEast", 14.0, 26.0, -1.5)
	_wall_x(spine, "SpineEastSouthWest", 4.5, 9.0, 7.0)
	_wall_x(spine, "SpineEastSouthMid", 12.0, 20.0, 7.0)
	_wall_x(spine, "SpineEastSouthEast", 23.0, 26.0, 7.0)
	_wall_z(spine, "SpineEastNorthReturn", 26.0, -1.5, 0.8)
	_wall_z(spine, "SpineEastSouthReturn", 26.0, 3.8, 4.5)

	var gallery_a := _district("GalleryA")
	_wall_z(gallery_a, "GalleryAWest", -3.0, -13.0, -1.5)
	_wall_x(gallery_a, "GalleryANorthWestShoulder", -5.0, -3.0, -13.0)
	_wall_z_joined(gallery_a, "GalleryANorthWestSide", -5.0, -16.0, -13.0)
	_wall_x_joined(gallery_a, "GalleryANorthWest", -5.0, 1.0, -16.0)
	_wall_z_joined(gallery_a, "GalleryANorthWestEast", 1.0, -16.0, -13.0)
	_wall_x(gallery_a, "GalleryANorthEastShoulder", 1.0, 4.5, -13.0)
	_wall_z(gallery_a, "GalleryAEastNorth", 4.5, -13.0, -9.4)
	_wall_z(gallery_a, "GalleryAEastSouth", 4.5, -7.0, -1.5)

	var gallery_b := _district("GalleryB")
	_wall_z(gallery_b, "GalleryBWestNorth", 9.0, -13.0, -9.4)
	_wall_z(gallery_b, "GalleryBWestSouth", 9.0, -7.0, -1.5)
	_wall_x(gallery_b, "GalleryBNorthShoulder", 9.0, 12.0, -13.0)
	_wall_z_joined(gallery_b, "GalleryBNorthBumpWest", 12.0, -14.5, -13.0)
	_wall_x_joined(gallery_b, "GalleryBNorth", 12.0, 16.5, -14.5)
	_wall_z(gallery_b, "GalleryBEastNorth", 16.5, -14.5, -8.2)
	_wall_z(gallery_b, "GalleryBEastSouth", 16.5, -5.4, -1.5)

	var junction := _district("SharedABJunction")
	_wall_x(junction, "SharedJunctionNorthWest", 4.5, 5.8, -13.0)
	_wall_x(junction, "SharedJunctionNorthEast", 8.2, 9.0, -13.0)

	var medical := _district("MedicalApproach")
	_wall_z(medical, "MedicalCorridorWest", 5.8, -16.0, -13.0)
	_wall_z(medical, "MedicalCorridorEast", 8.2, -16.0, -13.0)
	_wall_x(medical, "MedicalRoomSouthWest", 3.0, 5.8, -16.0)
	_wall_x(medical, "MedicalRoomSouthEast", 8.2, 10.8, -16.0)
	_wall_z_joined(medical, "MedicalRoomWest", 3.0, -23.0, -16.0)
	_wall_z_joined(medical, "MedicalRoomEast", 10.8, -23.0, -16.0)

	var kitchen := _district("KitchenApproach")
	_wall_x(kitchen, "KitchenEastLegNorth", 16.5, 21.2, -8.2)
	_wall_x(kitchen, "KitchenEastLegSouth", 16.5, 24.0, -5.4)
	_wall_z_joined(kitchen, "KitchenNorthLegWest", 21.2, -18.0, -8.2)
	_wall_z_joined(kitchen, "KitchenNorthLegEast", 24.0, -18.0, -5.4)
	_wall_x(kitchen, "KitchenRoomSouthWest", 19.0, 21.2, -18.0)
	_wall_x(kitchen, "KitchenRoomSouthEast", 24.0, 29.5, -18.0)
	_wall_z_joined(kitchen, "KitchenRoomWest", 19.0, -25.0, -18.0)
	_wall_z_joined(kitchen, "KitchenRoomEast", 29.5, -25.0, -18.0)

	var gallery_c := _district("GalleryC")
	_wall_z(gallery_c, "GalleryCWest", -2.0, 5.5, 15.0)
	_wall_x(gallery_c, "GalleryCNorthEastReturn", 4.5, 6.0, 5.5)
	_wall_x(gallery_c, "GalleryCSouthWest", -2.0, 2.0, 15.0)
	_wall_z(gallery_c, "GalleryCDividerNorth", 6.0, 5.5, 9.0)
	_box(gallery_c, "GalleryCIrregularSouthMass", Vector3(4.0, 1.7, 13.25), Vector3(4.0, 3.4, 3.5), _materials["wall"])

	var gallery_d := _district("GalleryD")
	_wall_z_joined(gallery_d, "GalleryDEast", 15.5, 7.0, 17.5)
	_wall_x(gallery_d, "GalleryDSouthWest", 6.0, 9.5, 17.5)
	_wall_z_joined(gallery_d, "GalleryDBumpWest", 9.5, 17.5, 19.0)
	_wall_x_joined(gallery_d, "GalleryDBumpSouth", 9.5, 12.5, 19.0)
	_wall_z_joined(gallery_d, "GalleryDBumpEast", 12.5, 17.5, 19.0)
	_wall_x(gallery_d, "GalleryDSouthEast", 12.5, 15.5, 17.5)

	var gallery_e := _district("GalleryE")
	_wall_z_joined(gallery_e, "GalleryEWest", 17.5, 7.0, 15.4)
	_wall_x(gallery_e, "GalleryESouthShoulder", 17.5, 19.0, 15.4)
	_wall_z_joined(gallery_e, "GalleryESouthProjectionWest", 19.0, 15.4, 21.0)
	_wall_x_joined(gallery_e, "GalleryESouth", 19.0, 25.5, 21.0)
	_wall_z_joined(gallery_e, "GalleryEEast", 25.5, 7.0, 21.0)

	var workshop := _district("WorkshopService")
	_wall_z(workshop, "WorkshopEntryWest", -12.0, 5.0, 15.0)
	_wall_z(workshop, "WorkshopEntryEast", -8.0, 5.0, 15.0)
	_wall_x_joined(workshop, "WorkshopRoomNorthWest", -18.0, -12.0, 15.0)
	_wall_x(workshop, "WorkshopRoomNorthEast", -8.0, -6.0, 15.0)
	_wall_x_joined(workshop, "WorkshopRoomSouth", -18.0, -6.0, 25.0)
	_wall_z(workshop, "WorkshopRoomEastNorth", -6.0, 15.0, 20.0)
	_wall_z(workshop, "WorkshopRoomEastSouth", -6.0, 24.0, 25.0)

	var salvager := _district("Salvager")
	_wall_x(salvager, "SalvagerCrossNorth", -6.0, 8.0, 20.0)
	_wall_x(salvager, "SalvagerCrossSouth", -6.0, 2.0, 24.0)
	_wall_z_joined(salvager, "SalvagerPocketWest", 2.0, 23.5, 29.5)
	_wall_z_joined(salvager, "SalvagerEast", 8.0, 20.0, 29.5)
	_wall_x_joined(salvager, "SalvagerBack", 2.0, 8.0, 29.5)

	var deeper := _district("DeeperApproach")
	_wall_x(deeper, "DeeperWideNorth", 26.0, 39.0, 0.0)
	_wall_x(deeper, "DeeperWideSouthWest", 26.0, 29.5, 4.5)
	_wall_x(deeper, "DeeperWideSouthEast", 33.5, 43.0, 4.5)
	_wall_z_joined(deeper, "DogLegWest", 39.0, -7.0, 0.0)
	_wall_z_joined(deeper, "DogLegEastReturn", 43.0, -4.0, 4.5)
	_wall_x_joined(deeper, "DogLegNorth", 39.0, 43.0, -7.0, CLEAR_HEIGHT, true, false)
	_wall_x(deeper, "DeeperNarrowNorth", 43.0, 59.0, -7.0)
	_wall_x(deeper, "DeeperNarrowSouth", 43.0, 59.0, -4.0)

	var incinerator := _district("Incinerator")
	_wall_z(incinerator, "IncineratorApproachWest", 29.5, 4.5, 10.0)
	_wall_z(incinerator, "IncineratorApproachEast", 33.5, 4.5, 10.0)
	_wall_x(incinerator, "IncineratorPocketNorthWest", 28.0, 29.5, 10.0)
	_wall_x(incinerator, "IncineratorPocketNorthEast", 33.5, 35.0, 10.0)
	_wall_z(incinerator, "IncineratorPocketWest", 28.0, 10.0, 17.0)
	_wall_z(incinerator, "IncineratorPocketEast", 35.0, 10.0, 17.0)
	_wall_x(incinerator, "IncineratorPocketBack", 28.0, 35.0, 17.0)

	var bunker_ops := _district("BunkerOps")
	_wall_z(bunker_ops, "BunkerWestNorth", 59.0, -11.0, -7.0)
	_wall_z(bunker_ops, "BunkerWestSouth", 59.0, -4.0, -2.0)
	_wall_x_joined(bunker_ops, "BunkerSouth", 59.0, 66.0, -2.0)
	_wall_z_joined(bunker_ops, "BunkerEastNorth", 66.0, -11.0, -8.0)
	_wall_z_joined(bunker_ops, "BunkerEastSouth", 66.0, -5.6, -2.0)
	_box(bunker_ops, "BunkerEastDoorLintel", Vector3(66.0, 3.15, -6.8), Vector3(WALL_THICKNESS, 0.5, 2.4), _materials["wall"])


func _build_fixed_boundaries() -> void:
	var freight := _owned_node(_boundaries, Node3D.new(), "FreightBarrier") as Node3D
	_box(freight, "LowerRail", Vector3(-39.0, 0.35, 0.0), Vector3(0.32, 0.28, 4.8), _materials["barrier"])
	_box(freight, "UpperRail", Vector3(-39.0, 1.15, 0.0), Vector3(0.32, 0.24, 4.8), _materials["barrier"])
	for index: int in 4:
		_box(freight, "Post%02d" % index, Vector3(-39.0, 0.75, -2.25 + index * 1.5), Vector3(0.34, 1.5, 0.24), _materials["barrier"])

	# Each departmental support space has a traversable territorial entrance,
	# a separate neutral interface envelope, and this opaque staffed-core edge.
	_box(_boundaries, "MedicalInnerBoundary", Vector3(6.9, 1.7, -23.0), Vector3(7.8, 3.4, 0.30), _materials["closure"])
	_box(_boundaries, "KitchenInnerBoundary", Vector3(24.25, 1.7, -25.0), Vector3(10.5, 3.4, 0.30), _materials["closure"])
	_box(_boundaries, "WorkshopInnerBoundary", Vector3(-18.0, 1.7, 20.0), Vector3(0.30, 3.4, 10.0), _materials["closure"])
	_box(_boundaries, "BunkerOpsInnerBoundary", Vector3(62.5, 1.7, -11.0), Vector3(7.0, 3.4, 0.30), _materials["closure"])
	_box(_boundaries, "DeeperSettlementDoor", Vector3(66.0, 1.45, -6.8), Vector3(0.65, 2.90, 2.4), _materials["closure"])


func _build_spatial_proxies() -> void:
	_box(_proxies, "SortingTable", Vector3(-10.0, 0.45, -6.18), Vector3(4.8, 0.90, 1.74), _materials["proxy"])
	_box(_proxies, "DispatchWorkSurface", Vector3(-33.25, 0.45, -7.8), Vector3(5.0, 0.90, 0.9), _materials["proxy"])
	_box(_proxies, "BacklogNorthBlock", Vector3(-25.8, 0.85, -2.9), Vector3(2.0, 1.7, 1.3), _materials["backlog"])
	_box(_proxies, "BacklogSouthBlock", Vector3(-23.0, 0.65, 3.0), Vector3(1.6, 1.3, 1.1), _materials["backlog"])

	# Wall-fitted shelf envelopes in all five galleries.
	_shelf("GalleryA_West", Vector3(-2.35, 1.35, -7.2), Vector3(0.9, 2.7, 7.0))
	_shelf("GalleryA_NorthWest", Vector3(-2.0, 1.35, -15.35), Vector3(5.0, 2.7, 0.9))
	_shelf("GalleryB_North", Vector3(14.0, 1.35, -13.85), Vector3(4.2, 2.7, 0.9))
	_shelf("GalleryB_EastSouth", Vector3(15.85, 1.35, -3.6), Vector3(0.9, 2.7, 3.0))
	_shelf("GalleryC_West", Vector3(-1.35, 1.35, 9.0), Vector3(0.9, 2.7, 6.0))
	_shelf("GalleryC_SouthWest", Vector3(0.0, 1.35, 14.35), Vector3(2.8, 2.7, 0.9))
	_shelf("GalleryD_East", Vector3(14.85, 1.35, 11.0), Vector3(0.9, 2.7, 7.5))
	_shelf("GalleryD_SouthEast", Vector3(14.0, 1.35, 16.85), Vector3(2.0, 2.7, 0.9))
	_shelf("GalleryE_East", Vector3(24.85, 1.35, 11.2), Vector3(0.9, 2.7, 7.2))
	_shelf("GalleryE_South", Vector3(22.0, 1.35, 20.35), Vector3(4.5, 2.7, 0.9))
	_box(_proxies, "GalleryD_LowIsland", Vector3(10.5, 0.65, 11.0), Vector3(3.0, 1.3, 1.1), _materials["proxy"])
	_box(_proxies, "GalleryE_LowIsland", Vector3(21.0, 0.55, 11.0), Vector3(2.5, 1.1, 1.0), _materials["proxy"])

	_box(_proxies, "MedicalInterface", Vector3(6.9, 0.60, -22.15), Vector3(3.6, 1.2, 0.6), _materials["interface"], false)
	_box(_proxies, "KitchenInterface", Vector3(24.25, 0.60, -24.15), Vector3(6.0, 1.2, 0.6), _materials["interface"], false)
	_box(_proxies, "WorkshopInterface", Vector3(-17.15, 0.60, 20.0), Vector3(0.6, 1.2, 3.2), _materials["interface"], false)
	_box(_proxies, "BunkerOpsInterface", Vector3(62.5, 0.60, -10.15), Vector3(4.0, 1.2, 0.6), _materials["interface"], false)
	_box(_proxies, "SalvagerMachine", Vector3(5.0, 1.45, 26.5), Vector3(5.4, 2.9, 3.0), _materials["machine"])
	_box(_proxies, "IncineratorMachine", Vector3(31.5, 1.45, 14.75), Vector3(6.2, 2.9, 3.5), _materials["machine"])


func _build_anchors() -> void:
	_anchor("ReceivingApron", Vector3(-33.0, 0.05, 0.0), -90.0)
	_anchor("Dispatch", Vector3(-33.0, 0.05, -6.75), 180.0)
	_anchor("SortingWork", Vector3(-10.0, 0.05, -4.4), 0.0)
	_anchor("StorageNear", Vector3(-2.0, 0.05, 2.7), -90.0)
	_anchor("GalleryA", Vector3(0.0, 0.05, -7.0), 0.0)
	_anchor("GalleryB", Vector3(12.0, 0.05, -5.0), 0.0)
	_anchor("GalleryC", Vector3(2.0, 0.05, 8.0), 180.0)
	_anchor("GalleryD", Vector3(10.0, 0.05, 9.0), 180.0)
	_anchor("GalleryE", Vector3(21.0, 0.05, 10.0), 180.0)
	_anchor("SharedABJunction", Vector3(6.75, 0.05, -8.2), 0.0)
	_anchor("MedicalAnteroom", Vector3(6.9, 0.05, -19.5), 0.0)
	_anchor("KitchenService", Vector3(24.25, 0.05, -21.0), 0.0)
	_anchor("WorkshopService", Vector3(-11.0, 0.05, 19.0), -90.0)
	_anchor("BunkerOpsLanding", Vector3(62.5, 0.05, -6.0), -90.0)
	_anchor("MedicalSafeSide", Vector3(6.9, 0.05, -21.0), 0.0)
	_anchor("KitchenSafeSide", Vector3(24.25, 0.05, -22.0), 0.0)
	_anchor("WorkshopSafeSide", Vector3(-15.5, 0.05, 20.0), -90.0)
	_anchor("WorkshopApproach", Vector3(-10.0, 0.05, 18.5), -45.0)
	_anchor("SalvagerFront", Vector3(5.0, 0.05, 24.5), 180.0)
	_anchor("IncineratorFront", Vector3(31.5, 0.05, 12.4), 180.0)
	_anchor("BunkerOpsSafeSide", Vector3(62.5, 0.05, -8.5), 0.0)
	_anchor("DeeperClosureSafeSide", Vector3(64.5, 0.05, -6.8), -90.0)
	_anchor("CSecondaryWest", Vector3(5.0, 0.05, 10.25), -90.0)
	_anchor("DSecondaryEast", Vector3(7.0, 0.05, 10.25), 90.0)


func _floor_zone(district_name: String, zone_name: String, x0: float, x1: float, z0: float, z1: float, height: float, floor_material_key: String) -> void:
	var district := _district(district_name)
	_box(district, "Floor_" + zone_name, Vector3((x0 + x1) * 0.5, -FLOOR_THICKNESS * 0.5, (z0 + z1) * 0.5), Vector3(x1 - x0, FLOOR_THICKNESS, z1 - z0), _materials[floor_material_key])
	_box(_roof_visuals, "Ceiling_" + zone_name, Vector3((x0 + x1) * 0.5, height + FLOOR_THICKNESS * 0.5, (z0 + z1) * 0.5), Vector3(x1 - x0, FLOOR_THICKNESS, z1 - z0), _materials["ceiling"])


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
