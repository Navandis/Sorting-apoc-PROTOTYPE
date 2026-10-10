extends SceneTree
# Real Compatibility renderer proof in the actual wing world. Temporary in-memory
# placements only; no canonical scene/resource is saved. This is NOT editor UI evidence.
const WING = "res://gameplay/logistics_wing/wing_gameplay.tscn"
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)
func frame_image() -> Image:
    for frame in 5: await process_frame
    await RenderingServer.frame_post_draw
    return root.get_texture().get_image()
func changed_pixels(a: Image, b: Image) -> int:
    var count := 0
    for y in range(0, a.get_height(), 2):
        for x in range(0, a.get_width(), 2):
            var delta := a.get_pixel(x, y) - b.get_pixel(x, y)
            if absf(delta.r) + absf(delta.g) + absf(delta.b) > 0.05:
                count += 1
    return count
func run() -> void:
    check(DisplayServer.get_name() != "headless", "real renderer required")
    if DisplayServer.get_name() == "headless":
        quit(1)
        return
    root.size = Vector2i(640, 480)
    var wing: Node3D = load(WING).instantiate()
    wing.get_node("Player").set_physics_process(false)
    root.add_child(wing)
    for camera in wing.find_children("*", "Camera3D", true, false):
        camera.current = false
    wing.get_node("AuthoredWear").hide()
    wing.get_node("ImperfectionExperiments").hide()
    check(wing.get_node("ReceivingSetDressing/ReceivingDecals/ReceivingSignage").is_visible_in_tree(), "runtime hide wear keeps label")
    var camera := Camera3D.new()
    camera.fov = 50
    camera.near = 0.05
    wing.add_child(camera)
    camera.current = true
    var cases := [
        {"path":"res://environment_authoring/wear/presets/oil_stain_semlsbi.tscn", "position":Vector3(-33.65, 0, -0.2), "camera":Vector3(-33.65, 2.7, 1.5), "wall":false},
        {"path":"res://environment_authoring/wear/presets/chipped_paint_patch_ui2ncdjfw.tscn", "position":Vector3(-32.4, 1.7, 3.84), "camera":Vector3(-32.4, 1.7, 0.6), "wall":true}
    ]
    for entry in cases:
        var helper := (load(entry["path"]) as PackedScene).instantiate()
        wing.add_child(helper) # Temporary diagnostic; saved art branches stay hidden in memory.
        helper.position = entry["position"]
        if entry["wall"]: helper.rotation.y = PI
        helper.width_m = 1.6
        helper.height_m = 1.2
        helper.albedo_strength = 0.0
        helper.albedo_tint = Color(0.1, 1.0, 0.15)
        helper.opacity_multiplier = 0.0
        camera.position = entry["camera"]
        camera.look_at(helper.position, Vector3.UP)
        var before: Image = await frame_image()
        helper.opacity_multiplier = 1.0
        var after: Image = await frame_image()
        var difference := changed_pixels(before, after)
        check(difference > 50, str(helper.name) + " edited patch visibly renders in actual wing environment")
        check(helper.get_child_count() == 1, "runtime has one generated quad")
        print("WEAR_RENDER ", helper.name, " image=", after.get_size(), " changed_samples=", difference)
        helper.free()
    wing.free()
    await process_frame
    await process_frame
    print("test_wear_presets_render: ", failures, " failures")
    # Let the suspended test function release temporary loaded scenes/images.
    _finish_test.call_deferred()

func _finish_test() -> void:
    quit(0 if failures == 0 else 1)
