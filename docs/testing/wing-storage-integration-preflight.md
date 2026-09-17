# Seeded storage bridge preflight

**Date:** 17 September 2026
**Repository baseline inspected:** `55397bdbdc37a826731629f85ad7f0218b2dcc2a`
**Implementation status:** **NOT STARTED**

This is the authorized read-only dependency map for a later focused gameplay
bridge. It does not change a scene, script, item definition, default launch,
asset, or Receiving implementation.

## Recommendation

Create one explicit gameplay composition, provisionally
`gameplay/logistics_wing/wing_gameplay.tscn`. Reference the accepted
`greybox/logistics_wing/wing_geometry.tscn`; do not copy its nodes or edit its
builder-owned output. Add one normal gameplay player, its carried-items HUD,
a sibling `FunctionalFixtures` root containing three supported shelves, and a
single sibling seed registrar. Run this scene explicitly until human
playtesting is complete.

Keep all of these independently runnable and unchanged during that bridge:

- `main.tscn`, the legacy mechanics fixture and current default scene;
- `greybox/logistics_wing/wing_review.tscn`, the neutral spatial harness;
- `greybox/logistics_wing/wing_geometry.tscn` and
  `build_wing_geometry.gd`, the accepted generated shell and its owner;
- every Receiving scene, pool and branch.

Only a later, separately reviewed milestone should change `project.godot`.

## Current entry scenes and ownership

- `project.godot:14` assigns `run/main_scene` to
  `uid://drbkr86g3cxl1`; `main.tscn:1` owns that UID.
- `main.tscn` has `environment_collision.gd` on its root, four supported
  storage fixtures as direct children, one `CharacterBody3D` with
  `Camera3D` and `CarriedItems`, a root `HUD/CarriedItemsHUD`, and the loose
  item instances used by the prototype registration path. A fresh smoke run
  reported 31 trimesh colliders, 9 convex colliders, 16 storage surfaces and
  87 registered world items.
- `wing_review.tscn` instances only the accepted geometry, the review player,
  review lighting and orientation aids. Its `review_player.tscn` reuses
  `player_controller.gd` and `carried_items.gd`, but explicitly disables loot
  auto-registration, registration logging and the held-item view. It has no
  `CarriedItemsHUD`.
- The generated geometry declares revision 04 and its regeneration command in
  metadata. `build_wing_geometry.gd` owns `Districts`, `RoofVisuals`,
  `Boundaries`, `Proxies` and `Anchors`; future gameplay content must remain
  outside that subtree.

Hard-coded legacy-main consumers should stay legacy-main consumers. They are
`tools/asset_pipeline/run_main_scene_loot_audit.gd`,
`seed_item_definitions.gd`, `seed_or_sync_item_authoring_review.gd`, and the
`footprint_review_content`, `item_catalog_coverage`, `loot_audit_core`,
`main_scene_pickup_registration`, `storage_singleton_clearance`, and
`storage_stack_clearance` test suites. The wing geometry suite also protects
the current default UID, while the capture suite asserts that the neutral
review does not instance `main.tscn`. Do not retarget these checks wholesale.

## Player and UI reuse

`player_controller.gd` already constructs the interaction HUD, held-item view,
`StoragePlacementController`, and zoning editor in `_ready()`. It requires
direct `Camera3D` and `CarriedItems` children. Its ordinary controls are raw
keyboard/mouse handling rather than project input actions, and the project has
no autoload or input-map section to reproduce.

The least divergent later implementation is a reusable full gameplay-player
scene with the same capsule, camera and `CarriedItems` structure as the
current player, leaving its ordinary interaction mechanics enabled. The gameplay
composition should contain exactly one current camera and one player. It
should also instance `CarriedItemsHUD`; either retain the current root/player
names so its default `../../CharacterBody3D/CarriedItems` NodePath resolves,
or override that exported path explicitly. Do not turn `review_player.tscn`
into the full gameplay player and do not fork `player_controller.gd`.

For the deterministic seed route below, configure the gameplay player with
`prototype_auto_register_known_loot = false`,
`print_loot_registration = false`, and `enable_held_item_view = true`. The
player registrar scans only
direct children of `current_scene` and generates time-based instance IDs, so
it must not race or duplicate the dedicated seed owner.

## Supported shelf fixtures

`StoragePrototypeManager.install(scene_root)` scans only direct children of
the supplied root. Put `environment_collision.gd` on `FunctionalFixtures` so
its shelf children satisfy that contract without flattening all gameplay
content onto the scene root. The installer recognizes names beginning
`SM_MetalShelves` and
`SM_ventilated_locker`, installs four authored levels on each, derives IDs
from the shelf node name, and reads a direct
`StorageShelfClearanceContext`. `SM_ClothesCabinet` remains explicitly
unsupported.

The existing verified profiles are:

| Family / placed scale | Surfaces | Grid per surface | Explicit open-top cap |
| --- | ---: | ---: | ---: |
| `SM_MetalShelves`, identity | 4 | `10 x 29` at 0.10 m | 0.919 m |
| `SM_MetalShelves2`, `(0.4, 0.67, 1)` | 4 | `4 x 29` at 0.10 m | 0.615730 m |
| `SM_ventilated_locker2`, identity | 4 | `8 x 13` at 0.10 m | 0.519 m |
| `SM_ventilated_locker`, uniform 0.655 | 4 | `5 x 8` at 0.10 m | 0.339945 m |

Use three identity-scale fixtures for the first bridge. These are exact
candidate transforms in wing coordinates (`+X` east, `+Z` south, floor at
`Y=0`), chosen from accepted shelf-proxy envelopes:

| Proposed child of `FunctionalFixtures` | Source | Transform | Replaced proxy |
| --- | --- | --- | --- |
| `SM_MetalShelves_GalleryA_West` | `assets/environment/furniture/storage/SM_MetalShelves.glb` | origin `(-2.28, 0, -7.20)`, rotation `(0, 0, 0)`, scale `(1, 1, 1)` | `Geometry/Proxies/GalleryA_West` |
| `SM_MetalShelves_GalleryB_North` | same | origin `(14.00, 0, -13.78)`, rotation `(0, 90, 0)`, scale `(1, 1, 1)` | `Geometry/Proxies/GalleryB_North` |
| `SM_ventilated_locker_GalleryC_West` | `assets/environment/furniture/storage/SM_ventilated_locker.glb` | origin `(-1.35, 0, 9.00)`, rotation `(0, 0, 0)`, scale `(1, 1, 1)` | `Geometry/Proxies/GalleryC_West` |

These names are unique, preserve the required family prefixes, yield twelve
functional surfaces, and occupy Storage galleries rather than a service room.
The imported metal-shelf bounds are approximately
`(-0.560304, 0, -1.617743)` to `(0.537142, 2.935878, 1.609468)` and the
locker bounds approximately `(-0.422524, -0.000346, -0.731492)` to
`(0.434887, 2.758126, 0.731518)`. The 0.07 m east/south offsets above correct
wall penetration found at the proxy centers: the Gallery A west-wall inside
face is `X=-2.85`, and the Gallery B north-wall inside face is `Z=-14.35`.
These remain bounding-fit candidates, not human clearance approval; the later
scene must prove facing, player approach and unchanged passage widths before
acceptance. Do not promote the Sorting table proxy into a surface: no current
installer profile supports it.

Each placed shelf needs its own explicit `StorageShelfClearanceContext`.
Identity metal shelves may start from the proven 0.919 m value and the
identity locker from 0.519 m, but the new wall/ceiling context must be measured
and tested rather than copied blindly.

## Collision and proxy replacement

Accepted wing floors, walls, boundaries and most spatial proxies already own
their `StaticBody3D/CollisionShape3D` nodes on the default movement layer.
`environment_collision.gd` is a viable narrow bootstrap on the new
`FunctionalFixtures` root: with its current flags enabled it will generate
convex movement collision for the three recognized shelf branches, then
install their storage surfaces. Turning
`generate_test_collisions` off also skips storage installation because of the
early return at lines 40–42.

Gameplay composition overrides must suppress both halves of each replaced
greybox envelope:

- hide `Geometry/Proxies/<name>/Mesh`; and
- disable `Geometry/Proxies/<name>/StaticBody3D/CollisionShape3D`.

Hiding a parent is not sufficient because physics collision remains active.
Do not alter or regenerate `wing_geometry.tscn`; use explicit overrides or a
small bridge-owned configuration that validates all six exact paths. The new
shelf's convex movement collider may remain. It does not occlude the current
interaction rays: `WorldItem` uses layer 8 (`1 << 7`) and `StorageSurface`
uses layer 9 (`1 << 8`), while both controller queries inspect areas only.

## Items, registration and the deterministic fixture

Runtime truth is `data/items/item_catalog.tres` and its 42
`ItemDefinition` resources. `PrototypeItemCatalog` maps an authored visual
path to that catalogue. `WorldItem.configure()` creates a new `ItemInstance`;
`configure_existing()` preserves an existing instance through shelf storage.
`StoragePlacementController` removes the selected instance from
`CarriedItems`, instantiates its authored visual, applies the authored storage
pose/Footprint, commits the `StorageSurface` entry, and gives the exact same
instance to the resulting `WorldItem`.

Use one gameplay-local seed registrar as the declared test-fixture owner.
Resolve definitions by stable ID with
`PrototypeItemCatalog.get_definition_by_id()`, instantiate the definition's
authored `visual_scene`, create `ItemInstance.new(definition,
"wing_seed_v1:item_####")`, and attach exactly one `WorldItem` through
`configure_existing(host, instance)`. Reject duplicate configured IDs before
spawning. Place the owned loose hosts on a deliberate staging area adjacent to
the supported shelves, never as arbitrary floor drops. Do not also enable the
player's raw-GLB registrar.

A small useful first sample is 12 items:

- two `loot_000005` plus one `loot_000007` (`boxed_food`);
- two `loot_000022` plus one `loot_000023` (`round_cans`);
- one `loot_000030` plus two `loot_000031` (`flat_media`);
- two `loot_000028` (`medical_boxes`); and
- one `loot_000037` Hammer for elongated/manual-rotation coverage.

This supplies four compatible stack families, repeated members, five
categories, and materially different footprints/shapes without making the
fixture an inventory-design claim. Use the catalogue definitions unchanged.
Restart/reset means re-instantiating this explicit scene or a fresh test
instance, which restores the fixed IDs/hosts and clears only that instance's
runtime storage state. Do not add an in-place global reset, touch save data,
or call Receiving generation. If the seed must begin mechanically reserved
on surfaces, expose a narrow shared placement API later; do not copy the
private `_spawn_stored_world_item()` path or manufacture surface ownership.
The first bridge may instead start these registered items loose on its
declared staging shelf.

### Content debt exclusions

- `loot_000015` (Fuel Canister) is otherwise in the 40-item eligible pool, but
  the established storage-pose suite still emits its known source-fingerprint
  assertion at line 143. The manifest records
  `e3cbd7d3dd60c9fde76fe92df640aaf62091c9e6c9b6491ee548b0ac1cf10698`,
  while the local GLB hashes to
  `f095c1ee2eb407ced7214686ba599207d3cbcae8cfbbb61ff0cf06242f54ef85`.
  Omit it from this focused seed until that baseline is repaired and
  re-approved; do not waive a new failure under the exception.
- `loot_000034` (Gloves) and `loot_000036` (Pants) remain the two upstream
  `CUSTOM_POSE_REQUIRED` / Footprint-unreviewed definitions and are excluded
  from `data/receiving/prototype_loot_pool.tres`. Keep them out of the bridge
  seed and do not change the catalogue, pool, pose or review manifest here.

## Later implementation tests

Keep the existing 33-script non-hanging regression set and focused wing
geometry/capture/traversal suites unchanged. Add focused coverage for the new
composition rather than retargeting legacy-main tests:

1. Load the new scene explicitly; assert one current camera, one player,
   resolvable `CarriedItems`, held view enabled, and a HUD whose NodePath
   resolves to that same container.
2. Assert the three unique direct `FunctionalFixtures` shelf names, twelve
   unique surface IDs, explicit top-clearance contexts, no missing-context
   diagnostics, corrected wall clearances, and the expected family profiles.
3. Assert each replaced proxy mesh is hidden and each matching collision shape
   disabled while all other accepted geometry hashes/paths remain unchanged.
4. Instantiate twice and verify the exact 12 stable seed IDs/hosts and 12
   unique `WorldItem`/`ItemInstance` owners each time, with no duplicate
   registration.
   Test-only reset must replace only the fixture scene instance.
5. Exercise normal pickup, bulk/selection/HUD/held view, zoning, hold-E and
   single-E auto storage, manual placement/rotation, compatible stacking,
   retrieval, cross-surface transfer and failed-placement rollback.
6. Smoke-run the new scene, original `main.tscn`, and neutral
   `wing_review.tscn`; rerun the main-specific registration, shelf clearance,
   item catalogue, visual pose, stacking-interaction, stack-surface,
   unstacked-equivalence and support-metadata suites.

The later human gate must confirm recognizable meshes, unchanged scale,
usable approaches/passages, deterministic restart, and the complete ordinary
interaction loop. Only then should a separate change consider making the
gameplay composition the default.

## Gate

- Repository-grounded bridge plan: **READY FOR FOCUSED HANDOFF**.
- Genuine unresolved blocker: **none**; placement/facing and explicit
  top-clearance values still require implementation-time measurement and
  human playtest approval.
- Gameplay bridge implementation: **NOT STARTED**.
- Default-scene migration: **NOT STARTED**.
- Shelves/loot added to a gameplay scene: **NOT STARTED**.
- Physical Receiving: **NOT STARTED**.
