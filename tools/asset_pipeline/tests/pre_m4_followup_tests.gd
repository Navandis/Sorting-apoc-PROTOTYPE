extends "res://tools/asset_pipeline/tests/pre_m4_relationship_tests.gd"

const FACTORS := {"loot_000025": 1.5, "loot_000027": 1.2, "loot_000075": 1.2, "loot_000129": 1.2, "loot_000141": 1.2}
const Review = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
var evidence_dir := ""

func _run() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--evidence-dir="): evidence_dir = arg.trim_prefix("--evidence-dir=")
		if arg.begins_with("--capture-dir="): capture_directory = arg.trim_prefix("--capture-dir=")
	if not evidence_dir.is_absolute_path():
		quit(2)
		return
	_definitions = _definitions_by_id()
	var reports: Array[Dictionary] = []
	for id: String in FACTORS:
		var definition: ItemDefinition = _definitions[id]
		var original := definition.duplicate() as ItemDefinition
		if original.get("visual_scale") != null: original.set("visual_scale", 1.0)
		var original_item := ItemInstance.new(original)
		var item := ItemInstance.new(definition)
		var before: AABB = StorageVisualPose.measure_item(original_item, false).posed_bounds
		var after: AABB = StorageVisualPose.measure_item(item, false).posed_bounds
		_check(after.size.is_equal_approx(before.size * FACTORS[id]), "Exact uniform runtime posed-bounds factor " + id)
		var workbench: Node3D = load("res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn").instantiate()
		workbench.item_definition = definition
		root.add_child(workbench)
		workbench.refresh_preview()
		var suggested := Vector2i(maxi(1, ceili(after.size.x / 0.10)), maxi(1, ceili(after.size.z / 0.10)))
		_check(workbench.get("_suggested_canonical_footprint") == suggested, "Workbench uses scaled measured geometry " + id)
		var preview_state := {"valid": false, "bounds": AABB()}
		StorageVisualPose._scan_bounds_recursive(workbench.get_node("ItemPreviewRoot"), Transform3D.IDENTITY, preview_state)
		_check((preview_state.bounds as AABB).size.is_equal_approx(after.size), "Workbench rendered geometry matches runtime bounds " + id)
		_check(bool(workbench.get_preview_contract().suggestion_exceeds_authored) == (id == "loot_000027"), "Workbench exposes reservation overhang " + id)
		workbench.free()
		# Ordinary editor-authored GLB host, including repeated registration.
		var host := Node3D.new()
		var raw := definition.visual_scene.instantiate() as Node3D
		host.add_child(raw)
		root.add_child(host)
		var raw_before := raw.scale
		var world := WorldItem.new()
		host.add_child(world)
		world.configure_existing(host, item)
		world.configure_existing(host, item)
		_check(raw.scale.is_equal_approx(raw_before * FACTORS[id]), "Loose authored GLB scaled exactly once " + id)
		var shape := world.get_node("PickupArea/PickupShape") as CollisionShape3D
		_check((shape.shape as BoxShape3D).size.is_equal_approx((world.get("_bounds") as AABB).size + Vector3.ONE * 0.025), "Pickup collider follows actual visual bounds " + id)
		host.free()
		var held := load("res://held_item_view.gd").new() as Node3D
		root.add_child(held)
		held.set_item(item)
		var preview := load("res://item_preview_3d.gd").new() as Control
		root.add_child(preview)
		preview.set_item(item)
		# Compare pre-fit/pre-framing bounds to source geometry, not screen pixels.
		var source_root := Node3D.new()
		source_root.add_child(original.visual_scene.instantiate())
		var state := {"valid": false, "bounds": AABB()}
		StorageVisualPose._scan_bounds_recursive(source_root, Transform3D.IDENTITY, state)
		var raw_expected: Vector3 = (state.bounds as AABB).size * FACTORS[id]
		_check((held.get("_bounds") as AABB).size.is_equal_approx(raw_expected), "Held pre-fit bounds " + id)
		_check((preview.get("_bounds") as AABB).size.is_equal_approx(raw_expected), "HUD pre-framing bounds " + id)
		var pile: Node3D = load("res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.gd").new()
		var body: RigidBody3D = pile.create_temporary_body(definition, "ScaledProof")
		var original_body: RigidBody3D = pile.create_temporary_body(original, "OriginalProof")
		_check(body != null and original_body != null, "Existing physics proof constructs scaled visual and hull " + id)
		if body != null and original_body != null:
			var hull: ConvexPolygonShape3D = body.get_node("PhysicsHull").shape
			var original_hull: ConvexPolygonShape3D = original_body.get_node("PhysicsHull").shape
			_check(_point_bounds(hull.points).size.is_equal_approx(_point_bounds(original_hull.points).size * FACTORS[id]), "Physics proof hull follows uniform geometry factor " + id)
			body.free()
			original_body.free()
		pile.free()
		source_root.free()
		held.free()
		preview.free()
		var context := _context(Vector2i(30, 30), 2.0)
		context.surface.set_zone_rect("General", Vector2i.ZERO, context.surface.grid_size)
		_check(_place_auto(context.controller, context.carried, context.surface, item), "Actual storage placement " + id)
		var stack: StorageStack = context.surface.get_storage_stack(item.instance_id)
		if stack != null:
			_check(stack.entries[0].aligned_bounds.size.is_equal_approx(after.size), "Stored bounds match scaled measurement " + id)
			_check(stack.entries[0].world_item.pickup_into(context.carried), "Actual retrieval " + id)
		_free_context(context)
		reports.append({"item_id": id, "factor": FACTORS[id], "before_m": _vec(before.size), "after_m": _vec(after.size), "suggested_footprint": [suggested.x, suggested.y], "authored_footprint": [definition.storage_footprint.x, definition.storage_footprint.y], "reservation_overhang_m": [maxf(0, after.size.x - definition.storage_footprint.x * 0.1), maxf(0, after.size.z - definition.storage_footprint.y * 0.1)], "required_clearance_m": after.size.y + StorageVisualPose.SHELF_CLEARANCE_M, "physical_review": "PENDING_HUMAN_RE_REVIEW"})
	await _test_clothing()
	var snapshots: RefCounted = load("res://gameplay/run/run_snapshot.gd").new()
	var fingerprint: String = snapshots.content_fingerprint()
	var scaled: ItemDefinition = _definitions["loot_000025"]
	var saved_factor: float = float(scaled.get("visual_scale"))
	scaled.set("visual_scale", saved_factor + 0.01)
	_check(snapshots.content_fingerprint() != fingerprint, "Continuation fingerprint includes authored scale")
	scaled.set("visual_scale", saved_factor)
	var file := FileAccess.open(evidence_dir.path_join("scaled-items.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(reports, "\t"))
	file.close()
	_check(_pending_helpers == 0, "All helpers completed")
	print("PRE_M4_FOLLOWUP_COMPLETE scaled=5 clothing=4 failures=", int(_failed))
	quit(1 if _failed else 0)

func _test_clothing() -> void:
	var context := _context(Vector2i(15, 15), 1.5)
	context.surface.set_zone_rect("General", Vector2i.ZERO, context.surface.grid_size)
	# Bundle first, then the three progressively compatible folded tops.
	var ids := [&"loot_000155", &"loot_000154", &"loot_000153", &"loot_000152"]
	var base: ItemInstance
	for id: StringName in ids:
		var item := _item(id)
		_check(item.definition.auto_stack_group == &"folded_clothing", "Approved clothing membership " + String(id))
		_check(_place_auto(context.controller, context.carried, context.surface, item), "Real automatic clothing insertion " + String(id))
		if base == null: base = item
	var stack: StorageStack = context.surface.get_storage_stack(base.instance_id)
	_check(stack != null and stack.entries.size() == 4, "Four actual clothing items form one mixed automatic stack")
	if stack != null:
		var clothing: Array[Dictionary] = []
		for index: int in stack.entries.size():
			var entry := stack.entries[index]
			clothing.append({"item_id": String(entry.item.definition.item_id), "footprint": [entry.footprint.x, entry.footprint.y], "bounds_m": _vec(entry.aligned_bounds.size), "host_y_m": stack.entry_host_y(index, 0.0)})
		_check(stack.current_top_y(0.0) <= 1.5, "Mixed clothing stack respects shelf clearance")
		var proof := FileAccess.open(evidence_dir.path_join("clothing-stack.json"), FileAccess.WRITE)
		proof.store_string(JSON.stringify({"entries": clothing, "top_y_m": stack.current_top_y(0.0), "clearance_limit_m": 1.5}, "\t"))
		proof.close()
		await capture_stack(context.surface, stack, "folded-clothing-mixed")
		var unrelated := _item(&"loot_000031")
		_check(not stack.find_auto_insertion([context.controller._entry_for_item(unrelated, false)], 1.5, 0.0).valid, "Unrelated group cannot automatically join clothing")
		var denied := _item(&"loot_000152")
		var denied_def := denied.definition.duplicate() as ItemDefinition
		denied_def.can_be_stacked = false
		denied.definition = denied_def
		_check(not context.surface.find_manual_stack_fit(base.instance_id, context.controller._entry_for_item(denied, false)).valid, "Membership never overrides resting role")
		var legal: StorageStack.Entry = context.controller._entry_for_item(_item(&"loot_000152"), false)
		var no_support := _context(Vector2i(10, 10), 1.5)
		no_support.surface.set_zone_rect("General", Vector2i.ZERO, no_support.surface.grid_size)
		var support_denied := _item(&"loot_000152")
		support_denied.definition = support_denied.definition.duplicate() as ItemDefinition
		support_denied.definition.can_support_stack = false
		_check(_place_auto(no_support.controller, no_support.carried, no_support.surface, support_denied), "Non-supporting clothing still rests on an empty shelf")
		var singleton: StorageStack = no_support.surface.get_storage_stack(support_denied.instance_id)
		_check(not singleton.find_auto_insertion([legal], 1.5, 0.0).valid, "Same group cannot append above non-supporting singleton")
		_free_context(no_support)
		legal.footprint = Vector2i(20, 20)
		_check(not stack.find_auto_insertion([legal], 1.5, 0.0).valid, "Same group cannot bypass horizontal physical fit")
		var low := _context(Vector2i(4, 4), 0.01)
		low.surface.set_zone_rect("General", Vector2i.ZERO, low.surface.grid_size)
		_check(not _place_auto(low.controller, low.carried, low.surface, denied) and low.carried.get_selected_item() == denied and low.surface.get_stack_count() == 0, "Failed clearance preserves exact carried item")
		_free_context(low)
	_free_context(context)

func _vec(v: Vector3) -> Array:
	return [v.x, v.y, v.z]

func _point_bounds(points: PackedVector3Array) -> AABB:
	var bounds := AABB(points[0], Vector3.ZERO)
	for point: Vector3 in points: bounds = bounds.expand(point)
	return bounds
