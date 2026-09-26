"""Basecolor-only source triage sheets; not final PBR quality evidence."""
import argparse
import json
import math
from pathlib import Path
import textwrap
import time

from PIL import Image, ImageDraw, ImageFont, ImageOps

try:
    from .path_guard import load_repository, BoundaryError
    from .source_index import INDEX_PATH, DIFF_PATH, REPORT_DIR, load_index, fingerprint, quick_signature, write_json
    from .query_index import query, batch_manifest, select_batch, report_path, add_filters, filter_arguments
except ImportError:
    from path_guard import load_repository, BoundaryError
    from source_index import INDEX_PATH, DIFF_PATH, REPORT_DIR, load_index, fingerprint, quick_signature, write_json
    from query_index import query, batch_manifest, select_batch, report_path, add_filters, filter_arguments

PREVIEW_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.tif', '.tiff', '.tga', '.bmp', '.webp'}


def thumbnail(repository, candidate, cache_dir):
    selected = None
    resolution = None
    for res in candidate['available_resolutions']:
        maps = candidate['maps_by_resolution'][res].get('basecolor', [])
        if len(maps) == 1 and Path(maps[0]['relative_path']).suffix.lower() in PREVIEW_EXTENSIONS:
            selected, resolution = maps[0], res
            break
    empty = {'path': None, 'reused': False, 'source_relative_path': None, 'resolution': None}
    if selected is None:
        return {**empty, 'warning': 'no_unambiguous_decodable_basecolor'}
    relative = selected['relative_path']
    try:
        if quick_signature(relative, repository.stat(relative)) != selected:
            return {**empty, 'warning': 'source_changed_rescan_required'}
        key = fingerprint({'stable_id': candidate['stable_id'], 'quick_fingerprint': candidate['quick_fingerprint'],
                           'source': relative, 'resolution': resolution, 'size': 256, 'thumbnail_revision': 1})
        cache = Path(cache_dir) / (key + '.png')
        result = {'path': str(cache), 'source_relative_path': relative, 'resolution': resolution,
                  'reused': cache.exists(), 'warning': None}
        if not cache.exists():
            with repository.open(relative) as stream, Image.open(stream) as source:
                source.thumbnail((256, 256), Image.Resampling.LANCZOS)
                thumb = ImageOps.pad(source.convert('RGB'), (256, 256), color=(38, 43, 50))
                cache.parent.mkdir(parents=True, exist_ok=True)
                thumb.save(cache)
        return result
    except BoundaryError:
        return {**empty, 'warning': 'unsafe_preview_path_rejected'}
    except (OSError, ValueError, Image.DecompressionBombError) as error:
        return {**empty, 'warning': f'preview_decode_or_read_failed:{type(error).__name__}'}


def build_sheets(repository, index, candidates, output_dir, cache_dir, page_size=24):
    if not 1 <= page_size <= 40:
        raise ValueError('page_size must be between 1 and 40')
    start = time.perf_counter()
    output = Path(output_dir)
    output.mkdir(parents=True, exist_ok=True)
    ordered = select_batch(index, batch_manifest(index, candidates))
    manifest = {'schema_version': 1, 'purpose': 'SOURCE TRIAGE ONLY; not PBR quality evidence or material approval',
                'batch': batch_manifest(index, ordered), 'pages': []}
    font = ImageFont.load_default(size=14)
    small = ImageFont.load_default(size=12)
    heading = ImageFont.load_default(size=22)
    columns, tile_width, tile_height = 4, 344, 430
    for page_number, offset in enumerate(range(0, len(ordered), page_size), 1):
        records = ordered[offset:offset + page_size]
        rows = math.ceil(len(records) / columns)
        sheet = Image.new('RGB', (columns * tile_width + 32, rows * tile_height + 100), (21, 25, 31))
        draw = ImageDraw.Draw(sheet)
        draw.text((20, 16), f'EAF3A / SOURCE TRIAGE / PAGE {page_number}', font=heading, fill=(237, 240, 245))
        draw.text((20, 48), 'Basecolor only - source discovery, not material approval or final PBR evidence', font=font, fill=(155, 170, 186))
        page = {'page': page_number, 'image': f'page_{page_number:02d}.png', 'tiles': []}
        for number, candidate in enumerate(records):
            x, y = 16 + (number % columns) * tile_width, 82 + (number // columns) * tile_height
            preview = thumbnail(repository, candidate, cache_dir)
            has_warning = bool(candidate['warnings'] or preview['warning'])
            draw.rounded_rectangle((x, y, x + tile_width - 12, y + tile_height - 12), radius=7, fill=(33, 39, 47))
            if preview['path']:
                with Image.open(preview['path']) as thumb:
                    sheet.paste(thumb, (x + 38, y + 10))
            else:
                draw.rectangle((x + 38, y + 10, x + 294, y + 266), fill=(48, 53, 61))
                draw.text((x + 65, y + 125), 'NO BASECOLOR PREVIEW', font=font, fill=(225, 177, 110))
            label = candidate['display_name']
            text_lines = textwrap.wrap(label, width=37, break_long_words=True)[:2]
            while len(text_lines) < 2:
                text_lines.append('')
            text_lines += [f"#{offset + number + 1:03d}  {candidate['package_id']}@{candidate['package_version']}",
                           'ID: ' + candidate['stable_id'][:41] + ('...' if len(candidate['stable_id']) > 41 else ''),
                           'Res: ' + ', '.join(candidate['available_resolutions']) + ' | ' + candidate['suggested_family']]
            present = sorted({c for m in candidate['maps_by_resolution'].values() for c in m})
            abbreviations = {'basecolor': 'BC', 'normal': 'N', 'roughness': 'R', 'metallic': 'M', 'ao': 'AO', 'height': 'H', 'opacity': 'O', 'emissive': 'E'}
            text_lines += ['Maps: ' + ' '.join(abbreviations.get(c, '?') for c in present),
                           '! WARNINGS - see manifest' if has_warning else 'No indexed warnings']
            for line_number, line in enumerate(text_lines):
                draw.text((x + 10, y + 277 + line_number * 18), line, font=small,
                          fill=(240, 187, 110) if line.startswith('!') else (224, 230, 237))
            page['tiles'].append({'tile_index': number + 1, 'batch_index': offset + number + 1,
                                  'stable_id': candidate['stable_id'], 'display_name': candidate['display_name'],
                                  'preview_source': preview['source_relative_path'], 'preview_resolution': preview['resolution'],
                                  'preview_warning': preview['warning'], 'thumbnail_reused': preview['reused'],
                                  'warnings': candidate['warnings']})
        sheet.save(output / page['image'])
        write_json(output / f'page_{page_number:02d}.json', page)
        manifest['pages'].append(page)
    manifest['generation_seconds'] = round(time.perf_counter() - start, 4)
    write_json(output / 'batch.json', manifest['batch'])
    write_json(output / 'manifest.json', manifest)
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--index', default=str(INDEX_PATH))
    parser.add_argument('--diff', default=str(DIFF_PATH))
    parser.add_argument('--batch')
    parser.add_argument('--output', default=str(REPORT_DIR / 'triage'))
    parser.add_argument('--page-size', type=int, default=24)
    add_filters(parser)
    args = parser.parse_args()
    try:
        index = load_index(report_path(args.index))
        if args.batch:
            if any(value for value in filter_arguments(args).values()):
                raise ValueError('Use a batch or query filters, not both')
            candidates = select_batch(index, json.loads(report_path(args.batch).read_text(encoding='utf-8')))
        else:
            diff = json.loads(report_path(args.diff).read_text(encoding='utf-8')) if args.status else None
            candidates = query(index, diff=diff, **filter_arguments(args))
        manifest = build_sheets(load_repository(), index, candidates, report_path(args.output),
                                REPORT_DIR / 'thumbnails', args.page_size)
        print(f"{len(candidates)} candidates; {len(manifest['pages'])} pages; {manifest['generation_seconds']:.4f} seconds")
    except (OSError, ValueError, KeyError) as error:
        parser.exit(1, f'Triage failed: {error}\n')


if __name__ == '__main__':
    main()
