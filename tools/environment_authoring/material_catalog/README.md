# EAF3B material review and catalog

Run from the project root with the bundled Python interpreter. EAF3B reads the
single EAF3A `local_config.json` and `reports/environment_material_catalog/source_index.json`.
It never accepts a source repository path on the command line. External source
reads use EAF3A's `Repository` path guard. The configured repository is read
only; staged commercial map bytes and Godot `.import` records live under ignored
`assets/environment/materials/kitbash_cache/`.

```powershell
$py = 'C:\Users\Boschetar\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $py tools/environment_authoring/material_repository/scan_repository.py
& $py -m tools.environment_authoring.material_catalog.cli prepare --batch foundation_mineral_01
& $py -m tools.environment_authoring.material_catalog.cli capture --batch foundation_mineral_01
```

The tracked `review_batches/<batch_id>/batch.json` contains stable IDs, the
EAF3A schema/revision/scan fingerprint, source-triage rationale, default 2K
policy, and optional candidate parameters. `prepare` stages only indexed
basecolor, normal, roughness, metallic, and AO. It generates candidate `.tres`
resources and `review_set.tres` under the tracked batch directory. The source
files stay in one ignored cache keyed by a hash of the complete stable ID and
resolution. A source change repairs the same cache location after strong
SHA-256 verification. Height and unsupported maps remain source facts; height
is not staged or included in the normal review fingerprint.

`capture` imports textures in Godot 4.7, normalizes the local `.png.import`
records, reimports, and invokes the unchanged EAF1 capture matrix with an
injected review set. The package at
`reports/environment_material_catalog/reviews/<batch_id>/` has 1920×1080
PNGs, `manifest.json`, `batch_summary.md`, and `decision_template.json`.
The adjacent `<batch_id>_review.zip` contains exactly those shareable files.
Neither package contains source textures, cache bytes, or `.import` files.

Godot's `StandardMaterial3D` samples basecolor in the albedo slot as color.
Normal, roughness, metallic, and AO bind to their data slots. All staged maps
use lossless import and mipmaps; normal maps additionally set
`compress/normal_map=1` and leave source green channels unchanged. The
promoted EAF1 builder applies a transient normal-Y inversion only when a spec
requests it. On a new machine, regenerate the ignored `.import` records by
running `capture` after `prepare`.

## Human iteration and catalog

To change mapping, metres per repeat, normal Y, or material multipliers, copy
an iteration JSON with `schema_version`, `batch_id`, and `candidate_overrides`
to a project-local file, then run `prepare --batch <id> --iteration <file>`
and `capture --batch <id>`. Source bytes are reused when their SHA-256 values
match. An explicit `review_resolution` batch override may select a newly
indexed 4K source after a normal EAF3A rescan. Run `refresh-batch --batch <id>`
only after reviewing the EAF3A diff; it updates the scan identity while
preserving stable candidate IDs and overrides. Re-running captures for the
same batch replaces that batch's PNGs and decision template, so save an
earlier review package if comparison history is needed.

The live decision template is `PENDING`. A human reviews the captures and
fills `APPROVED`, `REJECTED`, or `DEFERRED`, revision/date, review parameters,
and notes in a copy of that JSON. Approved decisions require controlled family,
VDD layer, and at least one role; rejected and deferred decisions may leave
those classification fields empty. The template's
review resolution and strong fingerprint tie the decision to the captured
source. Then run:

```powershell
& $py -m tools.environment_authoring.material_catalog.cli reconcile --decisions reports/environment_material_catalog/reviews/foundation_mineral_01/human_decisions.json
& $py -m tools.environment_authoring.material_catalog.cli restage-approved
```

Reconciliation writes tracked `data/environment/material_catalog/catalog.json`
and ignored readable/JSON diffs under `reports/environment_material_catalog/`.
Repeating a decision at the same revision is idempotent; changed human fields
require a higher revision. Stale or missing sources preserve the historical
human status but change `effective_status`. `restage-approved` refuses stale
records and writes current approved `.tres` resources under
`data/environment/material_catalog/approved_specs/`; it also reapplies Godot
import policy. No live material is approved in the initial catalog. Future
authoring code can call `EnvironmentMaterialCatalogQuery.query(family, layer,
role)`; it returns only current approved entries by default.
