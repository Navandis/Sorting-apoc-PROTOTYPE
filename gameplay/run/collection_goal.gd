extends RefCounted

signal changed

const RULE_REVISION := 1
const CATEGORIES := ["Electronics", "Food", "Fuel", "Hydration", "Medical", "Morale", "Protection", "Weapons"]

var target: int
var totals: Dictionary = {}
var completed := false
var first_completion_at := -1.0
var _surfaces: Array[StorageSurface] = []

func _init(common_target: int) -> void:
	target = common_target

func bind(surfaces: Array[StorageSurface]) -> void:
	_surfaces = surfaces.duplicate()

static func definition_error(definition: ItemDefinition) -> String:
	if not StorageCategories.is_item_category(definition.storage_category) or String(definition.utility_id) != definition.storage_category or definition.utility_value <= 0:
		return "Collection category/primary Utility is incompatible: " + String(definition.item_id)
	return ""

func refresh(elapsed: float, record_completion: bool = true) -> String:
	var next: Dictionary = {}
	for category: String in CATEGORIES:
		next[category] = 0
	var seen: Dictionary = {}
	for surface: StorageSurface in _surfaces:
		for item: ItemInstance in surface.get_stored_items():
			if seen.has(item.instance_id):
				return "Multiply owned collection item: " + item.instance_id
			seen[item.instance_id] = true
			if item.definition == null:
				return "Collection item has no definition: " + item.instance_id
			var category := item.get_storage_category()
			if not StorageCategories.is_item_category(category) and not StorageCategories.is_item_category(String(item.get_utility_id())):
				continue # Unclassified outputs have no category to credit.
			var error := definition_error(item.definition)
			if not error.is_empty():
				return error
			next[category] += item.definition.utility_value
	next.make_read_only()
	var updated := totals != next
	totals = next
	if record_completion and not completed and is_satisfied():
		completed = true
		first_completion_at = elapsed
		updated = true
	if updated:
		changed.emit()
	return ""

func is_satisfied() -> bool:
	if target <= 0:
		return false
	for category: String in CATEGORIES:
		if int(totals.get(category, 0)) < target:
			return false
	return true

func capture_state() -> Dictionary:
	return {"target": target, "rule_revision": RULE_REVISION,
		"completed": completed, "first_completion_at": first_completion_at}

func restore_state(state: Dictionary) -> void:
	target = state.target
	completed = state.completed
	first_completion_at = state.first_completion_at
