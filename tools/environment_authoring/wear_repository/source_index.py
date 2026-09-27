"""Versioned portable wear source index."""
from collections import Counter, defaultdict
import copy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import time
from urllib.parse import quote

from .path_guard import ARCHIVES, PROJECT_ROOT
from .profiles import (PROFILE_REVISIONS, CLASSES, IMAGES, MODELS, interpret_map,
                       normalize_group, resolution_key, read_metadata, suggestions, profile_for, classify)
from .image_facts import header, alpha_statistics, efficient_map
from .unreal_instance_parser import parse_instance, atlas_region
from .profiles.maps import fab_group

SCHEMA_VERSION = 1
SCANNER_REVISION = 'eaf4a-1'
REPORT_DIR = PROJECT_ROOT / 'reports/environment_wear_catalog'
INDEX_PATH = REPORT_DIR / 'source_index.json'
DIFF_PATH = REPORT_DIR / 'scan_diff.json'


def fingerprint(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode()).hexdigest()


def identity(*parts):
    return 'eaf4:' + ':'.join(quote(str(p), safe='-_.') for p in parts)


def quick_signature(relative, info):
    return {'relative_path': relative, 'size': info.st_size, 'mtime_ns': info.st_mtime_ns}


def signature_from_map(record):
    return {k: record[k] for k in ('relative_path', 'size', 'mtime_ns')}


def validate_index(index):
    if index.get('schema_version') != SCHEMA_VERSION:
        raise ValueError('Unsupported EAF4 source index schema')
    for collection in ('source_families', 'logical_candidates'):
        ids = [r['stable_id'] for r in index[collection]]
        if len(ids) != len(set(ids)):
            raise ValueError('Duplicate stable IDs: ' + collection)
    return index


def load_index(path=INDEX_PATH):
    return validate_index(json.loads(Path(path).read_text(encoding='utf-8')))


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + '.tmp')
    temp.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    temp.replace(path)


def _new_candidate(profile, group, name, display, maps, files, metadata):
    family, provenance = suggestions(display, metadata)
    size = metadata.get('physical_size') or {}
    return {'stable_id': identity(profile, group, name), 'display_name': display,
            'source_name': name, 'profile': profile, 'relative_group': group,
            'family_id': identity('family', profile, group), 'source_class': 'UNKNOWN', 'route': None,
            'available_resolutions': sorted(maps, key=resolution_key),
            'maps_by_resolution': {r: {c: sorted(v, key=lambda m: m['relative_path']) for c, v in sorted(ch.items())}
                                   for r, ch in sorted(maps.items(), key=lambda pair: resolution_key(pair[0]))},
            'source_files': sorted({f['relative_path']: f for f in files}.values(), key=lambda f: f['relative_path']),
            'opacity_source': ['UNKNOWN'], 'alpha_stats': None,
            'source_physical_width_m': size.get('width_m'), 'source_physical_height_m': size.get('height_m'),
            'physical_size_provenance': size or None, 'tileable': metadata.get('tileable'),
            'tileability_provenance': metadata.get('provenance') if metadata.get('tileable') is not None else None,
            'suggested_family': family, 'suggestion_evidence': provenance,
            'metadata_facts': metadata, 'warnings': list(metadata.get('warnings', []))}


def _finish_candidate(candidate):
    candidate['warnings'] = sorted(set(candidate['warnings']))
    candidate['quick_fingerprint'] = fingerprint({'record': candidate, 'scanner_revision': SCANNER_REVISION,
        'profile_revision': PROFILE_REVISIONS[candidate['profile']]})
    return candidate


def scan(repository):
    started, start = datetime.now(timezone.utc).isoformat(), time.perf_counter()
    files, archives, archives_by_directory, metadata_by_dir = {}, Counter(), defaultdict(Counter), defaultdict(list)
    image_headers, warnings = {}, []
    platform_bookkeeping = 0
    for relative, info in repository.walk_files():
        path = PurePosixPath(relative)
        ext = path.suffix.lower()
        if ext in ARCHIVES:
            archives[ext] += 1
            archives_by_directory[path.parts[0] if len(path.parts) > 1 else '.'][ext] += 1
            continue
        if '__MACOSX' in path.parts or path.name.startswith('._'):
            platform_bookkeeping += 1
            continue
        category = ('IMAGE' if ext in IMAGES else 'GEOMETRY' if ext in MODELS else 'METADATA' if ext == '.json'
                    else 'INSTANCE_NOTE' if ext == '.txt' and path.parts[0].lower() == 'unreal_extracted'
                    else 'UNSUPPORTED' if ext in ('.sbs', '.sbsar', '.blend', '.bin') else 'UNKNOWN')
        files[relative] = {**quick_signature(relative, info), 'content_class': category}
        if ext in IMAGES:
            image_headers[relative] = header(repository, relative)
        elif ext == '.json':
            metadata = read_metadata(repository, relative, info.st_size)
            if metadata.get('recognized'):
                metadata_by_dir[path.parent.as_posix()].append(metadata)
            else:
                warnings.extend(relative + ':' + w for w in metadata['warnings'])

    def nearest_metadata(relative):
        parent = PurePosixPath(relative).parent
        for directory in (parent, *parent.parents):
            values = metadata_by_dir.get(directory.as_posix(), [])
            if len(values) == 1:
                return values[0], directory.as_posix()
            if values:
                return {'warnings': ['ambiguous_package_metadata']}, parent.as_posix()
        return {}, parent.as_posix()

    alpha_cache = {}

    def alpha(record):
        relative = record['relative_path']
        if relative not in alpha_cache:
            alpha_cache[relative] = alpha_statistics(repository, relative)
        return alpha_cache[relative]

    def map_record(relative, parsed):
        facts = image_headers[relative]
        res = parsed['resolution']
        if res == 'UNKNOWN' and facts['width_px'] and max(facts['width_px'], facts['height_px']) in (1024, 2048, 4096, 8192, 16384):
            res = str(max(facts['width_px'], facts['height_px']) // 1024) + 'K'
        return res, {**signature_from_map(files[relative]), **facts,
                     'suffix': parsed['suffix'], 'normal_convention': parsed['normal_convention']}

    consumed, candidates, unreal_families = set(), [], {}
    for relative, source in files.items():
        if source['content_class'] != 'INSTANCE_NOTE' or source['size'] > 65536:
            continue
        with repository.open(relative) as stream:
            instance = parse_instance(stream.read().decode('utf-8-sig'), PurePosixPath(relative).stem)
        if not instance['parent_material'] or not instance['base_texture']:
            continue
        parent = PurePosixPath(relative).parent.as_posix()
        ref = instance['base_texture']
        # Only exact sibling stem association; metadata paths/URLs never get opened.
        matches = [p for p in image_headers if PurePosixPath(p).parent.as_posix() == parent
                   and isinstance(ref, str) and PurePosixPath(p).stem.casefold() == ref.casefold()]
        family_id = identity('unreal_atlas_family', parent, instance['parent_material'], ref)
        family = unreal_families.setdefault(family_id, {'stable_id': family_id,
            'profile': 'UNREAL_EXTRACTED_ATLAS_PROFILE', 'relative_group': parent,
            'parent_material': instance['parent_material'], 'atlas_name': ref,
            'atlas_textures': [], 'source_files': [], 'logical_ids': [], 'warnings': []})
        maps, entry_warnings = {}, list(instance['warnings'])
        entry_files = [signature_from_map(source)]
        stats = None
        if len(matches) == 1:
            atlas = matches[0]
            parsed = interpret_map(atlas)
            res, record = map_record(atlas, parsed)
            maps = {res: {'basecolor': [record]}}
            entry_files.append(signature_from_map(files[atlas]))
            if record['has_alpha']:
                stats = alpha(record)
            family['atlas_textures'] = [record]
            consumed.add(atlas)
        else:
            entry_warnings.append('atlas_texture_missing_or_ambiguous')
        entry = _new_candidate('UNREAL_EXTRACTED_ATLAS_PROFILE', parent, instance['instance_name'], instance['instance_name'], maps, entry_files, {})
        entry['stable_id'] = identity('unreal_atlas', family_id, instance['instance_name'])
        entry['family_id'] = family_id
        entry['source_class'] = 'UNREAL_ATLAS_DECAL_FAMILY'
        entry['unreal_instance'] = instance
        entry['alpha_stats'] = stats
        opacity = []
        if stats and stats['opaque_fraction'] < 1:
            opacity.append('ATLAS_ALPHA')
        if instance['parameters']['OpacityLevel']['recorded'] and type(instance['parameters']['OpacityLevel']['value']) in (int, float):
            opacity.append('MATERIAL_SCALAR')
        entry['opacity_source'] = opacity or ['UNKNOWN']
        region = atlas_region(instance)
        entry['atlas_region'] = region
        entry['atlas_region_status'] = region['status']
        if region['status'] != 'DERIVED':
            entry_warnings.append('atlas_region_needs_manual_metadata')
        if instance['parameters']['Length']['recorded'] or instance['parameters']['Height']['recorded']:
            entry_warnings.append('unreal_dimensions_units_unrecorded')
        entry['warnings'] = entry_warnings
        # Atlas source facts are stored once in the family. Logical entries reference it.
        entry['maps_by_resolution'] = {}
        entry['atlas_texture_family_ref'] = family_id
        entry['source_files'] = [signature_from_map(source)]
        entry['atlas_quick_signatures'] = entry_files[1:]
        candidates.append(_finish_candidate(entry))
        family['source_files'].extend(entry_files)
        family['logical_ids'].append(entry['stable_id'])
        family['warnings'].extend(entry_warnings)
        consumed.add(relative)

    groups = {}
    for relative, source in files.items():
        if relative in consumed or source['content_class'] not in ('IMAGE', 'GEOMETRY', 'UNSUPPORTED'):
            continue
        path = PurePosixPath(relative)
        metadata, package_dir = nearest_metadata(relative)
        fab_export = bool(metadata.get('logical_name')) and metadata.get('source_kind') in ('decal', 'imperfection', 'surface')
        if source['content_class'] == 'UNSUPPORTED' and not (fab_export and path.suffix.lower() == '.bin'):
            continue
        model = source['content_class'] == 'GEOMETRY' and not fab_export
        is_image = source['content_class'] == 'IMAGE'
        parsed = interpret_map(relative) if is_image else {'stem': path.stem, 'channel': None}
        group = fab_group(package_dir) if fab_export else normalize_group(package_dir if metadata.get('logical_name') else path.parent.as_posix())
        name = metadata.get('logical_name') if metadata.get('logical_name') and not model else parsed['stem']
        key = (group, name, model)
        data = groups.setdefault(key, {'maps': defaultdict(lambda: defaultdict(list)), 'files': [], 'metadata': metadata,
                                       'metadata_variants': {}, 'warnings': []})
        data['files'].append(signature_from_map(source))
        data['warnings'].extend(metadata.get('warnings', []))
        if metadata.get('provenance'):
            data['files'].append(signature_from_map(files[metadata['provenance']]))
            data['metadata_variants'][metadata['provenance']] = metadata
        if not is_image and fab_export:
            data['warnings'].append('unsupported_supplemental_export:' + path.suffix.lower())
        if is_image:
            res, record = map_record(relative, parsed)
            data['maps'][res][parsed['channel']].append(record)
            if parsed['channel'].startswith('packed_unknown:'):
                data['warnings'].append('packed_channel_semantics_unverified:' + parsed['channel'].split(':')[1])
            if parsed['channel'] == 'unknown_image':
                data['warnings'].append('unknown_image_suffix')
            if record['decode_warning']:
                data['warnings'].append(record['decode_warning'])

    for (group, name, model), data in sorted(groups.items()):
        maps, metadata = data['maps'], copy.deepcopy(data['metadata'])
        variants = list(data['metadata_variants'].values())
        if variants:
            metadata['source_metadata_variants'] = variants
            if len({v.get('tileable') for v in variants}) > 1:
                metadata['tileable'] = None
                data['warnings'].append('conflicting_tileability_metadata')
            sizes = {(v['physical_size']['width_m'], v['physical_size']['height_m']) if v.get('physical_size') else None for v in variants}
            if len(sizes) > 1:
                metadata['physical_size'] = None
                data['warnings'].append('conflicting_physical_size_metadata')
            if len({v.get('source_kind') for v in variants}) > 1:
                metadata['source_kind'] = None
                data['warnings'].append('conflicting_source_kind_metadata')
        channels = {c for ch in maps.values() for c in ch}
        profile = profile_for(metadata, channels, model)
        display = metadata.get('display_name') or name
        entry = _new_candidate(profile, group, name, display, maps, data['files'], metadata)
        opacity = ['SEPARATE_MASK'] if 'opacity' in channels else []
        alpha_evidence = []
        for color_channel in ('baseopacity', 'basecolor', 'unknown_image'):
            selected, _, _ = efficient_map(maps, (color_channel,))
            if selected and selected['has_alpha']:
                facts = alpha(selected)
                if facts:
                    alpha_evidence.append(facts)
        usable_alpha = [a for a in alpha_evidence if a['opaque_fraction'] < 1]
        entry['alpha_analysis'] = alpha_evidence
        entry['alpha_stats'] = (usable_alpha or alpha_evidence or [None])[0]
        if usable_alpha:
            opacity.append('EMBEDDED_ALPHA')
        selected, _, _ = efficient_map(maps, ('baseopacity', 'basecolor', 'unknown_image'))
        entry['opacity_source'] = opacity or ['NONE' if selected and selected['has_alpha'] is not None else 'UNKNOWN']
        entry['source_class'] = classify(metadata, channels, opacity, model)
        entry['route'] = 'EAF3' if entry['source_class'] == 'FULL_SURFACE_MATERIAL' else None
        entry['warnings'].extend(data['warnings'])
        if metadata.get('source_kind') == 'decal' and not opacity:
            entry['warnings'].append('missing_opacity_evidence')
        if model and entry['source_class'] == 'UNKNOWN':
            entry['warnings'].append('geometry_role_unverified')
        if entry['source_class'] == 'UNKNOWN' and 'basecolor' in channels and {'normal', 'roughness', 'orm'} & channels:
            entry['warnings'].append('surface_like_pbr_without_localization_or_tileability_metadata')
        for res, ch in maps.items():
            for channel, values in ch.items():
                if len(values) > 1:
                    entry['warnings'].append('multiple_channel_variants:' + res + ':' + channel)
        candidates.append(_finish_candidate(entry))

    families = dict(unreal_families)
    for c in candidates:
        if c['profile'] == 'UNREAL_EXTRACTED_ATLAS_PROFILE':
            continue
        f = families.setdefault(c['family_id'], {'stable_id': c['family_id'], 'profile': c['profile'],
            'relative_group': c['relative_group'], 'source_files': [], 'logical_ids': [], 'warnings': []})
        f['logical_ids'].append(c['stable_id'])
        f['source_files'].extend(c['source_files'])
        f['warnings'].extend(c['warnings'])
    for f in families.values():
        f['source_files'] = sorted({s['relative_path']: s for s in f['source_files']}.values(), key=lambda s: s['relative_path'])
        f['logical_ids'].sort()
        f['warnings'] = sorted(set(f['warnings']))
        f['quick_fingerprint'] = fingerprint({'family': f, 'candidates': [(c['stable_id'], c['quick_fingerprint']) for c in sorted(candidates, key=lambda c: c['stable_id']) if c['family_id'] == f['stable_id']]})
    counts = Counter(c['source_class'] for c in candidates)
    return validate_index({'schema_version': SCHEMA_VERSION, 'scanner_revision': SCANNER_REVISION,
        'profile_revisions': PROFILE_REVISIONS, 'scan_started_at': started,
        'scan_finished_at': datetime.now(timezone.utc).isoformat(),
        'scan_seconds': round(time.perf_counter() - start, 4), 'configured_root_diagnostic': str(repository.root),
        'total_repository_files_excluding_archives': len(files),
        'platform_bookkeeping_ignored_count': platform_bookkeeping,
        'archives_ignored': {'count': sum(archives.values()), 'by_extension': dict(sorted(archives.items())),
                            'by_top_directory': {d: dict(sorted(c.items())) for d, c in sorted(archives_by_directory.items())}},
        'source_families': sorted(families.values(), key=lambda f: f['stable_id']),
        'logical_candidates': sorted(candidates, key=lambda c: c['stable_id']),
        'source_class_summary': {k: counts[k] for k in CLASSES},
        'content_class_summary': dict(sorted(Counter(f['content_class'] for f in files.values()).items())),
        'source_files': list(files.values()), 'warnings': sorted(set(warnings + repository.warnings))})


def diff_indexes(previous, current):
    validate_index(current)
    if previous:
        validate_index(previous)
    result = {'schema_version': 1, 'previous_scan': previous['scan_finished_at'] if previous else None,
              'current_scan': current['scan_finished_at']}
    for collection in ('source_families', 'logical_candidates'):
        before = {r['stable_id']: r['quick_fingerprint'] for r in previous[collection]} if previous else {}
        after = {r['stable_id']: r['quick_fingerprint'] for r in current[collection]}
        result[collection] = {'new': sorted(after.keys() - before.keys()), 'removed': sorted(before.keys() - after.keys()),
            'changed': sorted(k for k in before.keys() & after.keys() if before[k] != after[k]),
            'unchanged': sorted(k for k in before.keys() & after.keys() if before[k] == after[k])}
    return result


def aggregate_statistics(index):
    return {'schema_version': 1, 'repository_files_excluding_archives': index['total_repository_files_excluding_archives'],
            'platform_bookkeeping_ignored_count': index['platform_bookkeeping_ignored_count'],
            'archives_ignored': index['archives_ignored'], 'source_family_count': len(index['source_families']),
            'logical_candidate_count': len(index['logical_candidates']), 'per_class': index['source_class_summary'],
            'per_profile': dict(sorted(Counter(c['profile'] for c in index['logical_candidates']).items())),
            'semantic_families': dict(sorted(Counter(c['suggested_family'] for c in index['logical_candidates']).items())),
            'warning_counts': dict(sorted(Counter(w for c in index['logical_candidates'] for w in c['warnings']).items())),
            'unreal_atlas_family_count': sum(f['profile'] == 'UNREAL_EXTRACTED_ATLAS_PROFILE' for f in index['source_families']),
            'unreal_logical_entry_count': sum(c['profile'] == 'UNREAL_EXTRACTED_ATLAS_PROFILE' for c in index['logical_candidates']),
            'scan_seconds': index['scan_seconds']}


def summary_text(index, diff):
    stats = aggregate_statistics(index)
    lines = ['EAF4A SOURCE TRIAGE - HUMAN REVIEW PENDING',
             'Configured root: ' + index['configured_root_diagnostic'],
             f"Files excluding archives: {stats['repository_files_excluding_archives']} | Archives ignored: {index['archives_ignored']['count']}",
             f"Families: {stats['source_family_count']} | Logical candidates: {stats['logical_candidate_count']}",
             f"Unreal families: {stats['unreal_atlas_family_count']} | Logical entries: {stats['unreal_logical_entry_count']}",
             f"Scan seconds: {index['scan_seconds']}", 'Source classes: ' + json.dumps(stats['per_class'])]
    lines += [collection + ': ' + ', '.join(k + '=' + str(len(v)) for k, v in diff[collection].items()) for collection in ('source_families', 'logical_candidates')]
    lines.append('Classification is source evidence only. No artistic approval, staging or runtime integration.')
    return '\n'.join(lines) + '\n'


def save_scan(current):
    from .query_index import report_path
    report_path(REPORT_DIR)
    previous = load_index() if INDEX_PATH.exists() else None
    diff = diff_indexes(previous, current)
    write_json(INDEX_PATH, current)
    write_json(DIFF_PATH, diff)
    write_json(REPORT_DIR / 'aggregate_statistics.json', aggregate_statistics(current))
    (REPORT_DIR / '.gdignore').touch()
    summary = summary_text(current, diff)
    (REPORT_DIR / 'scan_summary.txt').write_text(summary, encoding='utf-8')
    return summary
