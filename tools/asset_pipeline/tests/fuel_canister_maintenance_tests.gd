extends SceneTree

const Manifest = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const Catalog = preload("res://prototype_item_catalog.gd")
const Audit = preload("res://tools/asset_pipeline/loot_audit_core.gd")
const SOURCE := "res://assets/props/Fuel/SM_FuelCanister.glb"
const SHA := "f095c1ee2eb407ced7214686ba599207d3cbcae8cfbbb61ff0cf06242f54ef85"
var _failed := false


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var definition := Catalog.get_definition_by_id(&"loot_000015")
	_check(definition != null and definition.visual_scene.resource_path == SOURCE, "Fuel resolves through catalogue to exact source")
	_check(FileAccess.get_sha256(SOURCE) == SHA, "current source is measured maintenance export")
	_check(definition.storage_rotation_degrees == Vector3.ZERO and definition.storage_footprint == Vector3i(4, 2, 1), "approved zero pose and 4x2x1 preserved")
	_check(definition.can_be_stacked and not definition.can_support_stack and definition.auto_stack_group == &"", "approved stack roles and explicit None preserved")
	var record: Dictionary = Manifest.load_manifest("res://tools/asset_pipeline/item_authoring_review.json")["assets"]["loot_000015"]
	var evidence := Manifest.review_evidence(record, {"has_item_definition": true, "source_fingerprint": SHA, "storage_rotation_degrees": [0.0, 0.0, 0.0], "storage_footprint": [4, 2, 1], "can_be_stacked": true, "can_support_stack": false, "auto_stack_group": ""})
	for field: String in ["scale_review_current", "storage_pose_review_current", "footprint_review_current", "stack_role_review_current", "auto_group_review_current"]:
		_check(evidence[field], "Fuel freshness: " + field)
	var scene := (load("res://main.tscn") as PackedScene).instantiate()
	var player := scene.get_node("CharacterBody3D")
	player.set("enable_held_item_view", false)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	player.process_mode = Node.PROCESS_MODE_DISABLED
	var carried := player.get_node("CarriedItems") as CarriedItems
	var controller := player.get_node("StoragePlacementController") as StoragePlacementController
	var world := scene.get_node("SM_FuelCanister/WorldItem") as WorldItem
	var item := world.get_item_instance()
	_check(item.definition == definition, "legacy existing instance uses catalogue definition")
	var metrics := StorageVisualPose.measure_item(item, false)
	var bounds: AABB = metrics["aligned_bounds"]
	_check(bounds.size.distance_to(Vector3(0.315692, 0.428463, 0.150775)) < 0.00001, "current canonical dimensions match measured source")
	_check(bounds.position.distance_to(Vector3(-0.157846, 0.006, -0.075388)) < 0.00001, "seated bounds preserve 6mm clearance")
	var footprint := Audit.raw_footprint(bounds.size, 0.1)
	_check(footprint["width_cells"] == 4 and footprint["depth_cells"] == 2, "current geometry derives retained 4x2 footprint")
	print("FUEL_METRICS canonical=%s aligned=%s footprint=%s" % [metrics["posed_bounds"], bounds, footprint])
	_check(world.pickup_into(carried), "existing legacy Fuel picks up through WorldItem")
	_check(carried.get_selected_item() == item and carried.get_item_count() == 1, "carry owns exact instance once")
	var surface := scene.get_node("SM_MetalShelves/StorageSurface_01") as StorageSurface
	surface.set_zone_rect("Fuel", Vector2i.ZERO, surface.grid_size - Vector2i.ONE)
	for rotated: bool in [false, true]:
		var entry := controller.call("_entry_for_item", item, rotated) as StorageStack.Entry
		var fit := surface.find_manual_empty_fit(Vector3.ZERO, entry) if rotated else surface.find_zone_stack_or_empty_fit("Fuel", entry)
		_check(fit.get("footprint") == (Vector2i(2, 4) if rotated else Vector2i(4, 2)), "native/R90 packing selects approved orientation")
		_set_fit(controller, surface, fit, rotated, rotated)
		# Exercise the actual ghost construction path before final placement.
		controller.call("_update_ghost", item)
		var ghost := controller.get("_ghost_packing_root") as Node3D
		var ghost_transform := ghost.global_transform
		var ghost_bounds: AABB = ghost_transform * bounds
		_check(controller.place_selected(), "Fuel commits native auto or R90 manual fit")
		var stack := surface.get_storage_stack(item.instance_id)
		_check(stack != null, "Fuel creates one stored stack")
		if stack == null:
			break
		var stored := stack.entries[0]
		var packing := stored.host.get_node("StoredPackingYaw") as Node3D
		_check(packing.global_transform.is_equal_approx(ghost_transform), "actual ghost/final transforms match")
		_check((packing.global_transform * stored.aligned_bounds).is_equal_approx(ghost_bounds), "ghost/final seated bounds match")
		_check(stored.host.global_basis.get_scale().is_equal_approx(Vector3.ONE), "stored Fuel stays canonical world scale")
		_check(stored.item == item and carried.get_item_count() == 0, "storage conserves exact Fuel identity")
		print("FUEL_PATH mode=%s footprint=%s ghost_final_match=true world_bounds=%s instance_preserved=true" % ["manual_R90" if rotated else "auto_native", fit["footprint"], ghost_bounds])
		var can := ItemInstance.new(Catalog.get_definition_by_id(&"loot_000022"))
		var can_entry := controller.call("_entry_for_item", can, false) as StorageStack.Entry
		var rejected := surface.find_manual_stack_fit(item.instance_id, can_entry)
		_check(not rejected.get("valid", true), "Fuel cannot support a Soda Can even when its footprint fits")
		_check(stored.world_item.pickup_into(carried), "Fuel retrieves through stored WorldItem")
		_check(carried.get_selected_item() == item and surface.get_stack_count() == 0, "retrieval releases reservation without duplication")
		await process_frame
	# A real MedKit is wide enough and short enough to accept Fuel manually.
	var support := ItemInstance.new(Catalog.get_definition_by_id(&"loot_000028"))
	_check(carried.add_item(support), "support fixture enters carry")
	carried.select_index(1)
	var support_entry := controller.call("_entry_for_item", support, false) as StorageStack.Entry
	var support_fit := surface.find_manual_empty_fit(Vector3.ZERO, support_entry)
	_set_fit(controller, surface, support_fit, false)
	_check(controller.place_selected(), "real MedKit support commits")
	carried.select_index(0)
	var fuel_entry := controller.call("_entry_for_item", item, false) as StorageStack.Entry
	var auto_fit := surface.find_zone_stack_or_empty_fit("Fuel", fuel_entry)
	_check(auto_fit.get("placement_kind") == "empty", "explicit None prevents automatic group stacking")
	var supported_fit := surface.find_manual_stack_fit(support.instance_id, fuel_entry)
	_check(supported_fit.get("valid", false), "can_be_stacked permits Fuel on real adequate MedKit")
	_set_fit(controller, surface, supported_fit, false)
	_check(controller.place_selected(), "retrieved Fuel re-stores on legitimate support")
	var supported_stack := surface.get_storage_stack(support.instance_id)
	_check(supported_stack != null and supported_stack.entries.size() == 2, "support stack contains exactly MedKit plus Fuel")
	if supported_stack != null and supported_stack.entries.size() == 2:
		_check(supported_stack.entries[1].item == item, "supported re-store retains exact Fuel identity")
		_check(supported_stack.entries[1].world_item.pickup_into(carried), "supported Fuel retrieves")
	_check(carried.get_selected_item() == item, "final carried owner is original Fuel")
	await process_frame
	scene.free()
	current_scene = null
	if not _failed:
		print("PASS: fuel canister maintenance tests")
	quit(1 if _failed else 0)


func _set_fit(controller: StoragePlacementController, surface: StorageSurface, fit: Dictionary, rotated: bool, manual: bool = true) -> void:
	_check(fit.get("valid", false), "production fit is legal")
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", manual)
	controller.set("_rotated", rotated)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error("ASSERTION FAILED: " + message)
