"""EAF4B batch staging, capture, human reconciliation and approved restaging.

Run from project root: python -m tools.environment_authoring.wear_catalog.cli <command>
No command accepts an external source path or root.
"""
import argparse
import json
from pathlib import Path
import subprocess

from tools.environment_authoring.wear_repository.path_guard import PROJECT_ROOT, load_repository
from tools.environment_authoring.wear_repository.source_index import load_index
from . import workflow, authoring

GODOT = Path(r"D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe")
REVIEW_SCENE = "res://gameplay/dev/environment_wear/environment_wear_review.tscn"


def project_input(value):
    path = (PROJECT_ROOT / value).resolve(strict=True)
    if not path.is_relative_to(PROJECT_ROOT) or path.is_symlink():
        raise ValueError("Decision file must be project-local")
    return path


def run_godot(*args):
    result = subprocess.run([str(GODOT), *args], cwd=PROJECT_ROOT, check=False)
    if result.returncode:
        raise RuntimeError("Godot exited " + str(result.returncode))


def reconcile_decisions(input_path):
    manifest = json.loads(project_input(input_path).read_text(encoding="utf-8"))
    workflow._reject_external_paths(manifest)
    if manifest.get("schema_version") != 1 or not isinstance(manifest.get("decisions"), list):
        raise ValueError("Invalid human decision manifest")
    decisions = [x for x in manifest["decisions"] if x.get("decision") != "PENDING"]
    catalog = json.loads(authoring.CATALOG.read_text(encoding="utf-8"))
    index = load_index()
    repository = load_repository()
    workflow.validate_decision_sources(repository, index, decisions, catalog)
    records = catalog["wear"] + decisions
    latest = workflow.current_fingerprints(repository, index, records)
    masks = workflow.current_imperfection_status(repository, index, records)
    updated, audit = workflow.reconcile(catalog, decisions, latest, masks, source_index=index)
    authoring.write_json(authoring.CATALOG, updated)
    audit_path = PROJECT_ROOT / "reports/environment_wear_catalog/catalog_audit.json"
    authoring.write_json(audit_path, {"changes": audit})
    print("EAF4B_RECONCILE", len(decisions), len(audit), audit_path)


def restage_approved(output_dir=None, dry_run=False):
    """Plan and validate every export first; optional scratch output never writes catalog."""
    catalog = json.loads(authoring.CATALOG.read_text(encoding="utf-8"))
    index = load_index()
    repository = load_repository()
    # Validate historical/scoped approvals even if freshness would exclude them
    # from query: an unavailable selected channel must not silently disappear.
    mask_decisions = [workflow._human_fields(r) for r in catalog["wear"]
                      if r.get("status") == "APPROVED" and workflow.candidate_by_id(
                          index, r["source_stable_id"])["source_class"] == "IMPERFECTION_MASK"]
    workflow.validate_decision_sources(repository, index, mask_decisions, catalog)
    current = workflow.current_fingerprints(repository, index, catalog["wear"])
    masks = workflow.current_imperfection_status(repository, index, catalog["wear"])
    updated, audit = workflow.reconcile(catalog, [], current, masks)
    target_dir = Path(output_dir) if output_dir is not None else authoring.DATA / "approved_specs"
    count = 0
    approved_masks = []
    specs = {}
    stage_requests = {}
    for record in workflow.query(updated):
        candidate = workflow.candidate_by_id(index, record["source_stable_id"])
        staged = workflow.stage_current_approved(repository, index, record, authoring.CACHE, dry_run=True)
        stage_requests[(record["source_stable_id"], record["selected_resolution"])] = staged
        if candidate["source_class"] == "IMPERFECTION_MASK":
            channel, uses = workflow.mask_scope(record, allow_legacy=True)
            scalar = staged["maps"][channel.split(".")[0]]
            approved_masks.append({"catalog_wear_id": record["catalog_wear_id"],
                                   "source_stable_id": record["source_stable_id"],
                                   "source_fingerprint": staged["source_fingerprint"],
                                   "texture": workflow.CACHE_RESOURCE_ROOT + "/" + scalar["cache_relative"],
                                   "modulation_only": uses == ["WEAR_OPACITY_MODULATION"],
                                   "scalar_channel": channel, "supported_uses": uses,
                                   "scalar_sha256": scalar["sha256"]})
            count += 1
            continue
        entry = {"semantic_category": record["semantic_category"], "cause_tags": record["cause_tags"],
                 "surface_capabilities": record["surface_capabilities"],
                 "selection_rationale": record.get("review_notes", ""),
                 "initial_parameters": {"render_mode": record["render_mode"],
                                        "physical_size_m": record["default_size"],
                                        "surface_offset_m": record["surface_offset"],
                                        "opacity_multiplier": record["opacity"],
                                        "albedo_strength": record["albedo_strength"],
                                        "normal_strength": record["normal_strength"],
                                        "roughness_strength": record["roughness_strength"],
                                        "normal_y_flip": record.get("normal_y_flip", False),
                                        "albedo_tint": record.get("albedo_tint", [1.0, 1.0, 1.0]),
                                        "edge_feather": record.get("edge_feather", 0.035),
                                        "imperfection": record.get("imperfection", {}),
                                        "provenance": "human-approved"}}
        imperfection_resource = ""
        imperfection = record.get("imperfection", {})
        if imperfection.get("source_stable_id"):
            if staged["catalog_wear_id"] not in workflow.LEAKAGE_MODULATION_IDS or record["render_mode"] != "SOFT_BLEND":
                raise ValueError("Wear opacity modulation is restricted to the two approved soft Leakage effects")
            mask_candidate = workflow.candidate_by_id(index, imperfection["source_stable_id"])
            if mask_candidate["source_class"] != "IMPERFECTION_MASK":
                raise ValueError("Approved imperfection reference is not a mask")
            mask_record = next((r for r in updated["wear"] if r["source_stable_id"] == imperfection["source_stable_id"]), None)
            if mask_record is None or mask_record.get("effective_status") != "APPROVED":
                raise ValueError("Dependent mask requires a current APPROVED source decision")
            if mask_record["selected_resolution"] != imperfection["selected_resolution"] or mask_record["reviewed_source_fingerprint"] != imperfection["source_fingerprint"]:
                raise ValueError("Dependent mask differs from its reviewed resolution/fingerprint")
            channel, uses = workflow.mask_scope(mask_record, allow_legacy=True)
            if "WEAR_OPACITY_MODULATION" not in uses:
                raise ValueError("Dependent mask is not approved for WEAR_OPACITY_MODULATION")
            mask_staged = workflow.stage_candidate(repository, mask_candidate,
                                                   imperfection["selected_resolution"], authoring.CACHE, dry_run=True)
            if mask_staged["source_fingerprint"] != imperfection["source_fingerprint"]:
                raise ValueError("Approved imperfection mask changed during restaging")
            imperfection_resource = mask_staged["maps"][channel.split(".")[0]]["cache_relative"]
            stage_requests[(mask_record["source_stable_id"], mask_record["selected_resolution"])] = mask_staged
        specs[staged["catalog_wear_id"] + ".tres"] = authoring.spec_text(entry, staged, candidate, imperfection_resource)
        count += 1
    plan = {"catalog": updated, "masks": approved_masks, "specs": specs}
    if dry_run:
        return plan
    # No canonical writes until all scopes, map bindings and resource text pass.
    cache = target_dir / "cache" if output_dir is not None else authoring.CACHE
    for (stable_id, resolution), expected in stage_requests.items():
        workflow.stage_candidate(repository, workflow.candidate_by_id(index, stable_id), resolution, cache,
                                 expected_fingerprint=expected["source_fingerprint"])
    if output_dir is None:
        _write_if_changed(authoring.CATALOG, json.dumps(updated, indent=2, ensure_ascii=False) + "\n")
    for filename, text in specs.items():
        _write_if_changed(target_dir / filename, text)
    _write_if_changed(target_dir / "approved_masks.json", json.dumps(
        {"schema_version": 1, "masks": approved_masks}, indent=2, ensure_ascii=False) + "\n")
    print("EAF4B_RESTAGE_APPROVED", count, "freshness_changes", len(audit))
    return plan


def _write_if_changed(path, text):
    path = Path(path)
    if path.exists() and path.read_text(encoding="utf-8") == text:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    for name in ("prepare", "capture"):
        command = commands.add_parser(name)
        command.add_argument("--batch", required=True)
    command = commands.add_parser("reconcile")
    command.add_argument("--decisions", required=True, help="Project-local human decision file")
    restage = commands.add_parser("restage-approved")
    restage.add_argument("--output-dir", help="Project-local scratch destination; leaves canonical catalog/specs untouched")
    restage.add_argument("--dry-run", action="store_true", help="Validate and plan without any output writes")
    rerun = commands.add_parser("capture-rerun")
    rerun.add_argument("--rerun", required=True)
    query = commands.add_parser("query")
    query.add_argument("--category", default="")
    query.add_argument("--cause", default="")
    query.add_argument("--capability", default="")
    query.add_argument("--mode", default="")
    query.add_argument("--include-noncurrent", action="store_true")
    args = parser.parse_args(argv)
    if args.command == "prepare":
        authoring.prepare(args.batch)
    elif args.command == "capture":
        batch_id = authoring._safe_batch(args.batch)
        if batch_id != "wear_foundation_01":
            raise ValueError("Review scene is configured for wear_foundation_01")
        stage_path = authoring.REPORTS / batch_id / "stage_manifest.json"
        if not stage_path.is_file():
            raise ValueError("Run prepare before capture")
        stage = json.loads(stage_path.read_text(encoding="utf-8"))
        batch = json.loads((authoring.BATCHES / batch_id / "batch.json").read_text(encoding="utf-8"))
        workflow.validate_batch(batch, load_index())
        if stage["source_index_fingerprint"] != batch["source_index_fingerprint"]:
            raise ValueError("Staged assets do not match current batch")
        run_godot("--headless", "--editor", "--path", str(PROJECT_ROOT), "--quit")
        changed = authoring.normalize_imports(stage["candidates"], authoring.CACHE)
        if changed:
            run_godot("--headless", "--editor", "--path", str(PROJECT_ROOT), "--quit")
        run_godot("--path", str(PROJECT_ROOT), REVIEW_SCENE, "--", "--eaf4b-capture")
        archive = authoring.package_review(batch_id)
        print("EAF4B_CAPTURE_PACKAGE", archive)
    elif args.command == "capture-rerun":
        config = authoring.prepare_rerun(args.rerun)
        if config["rerun_id"] != "wear_foundation_01_rerun_01":
            raise ValueError("Review scene is configured for wear_foundation_01_rerun_01")
        run_godot("--headless", "--editor", "--path", str(PROJECT_ROOT), "--quit")
        run_godot("--path", str(PROJECT_ROOT), REVIEW_SCENE, "--", "--eaf4b-rerun")
        archive = authoring.package_review(config["rerun_id"])
        print("EAF4B_RERUN_CAPTURE_PACKAGE", archive)
    elif args.command == "reconcile":
        reconcile_decisions(args.decisions)
    elif args.command == "restage-approved":
        destination = None
        if args.output_dir:
            destination = (PROJECT_ROOT / args.output_dir).resolve()
            if not destination.is_relative_to(PROJECT_ROOT):
                raise ValueError("Scratch output must be project-local")
        plan = restage_approved(output_dir=destination, dry_run=args.dry_run)
        if args.dry_run:
            print("EAF4B_RESTAGE_DRY_RUN", len(plan["specs"]), "specs", len(plan["masks"]), "masks; no writes")
    else:
        catalog = json.loads(authoring.CATALOG.read_text(encoding="utf-8"))
        for item in workflow.query(catalog, args.category, args.cause, args.capability, args.mode,
                                   status="" if args.include_noncurrent else "APPROVED",
                                   include_noncurrent=args.include_noncurrent):
            print(item["source_stable_id"], item["effective_status"])


if __name__ == "__main__":
    main()
