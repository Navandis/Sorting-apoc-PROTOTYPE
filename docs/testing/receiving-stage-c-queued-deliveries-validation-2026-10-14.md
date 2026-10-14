# Receiving Stage C — queued deliveries, 14 October 2026

**IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-PROMOTED — 14 October 2026.** Accepted implementation: `83cbed14aa81d3f5551c07cab95dcd96b54f5fa2`. The dated disposition below supersedes this original technical handoff's pending-review/publication boundary. Promoted C1, single-cycle gameplay and intentional lighting remain closed in their respective scopes.

## Authority and implementation

Worked in the authoritative asset-equipped `D:\Godot Projects\Sorting-apoc-PROTOTYPE`. Local HEAD and live remote `main` both verified as `9ede796fae0733b59b4cfe78f3d9652657f73d7b` before editing (`git -c http.sslBackend=openssl ls-remote origin refs/heads/main`; Windows Schannel initially could not acquire credentials). Local branch: `codex/receiving-stage-c-queued-deliveries`. The pre-existing untracked `docs/.~lock.Sorting_Apocalypse_Preliminary_GDD_v0.13.docx#` remains untouched and excluded from the commit.

The coordinator consumes the manager's returned promoted ID after full departure, completion of all synchronous presenter staging handlers and reset of its busy/retiring guards. Each waiting batch reuses the same six states, presenter, FIFO ownership and sound players. Incompatible promoted staging stays closed and noninteractive without rerolling.

`run_two_batch_debug_delivery(fixture_mode)` separately prepares B, admits A through the unchanged guarded single-delivery route, then deposits B exactly once on A's OPEN signal. Both use `PrototypeLootSource` and the shared existing planner. Normal startup and the new flag without `--receiving-deck-debug` create no delivery. The two-batch demonstration uses fixed seeds/bulk; numeric seed/bulk overrides continue to apply to the single-batch route. Fixture options remain `bare`, `crates`, `pallets`, `mixed`.

No scene, geometry, wear, lighting, probe setting, W1 tuning, shutter timing/endpoint, audio asset/import, CRT presentation/vocabulary, storage rule, deck profile or economy changes. The CRT test now allows obsolete hidden alternatives to have been removed, preserving the actual published scene.

## Committed batches

| Batch | ID | Content / presentation seed | Entries / actual bulk |
| --- | --- | --- | --- |
| A | `receiving_debug_1842_9001_24` | 1842 / 9001 | 24 / 24 |
| B | `receiving_debug_1843_9002_24` | 1843 / 9002 | 24 / 24 |

Definition multiplicities differ even after sorting: A contains `loot_000020` three times and no `loot_000030`; B contains `loot_000030` three times and no `loot_000020`. Complete manifests are printed in queue logs. Each batch retains entries `entry_0000`–`entry_0023` and its own batch-prefixed `:item_0000`–`:item_0023` identities. All 48 exact ItemInstances transfer once through ordinary TAKE. B's prepared snapshot is byte-identical before A unloading, after queue residence and after promotion. Mixed layouts use each batch's separate presentation seed.

## Actual timed sequence

Godot **4.7.stable.official.5b4e0cb0f**, OpenGL 3.3 / Compatibility, RTX 5060 Ti; unchanged full-length cues and accepted arrival/opening overlap. Seconds are relative to first admission:

| Event | Seconds | CRT STATUS / DECK / QUEUE |
| --- | ---: | --- |
| Before admission | — | IDLE / CLEAR / 00 |
| A arrival | 0.022 | INCOMING / CLEAR / 00 |
| A ready / revealing | 20.495 | INCOMING then OPENING / 24 / 00 |
| A OPEN; B deposited automatically | 26.530 | OPEN / 24 / 01 |
| A final TAKE / closing | 27.448 | CLOSING / CLEAR / 01 |
| A outbound begins | 34.687 | IDLE / CLEAR / 01 |
| A outbound complete; B arrival | 53.840 | INCOMING / CLEAR / 00 |
| B ready / revealing | 73.869 | INCOMING then OPENING / 24 / 00 |
| B OPEN | 79.915 | OPEN / 24 / 00 |
| B final TAKE / closing | 80.866 | CLOSING / CLEAR / 00 |
| B outbound begins | 88.111 | IDLE / CLEAR / 00 |
| Final empty check/capture | 108.539 | IDLE / CLEAR / 00 |

A's outbound interval is **19.153 s**; closing intervals are **7.239 / 7.245 s**. Every outbound frame checks no incoming audio/TAKE and B's preserved FIFO position. W1 restarts amber for B after A's turnaround. Final ownership, fixtures and queue are empty, with no third arrival or idle reflection polling. A/B screenshots show distinct cargo.

## Verification and limitations

**12 focused suites PASS**, with exits and logs inspected: `receiving_queued_delivery`, `receiving_manager`, `receiving_deck_presenter`, `receiving_lift_cycle`, `receiving_lift_crt`, `receiving_reflections_integration`, `receiving_prototype_loot_source`, `receiving_stage_a_integration`, `wing_startup_parity`, `storage_stack_surface`, `storage_stack_rules`, `storage_stacking_interaction` (under `tools/asset_pipeline/tests/`, suffix `_tests.gd`). The lone-delivery suite still ends without another cycle; manager capacity/FIFO and atomic fourth-deposit rejection remain intact. Startup with `--receiving-two-batch-debug` alone also passes without cargo.

The new test reproduced missing arrival before the handoff fix and missing helper before its implementation. Final coverage includes reversed presenter signal order, full-bundle rejection on both batches, fully-OPEN-only/stale TAKE, live counts, retained drained fixtures, exact identities/layout, cleared A stack reservations, failed promoted staging and final idle. The Godot editor script scan exited 0 without diagnostics. One consolidated read-only review found no actionable code issues.

Local ignored evidence is `reports/receiving/stage_c_queue_2026-10-14/`: `final_queued_delivery.log`, `queue_realtime.log`, `final_*.log`, and screenshots. **`corrected_crt_opengl.log` supersedes failed `final_receiving_lift_crt.log`**: the original CRT test aborted on a removed monitor and its stalled test process was stopped; no art was restored. Corrected CRT pixel checks pass for configured UID and canonical scene, both 704 × 400 with 3,924 green samples. Earlier sandboxed RED/GREEN logs contain a Windows certificate-store startup error; final elevated gameplay/render checks do not. The source suite retains its intentional duplicate-visual-path rejection diagnostic. Final queue/OpenGL logs contain no unexpected diagnostics.

The timed harness disables held-item rendering, automates ordinary `pickup_into()` and removes carried entries between takes. Human movement, carrying/storage feel, audio balance and repeated theatrical pacing remain for human review. Existing held-view diagnostics and accepted probe costs remain outside scope. No unchanged environment-authoring sweep, Expedition/Awaiting Lift, save recovery or performance work was added.

## Human playtest

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' -- --receiving-deck-debug --receiving-two-batch-debug --receiving-fixture-mode=mixed
```

Wait for A to open and observe QUEUE 01. Unload through normal TAKE, carrying/storing as needed; leave cargo or fill capacity to confirm OPEN waits. Watch complete close/latch and departure, followed by B's automatic amber arrival and independent opening. Unload B and observe final IDLE / CLEAR / 00. No delivery button, confirmation or manual advancement is needed.

Technical timed reproduction: use the same executable/path with `--rendering-method gl_compatibility --script res://tools/asset_pipeline/tests/receiving_queued_delivery_tests.gd -- --queue-real-time --receiving-deck-debug --receiving-two-batch-debug --receiving-fixture-mode=mixed`. The same test without user flags runs bounded deterministic integration and promoted-staging rejection.

Original technical-handoff boundary: one local implementation commit and no publication pending human review. The following explicit decision supersedes that publication restriction; branch/worktree preservation remains required.

## 14 October 2026 — explicit human PROMOTE and publication authorization

The developer HUMAN-PROMOTED **Receiving Stage C — Two Distinct Back-to-Back Queued Deliveries** after normal in-game testing of implementation `83cbed1`. Two different committed batches, with independent identities/manifests, completed autonomous A → B cycles. B waited FIFO and began arrival only after A's full departure; no overlap was observed. CRT counts/status, warning states, TAKE gating, shutter motion, full audio, lighting and normal carrying/storage were satisfactory.

Approval covers only this two-batch physical queue milestone. **Awaiting Lift/fourth-return backpressure, midnight forfeiture and Expedition integration remain separate later scope.** No new loot-source behavior, UI or wider Stage C close-out is authorized. C1, the Stage C single cycle and intentional Receiving lighting remain HUMAN-PROMOTED and closed.

The unchanged implementation's existing 12-suite validation and full-cue OpenGL evidence above were inspected and reused for acceptance/publication. No new engine test run or performance claim is made. Existing accepted probe/performance debt and held-view diagnostic limitations remain recorded; the developer's normal carrying/storage acceptance is distinct from the automated harness's held-view limitation.

The developer explicitly authorized a targeted acceptance commit, safe fast-forward integration into `main` and normal push to `origin`. Publication includes unchanged implementation `83cbed14aa81d3f5551c07cab95dcd96b54f5fa2` and this documentation disposition. Keep all branches/worktrees and unrelated local files. Stop immediately after independently verifying publication; Awaiting Lift implementation awaits its separate prompt.
