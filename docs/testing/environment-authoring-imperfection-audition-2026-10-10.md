# Experimental EAF4 imperfection audition — 2026-10-10

Local implementation on `codex/receiving-c1-label-wear-pass`, continuing directly from verified HEAD `6051e83116bb4837fd1796c0a726e60056df2204` (Task 2), parent `99fc745` (Task 1). The starting index was empty. This task adds a separate experimental editor audition; it grants no source/placement approvals, changes no artistic composition, and does not close Receiving C1. No merge, push or publication.

## Preflight and preservation

Before scene changes, exact bytes, diffs and hashes of the four pre-existing dirty files were saved under ignored, Godot-excluded `reports/environment_wear_catalog/imperfection_audition/` (`preflight_state.json`, `dirty_0.bin`…`dirty_3.bin`, corresponding `.diff`). The wing diff contains the existing seven local Road Dust specs/materials/generated quads and authored dimensions/appearance, alongside editor serialization changes to floats, resource ordering/IDs, default collision fields and editable-path order. Its complete contents were preserved. No additional experimental placements were present on disk.

| Protected file | SHA-256 before | Preservation |
| --- | --- | --- |
| `data/environment/receiving_proof/eaf5_review_control.png.import` | `621de3c3b065ad001b9c30d7c72f98fa046535feb69f5119061c508edcd280ea` | Byte-identical |
| `data/environment/receiving_signage/lift_emergency_stop.svg.import` | `78eb4b8bcb44e55f5388ae1946d9236ea27468431d6594a82e2879e2d1f187a7` | Byte-identical |
| `data/receiving/receiving_deck_stage_b_proof.tres` | `33914e658f2873175218fa4e809bf34af883480242f15c20a1d4658d6f349868` | Byte-identical |
| `gameplay/logistics_wing/wing_gameplay.tscn` | `1f6f04dcf42718b013a87762b85a203c3bb5cacfeb226a09844de41f2bca3120` | Byte-identical after subtracting the 179-byte additive group |

The only canonical addition is an empty, visible, direct scene-owned `WingGameplay/ImperfectionExperiments` Node3D with an experimental-purpose annotation. No experimental wear placement is saved. Current wing hash after this addition: `79fac98247d5c2fc239893a77bcd4577eb472786199051c172f440fe08a7cbe2`. `wing_additive_block.bin` and `wing_task_only.patch` record the owned change. Staging uses that patch against HEAD; the existing wing edits remain unstaged. The other three dirty files are not staged.

All **137** snapshotted approved dependencies remain byte-identical: catalog, decisions, approved specs/mask records, all eleven approved presets, approved shaders/cache files, Receiving finish scene and accepted plaque SVG. The Task 1/2 implementation remains in place. Existing source index/config and original exports are untouched. `preservation_after.json` contains final comparisons.

## Source coverage and architecture

The [inventory](environment-authoring-imperfection-source-inventory-2026-10-10.md) was written before production implementation. It validates all sixteen triaged stable identities against actual originals in the single configured, guarded `D:/AssetPipeline/EAF4_repository`. Every indexed signature is current; genuine selected 1K files decode, and strong EAF4 selected-resolution fingerprints/hash anchors are recorded. No source archive or contact sheet was sampled. **11 opacity.red and 5 roughness.red** maps are included; zero currently blocked. Roughness is explicitly repurposed as scalar distribution, not physical roughness.

Source status remains from the existing catalog: Grunge `tedxadjc` APPROVED for its existing modulation-only use, Scratched Metal `vdekebbc` DEFERRED, fourteen UNREVIEWED. An experimental placement remains EXPERIMENTAL / NOT APPROVED regardless of source status. [Manifest and coverage index](../../environment_authoring/wear/imperfection_experiments/README.md) provide actual channels, original/cache paths, source-map hashes, strong fingerprints, physical-size provenance and named wrappers. All wrappers use a practical 1×1 m starting patch; source estimates are retained as references.

`imperfection_audition.gd` is a reusable @tool Node3D, with coalesced deferred refresh and no processing loop. Root exports serialize normal Inspector edits; one ownerless QuadMesh/MeshInstance3D is generated per instance. Mesh/material and Mode B effective specs are independent; texture references stay shared/read-only. Invalid selections, missing/changed cache bytes or invalid settings warn and hide without substitution. Source changes preserve transform and all authored settings.

Three Preview Mode options separate grayscale diagnostic, tinted-opacity illustration and actual approved-wear modulation. Mode B is deliberately limited to the two current approved SOFT_BLEND Leakage overlays (`skiubhzc`, `tculfbnc`), with explicit independent Wear Source and unmasked/strength-zero comparisons. Its dedicated experimental shader preserves the established soft alpha/feather/normal/roughness/metallic equations; it adds scalar inversion/bias and diagnostic branches. Native cutout/material patches/other overlays are unsupported. No approved shader/spec/default or underlying EAF3 surface changes.

The one-shot `build_imperfection_experiments` tool reuses EAF4’s guarded fingerprint/staging pipeline and stages only actual 1K maps into a separate ignored cache. No editor importer/status manager, alternate-root discovery, DCC tool or new approval system. Commercial textures and imports are not versioned; the coverage README documents licensing, local config/index prerequisites and workstation reproduction.

## Narrow guard and review

The test-only guard has a separate `validate_experiments` entry point for the explicit experimental branch. The approved `validate` allowance remains restricted to its exact existing helper. Each permits directly scene-owned plain grouping nodes, its exact helper script on a **plain native Node3D root**, and one unscripted, ownerless Quad. Arbitrary scripts, meshes, nested children, cameras/lights/physics and incorrect ownership are rejected.

Consolidated read-only review found no remaining Critical/Important implementation issues after corrections and judged the work ready for a local commit and human audition, subject to completing this report and deliberate task-only staging. It found a real script/native-class bypass: a legal Node3D helper script could be attached to Camera3D, OmniLight3D or StaticBody3D. Four focused assertions failed before requiring a plain native Node3D root, then the 30-check experimental guard suite passed; retained approved workspace and infrastructure tests were rerun. The channel-count prose was also corrected; per-source bindings were always accurate.

## Verification evidence

Godot: `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`, version `4.7.stable.official.5b4e0cb0f`. Python: bundled `C:/Users/Boschetar/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`. Commands run from project root. Raw logs and exact argv/exit statuses: `reports/environment_wear_catalog/imperfection_audition/suite_results.json` and individual logs.

```powershell
$G = "D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe"
$P = "C:/Users/Boschetar/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe"
& $P -m unittest discover -s tools/environment_authoring/wear_repository/tests -v
& $P -m unittest discover -s tools/environment_authoring/wear_catalog/tests -v
& $P -m unittest discover -s tools/environment_authoring/material_catalog/tests -v
& $P -m tools.environment_authoring.wear_catalog.build_imperfection_experiments --check
& $P tools/environment_authoring/wear_catalog/build_presets.py --check
# Every headless row below:
& $G --headless --path . --script <script-path>
& $G --headless --editor --path . --script tools/environment_authoring/wear_catalog/tests/test_imperfection_audition.gd
& $G --headless --editor --path . --import
& $G --path . --rendering-method gl_compatibility --script tools/environment_authoring/wear_catalog/tests/test_imperfection_render.gd
& $G --path . --rendering-method gl_compatibility --script tools/asset_pipeline/tests/receiving_lift_crt_tests.gd
git diff --check
```

Run cache-mutating lifecycle probes **sequentially** with renderer/staging tests: the missing-file probe temporarily removes an owned experimental texture, then restores exact bytes. A concurrent render initially saw that temporary absence and hid the diagnostic; the isolated renderer rerun passed all 50 checks. This was test interference, not a reason to substitute another source or weaken the assertion.

| Check | Outcome |
| --- | --- |
| Python wear repository / catalog / material catalog | PASS: 23 + 27 + 17 = 67 tests; seven experimental tests cover actual mappings/statuses and synthetic missing/stale/ambiguous/resolution/hash failures |
| Both experimental and approved one-shot audits | PASS; sixteen actual 1K bindings and all eleven approved presets retained |
| `test_imperfection_audition.gd` | PASS: 159 checks, all sixteen wrapper IDs/channels/resources; controls, per-frame stability, duplicate/material/spec/default isolation, positive scale/transform retention, UndoRedo, disk parent save/reopen, missing/changed cached source hides, both approved effects |
| Same script with `--headless --editor` | PASS: 159 checks; automated editor-hint evidence only; shutdown RID/ObjectDB retention remains |
| `imperfection_workspace_tests.gd` | PASS: 30 checks, separate guard, scene ownership, unscripted and scripted authority rejection, branch hide keeps approved wear/signage/CRT independent |
| Retained `test_wear_presets.gd` / `test_wear_authoring.gd` | PASS: 224 / 63 checks |
| Retained `test_wear_authoring_fixture`, `test_wear`, `test_wear_human_catalog`, `test_wear_rerun`, `test_material_patch_scale`, `test_wear_live_refresh` | PASS: all six suites |
| Retained `wear_authoring_workspace_tests.gd` | PASS: 30 checks, including all existing approved-branch negative checks |
| Wing startup parity / gameplay composition | PASS; intentional duplicate-seed rejection diagnostics remain expected |
| Receiving infrastructure / set-dressing collision / lighting / lift installation / deck presenter | PASS; lighting 126 checks; retained collisionless hidden alternatives, fixture/movement proxies and physical composition remain guarded |
| Real OpenGL imperfection proof | PASS: 50 checks; floor/wall diagnostic images and genuine masking, no scene saves |
| Real OpenGL CRT proof | PASS: configured UID and explicit canonical launch both 704×400, 4041 green samples, 0 failures |
| `git diff --check` / protected hashes | PASS; all four protected contents preserved, all 137 approved dependencies unchanged |

The serial regression sweep passed **24/24 commands**. After the review guard fix, the three affected guard/infrastructure suites passed again.

## Actual renderer diagnostics

GPU: NVIDIA RTX 5060 Ti, OpenGL 3.3 / driver 617.14, Compatibility. Temporary in-memory instances use the canonical wing WorldEnvironment, existing lighting, floor/wall materials and scale. No lighting/base-material adjustments, artistic arrangement or saved shipping placements. Floor position `(-33.65,0,-0.2)`, X=-90°; clear wall position `(-32.4,3.0,3.84)`, Y=180°. Size 1.6×1.2 m, offset 0.004 m, opacity 0.65, neutral tint. Exact mode/source/scalar/settings and capture labels: `render_evidence.json`.

Images under the ignored evidence folder: `floor_00_room_before.png`, `floor_01_grayscale_roughness_red.png`, `floor_02_grayscale_inverted.png`, `floor_03_tinted_opacity_illustration.png`, `floor_04_adjusted_scalar_distribution.png`; `wall_leakage_{skiubhzc,tculfbnc}_{unmasked,grunge_tedxadjc_masked}.png`; `wall_candidate_dust_uh4qbeic.png`. They were visually inspected as diagnostic output. They are **runtime images, not editor screenshots or artistic-quality judgments**.

Fixed central pixel probes (every second pixel, RGB delta sum >0.025) confirm grayscale/invert/mode/scalar controls visibly differ. Grunge modulation changed 2385 samples on Leakage skiubhzc and 308 on tculfbnc; all sixteen candidates changed 308–877 samples on the tculfbnc comparison with fixed tint/appearance. Every strength-zero comparison and both established unmasked shader comparisons stayed below the 10-sample tolerance. This proves distribution masking/render binding, not source quality or suitability.

## Interactive acceptance and unresolved issues

| Actual Godot editor action | Status |
| --- | --- |
| FileSystem drag/drop into canonical experiment branch; live Inspector tuning without F5/F6 | NOT RUN |
| Ctrl+D / independent sibling edits / native Ctrl+Z and redo | NOT RUN |
| Save/close/reopen via native editor UI; manual editor/runtime comparison | NOT RUN |
| Group hide with accepted plaque/CRT/approved wear visible in editor | NOT RUN |

Computer-use retry found Godot Project Manager window 1051784 but state capture failed with `FrameArrived timed out: timed out waiting on channel`; after refreshing window selection, retry failed with `window capture timed out: timed out waiting on channel`. No native UI actions or screenshots were invented. The [computer-use skill](C:/Users/Boschetar/.codex/plugins/cache/openai-bundled/computer-use/26.1007.21434/skills/computer-use/SKILL.md) references recovery guidance: “If state capture or window activation fails, stop using prior coordinates or element indexes.” The required fresh selection/single retry was attempted.

The existing editor shutdown retention remains unresolved and has not been established as an EAF4 regression. This task’s import reached Editor layout ready and exited 0, with 21 leaked ObjectDB / 12 retained resources and VariantPools exit diagnostics. The explicit editor-hint custom-loop test passed assertions but reported editor RID/ObjectDB retention (221 instances) at shutdown. The plain runtime lifecycle and final OpenGL imperfection run exited without those retention diagnostics. Existing Windows certificate-store errors remain unrelated startup diagnostics. No engine/gameplay repair was attempted.

## Human stopping point

Use the [exact-label novice guide and five-minute checklist](../environment-authoring/eaf4-imperfection-audition-guide.md#five-minute-human-editor-check): place/orient a diagnostic, compare scalar modes/controls, switch an actual opacity source, duplicate onto a wall for both Leakage comparisons, undo/redo, save/reopen/run, then hide the experiment group and verify accepted art remains. Capture native root/Inspector evidence. Human editor acceptance and later source-quality/placement decisions remain open.
