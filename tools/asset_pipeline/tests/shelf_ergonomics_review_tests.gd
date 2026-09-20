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
		_check((contract.get("unfitted_samples", []) as Array).is_empty(), "%s seats every review functional sample after the height amendment" % case_id)
		_check(int(contract.get("cabinet_take_sample_count", 0)) == 5, "%s presents five cabinet samples without cabinet storage" % case_id)
		_check(bool(contract.get("cabinet_samples_editor_authored", false)), "%s registers saved cabinet hosts without rearranging them" % case_id)
		_check(bool(contract.get("f6_enabled", false)), "%s permits only the F6 storage presentation" % case_id)
		_check(bool(contract.get("f7_disabled", false)), "%s keeps F7 disabled" % case_id)
		_check(is_equal_approx(float(contract.get("ceiling_y_m", 0.0)), 2.80 if case_id == "C" else 3.40), "%s has its specified local ceiling" % case_id)
		_check(is_equal_approx(float(contract.get("eye_height_m", 0.0)), 1.80), "%s starts at the 1.80 m review eye height" % case_id)
		_check(String(contract.get("eye_toggle", "")) == "F5", "%s exposes the review-only eye-height toggle" % case_id)
		_check(is_equal_approx(float(contract.get("metal_x_m", 0.0)), 10.10), "%s uses the corrected metal-shelf X placement" % case_id)
		_check(is_equal_approx(float(contract.get("metal_z_m", 0.0)), -10.95), "%s uses the corrected metal-shelf Z placement" % case_id)
		_assert_metal_fixture_clearance_and_coherence(scene, case_id)
		if case_id == "B" or case_id == "C":
			_check(float(contract.get("metal_top_y_m", 99.0)) <= 1.75, "%s metal top usable plane is within the revised trial cap" % case_id)
			_check(float(contract.get("metal_top_y_m", 0.0)) >= 1.65, "%s metal top usable plane is within the revised trial floor" % case_id)
			_check(float(contract.get("locker_top_y_m", 99.0)) <= 1.75, "%s locker top usable plane is within the revised trial cap" % case_id)
			_check(float(contract.get("locker_top_y_m", 0.0)) >= 1.65, "%s locker top usable plane is within the revised trial floor" % case_id)
			await _exercise_review_storage(scene, case_id)
		await _exercise_cabinet_take_pickup(scene, case_id)
		await _exercise_eye_toggle(scene, case_id)
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
		tall_entry != null and bool(narrow_surface.get_singleton_clearance_result(tall_entry, 0.0).get("valid", false)),
		"%s accepts the revised opening's credible tall-item fit" % case_id
	)


func _exercise_eye_toggle(scene: Node, case_id: String) -> void:
	var player := scene.get_node_or_null("Player") as Node3D
	var camera := scene.get_node_or_null("Player/Camera3D") as Camera3D
	var carried := scene.get_node_or_null("Player/CarriedItems") as CarriedItems
	_check(player != null and camera != null and carried != null and scene.has_method("toggle_review_eye_height"), "%s provides a player-preserving eye toggle" % case_id)
	if player == null or camera == null or carried == null or not scene.has_method("toggle_review_eye_height"):
		return
	var player_xz := Vector2(player.global_position.x, player.global_position.z)
	var view_basis := camera.global_basis
	var selected_item := carried.get_selected_item() as ItemInstance
	scene.call("toggle_review_eye_height")
	await process_frame
	var toggled: Dictionary = scene.call("get_review_contract") as Dictionary
	_check(is_equal_approx(float(toggled.get("eye_height_m", 0.0)), 1.716), "%s toggles to the existing approximately 1.71 m eye height" % case_id)
	_check(Vector2(player.global_position.x, player.global_position.z).is_equal_approx(player_xz), "%s preserves player X/Z during eye toggle" % case_id)
	_check(camera.global_basis.is_equal_approx(view_basis), "%s preserves viewing direction during eye toggle" % case_id)
	_check(carried.get_selected_item() == selected_item, "%s preserves carried item state during eye toggle" % case_id)


func _exercise_cabinet_take_pickup(scene: Node, case_id: String) -> void:
	var carried := scene.get_node_or_null("Player/CarriedItems") as CarriedItems
	var samples := scene.get_node_or_null("CabinetTakeSamples") as Node3D
	_check(carried != null and samples != null and samples.has_method("get_active_hosts"), "%s exposes saved cabinet TAKE hosts" % case_id)
	if carried == null or samples == null or not samples.has_method("get_active_hosts"):
		return
	var hosts: Array = samples.call("get_active_hosts") as Array
	var host := hosts[2] as Node3D if hosts.size() > 2 else null
	var world := host.get_node_or_null("WorldItem") as WorldItem if host != null else null
	var item := world.get_item_instance() as ItemInstance if world != null else null
	_check(world != null and item != null, "%s active cabinet host has an ordinary WorldItem" % case_id)
	if world == null or item == null:
		return
	_check(world.pickup_into(carried), "%s picks up a cabinet sample through WorldItem" % case_id)
	_check(carried.get_selected_item() == item, "%s cabinet pickup preserves exact item identity" % case_id)
	await process_frame


func _assert_metal_fixture_clearance_and_coherence(scene: Node, case_id: String) -> void:
	var metal := scene.get_node_or_null("ReviewFixtures/SM_MetalShelves_Ergonomics") as Node3D
	var collision := scene.get_node_or_null("ReviewFixtureCollision/SM_MetalShelves_Ergonomics_ReviewCollision") as StaticBody3D
	_check(metal != null and collision != null and scene.has_method("_global_bounds"), "%s has the complete moved metal fixture and collision" % case_id)
	if metal == null or collision == null or not scene.has_method("_global_bounds"):
		return
	var bounds := scene.call("_global_bounds", metal) as AABB
	_check(bounds.position.z > -12.85, "%s metal fixture clears Gallery B's north wall inner face" % case_id)
	var shape_node := collision.get_node_or_null("UnitScaleShape") as CollisionShape3D
	var box := shape_node.shape as BoxShape3D if shape_node != null else null
	_check(
		box != null and collision.global_position.is_equal_approx(bounds.get_center()) and box.size.is_equal_approx(bounds.size),
		"%s metal collision follows the moved fixture bounds" % case_id
	)
	var metal_surfaces := 0
	var metal_stored_samples := 0
	for value: Variant in scene.find_children("*", "StorageSurface", true, false):
		var surface := value as StorageSurface
		if surface == null or surface.get_parent() != metal:
			continue
		metal_surfaces += 1
		_check(bounds.has_point(surface.global_position), "%s metal support remains inside the moved fixture bounds" % case_id)
		for stack_value: Variant in (surface.get("_stacks") as Dictionary).values():
			metal_stored_samples += (stack_value as StorageStack).entries.size()
	_check(metal_surfaces == 4, "%s preserves all four moved metal supports" % case_id)
	_check(metal_stored_samples >= 2, "%s preserves the moved metal review samples" % case_id)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
