# M4 Stage B geometry measurement reuse — 25 October 2026

**STAGE B TECHNICALLY VERIFIED LOCAL CANDIDATE / INDEPENDENT CONTEXTUAL REVIEW AND DEVELOPER RETEST PENDING.** No merge, push, publication, M4 promotion or M5 work.

## Identity and preservation

Authoritative checkout: `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, branch `codex/m4-expedition-loadout`. Starting HEAD was `a0d4a8adb56b907587103ec65f5edf917c04ff2a`, directly above `3a57177c14f60aa3bd29508dff60bb64ab3ed3a9`; ancestry was verified. Stage A's retained catalogue correction remains untouched.

Preflight found an existing developer edit to `gameplay/logistics_wing/wing_gameplay.tscn` and **18** untracked sidecars, including Stage A's snapshot-catalogue test UID (the handoff's seventeen-count predates it). All are protected and excluded from this commit. Both performance candidates use the same current developer scene. No reset, cleanup, stash, worktree change, asset edit or actual developer save access occurred. The final external preservation audit compared **17,126 existing source/resource/asset/sidecar files** with their starting hashes: nothing missing, only `storage_visual_pose.gd` changed, and worktree registrations identical.

Task paths: `storage_visual_pose.gd`, `tools/asset_pipeline/tests/geometry_measurement_reuse_tests.gd`, its generated `.gd.uid`, and this note. Raw evidence, probe scripts, disposable slots and profiles remain outside the checkout at `C:/Users/Boschetar/.codex/attachments/m4-geometry-reuse-2026-10-25/` (E below).

## Implementation and input boundary

The shared helper caches **only the true transformed vertex minimum Y per mesh**. The key is the live Mesh instance identity plus the exact complete accumulated `Transform3D`, including authored storage rotation, visual scale, internal imported scale, nested rotations/scales/translations and mesh-node transform. A strong Mesh reference prevents object-ID reuse. Resource paths merely restrict eligibility to imported GLB ArrayMeshes; paths and item IDs are never measurement keys. All mesh surfaces still participate in a miss. Misses use a local minimum accumulator instead of a dictionary update for every vertex.

Packing yaw is applied above `AuthoredStoragePose`, outside the measured subtree. Thus the same geometry measurement correctly serves both packing orientations and Receiving's additional outer half-turn. World position, unit front alignment, shelf constraints and reservations remain under their existing owners. Every build still traverses the actual current node hierarchy, transforms conservative mesh AABBs, merges bounds and computes centering/seating. The vertex-corrected bottom, conservative top/X/Z extents and exact `SHELF_CLEARANCE_M = 0.006` remain unchanged. Cargo preflight, placement attempts and physical checks are unchanged.

The process cache holds at most **512 mesh/transform minima**, retaining no vertex arrays. Reaching the bound clears entries and disconnects their signal handlers; reuse resumes normally. `Resource.changed` invalidates every measurement for that exact Mesh. Explicit `clear_measurement_cache()` also releases references/handlers. Editor authoring and procedural/non-imported meshes always bypass reuse. This is an **immutable runtime loot** optimization: owners that change imported geometry must emit `Resource.changed` or clear before reuse; unsupported GPU-only deformation without that signal is outside this contract. Editor reimport never consumes the cache; a new runtime process starts empty. No persistent metrics, format, authoring flag or bake pipeline was introduced. Cache statistics return copied scalar counters and do not expose cached measurements.

## Before/after performance

Godot `4.7.stable.official.5b4e0cb0f`, native Windows OpenGL Compatibility, NVIDIA RTX 5060 Ti, 1280×720. Each invocation has its own external APPDATA/LOCALAPPDATA/TEMP directories and disposable slot copied from the preserved review snapshot, SHA-256 `9028ea7e310a71fe2cba75f4ea82bd395687f7871bebeb0cab67e8cdfea74e0d`. SaveService is injected before scene setup. The copy has 100 physical items: 83 stored, one carried and sixteen Receiving. No caches were cleared. Fresh means a separate process; warm repeats follow production Save & Exit in the same process. The existing developer editor was left alone throughout.

Monotonic usable-frame seconds **from the accepted production gameplay request**, after the menu. New Run confirmation is accepted immediately; first draw is separately logged. These are actual samples, not a statistical guarantee or a target claim.

| Native production request | Stage A fresh | Stage B fresh | Stage A warm | Stage B warm |
| --- | ---: | ---: | ---: | ---: |
| New Run | 23.631 | 12.173 | 18.970 | 6.444 |
| Continue | 13.300 | 10.697 | 8.545 | 5.509 |

Sources: `before-native-{new,continue}-serial` and `after-native-{new,continue}` console/engine logs and exit JSON, all exit 0 / `M4_PROBE_COMPLETE`. `-Baseline` in the external runner means no injected production scopes; it does not select or change a source revision. The production cache counters are present in Stage B.

Geometry work per transition (misses are actual vertex scans; hits do not call `surface_get_arrays`):

| Request | Stage A mesh scans / vertices | Stage B fresh misses / hits / vertices | Stage B warm misses / hits / vertices |
| --- | ---: | ---: | ---: |
| New Run | 664 / 42,070,574 | 135 / 529 / 7,083,348 | 0 / 664 / 0 |
| Continue | 142 / 10,035,378 | 65 / 77 / 5,076,784 | 0 / 142 / 0 |

Fresh vertex work falls **83.2%** for New Run and **49.4%** for Continue; warm repeats eliminate it. All 533 New Run and 115 Continue visual builds still occur. Twelve exact preflight calls, 192 orientation-record calls, 148 seed surface attempts and 85 successful placements still occur. Stage B counters are cumulative within each process; the warm row above is the delta from the fresh row. There are zero production bypasses in these scenarios.

Selected traced phase milliseconds (`before-trace-*` versus `after-trace-complete-*`, fresh requests):

| Phase | New before | New after | Continue before | Continue after |
| --- | ---: | ---: | ---: | ---: |
| Wing resource load | 6509.764 | 4884.497 | 6703.999 | 4989.101 |
| Wing instantiation | 2195.350 | 2042.869 | 2228.902 | 2067.517 |
| Synchronous add_child / ready | 14145.368 | 1818.304 | 413.801 | 369.196 |
| Twelve-manifest preflight, inclusive | 11653.086 | 639.515 | — | — |
| Seed placement, inclusive | 2078.693 | 813.785 | — | — |
| Snapshot restoration, inclusive | — | — | 3149.180 | 604.567 |
| Receiving restoration, within snapshot | — | — | 2388.039 | 373.795 |
| Visual builds, inclusive | 13044.330 | 787.802 | 3091.398 | 552.452 |
| Non-overlapping root geometry scans | 13037.425 | 782.338 | 3089.584 | 550.785 |

These are overlapping scopes: **do not add preflight, builds, recursive scans and restoration together**. Warm root scan time falls from 13011.332 to 9.604 ms New / 3082.011 to 1.988 ms Continue. Warm preflight is 55.131 ms; warm snapshot restoration is 51.291 ms. The reduction includes both measurement reuse and the miss loop's local accumulator; no isolated attribution between those two is claimed.

Catalogue acquisition remains one retained initial load: traced New 9791.399 → 7754.629 ms; Continue 9640.984 → 7871.505 ms, before the gameplay request. Its source is unchanged; this variation is **not attributed to Stage B**. Fresh traced usable frames were 23.223 → 9.095 s New and 12.864 → 8.382 s Continue. Other retained after traces recorded 11.062 / 9.284 s; loading variability is material. Primary native samples above are retained rather than replaced by faster later samples.

**Remaining cost:** unique first-use geometry still visits 7.08M / 5.08M vertices but now costs about 0.78 / 0.55 s in measured root scans. Wing resource load (about 4.9–5.0 s fresh / 4.4 s warm in the final trace), fresh instantiation (about 2.0 s), catalogue acquisition and ordinary construction remain. This scoped reuse materially addresses redundant scanning. If more startup work is authorized, investigate wing resource acquisition/instantiation and development-palette construction as a separately bounded correction. Do not infer those causes below the measured phase boundary or introduce persistent geometry baking here.

## Focused correctness evidence

Every selected successful production check below exited **0** with its completion marker and no failures. Console and engine logs were inspected separately.

- `geometry_measurement_reuse_tests.gd`: **287 checks**. Before implementation: 261 checks, exactly one expected failure for missing reuse; all 260 geometry assertions passed. After: 287/287. All **32 recorded Stage A pose/aligned-bound/seating rows are text-identical** (`geometry-reference-comparison.json`). Covers 061, 147, 041, high-poly Meat Pie 059, scaled 025, compound/LOD 108, 152 and 163; both packing orientations; changed scale/pose, nested non-uniform transforms, reused visual nodes, procedural multi-surface geometry, free/recreate, signalled geometry mutation, capacity eviction and explicit clear. An external intentionally stale transform key exits **1**, completion marker with **100 failures**, proving the oracle rejects incorrect reuse. No authored resource is written by mutation tests.
- `m4_cargo_tests`: all **12 exact manifests / 192 production TAKEs / 192 shelf handoffs**, no blockers. Its independent transformed-vertex contact assertions remain active, along with fully-OPEN reach and barrier checks.
- Isolated copy of `m4_seed_tests`: **173 checks**, exact **85 items / 240 Bulk**, production placement/retrieval. `m4_seed_access_tests`: **85 actual production-ray TAKEs** at the existing 2.3 m reach, no blockers.
- `m4_receiving_lifecycle_tests`: zero failures, active/deposited/upstream FIFO and real TAKE lifecycle.
- Isolated `m4_snapshot_tests`: separate writer **27 checks**, separate reader **21**. Mixed stored/Receiving/carry ownership, partial/open/terminal/cutoff/report states, physical reconstruction and no issuance/spend replay.
- Isolated save compatibility probe: **32 checks**, schema 4, rejection of schemas 1–3, changed content/fingerprint, invalid ownership and receipts; rejected operations preserve fixture bytes. Fingerprint remains `05fe898ff3e0535e7a8856d36c42827bd5235718c929e11e9ce8481d485093c9`.
- `m4_baseline_tests`: **167 rows**; `snapshot_catalogue_tests`: **6 checks**; `storage_visual_pose_tests`, `storage_stacking_interaction_tests`, `item_storage_pose_authoring_tests`: PASS.
- Isolated native `m4_rendered_tests`: **228 checks**, Windows display, both **1920×1080 and 1280×720**, real input/controller/physics paths, Save & Exit/Continue, report and stock construction. Native captures include seed overview and both-resolution panels. Representative stock/report captures were inspected. This is controlled integration, not developer gameplay acceptance.

Supplementary editor-mode probe confirms `Engine.is_editor_hint = true`, **two bypasses, zero hits/entries**, 1,154 vertex visits. Its custom editor SceneTree shutdown emits RID/ObjectDB leak diagnostics; it is not counted as clean interactive workbench acceptance. The first editor probe used the non-tool catalogue facade and failed on a placeholder instance; the corrected probe loads the tool-enabled definition directly. Existing pose-authoring tests pass. Native interactive workbench review remains a developer gate.

Native integration retains four known CF-07 `Parameter "material" is null` messages in each log; no suppression or repair was attempted. Selected gameplay performance and headless regression logs contain no script/assertion/warning/leak diagnostics. Failed harness preparation is preserved: the first RED attempt had a dynamic-call parse error; the corrected RED is the behavior proof. The first two exploratory native invocations briefly overlapped and are excluded from comparisons; `*-serial` replaces them. Initial after traces omitted visual-build scope timers because of mixed line endings; root counters/times were valid, and the final `*-complete-*` runs add those missing scopes. No production edit was needed for these harness corrections.

## Reproduction, review and stopping point

E contains `run-before.ps1`, `run-after.ps1`, `run-regressions.ps1`, `run-final-evidence.ps1`, `run-editor-native.ps1`, their referenced probe/source files, exact invocation arguments in exit JSON, `performance-results-final.json`, `regression-results.json`, diagnostic audits and preservation inventories. Use **new tags/destinations** on repetition; runners refuse existing gameplay slot tags. All test processes sharing the project ran serially in the selected sets. Historical hardcoded fixture destinations were changed only in external copies before invocation.

One proportionate author self-review checked resource identity/lifetime, transform equality, all-surface scans, invalidation/disconnection, bounded references, empty geometry behavior, editor bypass, mutable-result isolation, and the unchanged storage/Receiving callers and fingerprint contract. No actionable correctness issue was found in the authorized immutable-runtime scope. This is a self-review, not an independent contextual acceptance review. Independent review and developer native-performance/playtest gates remain pending.
