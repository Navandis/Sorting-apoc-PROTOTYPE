# Review-scene supply reuse validation

**Branch:** `codex/review-scene-supply-reuse`

**Baseline:** synchronized local and `origin/main` at `e7af7c103f35905f77a41f7ed078e4042455d5b4`

**Status:** automated checks pass; human review is pending.

## Result

`wing_gameplay.tscn` remains the sole authority for the composed development palette. The shelf ergonomics review instantiates `wing_gameplay.tscn` off-tree, detaches its composed `DevelopmentSetup`, frees the unused gameplay root, and then adds only that detached setup to the active review tree. The existing `SeedRegistrar` initializes after the setup enters the review scene, preserving the authored table/host transforms and `wing_seed_v1` identities.

The active `CabinetTakeSamples` path and its cabinet-only status text are retired. The historical cabinet sample scene and script remain unchanged in the repository, and the clothes-cabinet visual remains part of the A/B/C comparison.

## Focused verification

Run on 20 September 2026 with Godot 4.7 stable:

| Check | Result |
| --- | --- |
| `shelf_ergonomics_review_tests.gd` | PASS for A/B/C. Confirms exactly one reused setup, composed table/host and transform parity, one registration and `WorldItem` per eligible host, Fuel availability, Gloves/Pants exclusion, no cabinet fixture or temporary gameplay subtrees, Fuel TAKE, review-shelf auto/manual/rotation/stack/retrieve paths, and retained F5/F6/F7 contracts. |
| `wing_gameplay_composition_tests.gd` | PASS. The two duplicate-namespace error diagnostics are intentional rejection cases in the suite. |
| Headless editor scan | Exit 0; scripts and resources load. |
| Explicit `shelf_ergonomics_review.tscn` smoke | Exit 0; case A initializes eight functional review surfaces. |
| Default project launch smoke | Exit 0; `wing_gameplay.tscn` initializes twelve functional surfaces. |

All runs emitted the existing Windows root-certificate-store diagnostic. No task-specific unexpected error was reported.

Protected-file checks confirm `wing_gameplay.tscn` and `project.godot` remain unchanged from the baseline. The project main scene remains UID `uid://bljf1nlhijej`, resolving to `wing_gameplay.tscn`.

## Human review

Launch the explicit review scene:

```powershell
& 'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe' --path . --rendering-method gl_compatibility res://gameplay/logistics_wing/review/shelf_ergonomics/shelf_ergonomics_review.tscn
```

Verify that the normal gameplay tables and complete eligible palette appear at their authored wing coordinates; representative small, tall, flat, irregular, and stackable items can be carried to the review fixtures; auto/manual placement, rotation, stacking, and retrieval still work; the old cabinet-only samples are absent; and A/B/C, F5, and F6 remain normal. Return **PROMOTE** or **REVISE**.
