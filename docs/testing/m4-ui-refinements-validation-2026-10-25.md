# M4 report and Dispatch UI refinements — 25 October 2026

**M4 UI REFINEMENTS TECHNICALLY VERIFIED / FOCUSED REVIEW AND HUMAN UI RETEST PENDING / NOT PUBLISHED.**

The final developer-retest addendum below supersedes this initial candidate's visible dispatch-reason wording and fulfilled-track colour.

Implemented the approved 25 October UI handoff with one implementer and one consolidated author self-review. This record does not complete independent review, Stage B acceptance or developer hardware-input/readability acceptance. No merge, push, PR, publication, M4 promotion or M5 work.

## Candidate and preservation

Authoritative checkout: `D:/Godot Projects/Sorting-apoc-PROTOTYPE`, branch `codex/m4-expedition-loadout`. Exact base: `7ebc571d1877dce0462424bdded5978651b6caf9`; its Stage A `a0d4a8adb56b907587103ec65f5edf917c04ff2a`, original candidate `3a57177c14f60aa3bd29508dff60bb64ab3ed3a9`, and twelve-item top-up ancestors remain. The final SHA is recorded in external `delivery.json` and the delivery message (a commit cannot embed its own SHA).

Initial index and tracked working tree were clean. The historical developer edit to `gameplay/logistics_wing/wing_gameplay.tscn` was **absent**; its actual starting bytes were preserved, without restoring or staging historical differences. Exactly **18 pre-existing untracked sidecars** remain untracked and byte-identical; their complete paths and hashes are in external `baseline.json` / `preservation.json`. No new sidecars were needed. Five registered worktrees remain identical.

The preservation comparison covers **1,443 tracked/nonignored existing files**: no missing files, only the seven scoped implementation/test files below changed. The new validation record is the eighth committed path. Locked CSV/JSON/scenario files, all 167 item definitions and authored resources, gameplay/accounting/snapshot/save owners, Stage A/B corrections and the wing scene are unchanged. Ignored licensed originals were neither edited nor staged. Existing evidence and actual developer saves were not opened or overwritten. All test save services were injected with new external directories; external APPDATA/LOCALAPPDATA/TEMP/TMP were used per process, with Godot user data observed under those profiles.

## Changed paths and behavior

| Path | Change |
|---|---|
| `gameplay/run/night_report.gd` | Exactly Expeditions / Medical / Meal Service tabs, independent scroll regions, fixed title/status/scenario notice/Begin Day/ESC hint. Defaults to Expeditions on every presentation. |
| `gameplay/requests/dispatch_carousel.gd` | Compact projected lane and whole-item Bulk text, semantic substring colours, centered rejection messages, no opaque request labels/tooltips, buttons followed by italic hint. |
| `tools/asset_pipeline/tests/m4_carousel_tests.gd` | Exact preview/style/state assertions and both-resolution state captures; existing navigation/input invariants retained. |
| `tools/asset_pipeline/tests/m4_report_tests.gd` | Tab order/default, empty/partial/fulfilled/expired facts, frozen coverage, departure clock/reasons, supply aggregates, scenario notice, read-only switching and independent scrolling. |
| `tools/asset_pipeline/tests/m4_rendered_tests.gd` | Real tab hit areas, exact snapshot comparison, report/menu pause ownership, both-resolution tab/supply captures and settled-layout pointer clicks. Requires explicit external evidence directory. |
| `tools/asset_pipeline/tests/m4_held_movement_tests.gd` | Explicit external slot/evidence; fresh-process first-frame bounds/capture, default tab, exact snapshot preservation, ESC, once-only Begin Day and retained movement checks. |
| `tools/asset_pipeline/tests/m4_snapshot_tests.gd` | Explicit external `--m4-save-dir`; substantive physical/accounting continuation assertions retained. |
| This record | Validation, evidence, limitations and retest checklist. |

Report presentation reads only the frozen completed-day report. Reasons are **Fully provisioned**, **Manually dispatched under-prepared**, and **Cutoff-dispatched**, followed by **Departed HH:MM:SS** using the stored clock conversion. Lanes are Food, Hydration, Medical, Weapons, Protection. Receiving appears separately as **Incoming supplies — scripted scenario**, preserving admitted / midnight-forfeit / deposited-backlog counts. No per-team return association, invented return status or new accounting is introduced.

Exact eligible examples verified: `Food 24/48 (+12 / 0 wasted)`, `Food 48/48 (+5 / 7 wasted)`, and `Outgoing 2 (+6) / 112 Bulk · Return Capacity 110 (-6)`. Only projected numerator/applied contribution are green; positive `7 wasted` is red including the word, zero waste/target/punctuation are normal. Authored display names remain literal labels. Rejections read **Selected item not eligible for Expeditions**, **Food requirement already fulfilled.**, **Insufficient load capacity.**, or truthful **Selected item already spent.** Terminal teams remain blue/read-only with **Team Dispatched**.

## Fresh validation

Evidence root **E**: `C:/Users/Boschetar/.codex/attachments/m4-ui-refinements-20261025-01/`. Installed executable **G**: `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`, verified `4.7.stable.official.5b4e0cb0f`. Native Windows OpenGL Compatibility / NVIDIA RTX 5060 Ti, driver 621.01; no tools installed/upgraded.

Each tag contains exact `command.json`, `exit.json`, stdout/stderr and an isolated profile. The short external `run.ps1` is the invocation transcript/helper; it refuses existing tags. Tests ran serially. Every successful row below has **exit 0**, its completion marker, **zero assertion failures**, and inspected diagnostics.

| Tag / fixture | Result |
|---|---|
| `compact-native` / `m4_carousel_tests.gd` | **588 checks**, both resolutions, exact substring markup and plain text, eligible/waste/full/irrelevant/capacity/spent/empty/terminal resets, E rejection, manual dispatch while holding ineligible item, layout containment and existing input/navigation/selection checks. |
| `integrated-verified` / `m4_rendered_tests.gd` | **239 checks**, actual production F/E/ESC/navigation/wheel/number/controller/physics paths, manual-button/arrow/side-card/tab clicks, terminal selection, cutoff, save/Continue, exact snapshot on tab navigation, pause owners, report acceptance and >10-item strip. |
| `fresh-report-standing` / `m4_held_movement_tests.gd` | **16 checks**, separate-process Continue into REPORT_PENDING at 1280×720. First drawn card `(255,45; 1410×990)` in logical 1920×1080 = physical `(170,30; 940×660)`. Footer fits on first draw; tabs preserve snapshot/pause; ESC/menu and repeated Begin Day safe; held-W behavior retained. Uses a new copy of this task's standing-player report slot. |
| `report-layout-final` / `m4_report_tests.gd` | Completion with **zero failures**; report facts, no IDs/redundant lane suffixes, all tabs/empty states, coverage/Medical aggregates, saved-status wording, independent scroll offsets and teardown. |
| `locked-baseline` / `m4_baseline_tests.gd` | **167 rows**, zero mismatches. |
| `accounting` / `m4_loadout_tests.gd` | **51 checks**, unchanged selected-item accounting/caps/Bulk/rejection/exactly-once semantics. |
| `schedule` / `m4_schedule_tests.gd` | **28 checks**, chronology, formation/cutoff, report facts and next-day issuance. |
| `snapshot-write` / `m4_snapshot_tests.gd` | **28 checks**, new partial/mixed/cutoff/report slots and corrupt-state rejection. |
| `snapshot-read` / `m4_snapshot_tests.gd --read` | **22 checks**, separate process, exact restoration/physical ownership/velocity/ladder/request facts, no reactivation/redispatch. |

Typical command (full argument arrays in each tag): `G --path <checkout> --rendering-method gl_compatibility --resolution 1280x720 [--headless] --script res://tools/asset_pipeline/tests/<fixture>.gd -- <external overrides>`. Overrides: `--m4-ui-evidence-dir=E/compact-captures`, `--m4-evidence-dir=E/integrated-captures-verified`, `--m4-slot=E/fresh-slot-standing`, `--m4-evidence-dir=E/fresh-captures-standing`, or `--m4-save-dir=E/snapshot-slots` plus `--read` for the independent reader.

Expected RED evidence is retained: old report **5 failures**, old capacity wording **1 failure**, old compact behavior **11 failures**. Native old-UI baseline also reproduced a stale-layout pointer-click failure. Initial fresh testing exposed a genuine transient report height of **739 physical layout units rather than 660**, with card above/below the viewport on first draw. Pre-sizing the wrapped save-status label before assigning text fixes that measured failure without deferred resize callbacks. The rendered helper now waits for settled pointer coordinates; first-frame assertions remain independent of that wait.

Failed preparation/iterations are not counted as success: `fresh-report-native` had a duplicate local variable parse error (renamed); `fresh-report-native-final` failed first-frame containment; `fresh-report-layout` passed sizing but used the snapshot fixture's deliberately ladder-attached player for a walking check. The corrected standing-player source passes. Earlier `integrated-native` / `integrated-native-final` retained the pointer timing failure; `integrated-verified` supersedes them. Logs are preserved. Final integrated native output retains exactly the four known CF-07 **Parameter "material" is null** engine diagnostics, as in the baseline and prior M4/Stage B record; no suppression or unrelated material fix. Other selected final logs have no script/assertion/warning/leak/incomplete diagnostics, including report teardown.

## Captures, reused evidence and retest

Captures were visually inspected for readable text, clipping, colour resets, fixed controls and terminal contrast. Compact fixtures deliberately show a display name containing literal markup as an escaping check.

- `E/compact-captures/{eligible,wasted,full-lane,rejected,capacity,empty,terminal}-{1920,1280}.png`: all compact states at both supported resolutions.
- `E/integrated-captures-verified/report-tab-{0,1,2}-{1920,1280}.png`: all three production report tabs at both resolutions.
- `E/integrated-captures-verified/report-scripted-supplies-{1920,1280}.png`: scroll to scripted-supply summary with fixed footer.
- `E/fresh-captures-standing/fresh-continue-first-frame-1280.png`: exact fresh-process first rendered report.
- `E/before-captures/`: representative old UI. `E/m4-ui-review.patch` and `E/delivery.json`: bounded base-to-final review patch and exact final SHA/status.

Geometry/cargo/stock-access/performance sweeps were **not rerun** for these UI changes. Their owners/inputs are unchanged; reuse the [Stage B record](m4-geometry-measurement-reuse-validation-2026-10-25.md) for 287 geometry checks, all twelve exact cargo manifests / 192 TAKEs and shelf handoffs, 85-item placement/access, and measurements; reuse the [Stage A record](m4-startup-catalogue-reuse-validation-2026-10-25.md) for retained-catalogue behavior. Original wider M4 evidence remains in the [24 October validation](m4-expedition-loadout-validation-2026-10-24.md). These are attributed prior results, not new runs or independent acceptance of Stage B.

Developer retest with a disposable profile: (1) At 1920×1080 and 1280×720, inspect eligible/capped-waste/rejected/terminal Dispatch readability and use actual F/E/A/D/arrows/wheel/number/click/ESC controls, including manual under-prepared with an ineligible item. (2) At midnight, visit all three tabs, scroll Expeditions to scripted supplies, and verify fixed status/Begin Day/ESC controls. (3) Fresh Continue the pending report at 1280×720; inspect its first visible frame, ESC/menu/Save & Exit, and Begin Day once. One focused combined independent review of this delta and still-pending Stage B reuse remains before human acceptance.

## Developer UI retest follow-up — 25 October 2026

Base `80ab28c512beea225232c7f20f2db2d7dd9c6ad4`, same branch. Four explicitly requested presentation refinements: fulfilled-track card/track borders and message are yellow (unrelated-item/capacity rejection remains red); terminal cards replace deadline/countdown with the recorded **Dispatched HH:MM:SS**; Expeditions report entries show only **Dispatched HH:MM:SS**, followed by all five lanes on one logical line with natural wrapping; expired meals with positive credited Food **or** Hydration display **Partially fulfilled**, while untouched meals remain **Expired** and completed meals **Fulfilled**. Stored dispatch reasons, closure reasons, clock conversion, coverage and accounting are unchanged. Terminal timestamp checks include a nondefault day start/rate on day 2 and advancing the current clock after dispatch.

Only the same two presentation owners, their carousel/report fixtures and this record changed (five paths). Initial tracked tree/index were clean; the same 18 untracked sidecars, current wing scene, authored/locked resources and other worktrees were preserved. External `pre-implementation.json` was captured after updating the two fixtures and before production edits; its hash comparison found only the two intended source changes, no missing files, and unchanged registrations/sidecars. No actual developer save or earlier evidence was overwritten.

Fresh evidence: `C:/Users/Boschetar/.codex/attachments/m4-ui-followup-20261025-01/`. Same installed Godot/Compatibility renderer, new per-process external profiles and slots. Expected RED: carousel **3 failures**, report **6 failures**; GREEN: carousel **45 checks**, report **zero failures**. Native carousel **593 checks**; native report captures at **1920×1080 and 1280×720**; production rendered/input suite **239 checks**; separate-process fresh Continue/first-frame/held movement **16 checks**; accounting smoke **51 checks**; locked baseline **167 rows**. All final commands exited **0** with complete markers and no assertion failures. Only the same four known CF-07 material diagnostics occur in production integration; other final logs have no unexpected diagnostics. Full argument arrays, exits and logs are retained per tag. Prior snapshot writer/reader, geometry, cargo, stock-access and performance evidence above is reused, not rerun; those owners/inputs are untouched.

Visually inspected changed states at both resolutions: `carousel-captures/full-lane-{1920,1280}.png`, `carousel-captures/terminal-{1920,1280}.png`, `report-captures/report-tab-{0,2}-{1920,1280}.png`. The report captures are frozen formatting fixtures showing partial/fulfilled/expired meals and scenario-complete notice; `integrated-captures/` contains production report/input captures, and `fresh-captures/fresh-continue-first-frame-1280.png` records actual fresh Continue. The existing single validation helper was reused. `delivery.json` records the exact final SHA/status; `m4-ui-followup.patch` is the bounded base-to-final patch.

One consolidated author self-review and `git diff --check` found no further changes needed. Human retest: compare full-track yellow with unrelated-item red, revisit an already dispatched card, verify dispatch-time-only report entries and naturally wrapping lane values, and compare partial versus zero-contribution meals. Independent review and focused human retest remain pending; no merge/push/publication/promotion/M5.
