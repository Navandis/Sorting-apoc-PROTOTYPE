# Pre-M4 catalogue first pass — 20 October 2026

**CATALOGUED / TECHNICALLY CHECKED / HUMAN PHYSICAL REVIEW PENDING.** This implements the developer-approved first pass only. It does not approve physical proposals, calibrate Utility/Bulk, implement Dispatch/M4 or promote a milestone.

## Scope and preservation

Base: `53805a97ec43455920e3ceffb6f7acd98001f5b6`; feature branch `codex/pre-m4-catalogue-expansion` in `D:/Godot Projects/Sorting-apoc-PROTOTYPE`. Preflight found clean `main`, the reported baseline at HEAD, four other worktrees and no running Godot process. The asset-equipped authoritative checkout is used on a separate feature branch; no other worktree was changed. No reset, stash, clean, source-asset deletion, renderer/version change, merge, push or PR. Git branch/index/commit writes require the sandbox override because `.git` is read-only in the workspace policy.

External evidence: `C:/Users/Boschetar/.codex/attachments/pre-m4-2026-10-20`. The actual developer save slot was never read or changed. Engine: `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`, `4.7.stable.official.5b4e0cb0f`, Compatibility. Engine executions are serial.

## Exact inventory and dispositions

| Disposition | Count |
| --- | ---: |
| Retained definitions | 35 |
| New first-pass candidates | 120 |
| Authorized retirements | 7 |
| Active catalogue | 155 |
| Source models accounted for under `assets/props` | 162 |
| Missing retained sources / changed retained fingerprints | 0 / 0 |
| Technical geometry/storage/Receiving blockers found | 0 |
| Representation uncertainty flagged for human review | 1 pickaxe |

The exact ID/source/fingerprint, source transforms/dimensions, mesh nodes, category, proposed identity/name, scale/pose/stack/group rationale and individual flags are in `tools/asset_pipeline/props_inventory.json`. The 120 new IDs run from `loot_000043` through `loot_000162`. All supplied GLBs embed their image dependencies; no GLB supplied copyright/license metadata. Adjacent PNG/JPG/import files are dependencies/source-library material, not additional loot. Existing commercial/local source boundaries remain; no redistribution rights are inferred.

`retired_items.json` permanently reserves the seven exact ID/path mappings and old allocation high-water 42. All seven GLBs and associated files remain on disk, explicitly excluded from onboarding; no recovery copy was needed because nothing was destructively removed. Their exact paths in that file are the manual cleanup list. Do not delete adjacent files by stem: external users of embedded/extracted materials and other importers were not ruled out.

All 35 retained definitions and review decisions are preserved. No retained item required source-invalidated physical review. Existing `loot_000019` name/Utility debt remains. The initial-42 migration tables and historical review records remain historical; closed executable fixtures now return `RETIRED_FIXTURE`/exit 2 instead of claiming a current PASS. Generic catalogue/seeder/manifest tests and current gameplay fixtures are adapted separately.

The canonical wing loses only `Medical_Painkillers` and `Weapons_TennisRacket` plus their visuals/resource declarations. Twelve nominated raw hosts are removed from legacy `main.tscn`. The small inherited seed fixture substitutes retained 007 for 005, 022 for 023 and 041 for 037, preserving host names and transforms. Starting stock becomes **44 items / 44 Bulk**, from 46/46; primary Food **51** and Hydration **20** remain unchanged. The removed palette items had no authored Utility. New-run M3 baskets substitute 007/022 and preserve each basket's ordered count, Food/Hydration totals and Bulk. New additions are absent from normal M3 events, starting supplies and the production recurring pool (35 retained members).

## Physical proposals and uncertainty

Scale → pose/front → Footprint → stack roles → group is preserved. No source transform normalization was performed. New Footprints use `StorageVisualPose` canonical bounds and the workbench's 0.10 m ceiling convention. Retained overrides are untouched. New items use temporary `None / 0` Utility and default Bulk 1, recorded explicitly in the inventory; player capacity remains 10.

Rigid flat packages/appliances, containers, loose food, rounded balls, clothing, long tools and instruments receive distinct pose/role proposals. Auto Group reuses only `round_cans` and `flat_media` where proposed; other additions have explicit None. Loaded crates, footwear pairs and folded bundles remain intentional single entities. Multi-mesh pasta jars are assembled glass/contents/lid, not unrelated example objects. `SM_Pickaxe_03.glb` contains three co-located named LOD meshes: one pickaxe candidate, with a representation-review flag; no mesh removal is authorized or performed. Visual credibility, label/face Front and contact stability still require human review. All five review stages for all 120 additions are `UNREVIEWED`; no automated result is human approval.

New proposals by category: Electronics 9, Food 25, Fuel 4, Hydration 10, Medical 4, Morale 15, Protection 20, Weapons 33. Stack roles: 15 can rest/support, 103 can rest but cannot support, 2 rounded balls deny both. Auto Group: 5 `round_cans`, 2 `flat_media`, 113 explicit None. Six clothing/instrument poses were refined after source previews to put their front/details upward. All are proposals, including semantic Front; human review can change them.

## Verification

| Focused proof | Result and practical limit |
| --- | --- |
| `pre_m4_catalogue_tests` | Exact counts, unique mappings, all model accounting, seven exclusions, retired-name fallback rejection, 35-member normal pool, reserved highest old ID 42 and higher historical allocation. |
| `pre_m4_physical_tests` | All **120** new sources instantiate with finite nonempty bounds, exact workbench Footprint convention, actual loose pickup, production-shelf store/retrieve and stable identity. **0** compatible-surface blockers. No requirement that every shelf fit every item. |
| `pre_m4_receiving_tests` | **30** bounded mixed exact manifests, **120** unique production-ray TAKEs and **120** shelf handoffs/retrievals; original reach, geometry and capacity retained. Six affected four-item manifests were rerun after pose refinements; the basketball's exact mixed manifest was rerun after its role correction. No item omission, shrink, substitution or reroll. |
| `pre_m4_relationship_tests` | Allowed heterogeneous new/retained flat-media and round-can stacks, denied rounded-ball role on otherwise large-enough support, narrow bottle support denial, category/General/erased zones, actual retrieval/base promotion. Existing stacking, orientation and storage-command suites also pass, including committed packing orientation and non-loss rejection. |
| `pre_m4_authoring_tests` | Actual workbench scene loads a new external `.tres`, live pose edit refreshes, suggested Footprint and stack/group edits save externally, reopen and preview; production proposal hash unchanged. GPU capture uses transient camera/light because the editor workbench has no gameplay camera. |
| `pre_m4_continuation_tests` | Separate writer **7 checks**, reader **18 checks**, zero failures after metadata stabilized. Production external save service and Continue preserve an eight-item mixed commitment, remaining cargo/identities, normal 10-Bulk capacity, A ownership through full outbound and FIFO B activation; reader takes all eight once. Whole-catalogue content mismatch still rejects explainably. |
| Medical/Kitchen owners | Kitchen **69**, schedule **43**, contribution **24** checks, zero failures. All **12** substituted exact M3 baskets / **192** progressive TAKEs pass (**2221** checks). |
| Rendered M3 | **50 checks / zero failures**, both resolutions, F/E/ESC/modal/selection behavior, full-lane non-loss rejection, report and actual injected Save/Continue. Synthetic engine input; no native keyboard or human physical acceptance is claimed. |
| Affected reusable owners | Catalogue unit/seed coverage/seeder/manifest, curated pool/source, freight-fixture runtime, seed fixture, startup parity, Stage A synthetic boundaries, ladder, pose-workbench, wing storage bridge, and persistence (**26 checks**) pass. The bridge's observable packing test uses retained asymmetric firewood inside its disposable regression fixture; the production replacement hammer is correctly square and cannot exercise that invariant. Closed initial-42 fixture executables are deliberately retired, not passing current gameplay proof. |
| Rerun/import/current audit | Onboarding `--apply` produces **0 additions / total 155**, with all **158** definition/catalogue/manifest/inventory file hashes unchanged. Normal headless editor scan exits 0; current main-scene audit completes with 35 retained sources. The initial-seed historical executable returns the explicit retired marker and expected exit 2. |

Raw commands/results are in `run-focused.ps1`, `focused-results.json`, `run-corrections.ps1`, `correction-results.json` and the final log/result inventory under the external evidence root. Failed attempts are kept separate: initial retirement/pool red checks; a private-deck counting mistake; missing inherited reach-case fields; an initial shell argument-packing mistake; old fixture expectations; a fixed 20-second continuation wait that was correctly rejected before B fully OPEN; and the basketball-role regression red. Corrected completions, not these attempts, support the table. No unfamiliar error is classified as accepted debt.

The single contextual read-only review found a missed Stage A 42/40 boundary assertion, a truncated propane name, and a relationship assertion that could pass by size instead of role. All three were corrected with focused affected checks. The reviewer independently confirmed all 162 paths/fingerprints, all 42 original historical review records, all 35 surviving definitions, unrelated wing-node preservation and controlled-only new content. Semantic Front/contact stability/scale credibility and pickaxe representation were explicitly left for human review, not approved.

Known diagnostics remain disclosed: `Failed to read the root certificate store` at `platform/windows/os_windows.cpp:2582`; rendered M3 emits **36** existing CF-07 `Parameter "material" is null` messages (console count, not double-counted engine copies) at GLES3 material-storage functions `material_casts_shadows:2592`, `material_is_animated:2579`, `material_get_instance_shader_parameters:2618`, and `material_update_dependency:2630`. No diagnostic suppression or renderer repair was introduced. Expected synthetic duplicate-catalogue and invalid seed-declaration rejection diagnostics are retained with their test logs. Final selected logs contain no script errors, assertion failures or leak signature.

Visual evidence: external `proposals-00.png` … `proposals-07.png` cover the proposed catalogue; `sources-00.png` … `sources-07.png` are earlier imported-source diagnostics. `workbench-external-roundtrip.png` shows the reopened isolated edit. The first camera-less capture is explicitly retained as `workbench-no-camera-attempt.png`, not usable visual proof. Actual controller-committed new/retained stacks are captured in `new-vhs-retained-cd.png` and `new-food-can-retained-soda.png`; they were visually inspected for centered contact/seating. `m3-rendered/` contains the focused UI captures. These are technical/review aids, not human physical approval.

Reproduce focused commands from the project root (PowerShell):

```powershell
$engine = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
$evidence = 'C:/Users/Boschetar/.codex/attachments/pre-m4-2026-10-20'
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_catalogue_tests.gd
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_physical_tests.gd -- "--evidence-dir=$evidence"
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_receiving_tests.gd
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_continuation_tests.gd -- "--evidence-dir=$evidence/new-continuation" --mode=write
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_continuation_tests.gd -- "--evidence-dir=$evidence/new-continuation" --mode=read
```

Run serially and use a new external evidence directory for fresh verification. The saved `final-results.json` enumerates 34 selected passing proof runs, their actual completion markers and diagnostics; onboarding/current-audit/explicit-retirement classification results are additional maintenance checks. `preservation-results.json` records the source/definition/review/scene comparisons. `base-to-final.patch`, `final-git.txt` and `SHA256SUMS.txt` are the external checkpoint package; the commit ID is recorded there to avoid embedding a self-referential hash here.

## Developer review in the existing workbench

1. Open `res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn` in the Godot 4.7 editor. Select the scene root; load the desired **external** `res://data/items/definitions/loot_000043.tres` … `loot_000162.tres` into **Item Definition**. Use the inventory to map IDs to source assets and prioritize flags/large items.
2. Inspect scale before editing pose. Leave the imported model transforms intact. Edit the external definition's **Storage Rotation Degrees** to get a credible resting pose and semantic Front facing canonical **+Z**. The preview refreshes from the actual resource; Packing Rotated is a separate preview, not a pose edit.
3. Compare the authored and suggested Footprint. **Apply Suggested Footprint** changes x/y only and preserves z and pose. Keep an intentional override where appropriate, and save the external `.tres` resource in the Inspector; saving only the workbench scene is insufficient.
4. In that same external definition inspect **Can Be Stacked**, **Can Support Stack**, and **Auto Stack Group** independently. An object that can rest on support may still have no credible supporting top. Empty Auto Stack Group means explicit None. Inspect real multi-item relationships in gameplay as needed: the pose workbench is not a complete stack simulator.
5. Reopen a saved item to verify persistence. Review the 120 candidates and flagged pickaxe representation; report any source/scale blocker rather than silently repairing art. Do not change temporary Utility/Bulk during this review.

Human decisions are not inferred from `.tres` saves. Subsequent reconciliation of actual saved values and decision provenance remains a separately authorized step after the developer reports review complete. Do not rerun machine proposals over human edits.

For an intentional future inventory rerun: `onboard_props.gd` defaults to validation/dry-run; `-- --apply` creates missing inventory definitions and review records only. It skips registered existing definitions, reserves retired paths/IDs, refuses stale sources and does not add items to production inflow. New/unaccounted files require explicit inventory proposals before application.
