# M2 day clock and midnight — local candidate validation

**Current disposition: M2 HUMAN-PROMOTED / CLOSED following independent ACCEPT and all final human playtests passing.** Publication is authorized, subject to safe fast-forward and independent live remote verification. See the [final acceptance addendum](#17-october-2026--independent-accept-and-final-human-promotion). Earlier candidate/pending statements below are dated implementation checkpoints, preserved as history. M1 remains HUMAN-PROMOTED / PUBLISHED / CLOSED; M3 Kitchen is next, NOT IMPLEMENTED.

## Revision, sources and isolation

- Checkout: `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, remote `https://github.com/Navandis/Sorting-apoc-PROTOTYPE.git`, branch `codex/m2-day-clock-midnight`.
- Base and verified live main: `2cad0d766930ae2d5197171146ef253eb1087ad5`. Production checkpoint: `524edf11e218f7b59fcd475e4fad42e9a04f46f5`. The following delivery commit adds the final boundary test and this record, without changing production. Full delivery HEAD, commit list, final status and base-to-final patch SHA-256 are in external `final-git.txt`, avoiding a self-referencing commit ID here.
- Authority: approved external `C:/Users/Boschetar/Dropbox/Sorting Apocalypse/Sorting_Apocalypse_M2_Day_Clock_Scheduling_Midnight_Design_v0.2.md` in full; MVP v0.3 §§4–9 and 13–19; repository guidelines/fronts and the complete M1 validation/acceptance addendum. Stale v0.2 pointers were not treated as superseding the approved handoff. Masters, generated companions, historical records and art remain unchanged.
- Engine: `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`, locally reported `4.7.stable.official.5b4e0cb0f`. Existing imports/assets and Compatibility retained; Windows rendered runs report `gl_compatibility`. No installation or engine/renderer/dependency/framework migration.
- One implementer in this Codex session, with author self-review. No subagent or independent reviewer was dispatched. Existing worktrees were inventoried and preserved; this asset-equipped checkout was used in place. Initial tracked working tree was clean. Git's default TLS ref query failed with `SEC_E_NO_CREDENTIALS`; the read-only OpenSSL query verified live main successfully.

All executor preservation services inject directories beneath **`C:/Users/Boschetar/.codex/attachments/m2-2026-10-17-a`**. This fresh external root and its existing ancestors were checked for reparse points and separation from every listed worktree. Owner-only fixtures do not invoke a default preservation service. The developer's actual `user://saves` slot was not operated on, inspected, migrated or replaced; its absence is not asserted.

Tests ran serially. No developer Godot process was found at preflight or terminated. One early malformed executor run's identified PIDs were stopped; failed/interrupted runs remain raw evidence and do not establish success. An editor import scan generated only the required new script UID companions among tracked changes. Ordinary ignored `.godot`, portable editor/profile and runtime cache activity occurred; this is not a zero-filesystem-write claim. `APPDATA` and `LOCALAPPDATA` were directed into the existing `D:/AI Tools/Godot-4.7-Codex/runtime_profile/AppData/` profile.

## Actual ownership and schema

`run_clock.gd` owns elapsed active seconds, day and captured rate/day-start/latest-return configuration. Day progress/calendar coordinates derive from that owner; `run_identity.gameplay_seconds` is a read-only view. The wing advances `run_schedule.gd`; persistent lifts disable independent process advancement. `seconds_to_boundary()`, `advance_time(delta, false)` and `settle_boundary()` split real seconds at authored, request, mechanical and midnight endpoints. Engine time scale and normal movement/theatre pacing are unchanged. Midnight discards excess advance and jumps the calendar without overnight mechanical work.

The captured `m2_medical_supply` scenario revision 2 contains exactly the approved three Medical windows and three exact manifests. Validation rejects invalid/overlapping windows, late controlled attempts, unsupported items and unpresentable future manifests before New Run publication. Feasibility uses the existing planner with temporary values, without allocating run identities, submitting returns or occupying slots. Actual occurrences allocate once and submit exact prepared cargo through `AwaitingLiftAdmission`. Continue restores definitions, commitments and issued markers without preparation, seeding, generation or submission replay.

Requests retain occurrence identity/day, actual opening/deadline/closure, reason, exact receipts and required/supplied/unmet results. Submission revalidates the half-open window through the clock. Partial/zero expiry consumes nothing; fulfilled scheduled expiry is inert. History owns the objects. `wing.medical_request` references the latest history entry for existing callers; the station/panel bind only the current active occurrence or null. F/E/ESC, selection, red rejection, cap/waste, receipt-before-notification and release guards are preserved. The panel reads the same clock for its deadline/countdown.

Schema **2** extends the same snapshot, exact codec and save service with `clock` and `schedule` records. The latter includes captured definitions, request history, issued occurrences, actual admission facts, phase, resolved day and completed report. `timed_state_validation.gd` validates those relationships alongside the existing physical, receipt, allocator and Receiving checks. One remaining-item map, storage organization/poses, carrying gaps/selection, original-host removal, ladder/player state and all deposited/upstream/pending-debug ownership remain authoritative. Schema 1 gets explanatory disabled Continue; no migration occurs.

At midnight the shell blocks input/acquires `night_report`; admission closes before no-flush forfeiture and same-time mechanical settlement. Old-day report facts are frozen, the next day/start occurrences are prepared once, then phase `REPORT_PENDING` is captured/saved once through the ordinary service. Report display and Begin Day calculate no outcomes. Publication establishes a restored report hold before gameplay can run. Menu/zoning/loading/report reasons remain separate; Save & Exit remains available from the report menu. HUD/report are views of applied state.

## Executed proof and command record

Every executable, full argument array, start/end, mode and actual process exit is retained in **`commands.jsonl`**. Full output is `<name>.console.log` and `<name>.engine.log`; `final-verified-results.json` contains completion/diagnostic summaries. `preflight.json`, `source-manifest.json` and `attempt-notes.txt` retain source/isolation context and honest failed attempts. Exit 0 alone was not accepted. Helper completion guards and a deliberate abort canary protect against GDScript helper early returns.

| Final evidence names | Completion / actual exit | Decisive observation |
| --- | --- | --- |
| `final-m2-clock` | 15 checks, 0 failures / 0 | 150 seconds/hour, 2,550-second day, saved configuration, valid 20:59/invalid 21:00 opening, overlap/adjacency and initiation/departure/ordinal tie ordering |
| `final-m2-request` | 24, 0 / 0 | Before/at/after acceptance; stale preview; partial, fulfilled and zero histories; exact spent IDs, no live spent ownership or cross-day reuse; adjacent binding without automatic spend/reopening |
| `final-m2-schedule` | 18, 0 / 0 | Exact normal manifests, noon Day-2 closure before cargo, large/segmented chronology, no leftover time behind report, next-day start facts excluded from old report, finite content through Day 5 |
| `verified-production-boundary-audio` | 30, 0 / 0 | Full 1+2 queue; vacancy 0.25 s before midnight admits without a rendered callback; exact-midnight vacancy forfeits first; FIFO/remaining phase; actual unpause notifications and real shell report hold including queued audio |
| `final-m2-night` | 15, 0 / 0 | Same-service prepared report save, Save & Exit from report, restored hold before play, nested reasons, dismissal without outcomes/setup/save, active next-day continuation |
| `final-m2-failure` | 16, 0 / 0 | Ordinary same-name replacement rollback preserves prior snapshot/pointer bytes; one automatic attempt, warning/Begin Day, explicit fail-paused exit; M1 rejection/cancel and invalid initialization |
| `verified-phase-pre-writer` / `reader` | 24 / 19, 0 failures / both 0 | Separate processes recover a pre-midnight state and deterministically reproduce its completed transition and auto-save |
| `verified-phase-report-writer` / `reader` | 26 / 18, 0 / both 0 | Exact report-pending next-day state and mid-arrival progress; no replay or unpaused frame |
| `verified-phase-active-writer` / `reader` | 26 / 18, 0 / both 0 | Post-dismissal Save & Exit resumes active next day |
| `final-rendered-m1-v2` | 63, 0 / 0 | Existing synthetic F/E/ESC/selection/storage-hold pipeline, valid/ineligible/waste preview, centering and exact continuation with real held view |
| `final-rendered-m2` | 36, 0 / 0 | Deadline, open-panel expiry/cues, held-input rejection, clock away from Medical, report/nested menu/Continue/warning, 1920×1080 and 1280×720 |
| `final-reflection-lifetime` | Both deletion windows complete / 0 | Accepted owner-bound lifetime behavior retained |
| `final-abort-canary` | Deliberate abort, no completion / 2 | Incomplete helper cannot be mistaken for a passing completed run |

The 36-command serial sweep passed its expected completions and exits. Its fresh regression portion includes `m1_contribution_tests`, `m1_persistence_tests`, `m1_menu_tests`, `m1_receiving_continuation_tests`, `m1_pause_admission_tests`, separate M1 continuation writer/reader, startup parity, Receiving manager/lift/queued/Awaiting unit/integration/debug-identity/deck-presenter/reflection, storage command/stacking/stack-surface/orientation/semantic-zoning, fixed-ladder player/authoring and wing composition. Their exact basenames/results are external. Old suite names denote preserved contracts; persistence fixtures now use schema 2. No unrelated art/tooling sweep was run.

Six earlier OPEN-state process cases in that sweep are retained as same-production evidence, superseded for final continuation proof by the six strengthened `verified-phase-*` cases. Those save the promoted successor at 0.25 seconds before midnight and 0.5 seconds after resolution, with no overnight advance. Full captured/decoded/restored snapshots compare exactly. Only ideal mathematical quarter-/half-second assertions allow 1 ns for binary cue-length arithmetic: the observed discrepancy was `2.27e-13` seconds. That tolerance is not used for saved/load equality. Readers actually retrieve/promote/restow a saved stack member, enforce erased zoning, climb/release/rearm/reapproach the rotated saved ladder, finish the remaining lift journey and TAKE cargo, then allocate disjoint new identities.

Reused historical evidence is limited to M1's recorded independent ACCEPT/human promotion and unchanged foundation context. It is not asserted as a new M2 native-input, audio or human acceptance result. Later changes after the 36-command sweep were confined to stronger tests/documentation; production remains the tested checkpoint above.

## Failures, diagnostics and performance

Ordinary automatic replacement failure is exercised after same-name snapshot installation by an isolated directory obstructing the real pointer rename. Production rollback retains both prior files byte-for-byte and leaves the prior continuation usable. In-memory Day 2/report stay coherent; Begin Day works without retry. Explicit Save & Exit still fails paused until the ordinary obstruction is removed. The exact approved warning appears on the normal report. No retry UI, second serializer or durability framework was added.

Raw RED attempts cover missing owners/expiry, absent night integration, next-day start admission incorrectly held closed and future manifest feasibility. Parse errors, outdated fixture keys, a mistaken helper argument order, reused advanced test slots, rotated-ladder fixture assumptions, physics-overlap settling, a hidden-label text assertion and the initially absent M1 screenshot directory are all retained as failed attempts. One early helper error incorrectly returned completion/exit 0; it is explicitly invalid evidence. Completion counters and successful actual owner operations supersede it.

The final audio test initially used a wing inheriting the shell's `ALWAYS` process mode, unlike production's `PAUSABLE` candidate, and asserted an immediate `stream_paused` value for a not-yet-started cue. Investigation corrected that fixture. Installed-engine evidence now shows `can_process=false` and playback position exactly zero throughout the report; Begin Day resumes normal processing. No production audio workaround was retained. Godot documents positional `play()` as queued for a physics frame ([official API reference](https://docs.godotengine.org/en/4.5/classes/class_audiostreamplayer3d.html#class-audiostreamplayer3d-method-play)); the recorded local 4.7 observations, not an assumption about that getter, establish this test's result.

Final diagnostics were inspected in both console and engine logs. The known sandbox `Failed to read the root certificate store` signature at `os_windows.cpp:2582` remains disclosed. CF-07 produced **16** material-null diagnostics in final M1 rendering and **4** in final M2 rendering: `material_casts_shadows:2592`, `material_is_animated:2579`, `material_get_instance_shader_parameters:2618`, `material_update_dependency:2630`. They were not suppressed or repaired. Intentional rejected-seed, Awaiting mutation, duplicate namespace and automatic-save-failure diagnostics match their named fixtures. No other final error signature or unresolved functional failure was identified. Earlier aborted-fixture shutdown leaks are not final proof.

Final successful Windows-rendered Day-1 transition measurements, milliseconds:

| Measurement | ms |
| --- | ---: |
| Resolution/next-day preparation | 2.191 |
| Snapshot capture | 1.511 |
| Complete save service (validation/encoding/staging/reread/publication included) | 34.440 |
| Actual file write/flush portion within that service | 7.550 |
| Report control setup | 0.958 |
| Transition to completed report setup | 39.102 |
| First rendered report frame | 43.840 |

This warmed single-machine transition is below the practical 2–3-second response target; it excludes initial world loading and establishes no full-game crash-loss guarantee. Midnight, New Run and Save & Exit remain triggers of the same preservation path. Continuous 2–3-real-second durability, journals, random expedition/treatment/outage outcomes and anti-cheat remain unimplemented.

## Human playtest and review handoff

1. Verify incompatible M1 Continue is explained/disabled and cancelling New Run preserves the slot. Use a deliberately chosen M2 playtest run; executor tests have not replaced the developer's continuation.
2. Check persistent clock visibility away from Medical, normal pace, pause/zoning freeze and no offline advancement after restart.
3. Check F toggle, distinct E, wheel/numbers, red rejection and cap/waste; leave a panel open across expiry and confirm both cues close with no held action leaking into shelves or the later request. Ordinary shelf hold-E should remain reversible.
4. Observe exact authored cargo, fully OPEN TAKE and full outbound/FIFO/audio continuity at normal speed. Distinguish admission from presentation/collection and retained upstream pressure.
5. Reach midnight: inspect End of Day D totals with Day D+1 07:00 paused HUD, then ESC menu/resume without releasing the report. Begin Day should only release the prepared day, preserving organization and in-flight travel.
6. Save & Exit from the report and restart/Continue; then dismiss, Save & Exit again and verify active next-day restoration, exact carrying/selection, stack retrieval/restorage and ladder movement/rearm.
7. Subjectively assess deadline/report/warning legibility and audible cue pause/resume. The recorded Windows captures use synthetic Godot events/direct fixture operations, not native keyboard/mouse or human listening. Normal gameplay has no time-skip control; later-day/exhaustion coverage here is automated.

Author self-review covered the complete owning diff and all five handoff focus areas. The next gate is one fresh contextual review of **base → delivery HEAD**, followed by developer playtesting; neither gate is claimed complete. No new design ruling or additional-system scope was introduced. Known CF-07 debt stays disclosed.

External delivery root contains `m2-day-clock-midnight.patch`, `final-git.txt`, `commands.jsonl`, `final-verified-results.json`, `source-manifest.json`, all raw logs and `attempt-notes.txt`. Final images are in `rendered-m1-verified/` and `rendered-m2-final/`; reproducible independent-process slots/expected snapshots are in `verified-phase-pre/`, `verified-phase-report/` and `verified-phase-active/`. No licensed assets or caches are archived with the patch.

## 17 October 2026 — independent ACCEPT and final human promotion

The reviewed source is the unchanged linear candidate: base `2cad0d766930ae2d5197171146ef253eb1087ad5` → production implementation `524edf11e218f7b59fcd475e4fad42e9a04f46f5` → reviewed final delivery `c7bbf449703495ce10d36fd0c7bcf1bda745ed61`. Publication preflight confirmed the clean local candidate, exact parentage and live remote base. The local base-to-final binary/full-index patch matched SHA-256 `BEEA5686525193B11355870ED31DF9903B9ADBB632D1F2D91152A7D44111CB8B`; source was verified locally, not reconstructed from the external patch.

The independent contextual reviewer recommended **ACCEPT**, establishing **no BLOCKER or IMPORTANT correctness issue** and proposing no correction. Its fresh isolated bulk-versus-32,998-fractional-step probe reported **19 checks, zero failures, exit 0**, matching events/request timestamps and reported phase differences below 0.1 nanosecond. These are attributed independent results, not tests rerun by this publication task. Reviewer raw attachments are external; no repository path or committed-copy claim is made for them.

The developer explicitly reported **all requested final native-gameplay/playtest scenarios passed, with no issues or unexpected behavior across old and new systems**, and **HUMAN-PROMOTED / CLOSED M2**. The reported scenarios covered clock/pause, timed Medical/deadlines, Receiving, midnight report, report/Continue and established player/storage/ladder workflows. This records the human's actual report; it does not imply an exhaustive platform or audio audit.

Accepted M2 scope is one authoritative calendar/scheduler; provisional **07:00–00:00 / 150 real seconds per game hour** pacing; timed Medical occurrences and expiry; controlled authored cargo; hard-midnight Awaiting Lift cutoff; already-applied night results and report; automatic preservation through the **same save service**; HUD; pause; and Save & Exit/Continue. M1 restoration, ownership, item/receipt identity and F/E/ESC remain accepted and preserved. Approved M2 specification **v0.2** remains the design authority for this slice; active MVP master/companion remain edition **v0.3**.

The earlier implementation, failed attempts, diagnostics, evidence tables and pending handoff above are retained as historical checkpoints. The implementer's 36-command sweep, six strengthened separate-process continuation cases, rendered checks, 30 Receiving boundary/audio checks and deliberate abort canary remain **attributed prior results**. No Godot run, import scan, game regression sweep or access to the developer's `user://saves` occurs in this docs-only publication. The reported **43.84 ms** first report frame was a single-machine measurement, not a performance guarantee.

**Retained limits:** CF-07 held-material null diagnostics and the Windows certificate-store diagnostic remain disclosed non-blocking debt. Full-game continuous Ironman preservation/journaling, rotating recovery and the ideal **2–3-real-second crash-loss target remain NOT IMPLEMENTED**. The approved full-game design/randomness contract is unchanged; midnight and Save & Exit are triggers of the same preservation path, not separate save systems. M3 Kitchen, M4 Loadout, M5 combined allocation, actual expeditions/patients/outcomes and resource economy remain outside this publication and unimplemented/unrun as applicable.

**Publication checkpoint:** the developer authorized publishing M2 to `main` on 17 October 2026. This addendum precedes integration and records that authorization, not a completed push. PUBLISHED is established only after a fresh base/ancestry check, safe linear fast-forward of local `main`, normal non-force push and independent live remote `main` query. The executor's final publication report records the full resulting SHA and clean branch/worktree state. No M3 work follows this close-out.
