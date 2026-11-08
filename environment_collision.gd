extends Node3D

# Temporary collision generation for the imported-asset test room.
# Architecture receives accurate static trimesh collision; large props receive
# a single convex hull so the FPS controller does not snag on tiny details.
# This is intentionally a prototype aid, not the final collision pipeline.

@export var generate_test_collisions: bool = true
@export var print_collision_summary: bool = true
@export var generate_storage_prototype: bool = true
## The wing loads inside a hidden run candidate. Keep this branch's own
## hidden meshes excluded while ignoring that temporary ancestor visibility.
@export var use_local_visibility_for_collision: bool = false

const StoragePrototypeManagerScript = preload("res://storage_prototype_manager.gd")

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
	"SM_Tool_Cabinet_",
	"SM_MetalShelves"
]

var _trimesh_count := 0
var _convex_count := 0
var _initialized := false


func _ready() -> void:
	if not generate_test_collisions or _initialized:
		return
	_initialized = true

	if not use_local_visibility_for_collision or visible:
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

	if generate_storage_prototype:
		var storage_manager: Node = StoragePrototypeManagerScript.new()
		storage_manager.name = "StoragePrototypeManager"
		add_child(storage_manager)
		storage_manager.install(self)


func _generate_for_branch(node: Node, use_trimesh: bool) -> void:
	# Skip invisible imported branches; several catalogue/reference pieces in the
	# test scene are deliberately hidden.
	if node is Node3D:
		var branch_visible: bool = node.visible if use_local_visibility_for_collision else node.is_visible_in_tree()
		if not branch_visible:
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
