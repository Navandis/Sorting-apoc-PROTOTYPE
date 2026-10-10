# Place and edit approved EAF4 wear in the wing

Open `res://gameplay/logistics_wing/wing_gameplay.tscn` in Godot 4.7 Compatibility. The library is `res://environment_authoring/wear/presets/`. Its [coverage index](../../environment_authoring/wear/presets/README.md) lists every source, surface capability and usage restriction. There are currently 11 eligible presets. Source approval does not approve a particular placement or the room's final wear composition.

## Place a preset

1. Find `WingGameplay/AuthoredWear` in the Scene tree. Its `Receiving`, `Storage` and `OtherRooms` children are empty visual organization groups. Add plain Node3D room subgroups as needed. Their transforms start at identity; placements use wing coordinates.
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

**Advanced Surface / Normal Y Flip** changes normal-map convention. **Advanced Imperfection** controls and **Imperfection Enabled** apply only where an approved modulation mask exists. The mask is not a standalone grime preset. Unsupported controls are hidden. The defaults toggle can also hide appearance controls deliberately.

For approved appearance, enable Use Approved Appearance Defaults. To restore an entire new placement, instance the same library preset afresh. For just size/offset, use the source's `physical_size_m` / `surface_offset_m` in `res://data/environment/wear_catalog/approved_specs/<catalog ID>.tres` as read-only reference; do not edit the approved resource. Source switching deliberately keeps the prior dimensions and appearance, so inspect the new source's restrictions and defaults after switching.

## Duplicate, save and reopen

Select a preset instance root and use ordinary **Ctrl+D**. Move the copy and edit its root controls; sibling settings/materials and the preset/default files remain independent. Change Approved Source on the copy without rebuilding its placement. **Ctrl+Z / Ctrl+Shift+Z** should undo/redo Inspector changes and transforms normally.

Save the wing, close/reopen the scene and verify your instance-root overrides. Each helper should have one generated visual in the viewport and at runtime. Generated Quad nodes are preview/render output and stay unsaved. Do not edit or manually copy them. Future rooms instance the library files directly; there is no hidden template bank to copy.

## Keep the existing examples and signage separate

The seven existing Road Dust examples remain at:

`WingGameplay/ReceivingSetDressing/ReceivingDecals/ReceivingFinishPass`

Their source is `res://gameplay/logistics_wing/receiving/receiving_finish_pass.tscn`. Select an existing wear helper root and expand **Spec** to edit **Physical Size M**, **Opacity Multiplier**, tint and supported map settings. Task 1's resource-change refresh is active for these older instances too. The canonical wing already exposes their inherited overrides; new presets use the simpler flat interface above. Their present sizes/appearance/placement were preserved, including the wing's pre-existing Traffic_Approach size `(1.805, 1.655)`.

To switch off only the examples, set **Visible** off on both `ReceivingWear_Floor` and `ReceivingWear_LiftZone`. Leave `ReceivingFinishPass` and `ReceivingSignage` visible. The accepted `ReceivingSignage/LiftEmergencyStopLabel` remains with its existing SVG, material, dimensions, transform and button/column relationship. These Road Dust examples are available for authoring review, not an accepted final layout.

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

## Hands-on acceptance still required

No genuine editor screenshots were captured: the Windows computer-use helper found Godot but failed window capture twice (`FrameArrived timed out`, then `window capture timed out`). Automated checks and real OpenGL rendering are separate evidence; they do not close editor interaction acceptance.

In the actual wing editor, place a floor preset and a wall preset under AuthoredWear, focus them with F, edit dimensions/opacity/tint and supported map settings, duplicate with Ctrl+D, switch the copy's source, toggle approved defaults, undo/redo, save/close/reopen and run the wing. Confirm one patch per instance and independent settings. Edit one existing Road Dust Spec, then hide both old wear groups and verify the label remains visible. Capture the selected root/Inspector before and after edits. Remove validation placements unless you intend to retain them as your authored layout. No distinct material-patch preset is currently eligible to test.

Human placement and tuning review is the next step; this workflow does not accept new wear art or close Receiving C1.
