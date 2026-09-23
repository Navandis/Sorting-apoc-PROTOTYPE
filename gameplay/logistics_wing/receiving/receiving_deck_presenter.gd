extends Node3D
class_name ReceivingDeckPresenter

const DeckItemPoseScript = preload("res://receiving/receiving_deck_item_pose.gd")
const DeckProfileScript = preload("res://receiving/receiving_deck_profile.gd")
const DeckSurfaceScript = preload("res://gameplay/logistics_wing/receiving/receiving_deck_surface.gd")
const StorageStackScript = preload("res://storage_stack.gd")
const WorldItemScript = preload("res://world_item.gd")

enum PresentationState {
	HIDDEN,
	AVAILABLE,
	DRAINED_WAITING_CLOSE,
}

var _manager: ReceivingManager = null
var _catalog: ItemCatalog = null
var _profile: Resource = null
var _state: PresentationState = PresentationState.HIDDEN
var _surface_wrappers: Dictionary = {}
var _world_items_by_entry_id: Dictionary = {}
var _released_callbacks: Dictionary = {}


func configure(manager: ReceivingManager, catalog: ItemCatalog, profile: Resource) -> bool:
	if (
		manager == null
		or catalog == null
		or profile == null
		or profile.get_script() != DeckProfileScript
		or not (profile.call("validate") as PackedStringArray).is_empty()
		or not catalog.get_validation_errors().is_empty()
	):
		return false
	_disconnect_manager()
	_manager = manager
	_catalog = catalog
	_profile = profile
	_manager.active_batch_changed.connect(_on_active_batch_changed)
	_manager.active_batch_drained.connect(_on_active_batch_drained)
	return _rebuild_private_surfaces()


func present_active_batch() -> bool:
	if _manager == null or _profile == null or _catalog == null:
		return false
	var batch: LootBatch = _manager.get_active_batch()
	if (
		batch == null
		or batch.preparation_state != LootBatch.STATE_PREPARED
		or batch.presentation_profile_id != _profile.get("profile_id")
		or batch.presentation_profile_revision != int(_profile.get("revision"))
	):
		return false
	if not _rebuild_private_surfaces():
		return false
	_world_items_by_entry_id.clear()
	_released_callbacks.clear()
	_state = PresentationState.HIDDEN

	var groups: Dictionary = {}
	for entry: LootBatchEntry in batch.entries:
		if not entry.has_deck_layout:
			return false
		var group: Array = groups.get(entry.presentation_stack_group_id, []) as Array
		group.append(entry)
		groups[entry.presentation_stack_group_id] = group
	var group_ids: Array = groups.keys()
	group_ids.sort()
	for group_id_value: Variant in group_ids:
		var group_entries: Array = groups[group_id_value] as Array
		group_entries.sort_custom(
			func(a: LootBatchEntry, b: LootBatchEntry) -> bool:
				return a.presentation_stack_index < b.presentation_stack_index
		)
		if not _materialize_group(batch, group_entries):
			_rebuild_private_surfaces()
			_world_items_by_entry_id.clear()
			return false
	return true


func reveal_active_batch() -> bool:
	if _manager == null or _manager.get_active_batch() == null or _manager.get_active_batch().is_drained():
		return false
	_state = PresentationState.AVAILABLE
	_set_materialized_available(true)
	return true


func retire_drained_active_after_close() -> String:
	if _manager == null:
		return ""
	return _manager.retire_drained_active_after_close()


func get_presentation_state() -> PresentationState:
	return _state


func get_materialized_world_items() -> Array[WorldItem]:
	var result: Array[WorldItem] = []
	for value: Variant in _world_items_by_entry_id.values():
		var world_item := value as WorldItem
		if world_item != null and is_instance_valid(world_item) and not world_item.is_queued_for_deletion():
			result.append(world_item)
	return result


func get_private_storage_surfaces() -> Array[StorageSurface]:
	var result: Array[StorageSurface] = []
	for value: Variant in _surface_wrappers.values():
		var wrapper := value as Node3D
		if wrapper != null and is_instance_valid(wrapper):
			var surface: StorageSurface = wrapper.call("get_storage_surface") as StorageSurface
			if surface != null:
				result.append(surface)
	return result


func _materialize_group(batch: LootBatch, entries: Array) -> bool:
	if entries.is_empty():
		return true
	var first_entry := entries[0] as LootBatchEntry
	var wrapper := _surface_wrappers.get(first_entry.presentation_surface_id) as Node3D
	if wrapper == null:
		return false
	var surface: StorageSurface = wrapper.call("get_storage_surface") as StorageSurface
	var item_records: Array[Dictionary] = []
	var first_remaining_index := -1
	for index: int in range(entries.size()):
		var entry := entries[index] as LootBatchEntry
		if entry.presentation_surface_id != first_entry.presentation_surface_id:
			return false
		var item: ItemInstance = batch.create_item_instance(entry.entry_id, _catalog)
		var measured: Dictionary = DeckItemPoseScript.measure_item(item, entry.presentation_quarter_turns)
		if item == null or not bool(measured.get("valid", false)):
			return false
		item_records.append({"entry": entry, "item": item, "measured": measured})
		if first_remaining_index < 0 and entry.remaining_in_batch:
			first_remaining_index = index
	if first_remaining_index < 0:
		return true

	var current_origin := first_entry.presentation_cell_origin
	var previous_footprint: Vector2i = (item_records[0]["measured"] as Dictionary)["footprint"] as Vector2i
	for index: int in range(1, first_remaining_index + 1):
		var next_footprint: Vector2i = (item_records[index]["measured"] as Dictionary)["footprint"] as Vector2i
		current_origin = StorageStackScript.centered_shrink_origin(current_origin, previous_footprint, next_footprint)
		previous_footprint = next_footprint

	var first_remaining: LootBatchEntry = (item_records[first_remaining_index]["entry"] as LootBatchEntry)
	# Stable presentation group identity is durable metadata only. StorageSurface
	# intentionally keys a live stack by its current base item so ordinary base
	# TAKE can atomically rekey it to the promoted survivor.
	var runtime_stack_id := first_remaining.item_instance_id
	var materialized_count := 0
	for index: int in range(first_remaining_index, item_records.size()):
		var record: Dictionary = item_records[index]
		var entry: LootBatchEntry = record["entry"] as LootBatchEntry
		if not entry.remaining_in_batch:
			continue
		var item: ItemInstance = record["item"] as ItemInstance
		var measured: Dictionary = record["measured"] as Dictionary
		if not _materialize_entry(
			batch, entry, item, measured, surface, current_origin,
			runtime_stack_id, materialized_count == 0
		):
			return false
		materialized_count += 1
	return true


func _materialize_entry(
	batch: LootBatch,
	entry: LootBatchEntry,
	item: ItemInstance,
	measured: Dictionary,
	surface: StorageSurface,
	origin: Vector2i,
	stack_id: String,
	is_base: bool
) -> bool:
	var host := Node3D.new()
	host.name = "ReceivingItem_%s" % entry.entry_id
	surface.add_child(host)
	var visual: Node = item.definition.visual_scene.instantiate()
	var pose_result: Dictionary = DeckItemPoseScript.build_visual(host, visual, item, entry.presentation_quarter_turns)
	if not bool(pose_result.get("valid", false)):
		host.free()
		return false
	var world_item: WorldItem = WorldItemScript.new()
	world_item.name = "WorldItem"
	host.add_child(world_item)
	var storage_entry: StorageStack.Entry = StorageStackScript.create_entry(
		item,
		measured["footprint"] as Vector2i,
		bool(measured["packing_rotated"]),
		measured["aligned_bounds"] as AABB
	)
	storage_entry.host = host
	storage_entry.world_item = world_item
	world_item.configure_receiving(host, item, surface, stack_id, item.instance_id)
	var fit: Dictionary
	if is_base:
		fit = {
			"valid": true,
			"placement_kind": "empty",
			"stack_id": stack_id,
			"origin": origin,
			"footprint": storage_entry.footprint,
			"rotated": storage_entry.packing_rotated,
			"host_y_m": surface.get_local_placement_position(origin, storage_entry.footprint).y,
		}
	else:
		var stack: StorageStack = surface.get_storage_stack(stack_id)
		if stack == null:
			host.free()
			return false
		var base_y := surface.get_local_placement_position(stack.surface_origin, stack.base_footprint).y
		fit = stack.find_manual_append(storage_entry, surface.get_maximum_stack_top_y_m(), base_y)
		fit["placement_kind"] = "stack"
		fit["stack_id"] = stack_id
	if not surface.commit_stack_entry(storage_entry, fit):
		host.free()
		return false
	world_item.set_pickup_interaction_enabled(false)
	world_item.picked_up.connect(
		func(_picked_item: ItemInstance) -> void:
			_release_picked_entry(batch.batch_id, entry.entry_id, item.instance_id)
	)
	_world_items_by_entry_id[entry.entry_id] = world_item
	return true


func _release_picked_entry(batch_id: String, entry_id: String, item_instance_id: String) -> bool:
	var callback_key := "%s\n%s\n%s" % [batch_id, entry_id, item_instance_id]
	if _released_callbacks.has(callback_key) or _manager == null:
		return false
	if not _manager.release_entry(batch_id, entry_id, item_instance_id):
		push_error("Receiving invariant failure: successful pickup could not release %s/%s." % [batch_id, entry_id])
		return false
	_released_callbacks[callback_key] = true
	_world_items_by_entry_id.erase(entry_id)
	return true


func _rebuild_private_surfaces() -> bool:
	for value: Variant in _surface_wrappers.values():
		var old_wrapper := value as Node3D
		if old_wrapper != null and is_instance_valid(old_wrapper):
			old_wrapper.free()
	_surface_wrappers.clear()
	if _profile == null:
		return false
	for spec: Resource in _profile.get("surfaces") as Array[Resource]:
		if not bool(spec.get("enabled")):
			continue
		var wrapper: Node3D = DeckSurfaceScript.new()
		wrapper.name = "DeckSurface_%s" % String(spec.get("surface_id"))
		add_child(wrapper)
		if not wrapper.configure_from_spec(spec, float(_profile.get("cell_size_m"))):
			wrapper.free()
			return false
		_surface_wrappers[spec.get("surface_id") as StringName] = wrapper
	return not _surface_wrappers.is_empty()


func _set_materialized_available(available: bool) -> void:
	for world_item: WorldItem in get_materialized_world_items():
		world_item.set_pickup_interaction_enabled(available)


func _on_active_batch_changed(_batch_id: String) -> void:
	if _manager == null or _manager.get_active_batch() == null:
		_rebuild_private_surfaces()
		_world_items_by_entry_id.clear()
		_state = PresentationState.HIDDEN
		return
	present_active_batch()


func _on_active_batch_drained(batch_id: String) -> void:
	if _manager != null and _manager.get_active_batch_id() == batch_id:
		_state = PresentationState.DRAINED_WAITING_CLOSE


func _disconnect_manager() -> void:
	if _manager == null or not is_instance_valid(_manager):
		return
	if _manager.active_batch_changed.is_connected(_on_active_batch_changed):
		_manager.active_batch_changed.disconnect(_on_active_batch_changed)
	if _manager.active_batch_drained.is_connected(_on_active_batch_drained):
		_manager.active_batch_drained.disconnect(_on_active_batch_drained)
