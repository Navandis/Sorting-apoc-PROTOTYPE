# EAF4 imperfection decision/export extension — local checkpoint

10 October 2026. Infrastructure only on `codex/receiving-c1-label-wear-pass`, starting at `f80bba9020846070daf5470dcd4c675b9a5eeeb5`. Live origin/main was rechecked as `a331b6175fb0bda0f2fac7ce89744c321088c675`; Godot is `4.7.stable.official.5b4e0cb0f`. No live approvals, scene composition, source textures or published milestone documents changed. Receiving C1 remains open.

## Canonical contract and legacy policy

The old export preferred roughness over opacity and unconditionally set `modulation_only: true`. All eleven reviewed opacity sources also have different roughness maps. A fingerprint covering both maps and free-text restrictions could not select the approved pattern or distinguish its uses.

New imperfection decision templates expose exactly:

- `scalar_channel`: `opacity.red` or `roughness.red`.
- `supported_uses`: nonempty, unique array from `TINTED_OPACITY_LAYER` and `WEAR_OPACITY_MODULATION`. Export order follows this listed order.

Templates leave both fields empty and remain PENDING until a human decision. Tinted opacity means an independently placed flat scalar layer. Modulation remains limited to the two approved SOFT_BLEND Leakage effects, `skiubhzc` and `tculfbnc`. Grayscale is diagnostic. Roughness inputs are repurposed scalar distribution, with no physical substrate roughness or base-material approval. Mask decisions cannot also claim a material patch or dependent overlay. Masks never become conventional wear specs/presets.

`workflow.mask_scope` has a deliberate legacy read path for original Grunge `tedxadjc`: exact stable ID, derived catalog ID, reviewed fingerprint, 1K resolution, revision 1, APPROVED state, IMPERFECTION_MASK category and SOFT_BLEND mode must match, with both new fields absent. That path resolves only `roughness.red` / `WEAR_OPACITY_MODULATION`. Unannotated reconciliation is allowed only for an exact reapplication of existing trusted human fields. An unannotated new approval or revised Grunge approval fails. Old deferred records remain readable; no historical revision or live record was migrated.

Non-mask templates and catalog semantics stay valid. Indexed non-mask sources cannot claim mask scope. New decision catalog IDs must equal the deterministic ID derived from their source identity; a caller-supplied Leakage ID cannot authenticate an unrelated target.

## Files/APIs and consumer audit

Production changes are confined to `tools/environment_authoring/wear_catalog/workflow.py` and `cli.py`.

`validate_decision_sources(repository, index, decisions, catalog)` is a read-only CLI preflight: indexed source class, scope, selected resolution, exact unambiguous channel availability, guarded originals and strong fingerprint must agree before canonical writes. No alternate channel/resolution is substituted. Pure `reconcile` preserves monotonic revision and effective freshness rules; CLI reconciliation passes the actual index and runs original-source validation first. Scope changes require a higher revision. APPROVED source intent alone does not establish current provenance.

`stage_candidate(..., dry_run=True)` describes maps without copying them. `expected_fingerprint` rejects source changes before destination mutation; copied bytes are also hashed before replacement. Approved staging supplies the reviewed/planned anchor. `restage_approved` validates every mask and dependent resource and prepares all output text before any canonical writes. Invalid scopes/maps or changed approved mask provenance leave canonical files unchanged.

`restage_approved(output_dir=..., dry_run=...)` and CLI `--output-dir` / `--dry-run` allow isolated verification. Scratch output does not rewrite the canonical catalog/specs/cache. CLI scratch destinations must be project-local; use the existing ignored `.gdignore`-protected reports root. Unchanged generated resource text is not rewritten, preserving exact existing bytes/line endings.

Approved mask exports retain `texture`, source/catalog identity and fingerprint, and add `scalar_channel`, `supported_uses`, `scalar_sha256`. `modulation_only` is true exactly for modulation-only use. The existing Godot test consumer uses the old keys and tolerates additions; old generated records without new keys remain readable. The preset builder excludes IMPERFECTION_MASK. The experiment builder/component and separate manifest/cache remain unchanged, including their exact two-effect selection. No other export consumers were found.

Dependent conventional overlay generation requires a current approved mask with matching resolution/fingerprint and modulation permission, then uses its selected channel. Target restriction uses the authenticated staged identity. Both historical Leakage specs continue binding the exact same Grunge roughness texture. The old live `approved_masks.json` remains byte-identical in this infrastructure task; its next authorized restage will add compatible metadata. No shader, geometry, editor control, wrapper path, scene reference or conventional preset changed.

Tests changed: new `tests/test_mask_scope.py`, existing `tests/test_workflow.py`, and `tools/asset_pipeline/tests/{imperfection_workspace_tests,wear_authoring_workspace_tests}.gd`. Workspace assertions now accept valid saved instances and check preservation of saved signage visibility. All strict script/native-authority rejection probes and guards remain intact.

## Hypothetical sixteen-source proof and subsequent recipe

The actual guarded inventory matches every current manifest row: sixteen genuine 1K identities/fingerprints/maps, eleven opacity.red and five roughness.red. Live statuses remain one APPROVED, one DEFERRED, fourteen UNREVIEWED. The human acceptance supplied in the brief has not been applied to the canonical data in this task.

In-memory decisions and temporary output prove all sixteen bindings with both uses, producing sixteen masks and eleven conventional specs. Every scalar hash matches its audited channel; repeated exports are identical. Full hypothetical decisions/exports are in `reports/environment_wear_catalog/imperfection_extension/hypothetical_sixteen_export.json` and are explicitly test evidence, not human decisions. Example future export:

```json
{
  "catalog_wear_id": "eaf4b_7861a882827158cab9937196",
  "source_stable_id": "eaf4:IMPERFECTION_TEXTURE_PROFILE:dust_uh4qbeic:uh4qbeic",
  "source_fingerprint": "64cc7e145ecf460d0d7d0b939dad716ed3fe1e5f103fb2ccb579bdb88a97b0a1",
  "texture": "res://assets/environment/wear/eaf4_cache/eaf4b_7861a882827158cab9937196/1k/opacity.jpg",
  "modulation_only": false,
  "scalar_channel": "opacity.red",
  "supported_uses": [
    "TINTED_OPACITY_LAYER",
    "WEAR_OPACITY_MODULATION"
  ],
  "scalar_sha256": "e9ff86689c0fe9816f92c2d02988c3fb02078cf0d1241d508c8e94e3d09de577"
}
```

For the separately authorized approval/cleanup task:

1. Re-audit originals through the single configured EAF4 repository and snapshot freshly saved scenes.
2. Generate a dated human decision manifest via `decision_template`, with exact audited channel/1K anchor, both bounded uses and the actual human review notes. Grunge and Scratched Metal require revision **2**; the fourteen unreviewed sources require new revision **1** records. Leave unrelated decisions unchanged. Do not reuse hypothetical review notes as human evidence.
3. Validate the entire manifest using `validate_decision_sources`, then reconcile through the existing CLI. Check a dry-run and isolated export before authorized canonical restaging. Compare all sixteen channel/hash/scope records, all eleven conventional spec bytes and both historical Leakage bindings.
4. Rebuild/check the existing experimental manifest after real status changes, preserving wrappers/paths/controls/shaders. Signage extraction/seven-patch retirement remains a separate saved-scene preservation and visual task. The request to restore the accepted plaque to visible remains pending; this checkpoint leaves its hidden finish parent intact.

```powershell
& $P -m tools.environment_authoring.wear_catalog.cli reconcile --decisions <dated-project-local-human-manifest>
& $P -m tools.environment_authoring.wear_catalog.cli restage-approved --dry-run
& $P -m tools.environment_authoring.wear_catalog.cli restage-approved --output-dir reports/environment_wear_catalog/<ignored-scratch-directory>
# Only in the subsequently authorized task, after comparisons:
& $P -m tools.environment_authoring.wear_catalog.cli restage-approved
```

## Verification evidence

Raw argv, exits and logs are under `reports/environment_wear_catalog/imperfection_extension/`. `suite_results.json` records the original sweep; `additional_results.json` records corrected workspace/render/editor runs; `catalog-final.log` contains the final Python catalog run. Python is `C:/Users/Boschetar/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`; Godot is `D:/AI Tools/Godot-4.7-Codex/Godot_v4.7-stable_win64_console.exe`.

| Check | Result |
| --- | --- |
| Initial focused RED | Two failures: wrong scalar file and false modulation-only labeling; `red.log` |
| Review regressions RED | Target-ID spoof and accepted-cache overwrite each reproduced before correction; separate red logs retained |
| Python repository/catalog/material suites | **23 + 41 + 17 = 81 PASS**; final catalog exit 0 |
| Both one-shot audits / current CLI dry-run | PASS; **11 specs / 1 legacy mask**, no writes |
| Runtime imperfection / presets / live authoring | **159 / 224 / 63 checks**, zero failures |
| Wear fixture, overlays, human catalog, rerun, material-patch scale, live refresh | All PASS |
| Corrected imperfection / approved workspace suites | **30 / 30 checks**, zero failures; all rejection probes retained |
| Actual Compatibility OpenGL imperfection proof | **50 checks**, zero failures; sixteen sources and both established effects |
| Actual OpenGL CRT UID / explicit scene | **704 x 400**, **4041 green samples** each, zero failures |
| Wing startup parity/composition; Receiving infrastructure/collision/lighting/lift/deck | All PASS; lighting **126 checks**; two intentional duplicate-seed diagnostics retained |
| Editor import/parse and editor-hint component | Exit 0, **159** component checks; shutdown diagnostics remain |
| Native editor interaction/capture | **NOT RUN** in this schema task |

The initial workspace failures were pre-existing stale assumptions about an empty branch and visible signage, despite the saved human placements and hidden parent. Original failing logs remain. Corrected tests preserve the saved state rather than retuning the room.

Editor shutdown is not clean: import reports **21 ObjectDB / 12 resources** and VariantPool pages; editor-hint tests report **221 ObjectDB** plus retained editor RIDs. Windows root-certificate diagnostics remain. No engine cleanup or invented editor-interaction evidence is claimed.

## Preserved work and local commit scope

All **109** snapshotted catalog/decision/spec/helper/preset/finish and protected dependencies remain byte-identical. The saved wing retains all **17** human instances with exact scene bytes, transforms and controls, the seven legacy patches and accepted plaque. The four original dirty files remain unstaged, with identical hashes:

| Protected path | SHA256 |
| --- | --- |
| `data/environment/receiving_proof/eaf5_review_control.png.import` | `621de3c3b065ad001b9c30d7c72f98fa046535feb69f5119061c508edcd280ea` |
| `data/environment/receiving_signage/lift_emergency_stop.svg.import` | `78eb4b8bcb44e55f5388ae1946d9236ea27468431d6594a82e2879e2d1f187a7` |
| `data/receiving/receiving_deck_stage_b_proof.tres` | `33914e658f2873175218fa4e809bf34af883480242f15c20a1d4658d6f349868` |
| `gameplay/logistics_wing/wing_gameplay.tscn` | `2d752a65b61d1002a16b50fa3975114d8d2f57c5919066d3b4ae085e3063753f` |

`preflight.json`, original byte snapshots/diffs and `preservation_after.json` record the comparisons. Only seven task-owned files are committed: workflow, CLI, the new mask-scope tests, existing workflow tests, two workspace test scripts and this report. No approval/catalog/spec/scene or commercial binary is staged. No push, merge, rebase, branch deletion or automatic continuation follows.

The decision-model blocker is resolved. Source approvals and Receiving finish cleanup await human review of this technical checkpoint; Receiving C1 is not complete or published.
