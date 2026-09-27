# EAF4B Wear Overlay Catalog Implementation Plan

**Goal:** Implement the approved EAF4B brief on branch codex/eaf4b-wear-overlay-catalog, preserving promoted EAF4A/EAF3/EAF1 systems and leaving live decisions pending.

**Architecture:** Python resolves stable IDs through EAF4A, stages only selected maps and strong provenance, and maintains a separate curated catalog. Godot Resources and Compatibility shaders render physical mesh overlays. A composed EAF1 review scene supplies approved EAF3 substrates and deterministic capture.

**Source:** User-attached EAF4B implementation brief, sections 1–47.

## Tasks

- [x] Select 10–14 candidates from contact sheets and record rationale, source facts, and review hints.
- [x] Test then implement guarded staging, SHA-256 fingerprints, resolution selection, and import normalization.
- [x] Test then implement wear spec, cutout/soft shaders, physical overlay node, material patches, and synthetic atlas.
- [x] Compose EAF1 review, bounded controls, capture matrix, base references, manifest, and allowlist ZIP.
- [x] Test then implement catalog decisions, stale/missing/current query, and synthetic approved restaging.
- [x] Run focused and regression tests, inspect images, record validation, and stop at human review.

## Constraints

- No merge, push, live approval, EAF5, Receiving C1, or EAF4 overall promotion.
- Only the EAF4A configured repository and guarded source paths; no arbitrary source paths in batch or decisions.
- Generated source maps and captures are ignored; ZIP contains no commercial maps.
- Compatibility renderer, no Decal nodes, no displacement, no random scattering.
