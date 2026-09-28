"""Render the revised Receiving proof composition as tracked EAF2 piece specs."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json'
HISTORICAL = ROOT / 'data/environment/receiving_proof/eaf5_receiving_shell_source.json'
OUTPUT = ROOT / 'data/environment/receiving_proof/substrate'
CONTROL = 'res://data/environment/receiving_proof/eaf5_review_control.tres'


def piece_role(piece_id: str) -> str:
    if piece_id.startswith(('Floor_Dispatch', 'Ceiling_Dispatch', 'DispatchNorth', 'DispatchEast', 'DispatchWest')):
        return 'CONTEXT_ONLY'
    if piece_id.startswith('Floor_'):
        return 'FLOOR_PRIMARY'
    if piece_id.startswith('Ceiling_'):
        return 'CEILING_PRIMARY'
    if piece_id.startswith('Freight'):
        return 'FREIGHT_RECESS_WALL'
    if piece_id.startswith('ReceivingWest'):
        return 'OPENING_REVEAL'
    return 'WALL_PRIMARY'


def uv_phase(piece: dict) -> tuple[float, float]:
    size = piece['dimensions_m']
    center = piece['center_local_m']
    if piece['semantic_role'] in ('floor', 'ceiling'):
        return round(center[0] - size[0] / 2, 6), round(center[2] - size[2] / 2, 6)
    if piece['rotation_y_degrees'] == 90:
        return round(-(center[2] + size[0] / 2), 6), round(center[1] - size[1] / 2, 6)
    if piece['rotation_y_degrees'] == 0:
        return round(center[0] - size[0] / 2, 6), round(center[1] - size[1] / 2, 6)
    raise ValueError('unsupported shell rotation')


def _number(value: float) -> str:
    return str(float(value))


def build_specs(manifest: dict, output: Path) -> list[Path]:
    mapping = manifest['eaf2_recipe_mapping']
    if len(mapping) != 14 or len({p['piece_id'] for p in mapping}) != 14:
        raise ValueError('revised EAF5 composition must contain 14 distinct pieces')
    if manifest['source_manifest_sha256'] != hashlib.sha256(HISTORICAL.read_bytes()).hexdigest():
        raise ValueError('historical EAF5 source changed since proof composition')
    if {p['recipe_id'] for p in mapping} != {'rect_solid', 'wall_with_rect_opening'}:
        raise ValueError('unexpected EAF2 recipe')
    output.mkdir(parents=True, exist_ok=True)
    paths = []
    for piece in sorted(mapping, key=lambda p: p['piece_id']):
        piece_id = piece['piece_id']
        if not piece_id.replace('_', '').isalnum():
            raise ValueError('unsafe piece ID')
        size = piece['dimensions_m']
        phase = uv_phase(piece)
        role = piece_role(piece_id)
        lines = [
            '[gd_resource type="Resource" script_class="EnvironmentSubstratePieceSpec" load_steps=3 format=3]',
            '',
            '[ext_resource type="Script" path="res://environment_authoring/substrate/environment_substrate_piece_spec.gd" id="1"]',
            f'[ext_resource type="Resource" path="{CONTROL}" id="2"]',
            '',
            '[resource]',
            'script = ExtResource("1")',
            f'piece_id = "{piece_id}"',
            f'recipe_id = "{piece["recipe_id"]}"',
            f'semantic_role = "{role}"',
            f'dimensions_m = Vector3({", ".join(_number(v) for v in size)})',
            'bevel_width_m = 0.0',
            *([f'concealed_faces = PackedStringArray({", ".join(json.dumps(face) for face in piece["concealed_faces"])})'] if piece.get('concealed_faces') else []),
            'uv_quarter_turns = 0',
            f'uv_origin_m = Vector2({_number(phase[0])}, {_number(phase[1])})',
            'collision_policy = 0',
            'material_spec = ExtResource("2")',
            'generation_revision = 1',
            f'authoring_notes = "EAF5 Pass 3A proof composition; {role}; review tooling only."',
        ]
        if piece['recipe_id'] == 'wall_with_rect_opening':
            opening = piece['opening_parameters']
            lines += [f'{key} = {_number(opening[key])}' for key in ('opening_width_m', 'opening_height_m', 'opening_offset_x_m', 'opening_bottom_m')]
        path = output / f'{piece_id}.tres'
        path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
        paths.append(path)
    return paths


if __name__ == '__main__':
    paths = build_specs(json.loads(SOURCE.read_text(encoding='utf-8')), OUTPUT)
    print(f'EAF5_SPECS {len(paths)}')
