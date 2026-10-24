extends SceneTree
var failures := 0
func _init() -> void:
	create_timer(240).timeout.connect(func():
		push_error("M4 seed access helper incomplete")
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func run() -> void:
	var wing = load("res://gameplay/logistics_wing/wing_gameplay.tscn").instantiate()
	wing.configure_new_run()
	wing.set_process(false)
	wing.get_node("Player").enable_held_item_view = false
	root.add_child(wing)
	await physics_frame
	await physics_frame
	var player = wing.get_node("Player")
	player.set_physics_process(false)
	var carry: CarriedItems = player.carried_items
	var surfaces: Array = wing.get_functional_surfaces().filter(func(s): return not s._stacks.is_empty())
	var center := Vector3.ZERO
	var count := 0
	for surface: StorageSurface in surfaces:
		for stack: StorageStack in surface._stacks.values():
			for entry: StorageStack.Entry in stack.entries:
				center += entry.host.global_position
				count += 1
	center /= count
	var normal: Vector3 = surfaces[0].global_basis * StorageOrientation.front_local_axis(surfaces[0].get_semantic_orientation_quarter_turns())
	normal = normal.normalized()
	var lateral := normal.cross(Vector3.UP).normalized()
	var taken: Array[String] = []
	var blockers: Array[String] = []
	while taken.size() < 85:
		var candidate: Dictionary = {}
		var remaining: Array[WorldItem] = []
		for surface: StorageSurface in surfaces:
			for stack: StorageStack in surface._stacks.values(): remaining.append(stack.entries[-1].world_item)
		for world: WorldItem in remaining:
			var target: Vector3 = world.get_node("PickupArea/PickupShape").global_position
			for offset: float in [-0.8,0.0,0.8]:
				var stance := center + normal*1.2 + lateral*offset
				stance.y = 0.05
				player.global_position = stance
				player.velocity = Vector3.ZERO
				player.camera.look_at(target)
				if player._get_looked_at_world_item() == world:
					var distance: float = player.camera.global_position.distance_to(target)
					if candidate.is_empty() or distance < candidate.distance: candidate = {"world":world,"stance":stance,"target":target,"distance":distance}
		if candidate.is_empty():
			for world: WorldItem in remaining: blockers.append(String(world.get_item_instance().definition.item_id)+":"+world.get_item_instance().instance_id)
			check(false,"No production storage ray exposes remaining seeded items: " + str(blockers))
			break
		var world: WorldItem = candidate.world
		var item: ItemInstance = world.get_item_instance()
		player.global_position = candidate.stance
		player.camera.look_at(candidate.target)
		player._attempt_pickup_click()
		if carry.get_selected_item() != item:
			check(false,"Production seeded TAKE failed: " + item.instance_id)
			break
		taken.append(item.instance_id)
		carry.remove_item(item) # Inspected fixture supply only, no developer save.
		await physics_frame
	check(taken.size() == 85 and carry.max_bulk == 20 and player.storage_interaction_distance == 2.3,"All 85 seed identities progressively accessible through unchanged production rays/reach and carrying")
	wing.free()
	print("M4_SEED_ACCESS_COMPLETE takes=",taken.size()," blockers=",blockers," failures=",failures)
	quit(1 if failures else 0)
