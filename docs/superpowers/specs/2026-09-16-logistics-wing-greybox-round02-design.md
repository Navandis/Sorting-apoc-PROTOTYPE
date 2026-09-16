# Logistics-Wing Greybox Round-02 Design

**Date:** 16 September 2026

**Branch:** `codex/logistics-wing-greybox`

**Verified starting revision:** `add47716a125f3fc035e10d50fdb11a15836659b`

## Outcome and authority

This pass corrects the bounded round-two structural feedback for the complete logistics wing. The round-two kickoff, brief, supersession record, evidence index, human screenshots, walkthrough, and both topology schematics govern this work. The round-two Workshop decision explicitly supersedes the retained-continuation language in GDD v0.7, Visual Direction v0.4, the round-one plan, and the round-one validation.

The abandoned Workshop continuation is removed completely. No floor, ceiling, wall pocket, blocker, debris, route, topology edge, anchor, probe, capture, label, or reserved void remains. Workshop ends at a continuous full-height south perimeter. No replacement stub is reserved elsewhere.

Freight lining, furnishing, production art, physical Receiving, facility interactions, delivery choreography, NPCs, and balance changes remain deferred. The existing freight cage geometry stays unchanged. This is a neutral greybox correction and evidence pass; human spatial promotion remains pending.

## Root-cause findings

The defects share four causes in the round-one coordinate authority:

1. Adjacent slabs and wall strips were authored as independent closed boxes with overlapping or coplanar faces. The Receiving height-transition box overlaps the Backlog ceiling by 0.15 m and shares its bottom plane, producing deterministic z-fighting.
2. Several circulation boundaries were expressed by parallel owners. A-east/B-west, the shared junction, and the Medical corridor have separate wall skins instead of one boundary owner, while perpendicular helpers terminate at centerlines and expose half-thickness rebates at selected corners.
3. Round-one revisions accumulated local offsets without rebalancing the whole path. The Kitchen route became a four-segment zigzag, the Storage spine narrowed around D/E, and the Deeper approach retained a 9 m versus 22 m useful-run imbalance.
4. The retained Workshop stub remained encoded in every layer (floor/ceiling, walls, boundary, debris, topology, anchor, traversal, capture, and tests), so removing only its visible blocker would leave false playable and evidentiary state.

The human images and saved scene reproduce all four causes. The three pre-change wing contracts pass at the verified start, proving the round-two expectations are new tests rather than baseline instability.

## Coordinate convention

All values are metres. `+X` is east, `+Z` is south, and `Y=0` is finished floor. Ordinary clear height remains `3.40`; Receiving remains `4.20`; wall and slab thickness remain `0.30`. Coordinate intervals describe walkable floor rectangles. Structural wall centerlines lie on their named interval boundaries unless a table says otherwise.

## Before/after dependency map

| Relationship | Round one | Round two |
| --- | --- | --- |
| Receiving -> Backlog | 4.80 m opening at `X=-27` | 3.84 m opening at `X=-28.5`; freight assembly unchanged |
| Backlog -> Sorting | 4.80 m opening at `X=-15`, symmetric | 3.84 m opening at `X=-21`; north edge remains `Z=-2.4`, south edge moves to `Z=1.44` |
| Sorting desk -> freight aperture | aperture not visible from the real work anchor | southern aperture portion visible through both narrowed thresholds from `(-10,-4.4)` |
| Shared A/B junction | short southern junction, duplicate side skins | junction extends north; A-east and B-west are sole side owners; Medical begins beyond it |
| B -> Kitchen | east/north/east/north zigzag | east from B, then north to the service room |
| C <-> D | north and south divider strips | north divider plus one opening; southern separation is the C irregular solid mass |
| Storage -> Deeper | D/E pinch the spine | D/E move south and preserve broad spine stations |
| Sorting -> Workshop | 8 m approach | 10 m approach; downstream Workshop/Salvager translated coherently |
| Workshop -> abandoned continuation | playable lip plus fixed blocker | no dependency or reserved space; solid south perimeter |
| Workshop -> Salvager | reveal begins from inside the spur | machine is visible from the Workshop-room approach before entering the spur |
| Deeper pre/post bend | about 9 m / 22 m | 16 m / 16 m authored runs (useful measured runs expected within 10%) |

## Walkable floor outline

| District / zone | Round-two walkable rectangle(s) |
| --- | --- |
| Freight enclosure | unchanged: `X -44..-39`, `Z -3.5..3.5` |
| Receiving Apron | `X -39..-28.5`, `Z -5..5` |
| Dispatch annex | `X -38..-28.5`, `Z -8.5..-5`; doorless framed opening `X -34.2..-31.8` in its south wall |
| Backlog | `X -28.5..-21`, `Z -3.8..3.8` |
| Sorting | `X -21..-5`, `Z -5..5`, with the existing work pocket `X -14..-6`, `Z -7.2..-5` |
| Storage spine west | `X -5..4.5`, `Z -1.5..5.5` |
| Storage spine east | `X 4.5..26`, `Z -1.5..7.0` |
| Shared A/B junction | `X 4.5..9`, `Z -13..-1.5` |
| Gallery A main | `X -3..4.5`, `Z -13..-1.5` |
| Gallery A north-west extension | `X -5..1`, `Z -16..-13` |
| Gallery B | `X 9..16.5`, `Z -13..-1.5` with retained north-east bump `X 12..16.5`, `Z -14.5..-13` |
| Medical approach | `X 5.8..8.2`, `Z -16..-13` |
| Medical anteroom | `X 3..10.8`, `Z -23..-16` |
| Kitchen east leg | `X 16.5..24`, `Z -8.2..-5.4` |
| Kitchen north leg | `X 21.2..24`, `Z -18..-5.4` |
| Kitchen service room | `X 19..29.5`, `Z -25..-18` |
| Gallery C main | `X -2..6`, `Z 5.5..11.5` |
| Gallery C south-west | `X -2..2`, `Z 11.5..15` |
| Gallery D | `X 6..15.5`, `Z 7..17.5`, with `X 9.5..12.5`, `Z 17.5..19` bump |
| Gallery E main | `X 17.5..25.5`, `Z 7..15.4` |
| Gallery E projection | `X 19..25.5`, `Z 15.4..21`; `5.6/14.0 = 40%` of final north-south extent |
| Workshop approach | `X -12..-8`, `Z 5..15` |
| Workshop service room | `X -18..-6`, `Z 15..25` |
| Salvager cross-leg | `X -6..8`, `Z 20..24` |
| Salvager pocket | `X 2..8`, `Z 23.5..29.5` |
| Deeper wide run | `X 26..42`, `Z 0..4.5` |
| Deeper dogleg | `X 39..43`, `Z -7..4.5` |
| Deeper narrow run | `X 43..59`, `Z -7..-4` |
| Incinerator | unchanged footprint and buffer |
| Bunker Ops | `X 59..66`, `Z -11..-2` |

Floor rectangles meet at boundaries but do not overlap by positive area. Every floor rectangle has a matching ceiling rectangle except that the removed Workshop continuation has neither.

## Solid outline and ownership

- Dispatch is a shallow annex outside Receiving. West, north, and east walls are closed. Its south wall has two substantial returns and one 2.4 m doorless opening; the 9.5 m long side is not left open.
- The Receiving height strip is wholly on the Receiving side: `X -28.80..-28.50`, `Y 3.40..4.20`, `Z -1.92..1.92`. It touches but never overlaps the Backlog ceiling.
- The Backlog-to-Sorting north return ends at `Z=-2.4` exactly as round one. Only the south return advances, to `Z=1.44`.
- A owns the `X=4.5` wall around its north opening; B owns the `X=9` wall around its north opening. The junction does not recreate either wall. The A/B openings are `Z -9.4..-7.0`.
- Medical corridor side walls begin north of the A/B rooms at `Z=-13`; they do not run beside A/B as a second skin. The A/B walls alone enclose the shared-junction run between the rooms. The anteroom remains about `7.8 x 7.0 m`, is moved north, and has no positive floor/ceiling overlap with A or B.
- Gallery C keeps its north edge at `Z=5.5`. `GalleryCDividerSouth` is deleted. A full-height `GalleryCIrregularSouthMass` occupies `X 2..6`, `Z 11.5..15` and supplies the southern C/D separation. The only C/D aperture is `X=6`, `Z 9.0..11.5`.
- D and E begin at `Z=7.0`, leaving the east spine broad to their thresholds. E remains single-entry and has no Deeper bypass.
- Workshop has a continuous wall along `Z=25`, `X -18..-6`. The east-side Salvager opening remains the only onward Workshop service connection.
- The Salvager machine center is `Z=26.5`; its south face is `Z=28.0`, and the inside face of the rear wall is `Z=29.35`, reducing rear clearance from about 1.85 m to about 1.35 m. Pocket floor, ceiling, side walls, and back wall move with the revised machine enclosure.
- Perpendicular corners use joined wall ends: the participating wall extends by one half wall thickness at the joined end. Doorway ends remain unextended so clear-width coordinates remain literal. This is the project-wide round-two junction convention; no decorative corner pillars are added.
- The Deeper bend is redistributed eastward without creating another route. Incinerator separation remains. Ops and its personnel door move east by 1 m as a rigid terminal assembly.

## Testable invariants

The saved scene, not source text, must prove:

- revision metadata identifies round two;
- exact key boxes and openings match the tables above;
- the height-transition box has no positive-volume or coplanar-face overlap with adjacent ceilings;
- floor and ceiling rectangles do not overlap by positive area across district owners;
- required joined-corner sample points are solid while all doorway sample points are clear;
- no collinear duplicate walls or A/B/Medical parallel skins exist;
- the abandoned Workshop continuation has no scene nodes, graph edge, anchor, route, boundary record, capture, label, or local floor/ceiling area;
- the Workshop south-perimeter probe blocks the unchanged player;
- the Sorting work-eye to freight-aperture ray reaches the freight barrier and crosses both thresholds through their legal openings;
- Gallery E projection ratio is 40%, C/D has one opening, and Kitchen has only the east-then-north route;
- controller traversal reaches every retained destination, including Dispatch, and C/D alternatives use the same endpoints;
- capture coverage includes sequential ceiling-transition frames, a short Backlog/Sorting turn sequence, an honest Workshop-approach Salvager reveal, and the whole-wing overview;
- evidence writes only to `reports/logistics_wing/greybox/revision_02/` and records exact source/evidence revisions and hashes.

## Evidence and promotion boundaries

Normal first-person images retain eye height `1.7162851 m` and `75 degree` FOV. The top-down debug image alone may hide the roof. The ceiling defect receives sequential approach/threshold/departure frames so one favorable angle cannot conceal recurrence. The Backlog/Sorting threshold and Sorting desk sightline receive a short turn sequence. Workshop receives both the retained semantic room view and a new approach reveal captured west of the Salvager spur.

The final validation separates technical integrity, correction-register fidelity, human spatial promotion, workflow feasibility, production-art status, physical Receiving, furnishing, and integrated balance. Only the first two can pass in this work. No merge or push is authorized.
