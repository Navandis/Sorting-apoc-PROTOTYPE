"""EAF3B commands. Source root always comes from EAF3A local_config.json.

Run from the project root: python -m tools.environment_authoring.material_catalog.cli <command>
"""
import argparse
import json
from pathlib import Path
import subprocess

from tools.environment_authoring.material_repository.path_guard import PROJECT_ROOT, load_repository
from tools.environment_authoring.material_repository.source_index import load_index, INDEX_PATH
from . import catalog, workflow


CATALOG_ROOT = PROJECT_ROOT / 'data/environment/material_catalog'
REVIEW_BATCHES = CATALOG_ROOT / 'review_batches'
CATALOG_PATH = CATALOG_ROOT / 'catalog.json'
CACHE_ROOT = PROJECT_ROOT / 'assets/environment/materials/kitbash_cache'
REPORT_ROOT = PROJECT_ROOT / 'reports/environment_material_catalog'
APPROVED_SPECS = CATALOG_ROOT / 'approved_specs'
GODOT = Path(r'D:\AI Tools\Godot-4.7-Codex\Godot_v4.7-stable_win64_console.exe')
CAPTURE_SCENE = 'res://gameplay/dev/environment_lookdev/environment_material_lookdev_capture.tscn'


def _batch_paths(batch_id):
    if not batch_id.isidentifier() or batch_id != batch_id.lower() or len(batch_id) > 64:
        raise ValueError('Invalid batch ID')
    return REVIEW_BATCHES / batch_id, REPORT_ROOT / 'reviews' / batch_id


def _project_input(value):
    raw = PROJECT_ROOT / value
    path = raw.resolve(strict=True)
    if not path.is_relative_to(PROJECT_ROOT) or path.is_symlink():
        raise ValueError('Decision/iteration file must remain inside the project')
    return path


def _read_json(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def _run_godot(*args):
    result = subprocess.run([str(GODOT), *args], cwd=PROJECT_ROOT, check=False)
    if result.returncode:
        raise RuntimeError(f'Godot failed with exit {result.returncode}')


def _audit_text(diff):
    return '\n'.join(['# EAF3B catalog reconciliation', ''] +
                     [f'- {name.replace("_", " ")}: {", ".join(items) if items else "none"}'
                      for name, items in diff.items()]) + '\n'


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    for name in ('prepare', 'capture', 'refresh-batch'):
        command = commands.add_parser(name)
        command.add_argument('--batch', required=True, help='Tracked batch ID, never a source path')
        if name == 'prepare':
            command.add_argument('--iteration', help='Project-local parameter iteration JSON')
    reconcile = commands.add_parser('reconcile')
    reconcile.add_argument('--decisions', required=True, help='Project-local human decision JSON')
    commands.add_parser('restage-approved')
    args = parser.parse_args(argv)
    try:
        if args.command in ('prepare', 'capture', 'refresh-batch'):
            spec_dir, review_dir = _batch_paths(args.batch)
            batch_path = spec_dir / 'batch.json'
            batch = _read_json(batch_path)
            index = load_index(INDEX_PATH)
            if args.command == 'refresh-batch':
                updated = catalog.make_batch(batch['batch_id'], index, batch['candidate_ids'],
                                             batch.get('notes', ''), batch.get('candidate_overrides', {}))
                updated['selection_rationale'] = batch.get('selection_rationale', {})
                workflow.write_json(batch_path, updated)
                print(f'Refreshed batch against EAF3A scan: {index["scan_finished_at"]}')
                return
            catalog.validate_batch(batch, index)
            if args.command == 'prepare':
                iteration = _read_json(_project_input(args.iteration)) if args.iteration else None
                result = workflow.prepare(batch, index, load_repository(), CACHE_ROOT, spec_dir, review_dir, iteration)
                print(f'Prepared {len(result["candidates"])} candidates: {review_dir}')
                return
            if not (review_dir / 'stage_manifest.json').exists():
                raise ValueError('Run prepare before capture')
            staged = _read_json(review_dir / 'stage_manifest.json')
            if staged['source_index_fingerprint'] != batch['source_index_fingerprint']:
                raise ValueError('Staged review belongs to another source snapshot')
            _run_godot('--headless', '--editor', '--path', str(PROJECT_ROOT), '--quit')
            changed = workflow.normalize_imports(staged['candidates'], CACHE_ROOT)
            print(f'Normalized {changed} Godot import records')
            _run_godot('--headless', '--editor', '--path', str(PROJECT_ROOT), '--quit')
            _run_godot('--path', str(PROJECT_ROOT), CAPTURE_SCENE, '--', '--capture', '--eaf3b-batch', args.batch)
            manifest = workflow.finalize_capture(review_dir)
            archive = workflow.package_review(review_dir)
            print(f'Captured {len(manifest["records"])} records: {review_dir}; shareable archive: {archive}')
            return
        index = load_index(INDEX_PATH)
        repository = load_repository()
        existing = _read_json(CATALOG_PATH)
        if existing.get('schema_version') != 1:
            raise ValueError('Unsupported catalog schema')
        records = existing.get('materials', [])
        if args.command == 'reconcile':
            manifest = _read_json(_project_input(args.decisions))
            catalog._reject_paths(manifest)
            if manifest.get('schema_version') != 1 or not isinstance(manifest.get('decisions'), list):
                raise ValueError('Unsupported decision manifest')
            decisions = [item for item in manifest['decisions'] if item.get('decision') != 'PENDING']
        else:
            decisions = []
        try:
            updated, diff = catalog.reconcile(records, decisions, index, repository)
        except ValueError as error:
            if 'Conflicting decision' in str(error):
                conflict = {'conflicts': [str(error)]}
                workflow.write_json(REPORT_ROOT / 'catalog_reconciliation_diff.json', conflict)
                (REPORT_ROOT / 'catalog_reconciliation_diff.md').write_text(_audit_text(conflict), encoding='utf-8')
            raise
        workflow.write_json(REPORT_ROOT / 'catalog_reconciliation_diff.json', diff)
        (REPORT_ROOT / 'catalog_reconciliation_diff.md').write_text(_audit_text(diff), encoding='utf-8')
        if args.command == 'restage-approved':
            completed, refused = catalog.restage_approved(updated, index, repository, CACHE_ROOT, APPROVED_SPECS)
            if completed:
                staged = [catalog.stage_candidate(repository,
                                                  catalog.candidate_by_id(index, record['source_stable_id']),
                                                  record['review_resolution'], CACHE_ROOT)
                          for record in updated if record['catalog_material_id'] in completed]
                _run_godot('--headless', '--editor', '--path', str(PROJECT_ROOT), '--quit')
                workflow.normalize_imports(staged, CACHE_ROOT)
                _run_godot('--headless', '--editor', '--path', str(PROJECT_ROOT), '--quit')
            workflow.write_json(REPORT_ROOT / 'approved_restage_report.json', {'restaged': completed, 'refused': refused})
            print(f'Restaged {len(completed)} current approved specs; refused {len(refused)}')
        workflow.write_json(CATALOG_PATH, {'schema_version': 1, 'materials': updated})
        print(_audit_text(diff))
    except (OSError, ValueError, RuntimeError, KeyError, TypeError) as error:
        parser.exit(1, f'EAF3B failed: {error}\n')


if __name__ == '__main__':
    main()
