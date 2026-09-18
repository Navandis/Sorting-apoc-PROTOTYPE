# Continuing gameplay — default-entry close-out validation

**Validated:** 18 September 2026
**Branch:** `codex/wing-storage-bridge`
**Synchronized starting main:** `1491fd729f3237706ad9533274b7525f6b058932`
**Saved-scene checkpoint:** `d359ab6ce1ea9ff72d3e0f9a60cfeeb5da3025bf`
**Default-entry implementation:** `ea96777f5a094aa785f8b2f8d7a492034792f41e`
**First verified integration:** `c1c570c3a683b0ad1f21d023066829e8f1e4eb29`

## Result and bounded scope

The accepted continuing scene is the normal development entry through `application/run/main_scene="uid://bljf1nlhijej"`, resolving to `res://gameplay/logistics_wing/wing_gameplay.tscn`. The historical `res://main.tscn` and neutral `res://greybox/logistics_wing/wing_review.tscn` remain intact and explicitly loadable.

This close-out checkpoints the developer's accepted saved scene, records the human PROMOTE decisions, updates only the affected launch contract and current records, and synchronizes the accepted branch and `main`. It does not repair content, expand the palette, change shelf or ceiling heights, add production art or begin Receiving.

## Saved authoring authority

Before any launch change, the modified working scene was recorded and committed by itself. The captured LF payload and raw committed blob both have SHA-256 `eb260b07795edc0975e7c1a21706ef72a6494b9ceb8ccde24cc5f43f6f66d3e9`; its Git blob is `e53b4b6eb48540cd229868962a785baccffcdd8b`. The scene contains fourteen saved hosts, including `Book2` (`loot_000030`) and `CDStack_B2` (`loot_000031`), plus the developer's moved and 90-degree-rotated East table at `(-6.0698276, 0, -1.65)`.

The Windows checkout has global `core.autocrlf=true` while the repository declares `* text=auto`. A later branch checkout therefore materialized the unchanged 6,692-byte LF blob as a 6,808-byte CRLF working file (SHA-256 `e3b90bd934c6b84e8a9283c4c955eab5544c982246fa191ab4ec86bad6858619`). `git status` remains clean and the path-filtered working hash still resolves to the accepted blob. This is a checkout representation difference, not a scene edit; the published Git payload is byte-identical to the captured authority.

The fixed twelve-host regression fixture remains separate. No restore, reset, content repair, seed expansion or mass reimport occurred.

## Human acceptance

The earlier broad handling/editor-authorship review and all three focused F6 checks are PROMOTE. The installed [acceptance record](wing-gameplay-foundation-acceptance-2026-09-18.md) preserves the developer's conclusions and the limits of promotion without rewriting the dated implementation reports.

## Launch and regression verification

Godot `4.7.stable.official.5b4e0cb0f` was used for fresh verification.

- The launch test failed first against the old `main.tscn` default, then passed after the one-line `project.godot` promotion.
- The affected launch contract verifies the configured UID, its path mapping, root name `WingGameplay`, one player, one carried-items HUD, all fourteen accepted seed hosts, and explicit loadability of the legacy and neutral scenes.
- Normal launch with no `--script` and no explicit scene exits 0, loads `wing_gameplay.tscn`, and reports twelve functional surfaces, F6 default OFF and F7 disabled.
- Parser/editor initialization and explicit wing, legacy-main and neutral-review smokes exit 0 without script or parse failures. Legacy main still reports its historical sixteen surfaces.
- All 39 non-hanging `*_tests.gd` scripts exit 0 with exactly one PASS each. Their 52 diagnostic lines match the established ledger, including the inherited Fuel Canister content assertion and intentional negative tests.
- The bounded legacy audit was stopped after 25 seconds with no PASS and reproduced its three inherited assertion stacks: `_assert_summary` line 179 twice, called from lines 72 and 73, and `_init` line 95 once. It remains a known exception, not a pass or repaired condition.

The normal launch was also recorded for two rendered frames at 1920×1080 using `gl_compatibility` on an NVIDIA GeForce RTX 5060 Ti. `default_entry00000000.png` and `default_entry00000001.png` are byte-identical with SHA-256 `3f1ebf01abc4df6bca5ac780064de7a3a065f0a161d2b86b15346797bf2303da`. The capture and process logs remain ignored under `reports/logistics_wing/storage_bridge/closeout/`; they are review evidence, not production assets.

## Generated sidecar disposition

The six pre-existing Godot `.import` sidecars beside committed documentation/evidence PNGs are reproducible local metadata. Six exact paths are ignored in `.gitignore`; no blanket `*.import` rule was added, no sidecar was deleted or staged, and the existing tracked `icon.svg.import` policy is unchanged.

## Preservation and publication

`project.godot` changes only the `application/run/main_scene` assignment. Protected gameplay behavior, catalogue/data, accepted geometry, `main.tscn`, neutral review, historical evidence and rejected Receiving history remain preserved. Licensed/imported `assets/`, `.godot/`, ignored reports and private/bulky evidence are excluded from publication.

The protected Git objects below are byte-identical between the accepted F6 tip `2b00d5d612e8ec74e8a09f1620469c54552a15e8` and the implementation checkpoint:

| Protected path | Git object |
|---|---|
| `main.tscn` | `58ff1d13d7a1d989a184836dea157fbde45c825d` |
| `greybox/logistics_wing/` | `8c4b7acafa406d8c40b9a6c6882ccc55c0febd9f` |
| `receiving/` | `251f07eb6aee74cbad6cb248261974ab01043fb2` |
| `data/` | `064b5ab2a67cd05574db46452ae6a20f901d3bcf` |
| `item_catalog.gd` | `b4edda2b346c0be9e4f30dee836c179527803858` |
| `player_controller.gd` | `ab59d4f2bac989cda029f3468ced62aa388a50ff` |
| `storage_placement_controller.gd` | `1b58b2fb8654b8d4d0c28ba3084bf20295cdb4d3` |
| Curated accepted greybox evidence | `187c943240a83889489ba1a66525860ae7b2485d` |

After a fresh fetch, local `main` and `origin/main` both remained at `1491fd729f3237706ad9533274b7525f6b058932`. That revision is an ancestor of the feature tip; the rejected Receiving commit `c9752c8c68cd55b950dd588542ea271e1acc0aab` is not. The accepted foundation, evidence, F6 and saved-scene checkpoint commits are all in the linear feature history.

The authorized GitHub repository is public and its default branch is `main`. The outgoing audit found nineteen commits and fifty-two changed paths at the implementation checkpoint: forty-six additions, six modifications, no deletions, and 330,432 bytes of tracked payload. No changed file exceeds 1 MiB; no credential-like filename, `assets/`, `.godot/` or ignored `reports/` content is present.

## Guarded synchronization result

The feature branch was published first at `c1c570c3a683b0ad1f21d023066829e8f1e4eb29`. A fresh fetch proved the remote feature matched exactly and `origin/main` was still the synchronized starting revision. Local `main` then fast-forwarded from `1491fd729f3237706ad9533274b7525f6b058932` with `--ff-only`; no merge commit was created.

On integrated `main`, all 39 non-hanging suites again exited 0 with one PASS each and the same 52 expected diagnostics. Normal default launch, explicit legacy main, explicit neutral review and the focused F6 suite all exited 0. A fresh pre-push fetch showed no upstream movement, after which `main` was pushed normally. The post-push fetch showed local/remote feature and local/remote main all equal to `c1c570c3a683b0ad1f21d023066829e8f1e4eb29`, with ahead/behind `0/0` for both branches.

This concluding documentation-only update is propagated through the same guarded feature-push, `--ff-only` local-main update and normal main push. The final containing revision is the common feature/main tip; both remote refs are re-fetched and required to match it with `0/0` divergence before close-out is reported complete. No force-push, protection bypass, branch deletion or rejected-branch publication is used.
