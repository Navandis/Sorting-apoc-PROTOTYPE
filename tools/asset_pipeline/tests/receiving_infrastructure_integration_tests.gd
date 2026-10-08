extends SceneTree
# Catches missing/island-owned services, emissive source mutation, and cabinet collision regressions.
const WING = "res://gameplay/logistics_wing/wing_gameplay.tscn"
const INFRA = "res://gameplay/logistics_wing/receiving/receiving_infrastructure.tscn"
const BASE = "res://assets/environment/infrastructure/"
var failures = 0
func _init():
 call_deferred("run")
func check(ok: bool, message: String) -> bool:
 if not ok:
  failures += 1
  push_error("ASSERTION FAILED: "+message)
 return ok
func run():
 var wing = load(WING).instantiate()
 root.add_child(wing)
 await physics_frame
 await physics_frame
 var group = wing.get_node_or_null("Environment/ReceivingInfrastructure")
 if check(group != null,"saved production Environment owns Receiving infrastructure"):
  check(group.scene_file_path == INFRA and group.transform == Transform3D.IDENTITY and group.get_parent().global_transform == Transform3D.IDENTITY,"room-owned scene at identity")
  check(group.get_child_count() == 3,"three localized service owners")
  check(group.find_children("*","Light3D",true,false).is_empty(),"services add no lights")
  check(group.find_children("*","StorageSurface",true,false).is_empty(),"services add no registered storage")
  var instances = {}
  for n in group.find_children("*","",true,false):
   check(n.get_script() == null,"no utility script: "+str(group.get_path_to(n)))
   if not n.scene_file_path.is_empty(): instances[n.scene_file_path] = instances.get(n.scene_file_path,0)+1
  for expected in [["pipes/SM_L_Pipe_4m_02",4],["vents/SM_Vent_Holders",3],["cables/SM_ElectricalSupply_Wire01_Straight",5],["cables/SM_ElectricalSupply_Wire01_Corner",2],["service_props/SM_ElectricalSupply_JunctionBox04",1],["electrical/SM_KB3D_PAR_PropElectricalBox_A",1]]:
   check(instances.get(BASE+expected[0]+".glb",0) == expected[1],"selected service instances: "+expected[0])
  check(instances.size() == 6,"six selected GLBs; no extra installations")
  for i in 3:
   var support = group.get_node("P1_ServiceMain/P1_CeilingHanger_%d"%i)
   var bearer = support.get_node_or_null("Bearer") as MeshInstance3D
   if check(bearer != null,"support has a fitted bearer below the enlarged pipe"):
    var bb = bearer.global_transform*bearer.get_aabb()
    check(absf(bb.end.y-2.84)<.01,"bearer contacts underside instead of passing through barrel")
    var rod = support.get_node("Mesh") as MeshInstance3D
    var rb = rod.global_transform*rod.get_aabb()
    check(absf(rb.end.y-4.2)<.001 and rb.size.x<=.04,"slender rod anchors at existing ceiling")
  assert_materials(group)
  assert_cabinet_physics(wing,group)
  check(wing.get_functional_surfaces().size() == 16,"ordinary surface count remains 16")
 wing.free()
 print("receiving_infrastructure_integration_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL",failures])
 quit(0 if failures == 0 else 1)
func assert_materials(group):
 for source in ["cables/SM_ElectricalSupply_Wire01_Straight","cables/SM_ElectricalSupply_Wire01_Corner","service_props/SM_ElectricalSupply_JunctionBox04"]:
  var path = BASE+source+".glb"
  var original = load(path).instantiate()
  var imported = original.get_node("Mesh").get_active_material(0)
  check(imported.emission_enabled and is_equal_approx(imported.emission_energy_multiplier,10),"imported source emission preserved: "+source)
  var shared = null
  for n in group.find_children("*","Node3D",true,false):
   if n.scene_file_path != path: continue
   var material = n.get_node("Mesh").get_surface_override_material(0)
   if not check(material is BaseMaterial3D,"explicit scene-local material override: "+str(n.name)): continue
   check(material != imported and material.resource_path.begins_with(INFRA+"::") and not material.emission_enabled,"isolated non-emissive override: "+str(n.name))
   for prop in imported.get_property_list():
    if prop.usage & PROPERTY_USAGE_STORAGE and prop.name not in ["emission_enabled","resource_path"]:
     check(imported.get(prop.name) == material.get(prop.name),"supplied property retained: %s/%s" % [n.name,prop.name])
   if shared == null: shared = material
   else: check(shared == material,"override reused per original material path")
  original.free()
func assert_cabinet_physics(wing,group):
 var bodies = group.find_children("*","CollisionObject3D",true,false)
 var shapes = group.find_children("*","CollisionShape3D",true,false)
 if not check(bodies.size() == 1 and shapes.size() == 1,"cabinet is the sole service collision authority"): return
 var body = bodies[0]
 check(body is StaticBody3D and body.collision_layer == 1 and body.collision_mask == 1,"cabinet uses existing movement layer/mask")
 check(shapes[0].shape is BoxShape3D and not shapes[0].disabled,"one active coarse box")
 var player = wing.get_node("Player") as CharacterBody3D
 player.set_physics_process(false)
 var probe = PhysicsTestMotionParameters3D.new()
 probe.from = Transform3D(Basis.IDENTITY,Vector3(-35.05,.01,2.75))
 probe.motion = Vector3(0,0,1.0)
 var hit = PhysicsTestMotionResult3D.new()
 check(PhysicsServer3D.body_test_motion(player.get_rid(),probe,hit) and hit.get_collision_count()>0 and hit.get_collider()==body,"real player capsule cannot penetrate cabinet front")
 for route in [
  ["cabinet face",Vector3(-35.3,.01,2.9),Vector3(1.4,0,0)],
  ["cabinet east side",Vector3(-34.15,.01,2.55),Vector3(0,0,.7)],
  ["lift apron",Vector3(-35.2,.01,-3),Vector3(0,0,6)],
  ["Dispatch",Vector3(-31.714286,.01,-3),Vector3(0,0,-2)],
  ["Backlog",Vector3(-29.6,.01,0),Vector3(3,0,0)]]:
  probe.from = Transform3D(Basis.IDENTITY,route[1])
  probe.motion = route[2]
  check(not PhysicsServer3D.body_test_motion(player.get_rid(),probe),"cabinet leaves legal capsule passage: "+route[0])
