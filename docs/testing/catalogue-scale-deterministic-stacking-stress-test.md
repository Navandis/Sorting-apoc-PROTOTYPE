# Catalogue-Scale Deterministic Stacking Stress Test

## Gate status and evidence rules

This is the completed formal gameplay-validation gate for the current 40-item eligible catalogue. It is a stratified stress test, not exhaustive pairwise coverage.

The gate has two independent evidence tracks:

1. **Mechanical result** — `PASS`, `FAIL`, or `BLOCKED`. This records whether the authored runtime behavior matches the current deterministic-stacking rules.
2. **Human authoring/playability observation** — a short observation plus one or more tags: `PREDICTABLE`, `GROUP_TOO_BROAD`, `GROUP_TOO_NARROW`, `NONE_CONFUSING`, `REARRANGEMENT_CONFUSING`, `VISUALLY_SURPRISING`, or `OTHER`.

A mechanical `PASS` does not imply that the Auto Group is well authored. For example, a technically correct automatic combination may still be visually surprising and require `REVISE AUTHORING`.

Codex setup and automated verification remain distinct from the human gameplay evidence recorded below. The human run completed S01–S14 with mechanical `PASS` results and expected predictability. The final decision is `PROMOTE`.

## Current preflight snapshot

Snapshot date: 2026-09-11. Matrix preflight baseline: `4245d5c`. Completed human gameplay evidence was recorded against current baseline `4fbb6e0` on clean `main`.

- Audit: 42 current assets; 40 Stack Role eligible/approved/current; 40 Auto Group eligible/approved/current.
- Blocked upstream: `loot_000034` Gloves and `loot_000036` Pants.
- Registry: four approved classes; no unknown references, invalid references, or compatibility-revision issues.
- Existing automated baseline: all 22 scripts in `tools/asset_pipeline/tests` exited zero before this matrix was created.
- Runtime fixture: `main.tscn`, 87 registered world items, and 16 deterministic storage surfaces.

The repeated Windows `Failed to read the root certificate store` diagnostic is environment noise. Judge each suite by its exit code and expected `PASS:` marker. Some negative-path suites also intentionally emit the error or warning they assert.

## Catalogue strata used by this gate

### Approved Auto Groups

| Auto Group | Eligible members | Category | Footprint | Posed height | Scene instances | Selected contrast |
|---|---|---|---:|---:|---:|---|
| `boxed_food` | `loot_000005` Cereal Box | Food | `3x1` | `0.28 m` | 2 | Visual/height contrast with Cereal Box 2 |
| `boxed_food` | `loot_000007` Cereal Box 2 | Food | `3x1` | `0.30 m` | 1 | Same convention across different package art |
| `flat_media` | `loot_000030` Book 01 | Morale | `3x2` | `0.04 m` | 6 | Larger support, rotation and promotion member |
| `flat_media` | `loot_000031` CDStack 01 | Morale | `2x2` | `0.06 m` | 6 | Smaller member and initial promotion base |
| `medical_boxes` | `loot_000028` Med Kit 4 | Medical | `5x4` | `0.14 m` | 3 | Single-member convention tested with duplicates |
| `round_cans` | `loot_000008`, `000009`, `000010` Dry Goods | Food | `1x1` | `0.11–0.13 m` | 10 total | Food side of cross-category convention |
| `round_cans` | `loot_000019`, `000022`, `000023` Food/Soda Cans | Hydration | `1x1` | `0.12–0.14 m` | 17 total | Hydration side and height boundary |

Within-group footprint extremes are Book `3x2` versus CD Stack `2x2` for `flat_media`. Other groups have one footprint convention, so their useful contrasts are package appearance, height, category, and duplication rather than invented footprint variation.

### Actual Stack Role patterns

| Pattern | Count | Representative coverage |
|---|---:|---|
| stackable / non-supporting | 26 | Milk Carton, Electronic Device, Bread |
| support-only | 1 | Computer Tower 01 |
| full stack member | 11 | All approved Auto Group members |
| non-participant | 2 | Pig Carcass 1; Firewood Pile 01 |

### Height, orientation, and explicit-None boundaries

- Shortest selected member: `loot_000001` Computer Mouse 01 at about `0.03 m`.
- Tallest eligible item: `loot_000017` Gas Cylinder 01 at about `0.55 m`.
- Selected near-limit chain: `0.14 + 0.13 = 0.27 m` valid under the `SM_ventilated_locker` highest-level permitted cap of about `0.32295 m`; adding a `0.12 m` can produces `0.39 m` and must fail.
- Selected 90-degree boundary: Electronic Device `3x5` does not fit natively on Med Kit `5x4`, but its `5x3` alternative does.
- Selected automatic rotation boundary: Book `3x2` / `2x3` promoting a CD Stack `2x2` where surrounding reservations leave only one expansion orientation.
- Selected explicit-None contrasts: Milk Carton against same-category `round_cans`; Electronic Device on Med Kit across category/group; small medical None items on a Med Kit; Bread as a same-category terminal package that must not be mistaken for `boxed_food`.

## Coverage matrix

| ID | Scenario | Auto Group / role | Footprint, orientation, height | Zone / operation | Mechanical evidence | Human authoring evidence |
|---|---|---|---|---|---|---|
| S01 | Boxed-food ordinary automatic stack | `boxed_food`; full members | Equal `3x1`, `0.28/0.30 m` | Food-specific; ordinary stack-first | Correct coherent stack and reservation | Package convention reads as obvious |
| S02 | Medical-box duplicate convention | `medical_boxes`; full members | Equal `5x4`; medium clearance | Medical-specific; ordinary stack-first | Duplicate Med Kits stack automatically | Single-member group convention still feels intentional |
| S03 | Cross-category round cans | `round_cans`; full members | Equal `1x1`, varied heights | General; Food + Hydration auto-stack | Cross-category coherence and stable height accumulation | Mixed can silhouettes remain predictable |
| S04 | Category tier ordering | `round_cans`; full members | `1x1` | matching category → General → stop | No mismatched specific-zone entry | Category boundary remains understandable |
| S05 | Awkward flat-media carry order | `flat_media`; full members | `3x2/2x3` and `2x2`; preserve prior yaw | Morale-specific; highest-valid smart insertion | Final narrowing chain without repack | Insertion does not look magical |
| S06 | Automatic base promotion and expansion | `flat_media`; full members | CD `2x2` → Book `3x2/2x3` | General; promotion, shift, atomic rekey | New base owns expanded reservation | Rearrangement is visually legible |
| S07 | Correctly blocked base promotion | `flat_media`; full members | Only expansion cells blocked | General; failed promotion | Existing stack, ownership, and carry remain unchanged | Rejection feels explainable |
| S08 | Restrictive clearance boundary | `round_cans`; full members | `0.27 m` valid; `0.39 m` invalid | low authored top-level cap | Near-limit accept, over-limit reject | Remaining headroom looks credible |
| S09 | Support-only and ordinary clearance | Tower support-only; Book full member | Tower `5x3/3x5`; Book fits; Med Kit does not | `SM_MetalShelves2` level 1 | Tower supports but cannot be incoming; footprint/clearance rules hold | Tall support stack remains readable |
| S10 | Authored open-top contexts | `round_cans` / `flat_media` | Compare explicit caps | top levels of two shelf families | Each family stops at its own cap | Different caps do not look arbitrary |
| S11 | Manual rotated cross-group stack | Med Kit full; Electronic Device None terminal | native `3x5` fails, `5x3` succeeds | manual current-top append | Rotation gates placement; later auto rejects mixed stack | Broader manual compatibility is useful and clear |
| S12 | Explicit-None automatic negative | can full; Milk Carton None terminal | both `1x1` and manually compatible | Hydration/General; manual then automatic | Manual append succeeds; automatic coherence refuses | Player understands why Milk is not `round_cans` |
| S13 | Stack Role negative controls | stackable terminal, support-only, non-participant | representative large/irregular shapes | manual and automatic negative targeting | Role-specific rejection without ordinary-storage regression | Rejection matches visible form |
| S14 | Dense visible-member retrieval | `round_cans`; full members | five-member column plus neighbors | top/middle/base removal | compression, rekey, shrink, visibility rules | Retrieval and compression remain intuitive |

All subjective cells above name the question to observe; they are not pre-filled verdicts.

### Automated and setup evidence map

These checks establish preconditions and mechanical regression protection; they do not fill the human observation column.

| Coverage | Existing automated/setup evidence |
|---|---|
| Current catalogue, group membership, roles, dimensions, posed heights, and instance counts | fresh `run_main_scene_loot_audit.gd` report plus `support_stacking_metadata_tests.gd` |
| Smart insertion, orientation choice, auto coherence, and promotion rules | `storage_stack_rules_tests.gd` |
| Zone tier ordering and cross-category General behavior | `storage_category_semantics_tests.gd` and `storage_stack_surface_tests.gd` |
| Expansion, rekey, blocked promotion, atomic rejection, erased cells, and removal | `storage_stack_surface_tests.gd` |
| Real Book/CD promotion, exact carry rollback, cans, visible-middle retrieval, manual terminal items | `storage_stacking_interaction_tests.gd` |
| Synthetic and real clearance boundaries, Tower/Book/Med Kit, explicit shelf profiles | `storage_stack_clearance_tests.gd` |
| Ordinary non-stacking storage behavior | `storage_unstacked_equivalence_tests.gd` |
| All required world instances remain registered, including `loot_000010` | `main_scene_pickup_registration_tests.gd` |

## Common setup and reset

Run `main.tscn` with the authoritative ignored `assets/` and `.godot/` content present.

- `LMB`: retrieve the visible item under the reticle, including visible non-top stack members.
- `E`: place the selected carried item. Holding repeats only in automatic mode.
- `M`: toggle automatic/manual placement.
- `R`: rotate the selected packing footprint by 90 degrees in manual mode.
- Mouse wheel or number keys: select a carried item.
- `O`: edit zones on the looked-at shelf.
- `F6`: toggle storage grid/occupancy rendering.

Before each scenario, retrieve the previous scenario's items or use a clearly empty shelf segment. Record the shelf family/level and zone layout. Upper stack members must not add occupancy cells; the highlighted reservation remains the base rectangle.

If a setup step cannot be reproduced in `main.tscn`, record `BLOCKED — <exact setup problem>`. Do not change item metadata, stacking rules, categories, or clearances to force the scenario.

## Scenario procedures

### S01 — Boxed-food ordinary automatic stack

1. Use the top level of `SM_MetalShelves` and mark an empty segment Food-specific.
2. Carry one `loot_000005` Cereal Box and `loot_000007` Cereal Box 2.
3. In automatic mode, place the two-box contrast pair while looking at the same surface.
4. Require one centered coherent `3x1` column, one base reservation, stable authored poses, and no intersection or air gap.
5. Observe whether the package variants advertise the same storage convention before placement.

The earlier draft requested a three-box stack. No current enclosed shelf provides sufficient vertical clearance for that configuration. The reproducible current-fixture scenario and completed evidence therefore use the two-member contrast pair on the genuinely open top of `SM_MetalShelves`; no three-box result is claimed.

### S02 — Medical-box duplicate convention

1. Mark an empty area Medical-specific and use ordinary medium clearance.
2. Carry all three `loot_000028` Med Kit 4 instances.
3. Place them automatically while looking at the same surface.
4. Require one coherent stack, one `5x4` base reservation, and deterministic height accumulation.
5. Observe whether a registry class with one catalogue definition but repeated instances reads as intentional rather than arbitrary.

### S03 — Cross-category round cans

1. Mark a clean shelf segment General.
2. Carry at least two Food cans (`loot_000008/9/10`) and two Hydration cans (`loot_000019/22/23`), including the `0.11 m` and `0.14 m` extremes.
3. Place them automatically in alternating category order.
4. Require one `round_cans` stack, a single `1x1` reservation, no drift, and exact accumulated seating.
5. Observe whether all selected silhouettes read as one obvious convention without knowing the registry ID.

### S04 — Matching category, then General, then stop

1. On one surface, create separate Food-specific and General areas. Leave a Hydration-specific area available only as a mismatch control.
2. Seed valid `round_cans` stacks in Food and General.
3. Place an incoming Food can automatically. Require the matching Food tier before General.
4. Fill or block the Food destination and place another Food can. Require General.
5. Fill/block General and try again. Require stop; the item must not enter Hydration merely to join a group member.
6. Repeat the cross-category edge with a Hydration can and confirm it never enters Food-specific cells.

### S05 — Awkward flat-media order and highest-valid insertion

1. Mark an empty area Morale-specific. In manual mode, place the first Book in a deliberate `2x3` packing orientation, then return to automatic mode. A manually placed group member remains a coherent single-member stack.
2. Carry CD Stack, Book, CD Stack in that awkward remaining order.
3. Place all three automatically while looking at the same surface.
4. Require the second Book to smart-insert below the first CD rather than fail or create an avoidable new stack.
5. Require the final narrowing order to be Book → Book → CD → CD. Existing members retain relative order and prior packing yaw; no global optimization occurs.
6. Observe whether the insertion is helpful and visually understandable.

### S06 — Automatic base promotion, rotation, and reservation expansion

1. Place a CD Stack automatically near, but not flush against, a shelf edge.
2. Use neighboring ordinary reservations so only one of Book's `3x2` / `2x3` expansion orientations remains valid.
3. Place a Book automatically while looking at the same surface.
4. Require Book to become the base, CD to become entry one, and all prior member order/yaw to remain unchanged.
5. Require the reservation to expand, remain within the surface, rekey atomically to the Book ID, and shift only as far as necessary.
6. Observe whether the base change and small shift look like a clear storage operation rather than unexplained rearrangement.

### S07 — Promotion rejection is atomic

1. Recreate a CD Stack base near an edge.
2. Block every valid Book expansion alternative using one unrelated reservation, a deliberately disabled cell, or the surface bound.
3. Attempt automatic Book placement.
4. Require rejection with no movement, no order/yaw change, no owner change, no reservation mutation, and no carried-selection loss.
5. Remove only the selected blocker and retry. Require the now-valid deterministic promotion, proving that the original rejection came from expansion policy.

### S08 — Restrictive clearance, near-limit valid, then invalid

1. Use the highest generated level of the enclosed `SM_ventilated_locker`, whose explicit top-level clearance cap is `0.339945 m` and whose permitted 95% top is about `0.32295 m`.
2. Automatically stack a `0.14 m` can and a `0.13 m` can. Require the `0.27 m` stack to remain valid.
3. Attempt a `0.12 m` can. Require rejection because `0.39 m` exceeds the permitted top.
4. Require visible headroom to remain and no mutation of the valid two-can stack.
5. Record separately whether the 5% headroom looks credible.

### S09 — Support-only Tower on ordinary clearance

1. Use level 1 of `SM_MetalShelves2`, with approximately `0.55077 m` closed-level clearance and `0.52323 m` permitted top.
2. Place Computer Tower 01 manually in its `3x5` packing orientation.
3. Place Book 01 on it. Require the approximately `0.51215 m` combined top to fit and remain readable.
4. Clear Book and try Med Kit in both orientations. Require rejection: neither approved Med Kit footprint fits the Tower, and the measured combination also exceeds clearance.
5. Attempt to place Tower as an incoming stack member. Require role rejection because Tower is support-only.
6. Do not report Tower → Med Kit as clearance-only evidence.

### S10 — Explicit open-top contexts

1. Use the genuinely open top levels of `SM_MetalShelves2` (`0.61573 m`) and `SM_MetalShelves` (`0.919 m`).
2. Build equivalent automatic can or flat-media stacks on each, continuing until each family rejects its next member.
3. Require each family to use its placed `StorageShelfClearanceContext` cap rather than a shared fallback.
4. Require rejected additions to leave the existing stack unchanged.
5. Observe whether the different visible shelf contexts make their different capacities unsurprising.

`SM_ventilated_locker2` has an authored `0.519 m` highest-level clearance cap in the runtime profile, but the physical furniture remains an enclosed locker. It is not counted as visual open-top evidence. S10's completed open-top evidence comes from the two metal-shelf families.

### S11 — Manual rotated cross-group relationship

1. Place Med Kit 4 on an empty General area.
2. Switch to manual and target the Med Kit with Electronic Device 01.
3. Require native `3x5` to fail against Med Kit `5x4`; rotate to `5x3` and require placement to succeed.
4. Require Electronic Device to cap the stack because it cannot support another member.
5. Switch to automatic and try another Med Kit. Require the mixed/non-auto-coherent stack to be ignored or rejected under the retained rule.
6. Observe whether manual compatibility feels like useful agency and automatic refusal remains understandable.

### S12 — Explicit-None automatic compatibility negative

1. On General or Hydration-specific cells, place a Hydration `round_cans` member as a `1x1` base.
2. In manual mode, target it with `loot_000020` Milk Carton 1, also `1x1` and explicit `None`.
3. Require manual current-top append to succeed; Footprint, support, and height remain authoritative.
4. Require Milk Carton to cap the stack because it is non-supporting.
5. Rebuild the can alone, switch to automatic, and place Milk Carton while looking at the same surface. Require automatic placement not to join the can stack.
6. Rebuild the manual mixed stack and attempt another automatic can. Require rejection of that mixed/non-auto-coherent stack.
7. Observe whether the player can infer why visually related Hydration packages do not share one automatic convention. A mechanical pass plus `NONE_CONFUSING` is an authoring concern, not a system failure.

### S13 — Stack Role negative controls

1. Confirm a small stackable/non-supporting item such as Bread can be manually added to a sufficiently large valid support, then caps the stack.
2. Confirm Computer Tower can support a valid smaller member but cannot be incoming.
3. Confirm Pig Carcass 1 cannot be stacked and cannot support a stack. Use Firewood Pile 01 as a second non-participant only if its visible form adds information.
4. Store and retrieve each control normally to ensure role rejection does not regress ordinary storage.
5. Observe whether each restriction agrees with the item's visible resting/support surfaces.

### S14 — Dense visible-member retrieval

1. Build a five-member `round_cans` stack and add neighboring reservations close enough to create partial occlusion without blocking intentional side access.
2. Retrieve the top. Require no movement below it.
3. Rebuild, retrieve a visible middle member, and require every member above to move straight down without physics or reordering.
4. Rebuild, retrieve the base, and require the next member to become centered base, ownership to rekey atomically, and reservation to shrink entirely within the old cells.
5. Retrieve the final member and require occupancy to disappear.
6. Require visible non-top members to be retrievable and fully occluded members not to be selected through geometry.
7. Observe whether selection and compression remain intuitive in the dense arrangement.

## Completed human gameplay evidence

The tester completed all fourteen scenarios. Every scenario received a mechanical `PASS`; predictability matched the expected behavior in every case. The observations below remain scenario-specific so the mechanical and authoring conclusions can be audited independently.

### S01 result — Boxed food

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** The reproducible two-box Cereal Box/Cereal Box 2 contrast formed one coherent `boxed_food` column with a single reservation and stable poses. The package variants communicated the shared convention clearly. The originally drafted third box was not tested: no current enclosed shelf had sufficient clearance for a three-box stack, so no evidence is claimed for that unavailable setup.

### S02 result — Medical boxes

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** Repeated Med Kit instances formed the expected uniform `medical_boxes` stack. The single-definition group remained understandable as a repeatable storage convention and did not read as arbitrarily broad or narrow.

### S03 result — Cross-category round cans

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** Food and Hydration members formed the expected cross-category `round_cans` stack on General storage, with stable seating and height accumulation. Dimensional variation among the authored `1x1` cans remained visually readable. A thin can supporting somewhat wider members can look slightly less stable, but the effect does not currently justify an Auto Group, Stack Role, Footprint, or system change.

### S04 result — Zone tier ordering

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** Automatic placement respected matching category first, General second, then stop. Cross-category group membership did not override specific-zone authority, and the distinction remained understandable during play.

### S05 result — Smart insertion

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** The awkward flat-media carry order resolved into the expected narrowing chain through highest-valid insertion. Existing order and packing rotation were retained, and the insertion read as helpful rather than as a global repack or unexplained rearrangement.

### S06 result — Base promotion

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** The larger Book promoted beneath the CD Stack, expanded and rekeyed the reservation, and shifted only as required by the available cells. The prior members remained stable, and the base change was visually legible.

### S07 result — Blocked promotion

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** Blocking all legal expansion alternatives caused the expected atomic rejection. The existing stack, reservation, ownership, and carried state remained unchanged; removing the blocker restored the valid deterministic promotion path.

### S08 result — Restrictive clearance

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** The near-limit can stack was accepted and the over-limit third can was rejected without mutating the existing stack. Insufficient remaining vertical clearance for the third can was visually obvious as well as mechanically correct.

### S09 result — Support-only Tower

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** The Tower behaved as support-only: it accepted the valid Book while remaining invalid as an incoming member. The Tower/Med Kit rejection reflected both the authored Footprint mismatch and clearance limit, and the valid Tower/Book stack remained readable.

### S10 result — Genuine open-top contexts

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** The genuinely open top levels of `SM_MetalShelves2` and `SM_MetalShelves` enforced their distinct authored caps and left rejected stacks unchanged. Their different visible contexts made the capacity difference understandable. `SM_ventilated_locker2` was not counted as open-top evidence because its physical model is enclosed, even though its highest generated storage level has an authored clearance cap.

### S11 result — Manual rotated cross-group relationship

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** The Med Kit/Electronic Device relationship obeyed the expected manual orientation boundary, terminal support rule, and later automatic-coherence refusal. In the associated clearance check, insufficient remaining vertical clearance for a third can was also visually obvious as well as mechanically correct.

### S12 result — Explicit-None automatic negative

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected, with a catalogue watchpoint
- **Observation:** Milk Carton on Soda Can demonstrated the retained distinction correctly: manual `1x1` placement was physically valid, while automatic placement did not treat the explicit-None Milk Carton as a coherent `round_cans` member. The result is somewhat visually awkward because both items occupy authored `1x1` Footprints despite visibly different dimensions. Record this as a future catalogue/content watchpoint, not an Auto Group, Stack Role, or system failure.

### S13 result — Stack Role controls

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** Stackable/non-supporting, support-only, and non-participant controls each accepted or rejected stacking according to their authored role while preserving ordinary storage and retrieval. The restrictions agreed with the representative items' visible forms.

### S14 result — Dense retrieval

- **Mechanical:** `PASS`
- **Predictability:** `PREDICTABLE` — expected
- **Observation:** Top, visible-middle, base, and final removal preserved the expected compression, atomic rekey, reservation shrink, and cleanup behavior. Dense can stacks retained useful sightlines, and member targeting and stack manipulation remained understandable.

## Separate follow-up defect

The human run exposed a separate ordinary-placement issue: sufficiently tall singleton items can apparently exceed a closed shelf level's vertical clearance and penetrate the shelf or top geometry through both automatic and manual empty placement. Automatic stacking continued to enforce vertical clearance correctly.

This issue was not investigated or fixed as part of this gate. It is recorded as `OPEN — SEPARATE DEBUGGING ISSUE` in `docs/testing/singleton-shelf-vertical-clearance-follow-up.md` and does not alter the stacking evidence above.

## Final gate decision

**Decision: `PROMOTE`**

- Current deterministic single-column support stacking is **PROMOTED** and gameplay-validated for the representative catalogue scope covered by S01–S14.
- All four approved Auto Groups remain accepted: `boxed_food`, `flat_media`, `medical_boxes`, and `round_cans`.
- No Stack Role or Auto Group authoring revision is indicated by this gate.
- Mechanical correctness and human authoring evidence remain separate: all scenarios passed mechanically, and the human observations found expected predictability with only the non-blocking S03 stability note and S12 catalogue watchpoint.
- Mixed/non-auto-coherent stack automation remains unchanged and unresolved as previously documented; this gate does not redesign or promote that retained rule.
- Manual under-base insertion remains deferred.
- Multi-column support packing remains outside the architecture.
- The newly discovered singleton vertical-clearance issue is separate from this promotion and remains an uninvestigated follow-up debugging issue.

The promotion applies only to the current deterministic single-column architecture and representative authored catalogue scope. It does not imply exhaustive pairwise validation or expansion to deferred stacking models.
