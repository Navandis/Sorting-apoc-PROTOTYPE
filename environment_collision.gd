extends Node3D

# Temporary collision generation for the imported-asset test room.
# Architecture receives accurate static trimesh collision; large props receive
# a single convex hull so the FPS controller does not snag on tiny details.
# This is intentionally a prototype aid, not the final collision pipeline.

@export var generate_test_collisions: bool = true
@export var print_collision_summary: bool = true

const TRIMESH_ROOT_PREFIXES = [
	"SM_Hangar_floor_",
	"SM_Sewer_Floor_",
	"SM_Sewer_Wall_",
	"SM_Walkway"
]

const CONVEX_ROOT_PREFIXES = [
	"SM_ventilated_locker",
	"SM_MilitaryCrate_",
	"SM_Barrel_",
	"SM_Hallway_Door_",
	"SM_PortaCabinDoor",
	"SM_Electrical_Cabinet_",
	"SM_Table",
	"SM_CinderBlocks_",
	"SM_Generator_",
	"SM_ClothesCabinet",
	"SM_Tool_Cabinet_"
]

var _trimesh_count := 0
var _convex_count := 0


func _ready() -> void:
	if not generate_test_collisions:
		return

	for child in get_children():
		if child is CharacterBody3D:
			continue

		var root_name := String(child.name)
		if _starts_with_any(root_name, TRIMESH_ROOT_PREFIXES):
			_generate_for_branch(child, true)
		elif _starts_with_any(root_name, CONVEX_ROOT_PREFIXES):
			_generate_for_branch(child, false)

	if print_collision_summary:
		print(
			"Prototype collision generated: ",
			_trimesh_count,
			" trimesh mesh(es), ",
			_convex_count,
			" convex mesh(es)."
		)


func _generate_for_branch(node: Node, use_trimesh: bool) -> void:
	# Skip invisible imported branches; several catalogue/reference pieces in the
	# test scene are deliberately hidden.
	if node is Node3D and not node.is_visible_in_tree():
		return

	if node is MeshInstance3D and node.mesh != null:
		if use_trimesh:
			node.create_trimesh_collision()
			_trimesh_count += 1
		else:
			node.create_convex_collision()
			_convex_count += 1

	# Snapshot the child list because collision helpers add nodes while running.
	var existing_children := node.get_children()
	for child in existing_children:
		# Do not recurse into collision bodies we just generated.
		if child is StaticBody3D:
			continue
		_generate_for_branch(child, use_trimesh)


func _starts_with_any(value: String, prefixes: Array) -> bool:
	for prefix in prefixes:
		if value.begins_with(prefix):
			return true
	return false
