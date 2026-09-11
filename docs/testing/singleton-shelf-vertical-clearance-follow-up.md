# Singleton Shelf Vertical-Clearance Follow-up

## Status

`IMPLEMENTED — AUTOMATED PASS; AWAITING IN-GAME AUTO/MANUAL VALIDATION`

Discovered during the completed catalogue-scale deterministic stacking stress test on 2026-09-11. This issue was recorded but deliberately not investigated or fixed during the stacking-promotion task.

## Observed symptom

Ordinary empty placement of a sufficiently tall single item appears able to exceed a closed shelf level's vertical clearance and penetrate the shelf or top geometry.

The symptom was observed through both:

- automatic empty storage placement; and
- manual empty placement.

Automatic placement onto an existing stack correctly enforced the authored vertical-clearance limit during the same gameplay-validation pass.

## Scope boundary

This remains a singleton/ordinary-placement clearance issue, separate from the validated deterministic single-column support-stacking operations. The investigation and implemented fix below do not change the promoted stacking architecture or catalogue authoring.

The follow-up debugging task reproduced the issue independently and compared empty-placement validation with stack-placement clearance validation before changing production behavior.

Related gate evidence: `docs/testing/catalogue-scale-deterministic-stacking-stress-test.md`.

## Root cause and implemented rule

Both ordinary empty-placement searches were horizontal-only. Automatic placement called the zone/occupancy first-fit path, while manual placement called the nearest free-cell path. Neither path compared the already-seated posed item bounds with the surface's physical vertical clearance. The working stack paths instead passed those same posed bounds through `StorageStack`, which compared the resulting seated stack top with the surface limit. Empty-placement commit also trusted the candidate fit, so a stale or independently constructed valid-looking fit could bypass search-time validation.

Singleton empty placement now evaluates the authoritative seated top as the candidate host Y plus `aligned_bounds.end.y`. The aligned bounds are produced by `StorageVisualPose` after authored pose, contributor aggregation, seating, and optional packing yaw. The check uses the existing storage-stack height epsilon and compares against physical `stack_clearance_m`; it deliberately does not apply the stack-only 95% gameplay-headroom rule. `StorageSurface.commit_stack_entry()` repeats the check for every empty placement before reserving cells.

Automatic and manual empty search share the same physical predicate. Manual ghost validity and final placement consume the same fit, and commit-time revalidation remains authoritative.

## Deterministic evidence

The authored-profile regression confirms that closed/intermediate `SM_ventilated_locker_level_3` has `0.321610 m` physical clearance. The focused singleton regression reproduces that exact clearance in an isolated deterministic surface with real posed catalogue items:

| Measurement | Computer Mouse 01 | Gas Cylinder 01 |
|---|---:|---:|
| Local support plane Y | `0.000000 m` | `0.000000 m` |
| Candidate host Y | `0.012000 m` | `0.012000 m` |
| Seated bounds min Y | `0.006000 m` | `0.006000 m` |
| Seated bounds max Y | `0.038945 m` | `0.552583 m` |
| Resulting seated top | `0.050945 m` | `0.564583 m` |
| Physical clearance | `0.321610 m` | `0.321610 m` |
| Result | accepted | rejected |

The real Computer Tower authored pose is also asserted at seated min Y `0.006 m` and reviewed posed height `0.45806125 m`, guarding against substituting raw contributor bounds for the authoritative seated frame. Native and 90-degree packing-yaw measurements produce the same vertical extent.

The genuine `SM_MetalShelves2_level_4` open-top regression reads its placed instance's explicit `0.615730 m` clearance. A synthetic seated top of `0.612 m` is accepted even though it exceeds the stack-only 95% threshold; a seated top of `0.622 m` is rejected.

## Validation state

Automated verification is complete. The promoted deterministic-stacking and Auto-Group architecture, authored item metadata, shelf profiles, and catalogue verdict are unchanged. The defect is not fully validated until the auto/manual gameplay checks in `docs/testing/singleton-shelf-vertical-clearance-fix-playtest.md` are completed.
