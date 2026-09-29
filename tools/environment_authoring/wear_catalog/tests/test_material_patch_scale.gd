extends SceneTree

const Patch = preload("res://environment_authoring/wear/environment_material_patch.gd")
const FINISH_ID := "eaf3b_7b12b8b3a2e05c502801d22f"
const SOURCE_SPEC := preload("res://data/environment/wear_catalog/approved_specs/eaf4b_e890439d8e117d36ac05e55c.tres")
var failures: Array[String] = []

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    var patch := Patch.new()
    patch.mode = Patch.Mode.EAF3_MATERIAL
    patch.eaf3_material_id = FINISH_ID
    patch.surface_offset_m = 0.003
    root.add_child(patch)
    for size in [Vector2(1.5, 1.5), Vector2(3.0, 1.5), Vector2(4.2, 2.4)]:
        patch.physical_size_m = size
        patch.regenerate()
        var quad := patch.get_node("PatchQuad") as MeshInstance3D
        var bounds := _bounds(quad.mesh)
        _check(patch.scale == Vector3.ONE, "EAF3 root unit scale")
        _check(_mesh_size(quad.mesh).is_equal_approx(size), "EAF3 physical geometry " + str(size))
        _check(bounds.is_equal_approx(size), "EAF3 metre UV span " + str(size) + " got " + str(bounds))
        _check(_front_winding(quad.mesh), "EAF3 front winding matches Godot QuadMesh")
        _check(is_equal_approx(quad.position.z, 0.003), "EAF3 offset")
        _check(quad.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "EAF3 shadow off")
        var material := quad.material_override as StandardMaterial3D
        _check(material != null and is_equal_approx(material.uv1_scale.x, 1.0 / 1.5), "EAF3 builder scale")
        print("PATCH_SCALE size=", size, " uv_span=", bounds, " expected_repeats_x=", size.x / 1.5)
    patch.mode = Patch.Mode.EAF4_SOURCE
    patch.wear_spec = SOURCE_SPEC
    patch.regenerate()
    var source_quad := patch.get_node("PatchQuad") as MeshInstance3D
    _check(_bounds(source_quad.mesh).is_equal_approx(Vector2.ONE), "EAF4 source normalized UV span")
    _check(_mesh_size(source_quad.mesh).is_equal_approx(SOURCE_SPEC.physical_size_m), "EAF4 source geometry")
    _check(is_equal_approx(source_quad.position.z, SOURCE_SPEC.surface_offset_m), "EAF4 source offset")
    patch.free()
    for failure in failures:
        push_error("PATCH_SCALE_FAIL " + failure)
    print("PATCH_SCALE_TEST failures=", failures.size())
    quit(0 if failures.is_empty() else 1)

func _bounds(mesh: Mesh) -> Vector2:
    var uvs: PackedVector2Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_TEX_UV]
    var minimum := Vector2(INF, INF)
    var maximum := Vector2(-INF, -INF)
    for uv in uvs:
        minimum = minimum.min(uv)
        maximum = maximum.max(uv)
    return maximum - minimum

func _front_winding(mesh: Mesh) -> bool:
    var arrays := mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
    var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
    var ab := vertices[indices[1]] - vertices[indices[0]]
    var ac := vertices[indices[2]] - vertices[indices[0]]
    return ab.cross(ac).z < 0.0

func _mesh_size(mesh: Mesh) -> Vector2:
    var vertices: PackedVector3Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
    var minimum := Vector2(INF, INF)
    var maximum := Vector2(-INF, -INF)
    for vertex in vertices:
        minimum = minimum.min(Vector2(vertex.x, vertex.y))
        maximum = maximum.max(Vector2(vertex.x, vertex.y))
    return maximum - minimum

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
