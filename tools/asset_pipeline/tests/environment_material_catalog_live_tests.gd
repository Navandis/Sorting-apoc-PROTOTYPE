extends SceneTree

const QUERY = preload("res://environment_authoring/environment_material_catalog_query.gd")

var failures: Array[String] = []

func _initialize() -> void:
	var records: Array = QUERY.load_catalog()
	_check(records.size() == 12, "all twelve human decisions")
	var counts := {"APPROVED": 0, "REJECTED": 0, "DEFERRED": 0}
	for record in records:
		counts[record["status"]] += 1
		_check(record["current_source_matches_review"], "current strong fingerprint: " + record["catalog_material_id"])
		_check(record["effective_status"] == record["status"], "current effective status")
	_check(counts == {"APPROVED": 5, "REJECTED": 4, "DEFERRED": 3}, "final human decision counts")
	var formed := "eaf3b_1435ce254f04bb8e61bd3e96"
	var floor_panels := "eaf3b_20c61bd1c85420be2f71a090"
	var bright := "eaf3b_39b926e570fb3824019aade2"
	var pitted := "eaf3b_bd0940113f04f3d3784629e7"
	var plaster := "eaf3b_8d5f0cf5add98dfe0a58f18a"
	var expected := [formed, floor_panels, bright, pitted, plaster]
	expected.sort()
	_check(_ids(QUERY.query()) == expected, "default query returns exactly five current approvals")
	_check(_ids(QUERY.query("structural_concrete", "structural_substrate", "beam_column")) == [formed, bright], "formed and bright structural roles")
	_check(_ids(QUERY.query("rough_poured_concrete", "structural_substrate", "ceiling")) == [pitted], "pitted rough structural role")
	_check(_ids(QUERY.query("service_floor_concrete", "structural_substrate", "floor")) == [floor_panels], "service floor role")
	_check(_ids(QUERY.query("service_floor_concrete", "structural_substrate", "wall")) == [floor_panels], "service wall role")
	_check(_ids(QUERY.query("cement_render", "applied_finish", "wall")) == [plaster], "plaster applied finish")
	_check(QUERY.query("cement_render", "structural_substrate", "wall").is_empty(), "plaster is not structural substrate")
	_check(QUERY.query("structural_concrete", "structural_substrate", "floor").is_empty(), "structural concrete floor excluded")
	_check(QUERY.query("service_floor_concrete", "structural_substrate", "ceiling").is_empty(), "service ceiling excluded")
	_check(QUERY.query("", "", "", true).size() == 12, "explicit history query includes all decisions")
	for material_id in expected:
		var spec: Resource = load("res://data/environment/material_catalog/approved_specs/" + material_id + ".tres")
		_check(spec != null and spec.material_id == material_id, "approved spec loads: " + material_id)
		if spec != null:
			_check(spec.base_color_texture != null and spec.normal_texture != null and spec.roughness_texture != null, "approved spec maps load: " + material_id)
	if failures.is_empty():
		print("EAF3B_LIVE_CATALOG_TESTS failures=0")
		quit(0)
	else:
		for failure in failures:
			push_error("FAIL: " + failure)
		print("EAF3B_LIVE_CATALOG_TESTS failures=", failures.size())
		quit(1)

func _ids(values: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(value["catalog_material_id"])
	return result

func _check(condition: bool, label: String) -> void:
	if not condition:
		failures.append(label)
