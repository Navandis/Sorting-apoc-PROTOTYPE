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
    records = catalog["wear"] + decisions
    latest = workflow.current_fingerprints(repository, index, records)
    masks = workflow.current_imperfection_status(repository, index, records)
    updated, audit = workflow.reconcile(catalog, decisions, latest, masks)
    authoring.write_json(authoring.CATALOG, updated)
    audit_path = PROJECT_ROOT / "reports/environment_wear_catalog/catalog_audit.json"
    authoring.write_json(audit_path, {"changes": audit})
    print("EAF4B_RECONCILE", len(decisions), len(audit), audit_path)


def restage_approved():
    catalog = json.loads(authoring.CATALOG.read_text(encoding="utf-8"))
    index = load_index()
    repository = load_repository()
    current = workflow.current_fingerprints(repository, index, catalog["wear"])
    masks = workflow.current_imperfection_status(repository, index, catalog["wear"])
    updated, audit = workflow.reconcile(catalog, [], current, masks)
    authoring.write_json(authoring.CATALOG, updated)
    target_dir = authoring.DATA / "approved_specs"
    target_dir.mkdir(parents=True, exist_ok=True)
    count = 0
    approved_masks = []
    for record in workflow.query(updated):
        candidate = workflow.candidate_by_id(index, record["source_stable_id"])
        staged = workflow.stage_current_approved(repository, index, record, authoring.CACHE)
        if candidate["source_class"] == "IMPERFECTION_MASK":
            scalar = staged["maps"].get("roughness", staged["maps"].get("opacity"))
            approved_masks.append({"catalog_wear_id": record["catalog_wear_id"],
                                   "source_stable_id": record["source_stable_id"],
                                   "source_fingerprint": staged["source_fingerprint"],
                                   "texture": workflow.CACHE_RESOURCE_ROOT + "/" + scalar["cache_relative"],
                                   "modulation_only": True})
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
            mask_candidate = workflow.candidate_by_id(index, imperfection["source_stable_id"])
            if mask_candidate["source_class"] != "IMPERFECTION_MASK":
                raise ValueError("Approved imperfection reference is not a mask")
            mask_staged = workflow.stage_candidate(repository, mask_candidate,
                                                   imperfection["selected_resolution"], authoring.CACHE)
            if mask_staged["source_fingerprint"] != imperfection["source_fingerprint"]:
                raise ValueError("Approved imperfection mask changed during restaging")
            mask_maps = mask_staged["maps"]
            imperfection_resource = mask_maps.get("roughness", mask_maps.get("opacity"))["cache_relative"]
        (target_dir / (staged["catalog_wear_id"] + ".tres")).write_text(
            authoring.spec_text(entry, staged, candidate, imperfection_resource), encoding="utf-8")
        count += 1
    authoring.write_json(target_dir / "approved_masks.json",
                         {"schema_version": 1, "masks": approved_masks})
    print("EAF4B_RESTAGE_APPROVED", count, "freshness_changes", len(audit))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    for name in ("prepare", "capture"):
        command = commands.add_parser(name)
        command.add_argument("--batch", required=True)
    command = commands.add_parser("reconcile")
    command.add_argument("--decisions", required=True, help="Project-local human decision file")
    commands.add_parser("restage-approved")
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
        restage_approved()
    else:
        catalog = json.loads(authoring.CATALOG.read_text(encoding="utf-8"))
        for item in workflow.query(catalog, args.category, args.cause, args.capability, args.mode,
                                   status="" if args.include_noncurrent else "APPROVED",
                                   include_noncurrent=args.include_noncurrent):
            print(item["source_stable_id"], item["effective_status"])


if __name__ == "__main__":
    main()
