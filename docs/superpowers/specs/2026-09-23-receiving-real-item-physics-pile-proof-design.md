# Sorting Apocalypse — Receiving Stage B Real-Item Physics Pile Proof

**Date:** 23 September 2026  
**Status:** APPROVED — bounded proof  
**Local prerequisite:** continue from the completed A/B/C comparison branch unless local preflight shows a safer state  
**Working live geometry baseline:** Case B only — `0.45 m` recess / deck top `Y = 0.82 m`

## 1. Purpose

Test whether **actual eligible loot visuals, temporarily simulated with physics, produce convincingly irregular settled piles often enough to justify continuing the irregular-pile Receiving approach**.

The proof asks:

> Do real catalogue item shapes, each represented by one automatically generated convex hull, settle into frozen piles that are materially more believable and workable than the manually placed primitive proxy pile?

The proof is deliberately allowed to fail. The logistics loop is more important than preserving the irregular-pile presentation at disproportionate engineering cost.

Approved fallback if this approach does not justify itself:

```text
ReceivingBatch
→ deterministic footprint packing / supported stacking
→ TAKE-only Receiving deck
```

Do not implement the fallback during this proof.

---

## 2. Locked scope

Use:

- actual current eligible `ItemDefinition.visual_scene` assets;
- Case B recess only;
- four representative batch types;
- three fixed instances/seeds per batch type;
- twelve items per batch;
- twelve total pile runs;
- one automatically generated convex hull per item;
- ordinary temporary rigid-body physics;
- settle → freeze;
- normal `WorldItem` / LMB TAKE smoke on frozen results.

Do **not** add:

- intentional adversarial batch construction;
- pile-beautification tuning;
- per-item physics exceptions;
- hand-authored pile collision;
- convex decomposition;
- support graphs;
- live re-settling after TAKE;
- pile repair;
- production save/load;
- production Receiving presenter integration;
- lift doors/travel/audio.

---

## 3. Catalogue authority

Use:

```text
res://data/items/item_catalog.tres
```

The current catalogue contains 42 definitions. The current promoted storage baseline has 40 eligible reviewed loot types; Gloves and Pants remain blocked.

Use the current eligibility state as authority.

Do not:

- modify `ItemDefinition` resources;
- alter gameplay loot probabilities;
- create pile-specific definitions;
- exclude legitimate large items because they settle poorly.

The proof batch manifests are review fixtures only.

---

## 4. Fixed batch families

Each batch contains **12 items**.

Create and save the exact twelve manifests **before any physics result is reviewed**. After the first physics run, manifests are frozen unless an entry is invalid/blocked/missing.

Duplicates are allowed only if selected naturally by the manifest-generation method; they are not required.

### A — Mixed General

A representative cross-category and cross-size return.

Intent: ordinary heterogeneous scavenger cargo; neither intentionally dense nor intentionally awkward.

### B — Bulky-Dominant

A legitimate large-item-heavy return.

Target approximately:

```text
9 / 12 large or bulky
3 / 12 small or medium
```

This is not an adversarial stress case. It represents the explicitly accepted possibility that a valid expedition returns roughly 70–80% large items.

### C — Long / Irregular

A plausible return with meaningful representation of elongated or irregular current assets such as weapons, tools, racket, firewood, and similar shapes, mixed with ordinary items.

Do not make all twelve objects maximally awkward.

### D — Small / Medium Dense

A plausible batch dominated by packaged food, cans/cartons, medicines, electronics/media and similar smaller or medium objects, with a few larger pieces.

This is the likely favorable presentation case.

### Manifest-selection guardrail

Specific items may be selected using current item metadata and/or actual visual bounds, but the twelve exact manifests must be committed to the proof fixture before physics review.

Do not change manifests because a resulting pile looks good or bad.

---

## 5. Physics collision representation

Do **not** use the current `WorldItem` interaction collider for settling.

`WorldItem` currently generates a padded AABB `BoxShape3D` for pickup targeting. That is intentionally coarse and is not suitable evidence for this proof.

Each temporary physics item should instead be:

```text
RigidBody3D
├── VisualRoot          actual ItemDefinition.visual_scene
└── CollisionShape3D    one ConvexPolygonShape3D
```

### One-hull generation

For each actual visual:

1. instantiate `ItemDefinition.visual_scene`;
2. recursively scan all `MeshInstance3D` descendants;
3. inspect every mesh surface vertex array;
4. transform every vertex through the accumulated node transforms into the temporary rigid body's local frame;
5. combine all points into one `PackedVector3Array`;
6. assign those points to a single `ConvexPolygonShape3D`;
7. attach exactly one `CollisionShape3D`.

The whole item receives one gross convex hull.

Do not create one hull per mesh/submesh.

Do not use a concave/trimesh shape for the dynamic rigid body.

Do not use convex decomposition in this proof.

### Accepted approximation

The single hull will fill concavities, for example:

- gaps below/around a pig's body;
- the inside of a hard hat;
- the racket hoop;
- weapon voids;
- gaps between pieces in an authored firewood pile.

That limitation is intentional. The proof is testing whether one cheap gross-shape approximation is good enough.

If a visual contains no usable mesh vertices, report it as invalid rather than silently substituting a box.

---

## 6. Isolated preparation/review scene

Create a dedicated proof scene, suggested:

```text
res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.tscn
res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.gd
```

Do not perform temporary settling in normal `wing_gameplay.tscn`.

Use a simple static containment volume matching the current Case-B comparison envelope:

```text
usable depth X ≈ 3.60 m
usable width Z ≈ 4.80 m
review height guide ≈ 1.50 m
local prep floor Y = 0
```

The corresponding live presentation baseline remains:

```text
Case B recess = 0.45 m
live deck top Y = 0.82 m
```

Containment walls may be invisible or review-toggleable.

The hidden environment only needs to reproduce the usable pile volume. It does not need lift art.

Include the normal gameplay player/HUD for frozen TAKE review if that is the simplest reuse path.

---

## 7. Deterministic drop setup

Each of the 12 runs receives a fixed seed.

Within a run:

- instantiate the exact manifest;
- spawn items above the containment floor;
- choose deterministic X/Z spawn points;
- choose deterministic three-axis rotations;
- avoid initial interpenetration;
- allow gravity/collision to determine the final pile.

A small fixed spawn stagger is acceptable if simultaneous creation causes artificial initial overlaps.

Do not hand-place final transforms.

Do not change a seed because a result is unattractive.

The three instances of a batch type should differ enough in initial conditions to expose ordinary variation.

---

## 8. Physics properties

Keep the simulation intentionally plain:

- normal gravity;
- one convex hull;
- ordinary/default contact behavior;
- no cosmetic impulses;
- no item-specific friction/bounce tuning;
- no hand-authored mass metadata.

The current catalogue has no promoted physical-mass authority.

Use one common proof mass, or the engine default, rather than interpreting gameplay `bulk` as kilograms.

If a concrete engine issue invalidates the proof, use only the smallest proof-wide correction and report it.

---

## 9. Settling rule

A run succeeds when all bodies are sleeping, or remain under small linear/angular velocity thresholds, for a short stable interval.

Suggested initial values:

```text
stable interval: 0.75–1.0 s
timeout:         ~15 s
```

If the timeout is reached:

```text
status = NOT SETTLED
```

Do not hide or auto-retry failures into a successful-looking result.

Record settle duration/status for every run.

---

## 10. Freeze transition

After a valid settle:

1. capture each item's settled transform;
2. zero linear and angular velocities;
3. freeze the body;
4. disable its temporary physics collision layer/mask;
5. preserve the exact settled visual transform.

The reviewed pile is now frozen.

Nothing resettles after item removal.

---

## 11. Normal TAKE smoke

After freeze, attach the existing ordinary `WorldItem` interaction path to each frozen item using its authoritative definition/instance.

Use normal player LMB TAKE.

Do not create a pile-specific delete interaction.

The human reviewer does **not** need to completely drain all twelve items in every run.

For each pile, attempt where possible:

- one exposed top item;
- one middle item;
- one visible lower/supporting large item.

The last action is specifically meant to reveal unsupported/floating remnants.

Do not solve floating behavior during this proof.

---

## 12. Technical evidence

For every run record:

```text
batch type
instance
seed
12 item IDs
settled / timeout
settle duration
maximum final pile height
escaped/out-of-bounds bodies, if any
notable physics/visual issue
```

Human review separately records:

```text
initial pile credibility
gap/void severity
precarious balancing
buried/unreachable items
gross convex-hull artifacts
floating-remnant severity after TAKE
```

A few representative screenshots are enough. Do not create an evidence bureaucracy.

---

## 13. Decision criteria

### CONTINUE IRREGULAR PILE

Appropriate if:

- real shape settling is materially more convincing than the proxy pile;
- ordinary runs settle reliably;
- bulky-dominant returns remain visually credible;
- pathological gaps/balancing are not dominant;
- frozen removal problems appear limited enough that a small pile-local support/exposure rule might solve them.

### DESIGN SMALL PILE-LOCAL SUPPORT / EXPOSURE RULE

Appropriate if:

- initial settled piles look convincingly good;
- but lower/supporting item removal frequently leaves obvious floating remnants;
- and the issue looks plausibly solvable without a broad physics/support framework.

Do not design that rule inside this proof.

### PIVOT TO ORDERED TAKE-ONLY DECK

Appropriate if:

- bulky-heavy piles remain fundamentally unconvincing;
- settling is routinely unstable/pathological;
- common items wedge/bury/become unreachable;
- one-hull approximations are inadequate across ordinary loot;
- frozen draining creates pervasive structural nonsense;
- likely fixes imply substantial item-specific collision/support machinery.

---

## 14. A/B/C status

Do not promote a final recess from the previous geometry comparison yet.

Use **B only** because A/B/C differences appeared secondary to pile composition.

Do not multiply this proof across A and C.

If real settled piles make floor depth important again, revisit/interpolate afterward.

---

## 15. Fantasy/audio note

If irregular piles eventually survive the engineering proof, fake lift travel can lean on heavy vibration, banging and jerking machinery sounds to justify cargo disorder during transit.

This remains deferred presentation/audio work.

---

## 16. Non-goals

Do not:

- alter gameplay loot selection;
- change ItemDefinitions;
- add mass metadata;
- use convex decomposition;
- hand-author per-item pile collision;
- implement support graphs;
- re-run physics after TAKE;
- implement pile repair;
- implement production batch integration;
- implement persistence;
- implement lift travel/doors/audio;
- merge this proof into normal gameplay.

---

## 17. Stop condition

Stop when:

- all 12 manifests are frozen in the proof;
- all 12 deterministic runs can execute;
- actual visuals use exactly one generated convex hull each;
- settling/freeze works;
- normal TAKE can remove frozen proof items;
- technical evidence distinguishes initial pile quality from frozen-removal behavior;
- human review instructions are ready.

Then stop for the human decision:

```text
CONTINUE IRREGULAR PILE
/ DESIGN SMALL PILE-LOCAL SUPPORT RULE
/ PIVOT TO ORDERED TAKE-ONLY DECK
```
