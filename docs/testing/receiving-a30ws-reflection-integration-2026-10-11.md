# Receiving A30WS production integration — 11 October 2026

Accepted A30WS is integrated faithfully on local branch `codex/receiving-a30ws-reflections`. Implementation commit: `f44f69d041f92fb99ac95e052906162cc1eba2db`. **Recommendation: REVISE the initial capture cost before promotion.** Visual equivalence, saved runtime ownership and bounded refresh pass; performance acceptance fails. Editor selection/reopen, editor 3D comparison and native F5/F6 keyboard review remain NOT RUN because UI capture failed. No push, merge or Stage C implementation.

Task-owned implementation/test paths (nine files; only these were staged for the implementation commit):

- [gameplay/logistics_wing/receiving/receiving_lighting.tscn](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/gameplay/logistics_wing/receiving/receiving_lighting.tscn>)
- [gameplay/logistics_wing/receiving/receiving_reflections.gd](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/gameplay/logistics_wing/receiving/receiving_reflections.gd>)
- [gameplay/logistics_wing/receiving/receiving_reflections.gd.uid](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/gameplay/logistics_wing/receiving/receiving_reflections.gd.uid>)
- [gameplay/logistics_wing/receiving/receiving_reflections.tscn](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/gameplay/logistics_wing/receiving/receiving_reflections.tscn>)
- [gameplay/logistics_wing/wing_environment.tscn](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/gameplay/logistics_wing/wing_environment.tscn>)
- [tools/asset_pipeline/tests/receiving_lighting_integration_tests.gd](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/tools/asset_pipeline/tests/receiving_lighting_integration_tests.gd>)
- [tools/asset_pipeline/tests/receiving_reflections_integration_tests.gd](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/tools/asset_pipeline/tests/receiving_reflections_integration_tests.gd>)
- [tools/asset_pipeline/tests/receiving_reflections_integration_tests.gd.uid](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/tools/asset_pipeline/tests/receiving_reflections_integration_tests.gd.uid>)
- [tools/asset_pipeline/tests/wing_gameplay_navigation_tests.gd](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/tools/asset_pipeline/tests/wing_gameplay_navigation_tests.gd>)

This report is the only additional tracked task file. Raw evidence remains in the established ignored report folder; prior auditions are preserved.

The canonical `WingGameplay/Environment` owns a dedicated `ReceivingReflections` scene with one ordinary saved `InteriorProbe` child. Its runtime owner is `ReceivingReflections`. Identity parent transforms make local and world probe poses identical. The human-dirty wing scene was never rewritten or saved. Runtime fresh-process tests confirm one probe; ordinary editor selection is still a human check.

| Setting | Saved/effective value |
| --- | --- |
| G1 / G2 | Energy **1.71** each; RGBA **(1, 0.82, 0.64, 1)** |
| T1 / T2 and fixture emission | Preserved: energy **0.85**, RGB **(1, 0.94, 0.82)**; emission **0.6** |
| Probe centre / basis | World **(-34.825, 2.1, 0)**; identity rotation, unit scale |
| Size / effective bounds | **(12.35, 4.2, 8)**; x **[-41, -28.65]**, y **[0, 4.2]**, z **[-4, 4]** |
| Origin offset / world capture origin | **(1, -0.2, 0)** / **(-33.825, 1.9, 0)** |
| Intensity / ambient / update mode | **0.30 / AMBIENT_DISABLED (0) / UPDATE_ONCE (0)** |
| Interior / box projection / shadows / visibility | All **true** |
| Blend / maximum distance / mesh LOD threshold | **0.50 / 12 / 1** |
| Cull mask / reflection mask / node layer | **1 / 1 / 1** |
| Existing desktop atlas | **256**, **64** slots; mobile override **128** unchanged |
| Authored WorldEnvironment | Background mode 1, RGB (.055,.06,.065); ambient source 3, RGB (.78,.81,.84), energy .12; reflected source 2; tonemap 2. All other properties unchanged. |

All other light parameters, transforms, attenuation, shadows, key light, environment, camera attributes, materials, imports and commercial source assets are preserved. [Exact effective settings and capture poses](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/settings_manifest.json>) includes every stored environment/light/probe property and engine metadata.

`request_refresh()` waits two process frames for reveal/queued TAKE removal, reassigns UPDATE_ONCE to the **same saved node**, and coalesces bursts with a 0.2-second settling window. A request during that window schedules one follow-up for the latest geometry. No polling, transform jitter, duplication or UPDATE_ALWAYS. This Godot 4.7 setter sends renderer dependency invalidation even for the same mode ([scene setter](https://github.com/godotengine/godot/blob/4.7-stable/scene/3d/reflection_probe.cpp#L178), [Compatibility implementation](https://github.com/godotengine/godot/blob/4.7-stable/drivers/gles3/storage/light_storage.cpp#L483)); the actual stale/refreshed visual experiment verifies its effect. `refresh_started` marks the request, not GPU completion.

Today's hooks are the existing ReceivingManager `active_batch_changed` and actual materialized WorldItem `picked_up` signals. Initial native capture stays UPDATE_ONCE. Normal launch has no synthetic batch. Explicit debug delivery uses `(1842, 9001, 24, MIXED=3)`, produces 24 items/3 fixtures, and refreshes after materialization. A real successful TAKE leaves 23 items and requests refresh. There is currently no shutter animation/settled event; future Stage C calls `Environment/ReceivingReflections.request_refresh()` once its geometry settles. No stage mechanics were added.

The controlled shutter test copies the saved Open marker pose in memory and introduces the seeded mixed batch. Only the scratch driver's batch hook is temporarily disconnected to retain a deliberately stale closed cubemap. Reconnecting and calling the production seam updates the cube while keeping the same probe ID and all accepted settings. Signs, permanent barrier, cargo and CRT remain legible. Geometry-only changes do not refresh UPDATE_ONCE automatically.

Evidence (native Godot pixels; montage labels/resizing only):

- [Baseline vs integrated and approved A30WS: tools board](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/comparison_close.png>) and [wide room](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/comparison_wide.png>).
- [Closed-cube stale vs production-refreshed open/cargo](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/comparison_refresh.png>).
- [Backlog edge consecutive samples](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/comparison_boundary.png>) and [north/south/lift views](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/comparison_room_edges.png>).
- Representative walk previews: [Backlog](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/walk_backlog.gif>), [north](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/walk_north.gif>), [south](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/walk_south.gif>), [lift](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/walk_lift.gif>).
- [Configured-main vs direct-wing CLI launch captures](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/comparison_launch_modes.png>) (default spawn; native hotkeys NOT RUN).

Rendering used Godot **4.7.stable.official.5b4e0cb0f**, Compatibility / OpenGL 3.3 (`gl_compatibility` / `opengl3`), NVIDIA RTX 5060 Ti, driver 617.14. No headless/dummy rendering. Audio-only Dummy driver was used in GPU tests. Fixed captures are 1920×1080, near .05, no camera environment or attributes override; close FOV 40 at (-30.20852,1.735807,1.619705), wide FOV 65 at (-29.6,1.65,2.5) aimed at (-34.2,1.65,-.5), cargo FOV 58 at (-33,1.65,1.25) aimed at (-37.65,1.15,0). Initial/refresh settle: 80 frames; each view: 20 settle + 24 measured frames. Complete bases and poses are in the manifest.

The saved baseline reuses previously verified N0 pixels (G1/G2 1.9, RGB 1/.84/.68, no probe), clearly labeled. Integrated images match approved A30WS visually: restored silver tools and restrained cabinet/shutter response, warm yellow surround, readable concrete/wear and CRT, and a dark tray/ceiling without broad brightening or orange wash. Approved-versus-integrated mean absolute RGB-channel differences on the 0�255 scale are .0015 close and .0142 wide; these support equivalence, not a pixel-equality requirement.

Four continuous controlled camera translations each ran 120 physics intervals; 32 representative PNGs and sparse GIF previews are retained. Backlog runs (-33.6,1.65,.6)→(-25.6,1.65,.6), crossing x=-28.65. North/south track x=-35.3→-29.1 at z=±3.3; lift tracks x=-34.9, z=-1.2→1.2. Sampled transitions show no obvious brightness pop, severe projection drift or spill; the tray remains subdued. North/south routes are inside the wall edges, not outside-wall crossings. Original bounds/blend were retained. A real player CharacterBody movement/input route through Receiving→Backlog also passes (final error .378 m; 112 floor/contact frames). Human free-look/parallax acceptance remains NOT RUN; the GIFs are representative samples, not full-rate video.

| Acceptance check | Result |
| --- | --- |
| Saved runtime ownership, exact settings, masks/bounds; fresh-process reload | PASS |
| A30WS sampled close/wide equivalence and protected material/environment state | PASS |
| UID resolution and real CLI equivalent launch modes | PASS: `uid://bljf1nlhijej` resolves only to canonical wing; both launches exit 0 and final spawn pixels match |
| Ordinary editor selection/reopen, editor 3D comparison, native F5/F6 hotkeys | NOT RUN: editor opened; Computer Use launch approval timed out, then visible-window capture returned `FrameArrived timed out` / `window capture timed out` despite fresh selection/activation retries |
| Controlled boundary camera movement / actual Receiving player route | PASS for the routes above; unrestricted human movement/parallax review NOT RUN |
| Stale/refreshed cube, batch/TAKE hooks, burst/follow-up behavior, no idle polling | PASS |
| Performance: rule out obvious first capture hitch | **FAIL**, detailed below |
| Full wing navigation script | **FAIL**, pre-existing Gallery A route; Receiving and other four original routes PASS |
| File/asset/evidence preservation and task-only commit scope | PASS |

Performance is an unresolved integration concern. Final explicit mixed-cargo refresh has one **131.18 ms** wall-time frame; controlled fresh-process repeats show **124.85–131.54 ms** on the first new-cargo recapture with either recreation or same-instance refresh. Subsequent recaptures peak **8.48–10.26 ms**. Final stable-wide measured GPU mean/p95/max is **1.246/1.273/1.288 ms**, wall mean/max **2.107/2.595 ms**. These stable values do not negate the cold hitch.

A separate same-scene first-close-view control, with only the probe removed in memory, gives **2162.50 ms** total / **1968.21 ms** worst frame across 80 frames. With the saved probe: **5720.50 ms** total / **3520.50 ms** worst frame, about **3558 ms additional window cost**. Thus existing cold material/texture work and a substantial added initial probe cost both exist. The initial atlas creates colour/radiance cubemaps for its configured slot count ([engine source](https://github.com/godotengine/godot/blob/4.7-stable/drivers/gles3/storage/light_storage.cpp#L818)); atlas initialization is a plausible contributor, not an isolated profile diagnosis. No global atlas/quality change or speculative prewarm system was saved. [Cold paired measurements](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/cold_start_comparison.json>), [raw final timings](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/runtime_integrated.json>) and [refresh repeats](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/refresh_same_first.json>) retain evidence. Measurements are single-machine controlled runs, not a complete gameplay benchmark.

Focused regressions: **11 PASS, 1 FAIL**. PASS scripts: wing_startup_parity, wing_gameplay_composition, receiving_lighting_integration (126 checks), receiving_reflections_integration (final controller), receiving_lift_installation, receiving_deck_metric, receiving_set_dressing_collision, receiving_lift_crt, receiving_deck_presenter, receiving_freight_fixture_runtime and receiving_freight_reach. [Regression results with exact log paths](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/regression_results.json>) lists each full script name and exit status.

Navigation FAIL is `gallery_a_fixture_front`: timeout before `(0,.05,-7)`, final error **4.066584 m**, **218** contact frames. The original test from pre-task HEAD, with probe removed and G1/G2 restored in memory, reproduces identically; other original routes pass. [Integrated navigation log](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/wing_gameplay_navigation_tests.log>) and [original-test baseline control](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/baseline_navigation.log>). No unrelated collision/art repair was attempted.

Actual GPU test logs report the known `ERROR: Failed to read the root certificate store.` at `platform/windows/os_windows.cpp:2582`. Composition's two `duplicate seed identity namespace wing_seed_v1` errors are deliberately exercised negative cases confirmed by its assertions. Navigation has the explicitly reported assertion/FAIL errors. No additional renderer, shader or parser failures were observed in the completed runs. Editor UI/shutdown success is not claimed.

Preservation: **6109** preflight files checked; **6105 byte-identical**, with exactly the four owned existing-file edits above. No missing file or unexpected drift. All prior four audition folders, commercial source/maps/import sidecars/caches in the protected inventory, hidden alternatives, wear, signage, furnishing and collision are retained. The three original unstaged files remain byte-identical and unstaged: `data/environment/receiving_signage/lift_emergency_stop.svg.import`, `data/receiving/receiving_deck_stage_b_proof.tres`, `gameplay/logistics_wing/wing_gameplay.tscn`. [Preflight hashes](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/preservation_before.json>) and [preservation comparison](<D:/Godot Projects/Sorting-apoc-PROTOTYPE/reports/logistics_wing/receiving_a30ws_integration_2026-10-11/preservation_after_editor.json>). Before task staging, staged diff was empty and indexed content still matched HEAD; the index's byte hash changed, so index metadata is not claimed byte-identical. Evidence uses the preserved current checkout, including those human edits; they are not part of the feature commits. Only the nine owned code/test files and this report are committed. Capture drivers are archived as `.gd.txt` inside a `.gdignore` folder.

The smallest next step is human cold-entry validation, followed by a focused profile of initial atlas/cubemap/shader work if the pause is unacceptable. Keep the accepted lighting/intensity/bounds while resolving initialization cost; do not expand into Stage C or unrelated Gallery A repair. Native editor/F5/F6 checks also require completion before promotion.

Five-minute human in-game checklist:

1. Start normal **F5**, without debug arguments; walk west through Backlog into Receiving. Confirm an empty lift and note any pause on the first view/entry.
2. Compare tools-board silver metal, tray/pipes, shutter, concrete/wear, yellow surround and CRT with the linked A30WS captures. Confirm the room remains subdued and warm.
3. Walk Receiving→Backlog and back near (-34.2,.05,.6)→(-26.7,.05,.6); move along north/south walls and around the lift/doorframe. Look for popping, projection drift, reflection spill or changed collision.
4. Stop, inspect `receiving_reflections.tscn` / `InteriorProbe` in the editor, then return to the **wing_gameplay** tab and start **F6**. Compare Receiving appearance and confirm exact saved values; do not save the dirty wing.
5. If desired, run one explicit seeded debug case using the command below and note first-cargo/TAKE hitch behavior. Shutter remains static closed in ordinary/debug startup; the automated open test used only an in-memory pose change. Then choose **PROMOTE / REVISE**. Recommendation is **REVISE** for cold capture cost.

```powershell
& 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64.exe' --path 'D:/Godot Projects/Sorting-apoc-PROTOTYPE' -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=mixed
```

Publication, merge and further implementation require a separate human decision. Work stops at this review delivery.

---

## Later human disposition - 11 October 2026: PROMOTE with known debt

**Human decision: PROMOTE.** After the technical report above, the developer independently verified normal F5, F6 from the wing scene and CLI launches with no issues, and accepted A30WS reflections, lighting, metallic/loot readability and Receiving's subdued warm atmosphere. Ordinary play showed no noticeable framerate loss, tearing or visual/gameplay regression. This is human visual/playability evidence on one development machine; synthetic mixed-cargo profiling, an editor-inspector/selection review and other-hardware benchmarking were not separately reported. The earlier dated REVISE recommendation, measurements and NOT RUN entries remain historical evidence; this later human disposition authorizes scoped publication.

**Accepted prototype performance debt:** the controlled cold comparison added approximately **3.56 s** to the initial probe-capture window; first mixed-cargo recapture was approximately **125-132 ms**, with subsequent captures approximately **8-10 ms**. Stable GPU measurements and ordinary-play acceptance do not erase those first-capture costs. The developer explicitly accepts them for this prototype. Reassess loading transitions, repeated deliveries and other hardware in a separate task; no optimization was attempted here.

The accepted saved configuration remains probe intensity **0.30**, interior/box projection/shadows, AMBIENT_DISABLED and UPDATE_ONCE; centre **(-34.825, 2.1, 0)**, size **(12.35, 4.2, 8)**, offset **(1, -0.2, 0)**; G1/G2 energy **1.71**, RGB **(1, .82, .64)**. T1/T2, authored ambient/key light, exposure, tonemap, materials and all other properties remain unchanged. Existing request_refresh() coalescing and batch/TAKE hooks are retained. Future Stage C still needs a shutter-geometry settled event; no dynamic shutter or audio/light theatre was implemented.

Bounded publication checks confirmed the existing task-only ten-path range, unchanged task-owned production/test source, exact probe settings/ownership and one production UID declaration across **75** Godot-scanned scenes. Existing Compatibility/OpenGL captures and **11 PASS** regression records were reused; no new engine sweep or profiling was needed after the human launch checks. Current pending human wing edits differ from the earlier capture-time version and are preserved/excluded, not newly certified by those reused automated records. All existing tracked, untracked and ignored files were inventoried for before/after preservation; only this appended acceptance text is a new tracked change. Publication requires verified fast-forward ancestry from freshly checked origin/main, a non-force push of the audited SHA, and exact remote-ref confirmation.

The unrelated, baseline-reproduced **gallery_a_fixture_front** failure remains; Receiving and the other relevant routes/checks passed previously. No navigation repair was authorized. The prior editor viewport/selection capture limitation remains **not separately evidenced**, distinct from the newly human-confirmed F5/F6/CLI checks, and is not a new promotion blocker. **Receiving C1 overall remains IN PROGRESS; the wider EAF4 authoring milestone remains complete.**

**Separate documentation follow-up (not performed here):** reconcile CURRENT_STATE.md, CODEX_BOOTSTRAP.md and README.md; align VDD v0.9 and Prototype Findings v0.12 DOCX masters programmatically, retain prior editions/embedded images, regenerate Markdown mirrors, and render PDF/page images for QA and human PDF review. Keep old counts/dates historical and identify A30WS as the accepted Receiving refinement. Leave GDD v0.12 unchanged unless that separate review demonstrates a real design/scope contradiction. Exact publication refs, paths and preservation hashes are delivered in the publication receipt and final response.
