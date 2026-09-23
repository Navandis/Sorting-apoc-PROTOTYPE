# Receiving Stage B — Real-Item Physics Pile Proof Validation

**Date:** 23 September 2026  
**Status:** IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING

## 1. Purpose

Determine whether real eligible loot visuals, represented by one automatically generated convex hull each, produce frozen irregular piles good enough to justify continuing the irregular-pile Receiving approach.

This proof does not promote production Receiving pile mechanics.

---

## 2. Proof configuration

```text
Branch:
Commit:
Proof scene:
Proof script:
Focused test:

Containment depth X: ~3.60 m
Containment width Z: ~4.80 m
Review height guide: ~1.50 m

Working live geometry baseline: Case B
B recess: 0.45 m
B live deck top Y: 0.82 m

Proof mass rule:
Stable interval:
Settle timeout:
```

---

## 3. Collision representation

For each temporary physics item:

```text
authoritative ItemDefinition.visual_scene
→ recursively collect actual MeshInstance3D surface vertices
→ transform points into rigid-body local space
→ combine all points
→ exactly one ConvexPolygonShape3D
```

Confirm:

```text
WorldItem pickup AABB used for settling: NO
Per-submesh hulls: NO
Convex decomposition: NO
Concave/trimesh dynamic collision: NO
Hand-authored pile collision: NO
Per-item physics tuning: NO
```

Any item that cannot produce valid mesh-derived hull points must be reported explicitly.

---

## 4. Fixed manifests

These exact manifests must be frozen before reviewing physics results.

Each manifest contains exactly 12 currently eligible loot IDs.

### A — Mixed General

```text
A1
seed:
items:

A2
seed:
items:

A3
seed:
items:
```

### B — Bulky-Dominant

Target approximately 9/12 bulky/large items.

```text
B1
seed:
items:

B2
seed:
items:

B3
seed:
items:
```

### C — Long / Irregular

```text
C1
seed:
items:

C2
seed:
items:

C3
seed:
items:
```

### D — Small / Medium Dense

```text
D1
seed:
items:

D2
seed:
items:

D3
seed:
items:
```

Manifest changes after first physics review:

```text
None expected.

If any:
Manifest:
Reason limited to invalid/blocked/missing asset:
Replacement:
```

---

## 5. Automated verification

Record exact commands/results.

### Focused structural test

```powershell
& $godot --headless --path . --script res://tools/asset_pipeline/tests/receiving_physics_pile_proof_tests.gd
```

Result:

```text
_fill_
```

### Editor/project scan if run

```powershell
& $godot --headless --editor --path . --quit
```

Result:

```text
_fill_
```

Additional proof-only runner command:

```text
_fill_
```

Known unchanged diagnostics:

```text
_fill_
```

---

## 6. Twelve-run metrics

| Batch | Instance | Seed | Settled? | Settle time | Max height | Escaped/OOB | Technical notes |
| --- | ---: | ---: | --- | ---: | ---: | ---: | --- |
| A | 1 | | | | | | |
| A | 2 | | | | | | |
| A | 3 | | | | | | |
| B | 1 | | | | | | |
| B | 2 | | | | | | |
| B | 3 | | | | | | |
| C | 1 | | | | | | |
| C | 2 | | | | | | |
| C | 3 | | | | | | |
| D | 1 | | | | | | |
| D | 2 | | | | | | |
| D | 3 | | | | | | |

---

## 7. Human launch / selection

Record the actual review command syntax.

Expected shape:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'

& $godot --path . <proof-scene> -- --pile-proof-batch=A --pile-proof-instance=1
```

Repeat for:

```text
A1 A2 A3
B1 B2 B3
C1 C2 C3
D1 D2 D3
```

---

## 8. Human review matrix

Review **all 12 frozen piles**.

Do not judge only screenshots of the freshly settled physics state; perform the frozen TAKE smoke too.

### A1

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### A2

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### A3

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### B1

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### B2

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### B3

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### C1

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### C2

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### C3

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### D1

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### D2

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

### D3

```text
Initial pile credibility:
Gap/void severity:
Precarious balancing:
Buried/unreachable items:
Convex-hull artifacts:

Top TAKE:
Middle TAKE:
Low/supporting TAKE:
Floating-remnant severity: none / minor / obvious / severe
Notes:
```

---

## 9. Batch-family summary

### Mixed General

```text
Overall pile quality:
Settling reliability:
Frozen-removal concerns:
```

### Bulky-Dominant

```text
Overall pile quality:
Settling reliability:
Frozen-removal concerns:
```

### Long / Irregular

```text
Overall pile quality:
Settling reliability:
Frozen-removal concerns:
```

### Small / Medium Dense

```text
Overall pile quality:
Settling reliability:
Frozen-removal concerns:
```

---

## 10. Human decision

Choose one:

```text
CONTINUE IRREGULAR PILE
```

or:

```text
DESIGN SMALL PILE-LOCAL SUPPORT/EXPOSURE RULE
```

or:

```text
PIVOT TO ORDERED TAKE-ONLY DECK
```

Decision notes:

```text

```

---

## 11. Interpretation boundary

This proof does **not** promote:

- Case B as final Receiving recess;
- production pile preparation;
- production presenter architecture;
- support/exposure rules;
- physics after presentation;
- save/load;
- lift doors/travel/audio.

If the decision is to continue irregular piles, the next design step should use the evidence from this proof rather than assuming support handling is necessary in advance.

If the decision is to pivot, preserve the already approved deterministic TAKE-only deck fallback rather than attempting to rescue the irregular pile through escalating complexity.
