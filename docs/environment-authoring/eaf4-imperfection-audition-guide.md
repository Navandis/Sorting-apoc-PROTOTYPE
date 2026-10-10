# Audition experimental imperfection masks in the wing

Open `res://gameplay/logistics_wing/wing_gameplay.tscn` in Godot 4.7 Compatibility. The experimental library is `res://environment_authoring/wear/imperfection_experiments/presets/`; its [coverage index](../../environment_authoring/wear/imperfection_experiments/README.md) identifies all 16 sources and their actual channels. These placements are **EXPERIMENTAL / NOT APPROVED**. Previewing a deferred or unreviewed source grants no approval. The accepted approved wear presets and their Advanced Imperfection controls remain the existing workflow.

## Place a source without running the game

1. Select `WingGameplay/ImperfectionExperiments` in the Scene tree. This empty, direct scene-owned group is separate from `AuthoredWear`, the old Receiving wear groups, signage and CRT. Plain Node3D subgroups are allowed; keep gameplay, collision, lights and cameras elsewhere.
2. Drag a named `.tscn` from the experimental folder onto this group. Start with `grunge_tedxadjc.tscn` for the known roughness scalar or `dust_uh4qbeic.tscn` for an actual opacity map. The suffix distinguishes repeated source names. Each wrapper starts upright at 1×1 m; it does not place itself in the room.
3. Select the instance root. Read **Experiment Notes**: current catalog source status, actual sampled channel, source size estimate, experiment disclaimer and wear restrictions. **Mask Source** can switch among all 16 exact stable IDs while retaining placement and root settings. Source estimates are starting references, not approved bunker dimensions.
4. Move the root onto a flat surface. Its quad lies in local XY and faces local **+Z**. For a floor set **Rotation X = -90°**. For a wall keep X=0 and rotate Y so +Z faces into the room; the Receiving inner +Z wall needs Y=180°. Place on the actual visible substrate face, not the exterior wall centre. Set **Width M**, **Height M** and **Surface Offset M**; 0.002 m is the starting offset.
5. Focus with **F** and tune the root Inspector. Updates should appear without F5/F6. Do not edit the generated Quad, Make Unique, or enable Editable Children. Positive node/ancestor scaling works; X/Y scale multiplies dimensions and Z scale multiplies offset. Prefer unit scale and dimensions in metres. Negative/zero scale and sheared transforms are unsupported.

## Choose what the preview means

| Preview Mode option | Meaning / useful controls |
| --- | --- |
| **Grayscale Diagnostic** | The selected map’s red scalar drives the patch’s grayscale albedo. Actual wing lighting and opacity affect the displayed brightness. This is a channel/distribution diagnostic, not a physical roughness preview. Tint and wear controls are hidden. |
| **Tinted Opacity Illustration** | The scalar drives the visibility of **Albedo Tint**. **Opacity Multiplier** fades the illustrative patch. It is not proof of grime, wetness, damage or a change to the substrate. |
| **Approved Wear Modulation** | **Wear Source** independently selects `leakage_skiubhzc` or `leakage_tculfbnc`, the two current approved soft Leakage overlays. The experimental candidate multiplies this effect’s opacity/distribution; it never changes the approved resource. Keep Leakage vertical on a compatible wall. A floor use would only be diagnostic, not an approved Leakage placement. |

The actual channel is fixed by the source’s manifest: eleven use genuine **opacity.red** and five use **roughness.red** deliberately repurposed as scalar. Bright means a higher scalar, not inherently dirt/wetness/damage. No base floor/wall/ceiling material is modified.

| Exact Inspector label | Effective behaviour |
| --- | --- |
| Width M / Height M | Local metres, each in (0,8]. Source changes retain both. |
| Surface Offset M | 0.0005–0.01 m along local +Z; adjust for separation from the substrate. |
| Opacity Multiplier | [0,1] multiplier in every mode. Grayscale default 0.5 is translucent; use 1 for an opaque scalar diagnostic. |
| Albedo Tint | Neutral patch colour in Tinted Opacity Illustration; contributes to Leakage at (1−Albedo Strength). Tint alpha is unused. Hidden in grayscale. |
| Albedo Strength | Modulation mode only: blend from tint at 0 to approved source colour at 1. Tint has no effect at 1. |
| Mask Repeat | Positive X/Y scalar repetition, independent of wear UVs. It does not establish seamless tileability. |
| Mask Rotation Degrees | Rotate the scalar about its centre independently of the root orientation. |
| Scalar Contrast / Scalar Bias | Contrast 0.1–4 about 0.5; bias −1 to +1; final scalar clamps to [0,1]. |
| Invert Scalar | Reverse the sampled scalar before contrast/bias. Useful for comparing the opposite distribution; no physical semantic is inferred. |
| Wear Source | Modulation mode only; exact approved Leakage identity. Switching retains authored dimensions, placement and appearance. Source normal/roughness/feather settings remain its approved defaults. Cutout, material patches and other overlays are unsupported in this experimental component. |
| Modulation Enabled | Modulation mode only: off gives the fully unmasked Leakage at the same transform/appearance. On applies the experimental candidate. |
| Mask Strength | Modulation mode only: 0 matches unmasked; 1 multiplies wear opacity by the scalar. Intermediate values interpolate between them. |

Mode B preserves soft-overlay source opacity, border feather, normal, roughness and metallic behaviour. Its final alpha is source alpha × edge fade × Opacity Multiplier × `mix(1, scalar, Mask Strength)` when enabled. Scalar repeat/rotation do not rotate the underlying Leakage. Each root generates an independent material and cloned effective spec while sharing read-only texture references. The existing approved shaders, preset files, specs and Grunge defaults are unchanged.

## Duplicate, compare, save and hide

Select the root, **Ctrl+D**, move the copy and change its Mask Source/size/inversion. The original should retain its settings and appearance. Use **Ctrl+Z / Ctrl+Shift+Z** to undo/redo Inspector edits and transforms. In modulation mode switch Modulation Enabled off/on without moving, then compare strength 0/1. Do not infer artistic approval from a visible difference.

Save the wing, close/reopen it, check root overrides and one patch per instance, then run the scene if useful. Generated Quad nodes are ownerless and omitted from saves; do not save or manipulate them directly. This implementation ships only the empty experiment parent, with no selected artistic wear composition.

Set **Visible** off on `ImperfectionExperiments` to hide all experiments. `AuthoredWear`, old Road Dust wear, `ReceivingSignage/LiftEmergencyStopLabel`, lift and CRT stay independent. Hide old wear separately only when you deliberately want that comparison; do not hide the whole ReceivingFinishPass parent or signage.

## Troubleshoot

| Symptom | Check |
| --- | --- |
| Missing preview / warning | Choose a known Mask Source; read the warning; restore the exact commercial source/cache dependencies with the one-shot tool in the coverage README, let Godot import them, then edit/reopen the instance. Unknown, absent or changed maps hide the visual without substitution. No background importer polls the source repository. |
| Entire patch transparent | Check Visible on root/ancestors, nonzero Opacity Multiplier, correct surface-facing +Z, positive dimensions/scale, and scalar distribution. Bias/contrast/invert can make tinted/modulated coverage zero. In Mode B try Modulation Enabled off to inspect the underlying effect. |
| Flicker / floating | Position on the actual substrate face; tune Surface Offset M in range; check ancestor Z scale and overlapping transparent patches. |
| Grayscale too bright/dark | It is lit patch albedo under the actual environment, not an unlit numeric swatch. Compare patterns and settings consistently; keep lighting/base materials unchanged. |
| Tint seems ineffective | In Mode B lower Albedo Strength from 1. Grayscale deliberately hides tint. |
| Wear choice absent or rejected | Only the two current approved soft Leakage effects are eligible. A changed/missing approval fingerprint or resource warns and hides; experimental source status never adds an approved effect. |
| Source cache/index changed | Run the explicit guarded inventory/staging audit. Review provenance drift before rebuilding; never crop contact sheets or search alternate source roots. Reopen the node/editor after restoring dependencies. |

## Five-minute human editor check

1. **Minute 1:** Drag Grunge under ImperfectionExperiments. Orient/position on the floor; inspect Experiment Notes. Change Width M and Opacity Multiplier in the editor without running.
2. **Minute 2:** Compare Grayscale Diagnostic and Tinted Opacity Illustration; change contrast/bias, repeat/rotation and Invert Scalar. Switch to a Dust source and confirm `opacity.red` in the notes.
3. **Minute 3:** Duplicate and place upright on a concrete wall. Set Approved Wear Modulation, choose each Leakage source, compare Modulation Enabled off/on and strength 0/1. Keep tint/transform fixed during masking comparisons.
4. **Minute 4:** Edit only the copy, switch its source, undo/redo, save/close/reopen. Check the original stays independent and both show one patch. Run the wing and compare settings/geometry; editor cameras can differ in brightness.
5. **Minute 5:** Hide the experiment group and verify approved/old wear, accepted plaque and CRT remain visible. Capture root/Inspector evidence before and after. Remove diagnostic placements unless you deliberately retain them as your own authored experiments.

Actual interactive checks for this task remain **NOT RUN** because native Godot window capture failed twice. Automated editor-hint/lifecycle checks and OpenGL runtime diagnostics are separate evidence. The human’s prior Task 2 acceptance does not automatically accept this new component. Source-quality and placement decisions remain with the human; Receiving C1 stays open.
