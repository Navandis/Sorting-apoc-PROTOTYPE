# Logistics-Wing Greybox Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and verify a complete, independently runnable, first-person greybox of the accessible Quartermaster logistics wing while preserving the current main test fixture and rejected Receiving branch.

**Architecture:** A review-local copy of the existing player traverses a generated-but-editor-inspectable primitive scene. A one-purpose builder owns explicit layout constants and emits ordinary Godot nodes to `wing_geometry.tscn`; a separate review scene supplies only lighting, labels, player, and capture support. Tests lock the player contract, topology, negative connections, scene resources, and capture manifest before implementation.

**Tech Stack:** Godot 4.7 stable, GDScript, `.tscn` resources, Jolt Physics, GL Compatibility renderer, PowerShell, Git

**Spec:** `docs/superpowers/specs/2026-09-15-logistics-wing-greybox-design.md`

## Global Constraints

- Base all work on local `main` commit `8ee62bd3bc4f23918717517e066d4c6a8cb565df` in the authoritative asset-complete checkout.
- Preserve `codex/receiving-elevator-stage-b-pass1-shell` at `c9752c8c68cd55b950dd588542ea271e1acc0aab` and do not reuse its geometry, palette, or measurements.
- Do not modify `main.tscn`, `project.godot`, shared gameplay scripts, catalogue/authoring data, ignored assets, or `.gitignore`.
- Do not commit the pre-existing untracked `reports/receiving/` files.
- Use Basic Structural Schematic V2 for gross walls/openings and Visual Direction v0.3 prose/Detailed Topology V3 for intent and relationships.
- Implement Receiving, Backlog, Sorting, Galleries A–E, C↔D, Dispatch, Workshop/Salvager, Medical, Kitchen, Incinerator, Bunker Ops, the deeper-settlement closure, and the Workshop-side blocked continuation.
- Do not add E→Deeper, other gallery shortcuts, gallery-mediated facility access, Medical↔Kitchen, or a lateral surface route.
- Keep normal scene ceilings visible; roof hiding is debug-capture-only and must not change collision.
- No functional Receiving, facility interiors, gameplay inventory, imported art, PBR pipeline, dressing, requests, progression, or generalized level generator.
- Human spatial review, workflow promotion, revision reliability, production-art approval, physical Receiving validation, and integrated balance remain unclaimed.

---

### Task 1: Review-local player harness

**Files:**
- Create: `greybox/logistics_wing/review_player.tscn`
- Create: `tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd`

**Interfaces:**
- Consumes: `res://player_controller.gd`, `res://carried_items.gd`, and the player properties inspected from `main.tscn`.
- Produces: `res://greybox/logistics_wing/review_player.tscn` with node paths `CharacterBody3D/CollisionShape3D`, `CharacterBody3D/Camera3D`, and `CharacterBody3D/CarriedItems`.

- [ ] **Step 1: Write the failing player contract test**

Add assertions that load `review_player.tscn`, instantiate it, and verify: controller script path, move speed `4.0`, sprint `2.0`, acceleration `18.0`, deceleration `24.0`, capsule radius `0.34`, height `1.75`, collision Y `0.875`, camera Y `1.7162851`, camera FOV `75`, exactly one current camera, and a `CarriedItems` child using the existing script. Also assert `project.godot` still names UID `uid://drbkr86g3cxl1` as the main scene.

- [ ] **Step 2: Run the test and confirm RED**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
```

Expected: non-zero or assertion output because `review_player.tscn` does not exist.

- [ ] **Step 3: Add the minimal player scene**

Create the copied subtree with unique resource identity and the exact transforms/properties from the design spec. Set only these disclosed review-local bindings: `prototype_auto_register_known_loot=false`, `print_loot_registration=false`, and `enable_held_item_view=false`. Do not edit the source scripts.

- [ ] **Step 4: Run the player contract and confirm GREEN**

Run the Task 1 command. Expected: exit 0 and one `PASS:` line after the test is temporarily limited to the player/default-launch contract.

- [ ] **Step 5: Commit the harness and test foundation**

```powershell
git add greybox/logistics_wing/review_player.tscn tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
git commit -m "test: lock logistics wing player contract"
```

### Task 2: Complete structural geometry and topology contract

**Files:**
- Modify: `tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd`
- Create: `greybox/logistics_wing/build_wing_geometry.gd`
- Create: `greybox/logistics_wing/wing_geometry.tscn`

**Interfaces:**
- Consumes: the dimensional/topology rules in the spec and `review_player.tscn` contract from Task 1.
- Produces: `wing_geometry.tscn`, district roots under `WingGeometry/Districts`, roof meshes under `WingGeometry/RoofVisuals`, markers under `WingGeometry/Anchors`, and root metadata `layout_revision`, `topology_edges`, `forbidden_edges`, `overall_extents_m`, `wall_thickness_m`, `clear_height_m`, and `regeneration_command`.

- [ ] **Step 1: Extend the geometry test and confirm RED**

Assert the generated scene exists and reloads; all required district roots, markers, proxies, fixed closures, and C↔D opening exist; topology metadata contains the required graph; forbidden edges are absent; every `BoxShape3D` is finite and positive; wall/floor/ceiling layers have collision; `RoofVisuals` defaults visible; and the root regeneration command is exact. Run the Task 1 test command and confirm failure because the geometry/build output is absent.

- [ ] **Step 2: Implement the one-purpose builder**

Add explicit constants for floor `0.30`, wall `0.30`, ordinary height `3.40`, Receiving height `4.20`, and the approved coordinate envelope. Implement small local helpers such as:

```gdscript
func add_box(parent: Node3D, node_name: String, center: Vector3, size: Vector3, material: Material, collision: bool = true) -> Node3D
func add_wall_x(parent: Node3D, node_name: String, x0: float, x1: float, z: float, height: float = CLEAR_HEIGHT) -> Node3D
func add_wall_z(parent: Node3D, node_name: String, x: float, z0: float, z1: float, height: float = CLEAR_HEIGHT) -> Node3D
func add_anchor(parent: Node3D, node_name: String, position: Vector3, facing_degrees: float) -> Marker3D
```

Hard-code named primitive calls for the complete plan. Assign every shared wall exactly once. Add shelf/table/machine/backlog proxy boxes and visible fixed blockers. Save only `res://greybox/logistics_wing/wing_geometry.tscn` and quit with a non-zero code on any save error.

- [ ] **Step 3: Generate and inspect the scene tree**

Run:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://greybox/logistics_wing/build_wing_geometry.gd
```

Expected: exit 0, a `WING_GEOMETRY_GENERATED` record, and an ordinary `.tscn` containing named primitive/collision nodes rather than runtime-only construction.

- [ ] **Step 4: Run the expanded geometry contract and confirm GREEN**

Run the Task 1 test command. Expected: exit 0, one `PASS:`, and no unexpected parser/resource errors.

- [ ] **Step 5: Run a parser scan**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path . --quit
```

Expected: exit 0. Record the known root-certificate diagnostic separately; fail on new parser, missing-resource, or script errors.

- [ ] **Step 6: Commit the complete structural first pass**

```powershell
git add greybox/logistics_wing/build_wing_geometry.gd greybox/logistics_wing/wing_geometry.tscn tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
git commit -m "feat: build complete logistics wing greybox"
```

### Task 3: Review scene and reproducible evidence capture

**Files:**
- Create: `greybox/logistics_wing/wing_review.tscn`
- Create: `greybox/logistics_wing/wing_capture.gd`
- Create: `greybox/logistics_wing/wing_capture.tscn`
- Create: `tools/asset_pipeline/tests/logistics_wing_capture_tests.gd`

**Interfaces:**
- Consumes: `wing_geometry.tscn` and `review_player.tscn`.
- Produces: an independently runnable review scene and full-resolution PNG/contact-sheet evidence under `res://reports/logistics_wing/greybox/` when launched with `--capture`.

- [ ] **Step 1: Write the failing capture/review contracts**

Verify the review scene instances exactly one geometry scene and one review player, contains a neutral `WorldEnvironment`, directional key, local fill lights, and diagnostic labels, and does not instance `main.tscn` or any `receiving/freight_bay_prototype.tscn`. Verify capture occurs only with `--capture`; view names/output basenames are stable; normal captures are `1920×1080`, `75°` FOV, and ceiling-on; the overview alone hides `RoofVisuals`; contact sheets are deterministic. Run and confirm RED because the files are absent.

- [ ] **Step 2: Add the minimal runnable review scene**

Instance the generated geometry and review player. Set the spawn to the Receiving apron anchor. Add even neutral lighting and diagnostic area IDs only. Keep `project.godot` unchanged; launch this scene explicitly.

- [ ] **Step 3: Add the capture helper and capture scene**

Implement fixed camera records containing basename, world position, target, FOV, roof state, and label. Required coverage: debug overview; Receiving/freight/core; three Sorting working-position directions; A/B; C/D; E/deeper boundary; Medical; Kitchen; Workshop/Salvager/blocked continuation; wide and narrow dog-leg; Incinerator; Bunker Ops/deeper closure. Record the same data in console output and use two readable contact sheets when needed.

- [ ] **Step 4: Run contracts and parser scan**

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_capture_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --editor --path . --quit
```

Expected: both test suites exit 0 with one `PASS:` each; parser scan exits 0 without new errors.

- [ ] **Step 5: Commit the review and capture harness**

```powershell
git add greybox/logistics_wing/wing_review.tscn greybox/logistics_wing/wing_capture.gd greybox/logistics_wing/wing_capture.tscn tools/asset_pipeline/tests/logistics_wing_capture_tests.gd
git commit -m "feat: add logistics wing review evidence harness"
```

### Task 4: Render inspection, normal-controller traversal, and correction

**Files:**
- Modify as defects require: `greybox/logistics_wing/build_wing_geometry.gd`
- Regenerate as defects require: `greybox/logistics_wing/wing_geometry.tscn`
- Modify as defects require: `greybox/logistics_wing/wing_review.tscn`, `greybox/logistics_wing/wing_capture.gd`, `greybox/logistics_wing/wing_capture.tscn`
- Create local evidence only: `reports/logistics_wing/greybox/*.png`

**Interfaces:**
- Consumes: the saved review/capture scenes and unchanged controller.
- Produces: inspected Godot renders, normal-controller traversal notes/times, and local corrections reflected in the same authored dimensions.

- [ ] **Step 1: Render the complete evidence set**

Run the capture scene with the non-headless renderer and `--capture`, using an explicit scene path. Require `CAPTURE_COMPLETE`, exit 0, all declared PNGs at `1920×1080`, and the contact sheets. Do not stage the PNGs or generated `.import` files.

- [ ] **Step 2: Inspect every full-resolution capture and contact sheet**

Check enclosure, ceiling visibility, threshold openings, sightline intent, district separation, proxy-induced lane widths, C↔D, E's closed boundary, no Medical↔Kitchen connection, Workshop blocked continuation, freight barrier, Incinerator spacing, dog-leg reveal, Bunker Ops frontage, and distinct deeper closure. Record defects before editing.

- [ ] **Step 3: Traverse with the actual review player**

Launch:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --editor-pid 0 --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://greybox/logistics_wing/wing_review.tscn'
```

Use normal WASD/mouse at the unchanged controller values. Walk every safe-side destination and test fixed boundaries. Directly time at minimum Receiving apron→Sorting work position, Sorting→Bunker Ops, and C↔D by both routes. Record start/end anchors, coordinates, walk speed, and observed seconds. Captures/teleports do not substitute for this step.

- [ ] **Step 4: Correct self-detectable defects test-first**

For a structural regression expressible in the contract, add the failing assertion first, run it RED, change the builder/review files, regenerate, run GREEN, and repeat the affected captures/traversal. Do not broaden scope or adjust movement/collider/FOV to hide layout defects.

- [ ] **Step 5: Commit focused corrections**

Stage only source/test scene changes, never `reports/receiving/` or capture PNGs. Use a focused commit such as:

```powershell
git commit -m "fix: correct logistics wing traversal defects"
```

### Task 5: Full regression, validation record, and first human handoff

**Files:**
- Create: `docs/testing/logistics-wing-greybox-validation.md`
- Modify only if final evidence exposes a defect: files from Tasks 2–4

**Interfaces:**
- Consumes: final saved scenes, capture evidence, route observations, Git history/diff, and baseline test behavior.
- Produces: reproducible delivery record and a scoped local commit ready for human walkthrough.

- [ ] **Step 1: Run focused and full technical verification**

Run the two new suites, editor/parser scan, original main-scene smoke launch, and every pre-existing `tools/asset_pipeline/tests/*_tests.gd` suite individually. Bound `main_scene_loot_audit_integration_tests.gd` to 25 seconds and compare its exact assertions to the preflight baseline. Record exit status, PASS count, and error output. Do not waive new failures under the `loot_000015` exception.

- [ ] **Step 2: Verify preservation and diff scope**

Run:

```powershell
git diff --check 8ee62bd3bc4f23918717517e066d4c6a8cb565df
git diff --exit-code 8ee62bd3bc4f23918717517e066d4c6a8cb565df -- main.tscn project.godot player_controller.gd camera_movement.gd data tools/asset_pipeline/item_authoring_review.json
git diff --stat 8ee62bd3bc4f23918717517e066d4c6a8cb565df
git status --short --untracked-files=all
git rev-parse codex/receiving-elevator-stage-b-pass1-shell
```

Expected: protected-file diff exits 0; rejected branch remains `c9752c8...`; only milestone sources/docs/tests are tracked. Generated `reports/receiving/` and `reports/logistics_wing/` remain untracked local evidence.

- [ ] **Step 3: Write the validation record**

Include exact branch/base/commit, Godot/version/renderer, explicit launch and regeneration commands, player parity table, topology checklist, dimensional and clear-lane table, measured/estimated route table, capture manifest/evidence paths, test output including known baseline diagnostics, intervention/rework/tool burden, scope gaps, and human walkthrough questions. Use separate statuses for technical completeness, traversal coverage, human spatial review, workflow feasibility, revision reliability, art approval, physical Receiving, and integrated balance.

- [ ] **Step 4: Re-run documentation-sensitive checks and commit**

Run `git diff --check`, the two new suites, parser scan, and original main smoke after the final record. Commit only scoped files:

```powershell
git add docs/testing/logistics-wing-greybox-validation.md docs/superpowers/specs/2026-09-15-logistics-wing-greybox-design.md docs/superpowers/plans/2026-09-15-logistics-wing-greybox-implementation-plan.md greybox/logistics_wing tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd tools/asset_pipeline/tests/logistics_wing_capture_tests.gd
git commit -m "docs: validate logistics wing greybox"
```

- [ ] **Step 5: Stop for human walkthrough**

Report local launch steps, branch/base/final commit, evidence paths, known limitations, and focused review questions. Mark human spatial review and revision reliability `PENDING`; do not push, merge, begin a speculative revision, implement functional Receiving, or start Applied Finish.
