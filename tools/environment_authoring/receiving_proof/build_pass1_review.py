"""Assemble EAF5 pass-1 review from promoted EAF2/EAF3A/EAF3B data."""

import json
from pathlib import Path
import re
import shutil
from zipfile import ZipFile, ZIP_DEFLATED

from tools.environment_authoring.material_repository.path_guard import PROJECT_ROOT, load_repository
from tools.environment_authoring.material_repository.source_index import INDEX_PATH, REPORT_DIR, load_index
from tools.environment_authoring.material_repository.query_index import (
    query, index_fingerprint, batch_manifest, select_batch,
)
from tools.environment_authoring.material_repository.build_triage_sheets import build_sheets
from tools.environment_authoring.material_catalog import catalog as material_catalog


DATA_DIR = PROJECT_ROOT / 'data/environment/receiving_proof'
PACKAGE_DIR = PROJECT_ROOT / 'reports/environment_receiving_proof/eaf5/source_shortlist_01'
ZIP_PATH = PACKAGE_DIR.parent / 'eaf5_source_shortlist_01_review.zip'
ROLES = ('WALL_CEILING_MINERAL', 'SERVICE_FLOOR', 'APPLIED_FINISH', 'STRUCTURAL_SECONDARY')
FAMILIES = ('concrete', 'cement_render', 'masonry_block', 'brick', 'tile')
APPROVED_IDS = {
    'eaf3b_1435ce254f04bb8e61bd3e96', 'eaf3b_20c61bd1c85420be2f71a090',
    'eaf3b_39b926e570fb3824019aade2', 'eaf3b_bd0940113f04f3d3784629e7',
    'eaf3b_8d5f0cf5add98dfe0a58f18a',
}


def _read(path):
    return json.loads(Path(path).read_text(encoding='utf-8'))


def _write(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def _close(a, b):
    return abs(a - b) < 0.0001


def validate_shell(shell):
    dims = shell['dimensions']
    if not _close(dims['main_apron']['clear_height_m'], 4.2) or not _close(dims['structural_thickness_m'], 0.3):
        raise ValueError('Receiving height or structural thickness differs from saved authority')
    if dims['freight_enclosure']['x_bounds_local_m'][1] != dims['main_apron']['x_bounds_local_m'][0]:
        raise ValueError('freight enclosure must be distinct from apron')
    for area in ('main_apron', 'freight_enclosure', 'dispatch_annex_context'):
        if any(dims[area][field] <= 0 for field in ('width_m', 'depth_m', 'clear_height_m')):
            raise ValueError('nonpositive shell area dimension')
    source = shell['source_elements']
    source_ids = [e['id'] for e in source]
    if len(source_ids) != len(set(source_ids)) or any(any(v <= 0 for v in e['saved_box_dimensions_m']) for e in source):
        raise ValueError('duplicate source ID or nonpositive source box')
    registry = (PROJECT_ROOT / 'environment_authoring/substrate/environment_substrate_recipe_registry.gd').read_text()
    recipe_ids = set(re.findall(r'^\s*"([a-z_]+)": \{', registry, re.M))
    mapped = shell['eaf2_recipe_mapping']
    ownership = [id_ for piece in mapped for id_ in piece['source_components']]
    if sorted(ownership) != sorted(source_ids):
        raise ValueError('every source element needs exactly one mapped structural owner')
    for piece in mapped:
        if piece['recipe_id'] not in recipe_ids or piece['classification'] != 'SUPPORTED_BY_EXISTING_RECIPE':
            raise ValueError('unknown EAF2 recipe or unclassified piece')
        if any(v <= 0 for v in piece['dimensions_m']):
            raise ValueError('nonpositive EAF2 piece')
        opening = piece['opening_parameters']
        if opening and (opening['opening_width_m'] >= piece['dimensions_m'][0]
                        or opening['opening_height_m'] >= piece['dimensions_m'][1]
                        or opening['opening_bottom_m'] + opening['opening_height_m'] >= piece['dimensions_m'][1]):
            raise ValueError('opening height or width outside EAF2 wall')
    for opening in shell['openings']:
        if opening['clear_height_m'] > dims['main_apron']['clear_height_m'] or opening['nominal_width_m'] <= 0:
            raise ValueError('opening height or width outside Receiving envelope')
        bounds = opening['horizontal_bounds_local_m']
        if not _close(bounds[1] - bounds[0], opening['nominal_width_m']):
            raise ValueError('opening width differs from bounds')
        limit = (-3.5, 3.5) if opening['id'] == 'west_freight' else (-5, 5) if opening['id'] == 'east_backlog' else (0, 10.5)
        if not (limit[0] < bounds[0] < bounds[1] < limit[1]):
            raise ValueError('opening outside wall bounds')
    if shell['missing_topology']:
        raise ValueError('missing topology requires a separate EAF2 extension contract')
    return {'source_elements': len(source), 'mapped_pieces': len(mapped),
            'composition_openings': sum(o['classification'] == 'SUPPORTED_BY_COMPOSITION' for o in shell['openings']),
            'missing_topology': len(shell['missing_topology'])}


def validate_shortlist(shortlist, index, catalog_records):
    expected = shortlist.get('source_index_fingerprint')
    if expected and expected != index_fingerprint(index):
        raise ValueError('stale EAF3A source index fingerprint')
    indexed = {c['stable_id']: c for c in index['material_candidates']}
    catalog = {c['source_stable_id']: c for c in catalog_records}
    seen = set()
    for item in shortlist['candidates']:
        identity = item['source_stable_id']
        if identity in seen or identity not in indexed:
            raise ValueError('duplicate or missing stable ID')
        seen.add(identity)
        candidate = indexed[identity]
        if any('atlas_trim_or_object_specific_name' in w for w in candidate['warnings']):
            raise ValueError('structural warning excluded from EAF5 role sheets')
        if candidate['suggested_family'] not in FAMILIES or not set(item['proposed_eaf5_roles']) <= set(ROLES):
            raise ValueError('unsupported family or role')
        record = catalog.get(identity)
        if record and record['status'] in ('REJECTED', 'DEFERRED'):
            raise ValueError(f'{record["status"]} EAF3 decision may not be proposed')
        if record and (record['effective_status'] != 'APPROVED' or item['review_state'] != 'EXISTING_EAF3_APPROVED'
                       or item['existing_catalog_material_id'] != record['catalog_material_id']):
            raise ValueError('EAF3 approval is stale or misidentified')
        if not record and item['review_state'] != 'SOURCE_SHORTLIST_PROPOSED':
            raise ValueError('unreviewed source has wrong state')
    return len(seen)


def validate_approved_seed_set(shortlist):
    included = {item['existing_catalog_material_id'] for item in shortlist['candidates']
                if item['review_state'] == 'EXISTING_EAF3_APPROVED'}
    if included != APPROVED_IDS:
        raise ValueError('five approved EAF3 seeds must all appear in role sheets')


def _shell_summary(shell, counts):
    d = shell['dimensions']
    lines = ['# Receiving saved-shell source', '',
             f'Authority: `{shell["authority"]["composition"][2]}` and `{shell["authority"]["builder"]}`.',
             f'Local origin: world {shell["coordinate_system"]["origin_world_m"]}; +X east, +Z south, Y up.', '',
             f'- Apron: {d["main_apron"]["width_m"]} × {d["main_apron"]["depth_m"]} m, {d["main_apron"]["clear_height_m"]} m clear.',
             f'- Freight: {d["freight_enclosure"]["depth_m"]} × {d["freight_enclosure"]["width_m"]} m, distinct west of apron.',
             f'- Structural thickness: {d["structural_thickness_m"]} m.',
             f'- Saved boxes: {counts["source_elements"]}; planned EAF2 pieces: {counts["mapped_pieces"]}.', '',
             '| Opening | Width | Clear height | Condition |', '| --- | ---: | ---: | --- |']
    for o in shell['openings']:
        lines.append(f'| {o["id"]} | {o["nominal_width_m"]} m | {o["clear_height_m"]} m | {o["classification"]} |')
    lines += ['', 'The full JSON contains every saved floor, ceiling, wall and freight-barrier box and the source file blobs.']
    return '\n'.join(lines) + '\n'


def _mapping_summary(shell):
    lines = ['# EAF2 mapping', '', '| Piece | Saved source | Recipe | Dimensions X/Y/Z m | Rotation Y | Collision |',
             '| --- | --- | --- | --- | ---: | --- |']
    for p in shell['eaf2_recipe_mapping']:
        lines.append(f'| {p["piece_id"]} | {", ".join(p["source_components"])} | {p["recipe_id"]} | {p["dimensions_m"]} | {p["rotation_y_degrees"]}° | {p["collision_policy"]} |')
    lines += ['', 'West freight and Dispatch apertures are full height and use composed wall segments. The east transition is one wall-with-opening piece; its header is 0.8 m. No new topology is needed.']
    return '\n'.join(lines) + '\n'


def build():
    shell = _read(DATA_DIR / 'eaf5_receiving_shell_source.json')
    shortlist = _read(DATA_DIR / 'eaf5_material_source_shortlist_01.json')
    index = load_index(INDEX_PATH)
    catalog_records = _read(PROJECT_ROOT / 'data/environment/material_catalog/catalog.json')['materials']
    counts = validate_shell(shell)
    validate_shortlist(shortlist, index, catalog_records)
    validate_approved_seed_set(shortlist)
    current_approved = {r['catalog_material_id']: r for r in material_catalog.query(catalog_records)
                        if r.get('current_source_matches_review')}
    if set(current_approved) != APPROVED_IDS:
        raise ValueError('five approved EAF3 seed materials are not current')
    repository = load_repository()
    indexed = {c['stable_id']: c for c in index['material_candidates']}
    for record in current_approved.values():
        live = material_catalog.fingerprint_candidate(repository, indexed[record['source_stable_id']],
                                                      record['review_resolution'])['source_fingerprint']
        if live != record['reviewed_source_fingerprint']:
            raise ValueError(f'approved source bytes changed: {record["catalog_material_id"]}')
        spec = PROJECT_ROOT / 'data/environment/material_catalog/approved_specs' / (record['catalog_material_id'] + '.tres')
        if not spec.is_file():
            raise ValueError(f'approved spec missing: {spec}')
    eligible = {c['stable_id']: c for family in FAMILIES for c in query(
        index, family=family, exclude_warnings=['atlas_trim_or_object_specific_name'])}
    if any(item['source_stable_id'] not in eligible for item in shortlist['candidates']):
        raise ValueError('shortlist bypasses promoted EAF3A eligibility query')
    PACKAGE_DIR.mkdir(parents=True, exist_ok=True)
    _write(PACKAGE_DIR / 'candidate_manifest.json', shortlist)
    _write(PACKAGE_DIR / 'shell_source.json', shell)
    (PACKAGE_DIR / 'shell_source_summary.md').write_text(_shell_summary(shell, counts), encoding='utf-8')
    (PACKAGE_DIR / 'eaf2_recipe_mapping.md').write_text(_mapping_summary(shell), encoding='utf-8')
    shutil.copyfile(DATA_DIR / 'eaf5_reuse_matrix.md', PACKAGE_DIR / 'eaf5_reuse_matrix.md')
    decisions = {'schema_version': 1, 'purpose': 'EAF5 source-shortlist human decision; only SHORTLIST unapproved IDs stage next',
                 'source_index_fingerprint': index_fingerprint(index), 'decisions': [
                     {'source_stable_id': c['source_stable_id'], 'roles': c['proposed_eaf5_roles'],
                      'decision': 'HOLD', 'notes': ''} for c in shortlist['candidates']
                     if c['review_state'] == 'SOURCE_SHORTLIST_PROPOSED'],
                 'approved_seed_role_notes': [
                     {'source_stable_id': c['source_stable_id'], 'roles': c['proposed_eaf5_roles'], 'notes': ''}
                     for c in shortlist['candidates'] if c['review_state'] == 'EXISTING_EAF3_APPROVED']}
    _write(PACKAGE_DIR / 'decision_template.json', decisions)
    lines = ['# EAF5 source shortlist 01', '',
             'Review the four role sheets and candidate manifest. Tiles show basecolor source triage only; they do not establish normal quality, roughness, normal-Y, physical scale, or room suitability.',
             'Set each unapproved decision to SHORTLIST, DROP, or HOLD and add notes. The five current EAF3 approvals remain available without another source decision; optional role notes are separate.',
             'The next pass stages only unapproved SHORTLIST stable IDs through EAF3B. This package contains no commercial source maps.', '',
             'Role sheets are under `roles/<ROLE>/`; each has a stable-ID batch, page JSON, and image. Warnings and full identities are in the manifests.', '']
    (PACKAGE_DIR / 'README.md').write_text('\n'.join(lines), encoding='utf-8')
    states = {c['source_stable_id']: c['current_eaf3_catalog_state'] for c in shortlist['candidates']}
    role_counts = {}
    for role in ROLES:
        ids = {c['source_stable_id'] for c in shortlist['candidates'] if role in c['proposed_eaf5_roles']}
        batch = batch_manifest(index, [eligible[i] for i in ids])
        selected = select_batch(index, batch)
        output = PACKAGE_DIR / 'roles' / role
        sheet = build_sheets(repository, index, selected, output, REPORT_DIR / 'thumbnails',
                             sheet_label=role, catalog_states=states)
        sheet_ids = {tile['stable_id'] for page in sheet['pages'] for tile in page['tiles']}
        if sheet_ids != ids:
            raise ValueError(f'contact sheet ID mismatch: {role}')
        role_counts[role] = len(ids)
    files = sorted(p for p in PACKAGE_DIR.rglob('*') if p.is_file())
    with ZipFile(ZIP_PATH, 'w', ZIP_DEFLATED) as archive:
        for path in files:
            rel = path.relative_to(PACKAGE_DIR).as_posix()
            if path.suffix.lower() not in ('.png', '.json', '.md') or 'cache' in rel.lower():
                raise ValueError(f'commercial source map or unsupported package member: {rel}')
            archive.write(path, rel)
    with ZipFile(ZIP_PATH) as archive:
        if archive.testzip() is not None:
            raise ValueError('review ZIP integrity failure')
        if set(archive.namelist()) != {p.relative_to(PACKAGE_DIR).as_posix() for p in files}:
            raise ValueError('review ZIP manifest mismatch')
    return {'shell': counts, 'role_counts': role_counts, 'proposed_unique': len(decisions['decisions']),
            'approved_current': len(current_approved), 'zip': str(ZIP_PATH)}


if __name__ == '__main__':
    print(json.dumps(build(), indent=2))
