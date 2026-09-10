extends SceneTree

const StackRoleAuthoringScript = preload("res://tools/asset_pipeline/stack_role_authoring.gd")
const EXPECTED_IDS: PackedStringArray = [
	"loot_000003", "loot_000007", "loot_000020", "loot_000021"
]
const EXPECTED_BATCH_TWO_IDS: PackedStringArray = [
	"loot_000008", "loot_000010", "loot_000015", "loot_000016", "loot_000017",
	"loot_000018", "loot_000022", "loot_000023", "loot_000024", "loot_000025",
	"loot_000027"
]
const EXPECTED_BATCH_THREE_IDS: PackedStringArray = [
	"loot_000001", "loot_000004", "loot_000012", "loot_000014", "loot_000029",
	"loot_000033", "loot_000035"
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
	var batch_two_records: Array[Dictionary] = []
	for item_id: String in ["loot_000027", "loot_000015", "loot_000099", "loot_000024", "loot_000008", "loot_000025", "loot_000018", "loot_000016", "loot_000022", "loot_000017", "loot_000010", "loot_000023"]:
		batch_two_records.append(_record(item_id))
	var batch_two_rows: Array[Dictionary] = StackRoleAuthoringScript.batch_two_rows(batch_two_records)
	var batch_two_ids: PackedStringArray = []
	for row: Dictionary in batch_two_rows:
		batch_two_ids.append(String(row["item_id"]))
	assert(batch_two_ids == EXPECTED_BATCH_TWO_IDS)
	var batch_two_markdown: String = StackRoleAuthoringScript.batch_two_markdown(batch_two_records)
	assert(batch_two_markdown == StackRoleAuthoringScript.batch_two_markdown(batch_two_records.duplicate(true)))
	assert("# Stack Role Authoring Review — Batch 2" in batch_two_markdown)
	assert("cylindrical / container-like" in batch_two_markdown)
	assert("loot_000016" in batch_two_markdown)
	assert("VISUAL_REVIEW_RECOMMENDED" in batch_two_markdown)
	var batch_three_records: Array[Dictionary] = []
	for item_id: String in ["loot_000035", "loot_000001", "loot_000099", "loot_000014", "loot_000033", "loot_000004", "loot_000029", "loot_000012"]:
		batch_three_records.append(_record(item_id))
	var batch_three_rows: Array[Dictionary] = StackRoleAuthoringScript.batch_three_rows(batch_three_records)
	var batch_three_ids: PackedStringArray = []
	for row: Dictionary in batch_three_rows:
		batch_three_ids.append(String(row["item_id"]))
	assert(batch_three_ids == EXPECTED_BATCH_THREE_IDS)
	var batch_three_markdown: String = StackRoleAuthoringScript.batch_three_markdown(batch_three_records)
	assert(batch_three_markdown == StackRoleAuthoringScript.batch_three_markdown(batch_three_records.duplicate(true)))
	assert("# Stack Role Authoring Review — Batch 3" in batch_three_markdown)
	assert("irregular rigid" in batch_three_markdown)
	assert("loot_000014" in batch_three_markdown)
	assert("VISUAL_REVIEW_RECOMMENDED" in batch_three_markdown)
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
