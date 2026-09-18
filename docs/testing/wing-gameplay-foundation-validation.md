# Continuing wing gameplay foundation validation

**Validation date:** 18 September 2026
**Branch:** `codex/wing-storage-bridge`
**Verified baseline:** `1491fd729f3237706ad9533274b7525f6b058932` (`main` and `origin/main`)
**Code/evidence revision:** `0a67b372d713fbce231f9c3806d237db5b7ece07`
**Playable scene:** `res://gameplay/logistics_wing/wing_gameplay.tscn`
**Evidence:** `reports/logistics_wing/storage_bridge/initial/`

## Outcome and gate status

The continuing gameplay foundation is implemented and technically validated. The saved composition reuses the accepted logistics-wing geometry, provides one normal gameplay player/HUD, installs three supported storage units with twelve empty storage surfaces, and registers twelve editor-visible table supplies with deterministic fixture identities. The default launch remains the original `uid://drbkr86g3cxl1` scene.

| Layer | Status | Meaning |
|---|---|---|
| Implementation | PASS | Saved gameplay, environment, fixture, player, HUD, seed, review-capture and evidence scenes/scripts exist. |
| Automated technical verification | PASS | Expanded non-hanging set is 38/38; parser, smokes, ownership, rollback, serialization, capture contract and local controller navigation pass. |
| Rendered review | PASS | Eleven 1920×1080 views plus one aspect-preserving contact sheet were generated with the OpenGL compatibility renderer. |
| Manual editor move/duplicate/save/reopen | PENDING | Automated temporary pack/save/reload and duplicate-identity tests pass; native Godot editor UI automation was unavailable. |
| Human handling/circulation review | PENDING | Direct API and injected W-key evidence is not a substitute for a human LMB/E/O/M/R walkthrough. |
| Default-launch promotion | PENDING | `project.godot` is intentionally unchanged. |
| Receiving, production art and persistence | OUT OF SCOPE | None was started. |

No merge, push, default-launch change, Receiving work, production-art work, asset relocation or branch deletion occurred.

## Saved composition

`WingGameplay` owns these focused components:

| Node | Saved scene | Responsibility |
|---|---|---|
| `Environment` | `gameplay/logistics_wing/wing_environment.tscn` | Accepted geometry plus neutral gameplay lighting and three local proxy substitutions. |
| `FunctionalFixtures` | `gameplay/logistics_wing/functional_fixtures.tscn` | Three supported furniture instances, explicit top-clearance contexts and twelve real storage surfaces. |
| `DevelopmentSetup` | `gameplay/logistics_wing/development/seeded_storage_setup.tscn` | Two collision-only tables and twelve saved visual seed hosts. |
| `Player` | `gameplay/player/gameplay_player.tscn` | Shared controller/carry behavior with main's capsule, camera and 1.4 m / 2.3 m interaction overrides. |
| `HUD/CarriedItemsHUD` | `gameplay/ui/carried_items_hud.tscn` | Shared HUD bound before readiness to `../../Player/CarriedItems`. |

The composition contains exactly one player, one current camera and one `WorldEnvironment`. It does not instance `main.tscn`, the neutral review player, the old capture harness or the rejected Receiving scene. Direct and identity-parent-hosted initialization both pass without a `current_scene` name scan.

To run it explicitly without changing the project default:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . res://gameplay/logistics_wing/wing_gameplay.tscn
```

## Fixtures, surfaces and clearance

All fixture roots and ancestors use identity scale. All twelve surfaces begin with zero reservations, zero stacks and uninitialized zones.

| Fixture | Transform | Surface clearances bottom→top (m) | Top plane Y (m) | Ceiling available (m) | Authored top cap (m) | Margin/limiter |
|---|---|---|---:|---:|---:|---|
| `SM_MetalShelves_GalleryA_West` | `(-2.28, 0, -7.20)`, yaw `0°` | 0.822046, 0.871956, 0.845533, 0.518000 | 2.851123 | 0.548877 | 0.518 | 0.030877 m construction margin below Y=3.40 ceiling. |
| `SM_MetalShelves_GalleryB_North` | `(14.00, 0, -13.78)`, yaw `90°` | 0.822046, 0.871956, 0.845533, 0.518000 | 2.851123 | 0.548877 | 0.518 | 0.030877 m construction margin below Y=3.40 ceiling. |
| `SM_ventilated_locker_GalleryC_West` | `(-1.35, 0, 9.00)`, yaw `0°` | 0.951673, 0.639966, 0.491008, 0.519000 | 2.224432 | 1.175568 | 0.519 | Existing cabinet obstruction is lower than the room ceiling and remains the conservative limiter. |

The metal grids are 10×29 at 0.10 m cells; the locker grids are 8×13. Surface IDs are the fixture name plus `_level_1` through `_level_4`. There are no missing top-clearance contexts. The continuing-scene fixture manager disables its F6/F7 unhandled-input path; an injected F7 event leaves all occupancy and zoning unchanged. Tables contain no `StorageSurface` descendants.

The gameplay-scene navigation suite drives the unchanged controller from spawn to a table pickup stance, to each fixture front, and across the accepted Gallery C–D secondary connection. Each route arrives without falling or stalling. This is useful collision/circulation evidence, but the subjective human reach/readability check remains pending.

## Proxy replacement whitelist

Only these gameplay-instance paths differ from the accepted proxy presentation:

| Proxy | Mesh | Collider |
|---|---|---|
| `GalleryA_West` | `Environment/Greybox/Proxies/GalleryA_West/Mesh.visible = false` | `.../StaticBody3D/CollisionShape3D.disabled = true` |
| `GalleryB_North` | `Environment/Greybox/Proxies/GalleryB_North/Mesh.visible = false` | `.../StaticBody3D/CollisionShape3D.disabled = true` |
| `GalleryC_West` | `Environment/Greybox/Proxies/GalleryC_West/Mesh.visible = false` | `.../StaticBody3D/CollisionShape3D.disabled = true` |

A separately instantiated accepted geometry scene retains all three meshes visible and all three colliders enabled. `greybox/logistics_wing/` has the same Git tree object ID at baseline and evidence revisions.

## Saved tables and seed identities

The west and east tables are saved at `(-11.4, 0, 2.65)` and `(-7.8, 0, 2.65)`. They generate movement collision only; storage installation is disabled.

The unmodified seed multiset is:

| Item definition | Count | Hosts |
|---|---:|---|
| `loot_000005` | 2 | `CerealBox_A`, `CerealBox_B` |
| `loot_000007` | 1 | `CerealBox_2` |
| `loot_000022` | 2 | `SodaCan_A`, `SodaCan_B` |
| `loot_000023` | 1 | `SodaCan_Classic` |
| `loot_000028` | 2 | `MedKit_A`, `MedKit_B` |
| `loot_000030` | 1 | `Book` |
| `loot_000031` | 2 | `CDStack_A`, `CDStack_B` |
| `loot_000037` | 1 | `Hammer` |

Each host saves exactly one visible catalogue visual and derives its identity as `wing_seed_v1:<host_name>`. Identity does not depend on transform, array order, time or `current_scene`. Validation completes for all declarations before any `WorldItem` is created. Unknown IDs, blocked IDs (`loot_000015`, `loot_000034`, `loot_000036`), missing visuals and mismatched visuals produce named failures and zero partial ownership.

The initial runtime census is 12 loose, 0 carried, 0 stored, 12 total and 12 unique IDs. The recorded `CerealBox_A` transaction keeps the same `ItemInstance` reference through loose → carried → Gallery A stored → carried → Gallery B stored. Every snapshot remains 12 total / 12 unique. The full interaction suite also covers all four approved stack families, a three-member stack with middle retrieval/compression, hammer manual rotation, carry-full rejection, category/erased/full-surface rejection and stale-commit rollback.

## Editor authorship and optional setup

Automated evidence performs a small safe transform edit on a temporary fixture copy, packs/saves it under `user://`, reloads it and observes the edited transform. A temporary duplicate produces a thirteenth distinct identity while the original twelve remain unchanged. The test copy is removed and the committed source fixture remains unmodified.

The actual Godot editor move/duplicate/save/reopen gesture remains PENDING for the developer because native editor UI control was unavailable. Use this exact review operation on a temporary copy:

1. Duplicate `gameplay/logistics_wing/development/seeded_storage_setup.tscn` and open the copy.
2. Move/rotate one `SeedItems` child slightly, save, close and reopen the copy, then run it and confirm the saved position is used.
3. Duplicate one seed host as a uniquely named sibling, save/reopen/run, and confirm both items can be targeted independently.
4. Discard only the temporary copy; do not overwrite the twelve-item regression fixture.

`WingGameplay.development_setup_enabled = false` must be set before adding the composition to the tree. That removes `DevelopmentSetup` before child readiness. Physically omitting the child is also supported. Both modes leave the permanent environment, player, HUD and twelve empty surfaces working. Restarting reinstantiates the saved twelve-host arrangement and fresh empty shelves; there is no save mutation or global reset.

## Verification commands and results

Godot version: `4.7.stable.official.5b4e0cb0f`.

Focused suites:

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_seed_fixture_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_storage_bridge_interaction_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_gameplay_capture_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_gameplay_navigation_tests.gd
```

Each exits 0 with exactly one `PASS:` line. The seed suite intentionally emits eight named validation errors while testing an unknown ID, all three blocked IDs, missing/mismatched visuals, a duplicate derived identity namespace, and its detach/re-add lifecycle. The composition suite emits two named rejections while proving that neither a duplicated setup nor a second composition using `wing_seed_v1` can register duplicate identities.

Parser/editor initialization:

```powershell
& $godot --headless --editor --path . --quit
```

Result: exit 0; no parse/resource failure. The recurring Windows `Failed to read the root certificate store` diagnostic is environmental and appears across otherwise successful runs.

Bounded scene smokes:

```powershell
& $godot --headless --path . --quit-after 120 res://gameplay/logistics_wing/wing_gameplay.tscn
& $godot --headless --path . --quit-after 120 res://main.tscn
& $godot --headless --path . --quit-after 120 res://greybox/logistics_wing/wing_review.tscn
```

All three exit 0. Each reports only the known Windows root-certificate diagnostic.

The established non-hanging discovery command runs every `tools/asset_pipeline/tests/*_tests.gd` except `main_scene_loot_audit_integration_tests.gd`. Result: **38/38 exit 0 with exactly one PASS line each** — the original 33 plus five new wing suites. The machine-readable ledger records 51 `ERROR:` diagnostics: one root-certificate line per script, plus the deliberate duplicate catalogue/path tests, Receiving duplicate-source test, eight seed negative/lifecycle tests and two duplicate active-namespace rejections.

The excluded audit was run with a 25-second process bound. It did not complete and produced no PASS line. Its inherited three assertions remain:

- stack-role `currently_eligible` is 39 rather than the stale expected 40 (`_assert_summary`, line 179 via line 72);
- auto-group `currently_eligible` is 39 rather than 40 (`_assert_summary`, line 179 via line 73);
- `loot_000015` is dependency-blocked/not currently eligible, tripping the per-item assertion at line 95.

The generated report shows both summaries at 42 total, 39 currently eligible, 39 approved current, 0 unreviewed, 1 stale and 3 dependency-blocked. This audit is a bounded known exception, not a pass.

## Preservation and repository state

`main == origin/main == 1491fd729f3237706ad9533274b7525f6b058932` at preflight. The feature branch was created from that synchronized revision without resetting newer work. The rejected Receiving commit `c9752c8c68cd55b950dd588542ea271e1acc0aab` is not an ancestor of the feature branch.

Protected Git blobs/trees match the baseline for `main.tscn`, `project.godot`, shared gameplay scripts, `data/`, both authoring registries, `greybox/logistics_wing/`, its three focused tests, `receiving/` and curated accepted evidence. Full values are in `protected_source_manifest.json`. The six pre-existing untracked `.import` files remain present and unstaged. Licensed/imported `assets/` remains an ignored local dependency and is excluded from the review ZIP.

`git diff --check` passes for the implementation range. Tracked changes are limited to the new design/plan/validation/status records, the new `gameplay/` composition family and the five focused wing suites.

## Rendered evidence and bundle

`wing_gameplay_capture.tscn` is gated by `--capture` and does not affect default launch. It generated 11 views at 1920×1080 plus one 4×3 contact sheet using `gl_compatibility` on `NVIDIA GeForce RTX 5060 Ti`. The manifest records resolved runtime camera positions for the actual stack and transfer targets, FOV, ceiling state and SHA-256 hashes of focused sources.

Evidence files:

- `capture_manifest.json` and `contact_sheet.png`;
- `fixture_census.json` with all fixtures, surfaces, caps, proxies, seed hosts and ownership snapshots;
- `protected_source_manifest.json`;
- `verification_results.json`;
- eleven full-resolution PNGs;
- `README.md` with manual review and asset-dependency notes;
- `wing-gameplay-foundation-review.zip` plus its external SHA-256 record.

The bundle is review-focused, not an asset-complete game export. It excludes `.godot/`, licensed GLBs/textures, the complete repository and legacy media.

## Human PROMOTE / REVISE questions

Please review the explicit gameplay scene and answer **PROMOTE** or **REVISE** for this integration scope:

1. Are all table supplies visible, reachable and recognizable, and do LMB pickup, carried HUD and held-item presentation feel correct?
2. Can you use O/E zoning, E auto-store, M/R manual placement, compatible stacking, retrieval and cross-shelf transfer at all three units without confusion or item loss?
3. Does a temporary editor move/rotate and duplicate/save/reopen behave as expected with distinct identities?
4. Do the fixtures preserve useful circulation and feel sensibly placed, with no unexplained blocker or purported usable level that cannot actually be handled?

Stop here. Default-launch promotion is a later small, separately authorized follow-through after human approval.
