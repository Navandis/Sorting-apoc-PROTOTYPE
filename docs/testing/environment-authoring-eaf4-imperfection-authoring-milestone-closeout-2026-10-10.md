# EAF4 wear and imperfection authoring — accepted milestone close-out, 10 October 2026

**Status: IMPLEMENTED / TECHNICALLY VERIFIED / HUMAN-ACCEPTED.** This documentation-only close-out publishes the accepted tooling/source milestone through controlled non-force main publication. **Receiving C1 remains IN PROGRESS**; its final wear composition is not accepted for publication. No Stage C, new gameplay, art placement, lighting or material tuning is included.

## Human acceptance and published scope

The human explicitly confirmed in this conversation on 10 October that the emergency-stop plaque is visible and unchanged, exactly seven original Codex Road Dust patches are absent, all seventeen local authored layers remain editable/render correctly, and manual F5/F6, collision, lift and CRT work correctly. Earlier actual-editor acceptance covers the live wear/scalar workflow and accepted decision/export extension. These are **human-reported checks**, distinct from Codex's fresh automated results below. Codex did not perform native Inspector interaction or manual F5/F6 during this close-out (**NOT RUN by Codex**).

Published accepted content consists of:

- **11 conventional approved standalone wear presets** at `res://environment_authoring/wear/presets/`, with live independent Inspector controls, duplication and save/reopen behavior. [Practical wear guide](../environment-authoring/eaf4-wear-authoring-guide.md).
- The separate **16-source scalar authoring library** at `res://environment_authoring/wear/imperfection_experiments/presets/`, retaining its existing paths/names, controls and render modes. Exact reviewed inputs are **11 opacity.red + five roughness.red**. Roughness is a scalar distribution only, not physical substrate roughness. [Scalar-layer guide](../environment-authoring/eaf4-imperfection-audition-guide.md).
- All sixteen source decisions support `TINTED_OPACITY_LAYER` and `WEAR_OPACITY_MODULATION`. Modulation currently targets only the two existing approved SOFT_BLEND effects `leakage_skiubhzc` and `leakage_tculfbnc`. Grayscale remains diagnostic. No substrate shader/normal/roughness integration, new wear family or individual placement approval is implied. The [genuine canonical decision manifest](../../data/environment/wear_catalog/decisions/2026-10-10-eaf4-imperfection-scoped-human-review.json), [catalog](../../data/environment/wear_catalog/catalog.json) and [approved_masks.json](../../data/environment/wear_catalog/approved_specs/approved_masks.json) remain the established authorities/outputs; this report creates no second approval list. Fresh count is **28 records: 27 current APPROVED, one DEFERRED paint remnant xetubap**. Conventional preset count remains eleven.
- The accepted original plaque in `res://gameplay/logistics_wing/receiving/receiving_emergency_stop_signage.tscn` at `ReceivingSetDressing/ReceivingDecals/ReceivingSignage/LiftEmergencyStopLabel`: unchanged SVG/material/0.32 × 0.14 m geometry/world transform, now independently visible. The old `receiving_finish_pass.tscn` and all seven rejected Codex dust helpers are intentionally retired. The red button remains decorative.

Detailed implementation and source/scene preservation evidence remains in the [059531a approval/retirement checkpoint](environment-authoring-eaf4-imperfection-approvals-and-receiving-finish-retirement-2026-10-10.md), [decision extension](environment-authoring-imperfection-decision-extension-2026-10-10.md), [audition report](environment-authoring-imperfection-audition-2026-10-10.md) and [preset/authoring Task 2 report](environment-authoring-eaf4-presets-task2-2026-10-10.md). Historical pending source/editor statements are superseded by the genuine later decisions and human acceptance without rewriting their original evidence.

## Publication boundary and protected local work

Preflight checked out `codex/receiving-c1-label-wear-pass` at accepted tip **059531a3181343f174ea2b1b0b4fa436c19252c0**, descending linearly through `280c4e8`, `f80bba9`, `6051e83`, `99fc745`, and `0709192`. Local main, fetched origin/main and freshly queried live remote main all started at **a331b6175fb0bda0f2fac7ce89744c321088c675**, an ancestor of feature HEAD. The index was empty; exactly four tracked dirty paths and no untracked user changes were present. Other registered worktrees are detached; local main was not checked out.

The committed HEAD wing and the working scene were inspected independently. **Committed/published `AuthoredWear` and `ImperfectionExperiments` roots have no placed instances** (AuthoredWear retains its empty room organization groups), with accepted standalone signage and no legacy finish/dust. **All seventeen authored instances exist only in the dirty working scene**, including intentionally hidden layers and source selections that differ from instance names. Their exact identities/full serialized blocks and SHA256 hashes are recorded in fresh local `manual_inventory.json`; all seventeen blocks match preflight after the entire test sweep. They are not part of this documentation commit or the published tree. Other existing local art/serialization deltas and dirty proof/import resources remain unstaged.

Fresh raw byte snapshots, `git diff --binary`, committed-scene bytes, dependency/UID inventories and all logs are under ignored, `.gdignore`-protected `reports/environment_wear_catalog/milestone_publication_2026_10_10/`. Existing evidence was not overwritten. No `.tscn` copy or duplicate production UID was introduced under Godot scan paths.

| Protected file | Before / after SHA256 (identical) |
| --- | --- |
| `data/environment/receiving_proof/eaf5_review_control.png.import` | `621de3c3b065ad001b9c30d7c72f98fa046535feb69f5119061c508edcd280ea` |
| `data/environment/receiving_signage/lift_emergency_stop.svg.import` | `78eb4b8bcb44e55f5388ae1946d9236ea27468431d6594a82e2879e2d1f187a7` |
| `data/receiving/receiving_deck_stage_b_proof.tres` | `33914e658f2873175218fa4e809bf34af883480242f15c20a1d4658d6f349868` |
| `gameplay/logistics_wing/wing_gameplay.tscn` | `b1bd3296a58c5a8677f844615b7fb9bfd099cfb3709f5ecf9d3b078b7117c0a9` |

All four raw files and all seventeen blocks are unchanged after checks. All **917 non-document tracked files** match their fresh preflight hashes, including catalog/approvals/specs/shaders/imports/scenes/tests. Commercial wear originals and caches remain ignored (193 local dependency paths inventoried); none is staged or pushed. UID sanity finds **zero duplicates across four tracked declared scene UIDs**, including the configured main UID `uid://bljf1nlhijej`. Scene-load/editor import and existing composition/authority tests pass.

## Fresh verification

Verified Godot **4.7.stable.official.5b4e0cb0f**, Compatibility OpenGL API 3.3 on NVIDIA GeForce RTX 5060 Ti. All **28 commands below exit 0**, with passing assertions. Raw full argv, durations and statuses are in local `suite_results.json`; read-only real-manifest `workflow.validate_decision_sources(load_repository(), load_index(), decisions, catalog)` also passes. Current mask exports agree with the guarded sixteen-source inventory on identity, fingerprint, exact channel/use and original/cache SHA256. No canonical reconcile, staging build or production resource write was performed in this documentation-only run.

Executable bindings used for the commands:

```powershell
$P = 'C:/Users/Boschetar/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
$G = 'D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe'
```

| Check | Actual command | Exit |
| --- | --- | --- |
| editor_import | `& $G --headless --editor --path . --import` | 0 |
| wear_repository_python | `& $P -m unittest discover -s tools/environment_authoring/wear_repository/tests -v` | 0 |
| wear_catalog_python | `& $P -m unittest discover -s tools/environment_authoring/wear_catalog/tests -v` | 0 |
| material_catalog_python | `& $P -m unittest discover -s tools/environment_authoring/material_catalog/tests -v` | 0 |
| experimental_audit | `& $P -m tools.environment_authoring.wear_catalog.build_imperfection_experiments --check` | 0 |
| approved_preset_audit | `& $P tools/environment_authoring/wear_catalog/build_presets.py --check` | 0 |
| test_imperfection_audition | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_imperfection_audition.gd` | 0 |
| test_wear_presets | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_wear_presets.gd` | 0 |
| test_wear_authoring | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_wear_authoring.gd` | 0 |
| test_wear_authoring_fixture | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_wear_authoring_fixture.gd` | 0 |
| test_wear | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_wear.gd` | 0 |
| test_wear_human_catalog | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_wear_human_catalog.gd` | 0 |
| test_wear_rerun | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_wear_rerun.gd` | 0 |
| test_material_patch_scale | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_material_patch_scale.gd` | 0 |
| test_wear_live_refresh | `& $G --headless --path . --script tools/environment_authoring/wear_catalog/tests/test_wear_live_refresh.gd` | 0 |
| imperfection_workspace_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/imperfection_workspace_tests.gd` | 0 |
| wear_authoring_workspace_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/wear_authoring_workspace_tests.gd` | 0 |
| wing_startup_parity_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/wing_startup_parity_tests.gd` | 0 |
| wing_gameplay_composition_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/wing_gameplay_composition_tests.gd` | 0 |
| receiving_infrastructure_integration_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/receiving_infrastructure_integration_tests.gd` | 0 |
| receiving_set_dressing_collision_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/receiving_set_dressing_collision_tests.gd` | 0 |
| receiving_lighting_integration_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/receiving_lighting_integration_tests.gd` | 0 |
| receiving_lift_installation_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/receiving_lift_installation_tests.gd` | 0 |
| receiving_deck_presenter_tests | `& $G --headless --path . --script tools/asset_pipeline/tests/receiving_deck_presenter_tests.gd` | 0 |
| receiving_lift_crt_tests | `& $G --path . --rendering-method gl_compatibility --script tools/asset_pipeline/tests/receiving_lift_crt_tests.gd` | 0 |
| audition_editor_hint | `& $G --headless --editor --path . --script tools/environment_authoring/wear_catalog/tests/test_imperfection_audition.gd` | 0 |
| imperfection_opengl | `& $G --path . --rendering-method gl_compatibility --script reports\environment_wear_catalog\milestone_publication_2026_10_10\imperfection_render.gd` | 0 |
| wear_presets_opengl | `& $G --path . --rendering-method gl_compatibility --script tools/environment_authoring/wear_catalog/tests/test_wear_presets_render.gd` | 0 |

The real imperfection render script was copied into the ignored evidence folder with **only its output directory constant redirected**; no tracked test or assertion changed. This preserves prior runtime captures. The Godot-import and game tests use the actual canonical working scene, retaining its local art; separate committed-text/tree checks establish that publication excludes that art. Automated startup parity uses the configured main UID versus explicit wing launch; it does not impersonate native F5/F6 interaction.

Python suites pass **23 repository + 41 catalog + 17 material tests**. Both one-shot audits are **check-only**. Godot audition passes **159 checks** in runtime and editor-hint modes; presets **224** across eleven sources, live authoring **63**, imperfection workspace **30**, approved workspace **25**, lighting **126**. Fixture/live-refresh/save-reopen/independence, catalog/approved mask status, strict authority-negative checks, wing composition/startup, Receiving infrastructure/collision/lift/deck all pass. No guard or test was weakened.

Real OpenGL imperfection rendering passes **50 checks**, covering sixteen patterns and both Leakage/Grunge paths. CRT renders **4,041 green samples** at 704×400 for configured-main and direct-wing launches. Conventional wear render passes with **2,136 floor / 436 wall** changed samples. These are runtime rendering assertions, not artistic judgments or native-editor screenshots.

The two intentional duplicate-seed rejection diagnostics remain in the composition negative test. The pre-existing Windows root-certificate-store error remains unresolved. Editor import reaches layout ready but retains **21 ObjectDB / 12 resources** plus VariantPools; editor-hint audition retains RID allocations and **221 ObjectDB** instances. The conventional wear custom-loop render still reports **452 ObjectDB / 400 resources** and RID/GL retention. Passing assertions/exit codes do not mean clean shutdown; these known pre-existing/unattributed diagnostics were not repaired or reclassified as fixed. Imperfection and CRT render tests have no additional retention diagnostics. No unexpected failure occurred in this sweep.

## Documentation commit and controlled publication

Only these four explicit documentation paths enter the close-out commit:

- `docs/CURRENT_STATE.md`
- `docs/CODEX_BOOTSTRAP.md`
- `docs/README.md`
- `docs/testing/environment-authoring-eaf4-imperfection-authoring-milestone-closeout-2026-10-10.md`

The full staged patch is documentation-only; all four protected paths, every manual instance block, commercial originals/caches and unrelated art are excluded. `git diff --check` and `git diff --cached --check` pass. The documentation commit is a direct child of accepted `059531a`; all source/tooling changes were already in the accepted history. No gameplay/test/scene/spec/shader/catalog/asset edit is made by this close-out.

Publication uses a fresh compatible-ancestry check and ordinary **non-force** `git -c http.sslBackend=openssl push origin HEAD:refs/heads/main`, while leaving the dirty feature checkout in place. The command-local OpenSSL backend avoids the workstation's prior Schannel credential failure; certificate verification is not disabled and global Git/credential settings are unchanged. No merge, rebase, branch switch/deletion, reset, stash, clean, PR or feature-branch push is included. Live remote/fetched origin/main must read back as the documentation commit. Local main can advance by `git update-ref refs/heads/main <published-HEAD> <verified-old-local-main-SHA>` only while not checked out anywhere and with verified ancestor/compare-and-swap conditions. No checkout files are replaced.

The publication SHA is the documentation commit introducing this record; the run's final response and ignored `publication_result.json` carry exact verified refs and command outcomes. The final verification rechecks empty index, feature checkout, committed scene with zero manual instances, all seventeen working instance blocks and all four original hashes. A dirty worktree is the intended result.

## Portability and next human action

Git publication includes accepted code/scenes/catalog decisions and documentation, **not a complete commercial source-art archive**. Obtain the actual licensed originals for the existing single configured guarded EAF4 repository, reproduce its source index and explicitly stage/check selected maps through the existing workflow; let Godot import the local caches. The two [coverage indices](../../environment_authoring/wear/presets/README.md) / [scalar coverage](../../environment_authoring/wear/imperfection_experiments/README.md) and authoring guides document the commands. No alternate source-root search, replacement imagery or redistribution license is implied.

The human's next action is to re-verify the seventeen-layer Receiving composition and personally accept it, then authorize a **separate explicit scene/art commit**. Until then all placements and other dirty resources remain local; Receiving C1 stays IN PROGRESS and Stage C remains out of scope. Stop after this accepted-milestone publication and report; no automatic artistic close-out or further implementation.
