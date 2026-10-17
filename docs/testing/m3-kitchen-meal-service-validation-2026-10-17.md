# M3 Kitchen Meal Service — local technical candidate, 17 October 2026

**Technically verified local M3 candidate; independent contextual review and developer playtest pending. M1/M2 remain HUMAN-PROMOTED / PUBLISHED / CLOSED. No M3 publication.**

Base: `3465098d1910be0bb697416cb4e8bf6d1058cfb8`. Branch: `codex/m3-kitchen-meal-service` in the authoritative asset-equipped `D:/Godot Projects/Sorting-apoc-PROTOTYPE`. Initial clean checkout and live remote main matched; final read-only remote check still matched. Git schannel's credential error was bypassed using the OpenSSL backend without disabling certificate verification. All five worktrees retained; no reset, stash, cleanup, push, merge or PR. No scenes, source art, licensed assets, master documents or generated companions were edited.

Engine: `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`, `4.7.stable.official.5b4e0cb0f`, Compatibility. SHA-256: `D8055FB8C7E7F5010D7439EC69BE051554055DAE55A265F8647BD7301C34161C`. Rendered tests used Windows/OpenGL 3.3, NVIDIA RTX 5060 Ti, driver 617.14. Headless owner tests used the same executable with `--headless --rendering-method gl_compatibility`. The original wing scene's Git blob remains `512aa41af3b0f5e312d9365d7670f29258b1abfc`.

Authority: the externally approved M3 v0.2 and Systems MVP v0.4 companions under `C:/Users/Boschetar/Dropbox/Sorting Apocalypse/`, the pasted implementation assignment, and `docs/AI_WORKING_GUIDELINES.md`. One implementer; no reviewer dispatch. Source-led plan: `docs/superpowers/plans/2026-10-17-m3-kitchen-meal-service.md`.

## Delivered behavior

The existing request, transaction, station script, panel, scheduler, report and preservation owners now serve Medical and Kitchen. The player identifies the single panel owning input; expiry/rebinding at one station cannot hijack the other. Kitchen displays both Food/Hydration rows, adaptive pips, actual-lane preview/rejection and whole-item cap/waste. Receipt publication remains inside the carrying transaction before notifications. Shared history rejects already-spent identities at runtime and during snapshot validation.

New runs capture scenario revision 3 and snapshot schema 3. There are nine meals, three unchanged Medical windows and twelve exact 16-item/16-Bulk return attempts; approved A/B/C/D order and seeds 9101–9112 are unchanged. All manifests proved feasible without substitutions or Receiving changes. Only the 13 approved primary Utility pairs were added to ItemDefinitions. `loot_000019` remains named **Food Can**, Storage Category **Hydration**, primary **Hydration +3**, with no compensating override. Its misleading name remains later authoring debt. Medical +5/+3/+8 and all physical item data remain unchanged.

Midnight captures all six positive-target meal lanes before next-day activation and saves through the existing service. Coverage uses equally weighted capped fractions; the unequal-target example yields **50.0%**, and a day with no scheduled meals yields **N/A**. Exact integers, histories and report survive Continue. No outcomes, Workshop effects, ration production, M4, additional clock/inventory/save service, migration or continuous Ironman system was added. Prior-schema Continue reports incompatibility; no M2-save migration/test was performed.

Focused numerical regressions exposed two different rounding directions when one advance is split over mechanical boundaries. The final scheduler retains the original remaining delta for lift mechanics and anchors the final calendar coordinate to one absolute endpoint before settling endpoint work. It neither adds a tolerance window nor shortens a lift phase. Both the missed-09:00 fractional case and exact remaining-closing-duration case were observed failing, then passing; midnight cutoff and bulk/fractional equivalence also pass.

## Isolation and evidence

Fresh external evidence root: **`C:/Users/Boschetar/.codex/attachments/m3-2026-10-17-a`**. Its ancestors and all five worktree paths were checked for reparse aliases and containment before tests. Every shell received an injected external SaveService before entering the tree. Tests ran serially; only executor-owned sessions were interrupted. The developer's actual `user://saves` continuation was never read, replaced, migrated or deleted.

The external root contains `commands.txt` (arguments/exits), paired `.console.log`/`.engine.log` files, `final-results.json` (the exact counted run list, completions and diagnostics), authority/engine hashes, separate-process expected snapshots and slots, selected screenshots, and final `base-to-final.patch`, `SHA256SUMS.txt`, `final-git.txt`. The latter records the actual delivery SHA without embedding a self-referencing commit ID here.

**27 completed proof runs passed their completion markers and exit 0.** This is 19 affected owner/regression suites, one unchanged-source cargo proof, four separate writer/reader processes, and three rendered suites. Relevant same-source results were retained rather than rerun after documentation or unrelated fixture changes. Baseline M1 contribution was separately 27 checks/zero failures/exit 0.

| Final proof / log stem | Result | What it proves |
| --- | --- | --- |
| `final-m3_kitchen_tests` | 71 checks, 0 failures | 13 Utility values, retained 019 data/Medical overrides; all schedules, basket counts/Bulk/Utility/order; overlap and partial-meal validation |
| `final-3-m3_contribution_tests` | 24, 0 | Both lane orders, full-lane rejection, no redirection; receipt/credit visible before carrying notifications |
| `final-3-m3_schedule_tests` | 43, 0 | Concurrent destinations; real seed spending; global spent IDs; exact manifest binding; valid one-full-lane snapshot; 50/100/0/N/A; all three days/exhaustion; bulk/fractional chronology and mechanical endpoint |
| `cargo` | 2221, 0 | All 12 exact preparations and 192 distinct items progressively exposed through production rays/TAKE, normal reach and barrier clearance, original fixtures and full-OPEN gate |
| `final-process-write-partial` / `read-partial` | 24 / 17, 0 | Separate processes restore simultaneous partial Medical/Kitchen, exact physical organization and partly unloaded larger cargo, without replay |
| `final-process-write-report` / `read-report` | 24 / 17, 0 | Exact old-day meal report, prepared day and report hold across processes; actual restored retrieve/restow, ladder climb/release/rearm, cargo TAKE and fresh allocation |
| `final-render-m3` | 50, 0 | Both real stations, F/E/ESC and held/echo guards, click-through rejection, number/wheel selection, Medical expiry isolation, Food-full rejection, deadline and report/Continue; both resolutions |
| `final-render-2-m1` | 63, 0 | Medical preview/cap/rejection/continuation, panel-first ESC, nested pause, closure cues and reversible shelf hold-E |
| `final-render-2-m2` | 36, 0 | Deadline/expiry/HUD, expanded report, report menu/Continue, failed-save warning and layout at both resolutions |
| `final-m1_contribution_tests`, `final-m1_persistence_tests`, `final-m1_menu_tests` | 27 / 26 / 23, 0 | Accepted transactions, physical/save/codec integrity, menu/reset/failure/pause ownership |
| `final-m2_clock_tests`, `final-m2_request_tests`, `final-3-m2_schedule_tests` | 15 / 24 / 18, 0 | Clock/configuration, Medical history/adjacency, same-time ordering and next-day boundaries using explicit fresh schema-3 synthetic mechanical fixture |
| `final-m2_night_tests`, `final-2-m2_failure_tests` | 15 / 16, 0 | Read-only report hold/acknowledgment; real failed pointer replacement preserves previous bytes; warning, fail-paused Save & Exit, invalid initialization/preparation |
| `final-3-m2_receiving_boundary_tests`, `final-3-m1_receiving_continuation_tests` | 30 / 71, 0 | Strict pre-/at-midnight admission, no overnight advancement, logical cue hold, all retained cargo phases, full outbound/FIFO and accepted reflection lifetime behavior |
| `final-3-m1_pause_admission_tests` | Complete, 0 | Existing Awaiting fairness and pause admission |
| `final-3-wing_startup_parity_tests`, `final-3-storage_command_validation_tests`, `final-3-fixed_ladder_player_tests`, `final-3-receiving_queued_delivery_tests`, `final-3-receiving_awaiting_lift_integration_tests` | PASS, exit 0 each | Startup/UID composition, real storage guards, ordinary ladder, deposited FIFO and upstream integration |

The cargo fixture reuses the established reach probe: it selects exposed rays from normal lateral stances and calls actual player pickup at the unchanged 3.4 m Receiving setting (ordinary loose/storage 1.4/2.3 m). It clears fixture carrying after each TAKE to measure every entry. This proves progressive presentation/access, not an increase to player capacity. Its planner/presenter/content/test source was unchanged after this run.

Windows captures were visually inspected for centered/contained rows, pips, cap/waste, red rejection, six-lane report and warning. Selected files: `final-render-m3/01-kitchen-waste-1920.png`, `02-kitchen-waste-1280.png`, `03-kitchen-full-food-1280.png`, `04-kitchen-ineligible-1280.png`, `05-meal-report-1280.png`, `06-meal-report-1920.png`; `final-render-2-m2/10-warning-1280.png`. These are synthetic engine input/fixture proofs, **not native keyboard/mouse or human hearing acceptance**.

## Performance and diagnostics

All twelve real manifest preparations measured **3.355–3.966 ms** in the warmed cargo run. Final M3 rendering with three deposited 16-item batches measured resolution **2.822 ms**, snapshot **1.812 ms**, save/validation/write **57.311 ms** (disk operation **11.326 ms**), report setup **1.296 ms**, response **63.243 ms**, first report frame **76.108 ms**. Separate-process report writing with partly unloaded cargo measured response **60.219 ms**. These are contextual single-machine observations, not guarantees; M2's historical 43.84 ms frame was not extrapolated. Existing `M2_MIDNIGHT_TIMING`/`M2_REPORT_FIRST_FRAME_MS` marker names remain on the shared owners.

Both console and engine diagnostics were inspected. Known scoped certificate signature: `Failed to read the root certificate store` at `os_windows.cpp:2582`. CF-07 material-null diagnostics remain: **36** in final M3 rendering, **16** in final M1 rendering, **4** in final M2 rendering (console counts, not double-counted engine copies), at `material_casts_shadows:2592`, `material_is_animated:2579`, `material_get_instance_shader_parameters:2618`, `material_update_dependency:2630`. No blanket suppression or rendering repair was introduced.

Intentional final failures are the menu fixture's rejected `missing_seed_definition`, the failure suite's obstructed pointer replacement, and the rendered warning fixture's blocked save root. All were checked against their named assertions. No other final functional failure, script error or leak signature was found. `git diff --check` passed.

Failed/aborted attempts remain externally preserved and are not counted: expected content/collector/binding REDs; unavailable Windows Python alias/edit-script typo; initial nil breakfast after a fractional boundary; the first calendar-only fix shortening a mechanical endpoint; an outdated return-array index in the failure fixture; Book selection omitted in the first render fixture; and the original M1 first capture lacking its fresh evidence directory. Focused reproductions and corrected completed runs supersede these, rather than their exit status being reclassified.

## Independent review and developer playtest

Review the complete **base → delivery HEAD** diff against the external approved v0.2/v0.4 designs and this plan/record; the user arranges one fresh contextual review. Author self-inspection and tests are not an independent review.

1. Launch the normal project entry. Use a deliberately chosen fresh M3 New Run; confirm old Continue incompatibility and cancellation/overwrite behavior before replacing any personal continuation.
2. Play at least one normal-speed day: 07:00–00:00, 150 real seconds/game hour, meals at 09:00/14:00/18:00, four return attempts at 08:30/12:45/17:30/22:15. Observe active work, route usability, repeated item submissions, reserve buildup and whether cargo pressure is appropriate. This fixture is supply-positive, not final survival balance.
3. During overlapping Medical/Kitchen, check both lane orders, a full Food lane with incomplete Hydration, wrong items, cap/waste, wheel/numbers, F toggle, distinct E, ESC panel-first/menu, no held repetition/click-through, and ordinary reversible shelf hold-E. Leave a panel open through its deadline.
4. Observe audible cue pause/resume and complete outbound before FIFO promotion. Leave cargo behind, reach midnight, inspect all six supplied/required pairs, open/close the report menu, then Continue a pending report and verify actual stock, ladder and stored poses. After Day 3, existing stock continues without new authored events and subsequent coverage is N/A.

No M3 promotion/publication is implied. Full-game continuous Ironman durability, CF-07, misleading 019 naming and final economy/workload tuning remain outside this delivery.

## 17 October 2026 — human-playtest UI/input follow-up

The original candidate `7d3d6c7b710fa0a822848e3ee6d67d8761efe0d0` subsequently received independent **ACCEPT**, with no BLOCKER/IMPORTANT correctness issue established and a fresh 33-check boundary probe passing with exit 0. That review and all original evidence remain intact. The developer then reported other requested behaviors manually validated and four corrections: Firewood rejected only the Food row visually; released W left movement after a request panel closed; zoning ESC opened the Game Menu; and contribution/zoning close-key hints were redundant. The supplied follow-up attachment was text-only; the captures below are new synthetic fixtures, not the developer's recording. M3 remains **not human-promoted / not published**.

Preflight again found the clean feature branch at `7d3d6c7`, all five existing worktrees, and live remote main at `3465098d1910be0bb697416cb4e8bf6d1058cfb8`. The process-list fallback found no running Godot process; the CIM query was access-denied. No reset, stash, branch switch, other-worktree change or process termination was used. The follow-up is a new linear commit, not an amendment; its exact delivery HEAD and clean final status are recorded externally in `final-git.txt`.

### Correction and causal evidence

- Shared preview now distinguishes an item with no usable Utility from a recognized full lane. The former highlights all request lanes red; the latter highlights only that lane. Committed fill stays green, eligible projection stays on its lane, and rejection spends nothing. Utility values, receipts and eligibility rules are unchanged.
- Actual synthetic W/F input reproduced stale locomotion at both real stations: after W was released during the panel, F, ESC and expiry each left about **0.02 m** of horizontal travel. Direct key state was false; velocity had remained `(0, 0, -1.2)` while physics returned early. Opening a contribution panel now clears locomotion. Ordinary ESC pause reproduced the same mechanism, so explicit Game Menu opening also clears it. Continue and general pause synchronization do not clear saved velocity. Held W resumes normally after close; no player/ladder serialization change was made.
- The run shell routes a distinct ESC to zoning before contribution/menu handling. Zoning cancels its clear confirmation first, otherwise closes itself; O remains supported. Independent pause owners, cursor capture and the report hold remain authoritative.
- Removed only the redundant contribution close-instruction line and zoning `[O / ESC] CLOSE` label. The selected-item instruction, buttons, shortcuts, category explanation and tooltips remain.

### Focused verification

Fresh external evidence: **`C:/Users/Boschetar/.codex/attachments/m3-ui-followup-2026-10-17-a`**. All shell SaveServices were injected to this root before entering the tree; the developer's actual `user://saves` was untouched. Godot remains `4.7.stable.official.5b4e0cb0f` / Compatibility, with the original recorded executable hash.

| Final log stem | Completed result / actual exit |
| --- | --- |
| `green-2` — new `m3_modal_followup_tests.gd` | **233 checks, 0 failures / 0** |
| `m3-contribution` | 24 checks, 0 failures / 0 |
| `m1-menu` | 23 checks, 0 failures / 0 |
| `m2-night` | 15 checks, 0 failures / 0 |
| `fixed-ladder` | PASS / 0 |
| `m1-rendered-2` | 63 checks, 0 failures / 0 |
| `m3-rendered` | 50 checks, 0 failures / 0 |

The new suite checks both rejection scopes and lane orders, unchanged Medical feedback, exact item retention/one receipt, neutral empty selection, both stations with W released before F/ESC/expiry close, six post-close physics frames, and W held across close. It covers zoning-first ESC, release/echo suppression, O, clear-confirmation precedence, independent pause owners, ordinary menu drift, exact nonzero saved-velocity restoration, real reversible shelf hold-E, report menu/Continue and helper completion. Existing affected-owner tests cover normal transactions, storage/ladder, lift audio stream pause and remaining F/E/ESC paths. No 27-run full sweep was repeated.

The initial RED run completed **179 checks / 29 failures / exit 1**. An initial corrected attempt failed with exit 1 due to a new inferred-boolean GDScript parse error; the declaration was corrected explicitly, and this attempt is not counted as passing. The first legacy M1 rendered run completed **63 checks / 1 failure / exit 1** because its fixture used ESC to create the now-forbidden menu behind zoning. It now explicitly acquires a separate menu hold and verifies that zoning ESC preserves that hold/cursor. All failed attempts and raw logs remain preserved. The new suite also checks that all eleven sections complete, alongside its watchdog and failure exit.

Both console and engine logs were inspected. Final scoped diagnostics are the known certificate-store error at `os_windows.cpp:2582`; the intentional `missing_seed_definition` rejection in `m1-menu`; and CF-07 material-null messages, **16** in `m1-rendered-2` and **36** in `m3-rendered` (console counts), at GLES3 material-storage lines 2592/2579/2618/2630. No new script error, assertion failure or leak signature remains in final runs. `git diff --check` passes.

Six selected captures under `green-2/` were rendered and visually inspected: `kitchen-ineligible-{1920,1280}.png`, `medical-ineligible-{1920,1280}.png`, and `zoning-{1920,1280}.png`. Shared panels are centered/contained; rejection preserves green committed fill, the redundant labels are absent, and Close controls remain reachable. These compact preview fixtures use test targets, not changed scenario targets. `commands.txt`, result JSON, paired raw logs, `corrective.patch` (`7d3d6c7` → delivery), and `base-to-final.patch` (published M2 → delivery) are external delivery evidence.

### Preservation and next gate

No scenario, schedule, Utility/Bulk data, cargo identity/capacity/reach, save schema, authored scene/art, licensed asset, master DOCX/Markdown or continuous Ironman work changed. M1/M2 accepted dispositions, M3's nine meals/three Medical windows/twelve 16-item returns, and `loot_000019` Hydration +3 / unchanged **Food Can** name remain preserved.

**M4 design follow-up only:** evaluate provisional authored Bulk for physical items against the player's **10-Bulk** carry limit, Expedition outgoing/team load and return capacity, and feasibility/compatibility of larger Receiving manifests. No Bulk rebalance or M4/M5 scenario was implemented here. CF-07, certificate-store and item-name debt remain separate.

Synthetic input is not conclusive native-keyboard/mouse or human-hearing verification. This implementer verification does not independently accept its own correction. The next gate is **one focused independent review of `7d3d6c7` → final candidate**, plus developer retest of the four observations. Human promotion and any Git publication require a later explicit authorization; no merge, push or PR was performed.
