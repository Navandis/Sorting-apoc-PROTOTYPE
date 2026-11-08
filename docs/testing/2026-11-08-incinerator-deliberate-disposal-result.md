# Incinerator and Deliberate Disposal

**8 November 2026 · Technically ready for developer playtest**

The local F5 build now supports one-item disposal at the existing Incinerator. The confirmed standing rules are in GDD §15.3. The implementation and evidence below are separate from developer acceptance.

## Checkout and implementation

- Branch **codex/incinerator-deliberate-disposal** in the asset-equipped `D:\Godot Projects\Sorting-apoc-PROTOTYPE` checkout. Local HEAD and GitHub `main` matched `90c5fc6beabaa5403629f4a45c97a380f36d39ec` at preflight. That revision includes the accepted foundation, expedition loop and furniture collision repair. A final read of GitHub `main` returned the same revision.
- Gameplay checkpoints `50fcd4c0223da88686eb3a8d958114a6ae6ae2ba` for atomic ownership and `873f515d77602841c5c4266710e7e5cc1f81fafb` for input, snapshot integration and focused tests. The developer's untracked brief stays in the checkout as supplied.
- Tested with `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`, version `4.7.stable.official.5b4e0cb0f`. Native renderer was OpenGL 3.3 Compatibility on an RTX 5060 Ti. Codex ran as the sole implementer. Exact implementer model variant and reasoning effort were unavailable. One read-only reviewer used GPT-6 Astra at High effort.
- `gameplay/disposal/incinerator_operations.gd` owns the warning flag and destruction receipts. `gameplay/disposal/incinerator_panel.gd`, `player_controller.gd`, `gameplay/logistics_wing/wing_gameplay.gd` and `gameplay/run/run_shell.gd` use the existing machine ray, carrying selection and pause ownership. `CarriedItems.commit_selected_consumption` removes one item and records its receipt before notifying observers.
- `gameplay/run/run_snapshot.gd` and `gameplay/expeditions/expedition_snapshot.gd` validate the terminal disposition of each released cargo identity. A disposal receipt records item ID, definition and active elapsed time. Seed receipts match the authored palette. Expedition receipts match the original manifest and prior handover. Save validation keeps disposal disjoint from live ownership and loadout credit. `gameplay/expeditions/expedition_operations.gd` exposes the existing loadout receipt index for the runtime guard.
- The three `incinerator_*_tests.gd` suites and their UID sidecars live in `tools/asset_pipeline/tests/`. The owning Word and Markdown sections were updated in GDD v0.16, Systems MVP v0.5 and VDD v0.11. Current-facing changes are in `docs/CURRENT_STATE.md`, `docs/README.md`, `docs/CODEX_BOOTSTRAP.md` and the 7 November conversation bootstrap.

## Save compatibility

Schema **7** uses the existing `user://saves/collection/` service. Schema 6 is incompatible and has no automatic conversion. The launch screen disables Continue and explains that a New Run is required. Inspection and failed Continue preserve the old pointer and snapshot. Confirmed New Run repoints the slot to schema 7 and retains the incompatible file. The retained schema-5 snapshot and the separate M4 slot are preserved.

Save & Exit and ordinary automatic attempts preserve the warning flag, disposal receipts and exact physical and expedition state. Continue starts with the panels closed and clears transient confirmation. The warning is consumed when displayed, including after Back. Destruction and warning display are recoverable after the next successful save.

The current real collection pointer, M4 pointer, both referenced snapshots and the retained schema-5 snapshot matched their preflight SHA-256 values. Tests used redirected application data and isolated save directories. [Read-only before and after hashes](evidence/incinerator-2026-11-08/save-preservation.json).

## Fresh verification

| Proof | Observed result |
| --- | --- |
| Transaction | 29 checks passed. Full 20-Bulk carrying, rejected over-capacity pickup, all eight categories, a synthetic zero-Utility item, exact removal, released Bulk, duplicate rejection and receipt-before-notification ordering. [Expected failure](evidence/incinerator-2026-11-08/operations-red.log) · [Passing log](evidence/incinerator-2026-11-08/operations-green.log) |
| Live interaction | 35 headless checks passed. Two native runs passed 46 checks each at 1280×720 and 2560×1440. Native input walked 1.515 m to the front, opened with F, selected with a number key, attempted with E, clicked Back and Continue, and navigated the warning with Tab and Enter. Held E neither replayed disposal nor entered shelf auto-store. A fresh E and mouse pickup completed shelf placement and retrieval. ESC closed the warning, then the panel, then paused the run. Time, expedition handover and lift motion advanced while the warning owned input. [Expected failure](evidence/incinerator-2026-11-08/interaction-red.log) · [Headless](evidence/incinerator-2026-11-08/interaction-headless-final.log) · [1280×720](evidence/incinerator-2026-11-08/interaction-native-720-final.log) · [2560×1440](evidence/incinerator-2026-11-08/interaction-native-display-final.log) |
| Continuation | 116 checks passed. Genuine destruction was accepted with its source batch OPEN and after retirement. Missing, multiply owned, untaken, prematurely destroyed and definition-mismatched cargo rejected. Save and Continue preserved cancellation, confirmation, a snapshot made with the warning open, and the first victory time. Ordinary retrieval subtracted Utility once. A rejected save kept the last good continuation. [Expected failure](evidence/incinerator-2026-11-08/continuation-red.log) · [Passing log](evidence/incinerator-2026-11-08/continuation-green.log) |
| Congestion | One spare shelf cell, 20 Bulk carried, one OPEN deck, two deposits and a genuine Awaiting Lift crew. Full carrying blocked a normal reticle TAKE. Two deliberate seed disposals freed 4 Bulk for remaining cargo. The crew stayed unavailable through disposal, last TAKE and outbound. It became Ready on admission after the full turnaround, raising Ready from 6 to 7. [Fixture and continuation log](evidence/incinerator-2026-11-08/continuation-green.log) |
| Affected regressions | Nine scripts exited 0. Collection goal, collection and expedition continuation (136 checks), expedition operations, M1 and M3 contribution (27 and 24 checks), nested pause/admission, Receiving Awaiting Lift integration, furniture movement collision and startup parity. The configured F5 smoke launch wrote its user log under the isolated profile. [Regression logs](evidence/incinerator-2026-11-08/regressions/) · [F5 launch](evidence/incinerator-2026-11-08/normal-f5-launch.log) · [Editor scan](evidence/incinerator-2026-11-08/editor-import.log) |
| Review and documents | The independent review found no actionable correctness defect. Its held-E storage and keyboard confirmation coverage gaps were exercised in both final native runs. Changed Word paragraphs and table rows match the regenerated Markdown. LibreOffice rendered 49 GDD pages, 50 MVP pages and 29 VDD pages. The affected pages were inspected at full size, with full-document overview checks. |

[Front interaction cue](evidence/incinerator-2026-11-08/front-1280x720.png) · [Red action and item facts](evidence/incinerator-2026-11-08/panel-1280x720.png) · [Exact warning](evidence/incinerator-2026-11-08/warning-1280x720.png) · [Warning at 2560×1440](evidence/incinerator-2026-11-08/warning-2560x1440.png).

The three expected failures were the missing transaction owner, the missing New Run station binding, and the old validation error for a genuinely destroyed released item. The native shelf proof initially missed the placed item. The final probe waits for physics and verifies the exact reticle target from a reachable stance before clicking.

The native tests inject keyboard input and dispatch mouse events through Godot's real window and GUI paths. Fixture setup positions the player near the authored approaches and supplies test stock through normal transfers. The headless interaction tests use a station request signal and button signals because the dummy display cannot capture the mouse. The congestion fixture repositions the player between the real station and Receiving. The developer playtest covers the full routes.

## Limits and prior evidence

- The existing minute and first-victory cadence remains synchronous. The warning-open automatic snapshot took about 55 ms including capture in the fresh fixture. The accepted expedition evidence previously measured 51.1–84.0 ms total, with 70.3–84.0 ms for its cargo and history cases. Large-stock performance, short silent Windows suspension and release crash durability retain their prior evidence limits. [Accepted expedition result](2026-11-08-expedition-to-storage-loop-result.md).
- Final logs retain the known Windows certificate-store and held-view material-null diagnostics. The selected regressions also exercise a deliberate cargo preparation failure and an isolated write blocker. The earlier native furniture acceptance is reused. This milestone ran the focused furniture regression again. [Accepted collision result](2026-11-08-furniture-collision-repair-result.md).
- The Incinerator has no Fuel or energy dependency in its entry and commitment paths. An active blackout scenario awaits a future outage system. The provisional collection and expedition settings served as the test fixture.

## Developer playtest

To use a fresh test slot, launch from a separate PowerShell window with redirected application data. Use Save & Exit and Continue in that launched game.

```powershell
$playtestRoot = Join-Path $env:TEMP ("Sorting-Incinerator-" + [Guid]::NewGuid().ToString("N"))
$env:APPDATA = Join-Path $playtestRoot 'Roaming'
$env:LOCALAPPDATA = Join-Path $playtestRoot 'Local'
New-Item -ItemType Directory -Path $env:APPDATA,$env:LOCALAPPDATA -Force | Out-Null
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE'
```

1. Carry an item to the machine. F opens without spending. First E shows “Incinerated items are permanently destroyed! This is a one-time warning.” Check that active time advances. Choose Back, then E. Only the selected item disappears and the warning stays dismissed.
2. On another fresh run, use Continue in the first warning while testing a held E. Close and reopen the panel. Each further destruction requires its own E press. Check that separate ESC presses dismiss the warning, close the panel and open pause.
3. Retrieve an item from a qualifying shelf and note the score decrease. Destroy it and verify there is no second decrease. Try a loose seed item and a taken expedition item. Check normal shelf use and movement collision.
4. Save and Continue after canceling a first warning and after destruction, including with cargo still on the lift. Check the warning flag, the destroyed item's absence, other goods, expeditions and first-completion time.
5. With a backed-up lift and full carrying, dispose of chosen items via ordinary trips and resume unloading. Waiting personnel become Ready at normal admission after the lift turns around.
