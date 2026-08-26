extends SceneTree

const LootAuditCoreScript = preload("res://tools/asset_pipeline/loot_audit_core.gd")


func _init() -> void:
	_test_transformed_bounds()
	_test_multi_mesh_aggregation()
	_test_cell_rounding_and_orientations()
	print("PASS: loot audit core geometry tests")
	quit(0)


func _test_transformed_bounds() -> void:
	var source: AABB = AABB(Vector3.ZERO, Vector3(1.0, 2.0, 3.0))
	var transform: Transform3D = Transform3D(
		Basis(Vector3.UP, PI * 0.5),
		Vector3(4.0, 0.0, 0.0)
	)
	var result: AABB = LootAuditCoreScript.transform_bounds(source, transform)
	assert(is_equal_approx(result.size.x, 3.0))
	assert(is_equal_approx(result.size.y, 2.0))
	assert(is_equal_approx(result.size.z, 1.0))


func _test_multi_mesh_aggregation() -> void:
	var contributors: Array[Dictionary] = [
		{"bounds": AABB(Vector3.ZERO, Vector3.ONE), "transform": Transform3D.IDENTITY},
		{
			"bounds": AABB(Vector3.ZERO, Vector3.ONE),
			"transform": Transform3D(Basis.IDENTITY, Vector3(2.0, 0.0, 0.0))
		}
	]
	var result: Dictionary = LootAuditCoreScript.aggregate_contributors(contributors)
	var bounds: AABB = result["bounds"] as AABB
	assert(bool(result["valid"]))
	assert(int(result["mesh_count"]) == 2)
	assert(is_equal_approx(bounds.size.x, 3.0))


func _test_cell_rounding_and_orientations() -> void:
	var result: Dictionary = LootAuditCoreScript.raw_footprint(
		Vector3(0.21, 0.04, 0.31),
		0.10
	)
	assert(result["width_cells"] == 3)
	assert(result["depth_cells"] == 4)
	assert(result["orientation_a"] == "3x4")
	assert(result["orientation_b"] == "4x3")
