# Scalable Loot Geometry / Content Audit v1 Implementation Plan

> For agentic workers: REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Build an evidence-only Godot audit that measures prop GLBs referenced by main.tscn, compares them with the temporary catalogue, and emits deterministic CSV and JSON reports.

**Architecture:** LootAuditCore is deterministic and side-effect-free while using Godot geometry value types. MainSceneLootAdapter reads SceneState into asset records, and a headless runner measures each GLB and serializes reports.

**Tech Stack:** Godot 4.7 GDScript, PackedScene/SceneState, AABB, Transform3D, FileAccess, headless Godot console, Git.

**Spec:** docs/superpowers/specs/2026-08-26-scalable-loot-geometry-audit-design.md

## Global Constraints

- Do not modify main.tscn, ItemDefinition values, catalogue entries, gameplay/storage code, source GLBs/textures, .import, or .godot.
- Create all tooling under tools/asset_pipeline/; reports may exist only under reports/asset_pipeline/.
- Compute root-local and effective canonical bounds separately. Effective canonical bounds apply the GLB root transform only; main-scene transforms are report-only.
- Raw storage axes are explicit: effective asset X -> storage width and effective asset Z -> storage depth. Runtime occupancy is Vector3i.x width, .y depth, .z reserved.
- Obtain the cell size from StoragePrototypeManager.DEFAULT_WORLD_CELL_SIZE_M; do not refactor runtime code.
- Serialize the approved thresholds: scale 0.01, small <0.05m, large >2.5m, aspect >=8, offset >max(0.10m, 25% longest).
- Add only /reports/asset_pipeline/ to .gitignore; never commit recurring reports by default.
- GDScript warnings are errors; declare types explicitly.

---

## File Structure

- Create tools/asset_pipeline/loot_audit_core.gd: pure geometry, raw footprint, categories, flags, ordering, and serialization helpers.
- Create tools/asset_pipeline/main_scene_loot_adapter.gd: read-only SceneState GLB enumeration.
- Create tools/asset_pipeline/run_main_scene_loot_audit.gd: headless measurement and report entry point.
- Create tools/asset_pipeline/tests/loot_audit_core_tests.gd: self-running headless assertions.
- Modify .gitignore: narrow generated-report ignore.
- Generate only reports/asset_pipeline/main_scene_loot_audit.csv and .json.

### Task 1: Geometry and raw-footprint core

**Files:**

- Create: tools/asset_pipeline/loot_audit_core.gd
- Create: tools/asset_pipeline/tests/loot_audit_core_tests.gd

**Interfaces:**

- Produces class_name LootAuditCore.
- static func transform_bounds(bounds: AABB, transform: Transform3D) -> AABB
- static func aggregate_contributors(contributors: Array[Dictionary]) -> Dictionary
- static func raw_footprint(effective_size: Vector3, cell_size_m: float) -> Dictionary

- [ ] **Step 1: Write failing tests for transformed bounds, multi-mesh aggregation, and cell rounding**

~~~gdscript
extends SceneTree
const LootAuditCoreScript = preload("res://tools/asset_pipeline/loot_audit_core.gd")

func _init() -> void:
	_test_transformed_bounds()
	_test_multi_mesh_aggregation()
	_test_cell_rounding_and_orientations()
	quit(0)

func _test_transformed_bounds() -> void:
	var source: AABB = AABB(Vector3.ZERO, Vector3(1.0, 2.0, 3.0))
	var result: AABB = LootAuditCoreScript.transform_bounds(
		source,
		Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(4.0, 0.0, 0.0))
	)
	assert(is_equal_approx(result.size.x, 3.0))
	assert(is_equal_approx(result.size.y, 2.0))
	assert(is_equal_approx(result.size.z, 1.0))

func _test_multi_mesh_aggregation() -> void:
	var contributors: Array[Dictionary] = [
		{"bounds": AABB(Vector3.ZERO, Vector3.ONE), "transform": Transform3D.IDENTITY},
		{"bounds": AABB(Vector3.ZERO, Vector3.ONE), "transform": Transform3D(Basis.IDENTITY, Vector3(2.0, 0.0, 0.0))}
	]
	var result: Dictionary = LootAuditCoreScript.aggregate_contributors(contributors)
	var bounds: AABB = result["bounds"] as AABB
	assert(bool(result["valid"]))
	assert(int(result["mesh_count"]) == 2)
	assert(is_equal_approx(bounds.size.x, 3.0))

func _test_cell_rounding_and_orientations() -> void:
	var result: Dictionary = LootAuditCoreScript.raw_footprint(Vector3(0.21, 0.04, 0.31), 0.10)
	assert(result["width_cells"] == 3)
	assert(result["depth_cells"] == 4)
	assert(result["orientation_a"] == "3x4")
	assert(result["orientation_b"] == "4x3")
~~~

- [ ] **Step 2: Run the test to verify it fails before the core exists**

Run:

~~~powershell
& 'D:\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/loot_audit_core_tests.gd'
~~~

Expected: preload/parser failure because loot_audit_core.gd does not exist.

- [ ] **Step 3: Implement manual eight-corner AABB transforms**

~~~gdscript
extends RefCounted
class_name LootAuditCore

static func transform_bounds(bounds: AABB, transform: Transform3D) -> AABB:
	var points: Array[Vector3] = []
	for x_index: int in range(2):
		for y_index: int in range(2):
			for z_index: int in range(2):
				points.append(transform * Vector3(
					bounds.position.x + bounds.size.x * float(x_index),
					bounds.position.y + bounds.size.y * float(y_index),
					bounds.position.z + bounds.size.z * float(z_index)
				))
	return _bounds_from_points(points)

static func aggregate_contributors(contributors: Array[Dictionary]) -> Dictionary:
	var valid: bool = false
	var aggregate: AABB = AABB()
	for contributor: Dictionary in contributors:
		var local_bounds: AABB = contributor["bounds"] as AABB
		var local_transform: Transform3D = contributor["transform"] as Transform3D
		var transformed: AABB = transform_bounds(local_bounds, local_transform)
		aggregate = aggregate.merge(transformed) if valid else transformed
		valid = true
	return {"valid": valid, "bounds": aggregate, "mesh_count": contributors.size()}

static func raw_footprint(effective_size: Vector3, cell_size_m: float) -> Dictionary:
	var width_cells: int = maxi(1, int(ceil(effective_size.x / cell_size_m)))
	var depth_cells: int = maxi(1, int(ceil(effective_size.z / cell_size_m)))
	return {
		"width_cells": width_cells,
		"depth_cells": depth_cells,
		"orientation_a": "%dx%d" % [width_cells, depth_cells],
		"orientation_b": "%dx%d" % [depth_cells, width_cells]
	}
~~~

Implement _bounds_from_points(points: Array[Vector3]) -> AABB with explicit min/max. Empty contributors must return {"valid": false, "bounds": AABB(), "mesh_count": 0}.

- [ ] **Step 4: Run the complete test file**

Run the Step 2 command. Expected: exit 0, no assertion failure, no parser warning.

- [ ] **Step 5: Commit the geometry milestone**

~~~powershell
git add tools/asset_pipeline/loot_audit_core.gd tools/asset_pipeline/tests/loot_audit_core_tests.gd
git commit -m "feat: add loot audit geometry core"
~~~

### Task 2: Categories, review flags, and deterministic ordering

**Files:**

- Modify: tools/asset_pipeline/loot_audit_core.gd
- Modify: tools/asset_pipeline/tests/loot_audit_core_tests.gd

**Interfaces:**

- Produces expected_category(source_path: String) -> String, audit_flags(input: Dictionary) -> PackedStringArray, threshold_metadata() -> Dictionary, and sort_records(records: Array[Dictionary]) -> Array[Dictionary].

- [ ] **Step 1: Add failing tests for category mismatch, footprint underflow, and order**

~~~gdscript
func _test_category_mismatch_and_footprint_underflow() -> void:
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
		"existing_footprint": Vector3i(2, 3, 1)
	})
	assert(flags.has("CATEGORY_MISMATCH"))
	assert(flags.has("EXISTING_FOOTPRINT_SMALLER_THAN_RAW_BOUNDS"))

func _test_deterministic_ordering() -> void:
	var sorted: Array[Dictionary] = LootAuditCoreScript.sort_records([
		{"source_path": "res://assets/props/Weapons/z.glb"},
		{"source_path": "res://assets/props/Food/a.glb"}
	])
	assert(String(sorted[0]["source_path"]) == "res://assets/props/Food/a.glb")
~~~

Call both methods from _init().

- [ ] **Step 2: Run the test and verify it fails for the missing APIs**

Run the Task 1 command. Expected: parser error naming missing audit_flags or sort_records.

- [ ] **Step 3: Add central thresholds and stable flags**

~~~gdscript
const SCALE_TOLERANCE: float = 0.01
const VERY_SMALL_LONGEST_M: float = 0.05
const VERY_LARGE_LONGEST_M: float = 2.5
const EXTREME_ASPECT_RATIO: float = 8.0
const OFF_CENTER_MIN_M: float = 0.10
const OFF_CENTER_LONGEST_FRACTION: float = 0.25

static func expected_category(source_path: String) -> String:
	var parts: PackedStringArray = source_path.split("/", false)
	var props_index: int = parts.find("props")
	return "" if props_index < 0 or props_index + 1 >= parts.size() else parts[props_index + 1]
~~~

Use lower-cased comparisons but preserve folder display case. audit_flags must return a fixed-order PackedStringArray and support NON_UNIT_ROOT_SCALE, NON_UNIFORM_SCALE, NON_UNIT_INSTANCE_SCALE, INSTANCE_SCALE_VARIANCE, VERY_SMALL, VERY_LARGE, EXTREME_ASPECT_RATIO, OFF_CENTER_BOUNDS, MULTI_MESH, NO_MESH_FOUND, CATEGORY_UNKNOWN, CATEGORY_MISMATCH, NO_ITEM_DEFINITION, EXISTING_FOOTPRINT_SMALLER_THAN_RAW_BOUNDS, and IRREGULAR_REVIEW.

Compute scale checks using absolute scale magnitudes. Match irregular path families using a central lower-cased list covering long guns, boots, clothing, helmets/vests, fuel containers, firewood, electronics, and pig carcass. Underflow is a warning only.

- [ ] **Step 4: Run the test file and verify it passes**

Run the Task 1 command. Expected: exit 0; category comparison is case-insensitive and flags remain warning evidence.

- [ ] **Step 5: Commit the flags milestone**

~~~powershell
git add tools/asset_pipeline/loot_audit_core.gd tools/asset_pipeline/tests/loot_audit_core_tests.gd
git commit -m "feat: add loot audit review flags"
~~~

### Task 3: Read-only main-scene adapter

**Files:**

- Create: tools/asset_pipeline/main_scene_loot_adapter.gd
- Modify: tools/asset_pipeline/tests/loot_audit_core_tests.gd

**Interfaces:**

- Produces class_name MainSceneLootAdapter.
- static func enumerate_loot_instances(scene_path: String) -> Array[Dictionary].
- A record contains source_path, scene_nodes, instance_count, and instance_transforms.

- [ ] **Step 1: Add a failing main-scene adapter test**

~~~gdscript
const MainSceneLootAdapterScript = preload("res://tools/asset_pipeline/main_scene_loot_adapter.gd")

func _test_main_scene_adapter() -> void:
	var records: Array[Dictionary] = MainSceneLootAdapterScript.enumerate_loot_instances("res://main.tscn")
	assert(not records.is_empty())
	var previous_path: String = ""
	for record: Dictionary in records:
		var source_path: String = String(record["source_path"])
		assert(source_path.begins_with("res://assets/props/"))
		assert(source_path.to_lower() >= previous_path.to_lower())
		assert(int(record["instance_count"]) == (record["scene_nodes"] as Array[String]).size())
		previous_path = source_path
~~~

- [ ] **Step 2: Run the test to verify it fails because the adapter is absent**

Run the Task 1 command. Expected: preload failure for main_scene_loot_adapter.gd.

- [ ] **Step 3: Implement SceneState enumeration**

~~~gdscript
extends RefCounted
class_name MainSceneLootAdapter

static func enumerate_loot_instances(scene_path: String) -> Array[Dictionary]:
	var scene_resource: Resource = load(scene_path)
	if not (scene_resource is PackedScene):
		return []
	var state: SceneState = (scene_resource as PackedScene).get_state()
	# Build a path -> local Transform3D map from node properties.
	# Read each node instance resource and retain only res://assets/props/*.glb.
	# Compose parent transforms from SceneState node paths, group by resource path,
	# and return sorted records without instantiating or saving the main scene.
	return []
~~~

For every instance transform, serialize origin, basis, and absolute scale_magnitude; keep all source node names. Compose parent transforms so a prop under a transformed parent retains accurate context.

- [ ] **Step 4: Run the adapter test**

Run the Task 1 command. Expected: exit 0; records are unique and sorted and instance_count equals the node-list length.

- [ ] **Step 5: Commit the adapter milestone**

~~~powershell
git add tools/asset_pipeline/main_scene_loot_adapter.gd tools/asset_pipeline/tests/loot_audit_core_tests.gd
git commit -m "feat: enumerate main scene loot for audit"
~~~

### Task 4: Headless runner and generated reports

**Files:**

- Create: tools/asset_pipeline/run_main_scene_loot_audit.gd
- Modify: .gitignore
- Modify: tools/asset_pipeline/loot_audit_core.gd

**Interfaces:**

- Consumes Task 1-3 APIs, PrototypeItemCatalog.create_definition_for_scene_path, and StoragePrototypeManager.DEFAULT_WORLD_CELL_SIZE_M.
- Produces schema version 1.0 CSV and JSON under reports/asset_pipeline/.

- [ ] **Step 1: Add the narrow report ignore**

Append exactly:

~~~gitignore
/reports/asset_pipeline/
~~~

- [ ] **Step 2: Implement the runner**

~~~gdscript
extends SceneTree

const LootAuditCoreScript = preload("res://tools/asset_pipeline/loot_audit_core.gd")
const MainSceneLootAdapterScript = preload("res://tools/asset_pipeline/main_scene_loot_adapter.gd")
const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const StoragePrototypeManagerScript = preload("res://storage_prototype_manager.gd")

func _init() -> void:
	var cell_size_m: float = StoragePrototypeManagerScript.DEFAULT_WORLD_CELL_SIZE_M
	var scene_records: Array[Dictionary] = MainSceneLootAdapterScript.enumerate_loot_instances("res://main.tscn")
	var audit_records: Array[Dictionary] = []
	for scene_record: Dictionary in scene_records:
		audit_records.append(_audit_asset(scene_record, cell_size_m))
	_write_reports(LootAuditCoreScript.sort_records(audit_records), cell_size_m)
	quit(0)
~~~

_audit_asset loads one GLB as PackedScene, instantiates it detached, recursively gathers every MeshInstance3D.mesh.get_aabb() with descendant transforms, and calls the core twice: root-local aggregation, then transform of that aggregate by the complete GLB root Transform3D. Retain both structured bounds as {min,max,size,center}. Do not use or alter collision shapes.

Use the catalogue lookup API directly. Raw footprint is derived only from effective canonical X and Z dimensions. Record asset_root_scale, contextual instance transforms/scales, item_id, display name, authored/expected category, category_source, existing footprint, bulk, raw orientations, flags, and notes.

- [ ] **Step 3: Implement deterministic serialization**

JSON top-level data:

~~~gdscript
{
	"schema_version": "1.0",
	"audit_configuration": {
		"cell_size_m": cell_size_m,
		"storage_axes": {
			"effective_asset_x": "storage_width",
			"effective_asset_z": "storage_depth"
		},
		"heuristic_thresholds": LootAuditCoreScript.threshold_metadata()
	},
	"assets": sorted_records
}
~~~

Use JSON.stringify(report, "\t", true). Implement RFC-4180 CSV escaping: quote fields containing comma, quote, CR, or LF and double embedded quotes. Include required audit columns plus root-local/effective bounds and explicit storage-axis labels. Do not serialize timestamps.

- [ ] **Step 4: Run tests and runner**

~~~powershell
& 'D:\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/tests/loot_audit_core_tests.gd'
& 'D:\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script 'res://tools/asset_pipeline/run_main_scene_loot_audit.gd'
~~~

Expected: both exit 0; reports exist and are ignored by Git.

- [ ] **Step 5: Commit durable tooling only**

~~~powershell
git add .gitignore tools/asset_pipeline/loot_audit_core.gd tools/asset_pipeline/main_scene_loot_adapter.gd tools/asset_pipeline/run_main_scene_loot_audit.gd
git commit -m "feat: add main scene loot geometry audit"
~~~

Do not stage report files.

### Task 5: Audit validation and delivery evidence

**Files:**

- Inspect only: reports/asset_pipeline/main_scene_loot_audit.csv
- Inspect only: reports/asset_pipeline/main_scene_loot_audit.json
- Inspect only: main.tscn, prototype_item_catalog.gd, Git status and diff.

**Interfaces:**

- Consumes generated reports from Task 4.
- Produces evidence for the completion report; changes no authored content.

- [ ] **Step 1: Prove report determinism**

Run the Task 4 runner twice. After each run:

~~~powershell
Get-FileHash reports/asset_pipeline/main_scene_loot_audit.csv -Algorithm SHA256
Get-FileHash reports/asset_pipeline/main_scene_loot_audit.json -Algorithm SHA256
~~~

Expected: each report hash is identical across both runs.

- [ ] **Step 2: Inspect required representative records**

Check a can, carton, pistol, rifle, paired boots, clothing, helmet/vest, fuel container, firewood, electronics asset, pig carcass, and SM_Hammer_3. For each, verify non-empty dimensions, X/Z raw axes, scale context, and expected category/definition/irregular flags. Confirm SM_Hammer_3 retains NO_ITEM_DEFINITION if it remains undefined.

- [ ] **Step 3: Inspect long-gun regression evidence**

Verify rifle and shotgun preserve their raw effective X/Z results. If authored components are smaller in the same orientation, require EXISTING_FOOTPRINT_SMALLER_THAN_RAW_BOUNDS; if source orientation is questionable, require IRREGULAR_REVIEW. Never rotate, pad, or overwrite authored footprint.

- [ ] **Step 4: Run final parser and repository checks**

~~~powershell
& 'D:\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64_console.exe' --headless --editor --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --quit
git diff --check
git status --branch --short
~~~

Expected: no new parser warnings/errors and no unintended tracked modifications.

- [ ] **Step 5: Deliver evidence only**

Report exact files, architecture, storage source/convention, AABB method, thresholds, test results, audit counts, representative findings, report paths, suspicious measurements, and final Git status. State that Footprints, catalogue entries, source assets, and gameplay remained unchanged.

## Plan Self-Review

- Spec coverage: Tasks 1-2 implement geometry, raw footprint, categories, comparisons, flags, thresholds, and deterministic ordering. Task 3 adds only main-scene enumeration/context. Task 4 measures GLBs and serializes reports. Task 5 verifies repeatability, representative content, historical rifle evidence, parser state, and repository safety.
- Placeholder scan: Each task names files, APIs, commands, expected outcomes, and test cases; no unresolved placeholders remain.
- Type consistency: LootAuditCore, MainSceneLootAdapter, transform_bounds, aggregate_contributors, raw_footprint, audit_flags, and sort_records use the same names and Godot types throughout.
