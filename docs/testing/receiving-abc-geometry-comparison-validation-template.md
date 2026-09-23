# Receiving Stage B — A/B/C Geometry Comparison Validation

**Date:** 22 September 2026  
**Status:** IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING

## Purpose

Select the vertical relationship between the Receiving front barrier and the future live lift/pile floor before irregular-pile implementation.

This comparison contains no real Receiving loot.

## Reference

```text
continuous upper barrier rail top Y: 1.27 m
```

## Cases

| Case | Recess below barrier | Deck top Y |
| --- | ---: | ---: |
| A | 0.10 m | 1.17 m |
| B | 0.45 m | 0.82 m |
| C | 0.70 m | 0.57 m |

## Delivered review geometry

```text
Branch:
Commit:
Comparison scene:
Comparison script:
Wing instance path:
Root transform:
Deck dimensions:
Occlusion mockup dimensions:
Pile-envelope preview dimensions:
Proxy item count:
```

## Automated verification

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/receiving_geometry_comparison_tests.gd
& $godot --headless --path . --script res://tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd
& $godot --headless --editor --path . --quit
```

Results:

```text
_fill_
```

## Human launch

Use the normal gameplay scene with the appropriate case override:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'

& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/wing_gameplay.tscn -- --receiving-geometry-case=A
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/wing_gameplay.tscn -- --receiving-geometry-case=B
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/wing_gameplay.tscn -- --receiving-geometry-case=C
```

## Review questions

For each case inspect from several metres away, normal approach, barrier-adjacent, and left/right positions.

Judge:

```text
Arrival readability:
Upper/middle visibility:
Lowest/front layer hidden enough:
Need to approach barrier to inspect base:
Downward viewing comfort:
Late-batch bottom access plausibility:
Lift/platform credibility:
Useful vertical capacity:
```

## Human decision

```text
Selected: A / B / C / interpolated
Chosen recess:
Chosen deck top Y:

Notes:
```

Promotion establishes only the floor/recess baseline for the next Stage-B pile proof.

It does not promote proxy geometry, final barrier art, pile dimensions, pile mechanics, support rules, lift doors, lift travel, or audio.
