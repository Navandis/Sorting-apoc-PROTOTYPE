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
	print("WING_GEOMETRY_GENERATED path=%s extents=104x53m nodes=%d" % [OUTPUT_PATH, _count_nodes(_root)])
	_root.free()
	_root = null
	_materials.clear()
	packed = null
	await process_frame
	quit(0)


func _create_roots() -> void:
	_root = Node3D.new()
	_root.name = "WingGeometry"
	_root.set_meta("layout_revision", "logistics-wing-greybox-v1")
	_root.set_meta("regeneration_command", "godot --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd")
	_root.set_meta("overall_extents_m", Vector3(104.0, 4.2, 53.0))
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
		"Incinerator", "BunkerOps",
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


func _build_floor_and_ceiling_plan() -> void:
	# Western logistics core.
	_floor_zone("Receiving", "ReceivingAndFreight", -42.0, -27.0, -5.0, 5.0, RECEIVING_HEIGHT, "floor_core")
	_floor_zone("Receiving", "DispatchAlcove", -34.0, -28.0, -9.0, -5.0, RECEIVING_HEIGHT, "floor_core")
	_floor_zone("Backlog", "BacklogPassage", -27.0, -15.0, -3.8, 3.8, CLEAR_HEIGHT, "floor_core")
	_floor_zone("Sorting", "SortingPassage", -15.0, -5.0, -5.0, 5.0, CLEAR_HEIGHT, "floor_core")

	# Bent, variable-width primary Storage spine and five galleries.
	_floor_zone("StorageSpine", "StorageSpineWest", -5.0, 4.0, 0.0, 5.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("StorageSpine", "StorageSpineEast", 4.0, 25.0, -1.5, 2.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryA", "GalleryA", -3.0, 4.0, -13.0, 0.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryB", "GalleryB", 8.0, 16.0, -11.0, -1.5, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryC", "GalleryC", -2.0, 6.0, 5.0, 14.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryD", "GalleryD", 6.0, 15.0, 2.5, 14.0, CLEAR_HEIGHT, "floor_storage")
	_floor_zone("GalleryE", "GalleryE", 17.0, 25.0, 2.5, 15.0, CLEAR_HEIGHT, "floor_storage")

	# Protected and inhabited shared-circulation approaches.
	_floor_zone("MedicalApproach", "MedicalApproach", 4.0, 8.0, -20.0, -1.5, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("KitchenApproach", "KitchenSouthLeg", 16.0, 20.0, -11.0, -1.5, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("KitchenApproach", "KitchenCrossLeg", 16.0, 26.0, -14.0, -11.0, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("KitchenApproach", "KitchenNorthLeg", 23.0, 26.0, -20.0, -14.0, CLEAR_HEIGHT, "floor_shared")

	# Workshop/service branch, Salvager, and blocked continuation lip.
	_floor_zone("WorkshopService", "WorkshopEntry", -12.0, -8.0, 5.0, 18.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("WorkshopService", "WorkshopServiceLeg", -12.0, 8.0, 18.0, 22.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("WorkshopService", "BlockedContinuationLip", -10.0, -7.0, 22.0, 27.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("Salvager", "SalvagerSpur", 3.0, 8.0, 22.0, 29.0, CLEAR_HEIGHT, "floor_service")

	# Wide-to-narrow dog-leg, Incinerator spur, and Bunker Ops terminus.
	_floor_zone("DeeperApproach", "DeeperWide", 25.0, 42.0, -1.5, 3.0, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("DeeperApproach", "DeeperDogLeg", 39.0, 43.0, -10.0, -1.5, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("DeeperApproach", "DeeperNarrow", 43.0, 58.0, -10.0, -7.0, CLEAR_HEIGHT, "floor_shared")
	_floor_zone("Incinerator", "IncineratorApproach", 35.0, 39.0, 3.0, 10.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("Incinerator", "IncineratorPocket", 32.0, 42.0, 10.0, 17.0, CLEAR_HEIGHT, "floor_service")
	_floor_zone("BunkerOps", "BunkerOpsTerminal", 58.0, 62.0, -12.0, -5.0, CLEAR_HEIGHT, "floor_shared")


func _build_structural_walls() -> void:
	var receiving := _district("Receiving")
	_wall_z(receiving, "ReceivingWest", -42.0, -5.0, 5.0, RECEIVING_HEIGHT)
	_wall_x(receiving, "ReceivingSouth", -42.0, -27.0, 5.0, RECEIVING_HEIGHT)
	_wall_x(receiving, "ReceivingNorthWest", -42.0, -34.0, -5.0, RECEIVING_HEIGHT)
	_wall_x(receiving, "ReceivingNorthEast", -28.0, -27.0, -5.0, RECEIVING_HEIGHT)
	_wall_z(receiving, "ReceivingEastNorth", -27.0, -5.0, -3.2, RECEIVING_HEIGHT)
	_wall_z(receiving, "ReceivingEastSouth", -27.0, 3.2, 5.0, RECEIVING_HEIGHT)
	_wall_z(receiving, "DispatchWest", -34.0, -9.0, -5.0, RECEIVING_HEIGHT)
	_wall_x(receiving, "DispatchNorth", -34.0, -28.0, -9.0, RECEIVING_HEIGHT)
	_wall_z(receiving, "DispatchEast", -28.0, -9.0, -5.0, RECEIVING_HEIGHT)

	var backlog := _district("Backlog")
	_wall_x(backlog, "BacklogNorth", -27.0, -15.0, -3.8)
	_wall_x(backlog, "BacklogSouth", -27.0, -15.0, 3.8)
	_wall_z(backlog, "BacklogWestNorth", -27.0, -3.8, -3.2)
	_wall_z(backlog, "BacklogWestSouth", -27.0, 3.2, 3.8)
	_wall_z(backlog, "BacklogEastNorth", -15.0, -3.8, -3.2)
	_wall_z(backlog, "BacklogEastSouth", -15.0, 3.2, 3.8)

	var sorting := _district("Sorting")
	_wall_x(sorting, "SortingNorth", -15.0, -5.0, -5.0)
	_wall_x(sorting, "SortingSouthWest", -15.0, -12.0, 5.0)
	_wall_x(sorting, "SortingSouthEast", -8.0, -5.0, 5.0)
	_wall_z(sorting, "SortingWestNorth", -15.0, -5.0, -3.2)
	_wall_z(sorting, "SortingWestSouth", -15.0, 3.2, 5.0)
	_wall_z(sorting, "SortingEastNorth", -5.0, -5.0, 0.0)
	_wall_z(sorting, "SortingEastSouth", -5.0, 4.0, 5.0)

	var spine := _district("StorageSpine")
	_wall_x(spine, "SpineWestNorthA", -5.0, 0.0, 0.0)
	_wall_x(spine, "SpineWestNorthB", 3.0, 4.0, 0.0)
	_wall_x(spine, "SpineWestSouthA", -5.0, 0.0, 5.0)
	_wall_x(spine, "SpineWestSouthB", 3.0, 4.0, 5.0)
	_wall_z(spine, "SpineWestEastClosure", 4.0, 2.5, 5.0)
	_wall_z(spine, "SpineWestWestClosure", -5.0, 4.0, 5.0)
	_wall_z(spine, "SpineEastWestNorth", 4.0, -1.5, 0.0)
	_wall_x(spine, "SpineEastNorthA", 4.0, 5.0, -1.5)
	_wall_x(spine, "SpineEastNorthB", 7.0, 10.0, -1.5)
	_wall_x(spine, "SpineEastNorthC", 13.0, 17.0, -1.5)
	_wall_x(spine, "SpineEastNorthD", 19.0, 25.0, -1.5)
	_wall_x(spine, "SpineEastSouthA", 4.0, 9.0, 2.5)
	_wall_x(spine, "SpineEastSouthB", 12.0, 19.0, 2.5)
	_wall_x(spine, "SpineEastSouthC", 22.0, 25.0, 2.5)

	var gallery_a := _district("GalleryA")
	_wall_z(gallery_a, "GalleryAWest", -3.0, -13.0, 0.0)
	_wall_z(gallery_a, "GalleryAEast", 4.0, -13.0, 0.0)
	_wall_x(gallery_a, "GalleryANorth", -3.0, 4.0, -13.0)
	_wall_x(gallery_a, "GalleryASouthWest", -3.0, 0.0, 0.0)
	_wall_x(gallery_a, "GalleryASouthEast", 3.0, 4.0, 0.0)

	var gallery_b := _district("GalleryB")
	_wall_z(gallery_b, "GalleryBWest", 8.0, -11.0, -1.5)
	_wall_z(gallery_b, "GalleryBEast", 16.0, -11.0, -1.5)
	_wall_x(gallery_b, "GalleryBNorth", 8.0, 16.0, -11.0)
	_wall_x(gallery_b, "GalleryBSouthWest", 8.0, 10.0, -1.5)
	_wall_x(gallery_b, "GalleryBSouthEast", 13.0, 16.0, -1.5)

	var medical := _district("MedicalApproach")
	_wall_z(medical, "MedicalWest", 4.0, -20.0, -1.5)
	_wall_z(medical, "MedicalEast", 8.0, -20.0, -1.5)
	_wall_x(medical, "MedicalSouthWest", 4.0, 5.0, -1.5)
	_wall_x(medical, "MedicalSouthEast", 7.0, 8.0, -1.5)

	var kitchen := _district("KitchenApproach")
	_wall_z(kitchen, "KitchenSouthWest", 16.0, -11.0, -1.5)
	_wall_z(kitchen, "KitchenSouthEast", 20.0, -11.0, -1.5)
	_wall_x(kitchen, "KitchenSpineWest", 16.0, 17.0, -1.5)
	_wall_x(kitchen, "KitchenSpineEast", 19.0, 20.0, -1.5)
	_wall_z(kitchen, "KitchenCrossWest", 16.0, -14.0, -11.0)
	_wall_x(kitchen, "KitchenCrossSouth", 20.0, 26.0, -11.0)
	_wall_x(kitchen, "KitchenCrossNorth", 16.0, 23.0, -14.0)
	_wall_z(kitchen, "KitchenNorthWest", 23.0, -20.0, -14.0)
	_wall_z(kitchen, "KitchenNorthEast", 26.0, -20.0, -14.0)

	var gallery_c := _district("GalleryC")
	_wall_z(gallery_c, "GalleryCWest", -2.0, 5.0, 14.0)
	_wall_x(gallery_c, "GalleryCNorthWest", -2.0, 0.0, 5.0)
	_wall_x(gallery_c, "GalleryCNorthEast", 3.0, 6.0, 5.0)
	_wall_x(gallery_c, "GalleryCSouth", -2.0, 6.0, 14.0)
	_wall_z(gallery_c, "GalleryCEastNorth", 6.0, 5.0, 8.0)
	_wall_z(gallery_c, "GalleryCEastSouth", 6.0, 11.0, 14.0)

	var gallery_d := _district("GalleryD")
	_wall_x(gallery_d, "GalleryDNorthWest", 6.0, 9.0, 2.5)
	_wall_x(gallery_d, "GalleryDNorthEast", 12.0, 15.0, 2.5)
	_wall_z(gallery_d, "GalleryDWestNorth", 6.0, 2.5, 8.0)
	_wall_z(gallery_d, "GalleryDWestSouth", 6.0, 11.0, 14.0)
	_wall_z(gallery_d, "GalleryDEast", 15.0, 2.5, 14.0)
	_wall_x(gallery_d, "GalleryDSouth", 6.0, 15.0, 14.0)

	var gallery_e := _district("GalleryE")
	_wall_x(gallery_e, "GalleryENorthWest", 17.0, 19.0, 2.5)
	_wall_x(gallery_e, "GalleryENorthEast", 22.0, 25.0, 2.5)
	_wall_z(gallery_e, "GalleryEWest", 17.0, 2.5, 15.0)
	_wall_z(gallery_e, "GalleryEEast", 25.0, 2.5, 15.0)
	_wall_x(gallery_e, "GalleryESouth", 17.0, 25.0, 15.0)

	var workshop := _district("WorkshopService")
	_wall_z(workshop, "WorkshopEntryWest", -12.0, 5.0, 18.0)
	_wall_z(workshop, "WorkshopEntryEast", -8.0, 5.0, 18.0)
	_wall_x(workshop, "ServiceNorth", -8.0, 8.0, 18.0)
	_wall_x(workshop, "ServiceSouthWest", -12.0, -10.0, 22.0)
	_wall_x(workshop, "ServiceSouthMid", -7.0, 3.0, 22.0)
	_wall_x(workshop, "ServiceSouthEast", 8.0, 8.3, 22.0)
	_wall_z(workshop, "ServiceEast", 8.0, 18.0, 22.0)
	_wall_z(workshop, "ContinuationWest", -10.0, 22.0, 27.0)
	_wall_z(workshop, "ContinuationEast", -7.0, 22.0, 27.0)
	_wall_x(workshop, "ContinuationBack", -10.0, -7.0, 27.0)

	var salvager := _district("Salvager")
	_wall_z(salvager, "SalvagerWest", 3.0, 22.0, 29.0)
	_wall_z(salvager, "SalvagerEast", 8.0, 22.0, 29.0)
	_wall_x(salvager, "SalvagerBack", 3.0, 8.0, 29.0)

	var deeper := _district("DeeperApproach")
	_wall_x(deeper, "DeeperWideNorth", 25.0, 39.0, -1.5)
	_wall_x(deeper, "DeeperWideSouthWest", 25.0, 35.0, 3.0)
	_wall_x(deeper, "DeeperWideSouthEast", 39.0, 42.0, 3.0)
	_wall_z(deeper, "DeeperWideEast", 42.0, -1.5, 3.0)
	_wall_z(deeper, "DogLegWest", 39.0, -10.0, -1.5)
	_wall_z(deeper, "DogLegEast", 43.0, -7.0, -1.5)
	_wall_x(deeper, "DogLegNorth", 39.0, 43.0, -10.0)
	_wall_x(deeper, "DeeperNarrowNorth", 43.0, 58.0, -10.0)
	_wall_x(deeper, "DeeperNarrowSouth", 43.0, 58.0, -7.0)

	var incinerator := _district("Incinerator")
	_wall_z(incinerator, "IncineratorApproachWest", 35.0, 3.0, 10.0)
	_wall_z(incinerator, "IncineratorApproachEast", 39.0, 3.0, 10.0)
	_wall_x(incinerator, "IncineratorPocketNorthWest", 32.0, 35.0, 10.0)
	_wall_x(incinerator, "IncineratorPocketNorthEast", 39.0, 42.0, 10.0)
	_wall_z(incinerator, "IncineratorPocketWest", 32.0, 10.0, 17.0)
	_wall_z(incinerator, "IncineratorPocketEast", 42.0, 10.0, 17.0)
	_wall_x(incinerator, "IncineratorPocketBack", 32.0, 42.0, 17.0)

	var bunker_ops := _district("BunkerOps")
	_wall_z(bunker_ops, "BunkerWestNorth", 58.0, -12.0, -10.0)
	_wall_z(bunker_ops, "BunkerWestSouth", 58.0, -7.0, -5.0)
	_wall_x(bunker_ops, "BunkerNorthWest", 58.0, 59.0, -12.0)
	_wall_x(bunker_ops, "BunkerNorthEast", 61.0, 62.0, -12.0)
	_wall_x(bunker_ops, "BunkerSouth", 58.0, 62.0, -5.0)


func _build_fixed_boundaries() -> void:
	var freight := _owned_node(_boundaries, Node3D.new(), "FreightBarrier") as Node3D
	_box(freight, "LowerRail", Vector3(-36.0, 0.35, 0.0), Vector3(0.32, 0.28, 9.0), _materials["barrier"])
	_box(freight, "UpperRail", Vector3(-36.0, 1.15, 0.0), Vector3(0.32, 0.24, 9.0), _materials["barrier"])
	for index: int in 5:
		_box(freight, "Post%02d" % index, Vector3(-36.0, 0.75, -4.0 + index * 2.0), Vector3(0.34, 1.5, 0.24), _materials["barrier"])

	_box(_boundaries, "MedicalFrontageClosure", Vector3(6.0, 1.7, -22.0), Vector3(8.0, 3.4, 4.0), _materials["closure"])
	_box(_boundaries, "KitchenFrontageClosure", Vector3(25.0, 1.7, -22.0), Vector3(10.0, 3.4, 4.0), _materials["closure"])
	_box(_boundaries, "WorkshopFrontageClosure", Vector3(-14.0, 1.7, 20.0), Vector3(4.0, 3.4, 4.0), _materials["closure"])
	_box(_boundaries, "BunkerOpsFrontageClosure", Vector3(59.0, 1.7, -14.0), Vector3(4.0, 3.4, 4.0), _materials["closure"])
	_box(_boundaries, "DeeperSettlementClosure", Vector3(62.0, 1.7, -8.5), Vector3(0.65, 3.4, 7.0), _materials["closure"])
	_box(_boundaries, "BlockedContinuation", Vector3(-8.5, 1.35, 24.2), Vector3(3.0, 2.7, 0.75), _materials["closure"])
	_box(_boundaries, "BlockedDebrisWest", Vector3(-9.35, 0.45, 23.45), Vector3(1.0, 0.9, 1.2), _materials["backlog"])
	_box(_boundaries, "BlockedDebrisEast", Vector3(-7.75, 0.35, 23.6), Vector3(1.0, 0.7, 0.9), _materials["backlog"])


func _build_spatial_proxies() -> void:
	_box(_proxies, "SortingTable", Vector3(-9.0, 0.45, -4.1), Vector3(3.8, 0.90, 1.45), _materials["proxy"])
	_box(_proxies, "DispatchWorkSurface", Vector3(-31.0, 0.45, -8.2), Vector3(3.0, 0.90, 1.1), _materials["proxy"])
	_box(_proxies, "BacklogNorthBlock", Vector3(-22.5, 0.85, -2.9), Vector3(3.0, 1.7, 1.3), _materials["backlog"])
	_box(_proxies, "BacklogSouthBlock", Vector3(-18.5, 0.65, 3.0), Vector3(2.2, 1.3, 1.1), _materials["backlog"])

	# Wall-fitted shelf envelopes in all five galleries.
	_shelf("GalleryA_West", Vector3(-2.4, 1.35, -7.2), Vector3(0.9, 2.7, 7.0))
	_shelf("GalleryA_North", Vector3(0.7, 1.35, -12.35), Vector3(5.0, 2.7, 0.9))
	_shelf("GalleryB_North", Vector3(12.0, 1.35, -10.35), Vector3(6.0, 2.7, 0.9))
	_shelf("GalleryB_East", Vector3(15.35, 1.35, -6.5), Vector3(0.9, 2.7, 5.2))
	_shelf("GalleryC_West", Vector3(-1.35, 1.35, 9.5), Vector3(0.9, 2.7, 6.5))
	_shelf("GalleryC_South", Vector3(2.0, 1.35, 13.35), Vector3(5.2, 2.7, 0.9))
	_shelf("GalleryD_East", Vector3(14.35, 1.35, 8.6), Vector3(0.9, 2.7, 7.5))
	_shelf("GalleryD_South", Vector3(10.5, 1.35, 13.35), Vector3(5.6, 2.7, 0.9))
	_shelf("GalleryE_East", Vector3(24.35, 1.35, 8.8), Vector3(0.9, 2.7, 8.0))
	_shelf("GalleryE_South", Vector3(21.0, 1.35, 14.35), Vector3(5.0, 2.7, 0.9))
	_box(_proxies, "GalleryD_LowIsland", Vector3(10.0, 0.65, 8.0), Vector3(3.0, 1.3, 1.1), _materials["proxy"])
	_box(_proxies, "GalleryE_LowIsland", Vector3(20.0, 0.55, 8.0), Vector3(2.5, 1.1, 1.0), _materials["proxy"])

	_box(_proxies, "WorkshopEdgeMass", Vector3(-10.9, 0.8, 12.5), Vector3(1.4, 1.6, 3.0), _materials["backlog"])
	_box(_proxies, "ServiceEdgeMass", Vector3(-2.0, 0.75, 21.15), Vector3(3.0, 1.5, 1.1), _materials["backlog"])
	_box(_proxies, "SalvagerMachine", Vector3(5.5, 1.45, 27.25), Vector3(4.4, 2.9, 2.5), _materials["machine"])
	_box(_proxies, "IncineratorMachine", Vector3(37.0, 1.45, 14.75), Vector3(9.0, 2.9, 3.5), _materials["machine"])
	_box(_proxies, "BunkerOpsCounter", Vector3(59.0, 0.55, -11.3), Vector3(2.2, 1.1, 0.9), _materials["proxy"])


func _build_anchors() -> void:
	_anchor("ReceivingApron", Vector3(-31.5, 0.05, 0.0), -90.0)
	_anchor("SortingWork", Vector3(-9.0, 0.05, -2.65), 0.0)
	_anchor("StorageNear", Vector3(-1.0, 0.05, 2.5), -90.0)
	_anchor("GalleryA", Vector3(1.5, 0.05, -6.0), 0.0)
	_anchor("GalleryB", Vector3(11.0, 0.05, -5.0), 0.0)
	_anchor("GalleryC", Vector3(2.0, 0.05, 8.0), 180.0)
	_anchor("GalleryD", Vector3(10.0, 0.05, 5.0), 180.0)
	_anchor("GalleryE", Vector3(20.0, 0.05, 5.5), 180.0)
	_anchor("MedicalSafeSide", Vector3(6.0, 0.05, -18.2), 0.0)
	_anchor("KitchenSafeSide", Vector3(24.5, 0.05, -18.2), 0.0)
	_anchor("WorkshopSafeSide", Vector3(-10.3, 0.05, 20.0), -90.0)
	_anchor("SalvagerFront", Vector3(5.5, 0.05, 24.8), 180.0)
	_anchor("BlockedContinuationSafeSide", Vector3(-8.5, 0.05, 23.0), 180.0)
	_anchor("IncineratorFront", Vector3(37.0, 0.05, 12.2), 180.0)
	_anchor("BunkerOpsSafeSide", Vector3(59.0, 0.05, -9.5), 0.0)
	_anchor("DeeperClosureSafeSide", Vector3(60.5, 0.05, -7.0), -90.0)
	_anchor("CSecondaryWest", Vector3(5.0, 0.05, 9.5), -90.0)
	_anchor("DSecondaryEast", Vector3(7.0, 0.05, 9.5), 90.0)


func _floor_zone(district_name: String, zone_name: String, x0: float, x1: float, z0: float, z1: float, height: float, floor_material_key: String) -> void:
	var district := _district(district_name)
	_box(district, "Floor_" + zone_name, Vector3((x0 + x1) * 0.5, -FLOOR_THICKNESS * 0.5, (z0 + z1) * 0.5), Vector3(x1 - x0, FLOOR_THICKNESS, z1 - z0), _materials[floor_material_key])
	_box(_roof_visuals, "Ceiling_" + zone_name, Vector3((x0 + x1) * 0.5, height + FLOOR_THICKNESS * 0.5, (z0 + z1) * 0.5), Vector3(x1 - x0, FLOOR_THICKNESS, z1 - z0), _materials["ceiling"])


func _wall_x(parent: Node3D, node_name: String, x0: float, x1: float, z: float, height: float = CLEAR_HEIGHT) -> void:
	_box(parent, node_name, Vector3((x0 + x1) * 0.5, height * 0.5, z), Vector3(x1 - x0, height, WALL_THICKNESS), _materials["wall"])


func _wall_z(parent: Node3D, node_name: String, x: float, z0: float, z1: float, height: float = CLEAR_HEIGHT) -> void:
	_box(parent, node_name, Vector3(x, height * 0.5, (z0 + z1) * 0.5), Vector3(WALL_THICKNESS, height, z1 - z0), _materials["wall"])


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
