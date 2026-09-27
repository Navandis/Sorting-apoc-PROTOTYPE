"""Generate tiny ORIGINAL placeholders; never copies commercial source data."""
import json
from pathlib import Path
from PIL import Image

FIXTURES = Path(__file__).with_name('fixtures')


def make(root=FIXTURES):
    def text(relative, value):
        path = root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(value, encoding='utf-8')

    def image(relative, alpha=False, scalar=False, size=8):
        path = root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        im = Image.new('L' if scalar else 'RGBA' if alpha else 'RGB', (size, size), 140 if scalar else (160, 90, 50, 255) if alpha else (160, 90, 50))
        if alpha:
            for y in range(size):
                for x in range(size):
                    im.putpixel((x, y), (160, 90, 50, 0 if x < size // 2 else 128 if x < size * 3 // 4 else 255))
        im.save(path)

    def fab(folder, identity, kind, maps, tileable=False, area='0.5x1 m'):
        text(f'{folder}/{identity}.json', json.dumps({
            'id': identity, 'name': identity, 'semanticTags': {'asset_type': kind},
            'assetCategories': {kind: {'crack' if kind == 'decal' else 'grunge': {}}},
            'meta': [{'key': 'scanArea', 'value': area}, {'key': 'tileable', 'value': tileable}],
            'maps': [{'type': 'albedo', 'uri': 'absent_8K.png', 'resolution': '8192x8192'}]}))
        for res, channels in maps.items():
            for channel in channels:
                image(f'{folder}/{identity}_{res}_{channel}.png', scalar=channel in ('Opacity', 'Roughness', 'Gloss'))

    fab('fab_crack_2k', 'crack', 'decal', {'2K': ['BaseColor', 'Opacity', 'Normal', 'Roughness']})
    fab('fab_crack_4k', 'crack', 'decal', {'4K': ['BaseColor', 'Opacity']})
    fab('no_opacity_2k', 'FloorCrack', 'decal', {'2K': ['BaseColor', 'Normal']})
    fab('grunge_8k', 'grunge', 'imperfection', {'1K': ['Roughness', 'Gloss'], '2K': ['Roughness'], '4K': ['Roughness'], '8K': ['Roughness']}, True, '2x1 m')
    fab('City-be_selective/surface', 'concrete', 'surface', {'2K': ['BaseColor', 'Normal', 'Roughness']}, True)
    image('City-be_selective/wear/WallLeak_1K_BaseColor.png', alpha=True)
    image('City-be_selective/wear/WallLeak_1K_Normal.png')
    image('embedded/paint_1K_BaseColor.tga', alpha=True)
    image('embedded/paint_1K_Normal.tga')
    image('separate/mark_basecolor_4k.png')
    image('separate/mark_opacity_4k.png', scalar=True)
    image('separate/mark_normal_opengl_4k.png')
    image('separate/mark_normal_directx_4k.png')
    image('separate/mark_RSMO_4k.png', alpha=True)
    image('packed_only/floor_2K_BaseColor.png')
    image('packed_only/floor_2K_ORM.png', alpha=True)
    image('unknown/mystery.png')
    text('unknown/layout.data', 'unsupported original fixture')
    text('City-be_selective/unsupported/graph.sbsar', 'placeholder, not an actual graph')
    text('physical/chipped_wall.obj', 'o original_placeholder\nv 0 0 0\nv 1 0 0\nv 0 1 0\nf 1 2 3\n')
    text('physical/source.json', json.dumps({'eaf4_source_metadata_version': 1, 'source_kind': 'physical_damage'}))
    text('patch/source.json', json.dumps({'eaf4_source_metadata_version': 1, 'source_kind': 'material_patch', 'localized': True}))
    image('patch/repair_1K_BaseColor.png')
    image('patch/repair_1K_Normal.png')
    image('unreal_extracted/leaks/T_Atlas_BCO.tga', alpha=True)
    text('unreal_extracted/leaks/MI_A.txt', 'MI_A\nParent=M_Leaks\nBaseColor=T_Atlas_BCO\nSelectX=0\nSelectY=0\nCellSizeX=0.5\nCellSizeY=1\nAtlasRegionConvention=normalized_offset_size_top_left\nHeightOverride=true\nHeight=None\nLength=2\n')
    text('unreal_extracted/leaks/MI_B.txt', 'MI_B\nParent=M_Leaks\nBaseColor=T_Atlas_BCO\nSelectX=1\nSelectY=0\nCellSizeX=1\nCellSizeY=1\nHeight=0\nOpacityLevel=0\nOpacityOverride=true\n')
    text('unreal_extracted/leaks/MI_C.txt', 'MI_C\nParent=M_Leaks\nBaseColor=T_Atlas_BCO\nHeight=2\n')
    for ext in ('zip', '7z', 'rar', 'tar', 'gz'):
        text(f'bookkeeping/FloorCrack.{ext}', 'DO NOT OPEN ARCHIVE PLACEHOLDER')
    text('City-be_selective/download.zip', 'DO NOT OPEN')
    text('__MACOSX/._junk.png', 'resource fork, not a texture')


if __name__ == '__main__':
    make()
