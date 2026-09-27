"""Positive-recognition profiles; filenames suggest semantics, never placement."""
from .maps import interpret_map, normalize_group, IMAGES, MODELS, resolution_key
from .metadata import read_metadata, suggestions

PROFILE_REVISIONS = {p: 1 for p in ('FAB_DECAL_PROFILE', 'IMPERFECTION_TEXTURE_PROFILE',
    'UNREAL_EXTRACTED_ATLAS_PROFILE', 'GENERIC_PBR_DECAL_PROFILE',
    'GENERIC_PHYSICAL_DAMAGE_PROFILE', 'FULL_SURFACE_PROFILE', 'MIXED_UNKNOWN_PROFILE')}
CLASSES = ('MASKED_DECAL', 'IMPERFECTION_MASK', 'UNREAL_ATLAS_DECAL_FAMILY',
           'MATERIAL_PATCH_SOURCE', 'PHYSICAL_DAMAGE_MODEL', 'FULL_SURFACE_MATERIAL', 'UNKNOWN')


def profile_for(metadata, channels, is_model=False):
    kind = metadata.get('source_kind')
    if kind == 'decal':
        return 'FAB_DECAL_PROFILE'
    if kind == 'imperfection':
        return 'IMPERFECTION_TEXTURE_PROFILE'
    if kind == 'surface':
        return 'FULL_SURFACE_PROFILE'
    if kind == 'physical_damage' and is_model:
        return 'GENERIC_PHYSICAL_DAMAGE_PROFILE'
    if channels - {'unknown_image'} and not is_model:
        return 'GENERIC_PBR_DECAL_PROFILE'
    return 'MIXED_UNKNOWN_PROFILE'


def classify(metadata, channels, opacity, is_model=False):
    kind = metadata.get('source_kind')
    if is_model:
        return 'PHYSICAL_DAMAGE_MODEL' if kind == 'physical_damage' else 'UNKNOWN'
    if kind == 'imperfection':
        return 'IMPERFECTION_MASK'
    if 'SEPARATE_MASK' in opacity or 'EMBEDDED_ALPHA' in opacity:
        return 'MASKED_DECAL'
    if kind == 'surface' and metadata.get('tileable') is not False:
        return 'FULL_SURFACE_MATERIAL'
    if metadata.get('tileable') is True and 'basecolor' in channels and {'normal', 'roughness', 'orm'} & channels:
        return 'FULL_SURFACE_MATERIAL'
    if kind == 'material_patch' and metadata.get('localized') is True:
        return 'MATERIAL_PATCH_SOURCE'
    return 'UNKNOWN'
