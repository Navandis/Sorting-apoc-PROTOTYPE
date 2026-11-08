extends SceneTree

const SHELL = preload("res://gameplay/run/run_shell.tscn")
const SAVE = preload("res://gameplay/run/run_save_service.gd")
const WING = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
const SNAPSHOT = preload("res://gameplay/run/run_snapshot.gd")
const FURNITURE := [
	"DevelopmentSetup/Tables/SM_Table_SeedWest",
	"DevelopmentSetup/Tables/SM_Table_SeedEast",
	"DevelopmentSetup/Tables/SM_Table_Palette_Food",
	"DevelopmentSetup/Tables/SM_Table_Palette_Hydration",
	"FunctionalFixtures/SM_ventilated_locker_GalleryC_West",
	"FunctionalFixtures/SM_MetalShelves_GalleryA_West",
	"FunctionalFixtures/SM_MetalShelves_GalleryB_North",
]
const RACK := "FunctionalFixtures/ModularRack_GalleryB_Initial"
const SIDES := [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
const CORNERS := [Vector3(-1, 0, -1), Vector3(1, 0, -1), Vector3(-1, 0, 1), Vector3(1, 0, 1)]

var failures := 0
var shell: Node
var stored: Dictionary = {}

func _initialize() -> void:
	create_timer(120).timeout.connect(func(): quit(3))
	run.call_deferred()

func run() -> void:
	var saves := OS.get_temp_dir().path_join("furniture-proof-" + Crypto.new().generate_random_bytes(8).hex_encode())
	shell = SHELL.instantiate()
	shell.save_service = SAVE.new(saves)
	root.add_child(shell)
	shell.set_process(false)
	if not check(shell.start_new_run(), "F5 New Run publishes its isolated wing"):
		finish()
		return
	await probe_wing(shell.wing, "New Run")
	await check_interactions(shell.wing)
	var before := SNAPSHOT.new().capture(shell.wing)
	if not check(shell.save_and_exit() and shell.continue_run(), "F5 Continue reconstructs its isolated wing"):
		finish()
		return
	await probe_wing(shell.wing, "Continue")
	check(SNAPSHOT.new().capture(shell.wing) == before, "Continue preserves exact saved organization, stock, goals and player pose")
	await retrieve_after_continue(shell.wing)
	if DisplayServer.get_name() != "headless":
		await native_walk(shell.wing, FURNITURE[0], Vector3.FORWARD, "table")
		await native_walk(shell.wing, FURNITURE[5], Vector3.RIGHT, "shelf")
	check(shell.save_and_exit(), "release the isolated F5 wing before checking visible F6")
	var standalone := WING.instantiate()
	root.add_child(standalone)
	await probe_wing(standalone, "Visible F6")
	standalone.free()
	finish()

func probe_wing(wing: Node3D, stage: String) -> void:
	var player := wing.get_node("Player") as CharacterBody3D
	player.set_physics_process(false)
	player.set_process(false)
	wing.set_process(false)
	await physics_frame
	await physics_frame
	var corner_checks := 0
	for path: String in FURNITURE + [RACK]:
		var unit := wing.get_node_or_null(path) as Node3D
		if not check(unit != null, stage + " has " + path):
			continue
		var bounds := visual_bounds(unit)
		var bodies := blocking_shapes(unit, player)
		var tested := 0
		var blocked := 0
		var side_clear := false
		for direction: Vector3 in SIDES + CORNERS:
			var sample := approach(player, bounds, direction)
			if sample.is_empty():
				continue
			var hit: Node = sample.collider
			# Another fixture or wall in this direction makes the approach inaccessible.
			if hit != null and not unit.is_ancestor_of(hit):
				print("OBSTRUCTED ", stage, " ", unit.name, " direction=", direction, " by=", hit.get_path())
				continue
			tested += 1
			if direction.length_squared() > 1.0:
				corner_checks += 1
			else:
				var tangent := direction.cross(Vector3.UP) * 0.22
				var pose := Transform3D(Basis.IDENTITY, sample.stance)
				side_clear = side_clear or not player.test_move(pose, tangent) or not player.test_move(pose, -tangent)
			if hit != null:
				blocked += 1
			print("BODY ", stage, " ", unit.name, " direction=", direction, " travel=", sample.travel,
				" requested=", sample.motion.length(), " blocks=", hit != null)
		print("FIXTURE ", stage, " ", path, " bounds=", bounds, " blocking_shapes=", bodies,
			" approaches=", tested, " stopped=", blocked, " player_mask=", player.collision_mask)
		check(tested > 0 and blocked == tested, stage + " player capsule stops at " + path)
		check(bodies == 1, stage + " has one enabled movement shape for " + path)
		check(side_clear, stage + " leaves walking space beside " + path)
	check(corner_checks > 0, stage + " covers accessible diagonal approaches")
	var ladder := wing.get_node("FunctionalFixtures/FixedLadder_GalleryB_Initial/MovementCollision")
	check(approach(player, visual_bounds(wing.get_node(RACK)), Vector3.RIGHT).get("collider") == ladder,
		stage + " retains the ladder-side movement blocker")
	var barrier := wing.get_node("ReceivingLiftInstallation/BarrierCollision/Shape") as CollisionShape3D
	var barrier_size: Vector3 = (barrier.shape as BoxShape3D).size
	var barrier_bounds := barrier.global_transform * AABB(-barrier_size * 0.5, barrier_size)
	check(approach(player, barrier_bounds, Vector3.RIGHT).get("collider") == barrier.get_parent(),
		stage + " retains the Receiving barrier")
	# Exercise repeated initialization of the two owners after publication.
	wing.get_node("FunctionalFixtures")._ready()
	wing.get_node("DevelopmentSetup/Tables")._ready()
	for path: String in FURNITURE:
		check(blocking_shapes(wing.get_node(path), player) == 1, stage + " repeated setup adds no duplicate blocker for " + path)

func visual_bounds(unit: Node3D) -> AABB:
	var result := AABB()
	for mesh: MeshInstance3D in unit.find_children("*", "MeshInstance3D", true, false):
		if not mesh.is_visible_in_tree() or mesh.mesh == null:
			continue
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		result = box if not result.has_volume() else result.merge(box)
	return result

func blocking_shapes(unit: Node3D, player: CharacterBody3D) -> int:
	var total := 0
	for shape: CollisionShape3D in unit.find_children("*", "CollisionShape3D", true, false):
		var body := shape.get_parent() as StaticBody3D
		if body != null and body.collision_layer & player.collision_mask and not shape.disabled and shape.shape != null:
			total += 1
	return total

func approach(player: CharacterBody3D, bounds: AABB, direction: Vector3) -> Dictionary:
	var center := bounds.get_center()
	center.y = 0.04
	var extent := bounds.size * 0.5
	var offset := Vector3(direction.x * extent.x, 0.0, direction.z * extent.z)
	var stance := center + offset + direction.normalized() * 0.52
	var pose := Transform3D(Basis.IDENTITY, stance)
	if not can_stand(player, stance):
		return {}
	var result := KinematicCollision3D.new()
	var motion := center - stance
	var hit := player.test_move(pose, motion, result)
	return {"stance": stance, "motion": motion, "collider": result.get_collider() if hit else null,
		"travel": result.get_travel().length() if hit else motion.length()}

func can_stand(player: CharacterBody3D, stance: Vector3) -> bool:
	var ground := PhysicsRayQueryParameters3D.create(stance + Vector3.UP * 0.20, stance - Vector3.UP * 0.20, player.collision_mask, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(ground)
	return not hit.is_empty() and absf(hit.position.y) <= 0.05 \
		and not player.test_move(Transform3D(Basis.IDENTITY, stance), Vector3.ZERO, null, 0.001, true)

func aim_from_side(player: CharacterBody3D, bounds: AABB, target: Vector3, outward: Vector3) -> bool:
	var stance := Vector3(target.x, 0.04, target.z)
	if outward.x != 0:
		stance.x = (bounds.end.x if outward.x > 0 else bounds.position.x) + outward.x * 0.43
	else:
		stance.z = (bounds.end.z if outward.z > 0 else bounds.position.z) + outward.z * 0.43
	if not can_stand(player, stance):
		return false
	player.global_position = stance
	player.camera.look_at(target)
	return true

func check_interactions(wing: Node3D) -> void:
	var player := wing.get_node("Player") as CharacterBody3D
	var carry: CarriedItems = player.carried_items
	var goal: RefCounted = wing.collection_goal
	var expected: Dictionary = goal.totals.duplicate()
	var seeds := wing.get_node("DevelopmentSetup/SeedItems")
	for path: String in FURNITURE.slice(0, 4):
		var bounds := visual_bounds(wing.get_node(path))
		check(take_from_table(player, seeds, bounds), "outside reticle takes loose stock at " + path)
	check(goal.totals == expected, "collision and carrying alone add no goal credit")
	var placement: StoragePlacementController = player._storage_placement
	for path: String in FURNITURE.slice(4):
		var unit := wing.get_node(path)
		var bounds := visual_bounds(unit)
		var item := carry.get_selected_item() as ItemInstance
		if not check(item != null, "a picked-up item is available for " + path):
			continue
		var placed := false
		for surface: StorageSurface in wing.get_functional_surfaces():
			if not unit.is_ancestor_of(surface):
				continue
			surface.initialize_zones_if_needed(StorageCategories.GENERAL)
			var grid := surface.get_grid_size()
			for outward: Vector3 in SIDES:
				if not aim_from_side(player, bounds, surface.global_position, outward) \
						or player._get_looked_at_storage_surface() != surface:
					continue
				placement.set_suppressed(false)
				placement.update_target()
				if placement.place_selected():
					expected[item.get_storage_category()] += item.get_utility_value()
					stored[path] = {"surface": wing.get_path_to(surface), "id": item.instance_id, "outward": outward, "grid": grid}
					check(surface.get_grid_size() == grid and surface.get_stored_items().has(item), "exact item and grid at " + path)
					print("STORE ", path, " surface=", surface.surface_id, " grid=", grid)
					placed = true
					break
			if placed:
				break
		check(placed, "outside reticle automatically places on " + path)
	await physics_frame
	check(goal.totals == expected and stored.size() == 3, "only the three ordinary storage transfers add goal credit")

func take_from_table(player: CharacterBody3D, seeds: Node, bounds: AABB) -> bool:
	for world: WorldItem in seeds.find_children("*", "WorldItem", true, false):
		var shape := world.get_node("PickupArea/PickupShape") as CollisionShape3D
		var at := shape.global_position
		if not bounds.grow(0.05).has_point(Vector3(at.x, bounds.get_center().y, at.z)):
			continue
		var item := world.get_item_instance()
		for outward: Vector3 in SIDES:
			if aim_from_side(player, bounds, at, outward) and player._get_looked_at_world_item() == world:
				player._attempt_pickup_click()
				if player.carried_items.get_items().has(item):
					print("TAKE ", item.get_display_name(), " from ", bounds.get_center())
					return true
	return false

func retrieve_after_continue(wing: Node3D) -> void:
	var player := wing.get_node("Player") as CharacterBody3D
	for path: String in stored:
		var record: Dictionary = stored[path]
		var surface := wing.get_node(record.surface) as StorageSurface
		var stack := surface.get_storage_stack(surface.get_stack_id_for_item(record.id))
		if not check(stack != null and surface.get_grid_size() == record.grid, "Continue restores grid and stored identity at " + path):
			continue
		var entry: StorageStack.Entry = stack.entries[0]
		var world := entry.world_item as WorldItem
		var shape := world.get_node("PickupArea/PickupShape") as CollisionShape3D
		var bounds := visual_bounds(wing.get_node(path))
		var took := false
		for outward: Vector3 in [record.outward] + SIDES:
			if aim_from_side(player, bounds, shape.global_position, outward) and player._get_looked_at_world_item() == world:
				player._attempt_pickup_click()
				took = player.carried_items.get_items().has(entry.item)
				break
		check(took, "outside reticle retrieves exact restored item at " + path)
		await physics_frame
	check(wing.collection_goal.totals.values().all(func(value: int): return value == 0), "retrieval removes the stored goal credit")

func native_walk(wing: Node3D, path: String, outward: Vector3, label: String) -> void:
	var player := wing.get_node("Player") as CharacterBody3D
	var unit := wing.get_node(path) as Node3D
	var sample := approach(player, visual_bounds(unit), outward)
	if not check(not sample.is_empty() and sample.collider != null and unit.is_ancestor_of(sample.collider), "native test finds supported " + label + " approach"):
		return
	var start: Vector3 = sample.stance
	player.global_position = start
	player.velocity = Vector3.ZERO
	player.look_at(start - outward)
	player.camera.rotation = Vector3(-0.72 if label == "table" else -0.12, 0, 0)
	player.set_physics_process(true)
	var key := InputEventKey.new()
	key.keycode = KEY_W
	key.pressed = true
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	for index in range(36):
		await physics_frame
	key = key.duplicate()
	key.pressed = false
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	player.set_physics_process(false)
	var advance := (start - player.global_position).dot(outward)
	check(advance > 0.08 and advance <= float(sample.travel) + 0.04, "native W moves and stops at " + label)
	print("NATIVE WALK ", label, " forward_m=", advance, " sweep_m=", sample.travel)
	var output := OS.get_environment("SORTING_FURNITURE_CAPTURE_DIR")
	if not output.is_empty():
		await process_frame
		await RenderingServer.frame_post_draw
		check(root.get_texture().get_image().save_png(output.path_join(label + "-movement.png")) == OK, "captured native " + label + " stop")

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok

func finish() -> void:
	shell.free()
	print("furniture_movement_collision_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)
