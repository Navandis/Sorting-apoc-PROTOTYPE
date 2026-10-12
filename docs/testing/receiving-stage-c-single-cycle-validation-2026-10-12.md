# Receiving Stage C — single-cycle technical handoff, 12 October 2026

Implemented and technically verified for human **PROMOTE / REVISE / REJECT** audiovisual review. This record does not promote Stage C or reopen closed, human-promoted C1. Physical back-to-back queued deliveries remain the next separately authorized task.

## Preflight and preserved authority

Worked in the asset-equipped `D:\Godot Projects\Sorting-apoc-PROTOTYPE`. Local and live remote `main` both resolved to `caf931746281aaa0d4e54c23e88373fe118be6ff`, a descendant of `d8d293ebf94176ddf5d31e61d9c8ebb8db2c7f8f`; `caf9317` contains the four WAV import sidecars. The checkout was clean. Implementation is on local `codex/receiving-stage-c-single-cycle`, based on that HEAD. No stash, reset, cleanup, push or merge.

The saved wing scene, shutter OPEN art pose (Y 3.142), its X/Z/basis and markers, room/set-dressing transforms, deck/profile/layout revisions, private fixture surfaces, 3.4 m Receiving reach, sixteen ordinary storage surfaces, A30WS rig/probe, four audio sources/import settings and master documents are unchanged.

## Result and owner boundaries

One additive `ReceivingLiftCycle` under `ReceivingRuntime` coordinates:
`SEALED_EMPTY → ARRIVAL → SEALED_READY → REVEALING → OPEN → CLOSING → SEALED_EMPTY`.

Normal startup creates no delivery and closes only the shutter's runtime Y to the existing Closed marker (0.086). An admitted batch is staged by the existing presenter before the cycle consumes its active-change signal. Arrival keeps TAKE disabled and the CRT deck clear. Successful staging is confirmed without an artificial SEALED_READY delay. Only the confirmed Open marker (3.1416707) enables TAKE. OPEN waits indefinitely for actual successful unloading.

Receiving WorldItems enforce interaction availability, a live cycle/endpoint guard, active batch and unreleased entry identity in the actual transfer path. Successful TAKE disables stale transfer immediately. Failed/full-bundle pickup cannot drain or close. Ordinary loose/storage mechanics remain unchanged.

Final successful TAKE closes automatically. Emptied fixtures and drained active ownership persist through closing and the full departure. Closed/latched presentation becomes IDLE while an internal busy condition remains. Retirement uses the existing post-close manager API only after departure has finished; existing FIFO promotion does not activate another physical cycle in this gate.

Four positional AudioStreamPlayer3Ds share a lift-local anchor, common attenuation and relative volume treatment. Full imported cue lengths remain arrival **20.69 s**, opening **5.96 s**, closing **7.24 s**, departure **19.12 s**. Interruption cannot shorten the nominal journey/latch budget or bypass staging, shutter endpoint or drain conditions.

W1 uses a duplicated runtime lens material: slow amber pulse during arrival/staging/opening, subdued steady green in OPEN, original unlit appearance during idle/closing. Unshaded tint follows the emission intensity so the indication remains visible on Compatibility despite the source's metallic reflections. No light source or shadow is added.

The existing CRT retains its Surface 1 binding, curved art, UVs, 704 × 400 viewport, layout/fonts/colors and ONLINE label. Only the L-01 header suffix is removed. Status/footer follow the specified six-state mapping; DECK counts unreleased individual entries, including stack/fixture members; QUEUE reports only actual waiting deposits. A small manager contents-change signal updates counts after deposits, successful releases and retirement.

The saved probe's initial UPDATE_ONCE captures the runtime-closed startup pose. Existing batch/TAKE hooks remain; explicit requests follow settled OPEN, closed/latched and concealed retirement boundaries. No per-frame refresh, new probe or GPU-completion claim.

## Verification

Godot **4.7.stable.official.5b4e0cb0f**, Compatibility; rendered checks used OpenGL 3.3 on RTX 5060 Ti. Commands ran from the authoritative checkout. Raw logs and six final state images are local/ignored under `reports/receiving/stage_c_2026-10-12/`.

**25 regression suites PASS**, with exits and diagnostic output inspected. The one final sweep was followed only by checks affected by corrections:

| Area | Suites under tools/asset_pipeline/tests/ |
| --- | --- |
| New cycle | receiving_lift_cycle_tests.gd |
| Existing batch/identity/source contracts | receiving_loot_batch, receiving_manager, receiving_stage_a_integration, receiving_item_identity, receiving_preparation_contract, receiving_prototype_loot_source, receiving_prototype_loot_pool |
| Presentation and fixtures | receiving_deck_layout, receiving_deck_presenter, receiving_freight_fixture_policy, receiving_freight_fixture_runtime, receiving_deck_metric, receiving_contact_seating, receiving_freight_reach |
| Installation/theatre preservation | receiving_lift_installation, receiving_lift_crt, receiving_reflections_integration, receiving_lighting_integration, receiving_set_dressing_collision |
| Ordinary storage/composition/startup | storage_stack_surface, storage_stack_rules, storage_stacking_interaction, wing_gameplay_composition, wing_startup_parity |

Abbreviated suite names in the table have the suffix `_tests.gd`. Final evidence uses `validated_receiving_lift_cycle.log`, `validated_receiving_lighting_integration.log`, `corrected_*.log` where present, and the other `final_*.log` sweep logs.

Additional checks:

- Actual CLI debug arguments: PASS; exact 24-item mixed load enters ARRIVAL with TAKE disabled (`cli_debug_startup.log`).
- Normal configured UID and explicit canonical CLI launch: exit 0, no errors; startup parity verifies unique UID resolution, no synthetic cargo and runtime closure. Fresh native editor F5/F6 clicks were not automated.
- Full real-time rendered cycle: PASS, no ERROR/SCRIPT ERROR/WARNING diagnostics (`cycle_realtime_final.log`). Last run reached READY/REVEALING at 20.93 s, OPEN at 26.55 s, CLOSING after actual automated unloading at 28.16 s, IDLE/departure at 35.55 s, and completed turnaround at approximately 55.14 s including test waits/captures. No test-time shortening of cues.
- CRT renderer proof: PASS for configured UID and explicit canonical scene, both 704 × 400 with 3,924 sampled phosphor pixels (`crt_opengl.log`).
- Editor import/class registration: exit 0, no script errors (`editor_first.log`).
- One consolidated read-only review: no actionable correctness findings. Minor EOF whitespace corrected. No second review hierarchy.

The new cycle test first failed because the coordinator was absent. Focused checks caught and corrected the release/readout signal-order issue. Redundant startup refresh and premature harness teardown diagnostics were corrected and affected suites rerun. Three retained final diagnostics are intentional existing rejection fixtures: one duplicate visual-path error in prototype loot-source tests and two duplicate seed-namespace errors in composition tests; all assert the corresponding rejection.

Earlier rendered automation created and destroyed the selected held view in the same test frame and logged GLES3 material-null errors. Controlled otherwise-identical probes reproduced errors with held view enabled and none with it disabled. The full cycle renderer harness disables that view; the playable wing and held-view code are unchanged. This is a disclosed automation limitation, not an error-free claim for those earlier runs. Their logs remain available. Human review should exercise ordinary carrying and storing.

## Human playtest

Run this PowerShell command:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' -- --receiving-deck-debug --receiving-content-seed=1842 --receiving-presentation-seed=9001 --receiving-target-bulk=24 --receiving-fixture-mode=mixed
```

Walk to Receiving during the incoming journey. Watch/hear the closed amber-pulsing installation, controlled opening and live CRT. Try pickup while moving; it must be unavailable. Unload through normal TAKE once fully open, using ordinary storage/sorting as needed. Leave an item behind or fill the carried bundle to confirm the lift stays OPEN. The final successful TAKE must close/latch automatically, extinguish W1 and begin departure while the CRT returns to IDLE. No button or acknowledgement is needed.

Without the debug arguments, ordinary startup is idle and awaits admission. The existing runtime method `run_debug_delivery(1842, 9001, 24, 3)` also triggers the mixed prototype batch explicitly.

Inspect `ReceivingRuntime/ReceivingLiftCycle` to tune: arrival/open overlap (0.65 s); opening delay/duration (0.15/5.30 s); closing delay/duration (0.15/5.60 s); amber period/energy (2.8 s/0.85); green energy (0.35); colors; common audio volume (-3 dB), unit size (3 m) and maximum distance (22 m). Change saved overrides and relaunch for audio tuning. Cues/imports are unchanged.

Human judgement remains pending for synchronization, sound balance near Receiving versus elsewhere, journey pacing, warning intensity/color, CRT readability and ordinary unloading/storage. Accepted C1 first-probe/first-cargo costs remain known prototype debt; no new performance threshold or optimization is claimed. Unrelated Gallery A navigation debt was not repaired or retested.

## Targeted changed files

- `gameplay/logistics_wing/receiving/receiving_lift_cycle.gd`, its UID, and `receiving_lift_cycle.tscn`: coordinator and four cue players.
- `receiving_runtime.gd/.tscn`: additive composition/configuration; controlled debug admission.
- `receiving_deck_presenter.gd`: staged readiness and authoritative Receiving entry/cycle guards.
- `receiving_lift_phosphor_display.gd/.tscn`: live text and header/footer corrections.
- `receiving/receiving_manager.gd`: additive live contents-change notification.
- `world_item.gd`: Receiving-only direct/stale transfer enforcement.
- `tools/asset_pipeline/tests/receiving_lift_cycle_tests.gd` and its UID: cycle, CLI and rendered variants.
- Existing `receiving_deck_presenter_tests.gd`, `receiving_freight_reach_tests.gd`, `receiving_reflections_integration_tests.gd`, `wing_startup_parity_tests.gd`: retain original invariants while adapting reveal timing.
- This validation record.

Stop at this first-cycle handoff. No physical queued-delivery demonstration, push, merge, branch deletion or automatic follow-up.
