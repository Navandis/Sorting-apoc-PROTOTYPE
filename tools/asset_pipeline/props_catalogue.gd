extends RefCounted

## Directory adapter for persistent definitions. The inventory is authoring
## input/evidence only; runtime reads ItemCatalog and ItemDefinition exclusively.
const Review = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const Audit = preload("res://tools/asset_pipeline/loot_audit_core.gd")

static func discover(directory: String = "res://assets/props") -> PackedStringArray:
	var result := PackedStringArray()
	for child: String in DirAccess.get_directories_at(directory):
		result.append_array(discover(directory.path_join(child)))
	for file: String in DirAccess.get_files_at(directory):
		if file.get_extension().to_lower() in ["glb", "gltf", "fbx", "obj", "blend"]:
			result.append(directory.path_join(file))
	result.sort()
	return result

static func next_sequence(catalogue: ItemCatalog, reserved: Dictionary, manifest: Dictionary) -> int:
	var highest := int(reserved.get("highest_historically_allocated",42))
	for definition: ItemDefinition in catalogue.definitions:
		highest=maxi(highest,String(definition.item_id).trim_prefix("loot_").to_int())
	for key: String in manifest.get("assets",{}):
		highest=maxi(highest,key.trim_prefix("loot_").to_int())
	return highest+1

static func excluded(path: String, retired: Dictionary) -> bool:
	for record: Dictionary in retired.get("items",[]):
		if record.source_path == path: return true
	return false

static func proposed_definition(record: Dictionary) -> ItemDefinition:
	var definition:=ItemDefinition.new()
	definition.item_id=StringName(record.item_id)
	definition.display_name=record.display_name
	definition.storage_category=record.storage_category
	definition.visual_scene=load(record.source_path)
	definition.storage_rotation_degrees=Vector3(record.rotation[0],record.rotation[1],record.rotation[2])
	definition.can_be_stacked=record.can_be_stacked
	definition.can_support_stack=record.can_support_stack
	definition.auto_stack_group=StringName(record.auto_stack_group)
	var measured:=StorageVisualPose.measure_item(ItemInstance.new(definition),false)
	if not measured.valid: return null
	var bounds: AABB=measured.posed_bounds
	if not bounds.size.is_finite() or bounds.size.x<=0 or bounds.size.y<=0 or bounds.size.z<=0: return null
	var footprint:=Audit.raw_footprint(bounds.size,0.10)
	definition.storage_footprint=Vector3i(footprint.width_cells,footprint.depth_cells,1)
	# Explicit temporary numerical placeholders; this is not M4 calibration.
	definition.utility_id=&"None"
	definition.utility_value=0
	definition.bulk=1
	return definition
