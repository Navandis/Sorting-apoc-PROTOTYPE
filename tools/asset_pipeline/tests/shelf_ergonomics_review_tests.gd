extends SceneTree

const REVIEW_SCENE := "res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn"

var _failed := false


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	_check(ResourceLoader.exists(REVIEW_SCENE), "shelf ergonomics review scene exists")
	if not _failed:
		for case_id: String in ["A", "B", "C"]:
			await _check_case(case_id)
	if _failed:
		push_error("FAIL: shelf ergonomics review tests")
		quit(1)
		return
	print("PASS: shelf ergonomics review tests")
	quit(0)


func _check_case(case_id: String) -> void:
	var scene := (load(REVIEW_SCENE) as PackedScene).instantiate()
	scene.set("case_override", case_id)
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	_check(scene.has_method("get_review_contract"), "%s exposes a review contract" % case_id)
	if scene.has_method("get_review_contract"):
		var contract: Dictionary = scene.call("get_review_contract") as Dictionary
		_check(contract.get("case") == case_id, "%s selects the requested preset" % case_id)
		_check(contract.get("functional_family_count") == 2, "%s has metal and locker storage only" % case_id)
		_check(contract.get("cabinet_surface_count") == 0, "%s cabinet remains TAKE-only" % case_id)
		_check(contract.get("surface_count") == 8, "%s exposes four metal and four locker supports" % case_id)
		_check(bool(contract.get("surfaces_unit_scale", false)), "%s storage and stored hosts keep unit scale" % case_id)
		_check(int(contract.get("stored_sample_count", 0)) >= 2, "%s reserves representative functional samples through real storage" % case_id)
		_check(int(contract.get("cabinet_take_sample_count", 0)) == 5, "%s presents five cabinet samples without cabinet storage" % case_id)
		_check(bool(contract.get("f6_enabled", false)), "%s permits only the F6 storage presentation" % case_id)
		_check(bool(contract.get("f7_disabled", false)), "%s keeps F7 disabled" % case_id)
		_check(is_equal_approx(float(contract.get("ceiling_y_m", 0.0)), 2.80 if case_id == "C" else 3.40), "%s has its specified local ceiling" % case_id)
		if case_id == "B" or case_id == "C":
			_check(float(contract.get("locker_top_y_m", 99.0)) <= 1.45, "%s locker top usable plane is within the approved trial cap" % case_id)
			_check(float(contract.get("locker_top_y_m", 0.0)) >= 1.35, "%s locker top usable plane is within the approved trial floor" % case_id)
			await _exercise_review_storage(scene, case_id)
	scene.free()
	current_scene = null
	await process_frame


func _exercise_review_storage(scene: Node, case_id: String) -> void:
	var player := scene.get_node_or_null("Player")
	var carried := scene.get_node_or_null("Player/CarriedItems") as CarriedItems
	var controller := scene.get_node_or_null("Player/StoragePlacementController") as StoragePlacementController
	var surfaces := scene.find_children("*", "StorageSurface", true, false)
	_check(player != null and carried != null and controller != null, "%s has the normal player storage path" % case_id)
	if carried == null or controller == null:
		return
	var stored_world: WorldItem = null
	var stored_surface: StorageSurface = null
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if surface == null:
			continue
		for stack_value: Variant in (surface.get("_stacks") as Dictionary).values():
			var stack := stack_value as StorageStack
			if not stack.entries.is_empty():
				stored_world = stack.entries[0].world_item as WorldItem
				stored_surface = surface
				break
		if stored_world != null:
			break
	_check(stored_world != null, "%s has a real stored WorldItem to retrieve" % case_id)
	if stored_world == null or stored_surface == null:
		return
	var stored_item := stored_world.get_item_instance()
	_check(stored_world.pickup_into(carried), "%s retrieves its reserved review item through WorldItem" % case_id)
	_check(carried.get_selected_item() == stored_item, "%s retrieval preserves exact item identity" % case_id)
	var orientations: Array = controller.call("_entry_orientations_for_item", stored_item)
	stored_surface.set_zone_rect(stored_item.get_storage_category(), Vector2i.ZERO, stored_surface.grid_size - Vector2i.ONE)
	var alternate := orientations[1] as StorageStack.Entry if orientations.size() > 1 else null
	var fit := stored_surface.find_zone_stack_or_empty_fit(stored_item.get_storage_category(), orientations[0] as StorageStack.Entry, alternate)
	controller.set("_current_surface", stored_surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	_check(controller.place_selected(), "%s re-stores through the normal controller" % case_id)
	var tall := ItemInstance.new(load("res://data/items/definitions/loot_000032.tres") as ItemDefinition)
	var tall_entry := controller.call("_entry_for_item", tall, false) as StorageStack.Entry
	var narrow_surface := surfaces[1] as StorageSurface
	_check(
		tall_entry != null and not bool(narrow_surface.get_singleton_clearance_result(tall_entry, 0.0).get("valid", true)),
		"%s rejects a credible too-tall item in its compressed opening" % case_id
	)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
