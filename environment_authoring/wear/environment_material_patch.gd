@tool
class_name EnvironmentMaterialPatch
extends Node3D

const MaterialBuilder = preload("res://environment_authoring/environment_material_builder.gd")
const MaterialQuery = preload("res://environment_authoring/environment_material_catalog_query.gd")
const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")

enum Mode { EAF3_MATERIAL, EAF4_SOURCE }
@export var mode: Mode = Mode.EAF3_MATERIAL
@export var eaf3_material_id := ""
@export var wear_spec: EnvironmentWearOverlaySpec
@export var physical_size_m := Vector2(1.0, 1.0)
@export var surface_offset_m := 0.002

func _ready() -> void:
    regenerate()

func resolve_material() -> Material:
    if mode == Mode.EAF4_SOURCE:
        return Overlay.build_material(wear_spec) if wear_spec != null else null
    for entry in MaterialQuery.query():
        if entry.get("catalog_material_id") == eaf3_material_id:
            var path := "res://data/environment/material_catalog/approved_specs/%s.tres" % eaf3_material_id
            var spec := load(path) as Resource
            if spec != null:
                return MaterialBuilder.new().build(spec)
    return null

func regenerate() -> void:
    scale = Vector3.ONE
    var quad := get_node_or_null("PatchQuad") as MeshInstance3D
    if quad == null:
        quad = MeshInstance3D.new()
        quad.name = "PatchQuad"
        add_child(quad)
        if Engine.is_editor_hint():
            quad.owner = get_tree().edited_scene_root
    var material := resolve_material()
    quad.visible = material != null
    if material == null:
        return
    var mesh := QuadMesh.new()
    mesh.size = wear_spec.physical_size_m if mode == Mode.EAF4_SOURCE and wear_spec != null else physical_size_m
    quad.mesh = mesh
    quad.position = Vector3(0.0, 0.0, wear_spec.surface_offset_m if mode == Mode.EAF4_SOURCE and wear_spec != null else surface_offset_m)
    quad.material_override = material
    quad.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
