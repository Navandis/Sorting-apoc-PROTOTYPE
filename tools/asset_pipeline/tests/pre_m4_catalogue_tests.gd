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
	var review=load("res://tools/asset_pipeline/authoring_review_manifest.gd")
	var registry=load("res://tools/asset_pipeline/auto_stack_group_registry.gd").load_registry("res://tools/asset_pipeline/auto_stack_group_registry.json")
	check(review.validate_manifest(manifest).is_empty(),"Current review manifest schema")
	check(Catalog.get_validation_errors().is_empty(),"Unique ID and source mapping")
	check(Catalog.definitions.size()==167,"35 retained plus original 120 plus twelve authorized top-ups")
	check(adapter.discover().size()==inventory.models.size(),"Every source model accounted for")
	var counts: Dictionary={}
	var current_counts: Dictionary={"scale_review_current":0,"storage_pose_review_current":0,"footprint_review_current":0,"stack_role_review_current":0,"auto_group_review_current":0}
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
		if record.has("human_review"):
			check(record.human_review.display_name==definition.display_name,"Saved human display name: "+record.item_id)
			var rotation:=definition.storage_rotation_degrees
			var footprint:=definition.storage_footprint
			var asset: Dictionary={"source_fingerprint":record.source_fingerprint,"storage_rotation_degrees":[rotation.x,rotation.y,rotation.z],"storage_footprint":[footprint.x,footprint.y,footprint.z],"can_be_stacked":definition.can_be_stacked,"can_support_stack":definition.can_support_stack,"auto_stack_group":String(definition.auto_stack_group)}
			var evidence: Dictionary=review.review_evidence(manifest.assets[record.item_id],asset,registry)
			for field: String in current_counts:
				if evidence[field]: current_counts[field]+=1
				var confirmed: bool=record.disposition!="topup" or field in ["storage_pose_review_current","footprint_review_current","stack_role_review_current"]
				check(evidence[field]==confirmed,"Exact confirmed human review scope: "+record.item_id+" "+field)
		if record.disposition in ["new", "topup"]:
			check(definition.utility_id==&"None" and definition.utility_value==0 and definition.bulk==1,"Temporary numerical placeholders only")
			for field: String in ["scale_review","storage_pose_review","footprint_review","stack_role_review","auto_group_review"]:
				var status: String = manifest.assets[record.item_id][field].status
				if record.disposition=="topup":
					var confirmed: bool=field in ["storage_pose_review","footprint_review","stack_role_review"]
					check((status!="UNREVIEWED")==confirmed,"Top-up approval does not infer scale/group acceptance: "+record.item_id+" "+field)
				elif record.has("human_review") and record.review_status == "HUMAN_REVIEWED_2026_10_21":
					check(status in ["APPROVED", "DEFAULT_POSE_APPROVED", "CUSTOM_POSE_APPROVED", "GEOMETRY_APPROVED", "OVERRIDE_APPROVED"], "Explicit human decision reconciled: " + record.item_id + " " + field)
				else:
					check(status=="UNREVIEWED","Pending physical review is not approval: "+record.item_id+" "+field)
	check(counts=={"retained":35,"new":120,"topup":12,"retired":7},"Exact dispositions; original 120 remain historical additions")
	check(current_counts=={"scale_review_current":155,"storage_pose_review_current":167,"footprint_review_current":167,"stack_role_review_current":167,"auto_group_review_current":155},"Exact stage counts preserve 155 full approvals and twelve scoped reviews")
	check(Catalog.get_definition_by_id(&"loot_000081").display_name=="Watercooler Bottle" and Catalog.get_definition_by_id(&"loot_000110").display_name=="Revolver","Two pre-existing name-only corrections")
	check(adapter.next_sequence(Catalog,retired,manifest)==175,"High-water allocation continues beyond all twelve new reservations")
	var topup_sources := {
		163: ["Food/SM_MysteryMeat_Carcass_Large_01.glb", "Mystery Meat Large", "Food"],
		164: ["Fuel/SM_Charcoal_Bag_03.glb", "BBQ Charcoal Bag", "Fuel"],
		165: ["Fuel/SM_Lighter_Fluid_Can_02.glb", "Lighter Fluid Can", "Fuel"],
		166: ["Hydration/SM_6L_Water_Bottle_02.glb", "Water Bottle (6 L)", "Hydration"],
		167: ["Hydration/SM_Bottles_Crate_01.glb", "Soda Bottle Crate", "Hydration"],
		168: ["Hydration/SM_Juice_BagBox_01.glb", "Juice Bag-in-Box", "Hydration"],
		169: ["Hydration/SM_OJ_LargeJug_01.glb", "Orange Juice Jug", "Hydration"],
		170: ["Hydration/SM_Water_6Pack_03.glb", "Water Bottle Six-Pack", "Hydration"],
		171: ["protection/SM_Cosplay_helmet_01.glb", "Cosplay Helmet", "Protection"],
		172: ["protection/SM_Fedora_Hat_01.glb", "Fedora Hat", "Protection"],
		173: ["protection/SM_LeatherGloves_01.glb", "Leather Gloves", "Protection"],
		174: ["protection/SM_Wellies_01.glb", "Rubber Wellies", "Protection"]
	}
	for number: int in topup_sources:
		var definition:=Catalog.get_definition_by_id(StringName("loot_%06d" % number))
		check(definition!=null,"Authorized top-up resolves: %d" % number)
		if definition==null: continue
		var expected: Array=topup_sources[number]
		check(definition.visual_scene.resource_path=="res://assets/props/"+expected[0] and definition.display_name==expected[1] and definition.storage_category==expected[2],"Exact authorized identity/name/category: %d" % number)
		check(definition.auto_stack_group==&"" and definition.visual_scale==1.0,"Conservative explicit None group and untouched source scale: %d" % number)
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
	print("PRE_M4_REVIEW_CURRENT_COUNTS ",JSON.stringify(current_counts))
	print("PRE_M4_CATALOGUE_COMPLETE failures=", failures)
	quit(1 if failures else 0)
