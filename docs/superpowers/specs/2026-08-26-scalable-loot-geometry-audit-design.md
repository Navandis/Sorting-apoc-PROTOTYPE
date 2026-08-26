# Scalable Loot Geometry / Content Audit v1

## Purpose and boundaries

Add evidence-only tooling that measures imported prop geometry used by `main.tscn`, compares it with the current temporary catalogue, and emits review reports. The tool never writes `ItemDefinition` data, footprint approvals, scene data, source assets, import files, or gameplay code.

The design treats authored storage occupancy as authoritative gameplay data. Geometry produces suggestions and warnings only.

## Architecture

The pipeline is separated into four files under `tools/asset_pipeline/`:

1. `loot_audit_core.gd` is deterministic and side-effect-free. It uses Godot geometry types, transforms bounds, calculates raw footprint suggestions, resolves flags, and orders records.
2. `main_scene_loot_adapter.gd` reads `main.tscn` through `PackedScene` / `SceneState` without saving or reserializing it. It returns the uniquely referenced prop GLBs, scene-node names, instance counts, and contextual transforms.
3. `run_main_scene_loot_audit.gd` loads each selected GLB, gathers mesh contributors, obtains existing definitions through `PrototypeItemCatalog`, calls the core, and writes reports.
4. `tests/loot_audit_core_tests.gd` runs focused headless tests for core behavior.

A later full-library adapter can provide a different asset collection to the same core.

## Geometry model

For every GLB, the runner instantiates the asset detached from the tree and recursively visits `MeshInstance3D` nodes. Each contributor AABB is transformed into asset-root space by explicitly transforming all eight corners through the accumulated descendant transform. The merged result is recorded as `root_local_bounds`.

The eight corners of that aggregate are then transformed by the complete GLB-root transform. This records `effective_canonical_bounds`, whose dimensions describe the visual object Godot instantiates. Root translation does not affect dimensions but remains visible in bounds-centre and origin-offset diagnostics. Main-scene instance transforms are never applied to canonical bounds or raw footprint suggestions.

Scale comparisons use absolute `Basis.get_scale()` magnitudes so mirrored transforms do not corrupt checks.

## Storage convention and footprint suggestion

The runner reads `StoragePrototypeManager.DEFAULT_WORLD_CELL_SIZE_M`, currently `0.10 m`. Runtime convention is `ItemDefinition.storage_footprint.x` = storage width cells and `.y` = storage depth cells; `.z` is reserved.

The report names its calculated axes explicitly: effective asset X -> storage width and effective asset Z -> storage depth. It calculates `ceil(effective_width / cell_size)` and `ceil(effective_depth / cell_size)`, then reports both W x D and D x W. No padding, orientation approval, stacking inference, or authored data write occurs.

## Categories and catalogue comparison

Existing definitions come from `PrototypeItemCatalog.create_definition_for_scene_path`, not copied mapping logic. Expected category is inferred case-insensitively from the first `assets/props/<category>/` directory component while preserving the path's displayed case. Reports retain authored category, expected category, and category source. Disagreement emits `CATEGORY_MISMATCH`; undefined assets emit `NO_ITEM_DEFINITION`.

Existing `storage_footprint` is compared directly against the raw X/Z suggestion. A smaller authored footprint produces `EXISTING_FOOTPRINT_SMALLER_THAN_RAW_BOUNDS` as a review flag only.

## Heuristics

The JSON metadata serializes these centralized v1 thresholds, which are anomaly detectors rather than design rules:

- scale deviation: `0.01`
- very small longest effective dimension: `< 0.05 m`
- very large longest effective dimension: `> 2.5 m`
- extreme aspect ratio: `>= 8`
- off-centre offset: `> max(0.10 m, 25% of longest effective dimension)`

Flags include the required scale, mesh, category, definition, footprint, and irregular-review cases. Instance transforms are contextual; non-unit and varying instance scales are flagged without changing the canonical result.

## Output and tests

The runner writes stable, sorted CSV and JSON to `reports/asset_pipeline/`. The report contains no volatile timestamp in per-asset records. This generated directory is ignored narrowly, so recurring audit runs do not create default commit noise.

Core tests cover transformed and multi-mesh aggregation, cell rounding, both orientations, category mismatch, existing-footprint underflow, and deterministic ordering. The runner is then executed headlessly against the real main scene and reviewed against the required representative assets.
