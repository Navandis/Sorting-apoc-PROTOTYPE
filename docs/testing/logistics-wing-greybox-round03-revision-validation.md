# Logistics Wing Greybox — Round-Three Revision Validation

**Date:** 17 September 2026

**Branch:** `codex/logistics-wing-greybox`

**Verified round-two final / revision start:** `66b7c18f54c45c6b682970b1971dd2bc6e5f099a`

**Verified round-two source/evidence ancestor:** `13f45122eaf141cf579fcb35131601181b99ee9e`

**Main/origin base preserved:** `8ee62bd3bc4f23918717517e066d4c6a8cb565df`

**Round-three source and evidence revision:** `e2803cd9f989b0545d41f0bdf52cd37cbf766371`

**Rejected Receiving branch preserved:** `c9752c8c68cd55b950dd588542ea271e1acc0aab`

**Engine:** Godot `4.7.stable.official.5b4e0cb0f`, Jolt, GL Compatibility

**Evidence renderer:** OpenGL 3.3 Compatibility, NVIDIA GeForce RTX 5060 Ti

## Outcome

The eight bounded round-three corrections are technically complete on the
existing local wing branch. The authoritative builder, generated scene,
review scene, capture helper, traversal helper and three focused test sources
are synchronized at the source/evidence revision above. Human spatial
promotion remains pending the developer's walkthrough.

The approved Backlog/Sorting northern-edge change is used only to produce a
real partial freight-aperture view from the unchanged desk stance. The Kitchen
increase is applied to its initial eastbound straight. Accepted neighbouring
geometry and active destinations remain intact. The Workshop abandoned stub
is still absent. Freight lining, furnishing, production art, departmental
delivery gameplay, physical Receiving, NPCs and balance remain deferred.

The final handoff commit is expected to be a documentation-only descendant of
the source/evidence revision. Its exact SHA is reported in the final task
response because a commit cannot embed its own hash.

## Review launch

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64.exe' --path 'D:\Godot Projects\Sorting-apoc-PROTOTYPE' 'res://greybox/logistics_wing/wing_review.tscn'
```

The review scene starts on the Receiving apron and uses the unchanged project
controller: `WASD`, mouse-look, `Shift` sprint and `Esc` mouse release. Walk
speed is `4.0 m/s`, sprint multiplier `2.0`, capsule radius/height
`0.34/1.75 m`, eye height `1.7162851 m`, and FOV `75°`.

## Eight-item correction register

`PASS` below means the authored correction and technical evidence passed. It
does not mean the spatial or production workflow has received human approval.

| ID | Requested target | Actual geometry / measurements | Technical check | Visual evidence | Retained neighbour result | Remaining human judgment |
| --- | --- | --- | --- | --- | --- | --- |
| R03-01 | Align the Receiving/Backlog height closure with the doorway depth and remove the ceiling artifact. | Closure is `X -28.65..-28.35`, `Z -1.92..1.92`, `Y 3.40..4.20`; Backlog floor still begins `X=-28.5`, while its ceiling begins at `-28.35`. | Exact saved boxes, zero positive overlap, mesh/collider parity, and three distinct capture poses pass. | `ceiling_transition_approach.png`, `ceiling_transition_threshold.png`, `ceiling_transition_departure.png`. | Receiving aperture, apron, Dispatch and freight assembly are unchanged. | Confirm the transition reads cleanly in motion with no distracting banding. |
| R03-02 | Restore the partition to `X=-15`, recover nominal `13.5/10 m` Backlog/Sorting spans and create meaningful partial freight awareness. | Partition `X=-15`; Backlog nominal/clear main span `13.5/13.2 m`; Sorting nominal/clear main span `10.0/9.7 m`; opening `Z -3.4..1.44` (`4.84 m`). Three rays cover real upper-rail targets `Z 1.95..2.2`. | Exact floors/jambs, three clear rays ending on `FreightBarrier/UpperRail`, and separate named long-vista blockers pass. | `backlog_sorting_*.png`, `sorting_desk_freight_aperture.png`. The desk image shows an identifiable yellow barrier fragment. | Desk/table/work eye, Receiving aperture, southern jamb, freight cage and Storage/Ops blockers are unchanged. | Judge whether the visible fragment is useful without weakening room separation. |
| R03-03 | Remove the Salvager elbow lip and tighten the rear enclosure. | Pocket rear moves `Z 29.5→28.5`; unchanged machine rear is `28.0`; rear wall inside face is `28.35`, leaving `0.35 m`. Pocket-west nominal start is `24.0`, joined only to `23.85`. | Exact floor/roof/side/rear boxes, exact saved-collider face clearance, route to the unchanged front, and generic junction audit pass. The gap is intentionally smaller than the controller diameter and is not tested by spawning inside it. | `workshop_salvager_approach_reveal.png`, `salvager_local.png`, `salvager_rear_clearance.png`. | Workshop room, machine, front anchor and approach reveal stay fixed; no floor/roof reserve survives beyond the rear wall. | Confirm the enclosure reads tight and connected rather than cramped or detached. |
| R03-04 | Replace the C/D cube with the supplied folded thin-wall chain and retain one secondary link. | Chain is `(-2,15)→(2,15)→(2,11.5)→(6,11.5)→(6,17.5)`; sole link remains `X=6`, `Z 9.0..11.5`. | Exact wall boxes, end/midpoint solid samples, all-quadrant junction audit, C/D shortcut and identical-endpoint spine replay, plus an outer-return controller probe pass. | `storage_cd_south.png`, `storage_cd_folded_c.png`, `storage_cd_folded_roofoff.png`. | D/E extents and the accepted spine stay fixed; there is no second C↔D opening or orphan slab. | Compare the roof-off chain directly with the red overlay and judge eye-level legibility. |
| R03-05 | Treat the full A/B connector as Storage and lengthen only Medical's exclusive spur. | Connector stays `X 4.5..9`, `Z -13..-1.5`, now Storage-treated and grouped. Medical-only corridor grows `3→5 m` (`+66.7%`) at `Z -18..-13`; the unchanged `7.8×7 m` room moves to `Z -25..-18`. | Material/name metadata, exact non-overlapping slabs/walls, translated anchors/interface/boundary, route and inner-boundary probe pass. | `storage_ab_junction.png`, `medical_approach.png`, `medical_anteroom.png`. | A/B footprints/openings, room size and territorial separation stay fixed; no gallery-mediated Medical access is added. | Judge whether the five exclusive metres clearly separate the anteroom from Main Storage. |
| R03-06 | Increase Kitchen's initial eastbound straight by about 40% and move the turn/room coherently. | B-east plane `16.5`; turn centre `22.6→25.0`; nominal straight `6.1→8.5 m` (`+39.3%`); wall-face-to-centre `8.35 m`; width remains `2.8 m`; room remains `10.5×7 m`. | Exact leg/room boxes, one B-east route, translated anchor/interface/boundary, no-overlap and boundary probes pass. | `kitchen_b_east.png`, `kitchen_turn.png`, `kitchen_service.png`. | Gallery B, Medical, spine and room shape remain unchanged; no shortcut is introduced. | Judge the longer first straight and single turn at walking speed. |
| R03-07 | Move the full Incinerator installation east near the wide-leg turn and close the old mouth. | Whole assembly translates `+5 m`; mouth centre `31.5→36.5`, mouth `X 34.5..38.5`, `2.5 m` from turn plane `X=39`; pocket remains `7×7 m` at `X 33..40`. | Exact approach, both front shoulders, both sides, rear, floor and machine pass; route reaches the translated front; old-mouth controller probe stalls on restored ordinary wall. | `incinerator.png` and the computed full-wing overview. | Deeper bend, narrow run and Ops geometry stay fixed; exactly one entrance remains. | Judge whether the installation is close enough to the turn without constricting the through route. |
| R03-08 | Complete and classify the whole current junction inventory. | `115` current perpendicular pairs: `57` corrected/new, `58` already covered, `0` unresolved; `11` intentional open jambs; `26` retired round-two pairs marked not applicable. Types: `53` true corners, `48` concave returns, `13` butt/T joins, `1` cross join. | Four thickness-quadrant samples per pair, typed floor-context classification, zero collinear duplicates, zero positive slab overlaps, exact visual/collision parity for every generated box, and all required openings clear. | Full overview, two local roof-off diagnostics, all normal-height views and `junction_inventory.json`. | Endpoint-specific joins preserve clear openings and accepted room outlines; no blanket both-end extension was used. | Inspect retained districts for any visually distracting join despite complete structural coverage. |

## Numeric change summary

Coordinates use `+X east`, `+Z south`, `Y=0` finished floor, `0.30 m`
wall/slab thickness and `3.40 m` ordinary clear height.

| Measurement | Round-two baseline | Round-three result |
| --- | --- | --- |
| Receiving height-closure depth | `X -28.80..-28.50` | `X -28.65..-28.35`; aligned to doorway strips |
| Backlog / Sorting partition | `X=-21` | `X=-15` |
| Backlog nominal / clear main span | `7.5 / 7.2 m` | `13.5 / 13.2 m` |
| Sorting nominal / clear main span | `16.0 / 15.7 m` | `10.0 / 9.7 m` |
| Backlog/Sorting opening | `Z -2.4..1.44`, `3.84 m` | `Z -3.4..1.44`, `4.84 m` |
| Salvager machine-to-rear-wall inside face | `1.35 m` | `0.35 m` |
| Medical-only corridor | `3.0 m` | `5.0 m` |
| Kitchen initial wall-plane-to-centreline straight | `6.1 m` | `8.5 m` (`+39.3%`) |
| Incinerator mouth centre / turn distance | `X=31.5 / 7.5 m` | `X=36.5 / 2.5 m` |

The authored floor-plan envelope is `110.0×4.2×53.5 m`. The manifest's
computed saved-mesh AABB is position `(-44.15,-0.30,-25.15)`, end
`(66.325,4.50,28.65)`, size `110.475×4.80×53.80 m`. The overview camera is
computed from that current AABB and targets `(11.0875,0,1.75)`; it is not
framed against the historical `110×55 m` constant.

The machine-readable numeric record is
`reports/logistics_wing/greybox/revision_03/round03_measurements.json`.

## Junction inventory

`junction_inventory.json` is generated by the focused geometry test against
both the preserved round-two scene and the current saved scene. It records
wall names, coordinate groups, topology type, playable-floor quadrant count,
four coverage samples, baseline gaps, final disposition and authorized open
jamb samples.

| Inventory result | Count |
| --- | ---: |
| Round-two static seed candidates | 39 |
| Round-two audited perpendicular pairs | 111 |
| Round-two uncovered pairs/quadrants | 39 / 39 |
| Round-three audited perpendicular pairs | 115 |
| Corrected or new/renamed joined pairs | 57 |
| Already-covered retained pairs | 58 |
| Intentional open jambs | 11 |
| Retired/not-applicable round-two pairs | 26 |
| Unresolved round-three pairs | 0 |

The baseline scene used for reproducibility is preserved below
`revision_03/round02_baseline/`; it was extracted from the verified round-two
final commit rather than copied over the working scene.

## Controller traversal and boundary evidence

The current replay uses the unchanged `CharacterBody3D`, capsule and
`player_controller.gd`, with injected physical W-key input and no sprint.
All **21/21 routes** and **12/12 boundary probes** pass with zero failures.

Selected moved/comparative routes:

| Route | Distance | Duration | Result |
| --- | ---: | ---: | --- |
| Shared A/B junction → Medical anteroom | `12.922 m` | `3.350 s` | PASS |
| Gallery B → Kitchen service | `27.162 m` | `6.933 s` | PASS |
| Sorting → Salvager front | `39.450 m` | `10.050 s` | PASS |
| Sorting → Incinerator front | `62.110 m` | `15.717 s` | PASS |
| C → D secondary link | `8.593 m` | `2.233 s` | PASS |
| C → D via primary spine | `18.254 m` | `4.767 s` | PASS |
| Sorting → Bunker Ops | `87.434 m` | `22.133 s` | PASS |

Boundary results:

| Probe | Final axis | Displacement | Result |
| --- | ---: | ---: | --- |
| Freight barrier | `X=-38.497` | `1.497 m` | PASS |
| Medical inner boundary | `Z=-24.508` | `1.508 m` | PASS |
| Kitchen inner boundary | `Z=-24.508` | `2.508 m` | PASS |
| Workshop inner boundary | `X=-17.509` | `2.009 m` | PASS |
| Workshop south wall | `Z=24.509` | `1.009 m` | PASS |
| Bunker Ops inner boundary | `Z=-10.509` | `2.009 m` | PASS |
| Deeper-settlement door | `X=65.334` | `0.834 m` | PASS |
| Kitchen turn return | `X=24.092` | `1.108 m` | PASS |
| Dogleg return | `X=42.508` | `0.508 m` | PASS |
| Shared-junction return | `Z=-12.508` | `0.708 m` | PASS |
| C/D folded outer return | `X=6.492` | `1.508 m` | PASS |
| Vacated Incinerator mouth | `Z=4.009` | `1.009 m` | PASS |

The complete machine-readable record is `traversal_results.json`.

## Rendered evidence and provenance

All current outputs are isolated below
`reports/logistics_wing/greybox/revision_03/`. Earlier evidence and the user's
untracked `reports/receiving/` tree were preserved. The set contains 36 named
full views and three contact sheets, all `1920×1080`. Normal views retain
`1.7162851 m` eye height, `75°` FOV and ceilings. Only the full overview and
two explicitly labelled local audit views hide ceilings. Contact-sheet image
regions preserve 16:9 and place captions in separate bands.

`comparison_index.md` maps ten byte-copied round-two before images to current
matched or supplemental views. Moved Medical/Kitchen/Incinerator cameras
follow the same route/working relationship; unchanged Sorting and Salvager
arrival poses remain fixed where required.

| Manifest source | SHA-256 |
| --- | --- |
| `build_wing_geometry.gd` | `451751612449a9b94716fce5b548eddf2d0c5f9d6dbe60c2a4970c5fdee94010` |
| `wing_capture.gd` | `44a085ee5de2b3f2d6aedfbe8f77764b7dfa9ea8e33510ee509a721f42aeee69` |
| `wing_geometry.tscn` | `720557fbb663d69bf918a491e5499bf31de16c4d5ae4edaf917a93e206c126ce` |
| `wing_review.tscn` | `922c21f35dc026e0b97d17828ea49f464619ae1b459a53e6d11d763ca19459a1` |
| `wing_traversal.gd` | `184ae356c1f0a6852f9cdf23259dd79c35f305518ab543614e71608a0f37e249` |
| `logistics_wing_capture_tests.gd` | `0fb3c56efb63ee8ba32cd5ef75634b743d1cafb5682b89899bf9f1447129047a` |
| `logistics_wing_geometry_tests.gd` | `ec12f4cd0a8b286b8c2dfb47e6b7af05b0f344dcca388cee4d9735bc17d2b8de` |
| `logistics_wing_traversal_tests.gd` | `2f31f4e38e8b378deed9b9895353ac40460a3e11c6a93a44775937589c5d476c` |

All eight hashes were recomputed after final capture and match the manifest.
The capture manifest, traversal result and junction inventory all identify
`e2803cd9f989b0545d41f0bdf52cd37cbf766371` as the exact source/evidence
revision.

## Verification record

| Check | Result |
| --- | --- |
| Preflight / ancestry | PASS — correct branch and exact reported round-two final verified; no reset, clean or stash used. |
| Test-first reproduction | PASS — the new contract failed against the round-two scene before production edits (36 geometry, 14 capture and 7 traversal assertions). |
| Deterministic geometry rebuild | PASS — 968 nodes; repeated saves changed only Godot-generated `unique_id` values. `git diff --no-index --ignore-matching-lines='unique_id='` returned 0. |
| Saved visual/collision parity | PASS — every generated box has a finite positive BoxMesh; all solids have identical BoxShape size/local transform; only four named provisional interfaces are visual-only. |
| `logistics_wing_geometry_tests.gd` | PASS — all eight corrections, retained neighbours, rays, openings, slabs, enclosure and typed junction checks. |
| `logistics_wing_capture_tests.gd` | PASS — 36-view manifest, computed overview bounds, roof state, camera and aspect-preserving contact contract. |
| `logistics_wing_traversal_tests.gd` | PASS — 21 routes and 12 meaningful boundary definitions. |
| Capture runtime | PASS — 36 views, 3 sheets, `gl_compatibility`; all 39 PNGs are `1920×1080`. |
| Traversal runtime | PASS — 21/21 routes, 12/12 boundaries, 0 failures. |
| Junction inventory | PASS — 115 current pairs, 11 intentional openings, 0 unresolved. |
| Editor/parser scan | PASS; Windows root-certificate diagnostic only. |
| Independent review-scene smoke | PASS. |
| Original default-main smoke | PASS; default scene unchanged, 31 trimesh meshes, 9 convex meshes, 87 world items registered. |
| Existing non-hanging regressions | PASS — 33/33 scripts exited 0 with exactly one PASS line each. |
| Bounded legacy integration audit | Baseline reproduced after 25 seconds: two `_assert_summary` assertions at line 179 and one `_init` assertion at line 95; no fourth assertion. |
| Independent read-only code review | PASS after fixes; no remaining findings. |
| Protected-file diff from `8ee62bd3` | PASS — `main.tscn`, `project.godot`, shared controller/camera, `data/` and authoring review manifest unchanged. |
| Workshop-stub / rejected Receiving source search | PASS — no active wing source match or instance. |
| Source/evidence working tree | PASS — tracked tree clean at the source checkpoint; only preserved untracked report trees present. |

The 33 passing regression scripts were `authoring_review_manifest`,
`auto_stack_group_registry`, `environment_asset_relocation`,
`footprint_review_content`, `item_catalog_coverage`,
`item_catalog_initial_seed`, `item_catalog`, `item_definition_seeder`,
`item_interaction_reviewability`, all three `logistics_wing` suites,
`loot_audit_core`, `main_scene_pickup_registration`, all seven `receiving_*`
suites, `stack_role_authoring`, `stack_role_batch`, all nine `storage_*`
suites and `support_stacking_metadata`.

Godot repeatedly emitted `Failed to read the root certificate store` on this
Windows host while every relevant command exited successfully. The wing does
not use network features.

## Scope and preservation

Round-three tracked changes are limited to the expected builder/generated
scene, capture/traversal/review dependencies, all three focused tests and the
new spec/plan/validation records. `review_player.tscn`, shared scripts,
project settings, gameplay/catalogue data and assets are unchanged. The
rejected Receiving branch still resolves to `c9752c8...` and is not an
ancestor of this branch. Nothing was merged or pushed.

The Workshop stub remains absent from floor, ceiling, side/rear walls,
boundary, debris, anchor, topology, route, label, light and capture layers.
No abandoned replacement stub was added. No freight lining, furnishing, art,
physical Receiving, facility interaction or balance work began.

## Review and correction cycle observations

- Full-resolution self-review replaced three obscured evidence poses with a
  readable Kitchen-leg view and local roof-off C/D and Salvager diagnostics.
- The endpoint audit expanded the 39 round-two seed candidates into a current
  115-pair typed inventory rather than suppressing or sampling only the list.
- Independent review rejected an attempted controller probe inside the
  intentionally non-traversable `0.35 m` Salvager gap; evidence now uses exact
  saved-collider faces and an elevated visual instead.
- The same review prompted complete BoxMesh/BoxShape parity, explicit junction
  types, honest `0.25 m` freight-ray wording and direct Incinerator
  front/side/rear invariants. All were rerun before the source checkpoint.

These observations demonstrate bounded correction and preservation behavior;
they do not by themselves approve the human–Codex production workflow.

## Status separation and next gate

| Status category | Status | Meaning |
| --- | --- | --- |
| Automated verification | PASS | Focused suites, 33 regressions, parser/smokes, render, controller replay, hashes and saved-scene audits passed. |
| Geometry integrity | PASS | No unresolved junction, visual/collision mismatch, unintended duplicate, slab overlap, exterior seam or removed-stub residue was found. |
| Eight-item correction fidelity | PASS | R03-01 through R03-08 have direct dimensional and technical evidence. |
| Human spatial promotion | PENDING | Requires the developer's normal-controller walkthrough. |
| Production-workflow feasibility | PENDING HUMAN JUDGMENT | The bounded revision is evidenced; reliability/effort promotion is not automatically claimed. |
| Freight lining / physical Receiving | DEFERRED | No lining, loot piles, live arrivals or rejected Receiving implementation was added. |
| Art / furnishing / departmental gameplay | DEFERRED | Neutral greybox and existing proxy masses only. |
| Integrated balance | DEFERRED | Route timings are measurements, not tuning approval. |

Human review should answer:

1. Is the Receiving/Backlog ceiling transition visually clean in motion?
2. Does the restored Backlog/Sorting allocation provide useful partial freight awareness without making the opening too permissive?
3. Do the C/D fold and tightened Salvager enclosure match the supplied visual intent at eye height?
4. Do the longer Medical and Kitchen approaches now feel distinct and proportionate?
5. Is the Incinerator close enough to the wide-leg turn while leaving a comfortable through route?
6. Does this correction cycle provide acceptable preservation, reliability and intervention cost for the next production decision?

Stop after this walkthrough. Do not merge, push, furnish, add abandoned stubs
or begin physical Receiving automatically.
