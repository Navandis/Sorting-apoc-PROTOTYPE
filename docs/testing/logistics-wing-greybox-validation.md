# Logistics Wing Greybox — First-Pass Validation

**Date:** 16 September 2026

**Branch:** `codex/logistics-wing-greybox`

**Verified base:** local `main` / `origin/main` at `8ee62bd3bc4f23918717517e066d4c6a8cb565df`

**Implementation verified through:** `7ba27a5`

**Rejected Receiving preserved:** `codex/receiving-elevator-stage-b-pass1-shell` at `c9752c8c68cd55b950dd588542ea271e1acc0aab`

**Engine:** Godot `4.7.stable.official.5b4e0cb0f`, Jolt, GL Compatibility

**Renderer used for evidence:** OpenGL 3.3 Compatibility on NVIDIA GeForce RTX 5060 Ti

## Outcome

The first complete neutral greybox of the accessible Quartermaster logistics wing is implemented in a dedicated scene. It includes Receiving, Dispatch, Backlog, passage-like Sorting, Storage A–E, the sole C↔D secondary opening, Medical and Kitchen approaches, Workshop/Salvager and retained blocked continuation, the dog-legged deeper approach, Incinerator, Bunker Ops frontage, and the separate deeper-settlement closure.

The original `main.tscn`, `player_controller.gd`, gameplay/catalogue data, and default main-scene UID `uid://drbkr86g3cxl1` were not changed. No rejected Receiving geometry was reused. No physical Receiving, functional storage, final assets, environment-art treatment, or off-map facility interiors are included.

## Reproduction

Run the independent review scene from PowerShell:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://greybox/logistics_wing/wing_review.tscn'
```

The player starts at the Receiving apron. Controls remain the project's normal `WASD`, mouse-look, `Shift` sprint, and `Esc` mouse release behavior. The review scene contains one active gameplay camera.

Regenerate the editor-visible geometry intentionally with:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script res://greybox/logistics_wing/build_wing_geometry.gd
```

Regenerate visual evidence with:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://greybox/logistics_wing/wing_capture.tscn' -- --capture
```

Regenerate controller/collision evidence with:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://greybox/logistics_wing/wing_traversal.tscn' -- --traversal-evidence
```

## Player parity

The review-only player scene directly reuses `res://player_controller.gd` and `res://carried_items.gd`. It preserves:

| Property | Review value |
| --- | ---: |
| Walk speed | 4.0 m/s |
| Sprint multiplier | 2.0 |
| Acceleration / deceleration | 18.0 / 24.0 |
| Capsule radius / height | 0.34 m / 1.75 m |
| Capsule centre height | 0.875 m |
| Camera eye height | 1.7162851 m |
| Camera FOV | 75° |

Only the spawn transform and review-local disabling of loot auto-registration, registration logging, and held-item presentation differ. Movement, mouse behavior, gravity, collision, HUD/controller script, and shared gameplay code were not rebuilt or modified.

## Topology and negative connections

The saved geometry declares and tests the intended graph. Runtime routes additionally exercise every named safe-side destination. The following remain absent and structurally closed:

- no E→deeper shortcut;
- no gallery-to-gallery shortcut except C↔D;
- no facility access through a storage gallery;
- no Medical↔Kitchen shortcut;
- no lateral Receiving/surface route;
- no extra eastern or Incinerator exit.

Freight, Medical, Kitchen, Workshop, Bunker Ops, the blocked continuation, and the deeper-settlement edge use visible fixed collision boundaries. The freight boundary is a rail-and-post barrier rather than an opaque full-height wall.

## Dimensions

Values are authored working hypotheses, not production architecture. “Clear” subtracts the 0.30 m wall faces where applicable; proxy lanes measure between visible proxy/boundary faces. Ordinary clear height is 3.40 m and Receiving clear height is 4.20 m.

| District / condition | Authored or derived clear measurement |
| --- | --- |
| Whole horizontal extent | 104 m east–west × 53 m north–south |
| Receiving | 9.70 m north–south; 8.69 m from barrier east face to east boundary; 6.40 m core threshold |
| Dispatch alcove | 5.70 m wide × 3.85 m deep; 1.35 m side gaps at work-surface proxy |
| Backlog | 7.30 m structural width; 4.70 m centre lane between opposing edge blocks |
| Sorting | 9.70 m internal north–south width; 8.225 m from table front to south wall; 3.95 m / 1.95 m table end clearances |
| Sorting thresholds | 6.40 m west; 4.00 m east to Storage; 4.00 m south to Workshop branch |
| Storage spine | 4.70 m west section; 3.70 m east section |
| Gallery A | 6.70 m structural width; 5.80 m west-shelf-to-east-wall lane; 3.00 m entrance |
| Gallery B | 7.70 m structural width; 6.75 m west-wall-to-east-shelf lane; 3.00 m entrance |
| Gallery C | 7.70 m structural width; 6.75 m shelf-constrained lane; 3.00 m entrance |
| Gallery D | 8.70 m structural width; 2.35 m narrowest island-side lane |
| C↔D secondary opening | 3.00 m |
| Gallery E | 7.70 m structural width; 1.60 m narrowest island/west-wall lane; 3.00 m single entrance |
| Medical | 3.70 m corridor; 2.00 m spine threshold |
| Kitchen / Mess approach | 3.70 m south leg; 2.70 m cross/north legs; 2.00 m spine threshold |
| Workshop branch | 3.70 m entry; 2.05 m east-side lane past edge mass; 2.45 m north bypass at service-edge mass |
| Salvager | 4.70 m room width; 4.00 m front buffer; 0.15 m side gaps intentionally prevent side/rear access |
| Deeper approach | 4.20 m wide leg; 3.70 m dog-leg; 2.70 m narrow leg |
| Incinerator | 3.70 m approach; 9.70 m pocket; 0.35 m machine side gaps intentionally prevent bypass |
| Bunker Ops handoff | 3.70 m wide × 6.70 m deep; 1.75 m east lane beside counter proxy |

Representative source assets measured before authoring were: Table `2.584972 × 0.885119 × 1.477014 m`, Metal shelves `3.227211 × 2.935879 × 1.097445 m` in the intended orientation, and Locker `0.857411 × 2.758472 × 1.463009 m`. They informed scale only; the greybox proxies remain deliberately generic.

## Controller-driven route evidence

All rows below are **measured simulated gameplay travel**, not straight-line distance divided by speed. The unchanged controller consumed injected physical `W` key events at a fixed 60 Hz physics step, without sprint. The runner sets yaw toward explicit hand-authored waypoints; each route resets to its start anchor, but no teleport occurs within a measured route. Arrival tolerance is 0.45 m and recorded endpoint errors were 0.320–0.383 m.

This proves controller/capsule traversal and collision on the saved scene. It is not a substitute for the pending human mouse-look walkthrough.

All coordinates below are `(X, Z)` at finished-floor `Y = 0.05 m`.

| Route / anchors | Start → end | Walk length | Elapsed |
| --- | --- | ---: | ---: |
| Receiving apron → Sorting work | `(-31.5, 0.0)` → `(-9.0, -2.65)` | 22.820 m | 5.883 s |
| Receiving apron → near Storage | `(-31.5, 0.0)` → `(-1.0, 2.5)` | 30.254 m | 7.683 s |
| Sorting → Medical safe side | `(-9.0, -2.65)` → `(6.0, -18.2)` | 37.980 m | 9.683 s |
| Sorting → Kitchen safe side | `(-9.0, -2.65)` → `(24.5, -18.2)` | 55.655 m | 14.200 s |
| Sorting → Workshop safe side | `(-9.0, -2.65)` → `(-10.3, 20.0)` | 22.600 m | 5.767 s |
| Sorting → Salvager front | `(-9.0, -2.65)` → `(5.5, 24.8)` | 40.408 m | 10.400 s |
| Sorting → Incinerator front | `(-9.0, -2.65)` → `(37.0, 12.2)` | 61.520 m | 15.583 s |
| Sorting → Bunker Ops safe side | `(-9.0, -2.65)` → `(59.0, -9.5)` | 79.013 m | 19.983 s |
| Sorting → blocked continuation safe side | `(-9.0, -2.65)` → `(-8.5, 21.5)` | 23.942 m | 6.100 s |
| Sorting → deeper-settlement closure safe side | `(-9.0, -2.65)` → `(60.5, -7.0)` | 80.897 m | 20.467 s |
| Gallery C → Gallery D via secondary opening | `(2.0, 8.0)` → `(10.0, 5.0)` | 10.831 m | 2.833 s |
| Gallery C → Gallery D via primary spine | `(2.0, 8.0)` → `(10.0, 5.0)` | 17.619 m | 4.600 s |
| Near Storage → Gallery A | `(-1.0, 2.5)` → `(1.5, -6.0)` | 10.044 m | 2.700 s |
| Near Storage → Gallery B | `(-1.0, 2.5)` → `(11.0, -5.0)` | 17.260 m | 4.450 s |
| Near Storage → Gallery C | `(-1.0, 2.5)` → `(2.0, 8.0)` | 6.698 m | 1.783 s |
| Near Storage → Gallery D | `(-1.0, 2.5)` → `(10.0, 5.0)` | 15.116 m | 3.933 s |
| Near Storage → Gallery E | `(-1.0, 2.5)` → `(20.0, 5.5)` | 25.661 m | 6.567 s |

The reproducible machine-readable record is `reports/logistics_wing/greybox/traversal_results.json`. Its final run reported `17` routes, `7` boundaries, and `0` failures.

### Sustained-input boundary checks

Each check drove the normal player forward for 3.0 simulated seconds and required both a safe-side coordinate and less than 0.08 m movement during the final second.

| Boundary | Final blocking coordinate | Result |
| --- | ---: | --- |
| Freight barrier | `X = -35.488` | PASS |
| Medical frontage | `Z = -19.657` | PASS |
| Kitchen frontage | `Z = -19.657` | PASS |
| Workshop frontage | `X = -11.657` | PASS |
| Blocked continuation | `Z = 22.946` | PASS |
| Bunker Ops frontage | `Z = -11.659` | PASS |
| Deeper-settlement closure | `X = 61.334` | PASS |

## Visual evidence

The final image set was refreshed from committed code at `21a2dba`; subsequent commit `7ba27a5` changes traversal coverage only and does not change geometry, cameras, or rendering. The capture manifest records each camera transform, target, FOV, roof state, resolution, renderer, review scene, and layout revision.

- Output directory: `reports/logistics_wing/greybox/`
- Full-resolution views: 19 PNGs at `1920 × 1080`
- Contact sheets: `contact_sheet_01.png`, `contact_sheet_02.png`
- Reproduction metadata: `capture_manifest.json`
- Debug overview: `overview_debug_topdown.png`, roof hidden, orientation/area aids visible, 10 m scale
- Normal evidence: 18 ceiling-on first-person views at eye height `1.7162851 m` and FOV `75°`, with diagnostic orientation labels hidden

Coverage includes Receiving/freight, the Receiving–Backlog–Sorting core, three Sorting looks from a common work position, A/B, C/D and the sole secondary opening, E, Medical, Kitchen, Workshop, Salvager, retained blocked continuation, wide/deep dog-leg, Incinerator, Bunker Ops, and the distinct deeper closure.

## Technical verification

The following checks are required before delivery and were run against the saved files:

| Check | Result |
| --- | --- |
| `logistics_wing_geometry_tests.gd` | PASS |
| `logistics_wing_capture_tests.gd` | PASS |
| `logistics_wing_traversal_tests.gd` | PASS |
| Controller traversal evidence | PASS — 17/17 routes, 7/7 boundaries |
| Visual capture runtime | PASS — 19 views, 2 sheets, `gl_compatibility` |
| Saved scene parser/editor scan | PASS; Windows root-certificate diagnostic only |
| Independent review-scene smoke | PASS |
| Original default-main smoke | PASS; default UID unchanged |
| Existing non-hanging regression scripts | PASS — 33/33 scripts exited 0 |

The baseline `main_scene_loot_audit_integration_tests.gd` remains a known long-running audit: a bounded 25-second run reproduced only its three pre-existing assertions (two at line 179 and one at line 95) before termination. This milestone does not waive, rewrite, or attribute new failures to that exception. The item-catalog duplicate-ID/path, Receiving duplicate-path, and known `loot_000015` diagnostics also remain deliberate baseline test stimuli, not new wing failures.

Godot repeatedly emitted `Failed to read the root certificate store` on this Windows host while the relevant commands still exited successfully. No network feature is used by the greybox.

## Self-inspection and rework record

- No clarification question or user intervention was needed after kickoff.
- The first visual review found an overly distant overview, intrusive orientation labels in first-person views, and several weak/occluded camera positions. The correction remained local to the capture helper and its contract test.
- The first traversal pass found `BlockedContinuationSafeSide` wedged inside two debris collision envelopes: the 0.60 m debris gap was smaller than the 0.68 m capsule diameter. A clearance regression was added, the source anchor moved to the real safe side, geometry was regenerated, and the full traversal/boundary run then passed.
- The validation audit caught that the original C↔D alternate timings used different endpoints. A same-anchor regression was added and both routes were remeasured fairly.
- A final acceptance audit expanded traversal from the required timing set to all five galleries and both closure safe sides. The final run covers every named safe-side anchor.
- One-time tooling added for this milestone is limited to the one-purpose geometry builder, capture helper, and explicit waypoint traversal evidence runner. No general layout/path solver, plugin, downloaded dependency, or shared controller refactor was introduced.
- Native-app computer control could launch Godot but exposed no attachable Godot window in this session. The automated controller replay is valid physics/collision evidence, but a human walkthrough remains required. This is a UI-tool-access limitation, not evidence of a geometry-authoring failure.
- Exact elapsed operator time, token usage, model identifier, and independent-review time were not exposed/recorded and are not invented here.

## Known limitations and non-claims

- Human spatial judgment, mouse-look feel, landmarking, and subjective route pacing are not approved by automated traversal or still captures.
- First-person images prove geometry, enclosure, proxy massing, and broad sightlines only. They do not validate final wayfinding, loot identification, arrival audio/light, requests, economy, category assignment, storage capacity percentage, or integrated gameplay balance.
- Geometry regeneration is intentional and one-command, but Godot may rewrite generated scene node `unique_id` fields even when geometry is semantically unchanged. Revision-reliability promotion awaits a genuine feedback-driven edit.
- Evidence PNGs and report JSON are intentionally local/untracked; reproducible source tooling and this record are committed.
- The unrelated untracked `reports/receiving/` evidence from the preserved historical branch was left untouched.

## Human walkthrough questions

1. Does Receiving→Backlog→Sorting read as one working logistics core rather than three isolated rooms?
2. At the Sorting work position, are freight awareness, table access, and the turn toward Storage legible at normal FOV?
3. Are Storage A–E differentiated enough at greybox fidelity, and is the C↔D shortcut useful without making the network feel like a grid?
4. Is Gallery E's 1.60 m proxy-constrained lane acceptably tight, or should the low island move before gameplay is layered in?
5. Do Medical and Kitchen feel protected/separate while remaining easy to find from shared circulation?
6. Do Workshop/Salvager and the blocked continuation communicate service character without implying an explorable abandoned district?
7. Is the roughly 20-second walk from Sorting to Bunker Ops a useful sense of depth, or disproportionately long for likely request loops?
8. Are Incinerator, Bunker Ops, and the deeper-settlement closure clearly distinct at the eastern end?

## Status

- **Scope completeness and technical verification:** PASS for the requested first complete greybox and recorded automated checks.
- **Actual normal-controller traversal coverage:** PASS for 17 scripted-yaw, normal-controller/capsule routes and 7 sustained-input boundaries; human mouse-look traversal remains pending.
- **Human spatial review:** **PENDING — awaiting the user/reviewer walkthrough.**
- **Workflow feasibility:** First-pass observations recorded; promotion/assessment remains **PENDING** until walkthrough feedback and one genuine revision cycle.
- **Revision reliability:** **PENDING** until a feedback-driven revision is implemented and rechecked.
- **Production-art approval, physical Receiving validation, and integrated gameplay balance:** **NOT CLAIMED.**

Stop here for the human walkthrough. Do not begin functional Receiving, environment art, or a speculative revision without actual feedback.
