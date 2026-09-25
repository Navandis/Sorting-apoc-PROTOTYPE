# EAF1 material and lighting lookdev validation

- **Status:** IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING
- **Branch:** `codex/eaf1-material-lighting-lookdev`
- **Implementation HEAD at validation:** `2b53a7355bddecd0ae6e3c52865cc98308f43f17`
- **Base:** local `main` `aa8d167f9f730546f6f8a5600712170fe2aed94a` (its docs-only transition commit was preserved).
- **Engine:** Godot 4.7 stable, Compatibility renderer (`gl_compatibility`). No renderer migration or production scene edits.

## What to review

- Interactive scene: `res://gameplay/dev/environment_lookdev/environment_material_lookdev.tscn`. Run the scene and use **L** for lighting, **N** or **]** for next material, **P** or **[** for previous, **C** for next camera, and **R** or **Home** for canonical reset (first material, Neutral, Hero). The HUD names the selected material, mode, camera, mapping, physical scale, and normal-Y state.
- Material contract and builder: `res://environment_authoring/environment_surface_material_spec.gd`, `res://environment_authoring/environment_material_builder.gd`, and `res://environment_authoring/environment_material_review_set.gd`.
- Ordered set: `res://data/environment/lookdev/eaf1_review_set.tres` and four referenced `.tres` specs.
- Capture scene: `res://gameplay/dev/environment_lookdev/environment_material_lookdev_capture.tscn`.

The review scene builds fixed tooling geometry: a 4.8 m floor, two 3 m walls at 90 degrees, a partial ceiling, column, approximately 1 m beveled block, one beam and partial return for shadows, three fixed value spheres, and a one-metre ruler. The same native `StandardMaterial3D` instance is applied across the six review surfaces. Reference objects and shadow structure keep fixed materials. This geometry is not EAF2 production substrate.

## Source material fixture

Archive: `D:/AssetPipeline/From KitBash/kb3d_americanneighborhoods.zip`, package `kb3d_americanneighborhoods/7.0.0`. Inspection found `Textures/png1k` and `Textures/exr1k`, with **no 2K variant**. Only the twelve PNGs listed below were copied to the ignored local directory `res://assets/environment/lookdev/kitbash_american_neighborhoods_1k/`; no commercial source texture bytes are tracked. Each copied PNG is **1024 × 1024**. All three source sets offer `basecolor`, `normal`, `roughness`, and `metallic` PNGs, plus a corresponding 1K EXR `height` source. No AO PNG was present. EXR heights were not copied or connected to runtime displacement.

The archive prefix for every source PNG below is `kb3d_americanneighborhoods/7.0.0/Textures/png1k/`; the project copy uses the same filename under the local directory above. Each row lists the actual four map filenames by combining its stem with `_basecolor.png`, `_normal.png`, `_roughness.png`, and `_metallic.png`.

| Source material stem | Mapping | Metres per repeat | Review purpose |
| --- | --- | ---: | --- |
| `KB3D_AMN_COBareSmoothWhiteConcrete` | TRIPLANAR | 2.00 | Light/smooth concrete response and bright-value calibration |
| `KB3D_AMN_COConcreteSidewalk` | UV | 1.50 | More patterned/rough concrete, seam and orientation stress |
| `KB3D_AMN_MTWornMetalTrim` | WORLD_TRIPLANAR | 0.75 | Metallic data and directional repeat stress |

The fourth spec, `diagnostic_sidewalk_wrong_normal_y`, reuses the Sidewalk files, UV mapping, and 1.50 m repeat, but deliberately flips the normal green channel. It is marked **DIAGNOSTIC / NOT A CANDIDATE** in the HUD and resource. Comparing its Neutral/WallGrazing image with the correct Sidewalk image makes reversed relief visible. None of these KitBash fixtures is approved final bunker material or art direction.

### Material and import seam

`meters_per_repeat` is the authoring unit. Review mesh UV coordinates are authored in metres; the builder sets `uv1_scale = Vector3.ONE / meters_per_repeat`. Local and world triplanar coordinates are also in metres, so the same reciprocal conversion applies. A 0.50 m repeat therefore yields a scale of 2.0. The one-metre ruler gives an in-scene check.

Godot 4.7's `StandardMaterial3D` exposes normal strength, UV/triplanar modes, and the PBR channel slots, but no per-material normal-green inversion property. The local PNG import record exposes `process/normal_map_invert_y=false`, which would affect all specs using that source. The builder therefore duplicates the imported normal `Image` in memory, inverts green, generates mipmaps for that transient copy, and binds the resulting `ImageTexture` only when a spec requests `normal_y_flip`. Source PNG bytes and the loaded source image stay unchanged; the focused test checks both. The twelve ignored local `.png.import` records were set to `mipmaps/generate=true` for grazing captures; a fresh local staging of these archive files should use that same import setting. Those import records remain under ignored `assets/`. `height_texture` is reference-only and `heightmap_enabled` remains false.

## Locked comparison setup

One `WorldEnvironment` is shared by both modes: background RGB `(0.052, 0.056, 0.060)`, ambient RGB `(0.74, 0.75, 0.76)` at energy `0.16`, Filmic tonemap, exposure `1.0`. These values and the Compatibility renderer do not change on toggle. Capture manifests retain the actual environment and per-record state.

| Rig | Light | RGB | Energy | Range / angle | Shadow |
| --- | --- | --- | ---: | --- | --- |
| Neutral | WhiteKey, spot | (1, 1, 1) | 1.55 | 8 m / 53° | on |
| Neutral | WhiteFill, omni | (1, 1, 1) | 0.55 | 5 m | off |
| Neutral | WhiteGraze, spot | (1, 1, 1) | 0.65 | 6.5 m / 42° | on |
| Receiving | WarmPracticalKey, spot | (1, .83, .70) | 2.10 | 6 m / 47° | on |
| Receiving | WarmSidePool, omni | (1, .86, .75) | 0.65 | 4 m | on |
| Receiving | NeutralWarmSupport, spot | (1, .92, .85) | 0.70 | 6 m / 48° | on |

These are provisional lookdev settings. The two supplied atmosphere images informed **lighting character only**: localized warm-neutral pools, directional shadows, darker ceiling/corners, and an inhabited industrial-service mood at a brighter and less amber level. Their geometry, furnishings, clutter, pipes, and room composition were not copied.

| Camera | Position (m) | Target (m) | FOV |
| --- | --- | --- | ---: |
| Hero | `(4.9, 3.22, 4.95)` | `(-0.2, 1.38, -0.44)` | 53° |
| WallGrazing | `(1.95, 1.62, 1.85)` | `(-0.84, 1.52, -2.32)` | 51° |
| FloorGrazing | `(0.55, 0.68, 2.26)` | `(-0.10, 0.16, -1.40)` | 55° |
| Context | `(7.0, 5.1, 6.8)` | `(0, 1.2, -0.45)` | 58° |

The manifest stores full camera basis, origin, and FOV, plus each active light's position, direction, color, energy, range/angle, and shadow state for every formal capture. Neutral and Receiving pairs were checked across all eight material/camera pairs: identical camera transform/FOV, mapping mode, and physical scale. Focused scene tests also check material identity, geometry transforms, shared environment, one active rig, reversibility, navigation order, and reset.

## Deterministic capture and technical results

Run from the project root in PowerShell:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $godot --headless --path . --script res://tools/asset_pipeline/tests/environment_material_lookdev_tests.gd
& $godot --headless --editor --path . --quit
& $godot --path . res://gameplay/dev/environment_lookdev/environment_material_lookdev_capture.tscn -- --capture
```

Output: ignored `res://reports/environment_lookdev/eaf1/` with 16 unique **1920 × 1080** PNGs and `manifest.json`. For each ordered spec the matrix is Neutral/Hero, Neutral/WallGrazing, Receiving/Hero, Receiving/WallGrazing. Filenames follow `<material_id>__<neutral|receiving>__<hero|grazing>.png`.

Focused tests: **0 failures, exit 0**. Headless editor import/parse: **exit 0**. Rendered capture: **16 records, exit 0**, renderer `gl_compatibility`; manifest parsed and all eight Neutral/Receiving camera pairs matched. No `SCRIPT ERROR` or `FAIL:` appeared in the final verification runs. Godot emitted a host root-certificate-store warning on startup; it did not affect scene, tests, or capture.

## Human review gate

**Neutral Calibration:** judge light concrete without clipping; roughness and normal response; physical scale and repetition; UV seam/orientation; coherence across wall, floor, ceiling, column, and beveled edge. Compare the Sidewalk normal-Y diagnostic with its correct source case.

**Receiving Target Preview:** judge whether the result is near the intended approximately 80% reference warmth/tone, brighter and less amber; localized practical pools; darker ceiling/corners; useful cast shadows; and continued material/gameplay readability. Do not judge the tooling box as a proposed Receiving room.

**Method:** hold material and camera fixed, toggle only **L**, then compare the paired capture files. Confirm the scene speeds future material decisions and that its 1 m scale is readily understood.

Human disposition remains **PROMOTE EAF1 / REVISE EAF1**. No EAF2 work, Receiving C1 implementation, merge, or push was performed.
