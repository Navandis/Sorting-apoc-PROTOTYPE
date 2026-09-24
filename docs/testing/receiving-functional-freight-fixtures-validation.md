# Receiving functional freight fixtures validation

Status: **WAVE 1 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN CALIBRATION REVIEW COMPLETE / REVISION APPLIED**

## Scope and authority

Wave 1 adds Receiving-only freight-fixture definitions, candidate sockets, pure size/eligibility policy, focused tests, and a retained calibration scene. It does not activate fixtures in live deliveries, reserve fixture footprints in runtime layouts, place items on fixtures, persist fixture state, or change the planner, presenter, `LootBatch`, Expedition generation, ordinary storage, the 3.00 m × 2.00 m Receiving deck, or the 2.1 m Receiving reach.

Human review accepted the fixture calibration and socket layout with one required revision: reduce every fixture's Y-axis stack-clearance guide by 20%. This record applies that revision. Wave 2 remains separate and has not begun.

## Local asset preflight and provisional calibration

Godot 4.7 loaded and instantiated each authoritative local GLB successfully. Every imported scene has an identity root transform, unit scale, and one measurable mesh. Aggregate source bounds were inspected locally; no source file was rotated, rescaled, re-exported, or edited.

| Fixture ID | Resolved local asset path | Family | Load | Measured source bounds (X × Y × Z m) | Provisional base footprint | Provisional visual transform origin (m) | Provisional support-plane origin (m) | Provisional usable W × D (m) | Provisional clearance (m) | Notes / uncertainty |
|---|---|---|---|---:|---:|---:|---:|---:|---:|---|
| `crate_plastic_01` | `res://assets/environment/dressing/containers/SM_PlasticBox_01.glb` | Crate | Success | 0.4704 × 0.1280 × 0.5824 | 5 × 6 | (0, 0, 0) | (0, 0.028, 0) | 0.39 × 0.50 | 0.52 | Mesh bounds seed the base only. Human-reviewed; clearance reduced by 20%. |
| `crate_plastic_06` | `res://assets/environment/dressing/containers/SM_PlasticBox_06.glb` | Crate | Success | 0.4500 × 0.1249 × 0.6400 | 5 × 7 | (0, 0, 0) | (0, 0.028, 0) | 0.37 × 0.55 | 0.52 | Human-reviewed; clearance reduced by 20%. |
| `crate_palletcart_box` | `res://assets/environment/dressing/containers/SM_PalletCart_box.glb` | Crate | Success | 0.3509 × 0.1312 × 0.6174 | 4 × 7 | (0, 0.000154, 0) | (0, 0.030, 0) | 0.27 × 0.52 | 0.52 | Human-reviewed; clearance reduced by 20%. |
| `crate_wood_01` | `res://assets/environment/dressing/containers/SM_Wooden_Crates_01.glb` | Crate | Success | 0.4013 × 0.1327 × 0.5576 | 5 × 6 | (0, 0.002239, 0) | (0, 0.032, 0) | 0.32 × 0.47 | 0.52 | Human-reviewed; clearance reduced by 20%. |
| `crate_wood_02` | `res://assets/environment/dressing/containers/SM_Wooden_Crates_02.glb` | Crate | Success | 0.4129 × 0.1257 × 0.5900 | 5 × 6 | (0, 0.000330, 0) | (0, 0.030, 0) | 0.33 × 0.50 | 0.52 | Human-reviewed; clearance reduced by 20%. |
| `pallet_01` | `res://assets/environment/dressing/containers/SM_Pallet01.glb` | Pallet | Success | 0.9635 × 0.1200 × 1.2814 | 10 × 13 | (0, 0, 0) | (0, 0.120, 0) | 0.88 × 1.18 | 0.96 | Human-reviewed; clearance reduced by 20%. |
| `pallet_wood_03` | `res://assets/environment/dressing/containers/SM_WoodPallet_03.glb` | Pallet | Success | 0.8627 × 0.1558 × 1.2941 | 9 × 13 | (0, 0.000001, 0) | (0, 0.155829, 0) | 0.78 × 1.18 | 0.96 | Human-reviewed; clearance reduced by 20%. |
| `pallet_industrial_worn_07` | `res://assets/environment/dressing/containers/SM_Ind_War_Storage_Pallet_Wood_Worn_07.glb` | Pallet | Success | 0.7618 × 0.1340 × 1.0521 | 8 × 11 | (0, 0.012479, 0) | (0, 0.133952, 0) | 0.68 × 0.96 | 0.96 | Human-reviewed; clearance reduced by 20%. |

All provisional transforms retain the source basis. Functional fixture FRONT remains local `+Z` toward the player barrier/apron; REAR remains local `-Z` toward the lift interior. If a mesh reads backward during review, adjust only its `visual_local_transform`; do not reverse the functional convention.

## Provisional MainDeck socket candidates

The proof profile remains a 30 × 20 grid. These are sparse authoring candidates only; later runtime planning must validate the selected fixture's rotated base footprint and all conflicts before use.

| Socket ID | Family | MainDeck origin | Quarter turns | Distribution intent |
|---|---|---:|---:|---|
| `crate_front_left` | Crate | (1, 14) | 0 | Front / left |
| `crate_middle_center` | Crate | (12, 7) | 1 | Middle / center |
| `crate_rear_right` | Crate | (24, 1) | 0 | Rear / right |
| `pallet_front_right` | Pallet | (16, 10) | 1 | Front / right; rotated candidate |
| `pallet_rear_left` | Pallet | (1, 1) | 0 | Rear / left |

The set provides three crate and two pallet candidates without creating a dense arbitrary grid. Candidate sockets are not promises that every fixture combination is simultaneously legal.

## Human calibration procedure

1. Open `res://gameplay/logistics_wing/receiving/review/receiving_freight_fixture_calibration.tscn` in Godot 4.7.
2. Select the scene root. In the Inspector, assign each of the eight resources from `res://data/receiving/freight_fixtures/` to `fixture_definition`, one at a time.
3. Use `preview_item_definition` to inspect real catalogue items through the canonical stored-pose path. Recommended representatives are:
   - 1×1: `res://data/items/definitions/loot_000022.tres` (Soda Can)
   - 2×1: `res://data/items/definitions/loot_000026.tres` (Bandages)
   - 2×2: `res://data/items/definitions/loot_000029.tres` (Ball)
   - 3×3: `res://data/items/definitions/loot_000012.tres` (Watermelon)
   - bulky pallet cargo: `res://data/items/definitions/loot_000011.tres` (Pig Carcass, 10×5)
4. Review from local `+Z` first. The green label marks FRONT / apron; the red label marks REAR / lift. The blue grid is the base footprint, green is the support plane, amber is the usable rectangle, and purple is the stack-clearance volume.
5. For every crate/box, confirm the base footprint covers physical floor occupation; the support plane sits visibly inside/on the container bottom; eligible 1×1, 2×1, and 2×2 items remain visible from `+Z`; the usable rectangle avoids wall penetration; clearance is sensible; and the result still reads as a crate/box rather than a shallow tray.
6. For every pallet, confirm the base footprint covers the real pallet; the support plane sits on the top deck; the cargo rectangle is safely inset from feet and protruding edges; representative Large cargo has no obvious unsupported overhang; and clearance is sensible.
7. Open `res://data/receiving/receiving_deck_stage_b_proof.tres` and review the five socket resources for plausible distribution, variety, floor-cargo room, crowding, and likely support for some three-crate and two-pallet combinations.
8. Any later fixture `.tres` or socket edits made directly in the Inspector are authoritative developer authoring and must be preserved.

Human calibration review is complete. All values and the socket layout were accepted with the recorded uniform 20% stack-clearance reduction. Do not begin Wave 2 as part of this Wave-1 revision.

## Automated verification

The focused suite covers size-band boundaries, exact crate blacklist behavior, count limits, definition/socket validation, all eight resource bindings and families, visual instantiation, profile backward compatibility, proof-profile references/sockets, and the calibration scene's fixture/item preview contract.

Final command results and branch identity are recorded in the Wave-1 handoff after the required adjacent regressions and smoke checks run.

Known baseline diagnostics:

- Windows reports `Failed to read the root certificate store.` during headless runs.
- `wing_gameplay_composition_tests.gd` deliberately logs two duplicate seed-namespace rejection errors; the named negative tests pass.
