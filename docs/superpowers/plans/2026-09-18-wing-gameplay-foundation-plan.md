# Continuing Wing Gameplay Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the continuing logistics-wing gameplay composition with three empty functional storage units and a saved, editor-editable twelve-item table fixture, then stop for human handling review.

**Architecture:** Compose focused saved scenes for environment, fixtures, player, HUD, and removable development supplies. Reuse the accepted geometry and all existing gameplay algorithms; add only local adapters for proxy suppression, fixture debug-input isolation, pre-ready composition binding, and deterministic registration of saved seed hosts.

**Tech Stack:** Godot 4.7 (`4.7.stable.official.5b4e0cb0f`), GDScript, text `.tscn` resources, existing SceneTree script-test convention, PowerShell verification.

**Spec:** `docs/superpowers/specs/2026-09-18-wing-gameplay-foundation-design.md`

## Execution status

- [x] Task 1 — continuing composition, player, HUD and environment boundary.
- [x] Task 2 — three functional fixtures, proxy isolation and measured clearance.
- [x] Task 3 — saved table/loot fixture and deterministic registrar.
- [x] Task 4 — ownership, navigation, preservation, evidence and review handoff.

The implementation stops at the approved human handling/editor review gate. Default launch, merge, push, Receiving and production art remain outside this plan's completed scope.

## Global Constraints

- Work only in `D:\Godot Projects\Sorting-apoc-PROTOTYPE` on `codex/wing-storage-bridge`, created from verified synchronized `main` at `1491fd729f3237706ad9533274b7525f6b058932`.
- Preserve `project.godot`, `main.tscn`, shared gameplay scripts, all `data/`, the authoring manifest, accepted geometry/builder, neutral review/player/tests, Receiving sources, and imported assets.
- Keep `uid://drbkr86g3cxl1` as the default launch and do not merge, push, delete branches, implement Receiving, or add production art.
- Use test-first development: add one observable failing check, run it to confirm the expected failure, add the minimum scene/script content, rerun to green, then refactor without changing behavior.
- Tests assert real loaded scenes, real catalogue definitions, real `ItemInstance`/`WorldItem` ownership, and real storage APIs. No source-text grep is accepted as gameplay proof.
- Keep the developer's six pre-existing untracked `.import` files untouched.
- Store new ignored evidence under `reports/logistics_wing/storage_bridge/initial/` without deleting any existing evidence.

---

### Task 1: Continuing composition, player, HUD, and environment boundary

**Files:**
- Create: `tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd`
- Create: `gameplay/logistics_wing/wing_gameplay.gd`
- Create: `gameplay/logistics_wing/wing_gameplay.tscn`
- Create: `gameplay/logistics_wing/wing_environment.gd`
- Create: `gameplay/logistics_wing/wing_environment.tscn`
- Create: `gameplay/player/gameplay_player.tscn`
- Create: `gameplay/ui/carried_items_hud.tscn`

**Interfaces:**
- `WingGameplay` exports `development_setup_enabled: bool = true` and removes `DevelopmentSetup` in `_enter_tree()` when false.
- `WingEnvironment.get_proxy_suppression_failures() -> Array[String]` reports missing/wrongly typed proxy paths after readiness.
- The player supplies direct `Camera3D` and `CarriedItems` children with the exact main overrides.
- `HUD/CarriedItemsHUD.carried_items_path` resolves to `../../Player/CarriedItems` before its `_ready()`.

- [ ] **Step 1: Write the failing composition test**

Create a deferred SceneTree suite that loads `res://gameplay/logistics_wing/wing_gameplay.tscn`, first as `current_scene` and then beneath a plain identity `Node3D`. For each context, wait one process and physics frame and assert literal observable values:

```gdscript
const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"

func _assert_composition(scene: Node) -> void:
	var player := scene.get_node_or_null("Player") as CharacterBody3D
	var carried := scene.get_node_or_null("Player/CarriedItems")
	var hud := scene.get_node_or_null("HUD/CarriedItemsHUD")
	_check(player != null, "full gameplay player exists")
	_check(is_equal_approx(float(player.get("interaction_distance")), 1.4), "pickup reach is preserved")
	_check(is_equal_approx(float(player.get("storage_interaction_distance")), 2.3), "storage reach is preserved")
	_check(player.get("prototype_auto_register_known_loot") == false, "raw-loot registration is disabled locally")
	_check(player.get("print_loot_registration") == false, "registration logging is disabled locally")
	_check(player.get("enable_held_item_view") == true, "held view stays enabled")
	_check(hud != null and hud.get_node_or_null(NodePath("../../Player/CarriedItems")) == carried, "HUD resolves the same carried container")
	_check(_count_current_cameras(scene) == 1, "composition has exactly one current camera")
```

Also assert there is no `main.tscn`, review player, capture script, or second WorldEnvironment in the composition.

- [ ] **Step 2: Run the test and verify RED**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd
```

Expected: exit 1 because `wing_gameplay.tscn` does not exist.

- [ ] **Step 3: Add the faithful player and HUD scenes**

Author `gameplay_player.tscn` from the exact current `main.tscn` subtree: capsule radius `0.34`, height `1.75`, collision center `Y=0.875`, camera transform origin `(-0.00447291, 1.7162851, -0.13648391)` with the saved pitched basis, FOV `75`, and default `CarriedItems.max_bulk = 10`. Set only the three new-local player flags plus `1.4/2.3` reach values.

Author the HUD wrapper with `CarriedItemsHUD.carried_items_path = NodePath("../../Player/CarriedItems")` in saved data.

- [ ] **Step 4: Add the environment wrapper and strict proxy adapter**

Implement:

```gdscript
extends Node3D

const PROXY_NAMES: Array[String] = ["GalleryA_West", "GalleryB_North", "GalleryC_West"]
var _proxy_suppression_failures: Array[String] = []

func _ready() -> void:
	for proxy_name in PROXY_NAMES:
		var mesh := get_node_or_null("Greybox/Proxies/%s/Mesh" % proxy_name) as MeshInstance3D
		var shape := get_node_or_null("Greybox/Proxies/%s/StaticBody3D/CollisionShape3D" % proxy_name) as CollisionShape3D
		if mesh == null or shape == null:
			_proxy_suppression_failures.append(proxy_name)
			push_error("WingEnvironment proxy substitution is incomplete: %s" % proxy_name)
			continue
		mesh.visible = false
		shape.disabled = true

func get_proxy_suppression_failures() -> Array[String]:
	return _proxy_suppression_failures.duplicate()
```

The scene instances the accepted geometry and saves the neutral review lighting only.

- [ ] **Step 5: Add the composition and pre-ready optional-component handling**

Implement `wing_gameplay.gd` with `_enter_tree()` so child configuration precedes child `_ready()`:

```gdscript
extends Node3D

@export var development_setup_enabled: bool = true

func _enter_tree() -> void:
	var hud := get_node_or_null("HUD/CarriedItemsHUD")
	if hud != null:
		hud.set("carried_items_path", NodePath("../../Player/CarriedItems"))
	if not development_setup_enabled:
		var setup := get_node_or_null("DevelopmentSetup")
		if setup != null:
			remove_child(setup)
			setup.queue_free()
```

For this task, compose `Environment`, an empty placeholder `FunctionalFixtures`, `Player`, and `HUD`; do not add runtime seed behavior yet.

- [ ] **Step 6: Run the focused test and editor parser to verify GREEN**

Run the focused test command above, then:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path . --quit
```

Expected: focused test exits 0 with one `PASS:` line; editor exits 0 without a new parse/resource error.

- [ ] **Step 7: Commit Task 1**

Stage only Task 1 files and commit `feat: compose continuing wing gameplay scene`.

---

### Task 2: Three functional fixtures, proxy isolation, and measured clearance

**Files:**
- Create: `gameplay/logistics_wing/functional_fixtures.gd`
- Create: `gameplay/logistics_wing/functional_fixtures.tscn`
- Modify: `gameplay/logistics_wing/wing_gameplay.tscn`
- Modify: `tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd`

**Interfaces:**
- `FunctionalFixtures.get_installed_surfaces() -> Array[Node]` returns the twelve real runtime surfaces.
- `FunctionalFixtures.get_missing_top_clearance_contexts() -> Array[String]` delegates to the installed manager.
- `FunctionalFixtures.is_storage_debug_input_enabled() -> bool` returns false for the continuing scene.
- The existing `StoragePrototypeManager`, `StorageSurface`, controller, and all legacy callers remain unchanged.

- [ ] **Step 1: Extend the test with fixture/proxy/clearance failures**

Assert:

```gdscript
const FIXTURE_NAMES := [
	"SM_MetalShelves_GalleryA_West",
	"SM_MetalShelves_GalleryB_North",
	"SM_ventilated_locker_GalleryC_West",
]
```

For a loaded composition, require those three unique direct children, identity scales, the approved transforms, twelve distinct surface IDs, zero occupied cells/stacks, uninitialized zones, zero missing-context names, and no StorageSurface outside the fixture branches. Require `Environment.get_proxy_suppression_failures().is_empty()`, exact three hidden meshes/disabled shapes, and a separately instantiated neutral geometry/review with those same three meshes visible and shapes enabled.

Calculate each installed top surface's global `Y`, compare the saved explicit cap with `3.40 - surface_y`, and require a positive conservative clearance that cannot cross the ceiling. For the locker, also require the cap not to exceed the existing cabinet-limited `0.519 m` until a lower measured obstruction is found. Send an F7 key event through the viewport and assert surface occupancy/zone state is unchanged.

- [ ] **Step 2: Run the focused test and verify RED**

Expected: failures for the placeholder fixture root, missing surfaces, and missing fixture API.

- [ ] **Step 3: Implement the local fixture bootstrap**

Use `extends "res://environment_collision.gd"`, call `super._ready()`, find the dynamically created `StoragePrototypeManager`, disable its unhandled input locally with `set_process_unhandled_input(false)`, and expose read-only surface/context accessors. Saved scene flags remain `generate_test_collisions = true`, `generate_storage_prototype = true`, and `print_collision_summary = false`.

- [ ] **Step 4: Author the three fixtures and clearance contexts**

Instance the existing GLBs as the three required direct children. Add one direct `StorageShelfClearanceContext` per fixture. Use measured caps from the actual installed top planes and `Y=3.40 m` ceiling, keeping a documented small construction margin and the locker cabinet limit. Do not scale the fixtures or add any occupancy/zones.

- [ ] **Step 5: Replace the placeholder and verify GREEN**

Instance `functional_fixtures.tscn` at `WingGameplay/FunctionalFixtures`, run the focused suite and editor parser, and inspect the actual printed surface census. Correct only fixture-local placement/yaw/cap values if a real bounds or collision check fails.

- [ ] **Step 6: Commit Task 2**

Commit `feat: install wing storage fixtures` with only fixture, composition, and focused-test changes.

---

### Task 3: Saved table-and-loot fixture and deterministic registrar

**Files:**
- Create: `tools/asset_pipeline/tests/wing_seed_fixture_tests.gd`
- Create: `gameplay/logistics_wing/development/seed_host.gd`
- Create: `gameplay/logistics_wing/development/seed_registrar.gd`
- Create: `gameplay/logistics_wing/development/seeded_storage_setup.gd`
- Create: `gameplay/logistics_wing/development/seeded_storage_setup.tscn`
- Modify: `gameplay/logistics_wing/wing_gameplay.tscn`

**Interfaces:**
- `SeedHost.item_id: StringName` is the only authored gameplay declaration; identity comes from the unique direct-child name.
- `SeedHost.get_authored_visual() -> Node3D` returns the sole editor-visible imported visual child or null.
- `SeedRegistrar.register_existing_hosts() -> bool` validates all hosts before registering any and is idempotent.
- `SeedRegistrar.get_validation_failures() -> Array[String]` and `get_registered_instance_ids() -> Array[String]` expose diagnostics/census.
- `SeededStorageSetup.initialize_if_enabled() -> bool` is the composition entry and does not depend on `current_scene`.

- [ ] **Step 1: Write the failing seed-fixture tests**

Load the development scene in isolated contexts and assert the literal baseline multiset, twelve unique host names, identity scales, one visible visual per host, and no StorageSurface beneath `Tables` or `SeedItems`. After readiness require twelve `WorldItem` components, twelve distinct `ItemInstance` references, and IDs equal to `wing_seed_v1:<host_name>`.

Add real behavioral cases:

```gdscript
var moved := host.transform.translated_local(Vector3(0.07, 0.02, -0.04)).rotated_local(Vector3.UP, deg_to_rad(11.0))
host.transform = moved
# Pack a temporary copy, save under reports/.../tmp, reload, and compare moved.
```

Duplicate a host in a temporary in-memory fixture with a unique sibling name, invoke registration, and require thirteen distinct identities while the original twelve stay unchanged. Exercise a second `register_existing_hosts()` call after taking one item and require no duplication/resurrection.

Construct isolated invalid fixtures for unknown ID, excluded ID (`loot_000015`, `loot_000034`, `loot_000036`), duplicate derived identity, missing visual, and mismatched visual. Each case must return false with a named failure and zero newly created WorldItems.

- [ ] **Step 2: Run the seed test and verify RED**

Expected: exit 1 because the scene and registrar do not exist.

- [ ] **Step 3: Implement the data-only host**

Implement exported `item_id`, sole-visual discovery, and a configuration warning for empty IDs or visual-child count other than one. Do not add registration in editor mode and do not store a transform copy.

- [ ] **Step 4: Implement validate-then-register behavior**

Preload `PrototypeItemCatalog`, `ItemInstance`, and `WorldItem`. Validate every direct `SeedItems` child before mutation. Compare the authored visual's `scene_file_path` with `definition.visual_scene.resource_path`; reject blocked IDs and duplicate `wing_seed_v1:<host_name>` IDs. After validation, skip hosts already holding `WorldItem`, otherwise create the explicit instance and call `configure_existing(host, instance)`.

Never instantiate or reposition the visual in the registrar. Never scan `current_scene`. When a picked host is queued for deletion, a second call observes its existing/queued state and does not recreate it.

- [ ] **Step 5: Author tables and the twelve hosts**

Use one or two `SM_Table.glb` instances near Sorting/near Storage in clear circulation. Give the `Tables` root collision generation with `generate_storage_prototype = false`. Save the twelve uniquely named hosts and their actual catalogue visual scene instances at reachable table-top transforms. Keep all host and ancestor scales at identity.

- [ ] **Step 6: Add the removable setup to the continuing composition**

Instance it as `DevelopmentSetup`. Extend the composition test to instantiate once with `development_setup_enabled = false` and once with the child omitted before entering the tree; both contexts must retain the player, HUD, environment, and twelve empty storage surfaces while producing no table/seed nodes.

- [ ] **Step 7: Verify GREEN and commit Task 3**

Run both focused suites and the editor parser. Commit `feat: add editor-authored wing seed fixture`.

---

### Task 4: Ownership interaction coverage, preservation, evidence, and review bundle

**Files:**
- Create: `tools/asset_pipeline/tests/wing_storage_bridge_interaction_tests.gd`
- Create: `docs/testing/wing-gameplay-foundation-validation.md`
- Create: `reports/logistics_wing/storage_bridge/initial/fixture_census.json`
- Create: `reports/logistics_wing/storage_bridge/initial/protected_source_manifest.json`
- Create: `reports/logistics_wing/storage_bridge/initial/capture_manifest.json`
- Create: `reports/logistics_wing/storage_bridge/initial/README.md`
- Modify: `docs/CURRENT_STATE.md`
- Modify: `docs/README.md`
- Create outside Git or in ignored reports: `reports/logistics_wing/storage_bridge/initial/wing-gameplay-foundation-review.zip`

**Interfaces:**
- The interaction suite uses existing public `WorldItem`, `CarriedItems`, `StorageSurface`, and `StoragePlacementController` APIs and verifies object identity, counts, and rollback.
- Evidence JSON records baseline/source hashes, scene path, fixture transforms/caps, surface/seed IDs, renderer/display details, and exact test results.

- [ ] **Step 1: Write the failing integration checks**

From the real composed scene, take a seed through `WorldItem.pickup_into()`, initialize a real surface zone, and place it using the real `StoragePlacementController`. Require the exact same `ItemInstance` reference in loose, carried, stored, retrieved, and second-surface states.

Cover all four automatic families with real seed definitions, including a three-member `flat_media` or `round_cans` stack and middle retrieval/compression; use the hammer in manual rotated placement. Exercise carry-full pickup rejection, disabled/full/mismatched/erased-cell placement rejection, and force a failed commit to require the original carried slot, selection, identity, surface count, and total item count to remain unchanged.

- [ ] **Step 2: Run the interaction suite and verify RED**

Expected: fail on the first uncovered bridge wiring/identity expectation; if it passes immediately because existing algorithms already satisfy every case, add a scene-specific assertion that fails when the real bridge is disconnected rather than changing shared algorithms.

- [ ] **Step 3: Make only bounded bridge fixes and verify GREEN**

Fix composition/fixture/registrar wiring only. If a shared gameplay algorithm defect is required, stop and present the exact reproduction and minimal proposed shared change instead of expanding scope.

- [ ] **Step 4: Run focused, parser, and scene-smoke verification**

Run all three new suites, editor initialization, a bounded explicit `wing_gameplay.tscn` headless smoke, original `main.tscn` smoke, and neutral `wing_review.tscn` smoke. Each smoke is bounded and its exit code/output is recorded.

- [ ] **Step 5: Run the full established regressions and bounded legacy audit**

Run every `tools/asset_pipeline/tests/*_tests.gd` except `main_scene_loot_audit_integration_tests.gd` as the non-hanging set; require exit 0 and exactly one `PASS:` line per script. Run the excluded legacy audit with the established 25-second bound and record its exact inherited assertion/timeout ledger without calling it a pass.

- [ ] **Step 6: Prove preservation and create machine-readable evidence**

Compare protected paths byte-for-byte against `1491fd729f3237706ad9533274b7525f6b058932`, confirm `project.godot` default UID, verify rejected Receiving commit `c9752c8c68cd55b950dd588542ea271e1acc0aab` is not an ancestor, run `git diff --check`, and inventory only intended tracked changes. Include exact fixture transforms, measured cap math, proxy paths/states, twelve surface IDs, twelve seed IDs, and before/after transaction counts.

- [ ] **Step 7: Capture proportionate review views**

Capture roughly 8–12 views without overwriting accepted evidence: whole-wing plan, table coverage, each fixture front/height, carrying/HUD, a stored stack and retrieval/transfer state, plus an editor hierarchy view when UI automation is available. If a real editor move/duplicate/save/reopen cannot be automated honestly, include the serialized round-trip evidence and exact manual steps and leave the human editor operation PENDING.

- [ ] **Step 8: Update status/index and write validation**

Record the continuing-scene and saved-editor-seed supersessions, keep the three current master versions, preserve the preflight wording, and separate technical PASS/PENDING from human handling PENDING and default-launch PENDING. Include exact commands, scene/node names, fixture/cap table, identity policy, proxy whitelist, setup omission behavior, hashes/commits, diagnostics, and human PROMOTE/REVISE questions.

- [ ] **Step 9: Build and hash the review ZIP**

Include new tracked source/scenes/tests/docs and focused evidence only. Exclude `.godot/`, imported/licensed GLBs/textures, full-repository copies, and large legacy media. Compute SHA-256 and record which ignored local assets are required to run the project.

- [ ] **Step 10: Fresh final verification, review, and documentation commit**

Re-run the three focused suites, full non-hanging set, editor/parser, all three smokes, protected-source comparison, `git diff --check`, and Git status. Review the diff against every GF-01 through GF-14 requirement. Commit intended evidence/status/validation as `docs: validate wing gameplay foundation` and stop for human handling review without changing default launch.
