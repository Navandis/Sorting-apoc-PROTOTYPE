# Modular rack authoring validation

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

**Date:** 20 September 2026

**Feature branch:** `codex/modular-rack-authoring`
**Main baseline:** `08d958d225b1fc5c3eb5335c42ceceec8ca75437`

## Delivered implementation

- `res://gameplay/logistics_wing/storage/modular_rack.tscn` is the reusable shelf-empty rack scaffold.
- `res://gameplay/logistics_wing/storage/modular_rack.gd` is the single `@tool` authoring/runtime component.
- `ReviewFixtures/ModularRack_Starter` in `shelf_ergonomics_review.tscn` remains an instance of the scaffold. Its three starter `Shelf_*` wrappers and Rack02 visuals are local to the review scene beneath the inherited editable `Levels` node.
- The root component derives frame geometry, per-instance collision, previews, usable deck rectangles, clearances and one runtime `StorageSurface` per valid local level.
- `StoragePrototypeManager` remains the owner of installed surfaces and F6 presentation. The shelf-ergonomics manager retains its existing Metal Shelf and Locker profiles and adds only the shared modular-rack installation pass.
- The obsolete `Control` / `Control2` rack and static-loot experiments remain removed from the active review scene. The retained inert ladder visual remains hidden and has no behavior.

## Rack02 deck calibration

`SM_Rack02.glb` exposes one inseparable textured mesh, so the functional gray deck uses measured source-local constants rather than the aggregate orange-rail/bracket AABB:

- deck top Y: `0.113742 m`;
- deck underside Y: `0.090407 m`;
- deck X: `-0.476953864 .. 0.476953864 m`;
- deck Z: `-1.875163436 .. 1.875163555 m`;
- physical deck thickness: `0.023335 m`.

Each shelf wrapper Y is the physical gray-deck top. The Rack02 visual is offset so that measured top is wrapper Y zero. The runtime `StorageSurface` origin is `-StorageSurface.DEBUG_Y_OFFSET_M` (`-0.012 m`) below the wrapper, placing the F6 grid and local placement plane exactly at the physical deck top without adding the legacy normalized-profile vertical nudge.

Horizontal usable size begins with the calibrated gray-deck rectangle, applies the four authored insets, then allows `StorageSurface.configure()` to quantize down to whole cells. Component assertions verify all four actual grid edges remain inside the calibrated deck.

## Persistence regression and real editor workflow

The previously failing workflow was repeated in the real Godot 4.7 editor against the saved review scene:

1. duplicated `ModularRack_Starter` as `ModularRack_RoundTrip`;
2. changed length/depth/frame height to `4.35 / 1.05 / 2.85 m`;
3. moved local `Shelf_02` to Y `1.42 m`;
4. duplicated it as local `Shelf_RoundTrip`;
5. deleted local `Shelf_03`;
6. saved and fully closed the editor;
7. reopened the scene from disk.

After reopen, the added shelf, deleted-shelf absence, moved Y and three rack dimensions all persisted. The original starter retained its original dimensions and shelves. The temporary duplicate and edits were then reverted, leaving only the intended starter rack.

The automated save/reload regression independently covers local add/move/delete persistence and per-instance collision-resource independence.

## Focused verification

All checks completed with Godot `4.7.stable.official.5b4e0cb0f`:

- `modular_rack_authoring_tests.gd` — PASS;
- `shelf_ergonomics_review_tests.gd` — PASS for cases A/B/C, deriving current modular counts (`8` legacy + `3` modular surfaces in the delivered starter scene);
- `wing_storage_debug_f6_tests.gd` — PASS;
- `storage_singleton_clearance_tests.gd` — PASS;
- `storage_stack_clearance_tests.gd` — PASS;
- headless editor project scan — exit `0`;
- explicit case-B ergonomics scene smoke — exit `0`, `11` surfaces installed;
- default project smoke — exit `0`, normal wing composition installed `12` surfaces.

A rendered human calibration check at changed rack length/depth and asymmetric insets confirmed that the cyan F6 grid is visually coincident with the gray deck, remains within the gray rectangle and does not cross the orange front/back/side structure.

## Protected state and bounded scope

Diff checks confirm no changes to:

- `project.godot`;
- `main.tscn`;
- `gameplay/logistics_wing/wing_gameplay.tscn`;
- `SM_Rack01.glb`;
- `SM_Rack02.glb`.

Existing Metal Shelf and Locker profile literals are unchanged. Loot definitions/catalogue and promoted supply reuse are unchanged. No ladder behavior, Receiving work, zone-editor changes, general StorageSurface axis change or broad front/back/orientation repair was added.

The broader StorageSurface front/back/orientation debt is intentionally deferred to the next separate gate after this milestone is promoted and before the fixed-ladder proof.

## Known warnings and limitations

- Godot emits the existing Windows root-certificate-store diagnostic in this local environment.
- `storage_stack_clearance_tests.gd` intentionally emits the existing `MissingContextShelf` family-fallback warning.
- The starter is a convenient mutable review configuration, not a universal rack standard. Tests derive rack/level counts rather than freezing the scene to one rack or three levels.
- Runtime reconfiguration of occupied racks remains explicitly unsupported.

## Human review launch

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn' -- --ergonomics-case=B
```

## Human PROMOTE / REVISE checklist

### Editor authoring

- Duplicate the complete starter rack.
- Change root length, depth and frame height.
- Move, duplicate and delete local `Shelf_*` wrappers.
- Save/reopen and confirm persistence and rack independence.
- Confirm no per-level script, manual `StorageSurface` or manual clearance field is needed.

### Runtime and visual behavior

- Run A/B/C and toggle F6.
- Confirm one grid per local shelf level.
- Confirm the grid follows length, depth, shelf height and asymmetric insets.
- Confirm the grid sits on and remains within the physical gray deck.
- Exercise promoted-table item auto placement, manual placement/rotation, stacking and retrieval.
- Confirm canonical loot scale, tall-item fit behavior, and unchanged Metal Shelf/Locker behavior.
- Confirm default Run Project remains `wing_gameplay.tscn`.

Disposition:

- **PROMOTE**
- **REVISE** with concrete observed behavior
