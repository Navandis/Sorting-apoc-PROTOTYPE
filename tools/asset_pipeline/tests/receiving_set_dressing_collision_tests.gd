extends SceneTree
# Missing, oversized, mis-scaled or duplicate furniture proxies must fail real movement checks.
const WING = "res://gameplay/logistics_wing/wing_gameplay.tscn"
const TARGETS = ["SM_Desk_A01_N1","SM_Res_Fur_Stool_Metal_Worn_01","SM_Utility_Box_1a","SM_Metal_Barrel_RedWhite_01","PalletJack","SM_WoodPallet_03","SM_Electrical_Cabinet_01a","SM_KB3D_DMZ_Bucket_A_Main","SM_PlasticBox_06","SM_KB3D_WHS_PropDolly_A_Main","SM_Ind_Aba_Storage_Barrel_Metal_Blue_01"]
var failures = 0
func _init(): call_deferred("run")
func check(ok: bool, message: String):
 if not ok:
  failures += 1
  push_error("ASSERTION FAILED: "+message)
func motion(player, origin: Vector3, travel: Vector3, excluded: Array[RID] = []):
 var params = PhysicsTestMotionParameters3D.new()
 params.from = Transform3D(Basis.IDENTITY,origin)
 params.motion = travel
 params.exclude_bodies = excluded
 var result = PhysicsTestMotionResult3D.new()
 var blocked = PhysicsServer3D.body_test_motion(player.get_rid(),params,result)
 return {"blocked":blocked,"result":result}
func run():
 var wing = load(WING).instantiate()
 var player = wing.get_node("Player") as CharacterBody3D
 player.set_physics_process(false)
 root.add_child(wing)
 await physics_frame
 await physics_frame
 var proxies = wing.get_node_or_null("ReceivingSetDressing/CollisionProxies")
 check(proxies != null,"eleven authored prop collision authorities exist")
 if proxies:
  check(proxies.get_child_count() == 11,"exactly eleven movement-only authorities")
  check(player.collision_mask & 1 != 0,"proxies use actual player movement layer")
  var resolved = []
  for body in proxies.get_children():
   var visual = body.get_node_or_null(body.get_meta("visual_target",NodePath()))
   check(visual != null and visual.is_visible_in_tree(),"proxy resolves visible authored target: "+str(body.name))
   if visual: resolved.append(str(visual.name))
   check(body is StaticBody3D and body.collision_layer == 1 and body.collision_mask == 1,"static movement layer/mask: "+str(body.name))
   check(body.global_basis.get_scale().is_equal_approx(Vector3.ONE) and body.global_basis.is_equal_approx(body.global_basis.orthonormalized()),"unit orthogonal physics basis: "+str(body.name))
   check(body.owner == wing and body.get_script() == null,"proxy saved in wing without gameplay logic")
   for shape in body.get_children():
    check(shape is CollisionShape3D and not shape.disabled and (shape.shape is BoxShape3D or shape.shape is CylinderShape3D),"enabled coarse primitive: "+str(body.name)+"/"+str(shape.name))
    check(shape.global_basis.get_scale().is_equal_approx(Vector3.ONE),"shape never inherits art scale")
   if visual:
    var bb = AABB()
    var first = true
    for mesh in visual.find_children("*","MeshInstance3D",true,false):
     var bound = body.global_transform.affine_inverse()*mesh.global_transform*mesh.get_aabb()
     bb = bound if first else bb.merge(bound)
     first = false
    for shape in body.get_children():
     var ext = shape.shape.size/2 if shape.shape is BoxShape3D else Vector3(shape.shape.radius,shape.shape.height/2,shape.shape.radius)
     for sign_x in [-1,1]:
      for sign_y in [-1,1]:
       for sign_z in [-1,1]:
        check(bb.grow(.04).has_point(shape.position+ext*Vector3(sign_x,sign_y,sign_z)),"primitive stays within rendered target bounds: "+str(body.name))
  resolved.sort()
  var expected = TARGETS.duplicate()
  expected.sort()
  check(resolved == expected,"each requested visible target resolves exactly once")
  var jack = proxies.get_node("PalletJackMovement")
  var assembly = jack.get_node(jack.get_meta("visual_target"))
  check(assembly.get_child_count() == 3 and jack.get_child_count() == 3,"three visual jack components share one three-primitive authority")
  check(assembly.find_children("*","CollisionObject3D",true,false).is_empty(),"no duplicate per-component jack physics")
  var pallet = proxies.get_node("LeaningPalletMovement")
  check(pallet.get_child_count() == 1 and absf(pallet.global_basis.y.y)<.3,"leaning pallet has one oriented slab")
  # Isolate each target from adjacent requested props for controlled blocking checks; room/barrier remain active.
  # Contextual traversal below uses every saved collider without exclusions.
  # Hand-measured approach points in the saved human composition, not generated from proxies.
  for route in [
   ["DeskMovement",Vector3(-30.55,.01,2.15),Vector3(0,0,1.3)],
   ["StoolMovement",Vector3(-29.48,.01,1.75),Vector3(0,0,1.2)],
   ["UtilityBoxMovement",Vector3(-32.89,.01,2.1),Vector3(0,0,1.3)],
   ["RedWhiteBarrelMovement",Vector3(-33.55,.01,3.4),Vector3(-1.2,0,0)],
   ["PalletJackMovement",Vector3(-33.8,.01,1.55),Vector3(0,0,1.15)],
   ["LeaningPalletMovement",Vector3(-34.65,.01,3.0),Vector3(-1,0,0)],
   ["ElectricalCabinetMovement",Vector3(-34.7,.01,-3.17),Vector3(-1.2,0,0)],
   ["BucketMovement",Vector3(-29.6,.01,-2.85),Vector3(.9,0,0)],
   ["PlasticBoxMovement",Vector3(-29.65,.01,-2.45),Vector3(0,0,-1.2)],
   ["DollyMovement",Vector3(-30.13,.01,-2.3),Vector3(0,0,-1.2)],
   ["BlueBarrelMovement",Vector3(-30.0,.01,-3.5),Vector3(1.2,0,0)]]:
   var excluded: Array[RID] = []
   for other in proxies.get_children():
    if str(other.name) != route[0]: excluded.append(other.get_rid())
   var hit = motion(player,route[1],route[2],excluded)
   var collider = hit.result.get_collider() if hit.blocked and hit.result.get_collision_count()>0 else null
   check(hit.blocked and collider == proxies.get_node(route[0]),"real player capsule blocked by "+route[0]+" (hit "+str(collider)+")")
  for route in [
   ["central lift apron",Vector3(-35.15,.01,-2.25),Vector3(0,0,4.0)],
   ["front service circulation",Vector3(-34.8,.01,1.25),Vector3(5.7,0,0)],
   ["Dispatch opening",Vector3(-31.714286,.01,-2.8),Vector3(0,0,-2.4)],
   ["Backlog opening",Vector3(-29.6,.01,0),Vector3(3,0,0)],
   ["cleaning nook front",Vector3(-30.7,.01,-1.9),Vector3(1.4,0,0)],
   ["desk return walk-around",Vector3(-30.2,.01,1.25),Vector3(1,0,0)],
   ["left TAKE stance",Vector3(-35.3,.01,-1.2),Vector3(0,0,.6)],
   ["right TAKE stance",Vector3(-35.3,.01,.6),Vector3(0,0,.6)]]:
   var hit = motion(player,route[1],route[2])
   check(not hit.blocked,"clear production capsule route: "+route[0]+" (hit "+str(hit.result.get_collider() if hit.blocked else null)+")")
  var legacy_ray = PhysicsRayQueryParameters3D.create(Vector3(-35.05,1.65,3.05),Vector3(-35.05,1.65,3.8),1)
  check(wing.get_world_3d().direct_space_state.intersect_ray(legacy_ray).is_empty(),"no phantom physics in retired cabinet upper housing")
  # Empty desk leg space stays physically empty below tabletop, even though a standing player hits the top.
  var query = PhysicsRayQueryParameters3D.create(Vector3(-28.95,.35,2.35),Vector3(-28.95,.35,1.9),1)
  check(wing.get_world_3d().direct_space_state.intersect_ray(query).is_empty(),"desk underside has no solid full-bound box")
  var forks_ray = PhysicsRayQueryParameters3D.create(Vector3(-34.1,.6,1.95),Vector3(-34.1,.6,3.1),1)
  check(wing.get_world_3d().direct_space_state.intersect_ray(forks_ray).is_empty(),"pallet-jack forks leave empty space above low base")
  var fresh = ResourceLoader.load(WING,"",ResourceLoader.CACHE_MODE_IGNORE).instantiate()
  var fresh_proxies = fresh.get_node("ReceivingSetDressing/CollisionProxies")
  for body in proxies.get_children():
   var reloaded = fresh_proxies.get_node(NodePath(str(body.name)))
   check(body.transform == reloaded.transform and reloaded.owner == fresh,"canonical reload preserves body transform/owner: "+str(body.name))
   for shape in body.get_children():
    var saved = reloaded.get_node(NodePath(str(shape.name)))
    check(shape.transform == saved.transform and shape.disabled == saved.disabled,"reload preserves shape transform/state")
    if shape.shape is BoxShape3D: check(shape.shape.size == saved.shape.size,"reload preserves fitted box dimensions")
    else: check(shape.shape.radius == saved.shape.radius and shape.shape.height == saved.shape.height,"reload preserves fitted cylinder dimensions")
  fresh.free()
 wing.free()
 print("receiving_set_dressing_collision_tests: %s (%d failures)" % ["PASS" if failures == 0 else "FAIL",failures])
 quit(0 if failures == 0 else 1)
