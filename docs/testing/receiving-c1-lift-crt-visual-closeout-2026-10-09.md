# Receiving C1 — CRT visual-only SubViewport close-out

**Date:** 9 October 2026.

**Status:** IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-ACCEPTED; promoted **only in this bounded visual scope**. **Receiving C1 overall remains OPEN; Receiving Stage C physical queue pressure remains later.**

## Human acceptance and limits

The developer reviewed the current proof in game and accepts it without additional tuning. Primary/larger status information is reasonably readable from the Dispatch doorway and plausible in-room positions/angles; smaller secondary text appropriately requires proximity. The original screen curvature is accurately preserved. The subdued dark plastic bezel is sufficiently understandable as powered-on equipment and is not a blocker. No light spill onto the bezel/wall is explicitly accepted; no extra lights, emission-based room illumination, glow or lighting pass is required.

The current composition, dimensions, font sizes, layout, mock text, brightness, model and mounting are accepted **prototype choices**, not permanent production UI specifications. This records the supplied in-game human observations; it does **not** claim a separate completed human F5/F6 side-by-side acceptance procedure. Automated startup parity is verified separately below.

## Exact implementation and preservation

Reviewed proof commit: `03f73aa0df67b6c62352b24d6ad878730d5df500`, on `codex/receiving-lift-crt-visual-proof`. Preflight local main, freshly fetched origin/main and independently queried live remote main all matched `aee0ecd5365a49b07324c83c510920df64fb3223`; the accepted feature is a fast-forward descendant. Godot is `4.7.stable.official.5b4e0cb0f` at `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`.

Production owner: `res://gameplay/logistics_wing/wing_gameplay.tscn`, configured UID `uid://bljf1nlhijej`. Exact mesh: `WingGameplay/ReceivingLiftMonitor/SM_KB3D_CPP_PropTV_A/Mesh`, from `res://assets/environment/infrastructure/service_props/SM_KB3D_CPP_PropTV_A.glb`. Surface **1** is the original curved screen; instance-local UV1 scale `(4.611302975, 5.949906454, 1)` and offset `(-2.119711754, -2.159240137, 0)` normalize its atlas rectangle. No overlay geometry is used.

`ReceivingLiftMonitor/PhosphorDisplay/ScreenViewport` is a passive **704 × 400 SubViewport** rendering small Control/Label UI. Its runtime-only helper binds the actual viewport texture to the scene-local unshaded Surface 1 material; editor saves retain a dark authoring material without a live pathless texture. Present text includes `STATUS: IDLE`, `DECK: CLEAR`, `QUEUE: 00`, freight-lift identity/ONLINE and the awaiting-freight footer. These are **static mock values**, with no real delivery, queue, lift or expedition data authority.

This close-out changes no scene, script, test, GLB, material, visual or behavior. CRT transforms, geometry, source/material ownership, UVs, text and both hidden monitor alternatives remain exactly accepted. Manual Receiving dressing/hidden alternatives, sibling collision proxies, shell, four-light baseline, shutter/barrier poses, deck/profile, TAKE-only contracts, reaches and sixteen ordinary storage surfaces remain preserved. Normal Receiving startup is empty. No input/interaction, gameplay signal/data connection or light was added. No master DOCX, readable edition or historical report is revised.

Both pre-existing dirty files remain unstaged and byte-identical to this run's preflight:

- `data/environment/receiving_proof/eaf5_review_control.png.import`: SHA256 `621DE3C3B065AD001B9C30D7C72F98FA046535FEB69F5119061C508EDCD280EA`.
- `data/receiving/receiving_deck_stage_b_proof.tres`: SHA256 `33914E658F2873175218FA4E809BF34AF883480242F15C20A1D4658D6F349868`.

## Fresh verification and local evidence

Commands ran from `D:/Godot Projects/Sorting-apoc-PROTOTYPE`:

```powershell
$godot = 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe'
& $godot --headless --path . --script res://tools/asset_pipeline/tests/<suite>.gd
& $godot --path . --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tools/asset_pipeline/tests/receiving_lift_crt_tests.gd
& $godot --headless --editor --path . --quit
& $godot --headless --path . res://gameplay/logistics_wing/wing_gameplay.tscn --quit-after 16
```

| Required check | Outcome |
| --- | --- |
| `wing_startup_parity_tests` | PASS before explicit canonical loading; configured UID resolves to the canonical scene, one scanned declaration, empty startup / sixteen surfaces |
| `wing_gameplay_composition_tests` | PASS; two intentional duplicate-seed rejection diagnostics |
| `receiving_set_dressing_collision_tests` | PASS, zero failures |
| `receiving_lighting_integration_tests` | PASS, 126 checks |
| `receiving_lift_installation_tests` | PASS |
| `receiving_infrastructure_integration_tests` | PASS, zero failures |
| `receiving_lift_crt_tests`, real OpenGL | PASS, zero failures; configured UID and explicit fresh instances each bind their own viewport RID and render 704 × 400 / 4,041 sampled green pixels |
| Normal headless editor parse / explicit saved canonical launch | Exit 0; no script/resource error or warning |
| Scope review, dirty-byte comparison, `git diff --check` | PASS; only the four requested documentation files changed |

Graphics evidence uses Compatibility / OpenGL 3.3 on NVIDIA GeForce RTX 5060 Ti, driver 617.14. Fresh raw logs and before/after hash records are ignored local evidence under `reports/logistics_wing/receiving_lift_crt_closeout/2026-10-09/`. Startup parity is repeated after documentation and publication, with its final outcome in that folder's `publication.txt` and delivery response.

Original proof evidence remains unchanged under `reports/logistics_wing/receiving_lift_crt/2026-10-09/`: `REPORT.txt`, UV native/corrected calibration, runtime approach/reading/oblique captures and viewport pixels. These ignored assets/captures are available locally, not included in Git publication. Earlier diagnostic red runs and the disposable editor-only repack harness's historical teardown warnings remain historical; normal editor/runtime checks pass. The locally provisioned ignored asset library is not a complete portable Git backup.

## Publication and remaining scope

The documentation-only commit containing this record is the intended verified fast-forward publication tip; the exact resulting close-out/publication SHA, refreshed local/fetched/live main agreement, post-publication startup result and merged-local-branch cleanup are recorded in ignored `reports/logistics_wing/receiving_lift_crt_closeout/2026-10-09/publication.txt` and the final delivery response. The original proof commit remains unchanged. Publication uses a normal non-force main push after fresh ancestry checks; no unrelated/research branch or remote feature branch is removed.

Future real-state wiring requires a separately established expedition/lift queue and status data contract. No fake data, manual elevator controls or live connection is introduced. Final status vocabulary and maximum text block are not established. Only when those requirements exist should later approved work reconsider physical screen size, text scale, content density and layout together while preserving in-world readability and room coherence. Accepted absence of light spill is not outstanding repair work. **C1 overall stays OPEN; Stage C remains a later milestone. No new implementation begins during this close-out.**
