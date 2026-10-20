extends SceneTree

const Adapter=preload("res://tools/asset_pipeline/props_catalogue.gd")
const Review=preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const INVENTORY="res://tools/asset_pipeline/props_inventory.json"
const RETIREMENTS="res://tools/asset_pipeline/retired_items.json"
const MANIFEST="res://tools/asset_pipeline/item_authoring_review.json"
const CATALOGUE="res://data/items/item_catalog.tres"

func _init() -> void:
	var apply:=OS.get_cmdline_user_args().has("--apply")
	var inventory: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(INVENTORY))
	var retired: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(RETIREMENTS))
	var manifest:=Review.load_manifest(MANIFEST)
	var catalogue: ItemCatalog=load(CATALOGUE)
	var errors:=Review.validate_manifest(manifest)
	var planned: Array[ItemDefinition]=[]
	var source_paths: Dictionary={}
	var ids: Dictionary={}
	for record: Dictionary in inventory.models:
		var path: String=record.source_path
		if source_paths.has(path): errors.append("Duplicate inventory source: "+path)
		source_paths[path]=true
		if Adapter.excluded(path,retired):
			if record.disposition!="retired": errors.append("Retirement disposition differs: "+path)
			continue
		if record.disposition=="exception": continue
		if ids.has(record.item_id): errors.append("Duplicate inventory identity: "+record.item_id)
		ids[record.item_id]=true
		if record.source_fingerprint!=Review.fingerprint_for_path(path): errors.append("Stale inventory source: "+path)
		var existing:=catalogue.get_definition_by_id(StringName(record.item_id))
		if existing!=null:
			if existing.visual_scene.resource_path!=path: errors.append("Identity mapping differs: "+record.item_id)
			continue # Never overwrite an existing definition or review decision.
		var definition_path: String=record.definition_path
		if FileAccess.file_exists(definition_path):
			errors.append("Unregistered existing definition requires inspection: "+definition_path)
			continue
		if not StorageCategories.is_item_category(record.storage_category) or record.item_id.trim_prefix("loot_").to_int()<=int(retired.highest_historically_allocated):
			errors.append("Invalid proposed category/identity: "+record.item_id)
			continue
		var definition:=Adapter.proposed_definition(record)
		if definition==null:
			errors.append("Invalid physical source: "+path)
			continue
		planned.append(definition)
	for path: String in Adapter.discover():
		if not source_paths.has(path): errors.append("Unaccounted model: "+path)
	if not errors.is_empty():
		for error: String in errors: push_error(error)
		quit(1)
		return
	if apply and not planned.is_empty():
		for definition: ItemDefinition in planned:
			var record: Dictionary=inventory.models.filter(func(r): return r.item_id==String(definition.item_id))[0]
			if ResourceSaver.save(definition,record.definition_path)!=OK:
				push_error("Definition save failed: "+record.definition_path)
				quit(1)
				return
			catalogue.definitions.append(load(record.definition_path))
			if not manifest.assets.has(record.item_id):
				var review:=Review.new_record(record)
				review.scale_review.notes="Machine proposal: measured imported scale unchanged. "+record.scale_notes
				review.storage_pose_review.notes="Machine proposal: "+record.pose_notes
				review.footprint_review.notes="Machine proposal: canonical X/Z bounds, ceil at 0.10 m, minimum one cell; human overrides pending."
				review.stack_role_review.notes="Machine proposal: "+record.stack_notes
				review.stack_role_review.flags=["VISUAL_REVIEW_RECOMMENDED"]
				review.auto_group_review.notes="Machine proposal: "+record.group_notes
				review.auto_group_review.flags=["VISUAL_REVIEW_RECOMMENDED"]
				manifest.assets[record.item_id]=review
		if ResourceSaver.save(catalogue,CATALOGUE)!=OK or not Review.write_manifest(MANIFEST,manifest):
			push_error("Catalogue/review save failed")
			quit(1)
			return
	print("PROPS_ONBOARDING_COMPLETE apply=",apply," additions=",planned.size()," total=",catalogue.definitions.size())
	quit()
