# Receiving Stage B — Real-Item Physics Pile Proof Validation

**Date:** 23 September 2026
**Status:** EXPERIMENT COMPLETE / TECHNICALLY VERIFIED IN RECORDED SCOPE / HUMAN REVIEW COMPLETE / IRREGULAR FROZEN PILE REJECTED FOR PRODUCTION

```text
EXPERIMENT COMPLETE
TECHNICALLY VERIFIED IN RECORDED SCOPE
HUMAN REVIEW COMPLETE
IRREGULAR FROZEN PILE: REJECTED FOR PRODUCTION
NEXT DIRECTION: DETERMINISTIC SEEDED TAKE-ONLY DECK PRESENTER
```

## 1. Purpose and boundary

This isolated proof tests whether actual eligible loot visuals, represented by one automatically generated convex hull each, settle into frozen irregular piles that are credible enough to continue the irregular-pile Receiving approach.

It does not promote Case B as final geometry, pile preparation or presentation into production Receiving, support/exposure behavior, post-TAKE physics, persistence, lift travel, doors, or audio. No production presenter, pile system, or support system was added. The deterministic seeded TAKE-only deck presenter was not implemented here; it is the selected next design direction after human review rejected the irregular frozen-pile presentation strategy.

Human review must choose one outcome after inspecting all twelve piles:

```text
CONTINUE IRREGULAR PILE
DESIGN SMALL PILE-LOCAL SUPPORT/EXPOSURE RULE
PIVOT TO ORDERED TAKE-ONLY DECK
```

This list records the decision options presented before human review. The final decision is recorded in section 11.

### Human-review preflight history

```text
Human-review preflight: BLOCKED
```

- The original standalone scene presented the preparation floor and apron at nearly the same visible height, so it did not reproduce the live Case-B apron/barrier/deck relationship.
- Runtime LMB TAKE was not usable from the supplied review start despite component-level `WorldItem.pickup_into()` coverage. The starting camera was at least 2.8 m from the pile envelope while ordinary loose-item reach was 1.4 m, and the test bypassed the production camera-ray lookup.

Correction:

- Settling and strict OOB measurement still run against the unchanged local preparation floor at `Y = 0`.
- Only after metrics are captured and bodies are frozen does interactive presentation translate the existing containment and frozen pile roots to deck top `Y = 0.82`.
- The apron remains at top `Y = 0.00`; a translucent, non-colliding barrier reference has top `Y = 1.27`, making the `0.45 m` Case-B barrier-to-deck drop visible without blocking the pickup ray.
- The review player is placed at the apron edge and aimed at the nearest frozen pickup target. The raised deck edge physically keeps the camera outside ordinary 1.4 m loose-item reach, so this isolated scene uses the smallest verified proof-only override, `1.8 m`. Normal gameplay remains `1.4 m`.
- Focused integration coverage now queries `_get_looked_at_world_item()` through the real camera ray, invokes the normal pickup-click path, verifies exact `ItemInstance` identity, and verifies that ordinary pickup removes the frozen host.
- A rendered C3 presentation preflight confirmed the visible `0.00 / 0.82 / 1.27 / 0.45 m` relationship and an unobstructed pile view. Its fixed-FPS render outcome is presentation-only and does not replace the locked headless technical metrics.

```text
Status after automated preflight: TECHNICALLY VERIFIED / HUMAN REVIEW PENDING
```

The automated geometry, targeting, and pickup-click preflight is clear. A physical reticle/LMB interaction in the native Godot window remains part of the pending human review; it was not recorded as completed by this implementation pass.

### Player-orientation and containment correction

After the first human-review correction, the proof exposed a second setup defect: the child camera had been yawed independently from the `CharacterBody3D`, making W/S and A/D move opposite the visible camera frame. The intended freight-cage basis was also clarified after the initial `3.60 × 4.80 m` proof: preserve approximately `0.545 m` at the front, reduce the rear clearance to approximately `0.273 m`, and reduce each side clearance to approximately `0.475 m` within the accepted raw shell.

Correction:

- The functional cage is now `3.872 m` deep by `5.75 m` wide. Preparation remains centred in its local physics frame; after freeze and metric capture, containment and pile presentation shift `-0.136 m` in X so the previous front usable edge remains fixed while the added depth extends rearward.
- The presentation edges are approximately local `X -2.072 .. +1.800` and `Z -2.875 .. +2.875`. The Case-B Y relationship remains unchanged.
- The real barrier reference retains its existing `4.8 m` span. Only the functional cage containment/envelope and review apron width changed.
- Horizontal facing now belongs to the player root. The camera retains normal local yaw and receives pitch only, so W aligns with camera forward and D aligns with camera right without any production movement-code change.
- Corrected-geometry reach samples measured a near exposed hit at `0.587 m`, a middle-depth exposed hit at `2.021 m`, and a far exposed hit at `3.466 m` (`0.766 / 2.192 / 3.637 m` to target centres). The initial automated-fixture calibration selected `2.1 m` to cover the middle sample.
- Initial native testing subsequently showed that useful proof review needs approximately `3.5 m`. The isolated proof override is now `3.5 m`, which covers the measured far hit; this remains review calibration rather than production Receiving range authority. Production loose-item reach remains `1.4 m`, and human review remains pending.
- Automated integration coverage performs ordinary camera-ray/pickup-click TAKE on both the near and middle-depth frozen targets and verifies that the human-calibrated proof reach covers the measured far-depth hit.
- A rendered corrected C3 presentation confirmed the wider/deeper deck, naturally spread pile, live interaction prompt on a frozen item, and unchanged Case-B vertical overlay. Its fixed-FPS result is presentation-only and is not included in the authoritative metric table.

The available Windows control surface did not expose the native Godot window, so physical WASD/mouse/LMB input was not recorded. That representative native-window check remains the first step of human review; it is not reported as cleared by the automated evidence.

## 2. Proof configuration

```text
Branch: codex/receiving-abc-geometry
Initial implementation checkpoint: b98d069083596459de3eb3ad22db9e6ebe0a34bb
Proof-wide spawn correction checkpoint: 4024eb35abfebdc7c56e966c5813718d7d37ee03
Proof scene: res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.tscn
Proof script: res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.gd
Focused test: res://tools/asset_pipeline/tests/receiving_physics_pile_proof_tests.gd

Previous containment depth X: 3.60 m
Previous containment width Z: 4.80 m
Corrected containment depth X: 3.872 m
Corrected containment width Z: 5.75 m
Corrected presentation edges: X -2.072 .. +1.800 m / Z -2.875 .. +2.875 m
Preserved barrier-reference span Z: 4.80 m
Review height guide: 1.50 m

Working live geometry correspondence: Case B only
Case B recess: 0.45 m
Case B live deck top Y: 0.82 m

Common proof mass: 1.0 kg
Initial minimum body bottom: 1.20 m
Gap above current pile: 0.18 m
Fixed spawn stagger: 0.25 s
Post-freeze interactive presentation offset: +0.82 m
Post-freeze front-edge-preserving X offset: -0.136 m
Proof-only loose-item TAKE reach: 3.5 m
Production loose-item TAKE reach: unchanged at 1.4 m
```

The spawn method is deterministic. Each item receives seeded X/Z coordinates and a seeded three-axis rotation, then is placed just above the highest current hull with a fixed gap and stagger. Gravity and collision determine the final transform; final transforms are not hand-authored.

## 3. Collision and interaction representation

Each temporary body is built as follows:

```text
authoritative ItemDefinition.visual_scene
→ recursively collect every MeshInstance3D surface vertex
→ apply accumulated child transforms into rigid-body local space
→ combine all points into one PackedVector3Array
→ exactly one ConvexPolygonShape3D
→ exactly one CollisionShape3D
```

The proof does not use the `WorldItem` pickup AABB for settling, per-submesh hulls, convex decomposition, concave/trimesh dynamic collision, hand-authored pile collision, or per-item physics tuning. An item with no usable mesh points is reported as invalid rather than silently receiving a box.

After settling, every body has zeroed linear/angular velocity, static freeze mode, `freeze = true`, and physics collision layer/mask zero. It then receives the normal `WorldItem` component backed by an authoritative `ItemInstance`. The interactive proof uses the normal player, reticle, camera ray, pickup-click path, carried-items container, and HUD. The proof disables only the held 3D item renderer because dummy-renderer material state is not part of the pile review. Removed items do not trigger re-settling.

## 4. Locked manifests and seeds

These exact fixtures were committed in `b98d069083596459de3eb3ad22db9e6ebe0a34bb`, before the first physics result was reviewed. They were not changed after physics review began.

### A — Mixed General

```text
A1 seed 230901
loot_000001, loot_000005, loot_000011, loot_000015, loot_000019, loot_000024, loot_000028, loot_000030, loot_000032, loot_000037, loot_000038, loot_000042

A2 seed 230917
loot_000002, loot_000006, loot_000012, loot_000013, loot_000016, loot_000020, loot_000025, loot_000029, loot_000031, loot_000033, loot_000039, loot_000040

A3 seed 230933
loot_000003, loot_000004, loot_000007, loot_000010, loot_000014, loot_000017, loot_000018, loot_000021, loot_000026, loot_000027, loot_000035, loot_000041
```

### B — Bulky-Dominant

```text
B1 seed 231101
loot_000002, loot_000003, loot_000011, loot_000014, loot_000015, loot_000017, loot_000028, loot_000032, loot_000038, loot_000005, loot_000019, loot_000024

B2 seed 231117
loot_000002, loot_000012, loot_000014, loot_000016, loot_000018, loot_000028, loot_000033, loot_000040, loot_000042, loot_000001, loot_000020, loot_000026

B3 seed 231133
loot_000003, loot_000011, loot_000013, loot_000015, loot_000017, loot_000032, loot_000035, loot_000038, loot_000040, loot_000004, loot_000022, loot_000030
```

### C — Long / Irregular

```text
C1 seed 231301
loot_000013, loot_000014, loot_000037, loot_000038, loot_000040, loot_000041, loot_000042, loot_000011, loot_000005, loot_000019, loot_000024, loot_000031

C2 seed 231317
loot_000013, loot_000037, loot_000038, loot_000040, loot_000041, loot_000042, loot_000033, loot_000015, loot_000006, loot_000020, loot_000027, loot_000029

C3 seed 231333
loot_000011, loot_000013, loot_000014, loot_000037, loot_000038, loot_000040, loot_000041, loot_000042, loot_000004, loot_000012, loot_000026, loot_000030
```

### D — Small / Medium Dense

```text
D1 seed 231501
loot_000001, loot_000004, loot_000005, loot_000006, loot_000019, loot_000020, loot_000022, loot_000024, loot_000025, loot_000030, loot_000002, loot_000012

D2 seed 231517
loot_000001, loot_000005, loot_000007, loot_000008, loot_000009, loot_000019, loot_000021, loot_000023, loot_000026, loot_000027, loot_000028, loot_000033

D3 seed 231533
loot_000004, loot_000006, loot_000008, loot_000009, loot_000010, loot_000020, loot_000022, loot_000024, loot_000025, loot_000029, loot_000015, loot_000035
```

The twelve fixtures collectively exercise all forty currently eligible definitions. No entry was invalid, blocked, missing, or replaced.

## 5. Settling and metric rules

A run is settled when every body is sleeping or all bodies remain below both thresholds for the full stable interval:

```text
linear speed threshold: 0.04 m/s
angular speed threshold: 0.08 rad/s
stable interval: 0.90 s
timeout: 15.0 s, including fixed spawn-stagger time
OOB contact tolerance: 0.02 m beyond any usable X/Z edge or below the floor
```

At timeout the status is `NOT SETTLED`; the runner does not retry or conceal failure. A body is OOB if any part of its final hull AABB exceeds the usable X/Z envelope or penetrates below the floor by more than the 0.02 m contact tolerance. Metrics include batch, instance, seed, the twelve IDs, status, duration, maximum final hull height, escaped/out-of-bounds IDs, and invalid item reports.

## 6. Automated verification

Focused structural/integration test:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $godot --headless --path . --script res://tools/asset_pipeline/tests/receiving_physics_pile_proof_tests.gd
```

Verified assertions cover the fixed manifests/seeds, CLI batch/instance selection, batch-runner failure classification, corrected OOB boundary/tolerance behavior, all forty eligible visuals, one mesh-derived convex hull per item, absence of pickup components during settling, deterministic non-overlapping spawn placement, corrected containment and presented edges, preserved `4.8 m` barrier span, unchanged Case-B world-space Y geometry, W/camera-forward and D/camera-right agreement, normal camera local yaw, actual production camera-ray targeting, ordinary near/mid pickup-click dispatch, exact `ItemInstance` transfer, frozen-host removal, measured near/mid/far exposed targets, the proof-only held-view override, and preservation of the normal gameplay `1.4 m` reach. Result: `PASS: receiving physics pile proof tests` with exit code 0.

Project/editor scan:

```powershell
& $godot --headless --editor --path . --quit
```

Result: exit code 0 with no parse/import errors.

Twelve-run evidence command:

```powershell
& $godot --headless --path . res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.tscn -- --pile-proof-run-all
```

Result: twelve `PILE_PROOF_METRIC` records, followed by `PILE_PROOF_ALL_COMPLETE runs=12 status=FAIL`, exit code 1. This is the intended aggregate result because the stricter final OOB accounting found boundary violations even though every run settled. The runner exits nonzero if any run is not settled, has an escaped/OOB body, or has an invalid item.

Known unchanged diagnostic: Godot reports the existing non-fatal Windows root-certificate loading warning in headless/editor runs. It does not affect scene parsing, physics execution, or the focused assertions.

## 7. Previous `3.60 × 4.80 m` technical metrics (historical)

| Batch | Instance | Seed | Status | Settle time | Max height | Escaped/OOB | Invalid | Technical notes |
| --- | ---: | ---: | --- | ---: | ---: | --- | --- | --- |
| A | 1 | 230901 | SETTLED | 5.467 s | 0.313 m | loot_000001, loot_000030, loot_000042 | none | strict boundary rerun |
| A | 2 | 230917 | SETTLED | 5.633 s | 0.488 m | loot_000006, loot_000039 | none | strict boundary rerun |
| A | 3 | 230933 | SETTLED | 6.850 s | 0.400 m | loot_000041 | none | strict boundary rerun |
| B | 1 | 231101 | SETTLED | 5.717 s | 0.418 m | loot_000024 | none | strict boundary rerun |
| B | 2 | 231117 | SETTLED | 4.917 s | 0.497 m | loot_000040, loot_000042 | none | strict boundary rerun |
| B | 3 | 231133 | SETTLED | 5.783 s | 0.358 m | none | none | strict boundary rerun |
| C | 1 | 231301 | SETTLED | 5.317 s | 0.398 m | loot_000013, loot_000038, loot_000040, loot_000042, loot_000011 | none | strict boundary rerun |
| C | 2 | 231317 | SETTLED | 5.983 s | 0.216 m | loot_000041, loot_000042 | none | strict boundary rerun |
| C | 3 | 231333 | SETTLED | 7.150 s | 0.341 m | loot_000013, loot_000041 | none | strict boundary rerun |
| D | 1 | 231501 | SETTLED | 5.750 s | 0.224 m | loot_000004 | none | strict boundary rerun |
| D | 2 | 231517 | SETTLED | 6.233 s | 0.235 m | loot_000001 | none | strict boundary rerun |
| D | 3 | 231533 | SETTLED | 7.417 s | 0.193 m | none | none | strict boundary rerun |

All twelve final evidence runs settled within the fixed timeout and had zero invalid items. Ten of twelve runs reported at least one OOB body; twenty run-item instances crossed a usable boundary beyond the 0.02 m tolerance. Spot inspection of A1 confirmed lower hull extents about 0.021–0.053 m below the floor, rather than side-wall escape. Human review should treat buried/sunk thin items as part of the evidence, not as a clean technical pass.

### OOB-accounting correction during consolidated review

The initial OOB predicate only reported a hull after its entire AABB had left the X/Z envelope or fallen entirely below the floor. That definition produced false-clean `none` values for partially protruding hulls. Consolidated code review caught the weakness. The predicate now reports any hull extent beyond X/Z or below the floor by more than the documented 0.02 m contact tolerance, and focused boundary tests cover in-bounds, tolerated contact, partial X/Z escape, and below-floor penetration. The table above is the stricter rerun and supersedes the earlier zero-OOB output.

### Proof-wide correction before final evidence

The first preflight used simultaneous bodies in a tall vertical column. Five runs timed out with out-of-bounds bodies because the artificial initial drop height produced high-impact tunnelling. This was an invalidating setup defect rather than evidence about ordinary pile settling.

The smallest proof-wide correction was applied in `4024eb35abfebdc7c56e966c5813718d7d37ee03`: fixed 0.25-second spawning, with each new hull placed 0.18 m above the current pile and at least 1.20 m above the floor. The exact manifests, seeds, seeded rotations, and seeded X/Z coordinates were unchanged. The table above contains only the clean evidence pass after that correction; the failed preflight was not relabelled as successful physics evidence.

## 8. Corrected `3.872 × 5.75 m` technical metrics

The same twelve manifests, seeds, physics architecture, mass, gravity, spawn stagger, placement rule, settle thresholds, timeout, freeze transition, and strict OOB predicate were rerun after correcting only the functional cage footprint and presentation setup.

| Batch | Instance | Seed | Status | Settle time | Max height | Escaped/OOB | Invalid | Technical notes |
| --- | ---: | ---: | --- | ---: | ---: | --- | --- | --- |
| A | 1 | 230901 | SETTLED | 5.117 s | 0.324 m | loot_000001, loot_000030, loot_000042 | none | corrected containment |
| A | 2 | 230917 | SETTLED | 5.933 s | 0.487 m | loot_000006, loot_000039 | none | corrected containment |
| A | 3 | 230933 | SETTLED | 7.167 s | 0.400 m | loot_000041 | none | corrected containment |
| B | 1 | 231101 | SETTLED | 6.450 s | 0.400 m | loot_000003, loot_000024 | none | corrected containment |
| B | 2 | 231117 | SETTLED | 6.383 s | 0.497 m | loot_000042 | none | corrected containment |
| B | 3 | 231133 | SETTLED | 6.083 s | 0.590 m | loot_000004 | none | corrected containment |
| C | 1 | 231301 | SETTLED | 5.533 s | 0.398 m | loot_000013, loot_000038, loot_000040, loot_000041, loot_000042, loot_000011 | none | corrected containment |
| C | 2 | 231317 | SETTLED | 5.917 s | 0.216 m | loot_000037, loot_000041, loot_000042 | none | corrected containment |
| C | 3 | 231333 | SETTLED | 8.600 s | 0.337 m | loot_000013, loot_000004, loot_000026 | none | corrected containment |
| D | 1 | 231501 | SETTLED | 5.750 s | 0.224 m | loot_000004 | none | corrected containment |
| D | 2 | 231517 | SETTLED | 6.300 s | 0.235 m | loot_000001 | none | corrected containment |
| D | 3 | 231533 | SETTLED | 5.750 s | 0.172 m | loot_000004 | none | corrected containment |

All twelve corrected-containment runs settled within the unchanged timeout and had zero invalid items. All twelve reported at least one strict OOB body, for twenty-five run-item violations in total. The aggregate runner therefore correctly remained `FAIL` with exit code 1. The larger footprint is not treated as a reason to relax, hide, or reinterpret those failures.

This table is the relevant technical evidence for the upcoming human pile review. The previous table remains historical preflight evidence; exact transforms are not compared across the two footprints.

## 9. Human launch commands

Run from the repository root:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'

& $godot --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/receiving/review/receiving_physics_pile_proof.tscn -- --pile-proof-batch=A --pile-proof-instance=1
```

Repeat with each selector:

```text
A/1  A/2  A/3
B/1  B/2  B/3
C/1  C/2  C/3
D/1  D/2  D/3
```

The status overlay reports the selected run, seed, settle status/duration, maximum height, and OOB count. Wait for the frozen-review status before performing TAKE checks.

## 10. Human review matrix

Review all twelve frozen piles. For each one, inspect the initial pile and, where possible, use normal LMB TAKE on one exposed top item, one middle item, and one visible low/supporting large item. Record the post-removal condition without expecting the pile to re-settle.

| Run | Initial pile credibility | Gap/void severity | Precarious balancing | Buried/unreachable items | Gross hull artifacts | Top TAKE | Middle TAKE | Low/supporting TAKE | Floating remnants: none/minor/obvious/severe | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A1 | | | | | | | | | | |
| A2 | | | | | | | | | | |
| A3 | | | | | | | | | | |
| B1 | | | | | | | | | | |
| B2 | | | | | | | | | | |
| B3 | | | | | | | | | | |
| C1 | | | | | | | | | | |
| C2 | | | | | | | | | | |
| C3 | | | | | | | | | | |
| D1 | | | | | | | | | | |
| D2 | | | | | | | | | | |
| D3 | | | | | | | | | | |

Batch-family summary:

| Family | Overall pile quality | Settling reliability | Frozen-removal concerns |
| --- | --- | --- | --- |
| A — Mixed General | | | |
| B — Bulky-Dominant | | | |
| C — Long / Irregular | | | |
| D — Small / Medium Dense | | | |

The developer completed the twelve-scenario review qualitatively. Per-run cells remain blank because no trustworthy run-by-run scores were recorded; they are not backfilled after the fact. The cross-scenario findings below are the authoritative human evidence.

### Final human findings

- In almost all twelve reviewed scenarios, valid-looking TAKE sequences could leave items visibly floating or suspended.
- Support-gating large, visibly reachable objects such as the pig, fuel canister, wood pile, computer tower or armour item would read as a bug.
- Thin and awkward objects such as the hammer and racket exposed floor-clipping and single-convex-hull limitations.
- Actual mesh physics improved initial plausibility in places but did not solve the frozen-removal problem.
- Twelve returned items now appears conservative; mature Expedition balance may often produce closer to roughly twenty, although raw item count is not authoritative. More items are likely to increase support relationships and frozen-removal failures.
- Expedition loot composition must never be skewed merely to improve Receiving visuals.
- The support/collision machinery likely required to rescue the pile is disproportionate to its visual benefit. No support graph should be designed from this proof.
- The corrected approximately `3.87 m` usable depth is excessive: it requires extreme interaction reach, makes small rear items difficult to see, and still leaves the player outside the lift. Approximately `2.0 m` usable depth is the current provisional ergonomic hypothesis, not a promoted final dimension.
- Width remains intentionally open until Expedition and balance work bound presentation demand through Utility/value budgets, likely and maximum counts, Bulk distribution, footprints, legal stacking, composition extremes and catalogue expansion.
- The proof-only `3.5 m` TAKE range remains diagnostic only. Production ordinary loose-item reach remains `1.4 m`; any future Receiving-specific reach must be derived from the selected deck depth and player stance.

## 11. Human decision

Choose exactly one after completing the matrix:

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

Final decision:

```text
PIVOT TO ORDERED TAKE-ONLY DECK
```

The irregular frozen-pile presentation strategy is rejected for production. Receiving, physical loot presentation, the service-elevator fantasy and the isolated review tooling remain valid. This is successful research with a rejected production direction, not a technical failure.

## 12. Successful research outcomes and next direction

The experiment established that:

- real catalogue visuals can be instantiated and represented with one mesh-derived convex hull each;
- deterministic manifests, seeds and staged spawning are useful review tooling;
- hidden settling and frozen presentation can be technically separated;
- human review exposed important lift-cage size and interaction-reach constraints; and
- a technically settled pile is not automatically a good gameplay presenter.

Core ownership remains:

```text
Expedition owns WHAT loot exists.
Receiving owns WHERE/HOW that exact batch is presented.
```

Receiving must not add filler, remove awkward items, replace large items or bias Expedition outcomes for visual reasons.

The next active gate is **deterministic seeded TAKE-only deck presenter design**:

```text
ReceivingBatch
→ ReceivingDeckLayout
→ deterministic footprint reservations
→ controlled supported stacking where legal
→ ordinary WorldItems
→ TAKE only
```

This is not a rigidly ordered cargo presentation. Seeded legal layout may create small items hidden behind bulky front items, partly obscured rear rows, stacks that hide items behind them, and front-to-back wrapper layers that the player peels away. No universal large-back/small-front ordering is approved, but every item must ultimately be retrievable.

The presenter may reuse existing promoted support-stack behaviour where legal. Low, non-loot pallets, half-pallets, shallow industrial trays, low plastic boxes, open crates, freight plates or mats may later act as Receiving-only infrastructure with private internal placement surfaces. They are not player storage, loot, movable containers, PUT targets, zones, labels, manual-placement surfaces or visible grids. Neither the presenter nor those surfaces are implemented by this closure.
