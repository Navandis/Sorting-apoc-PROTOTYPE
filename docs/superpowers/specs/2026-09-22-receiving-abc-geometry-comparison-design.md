# Sorting Apocalypse — Receiving Stage B A/B/C Geometry Comparison

**Date:** 22 September 2026  
**Status:** Approved bounded spatial experiment  
**Expected `main`:** `92bf3472a51520ef440ea465962a30429437b475`  
**Primary scene:** `res://gameplay/logistics_wing/wing_gameplay.tscn`

## Purpose

Before implementing irregular Receiving piles, establish the live lift/pile floor height relative to the front freight barrier.

The question is narrow:

> How far below the barrier should the lift/pile floor sit so a frozen batch remains readable and reachable, while the lowest/supporting layer is not trivially exposed from ordinary standing positions?

No real Receiving batch presentation, settling, pickup support rules, doors, lift travel, or final art are part of this experiment.

The ordered TAKE-only Receiving-deck fallback remains approved if irregular piles later become disproportionately expensive.

## Existing geometry reference

Use the accepted greybox without modifying `wing_geometry.tscn`.

Current tracked geometry establishes:

- finished floor: `Y = 0`;
- freight enclosure floor top: `Y = 0`;
- freight enclosure: about `5.0 m` deep × `7.0 m` wide before wall thickness;
- rear wall centre: `X = -44.0`;
- front barrier centreline: `X = -39.0`;
- freight side walls: `Z = ±3.5`;
- upper continuous barrier rail centre: `Y = 1.15 m`;
- upper rail height: `0.24 m`.

Use the top of the continuous upper rail as the comparison reference:

```text
barrier_reference_y = 1.27 m
```

Do not use intermittent post tops.

## A/B/C cases

All cases use the same horizontal deck/envelope and the same visual proxy load. Only vertical floor position changes.

| Case | Recess below barrier | Deck/pile floor Y |
| --- | ---: | ---: |
| A | 0.10 m | 1.17 m |
| B | 0.45 m | 0.82 m |
| C | 0.70 m | 0.57 m |

A tests near-level presentation and the risk of exposing the base too early.  
B tests the likely middle compromise.  
C tests stronger lower-layer occlusion and the risk of feeling too pit-like.

These are review values, not production constants. Human review may choose an interpolated value.

## Comparison component

Create:

```text
res://gameplay/logistics_wing/receiving/receiving_geometry_comparison.tscn
res://gameplay/logistics_wing/receiving/receiving_geometry_comparison.gd
```

Instance it directly in `wing_gameplay.tscn`.

Suggested structure:

```text
ReceivingGeometryComparison       Node3D / @tool
├── LiftDeck
├── BarrierOcclusionMockup
├── PileEnvelopePreview
├── ProxyLoad
└── Guides
```

Root should align to the barrier centreline near world `(-39, 0, 0)`.

For this one installation:

- +X = apron/player side;
- -X = freight/rear;
- +Y = up;
- ±Z = lateral.

## Lift deck

Overlay a simple neutral review deck inside the accepted freight enclosure.

Approximate internal faces:

```text
front inner face: ~X -39.16
rear inner face:  ~X -43.85
side inner faces: ~Z ±3.35

raw internal span:
depth ~4.69 m
width ~6.70 m
```

Leave a small visual gap from shell geometry. The top of the deck must equal the selected case floor Y.

Do not alter/excavate the existing Y=0 floor. The review geometry represents a lift platform stopped above it.

## Opaque barrier mockup

The existing barrier is open-railed, but the intended finished apron may visually occlude much more of the lift.

Add a **visual-only** neutral panel immediately behind the barrier, approximately:

```text
width across Z = 4.8 m
bottom Y = 0
top Y = 1.27 m
```

No collision. Existing barrier collision remains authoritative.

This is sightline simulation only, not final art.

## Proxy load

Use one identical noninteractive proxy load for all cases.

Use primitive meshes representing a useful size range:

- small pieces;
- medium boxes;
- tall/canister-like pieces;
- one long/flat piece;
- base/front pieces;
- middle pieces;
- exposed upper pieces.

No `WorldItem`, no physics, no Receiving identity.

The exact same local arrangement moves vertically with the deck in A/B/C. It may look roughly irregular but does not need physical correctness.

## Pile envelope preview

Add a transparent review volume/guides starting at the selected floor.

Keep horizontal footprint identical across cases.

Add height references around:

```text
floor +0.5 m
floor +1.0 m
floor +1.5 m
```

Do not select final pile width/depth/height in this task.

## Case selection

Expose an editor enum:

```text
A
B
C
```

As an `@tool` component, changing the case should immediately update deck, proxy load, envelope base and guides.

Also support:

```text
--receiving-geometry-case=A
--receiving-geometry-case=B
--receiving-geometry-case=C
```

No permanent hotkey is needed.

## Human review

Run actual `wing_gameplay.tscn` for A/B/C.

For each case inspect:

1. several metres back;
2. normal approach distance;
3. directly against the barrier;
4. left/right of centre;
5. top/middle/base of the proxy load.

Judge:

- arrival readability;
- how much lowest/front layer is exposed from normal approach;
- whether the player must move close to inspect the base;
- upper/middle readability;
- downward viewing comfort;
- late-batch bottom access plausibility;
- whether the recess still reads as a lift platform rather than a pit;
- apparent vertical batch capacity.

Promotion from this experiment establishes only the selected floor/recess baseline for the next Stage-B pile proof.

## Later implementation boundary

Preferred path:

```text
ReceivingBatch
→ isolated hidden settling/preparation
→ frozen local transforms
→ live irregular pile
```

Approved fallback if that becomes disproportionate:

```text
ReceivingBatch
→ deterministic footprint packing / supported stacking
→ TAKE-only Receiving deck
```

Do not implement both in parallel.

## Fantasy/audio note

If irregular piles are eventually promoted, fake lift travel can use heavy vibration, banging and jerks to sell unstable machinery that disrupts cargo in transit.

This is deferred audio/presentation work and has no weight in this geometry decision.

## Non-goals

Do not implement real Receiving loot, settling, support graphs, pickup restrictions, lift doors, lift travel, final art, Stage A changes, shell edits, or the deterministic fallback.

## Stop condition

Stop when A/B/C comparison geometry exists in `wing_gameplay`, all three floor cases work from the shared 1.27 m barrier reference, the opaque visual mockup and proxy load are present, editor/runtime case switching works, existing gameplay is unaffected, and a human-review record is ready.
