# EAF3A implementation plan

Authority: approved 26 September user handoff; baseline b15f5bb; one implementer on codex/eaf3a-material-repository-index. Project proportionality rules govern process. No merge/push, EAF3B, EAF4, material staging or Receiving C1 work.

Architecture: Python 3.12/Pillow, guarded source reader, format profile, portable index/diff, deterministic queries, cached basecolor sheets. Production root comes only from the local config.

- [ ] Boundary: failing config/containment tests, guard implementation, guarded bounded real-layout inspection.
- [ ] Index: synthetic fixtures and failing classification/grouping/identity/diff tests, profile and scanner implementation.
- [ ] Triage: failing query/cache/manifest tests, query and contact-sheet implementation.
- [ ] Evidence: full synthetic suite, live scan and unchanged rescan, 2–4 inspected sheets, sample audit, performance/warnings, requested Godot parse, final diff review and local commits.

Review focus: junctions/symlinks, root migration, duplicate stems, unknown suffixes, packed maps, stale preview signatures and batches. Final validation records commands, results and implementation decisions.
