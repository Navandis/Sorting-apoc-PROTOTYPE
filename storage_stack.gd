extends RefCounted
class_name StorageStack

## Explicit deterministic state for one centered linear support stack.
## Node parenting is visual only; this ordered record is the mechanical truth.

const STACK_CONTACT_GAP_M: float = 0.0
const HEIGHT_EPSILON_M: float = 0.000001


class Entry extends RefCounted:
	var item: ItemInstance = null
	var item_key: String = ""
	var footprint: Vector2i = Vector2i.ONE
	var packing_rotated: bool = false
	var aligned_bounds: AABB = AABB(Vector3.ZERO, Vector3.ONE)
	var posed_height_m: float = 1.0
	var can_be_stacked: bool = false
	var can_support_stack: bool = false
	var auto_stack_group: StringName = &""
	var host: Node3D = null
	var world_item: Node = null


var stack_id: String = ""
var surface: Node = null
var surface_origin: Vector2i = Vector2i.ZERO
var base_footprint: Vector2i = Vector2i.ONE
var entries: Array[Entry] = []


static func create_entry(
	item: ItemInstance,
	footprint: Vector2i,
	packing_rotated: bool,
	aligned_bounds: AABB
) -> Entry:
	var entry: Entry = Entry.new()
	entry.item = item
	entry.item_key = item.instance_id if item != null else ""
	entry.footprint = _normalized_footprint(footprint)
	entry.packing_rotated = packing_rotated
	entry.aligned_bounds = aligned_bounds
	entry.posed_height_m = maxf(aligned_bounds.size.y, 0.0)
	if item != null:
		entry.can_be_stacked = item.can_be_stacked()
		entry.can_support_stack = item.can_support_stack()
		entry.auto_stack_group = item.get_auto_stack_group()
	return entry


static func footprint_fits(incoming: Vector2i, below: Vector2i) -> bool:
	var normalized_incoming: Vector2i = _normalized_footprint(incoming)
	var normalized_below: Vector2i = _normalized_footprint(below)
	return (
		normalized_incoming.x <= normalized_below.x
		and normalized_incoming.y <= normalized_below.y
	)


func find_manual_append(
	entry: Entry,
	maximum_top_y_m: float,
	base_host_y_m: float
) -> Dictionary:
	return _evaluate_insertion(entry, entries.size(), maximum_top_y_m, base_host_y_m)


func find_auto_insertion(
	orientation_entries: Array,
	maximum_top_y_m: float,
	base_host_y_m: float
) -> Dictionary:
	if not is_auto_coherent():
		return _invalid_result()

	var coherent_group: StringName = entries[0].auto_stack_group
	var best: Dictionary = _invalid_result()
	var best_index: int = -1
	var best_orientation_order: int = 999999
	for orientation_order: int in range(orientation_entries.size()):
		var value: Variant = orientation_entries[orientation_order]
		if not (value is Entry):
			continue
		var entry: Entry = value as Entry
		if entry.auto_stack_group.is_empty() or entry.auto_stack_group != coherent_group:
			continue
		for insertion_index: int in range(entries.size(), 0, -1):
			var candidate: Dictionary = _evaluate_insertion(
				entry,
				insertion_index,
				maximum_top_y_m,
				base_host_y_m
			)
			candidate["group_ok"] = true
			if not bool(candidate["valid"]):
				continue
			if (
				insertion_index > best_index
				or (
					insertion_index == best_index
					and orientation_order < best_orientation_order
				)
			):
				best = candidate
				best_index = insertion_index
				best_orientation_order = orientation_order
	return best


func is_auto_coherent() -> bool:
	if entries.is_empty():
		return false
	var expected_group: StringName = entries[0].auto_stack_group
	if expected_group.is_empty():
		return false
	for entry: Entry in entries:
		if entry.auto_stack_group != expected_group:
			return false
	return true


func entry_host_y(index: int, base_host_y_m: float) -> float:
	if index <= 0:
		return base_host_y_m
	if index >= entries.size():
		return base_host_y_m

	var host_y_m: float = base_host_y_m
	for entry_index: int in range(1, index + 1):
		var below: Entry = entries[entry_index - 1]
		var current: Entry = entries[entry_index]
		host_y_m += (
			below.aligned_bounds.end.y
			- current.aligned_bounds.position.y
			+ STACK_CONTACT_GAP_M
		)
	return host_y_m


func insertion_host_y(entry: Entry, insertion_index: int, base_host_y_m: float) -> float:
	if insertion_index <= 0 or entries.is_empty():
		return base_host_y_m
	var below_index: int = mini(insertion_index - 1, entries.size() - 1)
	var below: Entry = entries[below_index]
	return (
		entry_host_y(below_index, base_host_y_m)
		+ below.aligned_bounds.end.y
		- entry.aligned_bounds.position.y
		+ STACK_CONTACT_GAP_M
	)


func resulting_top_y_with(
	entry: Entry,
	_insertion_index: int,
	base_host_y_m: float
) -> float:
	if entries.is_empty():
		return base_host_y_m + entry.aligned_bounds.end.y

	var total_height_m: float = entry.posed_height_m
	for existing: Entry in entries:
		total_height_m += existing.posed_height_m
	var contact_count: int = entries.size()
	return (
		base_host_y_m
		+ entries[0].aligned_bounds.position.y
		+ total_height_m
		+ float(contact_count) * STACK_CONTACT_GAP_M
	)


func current_top_y(base_host_y_m: float) -> float:
	if entries.is_empty():
		return base_host_y_m
	var total_height_m: float = 0.0
	for entry: Entry in entries:
		total_height_m += entry.posed_height_m
	return (
		base_host_y_m
		+ entries[0].aligned_bounds.position.y
		+ total_height_m
		+ float(maxi(entries.size() - 1, 0)) * STACK_CONTACT_GAP_M
	)


func get_entry_index(item_key: String) -> int:
	for index: int in range(entries.size()):
		if entries[index].item_key == item_key:
			return index
	return -1


static func centered_shrink_origin(
	old_origin: Vector2i,
	old_size: Vector2i,
	new_size: Vector2i
) -> Vector2i:
	var normalized_old: Vector2i = _normalized_footprint(old_size)
	var normalized_new: Vector2i = _normalized_footprint(new_size)
	return old_origin + Vector2i(
		floori(float(normalized_old.x - normalized_new.x) * 0.5),
		floori(float(normalized_old.y - normalized_new.y) * 0.5)
	)


func _evaluate_insertion(
	entry: Entry,
	insertion_index: int,
	maximum_top_y_m: float,
	base_host_y_m: float
) -> Dictionary:
	var index_ok: bool = (
		entry != null
		and not entries.is_empty()
		and insertion_index > 0
		and insertion_index <= entries.size()
	)
	if not index_ok:
		return _invalid_result(entry, insertion_index)

	var below: Entry = entries[insertion_index - 1]
	var stackable_ok: bool = entry.can_be_stacked
	var below_supports: bool = below.can_support_stack
	var footprint_ok: bool = footprint_fits(entry.footprint, below.footprint)
	var above_support_ok: bool = true
	var above_footprint_ok: bool = true
	if insertion_index < entries.size():
		var above: Entry = entries[insertion_index]
		above_support_ok = entry.can_support_stack
		above_footprint_ok = footprint_fits(above.footprint, entry.footprint)

	var resulting_top_y_m: float = resulting_top_y_with(
		entry,
		insertion_index,
		base_host_y_m
	)
	var clearance_ok: bool = resulting_top_y_m <= maximum_top_y_m + HEIGHT_EPSILON_M
	var valid: bool = (
		stackable_ok
		and below_supports
		and footprint_ok
		and above_support_ok
		and above_footprint_ok
		and clearance_ok
	)
	return {
		"valid": valid,
		"entry": entry,
		"insertion_index": insertion_index,
		"rotated": entry.packing_rotated,
		"stackable_ok": stackable_ok,
		"below_supports": below_supports,
		"footprint_ok": footprint_ok,
		"above_support_ok": above_support_ok,
		"above_footprint_ok": above_footprint_ok,
		"clearance_ok": clearance_ok,
		"resulting_top_y_m": resulting_top_y_m,
		"host_y_m": insertion_host_y(entry, insertion_index, base_host_y_m)
	}


func _invalid_result(entry: Entry = null, insertion_index: int = -1) -> Dictionary:
	return {
		"valid": false,
		"entry": entry,
		"insertion_index": insertion_index,
		"rotated": entry.packing_rotated if entry != null else false,
		"stackable_ok": false,
		"below_supports": false,
		"footprint_ok": false,
		"above_support_ok": false,
		"above_footprint_ok": false,
		"clearance_ok": false,
		"group_ok": false,
		"resulting_top_y_m": INF,
		"host_y_m": 0.0
	}


static func _normalized_footprint(footprint: Vector2i) -> Vector2i:
	return Vector2i(maxi(1, footprint.x), maxi(1, footprint.y))
