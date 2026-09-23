# Receiving Stage B — A/B/C Geometry Comparison

**Date:** 23 September 2026
**Status:** IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING

## Purpose

Select the vertical relationship between the Receiving front barrier and the future live lift/pile floor before any irregular-pile implementation. This comparison contains no real Receiving loot, batch, settling, support, lift-travel, or storage behavior.

## Implementation

```text
Branch: codex/receiving-abc-geometry
Implementation checkpoint: ad03e35202273dff96a9c4852aa523c41b1ce420
Comparison scene: res://gameplay/logistics_wing/receiving/receiving_geometry_comparison.tscn
Comparison script: res://gameplay/logistics_wing/receiving/receiving_geometry_comparison.gd
Wing instance path: WingGameplay/ReceivingGeometryComparison
Component transform: position (-39.0, 0.0, 0.0), zero rotation, unit scale
Default case: B
```

The component is an editor-refreshing `@tool` scene. The A/B/C enum and `--receiving-geometry-case=A|B|C` runtime argument select the same three cases. Only the deck, proxy root, envelope root, and guide root move vertically.

## Authored geometry

```text
Continuous upper barrier reference: Y 1.27 m
Deck: 4.55 m deep (X) × 0.12 m thick (Y) × 6.55 m wide (Z)
Deck world centre X: -41.505 m
Occlusion panel: 0.08 m deep (X) × 1.27 m high (Y) × 4.80 m wide (Z)
Occlusion panel world centre: (-39.20, 0.635, 0.0)
Pile-envelope preview: 3.60 m deep (X) × 1.50 m high (Y) × 4.80 m wide (Z)
Envelope/proxy root world X: -41.505 m
Height guides: selected floor +0.5 m, +1.0 m, +1.5 m
```

The proxy load contains 11 visual-only primitive pieces inside the preview envelope:

```text
2 small boxes: each 0.34 × 0.22 × 0.42 m
2 medium boxes: each 0.74 × 0.48 × 0.66 m
2 large boxes: each 0.92 × 0.64 × 0.82 m
1 tall box: 0.42 × 0.94 × 0.44 m
1 canister: 0.50 m maximum diameter × 0.92 m high
1 long/flat box: 1.72 × 0.16 × 0.48 m
2 exposed upper boxes: each 0.54 × 0.38 × 0.50 m
```

These primitive dimensions and their shared local transforms are identical in A/B/C. The combined proxy bounding box and final pile dimensions are deliberately not promoted; the exact review envelope is the `3.60 × 1.50 × 4.80 m` volume above.

## Cases

| Case | Recess below barrier | Deck top / proxy root / envelope floor Y | Deck centre Y |
| --- | ---: | ---: | ---: |
| A | 0.10 m | 1.17 m | 1.11 m |
| B | 0.45 m | 0.82 m | 0.76 m |
| C | 0.70 m | 0.57 m | 0.51 m |

The accepted freight base remains at `Y = 0`; the comparison deck overlays it and does not excavate or modify the shell.

## Automated verification

The focused test checks scene existence and instantiation, the wing instance, the 1.27 m barrier reference, all three floor heights, invariant horizontal deck dimensions, invariant proxy local transforms, vertically coupled proxy/envelope/guides, no comparison collision, no `WorldItem`, no `StorageSurface`, the accepted freight-shell transforms, 16 continuing functional surfaces, and normal player/HUD instantiation.

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'

& $godot --headless --path . --script res://tools/asset_pipeline/tests/receiving_geometry_comparison_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd
& $godot --headless --editor --path . --quit

foreach ($case in @('A', 'B', 'C')) {
    & $godot --headless --path . --script res://tools/asset_pipeline/tests/receiving_geometry_comparison_tests.gd -- "--receiving-geometry-case=$case"
    & $godot --headless --path . --quit-after 8 res://gameplay/logistics_wing/wing_gameplay.tscn -- "--receiving-geometry-case=$case"
}
```

Results:

- Focused comparison test: exit `0`, `PASS: receiving geometry comparison tests`.
- Focused A/B/C runtime-argument checks: three exits `0`, three PASS markers.
- Actual `wing_gameplay.tscn` A/B/C bounded smokes: three exits `0`; every case installed the current 16 deterministic storage surfaces.
- Editor import/parse scan: exit `0`.
- Existing composition suite: exit `1` because its rack/shelf expectations predate user-authored commit `414c8a3`. The stale assertions expect Gallery A Z `-7.20`, rack Front `3`, and shelf heights `1.05 / 1.82 / 2.55`; current `main` already contains Z `-3.816217`, rack Front default, and heights `1.1643043 / 1.8968397 / 2.6355634`. This branch does not change those excluded fixtures or the composition test. The suite's expected duplicate-namespace diagnostics also remain present.

The comparison-specific test independently covers the requested continuing-gameplay count, player/HUD instantiation, and accepted-shell preservation, so the comparison itself is technically verified despite that unrelated stale baseline.

Known diagnostic: Windows headless runs report `Failed to read the root certificate store`; it did not affect any exit result or comparison assertion.

## Human launch

Run the normal gameplay scene with one case at a time:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'

& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/wing_gameplay.tscn -- --receiving-geometry-case=A
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/wing_gameplay.tscn -- --receiving-geometry-case=B
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/wing_gameplay.tscn -- --receiving-geometry-case=C
```

For each case inspect from several metres back, normal approach distance, directly against the barrier, and left/right of centre. Judge:

- arrival readability;
- upper and middle visibility;
- lowest/front layer exposure;
- whether base inspection requires moving close;
- downward-view comfort;
- late-batch bottom-access plausibility;
- platform-versus-pit feel;
- apparent useful vertical capacity.

The human may select A, B, C, or an interpolated recess. Promotion establishes only the selected floor/recess baseline for the next Receiving Stage B pile proof.

## Scope boundary

No real Receiving pile/batch mechanics were started. The comparison adds no `WorldItem`, physics, batch identity, storage surface, pickup/support metadata, lift travel, final art, or audio. Receiving Stage A, the accepted freight shell/barrier, player/controller, storage systems, `ModularRack`, `FixedLadder`, item definitions, and `DevelopmentSetup` contents remain unchanged.
