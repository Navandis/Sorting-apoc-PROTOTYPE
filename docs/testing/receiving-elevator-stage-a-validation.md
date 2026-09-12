# Receiving / Elevator MVP — Stage A Validation

## Status
`STAGE A — TECHNICALLY VERIFIED; CLOSED`

Stage A is implemented and technically verified as of 2026-09-12. This is technical verification only, not a player-facing/human gameplay gate. Stage B has not started.

## Implemented boundary
- Durable externally supplied ItemInstance identity.
- LootBatch/LootBatchEntry content and atomic arrangement commitment.
- Exact 40-ID prototype pool; Gloves/Pants excluded.
- Seeded Bulk-budget PrototypeLootSource.
- FreightBayPresentationProfile schema only; no bay asset authored.
- Transient preparation job/diagnostic contracts only; no physics.
- ReceivingManager one-active/two-queued FIFO lifecycle.
- Variant-safe snapshot/reconstruction evidence.

## Explicitly not started
- Freight-bay scene/architecture assets.
- Hidden rigid-body settling.
- WorldItem materialization/Receiving pickup.
- FreightBayPresenter/shutter/cues.
- Stage B debug delivery UI.
- Stage C physical queue playtest.

## Verification

Verified in the authoritative local project, `D:\Godot Projects\Sorting-apoc-PROTOTYPE`, on branch `codex/receiving-elevator-stage-a`, using `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe` (reported version `4.7.stable.official.5b4e0cb0f`).

The final hardened implementation/test range is `137155868a089c5d45f0682f4cc26c518f1de385..d37c01113868417ecef854b77b4a9aaa211af6a1` (exclusive baseline, inclusive verified implementation head). Its first commit is `6270e064b81100d671f8975064300118117eeee3`; the range contains 13 commits, including the original closure record `17c306c0de10135dd82cdb1cf07b75c34b260b09` and the final-review fix `d37c01113868417ecef854b77b4a9aaa211af6a1` (`fix: harden receiving validation and test failure accounting`). This refreshed record is the subsequent documentation-only commit, `docs: refresh hardened receiving stage a verification`.

Fresh verification ran after the hardening commit on 2026-09-12: full regression from **15:52:53 to 15:53:42 +01:00**, then the main-scene audit and editor/parser/scope checks completed by **15:54:45 +01:00** (Europe/Dublin).

### Full regression

All **30 suites** (23 baseline plus seven Receiving suites) ran in filename order against the hardened commit. Every suite printed exactly one `PASS`, exited **0**, and emitted **zero `SCRIPT ERROR` or `FAIL:` lines**; the full PowerShell loop exited **0**. No deliberate harness-error injection remained in this run.

```powershell
$GODOT = 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe'
$testFiles = Get-ChildItem 'tools/asset_pipeline/tests/*_tests.gd' | Sort-Object Name
Write-Output "SUITE_COUNT=$($testFiles.Count)"
foreach ($test in $testFiles) {
    $suiteOutput = & $GODOT --headless --path . --script $test.FullName 2>&1
    $suiteExit = $LASTEXITCODE
    $suiteOutput
    $passCount = @($suiteOutput | Where-Object { "$_" -match '^PASS:' }).Count
    $scriptErrorCount = @($suiteOutput | Where-Object { "$_" -match 'SCRIPT ERROR|^FAIL:' }).Count
    Write-Output "SUITE_EXIT $($test.Name)=$suiteExit PASS_COUNT=$passCount SCRIPT_ERRORS=$scriptErrorCount"
    if ($suiteExit -ne 0 -or $passCount -ne 1 -or $scriptErrorCount -ne 0) {
        throw "Headless suite failed: $($test.Name)"
    }
}
```

| Suite (`tools/asset_pipeline/tests/`) | Exit |
| --- | ---: |
| authoring_review_manifest_tests.gd | 0 |
| auto_stack_group_registry_tests.gd | 0 |
| footprint_review_content_tests.gd | 0 |
| item_catalog_coverage_tests.gd | 0 |
| item_catalog_initial_seed_tests.gd | 0 |
| item_catalog_tests.gd | 0 |
| item_definition_seeder_tests.gd | 0 |
| item_interaction_reviewability_tests.gd | 0 |
| loot_audit_core_tests.gd | 0 |
| main_scene_loot_audit_integration_tests.gd | 0 |
| main_scene_pickup_registration_tests.gd | 0 |
| receiving_item_identity_tests.gd | 0 |
| receiving_loot_batch_tests.gd | 0 |
| receiving_manager_tests.gd | 0 |
| receiving_preparation_contract_tests.gd | 0 |
| receiving_prototype_loot_pool_tests.gd | 0 |
| receiving_prototype_loot_source_tests.gd | 0 |
| receiving_stage_a_integration_tests.gd | 0 |
| stack_role_authoring_tests.gd | 0 |
| stack_role_batch_tests.gd | 0 |
| storage_category_semantics_tests.gd | 0 |
| storage_pose_content_tests.gd | 0 |
| storage_singleton_clearance_tests.gd | 0 |
| storage_stack_clearance_tests.gd | 0 |
| storage_stack_rules_tests.gd | 0 |
| storage_stack_surface_tests.gd | 0 |
| storage_stacking_interaction_tests.gd | 0 |
| storage_unstacked_equivalence_tests.gd | 0 |
| storage_visual_pose_tests.gd | 0 |
| support_stacking_metadata_tests.gd | 0 |

### Final-review hardening and failure-path proofs

The original identity harness was reproduced with a temporary helper `assert(false, ...)`: Godot emitted an assertion script error, then the suite printed PASS and exited 0. All six focused Receiving suites now use explicit failed-check counts plus pending-helper accounting. Every test, fixture, and signal helper remains pending until its last statement or until its return value has been computed. A runtime-aborted nested helper therefore prevents PASS/exit 0 even when its caller resumes. Inspection found completion accounting in all 63 such helpers across the six suites.

Each suite was independently run with three temporary injections: `_check(false, ...)`, a raw `assert(false, ...)`, and an invalid array-index assignment. Every injected run exited **1** with **zero PASS lines**. The manager injection targeted its nested `_prepared_batch` fixture for `prepared_elsewhere`; assertion/runtime aborts left both the fixture and its interrupted caller incomplete. All injections were removed before the hardening commit and final regression.

| Focused suite | Failed check exit | Assertion-abort exit | Runtime-abort exit |
| --- | ---: | ---: | ---: |
| receiving_item_identity_tests.gd | 1 | 1 | 1 |
| receiving_loot_batch_tests.gd | 1 | 1 | 1 |
| receiving_prototype_loot_pool_tests.gd | 1 | 1 | 1 |
| receiving_prototype_loot_source_tests.gd | 1 | 1 | 1 |
| receiving_preparation_contract_tests.gd | 1 | 1 | 1 |
| receiving_manager_tests.gd | 1 | 1 | 1 |

Lifecycle TDD added the rejection tests before production changes. RED: `LIFECYCLE_RED receiving_loot_batch_tests.gd EXIT=1` (fresh empty commitment escaped; one failed check) and `LIFECYCLE_RED receiving_manager_tests.gd EXIT=1` (exhausted PREPARED deposits changed state in fresh and occupied managers; ten failed checks). GREEN after the two guards: `LIFECYCLE_GREEN receiving_loot_batch_tests.gd EXIT=0` and `LIFECYCLE_GREEN receiving_manager_tests.gd EXIT=0`.

Fresh commitment now requires a non-empty entry array. Already-drained PREPARED deposits are rejected before ownership/capacity mutation; the tests compare active/queue IDs, registrations, object references, batch bytes, and active/drained notifications. Legitimate fully released committed and PREPARED snapshots retain their item records and reconstruct byte-identically.

The misleading non-finite setter fixture was replaced with an actual snapshot-input rejection boundary. The finite dirty-presentation fixture now verifies its reconstructed input state before testing fresh normalization. A separate p95 test supplies 20 shuffled distinct durations from 10 to 200 ms and requires the nineteenth sorted observation, **190 ms**, so maximum or unsorted selection cannot satisfy it. Preparation contract GREEN exit: **0**.

The implementation plan's affected examples and validation guidance now require failure accounting, observed helper completion, non-empty fresh content, rejection of drained physical deposits, and preserved released-snapshot reconstruction. Its architecture, existing checkboxes, and Stage B stop remain unchanged.

### Fresh main-scene audit

```powershell
& $GODOT --headless --path . --script res://tools/asset_pipeline/run_main_scene_loot_audit.gd
if ($LASTEXITCODE -ne 0) { throw 'Main-scene loot audit failed.' }
```

Exit **0**. Exact completion evidence: `LOOT_AUDIT_COMPLETE assets=42 csv=res://reports/asset_pipeline/main_scene_loot_audit.csv json=res://reports/asset_pipeline/main_scene_loot_audit.json`.

The fresh JSON contains 42 assets. Both `stack_role` and `auto_group` summaries have total 42, approved/current 40, eligible 40, dependency-blocked 2, stale 0, unreviewed 0. The unchanged downstream-blocked cases are `loot_000034` (`Gloves 02glb`) and `loot_000036` (`Pants 02`). The integration suite separately asserts 42 real catalogue definitions and the exact ordered 40-ID pool.

The audit reads gameplay/Receiving data and regenerates its established CSV/JSON reports; those reports were unchanged. A subsequent `git status --short` was empty, and `git diff --exit-code -- data/items data/receiving receiving item_instance.gd tools/asset_pipeline/item_authoring_review.json reports/asset_pipeline` exited **0**. No gameplay definition or Receiving data was rewritten by this validation.

### Editor/parser and scope checks

```powershell
& $GODOT --headless --editor --path . --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot editor/parser scan failed.' }
git diff --check
if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }
git status --short
git diff --stat
```

Editor/parser exit **0**, with no GDScript parse errors. Diff check exit **0**. Before refreshing this record, status and tracked diff were empty after both audit and parser scan. No new UID sidecars or unexpected tracked/untracked files needed inclusion. The hardening commit changed only two Receiving runtime files, the six focused suites, and affected plan guidance. No assets, scenes, player/storage/WorldItem files, catalogue/pool data, physics, or presenter implementation changed in the fix wave. Final staged scope for the evidence refresh is this validation document only.

Godot emitted `Failed to read the root certificate store.` during these local runs. The negative catalogue tests also deliberately emitted duplicate-ID/visual-path diagnostics, including the Receiving source's invalid-catalogue fixture, and the storage clearance negative fixture emitted its missing-context fallback warning. All affected default suites printed `PASS` and exited 0, with no script errors or object/resource leak diagnostics. The separate deliberate assertion/runtime-abort probes emitted script errors; the manager's deliberately interrupted fixture also emitted leak diagnostics in those probe-only runs. Those probes are not part of the default final output. These observations do not establish network/TLS functionality and are not hidden as clean stderr.

### Reproducibility, identity, and lifecycle proof

The passing `receiving_stage_a_integration_tests.gd` uses the real catalogue and pool `prototype_receiving_pool`, revision **1** (source reference `prototype_receiving_pool:1`). Fixed content seed: **1842**; presentation seed: **9001**; target Bulk: **24**. Arrangement evidence uses synthetic transforms and profile `stage_a_synthetic_integration`, revision **1**; it is not a physical preparation result.

- Reproducible content and distinct identity: two generations of batch `integration_first` with identical inputs produce byte-identical committed snapshots. Generation of `integration_distinct` with the same seeds/pool/Bulk produces the same ordered definition IDs and actual Bulk, while every item instance ID is disjoint from the first batch. Generated actual Bulk is checked against the sum of real catalogue entry Bulk and is at least the target. Both committed and prepared snapshots survive `var_to_bytes`/`bytes_to_var` reconstruction byte-identically; reconstructed ItemInstances retain exact durable IDs and real definition references.
- PREPARED-undelivered capacity: the suite prepares `integration_second`, `integration_third`, `integration_fourth`, and `integration_undelivered` before any deposit. A new manager still has no active batch, no queue, and no registration for the undelivered batch. The undelivered batch never enters ownership during subsequent deposits/drains, and its final snapshot is byte-identical to its initial PREPARED snapshot. Preparation alone consumes zero Receiving slots.
- Atomic fourth-deposit rejection: after deposits of `integration_first`, `integration_second`, and `integration_third`, depositing `integration_fourth` returns false. A byte snapshot covering active ID, queue IDs, every supplied batch snapshot, and each batch's ownership registration is identical before and after rejection. Original deposited object references remain intact, the rejected batch is absent from the registry, queue order remains second/third, and exactly one rejection notification names `integration_fourth`.
- Ownership and FIFO: invalid queued/wrong-identity releases preserve content; accepted releases drain each active batch exactly once. A drained batch retains its slot until explicit post-close retirement. Retirement promotes second, then third, then leaves the manager empty, with exact corresponding signal sequences.
- Disposable preparation: a synthetic failed job records transient diagnostics without modifying the committed snapshot. Reconstruction retains no job state/diagnostic fields, and a fresh job can prepare that content. The runtime manifest boundary guard passes. All four integration sections must reach their explicit completion counters, including guarded helper completion.

## Stage A exit decision
`PASS`

Stage A is implemented and technically verified. This decision is not a player-facing/human gameplay gate. No Stage B work, freight-bay asset inspection/assembly, or asset preflight was performed.

## Mandatory next checkpoint
Developer provisions candidate freight-bay building-block assets in the authoritative local project. Only then perform the read-only Stage A → Stage B asset preflight from the architecture spec. Do not begin Stage B before that checkpoint.
