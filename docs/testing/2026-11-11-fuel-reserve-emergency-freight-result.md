# Fuel Reserve and Emergency Freight

**HUMAN-PROMOTED / PUBLISHED / CLOSED IN ITS BOUNDED SCOPE.**

## Preflight and documentation checkpoint

The local feature branch starts at `a58cbf594a4e12d202cd8ba56d3ef73c82b03019`. Live `origin/main` returned the same ref with Git's OpenSSL backend. The published Kitchen anchor `b0dee116dbfd6802ccd41e046df50d294de05a41` is an ancestor. The only intervening changes provisioned the approved decisions, plan and two Kitchen image sidecars. The asset-equipped checkout was clean, with local ignored assets and Godot 4.7 stable `5b4e0cb0f` present. Preflight hashed the seven real save files and twelve tracked/untracked image import sidecars.

GDD §14 owns the approved reserve and freight rules. The three current Word masters were edited before their Markdown companions. Changed text and table cells matched the companions. The native Windows LibreOffice render yielded 50 GDD, 50 MVP and 29 VDD pages. Changed pages were inspected. Existing embedded media matched byte-for-byte.

The foundation checkpoint `a1d1db4` already retired the daily schedule, timed validator, station adapters, night report and scenario-dependent tests and UIDs. Kitchen close-out `7e80d41` retired the unused contribution modal. Searches of current scripts, project/scene/resource references and test paths found no live Ops debt, chance, episode, stage freeze or Incinerator lockout policy. The logistics-wing geometry and traversal fixtures still use the authored Ops landing and boundary. The Fuel canister maintenance review and tests cover the physical catalogue and storage, so they remain useful. The exact selected-item transaction, run save service and old-schema diagnostics have live callers.

Implementation and playtest verification were pending at this documentation checkpoint.


## Implemented behavior

- The reserve starts at 55/60 Fuel Utility, drains continuously at 1 per 30 active seconds and floors at zero. Fixed thresholds of 45, 30 and 15 select light strengths of 1.000, 0.835, 0.670 and 0.500. The Fuel panel presents Salvager and Workshop power permissions for those future systems.
- Below 15, the lift holds an admitted load for 60 active seconds before ARRIVAL. The wait begins at eligibility after complete outbound turnaround. A top-up below 15 preserves the deadline. A top-up to at least 15 starts that load once. Ongoing cycles finish through normal TAKE, close and outbound. The pending load owns the active slot, with two FIFO deposits and upstream Awaiting Lift beyond capacity. Healthy crew handover and empty returns use the existing expedition owners.
- The temporary station is the cabinet at `ReceivingSetDressing/ReceivingElectrical/SM_Electrical_Cabinet_01a`. It uses the authored `ReceivingSetDressing/CollisionProxies/ElectricalCabinetMovement` housing as its ordinary reach and occlusion target. F inspects, wheel or number keys select, fresh E supplies, and ESC closes the panel before pause. The selected whole item supplies available headroom and records fractional credit and waste. Only physical items in qualifying storage contribute to the goal.
- Dimming scales `Light3D.light_energy` on the saved `Environment/FillLights` lights StorageWest, StorageEast, MedicalKitchen, MedicalTuning, Workshop, Deeper and East, plus Receiving G1/G2, T1/T2 and ApronCeilingBounce under `Environment/ReceivingLighting`. The adapter caches authored values per instance and requests the existing coalesced Receiving reflection refresh on tier changes. W1, the hidden key and fill alternatives, CRT, HUD and held-item view are outside its membership. The 704×400 CRT retains STATUS, DECK, QUEUE and Surface 1 binding, with normal green, emergency orange and WAITING plus remaining active seconds.

The branch reuses `CarriedItems.commit_selected_consumption`, `receiving/receiving_manager.gd`, `receiving/awaiting_lift_admission.gd` and `gameplay/run/run_save_service.gd`. The legacy CRT test now opens an isolated F5 New Run through the shell before inspecting the live wing, and still checks standalone F6. The continuous-run regression crosses the new wait and counts exactly one ARRIVAL after promotion.

## Continuation and review

Schema 9 uses `user://saves/collection/`. The snapshot retains the exact reserve and accounting anchor, configuration, item receipts, committed lift phase, most recent completed turnaround and pending deadline. Validation replays Fuel credit and consumption, checks seed and generated cargo identity and prior handover, and composes Fuel with Kitchen, loadout and disposal histories. It verifies the pending deadline against admission, full turnaround and the last normal-power boundary. Save & Exit, first victory and 60-active-second attempts share the service. Schema 8 is incompatible. A failed Continue and canceled New Run preserve the old slot. Confirmed New Run writes schema 9 and retains the incompatible snapshot.

One implementer worked in this Codex chat. The exact implementer model variant and effort were unavailable. One consolidated read-only reviewer examined `a58cbf5..425c815` with requested routing GPT-6 Astra / high. The reviewer reported runtime model and effort metadata unavailable. Their finding was that a previously deposited load could accept a shortened deadline. The new continuation test reproduced it, then passed with exact turnaround-bound validation. The initial sweep exposed the changed outbound CRT footer and the former 100-second successor assumption. The correction restored the accepted footer and tested a complete outbound, wait and single ARRIVAL.

| Local checkpoint | Commit |
| --- | --- |
| Word masters, reading copies and authority routing | `2c12eb88ce5a1a52a017b372f97eb2af5e019ecc` |
| Reserve, live station, freight, lighting and schema 9 | `425c815558d0c371c8968214fe4eed4c977d81d7` |
| Review correction and affected regressions | `ab77b76aa8d13683825d3dce046e1cb83abcca4e` |
| Technical verification and developer handoff | `306cdba3d74573c3484d04f608eb25b54623d96e` |

## Verification

| Check | Result and evidence |
| --- | --- |
| Red to green | Operations, freight, station and continuation initially failed at the missing feature. Final focused counts are 28 operations, 44 Receiving, 73 headless interaction and 132 continuation checks. [Operations red](evidence/fuel-reserve-2026-11-11/operations-red.log) · [Receiving red](evidence/fuel-reserve-2026-11-11/receiving-red.log) · [Station red](evidence/fuel-reserve-2026-11-11/interaction-red.log) · [Continuation red](evidence/fuel-reserve-2026-11-11/continuation-red.log) · [Deadline red](evidence/fuel-reserve-2026-11-11/turnaround-deadline-red.log) · [Continuation final](evidence/fuel-reserve-2026-11-11/affected-reruns/fuel_continuation_tests.log) |
| Selected regressions | All 23 scripts and both headless startup checks passed after the affected reruns. Coverage includes Kitchen, Incinerator, real expeditions and empty returns, victory and continuation, Receiving admission and lift, storage rollback, furniture collision, pauses, shared consumption and F5/F6 parity. [Initial exit codes](evidence/fuel-reserve-2026-11-11/sweep-exits.json) · [Affected rerun exit codes](evidence/fuel-reserve-2026-11-11/affected-rerun-exits.json) · [Initial logs](evidence/fuel-reserve-2026-11-11/regressions/) · [Rerun logs](evidence/fuel-reserve-2026-11-11/affected-reruns/) |
| Native Compatibility | 136 checks passed at each actual viewport, 1280×720 and 2560×1421. Both used Godot `4.7.stable.official.5b4e0cb0f` with OpenGL 3.3 on the RTX 5060 Ti. Captures show the real cabinet and CRT. Native evidence is from `425c815`, with the outbound footer and save-validation correction verified by affected reruns. [1280 log](evidence/fuel-reserve-2026-11-11/native-1280x720.log) · [Large-window log](evidence/fuel-reserve-2026-11-11/native-2560x1440.log) |
| Preservation and documentation | SHA-256 matched for all seven actual save files and 23 image sidecars. The three Word masters were edited first and changed text and table cells matched the Markdown. Affected rendered pages were inspected at the documentation checkpoint and after the status update. [Hash evidence](evidence/fuel-reserve-2026-11-11/save-and-sidecar-preservation.json) |

The native fixture positioned the player at ordinary reticle stances, about 1.25 m in front of the cabinet and 1.10 m in front of the CRT. It used F, number selection, distinct and held E, ESC and ordinary reticle TAKE. With the reserve at zero and Kitchen carrying capacity at 10 Bulk, genuine expedition seed 27 delivered two Fuel items worth 20 Utility. After the full outgoing cycle the next deposited delivery began in normal freight, with about 19.12 Utility still in reserve. Recovery used the unchanged generated pool and ordinary carry limit. [Green CRT](evidence/fuel-reserve-2026-11-11/freight-normal-1280x720.png) · [Waiting CRT](evidence/fuel-reserve-2026-11-11/freight-wait-2560x1421.png) · [Emergency OPEN](evidence/fuel-reserve-2026-11-11/freight-open-emergency-2560x1421.png) · [Fractional preview](evidence/fuel-reserve-2026-11-11/fuel-fractional-1280x720.png)

The fixtures use the existing six-Utility goal and sixteen-definition expedition pool. The focused post-victory sample took about 64 ms in the save service and 8 ms in capture. Windows certificate-store and held-item material diagnostics remain in the logs, along with the deliberate invalid-cargo and save-write-blocker cases. Larger-stock save cost, release balance, short silent suspension and crash durability remain open.

## Developer playtest checklist at technical handoff

1. Start a New Run in an isolated profile. Verify 55/60, normal green freight, and that F only inspects. Select Fuel, check fractional credit and waste, then press E once. Try a full tank, an ineligible item and holding E through ESC.
2. Use an isolated low-reserve fixture to check the three dimmer tiers, orange CRT and normal restoration. Observe goal and item legibility and ordinary W1 indication.
3. Leave a load OPEN for over a minute, clear it, and watch complete closing and outbound. The next ready load waits a fresh minute. An additional arrival preserves the deadline and order.
4. Top up during a wait first below 15, then to at least 15. Observe the retained deadline and then one immediate start. Check that subsequent power loss leaves the ongoing cycle running.
5. Save and Continue while waiting, during a cycle and after refuelling. Check the reserve fraction, exact cargo, crew, deadline and first-victory time. Try the ordinary Kitchen, shelf, ladder and Incinerator interactions.
6. At zero reserve and 10 Bulk carrying capacity, unload and physically carry generated Fuel to the cabinet. Verify that refuelling restores ordinary freight and that the next deposit arrives after full turnaround.

## 11 November 2026 developer promotion

The developer explicitly promoted Fuel Reserve and Emergency Freight after a successful gameplay test. At promotion the milestone was **HUMAN-PROMOTED / CLOSED IN ITS BOUNDED SCOPE — LOCAL; PUBLICATION PENDING**.

The developer reported the following observations from the scenarios played:

- The starting reserve, maximum capacity and consumption behaved as specified. In the run without initial top-ups, the three thresholds took effect at the expected times and produced the expected lighting changes.
- Below 15, the CRT displayed emergency freight in orange. The minute wait occurred at the expected stage, and the normal delivery animation and sounds played uninterrupted.
- Refuelling above 15 restored normal freight. Refuelling across the other thresholds restored their corresponding lighting levels.
- Refuelling produced no unexpected grace periods, threshold rewards or other triggers. At zero, the reserve stayed at zero without debt or an additional event.
- Other game systems, saving and loading, and victory progress behaved as expected in the tested scenarios.

The technical evidence above covers exact equality at 15, additional continuation boundaries and power permissions for the future Workshop and Salvager systems. Recovery coverage uses the sixteen-definition expedition pool. Production balance, broader catalogue recovery, large-stock save cost, short silent suspension, crash durability and the recorded diagnostics remain qualified.

The close-out starts from the verified local handoff on `codex/fuel-reserve-emergency-freight`. The remote advertised `main` at `a58cbf594a4e12d202cd8ba56d3ef73c82b03019` on 11 November 2026 and had no branch ref for the local Fuel branch.

## Dispatch follow-up

The developer separately reported that with zero Ready scavengers and no formed current crew, Dispatch displays `1 selected` and permits affinity edits. Departure is correctly blocked. The reported screenshot shows eight Away expeditions, zero Ready, selected affinities and a disabled Dispatch button.

The introduction date and any relationship to Fuel remain open. The developer accepted the repair on 11 November 2026. The repair is published on main. [Dispatch repair result](2026-11-11-dispatch-no-ready-repair-result.md)

## 11 November 2026 publication

GitHub `main` first published the accepted Fuel and Dispatch history on 11 November 2026. A separate `git ls-remote origin refs/heads/main` check verified `a19636df5df5169cd4c2e41b80f0986c78f7a83b`.
