# M02 Fuel Canister source reconciliation

18 September 2026: technical reconciliation complete; maintenance human
PROMOTE/REVISE remains pending. The ordinary wing seed still blocks Fuel,
Gloves and Pants. No item definition, source/import file, scene, palette,
Receiving pool or gameplay rule was changed.

## Current content and retained decisions

Fuel resolves through the live catalogue as `loot_000015`, using
`res://assets/props/Fuel/SM_FuelCanister.glb` (exact case).

| Evidence | Retained decision | Current measured source |
|---|---|---|
| SHA-256 | `e3cbd7d3dd60c9fde76fe92df640aaf62091c9e6c9b6491ee548b0ac1cf10698` | `f095c1ee2eb407ced7214686ba599207d3cbcae8cfbbb61ff0cf06242f54ef85` |
| Canonical bounds | Old binary/bounds unavailable | P(-0.157827,-0.000053,-0.075644), S(0.315692,0.428463,0.150775) m |
| Scale | Approved; legacy instance unit scale | Import root scale 1.0, apply_root_scale=true; canonical/stored unit scale |
| Storage Pose | Default zero approved | (0,0,0), unchanged |
| Seated bounds | No retained old numeric bounds | P(-0.157846,0.006,-0.075388), same size |
| Footprint | Geometry-approved 4×2×1 | Current geometry derives 4×2; R90 packs 2×4 |
| Stack roles | Can be stacked; cannot support | true / false, unchanged |
| Auto Group | Human-approved explicit None | Empty group, unchanged |

The current content is compatible with the retained choices. This is not a
claim of byte, bounds or topology equivalence with an unavailable old export.
Category remains Fuel; Bulk 1, Utility None/0 and presentation metadata remain
unchanged. Fuel source, import sidecar and definition hashes remain respectively
`f095c1ee...f54ef85`, `12dd7d61...ba592de`, `b15fe534...ec83039` (full hashes in
`initial/m02/preserved_hashes.log`).

## Bounded writer and TDD evidence

The existing sole writer `tools/asset_pipeline/seed_or_sync_item_authoring_review.gd`
now has `--reconcile-fuel-canister-maintenance`. It calls a narrow manifest
helper that requires the exact old/new Fuel fingerprints, ID/path/definition,
zero pose, 4×2×1 footprint, roles, explicit None, and current prior decision
snapshots against the old fingerprint. Drift is refused without input mutation.

The writer was applied once. Only Fuel's top-level source fingerprint, four
review source fingerprints, Auto Group's nested source fingerprint and five
provenance notes changed. Prior statuses/decisions and notes are retained; the
added note explicitly says maintenance human review remains PENDING. Every one
of the other 41 records is semantically identical (`semantic_diff.log`); the Git
diff contains no other manifest record or definition change.

Evidence is under `reports/logistics_wing/content_maintenance/locker_fuel/initial/m02/`:

- `red_storage_pose.log`: original source-fingerprint assertion at line 143,
  despite the historical test printing PASS and exiting 0.
- `red_manifest_helper_verified.log`: exit 1 for missing bounded helper before
  implementation. `green_manifest_helper.log`: helper positive/refusal tests pass.
- `red_fuel_integration.log`: five real freshness failures before apply; the
  handling/geometry checks already passed. `fuel_canister_maintenance_tests_final.log`:
  exit 0, PASS, no script/assertion errors after apply.
- `red_audit_stderr.log`: 25-second timeout with two summary assertions and
  Fuel eligibility assertion. `audit_before.json` retains the dependency block.
- `audit_after_stdout.log` / `audit_after_stderr.log`: audit now exits 0 with
  PASS in approximately 6 seconds. All three assertions and timeout disappear;
  Fuel's five review-current fields are true and both dependency blocks false.
  Its coarse OFF_CENTER_BOUNDS / IRREGULAR_REVIEW flags remain disclosed.

Affected storage-pose, manifest, Stack Role authoring/batch, catalogue coverage,
Receiving pool and wing seed tests all pass. Seed tests intentionally emit their
invalid-ID/blocked-ID/duplicate-namespace errors. The Windows root-certificate
diagnostic remains on engine runs. No full baseline rerun or runner tooling was
added for this task.

The focused integration test picks up the existing legacy Fuel through WorldItem,
uses the real catalogue instance, carried-items, installed metal shelf, placement
controller and visual pose paths, and checks native auto/R90 manual packing,
actual ghost/final transforms and seated bounds, retrieval/re-store, identity,
unit scale, manual support by a real MedKit, rejection of a can above Fuel and
absence of automatic group stacking. Fits are selected programmatically at the
controller boundary, not presented as a human mouse/raycast test.

## Candidate review and captured appearance

`initial/m02/capture/` contains five labelled 1920×1080 images of current source,
held state, native auto placement, R90 manual placement and retrieval, plus an
identity/source manifest. Captured images were visually inspected. The
Compatibility renderer reports four null-material messages on each of three
held transitions (12 total), despite correct images. The bounded unchanged
Soda Can control (`held_control.gd` / `.log` in the same evidence directory)
reproduces the same four messages. This shared held/rendering diagnostic remains
unresolved; no rendering/player changes were made or errors suppressed.

Launch the labelled interactive candidate from the project directory:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/fuel_maintenance_review.tscn -- --review-fuel
```

It starts near a single loose Fuel candidate on Gallery A's level-2 metal shelf.
Use normal pickup, M/R/E placement and retrieval. The normal fourteen-host setup
is loaded unchanged; this extra candidate and its Fuel zone are runtime-only and
vanish on exit. Without an explicit review/capture flag the helper is inert.
`--capture-fuel` instead performs a bounded 45-second capture into a new numbered
directory. A rendered 120-frame interactive smoke exits 0 without gameplay errors.

After a separate human approval, eligibility follow-through would remove only
Fuel from `BLOCKED_ITEM_IDS` in `gameplay/logistics_wing/development/seed_registrar.gd`
and update the corresponding Fuel-block expectation in
`tools/asset_pipeline/tests/wing_seed_fixture_tests.gd`. Gloves and Pants stay
blocked; no such follow-through is part of this technical reconciliation.
