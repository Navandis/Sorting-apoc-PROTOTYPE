extends SceneTree

const CarriedItemsScript = preload("res://carried_items.gd")
const ItemInstanceScript = preload("res://item_instance.gd")
const PlayerControllerScript = preload("res://player_controller.gd")
const DeckSurfaceScript = preload("res://gameplay/logistics_wing/receiving/receiving_deck_surface.gd")
const StorageStackScript = preload("res://storage_stack.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")
const WorldItemScript = preload("res://world_item.gd")
const PersistentItemCatalog = preload("res://data/items/item_catalog.tres")
const ProofProfile = preload("res://data/receiving/receiving_deck_stage_b_proof.tres")

class RejectingSurface extends Node:
	func remove_stack_entry(_stack_id: String, _item_key: String) -> bool:
		return false

var _failures: int = 0
var _pending_helpers: int = 0


func _init() -> void:
	call_deferred("_run_suite")


func _run_suite() -> void:
	_pending_helpers += 1
	_test_private_surface_disables_player_storage_interaction()
	_test_world_item_reach_kinds_and_success_signal()
	await _test_real_camera_ray_uses_receiving_range()
	_pending_helpers -= 1
	_finish()


func _test_private_surface_disables_player_storage_interaction() -> void:
	_pending_helpers += 1
	var ordinary: StorageSurface = StorageSurfaceScript.new()
	root.add_child(ordinary)
	ordinary.configure(&"ordinary", 1.0, 1.0, 0.10, 1.0)
	_check(ordinary.is_player_storage_interaction_enabled(), "ordinary storage interaction remains enabled by default")
	var ordinary_area := ordinary.get_node_or_null("StorageInteractionArea") as Area3D
	_check(ordinary_area != null and ordinary_area.collision_layer == StorageSurfaceScript.STORAGE_INTERACTION_LAYER, "ordinary storage target layer remains unchanged")
	ordinary.set_player_storage_interaction_enabled(false)
	_check(not ordinary.is_player_storage_interaction_enabled(), "generic storage opt-out records disabled state")
	_check(ordinary_area.collision_layer == 0 and not ordinary_area.monitorable, "disabled storage area cannot be targeted")

	var private_surface = DeckSurfaceScript.new()
	root.add_child(private_surface)
	var spec: Resource = ProofProfile.get("surfaces")[0]
	_check(private_surface.configure_from_spec(spec, float(ProofProfile.get("cell_size_m"))), "private proof surface configures")
	var backend: StorageSurface = private_surface.get_storage_surface()
	_check(backend != null, "private wrapper owns an ordinary StorageSurface backend")
	if backend != null:
		_check(not backend.is_player_storage_interaction_enabled(), "private backend opts out of PUT targeting")
		_check(not backend.is_normal_debug_visible() and not backend.is_developer_debug_visible(), "private backend exposes no normal or F6 grid")
		_check(not backend.are_zones_initialized(), "private backend has no zones")
		var area := backend.get_node_or_null("StorageInteractionArea") as Area3D
		_check(area != null and area.collision_layer == 0 and not area.monitorable, "private interaction area stays non-targetable")
	private_surface.free()
	ordinary.free()
	_pending_helpers -= 1


func _test_world_item_reach_kinds_and_success_signal() -> void:
	_pending_helpers += 1
	var definition: ItemDefinition = PersistentItemCatalog.get_definition_by_id(&"loot_000030")
	var loose_context: Dictionary = _world_item_host(definition, "Loose")
	var loose: WorldItem = loose_context["world_item"] as WorldItem
	loose.configure(loose_context["host"] as Node3D, definition)
	_check(loose.get_pickup_reach_kind() == WorldItemScript.PickupReachKind.LOOSE, "configure defaults to LOOSE reach")
	(loose_context["host"] as Node3D).free()

	var stored_item: ItemInstance = ItemInstanceScript.new(definition, "stored:item")
	var rejecting := RejectingSurface.new()
	root.add_child(rejecting)
	var stored_context: Dictionary = _world_item_host(definition, "Stored")
	var stored: WorldItem = stored_context["world_item"] as WorldItem
	stored.configure_existing(stored_context["host"], stored_item, rejecting, "stored_stack", stored_item.instance_id)
	_check(stored.get_pickup_reach_kind() == WorldItemScript.PickupReachKind.STORAGE, "configure_existing defaults to STORAGE reach")
	var received_signals: Array[ItemInstance] = []
	stored.picked_up.connect(func(item: ItemInstance) -> void: received_signals.append(item))
	var carried := CarriedItemsScript.new()
	carried.max_bulk = 999
	root.add_child(carried)
	_check(not stored.pickup_into(carried), "failed storage removal rolls carried transfer back")
	_check(carried.get_item_count() == 0 and received_signals.is_empty(), "failed pickup emits no success signal")
	(stored_context["host"] as Node3D).free()
	rejecting.free()

	var private_surface = DeckSurfaceScript.new()
	root.add_child(private_surface)
	var spec: Resource = ProofProfile.get("surfaces")[0]
	_check(private_surface.configure_from_spec(spec, float(ProofProfile.get("cell_size_m"))), "pickup private surface configures")
	var backend: StorageSurface = private_surface.get_storage_surface()
	var receiving_item: ItemInstance = ItemInstanceScript.new(definition, "receiving:item")
	var receiving_context: Dictionary = _world_item_host(definition, "Receiving")
	var receiving: WorldItem = receiving_context["world_item"] as WorldItem
	var pose := preload("res://storage_visual_pose.gd").measure_item(receiving_item, false)
	var stack_entry = StorageStackScript.create_entry(receiving_item, Vector2i(2, 2), false, pose["aligned_bounds"])
	stack_entry.host = receiving_context["host"]
	stack_entry.world_item = receiving
	var fit: Dictionary = {
		"valid": true, "placement_kind": "empty", "stack_id": "MainDeck:stack_0000",
		"origin": Vector2i(0, 0), "footprint": Vector2i(2, 2), "rotated": false,
		"host_y_m": backend.get_local_placement_position(Vector2i(0, 0), Vector2i(2, 2)).y,
	}
	_check(backend.commit_stack_entry(stack_entry, fit), "real private stack entry commits")
	receiving.configure_receiving(receiving_context["host"], receiving_item, backend, "MainDeck:stack_0000", receiving_item.instance_id)
	_check(receiving.is_stored_item(), "Receiving member remains mechanically stored")
	_check(receiving.get_pickup_reach_kind() == WorldItemScript.PickupReachKind.RECEIVING, "Receiving reach is independent from storage ownership")
	var receiving_signals: Array[ItemInstance] = []
	receiving.picked_up.connect(func(item: ItemInstance) -> void: receiving_signals.append(item))
	_check(receiving.pickup_into(carried), "real Receiving pickup succeeds")
	_check(carried.get_selected_item() == receiving_item, "pickup transfers exact ItemInstance")
	_check(receiving_signals == [receiving_item], "success signal emits exact identity once")
	_check(backend.get_stack_count() == 0, "success removes private stack entry before notification returns")
	private_surface.free()
	carried.free()
	_pending_helpers -= 1


func _test_real_camera_ray_uses_receiving_range() -> void:
	_pending_helpers += 1
	var player: CharacterBody3D = PlayerControllerScript.new()
	player.name = "Player"
	player.set("prototype_auto_register_known_loot", false)
	player.set("print_loot_registration", false)
	player.set("enable_held_item_view", false)
	player.set("interaction_distance", 1.4)
	player.set("storage_interaction_distance", 2.3)
	player.set("receiving_interaction_distance", 3.0)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	player.add_child(camera)
	var carried := CarriedItemsScript.new()
	carried.name = "CarriedItems"
	carried.max_bulk = 999
	player.add_child(carried)
	root.add_child(player)

	var definition: ItemDefinition = PersistentItemCatalog.get_definition_by_id(&"loot_000001")
	var item: ItemInstance = ItemInstanceScript.new(definition, "ray:item")
	var rejecting := RejectingSurface.new()
	root.add_child(rejecting)
	var context: Dictionary = _box_world_item_host("ReceivingRayTarget")
	var host: Node3D = context["host"] as Node3D
	host.position = Vector3(0.0, 0.0, -2.6)
	root.add_child(host)
	var world_item: WorldItem = context["world_item"] as WorldItem
	world_item.configure_receiving(host, item, rejecting, "ray_stack", item.instance_id)
	await physics_frame
	await physics_frame
	_check(player.call("_get_looked_at_world_item") == world_item, "real camera ray reaches Receiving target beyond normal storage reach")
	player.set("receiving_interaction_distance", 2.0)
	_check(player.call("_get_looked_at_world_item") == null, "same Receiving hit is rejected beyond configured Receiving range")
	host.free()
	rejecting.free()
	player.free()
	_pending_helpers -= 1


func _world_item_host(definition: ItemDefinition, host_name: String) -> Dictionary:
	_pending_helpers += 1
	var host := Node3D.new()
	host.name = host_name
	root.add_child(host)
	var visual: Node = definition.visual_scene.instantiate()
	host.add_child(visual)
	var world_item: WorldItem = WorldItemScript.new()
	world_item.name = "WorldItem"
	host.add_child(world_item)
	_pending_helpers -= 1
	return {"host": host, "world_item": world_item}


func _box_world_item_host(host_name: String) -> Dictionary:
	_pending_helpers += 1
	var host := Node3D.new()
	host.name = host_name
	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.2, 0.2, 0.2)
	mesh_instance.mesh = box
	host.add_child(mesh_instance)
	var world_item: WorldItem = WorldItemScript.new()
	world_item.name = "WorldItem"
	host.add_child(world_item)
	_pending_helpers -= 1
	return {"host": host, "world_item": world_item}


func _check(condition: bool, message: String = "") -> bool:
	if not condition:
		_failures += 1
		var caller: Dictionary = get_stack()[1]
		push_error("FAILED: %s:%s %s" % [caller["function"], caller["line"], message])
	return condition


func _finish() -> void:
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving deck presenter tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving deck presenter tests")
	quit(0)
