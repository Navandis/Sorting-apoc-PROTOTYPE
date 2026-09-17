# Logistics wing greybox closeout validation

**Closeout date:** 17 September 2026
**Repository:** `Navandis/Sorting-apoc-PROTOTYPE`
**Accepted branch:** `codex/logistics-wing-greybox`
**Accepted source/evidence:** `aeb1ef27671f2f07d651e5064b00c3c77a06600b`
**Final Medical documentation checkpoint:** `8d64086aa02ade21449af24dbc7742748115792c`

This record owns the fresh local test and repository-synchronization claims for
the human-approved whole-wing neutral greybox. Dated construction reports keep
their original pre-approval status and are not rewritten.

## Starting repository state

The authoritative checkout was the normal asset-bearing repository at
`D:\Godot Projects\Sorting-apoc-PROTOTYPE`, on
`codex/logistics-wing-greybox` at `8d64086...`. Local `main` and freshly
fetched `origin/main` both resolved to
`8ee62bd3bc4f23918717517e066d4c6a8cb565df` with ahead/behind `0/0`.
Both were ancestors of the accepted branch. The intended remote URL was
`https://github.com/Navandis/Sorting-apoc-PROTOTYPE.git`.

The accepted source commit was an ancestor of the branch. Rejected branch
`codex/receiving-elevator-stage-b-pass1-shell` remained at
`c9752c8c68cd55b950dd588542ea271e1acc0aab` and was not an ancestor of the
accepted branch. It was not merged or published by this closeout.

The only pre-task worktree content outside Git was the expected historical
`reports/logistics_wing/` and `reports/receiving/` evidence. No reset, stash,
clean, force checkout or history rewrite was used.

## Current documentation installation

The supplied package manifest was verified before installation: all 26 listed
files matched both byte counts and SHA-256 hashes. No mapped destination
already existed, so no newer local document was replaced.

| Current authority | Repository path | SHA-256 |
| --- | --- | --- |
| GDD v0.8 | `docs/Sorting_Apocalypse_Preliminary_GDD_v0.8.docx` | `af0fe64fcefed746d0eb1038bfbf00d6c90984bcc138547cb6595691cffe84f6` |
| VDD v0.5 | `docs/Sorting_Apocalypse_Visual_Design_Direction_v0.5.docx` | `94c34df7b93758db3495258fea1cc999318c85affc3b92725cf5d745b3e9533d` |
| Findings v0.8 | `docs/Sorting_Apocalypse_Prototype_Findings_v0.8.docx` | `5f31fc14e6a4f70a3c06087e441aa879f9ef1bd8317ef779233fe2b6e3a7cef5` |
| GDD readable extract | `docs/readable/Sorting_Apocalypse_Preliminary_GDD_v0.8.md` | `76d4980e2bd21991dd12111a720ebbfc2e89cf866b82a10cc779487fb5f485fb` |
| VDD readable extract | `docs/readable/Sorting_Apocalypse_Visual_Design_Direction_v0.5.md` | `d576d5671b1291567e51ab043784d89333179f8178b0d176a6389fdb7b82df40` |
| Findings readable extract | `docs/readable/Sorting_Apocalypse_Prototype_Findings_v0.8.md` | `953f3a644f8d0c90fe7fd3e61108c0ca2d2b2ab23a0362a9b32f894288ae0fe7` |

`docs/README.md` is the single current documentation index and
`docs/CURRENT_STATE.md` is the single current status owner. Historical v0.4
and v0.3 DOCX files, amendments, plans, specs and validation reports remain in
place. The readable Markdown and five VDD media files are exact derived copies
from the package, not competing editable authorities.

After the inherited four whitespace issues were removed, staged diff checking
reports only three trailing-space markers on lines 3–5 of the supplied
acceptance Markdown. Those spaces are the package's intentional Markdown hard
breaks and were retained so the installed acceptance record stays byte-exact
with package SHA-256
`e622b6fdd7b1ad2247dbb941162b54cf124ceb3d39e05edc7d7b61049e533b5b`.

The compact accepted evidence is under
`docs/testing/evidence/greybox-accepted-2026-09-17/`, with a source and
checksum index, static checks and the accepted overview. The human acceptance
record is `docs/testing/logistics-wing-greybox-acceptance-2026-09-17.md`.

## Local evidence preservation and ignore policy

Before changing ignore policy, the two trees were inventoried:

| Local tree | Files | Bytes | Contents |
| --- | ---: | ---: | --- |
| `reports/logistics_wing/` | 378 | 35,252,253 | 176 PNGs and imports, 18 JSON records, two Markdown indexes, two baseline scenes, one comparison helper, two review ZIPs |
| `reports/receiving/` | 14 | 14,809,714 | seven rejected-shell PNGs plus Godot import sidecars |

The authorized root-specific `/reports/logistics_wing/` and
`/reports/receiving/` rules were added. `git check-ignore -v` resolves both
trees to those exact rules, and post-change counts confirm the files remain
present. No blanket `/reports/`, ZIP, Markdown or media rule was added.

The accepted full review bundle remains local at
`D:\Godot Projects\Sorting-apoc-PROTOTYPE\reports\logistics_wing\greybox\revision_04\logistics_wing_medical_tuning_review_bundle.zip`
with SHA-256
`ca98bb36be4b4cbb0bc0ef2e60199ca395b35f18920db3693b71f4fb62ca2490`.
Ignored evidence and ignored `assets/` are not represented as GitHub backups.

## Accepted source and protected-content checks

All five accepted wing sources and all three focused test files match the
SHA-256 values recorded at `aeb1ef2...`. The accepted geometry scene itself
remains byte-identical. The only `.tscn` hygiene change removes one final
blank line from the capture harness scene; its parsed properties and UID
references are unchanged.

Diffs from the earlier main base are empty for `project.godot`, `main.tscn`,
`player_controller.gd`, `carried_items.gd`, `data/` and the authoring review
manifest. Default launch remains `uid://drbkr86g3cxl1`. No storage, stacking,
catalogue, item-authoring or Receiving implementation was changed.

The four inherited branch diff-check findings were confirmed to be exactly
two Markdown trailing-space markers and one final blank line in the original
greybox design record, plus one final blank line in `wing_capture.tscn`.
Only those four whitespace issues were removed; no broad formatter was run.

## Fresh pre-integration verification

| Check | Result |
| --- | --- |
| Three focused wing suites | PASS as part of the established regression run; each exited 0 with exactly one PASS line and no unexpected diagnostics. |
| Established non-hanging regression set | PASS — 33/33 scripts exited 0 with exactly one PASS line. |
| Expected negative-test diagnostics | Exact expected set only: two item-catalog duplicate diagnostics, one Receiving duplicate-path diagnostic and the known storage-pose assertion at line 143. |
| Editor/parser initialization | Exit 0; filesystem initialization reached DONE. The bounded editor exit reported its normal scan-thread-aborted warning. |
| Wing review-scene smoke | PASS, exit 0. |
| Original default-main smoke | PASS, exit 0; 31 trimesh meshes, 9 convex meshes, 16 deterministic storage surfaces and 87 world items registered. |
| Normal-controller replay | PASS — 22/22 routes, 12/12 boundary probes, zero failures. |
| Accepted traversal evidence preservation | PASS — immutable revision-04 result stayed SHA-256 `72e3050519f4ea0d0a64a44c67f5364d16ebcf51e1d664c302b26e3672c63064` before and after. |
| Bounded legacy integration audit | Existing exception reproduced after 25 seconds: exactly two `_assert_summary` assertions at line 179 and one `_init` assertion at line 95; the process remained long-running and was terminated. This is not a pass. |

The fresh traversal used an ignored closeout-only copy of the accepted helper
whose sole change is its output path. Results are at
`reports/logistics_wing/closeout_2026-09-17/traversal_results.json`; the
accepted revision-04 file was not overwritten.

Godot emitted the known Windows root-certificate-store diagnostic during
successful commands. The project checks use no network feature.

## Integration and final synchronization

Bookkeeping commit
`55397bdbdc37a826731629f85ad7f0218b2dcc2a` was created on
`codex/logistics-wing-greybox`. Before publication, `origin` was fetched again
and remained at the inspected main baseline. The following gates all passed:

- `origin/main` was an ancestor of the accepted branch;
- accepted source `aeb1ef27671f2f07d651e5064b00c3c77a06600b` and accepted
  Medical documentation `8d64086aa02ade21449af24dbc7742748115792c` were ancestors;
- rejected Receiving commit
  `c9752c8c68cd55b950dd588542ea271e1acc0aab` was not an ancestor; and
- the worktree was clean and protected-path diffs remained empty.

The feature branch was pushed normally to the intended repository. Local
`main` then fast-forwarded with `--ff-only` to `55397bd...`. On integrated main,
the 33/33 non-hanging regression set, original-main smoke and wing-review
smoke passed again; the default UID stayed unchanged, protected-path diffing
remained empty and the rejected commit remained excluded. A final pre-push
fetch found no divergence, and `main` was pushed normally.

After the first synchronization and its confirming fetch, local/remote `main`
and local/remote `codex/logistics-wing-greybox` all resolved to
`55397bdbdc37a826731629f85ad7f0218b2dcc2a`; `main...origin/main` was `0/0`
and the worktree was clean. No force option, history rewrite, protection
bypass, branch deletion, stash, clean or reset was used.

Only after that equality was established, the supplied seeded-storage bridge
preflight was performed. Its read-only dependency report is
`docs/testing/wing-storage-integration-preflight.md`. The final
documentation-only commit containing that report and this synchronization
record is identified in the external closeout handoff because a commit cannot
embed its own final SHA. That commit is synchronized by the same guarded
feature-then-`--ff-only`-main sequence and reverified before closeout.

## Status gate

- Greybox spatial baseline: **PROMOTED by human review**.
- Bookkeeping publication and first main integration: **PASS**.
- Seeded-storage dependency preflight: **COMPLETE**.
- Seeded-storage bridge implementation: **NOT STARTED**.
- Default-scene migration: **NOT STARTED**.
- Functional Receiving: **NOT STARTED**.
