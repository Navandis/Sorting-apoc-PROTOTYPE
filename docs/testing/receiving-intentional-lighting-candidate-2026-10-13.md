# Receiving intentional lighting candidate

13 October 2026. **LOCAL CANDIDATE / AWAITING HUMAN LIGHTING REVIEW.** Receiving C1 and Stage C remain human-promoted. This review scene changes lighting only; it does not replace canonical startup or establish a final bunker lighting policy.

## Play the candidate

Open `res://gameplay/logistics_wing/review/receiving_lighting_review.tscn` and press **F6** for an empty lift. The real player starts in Receiving. For a representative delivery, run:

```powershell
& 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64.exe' --path 'D:/Godot Projects/Sorting-apoc-PROTOTYPE' 'res://gameplay/logistics_wing/review/receiving_lighting_review.tscn' -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=mixed
```

The ordinary accepted arrival/opening sequence reveals **24 actual items in three mixed freight fixtures**. Walk, TAKE, carry and store normally. F5 still opens the canonical production wing.

## Lighting choices

The scene instances the real wing, preserving its gameplay hierarchy and authored art. A private, per-instance Environment explicitly disables ambient. KeyLight is hidden. Filmic tonemapping, exposure 1, background and materials remain unchanged. Other provisional fills retain their production state; no neighboring room is relit.

With these helpers excluded, the starting rig left the upper workbench and much of the vertical envelope unreadable. Wider practical coverage and a modest G2 aim toward the workbench address that coverage first. The task strips aim further toward cargo. No fixture mesh, chain, bulb, furnishing or structural transform moves.

| Light | Candidate settings | Purpose |
| --- | --- | --- |
| G1/G2 | Energy 2.6; RGB (1,.90,.78); range 8 m; cone 70° | Warm-to-neutral apron, workbench and vertical coverage; G2 X rotation −105° |
| T1/T2 | Energy 1.15; range 4 m; cone 58°; existing color | Useful cage/front-cargo light; rotations (−68,−155,0) and (−68,−25,0) degrees |
| ApronCeilingBounce | Energy .45; RGB (1,.88,.75); range 5.8 m; cone 75°; shadowed | One upward floor-bounce approximation, at (−32.2,.65,0), X rotation +90° |

The practical-only rig still left the ceiling effectively black. The bounded upward spot makes the ceiling and some upper surfaces readable without reinstating global ambient. It is a deliberate diffuse approximation, not a physical fixture or GI simulation. **Toggle its Visible property** for the one useful fill comparison; then request a probe refresh/restart before judging reflections. No alternative scene or settings matrix is retained.

One Receiving probe and its existing batch/TAKE/settled-shutter refresh owner remain, with established .30 intensity and bounds. No probe intensity compensation, extra probe or continuous recapture. Metals retain restrained/dark responses; toolboard silhouettes and some reflected detail are readable. Judge this directly in play rather than against A30WS pixels.

W1 remains uncalibrated: accepted amber pulse, steady green OPEN and off during closing/idle, with its original energy/range/state logic. The green wall patch is conspicuous under the candidate and is a human-review point after the general lighting decision.

## Threshold and other rooms

Receiving reads as a lit destination from Backlog. The sill and apron approach receive practical spill, but the Backlog passage is substantially darker when looking out of Receiving; distant Sorting/helper-lit storage is visible beyond. **This is the principal unresolved navigation boundary.** A Backlog practical-light decision needs separate scope if this transition is unacceptable. No sill, material, geometry or circulation repair was made.

The review Environment affects the whole wing: removing ambient/KeyLight darkens unlit routes and shaded portions of other rooms. Gallery B retains its provisional direct lighting but loses the ambient floor. This consequence belongs to the candidate, not canonical startup.

## Inspector controls

All candidate lighting overrides live in the review scene. Expand its editable `Gameplay` instance:

- `Gameplay/Environment/GameplayEnvironment` → Environment → Ambient Light Source, Tonemap.
- `Gameplay/Environment/ReceivingLighting/GeneralFixtures/G1/Light` and `G2/Light` → Light Energy/Color, Spot Range/Angle, Rotation, Shadow Bias/Normal Bias.
- `Gameplay/Environment/ReceivingLighting/TaskFixtures/T1/Light` and `T2/Light` → the same controls.
- `Gameplay/Environment/ReceivingLighting/ApronCeilingBounce` → Visible, Energy, Range/Angle and Shadow settings.
- `Gameplay/Environment/ReceivingReflections/InteriorProbe` → Intensity, Size, Origin Offset and Ambient Mode. Preserve the existing refresh owner.

Save tuning into **this review scene**, not the original instanced scenes/resources. W1's functional controls remain on `Gameplay/ReceivingRuntime/ReceivingLiftCycle`; final calibration is deferred.

## Evidence and checks

[Six representative views](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_intentional_lighting_2026-10-13/candidate_contact_sheet.png>) include cargo, workbench, amber indication and both threshold directions. [Practical-only versus bounce](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_intentional_lighting_2026-10-13/bounce_comparison.png>) shows the reason for the added source. Full PNGs, settings, poses, logs and task-local capture driver remain in that ignored `.gdignore` folder. The earlier blackout diagnostic is preserved.

GPU evidence uses Godot **4.7.stable.official.5b4e0cb0f**, Compatibility/OpenGL 3.3, RTX 5060 Ti/NVIDIA 617.14, 1920×1080, actual player Camera3D with no environment/attributes overrides. Apron FOV 65°, cargo 58°, workbench 40°, threshold 70°. Materials, exposure and poses are fixed within comparisons; no average-brightness matching. Each relevant state uses the existing request_refresh(), 80 rendered settle frames and 20 view-settle frames. The OPEN stability pair is pixel-identical. Incoming captures freeze the accepted amber sample for matched reflection evidence; OPEN is reached through the real timed sequence.

**Focused candidate assertions PASS (0 failures)** in Compatibility/OpenGL. The test catches shared-resource leakage and exercises the real scene. Checks cover per-instance Environment isolation, unchanged art transforms/default entry, configured real gameplay, delivery, warning pulse/steady green, TAKE, CRT counts, the same probe's refresh connections and ordinary shelf placement. **Direct candidate CLI loading and nine GPU captures PASS.** The test log also emits material-null renderer errors when the first received item is shown in the real player held view. A minimal control reproduces this on the unchanged canonical wing; disabling held view in that control removes it. This baseline issue is retained, not repaired or concealed. TAKE succeeds and the remaining count becomes 23 in both controls. See `focused_deferred_teardown.log`, `canonical_take_control.log` and `canonical_take_no_held.log` in the evidence folder. Accepted 3.40-second shutter contact, full audio and closing/retirement evidence are reused with unchanged owning scripts/scenes/audio; there is no broad regression sweep or fresh full-audio certification. Capture runs use Dummy audio. Logs retain the known OS certificate-store startup error.

Canonical production files and both pre-existing dirty files remain byte-identical to preflight. Candidate-only files are committed locally; no push, merge, default-entry change, cleanup or production replacement. **Stop for human lighting review.**

## Shadow-artifact correction addendum — 13 October 2026

**LOCAL CORRECTION / AWAITING HUMAN REVIEW.** The broad cabinet, toolboard, wall and cargo bands are direct-light self-shadow acne. With illumination fixed and the probe temporarily hidden, all-shadow-off controls removed the bands; individual controls isolated G2 at the workbench and G1/T2 on cargo. Restoring each control reproduced its baseline pixel-for-pixel. Bias-only trials with all five shadow maps enabled cleared the dominant bands without relying on a changed atlas light count. [Godot's bias documentation](https://docs.godotengine.org/en/4.7/classes/class_light3d.html#class-light3d-property-shadow-bias) describes this acne/separation trade-off.

Only these `shadow_bias` overrides are retained in `receiving_lighting_review.tscn`:

| Owning path below `Gameplay/Environment/ReceivingLighting` | Before | After |
| --- | --- | --- |
| `GeneralFixtures/G1/Light` | .05 | .30 |
| `GeneralFixtures/G2/Light` | .05 | .20 |
| `TaskFixtures/T2/Light` | .025 | .10 |

G2 .10 and G1 .20 left visible bands in the tested views. Individual normal-bias trials were also compared; normal bias remains unchanged. T1 and ApronCeilingBounce retain their original settings, and all five lights still cast shadows. Shadow toggles, caster-mask exclusions, larger bias trials and a 32-bit atlas control were diagnostic only. The actual 4096 atlas, 16-bit depth, 4/4/16/64 slot distribution and Soft Low filters remain unchanged. The brace-junction hash survives a zero-caster-mask control; the developer identified it as pre-existing and explicitly excluded it from this correction. It is not a reason to increase T1 bias or alter art.

[Matched views](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_shadow_artifact_2026-10-13/before_after_views.png>) and [native-size crops](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_shadow_artifact_2026-10-13/before_after_crops.png>) use the same real camera, materials, exposure and illumination, with the existing probe enabled and freshly captured for both states. The real timed delivery reaches OPEN with 24 items/three fixtures. [Camera movement](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_shadow_artifact_2026-10-13/movement_views.png>) covers 60 rendered frames per view, including an oblique toolboard and a closer cargo angle. The pronounced bands did not recur; useful tool, cargo, rail, pallet-jack and furniture occlusion remains, with no visible new detachment or leaks in the checked angles. The darker upper envelope remains. Full PNGs, movement GIFs, exact transforms/settings, scripts and raw logs are in that ignored `.gdignore` evidence folder.

GPU verification uses the same Godot 4.7 Compatibility/OpenGL executable and RTX 5060 Ti. Focused loading/Environment-isolation/art-transform/startup/probe-owner checks **PASS, 0 failures**; matched-capture invariants also **PASS**. Existing TAKE, storage, W1, shutter and full-audio evidence is reused. The held-item material-null issue is untouched; no TAKE is needed in these captures. Logs retain the known certificate-store startup error.

All illumination parameters, ambient/KeyLight state, exposure, materials/maps, mesh transforms, probe settings/refresh owner, W1 and canonical production files remain unchanged. Both pre-existing dirty files are preserved byte-for-byte. This addendum and the three candidate bias overrides are the only retained changes. One local commit; no push, merge, cleanup or production replacement. **Stop for human artifact review.**
