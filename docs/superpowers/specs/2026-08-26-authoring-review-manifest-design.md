# Authoring Review Manifest Design

## Purpose

Track durable, human authoring decisions for scene loot without changing gameplay data. The generated loot audit correlates each current asset to this manifest and reports whether scale, storage pose, and Footprint decisions are current.

## Boundaries

`ItemDefinition` remains gameplay authority. `run_main_scene_loot_audit.gd` only reads the manifest. `seed_or_sync_item_authoring_review.gd` is the sole writer and retains records for assets absent from the current scene.

## Manifest

`tools/asset_pipeline/item_authoring_review.json` uses schema `1.0` and maps opaque `loot_NNNNNN` keys to source path, optional item ID, SHA-256 source fingerprint, and three independent review dimensions. Keys are never derived from names or paths and allocate as one greater than the largest existing numeric suffix.

## Correlation and freshness

Correlation prefers one unique item-ID match, then source-path match, then a one-to-one fingerprint match. Ambiguous fingerprint matches remain untracked and generate evidence; audit never repairs records. A completed decision is current when its required snapshots match the current asset. Completed scale decisions include `APPROVED` and `NORMALIZATION_REQUIRED`; completed pose decisions include `DEFAULT_POSE_APPROVED`, `CUSTOM_POSE_REQUIRED`, and `CUSTOM_POSE_APPROVED`; completed Footprint decisions include `GEOMETRY_APPROVED` and `OVERRIDE_APPROVED`.

Fingerprints use SHA-256 over GLB bytes, so a rename does not stale a review but a re-export does. Storage pose also compares tolerant rotation snapshots. Footprint also compares the stored footprint and rotation snapshots. Unreviewed entries are not stale.

## Output and verification

The generated audit becomes schema `1.2`, adding authoring identity, fingerprint, review status/currentness, and deterministic review flags. Focused GDScript tests exercise allocation, idempotence, conservative correlation, stale detection, serialization, and output schema, alongside the existing audit tests.
