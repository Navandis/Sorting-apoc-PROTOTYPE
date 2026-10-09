# Receiving C1 — hand-authored set-dressing and collision close-out

**Date:** 9 October 2026.

**Status:** Receiving C1 hand-authored set-dressing technical integration — IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-ACCEPTED; human-promoted in this bounded slice. **Receiving C1 overall remains open.**

The human has completed in-game review and accepts the manual arrangement and technical cleanup: all requested colliders behave appropriately, the room remains navigable, there are no phantom collisions, and no authored assets are missing or shifted. The grouped ownership is accepted. This records that acceptance and fresh automated verification; no additional F5/F6 manual re-verification is claimed here. Historical compact-retrofit F5/F6/CLI acceptance remains recorded separately.

## Exact authority and preflight

- Authoritative project: `D:/Godot Projects/Sorting-apoc-PROTOTYPE`.
- Verified feature branch: `codex/receiving-infrastructure-c1-step2`.
- Human-art checkpoint: `8857615c5981dcaae27520cafe10acf41bad4f81`.
- Accepted technical cleanup / freshly verified code tip: `7e57dd49e774bcbb7567a39704dd158ef52d43fb`.
- Pre-publication local main, freshly fetched origin/main and live remote main agree at `da9c199782c2be0f4b272b66a08d3ec1c66640ef`; the accepted feature is a fast-forward descendant.
- Godot `4.7.stable.official.5b4e0cb0f`, console executable `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`.
- Two current dirty, unstaged files: `data/environment/receiving_proof/eaf5_review_control.png.import` and `data/receiving/receiving_deck_stage_b_proof.tres`. Their current bytes were captured and hash-checked unchanged; no historical dirt was recreated.

The 9 October implementation report and preservation/collision maps remain ignored evidence under `reports/logistics_wing/receiving_c1_set_dressing_cleanup/2026-10-09/`. Historical records retain their original evidence states. This record and the operational authorities supersede older pending-infrastructure and old shutter-pose wording without changing DOCX masters or readable extracts.

## Accepted ownership and legacy retirement

The human-authored saved composition superseded the earlier proposal-owned `Environment/ReceivingInfrastructure`. That live instance, canonical overrides, and its active hidden cabinet collider are retired. The unreferenced `gameplay/logistics_wing/receiving/receiving_infrastructure.tscn` and its embedded private resources are deleted; shared imported GLBs, textures and materials remain. There is no live legacy P1/E1/L1 subtree or phantom cabinet collision. Do not restore old proposed positions from placement manifests; the human-authored installation is authoritative.

`WingGameplay/ReceivingSetDressing` is an identity organizational parent **inside `wing_gameplay.tscn`**, owning `ReceivingDecals`, `ReceivingPipes`, `ReceivingElectrical`, `ReceivingDesk`, `ReceivingDecorations` and `CollisionProxies`. Art remains editable in full-room context; no separate set-dressing scene was extracted. `WingGameplay/ReceivingLiftMonitor` remains a separate direct owner; its selected CRT, authored placement, mesh/Surface 1 material state and hidden monitor alternatives are preserved.

All 38 intentionally hidden manual nodes retain their authored positions and effective visibility and have no active movement collision. They are preserved alternatives. Prior machine comparison retained 1,876 production nodes, including 248 reparented nodes, without meaningful transform/basis, geometry, asset, material or visibility change. The fresh saved-production snapshot exactly matches the accepted post-cleanup snapshot (1,906 current total nodes, including the new organization/proxies); 310 source/import file hashes also match. These are evidence counts, not instructions to manufacture incidental nodes.

## Collision contract and authoring maintenance

There are **11 StaticBody3D movement authorities / 17 BoxShape3D or CylinderShape3D primitives** under `ReceivingSetDressing/CollisionProxies`, all movement layer/mask **1/1**, with unit orthonormal collider bases. Each proxy's `visual_target` NodePath maps to its existing visual assembly. No imported collider duplicates, dynamics, pickup areas, storage registration or new usable interactions were added.

| Authored target | Accepted coarse collision |
| --- | --- |
| `SM_Desk_A01_N1` | Two thin L-arm tops, true cabinet support, outside leg; open underside retained |
| `SM_Res_Fur_Stool_Metal_Worn_01` | Cylinder |
| `SM_Utility_Box_1a` | Box fitted to housing |
| `SM_Metal_Barrel_RedWhite_01` | Cylinder |
| `PalletJack` | One authority with low forks, pump base and handle; three source components remain one assembly |
| `SM_WoodPallet_03` | One rotated slab for the middle leaning pallet |
| `SM_Electrical_Cabinet_01a` | Box |
| `SM_KB3D_DMZ_Bucket_A_Main` | Small cylinder excluding mop handle |
| `SM_PlasticBox_06` | Box |
| `SM_KB3D_WHS_PropDolly_A_Main` | Base and slim upright frame boxes |
| `SM_Ind_Aba_Storage_Barrel_Metal_Blue_01` | Cylinder |

**Maintenance rule:** sibling proxies do not auto-sync to visual transforms. After moving, replacing or activating a visual alternative, also deliberately move/refit its mapped unit-scale collision proxy and disable any superseded proxy. Visibility changes do not toggle physics. Do not attach scaled physics blindly to imported meshes, delete positioned hidden alternatives, create duplicate hidden/imported colliders, or treat furniture as functional storage/loot. Separate scene extraction requires separate approval.

## Preserved production contracts

Compact Receiving **8.00 × 7.50 m**, Dispatch **6.50 × 3.50 m**, openings and resolved threshold geometry remain authoritative. The translated manual lift, shaft geometry/locked reinforced-concrete material, single barrier authority and six disabled historical barrier shapes remain unchanged. Active NWD shutter `SM_KB3D_NWD_ReuGarageDoorBlue_B` retains its saved **closed** visual pose, local Y **0.086**, and Closed/Open markers Y **0.086 / 3.1416707**. The collisionless shutter visual shortcut remains; animation and pickup gating are deferred.

MainDeck remains **3.30 × 2.00 m / 33 × 20 / 0.10 m / profile revision 4**. Fixture sockets/seating, exact ItemInstance identity, TAKE-only presentation and reaches **3.4 / 1.4 / 2.3 m** are unchanged. Ordinary storage remains **16** surfaces; normal launch synthesizes no delivery. Receiving G1/G2/T1/T2 retain exactly four shadowed spots; ambient **0.12**, W1 unlit, West/Sorting disabled, shared exposure/key/tonemap and separate manual bulbs/chains are preserved. No production scene, test, gameplay, art, source asset or lighting edit was made during close-out.

## Fresh technical verification

All checks ran against exact accepted code tip `7e57dd49e774bcbb7567a39704dd158ef52d43fb` before documentation edits. Suite command:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/<suite>.gd
```

| Suite/check | Result |
| --- | --- |
| `wing_startup_parity_tests` | PASS before explicit canonical loads and after editor diagnostics; configured UID/path and unique scanned declaration |
| `receiving_set_dressing_collision_tests` | PASS: all targets block, checked contextual routes clear, hidden/legacy collision absent, canonical reload stable |
| `receiving_infrastructure_integration_tests` | PASS: grouped manual ownership, separate monitor, no live legacy installation or interactions |
| `wing_gameplay_composition_tests` | PASS; two deliberate duplicate-seed rejection errors from negative tests |
| `receiving_lift_installation_tests` | PASS: exact authored closed shutter/marker endpoints, shaft material/geometry and single barrier authority |
| `receiving_lighting_integration_tests` | PASS, 126 checks |
| `receiving_freight_reach_tests` | PASS: explicit MIXED and other supported fixtures/legal extents, production TAKE rays, identity-safe drain/progression |
| `receiving_contact_seating_tests` | PASS, 228 items / 14 fixtures, zero failures |
| `receiving_deck_metric_tests` | PASS |
| Editor `--headless --editor --path . --quit` | PASS, exit 0 |
| Saved gameplay/environment owner loads | PASS; no dangling legacy resource |
| Accepted snapshot, source hashes, dirty-byte preservation | PASS |
| `git diff --check` | PASS |

Configured `uid://bljf1nlhijej` resolves to `res://gameplay/logistics_wing/wing_gameplay.tscn` before explicit canonical loading. Full logs were inspected; no unexpected error, warning, script, parse or resource failure. Representative MIXED freight uses content seed 1842 / presentation seed 9001 / Bulk 24 and drains exact committed identities through legal TAKE stances. Fresh finite capsule/raycast probes cover apron, Dispatch, Backlog, desk/stool, cabinet, jack/pallet staging and cleaning nook. Controlled target-blocking checks isolate adjacent requested proxies; contextual clear-route checks keep all saved colliders active. This is finite verification, not a formal proof of every position or recovery contact; human in-game acceptance supplies the navigation-feel judgment.

Fresh ignored logs/summary: `reports/logistics_wing/receiving_set_dressing_closeout/2026-10-09/`. Existing production and wire-overlay captures remain in the earlier cleanup folder and were not regenerated or rewritten.

## Remaining scope and publication boundary

The local `res://assets/...` library and review evidence are external/ignored resources in this machine's workflow. Referenced assets load in this configured local environment; Git publication is **not** a complete portable asset archive for a clean machine. No bulk asset staging or pipeline expansion is part of close-out.

Receiving C1 overall remains open for signage/display and further contextual finish/wear or polish as separately authorized. Bulb emitter/self-light work, threshold walking-surface material, shutter animation/gating/theatre, final Expedition bounds, queue pressure, save/journal work and other recorded milestones remain deferred. The next separate candidate is a **visual-only green-phosphor CRT Surface 1 UV/SubViewport proof** on the selected monitor, before any real lift-status or expedition queue integration. No SubViewport, text/UI, display behavior, lift controller or backend connection is implemented here.

The human authorizes a documentation-only commit, fast-forward publication of the complete verified feature history to main, a non-force push, exact local/fetched/live main SHA agreement and safe deletion of the fully merged feature branch. Re-fetch before publication and stop on unexpected remote advancement or non-fast-forward ancestry. Preserve both dirty files and parked/research branches. No broad regression repeat is needed after documentation-only publication with identical verified production content.
