extends SceneTree

const QUERY = preload("res://environment_authoring/environment_material_catalog_query.gd")

func _initialize() -> void:
	var records: Array = QUERY.load_catalog()
	_assert(records.size() == 9, "nine reconciled human decisions")
	var counts := {"APPROVED": 0, "REJECTED": 0, "DEFERRED": 0}
	for record in records:
		counts[record["status"]] += 1
		_assert(record["current_source_matches_review"], "current strong fingerprint")
	_assert(counts == {"APPROVED": 2, "REJECTED": 4, "DEFERRED": 3}, "human decision counts")
	var approved: Array[Dictionary] = QUERY.query()
	_assert(approved.size() == 2, "default query includes two current approvals")
	var formed := "eaf3b_1435ce254f04bb8e61bd3e96"
	var floor_panels := "eaf3b_20c61bd1c85420be2f71a090"
	_assert(_ids(QUERY.query("structural_concrete", "structural_substrate", "beam_column")) == [formed], "formed structural role")
	_assert(QUERY.query("structural_concrete", "structural_substrate", "floor").is_empty(), "formed floor excluded")
	_assert(_ids(QUERY.query("service_floor_concrete", "structural_substrate", "floor")) == [floor_panels], "service floor role")
	_assert(QUERY.query("service_floor_concrete", "structural_substrate", "ceiling").is_empty(), "service ceiling excluded")
	_assert(QUERY.query("", "", "", true).size() == 9, "explicit noncurrent query includes history")
	for material_id in [formed, floor_panels]:
		var spec: Resource = load("res://data/environment/material_catalog/approved_specs/" + material_id + ".tres")
		_assert(spec != null and spec.material_id == material_id, "approved spec loads")
		_assert(spec.base_color_texture != null and spec.normal_texture != null and spec.roughness_texture != null, "approved spec maps load")
	print("EAF3B_LIVE_CATALOG_TESTS failures=0")
	quit(0)

func _ids(values: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(value["catalog_material_id"])
	return result

func _assert(condition: bool, label: String) -> void:
	if not condition:
		push_error("FAIL: " + label)
		quit(1)
