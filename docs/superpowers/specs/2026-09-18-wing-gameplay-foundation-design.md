# Continuing Wing Gameplay Foundation Design

**Decision date:** 18 September 2026
**Implementation branch:** `codex/wing-storage-bridge`
**Verified baseline:** synchronized local and remote `main` at `1491fd729f3237706ad9533274b7525f6b058932`
**Approval:** The continuing gameplay composition and editor-authored table/loot workflow are approved for implementation. Human handling approval and default-launch promotion remain separate gates.

## Purpose and lifetime

`res://gameplay/logistics_wing/wing_gameplay.tscn` is the continuing playable game composition. It is not a disposable bridge room. Later prototype systems and, if appropriate, production development continue around this scene while individual environment and gameplay components remain replaceable.

This milestone supplies the first permanent composition boundary, three functional storage fixtures, and a removable twelve-item development setup. It does not implement Receiving, persistence, menus, production art, or default-scene promotion.

## Authority and preservation

The current masters remain GDD v0.8, Visual Design Direction v0.5, and Prototype Findings v0.8. The accepted logistics-wing geometry and neutral review remain the spatial authority. `docs/testing/wing-storage-integration-preflight.md` remains historical evidence; this design supersedes only its runtime-array seed proposal and temporary-scene framing.

The following remain byte-identical to the verified baseline:

- `project.godot` and its default scene UID `uid://drbkr86g3cxl1`;
- `main.tscn` and shared player, carrying, storage, stacking, placement, zoning, and item-authoring behavior;
- `greybox/logistics_wing/wing_geometry.tscn`, its builder, neutral review scene/player, and focused tests;
- `data/`, the catalogue, item definitions, Receiving resources, and authoring manifest;
- imported source assets and accepted historical evidence.

The rejected Receiving branch stays outside this branch ancestry. No merge, push, branch deletion, asset relocation, broad reimport, or history rewrite is part of the work.

## Saved composition and ownership

The new authored files have focused ownership:

| Path | Responsibility |
|---|---|
| `gameplay/logistics_wing/wing_gameplay.tscn` | Continuing composition; instances environment, fixtures, player, HUD, and optional development setup. |
| `gameplay/logistics_wing/wing_environment.tscn` | Author-owned wrapper around the accepted geometry plus neutral gameplay lighting and local proxy substitutions. |
| `gameplay/logistics_wing/wing_environment.gd` | Validates and suppresses exactly three proxy meshes and colliders within this instance. |
| `gameplay/logistics_wing/functional_fixtures.tscn` | Three editor-visible supported fixtures and their explicit clearance contexts. |
| `gameplay/logistics_wing/functional_fixtures.gd` | Reuses the existing fixture bootstrap, exposes installed surfaces, and disables the destructive F7 demo locally. |
| `gameplay/player/gameplay_player.tscn` | Faithful reusable full-gameplay player subtree based on current `main.tscn`. |
| `gameplay/ui/carried_items_hud.tscn` | Reusable carried-items HUD whose binding is configured by the composition before readiness. |
| `gameplay/logistics_wing/development/seeded_storage_setup.tscn` | Removable tables and twelve saved, editor-visible seed hosts. |
| `gameplay/logistics_wing/development/seed_host.gd` | Data-only host declaration: stable catalogue item ID and visual validation. |
| `gameplay/logistics_wing/development/seed_registrar.gd` | Validates the whole fixture, creates stable runtime identities, and registers existing hosts once. |

All top-level component transforms use identity scale. New authored content stays outside the generator-owned `Environment/Greybox` subtree.

## Environment adapter

`wing_environment.tscn` instances `res://greybox/logistics_wing/wing_geometry.tscn` as `Greybox`. It reproduces the neutral review's saved WorldEnvironment, directional light, and fill lights without its player, orientation labels, capture helpers, or extra camera.

At initialization, `wing_environment.gd` requires these exact relative paths beneath `Greybox/Proxies`:

- `GalleryA_West`;
- `GalleryB_North`;
- `GalleryC_West`.

For each path it sets only `Mesh.visible = false` and `StaticBody3D/CollisionShape3D.disabled = true`. Missing or wrongly typed nodes produce named initialization errors. The adapter never edits shared mesh/shape resources. Loading the neutral review in a separate context therefore retains all original proxy visuals and colliders.

## Player and HUD parity

`gameplay_player.tscn` preserves the main fixture's controller, capsule, camera transform, FOV, movement defaults, carry capacity, and interaction overrides. Its authored settings are:

- `interaction_distance = 1.4`;
- `storage_interaction_distance = 2.3`;
- `prototype_auto_register_known_loot = false`;
- `print_loot_registration = false`;
- `enable_held_item_view = true`.

The player retains direct `Camera3D` and `CarriedItems` children. The composition owns exactly one player and one current camera.

The HUD scene contains the existing `CarriedItemsHUD`. `wing_gameplay.gd` assigns its `carried_items_path` to `../../Player/CarriedItems` before the composition enters the tree, so `_ready()` observes the correct container both when run directly and when the gameplay scene is instanced beneath an identity-transform parent. No new root-name or `current_scene` scan is introduced.

## Functional fixtures and clearances

`FunctionalFixtures` has exactly these direct identity-scale children so the existing `StoragePrototypeManager` recognizes them and derives twelve unique surface IDs:

| Fixture | Transform | Replaced proxy |
|---|---|---|
| `SM_MetalShelves_GalleryA_West` | origin `(-2.28, 0, -7.20)`, yaw `0°` | `GalleryA_West` |
| `SM_MetalShelves_GalleryB_North` | origin `(14.00, 0, -13.78)`, yaw `90°` | `GalleryB_North` |
| `SM_ventilated_locker_GalleryC_West` | origin `(-1.35, 0, 9.00)`, yaw `0°` | `GalleryC_West` |

Each fixture has a direct `StorageShelfClearanceContext`. The ordinary accepted ceiling underside is `Y=3.40 m`. Tests calculate the actual installed top-surface plane in world space and require each authored cap to be positive, at or below the nearest physical obstruction, and conservative by the documented margin. Metal shelves are ceiling-limited; the locker remains limited by its own cabinet top when that is lower than the ceiling. No 95-percent stacking factor is baked into the physical cap.

Surfaces start empty and unzoned. Tables and seed hosts never become StorageSurfaces. `functional_fixtures.gd` runs the existing collision/storage bootstrap, then disables unhandled input on the dynamically created `StoragePrototypeManager` for this composition. That removes the F6/F7 debug controls locally and prevents F7 from calling `clear_all()` or creating reservations; legacy-main behavior is unchanged.

## Editor-authored development setup

`seeded_storage_setup.tscn` owns `Tables` and `SeedItems` as sibling roots. `Tables` contains ordinary instances of `res://assets/environment/furniture/work_surfaces/SM_Table.glb` with generated convex movement collision and storage installation disabled. No table has a `StorageSurface`, zoning, PUT behavior, or reservation state.

`SeedItems` contains twelve uniquely named `SeedHost` nodes. Each host:

- is independently movable/rotatable at identity scale;
- stores an exported catalogue item ID;
- contains exactly one editor-visible instance of that definition's existing `visual_scene`;
- derives its stable fixture key from its unique direct-child node name, never from position, array order, a timer, or `current_scene`.

The baseline multiset is `loot_000005 ×2`, `loot_000007 ×1`, `loot_000022 ×2`, `loot_000023 ×1`, `loot_000028 ×2`, `loot_000030 ×1`, `loot_000031 ×2`, and `loot_000037 ×1`. Catalogue definitions, visual scenes, scale, bulk, footprint, pose, support metadata, and Receiving eligibility are unchanged.

The registrar first validates every declaration and performs no ownership creation if any declaration is invalid. Named errors cover unknown or blocked IDs, duplicate derived identities, missing/non-unique visual children, and a visual scene path that differs from the catalogue definition. After successful validation it creates one `ItemInstance(definition, "wing_seed_v1:<host_name>")` per host and attaches one `WorldItem` through `configure_existing(host, instance)`.

Registration is one-shot and idempotent. A second setup call neither duplicates components nor resurrects a host already queued for deletion after pickup. Moving or rotating a host changes no identity and is never overwritten at runtime. Ordinary editor duplication creates a distinct sibling name and therefore a distinct identity. Two active copies of the same fixture namespace in one scene are unsupported and are rejected by the parent composition tests rather than silently sharing identities.

## Optional setup and restart

`WingGameplay` exposes an authored `development_setup_enabled` setting. Before children enter the tree, `wing_gameplay.gd` removes the `DevelopmentSetup` instance when this setting is false. Omission of that instance is also supported. Either path yields no tables or seed items while the environment, player, HUD, and twelve empty storage surfaces still initialize.

Stopping and rerunning the scene reinstantiates saved hosts and fresh empty surfaces. No save data, catalogue resource, scene file, or global reset is mutated. Hiding an already initialized setup is not a reset mode.

## Failure behavior and ownership invariants

Initialization failures are explicit and named; invalid seed declarations never produce a partial fixture. Successful runtime ownership always has exactly one of three states: loose host/WorldItem, carried `ItemInstance`, or a committed `StorageSurface` entry/WorldItem. Existing pickup and placement rollback retain the exact `ItemInstance` on failure.

Tests use the real catalogue, scenes, `WorldItem`, `CarriedItems`, `StorageSurface`, and `StoragePlacementController`. Mocks are not used for gameplay ownership. API-driven tests cover deterministic boundary states; human review remains required for ray targeting, input timing, visibility, reach, circulation, and editor ergonomics.

## Verification and evidence

Focused tests cover direct and parent-hosted initialization, exact player/HUD binding, proxy isolation, fixture names and twelve empty surfaces, measured clearances, F7 immunity, the seed multiset and stable identities, idempotence, invalid declarations, transform round-trip, editor-style duplication, setup omission, pickup/carry/store/retrieve/cross-shelf identity, compatible stacking, and rollback.

Full verification also runs the established 33 non-hanging scripts, the separately bounded legacy audit with its known exception ledger, parser/editor initialization, explicit gameplay/main/neutral-review smokes, protected-source hashes/diffs, and `git diff --check`.

Evidence is added without deleting prior reports under `reports/logistics_wing/storage_bridge/initial/`. The tracked validation report is `docs/testing/wing-gameplay-foundation-validation.md`. A review ZIP includes only the new tracked source/tests/docs plus protected-source manifest and focused evidence; it excludes `.godot/`, imported/licensed assets, the full repository, and large legacy media. The report keeps technical status, editor-operation coverage, human handling status, and default-launch status separate.

## Completion boundary

This delivery stops with a playable explicit scene, validation report, machine-readable evidence, review bundle, and human PROMOTE/REVISE questions. Human handling approval remains pending. `project.godot` remains unchanged, and no merge, push, Receiving work, production art, or default-launch promotion occurs.
