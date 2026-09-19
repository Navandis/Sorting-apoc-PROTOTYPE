# Shelf / ceiling ergonomics comparison

**Status:** playable review experiment; no production height has been selected.

Launch the explicit review scene; it never replaces the default launch:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn -- --ergonomics-case=A
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn -- --ergonomics-case=B
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn -- --ergonomics-case=C
```

No flag starts A. The review uses Gallery B's accepted shell and entry, the ordinary gameplay player/HUD (1.716 m eye, 75° FOV, normal movement and interaction distances), and a warm-neutral, shadow-enabled local lighting pair below 2.80 m. Existing Gallery-B fill/key lights are disabled only in this review instance. F6 is the existing developer-grid presentation, default OFF; F7 is inert.

## Conditions and measured supports

All support heights are from the finished floor. Metal and locker retain their existing four-level profiles and actual storage/zone/place/retrieve path. Visual compression is Y-only; generated `StorageSurface` and stored hosts remain unit-world-scale. The cabinet deliberately has no `StorageSurface`, zone or PUT path.

| Family | A: 3.40 m | B: 3.40 m | C: 2.80 m |
| --- | --- | --- | --- |
| Open metal shelves | levels 0.312 / 1.134 / 2.006 / 2.851 m; limiting clearance 0.540 m | levels 0.162 / 0.565 / 0.992 / 1.406 m; lower openings 0.403 / 0.427 / 0.414 m, top 1.999 m | B geometry; lower openings unchanged, top 1.399 m |
| Ventilated locker | levels 0.142 / 1.093 / 1.733 / 2.224 m; limiting clearances 0.952 / 0.640 / 0.491 / 0.519 m | levels 0.096 / 0.696 / 1.099 / 1.408 m; limiting clearances 0.600 / 0.403 / 0.309 / 0.327 m | B geometry and clearances unchanged |
| Clothes cabinet | current full-height visual; five loose TAKE samples only | Y-compressed candidate; five loose TAKE samples only | same B candidate; five loose TAKE samples only |

The B/C locker's highest usable support is **1.408 m**, inside the approved 1.35–1.45 m trial range. Case C replaces only Gallery B's two local roof slabs and their colliders with an aligned 2.80 m review ceiling; the rest of the wing is untouched.

## Samples and checks

The functional path seeds actual reserved samples using existing `ItemInstance`, `WorldItem`, zones and controller placement: medicine, flat book/CD-class media, a dark small electronic item, and Fuel. The cabinet presents the same representative catalogue classes plus a larger irregular item as loose, pickup-only samples; their hosts are outside the visually scaled cabinet subtree.

In B/C, `loot_000015` (Fuel) is explicitly reported as not fitting the locker level-3 0.309 m opening; it is not resized or forced through validation. The focused review check retrieves and re-stores a reserved sample through the ordinary path, confirms unit scale and F6/F7 behavior, and exercises a credible too-tall rejection in a compressed opening.

Run evidence:

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/shelf_ergonomics_review_tests.gd
& $godot --headless --editor --path . --quit
```

The focused test passed for A/B/C. It intentionally emits the Fuel non-fit warning for B/C. The editor scan and the preserved normal-launch composition smoke are recorded with this branch's final checks.

## Renderer observations for human review

Six player-eye captures were rendered in Compatibility mode at normal front and right-front stances under the same local light locations/settings in A/B/C. They show genuine mesh/panel/cage shadows, no emissive loot, outlines or per-case brightness adjustment. The captures are intentionally ignored review output under `reports/logistics_wing/shelf_ergonomics/`.

- The open metal shelves remain the clearest front-side reference; B makes all four supports reachably low, but its roughly 0.41 m lower openings visibly compress tall-item headroom.
- The locker reads as a real, shadowed enclosure. B/C keep the top support within the target band, but the cage and 0.309 m level-3 clearance make dark/rear recognition and Fuel placement intentionally poor; side/back peeking is not a pass criterion.
- The cabinet is evidence for visibility and loose pickup only. In the unboosted front-side renderer views, its partitioned samples are not reliably legible enough to count as a visual-access pass; that negative result is retained rather than corrected with extra fill, outlines or storage behavior.
- C changes containment/ceiling perception without changing fixtures or lighting. It should be judged for whether the 2.80 m lid feels cramped at the ordinary player eye, not promoted automatically.

Human review should decide: which supports can be seen, recognized, targeted and retrieved from front/left-front/right-front stances; whether light alone rescues dark items; whether B's compressed openings are too restrictive; and whether C improves containment without feeling cramped. No production promotion follows from this document.
