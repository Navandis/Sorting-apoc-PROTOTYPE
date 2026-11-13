# Expedition outcomes and provisioning technical result

**13 November 2026 · TECHNICALLY READY FOR DEVELOPER PLAYTEST**

The local branch is `codex/expedition-outcomes-provisioning` in the asset-equipped [Expedition checkout](<C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/Expedition>). Published `main` was verified at `d9eeb6cc937dd7b20d3aebacddf23cfadf51fd2d`. The ancestry checks both exited 0 for Receiving `6c82e59ffa00f1f63cda78ebf5a0a127aa049e26` and Fedora adoption `ed521a2a0cea5ba829430bf04c8046eed1e79f0a`. The GitHub comparison reported identical refs. The local commits are `9da46bd` for the approved-design checkpoint, `421cfb7` for implementation, and `3e768ac` for a test-only change that gives the zero-Ready witness distinct return times. This record and current status updates are in the documentation closeout commit.

The app-created checkout was outside the writable workspace. The branch and commits are in the writable local clone linked above, with junctions to the existing asset and import directories. Tests used the installed Godot executable and isolated saves. The supplied v0.2 workbook was read as capacity evidence. Its 23-Bulk row gives efficient-floor room of 56.5%, 71.7%, 71.0% and 75.0% for crews of one through four. The original decision record and plan were copied byte-for-byte from the local handoff files.

[Decision record](../design_history/2026-11-13-expedition-outcomes-and-provisioning-decisions.md) · [Implementation plan](../superpowers/plans/2026-11-13-expedition-outcomes-and-provisioning.md) · [Raw evidence](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-13-expedition-outcomes>)

## Candidate behavior

- Crews of 1–4 have 23 ordinary Bulk per original member. The 167 active catalogue definitions participate in category-first acquisition. Each chosen affinity starts at 15%. Ordinary draws filter only by remaining Bulk. Food bonus draws use the same category and quality rules with the full catalogue. One delivery contains the exact ordinary prefix and bonus suffix.
- Food adds one expected bonus item per eight credited Utility. Hydration reduces a 210–300 active-second base by up to 25%. Weapons blends up to 50% Utility/Bulk weighting within the chosen category. Protection halves Light and Severe chances at full credit. Morale gives each original up to 5% independent recruitment chance. Whole contributions charge full Bulk and cap lane credit. The distinct live warning explains the Food allowance at zero ordinary Bulk.
- A return releases its destination. Admission to an active or deposited slot completes handover, including a pending emergency start. Healthy originals and recruits become Ready. Light and Severe patients recover after 120 and 300 active seconds from handover. Empty returns hand over at return. Dispatch keeps recent outcomes, and F opens the read-only Medical view at its existing frontage.
- The local collection run uses 22 normal player Bulk. The Kitchen cap is 105 Utility and the maximum loss is 35%, giving 14 effective Bulk. Grandfathered carry and failed-transfer rollback still work. The adopted Fedora remains 0.897 scale, 3×3×1 Footprint and 2 Bulk. Eight Ready, the authored loose stock and the six-Utility target per category remain test settings.
- Schema 11 replays the saved per-journey seeds in isolated streams for validation. Continue restores exact state and deadlines. The tests rejected inconsistent manifests, bonus identity, personnel, recovery timing, terminal ownership and mixed-stack removal history. Confirmed New Run retains the schema-10 snapshot and uses the existing slot. Play continues after the first victory.

## Verification

Godot `4.7.stable.official.5b4e0cb0f`, Compatibility. The native renderer reported OpenGL 3.3.0 and NVIDIA GeForce RTX 5060 Ti. Tests used isolated AppData and temporary directories. The following table lists the latest result for each exercised check. The suite names are the exact script basenames.

| Command group | Tests and results |
| --- | --- |
| `focused-final` | `expedition_outcomes_tests`, `expedition_acquisition_tests`, `medical_recovery_tests` and `fuel_continuation_tests` all exit 0. Fuel continuation 192 checks, zero failures. |
| `final-deltas` | `expedition_operations_tests` and `expedition_outcomes_continuation_tests` both exit 0. Includes repeated rollback, bonus-only and empty boundary fixtures, eight simultaneously recovering originals, late admission with a pending recruit, and exact partial mixed-stack Continue. |
| `final-post-victory` | `collection_continuation_tests` exit 0, 124 checks. Includes schema 10 confirmation and byte retention, tied arrivals, terminal owner rejection, save failure, first victory and continued departures. |
| `affected-check` and `follow-up` | `kitchen_operations_tests` 2839, `kitchen_continuation_tests` 263, `fuel_operations_tests` 28, `fuel_receiving_tests` 44, `incinerator_operations_tests` 29, `incinerator_continuation_tests` 116 and `incinerator_interaction_tests` 35 checks. All exit 0 with zero failures on their final runs. |
| `receiving-storage` | `m1_contribution_tests`, `receiving_awaiting_lift_integration_tests`, `receiving_deck_layout_tests`, `receiving_deck_presenter_tests`, `storage_stacking_interaction_tests` and `collection_goal_tests` exit 0. The old `receiving_queued_delivery_tests` exits 1 for three CRT OPEN assertions on both the published baseline and candidate. It expects single-digit cargo counts and the display uses two digits. The fixtures' ownership and lifecycle assertions pass. |
| `final-startup`, `native-crt-final`, `launch-f5`, `launch-f6` | All exit 0. The CRT produced a 704×400 texture with 4,221 green samples through both entries. |
| `native-final-1280x720`, `native-1600x900` | `expedition_physical_tests` exits 0 at both actual Windows viewport sizes. Production seed 1220 yielded 3 ordinary items plus 1 Food bonus item, 1 Light injury and 1 recruit. All four items were taken through the reticle and shelved. |
| `native-no-ready-final`, `native-kitchen`, `native-fuel` | The zero-Ready variant of `expedition_physical_tests`, `kitchen_interaction_tests` and `fuel_interaction_tests` each exit 0. Kitchen ran 80 checks and recovered sprint. Fuel ran 175 and recovered normal freight using generated Fuel while Kitchen retained the 14-Bulk limit. |

The native Expedition witness used the normal New Run shell, controlled player positions, actual native input for stock pickup, F, E, Escape and dispatch, and production generation and presentation. It used controlled advances on the production active timeline for the long deadlines. Shelving used the ordinary placement owner with an addressed shelf. At zero Fuel, the recruit joined and the patient started recovery before ARRIVAL. With two deposits and an upstream waiter, Save & Exit and Continue kept the exact outcomes. Another Continue restored a partially unloaded batch. Maximum observed cargo TAKE reach was 1.380322 m. Handover and recovery were 1991.477309 and 2111.477309 active seconds at 1280×720. The final Ready count was nine. The mixed-stack continuation used a separate genuine production seed 0 and explicitly took its mixed base before Continue.

[1280×720 Dispatch](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-13-expedition-outcomes/native/final-1280x720/dispatch-five-lanes.png>) · [1600×900 Medical](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-13-expedition-outcomes/native/1600x900/medical-natural-recovery.png>) · [Native zero-Ready formed crew](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-13-expedition-outcomes/native/no-ready-final/dispatch-formed-zero-ready.png>) · [Consolidated review](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-13-expedition-outcomes/contextual-review.md>)

### Reproduction

In PowerShell, set the project and evidence paths below. The reused isolated test launcher accepts the listed tags and script basenames. Choose a fresh tag for a repeat to preserve the original logs.

```powershell
$project = 'C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/Expedition'
$evidence = 'C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-13-expedition-outcomes'
$engine = 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe'
git -c safe.directory='D:/Godot Projects/Sorting-apoc-PROTOTYPE' -C 'D:/Godot Projects/Sorting-apoc-PROTOTYPE' -c http.sslBackend=openssl -c credential.helper= -c core.askPass= -c http.extraHeader= ls-remote --exit-code origin refs/heads/main
& "$evidence/run_tests.ps1" -Project $project -Tag replay-outcomes -Test expedition_outcomes_tests,expedition_acquisition_tests,medical_recovery_tests,expedition_operations_tests,expedition_outcomes_continuation_tests,collection_continuation_tests
```

For native evidence, the environment and argument setup is recorded verbatim in [commands.ps1](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-13-expedition-outcomes/commands.ps1>). The launcher uses `--path`, `--rendering-method gl_compatibility`, `--resolution`, `--single-window`, `--max-fps 60` and the existing SceneTree test. Startup parity uses `-- --m1-save-dir=<isolated absolute directory>`. The initial run without the named argument failed at its argument check. Early development test failures are retained in the raw logs, including a runtime script error that emitted a misleading PASS. The later runs checked both exit codes and error output.

## Preservation and remaining scope

| Area | Disposition |
| --- | --- |
| Expedition fixture | Replaced `expedition_test_config.gd` with `expedition_config.gd`, preserving its script UID. Removed the sixteen-definition pool, minimum-Bulk-two, 8-Bulk-per-member and 90–180-second live settings. Tests now use production generation or labelled boundary fixtures. |
| Loadout and workforce | Replaced the Medical loadout lane with Morale, fixed-eight validation with historical Ready and patient accounting, and healthy-only release with handover outcomes. Retained the common exact-item transaction and sequence owner. |
| Receiving, stock and authoring | Retained Receiving layout, mixed-stack and exact manifest ownership, admissions and removal history. Tracked catalogue, authored wing scene and Receiving files match the base. The original working tree status and the eight real save hashes matched preflight. Assets and existing imports are linked into the isolated checkout and used by the runtime. |
| Historical systems and evidence | Retained the M1–M4 daily records, the earlier physical Receiving/Dispatch evidence, the workbook, previous loadout assessment and legacy fixture scene. The first-iteration values supersede their runtime assumptions in the continuous run. |
| Design masters | GDD v0.16, Systems MVP v0.5 and VDD v0.11 edited in Word package XML first. Regenerated changed text in their Markdown companions. Preserved non-document package parts, tables, styles, media and anchor structure. Rendered all three through LibreOffice/Poppler and visually checked affected pages. |
| Known limits | The 157-Bulk meat-and-mice overrun and the long-object planner failure remain deferred. Preparation rejects safely and an unchanged retry repeats the same manifest. This candidate retains the Windows certificate-store and held-material diagnostics and the active clock's existing ten-second suspension cutoff. Long-run balance, universal haul presentation, save performance at large stock and release crash durability remain open. |

The implementation had one independent contextual review against `d9eeb6c..421cfb7`. It found no actionable issues. The review and the native witnesses establish the tested local candidate. Developer acceptance and publication remain pending.

## Developer playtest

1. Run [Play-Expedition-Candidate.ps1](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-13-expedition-outcomes/Play-Expedition-Candidate.ps1>) and choose **New Run**. The launcher uses a dedicated profile. Confirm when prompted.
2. At Dispatch, send one unprovisioned crew. Prepare another with all five lanes. Check the selected item's credited Utility, waste and full outgoing Bulk, the Food bonus range and the travel, quality, injury and recruit previews.
3. Let an authentic haul return. Check that Dispatch hides committed outcomes while Away, shows them at return, and reports one combined delivery. Take the haul from Receiving and put items on ordinary storage.
4. With a full lift queue, check that an upstream crew's destination frees at return. Keep the lift busy long enough to see that its recruit and injured originals wait for admission. At zero Fuel an admitted emergency load can start personnel handover before ARRIVAL.
5. Check Medical for a Light or Severe patient. Compare the active recovery countdown before and after pausing and after Save & Exit and Continue. Watch Ready increase at the deadline. With zero Ready, verify a formed crew can still dispatch.
6. Finish the six-Utility-per-category goal and continue playing to exercise longer waits. Save partway through a haul and confirm that remaining cargo, workforce and the first victory time restore together.
