# Place and edit approved EAF4 wear in the wing

Open `res://gameplay/logistics_wing/wing_gameplay.tscn` in Godot 4.7 Compatibility. The library is `res://environment_authoring/wear/presets/`. Its [coverage index](../../environment_authoring/wear/presets/README.md) lists every source, surface capability and usage restriction. There are currently 11 eligible presets. Source approval does not approve a particular placement or the room's final wear composition.

## Place a preset

1. Find `WingGameplay/AuthoredWear` in the Scene tree. Its `Receiving`, `Storage` and `OtherRooms` children are visual organization groups; Receiving now contains an accepted authored preset. Add plain Node3D room subgroups as needed. Their transforms start at identity; placements use wing coordinates.
2. Drag a named `.tscn` from FileSystem onto the appropriate group in the Scene tree. For example, `road_dust_sgzh1so.tscn` is floor dust; `chipped_paint_patch_ui2ncdjfw.tscn` is damage to an applied painted finish. The source suffix distinguishes similarly named cracks/leaks.
3. Select the **instance root**, not its generated Quad. Read **Approved Usage Notes** and move/rotate the instance onto a compatible surface. New preset instances expose their controls directly; Editable Children and Make Unique are unnecessary.
4. Edit **Width M**, **Height M** and **Surface Offset M**. The visual should update in the editor without running gameplay. Give instances names describing their cause/location.

`AuthoredWear` belongs directly to the wing scene. ReceivingManager, deck presenters and storage actors do not own or rebuild this branch. It accepts approved visual helpers and plain Node3D organization only; put lights, collision, cameras and gameplay scripts in their existing dedicated branches.

## Orientation, dimensions and offset

The flat quad lies in local XY and faces local +Z. Floor-only presets start at **Rotation X = -90 degrees**, so +Z points up. Wall-only presets start upright with a +Z normal; rotate Y to face the room. PLANAR_ANY and dual floor/wall sources also start upright: set X = -90 degrees for a floor or rotate to a wall. PLANAR_ANY describes orientation capability, not permission for arbitrary damage origins. Keep vertical leakage flowing down.

Width/height are local metres, each greater than zero and at most 8. Positive node/ancestor X/Y scale multiplies these dimensions. Prefer dimensions with unit scale for predictable measurements. Positive Z scale also multiplies offset. Negative/zero scale and sheared hierarchies are outside the supported workflow; use **Mirror U** / **Mirror V** for texture flips.

Surface Offset M is 0.0005–0.01 metres along local +Z; 0.002 is a useful starting value. Position the instance root on the actual substrate surface, then use offset for separation. A patch is flat: it cannot wrap around a corner, curved pipe or broken edge. Use separate appropriately oriented placements on adjoining flat surfaces, with restrained overlap.

## Appearance and source switching

| Inspector label | Meaning |
| --- | --- |
| Approved Source | Readable source name plus stable catalog ID. Switching preserves your transform, dimensions, offset, mirrors and appearance settings. |
| Approved Usage Notes | Read-only restrictions from the existing approval catalog. |
| Use Approved Appearance Defaults | Render the selected source's approved appearance and hide authored appearance controls. Turn off to recover your retained values. It does not reset size, placement or mirrors. |
| Opacity Multiplier | Multiplies opacity. Soft sources fade; cutout sources can lose coverage below the existing 0.28 scissor threshold. |
| Albedo Strength | Blend from tint at 0 to source colour at 1. It does not blend toward the underlying wall/floor. |
| Albedo Tint | Tint contribution decreases as Albedo Strength rises. Tint has no effect at strength 1; tint alpha is unused. |
| Normal Strength | Source normal-map depth; shown only with a normal map. |
| Roughness Strength | Blend from fixed roughness 0.8 toward the source map, rather than toward substrate roughness. |
| Edge Feather | Narrow UV-edge fade for soft sources; hidden for cutout sources. |
| Mirror U / Mirror V | Flip the texture while retaining the placement. |

**Advanced Surface / Normal Y Flip** changes normal-map convention. **Advanced Imperfection** controls and **Imperfection Enabled** apply only where an approved modulation mask exists. These controls retain their existing Grunge binding. Independent approved scalar layers use the separate scalar library. Unsupported controls are hidden. The defaults toggle can also hide appearance controls deliberately.

For approved appearance, enable Use Approved Appearance Defaults. To restore an entire new placement, instance the same library preset afresh. For just size/offset, use the source's `physical_size_m` / `surface_offset_m` in `res://data/environment/wear_catalog/approved_specs/<catalog ID>.tres` as read-only reference; do not edit the approved resource. Source switching deliberately keeps the prior dimensions and appearance, so inspect the new source's restrictions and defaults after switching.

## Duplicate, save and reopen

Select a preset instance root and use ordinary **Ctrl+D**. Move the copy and edit its root controls; sibling settings/materials and the preset/default files remain independent. Change Approved Source on the copy without rebuilding its placement. **Ctrl+Z / Ctrl+Shift+Z** should undo/redo Inspector changes and transforms normally.

Save the wing, close/reopen the scene and verify your instance-root overrides. Each helper should have one generated visual in the viewport and at runtime. Generated Quad nodes are preview/render output and stay unsaved. Do not edit or manually copy them. Future rooms instance the library files directly; there is no hidden template bank to copy.

## Keep authored wear and accepted signage separate

The seven rejected original Codex Road Dust placements and their old finish scene were retired on 2026-10-10. The ordinary Road Dust library preset remains approved and available for new human-authored placements.

The accepted plaque is independently visible at `WingGameplay/ReceivingSetDressing/ReceivingDecals/ReceivingSignage/LiftEmergencyStopLabel`, instanced from `res://gameplay/logistics_wing/receiving/receiving_emergency_stop_signage.tscn`. Its SVG, material, 0.32 × 0.14 m mesh and world transform are unchanged. Hiding `AuthoredWear` or `ImperfectionExperiments` does not hide it. The red button remains decorative.

All 16 scalar patterns are separately approved for flat tinted-opacity layers and the existing two Leakage modulation cases; see the [scalar-layer guide](eaf4-imperfection-audition-guide.md). They are not additional conventional wear presets. Conventional preset count remains 11.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Invisible patch | Root/group Visible; supported approved source; warning icon; positive dimensions within bounds; nonzero opacity; texture dependencies staged. Clear/invalid sources hide only their own visual. |
| Wrong orientation | Quad +Z must face away from the substrate; floor X=-90 degrees. Rotate the root, not Quad. |
| Flicker / floating | Put the root on the substrate face and tune Surface Offset M within bounds. Check ancestor scale and overlapping soft layers. |
| Copy stays hidden | Check both the copy's Visible and every ancestor. Move it to a visible room group. |
| Control missing or ineffective | Check source map support, soft versus cutout mode, defaults toggle, and Albedo Strength's effect on tint. |
| Source dropdown/index stale | Reload the authoring script or reopen Godot after catalog reconciliation; the selector is cached for the script lifetime. Run the one-shot preset audit after approvals/assets change. |
| Editor and runtime differ in brightness | Use the actual wing environment/camera and inspect property/geometry updates first. Different viewport preview lighting/cameras do not guarantee pixel-identical pictures. |

## Accepted workflow and continuing room authoring

The human accepted actual Godot editor authoring, duplication and save/reopen, and the later plaque/legacy cleanup checks are recorded in the [accepted milestone](../testing/environment-authoring-eaf4-imperfection-authoring-milestone-closeout-2026-10-10.md). Codex automated/editor-hint and OpenGL results remain distinct from human interaction evidence.

The first manual Receiving wear composition is now completed, human-reviewed and merged into main. Current saved composition has 18 layers (17 separate scalar instances plus one conventional preset), confirmed by scene inventory and human clarification; see the [dated reconciliation](../testing/three-master-document-reconciliation-2026-10-10.md). The earlier unpublished seventeen-layer checkpoint remains historical. Later edits to wear or furnishings are normal authoring and do not reopen completed EAF4 tooling. There is no permanent art freeze, and C1 remains IN PROGRESS.

Use normal live root controls, duplication, undo/redo and save/reopen for further room work. Broad subtle editable scalar variation can break base-material repetition; localized layers express plausible traffic, service and spillage. Keep both restrained and readable, within approved source/use restrictions. Source/use approval remains distinct from specific scene/art acceptance.
