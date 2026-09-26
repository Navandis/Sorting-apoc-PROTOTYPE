"""Recreate tiny, original synthetic source files. No commercial content."""
from pathlib import Path
from PIL import Image


def generate(root):
    def put(path, data):
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(data, encoding='utf-8')

    def image(path):
        target = root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        Image.new('RGB', (8, 8), (120, 145, 165)).save(target)

    for package, versions in {'kb3d_alpha': ['1.0.0'], 'kb3d_mixed': ['2.0.0']}.items():
        base = f'{package}/{versions[0]}'
        put(f'{base}/Materials/Concrete/Concrete.usd', '#usda 1.0\ndef Material "Concrete" {}\n')
        for resolution in (['1k', '2k', '4k'] if package == 'kb3d_alpha' else ['2k']):
            for channel in ['basecolor', 'normal', 'roughness']:
                image(f'{base}/Textures/png{resolution}/Concrete_{channel}.png')
    base = 'kb3d_mixed/2.0.0'
    for stem, channels in {'Metal': ['albedo', 'metallic', 'orm', 'special'],
                           'Lonely': ['basecolor'], 'Emissive': ['emission'],
                           'Brick': ['basecolor', 'roughness', 'opacity', 'displacement', 'ao']}.items():
        for channel in channels:
            image(f'{base}/Textures/png2k/{stem}_{channel}.png')
    put(f'{base}/Materials/DescriptorOnly/DescriptorOnly.usda', '#usda 1.0\ndef Material "DescriptorOnly" {}')
    put(f'{base}/Geometry/Concrete.usd', 'binary-placeholder-not-material')
    put(f'{base}/Scenes/layout.usdc', 'binary-placeholder-not-material')
    put(f'{base}/Models/crate.fbx', 'synthetic model placeholder')
    put(f'{base}/Docs/readme.txt', 'Synthetic documentation')
    put(f'{base}/metadata.json', '{}')
    put(f'{base}/unknown.weird', 'Unknown must be counted')
    image(f'{base}/Previews/Concrete.png')
    put('unrecognized/layout.data', 'Unknown layout; never guessed into materials')


if __name__ == '__main__':
    generate(Path(__file__).with_name('fixtures'))
