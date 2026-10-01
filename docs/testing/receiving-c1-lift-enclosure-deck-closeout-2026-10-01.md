# Receiving C1 fixed lift enclosure and widened deck close-out — 1 October 2026

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-PROMOTED.** Scope: current fixed cage/enclosure, inner shaft walls, barrier integration, widened physical platform, Receiving-private metric isolation, current MainDeck/profile/socket layout and tested Stage B cargo presentation. Receiving C1 and Stage C overall remain open.

## Verified lineage and metric owner

Starting clean branch: `codex/receiving-inner-shaft-walls`, HEAD `588ba69c2e058dc6649e70321e62997990ae6ed8`. Local main, fetched origin/main and live remote main were `7f659141c337921a304bb2af7cd7836b7910a6f4`; the feature is a clean three-commit descendant. Godot: `4.7.stable.official.5b4e0cb0f`, executable `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`.

| Commit | Result |
| --- | --- |
| `b9fdaab7a3fc5c1d61790d4e9f57eb136b8df051` | Shaft-wall implementation |
| `c76442f73584c89f4fcd1763d817e01799ca3a57` | Human widening/tuning of lift cage and shaft |
| `588ba69c2e058dc6649e70321e62997990ae6ed8` | Private metric isolation and widened profile reconciliation |

ReceivingRuntime's inherited visual scale (X=1.11, Y=1.225) distorted literal profile metres through generic StorageSurface's intentional scale-aware conversion. ReceivingDeckSurface now isolates its world origin and orthonormalized orientation before applying profile pose and invoking unchanged generic storage; fixture visual roots share that metric frame. Initial metric regression reproduced six failures, fixture alignment three; final regressions are GREEN. Ordinary scaled furniture retains its scale-aware conversion. Decimal whole-cell precision is handled only at Receiving surface/planner/commit boundaries with a 0.000001-cell tolerance (0.1 micrometre at 0.10 m).

## Promoted deck and enclosure contract

Fresh transformed-mesh measurement: physical top approximately **3.441 × 2.100 m**, metric X ±1.7205, Z -1.050001..+1.049999, Y approximately zero (world Y=0.82). MainDeck is **3.30 × 2.00 m / 33 × 20 / 0.10 m cells**, identity profile-local transform. Side margins are 0.0705 m; front/rear approximately 0.05 m within source precision. No logical cells extend beyond the physical top. Live backend is unit-scale, 33 × 20 at literal 0.10 m.

Profile revision **4** rejects revision-3 prepared presentation without exposing cargo, silently replanning or changing durable state. `layout_version=3` remains justified: compatibility uses profile ID/revision; layout_version has no additional runtime migration contract. Capacity **6.60 m² / 660 cells**, versus 6.00 m² / 600, is a human-accepted **+10% presentation capacity** decision; Bulk targets, Expedition generation, economy and loot balance remain unchanged.

| Socket | Cell origin |
| --- | --- |
| crate_front_left | (1,13) |
| crate_middle_center | (14,13) |
| crate_rear_right | (27,13) |
| pallet_front_right | (22,0) |
| pallet_rear_left | (1,0) |

All supported variants fit with non-overlapping reservations; crates are FRONT (+Z), pallets REAR (-Z); activated fixtures contain cargo and widened sides remain usable for loose cargo. Historical socket identifiers are retained.

Human-authored platform/cage/shaft/frame/shutter transforms are unchanged from the widening checkpoint. Shaft walls remain visual-only Dirty Concrete; barrier collision is unchanged and excludes player entry. Shutter markers remain closed Y=1.85 / fully open Y=4.93. P05_C02 room shell and current unpromoted lighting are unchanged.

## Explicit human review

The human accepts the current widened cage/shaft composition, physical platform, private metric fix, logical profile/socket reconciliation and presentation capacity. Manual review reported items using the widened surface, no observed platform-edge overhang/out-of-bounds placement, normal TAKE, no PUT, manual placement, zoning or runtime gameplay grid toggling, and no gameplay issue in the reviewed configuration. Acceptance is explicit human evidence, not inferred from captures or tests.

Dirty Concrete is **PROVISIONALLY ACCEPTED for the inaccessible inner shaft-wall role, pending representative Receiving lighting**. This is not a final room-wide material endorsement. P05_C02 remains accepted for the approachable apron/room structural palette; the earlier rejection of Dirty Concrete in that role remains valid.

## Fresh final verification

All twelve suites PASS, exit 0, at exact implementation HEAD `588ba69`. Command from authoritative root: Godot executable above with `--headless --path . --script res://tools/asset_pipeline/tests/<identifier>.gd`.

| Identifiers | Result |
| --- | --- |
| receiving_deck_metric_tests; receiving_deck_layout_tests; receiving_deck_presenter_tests | PASS |
| receiving_freight_fixture_runtime_tests; receiving_freight_fixture_policy_tests; receiving_freight_reach_tests | PASS |
| receiving_loot_batch_tests; wing_gameplay_composition_tests; receiving_lift_installation_tests | PASS |
| storage_stack_surface_tests; storage_stack_clearance_tests; storage_stacking_interaction_tests | PASS |
| `--headless --path . --editor --quit`; `git diff --check` | PASS |
| Existing ignored `measure.gd` mesh/live-grid probe | PASS |

Full logs inspected: no script, missing-resource or assertion failure. Known non-blocking Windows root-certificate-store error; composition intentionally emits two duplicate seed-namespace rejection errors; storage clearance intentionally warns about MissingContextShelf's 0.750 m fallback. Editor changed only an import sidecar's line endings; normalized content matched HEAD and its original CRLF form was restored, excluded from staging.

Fresh farthest successful production-path pickup: **2.88975715637207 m**, legal widened extent `legal_extents:item_0`, Computer Mouse 01, MainDeck cell (0,0), metric host (-1.55,0.012,-0.950001), stance Z=+1.2, camera (-38.60135,1.716969,1.063516). Bare/crates/pallets/mixed and legal corners/middle progressively drain through real stance/ray/click with exact committed ItemInstance identity. Receiving TAKE stays **3.4 m**, loose **1.4 m**, ordinary storage/manual **2.3 m**. Private surfaces expose no PUT/manual placement/zoning/gameplay grid/F6, remain excluded from **16** ordinary functional surfaces; normal launch synthesizes no delivery.

Fresh ignored logs: `reports/logistics_wing/lift_reconciliation/widened_profile/closeout/`. Prior `owner_fix_result.txt`, RED/GREEN diagnostic evidence and `review/01_empty_grid.png` through `06_oblique_seating.png` remain preserved under that widened_profile tree. Captures were not regenerated; their review does not substitute for human acceptance.

## Deferred work and operational authority

Shutter interaction gating remains deliberately unimplemented; the current collisionless shutter does not itself block pickup.

| Shutter state | Required future Receiving pickup |
| --- | --- |
| Closed | Disabled |
| Opening | Disabled |
| Fully open | Enabled |
| Closing | Disabled |

Shutter animation/theatre/audio and broader Stage C queue/theatre remain deferred. Receiving lighting design + fixture-layout planning is next; fixture assets are already provisioned under `res://assets/environment/infrastructure/lighting/` and must be inspected in that next milestone. Use the completed cage/shutter/shaft as real occlusion/mounting context. No fixture inspection/selection/placement or lighting change occurred here. Final shaft-material judgment requires representative lighting; furniture/infrastructure/contextual wear follow later.

This record, [CURRENT_STATE](../CURRENT_STATE.md) and [CODEX_BOOTSTRAP](../CODEX_BOOTSTRAP.md) supersede exact older Receiving deck dimensions, physical lift/enclosure and next-step/gate details in GDD v0.11, Findings v0.11 and VDD v0.8 until the next proportionate master reconciliation. The historical 3.00 × 2.00 / 30 × 20 deck and 3.10 × 2.10 support are not current authority. No DOCX master refresh or independent readable-extract regeneration occurred. Historical records retain their original evidence states; the 30 September close-out continues to govern P05_C02 room-shell promotion.

Publication is authorized as a documentation close-out commit followed by a non-force fast-forward/push of main; no implementation history is amended. Exact verified game code remains unchanged by this close-out.
