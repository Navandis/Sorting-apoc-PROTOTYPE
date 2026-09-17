# Sorting Apocalypse — Whole-Wing Greybox Acceptance

**Record date:** 17 September 2026  
**Disposition:** PROMOTE the current whole-wing greybox as the human-validated working spatial baseline.  
**Scope:** Geometry, circulation, rough proportions, boundaries and first-person spatial review of the neutral logistics wing. This is not production-art or integrated-gameplay approval.  
**Repository action:** None performed by this acceptance record. No merge, push, branch change or project edit is authorized by the record itself.

## 1. Basis for closing the milestone

The developer previously reported that round three resolved essentially all pending geometry issues, including the missing corners. The remaining requests were two new Medical tuning choices: double the exclusive approach and align the unchanged-size room's eastern wall with the corridor.

After the Medical tuning implementation, the developer states:

> In-game review confirms that the medical room and its corridor are now build and placed exactly as requested.

> Visual checks did not identify any other changes or regressions.

These statements supply the human-review result that was necessarily PENDING when Codex packaged its validation report. The current recommendation is to close the greybox correction milestone and retain the scene as the accepted working layout. No additional general geometry correction round is indicated by the supplied feedback.

The full scope of later item interaction, furnished circulation, machinery operation, production art and integrated balance is not covered by this acceptance.

## 2. Accepted implementation and evidence identity

| Record | Value |
| --- | --- |
| Branch | `codex/logistics-wing-greybox` |
| Source/evidence commit | `aeb1ef27671f2f07d651e5064b00c3c77a06600b` |
| Final documentation-only commit, reported | `8d64086aa02ade21449af24dbc7742748115792c` |
| Layout revision | `logistics-wing-greybox-medical-tuning-revision-04` |
| Runtime review scene | `res://greybox/logistics_wing/wing_review.tscn` |
| Source geometry | `greybox/logistics_wing/build_wing_geometry.gd` |
| Saved geometry | `greybox/logistics_wing/wing_geometry.tscn` |
| Repository validation record | `docs/testing/logistics-wing-greybox-medical-tuning-validation.md` |
| Evidence directory | `reports/logistics_wing/greybox/revision_04/` |
| Supplied archive | `logistics_wing_medical_tuning_review_bundle.zip` |
| Archive SHA-256, independently recomputed | `ca98bb36be4b4cbb0bc0ef2e60199ca395b35f18920db3693b71f4fb62ca2490` |

The relationship between the commits, live branch cleanliness, protected-project diff and lack of merge/push are recorded by Codex and repeated by the developer. The attached archive does not include Git history or the complete project, so this review does not independently verify live repository state.

## 3. Final Medical dimensions

Coordinates follow the source: +X east; +Z south. Nominal wall-centre/floor bounds are not the same as clear inside-face dimensions.

| Element | Accepted result |
| --- | --- |
| Exclusive corridor | Nominal X `5.8..8.2`, Z `-23..-13`; length 10 m, previously 5 m; width unchanged. |
| Anteroom | Nominal X `0.4..8.2`, Z `-30..-23`; unchanged 7.8 x 7.0 m footprint and 3.4 m clear height. |
| Room translation | 2.6 m west and 5.0 m north relative to round three. |
| Eastern wall | Corridor and room align at centre plane X `8.2`; continuous inside face approximately X `8.05`. |
| Entrance | South-east corner of the room; old south-east shoulder removed. |
| Clear dimensions | Approximately 2.1 m corridor width and 7.5 x 6.7 m room plan. |
| A/B connector | Remains Main Storage circulation; not included in the exclusive Medical length. |

The room's inner staffed-core boundary, provisional interface, anchors and review label move with it. No final furnishing or permanent submission-device placement is approved by these proxy locations.

## 4. Evidence layers and verification limits

### Developer's human evidence

The requested Medical geometry was tested in game and accepted as matching the request. No other visual changes or regressions were identified. Combined with the preceding round-three review, this closes the outstanding greybox layout corrections.

### Codex's reported runtime and test evidence

The bundled validation report and machine-readable evidence record 22/22 controller routes, 12/12 boundary probes, zero traversal failures, 113 current junction pairs with zero unresolved, all three focused suites passing, and 33/33 established non-hanging regression scripts passing. Medical outbound and return routes are both included.

The known bounded integration-audit exception remains separately disclosed. The source/evidence checkpoint is distinct from the final documentation-only commit. These are reported local test results, not tests rerun by ChatGPT.

### Independently performed archive/static checks in this review

- Recomputed the archive checksum and matched the supplied SHA-256.
- Recomputed all eight source/test hashes listed in the capture manifest; all match the archived files.
- Compared the embedded round-three baseline with the separately supplied round-three bundle, normalizing line endings and generated identifiers/resource references; the scene records match.
- Compared the saved round-three and Medical-tuned wing scenes after recursively resolving resource properties and ignoring generated node/resource IDs. Excluding root metadata and the specifically authorized Medical paths, there are zero non-Medical saved-scene differences. This covers serialized node properties and referenced resources in `wing_geometry.tscn`, not the whole live project.
- Checked the saved Medical corridor and room floor positions/sizes against the intended dimensions and inspected the corresponding source definitions.
- Checked the route/boundary success flags and junction totals in the archived JSON records for consistency with the report. This does not replay the tests.
- Confirmed that the 38 manifest views and four contact sheets have the expected root-image count and 1920 x 1080 dimensions.
- Visually inspected the Medical roof-off plan, entrance, room-to-corridor east-wall view and whole-wing overview.

No Godot launch, new render, player walkthrough, full-project regression run or live Git inspection occurred in this chat. The separate `Sorting_Apocalypse_Wing_Greybox_Acceptance_Checks.json` preserves the static comparison results.

## 5. Production-workflow conclusion

**Full-wing construction feasibility is demonstrated for this scope:** the human-directed local Codex workflow produced a complete, walkable, collision-enabled neutral wing and converged on the accepted spatial arrangement.

**Bounded revision reliability is demonstrated by the final Medical edit:** the requested geometric change was isolated, its neighbouring saved geometry remained unchanged, and the developer confirmed the result in game.

This is not a claim of reliable unattended level design or first-attempt fidelity. Earlier rounds required repeated construction repairs, reference clarification and explicit constraint management; some later edits were genuine design refinements rather than executor failures. Human review remained material to the outcome.

The measured evidence does not establish a general time/cost budget or prove that the same workflow can deliver coherent materials, furnishings or production-quality asset composition. Those questions remain for the later small visual-construction proof. The result supports continued use of this supervised workflow without requiring a pipeline replacement solely because of the greybox exercise.

## 6. What is retained and what remains open

Retain the accepted whole-wing builder/scene and captured overview as the working dimensional baseline. The older schematics remain design-history and relationship references; do not revert approved in-engine refinements merely to conform to their pixels.

Preserve the original storage test scene and default launch, player/controller behaviour, existing storage/stacking and Receiving data/lifecycle contracts, rejected Receiving branch, and historical evidence trees. The accepted greybox is not a new reason to restructure those systems.

Remaining work is outside this completed greybox gate:

- physical Receiving, including actual item containment, visibility/reach, progressive unloading, barrier/shutter operation and transfer into legal storage;
- freight side-pocket and later lining-volume decisions, which were expressly deferred rather than validated by this empty-cage layout;
- final service-room furnishing, material submission devices and delivery choreography;
- production Structural Shell/Applied Finish and subsequent environment layers;
- optional abandoned stubs in a later context, not directly connected or immediately adjacent to service spaces or the Ops landing;
- integrated route pacing, usable storage capacity and request/economy balance under gameplay.

Further layout changes should be motivated by a specific new interaction, clearance or playtest finding. Acceptance does not freeze dimensions permanently or certify furnished gameplay.

## 7. Administrative close-out and next development direction

Persist the developer's acceptance in the active repository validation/status record when close-out work is authorized. Do not rewrite old reports to imply that earlier unapproved builds had already passed human review. Consolidate current decisions, this acceptance and the abandoned-stub supersession in the next master-document update; no GDD/VDD/Findings DOCX was edited in this review.

A merge/push decision remains separate from spatial approval. The branch and evidence should remain preserved until integration is explicitly authorized and the local checkout is inspected. A historical SHA is a checkpoint, not authority to reset subsequent work.

The previously agreed next substantive direction is a focused functional Receiving-to-storage prototype on this working layout, using the established item/handling systems. Its acceptance should concern a real reproducible batch and ordinary TAKE/carry/store operation, not a fully dressed Receiving room. The later small architectural/material proof remains a separate production question. Neither next-stage implementation nor full-wing dressing is started or authorized by this acceptance record.

## Source register

1. The developer's latest message: local Codex completion report and explicit in-game Medical acceptance/no observed visual regressions.
2. `logistics_wing_medical_tuning_review_bundle.zip`, especially `source/docs/testing/logistics-wing-greybox-medical-tuning-validation.md`, `evidence/revision_04/capture_manifest.json`, `traversal_results.json`, `junction_inventory.json`, `round04_measurements.json`, `non_medical_semantic_preservation.json`, the saved scenes/source, and the four inspected views.
3. Previously supplied `logistics_wing_round03_review_bundle.zip`, used to check the embedded pre-task baseline.
4. Current-session static audit output: `Sorting_Apocalypse_Wing_Greybox_Acceptance_Checks.json`.

The archive's pre-walkthrough PENDING status is historically correct; the developer's subsequent confirmation is the new evidence supporting this acceptance record.
