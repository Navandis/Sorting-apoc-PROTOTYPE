extends SceneTree
# Catches wrong-surface binding, broken viewport scope, moved authored art,
# and a configured display that never actually produces pixels.
const WING = "res://gameplay/logistics_wing/wing_gameplay.tscn"
const CRT = "ReceivingLiftMonitor/SM_KB3D_CPP_PropTV_A"
var failures = 0
func _init(): call_deferred("run")
func check(ok: bool, message: String):
 if not ok:
  failures += 1
  push_error("ASSERTION FAILED: "+message)
func run():
 for launch in [String(ProjectSettings.get_setting("application/run/main_scene")),WING]:
  var wing = load(launch).instantiate()
  wing.get_node("Player").set_physics_process(false)
  root.add_child(wing)
  await process_frame
  var crt: Node3D = wing.get_node(CRT)
  var mesh: MeshInstance3D = crt.get_node("Mesh")
  check(crt.transform.is_equal_approx(Transform3D(Basis(Vector3(1.235,0,0),Vector3(0,1.22,0),Vector3(0,0,1.665)),Vector3(-36.277256,2.0607827,-3.2622252))),"authored CRT transform retained")
  check(mesh.transform.is_equal_approx(Transform3D(Basis(Vector3(1,0,0),Vector3(0,.9999998,0),Vector3(0,0,1)),Vector3(.016489029,0,.02396071))),"authored imported Mesh transform retained")
  check(mesh.mesh.get_surface_count() == 6 and mesh.mesh.surface_get_material(1).resource_name == "MI_KB3D_CPP_GlassDarkTech_SM_KB3D_CPP_PropTV_A","source screen material remains on Surface 1")
  check(mesh.material_override == null and mesh.material_overlay == null,"no whole-mesh override")
  for index in [0,2,3,4,5]:
   check(mesh.get_surface_override_material(index) == null,"housing/source surface %d unchanged" % index)
  for alternative in ["SM_OfficeMonitor_02","SM_KB3D_CBD_PropPCMonitor_B"]:
   check(not wing.get_node("ReceivingLiftMonitor/"+alternative).visible,"hidden monitor remains hidden")
  var display = wing.get_node_or_null("ReceivingLiftMonitor/PhosphorDisplay")
  var material = mesh.get_surface_override_material(1) as StandardMaterial3D
  check(display != null and material != null,"screen owns passive live display and Surface 1 material")
  if display != null and material != null:
   check(not display.get_script().is_tool(),"editor saves cannot persist a pathless runtime viewport texture")
   var viewport: SubViewport = display.get_node("ScreenViewport")
   check(viewport.size == Vector2i(704,400) and viewport.disable_3d and viewport.gui_disable_input,"screen aspect and passive viewport")
   check(material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED and not material.emission_enabled,"internally luminous unshaded screen without light emission")
   check(material.albedo_texture is ViewportTexture,"visible surface uses genuine ViewportTexture")
   check(material.albedo_texture.get_rid() == viewport.get_texture().get_rid(),"texture binds to this fresh instance's viewport")
   var uv_min = Vector2(.459677398204803,.362903207540512)
   var uv_max = Vector2(.676535844802856,.530973076820374)
   var uv_scale = Vector2(material.uv1_scale.x,material.uv1_scale.y)
   var uv_offset = Vector2(material.uv1_offset.x,material.uv1_offset.y)
   check((uv_min*uv_scale+uv_offset).is_equal_approx(Vector2.ZERO) and (uv_max*uv_scale+uv_offset).is_equal_approx(Vector2.ONE),"measured atlas rectangle maps upright to full texture")
   for control in display.find_children("*","Control",true,false):
    check(control.mouse_filter == Control.MOUSE_FILTER_IGNORE and control.focus_mode == Control.FOCUS_NONE,"read-only display has no input/focus: "+str(control.name))
   for kind in ["Light3D","CollisionObject3D","CollisionShape3D","Area3D"]:
    check(wing.get_node("ReceivingLiftMonitor").find_children("*",kind,true,false).is_empty(),"monitor has no "+kind)
   check(display.find_children("*","Label",true,false).size() >= 4,"static labels render status/deck/queue")
   if DisplayServer.get_name() != "headless":
    for i in 8: await process_frame
    await RenderingServer.frame_post_draw
    var image = viewport.get_texture().get_image()
    check(image != null and not image.is_empty(),"live viewport produces nonempty pixels")
    if image != null and not image.is_empty():
     var phosphor = 0
     for y in range(0,image.get_height(),2):
      for x in range(0,image.get_width(),2):
       var pixel = image.get_pixel(x,y)
       if pixel.g > .25 and pixel.g > pixel.r*1.3: phosphor += 1
     check(phosphor > 1000,"rendered pixels contain green phosphor text, not a blank texture")
     print("CRT_RENDER launch=",launch," pixels=",image.get_size()," green_samples=",phosphor)
   else:
    print("CRT_RENDER skipped under dummy renderer; run with OpenGL for pixel proof")
  wing.free()
 print("receiving_lift_crt_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL",failures])
 quit(0 if failures == 0 else 1)
