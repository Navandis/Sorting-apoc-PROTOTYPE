"""EAF3B review package generation and Godot import normalization."""
import json
from pathlib import Path
import re
import shutil
from zipfile import ZipFile, ZipInfo, ZIP_STORED

from . import catalog


def write_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def prepare(batch, index, repository, cache_root, spec_dir, review_dir, iteration=None):
    candidates = catalog.validate_batch(batch, index)
    spec_dir, review_dir = Path(spec_dir), Path(review_dir)
    spec_dir.mkdir(parents=True, exist_ok=True)
    review_dir.mkdir(parents=True, exist_ok=True)
    overrides = dict(batch.get('candidate_overrides', {}))
    if iteration:
        catalog._reject_paths(iteration)
        if iteration.get('schema_version') != 1 or iteration.get('batch_id') != batch['batch_id']:
            raise ValueError('Iteration belongs to another batch/schema')
        if set(iteration.get('candidate_overrides', {})) - set(batch['candidate_ids']):
            raise ValueError('Iteration references candidate outside batch')
        for stable_id, values in iteration.get('candidate_overrides', {}).items():
            catalog.validate_parameters(values)
            overrides[stable_id] = {**overrides.get(stable_id, {}), **values}
    records, spec_paths, decisions = [], [], []
    for candidate in candidates:
        stable_id = candidate['stable_id']
        value = overrides.get(stable_id, {})
        requested = value.get('review_resolution', '2K')
        staged = catalog.stage_candidate(repository, candidate, requested, cache_root)
        parameters = catalog.validate_parameters({key: item for key, item in value.items() if key in catalog.PARAMETERS})
        # An initial hint is not a physical-scale or normal-Y verdict.
        spec_file = f'{staged["catalog_material_id"]}.tres'
        (spec_dir / spec_file).write_text(catalog.spec_text(staged, candidate, parameters), encoding='utf-8')
        spec_paths.append(f'res://data/environment/material_catalog/review_batches/{batch["batch_id"]}/{spec_file}')
        record = {**staged, 'display_name': candidate['display_name'],
                  'package_id': candidate['package_id'], 'package_version': candidate['package_version'],
                  'relative_material_group': candidate['relative_material_group'],
                  'suggested_family': candidate['suggested_family'],
                  'mapping_mode': parameters['mapping_mode'],
                  'meters_per_repeat': parameters['meters_per_repeat'],
                  'normal_y_flip': parameters['normal_y_flip'],
                  'normal_strength': parameters['normal_strength'],
                  'roughness_multiplier': parameters['roughness_multiplier'],
                  'metallic_multiplier': parameters['metallic_multiplier'],
                  'albedo_multiplier': parameters['albedo_multiplier'],
                  'warnings': candidate['warnings'],
                  'selection_rationale': batch.get('selection_rationale', {}).get(stable_id, '')}
        records.append(record)
        decisions.append({
            'source_stable_id': stable_id, 'decision': 'PENDING',
            'review_resolution': staged['actual_review_resolution'],
            'reviewed_source_fingerprint': staged['source_fingerprint'],
            'approval_revision': None, 'approval_date': None,
            'display_name': candidate['display_name'], 'surface_family': None, 'vdd_layer': None,
            'approved_roles': [], **parameters, 'review_notes': '',
            'preferred_runtime_resolution': None,
        })
    (spec_dir / 'review_set.tres').write_text(catalog.review_set_text(spec_paths), encoding='utf-8')
    result = {'schema_version': 1, 'batch_id': batch['batch_id'],
              'source_index_schema': batch['source_index_schema'],
              'source_index_revision': batch['source_index_revision'],
              'source_index_scan_id': batch['source_index_scan_id'],
              'source_index_fingerprint': batch['source_index_fingerprint'],
              'candidates': records}
    write_json(review_dir / 'stage_manifest.json', result)
    write_json(review_dir / 'decision_template.json', {'schema_version': 1, 'batch_id': batch['batch_id'], 'decisions': decisions})
    (review_dir / 'batch_summary.md').write_text(summary_text(batch, records), encoding='utf-8')
    return result


def summary_text(batch, records):
    lines = [f'# EAF3B review batch: {batch["batch_id"]}', '',
             'Status: human material decisions pending. Machine family, mapping and scale values are initial review hints.',
             '', f'Source index scan: `{batch["source_index_scan_id"]}`; schema `{batch["source_index_schema"]}` / `{batch["source_index_revision"]}`.',
             '', batch.get('notes', ''), '']
    for index, item in enumerate(records, 1):
        lines += [f'## {index}. {item["display_name"]}', '',
                  f'- Stable ID: `{item["source_stable_id"]}`',
                  f'- Package: `{item["package_id"]}` version `{item["package_version"]}`',
                  f'- Review resolution: requested `{item["requested_review_resolution"]}`, actual `{item["actual_review_resolution"]}`; available `{", ".join(item["available_resolutions"])}`',
                  f'- Fallback: {item["fallback_reason"] or "none"}',
                  f'- Source channels: `{", ".join(item["maps"])}`; unsupported facts: `{", ".join(item["unsupported_source_channels"]) or "none"}`',
                  f'- Suggested family: `{item["suggested_family"]}`',
                  f'- Mapping / scale hint: `{item["mapping_mode"]}` / `{item["meters_per_repeat"]}` m per repeat',
                  f'- Normal Y: {"SOURCE (visual confirmation pending)" if not item["normal_y_flip"] else "FLIPPED (review override)"}',
                  f'- Warnings: `{", ".join(item["warnings"]) or "none"}`',
                  f'- Selection rationale: {item["selection_rationale"] or "source triage diversity"}',
                  f'- Strong fingerprint: `{item["source_fingerprint"]}`', '']
    lines += ['Four captures per candidate: `neutral__hero`, `neutral__grazing`, `receiving__hero`, `receiving__grazing`.',
              'Set a human decision and revision in a copy of `decision_template.json` after inspecting the captures.']
    return '\n'.join(lines) + '\n'


def normalize_imports(staged_records, cache_root):
    changed = 0
    for staged in staged_records:
        for channel, record in staged['maps'].items():
            texture = Path(cache_root) / record['cache_relative']
            settings = texture.with_suffix(texture.suffix + '.import')
            if not settings.exists():
                raise FileNotFoundError(f'Godot import record missing for staged map: {settings}')
            text = settings.read_text(encoding='utf-8-sig')
            updates = {'compress/mode': '0', 'compress/normal_map': '1' if channel == 'normal' else '0',
                       'mipmaps/generate': 'true', 'process/normal_map_invert_y': 'false',
                       'detect_3d/compress_to': '0'}
            original = text
            for key, value in updates.items():
                pattern = re.compile(r'^' + re.escape(key) + r'=.*$', re.MULTILINE)
                if pattern.search(text):
                    text = pattern.sub(key + '=' + value, text)
                else:
                    text = text.rstrip() + '\n' + key + '=' + value + '\n'
            if text != original:
                settings.write_text(text, encoding='utf-8')
                changed += 1
    return changed


def finalize_capture(review_dir):
    review_dir = Path(review_dir)
    staged = json.loads((review_dir / 'stage_manifest.json').read_text(encoding='utf-8'))
    manifest_path = review_dir / 'manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    expected = [item['catalog_material_id'] for item in staged['candidates']]
    actual = [item['material_id'] for item in manifest['records'][::4]]
    if actual != expected or len(manifest['records']) != len(expected) * 4:
        raise ValueError('Capture matrix does not match batch order/count')
    manifest['source_index_scan_id'] = staged['source_index_scan_id']
    manifest['source_index_fingerprint'] = staged['source_index_fingerprint']
    manifest['candidates'] = [{key: item[key] for key in ('source_stable_id', 'catalog_material_id',
                                                          'requested_review_resolution', 'actual_review_resolution',
                                                          'fallback_reason', 'available_resolutions', 'source_fingerprint')}
                              for item in staged['candidates']]
    write_json(manifest_path, manifest)
    return manifest


def package_review(review_dir):
    review_dir = Path(review_dir)
    required = [review_dir / name for name in ('manifest.json', 'batch_summary.md', 'decision_template.json')]
    if any(not path.is_file() for path in required):
        raise FileNotFoundError('Review package is missing manifest, summary or decision template')
    files = required + sorted(review_dir.glob('*.png'))
    if not any(path.suffix == '.png' for path in files):
        raise ValueError('Review package has no capture PNGs')
    archive = review_dir.with_name(review_dir.name + '_review.zip')
    with ZipFile(archive, 'w', compression=ZIP_STORED) as bundle:
        for path in files:
            info = ZipInfo(path.name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = ZIP_STORED
            with path.open('rb') as source, bundle.open(info, 'w') as destination:
                shutil.copyfileobj(source, destination)
    return archive
