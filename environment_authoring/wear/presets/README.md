# Approved EAF4 preset coverage

11 eligible sources; 11 wrappers; 0 blocked. Derived from the current EAF4 catalog; this is an index, not another approval authority.

Run `python tools/environment_authoring/wear_catalog/build_presets.py --check` to audit mappings/dependencies and detect drift; omit `--check` for an explicit one-shot rebuild. Never runs in the editor.

Drag a `.tscn` into `WingGameplay/AuthoredWear/Receiving`, `Storage` or `OtherRooms`. Select the instance root. See [the practical guide](../../../docs/environment-authoring/eaf4-wear-authoring-guide.md). Floor-only wrappers face up (X = -90 degrees); wall and PLANAR_ANY wrappers start upright (+Z normal). Rotate PLANAR_ANY or dual-capability sources to the intended surface.

| Name / stable ID | Capabilities | Preset | Blocking reason |
| --- | --- | --- | --- |
| Chipped Paint Patch / `eaf4b_16c913a6a9cc1926bcc14833` | WALL | [chipped_paint_patch_ui2ncdjfw.tscn](chipped_paint_patch_ui2ncdjfw.tscn) | None |
| Concrete Crack / `eaf4b_c3b63b5da3fbdda32be47bd0` | PLANAR_ANY | [concrete_crack_sf2moag.tscn](concrete_crack_sf2moag.tscn) | None |
| Concrete Crack / `eaf4b_1215035d1f7cf36ee4b9f3eb` | PLANAR_ANY, WALL, CEILING | [concrete_crack_sfhmrfg.tscn](concrete_crack_sfhmrfg.tscn) | None |
| Concrete Damage / `eaf4b_5858bd2916c3227c201ec5a4` | PLANAR_ANY | [concrete_damage_sfcmkbg.tscn](concrete_damage_sfcmkbg.tscn) | None |
| Concrete Leakage / `eaf4b_cdded964c68d6777983af66f` | WALL, VERTICAL_PREFERRED | [concrete_leakage_tk3jej1c.tscn](concrete_leakage_tk3jej1c.tscn) | None |
| Damaged Concrete / `eaf4b_2faa4471206d5eaf048558bb` | PLANAR_ANY | [damaged_concrete_tbqmbayr.tscn](damaged_concrete_tbqmbayr.tscn) | None |
| Dust Uh4Qbeic / `eaf4b_7861a882827158cab9937196` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Dust Uh4Qbflc / `eaf4b_4ced1a3973d9ede63d7cde48` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Dust Uh4Rdfvc / `eaf4b_1258cd6455c7367fb02eb2fe` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Grain Sc2Nbisc / `eaf4b_cd6e17b97463ce00c0685bbd` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Grunge Tedwdiic / `eaf4b_88cbe4d6b460b401ee6d6d7b` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Grunge Tedxadjc / `eaf4b_c8b0a5126abd42ebe766fd44` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Grunge Tjnncdwc / `eaf4b_59ea0f6e18d6edba4035cf08` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Grunge Tjvibebc / `eaf4b_90ab5c8d3e788ad7f9300336` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Grunge Uh4Uaawc / `eaf4b_442aa42e72c622fa1f3af4b9` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Grungy Surface Slnnecvc / `eaf4b_3863efcbbda45860ab849694` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Industrial Abandonedfactory Wall Concrete Painted Xetubap / `eaf4b_dc44a10776bc702874712334` | WALL | — | DEFERRED |
| Leakage / `eaf4b_e890439d8e117d36ac05e55c` | WALL, VERTICAL_PREFERRED | [leakage_skiubhzc.tscn](leakage_skiubhzc.tscn) | None |
| Leakage Sl3Ace3C / `eaf4b_7fdb448b22a60aa6e146cfd7` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Leakage / `eaf4b_cd7701bd0cdb622c63628103` | WALL, VERTICAL_PREFERRED | [leakage_tculfbnc.tscn](leakage_tculfbnc.tscn) | None |
| Oil Stain / `eaf4b_16f72d4cb37ef4ee74a9073c` | FLOOR, HORIZONTAL_PREFERRED | [oil_stain_semlsbi.tscn](oil_stain_semlsbi.tscn) | None |
| Road Dust / `eaf4b_7efdf22029c82320d62147c7` | FLOOR, HORIZONTAL_PREFERRED | [road_dust_sgzh1so.tscn](road_dust_sgzh1so.tscn) | None |
| Rust Debris / `eaf4b_89c9cb7aa962b19eda21f278` | WALL, FLOOR | [rust_debris_ugxhbh0h.tscn](rust_debris_ugxhbh0h.tscn) | None |
| Scratched Metal Vdekebbc / `eaf4b_e1cf2067e3efcd02296f1f79` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Stains Ulttebjc / `eaf4b_59989972790f0d57a6e4fade` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Stains Ultwabqc / `eaf4b_2652b2a801b966c69a931213` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Stains Ultwaekc / `eaf4b_965ef296e00bba5e57459f76` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |
| Wipe Marks Uh4Scioc / `eaf4b_560a1a00053287b4aa7685e3` | PLANAR_ANY | — | Scalar source; use the separate scalar library, not a conventional wear preset |

## Approved usage restrictions

Approval establishes source quality, not universal placement. The Inspector also shows these catalog restrictions.

**Chipped Paint Patch (chipped_paint_patch_ui2ncdjfw)**: Approve as localized paint/finish damage, not damage to bare concrete. Use where an old painted/rendered institutional finish is historically plausible—paint bands, painted wall sections, repaired/overpainted areas or similar applied finish.

**Concrete Crack (concrete_crack_sf2moag)**: Good small branched crack. Prefer origins at corners, openings, structural joints, penetrations, impact points, or repair boundaries. Approval is for reusable source quality, not universal placement.

**Concrete Crack (concrete_crack_sfhmrfg)**: Strong long fracture. Clean silhouette and restrained source color. Place only where a plausible stress origin exists: opening/corner/junction/penetration/repair boundary/impact. Do not float arbitrarily in the middle of otherwise sound structure.

**Concrete Damage (concrete_damage_sfcmkbg)**: Strong compact concrete damage/spall source. Use sparsely as localized damage rather than baseline age. Prefer plausible impact, failed repair, opening/edge, or other local cause.

**Concrete Leakage (concrete_leakage_tk3jej1c)**: Deliberately narrow, low-amplitude vertical leak. Its subtlety is useful. Place directly beneath or behind a credible moisture source such as a pipe joint, penetration, fitting, vent, ceiling/service joint or similar infrastructure. Partial occlusion at the origin is preferable.

**Damaged Concrete (damaged_concrete_tbqmbayr)**: Broad broken-concrete source with useful depth language. Use only where impact, opening/edge condition, structural interruption, or failed repair justifies it. Avoid scattering across maintained active rooms.

**Leakage (leakage_skiubhzc)**: Strong broad mineral/water source. Normally begin behind/below a pipe, penetration, vent, ceiling/service joint, drain, fitting, or other plausible moisture source. Partial occlusion behind infrastructure is desirable.

**Leakage (leakage_tculfbnc)**: Useful smaller tapered leak/mineral mark. Place below a plausible service/moisture origin rather than freestanding on a wall.

**Oil Stain (oil_stain_semlsbi)**: Readable localized spill. Appropriate near machinery, maintenance points, containers, freight/service activity, or equipment. Avoid generic circulation placement.

**Road Dust (road_dust_sgzh1so)**: Sparse, subtle accumulation layer appropriate for an occupied/maintained bunker. Use along traffic paths, freight/cart turning areas, wall edges, thresholds or service accumulation zones; do not blanket floors uniformly.

**Rust Debris (rust_debris_ugxhbh0h)**: Sparse corrosion flecks. Use only with a nearby plausible corrosion source—fastener, bracket, pipe, plate, barrier, vent, rail or other metal fitting. Do not use as generic orange dirt.

0 current eligible material-patch sources. Material patches use the supported EnvironmentMaterialPatch EAF4_SOURCE path; never substituted as overlays. Any future patch approval also needs instance-control and wing-guard review. Unknown modes or missing/stale resources block generation explicitly. The current deferred and scalar-mask entries above remain excluded from conventional wear presets. Approved scalar sources use the [separate scalar library](../imperfection_experiments/README.md); placement acceptance remains separate.
