# Pre-MVP runtime corrections — 14 October 2026

Implemented locally in the approved order **R-02 → R-01 → R-03**. Technical checks pass; **independent contextual diff review and developer playtest are pending**. This is a local recovery/review checkpoint, not human PROMOTE or publication. R-04 remains deferred.

## Source and environment

Authoritative asset-equipped checkout: `D:\Godot Projects\Sorting-apoc-PROTOTYPE`. Initial clean `main`, actual base and read-only live remote main: `bf26b5320653cd452e99592ed176d0163d9e286f`. Stage C closure `bb6683d` is an ancestor (exit 0); no newer delta. Repair branch: `codex/pre-mvp-runtime-corrections`. All five existing worktrees remain. No developer Godot process was observed or stopped.

Verified executable: `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`, `4.7.stable.official.5b4e0cb0f`. Project remains `gl_compatibility`; all new executions used headless/dummy rendering/audio, no user flags. No install, upgrade or renderer change.

New external evidence/patch directory: `D:\Sorting_Apocalypse_Engineering_Review\2026-10-14\bf26b53-repairs-233213-c017f9`. Its absolute path is outside all worktrees; existing output/worktree ancestors had no reparse points. Original `bf26b53-A-222454-062e1c` evidence was read only, with no later modification time observed. Original audit reports remain unchanged. The supplied repair brief governs execution; repository guidelines/bootstrap/current state, GDD v0.14 §§7/11, original consolidated/neutral/A reports, probes and focused pose/queue/Awaiting records supplied context. DOCX masters and mirrors remain unchanged.

`final-source-sha256.log` records the first final-set state; `followup-source-sha256.log` records the final footprint correction and source/test state used by the affected follow-ups and remaining final checks. The local commit SHA and final Git state are recorded in external `final-git.log` and the delivery message.

## Repairs and failing evidence

**R-02:** Four bounded suites now keep scenario and fixture helpers pending until their own normal exit. Return expressions evaluate before accounting is cleared. Final decisions run outside scenario orchestration and require zero unfinished helpers. `receiving_manager_tests.gd` was the existing pattern and remains unchanged. No runner/framework or gameplay fault accommodation was added.

`r02-baseline-abort.log` reruns the original external subclass against unchanged source: BEGIN, null-call script error, missing UNREACHABLE, inherited PASS, exit **0**. Six `r02-canary-*.gd/.log/.engine.log` experiments inject the same deliberate null call immediately inside actual instrumented bodies: storage scenario/typed fixture, wing scenario/nested scene fixture, ladder awaited scenario, lift queue helper. Each reached its final incomplete-helper decision and exit **1**, with no PASS or UNREACHABLE. Fixture faults cascade into their callers (28 pending storage helpers / 8 wing helpers); these are intentional experiment diagnostics, not normal-suite failures. The old subclass replaces the entire instrumented method, so it would bypass body accounting; the adapted external suite copies preserve the protected body and add only the deliberate fault. Normal R-02 runs pass. This does not invalidate clean historical baseline runs.

**R-01:** Placement recomputes the selected ItemInstance proposal against the addressed destination before removal. Surface, proposal, footprint, packing/unit orientation, carrying owner and original slot remain local across synchronous removal callbacks. Spawning derives its entry from the actual item. Ordinary surface commit independently checks authored footprint/orientation, entry/proposal agreement, current zoning, support-chain/insertion rules, host height and clearance. Existing stack evaluators are reused; Receiving-private measured footprints and committed arrangements remain private and unreplanned. No player/carrying/stack ownership redesign was needed.

`storage_command_validation_tests.gd` drives the real number-selection callback and player store method without a process refresh: authored CD 2×2 → Armor 3×3. It checks unchanged exact slots/selection and empty destination on the 2×2 rejection; B's identity, 3×3 reservation and one transfer on a larger surface; synchronous preview refresh during removal; stale headroom rejection; and direct authored-footprint under-reservation rejection. `r01-red-fixture.log` and `r01-commit-footprint-red.log` show the corresponding real assertion failures before fixes; final checks pass. Earlier `r01-red.log` had a regression-author footprint type parse error, and `r01-red-typed.log` exposed a missing General-zone fixture precondition; both attempts remain preserved and are not claimed as valid failing proofs.

Existing rollback fixtures now install their blocker during `item_removed`, after command validation, to exercise genuine commit rejection and exact restoration. The disabled-zone fixture creates its existing stack before disabling its cells. Legal auto/manual, Front/rotation parity, existing-stack identity retention, promotion/removal/compression, retrieval and multi-item hold-to-store coverage remains asserted in the existing suites.

**R-03:** One process-local static serial owned by `ReceivingRuntime` adds a fresh delivery namespace in shared debug preparation. It is independent of both seeds, shared across single/two-batch/Awaiting preparation and runtime instances, and never used by reconstruction. No manager identity registry, global service, save system or content reroll. Awaiting retains its one-shot guard and team labels. Its integration fixture now obtains each allocated team-linked ID and reconstructs expected D with that same ID, retaining full commitment comparisons.

`r03-red.log` demonstrates duplicate batch/item IDs with the first haul still owned by actual carrying and wing storage, plus repeated two-batch collisions (103 failed assertions, completed exit 1). `r03-green.log` and the final identity suite pass: retained old ownership/reservation, disjoint new IDs, exact ordered definitions/Bulk/arrangement fields, reconstruction IDs, B's original object/snapshot through waiting, queue residence and FIFO promotion, and repeat after full departures. Existing queue helpers supply controlled TAKE/cycle advancement; old queue fixture references remain in the transfer dictionary.

## Final verification

Exact command family, authoritative checkout as CWD (each console log records its concrete expansion):

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --log-file '<external>\<run>.engine.log' --quit-after 10000 --script 'res://tools/asset_pipeline/tests/<suite>.gd'
```

All **16 selected suites PASS / actual exit 0**, with expected suite completion. `final-<suite>` logs cover the consolidated set; `followup-<suite>` logs supersede seven storage results after the independent commit-footprint correction. No unchanged broad gameplay sweep was repeated for packaging.

| Suite (suffix `_tests.gd`) | Final evidence / relevant coverage |
| --- | --- |
| wing_startup_parity | final; fresh process resolves configured UID before canonical load; one declaration, normal empty wing |
| storage_command_validation | followup; actual selected command, callback coherence, stale commit and authored footprint |
| storage_stacking_interaction | followup; protected helpers, legal/manual/rotation, promotion/retrieval/rollback/hold |
| storage_stack_surface | followup; stack identity/reservations, transitions and rejection |
| storage_semantic_zoning | followup; matching → General → stop, erased cells, Front |
| storage_singleton_clearance | followup; singleton physical clearance versus stack headroom |
| storage_item_orientation | followup; canonical/packing/Front parity |
| wing_storage_bridge_interaction | followup; actual wing carry/store/retrieve, ladder, ownership and rollback |
| fixed_ladder_player | final; protected real-player scenario/fixture completion |
| receiving_lift_cycle | final; protected cycle/readout/failed-staging scenarios |
| receiving_debug_delivery_identity | final; retained haul, same seeds/new IDs, repeated two-batch execution |
| receiving_deck_presenter | final; private metrics/materialization, exact identities, reconstruction and TAKE |
| receiving_prototype_loot_source | final; seeded content and caller-namespaced identity |
| receiving_queued_delivery | final; prepared B, FIFO/full departure and incompatible staging |
| receiving_awaiting_lift | final; admission, mutation rejection and midnight ordering |
| receiving_awaiting_lift_integration | final; shared debug IDs, one-shot/team labels, exact queued commitments and five cycles |

Full console/engine diagnostics were inspected. Two intentional final rejection signatures remain: duplicate `SM_ComputerMouse_01.glb` in the source suite's invalid-catalog test, and `team_D / batch D` changed commitment in Awaiting's mutation case. All other final/follow-up logs have no error/warning signature. Runs were serial and supervised using execution sessions; each completed within 17 seconds without timeout/iteration-ceiling intervention. `--quit-after 10000` is an iteration ceiling, not a wall-clock timeout. Original A/B evidence remains dated same-state baseline, not fresh post-change proof.

## Limits, preservation and handoff

No scene, source asset, definition/catalogue/pose/profile, import setting, art, lighting, audio, renderer or master/mirror changes. Git-visible edits are limited to the three runtime owners, supporting suites, two new regression scripts/UID companions and this note. Godot runs deliberately wrote external logs and the two new UID companions; incidental cache/runtime-profile activity is possible and was not exhaustively hashed. A post-run `.godot` mtime check found no changed files. No zero-filesystem-write claim is made. No reset/stash/clean, asset copying, worktree deletion, push, merge, PR or publication.

**R-04:** deferred by approval. Revisit before restart/reload/menu scene replacement or another scene-lifetime dependency, or sooner if it prevents trustworthy validation. The historical error is reflection frame-wait teardown, distinct from quiet timer-cooldown deletion and held-material diagnostics. No R-04/held-material error appeared in the final set; no lifecycle repair or global suppression was made. Existing/explicit fixture settling waits are evidence timing, not a teardown fix.

**Future transfer constraint:** carrying collection signals may fire before enclosing transfer success and rollback. Future irreversible consumers must observe successful transfer boundaries. They are not implemented here. Real future returns continue through `AwaitingLiftAdmission.submit_return(...)`.

**Pending independent review:** one fresh contextual review of the complete base-to-repair diff and relevant callers/consumers. This implementer's diff inspection is not independent review. Any review correction gets affected follow-up checks only. C1/Stage C/lighting remain closed; no automatic milestone reacceptance.

**Pending developer playtest:** launch the normal configured wing with real held view enabled. TAKE several mixed items; wheel and number-select each followed by E onto a legal shelf, observing correct selected item/held/HUD identity and rejection without loss when it cannot fit. Hold E with a mixed bundle and observe each legal transfer once and remaining items retained. Try representative manual placement, R rotation and retrieval/base promotion, checking seated visuals, footprint, stable committed orientation and normal reach. Optionally activate the existing explicit debug delivery to supply the haul; normal startup remains empty. Record actual human outcomes here after the developer performs them. The no-refresh race is deterministic-regression evidence; sub-frame human reproduction is not required.

## 15 October 2026 — R-01 manual target-address follow-up

The independent review of `a2afab1519448864146c5f0d1f8c03dc4a21856c` returned **REVISE** for F1/F2. This addendum records their bounded correction on the same `codex/pre-mvp-runtime-corrections` branch; the earlier commit remains a distinct checkpoint. Initial source was clean and matched that commit. Godot executable/version and Compatibility configuration were reverified unchanged; no editor process was observed or stopped.

`StoragePlacementController` now retains a manual address independently of the selected item's fit: addressed surface plus stack ID, or addressed surface plus actual local ray hit. Invalid stack fits remain stack attempts and cannot fall through to empty placement. Point commands re-evaluate the selected item from the original hit instead of the old snapped center. Target refresh, mode changes and suppression clear the retained address; suppressed commands reject. Existing selected-item validation, transaction-local snapshots, exact-slot rollback and commit validators remain. Only this runtime owner, three affected test files and this addendum changed. Controlled legacy fixtures explicitly supply their known target addresses; production has no fit-to-address fallback or test-only bypass.

New tracked command regressions use actual storage/WorldItem rays, real `update_target()` output, number-selection callback and player store command. F1 checks exact slots/selection, original entry/stack/reservation and absence of any extra destination after disabling cells under a stored CD. A valid addressed append remains legal and retains the destination stack ID. F2 checks Armor's distant `(8,4)` preview followed immediately by CD placement at the original near `(0,0)` island, with its own 2×2 footprint/ID and one transfer. The companion case starts with an invalid Armor preview and still places CD at the intended point. Existing manual R/unit-Front, ghost/final parity, rollback, retrieval and hold-to-store checks remain asserted.

New external evidence: `D:\Sorting_Apocalypse_Engineering_Review\2026-10-15\a2afab1-manual-address-121825-244e4d`, verified outside all five worktrees with no reparse-point ancestors. Original A/B, repair and independent-review evidence remains read-only. `reviewer-probe-red.log` reruns the exact supplied probe against unchanged `a2afab1`: both genuine invariant failures, final completion, exit **1**. `tracked-command-red.log` independently records the tracked F1/F2 assertion failures and completed exit **1**. `reviewer-probe-green.log` uses the unchanged probe: F1 retains one carried item/one stack with no incoming reservation; F2 reserves CD at `(0,0)`; completion failures=0, exit **0**. `tracked-command-green.log` passes, exit **0**. No parse error, timeout or missing completion was substituted for these proofs.

All **seven affected suites PASS / actual exit 0**, with full console/engine logs inspected and no error/warning diagnostics: `storage_command_validation_tests`, `storage_stacking_interaction_tests`, `storage_stack_surface_tests`, `storage_semantic_zoning_tests`, `storage_item_orientation_tests`, `storage_singleton_clearance_tests`, `wing_storage_bridge_interaction_tests`. Each `final-<suite>.log` records the exact Godot command, authoritative CWD, expected completion, actual exit and timestamps; paired engine logs and `verified-source-sha256.json` identify the tested state. Runs were serial and session-supervised, each completing within 12 seconds. The command pattern remains the one above, with `--headless --path . --log-file <new external log> --quit-after 10000 --script res://tools/asset_pipeline/tests/<suite>.gd`, no user flags. No startup-relevant file/resource changed, so startup was not rerun. Unchanged R-02 canaries, R-03 deliveries and the original full 16-suite set were not rerun for packaging.

Scoped follow-up review: one fresh read-only reviewer found **no blocking findings** in the four source/test diffs and relevant player/carrying/surface-validator paths. They verified source hashes and saved red/green completion/exit evidence; they did not rerun Godot or review the documentation addendum, rendered/native input, or R-02/R-03/R-04. Their result is preserved in external `focused-review.txt`. This was a single narrow follow-up review, not a repeated full baseline audit.

The developer's normal rendered storage playtest remains **PENDING**: retain real held view, wheel/number selection followed by E, mixed hold-to-store, manual R placement and retrieval from the earlier checklist. Headless/direct-handler evidence does not establish rendered HUD/held view, native input or human acceptance. R-02/R-03 behavior and all Receiving/scene/art/light/audio/definition/metric/master files remain unchanged. R-04 and the future irreversible carrying-signal constraint retain their original dispositions. No newly modified `.godot` file was observed; incidental runtime-profile/cache activity was not exhaustively hashed. Final local commit/patch identifiers are in the delivery and external `final-git.log`; no push, merge, PR, publication or human PROMOTE.
