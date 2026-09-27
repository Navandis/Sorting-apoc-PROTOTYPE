"""Generate tracked wear specs and ignored local review metadata from one EAF4B batch."""
from __future__ import annotations

import json
from pathlib import Path
import re
from zipfile import ZipFile, ZipInfo, ZIP_STORED

from tools.environment_authoring.wear_repository.path_guard import PROJECT_ROOT, load_repository
from tools.environment_authoring.wear_repository.source_index import load_index
from tools.environment_authoring.material_catalog.workflow import normalize_imports
from . import workflow

DATA = PROJECT_ROOT / "data/environment/wear_catalog"
BATCHES = DATA / "review_batches"
CACHE = PROJECT_ROOT / "assets/environment/wear/eaf4_cache"
REPORTS = PROJECT_ROOT / "reports/environment_wear_catalog/reviews"
CATALOG = DATA / "catalog.json"

BASE_LABELS = {
    "eaf3b_39b926e570fb3824019aade2": "KB3D_CSZ_ConcreteRoughBright",
    "eaf3b_bd0940113f04f3d3784629e7": "KB3D_DLA_ConcretePittedGrayMed",
    "eaf3b_20c61bd1c85420be2f71a090": "KB3D_BTL_ConcreteFloorPanelsRoughA",
    "eaf3b_8d5f0cf5add98dfe0a58f18a": "KB3D_AFT_PlasterA",
}


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def _safe_batch(batch_id):
    if not re.fullmatch(r"[a-z][a-z0-9_]{2,63}", batch_id):
        raise ValueError("Invalid batch ID")
    return batch_id


def _gd_string(value):
    return json.dumps(str(value), ensure_ascii=False)


def _gd_list(values):
    return "PackedStringArray(" + ", ".join(_gd_string(v) for v in values) + ")"


def spec_text(entry, staged, candidate, imperfection_resource=""):
    channels = dict(staged["maps"])
    if imperfection_resource:
        channels["imperfection"] = {"cache_relative": imperfection_resource}
    refs = [('Script', 'res://environment_authoring/wear/environment_wear_overlay_spec.gd', '1')]
    for n, (channel, record) in enumerate(channels.items(), 2):
        refs.append(('Texture2D', workflow.CACHE_RESOURCE_ROOT + '/' + record["cache_relative"], str(n)))
    ref_lines = [f'[ext_resource type="{kind}" path="{path}" id="{ident}"]' for kind, path, ident in refs]
    ref_ids = {channel: str(i) for i, channel in enumerate(channels, 2)}
    hints = entry["initial_parameters"]
    size = hints["physical_size_m"]
    mode = 0 if hints["render_mode"] == "CUTOUT" else 1
    lines = [f'[gd_resource type="Resource" script_class="EnvironmentWearOverlaySpec" load_steps={len(refs)+1} format=3]',
             '', *ref_lines, '', '[resource]', 'script = ExtResource("1")',
             'overlay_id = ' + _gd_string(staged["catalog_wear_id"]),
             'display_name = ' + _gd_string(candidate.get("display_name", candidate["stable_id"])),
             'source_stable_id = ' + _gd_string(candidate["stable_id"]),
             'source_fingerprint = ' + _gd_string(staged["source_fingerprint"]),
             'semantic_category = ' + _gd_string(entry["semantic_category"]),
             'cause_tags = ' + _gd_list(entry["cause_tags"]),
             'surface_capabilities = ' + _gd_list(entry["surface_capabilities"]),
             f'render_mode = {mode}',
             f'physical_size_m = Vector2({size[0]}, {size[1]})',
             f'surface_offset_m = {hints["surface_offset_m"]}',
             f'opacity_multiplier = {hints["opacity_multiplier"]}',
             f'albedo_strength = {hints["albedo_strength"]}',
             f'normal_strength = {hints["normal_strength"]}',
             f'roughness_strength = {hints["roughness_strength"]}',
             f'normal_y_flip = {str(hints.get("normal_y_flip", False)).lower()}',
             f'edge_feather = {hints.get("edge_feather", 0.035)}',
             'albedo_tint = Color(' + ', '.join(str(v) for v in hints.get("albedo_tint", [1.0, 1.0, 1.0])) + ', 1.0)',
             'embedded_alpha = ' + ('true' if 'EMBEDDED_ALPHA' in candidate.get('opacity_source', []) else 'false'),
             'review_notes = ' + _gd_string("Source class: " + candidate["source_class"] + "; " + entry["selection_rationale"] + "; " + hints["provenance"])]
    for channel, prop in (("basecolor", "base_color_texture"), ("opacity", "opacity_texture"), ("normal", "normal_texture"),
                          ("roughness", "roughness_texture"), ("metallic", "metallic_texture"),
                          ("imperfection", "imperfection_mask_texture")):
        if channel in ref_ids:
            lines.append(f'{prop} = ExtResource("{ref_ids[channel]}")')
    if imperfection_resource:
        imperfection = hints.get("imperfection", {})
        scale = imperfection.get("scale", [1.7, 1.3])
        lines += [f'imperfection_scale = Vector2({scale[0]}, {scale[1]})',
                  f'imperfection_rotation = {imperfection.get("rotation", 18.0)}',
                  f'imperfection_contrast = {imperfection.get("contrast", 1.35)}',
                  f'imperfection_strength = {imperfection.get("strength", 0.55)}']
    return "\n".join(lines) + "\n"


def prepare(batch_id):
    batch_id = _safe_batch(batch_id)
    index = load_index()
    batch = json.loads((BATCHES / batch_id / "batch.json").read_text(encoding="utf-8"))
    candidates = workflow.validate_batch(batch, index)
    repository = load_repository()
    spec_dir = BATCHES / batch_id
    review_dir = REPORTS / batch_id
    review_dir.mkdir(parents=True, exist_ok=True)
    staged_records = []
    by_id = {}
    for entry, candidate in zip(batch["candidates"], candidates):
        staged = workflow.stage_candidate(repository, candidate, entry["resolution"], CACHE)
        staged_records.append({**staged, "review_primitive": entry["primitive"], "selection_rationale": entry["selection_rationale"],
                               "base_material_ids": entry["base_material_ids"], "resolution_rationale": entry["resolution_rationale"]})
        by_id[candidate["stable_id"]] = staged
    grunge = next((r for r in staged_records if "grunge_tedxadjc" in r["source_stable_id"]), None)
    grunge_map = grunge["maps"].get("roughness", grunge["maps"].get("opacity"))["cache_relative"] if grunge else ""
    decisions = []
    for entry, candidate, staged in zip(batch["candidates"], candidates, staged_records):
        if entry["primitive"] != "IMPERFECTION":
            use_grunge = any(fragment in candidate["stable_id"] for fragment in ("leakage_tculfbnc", "leakage_skiubhzc"))
            (spec_dir / (staged["catalog_wear_id"] + ".tres")).write_text(
                spec_text(entry, staged, candidate, grunge_map if use_grunge else ""), encoding="utf-8")
        hints = {"semantic_category": entry["semantic_category"], "cause_tags": entry["cause_tags"],
                 "surface_capabilities": entry["surface_capabilities"], "render_mode": entry["initial_parameters"]["render_mode"],
                 "patch_mode": "EAF4_SOURCE" if entry["primitive"] == "EAF4_PATCH" else "",
                 "default_size": entry["initial_parameters"]["physical_size_m"],
                 "surface_offset": entry["initial_parameters"]["surface_offset_m"],
                 "opacity": entry["initial_parameters"]["opacity_multiplier"],
                 "albedo_strength": entry["initial_parameters"]["albedo_strength"],
                 "normal_strength": entry["initial_parameters"]["normal_strength"],
                 "roughness_strength": entry["initial_parameters"]["roughness_strength"],
                 "imperfection": ({"source_stable_id": grunge["source_stable_id"],
                                   "source_fingerprint": grunge["source_fingerprint"],
                                   "selected_resolution": grunge["selected_resolution"],
                                   "scale": [1.7, 1.3], "rotation": 18.0,
                                   "contrast": 1.35, "strength": 0.55}
                                  if grunge and any(fragment in candidate["stable_id"] for fragment in
                                                    ("leakage_tculfbnc", "leakage_skiubhzc")) else {}),
                 "review_notes": "Human review pending. " + entry["selection_rationale"]}
        decisions.append(workflow.decision_template(staged, hints))
    result = {"schema_version": 1, "batch_id": batch_id, "source_index_revision": batch["source_index_revision"],
              "source_index_fingerprint": batch["source_index_fingerprint"], "candidates": staged_records}
    write_json(review_dir / "stage_manifest.json", result)
    write_json(review_dir / "decision_template.json", {"schema_version": 1, "batch_id": batch_id, "decisions": decisions})
    lines = [f'# EAF4B wear review: {batch_id}', '', 'All live decisions are PENDING. Initial sizes, modes, offsets, and strengths are machine review hints, not artistic approval.', '',
             f'Source index: {batch["source_index_revision"]} / {batch["source_index_fingerprint"]}', '']
    for entry, record in zip(batch["candidates"], staged_records):
        lines += [f'## {record["source_stable_id"]}', '',
                  f'- Primitive: {entry["primitive"]}; EAF4A source class: {record["source_class"]}',
                  f'- Resolution: {record["selected_resolution"]}; available: {", ".join(record["available_resolutions"])}. {entry["resolution_rationale"]}',
                  f'- Staged maps: {", ".join(record["maps"])}',
                  f'- Review bases: {", ".join(BASE_LABELS.get(x, x) for x in entry["base_material_ids"])}',
                  f'- Rationale: {entry["selection_rationale"]}',
                  f'- Strong fingerprint: {record["source_fingerprint"]}', '']
    (review_dir / "batch_summary.md").write_text("\n".join(lines), encoding="utf-8")
    print("EAF4B_PREPARE", len(staged_records), sum(len(r["maps"]) for r in staged_records), review_dir)
    return result


def package_review(batch_id):
    directory = REPORTS / _safe_batch(batch_id)
    allowed = ["manifest.json", "batch_summary.md", "decision_template.json"]
    manifest = json.loads((directory / "manifest.json").read_text(encoding="utf-8"))
    image_names = [record["filename"] for record in manifest["records"]]
    if len(image_names) != len(set(image_names)) or any(Path(name).name != name or not name.endswith(".png") for name in image_names):
        raise ValueError("Unsafe or duplicate capture filename")
    files = [directory / name for name in allowed + image_names]
    if any(not p.is_file() for p in files) or not image_names:
        raise ValueError("Incomplete review package")
    archive = directory.with_name(batch_id + "_review.zip")
    with ZipFile(archive, "w", ZIP_STORED) as zipout:
        for path in files:
            info = ZipInfo(path.name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = ZIP_STORED
            zipout.writestr(info, path.read_bytes())
    return archive
