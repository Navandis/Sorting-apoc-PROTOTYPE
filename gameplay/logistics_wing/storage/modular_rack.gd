@tool
extends Node3D
class_name ModularRack

const StorageSurfaceScript = preload("res://storage_surface.gd")

const DEFAULT_WORLD_CELL_SIZE_M := 0.10
const SURFACE_VERTICAL_NUDGE_M := 0.018
const MIN_USABLE_DIMENSION_M := 0.10
const DIMENSION_EPSILON_M := 0.0001
const ROOT_TRANSFORM_EPSILON := 0.0001

@export_range(0.10, 20.0, 0.01, "or_greater", "or_less") var rack_length_m := 2.40:
	set(value):
		rack_length_m = value
		_request_refresh()

@export_range(0.10, 5.0, 0.01, "or_greater", "or_less") var rack_depth_m := 0.80:
	set(value):
		rack_depth_m = value
		_request_refresh()

@export_range(0.10, 8.0, 0.01, "or_greater", "or_less") var frame_height_m := 2.20:
	set(value):
		frame_height_m = value
		_request_refresh()

@export_range(0.0, 2.0, 0.005, "or_greater", "or_less") var usable_inset_left_m := 0.04:
	set(value):
		usable_inset_left_m = value
		_request_refresh()

@export_range(0.0, 2.0, 0.005, "or_greater", "or_less") var usable_inset_right_m := 0.04:
	set(value):
		usable_inset_right_m = value
		_request_refresh()

@export_range(0.0, 2.0, 0.005, "or_greater", "or_less") var usable_inset_front_m := 0.00:
	set(value):
		usable_inset_front_m = value
		_request_refresh()

@export_range(0.0, 2.0, 0.005, "or_greater", "or_less") var usable_inset_back_m := 0.05:
	set(value):
		usable_inset_back_m = value
		_request_refresh()

@export_range(0.01, 10.0, 0.01, "or_greater", "or_less") var overhead_limit_local_y_m := 3.40:
	set(value):
		overhead_limit_local_y_m = value
		_request_refresh()

@export var show_authoring_preview := true:
	set(value):
		show_authoring_preview = value
		_request_refresh()

var _refresh_requested := true
var _last_authoring_fingerprint := ""
var _runtime_surfaces: Array[StorageSurface] = []


func _ready() -> void:
	_ensure_instance_collision_resource()
	_request_refresh()
	refresh_authoring_state()


func _process(_delta: float) -> void:
	var fingerprint := _authoring_fingerprint()
	if _refresh_requested or fingerprint != _last_authoring_fingerprint:
		refresh_authoring_state()


func refresh_authoring_state() -> void:
	_ensure_instance_collision_resource()
	_align_frame_visual()
	_align_level_visuals()
	_update_collision()
	_update_overhead_marker()
	var layout := compute_layout()
	_rebuild_authoring_preview(layout)
	_refresh_requested = false
	_last_authoring_fingerprint = _authoring_fingerprint()
	update_configuration_warnings()


func compute_layout() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	_validate_root_authoring(errors)

	var frame_result := _get_source_bounds(get_node_or_null("Frame/Visual"))
	if not bool(frame_result.get("valid", false)):
		errors.append("Frame/Visual is missing or has no mesh geometry.")
	var platform_result := _first_platform_source_bounds()
	if not bool(platform_result.get("valid", false)):
		errors.append("Levels requires at least one shelf wrapper with a valid Rack02 Visual.")

	var frame_bounds := frame_result.get("bounds", AABB()) as AABB
	var platform_bounds := platform_result.get("bounds", AABB()) as AABB
	var length_factor := 0.0
	var depth_factor := 0.0
	if frame_bounds.size.z > DIMENSION_EPSILON_M:
		length_factor = rack_length_m / frame_bounds.size.z
	if frame_bounds.size.x > DIMENSION_EPSILON_M:
		depth_factor = rack_depth_m / frame_bounds.size.x
	var platform_size := Vector2(
		platform_bounds.size.z * length_factor,
		platform_bounds.size.x * depth_factor
	)
	var platform_thickness := platform_bounds.size.y
	var usable_size := Vector2(
		platform_size.x - usable_inset_left_m - usable_inset_right_m,
		platform_size.y - usable_inset_front_m - usable_inset_back_m
	)
	var usable_center := Vector2(
		(usable_inset_left_m - usable_inset_right_m) * 0.5,
		(usable_inset_front_m - usable_inset_back_m) * 0.5
	)
	if usable_size.x + DIMENSION_EPSILON_M < MIN_USABLE_DIMENSION_M:
		errors.append("Left/right insets leave less than one 0.10 m storage cell of usable length.")
	if usable_size.y + DIMENSION_EPSILON_M < MIN_USABLE_DIMENSION_M:
		errors.append("Front/back insets leave less than one 0.10 m storage cell of usable depth.")

	var levels_root := get_node_or_null("Levels")
	var level_records: Array[Dictionary] = []
	var identity_keys := {}
	if levels_root == null:
		errors.append("Levels container is missing.")
	else:
		for child: Node in levels_root.get_children():
			if not (child is Node3D):
				errors.append("Levels/%s must be a Node3D shelf wrapper." % child.name)
				continue
			var level := child as Node3D
			var level_name := String(level.name)
			var identity_key := level_name.to_lower()
			if identity_keys.has(identity_key):
				errors.append("Shelf-level identity is duplicated: %s." % level_name)
			else:
				identity_keys[identity_key] = true
			var level_visual_result := _get_source_bounds(level.get_node_or_null("Visual"))
			if not bool(level_visual_result.get("valid", false)):
				errors.append("Levels/%s/Visual is missing or malformed." % level_name)
			var support_y := level.position.y
			if support_y < 0.0:
				warnings.append("Shelf level %s is below the rack installation base." % level_name)
			level_records.append({
				"node": level,
				"name": level_name,
				"surface_id": StringName("%s_%s" % [name, level_name]),
				"support_y": support_y,
				"surface_origin_y": support_y + SURFACE_VERTICAL_NUDGE_M,
				"usable_size": usable_size,
				"usable_center": usable_center,
				"clearance": 0.0,
				"platform_thickness": platform_thickness,
			})

	if level_records.is_empty():
		errors.append("Modular rack has no authored shelf levels.")
	else:
		level_records.sort_custom(
			func(a: Dictionary, b: Dictionary) -> bool:
				return float(a.get("support_y", 0.0)) < float(b.get("support_y", 0.0))
		)
		for index: int in range(level_records.size()):
			var record := level_records[index]
			var clearance := 0.0
			if index + 1 < level_records.size():
				var upper := level_records[index + 1]
				clearance = (
					float(upper.get("support_y", 0.0))
					- platform_thickness
					- float(record.get("surface_origin_y", 0.0))
				)
				if clearance <= DIMENSION_EPSILON_M:
					errors.append("Shelf opening at %s is nonpositive after Rack02 thickness." % record.get("name", ""))
			else:
				clearance = overhead_limit_local_y_m - float(record.get("surface_origin_y", 0.0))
				if clearance <= DIMENSION_EPSILON_M:
					errors.append("Top shelf is at or above the authored overhead limit.")
			record["clearance"] = clearance
			level_records[index] = record
		var highest := level_records[-1]
		if float(highest.get("support_y", 0.0)) > frame_height_m + DIMENSION_EPSILON_M:
			warnings.append("Highest shelf level is above the authored frame height.")

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings,
		"rack": {
			"length": rack_length_m,
			"depth": rack_depth_m,
			"frame_height": frame_height_m,
			"platform_base_size": platform_size,
			"surface_vertical_nudge": SURFACE_VERTICAL_NUDGE_M,
			"cell_size": DEFAULT_WORLD_CELL_SIZE_M,
		},
		"levels": level_records,
	}


func get_layout_contract() -> Dictionary:
	return compute_layout()


func build_runtime_storage() -> Array[StorageSurface]:
	return _runtime_surfaces.duplicate()


func clear_runtime_storage() -> bool:
	_runtime_surfaces.clear()
	return true


func _get_configuration_warnings() -> PackedStringArray:
	var layout := compute_layout()
	var result := PackedStringArray()
	for error: String in layout.get("errors", []) as Array[String]:
		result.append("ERROR: %s" % error)
	for warning: String in layout.get("warnings", []) as Array[String]:
		result.append("WARNING: %s" % warning)
	return result


func _validate_root_authoring(errors: Array[String]) -> void:
	if rack_length_m <= 0.0:
		errors.append("Rack length must be positive.")
	if rack_depth_m <= 0.0:
		errors.append("Rack depth must be positive.")
	if frame_height_m <= 0.0:
		errors.append("Frame height must be positive.")
	if minf(usable_inset_left_m, usable_inset_right_m) < 0.0 or minf(usable_inset_front_m, usable_inset_back_m) < 0.0:
		errors.append("Usable-area insets cannot be negative.")
	var root_scale := transform.basis.get_scale()
	if not root_scale.is_equal_approx(Vector3.ONE):
		errors.append("ModularRack root scale must remain (1, 1, 1); use rack dimensions instead.")
	if absf(rotation.x) > ROOT_TRANSFORM_EPSILON or absf(rotation.z) > ROOT_TRANSFORM_EPSILON:
		errors.append("ModularRack root supports translation and yaw only; pitch and roll must remain zero.")


func _first_platform_source_bounds() -> Dictionary:
	var levels_root := get_node_or_null("Levels")
	if levels_root == null:
		return {"valid": false, "bounds": AABB()}
	for child: Node in levels_root.get_children():
		if child is Node3D:
			var result := _get_source_bounds(child.get_node_or_null("Visual"))
			if bool(result.get("valid", false)):
				return result
	return {"valid": false, "bounds": AABB()}


func _get_source_bounds(branch: Node) -> Dictionary:
	if not (branch is Node3D):
		return {"valid": false, "bounds": AABB()}
	var state := {"valid": false, "bounds": AABB()}
	for child: Node in branch.get_children():
		_scan_source_bounds(child, Transform3D.IDENTITY, state)
	return state


func _scan_source_bounds(node: Node, parent_transform: Transform3D, state: Dictionary) -> void:
	var transform_to_branch := parent_transform
	if node is Node3D:
		transform_to_branch = parent_transform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh != null:
			var bounds := transform_to_branch * mesh_node.get_aabb()
			if bool(state["valid"]):
				state["bounds"] = (state["bounds"] as AABB).merge(bounds)
			else:
				state["valid"] = true
				state["bounds"] = bounds
	for child: Node in node.get_children():
		_scan_source_bounds(child, transform_to_branch, state)


func _align_frame_visual() -> void:
	var visual := get_node_or_null("Frame/Visual") as Node3D
	var result := _get_source_bounds(visual)
	if visual == null or not bool(result.get("valid", false)):
		return
	var bounds := result.get("bounds", AABB()) as AABB
	if bounds.size.x <= DIMENSION_EPSILON_M or bounds.size.y <= DIMENSION_EPSILON_M or bounds.size.z <= DIMENSION_EPSILON_M:
		return
	var source_scale := Vector3(
		rack_depth_m / bounds.size.x,
		frame_height_m / bounds.size.y,
		rack_length_m / bounds.size.z
	)
	_set_visual_transform(visual, bounds, source_scale, false)


func _align_level_visuals() -> void:
	var levels_root := get_node_or_null("Levels")
	var frame_result := _get_source_bounds(get_node_or_null("Frame/Visual"))
	if levels_root == null or not bool(frame_result.get("valid", false)):
		return
	var frame_bounds := frame_result.get("bounds", AABB()) as AABB
	if frame_bounds.size.x <= DIMENSION_EPSILON_M or frame_bounds.size.z <= DIMENSION_EPSILON_M:
		return
	var source_scale := Vector3(
		rack_depth_m / frame_bounds.size.x,
		1.0,
		rack_length_m / frame_bounds.size.z
	)
	for child: Node in levels_root.get_children():
		if not (child is Node3D):
			continue
		var level := child as Node3D
		var aligned_level_transform := Transform3D(Basis.IDENTITY, Vector3(0.0, level.position.y, 0.0))
		if not level.transform.is_equal_approx(aligned_level_transform):
			level.transform = aligned_level_transform
		var visual := level.get_node_or_null("Visual") as Node3D
		var result := _get_source_bounds(visual)
		if visual != null and bool(result.get("valid", false)):
			_set_visual_transform(visual, result.get("bounds", AABB()) as AABB, source_scale, true)


func _set_visual_transform(visual: Node3D, bounds: AABB, source_scale: Vector3, top_aligned: bool) -> void:
	var basis := Basis(Vector3.UP, PI * 0.5) * Basis.from_scale(source_scale)
	var source_center := bounds.get_center()
	var transformed_center := basis * Vector3(source_center.x, 0.0, source_center.z)
	var target_y := -bounds.end.y * source_scale.y if top_aligned else -bounds.position.y * source_scale.y
	var target := Transform3D(basis, Vector3(-transformed_center.x, target_y, -transformed_center.z))
	if not visual.transform.is_equal_approx(target):
		visual.transform = target


func _ensure_instance_collision_resource() -> void:
	var shape_node := get_node_or_null("MovementCollision/Shape") as CollisionShape3D
	if shape_node == null or not (shape_node.shape is BoxShape3D):
		return
	if not shape_node.shape.resource_local_to_scene:
		shape_node.shape = shape_node.shape.duplicate(true)
		shape_node.shape.resource_local_to_scene = true


func _update_collision() -> void:
	var shape_node := get_node_or_null("MovementCollision/Shape") as CollisionShape3D
	if shape_node == null or not (shape_node.shape is BoxShape3D):
		return
	var valid_dimensions := rack_length_m > 0.0 and rack_depth_m > 0.0 and frame_height_m > 0.0
	shape_node.disabled = not valid_dimensions
	if not valid_dimensions:
		return
	var box := shape_node.shape as BoxShape3D
	var desired_size := Vector3(rack_length_m, frame_height_m, rack_depth_m)
	if not box.size.is_equal_approx(desired_size):
		box.size = desired_size
	var desired_transform := Transform3D(Basis.IDENTITY, Vector3(0.0, frame_height_m * 0.5, 0.0))
	if not shape_node.transform.is_equal_approx(desired_transform):
		shape_node.transform = desired_transform


func _update_overhead_marker() -> void:
	var marker := get_node_or_null("OverheadLimit") as Node3D
	if marker == null:
		return
	var desired := Transform3D(Basis.IDENTITY, Vector3(0.0, overhead_limit_local_y_m, 0.0))
	if not marker.transform.is_equal_approx(desired):
		marker.transform = desired


func _rebuild_authoring_preview(layout: Dictionary) -> void:
	var existing := get_node_or_null("AuthoringPreview")
	if existing != null:
		remove_child(existing)
		existing.free()
	if not Engine.is_editor_hint() or not show_authoring_preview:
		return
	var preview := Node3D.new()
	preview.name = "AuthoringPreview"
	add_child(preview)
	var surface_material := StandardMaterial3D.new()
	surface_material.albedo_color = Color(0.18, 0.72, 0.95, 0.30)
	surface_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	surface_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for value: Variant in layout.get("levels", []) as Array:
		var level := value as Dictionary
		var usable := level.get("usable_size", Vector2.ZERO) as Vector2
		if usable.x <= 0.0 or usable.y <= 0.0:
			continue
		var center := level.get("usable_center", Vector2.ZERO) as Vector2
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "Usable_%s" % level.get("name", "Shelf")
		var mesh := BoxMesh.new()
		mesh.size = Vector3(usable.x, 0.008, usable.y)
		mesh.material = surface_material
		mesh_instance.mesh = mesh
		mesh_instance.position = Vector3(center.x, float(level.get("surface_origin_y", 0.0)), center.y)
		preview.add_child(mesh_instance)
	var overhead := MeshInstance3D.new()
	overhead.name = "OverheadLimitPreview"
	var overhead_mesh := BoxMesh.new()
	overhead_mesh.size = Vector3(maxf(rack_length_m, 0.01), 0.012, 0.035)
	var overhead_material := StandardMaterial3D.new()
	overhead_material.albedo_color = Color(1.0, 0.45, 0.18, 0.65)
	overhead_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	overhead_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	overhead_mesh.material = overhead_material
	overhead.mesh = overhead_mesh
	overhead.position.y = overhead_limit_local_y_m
	preview.add_child(overhead)


func _authoring_fingerprint() -> String:
	var parts: Array[String] = [
		str(rack_length_m), str(rack_depth_m), str(frame_height_m),
		str(usable_inset_left_m), str(usable_inset_right_m),
		str(usable_inset_front_m), str(usable_inset_back_m),
		str(overhead_limit_local_y_m), str(show_authoring_preview),
		str(transform.basis.get_scale()), str(rotation.x), str(rotation.z),
	]
	var levels_root := get_node_or_null("Levels")
	if levels_root != null:
		for child: Node in levels_root.get_children():
			parts.append("%s:%s" % [child.name, (child as Node3D).transform if child is Node3D else child.get_class()])
	return "|".join(parts)


func _request_refresh() -> void:
	_refresh_requested = true
