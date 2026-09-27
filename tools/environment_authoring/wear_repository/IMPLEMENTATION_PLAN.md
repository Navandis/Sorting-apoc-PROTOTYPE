# EAF4A implementation plan and execution record

Authority: user's 27 September 2026 EAF4A handoff (47 sections); baseline
`ff49662e26f84048150fc1d720fc6186d743cb2d`. One primary implementer in the
authoritative checkout, branch `codex/eaf4a-wear-source-index`; optional read-only
source explorer. No merge/push. Final gate: PROMOTE EAF4A / REVISE EAF4A.

## Design and interfaces

Independent Python subsystem under this directory. Do not refactor EAF3.
`path_guard.Repository` owns every source enumeration/stat/open; only local config
chooses the production root. Tests inject a synthetic Repository. Archives never
enter content records or fingerprints. Reports/cache stay under the ignored
project report directory. Original tiny fixtures only are tracked.

`profiles` recognizes positive metadata/layout/map evidence, `image_facts` inspects
headers and one efficient alpha variant per channel, `unreal_instance_parser`
retains missing/null/zero/override states. No assumed Unreal parent defaults.
`source_index.scan(repository)` emits portable families/candidates and quick
signatures. `query_index` emits stable-ID-only manifests. `build_triage_sheets`
validates source paths/signatures again and creates cached source previews,
grouped sheets, City audit and Unreal summary. No Godot runtime or curation state.

## Work and verification

1. Boundary/config and original fixtures: test traversal, absolute/different drive,
   real junction, root contract, unopened archives and manipulated index before
   implementing the independent EAF3-style guard.
2. Profiles/index/parser: fixture tests establish expected classes, map vocabulary,
   multiresolution grouping, alpha/size/tileability, Unreal missing/None/0, atlas
   grouping/manual fallback, portable IDs, changed/removed/diff behavior. Implement
   modules against these tests after representative live-source inspection.
3. Triage: test conjunctive filters, stale/invalid ID manifests, preview channel and
   alpha/crop behavior, cache invalidation, grouped manifests and City categories.
   Implement CLI and contact sheets, preserving unknowns.
4. Run synthetic unittest suite, live guarded scan, unchanged rescan, bounded live
   candidate audit, representative queries/sheets/cache reuse, Godot headless editor
   parse. Inspect output images. EAF3 regression only if shared code changes.
5. Author README/schema/validation; assemble ignored shareable review package with
   derived sheets/manifests/statistics/audit only, no commercial source textures.
   Review full diff, commit implementation then validation evidence; stop at human
   review pending, without EAF4B, EAF5 or Receiving C1.

## Review focus

- Archive contents never opened, hashed, previewed or made candidates.
- No path from config/index/Unreal metadata can bypass containment.
- Source facts differ from weak name suggestions and later artistic decisions.
- Missing Unreal opacity does not erase alpha; None differs from zero and missing.
- Atlas crop needs recorded UV semantics, not plausible arithmetic alone.
- Root migration preserves IDs/fingerprints; resolution does not split identity.

## Execution record

- Preflight: clean baseline matched all three refs. Requested branch created.
- Ruling: use the user's detailed promoted design and explicit implementation
  authorization as scope; no additional design/plan approval milestone. Use this
  compact record instead of a generic per-task ceremony (AI_WORKING_GUIDELINES).
- Ruling: independent guard modeled on EAF3; no shared utility refactor or EAF3 scan.
- Completed: representative source inspection (Megascans, generic TGA/PBR,
  imperfection exports, City and Unreal) and independent EAF4 guard/config.
- Completed: original fixture suite, profiles/index/parser, query and triage.
  First missing-feature runs failed; the final suite passes 23 tests. Concrete
  corrections covered punctuation preservation, path checking before stale-cache
  handling, multiformat grunge grouping, conflicting metadata, and standalone alpha.
- Ruling: Unreal Select/CellSize values do not record shader UV semantics; all 13
  live logical entries remain manual metadata cases. Crop support is proven only
  with an explicit normalized convention fixture. Never infer Unreal metres.
- Ruling: 63 City sets and seven other surface-like PBR sets lack sufficient
  tileability/localization evidence. Keep UNKNOWN, with a NEEDS MORE PROFILE
  SUPPORT City recommendation. Definite EAF3 routing is covered synthetically.
- Completed: live scan (1,221 content files, 92 ZIPs ignored), unchanged rescan
  (160/170 families/candidates unchanged), 26 current contact pages, 22-entry live
  audit, 8/8 cache reuse, Godot editor integrity parse. EAF3 code was untouched.
- Review: primary implementer performed the source-boundary/profile/index/preview
  review, consistent with the user limiting other agents to source exploration.
- Remaining close-out: commit implementation and validation, assemble ignored
  human-review ZIP, stop with HUMAN REVIEW PENDING. No merge/push or next gate.
