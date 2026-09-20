# Sorting Apocalypse — Reusable Functional Modular-Rack Authoring Design

**Date:** 20 September 2026  
**Status:** Design approved in conversation; written-spec review pending  
**Target project:** `D:\Godot Projects\Sorting-apoc-PROTOTYPE`  
**Current promoted baseline:** `08d958d225b1fc5c3eb5335c42ceceec8ca75437`

## 1. Purpose

Create one reusable Godot modular-rack authoring component around:

- `res://assets/environment/furniture/storage/SM_Rack01.glb` — blue structural frame;
- `res://assets/environment/furniture/storage/SM_Rack02.glb` — independently positioned shelf platform.

The component must let the developer author a rack by editing the physical furniture they care about while the storage backend follows automatically.

The desired workflow is:

1. Place or duplicate one `ModularRack` scene/object.
2. Set rack length, front-to-back depth and frame height at the rack root.
3. Duplicate/delete plain shelf-level child nodes to choose the number of levels.
4. Move each shelf-level child vertically to choose its support height.
5. Set modest per-edge usable-area insets when needed.
6. Set one installation-level overhead limit when the top shelf must respect a ceiling/beam.
7. Save and run.

The developer must **not** manually add `StorageSurface` nodes, recalculate surface offsets, type per-level clearances, attach scripts to every shelf level, or rebuild placement grids after changing rack geometry.

This is a permanent storage-authoring feature. It is not a ladder-specific helper.

## 2. Scope and authority

The developer retains final authority over:

- rack placement in the bunker;
- model use;
- overall rack dimensions;
- level count;
- vertical level distribution;
- usable-area insets;
- ladder availability and placement later.

The component supplies derived gameplay geometry and validation. It does not choose a “correct” rack configuration.

Existing storage mechanics remain authoritative:

- deterministic 2D storage;
- 0.10 m world-cell target;
- Storage Zones;
- auto/manual placement;
- 90-degree packing rotation;
- deterministic support stacking;
- physical vertical-clearance checks;
- F6 developer-grid presentation;
- canonical loot scale.

No new storage engine is introduced.

## 3. Reusable scene structure

Recommended reusable path:

`res://gameplay/logistics_wing/storage/modular_rack.tscn`

with its root script beside it.

Conceptual scene hierarchy:

```text
ModularRack                    # Node3D, @tool authoring component
├── Frame                      # plain Node3D wrapper
│   └── Visual                 # SM_Rack01.glb
├── Levels                     # plain Node3D container
│   ├── Shelf_01               # plain Node3D; developer moves this in Y
│   │   └── Visual             # SM_Rack02.glb
│   ├── Shelf_02
│   │   └── Visual             # SM_Rack02.glb
│   └── Shelf_03
│       └── Visual             # SM_Rack02.glb
├── OverheadLimit              # Marker3D / derived visual handle
├── MovementCollision          # StaticBody3D
│   └── Shape                  # unit-scale CollisionShape3D
└── [editor-only derived preview]
```

There is **one authoring script on the rack root**.

`Shelf_XX` nodes are intentionally plain `Node3D` wrappers. No per-level script is required. Their local Y is the developer-authored support height. Their local X/Z and rotation are derived/aligned by the rack component.

The supplied review-scene instance must have its children editable so the developer can immediately duplicate/delete/move `Shelf_XX` nodes without extra setup.

When a completely fresh `ModularRack.tscn` instance is placed elsewhere, use Godot’s normal editable-child mechanism if necessary rather than building a custom editor plugin merely to bypass that native workflow.

## 4. Authoring coordinate convention

The reusable rack exposes a normalized local convention independent of the source GLB axes:

- local **X** = rack length, left ↔ right;
- local **Y** = vertical;
- local **Z** = front ↔ back;
- local **-Z** = the rack’s authored front.

The imported Rack01/Rack02 visuals may be rotated/offset inside their wrappers once during source calibration so the developer never has to reason about their original asset axes.

The `ModularRack` root may be translated and yaw-rotated in the world.

The root must remain unit scale. Overall dimensions are changed through rack properties, not by scaling the complete root. Pitch/roll and non-unit root scale are unsupported authoring states and should produce clear editor/runtime warnings rather than silently corrupting storage geometry.

## 5. Root authoring properties

The initial component should expose only properties that represent real developer decisions:

- `rack_length_m`
- `rack_depth_m`
- `frame_height_m`
- `usable_inset_left_m`
- `usable_inset_right_m`
- `usable_inset_front_m`
- `usable_inset_back_m`
- `overhead_limit_local_y_m`
- optional `show_authoring_preview`

Do not expose a competing `level_count` property. The count of direct `Levels/Shelf_*` children **is** the level count.

Do not expose duplicate per-level width/depth/clearance fields.

The 0.10 m storage-cell target remains an existing system constant, not a routine rack-authoring control.

### Horizontal dimensions

Measure the source Rack01 and Rack02 geometry once.

`rack_length_m` and `rack_depth_m` derive horizontal scale factors from the calibrated Rack01 source dimensions. Apply the corresponding horizontal factors coherently to:

- Rack01 frame visual;
- every Rack02 platform visual;
- coarse movement collision;
- derived usable shelf rectangles.

Preserve the source family’s relative frame/platform proportions rather than independently forcing every mesh to the same raw AABB size.

### Frame height

`frame_height_m` changes the blue Rack01 structure vertically.

It does **not** automatically redistribute shelf levels.

Shelf platforms retain their normal physical thickness; do not Y-scale Rack02 merely because frame height changes.

The frame may intentionally extend above the highest functional platform.

## 6. Shelf-level authoring

Each direct child of `Levels` is one authored functional platform.

The developer changes the rack by:

- duplicating a `Shelf_XX` wrapper;
- deleting one;
- dragging one vertically;
- renaming it if desired.

The rack component owns alignment in X/Z and platform visual calibration. Only the wrapper’s Y is meaningful author input.

Sort levels by support height for clearance calculation, but do **not** derive persistent surface identity from the sorted index. A level moved past another level should not silently exchange identity with it.

Use the rack node name plus shelf-level node name as the current authored surface identity, consistent with the project’s existing name-derived fixture identities. Validate uniqueness.

## 7. One-time Rack02 calibration

Calibrate Rack02 so the `Shelf_XX` wrapper origin represents the **physical top support plane** of that platform.

The child visual is positioned relative to that origin so:

- its deck top is at local Y = 0;
- its physical thickness extends below the support plane;
- its transformed deck bounds provide the base horizontal rectangle used for storage derivation.

This calibration is performed once in the reusable asset/component. The developer does not author support offsets per rack or per level.

The same measured geometry supplies the next-shelf underside used for vertical clearance.

## 8. Derived storage layout

The root component should centralize its geometry calculation in one method/data structure, conceptually:

`compute_layout() -> rack + level specifications + validation`

Both editor preview and runtime storage creation use the same derived specifications. Do not duplicate the dimension/clearance math in separate editor/runtime paths.

For each valid level derive:

- stable surface ID;
- support-plane world/local transform;
- usable rectangle width/depth;
- usable rectangle center shift caused by asymmetric edge insets;
- physical vertical clearance;
- authoring warnings/errors.

### Usable-area insets

Insets operate on the calibrated Rack02 platform rectangle.

They are independent per edge.

This allows, for example:

- a small rear inset that pulls the far row forward;
- side clearance around uprights or walls;
- zero/minimal front inset so the most accessible front capacity is not discarded unnecessarily.

Reject an invalid combination where the insets leave no meaningful storage area. Do not silently quantize an invalid visual area into a fake one-cell shelf.

The actual `StorageSurface` will still quantize legal capacity onto the existing 0.10 m grid; that existing behavior remains visible through F6 and tests.

## 9. Vertical clearance

### Intermediate levels

For a level with another platform above it:

1. take the current StorageSurface origin/support position;
2. take the actual physical underside of the next Rack02 platform;
3. derive world-metre clearance between them.

Do not use only support-to-support distance; platform thickness is real obstruction.

The existing tiny seating/surface offset convention must remain coherent with current `StorageSurface` clearance checks. Prefer physical surface-origin → next-platform-underside clearance.

### Top level

The top level derives its clearance from `overhead_limit_local_y_m`.

Moving the top shelf changes top clearance automatically.

The developer never types “top shelf clearance” separately.

In `shelf_ergonomics_review`, the review controller should set/override the starter rack’s overhead limit from the active case ceiling:

- A/B: current 3.40 m condition;
- C: current 2.80 m condition.

For later bunker installations, the developer sets the one rack-level overhead limit to the applicable ceiling/beam/local obstruction. Automatic world-geometry inference is intentionally not part of this milestone.

If the overhead limit is at/below the top support, report an invalid authoring state.

## 10. Runtime StorageSurface creation

The modular rack does not maintain live occupied `StorageSurface` state in the editor.

Editor mode maintains:

- visual geometry;
- movement collision dimensions;
- lightweight derived usable-area/clearance preview;
- warnings.

At runtime, the existing storage manager asks each modular rack to build its functional surfaces once.

Conceptual API:

```text
ModularRack.build_runtime_storage() -> Array[StorageSurface]
ModularRack.get_layout_contract() -> Dictionary
```

`build_runtime_storage()`:

- is idempotent;
- creates one `StorageSurface` for each valid authored shelf level;
- parents/logically associates each surface with its shelf level/rack;
- configures it through the existing `StorageSurface.configure()` API;
- preserves canonical loot scale;
- does not rebuild/reconfigure an occupied rack during gameplay.

No live runtime shelf editing is included.

## 11. Storage-manager / F6 integration

The existing `StoragePrototypeManager` / `FunctionalStorageManager` remains the owner of the installed surface collection and F6 presentation.

Add a small reusable modular-rack installation path to the shared manager rather than giving every rack its own F6 input handler.

When the manager scans its direct fixture children:

- existing Metal Shelf and Locker family handling remains unchanged;
- a recognized `ModularRack` asks the rack for its runtime surfaces;
- those surfaces join the same `_surfaces` collection;
- F6 therefore applies uniformly to legacy functional fixtures and modular racks;
- F7 remains suppressed in the continuing/review functional managers according to current policy.

The review-local storage manager keeps its special A/B/C Metal/Locker profiles but must also call the shared modular-rack installation path.

This establishes the eventual production workflow: modular racks placed as direct children of an installing fixture root can become functional without a new storage subsystem.

## 12. Movement collision

The modular rack owns one coarse movement-collision representation.

Use a unit-scale `CollisionShape3D` resource whose dimensions are updated from the authored rack footprint/frame envelope. Do not non-uniformly scale the collision shape node.

A simple rack-envelope box is acceptable for the first implementation if it:

- prevents walking through the furniture;
- tracks edited rack dimensions;
- does not extend outside the visible outer footprint enough to block reasonable front/side approach.

Interaction rays remain separate from movement collision as in the existing architecture.

Do not implement detailed per-bar/per-platform collision unless human testing demonstrates that the coarse envelope prevents intended approach behavior.

## 13. Editor-time behavior

Use `@tool`; no custom EditorPlugin is required.

When rack dimensions, insets, overhead limit, shelf count or shelf Y positions change:

- frame/platform visuals update;
- movement collision updates;
- derived preview updates;
- validation/warnings update.

A small editor-only configuration fingerprint/poll is acceptable to notice shelf-child transform/count changes if it avoids a more invasive plugin.

Avoid editor dirty-loop behavior: only assign derived transforms/resources when the computed value actually changed.

The editor preview should make it possible to see the derived usable rectangles and the overhead limit without creating real occupied storage state. It may be lightweight diagnostic geometry; production styling is unnecessary.

## 14. Invalid authoring states

Fail clearly rather than silently generating misleading capacity.

At minimum report:

- non-unit rack root scale;
- invalid/nonpositive length/depth/frame height;
- duplicate shelf-level identity;
- missing/malformed Rack01/Rack02 visual structure;
- insets that eliminate usable width/depth;
- overlapping/reversed levels with nonpositive physical opening;
- top level at/above overhead limit;
- highest level above the frame height as a warning;
- shelf level below the installation base as a warning/error as appropriate.

A small but positive opening may remain functional even if most catalogue items do not fit. That is legitimate authoring evidence; do not reject it just because it is inconvenient.

## 15. Initial shelf_ergonomics_review installation

Add one actual `ModularRack` instance to `shelf_ergonomics_review`.

The initial world position is not important, but it must:

- be plainly reachable;
- not intersect walls;
- not intersect the existing Metal Shelf, Locker, Cabinet, tables or another active rack;
- be suitable for immediate pickup → carry → place testing.

Use the developer’s old three-level `Control` assembly as the **visual starting reference**, not as a new universal standard:

- source frame horizontal scale was approximately X 0.75 / Z 1.0;
- source frame Y scale approximately 0.53;
- source Rack02 levels were around the old authored `0.166 / 1.042 / 1.546` root-Y arrangement.

Codex should measure/calibrate the source assets and translate that visual arrangement into the new normalized authoring properties/support-plane convention. Do not blindly treat the raw old GLB root positions as support-top measurements.

This initial rack is only a convenient starting object for the developer to duplicate/edit.

### Retiring the manual assemblies

The old manual modular-rack experiment under `Control` / `Control2`, including its static loot models, is no longer needed once the functional component exists.

Remove those obsolete manual rack/static-loot assemblies from the active review scene.

The existing inert ladder visual may be retained/repositioned near the new rack if useful for the upcoming ladder proof, provided it does not interfere with rack testing. It receives no behavior in this milestone.

Create/use a saved `ReviewFixtures` container if that gives the editor-authored starter rack a clean direct-child relationship to the review storage manager. The existing runtime Metal/Locker/Cabinet fixtures may continue to be added under the same container.

## 16. Mutable review scene vs regression tests

The review scene is deliberately developer-editable after delivery. The developer is expected to:

- duplicate the starter rack;
- change dimensions;
- add/remove/move shelf levels.

Therefore do not make long-term regressions depend on the review scene having exactly one rack or exactly three modular surfaces.

Add a focused reusable-component regression for the `ModularRack` scene itself and make review-scene checks derive expectations from whatever modular racks/levels are currently authored.

Useful invariants:

- one runtime surface per valid authored level;
- stable unique surface IDs;
- dimensions follow edited rack properties;
- level movement changes support/clearance without item scaling;
- add/remove level changes surface count;
- top clearance follows overhead limit;
- asymmetric inset shifts/reduces usable area correctly;
- root rotation/translation preserves world placement;
- duplicated rack instance is independent;
- F6 reaches all installed modular surfaces;
- no F7 behavior is introduced.

A focused save/reload test should prove that root properties and level transforms survive serialization and rebuild correctly. A temporary `user://` PackedScene is sufficient; no permanent matrix of test scenes is required.

## 17. Human acceptance

After focused automated checks, stop for developer review.

The developer should be able to perform this editor workflow:

1. Open `shelf_ergonomics_review.tscn`.
2. Find the supplied functional `ModularRack`.
3. Duplicate the complete rack.
4. Change its length/depth/frame height.
5. Move one shelf level vertically.
6. Duplicate or delete one shelf-level wrapper.
7. Save and reopen the scene.
8. Run the review.
9. Toggle F6 and confirm surfaces follow the authored platforms.
10. Carry representative items from the promoted review supply tables.
11. Test auto placement, manual placement/rotation, stacking and retrieval.
12. Confirm stored loot remains canonical scale and placement does not clip the frame/platforms in the tested configuration.
13. Confirm the original existing Metal/Locker behavior remains normal.

Human judgment determines whether the authoring workflow is practical and whether collision/surface alignment is visually credible.

## 18. Explicit non-goals

Do not implement:

- ladder locomotion or interaction;
- movable/sliding ladders;
- player-adjustable shelf levels;
- runtime shelf reconfiguration;
- free-form player furniture construction;
- crouch;
- height-aware auto-placement;
- gallery furnishing;
- Receiving;
- cabinet redesign;
- automatic ceiling/world-geometry inference;
- a generalized arbitrary-modular-furniture framework;
- a custom Godot EditorPlugin unless the simple `@tool` workflow proves impossible.

## 19. Completion boundary

A successful delivery establishes a reusable functional modular-rack authoring component and one editable starter installation in the retained review scene.

It does **not** select final production rack dimensions or promote any particular level configuration.

After human PROMOTE, the next gate is the single-rack fixed-ladder proof.

