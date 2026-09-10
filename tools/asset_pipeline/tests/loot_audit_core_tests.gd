extends SceneTree

const LootAuditCoreScript = preload("res://tools/asset_pipeline/loot_audit_core.gd")
const MainSceneLootAdapterScript = preload("res://tools/asset_pipeline/main_scene_loot_adapter.gd")
const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")


func _init() -> void:
	_test_transformed_bounds()
	_test_multi_mesh_aggregation()
	_test_posed_contributors_compose_authored_pose_before_contributor_transform()
	_test_posed_raw_footprint_uses_posed_xz_without_changing_canonical_bounds()
	_test_cell_rounding_and_orientations()
	_test_category_folder_mismatch_and_footprint_underflow()
	_test_category_folder_hint_is_case_insensitive()
	_test_deterministic_ordering()
	_test_main_scene_adapter()
	_test_migrated_medicine_paths_use_stable_authoring_identity()
	_test_review_summary_uses_explicit_non_overlapping_unreviewed_counts()
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


# Catches reversing authored_pose * contributor_to_asset_root, which loses the
# intended asset-root pose when GLB children have their own transforms.
func _test_posed_contributors_compose_authored_pose_before_contributor_transform() -> void:
	var contributor_to_asset_root: Transform3D = Transform3D(
		Basis(Vector3.UP, PI * 0.5),
		Vector3(2.0, 0.0, 0.0)
	)
	var authored_pose: Transform3D = Transform3D(
		Basis(Vector3.BACK, PI * 0.5),
		Vector3.ZERO
	)
	var contributors: Array[Dictionary] = [{
		"bounds": AABB(Vector3.ZERO, Vector3(1.0, 2.0, 1.0)),
		"transform": contributor_to_asset_root
	}]
	var result: Dictionary = LootAuditCoreScript.aggregate_posed_contributors(
		contributors,
		authored_pose
	)
	var bounds: AABB = result["bounds"] as AABB
	assert(bounds.position.is_equal_approx(Vector3(-2.0, 2.0, -1.0)))
	assert(bounds.size.is_equal_approx(Vector3(2.0, 1.0, 1.0)))


# Catches posed Footprint evidence accidentally reusing canonical X/Z.
func _test_posed_raw_footprint_uses_posed_xz_without_changing_canonical_bounds() -> void:
	var contributors: Array[Dictionary] = [{
		"bounds": AABB(Vector3.ZERO, Vector3(1.1, 2.2, 3.3)),
		"transform": Transform3D.IDENTITY
	}]
	var canonical_result: Dictionary = LootAuditCoreScript.aggregate_contributors(contributors)
	var posed_result: Dictionary = LootAuditCoreScript.aggregate_posed_contributors(
		contributors,
		Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3.ZERO)
	)
	var canonical_bounds: AABB = canonical_result["bounds"] as AABB
	var posed_bounds: AABB = posed_result["bounds"] as AABB
	var posed_footprint: Dictionary = LootAuditCoreScript.raw_footprint(
		posed_bounds.size,
		0.5
	)
	assert(canonical_bounds.size.is_equal_approx(Vector3(1.1, 2.2, 3.3)))
	assert(posed_bounds.size.is_equal_approx(Vector3(1.1, 3.3, 2.2)))
	assert(int(posed_footprint["width_cells"]) == 3)
	assert(int(posed_footprint["depth_cells"]) == 5)
	assert(String(posed_footprint["orientation_a"]) == "3x5")
	assert(String(posed_footprint["orientation_b"]) == "5x3")


func _test_cell_rounding_and_orientations() -> void:
	var result: Dictionary = LootAuditCoreScript.raw_footprint(
		Vector3(0.21, 0.04, 0.31),
		0.10
	)
	assert(result["width_cells"] == 3)
	assert(result["depth_cells"] == 4)
	assert(result["orientation_a"] == "3x4")
	assert(result["orientation_b"] == "4x3")


func _test_category_folder_mismatch_and_footprint_underflow() -> void:
	var folder_category_hint: String = LootAuditCoreScript.folder_category_hint(
		"res://assets/props/Hydration/SM_Metal_Can_01a.glb"
	)
	assert(folder_category_hint == "Hydration")

	var flags: PackedStringArray = LootAuditCoreScript.audit_flags({
		"source_path": "res://assets/props/Hydration/SM_Metal_Can_01a.glb",
		"authored_category": "Food",
		"folder_category_hint": "Hydration",
		"root_scale": Vector3.ONE,
		"instance_scales": [Vector3.ONE],
		"mesh_count": 1,
		"effective_bounds": AABB(Vector3.ZERO, Vector3(0.21, 0.12, 0.31)),
		"raw_width_cells": 3,
		"raw_depth_cells": 4,
		"existing_footprint": Vector3i(2, 3, 1),
		"has_item_definition": true
	})
	assert(flags.has("CATEGORY_FOLDER_MISMATCH"))
	assert(not flags.has("CATEGORY_MISMATCH"))
	assert(flags.has("EXISTING_FOOTPRINT_SMALLER_THAN_RAW_BOUNDS"))


func _test_category_folder_hint_is_case_insensitive() -> void:
	var flags: PackedStringArray = LootAuditCoreScript.audit_flags({
		"authored_category": "hydration",
		"folder_category_hint": "Hydration",
		"has_item_definition": true
	})
	assert(not flags.has("CATEGORY_FOLDER_MISMATCH"))


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


func _test_migrated_medicine_paths_use_stable_authoring_identity() -> void:
	var cough_syrup: ItemDefinition = PrototypeItemCatalogScript.create_definition_for_scene_path(
		"res://assets/props/medical/SM_CoughSyrup_01.glb"
	)
	var antibiotics: ItemDefinition = PrototypeItemCatalogScript.create_definition_for_scene_path(
		"res://assets/props/medical/SM_Antibiotics_01.glb"
	)
	assert(cough_syrup != null)
	assert(antibiotics != null)
	assert(cough_syrup.item_id == &"loot_000027")
	assert(cough_syrup.display_name == "Medicine Bottle")
	assert(antibiotics.item_id == &"loot_000025")
	assert(antibiotics.display_name == "Medicine Bottle")


func _test_review_summary_uses_explicit_non_overlapping_unreviewed_counts() -> void:
	var records: Array[Dictionary] = [
		_review_record(true, true, false, false, true, true, false, false),
		_review_record(true, false, false, false, false, false, false, true),
		_review_record(false, false, false, true, false, false, false, true),
		_review_record(false, false, true, true, false, false, true, true)
	]
	var summary: Dictionary = LootAuditCoreScript.review_summary(records)
	assert(summary["stack_role"] == {
		"total": 4,
		"currently_eligible": 2,
		"approved_current": 1,
		"unreviewed": 1,
		"stale": 1,
		"dependency_blocked": 2
	})
	assert(summary["auto_group"] == {
		"total": 4,
		"currently_eligible": 1,
		"approved_current": 1,
		"unreviewed": 0,
		"stale": 1,
		"dependency_blocked": 3
	})


func _review_record(
	stack_eligible: bool,
	stack_current: bool,
	stack_stale: bool,
	stack_blocked: bool,
	auto_eligible: bool,
	auto_current: bool,
	auto_stale: bool,
	auto_blocked: bool
) -> Dictionary:
	return {
		"stack_role_review_status": "APPROVED" if stack_current or stack_stale else "UNREVIEWED",
		"stack_role_review_eligible": stack_eligible,
		"stack_role_review_current": stack_current,
		"stack_role_review_stale": stack_stale,
		"stack_role_review_dependency_blocked": stack_blocked,
		"auto_group_review_status": "APPROVED" if auto_current or auto_stale else "UNREVIEWED",
		"auto_group_review_eligible": auto_eligible,
		"auto_group_review_current": auto_current,
		"auto_group_review_stale": auto_stale,
		"auto_group_review_dependency_blocked": auto_blocked
	}
