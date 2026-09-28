"""Audit captured EAF2 Receiving shell against the accepted Pass-1 manifest."""
import json
from collections import Counter
from pathlib import Path

import sys

ROOT = Path(__file__).resolve().parents[3]
if __package__ in (None, ''):
    sys.path.insert(0, str(ROOT))
from tools.environment_authoring.receiving_proof.build_pass3_specs import uv_phase
SOURCE = ROOT / 'data/environment/receiving_proof/eaf5_receiving_shell_source.json'
CAPTURE = ROOT / 'reports/environment_receiving_proof/eaf5/shell_review_01/manifest.json'
TOL = 1e-4
CONTACTS = (
    ('ReceivingSouth', 'ReceivingEastOpeningWall'),
    ('ReceivingSouth', 'ReceivingWestSouthReturn'),
    ('ReceivingNorthWest', 'ReceivingWestNorthReturn'),
    ('FreightNorth', 'FreightRear'),
    ('FreightSouth', 'FreightRear'),
    ('FreightNorth', 'ReceivingWestNorthReturn'),
    ('FreightSouth', 'ReceivingWestSouthReturn'),
    ('DispatchSouthWest', 'DispatchWest'),
    ('DispatchSouthEast', 'DispatchEast'),
    ('DispatchNorth', 'DispatchWest'),
    ('DispatchNorth', 'DispatchEast'),
)


def _near(a, b):
    return abs(float(a) - float(b)) <= TOL


def _aabb(record):
    size = record['exact_parameters']['dimensions_m']
    center = record['position_local_m']
    if _near(record['rotation_y_degrees'], 90):
        size = [size[2], size[1], size[0]]
    return [(center[i] - size[i] / 2, center[i] + size[i] / 2) for i in range(3)]


def _same_seq(a, b):
    return len(a) == len(b) and all(_near(x, y) for x, y in zip(a, b))


def audit_shell(source: dict, capture: dict) -> dict:
    errors = []
    planned = {p['piece_id']: p for p in source['eaf2_recipe_mapping']}
    generated = {p['piece_id']: p for p in capture.get('pieces', [])}
    if len(planned) != 19 or set(generated) != set(planned):
        errors.append('piece membership differs from 19 accepted pieces')
    recipes = dict(Counter(p['recipe_id'] for p in generated.values()))
    if recipes != {'rect_solid': 18, 'wall_with_rect_opening': 1}:
        errors.append('EAF2 recipe breakdown differs')
    for piece_id, accepted in planned.items():
        actual = generated.get(piece_id)
        if actual is None:
            continue
        if actual['recipe_id'] != accepted['recipe_id']:
            errors.append(f'{piece_id}: recipe mismatch')
        if not _same_seq(actual['exact_parameters']['dimensions_m'], accepted['dimensions_m']):
            errors.append(f'{piece_id}: dimension mismatch')
        if not _same_seq(actual['position_local_m'], accepted['center_local_m']):
            errors.append(f'{piece_id}: placement/contact mismatch')
        if not _near(actual['rotation_y_degrees'], accepted['rotation_y_degrees']):
            errors.append(f'{piece_id}: rotation mismatch')
        if not _same_seq(actual['root_scale'], [1, 1, 1]):
            errors.append(f'{piece_id}: root scale mismatch')
        if len(actual['geometry_fingerprint']) != 64:
            errors.append(f'{piece_id}: missing geometry fingerprint')
        if actual['spec_errors']:
            errors.append(f'{piece_id}: invalid EAF2 spec')
        if actual['collision_policy'] != 0 or not _near(actual['exact_parameters']['bevel_width_m'], 0):
            errors.append(f'{piece_id}: visual-proof collision/bevel policy mismatch')
        if not _same_seq(actual['uv_origin_m'], uv_phase(accepted)) or actual['uv_quarter_turns'] != 0:
            errors.append(f'{piece_id}: UV phase/rotation mismatch')
        if accepted['opening_parameters']:
            for key, value in accepted['opening_parameters'].items():
                if not _near(actual['exact_parameters'][key], value):
                    errors.append(f'{piece_id}: {key} mismatch')
    # Zone envelopes are hand-checked targets, including 0.30 m slabs.
    for piece_id, expected in {
        'Floor_ReceivingApron': [(0, 10.5), (-0.3, 0), (-5, 5)],
        'Ceiling_ReceivingApron': [(0, 10.5), (4.2, 4.5), (-5, 5)],
        'Floor_FreightEnclosure': [(-5, 0), (-0.3, 0), (-3.5, 3.5)],
        'Ceiling_FreightEnclosure': [(-5, 0), (4.2, 4.5), (-3.5, 3.5)],
    }.items():
        if piece_id in generated and not all(_same_seq(a, b) for a, b in zip(_aabb(generated[piece_id]), expected)):
            errors.append(f'{piece_id}: zone AABB mismatch')
    for left, right in CONTACTS:
        if left not in generated or right not in generated:
            continue
        a, b = _aabb(generated[left]), _aabb(generated[right])
        if any(max(a[i][0], b[i][0]) - min(a[i][1], b[i][1]) > TOL for i in range(3)):
            errors.append(f'{left}/{right}: positive contact gap')
    # Joined overlap is bounded by the accepted 0.15 m lateral extension.
    for a, b in (('FreightNorth', 'ReceivingWestNorthReturn'), ('FreightSouth', 'ReceivingWestSouthReturn')):
        if a in generated and b in generated:
            first, second = _aabb(generated[a]), _aabb(generated[b])
            overlap_x = min(first[0][1], second[0][1]) - max(first[0][0], second[0][0])
            if not _near(overlap_x, 0.15):
                errors.append(f'{a}/{b}: intentional 0.15 m join changed')
    apertures = {}
    if {'ReceivingWestNorthReturn', 'ReceivingWestSouthReturn'} <= generated.keys():
        north = _aabb(generated['ReceivingWestNorthReturn'])
        south = _aabb(generated['ReceivingWestSouthReturn'])
        apertures['west_freight'] = round(south[2][0] - north[2][1], 6)
        if not _near(apertures['west_freight'], 5.0):
            errors.append('west freight aperture differs from 5.00 m')
    if {'DispatchSouthWest', 'DispatchSouthEast'} <= generated.keys():
        west = _aabb(generated['DispatchSouthWest'])
        east = _aabb(generated['DispatchSouthEast'])
        apertures['dispatch'] = round(east[0][0] - west[0][1], 6)
        if not _near(apertures['dispatch'], 2.4):
            errors.append('Dispatch aperture differs from 2.40 m')
    east = generated.get('ReceivingEastOpeningWall')
    if east:
        apertures['east_backlog_width'] = east['exact_parameters']['opening_width_m']
        apertures['east_backlog_height'] = east['exact_parameters']['opening_height_m']
        if not _near(4.2 - apertures['east_backlog_height'], 0.8):
            errors.append('east opening upper closure differs from 0.80 m')
    slabs = [generated[x] for x in generated if x.startswith(('Floor_', 'Ceiling_'))]
    for index, a in enumerate(slabs):
        for b in slabs[index + 1:]:
            if a['piece_id'].split('_')[0] != b['piece_id'].split('_')[0]:
                continue
            aa, bb = _aabb(a), _aabb(b)
            if all(min(aa[i][1], bb[i][1]) - max(aa[i][0], bb[i][0]) > TOL for i in range(3)):
                errors.append(f'{a["piece_id"]}/{b["piece_id"]}: duplicate overlapping slab ownership')
    walls = [piece for piece in generated.values() if not piece['piece_id'].startswith(('Floor_', 'Ceiling_'))]
    for index, a in enumerate(walls):
        for b in walls[index + 1:]:
            if not _near(a['rotation_y_degrees'], b['rotation_y_degrees']):
                continue
            aa, bb = _aabb(a), _aabb(b)
            if all(min(aa[i][1], bb[i][1]) - max(aa[i][0], bb[i][0]) > TOL for i in range(3)):
                errors.append(f'{a["piece_id"]}/{b["piece_id"]}: duplicate coplanar wall ownership')
    walls = [piece for piece in generated.values() if not piece['piece_id'].startswith(('Floor_', 'Ceiling_'))]
    for index, a in enumerate(walls):
        for b in walls[index + 1:]:
            if not _near(a['rotation_y_degrees'], b['rotation_y_degrees']):
                continue
            aa, bb = _aabb(a), _aabb(b)
            if all(min(aa[i][1], bb[i][1]) - max(aa[i][0], bb[i][0]) > TOL for i in range(3)):
                errors.append(f'{a["piece_id"]}/{b["piece_id"]}: duplicate coplanar wall ownership')
    walls = [piece for piece in generated.values() if not piece['piece_id'].startswith(('Floor_', 'Ceiling_'))]
    for index, a in enumerate(walls):
        for b in walls[index + 1:]:
            if not _near(a['rotation_y_degrees'], b['rotation_y_degrees']):
                continue
            aa, bb = _aabb(a), _aabb(b)
            if all(min(aa[i][1], bb[i][1]) - max(aa[i][0], bb[i][0]) > TOL for i in range(3)):
                errors.append(f'{a["piece_id"]}/{b["piece_id"]}: duplicate coplanar wall ownership')
    return {'errors': errors, 'piece_count': len(generated), 'recipes': recipes, 'apertures_m': apertures, 'contact_pairs': len(CONTACTS)}


if __name__ == '__main__':
    result = audit_shell(json.loads(SOURCE.read_text(encoding='utf-8')), json.loads(CAPTURE.read_text(encoding='utf-8')))
    print(json.dumps(result, indent=2))
    raise SystemExit(1 if result['errors'] else 0)
