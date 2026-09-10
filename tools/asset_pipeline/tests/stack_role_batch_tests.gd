extends SceneTree

const StackRoleAuthoringScript = preload("res://tools/asset_pipeline/stack_role_authoring.gd")
const EXPECTED_IDS: PackedStringArray = [
	"loot_000003", "loot_000007", "loot_000020", "loot_000021"
]


func _init() -> void:
	var records: Array[Dictionary] = []
	for item_id: String in ["loot_000021", "loot_000003", "loot_000099", "loot_000007", "loot_000020"]:
		records.append(_record(item_id))
	var rows: Array[Dictionary] = StackRoleAuthoringScript.batch_one_rows(records)
	var actual_ids: PackedStringArray = []
	for row: Dictionary in rows:
		actual_ids.append(String(row["item_id"]))
		for field: String in [
			"item_id", "display_name", "source_path", "storage_category",
			"storage_footprint", "storage_rotation_degrees", "can_be_stacked",
			"can_support_stack", "flags", "rationale"
		]:
			assert(row.has(field))
	assert(actual_ids == EXPECTED_IDS)
	var first: String = StackRoleAuthoringScript.batch_one_markdown(records)
	var second: String = StackRoleAuthoringScript.batch_one_markdown(records.duplicate(true))
	assert(first == second)
	assert("| Stable ID | Display / asset | Storage Category | Approved Footprint | Approved rotation | Stackable | Supports | Flags | Rationale |" in first)
	for item_id: String in EXPECTED_IDS:
		assert(item_id in first)
	assert("loot_XXXXXX — APPROVE" in first)
	assert("loot_XXXXXX — ADJUST: true / false" in first)
	assert("loot_XXXXXX — HOLD" in first)
	print("PASS: stack role batch tests")
	quit(0)


func _record(item_id: String) -> Dictionary:
	return {
		"item_id": item_id,
		"display_name": "Display %s" % item_id,
		"source_path": "res://assets/props/Test/%s.glb" % item_id,
		"authored_category": "General",
		"storage_footprint": [2, 3, 1],
		"storage_rotation_degrees": [0.0, 90.0, 0.0]
	}
