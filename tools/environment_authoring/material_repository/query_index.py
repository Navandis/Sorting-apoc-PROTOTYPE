"""Deterministic index-only filtering. Batch manifests contain stable IDs."""
import argparse
import json
from pathlib import Path

try:
    from .source_index import INDEX_PATH, DIFF_PATH, REPORT_DIR, load_index, fingerprint, write_json
except ImportError:
    from source_index import INDEX_PATH, DIFF_PATH, REPORT_DIR, load_index, fingerprint, write_json


def query(index, *, package=None, name=None, family=None, resolution=None,
          required_channels=(), warnings=None, status=None, diff=None, limit=None):
    if status and (not diff or diff.get('current_scan') != index['scan_finished_at']):
        raise ValueError('Status filtering requires a diff for this exact index scan')
    status_ids = set(diff['material_candidates'][status]) if status else None
    result = []
    for candidate in sorted(index['material_candidates'], key=lambda c: c['stable_id']):
        if package and package.casefold() not in candidate['package_id'].casefold():
            continue
        if name and name.casefold() not in candidate['display_name'].casefold():
            continue
        if family and family != candidate['suggested_family']:
            continue
        if status_ids is not None and candidate['stable_id'] not in status_ids:
            continue
        if warnings == 'none' and candidate['warnings']:
            continue
        if warnings and warnings != 'none':
            if not candidate['warnings'] or (warnings != 'any' and not any(warnings.casefold() in w.casefold() for w in candidate['warnings'])):
                continue
        resolutions = [resolution.upper()] if resolution else candidate['available_resolutions']
        if resolution or required_channels:
            if not any(r in candidate['maps_by_resolution'] and all(
                    candidate['channel_states_by_resolution'][r].get(c) in {'SUPPORTED', 'OPTIONAL'}
                    for c in required_channels) for r in resolutions):
                continue
        result.append(candidate)
    return result if limit is None else result[:limit]


def index_fingerprint(index):
    return fingerprint([(c['stable_id'], c['quick_fingerprint']) for c in index['material_candidates']])


def batch_manifest(index, candidates):
    return {'schema_version': 1, 'kind': 'source_triage_batch', 'index_fingerprint': index_fingerprint(index),
            'stable_ids': sorted({c['stable_id'] for c in candidates})}


def select_batch(index, batch):
    if batch.get('schema_version') != 1 or batch.get('kind') != 'source_triage_batch':
        raise ValueError('Unsupported triage batch schema')
    if batch.get('index_fingerprint') != index_fingerprint(index):
        raise ValueError('Stale batch: regenerate the query after rescanning')
    records = {c['stable_id']: c for c in index['material_candidates']}
    ids = batch.get('stable_ids')
    if not isinstance(ids, list) or any(not isinstance(i, str) or i not in records for i in ids):
        raise ValueError('Batch must contain known stable IDs only')
    if len(ids) != len(set(ids)):
        raise ValueError('Duplicate batch stable IDs')
    return [records[i] for i in sorted(ids)]


def report_path(value):
    """CLI reports are project output, never another external source location."""
    path = Path(value).resolve()
    if not path.is_relative_to(REPORT_DIR.resolve()):
        raise ValueError(f'Index/batch/output paths must be inside {REPORT_DIR}')
    return path


def add_filters(parser):
    parser.add_argument('--package')
    parser.add_argument('--name')
    parser.add_argument('--family', choices=['concrete', 'cement_render', 'masonry_block', 'brick', 'tile', 'metal', 'wood', 'paint', 'other', 'unknown'])
    parser.add_argument('--resolution')
    parser.add_argument('--required-channel', action='append', default=[], dest='required_channels')
    parser.add_argument('--warnings', nargs='?', const='any', help='any, none, or warning substring')
    parser.add_argument('--status', choices=['new', 'changed', 'unchanged'])
    parser.add_argument('--limit', type=int)


def filter_arguments(args):
    if args.limit is not None and args.limit < 0:
        raise ValueError('limit must be non-negative')
    return {k: getattr(args, k) for k in ('package', 'name', 'family', 'resolution', 'required_channels', 'warnings', 'status', 'limit')}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--index', default=str(INDEX_PATH))
    parser.add_argument('--diff', default=str(DIFF_PATH))
    parser.add_argument('--format', choices=['json', 'ids', 'batch'], default='json')
    parser.add_argument('--output')
    add_filters(parser)
    args = parser.parse_args()
    try:
        index = load_index(report_path(args.index))
        diff = json.loads(report_path(args.diff).read_text(encoding='utf-8')) if args.status else None
        candidates = query(index, diff=diff, **filter_arguments(args))
        value = batch_manifest(index, candidates) if args.format == 'batch' else candidates
        text = '\n'.join(c['stable_id'] for c in candidates) if args.format == 'ids' else json.dumps(value, indent=2)
        if args.output:
            output = report_path(args.output)
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(text + '\n', encoding='utf-8')
        else:
            print(text)
    except (OSError, ValueError, KeyError) as error:
        parser.exit(1, f'Query failed: {error}\n')


if __name__ == '__main__':
    main()
