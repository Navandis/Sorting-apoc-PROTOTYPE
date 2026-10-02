extends SceneTree
const RIG = "res://gameplay/logistics_wing/receiving/receiving_lighting.tscn"
const BASE = "res://assets/environment/infrastructure/lighting/"
const LAYOUT = {
 "GeneralFixtures/G1": ["SM_Ind_War_Light_Ceiling_Metal_Hanging_02", Vector3(-36.9,4.137,-1.6),1.65,Vector3(-36.9,3.675,-1.6),Vector3(-36.9,0,-1.6)],
 "GeneralFixtures/G2": ["SM_Ind_War_Light_Ceiling_Metal_Hanging_02", Vector3(-33.25,4.137,2.4),1.65,Vector3(-33.25,3.675,2.4),Vector3(-33.25,0,2.4)],
 "GeneralFixtures/G3": ["SM_Ind_War_Light_Ceiling_Metal_Hanging_02", Vector3(-30.4,4.137,-1),1.65,Vector3(-30.4,3.675,-1),Vector3(-30.4,0,-1)],
 "TaskFixtures/T1": ["SM_Lamp_long",Vector3(-40.4,3.1,-.8),.65,Vector3(-40.4,2.9,-.8),Vector3(-40.38,.82,-.12)],
 "TaskFixtures/T2": ["SM_Lamp_long",Vector3(-40.4,3.1,.8),.65,Vector3(-40.4,2.9,.8),Vector3(-40.38,.82,.12)],
 "WarningFixtures/W1": ["SM_AlarmLight",Vector3(-38.83,2.85,2.2),1.0],
}
# Baseline oracles: position, color, energy, range, shadows, final visibility.
const FILLS = {
 "West": [Vector3(-33,2.7,0),Color(1,.92,.8),2.2,22.0,true,false],
 "Sorting": [Vector3(-10,2.7,-1),Color(.94,.97,1),2.0,20.0,false,false],
 "StorageWest": [Vector3(3,2.8,0),Color(1,.96,.86),2.0,21.0,false,true],
 "StorageEast": [Vector3(18,2.8,1),Color(1,.96,.86),2.0,20.0,false,true],
 "MedicalKitchen": [Vector3(17,2.7,-20),Color(.9,.96,1),2.0,20.0,false,true],
 "MedicalTuning": [Vector3(4.3,2.7,-26.5),Color(.9,.96,1),1.4,12.0,false,true],
 "Workshop": [Vector3(-8,2.7,21),Color(1,.88,.72),2.1,22.0,false,true],
 "Deeper": [Vector3(40,2.7,0),Color(.92,.96,1),2.0,23.0,false,true],
 "East": [Vector3(56,2.7,-5),Color(.94,.97,1),2.0,22.0,false,true],
}
var failed = false
var checks = 0
func _init():
 call_deferred("run")
func check(ok: bool, message: String) -> bool:
 checks += 1
 if not ok:
  failed = true
  push_error("ASSERTION FAILED: " + message)
 return ok
func run():
 if not check(ResourceLoader.exists(RIG),"Receiving lighting scene exists"):
  finish()
  return
 for path in [RIG,"res://gameplay/logistics_wing/wing_environment.tscn","res://gameplay/logistics_wing/wing_gameplay.tscn"]:
  check(load(path) is PackedScene,"scene loads: " + path)
 var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
 root.add_child(wing)
 await process_frame
 await physics_frame
 var env = wing.get_node("Environment")
 var rig = env.get_node_or_null("ReceivingLighting")
 if check(rig != null,"environment owns Receiving lighting"):
  check(rig.scene_file_path == RIG and rig.transform == Transform3D.IDENTITY and env.global_transform == Transform3D.IDENTITY,"identity ownership/world coordinates")
  check(rig.find_children("*","Light3D",true,false).size() == 5,"five sources; no helper fill")
  check(rig.find_children("*","SpotLight3D",true,false).size() == 5,"five spots")
  check(rig.find_children("*","OmniLight3D",true,false).is_empty(),"no local omni")
  check(rig.find_children("*","CollisionObject3D",true,false).is_empty(),"no fixture collision")
  var counts = {}
  for node in rig.find_children("*","",true,false):
   if not node.scene_file_path.is_empty():
    counts[node.scene_file_path] = counts.get(node.scene_file_path,0) + 1
  check(counts.get(BASE+"SM_Ind_War_Light_Ceiling_Metal_Hanging_02.glb",0)==3 and counts.get(BASE+"SM_Lamp_long.glb",0)==2 and counts.get(BASE+"SM_AlarmLight.glb",0)==1 and counts.size()==3,"3 pendant/2 strip/1 warning asset instances")
  for path in LAYOUT:
   assert_installation(rig,path)
  check(rig.get_node("TaskFixtures/T1/Fixture/Mesh").get_surface_override_material(0) != rig.get_node("TaskFixtures/T2/Fixture/Mesh").get_surface_override_material(0),"task materials duplicated per instance")
  assert_clearance(rig,wing)
 assert_environment(env)
 for pair in [["SM_Lamp_long",[20.0]],["SM_AlarmLight",[14.609375,791.5]]]:
  var source = load(BASE+pair[0]+".glb").instantiate()
  var mesh = source.get_node("Mesh")
  for s in mesh.mesh.get_surface_count():
   var mat = mesh.get_active_material(s)
   check(mat.emission_enabled and is_equal_approx(mat.emission_energy_multiplier,pair[1][s]),"original source emission preserved: %s/%d" % [pair[0],s])
  source.free()
 check(ProjectSettings.get_setting("rendering/renderer/rendering_method")=="gl_compatibility","Compatibility retained")
 check(ProjectSettings.get_setting("rendering/limits/opengl/max_lights_per_object",8)==8,"light limit unchanged; five spots fit")
 wing.free()
 finish()
func assert_installation(rig, path):
 var expected = LAYOUT[path]
 var installation = rig.get_node_or_null(path)
 if not check(installation != null,"installation: " + path):
  return
 var fixture = installation.get_node("Fixture")
 check(fixture.scene_file_path == BASE+expected[0]+".glb",path+" selected imported asset")
 check(fixture.global_position.distance_to(expected[1])<.0001 and fixture.scale.is_equal_approx(Vector3.ONE*expected[2]),path+" approved position/scale")
 check(fixture.rotation.is_zero_approx(),path+" body identity rotation")
 if expected.size()==5:
  var light = installation.get_node("Light")
  var general = path.begins_with("General")
  check(light is SpotLight3D and light.shadow_enabled,path+" shadowed spot")
  check(light.global_position.distance_to(expected[3])<.0001 and (-light.global_basis.z).dot((expected[4]-expected[3]).normalized())>.99999,path+" source/target aim")
  check(is_equal_approx(light.light_energy,1.9 if general else .85) and is_equal_approx(light.spot_range,6.2 if general else 3.2) and is_equal_approx(light.spot_angle,55 if general else 52),path+" energy/range/angle seed")
  check(light.light_color.is_equal_approx(Color(1,.84,.68) if general else Color(1,.94,.82)),path+" warmth")
  check(is_equal_approx(light.shadow_bias,.05 if path=="GeneralFixtures/G1" else .025) and is_equal_approx(light.shadow_normal_bias,.5 if path=="GeneralFixtures/G1" else .25) and is_equal_approx(light.light_volumetric_fog_energy,0),path+" shadow settings/no fog addition")
 else:
  check(installation.find_children("*","Light3D",true,false).is_empty(),"warning has no light")
 for mesh in fixture.find_children("*","MeshInstance3D",true,false):
  for s in mesh.mesh.get_surface_count():
   var mat = mesh.get_active_material(s)
   if expected[0] in ["SM_Lamp_long","SM_AlarmLight"]:
    check(mesh.get_surface_override_material(s)!=null and mat.resource_local_to_scene and mat.resource_name.begins_with("Receiving "),path+" Receiving-owned surface override")
   if expected[0]=="SM_AlarmLight":
    check(not mat.emission_enabled,"warning unlit surface")
   elif expected[0]=="SM_Lamp_long":
    check(mat.emission_enabled and is_equal_approx(mat.emission_energy_multiplier,.6) and mat.emission.is_equal_approx(Color(1,.94,.82)),"modest warm-neutral task emission")
func assert_environment(env):
 var e = env.get_node("GameplayEnvironment").environment
 check(is_equal_approx(e.ambient_light_energy,.12),"ambient .12")
 check(e.ambient_light_source==3 and e.ambient_light_color.is_equal_approx(Color(.78,.81,.84)) and e.reflected_light_source==2,"ambient mode/color/reflection retained")
 check(e.background_mode==1 and e.background_color.is_equal_approx(Color(.055,.06,.065)) and e.sky==null,"background/sky retained")
 check(e.tonemap_mode==2 and is_equal_approx(e.tonemap_exposure,1),"Filmic/exposure retained")
 var key = env.get_node("KeyLight")
 check(key.visible and key.rotation_degrees.is_equal_approx(Vector3(-58,-32,0)) and key.light_color.is_equal_approx(Color(1,.97,.92)) and is_equal_approx(key.light_energy,1) and key.shadow_enabled and is_equal_approx(key.directional_shadow_max_distance,140),"directional key retained")
 check(env.get_node("FillLights").get_child_count()==9,"all legacy nodes retained")
 for name in FILLS:
  var light = env.get_node("FillLights/"+name)
  var prior = FILLS[name]
  check(light.position.is_equal_approx(prior[0]) and light.light_color.is_equal_approx(prior[1]) and is_equal_approx(light.light_energy,prior[2]) and is_equal_approx(light.omni_range,prior[3]) and light.shadow_enabled==prior[4] and light.visible==prior[5] and is_equal_approx(light.omni_attenuation,1),"legacy values: "+name)
  if light.visible:
   var box = AABB(Vector3(-41.6,0,-5),Vector3(13.1,4.2,10))
   check(light.global_position.distance_to(light.global_position.clamp(box.position,box.end))>light.omni_range,name+" cannot reach Receiving")
func assert_clearance(rig,wing):
 var roof = AABB(Vector3(-41.511,3.213,-1.755),Vector3(2.176,.509,3.495))
 var sweep = AABB(Vector3(-39.266,.071,-1.803),Vector3(.195,6.638,3.622))
 var beam = AABB(Vector3(-39.51,3.514,-2.5),Vector3(.546,.907,5))
 var interaction = AABB(Vector3(-41.6,.82,-1.82),Vector3(3.3,1.7,3.64))
 for mesh in rig.find_children("*","MeshInstance3D",true,false):
  var box = mesh.global_transform*mesh.get_aabb()
  check(box.end.y<=4.2 and box.position.y>2.7,"ceiling/eye/barrier clearance: "+str(mesh.get_path()))
  check(not box.intersects(roof) and not box.intersects(sweep) and not box.intersects(beam) and not box.intersects(interaction),"roof/sweep/beam/cargo clearance: "+str(mesh.get_path()))
 for mesh in wing.get_node("ReceivingLiftInstallation").find_children("*","MeshInstance3D",true,false):
  check(mesh.cast_shadow!=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"enclosure shadow casting retained: "+str(mesh.get_path()))
func finish():
 print("receiving_lighting_integration_tests: %s (%d checks)" % ["FAIL" if failed else "PASS",checks])
 quit(1 if failed else 0)
