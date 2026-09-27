# EAF1 WallGrazing shadow artifact validation

- **Status:** FIX IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN REVIEW COMPLETE / PROMOTED
- **Baseline:** main / origin/main a48135892b31d7872abe2b773b7864b838be6b1f
- **Branch:** codex/eaf1-wallgrazing-artifact
- **Implementation commit:** 797a8634543660abf12868059f7e607487a7df8c
- **Feature branch HEAD at human review:** 1e1c941fcc0c80f84974cfe53725c36a5d4d3b3e
- **Engine:** Godot 4.7 stable, Compatibility renderer (gl_compatibility)

## Reproduction and controlled diagnosis

The diagnostic capture scene and script are local, ignored files under [the report directory](../../reports/environment_lookdev/eaf1_wallgrazing_fix/). They inject a two-spec review set into the existing EAF1 scene; the production catalog is unchanged. All captures use 1920 × 1080, the existing WorldEnvironment, lights, renderer, and fixed Hero or WallGrazing camera.

| Reproduction material | Mapping | Spec |
| --- | --- | --- |
| KB3D_BTL_ConcreteFloorPanelsRoughA (approved) | UV, 1.5 m/repeat | EAF3B foundation_mineral_01 / eaf3b_20c61bd1c85420be2f71a090 |
| KB3D_CSZ_ConcreteRoughBright (approved) | TRIPLANAR, 1.5 m/repeat | EAF3B foundation_mineral_01_rerun_01 / eaf3b_39b926e570fb3824019aade2 |
| Temporary mid-grey StandardMaterial3D | no textures or normal map; roughness 0.7 | diagnostic override only, absent from catalog |

Baseline captures include Neutral/Receiving × Hero/WallGrazing for both real materials, plus Neutral and Receiving WallGrazing for the plain material. The fine diagonal hatch appears on the plain wall, so source texture mapping and PBR channels are not required to produce it. Texture-channel isolation was therefore unnecessary.

S1 turned off every active rig shadow in temporary captures; the plain and UV wall hatch disappeared. S2 and S3 then enabled one shadowed light at a time (all other shadowed rig lights off):

| Isolated light | Plain WallGrazing result |
| --- | --- |
| Neutral WhiteKey | hatch visible |
| Neutral WhiteGraze | hatch visible |
| Receiving WarmPracticalKey | hatch visible |
| Receiving WarmSidePool | clean |
| Receiving NeutralWarmSupport | hatch visible |

This identifies positional shadow-map self-shadowing of the large review surfaces as the shared cause. It is not specific to one source material or one light. The preferred all-six-casters-off trial removed the hatch but also removed the beveled block's useful floor shadow in Hero. A narrower trial kept only the block casting; the plain, UV, and triplanar WallGrazing views remained free of the shared diagonal hatch while the block's scale and shape shadow returned.

## Final patch

The scene explicitly sets Wall_A, Wall_B_90Deg, Floor, Ceiling, and Column to SHADOW_CASTING_SETTING_OFF. BeveledBlock stays SHADOW_CASTING_SETTING_ON. ShadowStructure/OverheadBeam and ShadowStructure/PartialReturn stay at SHADOW_CASTING_SETTING_ON. The review surfaces still receive cast shadows from the remaining casters.

Before this patch all six review surfaces used Godot's shadow-casting default, ON. No shadow-bias or shadow-normal-bias override was authored: old and final values remain Godot defaults. Light shadow-enabled states are unchanged: Neutral WhiteKey ON, WhiteFill OFF, WhiteGraze ON; Receiving WarmPracticalKey ON, WarmSidePool ON, NeutralWarmSupport ON. No renderer, camera transform/FOV, environment, tonemap, exposure, material parameter, or texture import setting changed.

## Visual evidence

- [Before/after contact sheet](../../reports/environment_lookdev/eaf1_wallgrazing_fix/before_after_contact_sheet.png): UV Neutral WallGrazing, triplanar Neutral WallGrazing, UV Receiving WallGrazing, plain Neutral WallGrazing, and UV Receiving Hero.
- [Baseline captures](../../reports/environment_lookdev/eaf1_wallgrazing_fix/baseline/) and [final captures](../../reports/environment_lookdev/eaf1_wallgrazing_fix/final/): ten PNGs each.
- [Shadow isolation variants](../../reports/environment_lookdev/eaf1_wallgrazing_fix/): all_off, neutral_key, neutral_graze, receiving_key, receiving_side, receiving_support, casters_off, and block_cast.

The shared diagonal hatch is absent in the final plain, UV, and triplanar WallGrazing captures. Triplanar source detail remains visible and should be judged separately from the removed shadow artifact. Hero and Receiving retain the warm pools, darker corners, beam/return shadows, and block floor shadow. Human review accepted the brighter large review surfaces and confirmed the composition remains useful.

## Automated and parse verification

- EAF1 focused test: 0 failures, exit 0. New assertions cover the five non-casting large surfaces and the casting block and ShadowStructure pieces. Existing camera, material, environment, light-toggle, and injected-review-set assertions remain green.
- EAF3B live catalog test: 0 failures, exit 0.
- EAF3B catalog query test: 0 failures, exit 0.
- Godot headless editor parse: exit 0; no SCRIPT ERROR or FAIL.
- Final bounded diagnostic capture: ten decoded PNGs at 1920 × 1080, exit 0; same material/camera/light states as baseline.
- Godot emitted its existing Windows root certificate store startup warning. No script or test failure accompanied it.

## Final human review and promotion

The before/after evidence was reviewed and the patch is promoted. The diagonal hatch is removed from plain, UV, and triplanar WallGrazing views. Hero and Receiving composition remains useful; deliberate beam, partial-return, and beveled-block shadows remain. The brighter large review surfaces are accepted as the correct result after removing false self-shadowing. This patch becomes the new EAF1 lookdev baseline.

FINAL HUMAN DISPOSITION: PROMOTE EAF1 WALLGRAZING PATCH
