# Storage unit orientation and zoning basis validation

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

**Date:** 21 September 2026  
**Feature branch:** `codex/storage-unit-orientation-zoning`  
**Main baseline:** `f3baa8160e56f588cf8bb71a53022368b978e15e`  
**Implementation checkpoint before this handoff record:** `200c71fe97f7bb7455ac31dd5f62ec7ea6601c7a`

## Delivered contract

Every storage unit now owns one four-state semantic orientation. Ordinary Metal Shelf and Ventilated Locker instances use an explicit `StorageUnitOrientation` child context; `ModularRack` exposes the same state and controls on its root. Every runtime `StorageSurface` generated for one unit inherits that unit state.

The approved states are unchanged:

| State | Front | Right | Back | Left |
| --- | --- | --- | --- | --- |
| 0 | +Z | +X | -Z | -X |
| 1 | +X | -Z | -X | +Z |
| 2 | -Z | -X | +Z | +X |
| 3 | -X | +Z | +X | -Z |

State 0 is the non-null default. All three continuing `wing_gameplay` functional units are explicitly authored at state 0 for human adjustment; no front direction was inferred from mesh appearance, walls, room layout or player approach.

The inspector convention is:

- `Rotate Storage Directions CW`: increment `0 → 1 → 2 → 3 → 0`;
- `Rotate Storage Directions CCW`: decrement with wraparound.

Automated authoring probes verified both tool-button labels, the state sequence and save/reload persistence. Human review should still confirm that the CW/CCW wording feels correct in Godot's top view. If wording is revised, only which action increments/decrements may change; the state table and serialized meanings must remain fixed.

## Semantic zoning behavior

`StorageOrientation` owns all reversible semantic/physical mapping. Exhaustive tests cover physical sizes 8×3, 3×8 and 7×7 in all four states, both round-trip directions, exact corners, normalization, axes and labels.

`StorageSurface` retains its physical grid and zone-cell array and adds semantic mapping, read, paint, erase and percentage methods. Semantic rectangle writes are batched and emit `zones_changed` once. Changing orientation metadata does not rotate or reorder the physical surface, zones, reservations or stacks.

`StorageZoneCanvas` now uses semantic coordinates for shape, hit-testing, drawing, reads, writes, erase and drag percentage. It keeps BACK at the top and FRONT at the bottom. A focused canvas test verifies that an 8×3 physical surface presents as 8×3 in state 0 and 3×8 in state 1, maps state-1/state-3 front-left painting to the expected physical corners, and produces identical canvas geometry and label positions from opposite dummy viewpoints.

The final authoring probe exercised one rectangular promoted review rack through all four states on the same physical surface. It verified the wide/tall/wide/tall semantic aspect sequence, four distinct front-left physical corners, unchanged physical transform/grid/usable size/clearance, and unchanged physical zone cells.

## Unit inheritance and persistence

- Two ordinary Metal Shelf instances independently propagated states 2 and 1 to all four surfaces while retaining identical physical transforms and grid sizes.
- A Ventilated Locker propagated state 3 to all four surfaces.
- Missing unit context resolves to state 0.
- Continuing Metal Shelf/Locker fixtures expose explicit editable state-0 contexts.
- Two ModularRack instances independently propagated states 1 and 3 to all levels without changing calibrated transforms, grid sizes or usable deck dimensions.
- ModularRack states 1 and 3 persisted independently through automated save/reload.
- A continuing placed Metal Shelf context was changed to state 2 in an isolated round-trip probe and persisted after save/reload; the repository scene remains authored at state 0.

## Human-review progress and bounded authoring correction

- The human ModularRack semantic orientation/zoning sub-check is **PROMOTE**.
- Cross-family review was initially blocked because the review controller instantiated the functional Metal Shelf and Ventilated Locker only at runtime, so their unit-orientation contexts could not be edited or persisted in `shelf_ergonomics_review.tscn`.
- The review scene now saves exactly one functional `SM_MetalShelves_Ergonomics` and one functional `SM_ventilated_locker_Ergonomics` beneath `ReviewFixtures`. Each owns an editable `StorageUnitOrientation` context at state 0.
- The controller reuses those saved units while preserving A/B/C scaling, clearance contexts, generated collision, eight legacy surfaces, three authored ModularRack surfaces, 11 total surfaces, supply reuse and F6/F7 behavior.
- A real headless Godot editor round trip saved Metal Shelf state 1 and Locker state 3, reopened the scene in a separate editor process, confirmed both states persisted independently, and then saved both back to state 0.
- Overall Storage Unit Orientation & Zoning Basis remains **HUMAN REVIEW PENDING** until the remaining Metal Shelf/Locker cross-family checks pass.

## Focused verification

Godot version: `4.7.stable.official.5b4e0cb0f`.

All focused suites passed on the final implementation state:

- `storage_orientation_tests.gd` — PASS;
- `storage_semantic_zoning_tests.gd` — PASS;
- `wing_storage_bridge_interaction_tests.gd` — PASS;
- `wing_storage_debug_f6_tests.gd` — PASS;
- `modular_rack_authoring_tests.gd` — PASS;
- `shelf_ergonomics_review_tests.gd` — PASS for cases A/B/C.

Additional checks:

- headless editor project scan — exit 0 with the new global classes registered;
- explicit case-B `shelf_ergonomics_review.tscn` smoke — exit 0, 11 surfaces installed;
- default project smoke — exit 0, `wing_gameplay.tscn` installed 12 surfaces with F6 default OFF and F7 disabled;
- Task 6 authoring probe — PASS for inspector controls, placed-context persistence and all-four-state rectangular-rack mapping;
- bounded review-scene correction regression — PASS for one saved Metal Shelf, one saved Locker, no runtime duplicates, independent state inheritance, eight legacy surfaces, three modular surfaces and 11 total surfaces;
- protected diff — no changes to `storage_visual_pose.gd`, `storage_placement_controller.gd`, item definition storage metadata or `project.godot`.

## Physical storage and packing separation

Regression checks verify that semantic state does not change Metal Shelf, Locker or ModularRack physical transforms, grids, usable sizes, clearances or F6 grid geometry. F6 remains presentation-only and physical; F7 remains suppressed in continuing/review functional compositions.

A semantic front-left Food zone was exercised through the real auto-placement path. Matching items occupied only mapped physical Food cells, compatible stacking and ownership remained intact, retrieval preserved exact identity, and stored global scale remained `Vector3.ONE`. Manual placement at nonzero semantic state retained its physical cell origin, and the existing rotation action still selected and recorded the same 90-degree packing entry.

Item packing orientation was not redesigned or judged by this milestone. `StorageVisualPose`, authored item rotation metadata, `_entry_for_item()`, `_entry_orientations_for_item()`, native-versus-90-degree preference and manual R behavior remain unchanged. Human review has classified packing orientation as an **IMMEDIATE FOLLOW-UP** after this orientation milestone is fully closed. The tentative future rule is “Canonical stored loot should face the storage unit's authored Front”; it is recorded for later design and was not implemented or formalized here.

## Known warnings and limitations

- Godot emits the existing Windows root-certificate-store diagnostic in this local environment.
- Current placed functional units intentionally remain state 0 until the developer reviews and adjusts them.
- The saved review-scene Metal Shelf and Locker also intentionally remain state 0 until cross-family human review selects final states.
- Changing authored orientation reinterprets existing physical zone cells; it does not migrate or reorder historical zone data.
- CW/CCW controls were technically verified against the approved state sequence; their visual wording in the Godot top view remains part of human review.
- Player-facing item packing yaw remains outside this milestone.

## Exact human-review launch commands

Continuing gameplay editor authoring:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --editor --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://gameplay/logistics_wing/wing_gameplay.tscn'
```

Promoted rectangular ModularRack review:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn' -- --ergonomics-case=B
```

Default Run Project:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE'
```

## Human PROMOTE / REVISE checklist

The ModularRack-only orientation/zoning sub-check is complete and promoted. The remaining gate is cross-family validation on the newly saved Metal Shelf and Locker fixtures.

### A. Remaining per-unit authoring

- In `ReviewFixtures`, select `SM_MetalShelves_Ergonomics/StorageUnitOrientation` and `SM_ventilated_locker_Ergonomics/StorageUnitOrientation` directly in the saved scene.
- Set the two units to different states, save, close and reopen; confirm both states persist independently and the ModularRack state is unchanged.
- Confirm every generated level in each legacy unit inherits its own unit state.
- Confirm CW/CCW wording feels correct while looking down local +Y. Do not redefine state values.

### B. Zoning orientation

On one clearly rectangular rack, test states 0, 1, 2 and 3. For each state:

1. open the same shelf surface in zoning;
2. confirm the canvas aspect follows the authored Front;
3. paint a distinctive category at semantic front-left;
4. close zoning;
5. enable F6 and/or auto-place a matching item;
6. confirm the expected physical shelf corner is used.

Expected sequence: state 0 Front +Z / Right +X; state 1 Front +X / Right -Z; state 2 Front -Z / Right -X; state 3 Front -X / Right +Z.

### C. Viewpoint independence

- Open zoning while standing at authored Front.
- Close it, walk to the physical Back or side, then reopen the same surface.
- Confirm the 2D zoning view is identical.

### D. Cross-family consistency

Repeat a semantic front-left zoning check on ModularRack, Metal Shelf and Ventilated Locker.

### E. Physical behavior preservation

Confirm F6 has not rotated or moved, auto placement follows zones, manual placement and R rotation still work, stacking/retrieval still work, and stored loot retains canonical scale.

### F. Packing-orientation observation

Observe default auto-placed item yaw for each tested family/state and report one of:

- packing behavior acceptable;
- packing needs an immediate follow-up before ladder;
- packing imperfection can be recorded as later debt.

### Disposition

- **PROMOTE**, or
- **REVISE** with the orientation state, storage family, zoning action and observed physical result.
