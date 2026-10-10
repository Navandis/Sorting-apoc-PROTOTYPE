extends SceneTree
# Temporary diagnostic placements in the canonical wing. GPU/runtime evidence,
# never editor interaction evidence or artistic approval. No scene saves.
const EXP = preload("res://environment_authoring/wear/imperfection_experiments/imperfection_audition.gd")
const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")
const OUT = "res://reports/environment_wear_catalog/imperfection_audition/"
var failures := 0
var checks := 0
var evidence: Array[Dictionary] = []
func _initialize() -> void: run.call_deferred()
func check(ok: bool, text: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(text)
func capture(label: String, node, surface: String, save := false) -> Image:
    for frame in 5: await process_frame
    await RenderingServer.frame_post_draw
    var img := root.get_texture().get_image()
    if save:
        check(img.save_png(OUT + label + ".png") == OK, "save diagnostic " + label)
        evidence.append({"file":label + ".png","kind":"OpenGL runtime diagnostic; NOT editor acceptance", "surface":surface,"source":node.source_id(),"channel":node.selected_candidate().get("channel"),"mode":node.preview_mode,"modulation_enabled":node.modulation_enabled,"wear_source":node.effect_id(),"repeat":[node.mask_repeat.x,node.mask_repeat.y],"rotation_degrees":node.mask_rotation_degrees,"contrast":node.scalar_contrast,"bias":node.scalar_bias,"invert":node.invert_scalar,"strength":node.mask_strength,"opacity":node.opacity_multiplier,"size_m":[node.width_m,node.height_m],"offset_m":node.surface_offset_m,"position":str(node.position),"rotation":str(node.rotation_degrees),"lighting":"canonical wing WorldEnvironment and fixtures unchanged"})
    return img
func differences(a: Image,b: Image) -> int:
    var count := 0
    # Centre ROI excludes unrelated moving/debug/CRT content.
    for y in range(120,360,2):
        for x in range(160,480,2):
            var d := a.get_pixel(x,y)-b.get_pixel(x,y)
            if absf(d.r)+absf(d.g)+absf(d.b) > 0.025: count += 1
    return count
func run() -> void:
    if DisplayServer.get_name() == "headless":
        push_error("Real Compatibility renderer required")
        quit(1)
        return
    root.size = Vector2i(640,480)
    var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
    wing.get_node("Player").set_physics_process(false)
    root.add_child(wing)
    for camera in wing.find_children("*","Camera3D",true,false): camera.current = false
    var camera := Camera3D.new()
    camera.fov = 50
    camera.near = 0.05
    wing.add_child(camera)
    camera.current = true
    var node = EXP.new()
    node.mask_source = "eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_tedxadjc:tedxadjc"
    node.width_m = 1.6
    node.height_m = 1.2
    node.surface_offset_m = 0.004
    node.opacity_multiplier = 0.65
    wing.get_node("ImperfectionExperiments").add_child(node)
    node.position = Vector3(-33.65,0,-0.2)
    node.rotation.x = -PI/2
    camera.position = Vector3(-33.65,2.7,1.5)
    camera.look_at(node.position,Vector3.UP)
    node.hide()
    var before = await capture("floor_00_room_before",node,"Receiving floor",true)
    node.show()
    var gray = await capture("floor_01_grayscale_roughness_red",node,"Receiving floor",true)
    check(differences(before,gray)>50,"floor diagnostic visible under actual lighting")
    node.invert_scalar = true
    var inverted = await capture("floor_02_grayscale_inverted",node,"Receiving floor",true)
    check(differences(gray,inverted)>50,"inversion changes scalar pattern")
    node.invert_scalar = false
    node.preview_mode = 1
    var tinted = await capture("floor_03_tinted_opacity_illustration",node,"Receiving floor",true)
    check(differences(gray,tinted)>50,"grayscale and illustrative opacity distinguishable")
    node.scalar_contrast = 2.5
    node.scalar_bias = -0.2
    node.mask_repeat = Vector2(2,2)
    node.mask_rotation_degrees = 35
    var adjusted = await capture("floor_04_adjusted_scalar_distribution",node,"Receiving floor",true)
    check(differences(tinted,adjusted)>50,"contrast bias repeat rotation visibly change distribution")
    # Modulation only uses the intended vertical-wall Leakage soft overlays.
    node.position = Vector3(-32.4,3.0,3.84)
    node.rotation = Vector3(0,PI,0)
    camera.position = Vector3(-32.4,3.0,0.6)
    camera.look_at(node.position,Vector3.UP)
    node.mask_repeat = Vector2.ONE
    node.mask_rotation_degrees = 0
    node.scalar_contrast = 1
    node.scalar_bias = 0
    node.preview_mode = 2
    node.modulation_enabled = false
    node.albedo_strength = 0.5
    for effect in EXP.effect_sources():
        node.wear_source = effect.id
        var unmasked = await capture("wall_" + effect.label + "_unmasked",node,"Receiving concrete wall",true)
        var quad = node.get_node("Quad")
        var experiment_material = quad.material_override
        quad.material_override = Overlay.build_material(node.effective_spec,false,false,false)
        var established = await capture("established_reference",node,"Receiving wall")
        check(differences(unmasked,established)<10,"experimental unmasked branch preserves established soft-overlay rendering: " + effect.label)
        quad.material_override = experiment_material
        node.modulation_enabled = true
        var masked = await capture("wall_" + effect.label + "_grunge_tedxadjc_masked",node,"Receiving concrete wall",true)
        var count := differences(unmasked,masked)
        check(count>50,"genuine Grunge opacity modulation " + effect.label)
        print("IMPERFECTION_RENDER effect=",effect.label," grunge_changed_samples=",count)
        node.modulation_enabled = false
    # Every actual candidate must produce deterministic masking, rather than a tint change.
    for source in EXP.candidates():
        node.mask_source = source.stable_id
        node.modulation_enabled = false
        var unmasked = await capture("baseline",node,"Receiving wall")
        node.modulation_enabled = true
        var masked = await capture("wall_candidate_" + source.slug,node,"Receiving wall",source.slug == "dust_uh4qbeic")
        var count := differences(unmasked,masked)
        check(count>20,"actual candidate scalar modulates wear " + source.slug)
        node.mask_strength = 0
        var zero = await capture("zero_strength",node,"Receiving wall")
        check(differences(unmasked,zero)<10,"zero strength matches unmasked " + source.slug)
        node.mask_strength = 1
        print("IMPERFECTION_RENDER candidate=",source.slug," channel=",source.channel," changed_samples=",count)
    var file := FileAccess.open(OUT + "render_evidence.json",FileAccess.WRITE)
    file.store_string(JSON.stringify(evidence,"  "))
    file.close()
    wing.free()
    for i in 2: await process_frame
    print("IMPERFECTION_RENDER checks=",checks," failures=",failures)
    quit(1 if failures else 0)
