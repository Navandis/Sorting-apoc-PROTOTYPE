# EAF4B Human Decisions and Diagnostic Rerun Validation

Status: **REVIEW CALIBRATION IMPLEMENTED / TECHNICALLY VERIFIED / SIX HUMAN DECISIONS PENDING**

- Branch: codex/eaf4b-wear-overlay-catalog
- Starting HEAD: d58e463234688ebee497d24b101e9dd18f07b6d2
- Promoted main/origin/main baseline: 06153075bb77564c2ac12161bce62ca60439a4a0
- Source index: eaf4a-1, fingerprint ac8a65aa3f0552e8c70824e842a5ac4716988785bf20125c17ddc4c65271944c
- Human decision record: data/environment/wear_catalog/decisions/2026-09-27-eaf4b-human-review.json
- New rerun configuration: data/environment/wear_catalog/review_batches/wear_foundation_01_rerun_01/rerun.json

## Human decisions applied

The full stable IDs and reviewed fingerprints came from the existing wear_foundation_01 batch and decision template. No ID was inferred from a display name. The decision record preserves the user's review notes and uses decision_revision 1.

| Catalog ID | Source short name | Decision | Semantic category |
| --- | --- | --- | --- |
| eaf4b_1215035d1f7cf36ee4b9f3eb | concrete_crack_sfhmrfg | APPROVED | CRACK |
| eaf4b_5858bd2916c3227c201ec5a4 | concrete_damage_sfcmkbg | APPROVED | SPALL |
| eaf4b_2faa4471206d5eaf048558bb | damaged_concrete_tbqmbayr | APPROVED | SPALL |
| eaf4b_c3b63b5da3fbdda32be47bd0 | concrete_crack_sf2moag | APPROVED | CRACK |
| eaf4b_16f72d4cb37ef4ee74a9073c | oil_stain_semlsbi | APPROVED | OIL_GREASE |
| eaf4b_e890439d8e117d36ac05e55c | leakage_skiubhzc | APPROVED | WATER_MINERAL |
| eaf4b_c8b0a5126abd42ebe766fd44 | grunge_tedxadjc | APPROVED | IMPERFECTION_MASK |
| eaf4b_e1cf2067e3efcd02296f1f79 | scratched_metal_vdekebbc | DEFERRED | IMPERFECTION_MASK |

The catalog now has seven current APPROVED records, one DEFERRED record, no REJECTED record, and six undecided sources absent from final-decision records. All eight current source fingerprints match their reviewed fingerprints. The approved mineral stain's grunge dependency is also current. Reapplying the same decision manifest produced zero audit changes. Default approved query excludes the deferred scratch source.

Approved restaging produced six loadable EnvironmentWearOverlaySpec resources and one approved_masks.json entry for grunge_tedxadjc. The grunge entry is explicitly modulation-only; no standalone overlay spec is generated for it. The deferred scratch source has no approved spec. The mask resource path points to the ignored local cache, so a fresh checkout must restage from the EAF4A source root before loading it.

## Review calibration

The wrapper review scene adds a quiet untextured StandardMaterial3D with albedo (0.48, 0.49, 0.50), roughness 0.75, metallic 0, and no color or normal texture. It applies that material to the EAF1 review surfaces only when diagnostic mode is selected. The wall context is WEAR_DIAGNOSTIC_LIGHT; the floor context is WEAR_DIAGNOSTIC_FLOOR. The material is not entered in the EAF3 catalog. The B key returns to real EAF3 contexts; D toggles the diagnostic view interactively.

The floor wear placement and its close cameras were moved within the EAF4B wrapper so the overlay quad no longer intersects the EAF1 reference block footprint. EAF1's scene, lights, fixed cameras, Neutral Calibration, Receiving Target Preview, and WallGrazing shadow fix were not edited. The original approved EAF3 contexts remain available and are captured in the rerun.

The six unresolved sources are concrete_leakage_tk3jej1c, leakage_tculfbnc, road_dust_sgzh1so, rust_debris_ugxhbh0h, chipped_paint_patch_ui2ncdjfw, and industrial_abandonedfactory_wall_concrete_painted_xetubap. Each is captured on its diagnostic and original EAF3 base, with original and calibrated opacity/albedo controls, under both light rigs and both close cameras. The calibrated values and rationale are in rerun.json and in the capture manifest. These values are review probes; none was reconciled as a new catalog decision.

## Evidence packages

- Original: reports/environment_wear_catalog/reviews/wear_foundation_01_review.zip, 81 PNGs and three review files. SHA-256: 455d3f704ecc4e21909ef9c399d438296560b5fb8af82acc2371ac4c94d34451.
- Rerun: reports/environment_wear_catalog/reviews/wear_foundation_01_rerun_01_review.zip, 112 PNGs and three review files. SHA-256: ac90e278d4277164a673bdaee5fa41b49869914e02bf5f35512b29384f1e89df. The 112 captures are 96 candidate comparisons and 16 shared diagnostic/EAF3 base-only references.
- The rerun package includes only manifest-listed PNGs, manifest.json, batch_summary.md, and decision_template.json. Its six decision-template entries remain PENDING. Neither package includes commercial map bytes or Godot import sidecars.

The original ZIP hash is unchanged. After an output-routing correction during implementation, all 81 images in its expanded folder were restored byte-for-byte from that ZIP and the final rerun command completed independently in the new folder. The original expanded folder again contains exactly 81 PNGs.

Reproduce the new package from the project root:

    python -m tools.environment_authoring.wear_catalog.cli capture-rerun --rerun wear_foundation_01_rerun_01

The command verifies that the configuration selects exactly the six undecided sources and that staged fingerprints still match EAF4A inputs before capturing.

## Verification

- EAF4B Python suite: 12 tests passed, including mask-only restaging and exact unresolved rerun selection.
- EAF4B original Godot overlay test: pass.
- EAF4B diagnostic scene test: pass, including quiet material, EAF3 restoration, unchanged EAF1 light transform, and floor clearance.
- EAF4B live human catalog Godot test: pass, including all seven approved queries, six valid overlay specs, the approved mask texture, and deferred exclusion.
- EAF4A Python suite: 23 tests passed.
- EAF3B Python suite: 15 tests passed; Godot catalog query and live catalog suites reported zero failures.
- EAF1 focused Godot suite: zero failures, including light, camera, WallGrazing shadow, and injection checks.
- Review-scene headless parse: exit 0.
- Godot 4.7 Compatibility capture rerun: exit 0, 112 records, package assembled.
- Godot printed its local Windows certificate-store warning at startup; local tests and captures completed.

The remaining six sources require human review of the new diagnostic-versus-EAF3 evidence. EAF4B/EAF4 promotion, EAF5, Receiving C1, merge, and push remain outside this task.


## Subsequent disposition — 27 September 2026

The six sources described as pending above were subsequently resolved by the final human decision record `data/environment/wear_catalog/decisions/2026-09-27-eaf4b-final-six-human-review.json`: five APPROVED and xetubap DEFERRED. The current catalog has 12 APPROVED and 2 DEFERRED entries, with no pending or rejected entries. The earlier sections remain the time-local review-calibration record. The reproduction command above belongs to that pending-decision state; its exact-unresolved-source guard now correctly refuses a new capture after final reconciliation. The original and rerun package hashes above remain unchanged.
