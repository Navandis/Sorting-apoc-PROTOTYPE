extends SceneTree
const WING = "res://gameplay/logistics_wing/wing_gameplay.tscn"
const GUARD = "res://tools/asset_pipeline/tests/support/wear_branch_guard.gd"
const AUTHOR = preload("res://environment_authoring/wear/environment_wear_authoring.gd")
var failures := 0
var checks := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(message)
func run() -> void:
    var wing := load(WING).instantiate() as Node3D
    root.add_child(wing)
    await physics_frame
    await physics_frame
    var branch := wing.get_node_or_null("AuthoredWear")
    check(branch != null, "canonical wing has directly owned AuthoredWear")
    check(ResourceLoader.exists(GUARD), "narrow reusable wear guard exists")
    if branch != null and ResourceLoader.exists(GUARD):
        var guard := load(GUARD)
        check(branch.get_parent() == wing and branch.owner == wing and branch.transform == Transform3D.IDENTITY, "author root independent of gameplay actors")
        check(guard.validate(branch).is_empty(), "empty shipping branch valid")
        var a := AUTHOR.new()
        a.name = "UserPlacement"
        a.approved_source = "Road Dust | eaf4b_7efdf22029c82320d62147c7"
        branch.get_node("Receiving").add_child(a)
        a.owner = wing
        await process_frame
        await process_frame
        var b := a.duplicate()
        branch.get_node("Storage").add_child(b)
        b.owner = wing
        b.width_m = 2.1
        b.visible = false
        b.approved_source = "Concrete Crack | eaf4b_c3b63b5da3fbdda32be47bd0"
        await process_frame
        await process_frame
        check(guard.validate(branch).is_empty(), "approved source, duplicate, size and visibility valid")
        a.owner = null
        check(not guard.validate(branch).is_empty(), "reject helper not owned by wing scene")
        a.owner = wing
        b.reparent(branch.get_node("OtherRooms"))
        check(guard.validate(branch).is_empty(), "move between room groups valid")
        var new_room := Node3D.new()
        new_room.name = "FutureRoom"
        branch.add_child(new_room)
        new_room.owner = wing
        b.reparent(new_room)
        check(guard.validate(branch).is_empty(), "future room needs no hard-coded placement list")
        for forbidden in [Area3D.new(), StaticBody3D.new(), RigidBody3D.new(), CollisionShape3D.new(), OmniLight3D.new(), Camera3D.new(), MeshInstance3D.new()]:
            new_room.add_child(forbidden)
            forbidden.owner = wing
            var authority_errors: PackedStringArray = guard.validate(branch)
            check(not authority_errors.is_empty() and "only plain Node3D groups" in authority_errors[0], "reject authority type " + forbidden.get_class())
            forbidden.free()
        var scripted := Node3D.new()
        var arbitrary := GDScript.new()
        arbitrary.source_code = "extends Node3D\nfunc _ready(): pass\n"
        check(arbitrary.reload() == OK, "negative script compiles")
        scripted.set_script(arbitrary)
        a.add_child(scripted)
        check(not guard.validate(branch).is_empty(), "reject arbitrary script inside approved helper")
        scripted.free()
        var quad := a.get_node("Quad")
        quad.set_script(arbitrary)
        check(not guard.validate(branch).is_empty(), "reject script on generated mesh")
        quad.set_script(null)
        check(guard.validate(branch).is_empty(), "guard restored after negative probes")
        a.free()
        b.free()
        new_room.free()
    var finish := wing.get_node("ReceivingSetDressing/ReceivingDecals/ReceivingFinishPass")
    var signage := finish.get_node("ReceivingSignage")
    var legacy := finish.find_children("*", "EnvironmentWearOverlay", true, false)
    check(legacy.size() == 7, "seven original examples retained")
    var traffic := finish.get_node("ReceivingWear_Floor/Traffic_Approach")
    var original_size: Vector2 = traffic.spec.physical_size_m
    var original_opacity: float = traffic.spec.opacity_multiplier
    traffic.spec.physical_size_m = Vector2(0.71, 0.82)
    traffic.spec.opacity_multiplier = 0.12
    await process_frame
    await process_frame
    check(traffic.get_node("Quad").mesh.size == Vector2(0.71, 0.82), "existing Road Dust live dimension edit")
    check(is_equal_approx(traffic.get_node("Quad").material_override.get_shader_parameter("opacity_multiplier"), 0.12), "existing Road Dust live appearance edit")
    traffic.spec.physical_size_m = original_size
    traffic.spec.opacity_multiplier = original_opacity
    finish.get_node("ReceivingWear_Floor").hide()
    finish.get_node("ReceivingWear_LiftZone").hide()
    check(signage.is_visible_in_tree(), "hide wear preserves accepted signage")
    for helper in legacy:
        check(not helper.is_visible_in_tree() and helper.get_child_count() == 1, "legacy visibility and single geometry: " + str(helper.name))
    wing.free()
    print("wear_authoring_workspace_tests: %d checks, %d failures" % [checks, failures])
    quit(0 if failures == 0 else 1)
