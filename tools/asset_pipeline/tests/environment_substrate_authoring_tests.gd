extends SceneTree

const SPEC := "res://environment_authoring/substrate/environment_substrate_piece_spec.gd"
const REGISTRY := "res://environment_authoring/substrate/environment_substrate_recipe_registry.gd"
const BUILDER := "res://environment_authoring/substrate/environment_substrate_builder.gd"
const PIECE := "res://environment_authoring/substrate/environment_substrate_piece.gd"
const MATERIAL := "res://data/environment/substrate/diagnostic_metre_grid.tres"

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var spec_script := load(SPEC) as GDScript
	var registry_script := load(REGISTRY) as GDScript
	var builder_script := load(BUILDER) as GDScript
	_check(spec_script != null and registry_script != null and builder_script != null, "substrate scripts load")
	if spec_script == null or registry_script == null or builder_script == null:
		_finish()
		return
	var builder: RefCounted = builder_script.new()
	_test_spec(spec_script, registry_script)
	_test_rect(spec_script, builder)
	_test_bevel(spec_script, builder)
	_test_opening(spec_script, builder)
	_test_extension(spec_script, builder)
	_test_uv2(spec_script, builder)
	_test_material_and_wrapper(spec_script)
	_test_review()
	_finish()


func _spec(script: GDScript, id: String, recipe: String, size: Vector3) -> Resource:
	var spec: Resource = script.new()
	spec.set("piece_id", id)
	spec.set("recipe_id", recipe)
	spec.set("semantic_role", "test")
	spec.set("dimensions_m", size)
	spec.set("material_spec", load(MATERIAL))
	return spec


func _test_spec(script: GDScript, registry: GDScript) -> void:
	var spec := _spec(script, "rect", "rect_solid", Vector3(2, 3, 0.3))
	_check((spec.call("validate") as PackedStringArray).is_empty(), "valid rectangular spec")
	_check((registry.new().call("recipe_ids") as PackedStringArray).size() == 3, "registry discovers three recipes")
	_check((registry.new().call("metadata", "rect_solid") as Dictionary).has("canonical_axes"), "registry exposes axes")
	spec.set("piece_id", "")
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "empty ID rejected")
	spec.set("piece_id", "rect")
	spec.set("recipe_id", "missing")
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "unknown recipe rejected")
	spec.set("recipe_id", "rect_solid")
	for size in [Vector3.ZERO, Vector3(-1, 1, 1), Vector3(INF, 1, 1)]:
		spec.set("dimensions_m", size)
		_check(not (spec.call("validate") as PackedStringArray).is_empty(), "invalid dimensions rejected")
	spec.set("dimensions_m", Vector3(2, 3, 0.3))
	spec.set("bevel_width_m", 0.16)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "oversized bevel rejected")
	spec.set("bevel_width_m", 0.08)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "nonconservative bevel rejected")
	spec.set("bevel_width_m", 0.0)
	spec.set("uv_quarter_turns", 4)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "invalid UV turns rejected")
	spec.set("uv_quarter_turns", 0)
	spec.set("collision_policy", 5)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "invalid collision policy rejected")
	spec.set("collision_policy", 0)
	spec.set("uv_origin_m", Vector2(NAN, 0))
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "nonfinite UV origin rejected")


func _test_rect(script: GDScript, builder: RefCounted) -> void:
	var spec := _spec(script, "short", "rect_solid", Vector3(2, 3, 0.3))
	var result := builder.call("build", spec) as Dictionary
	var mesh := result.get("mesh") as ArrayMesh
	_check(mesh != null, "rect mesh built")
	if mesh == null:
		return
	_check(_aabb_is(mesh.get_aabb(), Vector3(-1, -1.5, -0.15), Vector3(2, 3, 0.3)), "rect exact AABB")
	_check(_triangles_valid(mesh) and _closed(mesh), "rect closed, finite, nondegenerate, outward, tangent-bearing")
	_check(_face_uv_span(mesh, Vector3(0, 0, 1), 2.0, 3.0), "2 m face has 2 UV units")
	_check((result.get("collision_boxes") as Array).is_empty(), "NONE collision")
	var fingerprint := String(result.get("fingerprint"))
	_check(fingerprint.length() == 64 and fingerprint == String((builder.call("build", spec) as Dictionary).get("fingerprint")), "deterministic fingerprint")
	spec.set("dimensions_m", Vector3(7.35, 3, 0.3))
	var long_result := builder.call("build", spec) as Dictionary
	_check(_face_uv_span(long_result.get("mesh") as ArrayMesh, Vector3(0, 0, 1), 7.35, 3.0), "7.35 m face has 7.35 UV units")
	_check(String(long_result.get("fingerprint")) != fingerprint, "dimension changes fingerprint")
	spec.set("collision_policy", 1)
	_check(((builder.call("build", spec) as Dictionary).get("collision_boxes") as Array).size() == 1, "SIMPLE rect has one box")
	spec.set("uv_quarter_turns", 1)
	var turned := builder.call("build", spec) as Dictionary
	_check(String(turned.get("fingerprint")) != String(long_result.get("fingerprint")), "UV quarter turn deterministic change")
	var baseline_uv := _first_uv(long_result.get("mesh") as ArrayMesh)
	var turned_uv := _first_uv(turned.get("mesh") as ArrayMesh)
	_check(turned_uv.is_equal_approx(Vector2(-baseline_uv.y, baseline_uv.x)), "quarter turn rotates physical UV axes")
	spec.set("uv_origin_m", Vector2(0.25, 0.75))
	var shifted := builder.call("build", spec) as Dictionary
	_check(String(shifted.get("fingerprint")) != String(turned.get("fingerprint")), "UV phase deterministic change")
	_check((_first_uv(shifted.get("mesh") as ArrayMesh) - turned_uv).is_equal_approx(Vector2(0.25, 0.75)), "UV origin shifts phase by metres")


func _test_bevel(script: GDScript, builder: RefCounted) -> void:
	var spec := _spec(script, "bevel", "rect_solid", Vector3(0.5, 2.4, 0.5))
	spec.set("bevel_width_m", 0.04)
	var mesh := (builder.call("build", spec) as Dictionary).get("mesh") as ArrayMesh
	_check(mesh != null and _aabb_is(mesh.get_aabb(), Vector3(-0.25, -1.2, -0.25), Vector3(0.5, 2.4, 0.5)), "bevel preserves AABB")
	_check(mesh != null and _triangles_valid(mesh) and _closed(mesh), "bevel closed triangles valid")


func _test_opening(script: GDScript, builder: RefCounted) -> void:
	var spec := _spec(script, "opening", "wall_with_rect_opening", Vector3(5.5, 3.2, 0.3))
	spec.set("opening_width_m", 1.4)
	spec.set("opening_height_m", 2.2)
	spec.set("opening_offset_x_m", 0.45)
	spec.set("opening_bottom_m", 0.15)
	spec.set("collision_policy", 1)
	_check((spec.call("validate") as PackedStringArray).is_empty(), "asymmetric opening valid")
	var result := builder.call("build", spec) as Dictionary
	var mesh := result.get("mesh") as ArrayMesh
	_check(mesh != null and _aabb_is(mesh.get_aabb(), Vector3(-2.75, -1.6, -0.15), Vector3(5.5, 3.2, 0.3)), "opening outer AABB")
	_check(mesh != null and _triangles_valid(mesh) and _closed(mesh), "opening is closed thick solid")
	_check(mesh != null and _has_reveal(mesh, -0.25, 1.15, 0.75), "jamb and header reveals")
	_check((result.get("collision_boxes") as Array).size() == 4, "opening SIMPLE has four regions")
	spec.set("opening_offset_x_m", 2.2)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "out of bounds opening rejected")
	spec.set("opening_offset_x_m", 0.45)
	spec.set("opening_bottom_m", 0.0)
	_check(((builder.call("build", spec) as Dictionary).get("collision_boxes") as Array).size() == 3, "doorway omits sill")


func _test_extension(script: GDScript, builder: RefCounted) -> void:
	var spec := _spec(script, "two", "wall_with_two_rect_openings", Vector3(7, 3.2, 0.3))
	spec.set("opening_width_m", 1.0)
	spec.set("opening_height_m", 2.1)
	spec.set("opening_offset_x_m", -1.5)
	spec.set("second_opening_width_m", 1.2)
	spec.set("second_opening_height_m", 1.4)
	spec.set("second_opening_offset_x_m", 1.35)
	spec.set("second_opening_bottom_m", 0.8)
	spec.set("collision_policy", 1)
	_check((spec.call("validate") as PackedStringArray).is_empty(), "extension distinct sill heights valid")
	var result := builder.call("build", spec) as Dictionary
	var mesh := result.get("mesh") as ArrayMesh
	_check(mesh != null and _aabb_is(mesh.get_aabb(), Vector3(-3.5, -1.6, -0.15), Vector3(7, 3.2, 0.3)), "extension outer AABB")
	_check(mesh != null and _triangles_valid(mesh) and _closed(mesh), "extension closed continuous wall")
	_check((result.get("collision_boxes") as Array).size() >= 5, "extension SIMPLE regions")
	_check(String(result.get("fingerprint")) == String((builder.call("build", spec) as Dictionary).get("fingerprint")), "extension deterministic")
	spec.set("second_opening_offset_x_m", -0.8)
	_check(not (spec.call("validate") as PackedStringArray).is_empty(), "overlapping openings rejected")


func _test_uv2(script: GDScript, builder: RefCounted) -> void:
	var spec := _spec(script, "uv2_probe", "rect_solid", Vector3(2, 3, 0.3))
	var mesh := (builder.call("build", spec) as Dictionary).get("mesh") as ArrayMesh
	var error := mesh.lightmap_unwrap(Transform3D.IDENTITY, 0.05)
	_check(error == OK, "native Godot 4.7 lightmap unwrap succeeds")
	if error != OK:
		return
	var arrays := mesh.surface_get_arrays(0)
	var uv2 := arrays[Mesh.ARRAY_TEX_UV2] as PackedVector2Array
	var uv1 := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var spread := Vector2.ZERO
	if not uv2.is_empty():
		var minimum := Vector2(INF, INF)
		var maximum := Vector2(-INF, -INF)
		for uv in uv2:
			minimum = minimum.min(uv)
			maximum = maximum.max(uv)
		spread = maximum - minimum
	_check(uv2.size() == vertices.size() and spread.x > 0.01 and spread.y > 0.01, "UV2 exists and has nonzero 2D span")
	_check(uv1.size() == vertices.size() and _face_uv_span(mesh, Vector3(0, 0, 1), 2.0, 3.0), "UV2 unwrap preserves metre UV1 density")
	_check(_uv2_triangles_nondegenerate(mesh), "UV2 triangle islands are nondegenerate")


func _uv2_triangles_nondegenerate(mesh: ArrayMesh) -> bool:
	var arrays := mesh.surface_get_arrays(0)
	var uv2 := arrays[Mesh.ARRAY_TEX_UV2] as PackedVector2Array
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	var count := indices.size() if not indices.is_empty() else uv2.size()
	if count == 0 or count % 3 != 0:
		return false
	for triangle in count / 3:
		var i := triangle * 3
		var a := uv2[indices[i] if not indices.is_empty() else i]
		var b := uv2[indices[i + 1] if not indices.is_empty() else i + 1]
		var c := uv2[indices[i + 2] if not indices.is_empty() else i + 2]
		if absf((b - a).cross(c - a)) < 0.000000001:
			return false
	return true


func _test_material_and_wrapper(script: GDScript) -> void:
	var material_spec := load(MATERIAL) as Resource
	_check(material_spec != null and (material_spec.call("validate") as PackedStringArray).is_empty(), "diagnostic EAF1 spec validates")
	if material_spec == null:
		return
	var material_builder: RefCounted = load("res://environment_authoring/environment_material_builder.gd").new()
	for mode in [0, 1, 2]:
		material_spec.set("mapping_mode", mode)
		var material := material_builder.call("build", material_spec) as StandardMaterial3D
		_check(material != null and material.uv1_triplanar == (mode != 0) and material.uv1_world_triplanar == (mode == 2), "EAF1 mapping mode %d" % mode)
	material_spec.set("mapping_mode", 0)
	var piece_script := load(PIECE) as GDScript
	_check(piece_script != null, "wrapper script loads")
	if piece_script == null:
		return
	var piece := piece_script.new() as Node3D
	piece.set("piece_spec", _spec(script, "wrapper", "rect_solid", Vector3(2, 3, 0.3)))
	root.add_child(piece)
	_check(piece.scale.is_equal_approx(Vector3.ONE) and (piece.call("validate_authoring") as PackedStringArray).is_empty(), "wrapper unit-scale")
	_check(bool(piece.call("regenerate")), "wrapper regenerates")
	_check((piece.get_node("GeneratedMesh") as MeshInstance3D).material_override is StandardMaterial3D, "wrapper binds EAF1")
	piece.scale = Vector3(2, 1, 1)
	_check(not (piece.call("validate_authoring") as PackedStringArray).is_empty(), "non-unit scale caught")
	piece.queue_free()


func _test_review() -> void:
	for path in ["res://gameplay/dev/environment_substrate/environment_substrate_review.tscn", "res://gameplay/dev/environment_substrate/environment_substrate_review_capture.tscn"]:
		_check(load(path) is PackedScene, "review scene loads")
	for seed in ["wall_standard", "floor_slab", "ceiling_slab", "beam_standard", "column_standard", "threshold_standard", "opening_return_standard", "wall_opening_standard"]:
		var resource := load("res://data/environment/substrate/seed/%s.tres" % seed) as Resource
		_check(resource != null and (resource.call("validate") as PackedStringArray).is_empty(), "seed validates: %s" % seed)


func _first_uv(mesh: ArrayMesh) -> Vector2:
	return (mesh.surface_get_arrays(0)[Mesh.ARRAY_TEX_UV] as PackedVector2Array)[0]


func _aabb_is(actual: AABB, position: Vector3, size: Vector3) -> bool:
	return actual.position.is_equal_approx(position) and actual.size.is_equal_approx(size)


func _face_uv_span(mesh: ArrayMesh, normal: Vector3, u_span: float, v_span: float) -> bool:
	var arrays := mesh.surface_get_arrays(0)
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	for i in normals.size():
		if normals[i].dot(normal) > 0.99:
			minimum = minimum.min(uvs[i])
			maximum = maximum.max(uvs[i])
	return is_equal_approx(maximum.x - minimum.x, u_span) and is_equal_approx(maximum.y - minimum.y, v_span)


func _triangles_valid(mesh: ArrayMesh) -> bool:
	var arrays := mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var tangents := arrays[Mesh.ARRAY_TANGENT] as PackedFloat32Array
	if vertices.is_empty() or vertices.size() % 3 != 0 or normals.size() != vertices.size() or tangents.size() != vertices.size() * 4:
		return false
	for i in vertices.size():
		if not vertices[i].is_finite() or not normals[i].is_finite() or absf(normals[i].length() - 1.0) > 0.01 or not is_finite(tangents[i * 4]):
			return false
	for t in vertices.size() / 3:
		var i := t * 3
		var cross := (vertices[i + 1] - vertices[i]).cross(vertices[i + 2] - vertices[i])
		if cross.length_squared() < 0.00000001 or cross.normalized().dot(normals[i]) < 0.99:
			return false
	return true


func _closed(mesh: ArrayMesh) -> bool:
	var vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var edges := {}
	for t in vertices.size() / 3:
		for e in 3:
			var a := vertices[t * 3 + e]
			var b := vertices[t * 3 + (e + 1) % 3]
			var ka := "%0.5f,%0.5f,%0.5f" % [a.x, a.y, a.z]
			var kb := "%0.5f,%0.5f,%0.5f" % [b.x, b.y, b.z]
			var key := ka + "|" + kb if ka < kb else kb + "|" + ka
			edges[key] = int(edges.get(key, 0)) + 1
	for key in edges.keys():
		if int(edges[key]) != 2:
			print("OPEN_EDGE ", key, " count=", edges[key])
			return false
	return true


func _has_reveal(mesh: ArrayMesh, left: float, right: float, top: float) -> bool:
	var arrays := mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var found := [false, false, false]
	for i in vertices.size():
		if absf(vertices[i].x - left) < 0.001 and absf(normals[i].x) > 0.99:
			found[0] = true
		if absf(vertices[i].x - right) < 0.001 and absf(normals[i].x) > 0.99:
			found[1] = true
		if absf(vertices[i].y - top) < 0.001 and absf(normals[i].y) > 0.99:
			found[2] = true
	return found[0] and found[1] and found[2]


func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		print("FAIL: ", label)
		failures.append(label)


func _finish() -> void:
	print("EAF2_TESTS failures=", failures.size())
	quit(0 if failures.is_empty() else 1)
