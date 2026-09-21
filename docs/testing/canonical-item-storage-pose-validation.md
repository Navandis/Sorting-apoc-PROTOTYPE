# Canonical item storage pose and shelf-Front alignment validation

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN PROMOTED**

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
- Consolidated self-review caught state-0 fallback use in direct review/capture tooling. A RED regression reproduced incorrect state-3 sample reservations; all production review/capture callers now pass their surface state explicitly, and the affected shelf, capture, Fuel, Locker, item-reviewability, and unstacked-equivalence checks pass.

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

This technical authoring verification was followed by a complete human visual review of the eligible catalogue content.

## Bounded authoring-tool correction after human review

Human review exposed two authoring-tool defects. Editing X/Y/Z on an assigned external `.tres` did not always rebuild the rendered preview because Godot did not consistently deliver `Resource.changed` for that inspector path. The fixture also showed only the authored footprint, with no geometry-derived canonical suggestion to distinguish deliberate authoring from a stale or undersized value.

The corrected fixture keeps `ItemDefinition.changed` as its fast path and also polls a stable editor-time fingerprint containing the definition identity/path, `storage_rotation_degrees`, `storage_footprint`, `visual_scene`, and the packing-preview toggle. It rebuilds only when that fingerprint changes or a refresh is explicitly requested. A regression changes all three rotation axes in place, without rebinding the definition or emitting `changed`, and verifies that the real `AuthoredStoragePose` basis refreshes.

Footprint behavior is now explicit:

- `authored_footprint` is the manually authored ItemDefinition width/depth and is never rewritten by pose or preview changes;
- `suggested_canonical_footprint` is calculated from the real canonical, unrotated-packing `StorageVisualPose` aligned bounds at 0.10 m per cell using `ceil`, with a minimum of one cell per axis;
- `suggestion_exceeds_authored` reports when either suggested axis is larger than its authored axis;
- `packing_preview_footprint` is the authored footprint transposed only for the preview-only packing state, and never redefines the canonical suggestion.

These four derived values are read-only in the fixture root inspector. The explicit **Apply Suggested Footprint** action writes only `storage_footprint.x/y` on the assigned ItemDefinition, preserves `storage_footprint.z` and `storage_rotation_degrees`, emits the resource change, and does not save or mutate the fixture scene as a substitute for the resource edit.

The bounded correction is technically verified: in-place external-definition refresh passes without rebinding; asymmetric 31 cm × 11 cm bounds suggest 4×2 and swap to 2×4 at 90 degrees canonical yaw; a sub-cell symmetric visual remains 1×1; packing preview leaves the canonical suggestion unchanged; manual authored values remain untouched until apply; and apply preserves footprint Z and all rotation axes. The authoring suite passes both headless and editor-process modes, and the unchanged storage-orientation, visual-pose, wing-bridge, and stacking interaction suites pass.

## Final human promotion and content reconciliation

The human verdict is **PROMOTE**. All 40 currently eligible ItemDefinitions were reviewed in the canonical pose workbench. Their saved `.tres` `storage_rotation_degrees` and `storage_footprint` values are now the promoted content authority. Gloves (`loot_000034`) and Pants (`loot_000036`) remain blocked in `CUSTOM_POSE_REQUIRED` with unreviewed footprint, Stack Role, and Auto Group decisions; they are not part of the 40-item promotion.

The manifest and literal content regression were reconciled to those saved resources. The final evidence contains:

- 21 `DEFAULT_POSE_APPROVED` and 19 `CUSTOM_POSE_APPROVED` eligible records;
- 27 `GEOMETRY_APPROVED` and 13 deliberate `OVERRIDE_APPROVED` footprints;
- 40 current pose, footprint, Stack Role, and Auto Group review snapshots;
- two unchanged blocked records;
- 42 catalogue definitions still present and resolvable.

Existing `can_be_stacked`, `can_support_stack`, and `auto_stack_group` gameplay decisions, along with their notes and flags, were preserved. Only their dependent pose/footprint snapshots were refreshed. Reconciliation found no Stack Role, Auto Group, catalogue-identity, or blocked-item contradiction. Source GLB/FBX assets, scale-normalization decisions, ItemCatalog references, gameplay scenes, shelf/rack definitions, unit orientation, zoning, and modular-rack calibration were not rewritten by the close-out.

The corrected fixture reduced the full 40-item pose/footprint review to roughly 10 minutes, compared with roughly two hours for the old seed-in-game → review → written-instructions → Codex-edit workflow. Future catalogue expansion should use this fixture as the primary pose/footprint authoring workflow.

## Protected content and future contracts

- Twenty-six ItemDefinition `.tres` resources contain the saved human pose/footprint edits from the 40-item review and are promoted as content authority.
- No source GLB/FBX asset was rotated, rescaled, or rewritten.
- No storage-unit orientation or zoning semantics were changed.
- No ModularRack calibration or `project.godot` default scene was changed.
- Historical `storage_rotation_degrees` values were not guessed or bulk re-authored.
- Future save/load must restore each placed item's saved orientation state and must not recompute it from the shelf's current Front.
- Optional 0/90/180/270 display rotation remains separate UX debt; this milestone retains the existing boolean packing choice.
- Fixed-ladder proof is the next active gate; no ladder implementation begins during this close-out.

## Known warnings and limitations

- Godot emits the existing Windows root-certificate-store diagnostic in this environment.
- `storage_stack_clearance_tests.gd` intentionally emits the existing missing-clearance-context fallback warning for its dedicated warning-path test.
- The scripted editor round trip exits the editor from a `SceneTree` test and therefore emits scan-aborted/RID cleanup diagnostics at process shutdown. The separate normal editor scan exits cleanly apart from the certificate diagnostic.
- Gloves and Pants remain deliberately blocked for future source/pose work; all other current definitions completed human review.

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

**PROMOTE.** Canonical Item Storage Pose & Shelf-Front Alignment is complete. Future save/load work must restore each placed item's saved orientation state rather than recomputing it from the shelf's current Front. Optional four-way 0/90/180/270 item display rotation remains deferred UX debt.
