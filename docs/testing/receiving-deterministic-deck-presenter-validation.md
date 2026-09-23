# Receiving deterministic deck presenter validation

Status: **IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN RE-REVIEW PENDING**

## Validation identity

- Branch: `codex/receiving-deterministic-deck`
- Validated implementation HEAD: `5d355ed5cad137478ed2f06896b2e71640079ef7`
- Promoted baseline: `f2ed1b019c9e07a57e51896a5603f5e213c2fb14`
- Engine: `4.7.stable.official.5b4e0cb0f`
- Profile: `receiving_deck_stage_b_proof`, revision 1, layout version 1

The validation-record commit follows the implementation HEAD above; use `git rev-parse HEAD` for the complete reviewed branch tip.

## Initial validation: installed proof geometry and behavior

- Usable deck: 3.00 m wide × 2.00 m deep, 0.10 m cells, 30 × 20 grid.
- Clearance: 1.50 m physical; planner append checks use the existing 95% stack limit.
- Runtime root transform: origin `(-40.705, 0.82, 0.0)` with local `+Z` mapped to world `+X` (apron/front).
- Usable world bounds: X `-41.705 .. -39.705`, Z `-1.50 .. +1.50`; deck top Y `0.82`.
- Private backend: one ordinary `StorageSurface`, excluded from the 16 functional wing surfaces, with player PUT collision, zones, normal grid, and F6 grid disabled.
- Presenter states: `HIDDEN`, `AVAILABLE`, `DRAINED_WAITING_CLOSE`. Final TAKE does not retire the active batch or reveal a queued batch.
- Normal launch produces no synthetic Receiving batch. Debug generation exists only behind `--receiving-deck-debug`.

## Determinism and failure behavior

- Baseline debug case: content seed 1842, presentation seed 9001, target Bulk 24.
- Baseline result: 24 exact entries / actual Bulk 24; layout succeeded on attempt 1.
- Maximum deterministic attempts: 4, all derived from the same presentation seed.
- Exhaustion result: `insufficient_layout_capacity`; the batch remains byte-equivalent `CONTENT_COMMITTED` and consumes no manager slot.
- Automated checks prove identical content seed preserves definition/count/identity/economics while presentation seed changes only layout.
- Stable persisted presentation groups reconstruct without planner invocation. Released leading members center-shrink the new base and compact vertical positions; live stacks use the current base item identity so ordinary atomic base rekey remains valid.

## Initial validation: Receiving reach measurement

Measured headlessly in the actual wing, using the real baseline debug batch, item pickup colliders, player camera, private surface, and physics ray.

- Requested centered apron stance: player X `-38.955`; collision-resolved stance `(-38.49948, 0.000494, 0.0)`.
- Camera position: `(-38.50396, 1.716779, -0.136483)`.
- Exposed targets from that stance: 7.
- Rear exposed target X: `-41.6550`.
- Camera-to-hit distance: `3.516 m`.
- `3.5 m` failed the rear target; `3.6 m` succeeded.
- Provisional Receiving-only range: **3.6 m**. Loose remains 1.4 m and storage remains 2.3 m.

This is proof tuning for the provisional 2.0 m depth, not a final production value.

## Initial validation: automated verification

All commands used `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe` on 2026-09-23.

| Check | Result |
|---|---|
| `receiving_loot_batch_tests.gd` | PASS, exit 0 |
| `receiving_manager_tests.gd` | PASS, exit 0 |
| `receiving_stage_a_integration_tests.gd` | PASS, exit 0 |
| `receiving_deck_layout_tests.gd` | PASS, exit 0 |
| `receiving_deck_presenter_tests.gd` | PASS, exit 0 |
| `storage_stack_surface_tests.gd` | PASS, exit 0 |
| `storage_stacking_interaction_tests.gd` | PASS, exit 0 |
| `wing_gameplay_composition_tests.gd` | PASS, exit 0; 16 functional surfaces retained |
| `--headless --editor --path . --quit` | PASS, exit 0 |
| `--headless --path . --quit-after 120` | PASS, exit 0; no synthetic batch |
| CLI debug 1842/9001/24 | PASS, exit 0 |
| CLI presentation variants 9002 and 9003 | PASS, exit 0 |
| CLI content variants 2718 and 31415 | PASS, exit 0 |

No `SCRIPT ERROR` or `FAIL:` occurred in the required verification runs. The Windows build logs a root-certificate-store warning. The composition suite deliberately exercises and logs duplicate seed-namespace rejection twice; those named negative checks pass and are pre-existing expected diagnostics.

## Human review commands

Run from the project root in PowerShell:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'

# Baseline
& $godot --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24

# Same exact loot generation, alternate presentation
& $godot --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9002 --receiving-target-bulk=24
& $godot --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9003 --receiving-target-bulk=24

# Small alternate-content sample
& $godot --path . -- --receiving-deck-debug --receiving-content-seed=2718 --receiving-presentation-seed=9001 --receiving-target-bulk=24
& $godot --path . -- --receiving-deck-debug --receiving-content-seed=31415 --receiving-presentation-seed=9001 --receiving-target-bulk=24
```

Review 3 m × 2 m proportions, freight/readability, occlusion and variation, rear targeting, legal stacks, base TAKE/compression, eventual drainability, and absence of PUT/zoning/grid affordances. Human disposition remains **PROMOTE / REVISE**.

## Minor revision: spatial corrections after REVISE

Human disposition accepted the core design and requested only fill direction, physical edge margin, deck offset, and reach retuning. The revision implementation commit is `d8d931b` (`fix: refine Receiving deck presentation geometry`); the validation-record commit follows it, and `git rev-parse HEAD` remains authoritative for the current branch tip.

### Revised geometry

- Functional usable area before/after: unchanged at **3.00 m × 2.00 m**.
- Functional grid before/after: unchanged at **30 × 20**, with 0.10 m cells.
- Physical support: **3.10 m × 2.10 m**, centered on the functional grid.
- Non-reservable physical margin: **0.05 m on every edge**.
- Previous runtime root: approximately `(-40.705, 0.82, 0.0)`.
- Revised runtime root: exactly `(-40.905, 0.82, 0.0)`.
- Revised transform: `Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, -40.905, 0.82, 0)`.
- Revised usable world depth: front X approximately `-39.905`, rear X approximately `-41.905`.
- Revised physical support depth: front X approximately `-39.855`, rear X approximately `-41.955`.
- Width centre remains world Z `0`; usable width remains Z `-1.50 .. +1.50`; physical support is Z `-1.55 .. +1.55`.

The root moved exactly 0.20 m in world `-X`; the permanent barrier did not move. Diagnostic evidence found that planner row order was already highest-to-lowest, but the old installed basis mapped local `+Z` to world `-X`. The corrected basis now makes the binding fill direction true in the live wing:

`local +Z / player-barrier side → local -Z / lift rear`

The spatial regression proves the first simple placement uses the highest valid row and positive local Z, while the next forced non-overlapping placement uses a lower row and negative local Z.

### Revised Receiving reach

The previous **3.6 m** value and 3.516 m hit remain the historical evidence for the previous root/orientation.

The revised measurement used the actual collision-resolved barrier stance and real `PlayerController` camera ray. Common measurement context:

- Collision-resolved player stance: `(-38.49948, 0.000494, 0.0)`.
- Camera position: `(-38.50396, 1.716779, -0.136483)`.
- Runtime root: `(-40.905, 0.82, 0.0)` with local `+Z` mapping to world `+X`.

Measured requested re-review scenarios:

| Content / presentation seed | Exposed targets | Rear exposed item X | Hit distance | Minimum passing 0.1 m value |
|---|---:|---:|---:|---:|
| 1842 / 9001 baseline | 16 | -40.405 | 1.616 m | 1.7 m |
| 31415 / 9001 stack variant | 19 | -40.305 | 1.719 m | 1.8 m |
| 1842 / 9002 alternate presentation | 12 | -40.555 | 2.049 m | 2.1 m |

For each measurement, the immediately lower 0.1 m setting failed and the listed setting succeeded through the real ray path. The revised Receiving-only range is therefore **2.1 m**, the smallest value that passes all three requested re-review scenarios. Loose remains **1.4 m** and normal storage remains **2.3 m**.

### Minor-revision verification

All commands used `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe` on 2026-09-23.

| Check | Result |
|---|---|
| `receiving_deck_layout_tests.gd` | PASS, exit 0; explicit local +Z FRONT to local -Z REAR proof |
| `receiving_deck_presenter_tests.gd` | PASS, exit 0 |
| `wing_gameplay_composition_tests.gd` | PASS, exit 0; support/grid/margin/root/basis and 16 functional surfaces verified |
| `receiving_physics_pile_proof_tests.gd` | PASS, exit 0; historical proof override unaffected |
| `--headless --editor --path . --quit` | PASS, exit 0 |
| `--headless --path . --quit-after 120` | PASS, exit 0; no synthetic batch |
| CLI baseline 1842/9001/24 | PASS, exit 0 |
| CLI stack variant 31415/9001/24 | PASS, exit 0 |
| CLI presentation variant 1842/9002/24 | PASS, exit 0 |

No `SCRIPT ERROR` or `FAIL:` occurred. The Windows root-certificate-store warning and the composition suite's two intentional duplicate seed-namespace rejection diagnostics remain the only known diagnostics.

### Human re-review commands

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'

# Baseline
& $godot --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24

# Useful stack/occlusion variant from prior review
& $godot --path . -- --receiving-deck-debug --receiving-content-seed=31415 --receiving-presentation-seed=9001 --receiving-target-bulk=24

# Same content, alternate presentation
& $godot --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9002 --receiving-target-bulk=24
```

Re-review is limited to corrected front-to-rear fill, the 5 cm physical border, front-row visibility from the barrier, rear exposed targeting, representative base-TAKE compression, and continued absence of storage affordances. Disposition remains **PROMOTE / REVISE**.
