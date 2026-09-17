# Logistics-Wing Greybox Round-03 Design

**Date:** 17 September 2026

**Branch:** `codex/logistics-wing-greybox`

**Verified starting revision:** `66b7c18f54c45c6b682970b1971dd2bc6e5f099a`

## Outcome and limits

This pass applies the eight bounded round-three corrections to the accepted round-two wing. The 17 September kickoff, correction brief, supersession record, exact developer feedback, red C/D overlay, and supplied review evidence govern this work. Unaffected round-two geometry stays fixed.

The Workshop abandoned-continuation stub remains absent at every active layer. Freight lining, furnishing, production art, departmental delivery interactions, physical Receiving, NPCs, item/economy work, and new dead-end infrastructure remain deferred. The project main scene, shared player/controller, freight assembly, Storage/Receiving gameplay, and rejected Receiving branch are protected.

All dimensions are metres. `+X` is east, `+Z` is south, and `Y=0` is finished floor. Ordinary clear height remains `3.40`, Receiving remains `4.20`, and wall/slab thickness remains `0.30`.

## Before/after coordinate authority

Coordinates below distinguish nominal floor or wall-centreline construction from actual wall-face clearance. Values not listed are retained from round two.

| Item | Round two | Round three |
| --- | --- | --- |
| Receiving height closure | centre `X=-28.65`, depth `-28.80..-28.50` | centre `X=-28.50`, depth `-28.65..-28.35`, aligned to both doorway wall planes |
| Backlog lower ceiling west termination | `X=-28.50` | `X=-28.35`, touching the closure's east face without positive overlap; floor still starts at `-28.50` |
| Backlog / Sorting allocation | partition `X=-21`; spans `7.5 / 16.0` | partition `X=-15`; spans `13.5 / 10.0` |
| Backlog / Sorting opening | `Z -2.40..1.44`, `3.84` nominal clear | `Z -3.40..1.44`, `4.84` nominal clear; south edge fixed |
| Sorting-to-freight evidence | one ray toward `Z=2.2` | three-ray bundle across a `0.25 m` real upper-rail target band at `Z=1.95, 2.075, 2.2`; unchanged work eye `(-10, 1.7162851, -4.4)` |
| Salvager pocket west wall | nominal `Z 23.5..29.5`, actual start `23.35` | nominal `Z 24.0..28.5`, actual start `23.85`, flush with the cross-wall face |
| Salvager rear clearance | machine rear `28.0`; wall inside face `29.35`; `1.35` clear | machine fixed; wall centre `28.5`, inside face `28.35`; `0.35` clear |
| C/D southern separation | solid cube `X 2..6`, `Z 11.5..15`; missing `X=6`, `Z 15..17.5` | folded wall chain `(-2,15)->(2,15)->(2,11.5)->(6,11.5)->(6,17.5)`; exterior region remains non-playable |
| Shared A/B connector | `floor_shared`; generic Shared A/B diagnostic identity | unchanged footprint `X 4.5..9`, `Z -13..-1.5`, reclassified as Main Storage circulation while retaining the useful node name |
| Medical-only spur | `Z -16..-13`, `3.0` exclusive length | `Z -18..-13`, `5.0` exclusive length (`+66.7%`) |
| Medical anteroom | `X 3..10.8`, `Z -23..-16` | same `7.8 x 7.0` room translated north to `Z -25..-18` |
| Kitchen initial run | B-east plane `16.5` to leg centre `22.6`: `6.1` nominal | plane `16.5` to leg centre `25.0`: `8.5` nominal (`+39.3%`); wall-face-to-centre `8.35` |
| Kitchen north leg / room | leg `X 21.2..24.0`; room `X 19.0..29.5` | translated `+2.4 X`: leg `23.6..26.4`; room `21.4..31.9`; sizes unchanged |
| Incinerator mouth | centre `X=31.5`, `5.5` from turn's west plane `X=39` | centre `X=36.5`, `2.5` from the turn; whole spur translated `+5.0 X` |
| Incinerator pocket | `X 28..35`, `Z 10..17` | `X 33..40`, `Z 10..17`; `7 x 7` size and machine envelope retained |

The authored floor-plan envelope becomes `X -44..66` by `Z -25..28.5`, or `110 x 53.5 m`. Validation will also report the exact saved primitive/collider AABB, which includes wall/slab thickness and must not be conflated with these centreline floor bounds.

## Assembly decisions

### R03-01 — one Receiving/Backlog surround

The closure occupies the same `X` depth as the two doorway wall strips: `-28.65..-28.35`. Its opening span stays `Z -1.92..1.92` and vertical span stays `Y 3.40..4.20`. The Backlog floor retains its accepted west boundary at `-28.5`; only the lower ceiling begins at the closure's east face, `-28.35`. This removes both the visible 0.15 m projection and renewed lower-ceiling overlap without moving the doorway.

### R03-02 — restored allocation and a real ray bundle

Backlog ends and Sorting begins at `X=-15`. Backlog owns partition returns from `Z -3.8..-3.4` and `1.44..3.8`; Sorting owns the outer shoulders from `-5..-3.8` and `3.8..5`. This avoids collinear double ownership. The `4.84 m` asymmetric opening preserves meaningful separation. A three-ray bundle across a disclosed `0.25 m` band of the existing upper rail (`Z=1.95..2.2`) must cross both structural thresholds, while the rendered desk view remains the proof that the freight fragment is actually identifiable. The table, work eye, Receiving aperture, southern jamb, freight cage, and both required long-vista blockers do not move.

### R03-03 — Salvager elbow and back enclosure

The pocket-west side wall begins nominally at `Z=24.0`; its joined start reaches only to the cross-passage wall's south face at `23.85`. Pocket floor, roof, both side walls, and rear wall end at `Z=28.5`. The unchanged machine rear at `28.0` therefore receives `0.35 m` to the rear wall's inside face. That installation gap is intentionally smaller than the unchanged controller diameter and is verified from saved collider faces plus the roof-off rear view, never by spawning the controller inside it. The approach, machine, front operating position, Workshop room, and approach reveal stay fixed.

### R03-04 — C/D folded perimeter

The red overlay is implemented as a thin, continuous structural chain, not a solid block: C's south wall reaches `(2,15)`, turns north to `(2,11.5)`, caps east to `(6,11.5)`, then the D-side return continues south to `(6,17.5)`. The region east/south of C's inset remains exterior because it has no floor or roof. The sole C/D aperture stays on `X=6`, `Z 9.0..11.5`; D's existing outer extent and south bump do not move. Endpoint-specific joins make the chain solid at its bends and at D's south wall without adding a facade, pocket, or second divider.

### R03-05 — Storage connector, then Medical

The `SharedABJunction` node name remains useful for routes, but its floor treatment, label, ownership metadata, and measurement grouping identify the entire `4.5 x 11.5 m` footprint as Main Storage circulation. Medical-only floor begins north of `Z=-13` and runs five metres to the translated room edge at `Z=-18`. The anteroom, opaque inner boundary, provisional interface, labels, anchors, captures, light coverage, and traversal waypoints translate two metres north. Room size and Medical's no-storage/no-gallery-mediated-access rules remain unchanged.

### R03-06 — longer first Kitchen straight

The B-east doorway remains at `X=16.5`. The north-leg centre moves to `X=25.0`, producing an `8.5 m` nominal initial run and `8.35 m` from the B wall's east face. The `2.8 m` corridor width is retained, so its sides become `X=23.6` and `26.4`. The north leg, `10.5 x 7 m` service room, opaque boundary, provisional interface, anchors, labels, captures, light coverage, and traversal waypoints translate `+2.4 X`. There is still exactly one east-then-north route from B.

### R03-07 — eastern Incinerator spur

The entire Incinerator assembly translates `+5.0 X`: the mouth is `34.5..38.5`, centre `36.5`; the room is `33..40`; the machine/anchors/captures/routes translate with it. The wide-run south wall closes the vacated `29.5..33.5` mouth as ordinary wall and exposes only the new mouth. The dogleg, narrow run, Ops landing, settlement door, machine size, room size, orientation, and front access remain fixed. A controller boundary probe at the former mouth must stall on the restored wall.

### R03-08 — endpoint-scale junction completion

Every perpendicular structural-wall pair whose nominal centreline endpoints meet is audited in the saved scene. A valid solid junction covers all four quarter-thickness samples around the intersection; an intentional jamb has no perpendicular mate and remains literal. Actual butt/through joins use endpoint-specific half-thickness extension on one participating run. Existing joined ends are retained when correct. This resolves the 39 round-two candidates without adding 39 pillars or globally extending both ends. Tests continue to reject collinear duplicate ownership, slab overlaps, parallel skins, and blocked intended openings.

The final evidence includes a machine-readable inventory of every investigated junction with its final disposition (`corrected`, `already_covered`, `intentional_open`, or `not_applicable`) and geometric sample result.

## Review views and traversal dependencies

Normal evidence remains at eye height `1.7162851 m` and FOV `75°`. The full-wing overview and two explicitly labelled local audit views hide ceilings; the local audits use FOV `50°` and omit global orientation aids. Affected positions are revised as follows:

| View | Position | Target |
| --- | --- | --- |
| Backlog/Sorting approach | `(-25, 1.7162851, 0.4)` | `(-16, 1.4, -0.6)` |
| Backlog/Sorting threshold | `(-17, 1.7162851, -0.4)` | `(-12, 1.4, -1.0)` |
| Backlog/Sorting departure | `(-13, 1.7162851, -1.0)` | `(-18, 1.4, 0.2)` |
| C/D folded perimeter from D | `(9, 1.7162851, 14.5)` | `(5.5, 1.4, 10.4)` |
| C/D folded perimeter from C | `(0, 1.7162851, 13.7)` | `(3.4, 1.4, 10.8)` |
| C/D local roof-off audit | `(4, 15, 19)` | `(4, 0, 14)` |
| Medical spur | `(6.75, 1.7162851, -11.0)` | `(6.9, 1.4, -19.0)` |
| Medical anteroom | `(6.9, 1.7162851, -20.0)` | `(6.9, 1.4, -24.7)` |
| Kitchen bend | `(25.0, 1.7162851, -7.8)` | `(25.0, 1.4, -13.5)` |
| Kitchen room | `(25.0, 1.7162851, -19.5)` | `(26.65, 1.4, -24.7)` |
| Salvager rear roof-off audit | `(10.0, 10.0, 31.0)` | `(5.0, 0.8, 26.5)` |
| Incinerator | `(36.5, 1.7162851, 7.5)` | `(36.5, 1.4, 14.75)` |

Existing unchanged views remain available. Captures may add views and contact sheets; historical view counts are not invariants. Traversal keeps all retained destinations, updates only moved waypoints/anchors, and adds the old-Incinerator-mouth closure probe.

## Verification and evidence boundary

The builder remains the single geometry authority and `wing_geometry.tscn` remains generated output. The three focused contracts must fail on the verified round-two scene before production edits, then pass against the regenerated round-three scene. Evidence writes only to `reports/logistics_wing/greybox/revision_03/`, with no overwrite of earlier reports.

Automated and rendered evidence can establish structural integrity, correction-register fidelity, route reachability, manifest/source identity, and junction coverage. Human spatial approval, production-workflow approval, art, furnishing, departmental gameplay, physical Receiving, and balance remain separate statuses. The branch stops for the developer's walkthrough; it is not merged or pushed.
