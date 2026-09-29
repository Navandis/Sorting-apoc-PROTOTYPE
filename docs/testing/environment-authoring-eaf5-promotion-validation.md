# EAF5 Receiving architectural proof — promotion validation

**Status: EAF5 — IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-PROMOTED / CLOSED.**

## Authority and final decision

Feature branch: `codex/eaf5-receiving-proof`; reviewed pre-close-out HEAD: `5ad500c8ff229012882df85d068023b221f867d1`. Promoted baseline: local `main` / `origin/main` at `ac12a51ce431f94c9a65a4e84edbf2f73bdf5c2c` before integration. The human selected **PROMOTE EAF5 / CLOSE EAF5**. This record closes the pending Pass 7A human decision without rewriting earlier evidence.

Accepted Pass-3A composition: `data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json`, SHA-256 `8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d`. It composes 14 EAF2 pieces: 13 `rect_solid`, one `wall_with_rect_opening`, zero missing topologies, unit root scale. The accepted 10.50 × 10.00 m apron, 5.00 × 7.00 m freight enclosure, 4.20 m clear height, 0.30 m structure, 5.00 m full-height freight aperture, 2.40 m full-height Dispatch opening, and 3.84 × 3.40 m east opening with 0.80 m upper closure remain authoritative.

| Role | Palette | Wall | Floor | Ceiling |
| --- | --- | --- | --- | --- |
| Primary | `P01_C02` | `eaf3b_d335d94fd85c2c95c26b6b8b` Dirty Concrete | `eaf3b_bb32071987faae156ff2d4e8` Worn Concrete Floor | `eaf3b_6bcd8f817ca2993433e217cc` Shuttered Concrete Wall |
| Alternate | `P05_C03` | `eaf3b_5a797fbdc766d7e3dc475abf` KB3D_BTL_ConcreteRoughPanelBright | `eaf3b_bb32071987faae156ff2d4e8` Worn Concrete Floor | `eaf3b_71edb3fc983ed8f7655d9523` KB3D_AMC_ConcreteWhite |

**Base applied finish: NONE. Structural secondary: NONE by default. Base wear preset: NONE.** No isolated Pass 7A L0–L2, D0–D2, or R0–R2 variant is promoted as a permanent Receiving preset. EAF4 architecture and catalog behavior, approved-source instantiation, causal placement, and deep-copied room-instance opacity/albedo tuning are accepted. Reduced local intensity improved dust/rust usability; leak needs real services; crack/spall belongs nearer stress, rough service, or damaged edges. EAF4 approvals remain unchanged.

C1 should author wear only after major infrastructure, furniture, shelving/pallets, freight barrier/shutter, and room lighting substantially exist. Use approved EAF4 sources, place and orient against actual causes, resize only for physical placement, tune local opacity/albedo without catalog mutation, and evaluate under final lighting and occlusion. The compact production recipe and migration boundary are in `data/environment/receiving_proof/eaf5_c1_handoff.json`.

## Promoted integration findings

- EAF2 composes the complete proof shell without a Receiving-specific generator or new topology. Through/butt ownership and omitted concealed construction faces work while default empty `concealed_faces` preserves closed-solid behavior. Metre-authored UVs and `Vector3.ONE` roots remain valid.
- **Default environment material mapping is UV.** Compatibility triplanar produced a high-frequency grid artifact on large review surfaces. Triplanar remains supported as explicit opt-in with documented reason and visual verification on representative large/multi-axis geometry; historical approved mappings are not automatically migrated.
- EAF5 reviewed **30 current approved EAF3 materials**. Source index → shortlist → EAF3B staging → EAF1 PBR review → human catalog reconciliation → room-role isolation → wall/floor pair review → ceiling expansion → complete structural palette review are proven. The production recipe uses catalog IDs only.
- EAF4 `EnvironmentMaterialPatch.Mode.EAF3_MATERIAL` now uses a planar generated mesh with exact physical dimensions and metre-authored UV extents; the material builder and unit root scale are unchanged. `EAF4_SOURCE` retains normalized UV semantics. This is generic EAF4 maintenance found during EAF5.

## Evidence and final checks

The historical reviews remain intact: [Pass 1 source shortlist](environment-authoring-eaf5-pass1-source-shortlist-validation.md), [Pass 2 PBR and UV recapture](environment-authoring-eaf5-pass2-material-pbr-review-validation.md), [Pass 3 shell and role isolation](environment-authoring-eaf5-pass3-shell-role-isolation-validation.md), [Pass 4 wall/floor pairs](environment-authoring-eaf5-pass4-wall-floor-pair-validation.md), [Pass 5 palettes](environment-authoring-eaf5-pass5-structural-palette-validation.md), [Pass 6A finish screening](environment-authoring-eaf5-pass6a-applied-finish-screen-validation.md), [Pass 6B finish layout and patch scale](environment-authoring-eaf5-pass6b-applied-finish-layout-validation.md), [Pass 7 causal wear](environment-authoring-eaf5-pass7-causal-wear-proof-validation.md), and [Pass 7A calibration](environment-authoring-eaf5-pass7a-wear-calibration-validation.md). Ignored review ZIPs remain local and were not regenerated for close-out.

- EAF5 Python: **50 passed**; EAF3B Python: **17 passed**; EAF4B Python: **12 passed**.
- Godot 4.7 headless EAF2 substrate, EAF1 lookdev, EAF3B query/live catalog, EAF4B overlay/patch-scale/human-catalog/rerun, and EAF5 proof/capture/finish-layout/wear/wear-calibration: **13 suites, exit 0, zero test failures and no SCRIPT ERROR**. The patch-scale suite checked EAF3 metre UVs at three sizes and EAF4 source normalized UVs.
- Godot 4.7 headless editor import/parse: **exit 0**. Its Windows root certificate-store warning was non-blocking.
- Accepted composition hash unchanged. Pass-3A shell audit: **14 current geometry fingerprints**, 13/1 recipe breakdown, 52 perimeter probes, nine joins, 27 aperture probes, and zero audit errors. Current catalogs: EAF3 **30 APPROVED / 7 DEFERRED / 6 REJECTED**; EAF4 **12 APPROVED / 2 DEFERRED**. EAF3B review default is `UV`; triplanar remains explicit.
- Git feature diff against baseline changes none of the protected production wing paths: `gameplay/logistics_wing/wing_gameplay.tscn`, `wing_environment.tscn`, `greybox/logistics_wing/wing_geometry.tscn`, `build_wing_geometry.gd`, or `gameplay/logistics_wing/receiving/*`. No production Receiving migration was implemented.

The inaccessible freight/elevator enclosure visual oddity is a **non-blocking deferred C1 refinement**. Contextual wear moves to C1. Historical explicit triplanar approvals remain as reviewed. The immediate next project task is the comprehensive documentation review/update; Receiving Stage C1 is the next implementation gate after it. C1A remains parked and unpromoted.

**EAF5 — IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-PROMOTED / CLOSED.**
