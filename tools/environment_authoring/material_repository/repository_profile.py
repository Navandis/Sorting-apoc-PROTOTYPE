"""Path interpretation belongs here; scanner/query/sheets are format independent."""
from pathlib import PurePosixPath
import re
import stat

CATEGORIES = ('MATERIAL_DESCRIPTOR', 'MATERIAL_TEXTURE', 'MODEL', 'SCENE_OR_GEOMETRY',
              'IMAGE_PREVIEW', 'DOCUMENTATION', 'METADATA', 'UNKNOWN')
CHANNELS = ('basecolor', 'normal', 'roughness', 'metallic', 'ao', 'height', 'opacity', 'emissive')
OPTIONAL_CHANNELS = {'ao', 'height', 'opacity', 'emissive'}
IMAGES = {'.png', '.jpg', '.jpeg', '.tif', '.tiff', '.tga', '.exr', '.bmp', '.webp'}


class KitBashProfile:
    profile_id = 'KITBASH_PROFILE_V1'
    revision = 1
    resolution_pattern = re.compile(r'(?:(?:png|jpe?g|exr|tiff?|tga))?(1|2|4|8|16)k$', re.I)
    suffixes = {
        'basecolor': 'basecolor', 'base_color': 'basecolor', 'albedo': 'basecolor',
        'normal': 'normal', 'roughness': 'roughness', 'metallic': 'metallic', 'metalness': 'metallic',
        'ao': 'ao', 'ambientocclusion': 'ao', 'height': 'height', 'displacement': 'height',
        'opacity': 'opacity', 'emissive': 'emissive', 'emission': 'emissive',
        'orm': 'packed', 'arm': 'packed', 'rma': 'packed', 'packed': 'packed',
        'refraction': 'refraction', 'specular': 'specular', 'glossiness': 'glossiness',
    }

    def packages(self, repository):
        packages = []
        for rel, info in repository.entries():
            if not stat.S_ISDIR(info.st_mode) or not rel.lower().startswith('kb3d_'):
                continue
            for version_path, version_info in repository.entries(rel):
                version = PurePosixPath(version_path).name
                if stat.S_ISDIR(version_info.st_mode) and re.fullmatch(r'\d+\.\d+\.\d+(?:[-+][\w.-]+)?', version):
                    packages.append({'package_id': rel.lower(), 'display_name': rel[5:],
                                     'version': version, 'relative_root': version_path,
                                     'profile_id': self.profile_id, 'warnings': [], 'metadata_hints': {}})
        return packages

    def interpret(self, relative):
        """Return category and optional logical material facts, relative to package."""
        path = PurePosixPath(relative)
        parts = path.parts
        lower = [p.lower() for p in parts]
        ext = path.suffix.lower()
        stem = path.stem
        if (len(parts) >= 3 and lower[0] == 'materials' and ext in {'.usd', '.usda', '.usdc'}
                and parts[-2] == stem):
            return 'MATERIAL_DESCRIPTOR', {'stem': stem, 'group': '/'.join(parts[1:-2])}
        if lower[0] == 'textures' and ext in IMAGES:
            resolution = 'UNKNOWN'
            group_parts = []
            for part in parts[1:-1]:
                match = self.resolution_pattern.fullmatch(part)
                if match:
                    resolution = match[1] + 'K'
                else:
                    group_parts.append(part)
            channel = None
            suffix = ''
            for token in sorted(self.suffixes, key=lambda s: (-len(s), s)):
                if stem.lower().endswith('_' + token):
                    suffix = token
                    channel = self.suffixes[token]
                    stem = stem[:-len(token)-1]
                    break
            if channel is None and '_' in stem:
                stem, suffix = stem.rsplit('_', 1)
                channel = 'unknown:' + suffix
            if channel and stem:
                info = {'stem': stem, 'group': '/'.join(group_parts), 'resolution': resolution,
                        'channel': channel, 'suffix': suffix}
                return ('MATERIAL_TEXTURE' if channel in CHANNELS or channel == 'packed'
                        or channel in {'refraction', 'specular', 'glossiness'} else 'UNKNOWN'), info
            return 'UNKNOWN', None
        if ext in {'.usd', '.usda', '.usdc', '.usdz', '.tscn', '.blend', '.ma', '.mb'}:
            return 'SCENE_OR_GEOMETRY', None
        if ext in {'.fbx', '.obj', '.gltf', '.glb', '.abc'}:
            return 'MODEL', None
        if ext in IMAGES:
            return ('IMAGE_PREVIEW' if any(p in {'preview', 'previews', 'thumbnails', 'renders'} for p in lower[:-1]) else 'UNKNOWN'), None
        if ext in {'.txt', '.md', '.pdf', '.html', '.rtf'}:
            return 'DOCUMENTATION', None
        if ext in {'.json', '.xml', '.yaml', '.yml', '.ini'}:
            return 'METADATA', None
        # Substance graphs are not parsed or expanded into source candidates.
        if lower[0] == 'substances' and ext in {'.sbs', '.sbsar'}:
            return 'UNKNOWN', {'stem': stem, 'group': '/'.join(parts[1:-2]), 'graph': True}
        return 'UNKNOWN', None

    def metadata_hints(self, repository, relative, size):
        # Bounded ASCII header inspection; never decode binary USD or large files.
        if size > 1024 * 1024:
            return {}
        with repository.open(relative) as stream:
            header = stream.read(8192)
        if not header.startswith(b'#usda'):
            return {}
        text = header.decode('utf-8', errors='replace')
        return dict(re.findall(r'string (kitDisplayName|kitId|kitVersion) = "([^"\r\n]+)"', text))

    def suggested_family(self, stem, package):
        name = stem.casefold()
        for family, tokens in (
            ('cement_render', ('plaster', 'render', 'stucco', 'cement')),
            ('masonry_block', ('cinder', 'masonry', 'concreteblock')),
            ('concrete', ('concrete',)), ('brick', ('brick',)), ('tile', ('tile', 'ceramic')),
            ('metal', ('metal', 'steel', 'iron', 'copper', 'aluminium', 'aluminum')),
            ('wood', ('wood', 'timber', 'plywood')), ('paint', ('paint',)),
            ('other', ('cloth', 'fabric', 'leather', 'glass', 'asphalt', 'rubber', 'plastic')),
        ):
            if any(token in name for token in tokens):
                return family
        return 'unknown'

    def material_warnings(self, stem):
        name = re.sub(r'^kb3d_[^_]+_', '', stem, flags=re.I).lower()
        if 'trim' in name or 'atlas' in name or name.startswith(('atl', 'unq')):
            return ['atlas_trim_or_object_specific_name;tileability_unverified']
        return []


KITBASH_PROFILE_V1 = KitBashProfile()
