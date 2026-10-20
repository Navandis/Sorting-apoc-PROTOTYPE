extends SceneTree

const Catalog = preload("res://data/items/item_catalog.tres")
const Retired: Array[int] = [5, 23, 24, 34, 36, 37, 42]
var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures+=1
		push_error(message)

func _init() -> void:
	for number: int in Retired:
		check(Catalog.get_definition_by_id(StringName("loot_%06d" % number))==null,"Retired identity still active: loot_%06d" % number)
	var adapter=load("res://tools/asset_pipeline/props_catalogue.gd")
	var inventory: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tools/asset_pipeline/props_inventory.json"))
	var retired: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tools/asset_pipeline/retired_items.json"))
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tools/asset_pipeline/item_authoring_review.json"))
	check(Catalog.get_validation_errors().is_empty(),"Unique ID and source mapping")
	check(Catalog.definitions.size()==155,"35 retained plus 120 new definitions")
	check(adapter.discover().size()==inventory.models.size(),"Every source model accounted for")
	var counts: Dictionary={}
	for record: Dictionary in inventory.models:
		counts[record.disposition]=int(counts.get(record.disposition,0))+1
		if record.disposition=="retired":
			check(adapter.excluded(record.source_path,retired),"Old GLB remains excluded even on disk")
			check(Catalog.get_definition_by_visual_path(record.source_path)==null,"Retired source has no active mapping")
			continue
		var definition: ItemDefinition=Catalog.get_definition_by_id(StringName(record.item_id))
		check(definition!=null,"Definition resolves "+record.item_id)
		if definition==null: continue
		check(definition.visual_scene.resource_path==record.source_path,"Exact source mapping "+record.item_id)
		if record.disposition=="new":
			check(definition.utility_id==&"None" and definition.utility_value==0 and definition.bulk==1,"Temporary numerical placeholders only")
			for field: String in ["scale_review","storage_pose_review","footprint_review","stack_role_review","auto_group_review"]:
				check(manifest.assets[record.item_id][field].status=="UNREVIEWED","Machine proposal is not approval: "+record.item_id+" "+field)
	check(counts=={"retained":35,"new":120,"retired":7},"Exact dispositions")
	var old_catalogue:=ItemCatalog.new()
	old_catalogue.definitions=[Catalog.get_definition_by_id(&"loot_000041")]
	check(adapter.next_sequence(old_catalogue,retired,{"assets":{}})==43,"Deleting highest old ID 42 never permits reuse")
	check(adapter.next_sequence(old_catalogue,retired,{"assets":{"loot_000170":{}}})==171,"Historical allocation higher than live catalogue remains reserved")
	var facade=load("res://prototype_item_catalog.gd")
	var pool=load("res://data/receiving/prototype_loot_pool.tres")
	check(pool.validate_against_catalog(Catalog).is_empty(),"Production pool resolves only retained catalogue members")
	check(pool.item_definition_ids.size()==35,"Production pool retains exactly 35 curated old members")
	var old_host:=Node3D.new()
	old_host.name="cereal_box_without_scene"
	check(facade.create_definition_for_node(old_host)==null,"Retired compatibility name cannot resurrect an item")
	old_host.free()
	print("PRE_M4_CATALOGUE_COMPLETE failures=", failures)
	quit(1 if failures else 0)
