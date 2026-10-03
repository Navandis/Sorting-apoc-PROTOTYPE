# Receiving C1 — first production lighting baseline close-out

**Date:** 3 October 2026
**Status:** Receiving first production lighting baseline — IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-PROMOTED.

The human completed visual/play review and accepts the current saved Receiving state as a solid production starting point. This baseline governs until explicitly superseded. Later furniture/services/infrastructure/wear may justify a small proportionate lighting review. C1 overall remains open; this closes only the first production lighting baseline.

## Exact verified state and authority

- Feature branch: `codex/receiving-lighting-step2`.
- Exact feature/code tip freshly verified: `ea202bf13b6eda6e07603b923500ad054e733e71`.
- Latest human-authored commit: that same SHA, `art: light bulbs, pendants and light fixture ceiling supports` (Navandis, 3 October 2026). It changes only `gameplay/logistics_wing/wing_gameplay.tscn`; manual bulbs/chains are accepted and were not recreated or repositioned.
- Pre-publication local main, fetched origin/main and live remote main: `bcea088c03a7e1d9120187ba596a8910e18a6c4e`; feature descends cleanly from that main.
- History retained: lighting `a2858108baaf36cc82bd6a8df28125d79ac32ead`; seating/G1 shadows `4135103deb6f0095f70ec69cbf65c59d96f48e2a`; remaining wall shadows `e41ab53814af659764ac367f621b8e27e9a58916`; final shaft material `a3d39b3024be08749a2ae82a5efad20887f97872`; human hardware `ea202bf13b6eda6e07603b923500ad054e733e71`.
- Initial worktree was clean. Editor load produced only known import-sidecar line-ending status noise in `data/environment/receiving_proof/eaf5_review_control.png.import`; it is preserved unstaged and excluded from the close-out commit.
- Godot `4.7.stable.official.5b4e0cb0f`, executable `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`.

This record and [CURRENT_STATE](../CURRENT_STATE.md), [CODEX_BOOTSTRAP](../CODEX_BOOTSTRAP.md) and [README](../README.md) supersede older Receiving lighting/shaft-material statements. The [1 October enclosure/deck record](receiving-c1-lift-enclosure-deck-closeout-2026-10-01.md) remains authority for accepted geometry and deck dimensions; its provisional Dirty Concrete shaft/lighting statements are superseded. Historical records, DOCX masters and readable extracts are unchanged.

## Promoted lighting contract

Room-owned `Environment/ReceivingLighting` instances `receiving_lighting.tscn`: exactly 3 warm apron pendants, 2 warm-neutral cage task strips and 1 physical unlit warning/alarm provision. Exactly 5 shadow-casting SpotLight3D; no Receiving OmniLight or helper fill. Ambient energy 0.12; legacy West and Sorting lights disabled; shared directional key, exposure 1 and Filmic retained.

| Installation | Fixture position (m) | Fixture scale | Spot position (m) |
| --- | --- | --- | --- |
| G1 | (-36.9, 4.137, -1.6) | 1.65 | (-36.9, 3.675, -1.6) |
| G2 | (-33.25, 4.137, 2.4) | 1.65 | (-33.25, 3.675, 2.4) |
| G3 | (-30.4, 4.137, -1) | 1.65 | (-30.4, 3.675, -1) |
| T1 | (-40.4, 3.1, -0.8) | 0.65 | (-40.4, 2.9, -0.8) |
| T2 | (-40.4, 3.1, 0.8) | 0.65 | (-40.4, 2.9, 0.8) |
| W1 | (-38.83, 2.85, 2.2) | 1.0 | No Light3D |

Saved orientations remain accepted. G1/G2/G3 energy 1.9, range 6.2 m, angle 55°, color (1, 0.84, 0.68), shadow_bias 0.05 and shadow_normal_bias 0.5. The corrected general-spot bias settings remove the reviewed wall hashing at both north-wall pieces neighboring Dispatch and the southern wall while retaining useful cage/cargo shadows. T1/T2 retain energy 0.85, range 3.2 m, angle 52°, color (1, 0.94, 0.82), shadow_bias 0.025 and shadow_normal_bias 0.25. Task-strip local emission remains 0.6; W1 has no emission or light. No tuning occurs during close-out.

Human review accepts loose and crate/pallet cargo readability, dark-item readability, visibility from legal player angles, cage task illumination, a muted/non-distracting cage roof, no major normal-play glare/artifact and localized practical-light hierarchy. Technical headless checks corroborate the saved contract; visual acceptance is the human's review, not a new headless visual claim.

## Promoted seating and preserved gameplay

Improved lighting exposed previous floating. Separate Receiving-private loose cargo, fixture-body support and cargo-on-fixture contact corrections are promoted, with approximately 0.5 mm final contact epsilon. Fixture bodies seat on the inset deck plate rather than the raised edge (0.010392 m support correction); no platform/geometry movement. Horizontal layout, profile/cells, sockets, reservations, reaches and ordinary TAKE/progressive drain remain unchanged.

MainDeck remains 3.30 × 2.00 m / 33 × 20 cells at 0.10 m, revision 4 / layout_version 3. Receiving/loose/storage reaches remain 3.4 / 1.4 / 2.3 m. Barrier exclusion is unchanged. Sixteen ordinary storage surfaces remain installed; normal launch has no synthetic delivery. Contact regression covers 228 items and 14 fixture occurrences across all eight fixture definitions.

## Locked shaft material

All three `ReceivingLiftInstallation/ShaftWalls/ShaftWall_Left`, `ShaftWall_Right` and `ShaftWall_Rear` use **eaf3b_1beac3a311a480af8844ea89 / KB3D_BYR_COReinforcedConcreteSlabs**. Mapping mode 0 (UV), 3.0 m/repeat, normal strength 1.0; approved albedo/roughness/metallic unchanged; no finish, structural secondary or fixed wear preset. The walls remain collisionless and retain human-tuned geometry/transforms. Dirty Concrete is no longer bound as the production shaft-wall material. P05_C02 remains room/apron authority.

## Accepted human hardware and deferred emitter treatment

The human-authored three visible bulb/glass nodes and three chain/link nodes in WingGameplay are accepted as part of the pendant installations. Technical inspection finds one mesh per instance, resources present, finite nonzero transforms, no collision and no embedded Light3D. The human commit does not mutate source assets. This close-out changes no art, source asset or production code.

Visible bulb self-emission/fixture self-light is intentionally deferred and is not a blocker. After intentional fixture layouts exist in additional rooms and infrastructure/furnishing provides final context, a reusable cross-room fixture task may evaluate glass shell, inner emissive core and optional tiny fixture-only self-light, separate from room-lighting Light3D. No emissive cores, bulb omnis, glow/bloom changes, fixture self-lights or reusable bulb framework are added now. Current room SpotLight3D remain illumination authority.

## Fresh verification

All checks ran against exact code tip `ea202bf13b6eda6e07603b923500ad054e733e71`, before documentation edits. Headless commands use `--path . --script res://tools/asset_pipeline/tests/<suite>.gd`; editor load uses `--headless --editor --path . --quit`.

| Check | Result |
| --- | --- |
| receiving_lighting_integration_tests | PASS, 128 checks, exit 0 |
| receiving_contact_seating_tests | PASS, 0 failures, 228 items / 14 fixtures, exit 0 |
| wing_gameplay_composition_tests | PASS, exit 0 |
| receiving_lift_installation_tests | PASS, including all three reinforced-concrete bindings/settings, exit 0 |
| receiving_freight_reach_tests | PASS, normal TAKE / progressive drain / legal extents, exit 0 |
| Editor parse/load | PASS, exit 0, no scene/resource/script failure |
| Manual fixture technical probe | PASS, all six human art instances, exit 0 |
| git diff --check | PASS |

Full logs were inspected. Known Windows root-certificate-store diagnostics occur during Godot startup; composition deliberately emits two duplicate seed-namespace rejection errors in negative tests. No substantive verification failure occurred. Editor reimport sidecar status noise is retained outside the commit. Additional gameplay suites were unnecessary because the human art commit touched no gameplay/profile owners beyond scene art instances.

Fresh ignored evidence: `reports/logistics_wing/receiving_lighting_closeout/2026-10-03/` (five suite logs, editor log and manual technical probe/log). Focused historical evidence remains in the Step-2, Step-2a, wall-follow-up and Step-2b report folders dated 2 October; none was rewritten.

## Deferred work and next milestone

- Receiving ↔ Backlog threshold: **DEFER_TO_BACKLOG_PASS**. The pre-existing same-plane apron/Backlog floor/sill overlap was exposed by lighting; it belongs to Backlog production work. No threshold geometry change here.
- Shutter pickup gating: future closed/opening/closing → disabled; only fully open → enabled. Current collisionless shutter does not itself block TAKE; no gating implementation here.
- Warning behavior: physical/unlit provision only.
- Reusable cross-room emitter/self-light treatment and a small evidence-based post-furnishing Receiving lighting refinement remain deferred.

Receiving C1 remains open for later environment/infrastructure/furniture and contextual detail. Receiving Stage C physical queue pressure remains the intended gameplay milestone after C1. This record chooses no new implementation slice and begins none.

## Publication boundary

The human explicitly authorizes a documentation-only close-out commit followed by fast-forward-only publication of the verified feature history to main, non-force push, exact local/fetched/live SHA verification and safe merged feature-branch cleanup. Re-fetch before publication and stop if origin/main unexpectedly advances. Preserve unrelated changes and parked/research branches. No repeated game regression sweep is needed after the documentation-only fast-forward when the verified production tree remains identical.
