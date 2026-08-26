# Persistent 42-Item Catalogue Design

## Purpose

Make all 42 unique loot visuals audited from `main.tscn` resolvable through the existing TAKE, carry, PUT, storage, and retrieval interaction slice while replacing the temporary hard-coded catalogue with persistent Godot-native `ItemDefinition` resources. The generated values are authoring-review scaffolding, not approved balance or presentation data.

## Frozen behavior and scope

The migration preserves LMB TAKE, E PUT, hold-E repeat, zone matching with General and unassigned fallback, manual placement, player-controlled 90-degree Footprint rotation, retrieval, shelf geometry, carried bundles, zoning UI, and storage categories. `main.tscn`, source GLBs, textures, `.import`, `.godot`, storage mechanics, and zoning behavior are not modified.

The pass ends after catalogue migration, manifest association, automated verification, and audit generation. It must not adjust individual storage poses, Footprints, review statuses, Bulk, Utility, or final display names based on visual judgment.

## Identity

The project uses the existing `ItemDefinition.item_id` property as the stable gameplay definition ID. For every current definition, it equals the durable manifest authoring key `loot_000001` through `loot_000042`. The property name is not renamed merely because the brief uses the conceptual spelling `ItemDefinition.id`.

The 11 legacy filename-derived IDs are safe to replace: current inspection found no save-data, authored-resource, reservation, or gameplay-comparison dependency. They only prefix ephemeral `ItemInstance.instance_id` values and participate in audit/manifest correlation. No second semantic identity layer or permanent legacy-ID alias is introduced.

Visual paths remain compatibility lookup keys, not gameplay identity. Future catalogue variants may share visuals, but the current persistent catalogue requires one unambiguous visual path per definition because raw `main.tscn` instances are registered through their PackedScene paths.

## Persistent resources

`data/items/definitions/` contains one `ItemDefinition` `.tres` per authoring key. `data/items/item_catalog.tres` is a persistent `ItemCatalog` resource containing an exported `Array[ItemDefinition]` that explicitly references all definitions.

`ItemCatalog` owns two per-resource-instance caches:

- stable `StringName` item ID to `ItemDefinition`;
- normalized visual resource path to `ItemDefinition`.

The dictionaries are calculated and validated once lazily for each loaded catalogue resource instance, then reused by every query. They are invalidated only if the resource's exported definitions array is deliberately replaced through its supported API; normal lookup never rebuilds them.

Validation detects empty IDs, missing visuals, duplicate IDs, and duplicate visual paths. A duplicate invalidates the affected key: lookup fails loudly, returns `null`, and surfaces a clear validation error naming the conflicting key and resources. Validation never selects a winner.

## Compatibility facade and runtime data flow

`PrototypeItemCatalog` remains the public compatibility facade used by player registration, the audit, and authoring tools. Its primary path is:

`scene PackedScene path -> PrototypeItemCatalog -> item_catalog.tres -> ItemCatalog visual-path cache -> ItemDefinition`

`create_definition_for_scene_path()` queries the persistent catalogue directly. `create_definition_for_node()` first uses `Node3D.scene_file_path`. The existing node-name mapping remains only as a fallback when the node does not expose a scene path; the resulting path still goes through the persistent catalogue. The facade no longer constructs definitions or contains legacy gameplay values.

The facade loads and reuses the persistent catalogue rather than scanning directories or rebuilding indexes on each call. A failed catalogue load or invalid affected lookup reports an actionable error and returns `null`.

## Explicit seed utility

`tools/asset_pipeline/seed_item_definitions.gd` is a developer-invoked command. Normal game launch and normal audit execution never create or modify gameplay resources.

Before writing, the utility verifies all of the following:

- generated audit schema is exactly `1.2`;
- every current audit asset has a non-empty authoring key;
- every recorded source fingerprint matches the current GLB bytes;
- the current audit asset set exactly matches fresh `main.tscn` enumeration;
- manifest correlations are unambiguous;
- every selected category is one of the eight item categories and is never `General`.

Any stale or ambiguous evidence aborts the whole operation before writes and tells the developer to rerun the audit or resolve the ambiguity.

For a missing definition, the utility creates `data/items/definitions/<authoring_key>.tres` with:

- `item_id` equal to the authoring key;
- the audited GLB as `visual_scene`;
- `bulk = 1` as review scaffolding;
- `utility_id = &"None"` and `utility_value = 0` as neutral review scaffolding;
- `storage_rotation_degrees = Vector3.ZERO`;
- `storage_footprint = Vector3i(raw_width_cells, raw_depth_cells, 1)`, where `z = 1` is neutral scaffolding and not a vertical-packing decision;
- a valid primary item category;
- a readable provisional display name;
- conservative defaults for all other fields already supplied by `ItemDefinition`.

The existing 11 hard-coded entries receive this same raw-audit baseline. Their previous Bulk, Utility, Footprint, rotation, and other provisional catalogue values are not migrated.

Category selection first uses an existing valid authored category only when it agrees with known content intent, otherwise a valid folder hint. `SM_Metal_Can_01a` is explicitly `Hydration`. Any other authored-category/folder conflict without decisive project evidence aborts and reports the ambiguity. `General` is never an item category.

Readable legacy display names may be retained for the existing 11. New labels are derived mechanically from descriptive source basenames by removing an `SM_` prefix, separating camel case and underscores, and preserving useful numeric variants. These labels remain provisional and do not affect identity.

## Rerun safety and catalogue membership

An existing definition file is authored gameplay data. On every rerun, the seed utility leaves every serialized value and the file bytes unchanged, even if the audit, category hints, geometry, or defaults later change. It may only create missing definition files and add newly created definitions to catalogue membership.

The utility does not repair, synchronize, or overwrite existing definitions. It reports missing or inconsistent existing data separately. Catalogue membership updates preserve existing order and entries and append only genuinely new resources. No directory scan occurs during normal runtime.

## Manifest integration

After definition creation and a refreshed audit, the existing explicit authoring-review sync updates each manifest record's `item_id` association to its matching `loot_NNNNNN` authoring key. That sync changes only `item_id`; it never changes scale, storage-pose, or Footprint status, notes, snapshots, or completion state.

All 42 scale, storage-pose, and Footprint review statuses remain `UNREVIEWED`. Creating or seeding a definition is not human review and does not snapshot provisional values into review evidence.

## Error handling

Validation failures are atomic at the planning stage: the seed tool performs all stale-evidence, identity, category, and collision checks before writing any resource. Resource save failures produce a non-zero exit and identify the path. Duplicate registry keys produce explicit validation diagnostics and `null` for those affected lookups. Missing definitions remain visible as audit `NO_ITEM_DEFINITION` evidence rather than receiving a hidden runtime fallback.

## Automated verification

Focused resource and seed tests verify:

- 42 manifest records correspond to 42 persistent definitions;
- unique IDs and exact authoring-key identity;
- unique current visual paths;
- successful lookup by every ID and every visual path;
- duplicate ID and visual-path detection with affected lookup returning `null`;
- per-instance cache construction occurs once rather than on every query;
- rerun leaves existing `.tres` content unchanged;
- a hypothetical new audit/manifest entry creates only its missing definition and catalogue membership;
- valid non-General categories;
- initial-only Bulk, neutral Utility, raw orientation-A Footprints, and zero storage rotations.

Initial scaffold assertions are isolated from permanent production invariants so later human edits do not break eternal catalogue tests.

Interaction reviewability tests prove the exact pickup-registration lookup path resolves all 42 audited `main.tscn` GLBs, with valid visuals, positive Footprints, and carry-compatible Bulk. Representative regular container, Medical, pistol, rifle, `SM_Hammer_3`, clothing, Fuel, electronics, and pig-carcass definitions also traverse the existing world-loot to carried item to storage reservation to stored `WorldItem` to retrieval flow where the headless harness permits. A selected shelf's inability to fit a provisional Footprint is evidence, not a reason to shrink it.

Existing storage-category, audit-core, manifest, audit-integration, and interaction tests remain in the verification suite. Final verification also runs the schema-1.2 audit, checks 42 defined and zero undefined assets, reports remaining category mismatches, confirms zero ambiguous authoring correlations and 42 unreviewed statuses, performs a Godot parser/editor scan, and runs `git diff --check`.

## Manual review handoff

The developer launches the current main scene, picks up representative mixed items, confirms formerly inert props can be taken, stores through zone-auto, retrieves them, and enters manual placement for irregular cases. The review observes canonical scale, default storage pose, provisional reservation Footprint, automatic 90-degree rotation, and visual centring and clearance.

Awkward poses and implausible Footprints are expected evidence. Nothing is automatically marked approved.
