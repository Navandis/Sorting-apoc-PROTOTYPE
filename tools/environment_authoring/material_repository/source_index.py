"""Portable source facts, fast signatures and deterministic incremental diffs."""
from collections import Counter, defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import time
from urllib.parse import quote

try:
    from .repository_profile import KITBASH_PROFILE_V1, CATEGORIES, CHANNELS, OPTIONAL_CHANNELS
    from .path_guard import PROJECT_ROOT
except ImportError:
    from repository_profile import KITBASH_PROFILE_V1, CATEGORIES, CHANNELS, OPTIONAL_CHANNELS
    from path_guard import PROJECT_ROOT

SCHEMA_VERSION = 1
SCANNER_REVISION = 'eaf3a-1'
REPORT_DIR = PROJECT_ROOT / 'reports/environment_material_catalog'
INDEX_PATH = REPORT_DIR / 'source_index.json'
DIFF_PATH = REPORT_DIR / 'scan_diff.json'


def fingerprint(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':')).encode()).hexdigest()


def quick_signature(relative, info):
    return {'relative_path': relative, 'size': info.st_size, 'mtime_ns': info.st_mtime_ns}


def package_key(package):
    return package['package_id'] + '@' + package['version']


def validate_index(index):
    if index.get('schema_version') != SCHEMA_VERSION:
        raise ValueError('Unsupported source index schema version')
    for collection, key in [('packages', package_key), ('material_candidates', lambda c: c['stable_id'])]:
        seen = set()
        for record in index[collection]:
            identity = key(record)
            if identity in seen:
                raise ValueError(f'Duplicate {collection} ID: {identity}')
            seen.add(identity)
    return index


def load_index(path=INDEX_PATH):
    return validate_index(json.loads(Path(path).read_text(encoding='utf-8')))


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + '.tmp')
    temporary.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    temporary.replace(path)


def scan(repository, profile=KITBASH_PROFILE_V1):
    start = time.perf_counter()
    started = datetime.now(timezone.utc).isoformat()
    packages = profile.packages(repository)
    by_root = {p['relative_root']: p for p in packages}
    package_files = defaultdict(list)
    groups = defaultdict(lambda: {'descriptors': [], 'maps': defaultdict(lambda: defaultdict(list)),
                                  'files': [], 'warnings': []})
    source_files = []
    counts = Counter({kind: 0 for kind in CATEGORIES})
    for relative, info in repository.walk_files():
        parts = relative.split('/')
        root = '/'.join(parts[:2])
        package = by_root.get(root)
        classification, material = profile.interpret('/'.join(parts[2:])) if package else ('UNKNOWN', None)
        signature = quick_signature(relative, info)
        source_files.append({**signature, 'classification': classification})
        counts[classification] += 1
        if not package:
            continue
        package_files[root].append(source_files[-1])
        if material is None:
            continue
        group = groups[(root, material['group'], material['stem'])]
        group['files'].append(signature)
        if classification == 'MATERIAL_DESCRIPTOR':
            group['descriptors'].append(relative)
            hints = profile.metadata_hints(repository, relative, info.st_size)
            for key, value in hints.items():
                existing = package['metadata_hints'].get(key)
                if existing and existing != value:
                    package['warnings'].append(f'conflicting_metadata:{key}')
                else:
                    package['metadata_hints'][key] = value
        elif material.get('graph'):
            group['warnings'].append('unsupported_substance_graph')
        else:
            resolution, channel = material['resolution'], material['channel']
            group['maps'][resolution][channel].append(signature)
            if resolution == 'UNKNOWN':
                group['warnings'].append('unknown_resolution')
            if channel not in CHANNELS:
                group['warnings'].append('unsupported_channel:' + channel)
    candidates = []
    for (root, logical_group, stem), data in sorted(groups.items()):
        package = by_root[root]
        coherent = any('basecolor' in channels and bool({'normal', 'roughness', 'metallic'} & channels.keys())
                       for channels in data['maps'].values())
        if not data['descriptors'] and not coherent:
            continue
        warnings = data['warnings']
        channel_states = {}
        for resolution, maps in sorted(data['maps'].items()):
            states = {}
            for channel in sorted(set(CHANNELS) | maps.keys()):
                if channel not in maps:
                    states[channel] = 'MISSING'
                elif channel not in CHANNELS:
                    states[channel] = 'UNSUPPORTED'
                elif len(maps[channel]) > 1:
                    states[channel] = 'AMBIGUOUS'
                    warnings.append(f'ambiguous_channel:{resolution}:{channel}')
                else:
                    states[channel] = 'OPTIONAL' if channel in OPTIONAL_CHANNELS else 'SUPPORTED'
            for channel in ('basecolor', 'normal', 'roughness', 'metallic'):
                if states[channel] == 'MISSING':
                    warnings.append(f'missing_channel:{resolution}:{channel}')
            channel_states[resolution] = states
        if not data['maps']:
            warnings.append('no_texture_maps')
        warnings.extend(profile.material_warnings(stem))
        identity = quote(stem, safe='-_.')
        if logical_group:
            identity = quote(logical_group, safe='/-_.') + '/' + identity
        record = {
            'stable_id': f"kitbash:{package['package_id']}@{package['version']}:{identity}",
            'display_name': stem, 'package_id': package['package_id'], 'package_version': package['version'],
            'relative_material_group': '/'.join(filter(None, (root, logical_group, stem))),
            'detection_evidence': 'both' if coherent and data['descriptors'] else ('descriptor' if data['descriptors'] else 'texture_set'),
            'available_resolutions': sorted(data['maps'], key=lambda r: (999 if r == 'UNKNOWN' else int(r[:-1]), r)),
            'maps_by_resolution': {r: {c: sorted(v, key=lambda f: f['relative_path']) for c, v in sorted(m.items())}
                                   for r, m in sorted(data['maps'].items())},
            'channel_states_by_resolution': channel_states,
            'descriptor_paths': sorted(data['descriptors']),
            'source_files': sorted(data['files'], key=lambda f: f['relative_path']),
            'suggested_family': profile.suggested_family(stem, package),
            'warnings': sorted(set(warnings)),
        }
        record['quick_fingerprint'] = fingerprint({'record': record, 'profile': profile.profile_id,
                                                    'profile_revision': profile.revision, 'scanner_revision': SCANNER_REVISION})
        candidates.append(record)
    for package in packages:
        files = package_files[package['relative_root']]
        package['content_summary'] = dict(sorted(Counter(f['classification'] for f in files).items()))
        hints = package['metadata_hints']
        package['display_name'] = hints.get('kitDisplayName', package['display_name'])
        if hints.get('kitId', package['package_id']).lower() != package['package_id']:
            package['warnings'].append('metadata_package_id_disagrees_with_path')
        if hints.get('kitVersion', package['version']) != package['version']:
            package['warnings'].append('metadata_version_disagrees_with_path')
        package['warnings'] = sorted(set(package['warnings']))
        package['quick_fingerprint'] = fingerprint({'files': files, 'package': package, 'profile_revision': profile.revision})
    index = {
        'schema_version': SCHEMA_VERSION, 'scanner_revision': SCANNER_REVISION,
        'profile_id': profile.profile_id, 'profile_revision': profile.revision,
        'scan_started_at': started, 'scan_finished_at': datetime.now(timezone.utc).isoformat(),
        'configured_root_diagnostic': str(repository.root),
        'scan_seconds': round(time.perf_counter() - start, 4),
        'total_repository_files': len(source_files), 'content_summary': dict(sorted(counts.items())),
        'non_material_summary': {k: counts[k] for k in CATEGORIES if not k.startswith('MATERIAL_')},
        'packages': sorted(packages, key=package_key),
        'material_candidates': sorted(candidates, key=lambda c: c['stable_id']),
        'source_files': source_files, 'warnings': sorted(set(repository.warnings)),
    }
    return validate_index(index)


def diff_indexes(previous, current):
    validate_index(current)
    if previous is not None:
        validate_index(previous)
    result = {'schema_version': 1, 'previous_scan': previous.get('scan_finished_at') if previous else None,
              'current_scan': current['scan_finished_at']}
    for collection, key in [('packages', package_key), ('material_candidates', lambda c: c['stable_id'])]:
        before = {key(c): c['quick_fingerprint'] for c in previous[collection]} if previous else {}
        after = {key(c): c['quick_fingerprint'] for c in current[collection]}
        result[collection] = {
            'new': sorted(after.keys() - before.keys()), 'removed': sorted(before.keys() - after.keys()),
            'changed': sorted(k for k in after.keys() & before.keys() if after[k] != before[k]),
            'unchanged': sorted(k for k in after.keys() & before.keys() if after[k] == before[k]),
        }
    return result


def summary_text(index, diff):
    lines = ['EAF3A SOURCE TRIAGE - no material approval or Godot staging',
             f"Files: {index['total_repository_files']} | Packages: {len(index['packages'])} | Material candidates: {len(index['material_candidates'])}",
             f"Scan wall time: {index['scan_seconds']:.4f} seconds", 'Content counts:']
    lines.extend(f'  {k}: {v}' for k, v in index['content_summary'].items())
    lines.append('Incremental diff:')
    for collection in ('packages', 'material_candidates'):
        lines.append(f"  {collection}: " + ', '.join(f'{k}={len(v)}' for k, v in diff[collection].items()))
    families = Counter(c['suggested_family'] for c in index['material_candidates'])
    warning_counts = Counter(w for c in index['material_candidates'] for w in c['warnings'])
    lines.extend(['Suggested families: ' + json.dumps(dict(sorted(families.items()))),
                  'Candidate warnings: ' + json.dumps(dict(sorted(warning_counts.items()))),
                  'Scan warnings: ' + json.dumps(index['warnings'])])
    return '\n'.join(lines) + '\n'
