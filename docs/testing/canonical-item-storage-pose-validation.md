# Canonical item storage pose and shelf-Front alignment validation

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING**

**Date:** 21 September 2026  
**Feature branch:** `codex/canonical-item-storage-pose`  
**Synchronized main baseline:** `47191b6c90d1d4c40d4344796b1b3e3b4ca789f7`

## Delivered contract

`ItemDefinition.storage_rotation_degrees` remains the one full pitch/yaw/roll correction that converts an untouched imported visual into its canonical stored pose. The canonical authoring reference is:

```text
Front +Z
Back  -Z
Right +X
Left  -X
Up    +Y
```

Runtime now combines the storage unit's authored quarter-turn with the existing `packing_rotated` boolean. The unit state aligns canonical item Front to shelf Front; packing rotation adds one separate +90-degree turn. Auto placement still tries canonical/front-facing first and the alternate packing state second.

For an asymmetric canonical 2×1 footprint:

| Unit state | Packing false | Packing true |
| --- | --- | --- |
| 0 | 2×1 / 0° | 1×2 / 90° |
| 1 | 1×2 / 90° | 2×1 / 180° |
| 2 | 2×1 / 180° | 1×2 / 270° |
| 3 | 1×2 / 270° | 2×1 / 0° |

The stored runtime hierarchy is:

```text
Stored_<Item>
└── StoredUnitOrientationYaw
    └── StoredPackingYaw
        └── StorageSeating
            └── AuthoredStoragePose
                └── ImportedVisual
```

The manual-placement ghost uses the same conceptual separation. `StorageVisualPose` continues to own authored three-axis pose, seating, bounds, and packing yaw; unit yaw remains outside that path.

## Technical results

- Pure tests cover states 0–3, both packing states, 2×1 and 3×2 asymmetric footprints, 2×2 square footprints, normalization, and exact 0/90/180/270 yaw.
- Visual composition tests confirm unit yaw and packing yaw are outer roots and do not flatten or rewrite authored pitch, yaw, or roll.
- Controller tests confirm physical footprints follow combined unit-plus-packing parity, including odd unit states while `packing_rotated == false`.
- Auto placement remains canonical-first when both candidates fit and selects the 90-degree alternate only when canonical cannot fit.
- Manual `R` remains a two-state packing choice; unit and packing roots remain separate and the reservation matches the visible combined parity.
- Canonical and packing placements retain existing stack insertion, retrieval, support, base-promotion, and clearance behavior.
- A committed item keeps its transform when surface Front metadata changes; a newly placed copy uses the new Front.
- One asymmetric Hammer definition was exercised on ModularRack state 0, Metal Shelf state 2, and Ventilated Locker state 3. Canonical and packing placements preserved scale `Vector3.ONE`, used the expected two yaw roots, and reserved the corresponding footprint.

Focused verification on the final implementation state:

- `storage_item_orientation_tests.gd` — PASS;
- `storage_visual_pose_tests.gd` — PASS;
- `wing_storage_bridge_interaction_tests.gd` — PASS;
- `storage_stacking_interaction_tests.gd` — PASS;
- `storage_singleton_clearance_tests.gd` — PASS;
- `storage_stack_clearance_tests.gd` — PASS;
- `item_storage_pose_authoring_tests.gd` — PASS;
- `shelf_ergonomics_review_tests.gd` — PASS for cases A/B/C;
- headless editor project scan — exit 0;
- explicit shelf-ergonomics case B smoke — exit 0, 11 surfaces;
- default project smoke — exit 0, 12 surfaces, F6 default OFF and F7 disabled.

## Canonical authoring fixture

Retained developer fixture:

```text
res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn
```

It is an `@tool` scene with a neutral support shelf, fixed FRONT/BACK/LEFT/RIGHT markers, deterministic footprint preview, an exported `ItemDefinition`, and a preview-only packing toggle. It instantiates the assigned definition's `visual_scene` and uses the real `StorageVisualPose.build_visual()` path. It has no second scene-local pose value and does not write to imported GLB/FBX scenes.

An editor-process round trip used the existing asymmetric Hammer definition as the source, duplicated it in memory, verified live nonzero X/Y/Z pose refresh, toggled packing preview, saved/reopened a temporary packed fixture, and confirmed pose and packing-preview persistence. The temporary scene was removed and the source ItemDefinition remained unchanged.

This is technical authoring verification, not human visual approval of existing item content.

## Protected content and future contracts

- No `data/items/definitions/*.tres` resource was changed.
- No storage-unit orientation or zoning semantics were changed.
- No ModularRack calibration or `project.godot` default scene was changed.
- Historical `storage_rotation_degrees` values were not guessed or bulk re-authored.
- Future save/load must restore each placed item's saved orientation state and must not recompute it from the shelf's current Front.
- Optional 0/90/180/270 display rotation remains separate UX debt; this milestone retains the existing boolean packing choice.
- Ladder work remains blocked until human review disposition for this gate.

## Known warnings and limitations

- Godot emits the existing Windows root-certificate-store diagnostic in this environment.
- `storage_stack_clearance_tests.gd` intentionally emits the existing missing-clearance-context fallback warning for its dedicated warning-path test.
- The scripted editor round trip exits the editor from a `SceneTree` test and therefore emits scan-aborted/RID cleanup diagnostics at process shutdown. The separate normal editor scan exits cleanly apart from the certificate diagnostic.
- Existing item definitions still require human review in the canonical fixture. Technical verification does not claim their historical rotations are correct under the new meaningful Front contract.

## Exact review launch commands

Open the canonical authoring fixture in the editor:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --editor --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn'
```

Run the cross-family shelf review case B:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn' -- --ergonomics-case=B
```

Run the default gameplay composition:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE'
```

## Human disposition

Human review must choose **PROMOTE** or **REVISE**. Runtime defects should be distinguished from item-definition content that simply needs deliberate re-authoring in the canonical fixture.
