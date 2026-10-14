# Receiving Stage C — Awaiting Lift prototype validation, 14 October 2026

**IMPLEMENTED / TECHNICALLY VERIFIED — awaiting human PROMOTE / REVISE / REJECT.** This gate covers upstream prototype admission and explicit midnight forfeiture only. C1, single-cycle and two-batch milestones remain human-promoted; overall Stage C closure/publication is separate.

## Preflight and implementation brief

Authoritative asset-equipped checkout: `D:\Godot Projects\Sorting-apoc-PROTOTYPE`. Live `origin/main`, local `main` and starting HEAD were `3be0c1c6953241af66bd83bde9e5aa260b397529`, verified with `git -c http.sslBackend=openssl ls-remote origin refs/heads/main`. Windows Schannel initially failed to acquire credentials. Published two-batch implementation `83cbed14aa81d3f5551c07cab95dcd96b54f5fa2` and manual-art checkpoint `9ede796` are ancestors. Godot is `4.7.stable.official.5b4e0cb0f`; project configuration remains GL Compatibility. Starting tracked/untracked status was clean; the historical DOCX lock was absent. Existing branches/worktrees and ignored local files were preserved.

Local branch: `codex/receiving-stage-c-awaiting-lift`. Followed the approved request, `AI_WORKING_GUIDELINES.md`, current state, GDD v0.13 §§5.4, 9.1–9.7 and 11.2/11.5–11.8, and published single-/two-batch validation. Bounded implementation: first test the upstream owner/invalid/FIFO/midnight contracts, then test runtime opt-in wiring against the production wing, then focused regressions, one full-cue OpenGL unblock and consolidated review. Missing-owner and missing-demo-helper RED failures were observed before implementing their respective behavior.

## Return-owner interface and ownership

`receiving/awaiting_lift_admission.gd` is one upstream `Node`, instantiated/configured by `ReceivingRuntime` as child `AwaitingLiftAdmission` after existing presenter/lift configuration. No authored scene changes.

- `configure(manager, item_catalog, deck_profile) -> bool`: one-time configuration; validates the existing resources.
- `submit_return(team_id: String, batch: LootBatch) -> ReturnResult`: `INVALID = 0`, `ADMITTED = 1`, `AWAITING = 2`. Accepts unique team/batch IDs and a fresh PREPARED compatible deck commitment. Invalid submissions create no waitlist record and no success/wait event.
- `get_awaiting_returns() -> Array[Dictionary]`: copied FIFO identity/status records, without loot-object access.
- `get_return_snapshot(team_id) -> Dictionary`, `get_return_status(team_id) -> StringName`: unknown IDs return `{}` / `UNKNOWN`; tracked statuses are `AWAITING_LIFT`, `ADMITTED_RETURNED`, `FORFEITED_RETURNED`, or exceptional `INVALID_RETURN` with diagnostic `reason`.
- `resolve_awaiting_lift_at_midnight() -> Array[Dictionary]`: explicit caller-owned event; returns forfeited identity/status records. Repeated calls are inert when nothing new is awaiting.

Four lifecycle signals have `(team_id: String, batch_id: String)` payloads: `return_admitted`, `return_awaiting_lift`, `return_admitted_after_waiting`, `return_forfeited_at_midnight`. `return_invalidated(team_id, batch_id, reason)` reports an unexpectedly changed/incompatible pending commitment or unexpected manager rejection. Signals and query state identify the commitment; console logging is observation only.

`ReceivingManager.get_deposit_eligibility(batch)` distinguishes `INVALID`, `CAPACITY_FULL`, `AVAILABLE`, checking invalidity before capacity. `has_deposit_capacity()` reads the existing one-active/two-queued capacity. `deposit_batch()` preserves its atomic bool rejection and `deposit_rejected` signal semantics. Existing manager tests pass unchanged.

The upstream FIFO alone retains the original prepared batch reference and comparison bytes while waiting. It never creates inventory, clones a replacement, rerolls, mutates entries/layout, materializes pending cargo, or expands manager occupancy. Terminal records retain identity/status only; weak-reference tests verify forfeits release gameplay batch objects. Terminal IDs remain reserved for this owner's lifetime, preventing resubmission through the return seam.

Manager `contents_changed` schedules one coalesced deferred admission pass only when a real slot exists. The pass runs after synchronous staging/retirement and lift guard reset. It handles a fixed starting FIFO budget, reserves identities before callbacks and admits only through `deposit_batch()`. It never starts/promotes a lift itself or polls frames. New arrivals behind a pending vacancy pass remain behind older commitments. Invalidated pending records terminate visibly and cannot spin/retry.

## Deterministic team ↔ batch mapping

The four-return helper uses existing `PrototypeLootSource` / `ReceivingDeckLayoutPlanner`, fixed seeds and the selected fixture mode. Bulk override applies to this new demo; existing single-/two-batch helpers retain their behavior. All four batches prepare before the first submission; repeated/busy/invalid demo calls cannot replace commitments.

| Team | Batch ID with review bulk 4 | Content / presentation seed | Definition IDs at bulk 4 |
| --- | --- | --- | --- |
| `prototype_team_A` | `receiving_debug_1842_9001_4` | 1842 / 9001 | 21, 24, 20, 32 |
| `prototype_team_B` | `receiving_debug_1843_9002_4` | 1843 / 9002 | 30, 4, 26, 12 |
| `prototype_team_C` | `receiving_debug_1844_9003_4` | 1844 / 9003 | 22, 7, 11, 13 |
| `prototype_team_D` | `receiving_debug_1845_9004_4` | 1845 / 9004 | 4, 40, 40, 8 |
| `prototype_team_E` (test only) | `receiving_debug_1846_9005_4` | 1846 / 9005 | Existing deterministic source, no alternative generator |

Definition shorthand is `loot_0000NN`. Each batch owns entries `entry_0000`–`entry_0003`, with exact item IDs `<batch_id>:item_0000`–`:item_0003`. Four demo manifests differ in actual multiplicities, not just ordering. Batch IDs use the requested bulk as their final suffix; default remains 24.

## Occupancy, FIFO and midnight evidence

| Explicit event | Active | Deposited FIFO | Awaiting teams | CRT queue |
| --- | --- | --- | --- | --- |
| Four submissions | A | B, C | D | 02 |
| Fifth test submission | A | B, C | D, E | 02 |
| A final TAKE, close/contact, outbound underway | A (drained) | B, C | D, E | 02 |
| A full departure; deferred vacancy processed | B | C, D | E | 02 |
| B full departure; deferred vacancy processed | C | D, E | none | 02 |
| C full departure | D | E | none | 01 |
| D full departure | E | none | none | 00 |
| E full departure | none | none | none | 00 |

Five production-wing cycles use ordinary TAKE, exact ItemInstances, the published FIFO handoff and each complete six-state cycle. Twenty identities transfer once. D/E retain their prepared snapshots and each emits one waited-admission event. Unit checks also submit F between retirement and deferred admission and during a synchronous deposit callback; D → E → F priority remains. Duplicate notifications coalesce; two simultaneous vacancies fill exactly two real slots.

Midnight-first with A/B/C deposited forfeits D/E in order and leaves all deposited snapshots intact. Vacancy-processed-first admits D behind C; subsequent midnight forfeits E only. A scheduled vacancy pass followed by midnight before it runs forfeits its still-pending return; the stale callback is inert. Later slot openings cannot resurrect terminal commitments. Payload example:

```gdscript
{"team_id": "team_D", "batch_id": "D", "status": &"FORFEITED_RETURNED"}
# Explicit test/future caller hook, without a timer or player button:
var forfeits = runtime.return_admission.resolve_awaiting_lift_at_midnight()
```

## Verification and full-cue scene result

**14 focused suites PASS**, all process exits and saved diagnostics inspected: `receiving_awaiting_lift`, `receiving_awaiting_lift_integration`, `receiving_manager`, `receiving_queued_delivery`, `receiving_deck_presenter`, `receiving_lift_cycle`, `receiving_lift_crt`, `receiving_reflections_integration`, `receiving_prototype_loot_source`, `receiving_stage_a_integration`, `wing_startup_parity`, `storage_stack_surface`, `storage_stack_rules`, `storage_stacking_interaction` (under `tools/asset_pipeline/tests/`, suffix `_tests.gd`). Startup with `--receiving-awaiting-lift-debug` alone also passes empty. Headless editor scan exits 0 with no script diagnostics; `git diff --check` is clean.

Actual OpenGL 3.3 Compatibility / RTX 5060 Ti four-return run, full unchanged cues; seconds from first admission:

| Event | Seconds | Observed state |
| --- | ---: | --- |
| A ready / revealing | 20.371 | D awaiting; B/C deposited |
| A OPEN | 26.428 | ordinary TAKE enabled, queue 02 |
| A final TAKE / closing | 27.190 | D still awaiting |
| A outbound starts | 34.441 | outgoing owns lift, no incoming/TAKE/admission |
| A outbound complete; B arrival | 53.576 | B promoted before D append |
| Unblocked capture / check | 54.373 | B active; C/D queued; D ADMITTED_RETURNED; queue 02 |

Outbound lasts 19.135 seconds. This real-time probe stops after the new unblock boundary; five complete eventual cycles are covered by the deterministic real-scene test. Existing human-accepted full audio/lighting evidence is reused for unchanged owners. CRT pixel checks pass for configured UID and canonical scene: 704 × 400, 3,924 green samples each.

Local ignored raw evidence: `reports/receiving/stage_c_awaiting_2026-10-14/`, including `red_admission.log`, `red_integration.log`, `final_*.log`, `startup_awaiting_flag_alone.log`, `script_scan.log`, `real_scene.log`, A opening/OPEN images and `four_return_unblocked.png`. Final elevated tests/scene/CRT logs have no unexpected diagnostics. The owner suite intentionally reports changed commitment `team_D / D` once; the existing source suite intentionally reports duplicate-visual-path rejection. Earlier sandboxed baseline/RED/GREEN and editor-scan logs contain the Windows certificate-store startup warning; this is separate from script/test outcomes.

One consolidated read-only code review found no critical or important findings and requested no correction loop. It checked identity reservations, synchronous callbacks, capacity release, FIFO, commitment preservation, midnight ordering, terminal references and startup guards. Real Expedition/Dispatch/clock/recovery and subjective audiovisual pacing were excluded under the explicit task boundary; deliberate private-field mutation/reuse after ownership transfer is outside the commitment API. The supported pending-content mutation fails closed in the focused test.

## Human demonstration and stopping boundary

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' -- --receiving-deck-debug --receiving-awaiting-lift-debug --receiving-target-bulk=4 --receiving-fixture-mode=mixed
```

Observe console `AWAITING_MANIFEST` / `AWAITING_RETURN`: A/B/C initially admitted, D `return_awaiting_lift`. CRT stays queue 02. Unload A with normal TAKE/carry/store; D stays waiting until complete close/latch/outbound. Then observe B incoming, C/D queued and D `return_admitted_after_waiting`. Continue normal unloading through B/C/D to empty. No new player control or Dispatch monitor is needed.

Test-only midnight reproduction:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' --script res://tools/asset_pipeline/tests/receiving_awaiting_lift_tests.gd
```

Full-cue technical reproduction uses the same executable/path with `--rendering-method gl_compatibility --script res://tools/asset_pipeline/tests/receiving_awaiting_lift_integration_tests.gd -- --awaiting-real-time --receiving-deck-debug --receiving-awaiting-lift-debug --receiving-target-bulk=4 --receiving-fixture-mode=mixed`.

Limitations: prototype IDs/status are in-memory seams, not real teams, a production clock, durable journal/save recovery or outcome/population reporting. All future returns must use the upstream owner to enforce terminal identity/fairness. Automated TAKE disables held-item rendering and removes items between pickups; human carrying/storage feel and repeated pacing remain human review. Accepted probe/held-view debt remains. No scene/art/material/wear/light/probe/W1/audio/shutter timing/CRT vocabulary/storage/economy changes, overall Stage C closure, publication or cleanup. Stop at a local implementation/validation commit for **PROMOTE / REVISE / REJECT**.
