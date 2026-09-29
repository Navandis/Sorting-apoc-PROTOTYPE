# EAF5 Pass 6B — bounded applied-finish layout validation

**Status: EAF5 PASS 6B — HUMAN FINISH-LAYOUT REVIEW COMPLETE.**

## Authority and branch

Authoritative checkout: `D:\Godot Projects\Sorting-apoc-PROTOTYPE`, branch `codex/eaf5-receiving-proof`. Pass 6B started at HEAD `004377070132558a8409142d10de98f97b9bb312`; main and origin/main remained `ac12a51ce431f94c9a65a4e84edbf2f73bdf5c2c`. The owner-system correction was locally committed as `5b33ef7` (`fix: preserve physical scale on EAF3 material patches`). No merge or push was performed. This is the requested existing checkout, not a linked worktree.

Pass 6A decisions: `data/environment/receiving_proof/decisions/eaf5_applied_finish_screen_01_human_review_01.json`. The preserved Pass 6A ZIP SHA-256 is `e8bfa330e836687b2fe869a938bf7ed3181ca1a0f076d0d531a32293e6bda66b`. Six controls remain `CONTROL_NO_FINISH`; the 30 finish variants are 4 KEEP, 7 HOLD and 19 DROP. NO_FINISH remains a fully competitive final direction. S02/S03/S04 remain valid structural finalists but do not participate in this layout screen.

Accepted shell composition: `data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json`, SHA-256 `8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d`. All 14 geometry fingerprints, structural UV phase, structural materials, lights, WorldEnvironment and review-only context match prior evidence.

## EAF4 owner-system material-patch correction

`environment_authoring/wear/environment_material_patch.gd` previously sized a `QuadMesh` for EAF3 materials but retained UV span 1×1 at every physical size. A failing Godot test measured UV 1×1 on 1.5×1.5, 3.0×1.5 and 4.2×2.4 m patches. `EnvironmentMaterialBuilder` scales metre-authored UVs by `1 / meters_per_repeat`, so the old result changed the apparent source size with patch dimensions.

EAF3 mode now generates a planar `ArrayMesh` with physical vertices and UV spans in metres. The same three cases now measure their requested physical and UV extents, with root scale `Vector3.ONE`, shadow casting off and `surface_offset_m` preserved. The material still comes from the EAF3 catalog query and `EnvironmentMaterialBuilder`. Godot front winding was matched to the existing `QuadMesh`; the regression test checks it. EAF4_SOURCE still uses its original normalized-UV `QuadMesh`, wear-spec size and offset. No EAF5 patch class, shader, bake path or EAF4 wear composition was added.

The visible A01 source is approved at 1.5 m per repeat. The expected horizontal repeat counts are 2.8 across L01's 4.2 m and 1.2 across L02's 1.8 m; vertical counts are 1.6 and 0.8. The two rendered technical images in `applied_finish_layouts_01/scale_sanity` show the patch at both sizes, and their manifest records the mesh extents and computed repeats. The first render exposed incorrect triangle winding even though its mesh scale was correct; after the owner correction, the patches rendered on the occupied face with stable edges. The 20-image artistic gate was not started until this passed.

## Fixed layouts and matrix

ReceivingSouth is 10.5 m wide at occupied-face Z=4.85 m; the visible floor-to-ceiling wall range is Y=0.0–4.2 m. Patch roots face into occupied Receiving (negative Z) and use offset 0.002 m and unit scale.

| Layout | Physical size | World center on wall | Wall-local X offset | Visible substrate margins |
| --- | --- | --- | --- | --- |
| L00_NO_FINISH | none | none | none | whole structural wall |
| L01_INHERITED_FIELD | 4.20 × 2.40 m | (5.10, 2.10, 4.85) m | 0.00 m | left/right 3.15 m; above/below 0.90 m |
| L02_LOCAL_PATCH | 1.80 × 1.20 m | (3.10, 1.55, 4.85) m | −2.00 m | left 2.35 m; right 6.35 m; above 2.05 m; below 0.95 m |

The 13 configurations are `S01_L00`, `S05_L00`, `S06_L00`; `V01_L01`, `V01_L02`, `V02_L01`, `V02_L02`, `V03_L01`, `V03_L02`, `V04_L01`, `V04_L02`; `Q01_L02`, `Q02_L02`. These are three no-finish controls and ten pending finish/layout variants. V01=S01_A01, V02=S05_A04, V03=S06_A01, V04=S06_A05. Q01=S01_A02 and Q02=S01_A03 appear only at L02. No other HOLD variant advances. Exactly one configuration, Q01, uses a transient UV clone of the A02 triplanar-approved spec; approved texture references, fingerprint and PBR parameters are unchanged. All effective finish review mapping is UV.

The patch is an `EnvironmentMaterialPatch` in `EAF3_MATERIAL` mode, under the proof-only `FinishPatches` node. ReceivingSouth's structural material remains beneath it. The other 13 shell pieces, structural role settings and review context retain their existing materials. No EAF4_SOURCE patch, EnvironmentWearOverlay, wear catalog entry, structural-secondary material or imperfection mask is instantiated.

## Cameras and evidence

EastApproachOverview is unchanged: origin (8.0, 2.5, 3.5) m, 75° FOV, aimed at (0.0, 1.8, 0.0) m. FinishField is unchanged: origin (5.25, 2.10, 0.0) m, 65° FOV, aimed at (5.25, 2.10, 5.0) m. FinishPatch is fixed for every L02 capture: origin (3.10, 1.55, 2.30) m, 65° FOV, aimed at (3.10, 1.55, 5.0) m. The latter has basis X approximately (−1,0,0), Y (0,1,0), Z (0,0,−1); the manifest records full-precision transforms and FOVs. Both `NEUTRAL_ARCHITECTURAL` and `RECEIVING_TARGET` rigs use their prior transforms, energies, colors and shadow settings.

The artistic gate rendered five configurations × four views = 20 images: S01_L00, V01_L01, V01_L02, Q01_L02 and Q02_L02. All four S01_L00 images are pixel identical to Pass 6A S01_A00. Visual inspection found the patch confined to ReceivingSouth, stable edges with no z-fighting, exposed structural substrate, no visible material leak, and the unchanged accepted shell. A02's full-wall repetition is reduced at the small patch; A03's trowel/patch motif is readable. These observations authorize capture, not a final artistic winner. Both rigs remain visible in the evidence.

The final folder `reports/environment_receiving_proof/eaf5/applied_finish_layouts_01/` contains 13 configurations × four views = **52 PNGs** plus manifest, summary, decision template and three contact sheets. Contact sheet 1 groups S01_L00/V01_L01/V01_L02/Q01_L02/Q02_L02; sheet 2 groups S05_L00/V02_L01/V02_L02; sheet 3 groups S06_L00/V03_L01/V03_L02/V04_L01/V04_L02. Each row labels palette, finish, layout and physical size and shows Neutral Overall, Receiving Overall, Neutral Detail and Receiving Detail. The template holds three `CONTROL_NO_FINISH` entries and ten `PENDING` entries, with only KEEP_LAYOUT_VARIANT, HOLD_LAYOUT_VARIANT and DROP_LAYOUT_VARIANT available for human choice. No automated score or rank is supplied.

Review ZIP: `reports/environment_receiving_proof/eaf5/eaf5_applied_finish_layout_review_01.zip`. SHA-256: `0c261c0a144f4b51068fe7aebb4ab951f74d39e4ff5d0dce77ca8390bba36406`. ZIP CRC and exact 58-file allowlist passed: 52 captures, three contact sheets, `manifest.json`, `summary.md` and `decision_template.json`. It excludes commercial maps, import sidecars, caches and the technical/sanity subfolders.

## Verification and production protection

- EAF5 Python suite: 44 passed, including the new Pass 6B matrix, control pixel equality, package integrity and Pass 6A hash.
- EAF3B Python catalog suite: 17 passed. EAF3B Godot query and live catalog suites: zero failures.
- EAF4B Python workflow suite: 12 passed. Godot EAF4B overlay/material-patch, human-catalog and rerun suites pass; the new material-patch scale/winding test has zero failures and confirms EAF4_SOURCE normalized UV.
- Godot EAF5 proof, capture and new layout suites: zero failures each.
- Godot 4.7 headless editor import/parse: exit 0. The recurring Windows certificate-store warning did not fail any suite.
- Accepted composition hash and all 14 fingerprints match Pass 6A. No protected production wing or Receiving path changed. EAF2 source and code remained unchanged.

Human review should compare each variant directly against its same-structure no-finish control and decide whether a credible bounded Layer-2 finish improves the room. EAF4 wear must not be assumed to hide a bad finish boundary or repeated texture. At this earlier technical gate no finish-layout winner had yet been selected; the final human disposition is recorded below. Receiving C1 remains paused.

## Final human finish-layout disposition

The human review of the 13-configuration package is recorded in data/environment/receiving_proof/decisions/eaf5_applied_finish_layouts_01_human_review_01.json: 0 KEEP_LAYOUT_VARIANT, 5 HOLD_LAYOUT_VARIANT, 5 DROP_LAYOUT_VARIANT, and 3 CONTROL_NO_FINISH. Receiving's base applied-finish direction is **NO_FINISH**. The L02 HOLD patches are optional reserves only if a later production condition provides a genuine cause; none enters Pass 7. The EAF4 material-patch physical-scale and winding correction evidence above remains valid. No EAF3 approval changed.

**EAF5 PASS 6B — HUMAN FINISH-LAYOUT REVIEW COMPLETE. BASE APPLIED-FINISH DIRECTION — NO_FINISH.**
