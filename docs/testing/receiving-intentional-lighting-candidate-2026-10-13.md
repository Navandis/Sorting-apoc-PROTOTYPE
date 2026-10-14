# Receiving intentional lighting candidate

**Current status — 14 October 2026: HUMAN-PROMOTED / PRODUCTION INTEGRATION TECHNICALLY VERIFIED.** See the [integration record](#human-promote-and-production-integration--14-october-2026) below for current owners and tuning policy. The 13 October sections remain historical evidence; their awaiting-review status, candidate-only ownership instructions and earlier numerical values are superseded for current use.

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

## Warmth and cage-balance refinement — 13 October 2026

**LOCAL CANDIDATE / AWAITING COMBINED HUMAN REVIEW.** The developer has accepted the preceding shadow correction and tolerates its faint residual pattern. This pass follows the approved warmth → cage brightness → metallic response sequence; it does not promote a final lighting policy.

| Step / Inspector property | Before | Selected for review | Reason |
| --- | --- | --- | --- |
| A: G1/G2 `light_color` | RGB (1,.90,.78) | (1,.84,.68) | Warmer concrete/wood while green paint, pale surfaces and red objects remain distinct; energy stays 2.6 |
| A: T1/T2 `light_color` | (1,.94,.82), inherited | (1,.91,.77) | A warmer cage with slightly more neutral task light than the apron |
| B: T1 `light_energy` | 1.15 | .75 | Reduces the strong contribution to pale cases/rear pallet and bright upward faces |
| B: T2 `light_energy` | 1.15 | .85 | Reduces glare while retaining more light for the shaded left-hand cargo |
| C: InteriorProbe `intensity` | .30 | .30 retained | Fresh .40 trial did not improve the rendered metal references |

All retained overrides live in `gameplay/logistics_wing/review/receiving_lighting_review.tscn`. Use **F6** and the representative-delivery launch command above. Inspector paths remain `Gameplay/Environment/ReceivingLighting/GeneralFixtures/G1/Light`, `G2/Light`, `TaskFixtures/T1/Light`, `T2/Light`; use Light Color/Energy. The probe's existing `Gameplay/Environment/ReceivingReflections/InteriorProbe` intensity control remains unchanged.

[Warmth comparison](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_warmth_balance_2026-10-13/warmth_comparison.png>) changes one color group at a time. [Cage comparison](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_warmth_balance_2026-10-13/cage_comparison.png>) and [lid crops](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_warmth_balance_2026-10-13/first_aid_lid_crops.png>) show the energy change with selected colors fixed. Separate T1/T2 energy-zero controls established their relative contributions; neither exclusion is retained. The .85/.85 trial preceded the selected .75/.85 balance. The lid keeps pale paint/wear, and computer cases, pallet tops and yellow rail are less glaring; jerry cans, vests, shaded carcass faces and usable deck regions remain readable in the checked views. No falloff or general-light energy adjustment was needed.

**Metallic-response limitation:** [fresh .30 versus .40](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_warmth_balance_2026-10-13/probe_comparison.png>) produces pixel-identical full toolboard and cargo images, including fuel cylinder, metal cargo and nonmetal controls. Intensity was the only changed parameter. It is therefore not justified to retain an increase or claim recovered metallic detail. Runtime inspection confirms layer/mask inclusion and toolboard Z bounds 3.781–3.859 m, only .141–.219 m inside the probe's +Z boundary at 4 m; blend distance remains .5 m. Diagnostic camera views from the unchanged capture origin (−33.825,1.9,0) show lit wall and dark surrounding regions. These are origin views, not an extracted cubemap, and do not establish why intensity has no visible effect. Capture/application or coverage diagnosis needs separate scope before altering origin, bounds or lighting arrangement. No speculative probe move, reflection cards, material repair or additional light was retained.

[Combined views](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_warmth_balance_2026-10-13/combined_review_views.png>) and [movement](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_warmth_balance_2026-10-13/movement_views.png>) cover apron, close/oblique tools, loaded cage and both threshold directions. Movement traverses 60 rendered frames per checked path. Working visibility, useful shadows and the darker upper envelope remain, with no significant new bands, leaks or detachment observed. Backlog remains dark and unchanged; W1's steady green patch remains conspicuous and uncalibrated. The excluded brace hash was not investigated.

Verification uses Godot **4.7.stable.official.5b4e0cb0f**, Compatibility/OpenGL 3.3, RTX 5060 Ti, 1920×1080. Real timed OPEN delivery: 24 items/three fixtures, fixed seeds 1842/9001 and steady green. Each lighting state uses the existing refresh owner followed by 100 rendered settle frames and 30 view frames; the final GPU image is pixel-identical after another 12 rendered frames. The request signal alone is not the completion check. Matched settings/state checks **PASS**, with only a 0.000001 transform-component rounding difference between commanded identical camera poses. Focused loading, Environment/probe/light instance-isolation, authored-transform, default-startup and refresh-integration checks **PASS, 0 failures**. Unchanged gameplay/shutter/audio and accepted shadow evidence are reused. Known certificate-store startup errors remain in raw logs; no held-item repair or new TAKE test was performed.

Preserved: every shadow setting (including G1 .30, G2 .20 and T2 .10 bias), ambient disabled, KeyLight off, exposure/tonemap, all ranges/cones/aims/falloff, ceiling bounce, fixture/art transforms, source materials/maps, probe configuration/refresh integration, W1, gameplay/audio and 3.40-second shutter contact. Canonical files and all three pre-existing dirty/untracked files are byte-identical to this task's preflight. Only the review scene and this addendum are retained in one local commit. No push, merge, production replacement or cleanup. **Stop for combined human review; metallic response remains an explicit trade-off.**

## HUMAN-PROMOTE and production integration — 14 October 2026

The developer explicitly promoted the combined intentional-lighting candidate through `84f6a31`, including the shadow correction at `980c294`, and authorized integration into `main` and publication to `origin`. Receiving C1 remains CLOSED / HUMAN-PROMOTED and Stage C single-cycle gameplay remains HUMAN-PROMOTED. Historical A30WS acceptance is preserved; its exact practical/global illumination values are superseded for current production use.

Production ownership is now `wing_environment.tscn` for explicitly disabled ambient illumination and the retained, hidden KeyLight, and `receiving/receiving_lighting.tscn` for G1/G2, T1/T2 and one ApronCeilingBounce. Background, Filmic tonemapping, exposure and unrelated Environment properties remain unchanged. The playable review inherits these production lights with no competing light overrides or duplicate bounce; its private Environment and Receiving player pose remain review-only. For ordinary production tuning, edit the canonical owners rather than the superseded candidate overrides.

| Light | Energy / RGB | Range / cone | Rotation, degrees | Bias / normal bias |
| --- | --- | --- | --- | --- |
| G1 | 2.60 / (1,.84,.68) | 8 m / 70° | (−90,0,0) | .30 / .50 |
| G2 | 2.60 / (1,.84,.68) | 8 m / 70° | (−105,0,0) | .20 / .50 |
| T1 | .75 / (1,.91,.77) | 4 m / 58° | (−68,−155,0) | .025 / .25 |
| T2 | .85 / (1,.91,.77) | 4 m / 58° | (−68,−25,0) | .10 / .25 |
| ApronCeilingBounce | .45 / (1,.88,.75) | 5.8 m / 75° | (90,0,0) | .03 / .35 |

These are the **current reviewed, adjustable production baseline**, not immutable specifications, gameplay constants or permanent numerical approval gates. Ordinary Inspector changes to energy, warmth, range, cone, attenuation, shadow settings and other appropriate light properties should preserve room character and avoid demonstrated defects. Track meaningful changes in version control and review proportionately: a small intensity adjustment normally needs visual review, not a complete gameplay regression, formal audition, new milestone, C1/Stage C reopening or DOCX cycle. Focused tests now check usable properties, canonical ownership, inheritance and structural/gameplay invariants rather than dated practical-light numbers.

The intentional global direction is to give future rooms purposeful, context-appropriate lighting instead of automatically restoring a broad ambient/KeyLight floor. Darkness in unfinished rooms is understood. This direction remains subject to future explicit design decisions; it does not rule out any appropriate ambient contribution forever. A different global policy, architectural fixture changes or new rendering systems require their own design discussion.

**Focused verification PASS:** Godot 4.7 Compatibility/OpenGL 3.3, RTX 5060 Ti, 1920×1080. The configured F5 UID resolves uniquely to canonical `wing_gameplay.tscn`; normal configured CLI startup succeeds, with canonical spawn/camera unchanged. No editor-button automation is claimed. Fresh GPU captures compare the pre-integration approved candidate, configured canonical production and reconciled review at matching real player-camera poses/FOV, timed OPEN, seeds 1842/9001, 24 actual items/three fixtures and steady-green W1. Effective light/environment/probe settings and all light-source paths match; transform rounding is within .00001. [Matched apron, toolboard and cargo views](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_lighting_publication_2026-10-14/parity_contact_sheet.png>) retain the accepted warmth, shadow correction, working visibility, cargo and restrained metallic response. Canonical mean absolute RGB differences are .00394 / .00955 / .02555 on a 0–255 scale, confined to small edge differences; no material illumination change was observed. The reconciled review's toolboard image is pixel-identical to the approved capture.

Lighting integration (150 checks), configured startup parity, playable review (zero assertion failures) and wing composition suites pass. Runtime confirms ambient/key off, five spots plus W1, one bounce and one unchanged .30 probe with the established bounds/refresh owner. Actual canonical TAKE succeeds and CRT updates to 23; review checks retain amber pulse, steady green, off initialization, shutter timing, probe refresh and ordinary shelf placement. Unchanged full-audio/closing/retirement evidence is reused. Logs retain the known certificate-store error, expected duplicate-namespace rejection diagnostics in composition tests and the previously reproduced held-item material-null renderer errors; none was concealed or repaired.

Only the three scene owners, three affected tests, this addendum and `CURRENT_STATE.md` change in the integration. The two pre-existing tracked modifications and untracked test UID remain byte-identical and unstaged. Fixture/art/material transforms, W1 calibration/logic, probe configuration and gameplay/audio owners remain unchanged. Ignored evidence, commercial assets, worktrees and DOCX masters are preserved. Publication uses one local integration commit and safe fast-forward of the accepted candidate history into `main`, then a normal push with exact remote-HEAD verification; no cleanup or next milestone is authorized here.
