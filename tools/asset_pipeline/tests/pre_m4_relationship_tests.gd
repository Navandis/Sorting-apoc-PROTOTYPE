extends "res://tools/asset_pipeline/tests/storage_stacking_interaction_tests.gd"

var capture_directory:=""

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--capture-dir="): capture_directory=arg.trim_prefix("--capture-dir=")
	_definitions=_definitions_by_id()
	var inventory: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tools/asset_pipeline/props_inventory.json"))
	var by_name: Dictionary={}
	for record: Dictionary in inventory.models:
		by_name[record.source_path.get_file().get_basename()]=record.item_id
	var context:=_context(Vector2i(15,15),1.5)
	var surface: StorageSurface=context.surface
	var controller: StoragePlacementController=context.controller
	var carry: CarriedItems=context.carried
	surface.set_zone_rect("General",Vector2i.ZERO,surface.grid_size)
	var base:=_item(StringName(by_name.SM_KB3D_HOH_VHS_A))
	_check(_place_auto(controller,carry,surface,base),"New VHS rests as flat-media base")
	var upper:=_item(&"loot_000031")
	_check(_place_auto(controller,carry,surface,upper),"Retained smaller CD auto-groups with new VHS")
	var stack:=surface.get_storage_stack(base.instance_id)
	_check(stack!=null and stack.entries.size()==2,"Heterogeneous new/retained media forms one legal stack")
	await capture_stack(surface,stack,"new-vhs-retained-cd")
	_free_context(context)
	context=_context(Vector2i(15,15),1.5)
	surface=context.surface
	controller=context.controller
	carry=context.carried
	surface.set_zone_rect("General",Vector2i.ZERO,surface.grid_size)
	var broad_support:=_item(StringName(by_name.SM_KB3D_LCA_Microwave_A_Main))
	_check(_place_auto(controller,carry,surface,broad_support),"New rigid appliance provides broad enough support")
	var ball:=_item(StringName(by_name.SM_KB3D_HOK_PropBasketball_01))
	var ball_entry=controller.call("_entry_for_item",ball,false)
	var support_entry=surface.get_storage_stack(broad_support.instance_id).entries[0]
	_check(StorageStack.footprint_fits(ball_entry.footprint,support_entry.footprint),"Ball horizontal footprint fits broad support; denial must exercise role")
	_check(not ball.definition.can_be_stacked and not surface.find_manual_stack_fit(broad_support.instance_id,ball_entry).valid,"Rounded non-stackable new ball denied atop otherwise compatible support")
	_free_context(context)
	context=_context(Vector2i(15,15),1.5)
	surface=context.surface
	controller=context.controller
	carry=context.carried
	surface.set_zone_rect("Food",Vector2i.ZERO,surface.grid_size)
	var can:=_item(StringName(by_name.SM_Dry_Goods_01h))
	_check(_place_auto(controller,carry,surface,can),"New rigid food can stores in category zone")
	var drink:=_item(&"loot_000022")
	_check(not _place_auto(controller,carry,surface,drink),"Matching round-can form cannot bypass category zone")
	carry.remove_item(drink)
	surface.set_zone_rect("General",Vector2i.ZERO,surface.grid_size)
	_check(_place_auto(controller,carry,surface,drink),"General permits compatible cross-category cans")
	stack=surface.get_storage_stack(can.instance_id)
	_check(stack!=null and stack.entries.size()==2,"New/retained round cans share legal support")
	await capture_stack(surface,stack,"new-food-can-retained-soda")
	surface.set_zone_rect("",Vector2i.ZERO,surface.grid_size)
	var extra:=_item(&"loot_000022")
	_check(not _place_auto(controller,carry,surface,extra),"Erased zone denies additional auto placement")
	carry.remove_item(extra)
	_check(stack.entries[0].world_item.pickup_into(carry),"Erased zoning preserves actual retrieval and base promotion")
	_free_context(context)
	context=_context(Vector2i(15,15),1.5)
	surface=context.surface
	controller=context.controller
	carry=context.carried
	surface.set_zone_rect("General",Vector2i.ZERO,surface.grid_size)
	var bottle:=_item(StringName(by_name.SM_KB3D_LCA_KetchupBottle_01))
	_check(_place_auto(controller,carry,surface,bottle),"New bottle has a resting base")
	var incoming:=_item(&"loot_000022")
	_check(not surface.find_manual_stack_fit(bottle.instance_id,controller.call("_entry_for_item",incoming,false)).valid,"Narrow capped bottle cannot support an upper can")
	_free_context(context)
	_check(_pending_helpers==0,"All relationship helpers completed")
	print("PRE_M4_RELATIONSHIPS_COMPLETE failures=",int(_failed))
	quit(1 if _failed else 0)

func capture_stack(surface: StorageSurface, stack: StorageStack, label: String) -> void:
	if capture_directory.is_empty(): return
	_check(capture_directory.is_absolute_path(),"External capture directory")
	if not capture_directory.is_absolute_path() or stack==null:return
	surface.set_debug_visible(false)
	var camera:=Camera3D.new()
	root.add_child(camera)
	var center: Vector3=stack.entries[0].host.global_position
	camera.position=center+Vector3(0.50,0.45,0.65)
	camera.look_at(center+Vector3(0,0.10,0))
	camera.current=true
	var light:=DirectionalLight3D.new()
	light.rotation_degrees=Vector3(-50,-25,0)
	root.add_child(light)
	var plane:=MeshInstance3D.new()
	plane.mesh=BoxMesh.new()
	plane.mesh.size=Vector3(1.5,0.02,1.5)
	root.add_child(plane)
	plane.position=surface.global_position-Vector3(0,0.01,0)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(capture_directory.path_join(label+".png"))
	camera.free()
	light.free()
	plane.free()
