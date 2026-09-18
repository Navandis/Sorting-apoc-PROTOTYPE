# M01 locker level-2 maintenance measurements

Technical repair on 18 September 2026. Human PROMOTE/REVISE remains pending.

The only production change is the shared second locker level's X offset fraction,
`-0.10` to `0.005`, in `storage_prototype_manager.gd`. Heights, other profile
parameters, other levels/families, scene transforms, cell size and item scale are
unchanged. The continuing wing and both legacy lockers inherit this owner.

## Mesh reference and scope

Source: `res://assets/environment/furniture/storage/SM_ventilated_locker.glb`.
SHA-256: `0d1c9a54532ca71ebba71c3b05fa31980a03c7f43c18189720cd3c9de7159c6e`.
The test refuses a different source fingerprint. Retained mesh-triangle evidence
is in `reports/logistics_wing/content_maintenance/locker_fuel/initial/asset_geometry_probe.log`.

Front-to-back is local X. Inner back plane: X=-0.390274. Level-2 horizontal
support top: Y=1.116512, X=-0.390274..0.367064, Z=-0.718901..0.718882.
These are mesh measurements, not coarse movement-collider bounds.

| Measurement | Before | After |
|---|---:|---:|
| Level-2 local X center | -0.079559 | 0.010469 |
| Identity world movement in +X | — | 0.090028 m |
| 0.655 world movement in +X | — | 0.058968 m |
| Identity quantized size/capacity | 0.8 × 1.3 m / 8×13 | unchanged |
| 0.655 quantized size/capacity | 0.5 × 0.8 m / 5×8 | unchanged |
| Identity Soda Can rear clearance | -0.066426 m | 0.023602 m |
| 0.655 Soda Can rear clearance | -0.023622 m | 0.035346 m |
| Identity Book native / R90 rear clearance | -0.046170 / -0.062863 m | 0.043858 / 0.027165 m |
| 0.655 Book native / R90 rear clearance | -0.003366 / -0.020059 m | 0.055602 / 0.038909 m |
| Identity rear grid-line clearance | -0.089285 m | 0.000743 m |
| 0.655 rear grid-line clearance | -0.046482 m | 0.012487 m |

The identity grid's local X interval changes from [-0.479559, 0.320441] to
[-0.389531, 0.410469]; Z remains [-0.693877, 0.606123]. For the wing's placed
locker, world X changes from [-1.829559, -1.029559] to [-1.739531, -0.939531],
with world Z [8.306123, 9.606123]. The scaled legacy grid's world X changes from
[0.500682, 1.000682] to [0.559651, 1.059651], with world Z [0.015260, 0.815260].
The identity legacy grid's world X changes from [0.323076, 1.123076] to
[0.413105, 1.213105], with world Z [1.337891, 2.637891].

The regression proves the quantized rear grid boundary clears the panel and
actual rear-row item bounds clear the back and side interior at both ends.
The initial 0.00 candidate left the identity rear line 3.544 mm behind the panel;
the second RED test rejected it. The geometric minimum is approximately 0.004134
of the asset's 0.857411 m X span; 0.005 provides 0.743 mm clearance without losing
cells. It does **not** certify that the complete grid outline lies on the flat
support polygon: its front is beyond the measured flat top's X=0.367064 end.
The unchanged seating convention also leaves a
measured bottom-to-support delta of -5.054 mm at identity scale and +9.110 mm
at 0.655. Height tuning and full shelf-mesh certification are outside M01.

## Reproduction and verification

`tools/asset_pipeline/tests/locker_level2_calibration_tests.gd` was written and
run before the owner edit. `initial/m01/red_verified.log` exits 1 with 21
physical back-plane failures. The 0.00 intermediate candidate passed the item
test (`green.log`) but failed the added quantized-grid assertion twice in
`red_grid_boundary.log` (exit 1). The final 0.005 repair passes both requirements:
`green_grid_boundary.log` exits 0, prints its PASS marker, and has no
script/assertion failures. All runs contain the existing Windows
root-certificate-store diagnostic.
The earlier `red.log` is retained as a harness-development attempt, not the
authoritative RED result; its wrong legacy player path was corrected before
`red_verified.log` and before the production edit.

The test loads the actual wing and legacy scenes, uses `StorageVisualPose`,
installed `StorageSurface` fit APIs, the production placement controller and
`WorldItem` retrieval. It checks native/R90 Soda Cans at both rear ends,
native/R90 Book placement, auto placement reaching (0,0), nearest legal manual
placement, retrieval/re-store identity, unit stored scale, all four levels,
capacities and preserved level heights/Z offsets. Metal capacities and heights
are checked; the owner diff proves every metal profile field is unchanged.
Fits are selected programmatically at the production controller boundary;
this does not claim a human mouse/raycast interaction test.

Final focused regressions (`*_final.log`) exit 0 with PASS markers:

- `storage_stack_clearance_tests.gd` (intentional MissingContextShelf warning).
- `wing_storage_bridge_interaction_tests.gd`.
- `wing_gameplay_composition_tests.gd` (two intentional duplicate-namespace errors).
- `wing_storage_debug_f6_tests.gd`.

Default wing and explicit `main.tscn` headless 90-frame smokes exit 0. Editor
initialization exits 0 without parser errors. The certificate diagnostic occurs
throughout; it is disclosed separately from gameplay/test failures.

## Matched rendered evidence

Use `reports/logistics_wing/content_maintenance/locker_fuel/initial/m01/before_03/`
and `after_02/`. Each contains full-resolution 1920×1080 `player_eye.png`,
`diagnostic_rear.png`, and a manifest with source/helper SHA, camera position,
target/FOV, surface center, actual item bounds and reservation origins. Helper
SHA is identical between the matched runs. The earlier `before_02` diagnostic
was occluded by the wing wall and is not the selected comparison. `after/`
retains the superseded 0.00 candidate, not the final repair.

The normal view uses Y=1.72 m, FOV 75°, and the same position/target before and
after. Two actual cans use auto/native and manual/R90 placements. F6 is enabled
through the real input event path. The diagnostic rear-oblique image is
explicitly labelled. Inspection shows both cans behind the panel before and
inside the locker afterward. No furniture or mesh is moved for either image.

From the project directory, use the authoritative executable:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tools/asset_pipeline/tests/locker_level2_calibration_tests.gd
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/locker_level2_maintenance_capture.tscn -- --capture-m01 --phase=after
```

The capture scene is inert without `--capture-m01`, requires an explicit phase,
chooses a new numbered output directory if one exists, has a 45-second deadline,
and exits after capture. Its runtime-only sample disappears on exit. Ordinary
launch, F6/F7 behavior, saved fourteen-host setup and Fuel eligibility are untouched.
