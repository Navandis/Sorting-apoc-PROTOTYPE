# EAF5 Pass 3 — Receiving shell and role isolation validation

**Current status: EAF5 PASS 3 SHELL ACCEPTED / HUMAN ROLE-ISOLATION REVIEW PENDING.** The accepted Pass-3A v2 shell is the authority for the Pass-3B role packages below. No role survivor decision has been made.

**Historical Pass 3 v1 status:** EAF5 PASS 3 IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN SHELL + ROLE REVIEW PENDING. Shell acceptance was the first human gate; the v1 role captures are not promotion evidence.

- Branch: `codex/eaf5-receiving-proof`; pre-edit HEAD `718ca191bbe8ec0d754b53b5c466e97e334dd6b7`; promoted `main` / `origin/main` baseline `ac12a51ce431f94c9a65a4e84edbf2f73bdf5c2c`. Pre-edit tree was clean. The final local commit HEAD is reported in the task handoff. No merge or push.
- Isolated proof scene: `gameplay/dev/environment_receiving_proof/environment_receiving_proof.tscn`; capture scene: `gameplay/dev/environment_receiving_proof/environment_receiving_proof_capture.tscn`. Neither is referenced by the production wing.
- Accepted layout authority: `data/environment/receiving_proof/eaf5_receiving_shell_source.json`; source SHA-256 `12cf8f93024e833f5c16932a1d963b3986258a7661cff3e246a2db525d4d4fc9`. The tracked `substrate/*.tres` files are ordinary EAF2 `EnvironmentSubstratePieceSpec` resources generated from that manifest by `build_pass3_specs.py`.

## Shell geometry and UV

- 19 generated pieces through `EnvironmentSubstratePiece.regenerate()` and `EnvironmentSubstrateBuilder`: 18 `rect_solid`, one `wall_with_rect_opening`; no EAF5 mesh recipe. All 19 specs validate, roots are unit scale, collision is NONE, bevel is zero, and each has a 64-character deterministic geometry fingerprint.
- Main apron: 10.50 × 10.00 m, 4.20 m clear height, 0.30 m structural thickness. Freight enclosure: 5.00 × 7.00 m, 4.20 m clear height. Apertures: west freight 5.00 m full height; east Backlog 3.84 × 3.40 m with 0.80 m header; Dispatch 2.40 m full height.
- Automated audit compared all EAF2 dimensions, positions, recipes, opening parameters, unit roots, fingerprints and UV metadata against the accepted mapping. It checked apron/freight floor and ceiling AABBs, 11 intended contact pairs, the two explicit 0.15 m freight joins, absence of duplicate coplanar wall ownership and overlapping slabs. Result: zero errors.
- UV1 is metre-authored by EAF2. Each spec sets `uv_origin_m` from its accepted world-space lower edge so coplanar runs preserve metre-space phase; `uv_quarter_turns=0` keeps an upright wall orientation. The east one-piece opening uses EAF2 reveal UVs. The shell audit compares each actual phase to the manifest-derived policy.

| EAF2 piece | Geometry fingerprint |
| --- | --- |
| `Ceiling_DispatchAnnex` | `1dd56534d4c65845adb96b497ff0e0240f565e040c92eb162f6f5597d326d4b4` |
| `Ceiling_FreightEnclosure` | `3202a42d8f718e5baae95342835a601576c581bef708627dbdbc6e154e75f057` |
| `Ceiling_ReceivingApron` | `3dd29e69ad1f5e388f274929d426322768d1ff4d82277818ec5cafb2fd5ad983` |
| `DispatchEast` | `b354b08d7a2877a5115ac8d2d215db89e4a27e10e838c0fecf450e7337ccdacf` |
| `DispatchNorth` | `bd0e187f4e08e7fb60c2a055427af050250ad22dab2d2ce238f416a220a45496` |
| `DispatchSouthEast` | `fc41bf1032e36de45c66d1df481bffa2fa8f689ab8624ff5f26103f875ae8c84` |
| `DispatchSouthWest` | `78c5d446a51d9e5df62d20f6badf5cb4652ea6e808b742031594fbaad9ac91a1` |
| `DispatchWest` | `c5fb2b0e868dd9d7bf800883055d9bfc01f2151da1466f673b8d22c9507c26bb` |
| `Floor_DispatchAnnex` | `1dd56534d4c65845adb96b497ff0e0240f565e040c92eb162f6f5597d326d4b4` |
| `Floor_FreightEnclosure` | `3202a42d8f718e5baae95342835a601576c581bef708627dbdbc6e154e75f057` |
| `Floor_ReceivingApron` | `3dd29e69ad1f5e388f274929d426322768d1ff4d82277818ec5cafb2fd5ad983` |
| `FreightNorth` | `bd191f3de660b824a61a2cbe45b9124cebd85531c40ebd94a52f1ce0c6428564` |
| `FreightRear` | `7b22099f31c1145596cbb5c5fe6e3f95c1aaca3175dcd1e421a84eedd6d9c6fa` |
| `FreightSouth` | `bd191f3de660b824a61a2cbe45b9124cebd85531c40ebd94a52f1ce0c6428564` |
| `ReceivingEastOpeningWall` | `ec8d803d21e1c4aab0c9ee695d43fd320944ea6ae3311eb669fc25be0c96d6bf` |
| `ReceivingNorthWest` | `319627a489b7edf3cda09d09b2936998b73a6bdfb1b85132f1e9e6043248a6f3` |
| `ReceivingSouth` | `824fbf25acde521f6681a7b8d83b932bb5237fa24dd82bfd50189a24ba80ba42` |
| `ReceivingWestNorthReturn` | `6e6304e4ef66167168b9772c58c0fac8f4ca2a896fbee137ea9e179520db95a7` |
| `ReceivingWestSouthReturn` | `312e6736247824cc19e762ab5b5283d35988f937ba013f6c73660d7335a40dc5` |

## Review controls and catalog authority

- `data/environment/receiving_proof/eaf5_review_control.tres` is a textureless-looking medium grey EAF1 spec at roughness 0.75. It is EAF5 review tooling only, outside the EAF3 catalog and production palette.
- Two fixed Compatibility-renderer rigs: NEUTRAL_ARCHITECTURAL (white room-scale bounce plus local task spots) and RECEIVING_TARGET (warm/neutral room-scale bounce and bounded industrial task spots). WorldEnvironment, exposure and filmic tonemap remain fixed. The distant east spots have shadows off to avoid repeated large-plane bands; freight/task key spots keep architectural shadows. This was calibrated once before role capture.
- Nine locked camera transforms: EastApproachOverview, FreightAperture, FreightRecess, EastOpening, DispatchOpening, UpperCeilingContext, WallDominant, FloorRead, CeilingRead. Switching a role or lighting mode does not move a camera.
- Live EAF3 catalog at capture: 30 APPROVED, 7 DEFERRED, 6 REJECTED. The proof queries current approvals via `EnvironmentMaterialCatalogQuery`; every candidate loads its EAF3 approved spec and is built via `EnvironmentMaterialBuilder`. No room code reads raw source maps.
- One major role is active per capture; other shell roles remain on control. Freight recess inherits the wall candidate. Opening returns receive a wall candidate only if `opening_reveal` is approved. The east EAF2 opening is a composite mesh containing piers and reveals, so the entire east opening wall stays on control for a wall candidate without reveal approval; each manifest record flags this limitation.
- UV is the effective mapping in all role captures. Existing UV specs are used as approved. Historical triplanar IDs `eaf3b_39b926e570fb3824019aade2` (ConcreteRoughBright) and `eaf3b_bd0940113f04f3d3784629e7` (ConcretePittedGrayMed) use temporary duplicate specs whose only altered property is mapping mode. Their source textures, scale, normal settings and multipliers remain identical; the catalog and approved specs are unchanged. If either survives a final room palette, a later explicit EAF3 mapping revision is required.

| Role | Current candidates | Catalog IDs (sorted) |
| --- | ---: | --- |
| `WALL_PRIMARY` | 14 | `eaf3b_1435ce254f04bb8e61bd3e96`, `eaf3b_1beac3a311a480af8844ea89`, `eaf3b_20c61bd1c85420be2f71a090`, `eaf3b_2dc87647fd382ad8287a0280`, `eaf3b_39b926e570fb3824019aade2`, `eaf3b_42a2691272218b9a18a53418`, `eaf3b_50ad83f394c2da7652cd6e50`, `eaf3b_5a797fbdc766d7e3dc475abf`, `eaf3b_6bcd8f817ca2993433e217cc`, `eaf3b_71edb3fc983ed8f7655d9523`, `eaf3b_800060297ab83f24c0fb0d75`, `eaf3b_bd0940113f04f3d3784629e7`, `eaf3b_d335d94fd85c2c95c26b6b8b`, `eaf3b_d9c263b19df244e0c6417edb` |
| `FLOOR_PRIMARY` | 8 | `eaf3b_20c61bd1c85420be2f71a090`, `eaf3b_20e1005f19f39efb82251916`, `eaf3b_58622aae11bf1d5d20cee763`, `eaf3b_59351fb0f6850a3489e57c4e`, `eaf3b_66101106e84c33eb3874b1ba`, `eaf3b_af97cff72d3204f723d8e38f`, `eaf3b_bb32071987faae156ff2d4e8`, `eaf3b_f10d218d1e8b7f09b7c2689c` |
| `CEILING_PRIMARY` | 11 | `eaf3b_1435ce254f04bb8e61bd3e96`, `eaf3b_1beac3a311a480af8844ea89`, `eaf3b_2dc87647fd382ad8287a0280`, `eaf3b_39b926e570fb3824019aade2`, `eaf3b_42a2691272218b9a18a53418`, `eaf3b_6bcd8f817ca2993433e217cc`, `eaf3b_71edb3fc983ed8f7655d9523`, `eaf3b_800060297ab83f24c0fb0d75`, `eaf3b_bd0940113f04f3d3784629e7`, `eaf3b_d335d94fd85c2c95c26b6b8b`, `eaf3b_d9c263b19df244e0c6417edb` |

## Later-only inventory

These current-approved materials are recorded for structural-secondary or applied-finish review after primary role survivors. None was composited as an additional layer here.

| Later layer | Catalog ID | Display name | Family | Approved roles | Note |
| --- | --- | --- | --- | --- | --- |
| structural_secondary | `eaf3b_193e61e22156c9dbe801f0ea` | KB3D_CPI_CinderBlocksPDGray | `masonry_block` | wall, opening_reveal | Masonry/block possibility. |
| structural_secondary | `eaf3b_1beac3a311a480af8844ea89` | KB3D_BYR_COReinforcedConcreteSlabs | `structural_concrete` | wall, ceiling, beam_column, opening_reveal | Strong panel or reinforced slab possibility. |
| structural_secondary | `eaf3b_20c61bd1c85420be2f71a090` | KB3D_BTL_ConcreteFloorPanelsRoughA | `service_floor_concrete` | floor, wall | Also in primary floor review; secondary use is later-only. |
| structural_secondary | `eaf3b_5a797fbdc766d7e3dc475abf` | KB3D_BTL_ConcreteRoughPanelBright | `structural_concrete` | wall, beam_column, opening_reveal | Strong panel or reinforced slab possibility. |
| structural_secondary | `eaf3b_cb2bc1880df9d4b7d55cf348` | KB3D_BTL_ConcreteBlocksB | `masonry_block` | wall, opening_reveal | Masonry/block possibility. |
| structural_secondary | `eaf3b_e1a15a7af45c82b781600501` | KB3D_CSZ_ConcreteBlocksBPanels | `masonry_block` | wall, opening_reveal | Masonry/block possibility. |
| structural_secondary | `eaf3b_e7d641639f5d230a5d21ecbd` | KB3D_WDC_ConcreteBlocksA | `masonry_block` | wall, opening_reveal | Masonry/block possibility. |
| applied_finish | `eaf3b_7b12b8b3a2e05c502801d22f` | KB3D_RFS_ConcretePlasterWhite | `cement_render` | wall | Layer-2 wall finish only. |
| applied_finish | `eaf3b_8d5f0cf5add98dfe0a58f18a` | KB3D_AFT_PlasterA | `cement_render` | wall | Layer-2 wall finish only. |
| applied_finish | `eaf3b_9297ffec71774317b0627951` | Painted Concrete Wall | `applied_paint` | wall | Layer-2 wall finish only. |
| applied_finish | `eaf3b_b395eb3943870fbfd262e8ce` | KB3D_ECP_StuccoWhite | `cement_render` | wall | Layer-2 wall finish only. |
| applied_finish | `eaf3b_c29826cd934f1534ecfb48c5` | KB3D_NNY_ConcretePlasterWhite | `cement_render` | wall | Layer-2 wall finish only. |

## Captures and review packages

- Shell: six neutral 1920×1080 captures and one contact sheet. Role isolation: four 1920×1080 captures per candidate (Neutral/Receiving × Overall/role view), totaling 132 role captures. All candidate IDs and records are sorted deterministically. Each record includes source ID/fingerprint, approved and effective mapping, PBR settings, camera transform, light settings, shell source/version and all 19 geometry fingerprints.
- ZIP contents are allowlisted to capture PNGs, contact sheets, manifest, summary and pending decision template. All four ZIP integrity checks passed; no commercial maps, staged cache or `.import` files are included.

| Package | Captures | Sheets | SHA-256 |
| --- | ---: | ---: | --- |
| [eaf5_shell_review_01.zip](../../reports/environment_receiving_proof/eaf5/eaf5_shell_review_01.zip) | 6 | 1 | `9cb51061bab8f2d5abc999c10fe734855c01406ce5a6ede07f1842b2fb545c64` |
| [eaf5_wall_role_review_01.zip](../../reports/environment_receiving_proof/eaf5/eaf5_wall_role_review_01.zip) | 56 | 4 | `377210a717c20b1de2b7dff3f133e185a593f4907e2de7fad18057422385a3a6` |
| [eaf5_floor_role_review_01.zip](../../reports/environment_receiving_proof/eaf5/eaf5_floor_role_review_01.zip) | 32 | 2 | `51ab9c6477f8677d962c678484ffc3a02887bbbfe4e6adbdd87f863fef6be043` |
| [eaf5_ceiling_role_review_01.zip](../../reports/environment_receiving_proof/eaf5/eaf5_ceiling_role_review_01.zip) | 44 | 3 | `24caacf6ffa48dab4eb33536cf8979359a385b09d0967467ee9e77de753e9e69` |

## Verification and handoff

- `audit_pass3_shell.py`: 19 pieces, 18/1 recipes, 11 contact pairs, accepted openings, zero errors.
- EAF5 Python suite: 25 tests passed, covering Pass 1/2 authority plus specs, shell audit, live candidate matrix, provenance, package allowlist and visual readability.
- EAF3B Python suite: 17 tests passed. Godot EAF2 substrate, EAF3B query and live catalog, EAF1 lookdev, EAF5 proof and capture tests: all exit 0, zero reported failures.
- Godot 4.7 headless editor import/parse exited 0. A platform certificate-store warning appeared on all Godot invocations; it did not fail tests or imports.
- `git diff --name-only --` against the protected wing paths returned no files. No EAF4 overlay, patch or wear query is instantiated. No wall/floor/ceiling pair, applied finish, survivor selection, production migration or Receiving C1 work was performed.
- Human gate: review the shell ZIP first for proportion, contacts, apertures and freight enclosure. If accepted, record KEEP / DROP_FOR_RECEIVING / HOLD decisions separately in the three role ZIP templates. Decisions remain PENDING; no EAF3 status is revoked by a room-role drop.

## Pass 3A — bounded Receiving shell revision (2026-09-28)

**Historical Pass-3A technical gate: SHELL REVISION IMPLEMENTED / TECHNICALLY VERIFIED.** The subsequent human disposition is recorded in Pass 3B below. Human v1 disposition: **REVISE**. The four v1 ZIPs above are **SUPERSEDED FOR PROMOTION EVIDENCE — SHELL REVISION REQUIRED**. Their checksums remain exactly as recorded above; no role capture was regenerated and no KEEP / DROP_FOR_RECEIVING / HOLD decision was made.

### Artifact diagnosis and correction

| Observed v1 class | Diagnosis from saved boxes, generated AABBs and debug views | Pass 3A action |
| --- | --- | --- |
| Continuous wall/floor and wall/ceiling strips | `EXPOSED_SLAB_SIDE_FACE` at closed-box slab boundaries and seam; local neutral lighting also gives the finished floor a value change near walls. | Keep finished Y=0 and underside Y=4.20; walls cover the slab contact vertically; omit only slab lateral rendering faces while retaining 0.30 m dimensions, top and underside. Close debug views and the v2 ceiling comparison no longer show a vertical slab side or wide ceiling seam. The remaining neutral floor value gradient is lighting on the floor plane and remains visible for human review. |
| Vertical sliver / accidental pilaster at perpendicular joins | `EXPOSED_WALL_END_FACE` and `COPLANAR/Z_FIGHT`: an exact closed-box butt cap coincided with the through wall interior face. Trial hidden 0.02–0.30 m overlaps made depth fighting visible. | Use exact through/butt bounds and omit the internal butt cap on the ordinary EAF2 `rect_solid`; keep actual aperture jamb ends. The colored join audit now shows two planes and a corner line. |
| Return side faces and collinear seam | `WALL_JOIN_OVERLAP` / coincident caps at the saved half-thickness joins. | Make nine explicit junction assignments below, butt freight walls to returns/rear, and omit only concealed end faces. No interior gap or third wall plane in the audited samples. |
| False Dispatch sill/header and black structural frame | `CONTEXT_GEOMETRY` from the five closed EAF2 Dispatch annex boxes and an undersized nearby blocker. | Remove all five annex pieces from the Receiving EAF2 set. Retain Receiving-side DispatchSouthWest/East. Use distant oversize backdrop and a floor continuation under the aperture, tagged `CONTEXT_ONLY / REVIEW_ONLY`. |
| East opening reading as a dark insert | `CONTEXT_GEOMETRY`; blocker edges were visible through the genuine EAF2 opening. | Keep the 3.84 × 3.40 m opening and 0.80 m upper closure; move and oversize the distant backdrop and add a floor continuation under the aperture. |
| Repeated strips in all v1 role renders | `MATERIAL_ROLE_BOUNDARY` ruled out as the primary cause: the neutral shell and multiple role surfaces showed the same geometry/contact shapes. | Shell only was recaptured; role decisions remain on hold. |

The original [Pass 1 source manifest](../../data/environment/receiving_proof/eaf5_receiving_shell_source.json) remains byte-identical (SHA-256 `12cf8f93024e833f5c16932a1d963b3986258a7661cff3e246a2db525d4d4fc9`). It records the 19 saved greybox boxes and accepted spatial authority. The separate [Pass 3A proof composition](../../data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json) (SHA-256 `8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d`) records the 14 EAF2 structural proof pieces, exclusions, bounds and join ownership. Its EAF2 mapping uses 13 `rect_solid` and one `wall_with_rect_opening`; missing recipe count remains zero. The five excluded Dispatch annex IDs are `Floor_DispatchAnnex`, `Ceiling_DispatchAnnex`, `DispatchWest`, `DispatchNorth`, and `DispatchEast`.

The generic EAF2 `rect_solid` now accepts an optional `concealed_faces` list for lateral faces covered by adjacent construction. The default empty list retains the prior closed mesh behavior. This is a bounded EAF2 face-ownership option; there is no EAF5 generator, CSG, post-build surgery, or new recipe. Only proof specs use it. The masked face is part of the geometry fingerprint; mesh dimensions, UV phase and collision policy remain explicit. Four slab lateral faces are concealed on each of the two floor and two ceiling pieces. Their finished planes remain; the slab spec remains 0.30 m thick. Exposed aperture jambs retain their real 0.30 m end faces.

Accepted spatial authority remains: apron **10.50 × 10.00 m**, freight **5.00 × 7.00 m**, clear height **4.20 m**, structural thickness **0.30 m**, west freight aperture **5.00 m full height**, Dispatch aperture **2.40 m full height**, east opening **3.84 × 3.40 m** with **0.80 m upper closure**. Main and freight floor tops are Y=0; ceiling undersides are Y=4.20. Structural walls run Y=-0.30..4.50 behind those interfaces, preserving occupied interior planes. Main and freight slab plans retain accepted bounds and meet at X=0. UV origins are recomputed in metre space from composed bounds; visible floor/ceiling phase is unchanged and no revised wall run resets texture phase.

### Through/butt ownership

| Junction | Through | Butt | Contact plane |
| --- | --- | --- | --- |
| ReceivingSouth ↔ ReceivingWestSouthReturn | ReceivingSouth | ReceivingWestSouthReturn | Z=4.85 |
| ReceivingNorthWest ↔ ReceivingWestNorthReturn | ReceivingNorthWest | ReceivingWestNorthReturn | Z=-4.85 |
| ReceivingEastOpeningWall ↔ ReceivingSouth | ReceivingEastOpeningWall | ReceivingSouth | X=10.35 |
| ReceivingEastOpeningWall ↔ DispatchSouthEast | ReceivingEastOpeningWall | DispatchSouthEast | X=10.35 |
| FreightRear ↔ FreightNorth | FreightRear | FreightNorth | X=-4.85 |
| FreightRear ↔ FreightSouth | FreightRear | FreightSouth | X=-4.85 |
| ReceivingWestNorthReturn ↔ FreightNorth | ReceivingWestNorthReturn | FreightNorth | X=-0.15 |
| ReceivingWestSouthReturn ↔ FreightSouth | ReceivingWestSouthReturn | FreightSouth | X=-0.15 |
| ReceivingNorthWest ↔ DispatchSouthWest | COLLINEAR_BUTT | COLLINEAR_BUTT | X=1.00 |

The collinear `ReceivingNorthWest` ↔ `DispatchSouthWest` line is an exact butt with both coincident internal caps omitted. `ReceivingEastOpeningWall` and `FreightRear` cover their adjoining wall thickness at their outer faces. Closed wall ends at ordinary corners have no rendered coplanar cap. The west and Dispatch declared apertures have no structural header or sill.

### Context and review evidence

The `ReviewContext` inventory has six barrier proxies, two distant backdrops and two floor continuation planes. Every item is tagged `CONTEXT_ONLY / REVIEW_ONLY` and excluded from the 14 EAF2 piece records and geometry fingerprints. The backdrop dimensions hide their edges from the fixed opening views; the continuation planes are Y=-0.003 and extend beneath the finished floor at the full-height apertures. No review context masks an audit failure. Neutral and Receiving lighting rigs, WorldEnvironment, exposure and tonemap remain at their Pass 3 settings. The original six camera transforms/FOVs compare exactly with v1; two extra join views supplement them. Local ignored semantic-color captures include `JoinAudit_Apron`, `JoinAudit_Freight`, and `JoinAudit_Dispatch` (plus three diagnostic views), and are not in the review ZIP.

| Package | Views | SHA-256 | Status |
| --- | ---: | --- | --- |
| [eaf5_shell_review_02.zip](../../reports/environment_receiving_proof/eaf5/eaf5_shell_review_02.zip) | 8 neutral PNGs + contact sheet | `5b2d343a3b80689364fe087e528fd2eba3d6983efa3d5426509b8460217ebd2e` | HUMAN-ACCEPTED for role-isolation review |

The v2 ZIP contains only eight capture PNGs, the contact sheet, manifest, summary and pending shell decision template (12 files); ZIP integrity passed. The v1 ZIPs and their checksums above were verified unchanged. The v2 manifest records source/composition hashes, all 14 generation records/fingerprints, camera transforms, lighting, and review-only context.

### New EAF2 geometry fingerprints

| Piece | SHA-256 geometry fingerprint |
| --- | --- |
| `Ceiling_FreightEnclosure` | `89f21f04fdf1aaea4f3dd4847114e1fb91d7da3625063fe3e92bbbf5db3534a5` |
| `Ceiling_ReceivingApron` | `798eb536fec026054023c271443c5deccd2a947c0b6a1679d4ed1dfea42dc936` |
| `DispatchSouthEast` | `ccb6d3fcbfaae31303216e33bc38e68021251b66c9a50e55085a7604f39fd902` |
| `DispatchSouthWest` | `28f8275b1b06fc180f35f123f9c08054bc49a124ac47fe5107211a51f690ae26` |
| `Floor_FreightEnclosure` | `89f21f04fdf1aaea4f3dd4847114e1fb91d7da3625063fe3e92bbbf5db3534a5` |
| `Floor_ReceivingApron` | `798eb536fec026054023c271443c5deccd2a947c0b6a1679d4ed1dfea42dc936` |
| `FreightNorth` | `7e57cbdef976d189671e86773bf7c68d57894e5a1c170d751760a17910a4c70c` |
| `FreightRear` | `74f37d97eccf14e04884efd06d6a29529e6f6f5cef22c72baee9f242d76b8e54` |
| `FreightSouth` | `7e57cbdef976d189671e86773bf7c68d57894e5a1c170d751760a17910a4c70c` |
| `ReceivingEastOpeningWall` | `5f40559a388e850594330c4d0bf127323ee9ab44016a50dbd60b051a93c4e4bd` |
| `ReceivingNorthWest` | `5fcde161a562581913cbad65978f6e39190bcd4671ceeef095fc1d223279c19e` |
| `ReceivingSouth` | `be6e12a9d38219f77db2a400a37a9aab781e60170e3364475766068c4297cfa4` |
| `ReceivingWestNorthReturn` | `b52141eaf5c0093d9a4119f1f76585e5615d3fc2de15cd72823620e265fe732c` |
| `ReceivingWestSouthReturn` | `bfed3482be4d0a4d0245adf41987db42fd00f72aaa5d41d053be4c37bd6e4070` |

### Technical checks

- Interior-face audit: **0** floor perimeter, **0** ceiling perimeter, **0** slab-side ownership, **0** wall-end ownership, **0** corner ownership, **0** aperture obstruction failures. It evaluates **52** closed-perimeter samples, **9** joins and **27** aperture samples, as well as exact recipe/spec membership, unit roots, fingerprints, UV phase, accepted dimensions, source/composition hashes and context exclusions. Mutation tests detect an exposed slab edge, a missing concealed face, a corner gap and an aperture blocker.
- EAF5 Python suite: **32 passed**. EAF2 Godot substrate suite: **0 failures**, including default closed geometry and optional concealed lateral faces. EAF5 Godot proof and capture suites: **0 failures** each. Godot 4.7 headless editor import/parse: **exit 0**. The recurring Windows certificate-store message did not fail any run.
- Final shell capture: **8/8** neutral 1920×1080 views. The analytical audit passed against its final manifest before packaging. The neutral screenshots still expose floor-contact value changes for human judgement; technical acceptance does not substitute for human visual acceptance.
- No role packages were regenerated, no survivor/material palette/applied finish/EAF4 wear decision was made, and Receiving C1 remains paused. All modified tracked paths are confined to the EAF5 proof data/tooling/tests, the generic EAF2 face option, and this validation; production wing paths have no diff. No merge or push is authorized or performed.

## Pass 3B - human shell acceptance and v2 role recapture (2026-09-28)

**Pass 3A shell human disposition: ACCEPTED.** This acceptance applies to the main Receiving apron, freight aperture, east opening, Dispatch opening, floor, ceiling, wall joins, and overall proof-shell proportions. The accepted evidence remains `eaf5_shell_review_02.zip` (SHA-256 `5b2d343a3b80689364fe087e528fd2eba3d6983efa3d5426509b8460217ebd2e`). The known oddity inside the inaccessible freight/elevator enclosure is **NON-BLOCKING DEFERRED FOLLOW-UP** for later freight-enclosure/C1 refinement; it has not been resolved. It does not interfere with the primary fixed role-review cameras. EAF5 overall is not promoted.

The three Pass-3 v1 role ZIPs (`eaf5_wall_role_review_01.zip`, `eaf5_floor_role_review_01.zip`, `eaf5_ceiling_role_review_01.zip`) are **SUPERSEDED FOR HUMAN ROLE DECISIONS** because they were captured against the rejected Pass-3 v1 shell. They remain diagnostic/history evidence only; their pending templates are not decision authority. Their hashes above remain unchanged.

### Accepted shell and catalog lineage

- Pass-3A composition v2 SHA-256: `8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d`. Source manifest SHA-256: `12cf8f93024e833f5c16932a1d963b3986258a7661cff3e246a2db525d4d4fc9`. Both files are unchanged in this pass.
- The accepted 14 EAF2 geometry fingerprints listed in Pass 3A above remain unchanged. Recipe breakdown is 13 `rect_solid` plus one `wall_with_rect_opening`; missing topology is zero. Capture preflight verifies the accepted shell ZIP SHA-256 and reads its embedded manifest before comparing source/composition hashes and all 14 live fingerprints. Each v2 role manifest and every capture record reference that same source, composition and fingerprint set.
- Live EAF3 catalog: 30 APPROVED, 7 DEFERRED, 6 REJECTED. The live query returned the same sorted v1 membership: 14 WALL_PRIMARY, 8 FLOOR_PRIMARY, 11 CEILING_PRIMARY. All candidates are effectively APPROVED, their approved specs validate, their mapping and material parameters match the current catalog, and their current source matches the reviewed fingerprint. The two historical triplanar candidates use transient UV review clones. Approved catalog/spec files were not changed.
- Existing NEUTRAL_ARCHITECTURAL and RECEIVING_TARGET rigs, WorldEnvironment, exposure, filmic tonemap, cameras, and structural shell were used without recalibration or movement. Exactly one primary role is active per capture. EAF4 wear, applied finish, structural secondary, palette pairing, and Receiving C1 remain off/paused.

### Sanity gate and new role packages

The first sorted candidate of each role was captured in both light modes and both required cameras: 12 PNGs total. Visual inspection of the three four-view sanity contact sheets found candidate mapping on the intended surfaces, neutral control roles and context, and no recurrence of the v1 strips/slivers or a new primary-camera artifact. The freight-enclosure oddity remains deferred. The same capture path then produced all 132 full role PNGs.

| v2 shareable package | Candidates | Captures | Contact sheets | SHA-256 |
| --- | ---: | ---: | ---: | --- |
| [eaf5_wall_role_review_02.zip](../../reports/environment_receiving_proof/eaf5/eaf5_wall_role_review_02.zip) | 14 | 56 | 4 | `2fbb4a646b2e48c742a901c0e650178ebb5e89e2c39bd3c964fcc32566946dcb` |
| [eaf5_floor_role_review_02.zip](../../reports/environment_receiving_proof/eaf5/eaf5_floor_role_review_02.zip) | 8 | 32 | 2 | `75ccd8600d1f15e9030b87284bbda0bae1f3f5c362dfe35be02d3c0f80df538e` |
| [eaf5_ceiling_role_review_02.zip](../../reports/environment_receiving_proof/eaf5/eaf5_ceiling_role_review_02.zip) | 11 | 44 | 3 | `a666f59876a6b35112803f9c8a30995aac06cc9da81f4fe3f1a42c53c5e57c37` |

Each candidate has Neutral/Receiving overall and role-specific views. Contact sheets show display name, catalog ID, role, surface family, metres per repeat, effective UV mapping, and a transient-override marker when applicable. Manifests contain material/source provenance, approved roles, mapping and parameters, camera/lighting data, the accepted shell hashes, and 14 geometry fingerprints. The known one-mesh east opening remains entirely on control when `opening_reveal` is not approved; no EAF2 recipe was redesigned. Opening-reveal authority comes from the current EAF3 approved roles, while the preflight freezes candidate ID membership to v1 as required. Each ZIP passed integrity and allowlist checks: only capture PNGs, contact sheets, manifest, summary, and a fresh all-PENDING decision template are included. No commercial maps or staging data are shared.

### Pass 3B verification and handoff

- EAF5 Python suite: 34 passed. EAF3B material catalog Python suite: 17 passed. EAF5 Godot proof/capture and EAF3B Godot query/live catalog suites: zero failures. Godot 4.7 headless editor import/parse exited 0. The recurring Windows certificate-store warning did not fail tests or import.
- `eaf5_shell_review_01.zip`, accepted `eaf5_shell_review_02.zip`, and all three v1 role ZIPs retain their recorded SHA-256 hashes. Package inspection confirmed 56/32/44 captures, four combinations per candidate, 4/2/3 contact sheets, fresh PENDING templates, and ZIP integrity. All three v2 role manifests refer to the accepted composition and fingerprints.
- No protected production Receiving/wing file changed. No KEEP / DROP_FOR_RECEIVING / HOLD decision was selected. Human review now selects role survivors; Pass 3 is not complete and EAF5 is not promoted.

**Handoff status: EAF5 PASS 3B READY — HUMAN ROLE-SURVIVOR REVIEW PENDING.**
