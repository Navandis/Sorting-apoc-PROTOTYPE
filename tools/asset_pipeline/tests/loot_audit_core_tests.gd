extends SceneTree

const LootAuditCoreScript = preload("res://tools/asset_pipeline/loot_audit_core.gd")
const MainSceneLootAdapterScript = preload("res://tools/asset_pipeline/main_scene_loot_adapter.gd")


func _init() -> void:
	_test_transformed_bounds()
	_test_multi_mesh_aggregation()
	_test_cell_rounding_and_orientations()
	_test_category_mismatch_and_footprint_underflow()
	_test_deterministic_ordering()
	_test_main_scene_adapter()
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


func _test_category_mismatch_and_footprint_underflow() -> void:
	var expected_category: String = LootAuditCoreScript.expected_category(
		"res://assets/props/Hydration/SM_Metal_Can_01a.glb"
	)
	assert(expected_category.to_lower() == "hydration")

	var flags: PackedStringArray = LootAuditCoreScript.audit_flags({
		"source_path": "res://assets/props/Hydration/SM_Metal_Can_01a.glb",
		"authored_category": "Food",
		"expected_category": "Hydration",
		"root_scale": Vector3.ONE,
		"instance_scales": [Vector3.ONE],
		"mesh_count": 1,
		"effective_bounds": AABB(Vector3.ZERO, Vector3(0.21, 0.12, 0.31)),
		"raw_width_cells": 3,
		"raw_depth_cells": 4,
		"existing_footprint": Vector3i(2, 3, 1),
		"has_item_definition": true
	})
	assert(flags.has("CATEGORY_MISMATCH"))
	assert(flags.has("EXISTING_FOOTPRINT_SMALLER_THAN_RAW_BOUNDS"))


func _test_deterministic_ordering() -> void:
	var sorted: Array[Dictionary] = LootAuditCoreScript.sort_records([
		{"source_path": "res://assets/props/Weapons/z.glb"},
		{"source_path": "res://assets/props/Food/a.glb"}
	])
	assert(String(sorted[0]["source_path"]) == "res://assets/props/Food/a.glb")


func _test_main_scene_adapter() -> void:
	var records: Array[Dictionary] = MainSceneLootAdapterScript.enumerate_loot_instances(
		"res://main.tscn"
	)
	assert(not records.is_empty())
	var previous_path: String = ""
	for record: Dictionary in records:
		var source_path: String = String(record["source_path"])
		var scene_nodes: Array = record["scene_nodes"] as Array
		assert(source_path.begins_with("res://assets/props/"))
		assert(source_path.to_lower() >= previous_path.to_lower())
		assert(int(record["instance_count"]) == scene_nodes.size())
		previous_path = source_path
