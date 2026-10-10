# EAF4 live editor authoring Task 1 checkpoint

10 October 2026. Local implementation on `codex/receiving-c1-label-wear-pass`, continuing `0709192` after `a331b61`. Automated checks PASS; interactive editor acceptance NOT RUN. Task 2 has not started. Receiving wear remains unaccepted as final; Receiving C1 is not promoted or closed.

## Root cause and repair

The overlay already had `@tool`. Spec fields did not emit `Resource.changed`, neither helper subscribed to nested changes, material-patch exports lacked refresh setters, and regeneration assigned `scale = Vector3.ONE`. Editor quads were owned by the edited scene and could be saved as preview state.

Spec setters now emit changes. Helpers connect once, disconnect replaced/exiting resources, and coalesce edits into deferred refresh. Refresh preserves the whole root transform. Generated meshes/materials are independent; ownerless visuals are excluded from scene saves. Invalid input clears the affected visual and supplies configuration warnings. There is no per-frame process or room rebuild.

The focused reproduction had five failures before repair, zero afterward. Review reproduced four serialization failures for authored values equal to script defaults. Initialization now waits until serialized fields and the initialization marker load. Two further failures for explicit pre-tree settings were repaired by initializing only unspecified fields.

## Interface and ownership

`EnvironmentWearAuthoring` is a thin `EnvironmentWearOverlay` subclass with ordinary Inspector properties. **Approved Source** stores `display name | catalog_wear_id`; lookup uses the ID suffix, never the name or list index. It includes all 11 current approved floor/wall overlays, including four PLANAR_ANY entries. The approved modulation-only mask is excluded. xetubap is the only material-patch source and remains DEFERRED; no eligible material-patch fixture is required. The existing `EnvironmentMaterialPatch.Mode.EAF4_SOURCE` path remains and has live nested-refresh coverage.

The first valid source supplies approved defaults for unspecified fields. **Source switches preserve all authored settings**, including appearance, dimensions, mirrors, offset, position, rotation, scale and visibility. **Use Approved Appearance Defaults** renders the selected source's approved appearance and hides authored appearance controls. Turning it off restores retained authored values. Placement, dimensions, offset and mirrors remain authored. Refresh, load and save never reset settings. `_appearance_initialized` is serialization metadata; explicit pre-tree properties are respected without it.

Settings are scalar/vector/color properties on each node. Effective specs and generated materials are independent; textures and approved defaults remain shared. Legacy helpers detach editable specs on tree entry and editor resource assignment, supporting duplication and separate scene instances without Make Unique. Programmatic runtime resource assignment after tree entry retains the existing caller-managed resource API.

Width/height are local metres in `(0, 8]`, multiplied by ordinary positive node/ancestor scaling. Offset retains `[0.0005, 0.01]` metre bounds along local +Z; positive Z scaling also scales it. Refresh never normalizes scale. Negative/zero scaling and sheared hierarchies are outside this authoring contract. Validation policy, renderer, assets, approvals and fingerprints are unchanged.

Shader meanings are unchanged: `ALBEDO = mix(tint.rgb, source.rgb, albedo_strength)`. Strength 0 uses tint; strength 1 uses source colour, making tint ineffective at 1. Tint alpha is unused. This is not substrate blending or multiplicative tint. Roughness blends fixed 0.8 toward the source map; normals retain the existing map-depth control. SOFT_BLEND multiplies alpha and feathers UV edges. CUTOUT multiplies its mask before the existing 0.28 scissor test, so reduced opacity can remove coverage. Unsupported normal/roughness/feather controls are hidden. Imperfection controls appear only for sources with a mask, under advanced groups.

## Changed files and fixture

- `environment_authoring/wear/environment_wear_overlay_spec.gd`: change notifications, unchanged validation.
- `environment_authoring/wear/environment_wear_overlay.gd`: refresh lifecycle, ownership and transform preservation.
- `environment_authoring/wear/environment_material_patch.gd`: corresponding refresh/ownership repair; existing EAF3 rendering retained.
- `environment_authoring/wear/environment_wear_authoring.gd` and `.uid`: approved-source Inspector wrapper.
- `environment_authoring/wear/fixtures/wear_authoring_validation.tscn`: diagnostic soft floor instances, cutout original/copy, PLANAR_ANY and legacy cases.
- `environment_authoring/wear/fixtures/wear_authoring_floor_sample.tscn`: reusable fixture instance, not the Task 2 preset library.
- `tools/environment_authoring/wear_catalog/tests/test_wear_live_refresh.gd`, `test_wear_authoring.gd`, `test_wear_authoring_fixture.gd` and their `.uid` files.
- This report.

Open **`res://environment_authoring/wear/fixtures/wear_authoring_validation.tscn`** in Godot 4.7 Compatibility. Select `Floor_Instance_A`; edit dimensions, opacity, tint/blend, supported map strengths, feather and mirrors. Move/rotate/scale, then edit appearance again. Duplicate with the normal editor command and edit the copy. Repeat with separate floor scene instances. Switch source, use the defaults toggle, undo/redo, save and reopen. Clear the source and test zero/above-8 dimensions and above-0.01 offset. Finally run the fixture and check one visual per helper. Gameplay launch is not needed for authoring.

## Verification commands and results

All commands ran from `D:\Godot Projects\Sorting-apoc-PROTOTYPE`. Local raw evidence: ignored `reports/environment_wear_catalog/editor_authoring_task1/`.

```powershell
$G = 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe'
$P = 'C:\Users\Boschetar\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
# Each Godot table row was run with:
& $G --headless --path . --script <script-path>
```

| Script path | Result |
| --- | --- |
| `tools/environment_authoring/wear_catalog/tests/test_wear_live_refresh.gd` | Before: five failures, exit 1. Final: zero, exit 0 |
| `tools/environment_authoring/wear_catalog/tests/test_wear_authoring.gd` | PASS, 63 checks, zero failures, exit 0 |
| `tools/environment_authoring/wear_catalog/tests/test_wear_authoring_fixture.gd` | PASS, runtime/parent-instance roundtrip and seven legacy Receiving overlays with exact serialized transforms |
| `tools/environment_authoring/wear_catalog/tests/test_wear.gd` | PASS before/after |
| `tools/environment_authoring/wear_catalog/tests/test_wear_human_catalog.gd` | PASS before/after |
| `tools/environment_authoring/wear_catalog/tests/test_wear_rerun.gd` | PASS before/after |
| `tools/environment_authoring/wear_catalog/tests/test_material_patch_scale.gd` | PASS before/after |
| `tools/asset_pipeline/tests/wing_startup_parity_tests.gd` | PASS before/after |
| `tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd` | PASS before/after; intentional duplicate-seed rejection diagnostics retained |
| `tools/asset_pipeline/tests/receiving_infrastructure_integration_tests.gd` | PASS, zero failures |
| `tools/asset_pipeline/tests/receiving_set_dressing_collision_tests.gd` | PASS, zero failures |
| `tools/asset_pipeline/tests/receiving_lighting_integration_tests.gd` | PASS, 126 checks |
| `tools/asset_pipeline/tests/receiving_lift_installation_tests.gd` | PASS |
| `tools/asset_pipeline/tests/receiving_deck_presenter_tests.gd` | PASS |

```powershell
& $P -m unittest discover -s tools/environment_authoring/wear_repository/tests -v
& $P -m unittest discover -s tools/environment_authoring/wear_catalog/tests -v
& $P -m unittest discover -s tools/environment_authoring/material_catalog/tests -v
& $G --path . --rendering-method gl_compatibility --script tools/asset_pipeline/tests/receiving_lift_crt_tests.gd
& $G --headless --path . environment_authoring/wear/fixtures/wear_authoring_validation.tscn --quit-after 30
& $G --headless --editor --path . --script tools/environment_authoring/wear_catalog/tests/test_wear_authoring_fixture.gd
& $G --headless --editor --path . environment_authoring/wear/fixtures/wear_authoring_validation.tscn --max-fps 30 --quit-after 1200 --verbose
& $G --headless --editor --path . reports/environment_wear_catalog/editor_authoring_task1/empty_editor_baseline.tscn --quit-after 1200 --verbose
git diff --check
```

Python: 23 EAF4A, 12 EAF4B, 17 EAF3 catalog tests PASS. CRT OpenGL: PASS for configured and explicit wing launch, 704 x 400 and 4,041 green samples each. Fixture runtime startup and whitespace check: PASS. All table suites exited 0 after repair.

Programmatic editor-hint fixture assertions PASS with `editor_hint=true`; custom-main-loop shutdown emits RID/ObjectDB diagnostics. Full editor loads the fixture through **Editor layout ready**, exit 0, but reports 21 retained instances / 12 item and Receiving script resources at shutdown; verbose retention lists contain no wear resources. **FAIL for clean shutdown**, cause unestablished here. The ignored empty-scene control also reached Editor layout ready, then exited `-1073741819`. No unrelated engine/gameplay repair was attempted. Initial focused/canonical baseline tests passed; all Godot runs emit the pre-existing Windows root-certificate-store diagnostic. Editor shutdown failures were discovered during this task, not established on a pre-change full-editor baseline.

| Interactive acceptance | Actual editor UI | Automated evidence |
| --- | --- | --- |
| Visible without gameplay | NOT RUN | Initialization/editor-hint fixture assertions PASS; editor scene load completes |
| Live controls, transform and scale | NOT RUN | Nested/flat setter checks PASS |
| Normal editor duplicate; separate instances | NOT RUN | Node duplication and separate PackedScene instances PASS |
| Source switch and defaults | NOT RUN | Property/source/material checks PASS |
| Inspector undo/redo, save/close/reopen | NOT RUN | UndoRedo property operations, disk roundtrip and parent-local overrides PASS |
| Invalid/cleared/replaced source and bounds | NOT RUN | State, disconnection and bounds checks PASS |
| Runtime appearance and one overlay | NOT RUN visually | Runtime fixture assertions/startup PASS |

Native app control is unavailable in this session. These NOT RUN checks require the human workflow above. Headless assertions and runtime launches are not full editor acceptance.

## Handoff and remaining limits

Reuse `EnvironmentWearAuthoring`, `approved_source`, its exported node properties, `use_approved_appearance_defaults`, and these fixture scenes. Task 2 can create its complete presets and integrate them after review; no wing composition was changed here. Catalog metadata is cached once per script lifetime; catalog reconciliation requires reopening/reloading the authoring script before a new selection list. Source-resource changes refresh live. Approved texture caches must already be staged; missing sources warn and hide the affected visual. Soft-layer overlap and artistic placement require human review.

The four original dirty files are byte-identical and unstaged: `gameplay/logistics_wing/wing_gameplay.tscn`, `data/receiving/receiving_deck_stage_b_proof.tres`, `data/environment/receiving_proof/eaf5_review_control.png.import`, and `data/environment/receiving_signage/lift_emergency_stop.svg.import`. The accepted label, Receiving source scene, wear values, shaders, approved resources and catalog records were not edited. Review found no remaining code blocker. Interactive acceptance and the editor shutdown limitation remain open at this local technical checkpoint; this report does not authorize Task 2.
