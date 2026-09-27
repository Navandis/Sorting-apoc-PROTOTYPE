"""Conservative flat exported MaterialInstance records."""
import math
import re

PARAMETERS = ('SelectX', 'SelectY', 'CellSizeX', 'CellSizeY', 'Length', 'Height',
              'OpacityLevel', 'Roughness', 'UseCellSizeStep0', 'UseCellSizeStep1')


def scalar(text):
    if text.lower() in ('none', 'null'):
        return None
    if text.lower() in ('true', 'false'):
        return text.lower() == 'true'
    if re.fullmatch(r'[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?', text):
        number = float(text)
        return number if math.isfinite(number) else text
    return text


def parse_instance(text, fallback_name=None):
    raw, names, warnings = {}, [], []
    for line in text.splitlines():
        line = line.strip().lstrip('\ufeff')
        if not line or line.startswith(('#', '//')):
            continue
        if '=' not in line:
            names.append(line)
            continue
        key, value = (p.strip() for p in line.split('=', 1))
        if key in raw:
            warnings.append('duplicate_parameter:' + key)
        raw[key] = scalar(value)
    parameters = {}
    for name in PARAMETERS:
        override = raw.get(name + 'Override')
        if name == 'OpacityLevel' and name + 'Override' not in raw:
            override = raw.get('OpacityOverride')
        parameters[name] = {'recorded': name in raw, 'override': override if isinstance(override, bool) else None,
                            'value': raw.get(name)}
    return {'instance_name': names[0] if names else fallback_name,
            'parent_material': raw.get('Parent'), 'base_texture': raw.get('BaseColor', raw.get('Atlas')),
            'parameters': parameters, 'raw_records': raw, 'warnings': sorted(set(warnings))}


def atlas_region(instance):
    """Only an explicitly recorded normalized offset/size convention is supported.

    Select/CellSize names alone never establish the parent shader's UV equation.
    Live exports currently have no convention, so remain manual metadata cases.
    """
    raw = instance['raw_records']
    inputs = {k: instance['parameters'][k] for k in ('SelectX', 'SelectY', 'CellSizeX', 'CellSizeY', 'UseCellSizeStep0', 'UseCellSizeStep1')}
    result = {'status': 'NEEDS_MANUAL_METADATA', 'rect': None, 'rule': None, 'inputs': inputs,
              'reason': 'No explicit normalized UV convention; parent defaults not inferred'}
    if raw.get('AtlasRegionConvention') != 'normalized_offset_size_top_left' or instance['warnings']:
        return result
    values = [inputs[k]['value'] for k in ('SelectX', 'SelectY', 'CellSizeX', 'CellSizeY')]
    if any(type(v) not in (int, float) or not math.isfinite(v) for v in values):
        return result
    if any(inputs[k]['value'] is True for k in ('UseCellSizeStep0', 'UseCellSizeStep1')):
        return result
    if any(inputs[k]['override'] is False for k in ('SelectX', 'SelectY', 'CellSizeX', 'CellSizeY')):
        return result
    x, y, w, h = values
    if x < 0 or y < 0 or w <= 0 or h <= 0 or x + w > 1 or y + h > 1:
        result['reason'] = 'Recorded rectangle falls outside normalized atlas bounds'
        return result
    return {**result, 'status': 'DERIVED', 'rect': [float(v) for v in values],
            'rule': 'explicit_normalized_offset_size_top_left_v1', 'reason': None}
