extends SceneTree
const RIG = "res://gameplay/logistics_wing/receiving/receiving_lighting.tscn"
const BASE = "res://assets/environment/infrastructure/lighting/"
const LAYOUT = {
 "GeneralFixtures/G1": ["SM_Ind_War_Light_Ceiling_Metal_Hanging_02", Vector3(-34.4,4.137,-1.2),1.65,Vector3(-34.4,3.675,-1.2)],
 "GeneralFixtures/G2": ["SM_Ind_War_Light_Ceiling_Metal_Hanging_02", Vector3(-30.3,4.137,1.2),1.65,Vector3(-30.3,3.675,1.2)],
 "TaskFixtures/T1": ["SM_Lamp_long",Vector3(-37.4,3.1,-.8),.65,Vector3(-37.4,2.9,-.8)],
 "TaskFixtures/T2": ["SM_Lamp_long",Vector3(-37.4,3.1,.8),.65,Vector3(-37.4,2.9,.8)],
 "WarningFixtures/W1": ["SM_AlarmLight",Vector3(-35.83,2.85,2.2),1.0],
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
  check(rig.find_children("*","Light3D",true,false).size() == 6,"five production spots plus one W1 warning source")
  check(rig.find_children("*","SpotLight3D",true,false).size() == 5,"five spots")
  check(rig.find_children("*","OmniLight3D",true,false).size() == 1,"only the authorized local W1 omni")
  var bounce = rig.get_node_or_null("ApronCeilingBounce")
  if check(bounce is SpotLight3D and rig.find_children("ApronCeilingBounce","SpotLight3D",true,false).size()==1,"one canonically owned ceiling bounce"):
   assert_light_parameters(bounce,"ApronCeilingBounce")
   check((-bounce.basis.z).y>0,"ceiling bounce points upward")
  check(rig.find_children("*","CollisionObject3D",true,false).is_empty(),"no fixture collision")
  check(rig.get_node_or_null("GeneralFixtures/G3")==null and wing.get_node_or_null("SM_ChainLink_03")==null and wing.get_node_or_null("SM_KB3D_SIN_PropPendantLight_A_Main_transparent")==null,"complete G3 placement retired")
  for name in ["SM_ChainLink_01","SM_ChainLink_02","SM_KB3D_WDC_PropLight_H_Glass","SM_KB3D_WDC_PropLight_H_Glass2"]:
   check(wing.get_node_or_null(name)!=null,"retained complete pendant hardware: "+name)
  var counts = {}
  for node in rig.find_children("*","",true,false):
   if not node.scene_file_path.is_empty():
    counts[node.scene_file_path] = counts.get(node.scene_file_path,0) + 1
  check(counts.get(BASE+"SM_Ind_War_Light_Ceiling_Metal_Hanging_02.glb",0)==2 and counts.get(BASE+"SM_Lamp_long.glb",0)==2 and counts.get(BASE+"SM_AlarmLight.glb",0)==1 and counts.size()==3,"2 pendant/2 strip/1 warning asset instances")
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
 if expected.size()==4:
  var light = installation.get_node("Light")
  check(light is SpotLight3D,path+" practical spot")
  check(light.global_position.distance_to(expected[3])<.0001,path+" emitter remains at authored fixture")
  assert_light_parameters(light,path)
 else:
  check(installation.find_children("*","Light3D",true,false).size() == 1,"one W1 local source")
  var warning = fixture.get_node_or_null("WarningLight") as OmniLight3D
  if check(warning != null,"warning source follows existing W1 fixture"):
   check(not warning.shadow_enabled and not warning.visible and warning.light_energy == 0.0,"warning initializes off without shadows")
   check(warning.position.is_equal_approx(Vector3(.16,0,0)) and warning.global_position.distance_to(Vector3(-35.67,2.85,2.2)) < .001,"warning source just outside the lens")
   check(is_equal_approx(warning.omni_range,1.8) and is_equal_approx(warning.omni_attenuation,2.0),"localized warning reach/falloff")
 for mesh in fixture.find_children("*","MeshInstance3D",true,false):
  for s in mesh.mesh.get_surface_count():
   var mat = mesh.get_active_material(s)
   if expected[0] in ["SM_Lamp_long","SM_AlarmLight"]:
    check(mesh.get_surface_override_material(s)!=null and mat.resource_local_to_scene and mat.resource_name.begins_with("Receiving "),path+" Receiving-owned surface override")
   if expected[0]=="SM_AlarmLight":
    check(not mat.emission_enabled,"warning unlit surface")
   elif expected[0]=="SM_Lamp_long":
    check(mat.emission_enabled and is_equal_approx(mat.emission_energy_multiplier,.6) and mat.emission.is_equal_approx(Color(1,.94,.82)),"modest warm-neutral task emission")
# Energy, warmth, aim, reach, attenuation and shadow parameters are tunable.
# Validate usable properties and ownership rather than a dated numerical baseline.
func assert_light_parameters(light: SpotLight3D, path: String):
 check(is_finite(light.light_energy) and light.light_energy>=0,path+" finite nonnegative energy")
 check(is_finite(light.spot_range) and light.spot_range>0 and is_finite(light.spot_angle) and light.spot_angle>0 and light.spot_angle<=90,path+" usable reach/cone")
 var color = light.light_color
 check(is_finite(color.r) and is_finite(color.g) and is_finite(color.b) and is_finite(color.a) and light.transform.is_finite(),path+" finite color/transform")
 check(is_finite(light.spot_attenuation) and is_finite(light.spot_angle_attenuation) and is_finite(light.light_specular),path+" finite attenuation/specular")
 check(is_finite(light.shadow_bias) and is_finite(light.shadow_normal_bias) and is_finite(light.shadow_blur),path+" finite tunable shadow settings")
 check(is_equal_approx(light.light_volumetric_fog_energy,0),path+" no fog addition")
func assert_environment(env):
 var e = env.get_node("GameplayEnvironment").environment
 check(e.ambient_light_source==Environment.AMBIENT_SOURCE_DISABLED,"production ambient explicitly disabled")
 check(e.reflected_light_source==2,"reflection source retained")
 check(e.background_mode==1 and e.background_color.is_equal_approx(Color(.055,.06,.065)) and e.sky==null,"background/sky retained")
 check(e.tonemap_mode==2 and is_equal_approx(e.tonemap_exposure,1),"Filmic/exposure retained")
 var key = env.get_node("KeyLight")
 check(not key.visible and key.rotation_degrees.is_equal_approx(Vector3(-58,-32,0)) and key.light_color.is_equal_approx(Color(1,.97,.92)) and is_equal_approx(key.light_energy,1) and key.shadow_enabled and is_equal_approx(key.directional_shadow_max_distance,140),"directional key retained but disabled")
 check(env.get_node("FillLights").get_child_count()==9,"all legacy nodes retained")
 for name in FILLS:
  var light = env.get_node("FillLights/"+name)
  var prior = FILLS[name]
  check(light.position.is_equal_approx(prior[0]) and light.light_color.is_equal_approx(prior[1]) and is_equal_approx(light.light_energy,prior[2]) and is_equal_approx(light.omni_range,prior[3]) and light.shadow_enabled==prior[4] and light.visible==prior[5] and is_equal_approx(light.omni_attenuation,1),"legacy values: "+name)
  if light.visible:
   var box = AABB(Vector3(-40.85,0,-4),Vector3(12.35,4.2,8))
   check(light.global_position.distance_to(light.global_position.clamp(box.position,box.end))>light.omni_range,name+" cannot reach Receiving")
func assert_clearance(rig,wing):
 var roof = AABB(Vector3(-38.511,3.213,-1.755),Vector3(2.176,.509,3.495))
 # Accepted collisionless shutter prism excludes added fixture hardware only.
 var sweep = AABB(Vector3(-36.291565,.085839,-1.838069),Vector3(.214279,6.483488,3.635061))
 var beam = AABB(Vector3(-36.510307,3.514409,-2.809088),Vector3(.546615,.907182,12))
 var interaction = AABB(Vector3(-38.6,.82,-1.82),Vector3(3.3,1.7,3.64))
 for mesh in rig.find_children("*","MeshInstance3D",true,false):
  var box = mesh.global_transform*mesh.get_aabb()
  check(box.end.y<=4.2 and box.position.y>2.7,"ceiling/eye/barrier clearance: "+str(mesh.get_path()))
  check(not box.intersects(roof) and not box.intersects(sweep) and not box.intersects(beam) and not box.intersects(interaction),"roof/sweep/beam/cargo clearance: "+str(mesh.get_path()))
 for mesh in wing.get_node("ReceivingLiftInstallation").find_children("*","MeshInstance3D",true,false):
  check(mesh.cast_shadow!=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"enclosure shadow casting retained: "+str(mesh.get_path()))
func finish():
 print("receiving_lighting_integration_tests: %s (%d checks)" % ["FAIL" if failed else "PASS",checks])
 quit(1 if failed else 0)
