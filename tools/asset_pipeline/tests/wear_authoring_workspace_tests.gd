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
    check(not wing.has_node("ReceivingSetDressing/ReceivingDecals/ReceivingFinishPass"), "seven rejected Codex examples retired")
    var signage := wing.get_node("ReceivingSetDressing/ReceivingDecals/ReceivingSignage")
    var label := signage.get_node("LiftEmergencyStopLabel") as MeshInstance3D
    check(label.is_visible_in_tree(), "accepted plaque effectively visible")
    check(label.mesh.size == Vector2(0.32, 0.14), "original plaque proportions")
    check(label.global_transform == Transform3D(Vector3(0,0,-1), Vector3(0,1,0), Vector3(1,0,0), Vector3(-35.8485,2.055,-2.1937)), "original exact plaque world placement")
    check(label.material_override.albedo_texture.resource_path == "res://data/environment/receiving_signage/lift_emergency_stop.svg" and is_equal_approx(label.material_override.roughness,0.86), "original SVG/material appearance")
    branch.hide()
    wing.get_node("ImperfectionExperiments").hide()
    check(label.is_visible_in_tree(), "hide authoring branches preserves visible plaque")
    wing.free()
    print("wear_authoring_workspace_tests: %d checks, %d failures" % [checks, failures])
    quit(0 if failures == 0 else 1)
