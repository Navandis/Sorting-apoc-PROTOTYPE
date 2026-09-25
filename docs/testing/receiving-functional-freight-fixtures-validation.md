# Receiving functional freight fixtures validation

Status: **WAVE 2 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW COMPLETE / PROMOTED**

## Scope and authority

Wave 1 adds Receiving-only freight-fixture definitions, candidate sockets, pure size/eligibility policy, focused tests, and a retained calibration scene. It does not activate fixtures in live deliveries, reserve fixture footprints in runtime layouts, place items on fixtures, persist fixture state, or change the planner, presenter, `LootBatch`, Expedition generation, ordinary storage, the 3.00 m × 2.00 m Receiving deck, or the 2.1 m Receiving reach.

Human review accepted the fixture calibration and socket layout with one required revision: reduce every fixture's Y-axis stack-clearance guide by 20%. This record applies that revision. The Wave-1 history below remains authoritative; the Wave-2 implementation record is appended after it.

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

## Wave 2 implementation record

Implementation checkpoint: `9b3847a` (`feat: integrate deterministic Receiving freight fixtures`)

The proof profile is now `revision = 2`, `layout_version = 2`. All eight approved fixture resources, their calibrated visual/item-surface transforms, base footprints, usable dimensions, reduced stack clearances, and all five socket origins/orientations are unchanged from the approved Wave-1 checkpoint.

### Persisted presentation schema

`ReceivingFreightFixtureInstance` persists the durable instance ID, definition ID, family, socket ID, stable private-surface ID, rotated MainDeck footprint/origin, quarter turns, and presenter-local fixture transform. `LootBatch.presentation_fixtures` is a read-copy collection serialized under `presentation_fixtures`.

Historical snapshots without that key restore an empty list. `CONTENT_COMMITTED` snapshots cannot carry fixtures. Prepared bare-deck snapshots remain valid. Fixture-aware deck commitment validates the entire placement and fixture collection before mutation, including unique instance/surface/socket identities, definition/socket family agreement, profile membership, limits, rotated MainDeck bounds, fixture-base overlap, initial fixture use, and active surface references.

Stable fixture surfaces are `Crate_00` through `Crate_02` and `Pallet_00` through `Pallet_01`. Limits remain three crates and two pallets. Definition selection is without replacement within each family.

### Deterministic planner behavior

The planner exposes `BARE`, `CRATES_ALLOWED`, `PALLETS_ALLOWED`, and `MIXED`; the backward-compatible default is `BARE`. Fixture activation is lazy and attempt-local. A fixture base reserves MainDeck cells under a non-item owner before its triggering item is placed, and failed candidates roll back fully. No successful layout can contain an initially empty fixture.

Surface preferences are:

- eligible Small: crate, MainDeck, pallet;
- blacklisted Small: MainDeck, pallet;
- Medium: MainDeck, pallet;
- Large: pallet, MainDeck.

The crate blacklist remains Mouse (`loot_000001`), Antibiotics (`loot_000025`), and Book (`loot_000030`). The seeded mixed sequence is preserved except that entries already occupying Large positions are reordered by descending footprint area with a deterministic seed-derived equal-area tie-break. Small and Medium positions do not move.

### Reconstruction and presentation

The presenter reconstructs persisted fixtures before item groups and never invokes the planner. It reserves each fixture base on the private runtime MainDeck, instantiates the exact persisted visual using the approved transform, and creates a private `ReceivingDeckSurface` from the approved item-surface calibration. Fixture visuals have no `WorldItem`, pickup interaction, PUT target, zoning, label, or visible/F6 grid.

Fixtures remain visible and reserved after their last item is TAKEN. A partially drained reconstruction recreates an empty historical fixture and its private surface until the delivery is explicitly closed. Fixture item stacks continue to use ordinary `StorageStack` append, TAKE, base-promotion, and compression behavior. Receiving reach remains 2.1 m; loose/storage reach remains 1.4/2.3 m.

### Focused technical verification

All commands used Godot `4.7.stable.official.5b4e0cb0f` and exited `0`:

| Verification | Result |
|---|---|
| `receiving_freight_fixture_policy_tests.gd` | PASS; approved resource/policy calibration retained |
| `receiving_freight_fixture_runtime_tests.gd` | PASS; persistence, atomic validation, modes, preferences, lazy activation, Large priority, reservations, and deterministic unique selection |
| `receiving_loot_batch_tests.gd` | PASS; historical and existing snapshot behavior retained |
| `receiving_deck_layout_tests.gd` | PASS; default bare planner and promoted spatial behavior retained |
| `receiving_deck_presenter_tests.gd` | PASS; exact identity, private surfaces, fixture reconstruction, empty-fixture persistence, CLI parsing |
| `wing_gameplay_composition_tests.gd` | PASS; exactly 16 ordinary functional surfaces retained |
| `storage_stack_surface_tests.gd` | PASS |
| `storage_stacking_interaction_tests.gd` | PASS |
| four same-batch fixture-mode CLI smokes | PASS |
| crate-heavy, bulky-pallet, and three blacklist CLI smokes | PASS |

### Human proof commands and bounded seed evidence

Run each from the project root with the same presentation seed and Bulk. These four compare the exact same generated batch (`content_seed=1842`) while changing presentation only:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=bare
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=crates
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=pallets
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=mixed
```

A bounded scan of content seeds `1..500` identified:

- crate-heavy: seed `249` (15 eligible Small entries), use `--receiving-fixture-mode=crates`;
- bulky pallet: seed `142` (14 Large entries; maximum footprint area 50), use `--receiving-fixture-mode=pallets`;
- blacklist coverage: seed `1` includes Book, seed `2` includes Mouse, and seed `3` includes Antibiotics; use crate mode and verify those exact items remain on an allowed fallback surface.

Replace only `--receiving-content-seed` in the commands above for these targeted cases. The targeted headless smokes for seeds `249`, `142`, `1`, `2`, and `3` all exited `0`.

### Human review checklist

- Compare seed 1842 across all four modes and confirm exact loot/identity is unchanged.
- Confirm crates group eligible Small items and never receive Mouse, Antibiotics, or Book.
- Confirm bulky Large cargo gets pallet opportunity before thin Large cargo without global sorting.
- Confirm the floor remains useful and fixture bases never overlap floor items or other fixtures.
- TAKE items from fixture stacks, including a base item, and confirm familiar promotion/compression.
- Empty a fixture and confirm its visual remains until the delivery closes.
- Confirm fixtures expose no prompt, PUT, zoning, labels, grids, or F6 surface.

Disposition: **PROMOTE / REVISE**

Known diagnostics remain the Windows root-certificate warning and the two intentional duplicate-namespace errors in `wing_gameplay_composition_tests.gd`. No new Wave-2 diagnostic is known.

## Human-review correction record

Status after this technical pass: **WAVE 2 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN RE-REVIEW PENDING**

Human review found that manual placement could bypass the private Receiving surface contract by ray-targeting a mechanically stored WorldItem and asking its owning StorageSurface for a manual stack fit. This was not a WorldItem ownership defect: Receiving items must remain mechanically stored for ordinary TAKE, removal, base promotion, and compression.

StoragePlacementController now applies the owning surface's generic is_player_storage_interaction_enabled() contract before accepting either a stored-item stack target or a direct surface target, and rechecks the same contract before commit. A real controller regression aims at a stored pickup Area3D and proves that a private stack exposes no target, valid fit, ghost, grid, prompt, placement, carry mutation, or stack mutation. Presenter integration coverage repeats that proof against both a reconstructed Receiving MainDeck stack and a fixture-private stack with a prevalidated compatible append. The same controller test re-enables an ordinary surface and proves manual stacking still succeeds.

### Corrected freight depth order

The proof profile is now revision 3, layout version 3. Only socket placement changed; every human-calibrated fixture resource value remains unchanged.

| Socket ID | Family | MainDeck origin | Quarter turns | Rotated base range |
|---|---|---:|---:|---|
| crate_front_left | Crate | (1, 13) | 0 | 4–5 × 6–7; front edge reaches row 19 or 20 |
| crate_middle_center | Crate | (12, 13) | 0 | 4–5 × 6–7; front edge reaches row 19 or 20 |
| crate_rear_right | Crate | (24, 13) | 0 | 4–5 × 6–7; front edge reaches row 19 or 20 |
| pallet_front_right | Pallet | (19, 0) | 0 | 8–10 × 11–13; rear anchored |
| pallet_rear_left | Pallet | (1, 0) | 0 | 8–10 × 11–13; rear anchored |

The names are retained as durable socket identities; coordinates and actual rotated footprints are the tested authority. Every enabled fixture definition fits every matching socket, every pair of candidates can coexist, and the complete three-crate/two-pallet candidate arrangement is legal. MainDeck's existing front-to-rear scan is unchanged.

### Receiving-only reach remeasurement

The previous promoted Receiving reach was **2.1 m**. It remains the historical result for the bare deterministic deck before rear freight fixtures were active; it has not been rewritten or reinterpreted as fixture evidence.

The correction measurement used the live wing_gameplay, its normal CharacterBody3D, collision resolution against the permanent freight barrier, the real Camera3D, persisted fixture transforms, calibrated private surfaces, real WorldItem/PickupArea geometry, and the production pickup ray. Ordinary lateral movement was represented by three fixed apron-side stance lanes at world Z = -1.2, 0.0, +1.2; no stance entered the lift or aligned continuously to an item's exact lateral coordinate. Each scenario was progressively drained through the production ray so later-exposed items also entered the envelope.

The table records the hardest progressively TAKEN target for each represented surface kind:

| Scenario | Player position | Camera position | Entry / item | Surface / cell | Ray hit position | Hit distance |
|---|---|---|---|---|---|---:|
| 1842 / mixed | (-38.49946, 0.000684, -1.2) | (-38.50394, 1.716969, -1.336484) | entry_0018 / Milk Carton 1 | Crate_00 / (0, 0) | (-40.40707, 0.983680, -1.057037) | 2.059 m |
| 1842 / mixed | (-38.49946, 0.000684, 0.0) | (-38.50394, 1.716969, -0.136484) | entry_0010 / Pistol | MainDeck / (18, 17) | (-40.00307, 0.883258, -0.391178) | 1.734 m |
| 1842 / mixed | (-38.49946, 0.000684, -1.2) | (-38.50394, 1.716969, -1.336484) | entry_0023 / Computer Tower 01 | Pallet_01 / (5, 1) | (-41.20308, 1.232270, -1.165920) | 2.748 m |
| 249 / crates | (-38.49946, 0.000684, -1.2) | (-38.50394, 1.716969, -1.336484) | entry_0016 / Dry Goods 01a | Crate_00 / (1, 0) | (-40.40320, 0.942132, -1.154951) | 2.059 m |
| 249 / crates | (-38.49946, 0.000684, +1.2) | (-38.50394, 1.716969, 1.063516) | entry_0009 / Shotgun | MainDeck / (3, 10) | (-40.32277, 0.899419, 1.098422) | 1.994 m |
| 142 / pallets | (-38.49946, 0.000684, 0.0) | (-38.50394, 1.716969, -0.136484) | entry_0016 / Assault Rifle | MainDeck / (16, 8) | (-40.37729, 0.932460, -0.242756) | 2.034 m |
| 142 / pallets | (-38.49946, 0.000684, 0.0) | (-38.50394, 1.716969, -0.136484) | entry_0013 / Firewood 01 | Pallet_01 / (0, 0) | (-41.68300, 1.027210, -0.687521) | **3.299 m** |

Dmax = 3.299374 m, therefore:

ceil_to_0.1(Dmax + 0.10 m) = ceil_to_0.1(3.399374 m) = 3.4 m

The saved wing_gameplay Receiving-only reach is now **3.4 m**. Loose remains **1.4 m** and ordinary storage/manual placement remains **2.3 m**. This value is new evidence from the current 2.0 m deterministic deck, barrier standoff, calibrated rear pallets, lateral player movement envelope, and real pickup-area hits; it does not restore or promote the rejected irregular physics-pile proof range.

The limiting seed-142 Firewood target was replayed from a fresh scene. At **3.3 m** the ray technically touches the pickup area but has only **0.000626 m** headroom, so it fails the agreed 0.10 m tolerance. At **3.4 m** the same production ray resolves the exact WorldItem. All fixture items retain PickupReachKind.RECEIVING.

### Crate ray and pallet occlusion rechecks

Seed 249's 1×1 Dry Goods item at crate cell (1, 0) and seed 1842's Milk Carton at crate cell (0, 0) both resolve through their ordinary enabled WorldItem pickup areas after the range correction. The suspected crate-ray problem is therefore recorded as range-related; no X-ray, ray skipping, collision-layer exception, or fixture-specific targeting path was added.

All persisted entries in each of the three requested scenarios—24/24 for mixed, 24/24 for crates, and 24/24 for pallets—became exposed and were progressively TAKEN from the three normal player-side stance lanes. No post-socket example remained completely concealed from all tested normal viewpoints, so no loose-cargo band/scoring algorithm was added. Fixture visual descendants own no WorldItem, loot PickupArea, or collision object on the pickup interaction layer.

### Correction verification

All commands used Godot 4.7.stable.official.5b4e0cb0f and exited 0:

| Verification | Result |
|---|---|
| storage_stacking_interaction_tests.gd | PASS; private ray target rejects every PUT artifact and ordinary manual stack succeeds |
| receiving_freight_fixture_runtime_tests.gd | PASS; revision-3 fixture snapshots and atomic validation |
| receiving_freight_fixture_policy_tests.gd | PASS; every calibrated definition/socket footprint, depth band, bound, and coexistence contract |
| receiving_deck_layout_tests.gd | PASS; revision/layout 3 and existing front-to-rear scan |
| receiving_deck_presenter_tests.gd | PASS; actual MainDeck and fixture-private manual PUT rejection |
| receiving_freight_reach_tests.gd | PASS; complete progressive envelope, 3.4/3.3 boundary, classification, crate ray, visibility, fixture collision invariant |
| wing_gameplay_composition_tests.gd | PASS; 3.4 m Receiving override and exactly 16 ordinary functional surfaces |
| headless editor scan | PASS |
| default headless launch | PASS; no synthetic Receiving batch |
| seed 1842 / mixed smoke | PASS |
| seed 249 / crates smoke | PASS |
| seed 142 / pallets smoke | PASS |

The unchanged known diagnostics are the Windows root-certificate warning and the composition suite's two intentional duplicate seed-namespace rejection messages. No unexpected SCRIPT ERROR or FAIL: remains.

### Human re-review commands

~~~powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=mixed
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . -- --receiving-deck-debug --receiving-content-seed=249 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=crates
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . -- --receiving-deck-debug --receiving-content-seed=142 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=pallets
~~~

Re-review the critical manual PUT invariant on both MainDeck and a fixture stack, then confirm ordinary shelf stacking still works. Confirm front crates remain readable, rear pallets do not fully conceal loose cargo from normal lateral movement, and exposed crate, rear loose, and rear pallet cargo can be TAKEN comfortably. Specifically recheck the seed-142 Firewood/pig-type pallet case. If a visibly exposed crate item inside 3.4 m still fails, record its exact seed, fixture, item, camera, and collider rather than expanding collision behavior.

Disposition: **PROMOTE / REVISE**

## Final human promotion

Human re-review is complete. The reviewed implementation tip is `acab305bf23bbab0230ac98518fc277bb1c93b72`; the final promoted branch tip is the documentation close-out commit containing this section. Earlier Wave-1/Wave-2 checkpoints, provisional dispositions, bare-deck measurements, and correction evidence above remain historical records rather than rewritten final-state claims.

The promoted operational foundation is Receiving Stage A batch/lifecycle authority plus the deterministic seeded TAKE-only presenter, private deterministic placement/stack surfaces, and functional Receiving-only crates and pallets. Expedition still owns the exact loot outcome, and Receiving presents that exact committed batch without filler, omission, replacement, or presentation-driven bias. Exact durable `ItemInstance` identity and `ReceivingManager` drain accounting remain authoritative.

Human review confirmed:

- exact loot remains unchanged by Receiving presentation;
- front-to-rear distribution is legible and behaves as intended;
- crates sensibly group eligible Small cargo, while Mouse, Antibiotics, and Book remain present but do not use crates;
- pallets collect bulky Large cargo before thin Large cargo without global size sorting;
- the MainDeck floor remains useful and visually breaks up fixture repetition;
- fixtures improve freight variety and occlusion without reading as forced decoration, and no fixture is initially empty;
- emptied fixture visuals remain visible until delivery close;
- ordinary legal stack TAKE, base promotion, and compression remain familiar;
- Receiving surfaces and fixtures expose no PUT, zoning, labels, visible grids, F6 grids, item ghosts, fixture prompts, or ordinary storage registration;
- all tested deliveries drain normally, and rear pallet cargo is reachable with the fixture-integrated Receiving-only reach;
- the fixture system achieves its intended role.

The promoted proof remains a 3.00 m × 2.00 m usable deterministic deck. Fixture-integrated Receiving-only TAKE reach is **3.4 m**, loose reach remains **1.4 m**, and storage/manual reach remains **2.3 m**. The limiting fixture measurement remains the seed-142 Firewood target at approximately **3.299 m**; 3.4 m includes the agreed aiming/stance margin. The historical **2.1 m** value above remains bare-deck evidence and is not rewritten as fixture-integrated evidence.

This promotion does not finalize Expedition returned-loot bounds, shipped lift dimensions, the fixture art roster, fixture counts for future profiles, elevator lighting, shutter/audio/theatre, Stage C queued-delivery presentation, full save/journal work, broader gallery furnishing, generalized player containers/storage, or production loot rebalance. No new implementation gate is authorized by this close-out; wait for the next explicit handoff.

**FINAL HUMAN DISPOSITION: PROMOTE**
