# Reactive Medical treatment — 18 November 2026

The developer accepted reactive Medical treatment after the 18 November walkthrough. Medical consumes one selected whole item and uses a provisional rate of **10 seconds per Medical Utility**. The budget shortens current timers in shortest-first order, completes patients immediately and spills over to the next timer. Any final excess is wasted. Light and Severe patients otherwise recover independently after 120 and 300 active seconds from handover.

Schema 12 records ordered receipts with physical identities, definitions, Utility, active timestamps and exact applied and wasted seconds. Continue reconstructs effective deadlines and Ready availability from handovers and receipts. The shared terminal-item validation checks Medical against the other consumers and cargo history. Confirmed New Run keeps incompatible snapshots.

## Focused evidence

Godot `4.7.stable.official.5b4e0cb0f`, Compatibility. Tests used an isolated save profile and a copy of the current source that read the live project's assets and import cache. The tested wing scene included the local authoring changes and temporary racks. See the [raw logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-18-reactive-medical/logs>).

```powershell
$godotExe = 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe'
$projectPath = 'C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.medical-work/game'
& $godotExe --headless --path $projectPath --script res://tools/asset_pipeline/tests/medical_recovery_tests.gd
& $godotExe --headless --path $projectPath --script res://tools/asset_pipeline/tests/expedition_outcomes_continuation_tests.gd
& $godotExe --headless --path $projectPath --script res://tools/asset_pipeline/tests/medical_interaction_tests.gd
& $godotExe --headless --path $projectPath --script res://tools/asset_pipeline/tests/fuel_continuation_tests.gd
& $godotExe --headless --path $projectPath --script res://tools/asset_pipeline/tests/kitchen_continuation_tests.gd
& $godotExe --headless --path $projectPath --script res://tools/asset_pipeline/tests/incinerator_continuation_tests.gd
& $godotExe --headless --path $projectPath --script res://tools/asset_pipeline/tests/collection_goal_tests.gd
& $godotExe --path $projectPath --resolution 1280x720 --audio-driver WASAPI --script res://tools/asset_pipeline/tests/medical_interaction_tests.gd
```

| Check | Observed result |
| --- | --- |
| Medical recovery | Exit 0. Verified 50/70/100 plus 200 seconds, fractional spillover, deadline ties, follow-up treatment and 10 seconds of terminal excess in the 20/30/40 example. |
| Expedition continuation | Exit 0. Verified natural recovery at the exact contribution boundary, expedition-origin Antibiotics, partial and completed recovery across Continue, early Dispatch and rejection of invalid history without replacing the live run or save. |
| Medical interaction | Exit 0 headless and native, including both reruns after the final panel edit. Covered actual frontage reach, empty or invalid selections, wheel and number selection, fresh E, held and repeated keys, F and ESC. |
| Fuel, Kitchen and Incinerator continuation | All exit 0. Respectively 192, 262 and 116 checks with zero failures. |
| Collection goal | Exit 0. Medical interaction also verified that treatment did not award qualifying stored Utility. |

The native check used seed 10 for a committed two-person expedition, advanced ordinary active-time boundaries through handover, and positioned the player at the existing front of Medical. The carried items came from authored world pickup paths. Injected Godot input exercised the real F/E/ESC path and existing Save & Exit and Continue handlers. Bandages applied 40 seconds with no immediate completion. After Continue, Antibiotics applied about 57.62 seconds, wasted about 22.37 seconds and returned two patients to Ready. Cough Syrup stayed carried at the empty Ward. Display values are rounded down to hundredths. [Partial treatment](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-18-reactive-medical/native-final/01-partial.png>) · [Live preview after Continue](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-18-reactive-medical/native-final/02-preview-after-continue.png>) · [Spillover and waste](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-18-reactive-medical/native-final/03-spillover-and-waste.png>)

While integrating the panel, Godot identified an unsupported format specifier. The subsequent headless and native runs passed after switching to the seconds formatter. The Windows root-certificate store and Compatibility held-item null-material diagnostics recurred. The two inherited geometry assertions concern the former direct launch UID and 46-host expectation. The inherited Salvager minimum-travel probe and the deferred Receiving 157-Bulk area and long-object cases retain their dated evidence. [Compact-layout results](2026-11-14-compact-bunker-layout-result.md) · [Receiving results](2026-11-13-receiving-mixed-stacking-result.md)

## Human walkthrough

1. Run [Play Medical Walkthrough.cmd](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-18-reactive-medical/Play Medical Walkthrough.cmd>) and choose **Continue**. The launcher makes a fresh isolated copy of a schema-12 fixture positioned at the Medical frontage with two genuine Light patients and three authored Medical items.
2. Press **F**. With Bandages selected, press a fresh **E** while the preview shows **+0 Ready** to shorten one timer. Press **Esc** once to close Medical, then again to pause. Use **Save & Exit**, then **Continue** to inspect the shorter timer.
3. Reopen Medical and select Antibiotics. When the preview shows **+2 Ready** and positive waste, press a fresh **E**. Check the Ready count and the applied and wasted time. Try Cough Syrup at the empty Ward to confirm it stays carried.

The ordinary F5 entry is `res://gameplay/run/run_shell.tscn`. The launcher uses a separate profile so the regular continuation and large-stock evidence stay available. The GDD and Systems MVP masters and reading copies include the local treatment rules and evidence.


## Developer acceptance — 18 November 2026

The developer reported no issues during their own walkthrough and confirmed the following results.

- A low-Utility item shortened only the shortest of several recovery timers.
- A larger item completed two patients and applied its remaining budget to a third.
- Opening and closing Medical preserved the existing recovery timing.
- A contribution wasted the excess after completing the final patient, and Medical rejected non-Medical items.
- Recovered scavengers became Ready immediately and could be dispatched.
- Saving and loading preserved the recovery timers.

The developer accepted the bounded Medical feature and authorized promotion, integration into main and GitHub publication. These observations come from the developer's playthrough. The earlier technical evidence records a controlled two-patient Godot run. Release tuning and large-stock save performance remain open.

## Publication checks — 18 November 2026

The closeout matched 921 source and test files to the verified candidate and reused the seven focused suites and native evidence above. The publication tree uses the wing scene already committed with the temporary racks at `9436134`. The separate local rack placements, lighting edits and image import sidecar stayed in the authoring checkout. The committed scene received a focused smoke check with the Medical scripts and an isolated save profile.

```powershell
$projectPath = 'C:/Users/Boschetar/Documents/ChatGPT/Sorting Apocalypse - Prototype/.medical-work/publication/game'
& $godotExe --path $projectPath --resolution 1280x720 --audio-driver WASAPI --script res://tools/asset_pipeline/tests/medical_interaction_tests.gd
& $godotExe --path $projectPath --headless --script res://tools/asset_pipeline/tests/wing_startup_parity_tests.gd -- "--m1-save-dir=$isolatedStartupSaves"
& $godotExe --path $projectPath --headless --script res://tools/asset_pipeline/tests/expedition_outcomes_continuation_tests.gd
```

All three exited 0. Native Medical input, spillover and Save & Continue passed on the committed scene, along with startup parity and Expedition continuation. The inherited certificate-store and null-material messages recurred. [Smoke logs](<C:/Users/Boschetar/.codex/attachments/Sorting_Apocalypse_Assessments/2026-11-18-reactive-medical/logs/publication-checks.txt>)
