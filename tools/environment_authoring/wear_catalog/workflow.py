"""EAF4B guarded selective staging and curated wear state.

External source opens go exclusively through EAF4A Repository. Public batch and
decision records contain stable IDs and review parameters, never source paths.
"""
from __future__ import annotations

from copy import deepcopy
import hashlib
import json
from pathlib import Path, PureWindowsPath
import re

from tools.environment_authoring.wear_repository.path_guard import ARCHIVES, BoundaryError
from tools.environment_authoring.wear_repository.profiles import PROFILE_REVISIONS
from tools.environment_authoring.wear_repository.source_index import fingerprint, validate_index

SCHEMA_VERSION = 1
MAP_CHANNELS = ("basecolor", "opacity", "normal", "roughness", "metallic")
IMAGE_SUFFIXES = {".png", ".jpg", ".jpeg", ".webp", ".tga", ".exr"}
HUMAN_STATES = {"APPROVED", "REJECTED", "DEFERRED"}
RENDER_MODES = {"CUTOUT", "SOFT_BLEND"}
CAPABILITIES = {"PLANAR_ANY", "VERTICAL_PREFERRED", "HORIZONTAL_PREFERRED", "WALL", "FLOOR", "CEILING"}
CACHE_RESOURCE_ROOT = "res://assets/environment/wear/eaf4_cache"
SCALAR_CHANNELS = {"opacity.red", "roughness.red"}
MASK_USES = ("TINTED_OPACITY_LAYER", "WEAR_OPACITY_MODULATION")
# Original reviewed source, not a default for unannotated future approvals.
LEGACY_GRUNGE_ID = "eaf4:IMPERFECTION_TEXTURE_PROFILE:grunge_tedxadjc:tedxadjc"
LEGACY_GRUNGE_FINGERPRINT = "e71aaf2f2092f229536c4a8ffd8e28b52db2c0e9b3924ab6436852a38267504b"
LEAKAGE_MODULATION_IDS = {"eaf4b_e890439d8e117d36ac05e55c", "eaf4b_cd7701bd0cdb622c63628103"}


def mask_scope(record, allow_legacy=False):
    """Return validated scalar-only usage; never infer approval from map availability."""
    if "scalar_channel" not in record and "supported_uses" not in record and allow_legacy:
        if (record.get("source_stable_id") == LEGACY_GRUNGE_ID
                and record.get("catalog_wear_id") == catalog_id(LEGACY_GRUNGE_ID)
                and record.get("reviewed_source_fingerprint") == LEGACY_GRUNGE_FINGERPRINT
                and record.get("selected_resolution") == "1K"
                and record.get("decision_revision") == 1
                and record.get("status", record.get("decision")) == "APPROVED"
                and record.get("semantic_category") == "IMPERFECTION_MASK"
                and record.get("render_mode") == "SOFT_BLEND"):
            return "roughness.red", ["WEAR_OPACITY_MODULATION"]
    channel = record.get("scalar_channel")
    if not isinstance(channel, str) or channel not in SCALAR_CHANNELS:
        raise ValueError("Mask decision requires scalar_channel opacity.red or roughness.red")
    uses = record.get("supported_uses")
    if (not isinstance(uses, list) or not uses or any(not isinstance(u, str) or u not in MASK_USES for u in uses)
            or len(set(uses)) != len(uses)):
        raise ValueError("Mask decision requires nonempty unique supported_uses from " + ", ".join(MASK_USES))
    if record.get("render_mode") != "SOFT_BLEND" or record.get("patch_mode") or record.get("eaf3_material_id") or record.get("imperfection"):
        raise ValueError("Scalar mask scope contradicts a material patch or dependent overlay")
    return channel, [u for u in MASK_USES if u in uses]


def validate_decision_sources(repository, index, decisions, catalog):
    """Read-only approval preflight against indexed originals, before canonical writes."""
    existing = {r["source_stable_id"]: r for r in catalog["wear"]}
    for decision in decisions:
        candidate = candidate_by_id(index, decision["source_stable_id"])
        if candidate["source_class"] not in ("IMPERFECTION_MASK", "MASKED_DECAL"):
            raise ValueError("Unsupported decision source class: " + candidate["source_class"])
        old = existing.get(decision["source_stable_id"])
        _validate_decision(decision, candidate["source_class"], allow_legacy=old is not None and _human_fields(old) == decision)
        if candidate["source_class"] != "IMPERFECTION_MASK" or decision["decision"] != "APPROVED":
            continue
        channel, _ = mask_scope(decision, allow_legacy=old is not None and _human_fields(old) == decision)
        maps = select_maps(candidate, decision["selected_resolution"])
        if channel.split(".")[0] not in maps:
            raise ValueError("Reviewed scalar_channel unavailable at selected resolution: " + channel)
        facts = fingerprint_candidate(repository, candidate, decision["selected_resolution"])
        if facts["source_fingerprint"] != decision["reviewed_source_fingerprint"]:
            raise ValueError("Reviewed mask fingerprint differs from current guarded source")


def _human_fields(record):
    return {**{k: v for k, v in record.items() if k not in (
        "effective_status", "current_source_fingerprint", "current_imperfection_fingerprint", "status")},
        "decision": record["status"]}


def _relative_source(value: str) -> str:
    if not isinstance(value, str) or not value or Path(value).is_absolute() or PureWindowsPath(value).drive:
        raise BoundaryError("Source map must be repository-relative")
    if "\\" in value or any(p in ("", ".", "..") for p in value.split("/")):
        raise BoundaryError("Invalid source-relative path")
    if Path(value).suffix.lower() in ARCHIVES or Path(value).suffix.lower() not in IMAGE_SUFFIXES:
        raise BoundaryError("Only indexed image maps may be staged")
    return value


def _reject_external_paths(value):
    if isinstance(value, dict):
        if any("path" in str(k).lower() or "root" in str(k).lower() for k in value):
            raise ValueError("Batch/decision/catalog cannot contain source paths or roots")
        for child in value.values():
            _reject_external_paths(child)
    elif isinstance(value, list):
        for child in value:
            _reject_external_paths(child)
    elif isinstance(value, str):
        if Path(value).is_absolute() or PureWindowsPath(value).drive or value.startswith("res://"):
            raise ValueError("Absolute/resource paths forbidden in batch/decision/catalog")


def candidate_by_id(index, stable_id):
    validate_index(index)
    matches = [c for c in index["logical_candidates"] if c["stable_id"] == stable_id]
    if len(matches) != 1:
        raise ValueError("Unknown or duplicate EAF4 stable ID: " + stable_id)
    return matches[0]


def index_fingerprint(index):
    validate_index(index)
    return fingerprint({"schema_version": index["schema_version"], "scanner_revision": index["scanner_revision"],
                        "candidates": [(c["stable_id"], c.get("quick_fingerprint")) for c in index["logical_candidates"]]})


def make_batch(batch_id, index, candidates):
    if not re.fullmatch(r"[a-z][a-z0-9_]{2,63}", batch_id):
        raise ValueError("Invalid batch ID")
    batch = {"schema_version": SCHEMA_VERSION, "batch_id": batch_id,
             "source_index_revision": index["scanner_revision"], "source_index_fingerprint": index_fingerprint(index),
             "candidates": deepcopy(candidates)}
    validate_batch(batch, index)
    return batch


def validate_batch(batch, index):
    _reject_external_paths(batch)
    if batch.get("schema_version") != SCHEMA_VERSION or batch.get("source_index_revision") != index["scanner_revision"] or batch.get("source_index_fingerprint") != index_fingerprint(index):
        raise ValueError("Batch source index identity differs; refresh after EAF4A review")
    entries = batch.get("candidates")
    if not isinstance(entries, list) or not entries or len({e["stable_id"] for e in entries}) != len(entries):
        raise ValueError("Batch requires unique stable IDs")
    for entry in entries:
        if set(entry) - {"stable_id", "resolution", "primitive", "selection_rationale", "semantic_category", "cause_tags", "surface_capabilities", "base_material_ids", "initial_parameters", "resolution_rationale"}:
            raise ValueError("Unsupported batch field")
        candidate = candidate_by_id(index, entry["stable_id"])
        if candidate["source_class"] not in ("MASKED_DECAL", "IMPERFECTION_MASK"):
            raise ValueError("Unsupported live source class")
        if "City-be_selective" in entry["stable_id"] or "metal_drain_cover" in entry["stable_id"] or "truncated_domes_pad" in entry["stable_id"]:
            raise ValueError("Excluded by EAF4A human triage")
        if entry["resolution"] not in ("1K", "2K", "4K") or entry["resolution"] not in candidate["available_resolutions"]:
            raise ValueError("Resolution unavailable or outside review policy")
        if entry.get("primitive", "OVERLAY") not in ("OVERLAY", "EAF4_PATCH", "IMPERFECTION"):
            raise ValueError("Unknown review primitive")
    return [candidate_by_id(index, e["stable_id"]) for e in entries]



def validate_rerun(config, batch, stage, catalog):
    """Require an exact, bounded rerun of sources without final decisions."""
    _reject_external_paths(config)
    if config.get("schema_version") != SCHEMA_VERSION or config.get("original_batch_id") != batch.get("batch_id"):
        raise ValueError("Rerun does not identify the original batch")
    if config.get("rerun_id") == batch.get("batch_id") or not re.fullmatch(
        r"[a-z][a-z0-9_]{2,63}", config.get("rerun_id", "")
    ):
        raise ValueError("Rerun needs a distinct safe ID")
    identity = batch.get("source_index_fingerprint")
    if config.get("source_index_fingerprint") != identity or stage.get("source_index_fingerprint") != identity:
        raise ValueError("Rerun source index identity differs")
    if stage.get("batch_id") != batch.get("batch_id"):
        raise ValueError("Staged sources belong to another batch")
    batch_by_id = {item["stable_id"]: item for item in batch["candidates"]}
    stage_by_id = {item["source_stable_id"]: item for item in stage["candidates"]}
    if set(batch_by_id) != set(stage_by_id):
        raise ValueError("Rerun stage differs from source batch")
    decided = {item["source_stable_id"] for item in catalog["wear"]}
    expected = set(batch_by_id) - decided
    entries = config.get("candidates")
    if not isinstance(entries, list) or not entries:
        raise ValueError("Rerun needs unresolved candidates")
    selected = [item.get("source_stable_id") for item in entries]
    if len(set(selected)) != len(selected) or set(selected) != expected:
        raise ValueError("Rerun must select exactly the unresolved sources")
    result = []
    for item in entries:
        if set(item) != {"source_stable_id", "catalog_wear_id", "diagnostic_context",
                         "calibrated_parameters", "rationale"}:
            raise ValueError("Unsupported rerun field")
        source_id = item["source_stable_id"]
        original = batch_by_id[source_id]
        staged = stage_by_id[source_id]
        if item["catalog_wear_id"] != staged["catalog_wear_id"] or original["resolution"] != staged["selected_resolution"]:
            raise ValueError("Rerun source mapping changed")
        floor = original["surface_capabilities"] == ["FLOOR"]
        expected_context = "WEAR_DIAGNOSTIC_FLOOR" if floor else "WEAR_DIAGNOSTIC_LIGHT"
        if item["diagnostic_context"] != expected_context:
            raise ValueError("Diagnostic surface differs from original review placement")
        controls = item["calibrated_parameters"]
        if set(controls) != {"opacity", "albedo_strength"} or any(
            not isinstance(value, (int, float)) or isinstance(value, bool) or not 0.0 <= value <= 1.0
            for value in controls.values()
        ):
            raise ValueError("Rerun may change only bounded opacity and albedo strength")
        if not isinstance(item["rationale"], str) or not item["rationale"].strip():
            raise ValueError("Rerun parameter rationale required")
        result.append(staged)
    return result

def select_maps(candidate, resolution):
    if resolution not in ("1K", "2K", "4K") or resolution not in candidate["available_resolutions"]:
        raise ValueError("Resolution unavailable or outside review policy")
    maps = candidate.get("maps_by_resolution", {}).get(resolution, {})
    allowed = ("opacity", "roughness") if candidate["source_class"] == "IMPERFECTION_MASK" else MAP_CHANNELS
    selected = {}
    for channel in allowed:
        records = maps.get(channel, [])
        if not records:
            continue
        if len(records) != 1:
            raise ValueError("Ambiguous indexed map: " + channel)
        selected[channel] = _relative_source(records[0]["relative_path"])
    if candidate["source_class"] == "IMPERFECTION_MASK":
        if not selected:
            raise ValueError("Imperfection has no selected scalar map")
    elif "basecolor" not in selected or ("opacity" not in selected and "EMBEDDED_ALPHA" not in candidate.get("opacity_source", [])):
        raise ValueError("Overlay needs indexed color and opacity evidence")
    return selected


def catalog_id(stable_id):
    return "eaf4b_" + hashlib.sha256(stable_id.encode("utf-8")).hexdigest()[:24]


def fingerprint_candidate(repository, candidate, resolution):
    selected = select_maps(candidate, resolution)
    maps = {}
    for channel, relative in selected.items():
        digest = hashlib.sha256()
        with repository.open(relative) as stream:
            while block := stream.read(1024 * 1024):
                digest.update(block)
        maps[channel] = {"source_relative": relative, "sha256": digest.hexdigest()}
    interpretation = {key: candidate.get(key) for key in (
        "profile", "source_class", "opacity_source", "source_physical_width_m",
        "source_physical_height_m", "physical_size_provenance", "tileable",
        "tileability_provenance", "metadata_facts", "warnings")}
    interpretation["profile_revision"] = PROFILE_REVISIONS.get(candidate["profile"])
    anchor = {"stable_id": candidate["stable_id"], "resolution": resolution, "maps": maps,
              "interpretation": interpretation}
    return {"source_fingerprint": fingerprint(anchor), "maps": maps, "interpretation": interpretation}


def stage_candidate(repository, candidate, resolution, cache_root, dry_run=False, expected_fingerprint=None):
    facts = fingerprint_candidate(repository, candidate, resolution)
    if expected_fingerprint is not None and facts["source_fingerprint"] != expected_fingerprint:
        raise ValueError("Approved source fingerprint changed before cache staging")
    cache_root = Path(cache_root)
    group = catalog_id(candidate["stable_id"]) + "/" + resolution.lower()
    staged = {}
    for channel, record in facts["maps"].items():
        suffix = Path(record["source_relative"]).suffix.lower()
        target_relative = group + "/" + channel + suffix
        target = cache_root / target_relative
        if dry_run:
            staged[channel] = {**record, "cache_relative": target_relative}
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        existing_hash = hashlib.sha256(target.read_bytes()).hexdigest() if target.exists() else None
        if existing_hash != record["sha256"]:
            temporary = target.with_suffix(target.suffix + ".tmp")
            with repository.open(record["source_relative"]) as source, temporary.open("wb") as sink:
                while block := source.read(1024 * 1024):
                    sink.write(block)
            if hashlib.sha256(temporary.read_bytes()).hexdigest() != record["sha256"]:
                temporary.unlink()
                raise ValueError("Source changed while staging")
            temporary.replace(target)
        staged[channel] = {**record, "cache_relative": target_relative}
    return {"source_stable_id": candidate["stable_id"], "catalog_wear_id": catalog_id(candidate["stable_id"]),
            "source_class": candidate["source_class"], "profile": candidate["profile"],
            "selected_resolution": resolution, "available_resolutions": candidate["available_resolutions"],
            "source_fingerprint": facts["source_fingerprint"], "source_interpretation": facts["interpretation"],
            "maps": staged}


def decision_template(staged, hints):
    _reject_external_paths(hints)
    result = {"source_stable_id": staged["source_stable_id"], "catalog_wear_id": staged["catalog_wear_id"],
            "reviewed_source_fingerprint": staged["source_fingerprint"], "selected_resolution": staged["selected_resolution"],
            "decision": "PENDING", "decision_revision": 0,
            "semantic_category": hints.get("semantic_category", ""), "cause_tags": hints.get("cause_tags", []),
            "surface_capabilities": hints.get("surface_capabilities", []), "render_mode": hints.get("render_mode", "SOFT_BLEND"),
            "patch_mode": hints.get("patch_mode", ""), "eaf3_material_id": hints.get("eaf3_material_id", ""),
            "default_size": hints.get("default_size", [0.5, 0.5]), "surface_offset": hints.get("surface_offset", 0.002),
            "opacity": hints.get("opacity", 1.0), "albedo_strength": hints.get("albedo_strength", 0.5),
            "albedo_tint": hints.get("albedo_tint", [1.0, 1.0, 1.0]),
            "normal_strength": hints.get("normal_strength", 1.0), "normal_y_flip": hints.get("normal_y_flip", False),
            "roughness_strength": hints.get("roughness_strength", 1.0),
            "imperfection": hints.get("imperfection", {}),
            "review_notes": hints.get("review_notes", "")}
    if staged.get("source_class") == "IMPERFECTION_MASK":
        result["semantic_category"] = hints.get("semantic_category", "IMPERFECTION_MASK")
        result.update(scalar_channel=hints.get("scalar_channel", ""), supported_uses=hints.get("supported_uses", []))
    return result


def _validate_decision(decision, source_class=None, allow_legacy=False):
    _reject_external_paths(decision)
    if decision.get("catalog_wear_id") != catalog_id(decision["source_stable_id"]):
        raise ValueError("catalog_wear_id differs from authenticated source_stable_id")
    if source_class is not None and source_class not in ("IMPERFECTION_MASK", "MASKED_DECAL"):
        raise ValueError("Unsupported decision source class: " + source_class)
    if decision.get("decision") not in HUMAN_STATES:
        raise ValueError("Only explicit human decisions may be reconciled")
    if not isinstance(decision.get("decision_revision"), int) or decision["decision_revision"] < 1:
        raise ValueError("Decision revision must be positive")
    if decision.get("render_mode") not in RENDER_MODES:
        raise ValueError("Unsupported render mode")
    if any(v not in CAPABILITIES for v in decision.get("surface_capabilities", [])):
        raise ValueError("Unsupported surface capability")
    if not isinstance(decision.get("reviewed_source_fingerprint"), str) or len(decision["reviewed_source_fingerprint"]) != 64:
        raise ValueError("Missing strong fingerprint")
    if source_class == "IMPERFECTION_MASK" or (source_class is None and (
            decision.get("semantic_category") == "IMPERFECTION_MASK" or "scalar_channel" in decision or "supported_uses" in decision)):
        if decision.get("decision") == "APPROVED" or decision.get("scalar_channel") or decision.get("supported_uses"):
            mask_scope(decision, allow_legacy)
    elif source_class is not None and ("scalar_channel" in decision or "supported_uses" in decision):
        raise ValueError("Mask scope fields require an IMPERFECTION_MASK source")


def reconcile(catalog, decisions, current_fingerprints, imperfection_current=None, source_index=None):
    if catalog.get("schema_version") != SCHEMA_VERSION or not isinstance(catalog.get("wear"), list):
        raise ValueError("Invalid wear catalog")
    imperfection_current = imperfection_current or {}
    output = deepcopy(catalog)
    by_id = {r["source_stable_id"]: r for r in output["wear"]}
    if len(by_id) != len(output["wear"]):
        raise ValueError("Duplicate catalog source ID")
    audit = []
    for decision in decisions:
        stable_id = decision["source_stable_id"]
        old = by_id.get(stable_id)
        source_class = candidate_by_id(source_index, stable_id)["source_class"] if source_index is not None else None
        _validate_decision(decision, source_class, allow_legacy=old is not None and _human_fields(old) == decision)
        if old:
            old_rev = old["decision_revision"]
            if decision["decision_revision"] < old_rev:
                raise ValueError("Cannot rewind human decision revision")
            if decision["decision_revision"] == old_rev and _human_fields(old) != decision:
                raise ValueError("Changed human fields require a higher revision")
        new = deepcopy(decision)
        new["status"] = new.pop("decision")
        if old and decision["decision_revision"] == old_rev:
            continue
        if old:
            audit.append({"source_stable_id": stable_id, "from": old["status"], "to": new["status"],
                          "revision": decision["decision_revision"]})
        else:
            audit.append({"source_stable_id": stable_id, "from": None, "to": new["status"],
                          "revision": decision["decision_revision"]})
        by_id[stable_id] = new
    old_effective = {r["source_stable_id"]: r.get("effective_status") for r in catalog["wear"]}
    for stable_id, record in by_id.items():
        current = current_fingerprints.get(stable_id)
        record["current_source_fingerprint"] = current if current != "UNSUPPORTED" else None
        dependent = imperfection_current.get(stable_id)
        if dependent is not None:
            record["current_imperfection_fingerprint"] = dependent["fingerprint"]
        else:
            record.pop("current_imperfection_fingerprint", None)
        record["effective_status"] = ("SOURCE_MISSING" if current is None else
                                      "UNSUPPORTED" if current == "UNSUPPORTED" else
                                      "STALE" if current != record["reviewed_source_fingerprint"] else
                                      dependent["status"] if dependent is not None and dependent["status"] != "CURRENT" else
                                      record["status"])
        previous = old_effective.get(stable_id)
        if previous is not None and previous != record["effective_status"]:
            audit.append({"source_stable_id": stable_id, "effective_from": previous,
                          "effective_to": record["effective_status"]})
    output["wear"] = [by_id[k] for k in sorted(by_id)]
    return output, audit


def query(catalog, semantic_category="", cause_tag="", surface_capability="", render_mode="", status="APPROVED", include_noncurrent=False):
    result = []
    for record in catalog.get("wear", []):
        if not include_noncurrent and record.get("effective_status") != "APPROVED":
            continue
        if status and record.get("effective_status") != status:
            continue
        if semantic_category and record.get("semantic_category") != semantic_category:
            continue
        if cause_tag and cause_tag not in record.get("cause_tags", []):
            continue
        if surface_capability and surface_capability not in record.get("surface_capabilities", []):
            continue
        if render_mode and record.get("render_mode") != render_mode:
            continue
        result.append(record)
    return result



def current_fingerprints(repository, index, records):
    """Recompute selected-resolution anchors; missing/unsupported never become current."""
    values = {}
    for record in records:
        stable_id = record["source_stable_id"]
        try:
            candidate = candidate_by_id(index, stable_id)
        except ValueError:
            values[stable_id] = None
            continue
        if candidate["source_class"] not in ("MASKED_DECAL", "IMPERFECTION_MASK"):
            values[stable_id] = "UNSUPPORTED"
            continue
        try:
            values[stable_id] = fingerprint_candidate(repository, candidate, record["selected_resolution"])["source_fingerprint"]
        except (FileNotFoundError, BoundaryError):
            values[stable_id] = None
        except ValueError:
            values[stable_id] = "UNSUPPORTED"
    return values


def current_imperfection_status(repository, index, records):
    """Classify optional secondary mask freshness without merging its anchor into the main source."""
    values = {}
    for record in records:
        mask = record.get("imperfection", {})
        if not isinstance(mask, dict) or not mask.get("source_stable_id"):
            continue
        stable_id = record["source_stable_id"]
        try:
            candidate = candidate_by_id(index, mask["source_stable_id"])
        except ValueError:
            values[stable_id] = {"status": "SOURCE_MISSING", "fingerprint": None}
            continue
        if candidate["source_class"] != "IMPERFECTION_MASK":
            values[stable_id] = {"status": "UNSUPPORTED", "fingerprint": None}
            continue
        try:
            digest = fingerprint_candidate(repository, candidate, mask["selected_resolution"])["source_fingerprint"]
        except (FileNotFoundError, BoundaryError):
            values[stable_id] = {"status": "SOURCE_MISSING", "fingerprint": None}
            continue
        except (ValueError, KeyError):
            values[stable_id] = {"status": "UNSUPPORTED", "fingerprint": None}
            continue
        values[stable_id] = {"status": "CURRENT" if digest == mask.get("source_fingerprint") else "STALE",
                             "fingerprint": digest}
    return values


def stage_current_approved(repository, index, record, cache_root, dry_run=False):
    if record.get("status") != "APPROVED" or record.get("effective_status") != "APPROVED":
        raise ValueError("Only current APPROVED wear may be restaged")
    candidate = candidate_by_id(index, record["source_stable_id"])
    staged = stage_candidate(repository, candidate, record["selected_resolution"], cache_root, dry_run=dry_run,
                             expected_fingerprint=record["reviewed_source_fingerprint"])
    return staged
