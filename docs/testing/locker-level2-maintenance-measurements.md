# M01 locker level-2 maintenance measurements

Technical repair on 18 September 2026. Human PROMOTE/REVISE remains pending.

Final shared level-2 profile: `_make_level_profile(0.390, 0.89, 0.92, 0.005, -0.03)`.
Relative to the original, only width fraction `0.94 -> 0.89` and X offset fraction
`-0.10 -> 0.005` change. The front-containment follow-up changes width only.
Height, depth/Z, other locker levels, metal profiles, fixture transforms, cell
size, canonical item scale and placement mechanics remain unchanged. M02 is not
changed by this follow-up. The wing and both legacy lockers use the shared owner.

## Mesh reference and calibration

Source: `res://assets/environment/furniture/storage/SM_ventilated_locker.glb`.
SHA-256: `0d1c9a54532ca71ebba71c3b05fa31980a03c7f43c18189720cd3c9de7159c6e`.
The regression refuses a different fingerprint. Retained mesh-triangle evidence:
`reports/logistics_wing/content_maintenance/locker_fuel/initial/asset_geometry_probe.log`.

Front-to-back is local X. Measured level-2 horizontal support: Y=1.116512,
X=[-0.390274, 0.367064], Z=[-0.718901, 0.718882]. These are mesh measurements,
not coarse movement-collider bounds. Aggregate asset X span is 0.857411 m.

| Stage | Width / X fractions | Identity local grid X (m) | Identity / scaled capacity |
|---|---|---|---|
| Original | 0.94 / -0.10 | [-0.479559, 0.320441] | 8×13 / 5×8 |
| Superseded first candidate | 0.94 / 0.00 | [-0.393818, 0.406182] | 8×13 / 5×8 |
| Superseded rear-only repair | 0.94 / 0.005 | [-0.389531, 0.410469] | 8×13 / 5×8 |
| Final both-edge repair | 0.89 / 0.005 | [-0.339531, 0.360469] | 7×13 / 4×8 |

The original penetrated the rear panel. The 0.00 candidate still left the rear
grid line 3.544 mm behind it. The 0.005 offset cleared that line but overhung the
front by 43.405 mm at identity and 16.430 mm at 0.655 scale. It was not a complete
support-containment repair and is retained only as superseded diagnostic evidence.

An 0.8 m grid cannot fit the 0.757338 m support span. At scale 0.655, an 0.5 m
world grid cannot fit the 0.496056 m world support span either. One X column must
be removed at each scale; no translation can preserve these former capacities.
The scaled quantization threshold is width fraction
`0.5 / (0.857411 * 0.655) = 0.890306724`: it must be strictly below that value.
`0.89` is the largest hundredth-step profile value that fits both scales; `0.90`
would retain the invalid scaled fifth column. Requested widths are 0.763095790 m
identity and 0.499827742 m scaled, quantizing to 0.7 and 0.4 m. The scaled request
has a 0.172258 mm margin below the rounding threshold; this calibration is bound
to the exact asset and scales, not a claim for arbitrary future exports/scales.
Keeping X offset 0.005 avoids another center shift and contains both final edges.

| Final measurement | Identity scale (wing and legacy) | 0.655 legacy scale |
|---|---:|---:|
| Local X center | 0.010469 m | 0.010469 m |
| Local grid X interval | [-0.339531, 0.360469] m | [-0.294875, 0.315812] m |
| World usable size | 0.7×1.3 m | 0.4×0.8 m |
| Level-2 cells | 91 (was 104; -13) | 32 (was 40; -8) |
| Grid rear / front clearance, world | 50.743 / 6.595 mm | 62.487 / 33.570 mm |
| Soda rear / front-row clearance, world | 73.602 / 29.455 mm | 85.346 / 56.429 mm |
| Book native rear / front clearance, world | 93.858 / 49.711 mm | 105.602 / 76.685 mm |
| Book R90 rear / front clearance, world | 77.165 / 33.018 mm | 88.909 / 59.992 mm |

Identity Z remains [-0.693877, 0.606123]. Wing world X is now
[-1.689531, -0.989531], Z=[8.306123, 9.606123]. Legacy identity world X is
[0.463105, 1.163105], Z=[1.337891, 2.637891]. Legacy scaled world X is
[0.609651, 1.009651], Z=[0.015260, 0.815260]. Other locker levels retain
8×13 identity / 5×8 scaled; metal surfaces retain 10×29 and 4×29 capacities.

Unchanged seating leaves bottom-to-support Y deltas -5.054 mm at identity and
+9.110 mm at 0.655. Height tuning is explicitly outside this repair. The test
certifies the measured horizontal support edges and representative mesh bounds,
not all possible items, arbitrary scales, full 3D shelf geometry or human approval.

## RED/GREEN and focused verification

Evidence root: `reports/logistics_wing/content_maintenance/locker_fuel/initial/m01/`.
All earlier evidence is retained: original `red_verified.log` (21 back-plane
failures), 0.00 `green.log` (items only), `red_grid_boundary.log` (rear-grid fail),
and 0.005 `green_grid_boundary.log` (rear-only pass, now superseded).

New non-overwriting child `front_containment/` contains:

- `red.log`: exit 1 before the width edit. Three front-grid failures, sixteen
  front-item failures (two identity installations), and three expected capacity
  failures. Identity Soda overhang was 20.545 mm; Book native/R90 overhang was
  0.289/16.982 mm. Scaled grid failed although sampled items were already inside.
- `green.log`: exit 0, `PASS: locker level2 calibration tests`, no assertions or
  script errors. Both X grid boundaries and front/rear item bounds now pass.
- `storage_stack_clearance.log`, `wing_storage_bridge_interaction.log`,
  `wing_gameplay_composition.log`, `wing_storage_debug_f6.log`: exit 0 and PASS.
- `default_smoke.log`, `main_smoke.log`: affected 90-frame headless launches exit 0.
- `capture_before.log`, `capture_after.log`: rendered real-F6 captures exit 0.

The regression uses the actual wing and legacy scenes, fingerprint-bound mesh
planes, `StorageVisualPose`, installed `StorageSurface` fits, the production
placement controller and `WorldItem` retrieval. Native/R90 Soda Cans cover both
ends of both front and rear rows; native/R90 Books cover front ends and rear
placement; auto reaches (0,0); extreme manual requests reach the nearest legal
edge. All samples retrieve/re-store with identity and canonical scale preserved.
All four locker levels get real placement loops and height/Z/capacity checks;
metal capacities/heights and locker fixture transforms are also checked.
Fits are selected at the controller boundary, not by a human mouse/raycast.

Known diagnostics remain: Windows root-certificate-store error throughout,
intentional MissingContextShelf warning in clearance tests, two intentional
duplicate-namespace errors in composition tests. No new script/assertion errors
occur in GREEN. No full baseline or 41-suite rerun was performed for this follow-up.

## Matched rendered evidence

Selected final comparison: `front_containment/before/` and
`front_containment/after/`, each with 1920×1080 `player_eye.png`,
`diagnostic_rear.png`, and `manifest.json`. These are copies of newly created
`before_04/` (0.94/0.005) and `after_03/` (0.89/0.005), respectively. The previous
`before_03/` versus `after_02/` still documents the earlier rear-only correction.

New matched helper SHA:
`62a5d16143bb9c110987b830d070f47c2b89d97ab13adea62fd3e4c247463152`.
Camera transforms/FOV, surface center, fixture, art and lighting match. The
ordinary camera uses Y=1.72 m, FOV 75°. The rear-oblique view is explicitly
diagnostic. Four actual Soda Cans use auto/native plus manual/native/R90 corner
placements with real F6 enabled. Inspection shows the narrowed level-2 grid and
corner placements drawn inward; numerical edge checks establish the clearances.
Manifests retain actual poses, origins, source/helper hashes and world scales.

From the project directory:

```powershell
$exe = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $exe --headless --path . --script res://tools/asset_pipeline/tests/locker_level2_calibration_tests.gd
& $exe --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/locker_level2_maintenance_capture.tscn -- --capture-m01 --phase=after
```

The capture remains inert without `--capture-m01`, requires an explicit phase,
chooses a fresh numbered directory, has a 45-second deadline, and exits after
capture. Samples are transient. Default launch, F6/F7 behavior, fourteen-host
setup, Fuel, Receiving, palette, art and accepted wing geometry are untouched.
