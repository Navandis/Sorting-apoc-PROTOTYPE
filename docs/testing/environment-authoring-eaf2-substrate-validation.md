# EAF2 structural substrate authoring validation

- **Status:** IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING
- **Branch:** `codex/eaf2-structural-substrate`
- **Implementation HEAD verified:** `ae721f2a5d9ff529cf15da4228eb8f93ccf23190`
- **Base:** clean `main` and `origin/main` at `caf7fe9dcc5df617364ad88f903cfd7a2d8cb419`.
- **Engine:** Godot 4.7 stable, Compatibility renderer (`gl_compatibility`). This branch was explicitly authorized for EAF2 implementation by the 26 September handoff; the earlier design-only wording on `main` predates that handoff.
- **Disposition for human:** PROMOTE EAF2 / REVISE EAF2.

## Authoring contract

The resource `EnvironmentSubstratePieceSpec` stores the piece ID, recipe, semantic role, exact dimensions in metres, optional bevel, UV quarter turns and origin in metres, collision policy, EAF1 material spec, generation revision, recipe-specific opening dimensions, and authoring notes. Validation rejects missing IDs/roles, unknown recipes, nonfinite or nonpositive dimensions, invalid bevels, UV orientation/phase errors, invalid collision policy, invalid opening bounds or overlap, and invalid material bindings.

The registry exposes each recipe's purpose, canonical axes, parameters, limitations and revision. All recipes use **X = width, Y = height, Z = depth/thickness**, with **+Z as wall Front**. The predictable pivot is the centre of the full outer AABB; placements use translation and rotation. Generated nodes must remain at `Vector3.ONE` scale. The wrapper's `validate_authoring()` rejects nonunit scale, and `regenerate()` refuses to build it. The `@tool` wrapper has an explicit **Regenerate Substrate** inspector button and stores generation metadata on the node. The dev review scene creates its isolated examples on launch; no production runtime construction system or wing migration is included.

| Recipe | Purpose | Revision |
| --- | --- | ---: |
| `rect_solid` | Closed six-face rectangular solid; straight wall, floor, ceiling, beam, column, threshold, ledge and simple return share this recipe. | 1 |
| `wall_with_rect_opening` | One thick wall with front/back faces, jambs, header reveal and optional sill reveal. | 1 |
| `wall_with_two_rect_openings` | Extension proof: continuous thick wall with two separated openings and independent sill heights. | 1 |

The builder uses Godot `SurfaceTool` and `ArrayMesh`. Flat outward normals and tangents are generated for each face; the rounded edge bevel is deterministic and preserves the requested outer AABB. Ordinary modular walls/slabs use a square edge. For exposed pieces, the optional bevel is limited to the smaller of **0.10 m** and **one quarter of the smallest dimension**; a bevel that would collapse the solid is also rejected. Opening walls do not support bevel in this revision. No room-edge exposure solver is implied.

The UV1 contract is physical metres **before** EAF1 `meters_per_repeat` scaling: front/back `U=X, V=Y`; left/right `U=Z, V=Y`; top/bottom `U=X, V=Z`. `uv_quarter_turns` rotates this coordinate pair in 90° steps and `uv_origin_m` shifts its phase. The same tracked EAF1 diagnostic material, with **1.0 m per repeat**, is applied to the 2.00 m and 7.35 m comparison walls. Tests measure respective 2.00 and 7.35 UV-unit spans, and the capture shows identical grid density. UV, local triplanar and world triplanar all bind through the existing `EnvironmentMaterialBuilder`. The grid SVG marks repeat borders and +U/+V axes; it is technical evidence, not a bunker palette choice.

The collision seam is optional. `NONE` creates no shapes. `SIMPLE` uses one `BoxShape3D` for a rectangular solid; wall openings use separate boxes for left/right piers, header and optional sill. The two-opening wall decomposes its continuous structural regions into the same simple boxes. No production collision migration occurs.

The builder metadata records piece ID, recipe/revision, generator and generation revision, exact parameters, semantic role, UV turns/origin, collision policy, material path, notes and SHA-256 geometry fingerprint. The fingerprint includes validated recipe parameters and ordered mesh vertex, normal, UV and index data; the same input reproduces it, while changed dimensions or UV parameters change it. This is a Godot-local reproducibility fingerprint, not a cross-engine binary mesh format.

## Seed set and extension proof

The eight common seeds are `wall_standard`, `floor_slab`, `ceiling_slab`, `beam_standard`, `column_standard`, `threshold_standard`, `opening_return_standard` and `wall_opening_standard` under `res://data/environment/substrate/seed/`. They are examples, not a catalog of fixed wall lengths. A ninth resource, `wall_two_openings_extension`, exercises the extension recipe.

A continuous wall with a doorway and a separate elevated service opening cannot be represented by the original one-opening recipe. Composing independent solids would introduce authored joins around the central pier and two openings. The extension adds typed second-opening width, height, X offset and bottom/sill parameters. It reuses the spec validation, registry discovery, the builder's metre-grid wall meshing, EAF1 material binding, unit-scale node, collision decomposition, fingerprint, tests and capture scene. No alternative authoring pipeline was introduced. The extension is a reusable topology; it does not prescribe a final Receiving C1 location.

Blender preflight resolved **`D:\Blender\blender.exe`**. Blender remains available as an escalation path and **was not used**. Godot-native geometry and UV2 generation covered this scope without an export pipeline.

## UV2 / lightmap seam

For one simple `rect_solid` of **2.0 × 3.0 × 0.30 m**, the focused test calls `ArrayMesh.lightmap_unwrap(Transform3D.IDENTITY, 0.05)`. Godot 4.7 returns `OK`; the resulting `Mesh.ARRAY_TEX_UV2` spans both axes, each UV2 triangle has nonzero area, and UV1 retains its physical 2.0 × 3.0 m front-face span. The unwrap may reorder vertices, so UV1 is checked by face span rather than array index. This is the reproducible native route documented in the [Godot 4.7 ArrayMesh reference](https://docs.godotengine.org/en/4.7/classes/class_arraymesh.html#class-arraymesh-method-lightmap-unwrap). It proves a viable seam for one piece only. There is no LightmapGI bake or general UV2 requirement for every seed.

## Technical verification and capture

Run from the project root:

```powershell
$godot = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
& $godot --headless --path . --script res://tools/asset_pipeline/tests/environment_substrate_authoring_tests.gd
& $godot --headless --editor --path . --quit
& $godot --path . res://gameplay/dev/environment_substrate/environment_substrate_review_capture.tscn -- --capture
```

Focused tests: **65 PASS, 0 FAIL, exit 0**. They cover spec validation, registry, exact AABBs, closed geometry, finite nondegenerate triangles, outward normals/tangents, bevel bounds and closure, asymmetric opening/reveals, SIMPLE/NONE collision descriptors, UV spans/turns/origin, fingerprint determinism, EAF1 mapping modes, unit-scale wrapper validation, UV2 generation and all eight common seeds. Headless editor parse/import: **exit 0**. Rendered capture: **exit 0**, five PNGs, 17 generated pieces, one manifest, Compatibility renderer. The manifest was parsed: **17/17 root scales are (1,1,1)** and **17/17 fingerprints are present**. Final logs contain no `SCRIPT ERROR` or `FAIL:`. Godot emitted its existing host root-certificate-store warning; it did not interrupt tests, editor import or capture. EAF1 files were untouched, so the EAF1 suite was not rerun.

The fixed-camera, neutral-light capture command writes to ignored local `res://reports/environment_substrate/eaf2/`:

- `seed_overview.png`
- `dimension_uv_comparison.png`
- `opening_detail.png`
- `composition.png`
- `extensibility_proof.png`
- `manifest.json` with camera transforms/FOV, renderer/environment, piece transforms, exact specs and fingerprints

The same directory contains `focused_tests.log`, `editor_import.log` and `capture.log`. This local generated evidence is not Git backup. The review scene is `res://gameplay/dev/environment_substrate/environment_substrate_review.tscn`; press **C** to cycle the five fixed views and **R** to reset. Targeted views hide unrelated pieces, while the overview shows the whole seed demonstration.

## Human review checklist

- **Structural authoring:** inspect exact dimensions and centred pivots, root scale 1, real wall/slab thickness, asymmetric opening reveals, and the 90° composition's predictable placement.
- **Mapping:** compare the 2.00 m and 7.35 m walls under one 1 m grid; confirm the same density and understandable +U/+V phase. Check front, side and overhead surfaces; switch a seed material spec to EAF1 triplanar only if desired for manual inspection.
- **Edges:** check that exposed beam/column bevels soften the read without suggesting grooves at ordinary wall seams.
- **Workflow:** inspect the spec, registry, seed resources and wrapper inspector button; judge whether common pieces can be authored from exact dimensions without hunting for prefab lengths.
- **Extensibility:** inspect the two-opening wall's continuous center pier and independently raised sill; verify that its resource, tests and capture follow the original workflow.

**Human disposition pending: PROMOTE EAF2 / REVISE EAF2.** No EAF3 work, Receiving C1 restart, GDD/VDD/Findings update, merge or push is part of this branch.
