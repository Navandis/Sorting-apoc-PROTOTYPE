# EAF2 structural substrate authoring validation

- **Status:** IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW COMPLETE / PROMOTED
- **Branch:** `codex/eaf2-structural-substrate`
- **Implementation HEAD verified:** `ae721f2a5d9ff529cf15da4228eb8f93ccf23190`
- **Base:** clean `main` and `origin/main` at `caf7fe9dcc5df617364ad88f903cfd7a2d8cb419`.
- **Engine:** Godot 4.7 stable, Compatibility renderer (`gl_compatibility`). This branch was explicitly authorized for EAF2 implementation by the 26 September handoff; the earlier design-only wording on `main` predates that handoff.
- **Final disposition:** PROMOTE EAF2. Earlier pending review statements below are retained as historical evidence.

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

## Human review revision — narrow proof pass, 26 September 2026

- **Status remains:** IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW PENDING.
- **Review-proof source commit:** `d6bc91420ac9691257a23c11f6d98f7c044b89d4`.
- **Scope:** fixed cameras and the isolated review composition only. The substrate spec, registry, builder, all three recipes, seeds, EAF1 binding, UV, collision, fingerprint and UV2 paths were unchanged.
- The preceding five-capture section records the initial technical review snapshot. The six-capture matrix below supersedes it for current human review. Its PNGs, manifest and logs remain preserved under ignored `res://reports/environment_substrate/eaf2/initial_review_00abb54/`.

### Opening verification and visual proof

A direct scan of the generated `wall_opening_standard` mesh found the expected outer AABB **5.50 × 3.20 × 0.30 m**. Local opening X bounds are **-0.25 to +1.15 m** and Y bounds **-1.60 to +0.60 m**, leaving **2.50 m** of left pier, **1.60 m** of right pier and **1.00 m** of header. Front-face pier area below the header is **5.50 m² left** and **3.52 m² right**.

Each jamb has two triangles and **0.66 m²** of reveal area across the complete **2.20 m height × 0.30 m thickness**. The left jamb normal is **+X**, the right jamb normal is **-X**, both pointing into the opening; direct triangle winding agrees with those normals with **zero reversed triangles**. The opening geometry fingerprint is unchanged from the initial manifest: `7280dfac8b5e1015b17e3d7377086efd2ae7967683d96f19244740457c5b8a5f`. The apparent missing post was **camera ambiguity, not a mesh defect**. No opening recipe change or regression test was needed.

The current captures use opposite fixed obliques: `opening_detail_left_jamb.png` views the left reveal from camera X greater than the opening; `opening_detail_right_jamb.png` views the right reveal from camera X less than the opening. Together they show both physical piers and reveals. The direct scan output is in local `opening_mesh_inspection.log`.

### Composition placement and contact audit

The original scene had only a vertical edge touch between the walls at **X=3.90, Z=8.15 m**. Its column had a **0.09 m gap** to the front wall, the beam embedded only **0.075 m** into that wall while projecting **0.275 m**, and the threshold had a **0.225 m gap**. Those relationships caused the visual ambiguity.

The corrected world-axis AABBs below are in metres. The side wall is rotated 90° about Y; all five roots retain unit scale. Root centres (X,Y,Z) are front wall (2.30,1.60,8.00), side wall (4.05,1.60,9.45), column (3.78,1.60,8.27), beam (2.24,3.025,8.14) and threshold (2.30,0.04,8.375).

| Piece | X bounds | Y bounds | Z bounds |
| --- | --- | --- | --- |
| `composition_wall_front` | 0.70–3.90 | 0.00–3.20 | 7.85–8.15 |
| `composition_wall_side` | 3.90–4.20 | 0.00–3.20 | 7.85–11.05 |
| `composition_column` | 3.57–3.99 | 0.00–3.20 | 8.06–8.48 |
| `composition_beam` | 0.70–3.78 | 2.85–3.20 | 7.965–8.315 |
| `composition_threshold` | 1.60–3.00 | 0.00–0.08 | 8.15–8.60 |

| Pair | Classification | Measured relationship |
| --- | --- | --- |
| Front wall / side wall | **BUTT JOINT** | Their X faces meet at 3.90 m over the full 3.20 m height and 0.30 m wall thickness. |
| Front wall / column | **INTENTIONAL EMBEDMENT** | 0.09 m behind the front wall face; 0.33 m across the wall-end X region. |
| Side wall / column | **INTENTIONAL EMBEDMENT** | 0.09 m into the side wall's inner X face; column spans 0.42 m along that wall. |
| Front wall / beam | **INTENTIONAL EMBEDMENT** | The beam is an explicit projecting top member: 0.185 m in the wall, 0.165 m into the room, top flush at Y=3.20 m. |
| Column / beam | **INTENTIONAL EMBEDMENT** | Beam end terminates 0.21 m inside the column in X, with 0.255 m Z overlap. |
| Front wall / threshold | **BUTT JOINT** | Threshold back meets the wall front at Z=8.15 m, with no gap or wall penetration. |
| Side wall / beam | **GAP** | 0.12 m in X; the beam deliberately terminates in the intervening column. |
| Side wall / threshold | **GAP** | 0.90 m in X; threshold is a separate wall-base example, away from the corner. |
| Column / threshold | **GAP** | 0.57 m in X; threshold does not collide with the corner column. |
| Beam / threshold | **GAP** | 2.77 m in Y; beam and threshold serve top and base roles. |

The column now projects into the inside corner while embedding **0.09 m into each wall face**, so its relationship to both solids is deliberate. The beam uses the requested projecting-member option and ends inside the column, without an unexplained free end or shallow sliver against the wall. The threshold is flush against the front wall and deliberately separate from the corner. All remain ordinary generated `rect_solid` pieces; no corner recipe was added.

### Revised capture and verification

The current formal matrix is **six** fixed neutral-light captures: `seed_overview.png`, `dimension_uv_comparison.png`, `opening_detail_left_jamb.png`, `opening_detail_right_jamb.png`, `composition.png` and `extensibility_proof.png`. Run the same capture command above to regenerate them in ignored `res://reports/environment_substrate/eaf2/`. The current manifest has **six records and 17 pieces**, all 17 at unit root scale, under the Compatibility renderer.

The requested focused tests ran with **65 PASS, 0 FAIL, exit 0**; headless editor parse/import and rendered capture each exited **0**. The direct opening mesh scan exited **0**. Final test, editor and capture logs contain no `SCRIPT ERROR` or `FAIL:`; the host root-certificate warning persists without affecting them. The current six images were inspected after rendering. Human disposition remains **PROMOTE EAF2 / REVISE EAF2**; this technical revision does not promote the milestone.

## Final human review and promotion — 26 September 2026

The initial geometry, material binding, UV1, collision, UV2 seam, seed and extensibility implementation was technically verified. The bounded review-proof revision then completed direct mesh inspection, which proved that both opening jambs existed with correct winding and inward-facing normals. Opposing fixed captures made both reveals visually verifiable. The 90° wall, corner column, beam and threshold contacts were measured, corrected and classified above. Human re-review found the three identified visual-proof concerns addressed and approved EAF2 in its designed structural-substrate scope.

EAF2 now establishes project-standard authoring with exact metre dimensions, generated geometry rather than node-scale fitting, unit root scale, physical structural thickness, deterministic normals and tangents, metre-authored UV1 compatible with EAF1 metres per repeat, optional UV quarter-turn and phase, bounded bevels for exposed edges, EAF1 material binding, optional NONE/SIMPLE collision, deterministic generation fingerprints, a native Godot UV2/lightmap unwrap seam, and a recipe registry, seed presets and incremental extension workflow. The promoted recipes are `rect_solid`, `wall_with_rect_opening` and `wall_with_two_rect_openings`.

The two-opening recipe demonstrates a new topology added through the established workflow with consistent mapping and material behavior and no core rewrite. EAF2's non-exhaustive closure condition is satisfied: the grammar, process, useful seed collection, deterministic validation and cheap incremental extension have been proven. The seed collection is a reusable starting set, not an exhaustive catalog. Later rooms should inspect accepted geometry, reuse recipes and presets, identify genuinely missing topology, extend and validate through this process, and add reusable results to the collection. A later missing shape does not reopen EAF2.

Blender remains an available escalation path but was unnecessary here. Native Godot UV2 unwrap is a proven seam, not a LightmapGI adoption. This promotion does not approve a finished Receiving room or final environment materials. Receiving Stage C1 remains paused; the next active gate is EAF3 — External Material Ingestion + Curated Catalog DESIGN, with implementation not yet authorized.

Final feature-state close-out verification repeated the focused tests (**65 PASS / 0 FAIL**), headless editor import (**exit 0**) and six-camera capture (**exit 0**). The manifest records **17/17 unit root scales** and **17/17 SHA-256 geometry fingerprints** under `gl_compatibility`; the three new logs have no `SCRIPT ERROR` or `FAIL:` markers.

FINAL HUMAN DISPOSITION: PROMOTE EAF2
