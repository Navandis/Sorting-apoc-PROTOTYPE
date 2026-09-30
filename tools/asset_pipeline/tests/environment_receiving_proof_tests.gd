extends SceneTree

const SCENE := "res://gameplay/dev/environment_receiving_proof/environment_receiving_proof.tscn"
var failures: Array[String] = []

func _initialize() -> void:
    _run.call_deferred()

func _run() -> void:
    var packed := load(SCENE) as PackedScene
    _check(packed != null, "isolated proof scene loads")
    if packed == null:
        _finish()
        return
    var room := packed.instantiate() as Node3D
    root.add_child(room)
    await process_frame
    var generation: Array = room.call("generation_records")
    _check(generation.size() == 14, "exactly 14 EAF2 generated pieces")
    var recipes := {"rect_solid": 0, "wall_with_rect_opening": 0}
    for record in generation:
        var piece := room.get_node("Shell/" + record["piece_id"]) as Node3D
        _check(piece != null and piece.scale.is_equal_approx(Vector3.ONE), "unit root: " + record["piece_id"])
        _check(String(record["geometry_fingerprint"]).length() == 64, "fingerprint: " + record["piece_id"])
        _check(record["spec_errors"].is_empty(), "valid EAF2 spec: " + record["piece_id"])
        recipes[record["recipe_id"]] += 1
        _check(piece.get_meta("eaf2_generation")["generator_revision"] == EnvironmentSubstrateBuilder.GENERATOR_REVISION, "current on-demand EAF2 generation: " + record["piece_id"])
        var generated := piece.get_node("GeneratedMesh") as MeshInstance3D
        _check((generated.material_override as StandardMaterial3D).cull_mode == BaseMaterial3D.CULL_BACK, "ordinary back-face culling: " + record["piece_id"])
    _check(recipes == {"rect_solid": 13, "wall_with_rect_opening": 1}, "accepted recipe breakdown")
    for excluded in ["Floor_DispatchAnnex", "Ceiling_DispatchAnnex", "DispatchWest", "DispatchNorth", "DispatchEast"]:
        _check(room.get_node_or_null("Shell/" + excluded) == null, "Dispatch annex context excluded: " + excluded)
    _check((room.get_node("Shell/ReceivingSouth") as Node3D).get("piece_spec").concealed_faces == PackedStringArray(["POS_X"]), "internal butt cap omitted")
    var context: Array = room.call("review_context_inventory")
    _check(context.size() >= 4, "distant context and barrier are separate from EAF2 shell")
    for item in context:
        _check(item["scope"] == "CONTEXT_ONLY / REVIEW_ONLY", "context tag: " + item["name"])
    var sets: Dictionary = room.call("role_candidates")
    _check(sets["WALL_PRIMARY"].size() == 14, "14 current wall candidates")
    _check(sets["FLOOR_PRIMARY"].size() == 8, "8 current floor candidates")
    _check(sets["CEILING_PRIMARY"].size() == 11, "11 current ceiling candidates")
    var floor_id := "eaf3b_20c61bd1c85420be2f71a090"
    _check(room.call("set_review", "WALL_PRIMARY", floor_id), "wall candidate applies")
    _check(room.get_node("Shell/ReceivingSouth/GeneratedMesh").material_override.resource_name == floor_id, "wall switched")
    _check(room.get_node("Shell/Floor_ReceivingApron/GeneratedMesh").material_override.resource_name == "eaf5_review_control_only", "floor isolated")
    _check(room.get_node("Shell/FreightRear/GeneratedMesh").material_override.resource_name == floor_id, "freight recess wall receives wall candidate")
    _check(room.get_node("Shell/ReceivingWestNorthReturn/GeneratedMesh").material_override.resource_name == "eaf5_review_control_only", "unapproved reveal stays control")
    var bright_id := "eaf3b_39b926e570fb3824019aade2"
    _check(room.call("set_review", "WALL_PRIMARY", bright_id), "historical triplanar candidate applies")
    _check(room.get_node("Shell/ReceivingWestNorthReturn/GeneratedMesh").material_override.resource_name == bright_id, "approved reveal inherits wall candidate")
    _check(room.get_node("Shell/ReceivingEastOpeningWall/GeneratedMesh").material_override.resource_name == bright_id, "approved east composite inherits wall candidate")
    var review_spec: Resource = room.call("active_review_spec")
    var approved_spec: Resource = load("res://data/environment/material_catalog/approved_specs/" + bright_id + ".tres")
    _check(review_spec.mapping_mode == 0 and approved_spec.mapping_mode == 1, "transient UV clone leaves approved spec intact")
    for field in ["base_color_texture", "normal_texture", "roughness_texture", "metallic_texture", "ao_texture", "height_texture", "meters_per_repeat", "normal_y_flip", "normal_strength", "roughness_multiplier", "metallic_multiplier", "albedo_multiplier", "source_path", "material_id"]:
        _check(review_spec.get(field) == approved_spec.get(field), "UV clone preserves " + field)
    var pitted_id := "eaf3b_bd0940113f04f3d3784629e7"
    _check(room.call("set_review", "CEILING_PRIMARY", pitted_id), "second historical triplanar candidate applies")
    review_spec = room.call("active_review_spec")
    approved_spec = load("res://data/environment/material_catalog/approved_specs/" + pitted_id + ".tres")
    _check(review_spec.mapping_mode == 0 and approved_spec.mapping_mode == 1, "second UV clone leaves approved spec intact")
    for field in ["base_color_texture", "normal_texture", "roughness_texture", "metallic_texture", "ao_texture", "height_texture", "meters_per_repeat", "normal_y_flip", "normal_strength", "roughness_multiplier", "metallic_multiplier", "albedo_multiplier", "source_path", "material_id"]:
        _check(review_spec.get(field) == approved_spec.get(field), "second UV clone preserves " + field)
    var camera := room.call("get_camera", "EastApproachOverview") as Camera3D
    var original := camera.transform
    room.call("set_light_mode", "RECEIVING_TARGET")
    room.call("set_review", "FLOOR_PRIMARY", floor_id)
    _check(room.get_node("Shell/ReceivingSouth/GeneratedMesh").material_override.resource_name == "eaf5_review_control_only", "wall isolated during floor review")
    _check(room.get_node("Shell/Ceiling_ReceivingApron/GeneratedMesh").material_override.resource_name == "eaf5_review_control_only", "ceiling isolated during floor review")
    _check(room.get_node("Shell/Floor_FreightEnclosure/GeneratedMesh").material_override.resource_name == floor_id, "freight floor receives floor candidate")
    _check(room.get_node("ReviewContext/BacklogFloorContinuation").material_override.resource_name != floor_id, "review continuation stays neutral")
    _check(room.get_node("ReviewContext/DispatchFloorContinuation").material_override.resource_name != floor_id, "Dispatch continuation stays neutral")
    _check(room.call("set_review", "CEILING_PRIMARY", bright_id), "ceiling candidate applies")
    _check(room.get_node("Shell/Ceiling_FreightEnclosure/GeneratedMesh").material_override.resource_name == bright_id, "freight ceiling receives ceiling candidate")
    _check(room.get_node("Shell/Floor_FreightEnclosure/GeneratedMesh").material_override.resource_name == "eaf5_review_control_only", "freight floor stays controlled during ceiling review")
    _check(camera.transform == original, "camera locked across candidates")
    _check(room.get_node("NeutralLightingRig").visible == false and room.get_node("ReceivingTargetLightingRig").visible == true, "only light rig switches")
    _check(not room.get_node("NeutralLightingRig/WhiteEast").shadow_enabled and room.get_node("NeutralLightingRig/WhiteWest").shadow_enabled, "neutral distant spot avoids shell shadow acne while freight key keeps shadow")
    _check(not room.get_node("ReceivingTargetLightingRig/WarmEastGeneral").shadow_enabled and room.get_node("ReceivingTargetLightingRig/WarmWestTask").shadow_enabled, "receiving distant spot avoids shell shadow acne while task key keeps shadow")
    _finish()

func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)

func _finish() -> void:
    for failure in failures:
        push_error("EAF5_PASS3_FAIL " + failure)
    print("EAF5_PASS3_TESTS failures=", failures.size())
    quit(0 if failures.is_empty() else 1)
