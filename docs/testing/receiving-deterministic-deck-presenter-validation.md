# Receiving deterministic deck presenter validation

Status: **IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

## Validation identity

- Branch: `codex/receiving-deterministic-deck`
- Validated implementation HEAD: `5d355ed5cad137478ed2f06896b2e71640079ef7`
- Promoted baseline: `f2ed1b019c9e07a57e51896a5603f5e213c2fb14`
- Engine: `4.7.stable.official.5b4e0cb0f`
- Profile: `receiving_deck_stage_b_proof`, revision 1, layout version 1

The validation-record commit follows the implementation HEAD above; use `git rev-parse HEAD` for the complete reviewed branch tip.

## Installed proof geometry and behavior

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

## Receiving reach measurement

Measured headlessly in the actual wing, using the real baseline debug batch, item pickup colliders, player camera, private surface, and physics ray.

- Requested centered apron stance: player X `-38.955`; collision-resolved stance `(-38.49948, 0.000494, 0.0)`.
- Camera position: `(-38.50396, 1.716779, -0.136483)`.
- Exposed targets from that stance: 7.
- Rear exposed target X: `-41.6550`.
- Camera-to-hit distance: `3.516 m`.
- `3.5 m` failed the rear target; `3.6 m` succeeded.
- Provisional Receiving-only range: **3.6 m**. Loose remains 1.4 m and storage remains 2.3 m.

This is proof tuning for the provisional 2.0 m depth, not a final production value.

## Automated verification

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
