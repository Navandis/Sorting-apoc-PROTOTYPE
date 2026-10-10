extends SceneTree
# Guards the human-owned manual arrangement and retirement of invisible legacy physics.
const WearGuard = preload("res://tools/asset_pipeline/tests/support/wear_branch_guard.gd")
const WING = "res://gameplay/logistics_wing/wing_gameplay.tscn"
const GROUPS = ["ReceivingDecals","ReceivingPipes","ReceivingElectrical","ReceivingDesk","ReceivingDecorations"]
var failures = 0
func _init(): call_deferred("run")
func check(ok: bool, message: String):
 if not ok:
  failures += 1
  push_error("ASSERTION FAILED: "+message)
func run():
 var wing = load(WING).instantiate()
 root.add_child(wing)
 await physics_frame
 await physics_frame
 var authored = wing.get_node_or_null("AuthoredWear")
 check(authored != null,"wing has explicit visual-only authoring home")
 if authored:
  check(authored.get_parent() == wing and authored.owner == wing and authored.transform == Transform3D.IDENTITY,"wear home is directly scene-owned, outside gameplay actors")
  var errors = WearGuard.validate(authored)
  check(errors.is_empty(),"authored wear branch rejects gameplay/physics/light authority: " + str(errors))
 var experiments = wing.get_node_or_null("ImperfectionExperiments")
 check(experiments != null,"wing has explicit separate experimental visual home")
 if experiments:
  check(experiments.get_parent() == wing and experiments.owner == wing and experiments.transform == Transform3D.IDENTITY,"experimental home is directly scene-owned")
  check(WearGuard.validate_experiments(experiments).is_empty(),"experimental branch rejects gameplay/physics/light authority")
 var dressing = wing.get_node_or_null("ReceivingSetDressing")
 check(dressing != null,"manual art has one editable production owner")
 if dressing:
  check(dressing.owner == wing and dressing.transform == Transform3D.IDENTITY,"identity organization retains wing scene ownership")
  for name in GROUPS:
   var group = dressing.get_node_or_null(name)
   check(group != null and group.owner == wing,"manual group retained: "+name)
   check(wing.get_node_or_null(name) == null,"old direct group path removed: "+name)
  check(dressing.find_children("*","Light3D",true,false).is_empty(),"dressing adds no lights")
  check(dressing.find_children("*","Area3D",true,false).is_empty(),"dressing adds no interaction areas")
  check(dressing.find_children("*","RigidBody3D",true,false).is_empty(),"dressing adds no dynamic bodies")
  for node in dressing.find_children("*","",true,false):
   check(node.get_script() == null,"manual art/proxies have no scripts: "+str(node.name))
   if node is Node3D and not node.is_visible_in_tree():
    if node is CollisionShape3D: check(node.disabled,"hidden alternative shape disabled")
    if node is CollisionObject3D: check(node.collision_layer == 0,"hidden alternative has no active collision")
  check(not dressing.has_node("ReceivingDecals/ReceivingFinishPass"),"rejected legacy finish instance retired")
  var signage = dressing.get_node_or_null("ReceivingDecals/ReceivingSignage")
  check(signage != null,"accepted plaque has independent signage owner")
  if signage:
   check(signage.is_visible_in_tree(),"accepted plaque restored to effective visibility")
   check(signage.get_child_count() == 1 and signage.get_node_or_null("LiftEmergencyStopLabel") is MeshInstance3D,"only original plaque geometry")
   for kind in ["CollisionObject3D","CollisionShape3D","Light3D","Camera3D"]:
    check(signage.find_children("*",kind,true,false).is_empty(),"signage visual-only: no "+kind)
 check(wing.find_children("ReceivingInfrastructure","",true,false).is_empty(),"no hidden legacy live root")
 check(wing.find_children("CabinetMovementCollision","",true,false).is_empty(),"legacy cabinet collider retired")
 check(wing.find_children("P1_ServiceMain","",true,false).is_empty() and wing.find_children("E1_ElectricalThroughFeed","",true,false).is_empty() and wing.find_children("L1_LiftServiceBranch","",true,false).is_empty(),"legacy P1/E1/L1 subtrees retired")
 var monitor = wing.get_node("ReceivingLiftMonitor")
 check(monitor.get_parent() == wing and monitor.owner == wing,"CRT owner remains separate")
 check(not monitor.get_node("SM_OfficeMonitor_02").visible and not monitor.get_node("SM_KB3D_CBD_PropPCMonitor_B").visible,"positioned monitor alternatives remain hidden")
 check(wing.get_functional_surfaces().size() == 16,"ordinary storage remains sixteen")
 check(wing.get_node("ReceivingRuntime/ReceivingManager").get_active_batch() == null,"normal startup remains empty")
 wing.free()
 print("receiving_infrastructure_integration_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL",failures])
 quit(0 if failures == 0 else 1)
