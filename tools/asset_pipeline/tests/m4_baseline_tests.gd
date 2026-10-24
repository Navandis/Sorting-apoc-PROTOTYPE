extends SceneTree

const BASELINE := "res://data/scenarios/m4/Sorting_Apocalypse_M4_Locked_Baseline_24Oct2026.json"
var failures := 0

func _init() -> void:
	var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASELINE))
	var catalog: ItemCatalog = load("res://data/items/item_catalog.tres")
	var mismatches: Array[String] = []
	for row: Dictionary in baseline.approved_items:
		var definition := catalog.get_definition_by_id(StringName(row.item_id))
		if definition == null or definition.display_name != row.display_name or definition.utility_id != StringName(row.utility_lane) or definition.utility_value != int(row.utility) or definition.bulk != int(row.bulk):
			mismatches.append(row.item_id)
		if definition != null and row.utility_lane == "Medical":
			var medical := definition.get_utility_for_context(&"medical_bay")
			check(String(medical.utility_id) == "Medical" and int(medical.value) == int(row.utility), "Medical override agrees: " + row.item_id)
		if definition != null:
			var routes := {"medical_bay":{"Medical":999},"kitchen":{"Food":999,"Hydration":999},"dispatch":{"Food":999,"Hydration":999,"Medical":999,"Weapons":999,"Protection":999}}
			for context: String in routes:
				var request = load("res://gameplay/requests/contribution_request.gd").new("route",context,routes[context])
				var preview: Dictionary = request.preview(ItemInstance.new(definition,"route:"+row.item_id))
				check((preview.status == "eligible") == row.destinations.has(context), "Explicit Utility routing: " + row.item_id + " / " + context)
	check(catalog.definitions.size() == 167 and baseline.approved_items.size() == 167, "Exact active catalogue count")
	check(mismatches.is_empty(), "Locked numeric/name rows match; mismatches: " + ", ".join(mismatches))
	var carry := CarriedItems.new()
	check(carry.max_bulk == 20, "Player can carry exactly 20 Bulk")
	carry.free()
	print("M4_BASELINE_COMPLETE rows=",baseline.approved_items.size()," failures=",failures)
	quit(1 if failures else 0)

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
