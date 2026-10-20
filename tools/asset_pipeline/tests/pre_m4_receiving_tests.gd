extends "res://tools/asset_pipeline/tests/receiving_freight_reach_tests.gd"

var completed:=0
var takes:=0
var handoffs:=0
var no_surface: Array[String]=[]
var identities: Dictionary={}

func _run() -> void:
	create_timer(240).timeout.connect(func():
		push_error("PRE_M4_RECEIVING helper incomplete")
		quit(3))
	var inventory: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tools/asset_pipeline/props_inventory.json"))
	var ids: Array=inventory.models.filter(func(r):return r.disposition=="new").map(func(r):return r.item_id)
	# Four exact items per bounded manifest, interleaved across inventory quarters.
	# No presentation-driven omission, replacement, shrink or limit expansion.
	var indices: Array=range(30)
	if OS.get_cmdline_user_args().has("--affected-poses"):
		indices=[6,7,13,24,25,28] # Six refined clothing/instrument poses; retain each exact mixed manifest.
	if OS.get_cmdline_user_args().has("--basketball-role"):
		indices=[3] # Exact mixed manifest containing loot_000136.
	for index: int in indices:
		var manifest: Array=[]
		for quarter: int in 4: manifest.append(ids[index+quarter*30])
		var result:=await _measure_case({"label":"new_%03d" % index,"manifest":manifest,"index":index,"content_seed":0,"fixture_mode":DeckPlannerScript.FixtureMode.BARE})
		_check(result.drained and result.records.size()==4,"Exact mixed manifest completely drained")
		for record: Dictionary in result.records:
			_check(not identities.has(record.instance_id),"Stable unique cargo identity")
			identities[record.instance_id]=true
			takes+=1
		completed+=1
	_check(completed==indices.size() and takes==indices.size()*4 and identities.size()==takes,"Every requested exact mixed manifest through progressive production rays/TAKE")
	print("PRE_M4_RECEIVING_COMPLETE manifests=",completed," takes=",takes," shelf_handoffs=",handoffs," ordinary_surface_blockers=",no_surface," failures=",int(_failed))
	quit(1 if _failed else 0)

func _prepare_case(runtime: Node, case: Dictionary) -> bool:
	runtime.run_identity=load("res://gameplay/run/run_identity.gd").new()
	var batch: LootBatch=runtime.prepare_manifest(case.manifest,case.label,9300+case.index)
	if batch==null: return false
	_check(batch.entries.map(func(e):return String(e.definition_id))==case.manifest,"Exact ordered content retained")
	return runtime.return_admission.submit_return(case.label,batch)==AwaitingLiftAdmission.ReturnResult.ADMITTED

func _after_measured_take(scene: Node, item: ItemInstance) -> void:
	var carry: CarriedItems=scene.get_node("Player/CarriedItems")
	var controller:=StoragePlacementController.new()
	root.add_child(controller)
	controller.configure(null,carry,2.3)
	var stored:=false
	for surface: StorageSurface in scene.get_functional_surfaces():
		surface.set_zone_rect("General",Vector2i.ZERO,surface.grid_size)
		var orientations: Array=controller.call("_entry_orientations_for_item",item,surface.get_semantic_orientation_quarter_turns())
		var fit:=surface.find_zone_stack_or_empty_fit(item.get_storage_category(),orientations[0],orientations[1] if orientations.size()>1 else null)
		if not fit.get("valid",false):continue
		controller.set("_current_surface",surface)
		controller.set("_current_fit",fit)
		controller.set("_manual_mode",false)
		_check(controller.place_selected(),"Receiving cargo hands off through real shelf placement")
		var stack:=surface.get_storage_stack(item.instance_id)
		_check(stack!=null and stack.entries[0].item==item,"Receiving identity reaches shelf unchanged")
		if stack!=null:
			_check(stack.entries[0].world_item.pickup_into(carry) and carry.get_selected_item()==item,"Retrieve same cargo identity from shelf")
			stored=true
			handoffs+=1
		break
	if not stored: no_surface.append(String(item.definition.item_id))
	carry.remove_item(item) # Isolated fixture clears each inspected item, without capacity changes.
	controller.free()
