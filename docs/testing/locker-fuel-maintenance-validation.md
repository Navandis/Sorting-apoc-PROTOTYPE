# Locker level-2 and Fuel Canister maintenance validation

**Final result:** M01 and M02 are human-PROMOTED; the bounded maintenance close-out and Fuel eligibility follow-through are complete on `codex/locker-fuel-maintenance`.
**Published base:** `948275ee296eaa0a94329e8bf0b202d6f5ad6129`
**M01 commits:** `4cf5ca6c11725dd5d56a2791f80d92365b0d71b4` and front-containment follow-up `1d9d1eaa0adfc85a95c1c04ac2d5617346724665`
**M02 commit:** `88ba1c20f0d900b54c3c34b7ca3f18f647ffe61c`
**Fuel eligibility commit:** `e0fca655eecbdb245e44b5f30ff155a7153975ab`

The accepted default wing, fourteen saved item hosts and developer transforms,
F6/F7 policy, geometry, player/HUD, item definitions and Receiving pool are
preserved. The bounded close-out changes only Fuel eligibility: Fuel is eligible
for a correctly authored development host without adding or moving any host in
the saved fourteen-host scene. Gloves and Pants remain blocked.

## M01 — ventilated-locker level 2

The measured source is
`res://assets/environment/furniture/storage/SM_ventilated_locker.glb`, SHA-256
`0d1c9a54532ca71ebba71c3b05fa31980a03c7f43c18189720cd3c9de7159c6e`.
Its front-to-back axis is local X. The measured level-2 support top is
Y=1.116512 and the solid inner back plane is X=-0.390274.

Only the second profile's width and X offset fractions changed in the shared
owner. The width follow-up is required because the old 0.8 m identity / 0.5 m
scaled legal grids cannot fit inside the measured 0.757338 m support span:

| Field | Original | Final |
|---|---:|---:|
| Level-2 profile | `(0.390, 0.94, 0.92, -0.10, -0.03)` | `(0.390, 0.89, 0.92, 0.005, -0.03)` |
| Identity grid rear / front clearance | rear -89.285 mm; front not baseline-sampled | +50.743 / +6.595 mm |
| 0.655 grid rear / front clearance | rear -46.482 mm; front not baseline-sampled | +62.487 / +33.570 mm |
| Identity Soda rear / front-row clearance | rear -66.426 mm; front not baseline-sampled | +73.602 / +29.455 mm |
| 0.655 Soda rear / front-row clearance | rear -23.622 mm; front not baseline-sampled | +85.346 / +56.429 mm |
| Identity capacity | 8×13 | 7×13 |
| 0.655 capacity | 5×8 | 4×8 |

The first measured candidate, 0.00, cleared representative item bounds but left
the identity grid rear edge 3.544 mm behind the panel. The first committed 0.005
offset cleared the rear edge but retained a front overhang of 43.405 mm at
identity and 16.430 mm at 0.655 scale. Final review caught that incomplete
containment. A new RED produced 22 expected front-grid/item/capacity failures.
Reducing only the width fraction to 0.89 removes one X column at both scales and
passes both grid edges plus native/R90 Soda and Book samples on the front and
rear rows. Other locker levels, all metal profiles, level heights, Z offsets,
fixture transforms and stored item scale are unchanged.

The focused test exercises the actual wing and legacy surfaces, production
visual pose and placement controller, auto/manual placement, rotation,
retrieval/re-store, both supported scales, all four levels and metal-profile
preservation. It certifies both measured horizontal support X edges and
representative item bounds; it does not claim every possible item, arbitrary
scale or the full 3D shelf mesh, and it does not alter the existing vertical
seating convention. Full measurements and RED/GREEN evidence are in
[the M01 measurement report](locker-level2-maintenance-measurements.md) and the
ignored `reports/logistics_wing/content_maintenance/locker_fuel/initial/m01/`
tree, including the non-overwriting `front_containment/` follow-up.
The developer human-PROMOTED M01 on 18 September 2026 after checking the
second-from-bottom F6 grid and actual placement at both rear and front edges;
all requested human placement/retrieval checks passed.

## M02 — Fuel Canister reconciliation

Fuel still resolves as `loot_000015` through
`res://assets/props/Fuel/SM_FuelCanister.glb`. The old reviewed binary is not
available, so no byte, topology or old-bounds equivalence is claimed.

| Evidence | Retained approved value | Current measured source |
|---|---|---|
| Source SHA-256 | `e3cbd7d3dd60c9fde76fe92df640aaf62091c9e6c9b6491ee548b0ac1cf10698` | `f095c1ee2eb407ced7214686ba599207d3cbcae8cfbbb61ff0cf06242f54ef85` |
| Canonical bounds | Old numeric bounds unavailable | P(-0.157827,-0.000053,-0.075644), S(0.315692,0.428463,0.150775) m |
| Seated bounds | Old numeric bounds unavailable | P(-0.157846,0.006,-0.075388), same size |
| Storage pose / scale | zero pose / unit scale | unchanged |
| Footprint | 4×2×1 | unchanged; R90 packs 2×4 |
| Stack roles | can be stacked / cannot support | `true` / `false`, unchanged |
| Auto Group | explicit None | unchanged |

The existing authoring writer gained the explicit guarded switch
`--reconcile-fuel-canister-maintenance`. It refuses drift in the item ID, path,
definition, old/new source fingerprints, prior snapshots or retained gameplay
values. One supported application changed only Fuel's top source fingerprint,
five dependent snapshot fingerprints and five provenance notes. All 41
non-Fuel records are semantically identical. Fuel's definition, GLB and import
sidecar remain byte-identical to the pre-task files; category, Bulk/Utility,
pose, Footprint, roles and Auto Group were not redesigned.

The focused integration test uses the existing legacy Fuel instance and real
catalogue, WorldItem, carried-items, placement controller, visual pose and
storage-surface paths. Native auto and R90 manual placement, ghost/final
transform and seated bounds, retrieval/re-store, identity, MedKit support,
Fuel-as-support rejection and absence of automatic group stacking pass. The
labelled runtime-only review scene leaves the normal fourteen-host saved setup
unchanged. Detailed provenance and commands are in
[the Fuel reconciliation report](fuel-canister-maintenance-reconciliation.md).
The developer human-PROMOTED M02 on 18 September 2026 after the recorded Fuel
appearance, handling, native/R90 storage and retrieval checks passed.

## Combined verification

The final combined pass was run once against M01+M02 at
`88ba1c20f0d900b54c3c34b7ca3f18f647ffe61c` with Godot
`4.7.stable.official.5b4e0cb0f`.

- 41/41 discovered non-audit tests exited 0, printed exactly one PASS marker,
  had no script failures or FAIL markers, and matched all 54 expected diagnostic
  lines. This includes both new focused tests.
- `main_scene_loot_audit_integration_tests.gd` separately exited 0 in about six
  seconds with one PASS and no script assertion. The three Fuel-dependent
  assertions and prior timeout are gone.
- Editor initialization plus default, legacy main, neutral review and both inert
  maintenance helpers: 6/6 exit 0 with no script, parse or resource failure.
- Default startup still reports 12 empty functional surfaces, F6 grids default
  OFF and F7 disabled. Explicit `main.tscn` still reports 16 storage surfaces
  and 87 registered items.
- `git diff --check` is clean. The published base is an ancestor of the branch;
  local `main` and `origin/main` remain at the base, and no remote maintenance
  branch exists.

Final review then identified the rear-only M01 result's unsupported front edge.
After the bounded follow-up at `1d9d1eaa0adfc85a95c1c04ac2d5617346724665`,
the affected locker calibration, stack-clearance, bridge interaction, gameplay
composition and F6 tests all exit 0 with PASS. The affected default and explicit
legacy-main 90-frame smokes also exit 0. No M02 file changed and the full
combined suite was not rerun merely for this focused repair; the new raw logs
are under `initial/m01/front_containment/`.

### Accepted close-out verification

After both human PROMOTEs, commit
`e0fca655eecbdb245e44b5f30ff155a7153975ab` removes only `loot_000015`
from the continuing seed registrar's blocked IDs. The saved fourteen-host scene
is unchanged. A runtime-only correctly authored Fuel host now registers through
the production registrar; the same test proves Gloves (`loot_000034`) and Pants
(`loot_000036`) remain rejected. Fuel definition, catalogue, Receiving pool,
locker calibration, default launch and F6 behavior are unchanged.

Five focused eligibility/Fuel checks pass with no assertion, script, parse or
resource failure. The final discovered combined pass includes all 42 test
scripts, including `main_scene_loot_audit_integration_tests.gd`: 42/42 exit 0,
print exactly one PASS marker and match the established per-test intentional
diagnostic headers. The legacy audit's former Fuel-related failure and timeout
are resolved; it now completes normally with no assertion. A fresh settled
editor scan and normal default launch both exit 0 without duplicate UID/class or
dependent compile errors. Default startup still reports twelve functional
surfaces, F6 default OFF and F7 disabled. The only common engine diagnostic is
the disclosed Windows root-certificate-store error.

Close-out logs and strict structured accounting are retained under
`initial/final/closeout/`, including `combined_e0fca65/combined_results.json`,
`editor_scan_final.log` and `default_launch_final.log`. The earlier technical,
RED/GREEN, rendered and packaging evidence remains historical and unchanged.

The first test-results classifier expected the baseline JSON's wrong container
shape and falsely labelled four known negative-diagnostic suites. The raw runs
were valid; classification was corrected from those logs without rerunning the
suite. Likewise, an initial smoke aggregate used malformed scene arguments and
recorded five command failures without authoritative project logs. That
aggregate is preserved as `smoke_results_invocation_error.json`; corrected
explicit scene invocations are the authoritative 6/6 record. No baseline was
rerun for either reporting correction.

Every Godot process reports the known Windows root-certificate-store diagnostic.
Fuel capture also reports four Compatibility-renderer null-material messages on
each of three held transitions. An unchanged Soda Can control reproduces the
same four messages, so this is disclosed as a shared unresolved renderer/player
diagnostic; it was not suppressed or repaired in this content task.

Authoritative final records are under
`reports/logistics_wing/content_maintenance/locker_fuel/initial/final/`:

- `combined_test_results.json` and `tests/*.log`;
- `main_scene_loot_audit_integration_tests.log`;
- `smoke_results.json`, `smokes/smoke_results.json` and six smoke logs;
- `m01/front_containment/` RED/GREEN, affected checks and matched captures;
- the hashed compact review bundle, evidence manifest and SHA-256 sidecar.

## Packaging isolation follow-up

Before resuming M01's human check, Godot discovered copied scripts and UIDs in
the two project-local review-bundle staging directories. Each staging root now
contains a genuine zero-byte `.gdignore` created at the root, before any child
resource can be scanned:

- `reports/logistics_wing/content_maintenance/locker_fuel/initial/final/review_bundle_5e9366f/.gdignore`
- `reports/logistics_wing/content_maintenance/locker_fuel/initial/final/review_bundle_95a8787/.gdignore`

No sibling `review_bundle_*` directory remains unisolated. The copied payloads,
ZIPs, checksum sidecars, production classes and production `.uid` files were not
changed or removed. A fresh settled editor scan and normal default launch both
exit 0 without duplicate-UID, duplicate-global-class or dependent compilation
errors. Logs are retained under `initial/final/packaging_isolation/`.

Future source-bundle staging must be created outside the Godot project when
practical. If it must be project-local, its empty `.gdignore` must be created
before any scripts, scenes, resources or `.uid` files are copied into it. This
is a packaging rule, not a new packaging framework.

## Preservation result

Of 26 protected tracked paths, 21 match the pre-task Git object and working-file
SHA exactly. The only five authorized differences are
`storage_prototype_manager.gd` for M01 and
`tools/asset_pipeline/item_authoring_review.json`,
`authoring_review_manifest.gd` and
`seed_or_sync_item_authoring_review.gd` for M02, plus
`gameplay/logistics_wing/development/seed_registrar.gd` for the approved Fuel
eligibility follow-through. Protected geometry trees,
`project.godot`, `wing_gameplay.tscn`, `main.tscn`, functional fixtures,
player/HUD, F6 sources, shared placement/stacking behavior, `data/` and Receiving
remain unchanged. The ignored locker/Fuel source hashes and required import
state remain present.

## Human acceptance

For the locker, start normal Run Project and enable F6. The dedicated labelled
capture/helper can also be launched with:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/locker_level2_maintenance_capture.tscn -- --capture-m01 --phase=after
```

For Fuel, launch the runtime-only candidate review:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/fuel_maintenance_review.tscn -- --review-fuel
```

M01 and M02 are independently PROMOTED within the focused checks described
above. The bounded Fuel eligibility follow-through is complete: only
`loot_000015` was removed from `BLOCKED_ITEM_IDS`, while Gloves and Pants remain
blocked. No upper-level visibility, shelf/ceiling height, expanded palette, art
or Receiving work is approved by this acceptance.
