# Shelf / ceiling ergonomics comparison

**Status:** completed ergonomics evidence. The explicit review scene and the developer-authored modular-rack experiment are retained for future use; no production camera height, ceiling height, rack implementation or ladder system has been selected.

Launch the explicit review scene; it never replaces the default launch:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn -- --ergonomics-case=A
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn -- --ergonomics-case=B
& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn -- --ergonomics-case=C
```

No flag starts A. The review uses Gallery B's accepted shell and entry, the ordinary gameplay player/HUD (75° FOV, normal movement and interaction distances), and a warm-neutral, shadow-enabled local lighting pair below 2.80 m. Existing Gallery-B fill/key lights are disabled only in this review instance. It starts at a measured 1.800 m eye height above the finished floor; **F5** independently switches to the retained approximately 1.716 m review eye height without changing X/Z, view direction, item state, FOV, player scale, capsule, movement or reach. F6 is the existing developer-grid presentation, default OFF; F7 is inert.

## Conditions and measured supports

All support heights are from the finished floor. Metal and locker retain their existing four-level profiles and actual storage/zone/place/retrieve path. Visual compression is Y-only; generated `StorageSurface` and stored hosts remain unit-world-scale. The cabinet deliberately has no `StorageSurface`, zone or PUT path.

| Family | A: 3.40 m | B: 3.40 m | C: 2.80 m |
| --- | --- | --- | --- |
| Open metal shelves | levels 0.312 / 1.134 / 2.006 / 2.851 m; limiting clearance 0.540 m | levels 0.192 / 0.678 / 1.195 / **1.695 m**; openings 0.487 / 0.516 / 0.501 m, top 1.707 m | B fixture geometry; openings unchanged except top 1.107 m |
| Ventilated locker | levels 0.142 / 1.093 / 1.733 / 2.224 m; limiting clearances 0.952 / 0.640 / 0.491 / 0.519 m | levels 0.112 / 0.835 / 1.322 / **1.695 m**; openings 0.723 / 0.486 / 0.373 / 0.394 m | B geometry and clearances unchanged |
| Clothes cabinet | current full-height visual; five loose TAKE samples only | Y-compressed candidate; five loose TAKE samples only | same B candidate; five loose TAKE samples only |

The B/C metal and locker highest usable supports are **1.695 m** above the finished floor, meeting the revised nominal 1.70 m trial inside the approved 1.65–1.75 m range. The earlier 1.406/1.408 m low-height trial is superseded; it is not a current candidate. The complete metal fixture, its generated collision and functional surfaces use the same corrected left-hand position in A/B/C (X = 10.100 m, Z = -10.950 m), leaving approximately 0.28 m to Gallery B's north-wall inner face. Case C replaces only Gallery B's two local roof slabs and their colliders with an aligned 2.80 m review ceiling; the rest of the wing is untouched.

## Samples and checks

The functional path seeds actual reserved samples using existing `ItemInstance`, `WorldItem`, zones and controller placement: medicine, flat book/CD-class media, a dark small electronic item, and Fuel. Fuel now uses the revised locker level-1 0.723 m opening; the old low-trial Fuel non-fit is intentionally no longer expected. The cabinet presents the same representative catalogue classes plus a larger irregular item as loose, pickup-only samples. Its saved editor-visible hosts and imported visuals are in `gameplay/logistics_wing/review/shelf_ergonomics/cabinet_take_samples.tscn`; separate full-height and lowered authored host sets keep canonical item scale while seating Armor/Fuel on lower compartment floors and the small items on actual upper supports. Runtime only attaches `WorldItem` pickup components and checks that authored transforms remain unchanged.

The cabinet remains deliberately without `StorageSurface`, zones, PUT path, physics settling or automated arrangement. The focused review check retrieves and re-stores a reserved sample through the ordinary path, confirms the revised tall-item clearance, saved cabinet-host preservation, unit scale, eye toggle and F6/F7 behavior.

Run evidence:

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/shelf_ergonomics_review_tests.gd
& $godot --headless --editor --path . --quit
```

The focused test passes for A/B/C with no unfitted review samples. The editor scan and the preserved normal-launch composition smoke are recorded with this branch's final checks.

## Renderer observations for human review

Nine player-eye captures were rendered in Compatibility mode at normal front, right-front and close cabinet-front stances under the same local light locations/settings in A/B/C. They show genuine mesh/panel/cage shadows, no emissive loot, outlines or per-case brightness adjustment. The captures are intentionally ignored review output under `reports/logistics_wing/shelf_ergonomics/`.

- The open metal shelves remain the clearest front-side reference; B/C now retain roughly 0.49–0.52 m lower openings while their highest usable support is 1.695 m.
- The locker reads as a real, shadowed enclosure. B/C retain the 1.695 m top support; its 0.373 m third opening remains visually restrictive, but the 0.723 m lowest opening supports the retained Fuel sample. Side/back peeking is not a pass criterion.
- The cabinet is evidence for visibility and loose pickup only. In the unboosted front-side renderer views, its partitioned samples are not reliably legible enough to count as a visual-access pass; that negative result is retained rather than corrected with extra fill, outlines or storage behavior.
- C changes containment/ceiling perception without changing fixtures or lighting. It should be judged for whether the 2.80 m lid feels cramped at the ordinary player eye, not promoted automatically.

## Human disposition and retained conclusions

The developer completed the ground-access review and retained the review scene as a comparison tool. The storage installation, rather than the furniture mesh alone, is the usability unit: authored dimensions and levels, room placement, approach space, usable depth and edge insets, player viewpoint, reach, lighting, target visibility and obstruction all contribute.

- Uniformly compressing existing multi-level furniture is rejected as the general solution.
- More than three ground-access levels in the tested corner-mounted modular-rack context produced unacceptable visibility and manual-targeting compromises unless the shelves became too shallow or squat.
- The developer's manually authored three-level modular-rack configuration is a useful ground-access reference, not a universal production template. `SM_Rack01.glb` and `SM_Rack02.glb` remain static review-scene assets without functional storage surfaces.
- Open racks can tolerate more usable depth when approached from more sides. Wall and corner installations generally require shallower usable depth.
- A slim usable-area inset can be authored per edge. No single percentage is promoted, and useful front-edge capacity should not be deleted silently.
- Cabinet and opaque storage remain selective rather than the general storage backbone.
- The 1.80 m eye-height trial helped some upper-level cases but did not solve deep shelves or opaque dividers and sometimes worsened low-shelf viewing. It remains provisional.
- The 2.8 m ordinary ceiling looked more proportionate in the tested context. It is not a wing-wide production decision.
- Upper storage beyond ordinary standing access may use appropriate furniture, a deliberately absent top deck, shallow or specialist wall storage, non-loot upper dressing, or a fixed shelf-serving ladder where justified.

The developer owns final functional storage authoring: model choice, installation placement, unit dimensions, level count and distribution, and ladder availability and placement. Codex may assist with tools, validation, decoration and later synthetic checks.

## Fixed ladder status

A fixed shelf-serving ladder is approved for one bounded proof based on this ergonomics evidence. It is not production-approved. The proof does not authorize general climbing or jumping, movable or sliding ladders, animations, visible hands, a fall system, or shelf-adjustment interaction. Player-adjustable shelf levels remain a post-release or expansion possibility with no weight in the current ladder decision.

Ordinary ground-access storage should remain usable without ladders. Intentionally ladder-served installations may exceed that limit only if the bounded proof is later accepted.
