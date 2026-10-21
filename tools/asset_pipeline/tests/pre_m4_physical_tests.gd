extends "res://tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd"

var completed:=0
var blockers: Array[Dictionary]=[]
var evidence_dir:=""

func _run() -> void:
	create_timer(180).timeout.connect(func():
		push_error("PRE_M4_PHYSICAL incomplete helper")
		quit(3))
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--evidence-dir="): evidence_dir=arg.trim_prefix("--evidence-dir=")
	if not evidence_dir.is_absolute_path():
		quit(1)
		return
	var wing: Node3D=load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	var scenario: Dictionary=load("res://gameplay/run/run_scenario.gd").new().default_definition()
	scenario.events=[]
	wing.configure_new_run(scenario)
	wing.get_node("Player").enable_held_item_view=false
	root.add_child(wing)
	wing.set_process(false)
	wing.get_node("Player").set_physics_process(false)
	await process_frame
	await physics_frame
	var surfaces: Array=wing.get_functional_surfaces()
	_check(surfaces.size()==16,"production wing retains sixteen ordinary surfaces")
	var inventory: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tools/asset_pipeline/props_inventory.json"))
	var catalogue: ItemCatalog=load(CATALOG_PATH)
	var results: Array[Dictionary]=[]
	var selected_id:=""
	var followup := OS.get_cmdline_user_args().has("--followup")
	var followup_ids := ["loot_000025", "loot_000027", "loot_000075", "loot_000129", "loot_000141", "loot_000152", "loot_000153", "loot_000154", "loot_000155"]
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--item-id="): selected_id=arg.trim_prefix("--item-id=")
	for record: Dictionary in inventory.models:
		if followup:
			if not record.item_id in followup_ids: continue
		elif record.disposition!="new": continue
		if not selected_id.is_empty() and record.item_id!=selected_id: continue
		var definition:=catalogue.get_definition_by_id(StringName(record.item_id))
		var item:=ItemInstance.new(definition,"physical:"+record.item_id)
		var measurement:=StorageVisualPose.measure_item(item,false)
		var size: Vector3=measurement.posed_bounds.size
		_check(measurement.valid and size.is_finite() and size.x>0 and size.y>0 and size.z>0,"Finite nonempty posed bounds "+record.item_id)
		if record.has("human_review"):
			var saved: Array = record.human_review.storage_footprint
			_check(definition.storage_footprint == Vector3i(saved[0], saved[1], saved[2]), "Saved human Footprint preserved " + record.item_id)
		else:
			_check(definition.storage_footprint.x==maxi(1,ceili(size.x/0.10)) and definition.storage_footprint.y==maxi(1,ceili(size.z/0.10)),"Workbench footprint convention "+record.item_id)
		var carry:=CarriedItems.new()
		root.add_child(carry)
		var controller:=StoragePlacementController.new()
		root.add_child(controller)
		controller.configure(null,carry,2.3)
		var host:=Node3D.new()
		root.add_child(host)
		host.add_child(definition.visual_scene.instantiate())
		var loose:=WorldItem.new()
		host.add_child(loose)
		loose.configure_existing(host,item)
		_check(loose.pickup_into(carry) and carry.get_selected_item()==item,"Actual loose TAKE preserves identity "+record.item_id)
		var compatible: StorageSurface=null
		var chosen: Dictionary={}
		for surface: StorageSurface in surfaces:
			surface.set_zone_rect("General",Vector2i.ZERO,surface.grid_size)
			var orientations: Array=controller.call("_entry_orientations_for_item",item,surface.get_semantic_orientation_quarter_turns())
			var fit:=surface.find_zone_stack_or_empty_fit(item.get_storage_category(),orientations[0],orientations[1] if orientations.size()>1 else null)
			if fit.get("valid",false):
				compatible=surface
				chosen=fit
				break
		if compatible==null:
			blockers.append({"item_id":record.item_id,"reason":"No compatible production ordinary surface at proposed pose/footprint/clearance","size_m":[size.x,size.y,size.z]})
		else:
			controller.set("_current_surface",compatible)
			controller.set("_current_fit",chosen)
			controller.set("_manual_mode",false)
			_check(controller.place_selected(),"Production shelf store "+record.item_id)
			var stack:=compatible.get_storage_stack(item.instance_id)
			_check(stack!=null and stack.entries[0].item==item and carry.get_item_count()==0,"Exact stored identity "+record.item_id)
			if stack!=null:
				var entry=stack.entries[0]
				_check(entry.world_item.pickup_into(carry) and carry.get_selected_item()==item,"Actual shelf retrieve preserves identity "+record.item_id)
				_check(compatible.get_stack_count()==0,"Retrieval frees reservation "+record.item_id)
		results.append({"item_id":record.item_id,"size_m":[size.x,size.y,size.z],"footprint":[definition.storage_footprint.x,definition.storage_footprint.y],"surface":String(compatible.surface_id) if compatible else "NONE","packing_rotated":chosen.get("rotated",false)})
		results.back()["surface_clearance_m"] = compatible.stack_clearance_m if compatible != null else 0.0
		results.back()["horizontal_reservation_contains_bounds"] = size.x <= definition.storage_footprint.x * 0.10 and size.z <= definition.storage_footprint.y * 0.10
		controller.free()
		carry.free()
		await process_frame
		completed+=1
	_check(completed==((9 if followup else 120) if selected_id.is_empty() else 1),"All requested candidates reached physical completion")
	var file:=FileAccess.open(evidence_dir.path_join("physical-results.json" if selected_id.is_empty() else "physical-"+selected_id+".json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"items":results,"blockers":blockers},"\t",true))
	file.close()
	wing.free()
	_check(_pending_helpers==0,"No unfinished inherited helper")
	print("PRE_M4_PHYSICAL_COMPLETE candidates=",completed," ordinary_surface_blockers=",blockers.size()," failures=",int(_failed))
	quit(1 if _failed else 0)
