extends SceneTree

const QUERY = preload("res://environment_authoring/environment_material_catalog_query.gd")

func _initialize() -> void:
	var approved := {"catalog_material_id": "a", "effective_status": "APPROVED", "surface_family": "structural_concrete", "vdd_layer": "structural_substrate", "approved_roles": ["wall", "beam_column"]}
	var stale := approved.duplicate(true)
	stale["catalog_material_id"] = "b"
	stale["effective_status"] = "STALE"
	var rejected := approved.duplicate(true)
	rejected["catalog_material_id"] = "c"
	rejected["effective_status"] = "REJECTED"
	var records := [approved, stale, rejected]
	var found: Array = QUERY.query_records(records, "structural_concrete", "structural_substrate", "wall")
	_assert(found.size() == 1 and found[0]["catalog_material_id"] == "a", "current approved family/layer/role only")
	_assert(QUERY.query_records(records, "structural_concrete", "structural_substrate", "floor").is_empty(), "role mismatch excluded")
	_assert(QUERY.query_records(records, "", "", "", true).size() == 3, "explicit noncurrent query includes all")
	print("EAF3B_QUERY_TESTS failures=0")
	quit(0)

func _assert(condition: bool, label: String) -> void:
	if not condition:
		push_error("FAIL: " + label)
		quit(1)