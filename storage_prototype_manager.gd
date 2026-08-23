extends Node
class_name StoragePrototypeManager

## Runtime Step 4 installer for deterministic shelf surfaces.
##
## This avoids modifying imported GLBs or hand-authoring shelf children in the
## .tscn during the prototype. Known shelf families receive authored per-level
## storage profiles normalized against their visual bounds.
##
## F6: toggle storage debug grids.
## F7: cycle an occupancy/release demonstration on the lowest available shelf.

const StorageSurfaceScript = preload("res://storage_surface.gd")

const DEFAULT_WORLD_CELL_SIZE_M: float = 0.10
const SURFACE_VERTICAL_NUDGE_M: float = 0.018

var _scene_root: Node = null
var _surfaces: Array[Node] = []
var _debug_visible: bool = true
var _demo_state: int = 0
var _demo_surface: Node = null


func install(scene_root: Node) -> void:
	_scene_root = scene_root
	_install_known_shelves()
	_choose_demo_surface()
	_print_summary()


func get_surfaces() -> Array[Node]:
	return _surfaces.duplicate()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return

	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_F6:
		_debug_visible = not _debug_visible
		for surface_node: Node in _surfaces:
			if surface_node.has_method("set_debug_visible"):
				surface_node.set_debug_visible(_debug_visible)
		get_viewport().set_input_as_handled()

	elif key_event.keycode == KEY_F7:
		_cycle_demo()
		get_viewport().set_input_as_handled()


func _install_known_shelves() -> void:
	if _scene_root == null:
		return

	# Step 4.1: storage geometry is authored per shelf FAMILY and per shelf LEVEL.
	# The first pass used one aggregate AABB plus one width/depth fraction for
	# the whole furniture item. That is too crude: frames, lips, cage backs and
	# top/bottom construction make the usable planes differ level by level.
	#
	# Profile values are normalized against the placed shelf's aggregate local
	# bounds so the same profile also works for uniformly scaled instances.
	for child: Node in _scene_root.get_children():
		if not (child is Node3D):
			continue

		var shelf: Node3D = child as Node3D
		var shelf_name: String = String(shelf.name)

		if shelf_name.begins_with("SM_MetalShelves"):
			_install_authored_profile(
				shelf,
				[
					# bottom → top
					_make_level_profile(0.105, 0.96, 0.92, 0.00, 0.00),
					_make_level_profile(0.390, 0.96, 0.92, 0.00, 0.00),
					_make_level_profile(0.685, 0.96, 0.92, 0.00, 0.00),
					_make_level_profile(0.980, 0.96, 0.92, 0.00, 0.00)
				]
			)

		elif shelf_name.begins_with("SM_ventilated_locker"):
			_install_authored_profile(
				shelf,
				[
					# Bottom and top shelf geometry is shallower/differently
					# centered than the two middle levels.
					_make_level_profile(0.045, 0.94, 0.92, 0.00, 0.00),
					_make_level_profile(0.365, 0.94, 0.92, -0.10, -0.03),
					_make_level_profile(0.625, 0.94, 0.92, 0.00, -0.03),
					_make_level_profile(0.820, 0.94, 0.92, 0.00, 0.00)
				]
			)

	# SM_ClothesCabinet remains intentionally deferred. Its vertical dividers
	# should become separate compartment surfaces rather than one shelf-wide
	# grid.


func _make_level_profile(
	y_ratio: float,
	width_fraction: float,
	depth_fraction: float,
	x_offset_fraction: float,
	z_offset_fraction: float
) -> Dictionary:
	return {
		"y_ratio": y_ratio,
		"width_fraction": width_fraction,
		"depth_fraction": depth_fraction,
		"x_offset_fraction": x_offset_fraction,
		"z_offset_fraction": z_offset_fraction
	}


func _install_authored_profile(
	shelf: Node3D,
	level_profiles: Array
) -> void:
	var bounds_result: Dictionary = _calculate_branch_local_bounds(shelf)
	var valid_value: Variant = bounds_result.get("valid", false)
	if not bool(valid_value):
		push_warning("Storage prototype could not determine bounds for %s" % shelf.name)
		return

	var bounds_value: Variant = bounds_result.get("bounds", AABB())
	var bounds: AABB = bounds_value as AABB
	var center: Vector3 = bounds.position + bounds.size * 0.5

	# Keep cells approximately 10 cm in WORLD space even if the placed shelf
	# instance is uniformly scaled (e.g. SM_ventilated_locker at 0.655).
	var root_scale: Vector3 = shelf.global_transform.basis.get_scale()
	var horizontal_world_scale: float = (
		absf(root_scale.x) + absf(root_scale.z)
	) * 0.5
	horizontal_world_scale = maxf(horizontal_world_scale, 0.001)
	var local_cell_size: float = DEFAULT_WORLD_CELL_SIZE_M / horizontal_world_scale

	var vertical_world_scale: float = maxf(absf(root_scale.y), 0.001)
	var shelf_id: String = String(shelf.name)

	for level_index: int in range(level_profiles.size()):
		var profile_value: Variant = level_profiles[level_index]
		if not (profile_value is Dictionary):
			continue

		var profile: Dictionary = profile_value as Dictionary

		var y_ratio: float = float(profile.get("y_ratio", 0.5))
		var width_fraction: float = float(profile.get("width_fraction", 0.90))
		var depth_fraction: float = float(profile.get("depth_fraction", 0.80))
		var x_offset_fraction: float = float(profile.get("x_offset_fraction", 0.0))
		var z_offset_fraction: float = float(profile.get("z_offset_fraction", 0.0))

		var local_width: float = maxf(bounds.size.x * width_fraction, 0.10)
		var local_depth: float = maxf(bounds.size.z * depth_fraction, 0.10)

		var local_x: float = center.x + bounds.size.x * x_offset_fraction
		var local_z: float = center.z + bounds.size.z * z_offset_fraction
		var local_y: float = (
			bounds.position.y
			+ bounds.size.y * y_ratio
			+ SURFACE_VERTICAL_NUDGE_M / vertical_world_scale
		)

		var surface: Node3D = StorageSurfaceScript.new()
		surface.name = "StorageSurface_%02d" % (level_index + 1)
		surface.position = Vector3(local_x, local_y, local_z)
		shelf.add_child(surface)

		var surface_identifier: StringName = StringName(
			"%s_level_%d" % [shelf_id, level_index + 1]
		)
		surface.configure(
			surface_identifier,
			local_width,
			local_depth,
			local_cell_size
		)
		surface.set_debug_visible(_debug_visible)
		_surfaces.append(surface)


func _calculate_branch_local_bounds(root: Node3D) -> Dictionary:
	var state: Dictionary = {
		"valid": false,
		"bounds": AABB()
	}

	for child: Node in root.get_children():
		_scan_bounds_recursive(child, Transform3D.IDENTITY, state)

	return state


func _scan_bounds_recursive(
	node: Node,
	accumulated_transform: Transform3D,
	state: Dictionary
) -> void:
	var next_transform: Transform3D = accumulated_transform
	if node is Node3D:
		var node_3d: Node3D = node as Node3D
		next_transform = accumulated_transform * node_3d.transform

	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh != null:
			var transformed_bounds: AABB = next_transform * mesh_instance.get_aabb()
			var valid_value: Variant = state.get("valid", false)
			if bool(valid_value):
				var current_value: Variant = state.get("bounds", AABB())
				var current_bounds: AABB = current_value as AABB
				state["bounds"] = current_bounds.merge(transformed_bounds)
			else:
				state["bounds"] = transformed_bounds
				state["valid"] = true

	for child: Node in node.get_children():
		_scan_bounds_recursive(child, next_transform, state)


func _choose_demo_surface() -> void:
	if _surfaces.is_empty():
		return

	# Prefer the lowest level of the large metal shelf; otherwise use the first
	# installed surface.
	for surface_node: Node in _surfaces:
		var parent_node: Node = surface_node.get_parent()
		if parent_node != null and String(parent_node.name).begins_with("SM_MetalShelves"):
			_demo_surface = surface_node
			return

	_demo_surface = _surfaces[0]


func _cycle_demo() -> void:
	if _demo_surface == null:
		print("Storage Step 4: no demo surface available.")
		return

	_demo_state = (_demo_state + 1) % 4
	_demo_surface.clear_all()

	match _demo_state:
		0:
			print("Storage Step 4 demo: cleared.")
		1:
			_reserve_demo_layout_a()
			print("Storage Step 4 demo A: mixed 1x1 / 1x3 / 2x1 / 2x5 / 2x2 footprints.")
		2:
			_reserve_demo_layout_a()
			_demo_surface.release("demo_hammer")
			_demo_surface.reserve_first_fit("demo_large_box", Vector2i(3, 2), true)
			print("Storage Step 4 demo B: hammer released; 3x2 footprint inserted.")
		3:
			_demo_surface.reserve_first_fit("demo_racket_a", Vector2i(2, 5), true)
			_demo_surface.reserve_first_fit("demo_racket_b", Vector2i(2, 5), true)
			_demo_surface.reserve_first_fit("demo_rifle", Vector2i(1, 5), true)
			_demo_surface.reserve_first_fit("demo_small_a", Vector2i(1, 1), true)
			_demo_surface.reserve_first_fit("demo_small_b", Vector2i(1, 1), true)
			print("Storage Step 4 demo C: long-item-heavy layout.")

	if _demo_surface.has_method("debug_summary"):
		print(_demo_surface.debug_summary())


func _reserve_demo_layout_a() -> void:
	_demo_surface.reserve_first_fit("demo_can", Vector2i(1, 1), true)
	_demo_surface.reserve_first_fit("demo_hammer", Vector2i(1, 3), true)
	_demo_surface.reserve_first_fit("demo_pistol", Vector2i(2, 1), true)
	_demo_surface.reserve_first_fit("demo_racket", Vector2i(2, 5), true)
	_demo_surface.reserve_first_fit("demo_box", Vector2i(2, 2), true)


func _print_summary() -> void:
	print("Storage Step 4: installed ", _surfaces.size(), " deterministic surface(s).")
	print("  F6 toggles storage debug grids. F7 cycles occupancy/release demos.")

	for surface_node: Node in _surfaces:
		if surface_node.has_method("debug_summary"):
			print("  ", surface_node.debug_summary())
