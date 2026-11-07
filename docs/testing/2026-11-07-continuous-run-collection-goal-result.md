# Continuous Run and Collection Goal Foundation

**7 November 2026 | HUMAN-ACCEPTED / CLOSED IN ITS BOUNDED SCOPE | LOCAL CHECKPOINT / PUBLICATION PENDING**

Normal F5 New Run and Continue use the continuous collection run. The playable loop, lift, goal and ordinary continuation passed the checks below. A short Windows suspension without a notification remains a timing limit. A separate read-only review found that edge and a released-cargo validation gap. The latter was reproduced, corrected and retested. The developer accepted the bounded slice after in-game testing. [Close-out and checkpoint](2026-11-07-continuous-run-collection-goal-closure.md).

## Fixture and storage

The provisional common target is **6 authored primary Utility** across all eight categories. Both hauls use the existing preparation and upstream admission paths. The original loose seed palette remains available and begins outside the stored totals.

| Active offset | Occurrence | Exact development supply |
| --- | --- | --- |
| 3 s | `collection_supply_01` | Computer Card, 2 Canned Potatoes, 2 Cola Cans, Antibiotics |
| 45 s | `collection_supply_02` | 2 Lighter Fluid Cans, Book 01, Work Boots, Brass Knuckles, Computer Mouse |

Fixture and scoring rule revision are both 1. The authored primary category matched the Storage Category across all 167 active definitions. The catalogue and its physical and numerical authoring were preserved. The ordinary 20 Bulk carry limit was used.

All 16 qualifying surfaces are explicitly registered by installed unit in `wing_gameplay.tscn`.

| Qualifying unit | Surfaces |
| --- | --- |
| `SM_MetalShelves_GalleryA_West` | `_level_1` through `_level_4` |
| `SM_MetalShelves_GalleryB_North` | `_level_1` through `_level_4` |
| `SM_ventilated_locker_GalleryC_West` | `_level_1` through `_level_4` |
| `ModularRack_GalleryB_Initial` | `_Shelf_01` through `_Shelf_04` |

Excluded installations include the SortingTable proxy, SeedWest and SeedEast tables, Food and Hydration palette tables, and the Medical, Kitchen and Dispatch frontages. These are staging or room props. Receiving's `MainDeck` and any generated private crate or pallet surfaces are excluded. Carry, loose seeds and deposited or upstream cargo remain separate owners.

The goal test took all 12 exact items through the production reticle and TAKE path. The furthest tested TAKE was **1.355 m** at the existing 3.4 m reach. Normal placement on Gallery A West level 2 yielded Electronics 14, Food 6, Fuel 6, Hydration 6, Medical 8, Morale 8, Protection 7 and Weapons 6, with the surplus mouse carried. First completion was recorded at 144.25 active seconds with upstream cargo waiting. The test also covered stacked members, manual zone mismatch, zone erase, shelf-to-shelf movement, rollback, a category falling below target, and continued play after completion.

## Changed and retired paths

| Owner | Local disposition |
| --- | --- |
| `gameplay/run/` | Monotonic clock, finite controlled supply, settled goal and HUD. The shell retains confirmation, nested pause, Continue and Save & Exit. Schema 5 stores time, fixture progress, target, completion and the last auto-save attempt in the existing snapshot, codec and service. |
| `gameplay/logistics_wing/`, `storage_surface.gd`, `storage_placement_controller.gd`, `world_item.gd`, `player_controller.gd` | Explicit collection storage and successful TAKE/PUT notifications. Physical ownership, placement, camera, lift, CRT counts and authored stock stay in their existing owners. Medical, Kitchen and Dispatch show inactive labels. CRT waiting and arrival footers refer to cargo. |
| `receiving/awaiting_lift_admission.gd` | Oldest-first admission survives one active and two deposited slots. Waiting cargo persists across former cutoffs. The lift finishes the full outbound leg before retirement and promotion. |
| `gameplay/run/`, `gameplay/requests/` | Removed the day schedule and scenario, timed state validator, day HUD, night report, station adapters, Dispatch loadout/carousel and M4 starting-manifest initializer. Retained whole-item contribution and receipt logic in the shared request and panel. |
| `tools/asset_pipeline/tests/` | Added three collection foundation scripts. Retired 35 scenario-bound scripts and helpers and their UID sidecars. Retained the live physical, carry and request regressions. |
| `docs/design_history/survival-era/` | Relocated the four prior plans and the tracked frozen M4 packet with original hashes, source paths and pinned revisions. Archived scripts remain available through Git. The archive is excluded from the Godot scan. |

[Historical index](../design_history/survival-era/README.md) · [Approved brief and Appendix A](../superpowers/plans/2026-11-07-continuous-run-collection-goal-foundation.md)

## Verification

Asset-equipped checkout `D:\Godot Projects\Sorting-apoc-PROTOTYPE`, clean tracked and untracked status at entry, on local `main` at `d802de64bf7a28bdf9d410be2c87d9dcf306b3d2`. Baseline startup passed using `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`, version `4.7.stable.official.5b4e0cb0f`. Exact Codex model variant and reasoning effort were unavailable in the execution metadata.

Each script ran as `Godot --headless --path <project> --script res://tools/asset_pipeline/tests/<name>.gd`. Startup parity also received `-- --m1-save-dir=<temporary directory>`. All saves used isolated temporary directories. The final successful results comprise one sweep plus affected checks rerun after corrections.

| Check | Exit and result |
| --- | --- |
| `continuous_run_foundation_tests` | 0, PASS, 0 failures. Crossed 600 and 2,700 s in ordinary steps and 5,400 s in a large advance. A remained active, two deposits stayed finite, and waiting D admitted after full outbound. The real-frame sample was 0.249031 active s over 0.253680 wall s. |
| `collection_goal_tests` | 0, PASS, 0 failures. Exact 12-item reticle and storage witness above. |
| `collection_continuation_tests` | 0, PASS, 76 checks, 0 failures. Mid-arrival, partial OPEN, closing and outbound round trips, exact zoning/pose/ladder/carry/cargo state, distinct saved target, nested holds and resume, blocked save recovery, malformed saves, coalesced and independent victory attempts, and completion preserved after stock removal. |
| `wing_startup_parity_tests`, `storage_command_validation_tests`, `storage_semantic_zoning_tests`, `storage_stacking_interaction_tests`, `wing_storage_bridge_interaction_tests`, `fixed_ladder_player_tests` | Each 0, PASS. |
| `receiving_awaiting_lift_tests`, `receiving_awaiting_lift_integration_tests`, `receiving_lift_cycle_tests` | Each 0, PASS, 0 failures. Includes six-state ordering, CRT, cue and stale TAKE checks. |
| `m1_pause_admission_tests`, `m1_contribution_tests`, `m3_contribution_tests`, `snapshot_catalogue_tests`, `wing_seed_fixture_tests` | Each 0, PASS or COMPLETE with 0 failures. The contribution tests ran 27 and 24 checks, and the catalogue fingerprint test ran 6. |
| `--headless --editor --import --quit` and normal F5 scene via `--headless --quit-after 5` | Each 0. One canonical wing UID in the startup check. |
| Native Compatibility render at 1280 × 720 | 0, PASS, 78 checks before the subsequent released-cargo validator correction. Inspected OPEN Receiving and completed-goal HUD captures, with the intentionally distinct saved target of 5. Audio stream pause/resume was asserted. Audible playback remains part of the human check. |

Red tests reproduced the old midnight clamp and forfeiture, absent goal, prior save namespace, and malformed released-cargo acceptance. The first sweep exposed an unsuitable headless timer in the wall-time probe and two inherited Receiving assertions that used Bulk as the expected item count. The targeted reruns used actual wall samples and committed entries. The original logs and earlier evidence remain available.

Logs were inspected for errors as well as completion markers. The Windows certificate-store error occurred on the pre-edit baseline too. The deliberate failed save, corrupted waiting commitment and invalid seed fixtures emitted their expected diagnostics. The implementation logs and two selected captures were copied byte-for-byte into [durable evidence](evidence/continuous-run-foundation-2026-11-07/README.md). The first sweep logs are in `final-sweep`. The three corrected checks are the `final-*.log` files. [SHA-256 manifest](evidence/continuous-run-foundation-2026-11-07/SHA256SUMS.txt).

## Continuation and limits

Schema 5 writes only in `user://saves/collection/` on the normal path. The launch menu explains the legacy slot. The Windows roaming M4 pointer and pointed snapshot had identical SHA-256 hashes before and after execution.

| Original file under `user://saves/` | SHA-256 |
| --- | --- |
| `active-slot.json` | `4159CE329A1EAC5CC539D915446CB45A531FC6057B1FD73E6B2EDD5528045B63` |
| `Save_341c889e7e8615bdfd79ea00_251026-17-33.json` | `0EE5AF7408DFC0EC4435C4CF4D890DE54F50C9EAA6D2F56B7D8E60D93E65E168` |

Auto-save attempts occur after 60 active seconds since the last automatic attempt and at first victory. A due interval and victory share one write. Manual Save & Exit preserves the interval position. The final successful headless samples took **55.7–63.7 ms** synchronously, including **6.8–7.5 ms** for capture, **24.8–27.7 ms** for validation and staged decoding, and **8.1–9.7 ms** for file writes. This can cause a brief hitch. A failed attempt keeps the previous continuation and waits for the next normal attempt or manual Save & Exit. The policy provides prototype continuation. Release durability and economy calibration require separate evidence.

Ordinary focus loss keeps time active. Loading and menu/zoning pauses rebase monotonic sampling, and offline time starts from the saved elapsed value. A silent sample gap of at least 10 seconds is discarded across the run and lift. A shorter silent Windows suspension can count as active time because this desktop build exposes no application-suspend notification. This is a remaining platform limit. [Godot lifecycle notifications](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-constant-notification-application-resumed) · [Windows performance counter behavior](https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps)

The finite hauls establish only this development supply loop and a small attainable collection. The later expedition lifecycle is recorded in Appendix A. Actual expedition implementation and production collection balance remain separate scopes.

## Developer acceptance

**7 November 2026. HUMAN-ACCEPTED / CLOSED IN ITS BOUNDED SCOPE.** The developer reported the following observations from in-game play.

- Save and reload worked before victory and after victory during continued play. In the tested intentional terminations, Continue recovered the latest minute-scale automatic save. The observation is scoped to those cases. Exact boundary saving, crash-during-write safety and seconds-scale durability remain unverified.
- Zoning, placing, stacking, auto-stacking and manual placement behaved correctly. Adding and removing qualifying stock updated the totals, including loose pre-seeded bunker items after storage. Carried items earned zero credit. Creating, deleting and changing zones left the totals of already-stored items intact.
- Seven over-target categories could not cover an eighth below target. The first victory recorded a fixed completion time, and both the live totals and the run clock continued changing afterward.
- The lift, monitor and delivery presentation behaved as expected. The developer observed no issues or abnormal behavior in the situations tested.

These are developer observations. The technical results and the independent read-only review above retain their original scope and chronology.

## Playtest checklist used for handoff

1. Start a collection run from F5. Go to Receiving and try a TAKE before the shutter fully opens. After OPEN, leave an item on the deck until the second haul is queued at 45 active seconds. Check the CRT shows one deposit, then Save & Exit and Continue.
2. Use LMB to TAKE and E to store on an ordinary shelf. On a fresh shelf, open zoning and keep General for an easy fit. Store both Food cans, retrieve one, and check Food falls from 6 to 3. Put it back and finish the other categories. Watch the first completion appear, then remove a scoring item and check the clock continues and the completion time stays recorded.
3. During a lift cue, pause with ESC and check the shutter and sound resume from the held point. Check zoning with O pauses the same clock and closes cleanly. Check the development supply HUD and inactive Medical, Kitchen and Dispatch signs while moving through the wing.
