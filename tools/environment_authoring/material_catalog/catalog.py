"""EAF3B selective material staging and curated catalog operations.

Only EAF3A's Repository may open source files. Paths in published records are
repository-relative facts or project-local cache locations, never source roots.
"""
from __future__ import annotations

from copy import deepcopy
from datetime import date
import hashlib
import json
from pathlib import Path, PureWindowsPath
import re

from tools.environment_authoring.material_repository.path_guard import BoundaryError
from tools.environment_authoring.material_repository.source_index import fingerprint, validate_index


SCHEMA_VERSION = 1
CHANNELS = ('basecolor', 'normal', 'roughness', 'metallic', 'ao')
REFERENCE_CHANNELS = ('height',)
MAPPINGS = {'UV': 0, 'TRIPLANAR': 1, 'WORLD_TRIPLANAR': 2}
FAMILIES = {'structural_concrete', 'rough_poured_concrete', 'service_floor_concrete',
            'cement_render', 'masonry_block', 'brick', 'applied_paint',
            'localized_tile', 'service_metal', 'wood_repair', 'other'}
LAYERS = {'structural_substrate', 'applied_finish', 'service_infrastructure', 'survivor_adaptation'}
ROLES = {'wall', 'floor', 'ceiling', 'beam_column', 'opening_reveal',
         'applied_finish', 'service_equipment'}
HUMAN_FIELDS = ('display_name', 'surface_family', 'vdd_layer', 'approved_roles',
                'mapping_mode', 'meters_per_repeat', 'normal_y_flip', 'normal_strength',
                'roughness_multiplier', 'metallic_multiplier', 'albedo_multiplier',
                'review_notes', 'preferred_runtime_resolution')
PARAMETERS = ('mapping_mode', 'meters_per_repeat', 'normal_y_flip', 'normal_strength',
              'roughness_multiplier', 'metallic_multiplier', 'albedo_multiplier')
CACHE_RESOURCE_ROOT = 'res://assets/environment/materials/kitbash_cache'
DEFAULT_PARAMETERS = {'mapping_mode': 'TRIPLANAR', 'meters_per_repeat': 1.0,
                      'normal_y_flip': False, 'normal_strength': 1.0,
                      'roughness_multiplier': 1.0, 'metallic_multiplier': 1.0,
                      'albedo_multiplier': 1.0}


def _relative_source(value: str) -> str:
    if not isinstance(value, str) or not value or Path(value).is_absolute() or PureWindowsPath(value).drive:
        raise BoundaryError('Source map path must be repository-relative')
    if '\\' in value or any(part in ('', '.', '..') for part in value.split('/')):
        raise BoundaryError('Invalid repository-relative source map path')
    return value


def _reject_paths(value):
    if isinstance(value, str):
        if Path(value).is_absolute() or PureWindowsPath(value).drive or value.startswith('res://'):
            raise ValueError('Absolute or resource paths are not allowed in batch/decision/catalog data')
    elif isinstance(value, dict):
        if any('path' in key.lower() or 'root' in key.lower() for key in value):
            raise ValueError('Batch/decision/catalog may not declare source paths or roots')
        for item in value.values():
            _reject_paths(item)
    elif isinstance(value, list):
        for item in value:
            _reject_paths(item)


def candidate_by_id(index, stable_id):
    validate_index(index)
    matches = [c for c in index['material_candidates'] if c['stable_id'] == stable_id]
    if len(matches) != 1:
        raise ValueError(f'Unknown or duplicate stable material ID: {stable_id}')
    return matches[0]


def choose_resolution(candidate, requested='2K'):
    if requested not in ('1K', '2K', '4K'):
        raise ValueError('Review resolution must be 1K, 2K or 4K')
    available = set(candidate['available_resolutions'])
    if requested in available:
        return requested, None
    if requested == '2K':
        if '4K' in available:
            return '4K', '2K unavailable'
        if '1K' in available:
            return '1K', '2K and 4K unavailable'
    raise ValueError(f'No indexed fallback for {candidate["stable_id"]} at {requested}')


def _source_maps(candidate, resolution, include_height=False):
    maps = candidate.get('maps_by_resolution', {}).get(resolution, {})
    states = candidate.get('channel_states_by_resolution', {}).get(resolution, {})
    selected = {}
    for channel in CHANNELS + (REFERENCE_CHANNELS if include_height else ()):
        entries = maps.get(channel, [])
        if entries and len(entries) == 1 and states.get(channel) in ('SUPPORTED', 'OPTIONAL'):
            selected[channel] = _relative_source(entries[0]['relative_path'])
    if 'basecolor' not in selected:
        raise ValueError(f'No unambiguous indexed basecolor: {candidate["stable_id"]} {resolution}')
    return selected


def fingerprint_candidate(repository, candidate, resolution, include_height=False):
    selected = _source_maps(candidate, resolution, include_height)
    result = {}
    for channel, relative in selected.items():
        digest = hashlib.sha256()
        with repository.open(relative) as source:
            while chunk := source.read(1024 * 1024):
                digest.update(chunk)
        result[channel] = {'source_relative': relative, 'sha256': digest.hexdigest(),
                           'channel_state': candidate['channel_states_by_resolution'][resolution][channel]}
    anchor = {'stable_id': candidate['stable_id'], 'resolution': resolution,
              'maps': result, 'interpretation': {'profile': 'KITBASH_PROFILE_V1',
                                                   'profile_revision': 1}}
    return {'source_fingerprint': fingerprint(anchor), 'maps': result}


def catalog_id(stable_id):
    return 'eaf3b_' + hashlib.sha256(stable_id.encode('utf-8')).hexdigest()[:24]


def stage_candidate(repository, candidate, requested, cache_root, include_height=False):
    actual, fallback = choose_resolution(candidate, requested)
    facts = fingerprint_candidate(repository, candidate, actual, include_height)
    cache_root = Path(cache_root)
    destination_group = f'{catalog_id(candidate["stable_id"])}/{actual.lower()}'
    staged = {}
    for channel, record in facts['maps'].items():
        if channel == 'height' and not include_height:
            continue
        suffix = Path(record['source_relative']).suffix.lower()
        if suffix not in ('.png', '.jpg', '.jpeg', '.webp', '.exr'):
            raise ValueError(f'Unsupported staged image format: {suffix}')
        cache_relative = f'{destination_group}/{channel}{suffix}'
        target = cache_root / cache_relative
        target.parent.mkdir(parents=True, exist_ok=True)
        # A changed source always repairs the same deterministic cache location.
        existing_hash = hashlib.sha256(target.read_bytes()).hexdigest() if target.exists() else None
        if existing_hash != record['sha256']:
            temporary = target.with_suffix(target.suffix + '.tmp')
            with repository.open(record['source_relative']) as source, temporary.open('wb') as sink:
                while chunk := source.read(1024 * 1024):
                    sink.write(chunk)
            if hashlib.sha256(temporary.read_bytes()).hexdigest() != record['sha256']:
                temporary.unlink()
                raise ValueError('Source changed during staging')
            temporary.replace(target)
        staged[channel] = {**record, 'cache_relative': cache_relative}
    return {'source_stable_id': candidate['stable_id'], 'catalog_material_id': catalog_id(candidate['stable_id']),
            'requested_review_resolution': requested, 'actual_review_resolution': actual,
            'fallback_reason': fallback, 'available_resolutions': candidate['available_resolutions'],
            'source_fingerprint': facts['source_fingerprint'], 'maps': staged,
            'source_channel_summary': {r: candidate['channel_states_by_resolution'].get(r, {})
                                       for r in candidate['available_resolutions']},
            'unsupported_source_channels': sorted(set(candidate['maps_by_resolution'].get(actual, {})) -
                                                  set(CHANNELS + REFERENCE_CHANNELS))}


def index_fingerprint(index):
    return fingerprint({'schema_version': index['schema_version'], 'scanner_revision': index['scanner_revision'],
                        'profile_id': index['profile_id'], 'profile_revision': index['profile_revision'],
                        'candidates': [(c['stable_id'], c.get('quick_fingerprint'))
                                       for c in index['material_candidates']]})


def make_batch(batch_id, index, candidate_ids, notes='', overrides=None):
    validate_index(index)
    if not re.fullmatch(r'[a-z][a-z0-9_]{2,63}', batch_id):
        raise ValueError('Batch ID must be a safe lowercase identifier')
    if len(candidate_ids) != len(set(candidate_ids)) or not candidate_ids:
        raise ValueError('Batch requires unique candidate IDs')
    if len({catalog_id(stable_id) for stable_id in candidate_ids}) != len(candidate_ids):
        raise ValueError('Candidate cache/catalog identity collision')
    for stable_id in candidate_ids:
        candidate_by_id(index, stable_id)
    batch = {'schema_version': SCHEMA_VERSION, 'batch_id': batch_id,
             'source_index_schema': index['schema_version'],
             'source_index_revision': index['scanner_revision'],
             'source_index_scan_id': index['scan_finished_at'],
             'source_index_fingerprint': index_fingerprint(index),
             'candidate_ids': candidate_ids, 'review_resolution_policy': '2K_THEN_4K_THEN_1K',
             'candidate_overrides': overrides or {}, 'notes': notes}
    _reject_paths(batch)
    return batch


def validate_parameters(values):
    if set(values) - set(PARAMETERS):
        raise ValueError('Unsupported review parameter override')
    if 'mapping_mode' in values and values['mapping_mode'] not in MAPPINGS:
        raise ValueError('Unknown mapping mode')
    if 'normal_y_flip' in values and not isinstance(values['normal_y_flip'], bool):
        raise ValueError('normal_y_flip must be boolean')
    for key in set(values) & (set(PARAMETERS) - {'mapping_mode', 'normal_y_flip'}):
        number = values[key]
        if not isinstance(number, (float, int)) or not (0.01 <= number <= 100.0 if key == 'meters_per_repeat' else 0.0 <= number <= (4.0 if key == 'normal_strength' else 2.0)):
            raise ValueError(f'Invalid {key}')
    return {**DEFAULT_PARAMETERS, **values}


def validate_batch(batch, index):
    _reject_paths(batch)
    if batch.get('schema_version') != SCHEMA_VERSION or batch.get('source_index_schema') != index['schema_version'] or batch.get('source_index_revision') != index['scanner_revision']:
        raise ValueError('Incompatible batch/index schema')
    if batch.get('source_index_fingerprint') != index_fingerprint(index):
        raise ValueError('Source index changed; refresh batch after EAF3A scan')
    if batch.get('review_resolution_policy') != '2K_THEN_4K_THEN_1K':
        raise ValueError('Unsupported resolution policy')
    ids = batch.get('candidate_ids', [])
    if not ids or len(ids) != len(set(ids)):
        raise ValueError('Batch candidate IDs must be unique')
    if len({catalog_id(stable_id) for stable_id in ids}) != len(ids):
        raise ValueError('Candidate cache/catalog identity collision')
    overrides = batch.get('candidate_overrides', {})
    if set(overrides) - set(ids):
        raise ValueError('Override references candidate outside batch')
    for value in overrides.values():
        if set(value) - (set(PARAMETERS) | {'review_resolution'}):
            raise ValueError('Unsupported batch override')
        if 'review_resolution' in value and value['review_resolution'] not in ('1K', '2K', '4K'):
            raise ValueError('Unsupported review resolution')
        validate_parameters({key: value[key] for key in value if key in PARAMETERS})
    return [candidate_by_id(index, stable_id) for stable_id in ids]


def _gd_string(value):
    return json.dumps(str(value), ensure_ascii=False)


def spec_text(staged, candidate, overrides=None, human=None):
    params = validate_parameters(overrides or {})
    if human:
        params = validate_parameters({key: human[key] for key in PARAMETERS})
    maps = staged['maps']
    lines = ['[gd_resource type="Resource" script_class="EnvironmentSurfaceMaterialSpec" load_steps=%d format=3]' % (2 + len(maps)),
             '', '[ext_resource type="Script" path="res://environment_authoring/environment_surface_material_spec.gd" id="1"]']
    for number, (channel, record) in enumerate(maps.items(), 2):
        lines.append('[ext_resource type="Texture2D" path="%s/%s" id="%d"]' %
                     (CACHE_RESOURCE_ROOT, record['cache_relative'], number))
    lines.extend(['', '[resource]', 'script = ExtResource("1")',
                  'material_id = ' + _gd_string(staged['catalog_material_id']),
                  'display_name = ' + _gd_string((human or {}).get('display_name', candidate['display_name']))])
    names = {'basecolor': 'base_color_texture', 'normal': 'normal_texture',
             'roughness': 'roughness_texture', 'metallic': 'metallic_texture',
             'ao': 'ao_texture', 'height': 'height_texture'}
    for number, channel in enumerate(maps, 2):
        lines.append('%s = ExtResource("%d")' % (names[channel], number))
    lines += ['mapping_mode = %d' % MAPPINGS[params['mapping_mode']],
              'meters_per_repeat = %s' % params['meters_per_repeat']]
    for key in ('normal_strength', 'roughness_multiplier', 'metallic_multiplier', 'albedo_multiplier'):
        lines.append('%s = %s' % (key, params[key]))
    lines += ['normal_y_flip = ' + ('true' if params['normal_y_flip'] else 'false'),
              'surface_family = ' + _gd_string((human or {}).get('surface_family', candidate.get('suggested_family', ''))),
              'vdd_layer = ' + _gd_string((human or {}).get('vdd_layer', '')),
              'source_label = ' + _gd_string('%s @ %s / %s' % (candidate['package_id'], candidate['package_version'], staged['actual_review_resolution'])),
              'source_path = ' + _gd_string(candidate['relative_material_group']),
              'review_notes = ' + _gd_string((human or {}).get('review_notes', 'Initial review hint; normal Y and physical scale require human confirmation.'))]
    return '\n'.join(lines) + '\n'


def review_set_text(spec_paths):
    lines = ['[gd_resource type="Resource" script_class="EnvironmentMaterialReviewSet" load_steps=%d format=3]' % (2 + len(spec_paths)), '',
             '[ext_resource type="Script" path="res://environment_authoring/environment_material_review_set.gd" id="1"]']
    for number, path in enumerate(spec_paths, 2):
        lines.append('[ext_resource type="Resource" path="%s" id="%d"]' % (path, number))
    lines.extend(['', '[resource]', 'script = ExtResource("1")',
                  'specs = Array[Resource]([%s])' % ', '.join('ExtResource("%d")' % n for n in range(2, 2 + len(spec_paths)))])
    return '\n'.join(lines) + '\n'


def _validate_decision(decision):
    _reject_paths(decision)
    if decision.get('decision') not in ('APPROVED', 'REJECTED', 'DEFERRED'):
        raise ValueError('Only human APPROVED, REJECTED or DEFERRED decisions reconcile')
    if not isinstance(decision.get('approval_revision'), int) or decision['approval_revision'] < 1:
        raise ValueError('Positive human approval revision required')
    date.fromisoformat(decision['approval_date'])
    if decision.get('mapping_mode') not in MAPPINGS or decision.get('surface_family') not in FAMILIES or decision.get('vdd_layer') not in LAYERS:
        raise ValueError('Invalid controlled vocabulary')
    roles = decision.get('approved_roles')
    if not isinstance(roles, list) or set(roles) - ROLES:
        raise ValueError('Invalid approved roles')
    validate_parameters({key: decision[key] for key in PARAMETERS})
    if not re.fullmatch('[0-9a-f]{64}', decision.get('reviewed_source_fingerprint', '')):
        raise ValueError('Reviewed strong fingerprint required')
    for key in ('display_name', 'review_notes'):
        if not isinstance(decision.get(key), str):
            raise ValueError(f'{key} required')


def _current_facts(repository, candidate, resolution):
    try:
        return fingerprint_candidate(repository, candidate, resolution), 'CURRENT'
    except (OSError, BoundaryError):
        return None, 'SOURCE_MISSING'
    except ValueError:
        return None, 'UNSUPPORTED'


def reconcile(existing, decisions, index, repository):
    validate_index(index)
    by_id = {}
    for record in existing:
        _reject_paths(record)
        identity = record['catalog_material_id']
        if identity in by_id:
            raise ValueError(f'Duplicate catalog ID: {identity}')
        by_id[identity] = deepcopy(record)
    seen_decisions = set()
    diff = {name: [] for name in ('new_approved', 'new_rejected', 'new_deferred',
                                   'status_changed', 'parameter_changed', 'became_stale',
                                   'source_missing', 'source_availability_changed', 'unchanged')}
    for decision in decisions:
        _validate_decision(decision)
        stable_id = decision['source_stable_id']
        if stable_id in seen_decisions:
            raise ValueError(f'Duplicate decision stable ID: {stable_id}')
        seen_decisions.add(stable_id)
        candidate = candidate_by_id(index, stable_id)
        identity = catalog_id(stable_id)
        previous = by_id.get(identity)
        if previous and previous['source_stable_id'] != stable_id:
            raise ValueError('Catalog ID collision')
        if previous and decision['approval_revision'] < previous['approval_revision']:
            raise ValueError('Older decision revision cannot replace human curation')
        if previous and decision['approval_revision'] == previous['approval_revision']:
            expected = {key: previous.get(key) for key in HUMAN_FIELDS}
            incoming = {key: decision.get(key) for key in HUMAN_FIELDS}
            if (expected != incoming or previous['status'] != decision['decision'] or
                    previous['reviewed_source_fingerprint'] != decision['reviewed_source_fingerprint']):
                raise ValueError('Conflicting decision at same human revision')
        elif previous and decision['approval_revision'] > previous['approval_revision']:
            if previous['status'] != decision['decision']:
                diff['status_changed'].append(identity)
            if any(previous.get(key) != decision.get(key) for key in HUMAN_FIELDS):
                diff['parameter_changed'].append(identity)
        else:
            diff['new_' + decision['decision'].lower()].append(identity)
        record = deepcopy(previous) if previous else {}
        record.update({'catalog_material_id': identity, 'source_stable_id': stable_id,
                       'package_id': candidate['package_id'], 'package_version': candidate['package_version'],
                       'relative_material_group': candidate['relative_material_group'],
                       'reviewed_source_fingerprint': decision['reviewed_source_fingerprint'],
                       'review_resolution': decision['review_resolution'],
                       'available_resolutions': candidate['available_resolutions'],
                       'status': decision['decision'], 'approval_revision': decision['approval_revision'],
                       'approval_date': decision['approval_date']})
        for key in HUMAN_FIELDS:
            record[key] = deepcopy(decision.get(key))
        by_id[identity] = record
    current_candidates = {c['stable_id']: c for c in index['material_candidates']}
    for identity, record in by_id.items():
        previous_effective = record.get('effective_status')
        candidate = current_candidates.get(record['source_stable_id'])
        if candidate:
            current_resolutions = list(candidate['available_resolutions'])
            if record.get('available_resolutions') != current_resolutions:
                diff['source_availability_changed'].append(identity)
            record['available_resolutions'] = current_resolutions
        facts, state = _current_facts(repository, candidate, record['review_resolution']) if candidate else (None, 'SOURCE_MISSING')
        record['current_source_fingerprint'] = facts['source_fingerprint'] if facts else None
        record['current_source_matches_review'] = bool(facts and facts['source_fingerprint'] == record['reviewed_source_fingerprint'])
        record['effective_status'] = (state if state != 'CURRENT' else
                                      'STALE' if not record['current_source_matches_review'] else record['status'])
        if record['effective_status'] == 'STALE' and previous_effective != 'STALE':
            diff['became_stale'].append(identity)
        if record['effective_status'] == 'SOURCE_MISSING' and previous_effective != 'SOURCE_MISSING':
            diff['source_missing'].append(identity)
        if not any(identity in items for name, items in diff.items() if name != 'unchanged'):
            diff['unchanged'].append(identity)
    return [by_id[key] for key in sorted(by_id)], {name: sorted(items) for name, items in diff.items()}


def query(records, family=None, layer=None, role=None, include_noncurrent=False):
    return [record for record in records
            if (include_noncurrent or record.get('effective_status') == 'APPROVED')
            and (family is None or record.get('surface_family') == family)
            and (layer is None or record.get('vdd_layer') == layer)
            and (role is None or role in record.get('approved_roles', []))]


def restage_approved(records, index, repository, cache_root, spec_root=None):
    completed, refused = [], []
    for record in records:
        if record.get('status') != 'APPROVED':
            continue
        identity = record['catalog_material_id']
        if record.get('effective_status') != 'APPROVED' or not record.get('current_source_matches_review'):
            refused.append({'catalog_material_id': identity, 'effective_status': record.get('effective_status')})
            continue
        candidate = candidate_by_id(index, record['source_stable_id'])
        facts, state = _current_facts(repository, candidate, record['review_resolution'])
        if state != 'CURRENT' or facts['source_fingerprint'] != record['reviewed_source_fingerprint']:
            refused.append({'catalog_material_id': identity, 'effective_status': 'STALE' if facts else state})
            continue
        resolution = record.get('preferred_runtime_resolution') or record['review_resolution']
        if resolution != record['review_resolution']:
            # A different resolution requires separate human review/fingerprint.
            refused.append({'catalog_material_id': identity, 'effective_status': 'UNSUPPORTED'})
            continue
        staged = stage_candidate(repository, candidate, resolution, cache_root)
        if staged['source_fingerprint'] != record['reviewed_source_fingerprint']:
            refused.append({'catalog_material_id': identity, 'effective_status': 'STALE'})
            continue
        if spec_root is not None:
            target = Path(spec_root) / f'{identity}.tres'
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(spec_text(staged, candidate, human=record), encoding='utf-8')
        completed.append(identity)
    return completed, refused
