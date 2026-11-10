# Continuous Kitchen service

**HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE**

**Original technical handoff · 10 November 2026 · TECHNICALLY READY FOR DEVELOPER PLAYTEST · Local branch**

The first continuous Kitchen service is live in the F5 collection run. The Food and Hydration schedule uses independent integer intervals of 180–300 active seconds, including the first event. Each event proposes 60–80 Utility with the larger lane at most 1.25 times the smaller. Whole-Utility largest-remainder clipping uses event parity for ties. Unissued overflow is discarded. Both random streams advance at the cap. [Contribution decisions](../design_history/2026-11-09-contribution-effects-and-kitchen-decisions.md) · [Implementation brief](../superpowers/plans/2026-11-09-continuous-kitchen-service.md)

The single cumulative obligation gets 60 active seconds of grace from opening. Once overdue, every 3 outstanding Utility costs one percentage point of carrying capacity, up to 150 Utility and 50% loss. The player can keep a full 20-Bulk bundle at a 10-Bulk effective limit. Pickups enforce the effective limit. Failed placement restores the exact item, slot and selection. Partial credit reduces loss. Only clearance restores sprint. Ordinary walking and ladders use their existing movement paths.

F opens or toggles Kitchen at its existing Gallery B frontage. A runtime ray target matches the authored proxy and uses the movement layers for occlusion. The target adds no movement obstruction. One fresh E consumes the selected eligible whole item and commits its receipt and capped lane credit together. Escape closes the panel before pause. Live status and previews show grace, admitted demand, loss, sprint, credit and waste. The existing shared clock settles Kitchen alongside Receiving and expeditions, including after victory.

The expedition fixture still has eight Ready scavengers, 8 Bulk per member, a sixteen-item pool, 90–180-second trips, the Medical loadout lane and the six-Utility collection goal per category. The master documents separately record the future expedition bonuses and Morale lane, Fuel greyouts, Medical healing and one-time Electronics purchases. Those effects, Workshop and Rations remain future scopes.

## Publication on 10 November 2026

The accepted close-out checkpoint, `17a007d3cec793ce8a676e1d2df2ff8676554425`, was fast-forwarded onto `main` and pushed to GitHub. An independent `git ls-remote origin refs/heads/main` read returned that exact SHA. The publication uses the original gameplay and cleanup evidence for the identical tree.

## Checkout and execution

- The asset-equipped checkout and GitHub main both began at `812c316b42a4a37bb0791b6fbd2326d4ae7422d6`. The earlier inspected `856353ef7fef957e1b3b8dd1b8c607df4aff2c17` was an ancestor. The intervening commit added the supplied decision record, plan and four Incinerator image sidecars.
- Branch `codex/continuous-kitchen-service`. The documentation-first checkpoint is `fe9bd9a7431ac671156d248b5cf31e2248d0cb3f`. Kitchen state, timing and transactions are at `127de1e1ac1e5e0339f1157ea61b3cdb6d956d64`. Live integration and continuation are at `bd94a19708b702748a94be163244dc3cb1c20dd6`. Live interaction and persistence share a checkpoint so that the new service is playable with compatible continuation.
- The current local Codex chat supplied one implementer. The exact implementer model preset and reasoning effort were unavailable. One independent read-only reviewer was dispatched as GPT-6 Astra at High effort. It reported no actionable findings across timing, rollback, ownership, continuation and input. It did not run Godot or edit the checkout.
- The engine was Godot `4.7.stable.official.5b4e0cb0f`. Native probes used OpenGL 3.3 Compatibility on the RTX 5060 Ti. The editor and all runs used isolated application data and save paths.

## Continuation

Schema 8 uses the existing one-slot service under `user://saves/collection/`. Continue restores the first and next timestamps, event progress, both RNG states, obligation, grace, exact Kitchen receipts and existing physical, expedition, Incinerator and goal state. Effects apply before play resumes. Transient panels and presses are closed and cleared on Continue.

Schema 7 and earlier schemas are incompatible. The launch screen requires confirmed New Run to repoint an incompatible slot and retains the previous snapshot. Failed Continue and canceled New Run leave the old pointer intact. An isolated write blocker left the last valid schema-8 snapshot and pointer intact. The six actual save files, including both pointers and the collection and M4 snapshots, matched their before and after SHA-256 values. [Save preservation](evidence/continuous-kitchen-2026-11-10/save-preservation.json)

## Verification

| Proof | Observed result |
| --- | --- |
| Red checks | Each exited 1 at the expected gap. The Kitchen owner/config, station binding, and schema-8 snapshot field were absent at the respective checkpoints. [Operations](evidence/continuous-kitchen-2026-11-10/operations-red.log) · [Interaction](evidence/continuous-kitchen-2026-11-10/interaction-red.log) · [Continuation](evidence/continuous-kitchen-2026-11-10/continuation-red.log) |
| Operations | **2,832 checks passed.** Feasible splits for all totals 60–80, representative cap headrooms and ties, grace and clearance, exact loss/rounding, cap/waste and receipt order. Timing draws match across payments, full-cap events and different amount seeds. [Log](evidence/continuous-kitchen-2026-11-10/operations-final.log) |
| Headless interaction | **22 checks passed.** Authored wall occlusion, live F/E/ESC conventions, scheduled demand without a lift transition, normal pause and 20/10 carrying. A genuine post-removal stale fit restored the over-limit tail slot, gap and selection. [Log](evidence/continuous-kitchen-2026-11-10/interaction-headless-final.log) |
| Continuation | **216 checks passed.** Round-trips before the first event, during grace, overdue with a full bundle, after partial relief and a capped event, after clearance and after victory. A genuine Kitchen receipt validated while its source was OPEN and after retirement. Exact queued and Away cargo, the Incinerator warning and receipt, both random states and first victory survived. Forged and multiply owned state rejected. [Log](evidence/continuous-kitchen-2026-11-10/continuation-final.log) |
| Native recovery | **151 checks at 1280×720 and 148 at 2560×1421.** Both walked 1.58 m to the authored frontage and used F, number selection, distinct E, held E/echo and Escape. Real Food and Hydration entered at 10 Bulk. Measured movement over the same controller steps was 2.39 m walking or holding Shift while overdue and 3.89 m holding Shift after clearance. Both lanes cleared with generated cargo. [1280×720 log](evidence/continuous-kitchen-2026-11-10/interaction-native-720-final.log) · [Large-window log](evidence/continuous-kitchen-2026-11-10/interaction-native-1440-final.log) |
| Selected regressions | **All ten passed on valid invocations.** Collection goal and continuation (136 checks), expedition operations, Incinerator operations/interaction/continuation (29/35/116), storage commands, furniture collision, continuous-run pause and lift chronology, and startup parity. The initial startup parity command omitted its required external save argument. Its isolated rerun passed. Editor import and the configured F5 smoke also exited 0. [Editor scan](evidence/continuous-kitchen-2026-11-10/editor-import.log) · [F5 smoke](evidence/continuous-kitchen-2026-11-10/normal-f5-smoke.log) · [Raw logs](evidence/continuous-kitchen-2026-11-10/regressions/) · [Exit codes](evidence/continuous-kitchen-2026-11-10/sweep-exits.json) |
| Documentation | The GDD, Systems MVP and VDD DOCX masters were edited before regenerating the changed companion blocks. The Word paragraphs and table cells match the companions. Relevant references and affected rendered pages were checked. Final renders were 50 GDD pages, 50 MVP pages and 29 VDD pages. |

[Overdue preview at maximum loss](evidence/continuous-kitchen-2026-11-10/kitchen-overdue-1280x720.png) · [Clearance and excess Utility at the larger viewport](evidence/continuous-kitchen-2026-11-10/kitchen-cleared-2560x1421.png)

The larger window requested 2560×1440. Windows provided a 2560×1421 viewport. For recovery, the test used two genuine four-member dispatches with deterministic expedition seeds 13 and 5293. It advanced the shared clock to the actual capped obligation and through lift turnaround. It positioned the player at the authored approaches and used the ordinary storage command to stage surplus. Native reticle TAKE supplied the recovered items. A fixed count of movement-controller steps made the native key comparisons independent of frame-rate variation. The local pool remained sixteen definitions bounded by 8 Bulk.

## Limits retained

The provisional goal can complete before the first event. Continued play is available to exercise Kitchen. The recovery proof covers the current generated pool and the chosen legal hauls. Production balance and broader catalogue recovery remain open.

Autosaves still run synchronously on the 60-active-second and first-victory paths. The recorded victory attempt took about 76 ms including capture in the focused fixture. Large-stock performance, short silent Windows suspension and release crash durability retain their prior limits. Logs retain the known Windows certificate-store and held-view material-null diagnostics. The selected regressions include deliberate cargo-preparation and isolated save-write failures.

## Developer playtest

Launch from a separate PowerShell window with a fresh profile.

```powershell
$kitchenPlaytest = Join-Path $env:TEMP ("Sorting-Kitchen-" + [Guid]::NewGuid().ToString("N"))
$env:APPDATA = Join-Path $kitchenPlaytest "Roaming"
$env:LOCALAPPDATA = Join-Path $kitchenPlaytest "Local"
New-Item -ItemType Directory -Path $env:APPDATA,$env:LOCALAPPDATA -Force | Out-Null
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE'
```

1. Start New Run. Watch for the first demand after 180–300 active seconds. Open the Kitchen and check both lanes and the 60-second grace with ordinary carrying and sprint.
2. Let grace expire with a full bundle. Verify every item stays carried and the HUD shows actual Bulk over the new limit. Compare walking and Shift, and try a pickup that would exceed the limit.
3. Preview and supply selected Food and Hydration, including a surplus-Utility item near a lane's end. Check credit and waste against the displayed percentage. Confirm sprint returns only when both balances clear.
4. Keep an obligation overdue through later events. Check that the original grace stays expired, the loss caps at 50%, and a contribution at the cap does not revive discarded demand.
5. Save and Continue during grace, overdue with grandfathered carrying, and after partial or full service. Check Kitchen timing, balances and receipts along with Incinerator warning state, stock, pending cargo and first victory.
6. Use ordinary Kitchen and Incinerator trips to relieve congestion. Check shelf and ladder handling and furniture collision. Continue after victory if the short collection goal completes before enough Kitchen cycles.

## Developer acceptance on 10 November 2026

The developer explicitly promoted the first continuous Kitchen iteration from gameplay testing. These observations are attributed to the developer's playtest.

- The first demand arrived just after three minutes at 38 Food and 31 Hydration. After 60 seconds of grace, the penalty reached 23% and the carried display read 20/15. Existing items stayed carried, sprint was disabled, and new pickups respected the lower limit after legal storage reduced the carried load.
- The second demand arrived near seven minutes and added 30 Food and 30 Hydration. The balance reached 68/61 with a 43% penalty and the original grace deadline. The developer described the carried display as 15/10. The exact-state check below qualifies that denominator.
- A 1-Bulk, +3 Food contribution reduced the balances to 65/61 and the loss to 42%, with 14/11 shown. The contribution consumed the selected item and recalculated the penalty. At those exact inputs, the effective maximum stays at 11 Bulk.
- A later addition clipped to +11 Food and +13 Hydration. The balances reached 76/74, the 150-Utility ceiling, with 50% loss, 10-Bulk capacity and the original grace deadline.
- A +2 Hydration contribution lowered the debt to 148, with 10-Bulk capacity under floor rounding. The next event filled the two-Utility headroom as +1 Food and +1 Hydration from its clipped proposal. The developer expected and wanted that behavior. About ten minutes at the cap produced no further growth.
- Full clearance restored 20 Bulk and sprint. The next obligation opened with fresh grace.
- Saving and loading, goal contributions and victory, zoning, shelf handling, expedition dispatch, lift pickup and incineration remained functional in the scenarios tried.

The developer identified an emergent strategy. Supplying Hydration while Food demand accumulates can reduce waste and the number of submissions when the player later supplies a high-Utility Food item. Waiting carries a cost in time under the penalty, handling limits and exposure to the demand ceiling. This finding describes a choice available in the tested fixture. Production balance and broader catalogue recovery remain open, along with the limits recorded above.

## Capacity discrepancy checked on 10 November 2026

Kitchen computes `floor(normal_capacity * (300 - outstanding_utility) / 300)` for the overdue loss. The wing binds that value to the carried-items owner. Pickup checks and the carried HUD read the same effective limit. The Kitchen change signal refreshes the HUD on demand changes, and the contents signal refreshes it after a contribution.

The isolated headless probe ran the normal F5 shell with timing seed 10 and amount seed 19780 to obtain both narrated additions from the production sampler. Authored pickups assembled a 15-Bulk bundle including the 1-Bulk, +3 Food Canned Potatoes. The probe aimed at the real frontage, used the station request signal to open the panel under headless input, and sent E through the active panel.

| State | Kitchen phase | Effective limit | Carried HUD |
| --- | --- | --- | --- |
| 68 Food + 61 Hydration = 129 | Overdue, 43% loss | 11 Bulk | 15/11 |
| 65 Food + 61 Hydration = 126 after the contribution | Overdue, 42% loss | 11 Bulk | 14/11 |

An ordinary pickup was rejected while carrying 15 at the 11-Bulk limit. After the contribution and ordinary placement of the 4-Bulk Med Kit, the pickup path rejected a proposed total of 12 and accepted exactly 11. The reported 15/10 was not reproduced at the stated inputs. Its cause is undetermined. The arithmetic and HUD required no correction. **17 checks passed, exit 0.** [Focused probe log](evidence/continuous-kitchen-2026-11-10/closeout-capacity-129-to-126.log)

## Kitchen legacy disposition

The local branch began this close-out at `e2c5a9704217a18ae93baa378455a7e75ec56415`, with all four Kitchen checkpoints in its ancestry. A read-only remote check found main at `812c316b42a4a37bb0791b6fbd2326d4ae7422d6`. The cleanup checkpoint is `7e80d414c17c97bab6797bd799ce7f7556d8235c`.

| Candidate | Disposition | Evidence |
| --- | --- | --- |
| Meal issuance and windows, day schedule and scenario, timed validator, night report, and station adapters | Already retired | The foundation checkpoint `a1d1db4494347e0dfb4dfb653ed71b2abaf76ce5` removed these paths. The configured F5 shell binds the wing's active timeline, which settles the current Kitchen. The wing binds the dedicated panel and existing frontage. [Foundation removal record](2026-11-07-continuous-run-collection-goal-result.md#changed-and-retired-paths) |
| Old fixed-target contribution modal and its M3 meal wrapper | Removed from active source | Before cleanup, only `m1_contribution_tests.gd` and `m3_contribution_tests.gd` loaded `contribution_panel.gd`. Dispatch and Kitchen own their panels. Removed `gameplay/requests/contribution_panel.gd` and `tools/asset_pipeline/tests/m3_contribution_tests.gd` with their two UID sidecars. The reference check covered script and UID references in active code, scenes, resources and tooling. |
| Contextual request checks and two-lane Kitchen checks | Narrowly refactored | `m1_contribution_tests.gd` now exercises the shared request directly, including exact receipt ordering, contextual Utility, waste and rejection. The current Kitchen operations test covers Hydration-first clearance and full-lane rejection alongside the existing Food-first coverage. The current interaction test checks both displayed balances. |
| Shared request and exact-item transaction | Retained and actively reused | `expedition_loadout.gd` extends `contribution_request.gd` for live Dispatch preview, cap and waste, receipts and draft/expedition snapshots. Kitchen uses the same carried-items transaction. M1-named Receiving lifecycle, pause/admission and reflection probes target their own current owners. |
| Older schema diagnostics and current continuation | Retained and actively reused | The save service identifies incompatible older slots and preserves their snapshots. Schema 8 validates the live Kitchen obligation, RNG states and receipts alongside expedition loadouts and other run state. |
| Fixed meals, Daily Meal Coverage and associated dated evidence | Historical only | The frozen M4 data, plans, acceptance and source references remain available. The survival archive is excluded from the Godot scan. [Survival-era index](../design_history/survival-era/README.md) |

### Scoped verification

After the cleanup, editor import and F5/F6 startup parity exited 0. The shared request test passed 17 checks, Kitchen operations passed 2,839 checks, Kitchen interaction passed 23 checks, and expedition operations passed. All used isolated application data and save paths. The logs retain the known certificate-store and material diagnostics and the deliberate invalid-cargo case. The earlier continuation, native recovery, selected sweep and independent review remain the original implementation evidence. [Cleanup logs and reference check](evidence/continuous-kitchen-2026-11-10/closeout-legacy-checks.log)

The seven actual save files and both pre-existing untracked evidence image sidecars matched their preflight SHA-256 values. The change set leaves the approved gameplay behavior and schema 8 in place. The recorded promotion stands without a further human retest.

The close-out updates GDD §20.3 and the Systems MVP CF-16 and §17 master text, then regenerates the matching Markdown. Both DOCX files retained 50 pages. The GDD page 40 and MVP pages 26 and 28 were the only changed render pages and were inspected. The VDD still describes the current frontage and presentation. Current-state, index and bootstrap links point to this result.

### Changed paths

| Scope | Paths |
| --- | --- |
| Retired modal and wrapper | `gameplay/requests/contribution_panel.gd`, `gameplay/requests/contribution_panel.gd.uid`, `tools/asset_pipeline/tests/m3_contribution_tests.gd`, `tools/asset_pipeline/tests/m3_contribution_tests.gd.uid` |
| Retained regression coverage | `tools/asset_pipeline/tests/m1_contribution_tests.gd`, `tools/asset_pipeline/tests/kitchen_operations_tests.gd`, `tools/asset_pipeline/tests/kitchen_interaction_tests.gd` |
| Masters and generated companions | [GDD DOCX](../Sorting_Apocalypse_Preliminary_GDD_v0.16.docx) · [GDD Markdown](../readable/Sorting_Apocalypse_Preliminary_GDD_v0.16.md) · [MVP DOCX](../Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.docx) · [MVP Markdown](../Sorting_Apocalypse_Systems_MVP_Foundation_Design_and_Progress_v0.5.md) |
| Current-facing status | [Current state](../CURRENT_STATE.md) · [Documentation index](../README.md) · [Codex bootstrap](../CODEX_BOOTSTRAP.md) · [Conversation bootstrap](../Sorting_Apocalypse_Bootstrap_Prompt_Next_Session_07Nov2026.md) |
| Result and evidence | This result, [capacity probe](evidence/continuous-kitchen-2026-11-10/closeout-capacity-129-to-126.log) and [legacy verification](evidence/continuous-kitchen-2026-11-10/closeout-legacy-checks.log) |
