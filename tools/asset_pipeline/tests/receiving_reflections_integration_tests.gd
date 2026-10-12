extends SceneTree
var failed := false
var refreshes := 0
func _init():
    run.call_deferred()
func check(ok: bool, message: String) -> bool:
    if not ok:
        failed = true
        push_error("ASSERTION FAILED: " + message)
    return ok
func frames(count: int):
    for i in count: await process_frame
func run():
    var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
    root.add_child(wing)
    await frames(12)
    var reflections = wing.get_node_or_null("Environment/ReceivingReflections")
    if not check(reflections != null,"canonical environment owns saved Receiving reflections"):
        wing.free()
        finish()
        return
    check(wing.find_children("*","ReflectionProbe",true,false).size()==1,"exactly one probe")
    var probe: ReflectionProbe = reflections.get_node("InteriorProbe")
    check(probe.global_position.is_equal_approx(Vector3(-34.825,2.1,0)) and probe.global_basis.is_equal_approx(Basis.IDENTITY),"accepted effective world pose")
    check(probe.size.is_equal_approx(Vector3(12.35,4.2,8)) and (probe.global_transform*probe.origin_offset).is_equal_approx(Vector3(-33.825,1.9,0)),"accepted bounds and clear capture origin")
    check(is_equal_approx(probe.intensity,.30) and probe.ambient_mode==ReflectionProbe.AMBIENT_DISABLED and probe.update_mode==ReflectionProbe.UPDATE_ONCE,"restrained reflection-only once capture")
    check(probe.interior and probe.box_projection and probe.enable_shadows and probe.visible,"interior projected shadowed probe")
    check(probe.cull_mask==1 and probe.reflection_mask==1 and probe.layers==1 and is_equal_approx(probe.blend_distance,.5) and is_equal_approx(probe.max_distance,12) and is_equal_approx(probe.mesh_lod_threshold,1),"accepted masks and distances")
    var runtime = wing.get_node("ReceivingRuntime")
    check(runtime.receiving_manager.get_active_batch()==null and runtime.deck_presenter.get_materialized_world_items().is_empty(),"normal startup has no synthetic delivery")
    if not check(reflections.has_method("request_refresh") and reflections.has_signal("refresh_started"),"bounded callable refresh seam"):
        wing.free()
        finish()
        return
    reflections.refresh_started.connect(func(): refreshes+=1)
    var initial_id := probe.get_instance_id()
    for i in 3: reflections.request_refresh()
    await frames(40)
    check(refreshes==1 and reflections.get_node("InteriorProbe").get_instance_id()==initial_id,"burst requests refresh once while preserving the saved probe")
    check(wing.find_children("*","ReflectionProbe",true,false).size()==1,"refresh never leaves duplicate probes")
    await frames(40)
    check(refreshes==1,"idle scene does not poll or recapture")
    reflections.request_refresh()
    await frames(4)
    reflections.request_refresh()
    await create_timer(.5).timeout
    check(refreshes==3,"a change during capture is coalesced into one latest-state follow-up")
    check(runtime.run_debug_delivery(1842,9001,24,3),"existing explicit mixed debug delivery succeeds")
    await frames(40)
    var items: Array = runtime.deck_presenter.get_materialized_world_items()
    check(items.size()==24 and runtime.deck_presenter.get_materialized_fixture_nodes().size()==3,"unchanged debug presentation geometry")
    check(refreshes==4,"active batch event refreshes after materialization")
    var cycle = runtime.get_node("ReceivingLiftCycle")
    cycle.set_process(false)
    cycle.get_node("Arrival").stop()
    cycle._process(21.0)
    cycle.get_node("Opening").stop()
    cycle._process(6.0)
    await frames(40)
    check(cycle.get_cycle_state()==4 and refreshes==5,"settled open shutter explicitly refreshes the same probe")
    var carried = load("res://carried_items.gd").new()
    root.add_child(carried)
    check(items[0].pickup_into(carried),"existing TAKE path succeeds")
    await frames(40)
    check(refreshes==6 and runtime.deck_presenter.get_materialized_world_items().size()==23,"actual TAKE event refreshes changed visible cargo")
    var current: ReflectionProbe = reflections.get_node("InteriorProbe")
    check(current.global_transform.is_equal_approx(probe_pose()) and current.size.is_equal_approx(Vector3(12.35,4.2,8)) and is_equal_approx(current.intensity,.3) and current.update_mode==ReflectionProbe.UPDATE_ONCE,"refresh preserves accepted settings and world transform")
    carried.free()
    wing.free()
    finish()
func probe_pose() -> Transform3D:
    return Transform3D(Basis.IDENTITY,Vector3(-34.825,2.1,0))
func finish():
    print("receiving_reflections_integration_tests: ","FAIL" if failed else "PASS")
    quit(1 if failed else 0)
