"""Guarded image facts. Inspect headers for all variants, alpha on efficient ones."""
from PIL import Image


def header(repository, relative):
    try:
        with repository.open(relative) as stream, Image.open(stream) as im:
            return {'width_px': im.width, 'height_px': im.height, 'mode': im.mode,
                    'has_alpha': 'A' in im.getbands() or 'transparency' in im.info,
                    'decode_warning': None}
    except (OSError, ValueError, Image.DecompressionBombError) as error:
        return {'width_px': None, 'height_px': None, 'mode': None, 'has_alpha': None,
                'decode_warning': 'image_header_unavailable:' + type(error).__name__}


def alpha_statistics(repository, relative):
    with repository.open(relative) as stream, Image.open(stream) as im:
        if 'A' not in im.getbands() and 'transparency' not in im.info:
            return None
        histogram = im.convert('RGBA').getchannel('A').histogram()
        total = sum(histogram)
        return {'has_alpha': True, 'opaque_fraction': histogram[255] / total,
                'transparent_fraction': histogram[0] / total,
                'partial_alpha_fraction': sum(histogram[1:255]) / total,
                'method': 'exact_8bit_alpha_histogram', 'source_relative_path': relative}


def efficient_map(maps, channels):
    """Prefer the requested channel then the smallest actual image, not advertised size."""
    for channel in channels:
        choices = [
            ((m.get('width_px') or 99999) * (m.get('height_px') or 99999), res, m)
            for res, channels_by_res in maps.items() for m in channels_by_res.get(channel, [])
            if m.get('decode_warning') is None]
        if choices:
            _, resolution, selected = min(choices, key=lambda v: (v[0], int(v[1][:-1]) if v[1].endswith('K') else 999, v[2]['relative_path']))
            return selected, resolution, channel
    return None, None, None
