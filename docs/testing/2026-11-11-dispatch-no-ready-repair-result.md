# Dispatch preparation with no Ready scavengers

**11 November 2026 · Technically verified locally · Developer retest pending**

## Reproduction and correction

On the local Fuel close-out at `6478116`, eight ordinary one-member, zero-loadout departures left an unformed draft at zero Ready. The open panel showed `0 Ready • 1 selected` and an affinity click changed the draft. Dispatch was already blocked. The regression failed on the label, affinity controls, capacity presentation and snapshot preservation. The reported screenshot was unavailable in this checkout, so the reproduction used the running game. [Pre-fix log](evidence/dispatch-no-ready-2026-11-11/empty-preparation-red.log)

Dispatch resets the draft to its preferred count after departure. The panel displayed that count unconditionally, and affinity edits checked category and destination rules without checking personnel. The Expedition owner now requires a formed crew or at least one Ready scavenger for affinity edits. The panel uses the same condition to show unavailable preparation while keeping operation monitoring and carried-item selection accessible. A formed crew at zero Ready retains its locked size and can change affinities, accept eligible supplies and depart.

Production changes are in [the operation owner](../../gameplay/expeditions/expedition_operations.gd) and [the Dispatch panel](../../gameplay/expeditions/dispatch_panel.gd). The regression extends [the operations test](../../tools/asset_pipeline/tests/expedition_operations_tests.gd) and [the physical test](../../tools/asset_pipeline/tests/expedition_physical_tests.gd). One focused read-only review found no actionable issues and required no corrections.

## Verification

- The focused case passed headless and on Windows Compatibility at an actual **1600 × 900** viewport. Scripted mouse and keyboard input exercised the production panel, including affinity and Dispatch clicks and the F and E actions. The empty view kept all eight Away operations visible. After forming the final crew with one item, the test closed and reopened the panel, saved and continued, changed affinities, contributed another item and dispatched the crew once. [Headless log](evidence/dispatch-no-ready-2026-11-11/empty-preparation-green.log) · [Native log](evidence/dispatch-no-ready-2026-11-11/dispatch-native.log) · [Empty panel capture](evidence/dispatch-no-ready-2026-11-11/dispatch-no-ready.png) · [Formed crew capture](evidence/dispatch-no-ready-2026-11-11/dispatch-formed-zero-ready.png)
- The test covered zero, one and two stored affinities. Isolated schema-9 Continue preserved the complete run snapshot for both legacy empty drafts and the formed crew, including count preferences, exact roster, receipts and cargo, inventory, journey RNG, identity allocator, goal, Fuel and Kitchen. Rejected selection, deselection, supply and departure attempts left the empty snapshot and revision intact.
- Actual cargo admission refreshed the open panel with the saved choices. Releasing a destination while a crew waited for the lift kept preparation unavailable. The operations and physical suites passed, including busy-pair rejection and zero-loadout departure. The Fuel verification covers the emergency pending-start handover and empty returns. [Operations log](evidence/dispatch-no-ready-2026-11-11/expedition_operations_tests.log) · [Physical log](evidence/dispatch-no-ready-2026-11-11/expedition_physical_tests.log) · [Fuel result](2026-11-11-fuel-reserve-emergency-freight-result.md#verification)
- The collection continuation suite passed all 136 checks and the headless startup smoke exited successfully. The logs retain the existing Windows certificate-store and null-material diagnostics, plus the intentional invalid-layout and blocked-save probes. [Continuation log](evidence/dispatch-no-ready-2026-11-11/collection_continuation_tests.log) · [Startup log](evidence/dispatch-no-ready-2026-11-11/f5-startup.log) · [Exit codes](evidence/dispatch-no-ready-2026-11-11/exit-codes.json)

Godot 4.7 stable commands below used separate temporary `APPDATA`, `LOCALAPPDATA`, `TEMP` and `TMP` directories per run. The native run set `SORTING_EXPEDITION_RENDER_DIR` to the temporary evidence directory. The first command exited 1 before the correction and 0 afterward. Before and after SHA-256 checks matched all eight real save files and 31 existing image sidecars, including the eight pre-existing untracked Fuel sidecars.

```powershell
$godot = 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe'
$project = 'D:/Godot Projects/Sorting-apoc-PROTOTYPE'
& $godot --path $project --headless --script res://tools/asset_pipeline/tests/expedition_physical_tests.gd -- --dispatch-no-ready
& $godot --path $project --rendering-method gl_compatibility --resolution 1600x900 --position 20,40 --max-fps 60 --script res://tools/asset_pipeline/tests/expedition_physical_tests.gd -- --dispatch-no-ready
& $godot --path $project --headless --script res://tools/asset_pipeline/tests/expedition_operations_tests.gd
& $godot --path $project --headless --script res://tools/asset_pipeline/tests/expedition_physical_tests.gd
& $godot --path $project --headless --script res://tools/asset_pipeline/tests/collection_continuation_tests.gd
& $godot --path $project --headless --quit-after 12
```

## Developer retest

1. Send all available crews away so the current draft is unformed at zero Ready. Open Dispatch and check that preparation is unavailable, affinities cannot be edited and operations remain visible.
2. With one scavenger Ready, contribute one eligible item to form the final crew. At zero Ready, check that its count stays locked, then change its affinities and dispatch it.
