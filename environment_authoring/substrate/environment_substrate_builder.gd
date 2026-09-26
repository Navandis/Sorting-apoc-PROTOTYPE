class_name EnvironmentSubstrateBuilder
extends RefCounted

const Registry = preload("res://environment_authoring/substrate/environment_substrate_recipe_registry.gd")
const Spec = preload("res://environment_authoring/substrate/environment_substrate_piece_spec.gd")
const GENERATOR_REVISION := 1


func build(spec: Resource) -> Dictionary:
	if spec == null or not spec is Spec:
		push_error("EAF2 build requires an EnvironmentSubstratePieceSpec")
		return {}
	var errors: PackedStringArray = spec.validate()
	if not errors.is_empty():
		push_error("EAF2 invalid piece %s: %s" % [spec.piece_id, "; ".join(errors)])
		return {}
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	if spec.recipe_id == "rect_solid":
		_build_rect(tool, spec)
	else:
		_build_opening_wall(tool, spec)
	tool.generate_tangents()
	var mesh := tool.commit() as ArrayMesh
	if mesh == null:
		push_error("EAF2 mesh generation failed for " + spec.piece_id)
		return {}
	mesh.resource_name = spec.piece_id
	var registry := Registry.new()
	var recipe: Dictionary = registry.metadata(spec.recipe_id)
	var metadata := {
		"piece_id": spec.piece_id,
		"recipe_id": spec.recipe_id,
		"recipe_revision": int(recipe["revision"]),
		"generator_revision": GENERATOR_REVISION,
		"generation_revision": spec.generation_revision,
		"exact_parameters": spec.exact_parameters(),
		"semantic_role": spec.semantic_role,
		"uv_quarter_turns": spec.uv_quarter_turns,
		"uv_origin_m": [spec.uv_origin_m.x, spec.uv_origin_m.y],
		"collision_policy": spec.collision_policy,
		"material_spec": spec.material_spec.resource_path,
		"authoring_notes": spec.authoring_notes,
	}
	var fingerprint := _fingerprint(mesh, spec, int(recipe["revision"]))
	metadata["geometry_fingerprint"] = fingerprint
	return {
		"mesh": mesh,
		"metadata": metadata,
		"fingerprint": fingerprint,
		"collision_boxes": _collision_boxes(spec),
	}


func _build_rect(tool: SurfaceTool, spec: Resource) -> void:
	var size: Vector3 = spec.dimensions_m
	var hx := size.x * 0.5
	var hy := size.y * 0.5
	var hz := size.z * 0.5
	var faces := [
		[Vector3(-hx,-hy,hz), Vector3(hx,-hy,hz), Vector3(hx,hy,hz), Vector3(-hx,hy,hz), 0],
		[Vector3(hx,-hy,-hz), Vector3(-hx,-hy,-hz), Vector3(-hx,hy,-hz), Vector3(hx,hy,-hz), 0],
		[Vector3(hx,-hy,hz), Vector3(hx,-hy,-hz), Vector3(hx,hy,-hz), Vector3(hx,hy,hz), 1],
		[Vector3(-hx,-hy,-hz), Vector3(-hx,-hy,hz), Vector3(-hx,hy,hz), Vector3(-hx,hy,-hz), 1],
		[Vector3(-hx,hy,hz), Vector3(hx,hy,hz), Vector3(hx,hy,-hz), Vector3(-hx,hy,-hz), 2],
		[Vector3(-hx,-hy,-hz), Vector3(hx,-hy,-hz), Vector3(hx,-hy,hz), Vector3(-hx,-hy,hz), 2],
	]
	for face in faces:
		var a: Vector3 = face[0]
		var b: Vector3 = face[1]
		var d: Vector3 = face[3]
		var axis_u := (b - a).normalized()
		var axis_v := (d - a).normalized()
		var width := a.distance_to(b)
		var height := a.distance_to(d)
		var steps_u := [0.0, width] if spec.bevel_width_m == 0.0 else [0.0, spec.bevel_width_m, width - spec.bevel_width_m, width]
		var steps_v := [0.0, height] if spec.bevel_width_m == 0.0 else [0.0, spec.bevel_width_m, height - spec.bevel_width_m, height]
		for vi in steps_v.size() - 1:
			for ui in steps_u.size() - 1:
				var p0 := a + axis_u * float(steps_u[ui]) + axis_v * float(steps_v[vi])
				var p1 := a + axis_u * float(steps_u[ui + 1]) + axis_v * float(steps_v[vi])
				var p2 := a + axis_u * float(steps_u[ui + 1]) + axis_v * float(steps_v[vi + 1])
				var p3 := a + axis_u * float(steps_u[ui]) + axis_v * float(steps_v[vi + 1])
				if spec.bevel_width_m > 0.0:
					p0 = _bevel_point(p0, size, spec.bevel_width_m)
					p1 = _bevel_point(p1, size, spec.bevel_width_m)
					p2 = _bevel_point(p2, size, spec.bevel_width_m)
					p3 = _bevel_point(p3, size, spec.bevel_width_m)
				_emit_quad(tool, p0, p1, p2, p3, int(face[4]), spec, size)


func _bevel_point(point: Vector3, size: Vector3, bevel: float) -> Vector3:
	var inset := size * 0.5 - Vector3.ONE * bevel
	var core := Vector3(clampf(point.x, -inset.x, inset.x), clampf(point.y, -inset.y, inset.y), clampf(point.z, -inset.z, inset.z))
	return core + (point - core).normalized() * bevel


func _build_opening_wall(tool: SurfaceTool, spec: Resource) -> void:
	var size: Vector3 = spec.dimensions_m
	var grid := _wall_grid(spec)
	var xs: Array = grid["xs"]
	var ys: Array = grid["ys"]
	var hz := size.z * 0.5
	for ix in xs.size() - 1:
		for iy in ys.size() - 1:
			if not _occupied(ix, iy, xs, ys, spec):
				continue
			var x0: float = xs[ix]
			var x1: float = xs[ix + 1]
			var y0: float = ys[iy]
			var y1: float = ys[iy + 1]
			_emit_quad(tool, Vector3(x0,y0,hz), Vector3(x1,y0,hz), Vector3(x1,y1,hz), Vector3(x0,y1,hz), 0, spec, size)
			_emit_quad(tool, Vector3(x1,y0,-hz), Vector3(x0,y0,-hz), Vector3(x0,y1,-hz), Vector3(x1,y1,-hz), 0, spec, size)
			if ix == 0 or not _occupied(ix - 1, iy, xs, ys, spec):
				_emit_quad(tool, Vector3(x0,y0,-hz), Vector3(x0,y0,hz), Vector3(x0,y1,hz), Vector3(x0,y1,-hz), 1, spec, size)
			if ix == xs.size() - 2 or not _occupied(ix + 1, iy, xs, ys, spec):
				_emit_quad(tool, Vector3(x1,y0,hz), Vector3(x1,y0,-hz), Vector3(x1,y1,-hz), Vector3(x1,y1,hz), 1, spec, size)
			if iy == 0 or not _occupied(ix, iy - 1, xs, ys, spec):
				_emit_quad(tool, Vector3(x0,y0,-hz), Vector3(x1,y0,-hz), Vector3(x1,y0,hz), Vector3(x0,y0,hz), 2, spec, size)
			if iy == ys.size() - 2 or not _occupied(ix, iy + 1, xs, ys, spec):
				_emit_quad(tool, Vector3(x0,y1,hz), Vector3(x1,y1,hz), Vector3(x1,y1,-hz), Vector3(x0,y1,-hz), 2, spec, size)


func _wall_grid(spec: Resource) -> Dictionary:
	var size: Vector3 = spec.dimensions_m
	var xs: Array[float] = [-size.x * 0.5, size.x * 0.5]
	var ys: Array[float] = [-size.y * 0.5, size.y * 0.5]
	for opening in spec.opening_rectangles():
		xs.append(opening.position.x)
		xs.append(opening.end.x)
		ys.append(opening.position.y)
		ys.append(opening.end.y)
	xs.sort()
	ys.sort()
	return {"xs": _unique_cuts(xs), "ys": _unique_cuts(ys)}


func _unique_cuts(values: Array[float]) -> Array[float]:
	var result: Array[float] = []
	for value in values:
		if result.is_empty() or absf(value - result.back()) > 0.000001:
			result.append(value)
	return result


func _occupied(ix: int, iy: int, xs: Array, ys: Array, spec: Resource) -> bool:
	var midpoint := Vector2((float(xs[ix]) + float(xs[ix + 1])) * 0.5, (float(ys[iy]) + float(ys[iy + 1])) * 0.5)
	for opening in spec.opening_rectangles():
		if opening.has_point(midpoint):
			return false
	return true


func _emit_quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, plane: int, spec: Resource, size: Vector3) -> void:
	_emit_triangle(tool, a, b, c, plane, spec, size)
	_emit_triangle(tool, a, c, d, plane, spec, size)


func _emit_triangle(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, plane: int, spec: Resource, size: Vector3) -> void:
	var normal := (b - a).cross(c - a).normalized()
	for point in [a, b, c]:
		tool.set_normal(normal)
		tool.set_uv(_uv(point, plane, spec, size))
		tool.add_vertex(point)


func _uv(point: Vector3, plane: int, spec: Resource, size: Vector3) -> Vector2:
	var metres := Vector2(point.x + size.x * 0.5, point.y + size.y * 0.5)
	if plane == 1:
		metres = Vector2(point.z + size.z * 0.5, point.y + size.y * 0.5)
	elif plane == 2:
		metres = Vector2(point.x + size.x * 0.5, point.z + size.z * 0.5)
	match int(spec.uv_quarter_turns):
		1:
			metres = Vector2(-metres.y, metres.x)
		2:
			metres = -metres
		3:
			metres = Vector2(metres.y, -metres.x)
	return metres + spec.uv_origin_m


func _collision_boxes(spec: Resource) -> Array:
	var boxes := []
	if spec.collision_policy == Spec.CollisionPolicy.NONE:
		return boxes
	if spec.recipe_id == "rect_solid":
		boxes.append({"center": Vector3.ZERO, "size": spec.dimensions_m})
		return boxes
	var grid := _wall_grid(spec)
	var xs: Array = grid["xs"]
	var ys: Array = grid["ys"]
	for ix in xs.size() - 1:
		var run_start := -1
		for iy in ys.size():
			var filled := iy < ys.size() - 1 and _occupied(ix, iy, xs, ys, spec)
			if filled and run_start < 0:
				run_start = iy
			elif not filled and run_start >= 0:
				var x0: float = xs[ix]
				var x1: float = xs[ix + 1]
				var y0: float = ys[run_start]
				var y1: float = ys[iy]
				boxes.append({"center": Vector3((x0 + x1) * 0.5, (y0 + y1) * 0.5, 0), "size": Vector3(x1 - x0, y1 - y0, spec.dimensions_m.z)})
				run_start = -1
	return boxes


func _fingerprint(mesh: ArrayMesh, spec: Resource, recipe_revision: int) -> String:
	var parts := PackedStringArray()
	parts.append("%s/%d/%d" % [spec.recipe_id, recipe_revision, spec.generation_revision])
	parts.append(JSON.stringify(spec.exact_parameters()))
	parts.append("%d/%.9f/%.9f" % [spec.uv_quarter_turns, spec.uv_origin_m.x, spec.uv_origin_m.y])
	var arrays := mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	for i in vertices.size():
		var v := vertices[i]
		var n := normals[i]
		var uv := uvs[i]
		parts.append("%.9f,%.9f,%.9f/%.9f,%.9f,%.9f/%.9f,%.9f" % [v.x,v.y,v.z,n.x,n.y,n.z,uv.x,uv.y])
	if indices.is_empty():
		for i in vertices.size():
			parts.append(str(i))
	else:
		for index in indices:
			parts.append(str(index))
	return ("|".join(parts)).sha256_text()
