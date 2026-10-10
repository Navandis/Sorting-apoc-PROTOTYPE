# EAF4 approved presets and wing authoring Task 2

10 October 2026. Continues directly from Task 1 `99fc745` on `codex/receiving-c1-label-wear-pass`. Local technical handoff; editor interaction remains NOT RUN; no artistic acceptance, push, merge or C1 promotion.

## Preflight: existing edits protected before implementation

Before ANY wing change, `git diff -- gameplay/logistics_wing/wing_gameplay.tscn` was inspected in full and saved to ignored `reports/environment_wear_catalog/editor_authoring_task2/wing_preflight.diff`. The file has 540 added / 104 removed lines, 139,053 bytes, SHA256 `fdcb8b52640f029472f1e8b61ca7a30f847b6e1e36a691e47a22883bebd8f91b`.

Existing edits include seven local Road Dust spec overrides and seven serialized preview ShaderMaterials/QuadMeshes/Quad nodes; Traffic_Approach already has physical size `(1.805, 1.655)` instead of the source scene's `(1.15, 0.8)`. These local authored values are the baseline and must stay. There are broad Godot resave changes: added node unique IDs, float precision/default-property serialization, reordered shape properties, renamed rack collision shape and CRT material subresource, unchanged CRT UV settings represented at resave precision, reordered existing external resources and editable paths. The Receiving finish and PhosphorDisplay references already existed before this task. None of this diff belongs in Task 2's commit.

All four original dirty files were copied byte-for-byte to ignored evidence, with SHA256 hashes in `protected_before.json`: the wing, Receiving deck proof resource, EAF5 control import sidecar and emergency-stop SVG import sidecar. The three non-wing files must remain byte-identical. The wing must reproduce its entire original byte stream after removing only Task 2's additive AuthoredWear block. No reset, stash, discard or unrelated staging is authorized.

The new block can be inserted before the final editable-path declarations, away from the pre-existing override hunks. The index will receive a patch against HEAD containing ONLY this additive block, never a whole-file add of the dirty wing. Compare the resulting unstaged wing diff to the recorded preflight diff before committing. Stop if this isolation fails.

## Execution record

Raw commands, logs, baseline byte copies and regression exit codes are local and ignored under `reports/environment_wear_catalog/editor_authoring_task2/`.

## Delivered workflow and coverage

The [library/index](../../environment_authoring/wear/presets/README.md) contains **11 eligible / 11 covered / zero blocked** current approved sources. These include four PLANAR_ANY sources, all current FLOOR/WALL overlays and dual-capability Rust Debris. Audit reads the existing catalog, stable source ID, reviewed/current fingerprint, approved spec identity and each dependency. No catalog, defaults, texture export or approval decision was changed. The approved modulation-only mask and deferred scratched mask remain excluded; xetubap is the sole material-patch record and remains DEFERRED, so **zero eligible material-patch sources**. The one-shot builder explicitly supports EAF4_SOURCE via the established EnvironmentMaterialPatch path and rejects unknown modes; a future patch approval also requires flat controls/guard review rather than automatic shipping integration.

Wrappers contain only the authoring script, stable readable source selection and floor-only orientation where applicable. They reuse Task 1's live flat properties and approved-default initialization. Read-only **Approved Usage Notes** displays restrictions directly from the same catalog. Duplicate names remain distinguished by their stable ID in the selector and their source suffix in FileSystem.

`WingGameplay/AuthoredWear/{Receiving,Storage,OtherRooms}` is empty, visible and directly scene-owned, outside gameplay actor ownership. Plain Node3D room groups can be added without changing code. No gallery, hidden template bank or artistic wear placements were added. [The practical guide](../environment-authoring/eaf4-wear-authoring-guide.md) covers exact paths, labels, orientation, scale/offset, shader interactions, duplication, source switches/defaults, visibility, save/reopen, corners and troubleshooting.

All seven existing Road Dust helpers remain at `ReceivingSetDressing/ReceivingDecals/ReceivingFinishPass`, with the exact preflight authored values and transforms. Their inherited Task 1 resource change subscriptions update nested Spec edits live and reuse the existing saved Quad instead of doubling geometry. Hide only `ReceivingWear_Floor` and `ReceivingWear_LiftZone`; leave ReceivingSignage and the finish root visible. The accepted label SVG/material/geometry/placement and its surrounding scene content were preserved.

## Guard change

The existing Receiving dressing allowance remains restricted to the exact legacy EnvironmentWearOverlay script in the two established wear groups; its unrelated infrastructure checks were retained. A test-only support validator is called for the explicit new AuthoredWear root. It permits directly scene-owned plain Node3D organization and the exact EnvironmentWearAuthoring script with valid approved settings and one unscripted, ownerless generated Quad. It rejects arbitrary scripts, additional children/meshes, collision shapes/bodies/areas, lights and cameras, including content nested inside a helper. No production/gameplay validator or runtime authority was added.

Positive probes cover a new source, duplicate, dimension/source/visibility edits, reparenting between room groups and a new FutureRoom group. Negative probes cover seven forbidden node classes, a nested arbitrary script, a script on Quad and incorrect helper scene ownership. No list of placement names/counts is used by the guard.

## Automated and runtime evidence

Commands ran from `D:/Godot Projects/Sorting-apoc-PROTOTYPE` using Godot `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe` and bundled Python `C:/Users/Boschetar/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.

```powershell
$G = 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe'
$P = 'C:/Users/Boschetar/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $P -m unittest discover -s tools/environment_authoring/wear_repository/tests -v
& $P -m unittest discover -s tools/environment_authoring/wear_catalog/tests -v
& $P -m unittest discover -s tools/environment_authoring/material_catalog/tests -v
& $P tools/environment_authoring/wear_catalog/build_presets.py --check
# Each headless row below:
& $G --headless --path . --script <script-path>
& $G --path . --rendering-method gl_compatibility --script tools/asset_pipeline/tests/receiving_lift_crt_tests.gd
& $G --path . --rendering-method gl_compatibility --script tools/environment_authoring/wear_catalog/tests/test_wear_presets_render.gd
& $G --headless --editor --path . --import
git diff --check
```

| Headless script under `tools/` | Result |
| --- | --- |
| `environment_authoring/wear_catalog/tests/test_wear_presets.gd` | PASS: 224 checks, all 11 mappings, initialization, root controls/restrictions, orientation, duplication, live source/size/appearance, materials/default/wrapper isolation and disk parent-instance roundtrip; one Quad after reopen/runtime |
| `asset_pipeline/tests/wear_authoring_workspace_tests.gd` | PASS: 30 checks, positive/negative guards, legacy live edits, wear-only hiding/signage retention, one visual per legacy helper |
| `environment_authoring/wear_catalog/tests/test_wear_authoring.gd` | PASS: 63 Task 1 checks including programmatic UndoRedo, script-default-valued saved overrides, invalid/boundary values |
| `environment_authoring/wear_catalog/tests/test_wear_authoring_fixture.gd` | PASS: instance roundtrip and original Receiving source transforms |
| `environment_authoring/wear_catalog/tests/{test_wear,test_wear_human_catalog,test_wear_rerun,test_material_patch_scale,test_wear_live_refresh}.gd` | PASS, all five retained suites |
| `asset_pipeline/tests/{wing_startup_parity_tests,wing_gameplay_composition_tests}.gd` | PASS; existing deliberate duplicate-seed rejection diagnostics retained |
| `asset_pipeline/tests/{receiving_infrastructure_integration_tests,receiving_set_dressing_collision_tests,receiving_lift_installation_tests,receiving_deck_presenter_tests}.gd` | PASS, all four retained suites |
| `asset_pipeline/tests/receiving_lighting_integration_tests.gd` | PASS: 126 checks |

Python PASS: 23 wear-repository + 20 wear-catalog (including eight new audit failure/drift tests) + 17 material-catalog = **60 tests**. Preset audit `--check`: PASS. RED evidence: initially 0/11 library coverage and missing AuthoredWear/guard; then 11 missing usage-note assertions; an additional wrong-owner probe failed before tightening ownership. Final focused runs pass. One-shot rebuild does not delete obsolete wrappers: it reports them for explicit review; missing/stale dependencies block before any partial library writes.

Real OpenGL uses NVIDIA GeForce RTX 5060 Ti, Compatibility API 3.3. CRT PASS: configured UID and explicit wing launches each produce 704x400 pixels and 4,041 green samples. The wear render probe uses the canonical wing's actual environment with in-memory floor Oil Stain and wall Chipped Paint instances, temporary camera/tint/opacity edits, and no saved scene changes. At 640x480 it measures 2,136 floor and 436 wall changed samples after the edit; one Quad per helper and signage visibility assertions PASS. This is runtime rendering evidence, not editor interaction or artistic approval.

## Editor evidence and limitations

**Actual editor interaction and screenshots: NOT RUN.** The [computer-use skill](C:/Users/Boschetar/.codex/plugins/cache/openai-bundled/computer-use/26.1007.21434/skills/computer-use/SKILL.md) initialized and returned a Godot Project Manager window. Initial capture failed with `FrameArrived timed out: timed out waiting on channel`; a fresh window-selection/capture retry failed with `window capture timed out: timed out waiting on channel`. Its referenced [guidance](C:/Users/Boschetar/.codex/plugins/cache/openai-bundled/computer-use/26.1007.21434/docs/guidance.md) says, “Refresh the app/window selection and retry once; report the exact error if recovery fails.” After the prescribed fresh selection and single retry, no captured UI state was available to support input. No screenshot, drag, Inspector edit or editor undo/redo was fabricated. The canonical scene is available for the precise [hands-on workflow](../environment-authoring/eaf4-wear-authoring-guide.md#hands-on-acceptance-still-required).

Headless editor import reaches **Editor layout ready**, exit 0, but clean shutdown FAILS with 21 retained ObjectDB instances / 12 resources and VariantPools diagnostics, repeating Task 1's known limitation. All Godot runs retain the pre-existing Windows root-certificate-store diagnostic. Programmatic save/reload/UndoRedo and runtime pixel evidence do not establish native editor interaction acceptance.

The additional real-renderer wear probe has passing render assertions, but its custom-main-loop shutdown emits substantial RID/ObjectDB/resource retention diagnostics; clean shutdown is not PASS and verbose inspection and independent review found no leaked wear scripts or scene nodes, and no straightforward missing free in this harness. Retained resources belong to the existing item/seed graph; causality remains unproven. No unrelated gameplay/engine repair is authorized here.

## Protected content and commit isolation

Byte comparisons PASS for all four initial contents: the three non-wing dirty files are unchanged, and removal of exactly the new AuthoredWear block restores the wing's entire 139,053-byte preflight file and SHA256. All 36 snapshotted catalog/spec/decision/shader/signage/source-scene files are also unchanged. This protects furniture/collision/light/CRT/signage overrides and the original local Road Dust changes as complete serialized content, not just node counts. Retained wing suites cover runtime consequences.

Changed files: 11 lightweight preset scenes and coverage README; one-shot `build_presets.py` and eight Python tests; read-only usage notes in Task 1's authoring component; the nine-line empty wing group block; narrow infrastructure-suite call plus test-only support guard and workspace suite; all-preset/runtime render tests and UID sidecars; practical guide, plan and this report. Independent read-only review found no implementation blocker and verified all 39 unique protected-file hashes. It identified that forbidden-type probes could pass solely on missing ownership. This was treated as a verification gap under the explicit negative-test requirement: probes now have correct scene ownership and assert the authority diagnostic. A separate ignored guard mutant with type rejection removed produces exactly seven failures; the real guard passes all 30 checks. No production guard relaxation was made. Staging/commit isolation inspection follows below.

## Human acceptance checklist

- [ ] In the actual wing editor, drag one floor and one wall preset into AuthoredWear and confirm live root controls under actual scene lighting.
- [ ] Duplicate normally, edit the copy, switch its source, toggle approved defaults, undo/redo, save/close/reopen and launch; verify independence and one visual per helper.
- [ ] Edit an existing Road Dust Spec; hide only both old wear groups and confirm the accepted emergency-stop label remains visible.
- [ ] Capture genuine editor before/after views, remove test-only placements, then review a few intentional placements for cause, scale, overlap and appearance.

Stop at this local technical checkpoint for human authoring review. No push, merge, publish, EAF4 approval change, artistic acceptance or Receiving C1 closure.


## Review rulings

- Continue in the existing checkout and implement the supplied approved design directly, without an additional worktree/approval pause: explicitly requested by the user. Cost if wrong: the task patch remains locally reviewable and independently staged.
- Treat the review's minor negative-test observation as a required verification correction because rejection must be demonstrated for the right reason. Correct-owner mutation proof now passes; no deferred minor remains.
- Native editor behavior stays NOT RUN; no assumption replaces capture failure. Artistic layout acceptance stays with the human. Pre-existing scene edits are protected without judging their design. No future material-patch editor/guard compatibility is claimed. Existing item/seed retention repair is out of scope; clean shutdown remains failed/unresolved, with its diagnostic evidence retained.

## Final index inspection

The index contains exactly 28 Task 2 files. `git show :gameplay/logistics_wing/wing_gameplay.tscn` reproduces HEAD's entire wing byte stream after removing only the nine-line AuthoredWear block; this proves none of the pre-existing 540 additions / 104 deletions are staged. Removing the same block from the working file reproduces the entire preflight dirty file. The other three protected dirty files are not staged and match their original byte hashes. No reset, discard or stash was used. The local Task 2 commit is a direct child of `99fc745`.
