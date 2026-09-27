"""Channel/resolution syntax only; no content-class or placement heuristics."""
from pathlib import PurePosixPath
import re

IMAGES = {'.png', '.jpg', '.jpeg', '.tga', '.tif', '.tiff', '.exr', '.bmp', '.webp'}
MODELS = {'.obj', '.fbx', '.glb', '.gltf', '.abc'}
RESOLUTION = re.compile(r'(?i)(?<![a-z0-9])(?:png|jpe?g|tga|tiff?|exr)?(1|2|4|8|16)k(?![a-z0-9])')
SUFFIXES = {
    'base_color': 'basecolor', 'basecolor': 'basecolor', 'albedo': 'basecolor', 'diffuse': 'basecolor',
    'color': 'basecolor', 'col': 'basecolor', 'baseopacity': 'baseopacity', 'bco': 'basecolor',
    'normal_directx': 'normal', 'normal_opengl': 'normal', 'normalgl': 'normal', 'normaldx': 'normal',
    'normal': 'normal', 'nrm': 'normal', 'roughness': 'roughness', 'rough': 'roughness',
    'glossiness': 'gloss', 'gloss': 'gloss', 'smoothness': 'gloss',
    'metalness': 'metallic', 'metallic': 'metallic', 'ambientocclusion': 'ao', 'ao': 'ao',
    'occlusionroughnessmetallic': 'orm', 'orm': 'orm',
    'displacement': 'height', 'height': 'height', 'bump': 'bump', 'cavity': 'cavity',
    'specular': 'specular', 'opacity': 'opacity', 'alpha': 'opacity', 'mask': 'opacity',
    'emissive': 'emissive', 'emission': 'emissive',
    'rsmo': 'packed_unknown:rsmo', 'mr': 'packed_unknown:mr', 'arm': 'packed_unknown:arm',
    'rma': 'packed_unknown:rma', 'packed': 'packed_unknown:packed',
}


def resolution_key(value):
    return (int(value[:-1]) if re.fullmatch(r'\d+K', value) else 999, value)


def without_resolution(text):
    if not RESOLUTION.search(text):
        return text
    return re.sub(r'__+', '_', RESOLUTION.sub('', text)).strip('_ ')


def normalize_group(relative):
    return '/'.join(without_resolution(p) for p in PurePosixPath(relative).parts if without_resolution(p)) or '.'


def fab_group(relative):
    """Recognized Megascans export suffixes don't create new logical assets."""
    path = PurePosixPath(normalize_group(relative))
    leaf = re.sub(r'_(?:exr|ue_high)$', '', path.name, flags=re.I)
    return (path.parent / leaf).as_posix()


def interpret_map(relative):
    path = PurePosixPath(relative)
    matches = list(RESOLUTION.finditer(path.stem))
    if not matches:
        matches = list(RESOLUTION.finditer(str(path.parent)))
    resolution = matches[-1][1] + 'K' if matches else 'UNKNOWN'
    stem = without_resolution(path.stem)
    channel, token = 'unknown_image', None
    for suffix in sorted(SUFFIXES, key=lambda s: (-len(s), s)):
        if stem.lower().endswith('_' + suffix):
            stem, channel, token = stem[:-len(suffix)-1], SUFFIXES[suffix], suffix
            break
    return {'stem': stem or path.stem, 'resolution': resolution, 'channel': channel,
            'suffix': token, 'normal_convention': ('DIRECTX' if token in ('normal_directx', 'normaldx')
                                                  else 'OPENGL' if token in ('normal_opengl', 'normalgl') else None)}
