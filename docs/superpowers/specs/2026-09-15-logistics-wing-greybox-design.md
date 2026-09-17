# Logistics-Wing Greybox Design

**Date:** 2026-09-15
**Status:** Approved handoff translated into a repository-grounded design
**Authority:** `D:\Godot Projects\Codex Handoff\01_MILESTONE_BRIEF.md`, Visual Direction v0.3, Basic Structural Schematic V2, Detailed Topology V3, and the local preflight recorded below

## Outcome

Build a separate, complete, first-person greybox of the accessible Quartermaster logistics wing. The deliverable establishes scale, enclosure, circulation, gallery legibility, facility spacing, fixed boundaries, representative proxy massing, and reproducible review evidence. It does not implement physical Receiving, facility interiors, production environment art, item systems, progression, or the broader settlement.

The original `main.tscn`, default main-scene setting, shared gameplay scripts, catalogue data, ignored asset library, and rejected Receiving branch remain unchanged.

## Verified local baseline

- Repository: `D:\Godot Projects\Sorting-apoc-PROTOTYPE`
- Feature branch: `codex/logistics-wing-greybox`
- Base: local `main` at `8ee62bd3bc4f23918717517e066d4c6a8cb565df`, synchronized with `origin/main` at preflight
- Preserved rejected branch: `codex/receiving-elevator-stage-b-pass1-shell` at `c9752c8c68cd55b950dd588542ea271e1acc0aab`
- Preserved rejected scene: `receiving/freight_bay_prototype.tscn`, absent from the feature branch as expected
- Godot: `D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe`, version `4.7.stable.official.5b4e0cb0f`
- Renderer/physics: GL Compatibility, Jolt Physics
- No Godot/editor process and no tracked/index changes were present before switching branches. The rejected branch's generated `reports/receiving/` evidence remains locally present and untracked; it must not be deleted or committed.
- Baseline editor scan and original main-scene runtime exited 0. Both emitted the known local root-certificate diagnostic. Main registered 31 trimesh and 9 convex collision meshes, 16 deterministic storage surfaces, and 87 prototype WorldItems.
- Thirty non-hanging test suites each exited 0 and printed one `PASS:`. `storage_pose_content_tests.gd` reproduced the known `loot_000015` assertion. The two duplicate-definition/path diagnostics occur inside tests that deliberately exercise rejection behavior. The legacy `main_scene_loot_audit_integration_tests.gd` reproduced exactly three known assertions and required the established 25-second bounded termination.

## Reused player contract

`main.tscn` owns an inline `CharacterBody3D` subtree rather than a reusable PackedScene. The review harness will make a faithful review-local scene containing only the required subtree:

- `CharacterBody3D` using `res://player_controller.gd`
- child `CollisionShape3D` with capsule radius `0.34 m`, total height `1.75 m`, centered `0.875 m` above the body origin
- child `Camera3D` at the effective `main.tscn` transform, with eye height `1.7162851 m`, default `75°` FOV, and one active camera
- child `CarriedItems` using `res://carried_items.gd`
- movement speed `4.0 m/s`, sprint multiplier `2.0`, acceleration `18.0`, deceleration `24.0`, gravity from project settings, and unchanged mouse sensitivity/look limits

The review copy keeps the original scripts read-only. It disables prototype loot auto-registration, registration logging, and the held-item visual locally because the review scene contains no gameplay loot; these are disclosed harness-only bindings, not movement/camera/collision changes. The generated interaction HUD remains available, Escape releases the mouse, and a click recaptures it.

## Scene and file boundaries

| File | Responsibility |
| --- | --- |
| `greybox/logistics_wing/review_player.tscn` | Faithful review-local copy of the required player subtree. |
| `greybox/logistics_wing/build_wing_geometry.gd` | One-purpose, editor-only scene builder containing the explicit authored dimensions and named primitive calls. It is the regeneration source of truth, not a general level generator. |
| `greybox/logistics_wing/wing_geometry.tscn` | Generated, editor-inspectable structural primitives, aligned collisions, proxy massing, district roots, anchors, and topology metadata. |
| `greybox/logistics_wing/wing_review.tscn` | Independently runnable scene instancing the geometry and one review player, plus neutral lighting/environment and diagnostic area IDs. |
| `greybox/logistics_wing/wing_capture.gd` | Review-local reproducible capture helper with fixed view manifest and roof-visual toggle. |
| `greybox/logistics_wing/wing_capture.tscn` | Capture-only scene instancing the review scene and fixed capture cameras. |
| `tools/asset_pipeline/tests/logistics_wing_geometry_tests.gd` | Geometry/topology/player/default-launch contract and negative-connection checks. |
| `tools/asset_pipeline/tests/logistics_wing_capture_tests.gd` | Capture gating, manifest, image normalization, and contact-sheet contract. |
| `docs/testing/logistics-wing-greybox-validation.md` | Baseline, launch steps, dimensions, route observations, evidence index, exceptions, burden record, and pending human decisions. |

The builder uses hard-coded, named calls for this wing only. It may regenerate only `wing_geometry.tscn` via one documented command. Generated nodes remain ordinary `MeshInstance3D`, `StaticBody3D`, `CollisionShape3D`, `Marker3D`, and `Label3D` nodes visible in the editor. There is no runtime-only geometry, layout solver, modular kit, or second editable layout truth.

## Coordinate and dimensional hypothesis

Godot world axes are used directly: east is `+X`, south is `+Z`, floor level is `Y=0`. One metre in the scene is one metre in the design notes.

- Overall first-pass occupied envelope: approximately `104 m` east-west (`X=-42..62`) by `53 m` north-south (`Z=-24..29`)
- Ordinary clear height: `3.4 m`; Receiving clear height: `4.2 m`
- Structural wall thickness: `0.30 m`; floor/ceiling thickness: `0.30 m`
- Normal open thresholds: `2.4–3.2 m`
- Narrow shared corridor: `3.0 m`; ordinary shared corridor: `4.0 m`; widened circulation/backlog: `5.0–7.6 m`
- Sorting table proxy: approximately `2.6×0.9×1.45 m`, informed by the measured `SM_Table` envelope of `2.585×0.885×1.477 m`
- Representative shelf proxy: approximately `3.0×2.7×0.9 m`, informed by the measured `SM_MetalShelves` envelope of `3.227×2.936×1.097 m`; selected low freestanding proxies are shorter to preserve visibility
- Player capsule: `0.68 m` diameter. The target minimum proxy-constrained clear lane is `1.2 m`, with most primary circulation at least `2.0 m` after massing.

These values are provisional authoring hypotheses, not final geography. They remain centralized and editable in the one-purpose builder.

## Topology and spatial composition

### Western logistics core

Receiving occupies the west end. The freight recess is wide, shallow, enclosed on three sides, and separated from the apron by a fixed waist-to-chest-height barrier with collision. It has no lateral surface route. Dispatch is a shallow north-wall alcove. Backlog is wider and asymmetrical, with a few non-interactive edge masses that preserve a clear through-lane.

Sorting is a widened passage rather than a room. A wide wall-backed table proxy sits on the north side. The work anchor is composed so a roughly quarter-turn exposes the Receiving passage and a half-turn exposes the early Storage route. The exact perceived angles will be judged in the captured player-height views, not claimed from the schematic alone.

### Storage network

The primary Storage spine makes one restrained offset and changes width. Galleries A–E are partially enclosed, differ in proportion, and remain attached to that spine. C and D alone share a short secondary opening. E is single-entry and has a complete east/south boundary, preventing a shortcut to the Deeper-Bunker Approach.

Each gallery includes representative wall-fitted shelf envelopes. Selected pockets include only low freestanding massing where the clear lane remains credible. Gallery labels are diagnostic only and do not assign item categories.

### Facility/service branches

- Medical branches from shared circulation between A/B and receives a clear protected approach with no shelving or backlog. It has an opaque frontage and no Kitchen connection.
- Kitchen branches from shared circulation near B through a separated bend and has a longer opaque frontage than Medical.
- Workshop/Salvager leaves shared circulation near Sorting/early Storage with one bend and local widening. Workshop is an opaque frontage; Salvager is a discoverable terminal spur dominated by a front-operated machine proxy.
- A separate blocked former service continuation extends shallowly beyond the Workshop leg and is closed by visible obstruction geometry.

### Eastern approach

The Deeper-Bunker Approach begins as a wider shared corridor, narrows through an orthogonal dog-leg, and does not present a straight Storage-to-Ops vista. The Incinerator occupies its own terminal spur before the dog-leg's final approach; ordinary corridor separates it from Bunker Ops. The machine proxy is front-operated and fills most of its pocket.

Bunker Ops is a modest side frontage on the final shared condition. A distinct opaque closure at the east end terminates the deeper-settlement route. The closure does not pass through an office and is not presented as an abandoned route.

## Construction and review language

All geometry is neutral primitive massing. Floors, walls, ceilings, closures, shelf/table/machine envelopes, and backlog/edge blocks receive a small muted material set that separates structure from collision-relevant proxies without implying Applied Finish. Neutral WorldEnvironment ambient light, one directional key, and broad local fill lights provide even review exposure. There are no imported environment meshes, PBR materials, dressing, gameplay items, facility interiors, working shutters, physical piles, or atmospheric art.

Ceiling meshes are grouped below `RoofVisuals`. The top-down capture hides only that visual root; saved default visibility remains on and collision remains unchanged. All first-person evidence is ceiling-on at the preserved eye height/FOV.

## Verification design

Automated contracts verify:

1. the player copy retains baseline movement, camera, and collider values;
2. required district roots, anchors, proxies, blockers, and open thresholds exist;
3. declared adjacency contains Receiving→Backlog→Sorting→Storage, all five galleries, C↔D, facility/service branches, Incinerator, Bunker Ops, and deeper closure;
4. forbidden adjacency is absent: E→Deeper, any other gallery shortcut, gallery-mediated facility access, Medical↔Kitchen, and lateral Receiving surface access;
5. floors/ceilings/collision boxes use finite positive dimensions and the geometry scene reloads;
6. `project.godot` still launches `main.tscn` and protected gameplay/catalogue files are unchanged from the base;
7. capture output names, dimensions, roof state, and contact-sheet layout are deterministic.

Automated topology is supplementary. The implementation also requires actual saved-scene rendering, normal-controller traversal in the running review scene, representative route timing, inspection of all captures, and correction of visible or collision defects. Teleports used by capture cameras do not count as traversal evidence.

## Evidence and stop condition

The evidence set contains one roof-hidden debug overview, ceiling-on first-person coverage of every district and boundary, fixed Sorting comparison views, full-resolution PNGs, and readable contact sheets under `reports/logistics_wing/greybox/`. The validation record identifies each camera position/target/FOV, capture resolution, renderer, roof state, measured dimensions, normal-walk route method/times, and any estimated routes.

First-pass delivery stops after a complete verified wing is committed and presented for human walkthrough. Human spatial review, workflow promotion, and revision reliability remain `PENDING`. No feedback is invented and no functional Receiving or environment-art work begins.
