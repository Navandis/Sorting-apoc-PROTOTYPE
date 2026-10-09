extends SceneTree
# Guards the human-owned manual arrangement and retirement of invisible legacy physics.
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
   check(node.get_script() == null,"art/proxies have no gameplay script: "+str(node.name))
   if node is Node3D and not node.is_visible_in_tree():
    if node is CollisionShape3D: check(node.disabled,"hidden alternative shape disabled")
    if node is CollisionObject3D: check(node.collision_layer == 0,"hidden alternative has no active collision")
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
