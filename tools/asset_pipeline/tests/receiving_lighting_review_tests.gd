extends SceneTree
# Catches candidate environment writes bleeding into canonical or other instances,
# losing the real gameplay hierarchy, and relocating authored fixture meshes.
const REVIEW := "res://gameplay/logistics_wing/review/receiving_lighting_review.tscn"
const PRODUCTION := "res://gameplay/logistics_wing/wing_gameplay.tscn"
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool, message: String) -> bool:
    if not ok:
        failures+=1
        push_error("ASSERTION FAILED: "+message)
    return ok
func art_transforms(node: Node,base: Node,result: Dictionary):
    if node is Node3D and not node is Light3D and not node is Camera3D and node.name != "Player":
        result[str(base.get_path_to(node))]=str(node.transform)
    for child in node.get_children(): art_transforms(child,base,result)
func run():
    if not check(ResourceLoader.exists(REVIEW),"playable isolated lighting candidate exists"):
        finish()
        return
    var canonical=load(PRODUCTION).instantiate()
    var review=load(REVIEW).instantiate()
    var other=load(REVIEW).instantiate()
    var wing=review.get_node("Gameplay")
    var env: Environment=wing.get_node("Environment/GameplayEnvironment").environment
    var other_env: Environment=other.get_node("Gameplay/Environment/GameplayEnvironment").environment
    var canonical_env: Environment=canonical.get_node("Environment/GameplayEnvironment").environment
    check(env!=canonical_env and env!=other_env,"candidate Environment is private per instance")
    check(env.ambient_light_source==Environment.AMBIENT_SOURCE_DISABLED,"declared zero ambient start")
    check(not wing.get_node("Environment/KeyLight").visible,"global key excluded in candidate")
    env.tonemap_exposure=2.0
    check(is_equal_approx(canonical_env.tonemap_exposure,1) and is_equal_approx(other_env.tonemap_exposure,1),"Inspector tuning cannot mutate production or another candidate")
    env.tonemap_exposure=1
    check(canonical_env.ambient_light_source==Environment.AMBIENT_SOURCE_SKY and is_equal_approx(canonical_env.ambient_light_energy,.12),"canonical ambient preserved")
    var before := {}; var after := {}
    art_transforms(canonical,canonical,before);art_transforms(wing,wing,after)
    check(before==after,"all authored art and structural transforms preserved")
    check(ProjectSettings.get_setting("application/run/main_scene")=="uid://bljf1nlhijej","canonical default startup retained")
    other.free();canonical.free()
    root.add_child(review)
    current_scene=review
    await process_frame
    var runtime=wing.get_node("ReceivingRuntime")
    var cycle=runtime.get_node("ReceivingLiftCycle")
    check(cycle.is_configured() and not cycle.is_busy(),"candidate independently initializes real cycle")
    check(wing.get_functional_surfaces().size()==16,"ordinary storage hierarchy retained")
    check(wing.find_children("*","ReflectionProbe",true,false).size()==1,"exactly one Receiving reflection probe")
    var reflections=wing.get_node("Environment/ReceivingReflections")
    check(reflections.has_method("request_refresh"),"existing refresh controller retained")
    check(is_equal_approx(cycle.closing_motion_delay_s+cycle.closing_motion_duration_s,3.4),"accepted shutter contact timing retained")
    for name in ["Arrival","Opening","Closing","Departure"]:
        check(cycle.get_node(name).stream!=null and cycle.get_node(name).stream.get_length()>5,"full "+name+" cue retained")
    var camera: Camera3D=wing.get_node("Player/Camera3D")
    check(camera.is_current() and camera.environment==null and camera.attributes==null,"actual playable camera without hidden environment/exposure")
    check(cycle.get("_reflections")==reflections,"settled shutter retains existing refresh owner")
    check(runtime.receiving_manager.active_batch_changed.is_connected(Callable(reflections,"_on_active_batch_changed")),"batch refresh remains connected")
    var refresh_count := [0]
    reflections.refresh_started.connect(func(): refresh_count[0]+=1)
    var probe_id: int = reflections.get_node("InteriorProbe").get_instance_id()
    cycle.set_process(false)
    check(runtime.run_debug_delivery(1842,9001,24,3),"existing explicit mixed delivery usable")
    var warning: OmniLight3D=wing.get_node("Environment/ReceivingLighting/WarningFixtures/W1/Fixture/WarningLight")
    cycle._process(.5)
    var amber_energy := warning.light_energy
    cycle._process(.2)
    check(warning.visible and warning.light_color.r>warning.light_color.g and not is_equal_approx(amber_energy,warning.light_energy),"accepted amber pulse retained")
    cycle.get_node("Arrival").stop();cycle._process(21)
    cycle.get_node("Opening").stop();cycle._process(6)
    check(cycle.get_cycle_state()==4 and cycle.can_take_receiving(),"real cargo reaches OPEN and TAKE gate")
    var green_energy := warning.light_energy
    cycle._process(.2)
    check(warning.visible and warning.light_color.g>warning.light_color.r and is_equal_approx(green_energy,warning.light_energy),"accepted steady green retained")
    await create_timer(.3).timeout
    var items: Array=runtime.deck_presenter.get_materialized_world_items()
    check(items.size()==24 and runtime.deck_presenter.get_materialized_fixture_nodes().size()==3,"representative actual cargo and fixtures intact")
    var carried=wing.get_node("Player/CarriedItems")
    if not items.is_empty():
        var refresh_before: int=refresh_count[0]
        check(items[0].pickup_into(carried),"actual TAKE transfers to real carried bundle")
        await create_timer(.3).timeout
        check(refresh_count[0]>refresh_before and reflections.get_node("InteriorProbe").get_instance_id()==probe_id,"TAKE refreshes the same probe")
        check(cycle.get_deck_item_count()==23,"real remaining count updates")
        var ui=wing.get_node("ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport/Interface")
        check(ui.get_node("Deck").text=="DECK   : 23","live CRT follows candidate TAKE")
    # Exercise ordinary storage through the existing player placement controller.
    var food_host: Node = null
    for host in wing.get_node("DevelopmentSetup/SeedItems").get_children():
        if StringName(host.get("item_id"))==&"loot_000005":
            food_host=host
            break
    if check(food_host!=null,"ordinary approved food seed remains available"):
        var food: ItemInstance=food_host.get_node("WorldItem").get_item_instance()
        check(food_host.get_node("WorldItem").pickup_into(carried),"ordinary seed pickup usable")
        carried.select_index(carried.get_slots().find(food))
        var item: ItemInstance=carried.get_selected_item()
        var surface=wing.get_functional_surfaces()[0]
        surface.set_zone_rect("Food",Vector2i.ZERO,surface.get_grid_size()-Vector2i.ONE)
        var controller=wing.get_node("Player/StoragePlacementController")
        var orientations: Array=controller._entry_orientations_for_item(item,surface.get_semantic_orientation_quarter_turns())
        var fit=surface.find_zone_stack_or_empty_fit(item.get_storage_category(),orientations[0],orientations[1] if orientations.size()>1 else null)
        controller.set("_current_surface",surface)
        controller.set("_current_fit",fit)
        controller.set("_manual_mode",false)
        check(controller.place_selected(),"ordinary deterministic shelf placement usable")
    # Let deferred placement/ghost updates complete before deferred teardown.
    await process_frame
    review.queue_free()
    await process_frame
    await process_frame
    finish()
func finish():
    print("receiving_lighting_review_tests: ","PASS" if failures==0 else "FAIL"," failures=",failures)
    quit(0 if failures==0 else 1)
