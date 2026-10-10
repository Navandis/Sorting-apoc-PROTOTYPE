"""One-shot EAF4 preset audit/build. The existing catalog is the only authority."""
from __future__ import annotations
import argparse
import json
from pathlib import Path
import re

PRESETS = Path('environment_authoring/wear/presets')
CATALOG = Path('data/environment/wear_catalog/catalog.json')
AUTHOR = 'res://environment_authoring/wear/environment_wear_authoring.gd'
PATCH = 'res://environment_authoring/wear/environment_material_patch.gd'


def audit(root: Path) -> list[dict]:
    records = json.loads((root / CATALOG).read_text(encoding='utf-8'))['wear']
    results = []
    seen = set()
    for entry in records:
        surfaces = entry['surface_capabilities']
        eligible = (entry['effective_status'] == 'APPROVED'
                    and entry['semantic_category'] != 'IMPERFECTION_MASK'
                    and bool(set(surfaces) & {'FLOOR', 'WALL', 'PLANAR_ANY'}))
        source = entry['source_stable_id'].split(':')
        slug = source[2]
        if not re.fullmatch(r'[a-z0-9_]+', slug):
            raise ValueError(f'Invalid source filename: {slug}')
        item = dict(record=entry, eligible=eligible, slug=slug,
                    name=slug.replace('_', ' ').title(), blocked='')
        if not eligible:
            item['blocked'] = ('Scalar source; use the separate scalar library, not a conventional wear preset'
                               if entry['semantic_category'] == 'IMPERFECTION_MASK' and 'TINTED_OPACITY_LAYER' in entry.get('supported_uses', [])
                               else 'Modulation-only, not a standalone placement'
                               if entry['semantic_category'] == 'IMPERFECTION_MASK'
                               else entry['effective_status'])
        else:
            spec = root / 'data/environment/wear_catalog/approved_specs' / (entry['catalog_wear_id'] + '.tres')
            try:
                text = spec.read_text(encoding='utf-8')
                def field(key):
                    match = re.search(r'^' + re.escape(key) + r' = "([^"]*)"$', text, re.M)
                    if match is None:
                        raise ValueError(f'Missing {key} in {spec}')
                    return match.group(1)
                item['name'] = field('display_name')
                if (field('overlay_id') != entry['catalog_wear_id']
                    or field('source_stable_id') != entry['source_stable_id']
                    or field('source_fingerprint') != entry['reviewed_source_fingerprint']
                    or entry['current_source_fingerprint'] != entry['reviewed_source_fingerprint']):
                    raise ValueError('stale approval or mismatched source identity/fingerprint')
                for dependency in re.findall(r'path="res://([^"]+)"', text):
                    if not (root / dependency).is_file():
                        raise ValueError(f'missing dependency: {dependency}')
                if entry['patch_mode'] not in ('', 'EAF4_SOURCE'):
                    raise ValueError(f'unsupported patch mode: {entry["patch_mode"]}')
                if slug in seen:
                    raise ValueError(f'duplicate preset filename: {slug}')
                seen.add(slug)
                item['path'] = str(PRESETS / (slug + '.tscn')).replace('\\', '/')
            except (OSError, ValueError) as error:
                item['blocked'] = str(error)
        results.append(item)
    return sorted(results, key=lambda item: item['slug'])


def wrapper(item: dict) -> str:
    entry = item['record']
    floor = ('FLOOR' in entry['surface_capabilities']
             and not set(entry['surface_capabilities']) & {'WALL', 'PLANAR_ANY'})
    node_name = ''.join(word.capitalize() for word in item['slug'].split('_'))
    lines = ['[gd_scene load_steps=%d format=3]' % (3 if entry['patch_mode'] else 2), '']
    script = PATCH if entry['patch_mode'] else AUTHOR
    lines.append(f'[ext_resource type="Script" path="{script}" id="1"]')
    if entry['patch_mode']:
        lines.append('[ext_resource type="Resource" path="res://data/environment/wear_catalog/approved_specs/%s.tres" id="2"]' % entry['catalog_wear_id'])
    lines += ['', f'[node name="{node_name}" type="Node3D"]']
    if floor:
        lines.append('rotation = Vector3(-1.5707963267948966, 0, 0)')
    lines.append('script = ExtResource("1")')
    if entry['patch_mode']:
        lines += ['mode = 1', 'wear_spec = ExtResource("2")']
    else:
        lines.append('approved_source = ' + json.dumps(item['name'] + ' | ' + entry['catalog_wear_id']))
    return '\n'.join(lines) + '\n'


def coverage(items: list[dict]) -> str:
    eligible = [item for item in items if item['eligible']]
    covered = [item for item in eligible if not item['blocked']]
    lines = ['# Approved EAF4 preset coverage', '',
             f'{len(eligible)} eligible sources; {len(covered)} wrappers; {len(eligible)-len(covered)} blocked. Derived from the current EAF4 catalog; this is an index, not another approval authority.', '',
             'Run `python tools/environment_authoring/wear_catalog/build_presets.py --check` to audit mappings/dependencies and detect drift; omit `--check` for an explicit one-shot rebuild. Never runs in the editor.', '',
             'Drag a `.tscn` into `WingGameplay/AuthoredWear/Receiving`, `Storage` or `OtherRooms`. Select the instance root. See [the practical guide](../../../docs/environment-authoring/eaf4-wear-authoring-guide.md). Floor-only wrappers face up (X = -90 degrees); wall and PLANAR_ANY wrappers start upright (+Z normal). Rotate PLANAR_ANY or dual-capability sources to the intended surface.', '',
             '| Name / stable ID | Capabilities | Preset | Blocking reason |', '| --- | --- | --- | --- |']
    for item in items:
        entry = item['record']
        path = f'[{item["slug"]}.tscn]({item["slug"]}.tscn)' if item.get('path') else '—'
        lines.append('| %s / `%s` | %s | %s | %s |' % (item['name'], entry['catalog_wear_id'], ', '.join(entry['surface_capabilities']), path, item['blocked'] or 'None'))
    lines += ['', '## Approved usage restrictions', '', 'Approval establishes source quality, not universal placement. The Inspector also shows these catalog restrictions.']
    for item in covered:
        lines += ['', f'**{item["name"]} ({item["slug"]})**: {item["record"]["review_notes"]}']
    patch_count = sum(bool(item['record']['patch_mode']) for item in eligible)
    lines += ['', f'{patch_count} current eligible material-patch sources. Material patches use the supported EnvironmentMaterialPatch EAF4_SOURCE path; never substituted as overlays. Any future patch approval also needs instance-control and wing-guard review. Unknown modes or missing/stale resources block generation explicitly. The current deferred and scalar-mask entries above remain excluded from conventional wear presets. Approved scalar sources use the [separate scalar library](../imperfection_experiments/README.md); placement acceptance remains separate.', '']
    return '\n'.join(lines)


def build(root: Path, check: bool = False) -> None:
    items = audit(root)
    blocked = [item for item in items if item['eligible'] and item['blocked']]
    if blocked:
        raise ValueError('\n'.join(f'{item["record"]["catalog_wear_id"]}: {item["blocked"]}' for item in blocked))
    expected = {root / item['path']: wrapper(item) for item in items if item['eligible']}
    expected[root / PRESETS / 'README.md'] = coverage(items)
    actual = set((root / PRESETS).glob('*.tscn'))
    stale = actual - {path for path in expected if path.suffix == '.tscn'}
    if stale:
        raise ValueError('Obsolete wrappers (remove explicitly after review): ' + ', '.join(str(path) for path in sorted(stale)))
    for path, text in expected.items():
        if check:
            if not path.exists() or path.read_text(encoding='utf-8') != text:
                raise ValueError(f'Missing or outdated preset/index: {path}')
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding='utf-8', newline='\n')
    print(f'EAF4 preset audit: {len(expected)-1} eligible, {len(expected)-1} covered, 0 blocked')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    build(Path(__file__).resolve().parents[3], args.check)
