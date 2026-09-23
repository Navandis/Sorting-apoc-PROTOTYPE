# Receiving Deck Spatial Corrections Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the three approved human-review corrections without changing deterministic deck capacity, architecture, or TAKE-only behavior.

**Architecture:** Keep the 3.00 m × 2.00 m private `StorageSurface` and planner contracts intact. Pin front-to-rear placement in both local and installed world space, enlarge only the neutral support mesh to 3.10 m × 2.10 m, move the installed runtime 0.20 m toward world -X, then remeasure the real Receiving ray and update only its dedicated reach.

**Tech Stack:** Godot 4.7, typed GDScript, `.tscn` composition, SceneTree regression suites.

**Spec:** `C:/Users/Boschetar/.codex/attachments/16412aca-e6a1-4695-84ad-5eaa6d4db7a7/Pasted text.txt`

## Global Constraints

- One implementer; stay on `codex/receiving-deterministic-deck`; do not merge, push, reset, rebase, or squash.
- Preserve usable 3.00 m × 2.00 m, 0.10 m cells, 30 × 20 grid, 1.50 m clearance, planner ownership, append-only stacking, private surface, TAKE-only semantics, and manager lifecycle.
- Receiving FRONT is local +Z / player-barrier side; REAR is local -Z / lift interior; installed local +Z maps to world +X.
- Physical support only becomes 3.10 m × 2.10 m, centered for a non-reservable 0.05 m edge margin.
- Runtime root moves from world X -40.705 to -40.905; Y 0.82, Z 0, and orientation stay fixed.
- Loose reach remains 1.4 m and storage reach remains 2.3 m; Receiving reach is remeasured rather than assumed.

## Review Focus

- A row-direction assertion must prove actual local positions, not merely repeat a helper name.
- The second non-overlapping placement must move toward local -Z after the front row is unavailable.
- The visible 3.10 m × 2.10 m mesh must not change the backend grid or functional surface count.
- The installed transform must map local +Z to world +X at X -40.905 with no barrier movement.
- Reach evidence must use the real camera ray and collision-resolved apron stance after the shift.

---

### Task 1: Spatial regressions and bounded geometry correction

**Files:**
- Modify: `tools/asset_pipeline/tests/receiving_deck_layout_tests.gd`
- Modify: `tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd`
- Modify: `gameplay/logistics_wing/receiving/receiving_deck_presenter.tscn`
- Modify: `gameplay/logistics_wing/wing_gameplay.tscn`

**Interfaces:**
- Consumes: planner cell origins/frozen transforms, proof profile, installed runtime scene.
- Produces: explicit local +Z→-Z spatial proof, 3.10 m × 2.10 m support, root X -40.905, unchanged 30 × 20 backend.

- [ ] Add a two-placement layout regression with hand-derived row/local-Z expectations and composition assertions for usable grid, physical mesh size/margin, installed basis/origin, and 16 functional surfaces.
- [ ] Run layout and composition suites and confirm RED on missing second-placement proof, 3.00 m support, and old root X.
- [ ] Make the smallest scene/test-fixture correction required by the observed root cause; do not change planner or profile if the spatial proof confirms their existing semantics.
- [ ] Run layout, presenter, and composition suites GREEN, then commit `fix: refine Receiving deck presentation geometry`.

### Task 2: Reach remeasurement and validation history

**Files:**
- Modify: `player_controller.gd` only if measurement requires a new Receiving value.
- Modify: `gameplay/logistics_wing/wing_gameplay.tscn` only if measurement requires a new Receiving override.
- Modify: `tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd` to pin the measured override.
- Modify: `docs/testing/receiving-deterministic-deck-presenter-validation.md`.

**Interfaces:**
- Consumes: corrected installed geometry from Task 1 and the real `PlayerController._get_looked_at_world_item()` ray path.
- Produces: smallest passing 0.1 m Receiving-only value and append-only minor-revision evidence.

- [ ] Measure the rear-most visibly exposed real target from the collision-resolved barrier stance; prove the preceding 0.1 m setting fails and the chosen value succeeds.
- [ ] If the value changes, first update the composition expectation and confirm RED, then change only the Receiving default/saved override and confirm GREEN.
- [ ] Append a labelled minor-revision section preserving previous geometry/reach evidence and distinguishing implementation/validation/current tips.
- [ ] Run the three focused suites, justified reach regression, editor smoke, default smoke, and requested CLI review cases; inspect exit codes plus `SCRIPT ERROR`/`FAIL:`.
- [ ] Commit `test: record Receiving spatial correction validation` and leave the branch unmerged/unpushed.
