"""Stable-ID-only, index-only triage filters."""
import argparse
import json
from pathlib import Path

from .source_index import INDEX_PATH, DIFF_PATH, REPORT_DIR, load_index, fingerprint
from .profiles import CLASSES, PROFILE_REVISIONS


def candidate_maps(index, candidate):
    if candidate.get('atlas_texture_family_ref'):
        family = next(f for f in index['source_families'] if f['stable_id'] == candidate['atlas_texture_family_ref'])
        return {candidate['available_resolutions'][0]: {'basecolor': family['atlas_textures']}} if family['atlas_textures'] else {}
    return candidate['maps_by_resolution']


def query(index, *, source_class=None, profile=None, family=None, opacity=None,
          has_normal=None, has_roughness=None, has_alpha_mask=None, tileable=None,
          resolution=None, warnings=None, directory=None, name=None, status=None, diff=None, limit=None):
    if limit is not None and limit < 0:
        raise ValueError('limit must be non-negative')
    if status and (not diff or diff.get('current_scan') != index['scan_finished_at']):
        raise ValueError('Status query requires a diff for this exact scan')
    status_ids = set(diff['logical_candidates'][status]) if status else None
    result = []
    for c in index['logical_candidates']:
        if source_class and source_class != c['source_class'] or profile and profile != c['profile']:
            continue
        if family and family != c['suggested_family'] or opacity and opacity not in c['opacity_source']:
            continue
        if name and name.casefold() not in c['display_name'].casefold():
            continue
        if directory and directory.casefold() not in (c['relative_group'] + ' ' + c['family_id']).casefold():
            continue
        if status_ids is not None and c['stable_id'] not in status_ids:
            continue
        if tileable and c['tileable'] is not {'true': True, 'false': False, 'unknown': None}[tileable]:
            continue
        if warnings == 'none' and c['warnings']:
            continue
        if warnings and warnings != 'none' and not any(warnings == 'any' or warnings.lower() in w.lower() for w in c['warnings']):
            continue
        alpha_mask = bool({'EMBEDDED_ALPHA', 'ATLAS_ALPHA', 'SEPARATE_MASK'} & set(c['opacity_source']))
        if has_alpha_mask is not None and alpha_mask != has_alpha_mask:
            continue
        maps = candidate_maps(index, c)
        possible = [maps[r] for r in maps if not resolution or r == resolution.upper()]
        if resolution or has_normal is not None or has_roughness is not None:
            if not any((has_normal is None or bool(ch.get('normal')) == has_normal)
                       and (has_roughness is None or bool(ch.get('roughness')) == has_roughness) for ch in possible):
                continue
        result.append(c)
    result.sort(key=lambda c: c['stable_id'])
    return result if limit is None else result[:limit]


def index_fingerprint(index):
    return fingerprint([(c['stable_id'], c['quick_fingerprint']) for c in index['logical_candidates']])


def batch_manifest(index, candidates):
    return {'schema_version': 1, 'kind': 'eaf4_source_triage_batch', 'index_fingerprint': index_fingerprint(index),
            'stable_ids': sorted(c['stable_id'] for c in candidates)}


def select_batch(index, batch):
    if set(batch) != {'schema_version', 'kind', 'index_fingerprint', 'stable_ids'} or batch.get('schema_version') != 1 or batch.get('kind') != 'eaf4_source_triage_batch':
        raise ValueError('Unsupported batch; only stable IDs are accepted')
    if batch['index_fingerprint'] != index_fingerprint(index):
        raise ValueError('Stale batch: regenerate after rescan')
    records = {c['stable_id']: c for c in index['logical_candidates']}
    ids = batch['stable_ids']
    if not isinstance(ids, list) or any(not isinstance(i, str) or i not in records for i in ids):
        raise ValueError('Unknown stable ID')
    if len(ids) != len(set(ids)):
        raise ValueError('Duplicate batch stable IDs')
    return [records[i] for i in sorted(ids)]


def report_path(value):
    path = Path(value).resolve()
    if not path.is_relative_to(REPORT_DIR.resolve()):
        raise ValueError('Index/batch/output paths must remain in the EAF4 report directory')
    # Resolving the report root must not make a junction into another output/source tree valid.
    if REPORT_DIR.resolve() != REPORT_DIR.absolute():
        raise ValueError('Report directory must not redirect through a junction')
    return path


def add_filters(parser):
    parser.add_argument('--source-class', choices=CLASSES)
    parser.add_argument('--profile', choices=sorted(PROFILE_REVISIONS))
    parser.add_argument('--family')
    parser.add_argument('--opacity', choices=('SEPARATE_MASK', 'EMBEDDED_ALPHA', 'ATLAS_ALPHA', 'MATERIAL_SCALAR', 'NONE', 'UNKNOWN'))
    for flag in ('normal', 'roughness', 'alpha-mask'):
        parser.add_argument('--has-' + flag, action=argparse.BooleanOptionalAction, default=None)
    parser.add_argument('--tileable', choices=('true', 'false', 'unknown'))
    parser.add_argument('--resolution')
    parser.add_argument('--warnings', nargs='?', const='any', help='any, none, or warning substring')
    parser.add_argument('--directory', help='Relative source directory or family ID substring')
    parser.add_argument('--name')
    parser.add_argument('--status', choices=('new', 'changed', 'unchanged'))
    parser.add_argument('--limit', type=int)


def filter_arguments(args):
    return {k: getattr(args, k) for k in ('source_class', 'profile', 'family', 'opacity', 'has_normal', 'has_roughness', 'has_alpha_mask', 'tileable', 'resolution', 'warnings', 'directory', 'name', 'status', 'limit')}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--index', default=str(INDEX_PATH))
    parser.add_argument('--diff', default=str(DIFF_PATH))
    parser.add_argument('--format', choices=('json', 'ids', 'batch'), default='json')
    parser.add_argument('--output')
    add_filters(parser)
    args = parser.parse_args()
    try:
        index = load_index(report_path(args.index))
        diff = json.loads(report_path(args.diff).read_text(encoding='utf-8')) if args.status else None
        selected = query(index, diff=diff, **filter_arguments(args))
        value = batch_manifest(index, selected) if args.format == 'batch' else selected
        text = '\n'.join(c['stable_id'] for c in selected) if args.format == 'ids' else json.dumps(value, indent=2)
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
