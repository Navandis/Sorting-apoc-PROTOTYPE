# EXPERIMENTAL / NOT APPROVED imperfection coverage

These 16 original 1K scalar sources are available locally for human audition. This library grants no approvals and modifies no substrate materials. Read [the editor guide](../../../docs/environment-authoring/eaf4-imperfection-audition-guide.md) and [pre-implementation inventory](../../../docs/testing/environment-authoring-imperfection-source-inventory-2026-10-10.md).

Drop a named wrapper under `WingGameplay/ImperfectionExperiments` in `res://gameplay/logistics_wing/wing_gameplay.tscn`. Wrappers start upright at 1×1 m; floor rotation X=-90°. Select the root; **Experiment Notes** reports the current catalog status and actual sampled channel. Source physical-size provenance, strong fingerprints, original relative paths and ignored cache dependencies are in [manifest.json](manifest.json). The manifest records the audit status for reproducibility; the existing catalog remains the status authority.

| Stable ID / readable source | Sampled channel | Catalog status at audit | Named wrapper | Caveat |
| --- | --- | --- | --- | --- |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:dust_uh4qbeic:uh4qbeic` / Dust (dust_uh4qbeic) | opacity.red | UNREVIEWED | [dust_uh4qbeic.tscn](presets/dust_uh4qbeic.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:dust_uh4qbflc:uh4qbflc` / Dust (dust_uh4qbflc) | opacity.red | UNREVIEWED | [dust_uh4qbflc.tscn](presets/dust_uh4qbflc.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:dust_uh4rdfvc:uh4rdfvc` / Dust (dust_uh4rdfvc) | opacity.red | UNREVIEWED | [dust_uh4rdfvc.tscn](presets/dust_uh4rdfvc.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:grain_sc2nbisc:sc2nbisc` / Grain (grain_sc2nbisc) | roughness.red | UNREVIEWED | [grain_sc2nbisc.tscn](presets/grain_sc2nbisc.tscn) | Roughness repurposed as scalar; not physical roughness |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_tedwdiic:tedwdiic` / Grunge (grunge_tedwdiic) | roughness.red | UNREVIEWED | [grunge_tedwdiic.tscn](presets/grunge_tedwdiic.tscn) | Roughness repurposed as scalar; not physical roughness |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_tedxadjc:tedxadjc` / Grunge (grunge_tedxadjc) | roughness.red | APPROVED | [grunge_tedxadjc.tscn](presets/grunge_tedxadjc.tscn) | Roughness repurposed as scalar; not physical roughness; approved only for existing modulation workflow |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_tjnncdwc:tjnncdwc` / Grunge (grunge_tjnncdwc) | roughness.red | UNREVIEWED | [grunge_tjnncdwc.tscn](presets/grunge_tjnncdwc.tscn) | Roughness repurposed as scalar; not physical roughness |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_tjvibebc:tjvibebc` / Grunge (grunge_tjvibebc) | roughness.red | UNREVIEWED | [grunge_tjvibebc.tscn](presets/grunge_tjvibebc.tscn) | Roughness repurposed as scalar; not physical roughness |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_uh4uaawc:uh4uaawc` / Grunge (grunge_uh4uaawc) | opacity.red | UNREVIEWED | [grunge_uh4uaawc.tscn](presets/grunge_uh4uaawc.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:grungy_surface_slnnecvc:slnnecvc` / Grungy Surface (grungy_surface_slnnecvc) | opacity.red | UNREVIEWED | [grungy_surface_slnnecvc.tscn](presets/grungy_surface_slnnecvc.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:leakage_sl3ace3c:sl3ace3c` / Leakage (leakage_sl3ace3c) | opacity.red | UNREVIEWED | [leakage_sl3ace3c.tscn](presets/leakage_sl3ace3c.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:scratched_metal_vdekebbc:vdekebbc` / Scratched Metal (scratched_metal_vdekebbc) | opacity.red | DEFERRED | [scratched_metal_vdekebbc.tscn](presets/scratched_metal_vdekebbc.tscn) | Source opacity.red used as experimental distribution; deferred source quality, preview is not approval |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:stains_ulttebjc:ulttebjc` / Stains (stains_ulttebjc) | opacity.red | UNREVIEWED | [stains_ulttebjc.tscn](presets/stains_ulttebjc.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:stains_ultwabqc:ultwabqc` / Stains (stains_ultwabqc) | opacity.red | UNREVIEWED | [stains_ultwabqc.tscn](presets/stains_ultwabqc.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:stains_ultwaekc:ultwaekc` / Stains (stains_ultwaekc) | opacity.red | UNREVIEWED | [stains_ultwaekc.tscn](presets/stains_ultwaekc.tscn) | Source opacity.red used as experimental distribution |
| `eaf4:IMPERFECTION_TEXTURE_PROFILE:wipe_marks_uh4scioc:uh4scioc` / Wipe Marks (wipe_marks_uh4scioc) | opacity.red | UNREVIEWED | [wipe_marks_uh4scioc.tscn](presets/wipe_marks_uh4scioc.tscn) | Source opacity.red used as experimental distribution |

All 16 are included, zero currently blocked. Bright pixels only mean a high sampled scalar; they do not establish dirt/wetness/damage. Repeat is a diagnostic control, not proof of seamless tileability. Mode B supports only the two current approved **soft Leakage** sources; cutout, other overlays and material patches are unsupported. The experimental shader copies the established soft alpha/normal/roughness equations and adds diagnostic branches; approved shaders/specs and their Grunge controls are untouched.

## Reproduce local dependencies

Commercial source images and their Godot imports under `assets/` are ignored and must not be committed or uploaded. Obtain the original source packages under a suitable license. Use the existing `tools/environment_authoring/wear_repository/local_config.json` with its single `source_repository_root` (see that tool’s README), preserving original relative layout. If the local source index is absent, run its existing guarded scan first. No alternate-root search, archive extraction, contact-sheet crops or automatic replacement occurs.

From the project root, using a Python environment with Pillow:

```powershell
python -m tools.environment_authoring.wear_repository.scan_repository
python -m tools.environment_authoring.wear_catalog.build_imperfection_experiments
python -m tools.environment_authoring.wear_catalog.build_imperfection_experiments --check
```

The explicit build audits all 16 source identities/signatures before output, hashes actual 1K maps using EAF4’s established fingerprint/staging functions, and stages them into the separate ignored `assets/environment/wear/imperfection_experiments_cache/`. It never changes approvals or the approved cache. Changed or missing originals fail with a named error; review inventory/dependency drift before deliberately rebuilding the manifest. Godot must import staged images before audition. An absent or changed selected cache shows a configuration warning and hides that instance, with no substitute source. Reopen/edit the instance after restaging; there is no background file watcher.
