extends SceneTree
const WING = "res://gameplay/logistics_wing/wing_gameplay.tscn"
const GUARD = "res://tools/asset_pipeline/tests/support/wear_branch_guard.gd"
const EXP = preload("res://environment_authoring/wear/imperfection_experiments/imperfection_audition.gd")
const AUTHOR = preload("res://environment_authoring/wear/environment_wear_authoring.gd")
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, text: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error(text)
func run() -> void:
    var wing = load(WING).instantiate()
    root.add_child(wing)
    await process_frame
    await process_frame
    var branch = wing.get_node_or_null("ImperfectionExperiments")
    check(branch != null, "explicit experimental wing group exists")
    var guard = load(GUARD)
    check(guard.has_method("validate_experiments"), "separate branch specific guard")
    if branch == null or not guard.has_method("validate_experiments"):
        wing.free()
        quit(1)
        return
    check(branch.owner == wing and branch.get_parent() == wing and branch.transform == Transform3D.IDENTITY and guard.validate_experiments(branch).is_empty(), "scene-owned branch permits valid saved authoring instances")
    var a = EXP.new()
    a.mask_source = EXP.candidates()[0].stable_id
    branch.add_child(a)
    a.owner = wing
    await process_frame
    await process_frame
    check(guard.validate_experiments(branch).is_empty(), "exact helper valid in experiment branch")
    check(not guard.validate(branch).is_empty(), "approved guard rejects experimental script")
    a.owner = null
    check(not guard.validate_experiments(branch).is_empty(), "reject wrong scene ownership")
    a.owner = wing
    for forbidden in [Area3D.new(),StaticBody3D.new(),RigidBody3D.new(),CollisionShape3D.new(),OmniLight3D.new(),Camera3D.new(),MeshInstance3D.new()]:
        branch.add_child(forbidden)
        forbidden.owner = wing
        check(not guard.validate_experiments(branch).is_empty(), "reject experiment authority " + forbidden.get_class())
        forbidden.free()
    # A Node3D script can legally attach to native Node3D subclasses; script
    # identity alone must not grant a camera/light/body authoring authority.
    for authority in [Camera3D.new(),OmniLight3D.new(),StaticBody3D.new()]:
        authority.set_script(EXP)
        authority.mask_source = EXP.candidates()[0].stable_id
        branch.add_child(authority)
        authority.owner = wing
        await process_frame
        await process_frame
        check(authority.get_child_count() == 1 and authority._get_configuration_warnings().is_empty(), "scripted authority probe is otherwise valid")
        check(not guard.validate_experiments(branch).is_empty(), "reject allowed experiment script on native " + authority.get_class())
        authority.free()
    var approved_branch = wing.get_node("AuthoredWear/Receiving")
    var approved_camera := Camera3D.new()
    approved_camera.set_script(AUTHOR)
    approved_camera.approved_source = "eaf4b_7efdf22029c82320d62147c7"
    approved_branch.add_child(approved_camera)
    approved_camera.owner = wing
    await process_frame
    await process_frame
    check(not guard.validate(wing.get_node("AuthoredWear")).is_empty(), "approved guard also rejects script on native camera")
    approved_camera.free()
    var arbitrary := GDScript.new()
    arbitrary.source_code = "extends Node3D\n"
    check(arbitrary.reload() == OK, "compile forbidden script")
    var scripted := Node3D.new()
    scripted.set_script(arbitrary)
    a.add_child(scripted)
    scripted.owner = wing
    check(not guard.validate_experiments(branch).is_empty(), "reject extra scripted helper child")
    scripted.free()
    var quad = a.get_node("Quad")
    quad.owner = wing
    check(not guard.validate_experiments(branch).is_empty(), "reject saved visual")
    quad.owner = null
    quad.set_script(arbitrary)
    check(not guard.validate_experiments(branch).is_empty(), "reject scripted generated visual")
    quad.set_script(null)
    var approved = AUTHOR.new()
    approved.approved_source = "eaf4b_7efdf22029c82320d62147c7"
    branch.add_child(approved)
    approved.owner = wing
    await process_frame
    await process_frame
    check(not guard.validate_experiments(branch).is_empty(), "experiment branch does not expand to other authoring scripts")
    approved.free()
    check(guard.validate_experiments(branch).is_empty(), "guard restored")
    var signage = wing.get_node("ReceivingSetDressing/ReceivingDecals/ReceivingFinishPass/ReceivingSignage")
    var signage_was_visible = signage.is_visible_in_tree()
    branch.hide()
    check(not a.get_node("Quad").is_visible_in_tree(), "hide all experiments")
    check(wing.get_node("AuthoredWear").is_visible_in_tree(), "approved authoring branch stays visible")
    check(wing.get_node("ReceivingLiftMonitor/SM_KB3D_CPP_PropTV_A/Mesh").is_visible_in_tree() and wing.has_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport"), "CRT stays visible")
    check(signage.is_visible_in_tree() == signage_was_visible, "hiding experiments preserves saved signage visibility")
    wing.free()
    print("IMPERFECTION_WORKSPACE checks=",checks," failures=",failures)
    quit(1 if failures else 0)
