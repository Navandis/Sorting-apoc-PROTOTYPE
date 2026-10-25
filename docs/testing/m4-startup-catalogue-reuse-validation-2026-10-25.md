# M4 retained-catalogue startup correction — 25 October 2026

Local correction based on candidate `3a57177c14f60aa3bd29508dff60bb64ab3ed3a9`, branch `codex/m4-expedition-loadout`. This record covers the explicitly authorized startup correction only. M4 human acceptance and the wider candidate review remain separate gates. No merge, push, publication, balance change or M5 work.

## Change and diagnosis

`gameplay/run/run_snapshot.gd:46` now obtains its `ItemCatalog` through `Catalog._catalogue()`, the existing facade's retained reference, rather than a function-local `load(Catalog.CATALOGUE_PATH)`. The facade itself is unchanged. Fingerprint fields, pose contract, serialization and SHA-256 calculation are unchanged; each request still computes its fingerprint. Snapshot validation, compatibility and ownership rules, reconstruction and save transactions are unchanged. Geometry scanning, cargo preflight and scene loading are untouched.

Before editing production code, the supplied diagnosis was checked against current source and a new focused regression was run. All **1,437** source/sidecar hashes in the diagnosis matched the pre-change checkout. The regression failed exactly its retained-catalogue assertion: after fingerprinting, the resource was no longer cached. Native tracing then observed two uncached acquisitions: **10,480.862 ms** in fingerprinting and **7,465.457 ms** in the facade. After the correction, the facade performed **one** uncached load, **7,553.228 ms**, inside the fingerprint acquisition (**7,553.315 ms**, overlapping parent time). Later warm acquisition was **0.011 ms**. These scopes were injected into current script source in memory, never written into production files.

## Fresh and warm launch measurements

Godot **4.7.stable.official.5b4e0cb0f**, Windows native OpenGL Compatibility, NVIDIA RTX 5060 Ti / driver 621.01, 1280×720. Each invocation had a unique external APPDATA/LOCALAPPDATA/TEMP profile and disposable save directory. Fresh means a new process; OS, project import and shader caches were not cleared. Warm menu inspection repeats in the same process. The same 100-item schema-4 review snapshot was copied for each saved-slot launch; no human slot was accessed.

Times are monotonic seconds from production shell setup to first drawn menu. Engine/script bootstrap and diagnostic setup before that point are excluded. These are observations, not a statistical performance guarantee.

| Saved-slot menu | Before fresh | After fresh | Before warm | After warm |
|---|---:|---:|---:|---:|
| Catalogue-only tracing | 18.672 | 7.924 | 0.223 | 0.207 |
| Uninstrumented production | 15.968 | 7.970 | 0.232 | 0.203 |

The uninstrumented pair improved by **7.998 s**. Variation in the initial load explains why the traced pair has a larger total difference; the second baseline load is the direct evidence of the removed duplicate cost. No faster warm fingerprint algorithm is claimed.

## Gameplay behavior and remaining costs

These post-change native probes use production requests, immediate New Run confirmation when applicable, real gameplay construction and production Save & Exit between warm repeats. First drawn and usable frames were measured separately. Warm gameplay saves include the few intervening simulation frames.

| Request after launch menu | Synchronous return | First draw | Usable frame |
|---|---:|---:|---:|
| New Run, saved-slot fresh process | 23.083 | 23.611 | 23.622 |
| New Run, warm repeat | 18.963 | 19.080 | 19.095 |
| Continue, fresh process | 10.814 | 11.223 | 11.232 |
| Continue, warm repeat | 8.218 | 8.252 | 8.259 |
| New Run, empty-slot fresh process | 27.360 | 27.550 | 27.562 |

The empty-slot menu drew in **0.168 s**, with Continue disabled. Its New Run performs the initial catalogue acquisition during gameplay startup. Both New Run paths produced **85 stored / 85 physical items**, unpaused and without initialization errors. Continue restored **83 stored / 100 physical items**, unpaused and without initialization errors. The pre-change diagnosis's same-candidate gameplay timings remain supporting historical evidence, not new before measurements: New Run usable approximately 20.7–21.9 s fresh / 18.5 s warm, Continue approximately 10.4–14.6 s fresh / 8.1 s warm. The current samples do not establish a gameplay-transition improvement.

**Remaining startup costs are explicit:** the first full catalogue load still costs about **7.5 s** in the corrected saved-slot trace. Wing scene resource loading/instantiation, transformed-vertex bounds scans, twelve-manifest cargo preflight, item placement and snapshot/Receiving visual reconstruction remain. The preserved diagnosis attributed about **6.5 s** to fresh wing load/instantiation, **11.4 s** to New Run preflight, **12.8 s** to New Run root geometry scans and **3.1 s** to Continue restoration; preflight and scan durations overlap and must not be added. Those component figures were not reprofiled here. Save work remains unchanged. No geometry, cargo, scene, renderer or warning optimization was made.

## Focused regression evidence

All successful checks below exited **0** with zero failures. Full console/engine logs were inspected; they contain no script, assertion, warning or leak diagnostics. No broad project-suite or human input/audio acceptance claim is made.

- New committed `snapshot_catalogue_tests.gd`: **6 checks**, retaining the catalogue after the first fingerprint, detecting an in-memory physical change, restoring the exact hash and recomputing across instances. Before production editing it exited **1**, with only the expected retention assertion failing.
- External production save compatibility probe: **32 checks before and 32 after**. Identical schema-4 load, schemas **1/2/3** rejected, changed fingerprint and actual physical-content changes rejected, duplicate ownership/unowned items rejected, invalid receipt Bulk and live-item receipt identity rejected. Every invalid save attempt preserves all original copied slot bytes; every invalid read preserves its fixture pointer and snapshot bytes.
- Existing M4 snapshot writer, copied externally with only its hardcoded OUTPUT changed: **27 checks**. Separate process reader: **21 checks**. Partial, mixed open/terminal, cutoff and report states restore exactly, including physical ownership, receipts, clock, storage, ladder and Receiving; Continue does not replay issuance/spends.
- Existing locked M4 baseline test: **167 rows**, zero failures.
- Seven native probe invocations passed, including two before and two after menu samples, New Run/warm repeat, Continue/warm repeat and empty-slot New Run.

Exact fingerprint before and after:

```text
05fe898ff3e0535e7a8856d36c42827bd5235718c929e11e9ce8481d485093c9
```

The initial external harness preparation duplicated an optional flag; that was corrected externally before native benchmarking. One initial compatibility attempt exited at its profile isolation guard (**4**), accessed no save and is retained as failed preparation evidence. Neither is counted as a successful check or a measured launch.

## Preservation and reproduction

External evidence: `C:/Users/Boschetar/.codex/attachments/m4-catalogue-reuse-2026-10-25/`. `COMMANDS.txt`, `run-probe.ps1` and `run-final-checks.ps1` record commands, profiles and destinations. `native-results.json`, `focused-results.json`, `diagnosis-source-match.json`, `preservation-before.json` and `preservation-after.json` hold measurements and audits; raw logs and all external probe scripts remain beside them. Existing evidence was not overwritten.

The final inventory checked **17,123 existing source, resource, asset and sidecar files**: the only changed existing file is `gameplay/run/run_snapshot.gd`; nothing is missing. The original **17 untracked sidecars** remain untouched and are excluded from this commit. Worktree registration and all other worktrees were unchanged before this local commit. The source review snapshot remains SHA-256 `9028ea7e310a71fe2cba75f4ea82bd395687f7871bebeb0cab67e8cdfea74e0d`. New files are limited to the focused test and this validation record. No accepted data, authored resources or existing saves were modified.

One consolidated read-only review of this correction and its evidence found no actionable issues and approved local commit of these three paths only. It did not grant wider M4 acceptance. Final git diff --check passed; no task-owned Godot process remained.
