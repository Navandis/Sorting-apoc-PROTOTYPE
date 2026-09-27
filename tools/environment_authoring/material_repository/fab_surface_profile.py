"""Conservative Megascans/Fab full-surface interpretation within the EAF3 root."""
from collections import defaultdict
import json
from pathlib import PurePosixPath
import re

try:
    from .repository_profile import CHANNELS, OPTIONAL_CHANNELS, IMAGES
except ImportError:
    from repository_profile import CHANNELS, OPTIONAL_CHANNELS, IMAGES

PROFILE_ID = 'FAB_SURFACE_PROFILE_V1'
REVISION = 1
_RESOLUTION = re.compile(r'(?i)(?<![a-z0-9])(1|2|4|8|16)k(?![a-z0-9])')
_SUFFIXES = {
    'base_color': 'basecolor', 'basecolor': 'basecolor', 'albedo': 'basecolor',
    'normal_directx': 'normal', 'normal_opengl': 'normal', 'normaldx': 'normal',
    'normalgl': 'normal', 'normal': 'normal', 'roughness': 'roughness',
    'metalness': 'metallic', 'metallic': 'metallic', 'ao': 'ao',
    'ambientocclusion': 'ao', 'height': 'height', 'displacement': 'height',
    'opacity': 'opacity', 'alpha': 'opacity', 'emissive': 'emissive',
    'emission': 'emissive', 'specular': 'specular', 'cavity': 'cavity',
    'bump': 'bump', 'glossiness': 'gloss', 'gloss': 'gloss',
    'orm': 'orm', 'mr': 'mr', 'rsmo': 'rsmo',
}
_FAMILIES = (
    ('cement_render', ('plaster', 'render', 'stucco', 'cement render')),
    ('masonry_block', ('masonry', 'cinder', 'concrete block')),
    ('concrete', ('concrete',)), ('brick', ('brick',)),
    ('tile', ('tile', 'ceramic')), ('metal', ('metal', 'steel', 'iron')),
    ('wood', ('wood', 'timber')), ('paint', ('paint',)),
)


def classify(relative):
    path = PurePosixPath(relative)
    if path.suffix.lower() == '.json':
        return 'METADATA'
    if path.suffix.lower() in IMAGES:
        return 'MATERIAL_TEXTURE'
    if path.suffix.lower() in ('.gltf', '.glb', '.fbx', '.obj'):
        return 'MODEL'
    return 'UNKNOWN'


def _group(relative):
    parent = PurePosixPath(relative).parent.as_posix()
    return _RESOLUTION.sub('', parent).rstrip('_-/').casefold()


def _map(relative):
    path = PurePosixPath(relative)
    if path.suffix.lower() not in IMAGES:
        return None
    match = _RESOLUTION.search(path.stem) or _RESOLUTION.search(path.parent.name)
    resolution = match[1] + 'K' if match else 'UNKNOWN'
    stem = path.stem.casefold()
    for suffix in sorted(_SUFFIXES, key=lambda s: (-len(s), s)):
        if stem.endswith('_' + suffix):
            convention = ('DIRECTX' if suffix in ('normal_directx', 'normaldx') else
                          'OPENGL' if suffix in ('normal_opengl', 'normalgl') else None)
            return resolution, _SUFFIXES[suffix], convention
    return resolution, 'unknown_image', None


def _belongs_to_asset(relative, asset_id):
    stem = PurePosixPath(relative).stem
    return re.search(r'(?i)(?:^|[_-])' + re.escape(asset_id) + r'(?:[_-]|$)', stem) is not None


def _metadata(repository, relative, size):
    if size > 2 * 1024 * 1024:
        return None
    try:
        with repository.open(relative) as source:
            data = json.load(source)
    except (ValueError, UnicodeError):
        return None
    if not isinstance(data, dict) or not isinstance(data.get('maps'), list):
        return None
    tags = data.get('semanticTags')
    if not isinstance(tags, dict) or tags.get('asset_type') != 'surface':
        return None
    asset_id = data.get('id')
    if not isinstance(asset_id, str) or not re.fullmatch(r'[A-Za-z0-9_-]+', asset_id):
        return None
    rows = data.get('meta', [])
    meta = {row['key']: row.get('value') for row in rows
            if isinstance(row, dict) and isinstance(row.get('key'), str)} if isinstance(rows, list) else {}
    area = meta.get('scanArea')
    physical = None
    if isinstance(area, str):
        match = re.fullmatch(r'\s*(\d+(?:\.\d+)?)\s*[x×]\s*(\d+(?:\.\d+)?)\s*m\s*', area)
        if match and float(match[1]) > 0 and float(match[2]) > 0:
            physical = {'width_m': float(match[1]), 'height_m': float(match[2]),
                        'raw': area, 'provenance': relative + '#meta.scanArea'}
    tileable = meta.get('tileable')
    return {'id': asset_id, 'name': data.get('name') if isinstance(data.get('name'), str) else asset_id,
            'categories': data.get('assetCategories', {}), 'tileable': tileable if type(tileable) is bool else None,
            'physical': physical, 'provenance': relative,
            'warnings': ['unparsed_scan_area'] if area is not None and physical is None else []}


def _family(name, categories):
    for evidence in (json.dumps(categories, sort_keys=True).casefold(), name.casefold()):
        for family, tokens in _FAMILIES:
            if any(token in evidence for token in tokens):
                return family
    return 'unknown'


def candidates(repository, files, quick_signature, fingerprint):
    """Build records from one pre-enumerated FAB subtree, using guarded reads."""
    by_folder = defaultdict(list)
    for relative, info in files:
        by_folder[PurePosixPath(relative).parent.as_posix()].append((relative, info))
    by_id = {}
    for folder, entries in sorted(by_folder.items()):
        metadata = [_metadata(repository, rel, info.st_size) for rel, info in entries
                    if PurePosixPath(rel).suffix.lower() == '.json']
        metadata = [m for m in metadata if m]
        if not metadata:
            continue
        if len(metadata) != 1:
            raise ValueError(f'Ambiguous FAB surface metadata: {folder}')
        facts = metadata[0]
        logical_group = _group(folder + '/map.jpg')
        previous = by_id.get(facts['id'])
        if previous and previous['logical_group'] != logical_group:
            raise ValueError(f'Duplicate FAB asset ID in different logical groups: {facts["id"]}')
        physical_dimensions = lambda value: ((value['width_m'], value['height_m']) if value else None)
        if previous and (previous['name'] != facts['name'] or previous['tileable'] != facts['tileable'] or
                         physical_dimensions(previous['physical']) != physical_dimensions(facts['physical'])):
            raise ValueError(f'Conflicting FAB metadata for asset ID: {facts["id"]}')
        folder_resolutions = {parsed[0] for rel, _ in entries
                              if _belongs_to_asset(rel, facts['id']) and (parsed := _map(rel))}
        if previous and previous['folder_resolutions'] & folder_resolutions:
            raise ValueError(f'Duplicate FAB asset ID and resolution: {facts["id"]}')
        group = by_id.setdefault(facts['id'], {**facts, 'logical_group': logical_group,
                                                'files': [], 'maps': defaultdict(lambda: defaultdict(list)),
                                                'normal_variants': defaultdict(list), 'provenances': [],
                                                'folder_resolutions': set()})
        group['folder_resolutions'].update(folder_resolutions)
        group['provenances'].append(facts['provenance'])
        for relative, info in entries:
            if relative != facts['provenance'] and not _belongs_to_asset(relative, facts['id']):
                continue
            signature = quick_signature(relative, info)
            group['files'].append(signature)
            interpreted = _map(relative)
            if interpreted:
                resolution, channel, convention = interpreted
                group['maps'][resolution][channel].append(signature)
                if channel == 'normal':
                    group['normal_variants'][resolution].append((convention, signature))
    result = []
    for asset_id, group in sorted(by_id.items()):
        maps_by_resolution, states_by_resolution, normal_conventions, normal_variants = {}, {}, {}, {}
        warnings = list(group['warnings'])
        for resolution, channels in sorted(group['maps'].items()):
            if resolution == 'UNKNOWN':
                warnings.append('unknown_resolution')
            normal = group['normal_variants'].get(resolution, [])
            if normal:
                normal_variants[resolution] = sorted(
                    ({'convention': kind or 'UNKNOWN', 'relative_path': record['relative_path']}
                     for kind, record in normal), key=lambda item: item['relative_path'])
            conventions = {kind for kind, _ in normal}
            if normal:
                if len(normal) == 1:
                    normal_conventions[resolution] = normal[0][0] or 'UNKNOWN'
                    if normal[0][0] is None:
                        warnings.append('normal_convention_unverified')
                elif conventions == {'OPENGL', 'DIRECTX'} and len(normal) == 2:
                    channels['normal'] = [record for kind, record in normal if kind == 'OPENGL']
                    normal_conventions[resolution] = 'OPENGL'
                    warnings.append('directx_normal_variant_available')
                else:
                    normal_conventions[resolution] = 'AMBIGUOUS'
                    warnings.append(f'ambiguous_normal_variant:{resolution}')
            maps_by_resolution[resolution] = {channel: sorted(records, key=lambda r: r['relative_path'])
                                               for channel, records in sorted(channels.items())}
            states = {}
            for channel in sorted(set(CHANNELS) | channels.keys()):
                records = channels.get(channel, [])
                if not records:
                    states[channel] = 'MISSING'
                elif channel not in CHANNELS:
                    states[channel] = 'UNSUPPORTED'
                    warnings.append('unsupported_channel:' + channel)
                elif len(records) > 1 or (channel == 'normal' and normal_conventions.get(resolution) == 'AMBIGUOUS'):
                    states[channel] = 'AMBIGUOUS'
                    warnings.append(f'ambiguous_channel:{resolution}:{channel}')
                else:
                    states[channel] = 'OPTIONAL' if channel in OPTIONAL_CHANNELS else 'SUPPORTED'
            states_by_resolution[resolution] = states
        available = [resolution for resolution, states in states_by_resolution.items()
                     if resolution != 'UNKNOWN' and states.get('basecolor') == 'SUPPORTED' and
                     any(states.get(c) == 'SUPPORTED' for c in ('normal', 'roughness', 'metallic'))]
        for resolution in states_by_resolution:
            if resolution not in available:
                warnings.append(f'incomplete_resolution:{resolution}')
        if not available:
            continue
        record = {'stable_id': 'fab:' + asset_id, 'display_name': group['name'],
                  'package_id': 'fab', 'package_version': 'source',
                  'relative_material_group': 'FAB/' + group['logical_group'].removeprefix('fab/'),
                  'detection_evidence': 'recognized_surface_metadata+texture_set',
                  'available_resolutions': sorted(available,
                                                  key=lambda r: (999 if r == 'UNKNOWN' else int(r[:-1]), r)),
                  'maps_by_resolution': maps_by_resolution,
                  'channel_states_by_resolution': states_by_resolution,
                  'descriptor_paths': [], 'source_files': sorted(group['files'], key=lambda f: f['relative_path']),
                  'suggested_family': _family(group['name'], group['categories']),
                  'warnings': sorted(set(warnings)), 'source_profile_id': PROFILE_ID,
                  'source_profile_revision': REVISION, 'source_asset_id': asset_id,
                  'tileable': group['tileable'], 'source_physical_size': group['physical'],
                  'metadata_provenance': sorted(group['provenances']),
                  'normal_conventions_by_resolution': normal_conventions,
                  'normal_variants_by_resolution': normal_variants}
        record['quick_fingerprint'] = fingerprint({'record': record, 'profile': PROFILE_ID,
                                                    'profile_revision': REVISION, 'scanner_revision': 'eaf3a-2'})
        result.append(record)
    return result
