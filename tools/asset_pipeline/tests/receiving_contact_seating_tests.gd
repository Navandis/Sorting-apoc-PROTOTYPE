extends SceneTree

const WING = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
const TOLERANCE_M = 0.001
var failures = 0
var records = {"items":[],"fixtures":[],"layout":{}}

func _init():
 call_deferred("run")

func check(ok: bool, message: String):
 if not ok:
  failures += 1
  push_error("CONTACT: " + message)

# Mesh vertices rather than host pivots or authored height constants.
func vertices(node: Node, frame: Transform3D = Transform3D.IDENTITY) -> Array[Vector3]:
 var result: Array[Vector3] = []
 for mesh: MeshInstance3D in node.find_children("*","MeshInstance3D",true,false):
  if not mesh.is_visible_in_tree():
   continue
  var xf = frame.affine_inverse()*mesh.global_transform
  for s in mesh.mesh.get_surface_count():
   for v: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
    result.append(xf*v)
 return result

func minimum_y(node: Node) -> float:
 var y = INF
 for v in vertices(node):
  y = minf(y,v.y)
 return y

# Vertical triangle intersections at a sample point, independent of material or collision.
func support_y(node: Node, point: Vector3, ceiling: float = INF) -> float:
 var y = -INF
 for mesh: MeshInstance3D in node.find_children("*","MeshInstance3D",true,false):
  if not mesh.is_visible_in_tree():
   continue
  for s in mesh.mesh.get_surface_count():
   var arrays = mesh.mesh.surface_get_arrays(s)
   var vv: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
   var ii: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
   var count = ii.size() if not ii.is_empty() else vv.size()
   for i in range(0,count,3):
    var a = mesh.global_transform*vv[ii[i] if not ii.is_empty() else i]
    var b = mesh.global_transform*vv[ii[i+1] if not ii.is_empty() else i+1]
    var c = mesh.global_transform*vv[ii[i+2] if not ii.is_empty() else i+2]
    var den = (b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
    if absf(den)<0.00000001:
     continue
    var u = ((b.z-c.z)*(point.x-c.x)+(c.x-b.x)*(point.z-c.z))/den
    var v = ((c.z-a.z)*(point.x-c.x)+(a.x-c.x)*(point.z-c.z))/den
    if u>=-0.00001 and v>=-0.00001 and u+v<=1.00001:
     var hit_y = u*a.y+v*b.y+(1-u-v)*c.y
     if hit_y<=ceiling:
      y=maxf(y,hit_y)
 return y

func run():
 var definitions = load("res://data/receiving/receiving_deck_stage_b_proof.tres").freight_fixture_definitions
 for mode in 4:
  await measure("mode_%d" % mode,mode,null)
 for definition in definitions:
  if definition.enabled:
   await measure(str(definition.fixture_id),1 if definition.family==0 else 2,definition)
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--contact-report="):
   FileAccess.open(arg.trim_prefix("--contact-report="),FileAccess.WRITE).store_string(JSON.stringify(records,"\t"))
 print("Receiving contact tests: ","PASS" if failures==0 else "FAIL", " failures=",failures," items=",records.items.size()," fixtures=",records.fixtures.size())
 quit(0 if failures==0 else 1)

func measure(label: String, mode: int, only_definition):
 var wing = WING.instantiate()
 var runtime = wing.get_node("ReceivingRuntime")
 if only_definition:
  runtime.deck_profile = runtime.deck_profile.duplicate()
  var selected: Array[Resource] = [only_definition]
  runtime.deck_profile.freight_fixture_definitions = selected
 root.add_child(wing)
 await physics_frame
 var seed = 249 if mode==1 else 142 if mode==2 else 1842
 check(runtime.run_debug_delivery(seed,9001,24,mode),label+" deterministic delivery")
 var presenter = runtime.get_node("ReceivingDeckPresenter")
 var batch = runtime.get_node("ReceivingManager").get_active_batch()
 var surfaces = {}
 for surface in presenter.get_private_storage_surfaces():
  surfaces[surface.surface_id]=surface
 var platform = presenter.get_node("DeckVisual")
 var fixture_nodes = {}
 var support_planes = {}
 for fixture in batch.presentation_fixtures:
  for fixture_root in presenter.get_materialized_fixture_nodes():
   if fixture_root.name=="FreightFixture_%s" % fixture.instance_id.validate_node_name():
    fixture_nodes[fixture.surface_id]=fixture_root
    var definition = only_definition
    if not definition:
     for candidate in definitions_for(runtime):
      if candidate.fixture_id==fixture.fixture_definition_id:
       definition=candidate
    var cargo = surfaces[fixture.surface_id]
    var physical_y = support_y(platform,fixture_root.global_position,fixture_root.global_position.y+.1)
    var body_min = minimum_y(fixture_root)
    var top_samples = []
    # Sample inside usable cargo area; crate rim is outside these interior samples.
    for x in [-.3,0.0,.3]:
     for z in [-.3,0.0,.3]:
      var p = cargo.global_transform*Vector3(x*definition.item_surface_usable_width_m,0,z*definition.item_surface_usable_depth_m)
      var top = support_y(fixture_root,p)
      if is_finite(top):
       top_samples.append(top)
    var inside_top = -INF
    for vertex in vertices(fixture_root,cargo.global_transform):
     if absf(vertex.x)<=definition.item_surface_usable_width_m*.5 and absf(vertex.z)<=definition.item_surface_usable_depth_m*.5 and (definition.family==1 or vertex.y<.02):
      inside_top=maxf(inside_top,(cargo.global_transform*vertex).y)
    var support = maxf(top_samples.max(),inside_top)
    support_planes[fixture.surface_id]=support
    records.fixtures.append({"scenario":label,"id":str(fixture.fixture_definition_id),"platform_y":physical_y,"root_y":fixture_root.global_position.y,"visual_transform_y":definition.visual_local_transform.origin.y,"body_min_y":body_min,"body_gap_m":body_min-physical_y,"support_samples_y":top_samples,"support_y":support,"surface_y":cargo.global_position.y,"surface_gap_m":cargo.global_position.y-support})
    check(absf(body_min-physical_y)<=TOLERANCE_M,label+" body "+str(fixture.fixture_definition_id)+" gap "+str(body_min-physical_y))
    check(absf(cargo.global_position.y-support)<=TOLERANCE_M,label+" support "+str(fixture.fixture_definition_id)+" gap "+str(cargo.global_position.y-support))
 var snapshot = []
 for entry in batch.entries:
  snapshot.append({"id":entry.entry_id,"instance":entry.item_instance_id,"surface":str(entry.presentation_surface_id),"cell":str(entry.presentation_cell_origin),"turn":entry.presentation_quarter_turns,"stack":entry.presentation_stack_group_id,"index":entry.presentation_stack_index,"xz":[entry.frozen_transform.origin.x,entry.frozen_transform.origin.z]})
 records.layout[label]=snapshot
 for item in presenter.get_materialized_world_items():
  var host = item.get_parent()
  var surface = host.get_parent()
  var entry
  for candidate in batch.entries:
   if candidate.item_instance_id==item.get_item_instance().instance_id:
    entry=candidate
    break
  if entry.presentation_stack_index!=0:
   continue
  var real_support = support_y(platform,host.global_position,surface.global_position.y+.1) if surface.surface_id==&"MainDeck" else support_planes[surface.surface_id]
  var min_y = minimum_y(host)
  var rec = {"scenario":label,"item":item.get_item_instance().get_display_name(),"surface":str(surface.surface_id),"support_y":real_support,"plane_y":surface.global_position.y,"host_y":host.global_position.y,"mesh_min_y":min_y,"gap_m":min_y-real_support}
  records.items.append(rec)
  check(min_y-real_support>=-TOLERANCE_M and min_y-real_support<=TOLERANCE_M,label+" base item "+rec.item+" gap "+str(rec.gap_m))
 if only_definition:
  check(not batch.presentation_fixtures.is_empty(),label+" exercises enabled definition")
 wing.free()
 await process_frame

func definitions_for(runtime):
 return runtime.deck_profile.freight_fixture_definitions
