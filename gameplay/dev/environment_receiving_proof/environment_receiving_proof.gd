extends Node3D

const Query = preload("res://environment_authoring/environment_material_catalog_query.gd")
const MaterialBuilder = preload("res://environment_authoring/environment_material_builder.gd")
const Piece = preload("res://environment_authoring/substrate/environment_substrate_piece.gd")
const CONTROL = preload("res://data/environment/receiving_proof/eaf5_review_control.tres")
const SOURCE := "res://data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json"
const HISTORICAL_SOURCE := "res://data/environment/receiving_proof/eaf5_receiving_shell_source.json"
const SPECS := "res://data/environment/receiving_proof/substrate/"
const WALL_FAMILIES := ["structural_concrete", "rough_poured_concrete", "service_floor_concrete"]
const CEILING_FAMILIES := ["structural_concrete", "rough_poured_concrete"]
const LIGHT_MODES := ["NEUTRAL_ARCHITECTURAL", "RECEIVING_TARGET"]
const CAMERA_NAMES := ["EastApproachOverview", "FreightAperture", "FreightRecess", "EastOpening", "DispatchOpening", "UpperCeilingContext", "WallDominant", "FloorRead", "CeilingRead", "JoinAudit_Apron", "JoinAudit_Freight", "JoinAudit_Dispatch"]

var _source: Dictionary = {}
var _historical_source: Dictionary = {}
var _pieces: Dictionary = {}
var _candidates: Dictionary = {}
var _active_spec: EnvironmentSurfaceMaterialSpec
var _active_record: Dictionary = {}
var _active_role := ""
var _light_mode := "NEUTRAL_ARCHITECTURAL"
var _builder := MaterialBuilder.new()
var _control_material: StandardMaterial3D

func _ready() -> void:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SOURCE))
    if not parsed is Dictionary:
        push_error("EAF5 shell source is invalid")
        return
    _source = parsed
    var historical: Variant = JSON.parse_string(FileAccess.get_file_as_string(HISTORICAL_SOURCE))
    if not historical is Dictionary or String(_source.get("source_manifest_sha256", "")) != FileAccess.get_sha256(HISTORICAL_SOURCE):
        push_error("EAF5 proof composition has stale historical source")
        return
    _historical_source = historical
    _control_material = _builder.build(CONTROL)
    _build_shell()
    _build_context()
    _configure_environment()
    _configure_cameras()
    _configure_lights()
    _query_candidates()
    set_light_mode("NEUTRAL_ARCHITECTURAL")
    set_control()

func _build_shell() -> void:
    for source_piece in _source["eaf2_recipe_mapping"]:
        var piece_id := String(source_piece["piece_id"])
        var spec := load(SPECS + piece_id + ".tres") as EnvironmentSubstratePieceSpec
        if spec == null or not spec.validate().is_empty():
            push_error("EAF5 invalid/missing EAF2 spec: " + piece_id)
            continue
        var node := Piece.new() as EnvironmentSubstratePiece
        node.name = piece_id
        node.piece_spec = spec
        node.position = _vec3(source_piece["center_local_m"])
        node.rotation_degrees.y = float(source_piece["rotation_y_degrees"])
        get_node("Shell").add_child(node)
        if not node.regenerate():
            continue
        node.add_to_group(spec.semantic_role)
        _pieces[piece_id] = node

func _build_context() -> void:
    var dark := StandardMaterial3D.new()
    dark.albedo_color = Color(0.10, 0.11, 0.12)
    dark.roughness = 0.8
    for box in _historical_source["freight_barrier_context"]["source_elements"]:
        _add_context_box("BarrierProxy_" + String(box["id"]), _vec3(box["saved_box_dimensions_m"]), _vec3(box["center_local_m"]), dark)
    # Oversized, distant review-only backdrops have no edge in either opening.
    var backdrop := StandardMaterial3D.new()
    backdrop.albedo_color = Color(0.18, 0.19, 0.21)
    backdrop.roughness = 0.9
    backdrop.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    _add_context_box("BacklogDarkDistance", Vector3(0.05, 20.0, 30.0), Vector3(15.0, 2.1, 0.0), backdrop)
    _add_context_box("DispatchDarkDistance", Vector3(30.0, 20.0, 0.05), Vector3(6.0, 2.1, -12.0), backdrop)
    var distant_floor := StandardMaterial3D.new()
    distant_floor.albedo_color = Color(0.28, 0.29, 0.30)
    distant_floor.roughness = 0.9
    _add_context_plane("BacklogFloorContinuation", Vector2(4.8, 10.0), Vector3(12.6, -0.003, 0.0), distant_floor)
    _add_context_plane("DispatchFloorContinuation", Vector2(10.0, 7.3), Vector3(6.0, -0.003, -8.35), distant_floor)

func _add_context_box(box_name: String, size: Vector3, location: Vector3, material: Material) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    var node := MeshInstance3D.new()
    node.name = box_name
    node.mesh = mesh
    node.position = location
    node.material_override = material
    node.set_meta("scope", "CONTEXT_ONLY / REVIEW_ONLY")
    get_node("ReviewContext").add_child(node)

func _add_context_plane(plane_name: String, size: Vector2, location: Vector3, material: Material) -> void:
    var mesh := PlaneMesh.new()
    mesh.size = size
    var node := MeshInstance3D.new()
    node.name = plane_name
    node.mesh = mesh
    node.position = location
    node.material_override = material
    node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    node.set_meta("scope", "CONTEXT_ONLY / REVIEW_ONLY")
    get_node("ReviewContext").add_child(node)

func review_context_inventory() -> Array:
    var result := []
    for child in get_node("ReviewContext").get_children():
        var mesh := (child as MeshInstance3D).mesh
        var size: Array = []
        if mesh is BoxMesh:
            size = _array3((mesh as BoxMesh).size)
        elif mesh is PlaneMesh:
            var plane_size := (mesh as PlaneMesh).size
            size = [plane_size.x, plane_size.y]
        result.append({"name": child.name, "scope": child.get_meta("scope"), "position_local_m": _array3(child.position), "size_m": size})
    return result

func _configure_environment() -> void:
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.052, 0.056, 0.06)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.74, 0.75, 0.76)
    environment.ambient_light_energy = 0.16
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.tonemap_exposure = 1.0
    (get_node("WorldEnvironment") as WorldEnvironment).environment = environment

func _configure_cameras() -> void:
    _camera("EastApproachOverview", Vector3(8.0, 2.5, 3.5), Vector3(0.0, 1.8, 0.0), 75.0)
    _camera("FreightAperture", Vector3(4.2, 2.0, 0.3), Vector3(-2.0, 1.8, 0.0), 72.0)
    _camera("FreightRecess", Vector3(-3.8, 2.15, 2.0), Vector3(0.2, 2.0, 0.0), 75.0)
    _camera("EastOpening", Vector3(6.7, 2.0, 0.5), Vector3(10.5, 1.8, 0.0), 70.0)
    _camera("DispatchOpening", Vector3(5.0, 2.0, -0.7), Vector3(6.0, 1.9, -5.0), 70.0)
    _camera("UpperCeilingContext", Vector3(5.0, 1.35, 3.7), Vector3(3.7, 4.2, -0.2), 72.0)
    _camera("WallDominant", Vector3(8.3, 1.95, -2.0), Vector3(1.4, 2.0, 3.8), 70.0)
    _camera("FloorRead", Vector3(7.0, 1.35, 3.7), Vector3(3.0, 0.0, -1.2), 73.0)
    _camera("CeilingRead", Vector3(7.0, 1.7, 3.3), Vector3(3.0, 4.2, -1.2), 72.0)
    _camera("JoinAudit_Apron", Vector3(7.6, 1.55, 1.2), Vector3(10.2, 1.9, 4.7), 60.0)
    _camera("JoinAudit_Freight", Vector3(-2.5, 1.7, 0.2), Vector3(-0.1, 1.9, 3.35), 65.0)
    _camera("JoinAudit_Dispatch", Vector3(6.0, 1.6, -2.5), Vector3(6.0, 1.9, -5.1), 63.0)

func _camera(camera_name: String, location: Vector3, target: Vector3, fov: float) -> void:
    var camera := get_camera(camera_name)
    camera.position = location
    camera.fov = fov
    camera.look_at(target, Vector3.UP)

func get_camera(camera_name: String) -> Camera3D:
    if camera_name not in CAMERA_NAMES:
        return null
    return get_node("Cameras/" + camera_name) as Camera3D

func set_camera(camera_name: String) -> bool:
    var camera := get_camera(camera_name)
    if camera == null:
        return false
    camera.make_current()
    return true

func _configure_lights() -> void:
    # In the closed 10.5 m shell the EAF1-sized local spots attenuate before
    # reaching large planes. Fixed unshadowed directional fill exposes the
    # architecture; bounded task spots retain local shadow cues.
    _directional("NeutralLightingRig", "WhiteUpperBounce", Vector3(1.0, -1.0, 0.4), Color.WHITE, 0.8)
    _directional("NeutralLightingRig", "WhiteLowerBounce", Vector3(-0.5, 1.0, -0.4), Color.WHITE, 0.9)
    _directional("ReceivingTargetLightingRig", "WarmUpperBounce", Vector3(1.0, -1.0, 0.4), Color(1.0, 0.86, 0.74), 0.70)
    _directional("ReceivingTargetLightingRig", "NeutralLowerBounce", Vector3(-0.5, 1.0, -0.4), Color(0.93, 0.94, 1.0), 0.70)
    _spot("NeutralLightingRig", "WhiteWest", Vector3(2.0, 3.65, 0.0), Vector3(-2.6, 1.5, 0.0), Color.WHITE, 1.1, 11.0, 72.0)
    _spot("NeutralLightingRig", "WhiteEast", Vector3(8.1, 3.65, 0.0), Vector3(5.0, 1.2, 0.0), Color.WHITE, 1.05, 10.5, 72.0, false)
    _omni("NeutralLightingRig", "WhiteFloorFill", Vector3(4.0, 2.75, -1.5), Color.WHITE, 0.45, 9.0)
    _spot("ReceivingTargetLightingRig", "WarmWestTask", Vector3(1.7, 3.55, 0.0), Vector3(-2.3, 1.2, 0.0), Color(1.0, 0.83, 0.69), 1.65, 10.0, 65.0)
    _spot("ReceivingTargetLightingRig", "WarmEastGeneral", Vector3(8.0, 3.55, 0.0), Vector3(4.3, 1.3, 0.0), Color(1.0, 0.91, 0.82), 1.2, 10.5, 72.0, false)
    _omni("ReceivingTargetLightingRig", "NeutralSupport", Vector3(4.5, 2.9, -2.0), Color(0.93, 0.94, 1.0), 0.35, 8.0)

func _directional(rig_name: String, light_name: String, target: Vector3, color: Color, energy: float) -> void:
    var light := DirectionalLight3D.new()
    light.name = light_name
    light.light_color = color
    light.light_energy = energy
    light.shadow_enabled = false
    get_node(rig_name).add_child(light)
    light.look_at(target, Vector3.UP)

func _spot(rig_name: String, light_name: String, location: Vector3, target: Vector3, color: Color, energy: float, range_m: float, angle: float, casts_shadow: bool = true) -> void:
    var light := SpotLight3D.new()
    light.name = light_name
    light.position = location
    light.light_color = color
    light.light_energy = energy
    light.spot_range = range_m
    light.spot_angle = angle
    light.shadow_enabled = casts_shadow
    get_node(rig_name).add_child(light)
    light.look_at(target, Vector3.UP)

func _omni(rig_name: String, light_name: String, location: Vector3, color: Color, energy: float, range_m: float) -> void:
    var light := OmniLight3D.new()
    light.name = light_name
    light.position = location
    light.light_color = color
    light.light_energy = energy
    light.omni_range = range_m
    get_node(rig_name).add_child(light)

func set_light_mode(mode: String) -> bool:
    if mode not in LIGHT_MODES:
        return false
    _light_mode = mode
    for rig_name in ["NeutralLightingRig", "ReceivingTargetLightingRig"]:
        var rig := get_node(rig_name) as Node3D
        rig.visible = (mode == "NEUTRAL_ARCHITECTURAL") == (rig_name == "NeutralLightingRig")
        for child in rig.get_children():
            (child as Light3D).visible = rig.visible
    return true

func light_mode() -> String:
    return _light_mode

func light_settings() -> Array:
    var rig_name := "NeutralLightingRig" if _light_mode == "NEUTRAL_ARCHITECTURAL" else "ReceivingTargetLightingRig"
    var settings := []
    for child in get_node(rig_name).get_children():
        var light := child as Light3D
        var item := {"name": light.name, "type": light.get_class(), "position": _array3(light.position), "color": light.light_color.to_html(), "energy": light.light_energy, "shadow": light.shadow_enabled}
        if light is SpotLight3D:
            item["range"] = light.spot_range
            item["angle"] = light.spot_angle
            item["direction"] = _array3(-light.global_transform.basis.z.normalized())
        elif light is OmniLight3D:
            item["range"] = (light as OmniLight3D).omni_range
        else:
            item["direction"] = _array3(-light.global_transform.basis.z.normalized())
        settings.append(item)
    return settings

func _query_candidates() -> void:
    _candidates = {"WALL_PRIMARY": [], "FLOOR_PRIMARY": [], "CEILING_PRIMARY": []}
    for record in Query.query("", "structural_substrate", "wall"):
        if String(record["surface_family"]) in WALL_FAMILIES:
            _candidates["WALL_PRIMARY"].append(record)
    for record in Query.query("service_floor_concrete", "structural_substrate", "floor"):
        _candidates["FLOOR_PRIMARY"].append(record)
    for record in Query.query("", "structural_substrate", "ceiling"):
        if String(record["surface_family"]) in CEILING_FAMILIES:
            _candidates["CEILING_PRIMARY"].append(record)
    for role in _candidates:
        _candidates[role].sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a["catalog_material_id"]) < String(b["catalog_material_id"]))

func role_candidates() -> Dictionary:
    return _candidates.duplicate(true)

func later_inventory() -> Dictionary:
    var inventory := {"structural_secondary": [], "applied_finish": []}
    for record in Query.query():
        if record["vdd_layer"] == "applied_finish" and record["surface_family"] in ["cement_render", "applied_paint"]:
            inventory["applied_finish"].append(record)
        elif record["surface_family"] == "masonry_block" or "panel" in String(record["display_name"]).to_lower() or "reinforced" in String(record["display_name"]).to_lower():
            inventory["structural_secondary"].append(record)
    return inventory

func set_control() -> void:
    _active_role = ""
    _active_record = {}
    _active_spec = null
    for piece in _pieces.values():
        (piece.get_node("GeneratedMesh") as MeshInstance3D).material_override = _control_material

func set_review(role: String, catalog_material_id: String) -> bool:
    if not _candidates.has(role):
        return false
    var record: Dictionary = {}
    for candidate in _candidates[role]:
        if candidate["catalog_material_id"] == catalog_material_id:
            record = candidate
            break
    if record.is_empty():
        return false
    var approved := load("res://data/environment/material_catalog/approved_specs/" + catalog_material_id + ".tres") as EnvironmentSurfaceMaterialSpec
    if approved == null or not approved.validate().is_empty() or approved.material_id != catalog_material_id:
        return false
    var review: EnvironmentSurfaceMaterialSpec = approved
    if approved.mapping_mode != EnvironmentSurfaceMaterialSpec.MappingMode.UV:
        review = approved.duplicate(false) as EnvironmentSurfaceMaterialSpec
        review.mapping_mode = EnvironmentSurfaceMaterialSpec.MappingMode.UV
    var material := _builder.build(review)
    if material == null:
        return false
    set_control()
    _active_role = role
    _active_record = record
    _active_spec = review
    var allow_reveal: bool = "opening_reveal" in record["approved_roles"]
    for piece in _pieces.values():
        var semantic: String = piece.piece_spec.semantic_role
        var active := semantic == role or (role == "WALL_PRIMARY" and semantic == "FREIGHT_RECESS_WALL")
        if role == "WALL_PRIMARY" and semantic == "OPENING_REVEAL":
            active = allow_reveal
        # The one EAF2 east-opening mesh owns both piers and reveals. Keep all
        # on control when reveal approval is absent; never assign candidate to an unapproved reveal.
        if role == "WALL_PRIMARY" and piece.name == "ReceivingEastOpeningWall" and not allow_reveal:
            active = false
        if active:
            (piece.get_node("GeneratedMesh") as MeshInstance3D).material_override = material
    return true

func set_wall_floor_pair(wall_id: String, floor_id: String) -> bool:
    if wall_id == floor_id:
        return false
    var wall_record: Dictionary = {}
    var floor_record: Dictionary = {}
    for candidate in _candidates["WALL_PRIMARY"]:
        if candidate["catalog_material_id"] == wall_id:
            wall_record = candidate
            break
    for candidate in _candidates["FLOOR_PRIMARY"]:
        if candidate["catalog_material_id"] == floor_id:
            floor_record = candidate
            break
    if wall_record.is_empty() or floor_record.is_empty() or wall_record["mapping_mode"] != "UV" or floor_record["mapping_mode"] != "UV":
        return false
    if not set_review("WALL_PRIMARY", wall_id):
        return false
    var floor_spec := load("res://data/environment/material_catalog/approved_specs/" + floor_id + ".tres") as EnvironmentSurfaceMaterialSpec
    if floor_spec == null or floor_spec.material_id != floor_id or not floor_spec.validate().is_empty() or floor_spec.mapping_mode != EnvironmentSurfaceMaterialSpec.MappingMode.UV:
        set_control()
        return false
    var floor_material := _builder.build(floor_spec)
    if floor_material == null:
        set_control()
        return false
    for piece in _pieces.values():
        if piece.piece_spec.semantic_role == "FLOOR_PRIMARY":
            (piece.get_node("GeneratedMesh") as MeshInstance3D).material_override = floor_material
    return true

func set_structural_palette(wall_id: String, floor_id: String, ceiling_id: String) -> bool:
    var ceiling_record: Dictionary = {}
    for candidate in _candidates["CEILING_PRIMARY"]:
        if candidate["catalog_material_id"] == ceiling_id:
            ceiling_record = candidate
            break
    if ceiling_record.is_empty() or ceiling_record["mapping_mode"] != "UV":
        return false
    var ceiling_spec := load("res://data/environment/material_catalog/approved_specs/" + ceiling_id + ".tres") as EnvironmentSurfaceMaterialSpec
    if ceiling_spec == null or ceiling_spec.material_id != ceiling_id or not ceiling_spec.validate().is_empty() or ceiling_spec.mapping_mode != EnvironmentSurfaceMaterialSpec.MappingMode.UV:
        return false
    if not set_wall_floor_pair(wall_id, floor_id):
        return false
    var ceiling_material := _builder.build(ceiling_spec)
    if ceiling_material == null:
        set_control()
        return false
    for piece in _pieces.values():
        if piece.piece_spec.semantic_role == "CEILING_PRIMARY":
            (piece.get_node("GeneratedMesh") as MeshInstance3D).material_override = ceiling_material
    return true
func active_review_spec() -> EnvironmentSurfaceMaterialSpec:
    return _active_spec

func active_record() -> Dictionary:
    return _active_record.duplicate(true)

func active_role() -> String:
    return _active_role

func generation_records() -> Array:
    var result := []
    for piece_id in _pieces.keys():
        var piece := _pieces[piece_id] as EnvironmentSubstratePiece
        var item: Dictionary = piece.generation_metadata.duplicate(true)
        item["position_local_m"] = _array3(piece.position)
        item["rotation_y_degrees"] = piece.rotation_degrees.y
        item["root_scale"] = _array3(piece.scale)
        item["spec_errors"] = Array(piece.piece_spec.validate())
        result.append(item)
    result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return String(a["piece_id"]) < String(b["piece_id"]))
    return result

func shell_source_sha256() -> String:
    return FileAccess.get_sha256(HISTORICAL_SOURCE)

func proof_composition_sha256() -> String:
    return FileAccess.get_sha256(SOURCE)

func set_join_debug_colors() -> void:
    var colors := [
        Color(0.83, 0.43, 0.34), Color(0.38, 0.69, 0.86), Color(0.78, 0.72, 0.36),
        Color(0.49, 0.79, 0.59), Color(0.72, 0.49, 0.82), Color(0.91, 0.61, 0.35)
    ]
    var ids := _pieces.keys()
    ids.sort()
    for index in ids.size():
        var debug := StandardMaterial3D.new()
        debug.albedo_color = colors[index % colors.size()]
        debug.roughness = 0.9
        var piece := _pieces[ids[index]] as EnvironmentSubstratePiece
        (piece.get_node("GeneratedMesh") as MeshInstance3D).material_override = debug

func _vec3(values: Array) -> Vector3:
    return Vector3(float(values[0]), float(values[1]), float(values[2]))

func _array3(value: Vector3) -> Array:
    return [value.x, value.y, value.z]
