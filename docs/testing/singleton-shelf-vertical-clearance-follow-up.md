# Singleton Shelf Vertical-Clearance Follow-up

## Status

`OPEN — SEPARATE DEBUGGING ISSUE`

Discovered during the completed catalogue-scale deterministic stacking stress test on 2026-09-11. This issue was recorded but deliberately not investigated or fixed during the stacking-promotion task.

## Observed symptom

Ordinary empty placement of a sufficiently tall single item appears able to exceed a closed shelf level's vertical clearance and penetrate the shelf or top geometry.

The symptom was observed through both:

- automatic empty storage placement; and
- manual empty placement.

Automatic placement onto an existing stack correctly enforced the authored vertical-clearance limit during the same gameplay-validation pass.

## Scope boundary

This is a singleton/ordinary-placement clearance issue, separate from the validated deterministic single-column support-stacking operations. No root cause has been assigned. No claim is made yet about the responsible layer, affected item set, or correct fix.

The follow-up debugging task should reproduce the issue independently and compare empty-placement validation with stack-placement clearance validation before changing production behavior.

Related gate evidence: `docs/testing/catalogue-scale-deterministic-stacking-stress-test.md`.
