extends RefCounted
class_name ReceivingDeckItemPose

const StorageVisualPoseScript = preload("res://storage_visual_pose.gd")

# The fixed SM_Platform_01 main plate is 10.392 mm below its raised edge datum.
# Keep the authored MainDeck frame unchanged; seat its cargo on the plate.
const MAIN_DECK_PLATE_INSET_M: float = 0.010392
const CONTACT_EPSILON_M: float = 0.0005


static func surface_host_y_m(surface_id: StringName) -> float:
	var plate_inset := MAIN_DECK_PLATE_INSET_M if surface_id == &"MainDeck" else 0.0
	# Shared pose normalization supplies 6 mm shelf clearance. Receiving cancels
	# that clearance at its host so ordinary shelves/stack semantics stay intact.
	return CONTACT_EPSILON_M - StorageVisualPoseScript.SHELF_CLEARANCE_M - plate_inset



static func normalize_quarter_turns(value: int) -> int:
	return ((value % 4) + 4) % 4


static func footprint_for(item: ItemInstance, quarter_turns: int) -> Vector2i:
	if item == null:
		return Vector2i.ONE
	var authored: Vector3i = item.get_storage_footprint()
	var footprint := Vector2i(maxi(1, authored.x), maxi(1, authored.y))
	if normalize_quarter_turns(quarter_turns) % 2 == 1:
		return Vector2i(footprint.y, footprint.x)
	return footprint


static func measure_item(item: ItemInstance, quarter_turns: int) -> Dictionary:
	if item == null:
		return {"valid": false}
	var normalized := normalize_quarter_turns(quarter_turns)
	var packing_rotated := normalized % 2 == 1
	var result: Dictionary = StorageVisualPoseScript.measure_item(item, packing_rotated)
	result["quarter_turns"] = normalized
	result["packing_rotated"] = packing_rotated
	result["outer_yaw_radians"] = PI if normalized >= 2 else 0.0
	result["footprint"] = footprint_for(item, normalized)
	return result


static func build_visual(
	host: Node3D,
	visual: Node,
	item: ItemInstance,
	quarter_turns: int
) -> Dictionary:
	if host == null or visual == null or item == null:
		return {"valid": false}
	var normalized := normalize_quarter_turns(quarter_turns)
	host.rotation = Vector3(0.0, PI if normalized >= 2 else 0.0, 0.0)
	var packing_root := Node3D.new()
	packing_root.name = "ReceivingPackingPose"
	host.add_child(packing_root)
	var result: Dictionary = StorageVisualPoseScript.build_visual(
		packing_root,
		visual,
		item.get_storage_rotation_degrees(),
		normalized % 2 == 1
	)
	result["quarter_turns"] = normalized
	result["packing_rotated"] = normalized % 2 == 1
	result["outer_yaw_radians"] = PI if normalized >= 2 else 0.0
	result["footprint"] = footprint_for(item, normalized)
	result["packing_root"] = packing_root
	return result
