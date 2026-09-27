"""Bounded Megascans metadata and explicit versioned source declarations."""
import json
import re


def read_metadata(repository, relative, size):
    if size > 2 * 1024 * 1024:
        return {'warnings': ['metadata_too_large'], 'recognized': False}
    try:
        with repository.open(relative) as stream:
            data = json.load(stream)
    except (ValueError, UnicodeError):
        return {'warnings': ['invalid_json_metadata'], 'recognized': False}
    if not isinstance(data, dict):
        return {'warnings': ['unrecognized_metadata'], 'recognized': False}
    sem = data.get('semanticTags', {})
    fab = isinstance(sem, dict) and isinstance(data.get('id'), str) and isinstance(data.get('maps'), list) and sem.get('asset_type') in ('decal', 'imperfection', 'surface', '3d')
    explicit = data.get('eaf4_source_metadata_version') == 1
    if not fab and not explicit:
        return {'warnings': [], 'recognized': False}
    rows = data.get('meta', [])
    shape_warnings = []
    if not isinstance(rows, list):
        shape_warnings.append('unrecognized_meta_shape')
        rows = []
    meta = {r['key']: r.get('value') for r in rows if isinstance(r, dict) and isinstance(r.get('key'), str)}
    tileable = meta.get('tileable', data.get('tileable'))
    result = {'recognized': True, 'provenance': relative, 'warnings': shape_warnings,
              'source_kind': sem.get('asset_type') if fab else data.get('source_kind'),
              'logical_name': data.get('id') if fab else None, 'display_name': data.get('name'),
              'tileable': tileable if type(tileable) is bool else None,
              'localized': data.get('localized'), 'physical_size': None,
              'semantic_evidence': {'categories': data.get('assetCategories', {}),
                                    'contains': sem.get('contains', [])} if fab else {},
              'advertised_map_count': len(data['maps']) if isinstance(data.get('maps'), list) else 0}
    area = meta.get('scanArea')
    if isinstance(area, str):
        match = re.fullmatch(r'\s*(\d+(?:\.\d+)?)\s*[x×]\s*(\d+(?:\.\d+)?)\s*m\s*', area)
        if match and float(match[1]) > 0 and float(match[2]) > 0:
            result['physical_size'] = {'width_m': float(match[1]), 'height_m': float(match[2]),
                                       'confidence': 'EXPLICIT_SOURCE_METADATA', 'provenance': relative + '#meta.scanArea', 'raw': area}
        else:
            result['warnings'].append('unparsed_scan_area')
    if result['tileable'] is False and 'tileable' in json.dumps(data.get('assetCategories', {})).lower():
        result['warnings'].append('tileability_category_conflicts_with_explicit_false')
    return result


def suggestions(name, metadata):
    evidence = json.dumps(metadata.get('semantic_evidence', {})).lower()
    rules = [('crack', ('crack',)), ('spall_damage', ('spall', 'damage', 'chipped')),
             ('water_mineral', ('leak', 'water', 'mineral', 'damp')), ('rust_corrosion', ('rust', 'corrosion')),
             ('oil_grease', ('oil', 'grease')), ('scrape_scuff', ('scrape', 'scuff', 'scratch', 'trace')),
             ('paint_remnant', ('paint_remnant',)), ('paint_damage', ('paint',)),
             ('soot_smoke', ('soot', 'smoke')), ('repair_patch', ('repair', 'patch')),
             ('grime', ('grime', 'dirt', 'stain')), ('imperfection', ('grunge', 'imperfection'))]
    if metadata.get('source_kind') == 'imperfection':
        return 'imperfection', 'metadata'
    for text, provenance in ((evidence, 'metadata'), (name.lower(), 'weak_filename')):
        for family, tokens in rules:
            if any(token in text for token in tokens):
                return family, provenance
    return 'unknown', 'none'
