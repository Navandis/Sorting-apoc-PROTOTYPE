# Pre-M4 catalogue first pass — 20 October 2026

Current acceptance is recorded in the [21 October final human acceptance addendum](#21-october-2026--final-human-acceptance-and-record-reconciliation); the later [publication close-out](#21-october-2026--publication-authorization-and-documentation-close-out) records authorization and verification boundaries. Earlier pending statements below are dated history, superseded only by those explicit decisions.

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

## 21 October 2026 — human checkpoint, uniform scale and folded clothing follow-up

**HUMAN AUTHORING CHECKPOINTED / FIVE SCALE ITEMS PENDING HUMAN RE-REVIEW / NOT PUBLISHED.** Focused implementation is delivered locally. The developer subsequently confirmed the five changed source GLBs were intentional and included in the completed physical review; their source-fingerprint reconciliation is now complete. **150 reviews are current; only the five post-scale physical reviews remain pending.** No milestone promotion or final post-scaling physical acceptance is claimed.

Checkpoint **`170ea013dec7e9cc463173bba78759d5cd16fcbc`** contains exactly the developer's **152 modified ItemDefinition `.tres` files**, from the reported comprehensive review of all **155** active items. Preflight found the requested branch at `5faa40baea44bdedef8b06447b244e05402fc4c5`, no running Godot process and no other working-tree changes. Live remote `main` was verified at `53805a97ec43455920e3ceffb6f7acd98001f5b6` using a per-command OpenSSL backend after Windows Schannel refused the initial read. Staged blobs, committed blobs and working-file SHA-256 values all preserved the original bytes; the checkpoint left a clean tree. No other worktree was modified.

The second commit adds `ItemDefinition.visual_scale`, default **1.0**, and an idempotent geometry transform. It retains each original `visual_scene` GLB path, preserving catalogue, raw-host registration, source fingerprint and onboarding identity. Tracked data stores **1.5** for `loot_000025` and **1.2** for `loot_000027`, `000075`, `000129`, `000141`. This is independent of ignored import metadata and licensed binaries. Uniform scaling feeds loose/world registration before pickup-collider construction, shared storage measurements, committed/ghost/restored storage poses, Receiving measurement/materialization, held and HUD pre-fit bounds, and the actual pose workbench. Existing freight preview and temporary physics-proof hull construction consume the same factor. `@tool` permits the resource helper in editor previews; live workbench refresh includes scale. Snapshot content fingerprints include the factor, retaining explainable incompatible-save rejection. Existing HUD framing, held fitting, Front, pose, Footprint, stack/support flags, Utility, Bulk and carrying capacity are preserved.

All **155** definitions were compared against the immutable checkpoint: **146** remain byte-identical, and the other **9** differ only by their one added scale/group property line. Every pre-existing authored byte remains intact. No source assets, saves, catalogue entries, retirements, inflow schedules or other worktrees were changed. Counts remain **155 active / 7 retired / 162 source models**; the production recurring pool remains the same 35 retained members.

### Measured scale consequences

Bounds below are authoritative runtime-renderable canonical posed **X × Y × Z**, in millimetres, rounded for display. `scaled-items.json` retains the full precision and pre-correction bounds. Clearance includes the existing 6 mm seating gap. Each affected item completed real pickup, placement and retrieval on production surface `SM_MetalShelves_GalleryA_West_level_1`, with **0.82 m** clearance. Mechanical reservation success does not certify horizontal containment.

| Item | Uniform factor | Posed bounds, mm | Saved Footprint | Suggested Footprint | Required clearance, mm |
| --- | ---: | --- | --- | --- | ---: |
| `loot_000025` | 1.50 | 94.234 × 127.554 × 94.215 | 1 × 1 | 1 × 1 | 133.554 |
| `loot_000027` | 1.20 | 105.225 × 167.451 × 105.291 | **1 × 1** | **2 × 2** | 173.451 |
| `loot_000075` | 1.20 | 122.366 × 199.874 × 122.366 | 2 × 2 | 2 × 2 | 205.874 |
| `loot_000129` | 1.20 | 131.040 × 197.065 × 131.040 | 2 × 2 | 2 × 2 | 203.065 |
| `loot_000141` | 1.20 | 62.142 × 132.607 × 42.194 | 1 × 1 | 1 × 1 | 138.607 |

**`loot_000027` is an explicit pending Footprint correction/override decision.** Its new X/Z dimensions exceed its reservation by **5.225 / 5.291 mm total**, approximately **2.612 / 2.646 mm per centered side**. The workbench warning is verified. Its 1×1 Footprint was not silently enlarged; shelf insertion under existing abstract reservation rules is not presented as accepted safe packing. The other four scaled items remain inside their saved horizontal reservations. All five scale/pose/Footprint and geometry-dependent role/group review stages remain `UNREVIEWED` pending the developer's post-correction inspection.

### Group and review reconciliation

The existing registry now contains approved class **`folded_clothing`**, description **"Folded clothing"**, compatibility revision **1**, assigned to exactly **`loot_000152`–`loot_000155`**. Their saved physical authoring is unchanged. Actual controller insertion forms one mixed stack containing all four, with top **0.243148 m** in the 1.5 m clearance fixture. Negative cases exercise an unrelated group, incoming resting-role refusal, a non-supporting same-group singleton, oversized horizontal fit and clearance refusal with exact carried-item retention. Production-shelf handoffs also cover all four individually.

The rendered stack is a technical contact aid, not final aesthetic approval. Preserve and inspect the existing soft-clothing overrides: **154** measures **0.348588 m** X and **155** measures **0.359252 m** X against their approved **0.300 m** reserved width; both suggest 4×4 while retaining saved 3×4. Their new group records disclose these overhangs and recommend visual review of contact and adjacent packing. No supporting flag or Footprint was changed to force the stack. The slightly irregular cloth contours still warrant the requested relationship/aesthetic follow-up.

Existing manifest schema **2.0** and its dependency/approval helpers were reused against the actual external definitions. Inventory proposal fields, source identities, flags and the seven retired review records are retained; current saved values and dated checkpoint provenance are recorded separately. The five confirmed source fingerprints and their source-change flags are updated, with former hashes and flags retained in explicit `human_review.source_confirmation` history and prior review notes. `loot_000019` now uses the developer's saved **"Cola Can"** name; its Hydration +3 and other utility data are untouched. The command regression uses an isolated copy of the old 3×3 armour fixture rather than reverting the developer's current Footprint. Pickaxe **`loot_000108` / `SM_Pickaxe_03.glb`** retains its unresolved co-located-LOD representation flag and notes; comprehensive physical review is not treated as explicit representation resolution.

**Pre-existing source discrepancy resolved by explicit developer confirmation on 21 October:** current GLB SHA-256 values differed from recorded inventory fingerprints for **`loot_000008`, `000009`, `000010`, `000043`, `000044`** (`SM_Dry_Goods_01a`, `01c`, `01g`, `01h`, `NN_01a`). File timestamps predate this execution. The initial delivery retained the old hashes and blocked onboarding; the developer then explicitly confirmed these current GLBs were intentionally updated and included in the completed physical review. The five current hashes and dependent review snapshots have now been reconciled through the existing approval helpers. Both old and accepted hashes remain recorded in source-confirmation history and external `source-fingerprint-mismatches.json`. Source files and all `.tres` files were unchanged during this metadata reconciliation. Counts are now **150 current reviews / 5 pending post-scale reviews / 0 pending source confirmations**. The other 150 physical definitions require no blanket re-review. The second local commit is amended to retain the requested two-commit structure; checkpoint `170ea01` remains immutable.

### Targeted verification and reproducibility

Engine: `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`, **4.7.stable.official.5b4e0cb0f**, Compatibility. Engine runs were serial. All save/continuation writes used explicitly injected paths below the new external evidence root; the developer's active continuation was not read, migrated, modified or deleted.

| Proof | Result |
| --- | --- |
| Catalogue | Exit 0; 155 active, 7 excluded/retired, unique source/ID mappings, allocation reservations and 35-member normal pool retained. |
| Follow-up scale/group probe | Exit 0; exact five factors from real bounds, actual workbench rendered geometry/warning, held/HUD pre-fit bounds, idempotent raw GLB registration, pickup collider, store/retrieve, temporary physics hull factor and scale-sensitive snapshot fingerprint. |
| Production physical owner, `--followup` | Exit 0; all 9 changed definitions complete pickup/store/retrieve, 0 mechanically incompatible production surfaces; explicit containment results disclose 027/154/155 overhang. |
| Receiving owner, `--followup` | Exit 0; 3 exact mixed manifests, 12 progressive production-ray TAKEs and 12 production-shelf handoffs/retrievals; 0 identity-loss or surface blockers. |
| Rendered follow-up | Exit 0; Compatibility GPU run and actual four-member stack captured as `folded-clothing-mixed.png`; no final human acceptance inferred. |
| Storage owners | Stack rules, stack clearance, actual stacking interaction and command validation all exit 0. |
| Medical / Kitchen / M3 schedule / contribution | Exit 0; respectively **24 / 69 / 43 / 24** checks, zero failures. |
| Persistence / separate continuation writer / reader | Exit 0; respectively **26 / 7 / 18** checks, zero failures. |
| External authoring roundtrip / editor scan / current audit | Exit 0; saved/reopened isolated definition, normal editor scan, and 35-source current main-scene audit. Audit posed bounds include authored scale and expose `visual_scale`. |
| Onboarding dry-run and `--apply` | After explicit source confirmation, **both exit 0**, **0 additions / total 155**. All **158** protected definition/catalogue/manifest/inventory hashes remain unchanged by both runs. Successful onboarding/idempotence is verified; the initial stale-source refusal logs remain historical evidence. |

The **21 selected final logs all exit 0** after source confirmation. Catalogue, current audit and both onboarding modes were refreshed; the other 17 passing runs are reused from the same geometry/gameplay state because this confirmation changes review metadata only. Script errors/assertions/leak signatures were checked independently of completion markers: **zero** in the selected final logs. The known Windows certificate-store diagnostic remains disclosed. Existing CF-07 material-null debt was neither suppressed nor repaired; it was not emitted by this rendered follow-up. Initial red checks, stale test expectations, failed helper attempts and initial exit-1 stale-source refusals are retained separately and do not support passing claims.

External evidence root: `C:/Users/Boschetar/.codex/attachments/pre-m4-followup-2026-10-21`. It contains the immutable file/hash inventory and diff, `checkpoint-paths.txt`, both commit file lists, `definition-preservation.json`, `scaled-items.json`, `clothing-stack.json`, `physical-results.json`, rendered stack, source discrepancies, exact regression runner/commands and `final-results.json` with individual diagnostics. `source-confirmation/` retains the prior partial state, explicit five-source reconciliation evidence and refreshed logs/hash-preservation checks. Final commit SHA/file-list evidence is external to avoid a self-referential commit hash in this document.

Core focused commands, from the project root:

```powershell
$engine = 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe'
$evidence = 'C:/Users/Boschetar/.codex/attachments/pre-m4-followup-2026-10-21'
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_followup_tests.gd -- "--evidence-dir=$evidence"
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_physical_tests.gd -- --followup "--evidence-dir=$evidence"
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_receiving_tests.gd -- --followup
& $engine --headless --path . --script res://tools/asset_pipeline/tests/pre_m4_catalogue_tests.gd
& $engine --headless --path . --script res://tools/asset_pipeline/onboard_props.gd -- --apply
```

For a new continuation reproduction, use a **fresh external directory**, writer followed by reader, with the established `pre_m4_continuation_tests.gd -- --evidence-dir=... --mode=write/read` arguments. The external `run-regressions.ps1` records the remaining owner commands. No new normal-scenario loot, Utility/Bulk calibration, Dispatch/M4, merge, push, PR or publication was performed.

**Human handoff:** reopen `res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn`, select its root, and assign each external `res://data/items/definitions/loot_000025.tres`, `000027.tres`, `000075.tres`, `000129.tres`, `000141.tres` in turn. Inspect corrected scale, canonical +Z Front, resting pose, saved versus suggested Footprint, and stack/support suitability; use Packing Rotated only as a preview. Resolve 027's explicit 1×1 versus 2×2 decision, save any deliberate edits to the external resources and reopen them. Report final acceptance before later reconciliation/publication authorization. Inspect the actual folded-clothing stack for soft contact/overhang aesthetics without a blanket re-review of other items. The separate five-source confirmation is complete and requires no further source decision.

## 21 October 2026 — final human acceptance and record reconciliation

**PRE-M4 PHYSICAL AUTHORING HUMAN-ACCEPTED / RECORDS RECONCILED / LOCAL CANDIDATE READY FOR PUBLICATION DECISION / NOT PUBLISHED.** Current dependency validation supports **155 current physical reviews / 0 pending**, with **155 active / seven retired**. This supersedes the preceding post-scale/Footprint handoff; it does not resolve the separate pickaxe representation caveat or authorize publication.

### Human decisions and retained exceptions

Authority is the developer's explicit final instruction supplied for this reconciliation, following comprehensive physical review of all 155 items. The developer separately visually reviewed and accepted **025 at 1.50×** and **027 / 075 / 129 / 141 at 1.20×**, reporting no outstanding visual inconsistencies. The five scale, pose/Front, Footprint and geometry-dependent stack/group records now approve the actual saved values and current source fingerprints. This is recorded human acceptance; the executor's measurements do not provide visual approval.

The developer also explicitly directs retention of these authored Footprints:

| Item | Retained Footprint | Current geometric difference / accepted disposition |
| --- | --- | --- |
| `loot_000027` | **1 × 1** | Posed X/Z **105.225 / 105.291 mm** against **100 / 100 mm** reservation. The suggested **2 × 2** is not approved. Centered overhang approximately **2.612 / 2.646 mm per side** is knowingly accepted. |
| `loot_000154` | **3 × 4** | Folded-clothing width **348.588 mm** against **300 mm** reservation. Suggested **4 × 4** is not approved; soft-clothing overhang accepted after human visual review. |
| `loot_000155` | **3 × 4** | Folded-clothing width **359.252 mm** against **300 mm** reservation. Suggested **4 × 4** is not approved; soft-clothing overhang accepted after human visual review. |

These remain geometric deviations, recorded as **OVERRIDE_APPROVED** with explicit final notes. General bounds/Footprint warning logic remains unchanged. The approved `folded_clothing` revision 1 membership is still exactly **152–155**, with all saved stack/support decisions intact. Human acceptance includes the three exceptions; it does not assert every hypothetical neighboring placement was visually tested.

### Bounded reconciliation and preservation

Read-only preflight found clean `codex/pre-m4-catalogue-expansion` at **`fe85aa902d0a61dc15cfbaf644ed9ef5166f0e14`**, with immutable developer checkpoint **`170ea013dec7e9cc463173bba78759d5cd16fcbc`** in its ancestry, and no running Godot process. Live remote `main` was read at **`53805a97ec43455920e3ceffb6f7acd98001f5b6`** through per-command OpenSSL. No reset, amend, rebase or other worktree change was used.

The existing schema 2.0, `apply_scale_review_reconciliation`, `stack_role_snapshot`, `apply_auto_group_approvals` and `review_evidence` helpers were reused. Only the five explicitly accepted post-scale items enter approval helpers; no blanket reapproval was performed. Manifest/inventory changes affect **seven item records**: the five final post-scale approvals, plus final Footprint/group notes on already-current 154/155. Of the other 150 current reviews, **148 are entirely unchanged and two retain identical approval snapshots/statuses with appended decision notes only**. All seven retired records, prior notes/fingerprints, original proposal fields/flags and the accepted five-source confirmation history remain intact. Original inventory proposal flags are explicitly historical; current state comes from `review_status`, `human_review` and the existing review manifest.

All **155 external ItemDefinition files and 162 source models are unchanged**. Tracked-file hash comparison permits only the two review/evidence JSON files, this validation record and a bounded test correction. The current-registry test still expected four classes despite the already-approved fifth class: its exact production expectation now requires five classes including `folded_clothing`. No production code, definition, registry, visual scale, pose/Front, Footprint, stack/support role, group membership, Utility/Bulk, production manifest or scene was changed. Earlier implementation/checkpoint commits remain intact; this reconciliation is a new local commit, whose exact SHA/diff are recorded externally to avoid a self-referential hash here.

### Fresh focused checks versus reused technical proof

Fresh evidence root: `C:/Users/Boschetar/.codex/attachments/pre-m4-final-human-acceptance-2026-10-21`. Engine **4.7.stable.official.5b4e0cb0f**, Compatibility; executions were serial. Every engine process redirected `APPDATA` and `LOCALAPPDATA` to that root's isolated `runtime-profile`; these focused checks neither instantiate the continuation service nor access the developer's active save.

| Newly executed focused check | Result |
| --- | --- |
| Current catalogue/review/geometry reconciliation probe | Exit 0; **155 current / 0 pending / seven retired**; all five review stages current per active item, no stale/dependency contradictions, all 155 source hashes and group references current. Fresh posed bounds for the seven affected items confirm actual saved scales/Footprints and all three retained deviations. Exact five registry classes/revision 1 and four clothing members confirmed. |
| `pre_m4_catalogue_tests.gd` | Exit 0, zero failures; **35 retained + 120 additions**, seven exclusions, 162-source accounting, identity reservations and unchanged 35-member production pool. |
| `authoring_review_manifest_tests.gd` | Exit 0; PASS with no script/assertion errors. |
| `auto_stack_group_registry_tests.gd` after expectation correction | Exit 0; PASS with no script/assertion errors; current five-class registry verified. |
| Onboarding dry-run and `--apply` | Both exit 0; **0 additions / total 155**. |
| Current main-scene audit | Exit 0; **35** retained scene sources audited. |
| Preservation comparison | **155 definitions / 162 GLBs unchanged**; all proposal/source-confirmation history, 148 unrelated active review records and seven retired records preserved. Across focused engine checks, all **158** protected definition/catalogue/manifest/inventory hashes unchanged. |

`final-results.json` selects the seven passing final runs and preserves exact commands, completion markers, exit codes and diagnostics. `verified.json` retains current full-precision measurements; `preservation-results.json` and `checks-preservation.json` record the comparisons. The external `reconcile.gd`, `apply.cjs` and `verify-preservation.cjs` are bounded execution evidence using the existing review system, not a new tracked review-state system. `run-focused.ps1` and `focused-results.json` preserve execution history. The first candidate's raw-versus-normalized JSON comparison failure and the stale four-class assertion (which misleadingly emitted PASS/exit 0) are retained separately as failed attempts, not passing evidence; the runner checked script/assertion output as well as exit status.

The final selected logs contain **zero script errors, assertion failures or leak signatures**. Each discloses the known Windows certificate-store diagnostic. CF-07 remains separate known debt; it was not emitted by these focused checks and was not suppressed or repaired.

**Attributed historical proof, not rerun here:** the preceding 21 October follow-up's actual workbench/scale probe, nine-item production physical check, three Receiving manifests / 12 TAKEs and handoffs, rendered four-member clothing stack, storage owners and persistence/separate continuation writer/reader (**26 / 7 / 18 checks**) remain the same-production-code and same-geometry evidence. Their logs remain under `pre-m4-followup-2026-10-21`, with source-confirmation refreshes identified there; the original full 120-item sweep remains dated 20 October. This reconciliation changed review metadata/documentation and one verification expectation only, so it did not repeat those physical/Receiving/continuation sweeps or relabel them as fresh.

**Retained caveat and stopping point:** `loot_000108` / `SM_Pickaxe_03.glb` still has its co-located-LOD representation flag, notes and `UNRESOLVED_LOD_REPRESENTATION` status. The final Footprint decisions do not resolve it. The candidate is ready for a separate developer publication decision with this disclosed caveat and existing diagnostic debt; no merge, push, PR, publication, cleanup, save migration or M4 work is included.

## 21 October 2026 — publication authorization and documentation close-out

The developer now explicitly authorizes fast-forward integration and a normal non-force push of the accepted history to `origin/main`. **HUMAN-ACCEPTED / CLOSED IN PHYSICAL SCOPE** applies to the physical catalogue. **PUBLISHED applies only after an independent post-push live remote read matches final local `main`**, recorded in the executor's final report and external `publication-result.json`; the documentation commit does not claim its own future SHA or a push not yet verified.

Read-only preflight independently found clean `codex/pre-m4-catalogue-expansion` at accepted candidate **`6040edeec9884b5a31ef88e368be124b85388deb`**, with exact linear ancestry **`53805a9 → 5faa40b → 170ea01 → fe85aa9 → 6040ede`**. Both starting local `main` and independently queried live remote `main` were **`53805a97ec43455920e3ceffb6f7acd98001f5b6`**. No other worktree owned `main`; four other worktrees remain intact. Integration preserves every accepted commit and adds only this same-edition documentation close-out.

**Acceptance carried forward:** **155 active = 35 retained + 120 additions; seven permanent retirements; 162 source models retained on disk; 155 current physical reviews / zero pending.** The accepted five scales, three Footprint overhang exceptions and exact 152–155 `folded_clothing` membership remain as recorded above, with general warnings and physical eligibility rules intact. Separately confirmed source changes 008/009/010/043/044 retain old/current fingerprints and provenance. `loot_000019` is now **Cola Can**, retaining Hydration +3; its former name debt is resolved. Gloves/Pants 034/036 remain retired, not repaired. Pickaxe 108's co-located-LOD caveat, CF-07 and certificate-store diagnostics remain disclosed.

**Evidence attribution:** the accepted reconciliation's scoped four-file diff and seven passing focused results were inspected from the retained Git/evidence record. Its physical/Receiving/continuation evidence remains attributed to the earlier executor, with the 20/21 October scope distinctions above. No Godot/gameplay, import, save/load or fresh physical regression was run for publication. A read-only extraction independently matched all 155 saved definitions to their current review snapshots/source hashes, verified all 162 source hashes and seven retirement exclusions, and confirmed 155 current / zero pending records. Existing posed dimensions are reused with units/source provenance, not presented as fresh measurement.

**Documentation checks:** Systems MVP **v0.4** DOCX was edited first; its same-stem Markdown was regenerated through the existing extractor. ZIP/XML and internal relationships validate; all **36 tables** and body/table text parity are checked. Only the document body and dated footer XML change inside the package; styles/settings/media/relationships remain intact. All CF-01–CF-24 obligations and numerical design tables remain; §§18–19 are verbatim. The available Documents renderer / installed LibreOffice produced **45 pages** at 110 dpi (previously 44); the reader page guide was updated. Final page PNGs were visually inspected for clipping, wrapping, tables, glyphs and footer/page numbering. Native Microsoft Word rendering was not separately tested. Relative documentation links and anchors were checked.

**Next stage only:** Utility/Bulk calibration covers retained items and additions. New-item None/0 Utility and Bulk 1, existing Utility and current player capacity **10** are unchanged. Player Bulk **15** is an approved later target, not implemented. Per-scavenger **25** Bulk and **5/6/3/4/4** requirements remain earlier provisional references to recheck, not shipped M4 values. The normal recurring M3 pool remains the retained **35 items** with approved placeholder substitutions; controlled addition tests are not normal inflow. M1/M2/M3 remain closed; M4 Expedition Loadout/Dispatch and final economy validation remain unimplemented.

External evidence and read-only calibration handoff: `C:/Users/Boschetar/.codex/attachments/pre-m4-publication-2026-10-21`. `catalogue-active-155.json` / `.csv` derive current names/category/primary and contextual Utility/Bulk/scale/source/Footprint/pose/roles/group from final `.tres` values and unchanged script defaults, with attributed current dimensions. `retired-items.json` lists retired IDs separately. Data source revision is `6040ede`; the external publication result supplies the final documentation/local/remote SHA after verification. No value is assigned by this export. The publication commit is limited to this record, the v0.4 DOCX/companion and three operational pointers; no runtime/test/data/asset/scenario change, source cleanup, branch deletion, worktree cleanup or PR is included.
