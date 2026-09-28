"""Audit captured EAF2 Receiving shell against the accepted Pass-1 manifest."""
import hashlib
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
COMPOSITION = ROOT / 'data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json'
CAPTURE_V2 = ROOT / 'reports/environment_receiving_proof/eaf5/shell_review_02/manifest.json'
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
    return {'errors': errors, 'piece_count': len(generated), 'recipes': recipes, 'apertures_m': apertures, 'contact_pairs': len(CONTACTS)}


# Pass 3A adds occupied-side face ownership while retaining the v1 audit above.
CLOSED_PERIMETER_PROBES = (
    # slab, edge axis, boundary, along axis, occupied samples, owning wall
    ('ReceivingApron', 0, 0.0, 2, (-4.4, -3.0), 'ReceivingWestNorthReturn'),
    ('ReceivingApron', 0, 0.0, 2, (3.0, 4.4), 'ReceivingWestSouthReturn'),
    ('ReceivingApron', 0, 10.5, 2, (-4.0, -2.2, 2.2, 4.0), 'ReceivingEastOpeningWall'),
    ('ReceivingApron', 2, 5.0, 0, (0.4, 5.0, 10.0), 'ReceivingSouth'),
    ('ReceivingApron', 2, -5.0, 0, (0.4,), 'ReceivingNorthWest'),
    ('ReceivingApron', 2, -5.0, 0, (2.5,), 'DispatchSouthWest'),
    ('ReceivingApron', 2, -5.0, 0, (8.5, 10.0), 'DispatchSouthEast'),
    ('FreightEnclosure', 0, -5.0, 2, (-3.0, 0.0, 3.0), 'FreightRear'),
    ('FreightEnclosure', 0, 0.0, 2, (-3.0,), 'ReceivingWestNorthReturn'),
    ('FreightEnclosure', 0, 0.0, 2, (3.0,), 'ReceivingWestSouthReturn'),
    ('FreightEnclosure', 2, -3.5, 0, (-4.0, -2.0, -0.5), 'FreightNorth'),
    ('FreightEnclosure', 2, 3.5, 0, (-4.0, -2.0, -0.5), 'FreightSouth'),
)


# Only butt caps and slab sides covered by adjacent structure or continuation are omitted. Reveals remain closed.
REQUIRED_CONCEALED_FACES = {
    'Floor_FreightEnclosure': {'NEG_X', 'POS_X', 'NEG_Z', 'POS_Z'},
    'Floor_ReceivingApron': {'NEG_X', 'POS_X', 'NEG_Z', 'POS_Z'},
    'Ceiling_FreightEnclosure': {'NEG_X', 'POS_X', 'NEG_Z', 'POS_Z'},
    'Ceiling_ReceivingApron': {'NEG_X', 'POS_X', 'NEG_Z', 'POS_Z'},
    'ReceivingSouth': {'POS_X'},
    'DispatchSouthEast': {'POS_X'},
    'FreightNorth': {'NEG_X', 'POS_X'},
    'FreightSouth': {'NEG_X', 'POS_X'},
    'ReceivingWestNorthReturn': {'POS_X'},
    'ReceivingWestSouthReturn': {'NEG_X'},
    'ReceivingNorthWest': {'POS_X'},
    'DispatchSouthWest': {'NEG_X'},
}


def _inside(value, bounds, tolerance=TOL):
    return bounds[0] - tolerance <= value <= bounds[1] + tolerance


def _wall_contains_sample(wall, axis, boundary, along_axis, along):
    box = _aabb(wall)
    return box[axis][0] + TOL < boundary < box[axis][1] - TOL and _inside(along, box[along_axis])


def _solid_at(point, piece):
    box = _aabb(piece)
    if not all(_inside(point[axis], box[axis]) for axis in range(3)):
        return False
    if piece['recipe_id'] == 'wall_with_rect_opening':
        opening = piece['exact_parameters']
        # The only opening wall is Y-rotated, so its opening axis is world Z.
        return not (
            abs(point[2] - piece['position_local_m'][2]) < opening['opening_width_m'] / 2 - TOL
            and 0.0 + TOL < point[1] < opening['opening_height_m'] - TOL
        )
    return True


def audit_shell_v2(source: dict, composition: dict, capture: dict) -> dict:
    errors = []
    source_hash = hashlib.sha256(SOURCE.read_bytes()).hexdigest()
    if composition.get('source_manifest_sha256') != source_hash or capture.get('shell_source_sha256') != source_hash:
        errors.append('historical source fingerprint mismatch')
    if capture.get('proof_composition_sha256') != hashlib.sha256(COMPOSITION.read_bytes()).hexdigest():
        errors.append('proof composition fingerprint mismatch')
    if source['dimensions']['main_apron'] != {'x_bounds_local_m': [0, 10.5], 'z_bounds_local_m': [-5, 5], 'width_m': 10.5, 'depth_m': 10.0, 'clear_height_m': 4.2}:
        errors.append('accepted main apron authority changed')
    if source['dimensions']['freight_enclosure'] != {'x_bounds_local_m': [-5, 0], 'z_bounds_local_m': [-3.5, 3.5], 'depth_m': 5.0, 'width_m': 7.0, 'clear_height_m': 4.2}:
        errors.append('accepted freight authority changed')
    expected_exclusions = {'Floor_DispatchAnnex', 'Ceiling_DispatchAnnex', 'DispatchWest', 'DispatchNorth', 'DispatchEast'}
    if set(composition.get('source_piece_exclusions', [])) != expected_exclusions:
        errors.append('Dispatch annex exclusion differs')
    planned = {piece['piece_id']: piece for piece in composition['eaf2_recipe_mapping']}
    generated = {piece['piece_id']: piece for piece in capture.get('pieces', [])}
    if len(planned) != 14 or set(generated) != set(planned) or expected_exclusions & generated.keys():
        errors.append('authoritative EAF2 membership differs from 14 Receiving pieces')
    recipes = dict(Counter(piece['recipe_id'] for piece in generated.values()))
    if recipes != {'rect_solid': 13, 'wall_with_rect_opening': 1}:
        errors.append('revised EAF2 recipe breakdown differs')
    for piece_id, accepted in planned.items():
        actual = generated.get(piece_id)
        if actual is None:
            continue
        if actual['recipe_id'] != accepted['recipe_id'] or not _same_seq(actual['exact_parameters']['dimensions_m'], accepted['dimensions_m']):
            errors.append(f'{piece_id}: recipe/dimension mismatch')
        if not _same_seq(actual['position_local_m'], accepted['center_local_m']) or not _near(actual['rotation_y_degrees'], accepted['rotation_y_degrees']):
            errors.append(f'{piece_id}: placement mismatch')
        if not _same_seq(actual['root_scale'], [1, 1, 1]) or len(actual['geometry_fingerprint']) != 64 or actual['spec_errors']:
            errors.append(f'{piece_id}: invalid EAF2 generation')
        if actual['collision_policy'] != 0 or not _near(actual['exact_parameters']['bevel_width_m'], 0):
            errors.append(f'{piece_id}: visual proof collision/bevel mismatch')
        if not _same_seq(actual['uv_origin_m'], uv_phase(accepted)) or actual['uv_quarter_turns'] != 0:
            errors.append(f'{piece_id}: UV phase/orientation mismatch')
        for key, value in (accepted['opening_parameters'] or {}).items():
            if not _near(actual['exact_parameters'][key], value):
                errors.append(f'{piece_id}: {key} mismatch')
    floor_failures = []
    ceiling_failures = []
    for zone, axis, boundary, along_axis, samples, wall_id in CLOSED_PERIMETER_PROBES:
        wall = generated.get(wall_id)
        for prefix, failures, interface in (('Floor', floor_failures, 0.0), ('Ceiling', ceiling_failures, 4.2)):
            slab = generated.get(prefix + '_' + zone)
            label = f'{prefix}_{zone}/{wall_id} at {boundary}'
            if slab is None or wall is None:
                failures.append(label + ': missing owner')
                continue
            slab_box = _aabb(slab)
            wall_box = _aabb(wall)
            if not _near(slab_box[axis][0 if boundary < sum(slab_box[axis]) / 2 else 1], boundary):
                failures.append(label + ': slab boundary moved')
            if not _near(slab_box[1][1 if prefix == 'Floor' else 0], interface):
                failures.append(label + ': finished interface moved')
            if not (wall_box[1][0] < 0.0 and wall_box[1][1] > 4.2):
                failures.append(label + ': wall does not bury slab-side contact')
            for along in samples:
                if not _wall_contains_sample(wall, axis, boundary, along_axis, along):
                    failures.append(f'{label}: exposed slab side at {along}')
    errors += ['floor perimeter: ' + item for item in floor_failures]
    errors += ['ceiling perimeter: ' + item for item in ceiling_failures]
    corner_failures = []
    for join in composition['join_ownership']:
        if join['through'] == 'COLLINEAR_BUTT':
            left, right = (generated.get(x) for x in join['junction'].split(' / '))
            if left is None or right is None or not _near(_aabb(left)[0][1], _aabb(right)[0][0]):
                corner_failures.append(join['junction'] + ': collinear gap/overlap')
            continue
        through, butt = generated.get(join['through']), generated.get(join['butt'])
        if through is None or butt is None:
            corner_failures.append(join['junction'] + ': missing wall')
            continue
        axis_name, value_text = join['contact_plane'].split('=')
        axis = {'X': 0, 'Z': 2}[axis_name]
        value = float(value_text)
        through_box, butt_box = _aabb(through), _aabb(butt)
        tangential = 2 if axis == 0 else 0
        if not (any(_near(edge, value) for edge in through_box[axis]) and any(_near(edge, value) for edge in butt_box[axis])):
            corner_failures.append(join['junction'] + ': butt end does not meet through face')
        if not (through_box[tangential][0] <= butt_box[tangential][0] + TOL and through_box[tangential][1] >= butt_box[tangential][1] - TOL):
            corner_failures.append(join['junction'] + ': through wall leaves exposed butt end')
    errors += ['corner ownership: ' + item for item in corner_failures]
    wall_end_failures = []
    slab_side_failures = []
    for piece_id, actual in generated.items():
        required = REQUIRED_CONCEALED_FACES.get(piece_id, set())
        planned_flags = set(planned[piece_id].get('concealed_faces', [])) if piece_id in planned else set()
        actual_flags = set(actual['exact_parameters'].get('concealed_faces', []))
        if planned_flags != required or actual_flags != required:
            failures = slab_side_failures if piece_id.startswith(('Floor_', 'Ceiling_')) else wall_end_failures
            failures.append(f'{piece_id}: concealed face ownership differs')
    errors += ['wall end face: ' + item for item in wall_end_failures]
    errors += ['slab side face: ' + item for item in slab_side_failures]
    aperture_failures = []
    walls = [piece for piece in generated.values() if not piece['piece_id'].startswith(('Floor_', 'Ceiling_'))]
    for opening, samples in (
        ('west_freight', [(0.0, y, z) for y in (0.05, 2.1, 4.15) for z in (-2.4, 0.0, 2.4)]),
        ('dispatch', [(x, y, -5.0) for y in (0.05, 2.1, 4.15) for x in (4.9, 6.0, 7.1)]),
        ('east_backlog', [(10.5, y, z) for y in (0.05, 2.0, 3.35) for z in (-1.8, 0.0, 1.8)]),
    ):
        for point in samples:
            blockers = [piece['piece_id'] for piece in walls if _solid_at(point, piece)]
            if blockers:
                aperture_failures.append(f'{opening} {point}: {blockers}')
    east = generated.get('ReceivingEastOpeningWall')
    if east and (not _near(east['exact_parameters']['opening_width_m'], 3.84) or not _near(east['exact_parameters']['opening_height_m'], 3.4) or not _near(east['exact_parameters']['opening_bottom_m'], 0.3)):
        aperture_failures.append('east opening bounds changed')
    errors += ['aperture obstruction: ' + item for item in aperture_failures]
    return {
        'errors': errors,
        'piece_count': len(generated),
        'recipes': recipes,
        'floor_perimeter_failures': len(floor_failures),
        'ceiling_perimeter_failures': len(ceiling_failures),
        'corner_ownership_failures': len(corner_failures),
        'wall_end_face_failures': len(wall_end_failures),
        'slab_side_face_failures': len(slab_side_failures),
        'aperture_obstruction_failures': len(aperture_failures),
        'perimeter_probe_count': 2 * sum(len(item[4]) for item in CLOSED_PERIMETER_PROBES),
        'corner_join_count': len(composition['join_ownership']),
        'aperture_probe_count': 27,
    }


if __name__ == '__main__':
    result = audit_shell_v2(
        json.loads(SOURCE.read_text(encoding='utf-8')),
        json.loads(COMPOSITION.read_text(encoding='utf-8')),
        json.loads(CAPTURE_V2.read_text(encoding='utf-8')),
    )
    print(json.dumps(result, indent=2))
    raise SystemExit(1 if result['errors'] else 0)
