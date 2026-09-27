"""Guarded alpha-aware source previews and triage sheets."""
import argparse
from collections import defaultdict
import json
import math
from pathlib import Path
import textwrap
import time

from PIL import Image, ImageDraw, ImageFont, ImageOps

from .path_guard import load_repository, BoundaryError
from .source_index import (INDEX_PATH, DIFF_PATH, REPORT_DIR, load_index, fingerprint, quick_signature,
                           signature_from_map, write_json)
from .image_facts import efficient_map
from .query_index import (candidate_maps, query, batch_manifest, select_batch, report_path, add_filters, filter_arguments)


def checked_output(repository, value):
    output = Path(value).resolve()
    if output.is_relative_to(repository.root) or repository.root.is_relative_to(output):
        raise BoundaryError('Source repository is read-only, including output/cache paths')
    return output


def checker(size):
    im = Image.new('RGBA', size, (95, 100, 106, 255))
    draw = ImageDraw.Draw(im)
    for y in range(0, size[1], 16):
        for x in range(0, size[0], 16):
            if (x // 16 + y // 16) % 2:
                draw.rectangle((x, y, x + 15, y + 15), fill=(135, 140, 146, 255))
    return im


def thumbnail(repository, index, candidate, cache_dir):
    cache_dir = checked_output(repository, cache_dir)
    maps = candidate_maps(index, candidate)
    priorities = ('roughness', 'gloss', 'opacity', 'unknown_image') if candidate['source_class'] == 'IMPERFECTION_MASK' else ('baseopacity', 'basecolor', 'opacity', 'roughness', 'gloss', 'unknown_image')
    selected, resolution, channel = efficient_map(maps, priorities)
    alpha_source = (candidate.get('alpha_stats') or {}).get('source_relative_path')
    if 'EMBEDDED_ALPHA' in candidate['opacity_source'] and candidate['source_class'] != 'IMPERFECTION_MASK':
        for res, channels in maps.items():
            for ch in ('basecolor', 'baseopacity', 'unknown_image'):
                for record in channels.get(ch, []):
                    if record['relative_path'] == alpha_source:
                        selected, resolution, channel = record, res, ch
    empty = {'path': None, 'reused': False, 'source_relative_path': None, 'resolution': None, 'channel': None,
             'warning': None, 'preview_scope': 'SOURCE_TEXTURE', 'opacity_compositing': None}
    if selected is None:
        return {**empty, 'warning': 'no_supported_preview_channel'}
    relative = selected['relative_path']
    mask_maps = maps[resolution].get('opacity', []) if channel in ('basecolor', 'baseopacity') else []
    mask = mask_maps[0] if len(mask_maps) == 1 else None
    signatures = candidate['source_files'] + candidate.get('atlas_quick_signatures', []) + [signature_from_map(selected)]
    if mask:
        signatures.append(signature_from_map(mask))
    try:
        actual = [quick_signature(sig['relative_path'], repository.stat(sig['relative_path'])) for sig in signatures]
        if any(now != signature_from_map(sig) for now, sig in zip(actual, signatures)):
            return {**empty, 'warning': 'source_changed_rescan_required'}
        region = candidate.get('atlas_region', {})
        rect = region.get('rect') if region.get('status') == 'DERIVED' else None
        # Reject manipulated rectangles too; never trust prior-index crop coordinates.
        if rect and (len(rect) != 4 or any(type(v) not in (int, float) or not math.isfinite(v) for v in rect)
                     or min(rect) < 0 or min(rect[2:]) <= 0 or rect[0] + rect[2] > 1 or rect[1] + rect[3] > 1):
            raise ValueError('Invalid normalized atlas rectangle')
        atlas = bool(candidate.get('atlas_texture_family_ref'))
        scope = 'LOGICAL_ATLAS_REGION' if atlas and rect else 'WHOLE_ATLAS_UNRESOLVED' if atlas else 'SOURCE_TEXTURE'
        warning = 'whole_atlas_shown_region_needs_manual_metadata' if scope == 'WHOLE_ATLAS_UNRESOLVED' else None
        cache = cache_dir / (fingerprint({'candidate': candidate, 'selected': selected, 'mask': mask, 'size': 256, 'preview_revision': 1}) + '.png')
        color_preview = channel in ('basecolor', 'baseopacity', 'unknown_image')
        compositing = 'separate_mask' if mask else 'embedded_alpha' if selected['has_alpha'] and color_preview else None
        result = {**empty, 'path': str(cache), 'reused': cache.exists(), 'source_relative_path': relative,
                  'resolution': resolution, 'channel': 'gloss_inverted_for_display' if channel == 'gloss' else channel,
                  'preview_scope': scope, 'opacity_compositing': compositing, 'warning': warning,
                  'mask_source': mask['relative_path'] if mask else None}
        if not cache.exists():
            with repository.open(relative) as stream, Image.open(stream) as source:
                if rect:
                    x, y, w, h = rect
                    im = source.crop((round(x * source.width), round(y * source.height), round((x + w) * source.width), round((y + h) * source.height)))
                else:
                    source.thumbnail((256, 256), Image.Resampling.LANCZOS)
                    im = source.copy()
                im.thumbnail((256, 256), Image.Resampling.LANCZOS)
                if channel == 'gloss':
                    im = ImageOps.invert(im.convert('L'))
                if not color_preview:
                    im = im.convert('RGB')
                im = im.convert('RGBA')
                if mask:
                    with repository.open(mask['relative_path']) as mask_stream, Image.open(mask_stream) as mask_image:
                        alpha = mask_image.convert('L').resize(im.size, Image.Resampling.LANCZOS)
                        im.putalpha(alpha)
                if compositing:
                    background = checker(im.size)
                    background.alpha_composite(im)
                    im = background
                thumb = ImageOps.pad(im.convert('RGB'), (256, 256), color=(36, 42, 49))
                cache.parent.mkdir(parents=True, exist_ok=True)
                thumb.save(cache)
        return result
    except BoundaryError:
        return {**empty, 'warning': 'unsafe_preview_path_rejected'}
    except (OSError, ValueError, Image.DecompressionBombError) as error:
        return {**empty, 'warning': 'preview_read_or_decode_failed:' + type(error).__name__}


def build_sheets(repository, index, candidates, output_dir, cache_dir, page_size=16, title='SOURCE TRIAGE'):
    if not 1 <= page_size <= 40:
        raise ValueError('page_size must be 1..40')
    start = time.perf_counter()
    output = checked_output(repository, output_dir)
    output.mkdir(parents=True, exist_ok=True)
    ordered = select_batch(index, batch_manifest(index, candidates))
    manifest = {'schema_version': 1, 'purpose': 'SOURCE TRIAGE ONLY; no artistic approval or runtime validation',
                'title': title, 'batch': batch_manifest(index, ordered), 'pages': []}
    font, small, heading = (ImageFont.load_default(size=size) for size in (14, 13, 23))
    columns, tw, th = 4, 358, 488
    for number, offset in enumerate(range(0, len(ordered), page_size), 1):
        records = ordered[offset:offset + page_size]
        sheet = Image.new('RGB', (columns * tw + 32, math.ceil(len(records) / columns) * th + 100), (20, 25, 31))
        draw = ImageDraw.Draw(sheet)
        draw.text((20, 15), 'EAF4A / ' + title.replace('_', ' ').upper() + f' / {number}', fill=(239, 242, 245), font=heading)
        draw.text((20, 49), 'Source evidence only | checker = transparency | full IDs and warnings in page manifest', fill=(162, 180, 197), font=font)
        page = {'page': number, 'image': f'page_{number:02d}.png', 'tiles': []}
        for i, c in enumerate(records):
            x, y = 16 + i % columns * tw, 82 + i // columns * th
            preview = thumbnail(repository, index, c, cache_dir)
            draw.rounded_rectangle((x, y, x + tw - 12, y + th - 12), radius=8, fill=(34, 40, 49))
            if preview['path']:
                with Image.open(preview['path']) as im:
                    sheet.paste(im, (x + 43, y + 10))
            else:
                draw.text((x + 65, y + 128), 'NO SOURCE PREVIEW', fill=(244, 187, 107), font=font)
            short_id = fingerprint(c['stable_id'])[:12]
            names = textwrap.wrap(c['display_name'], width=42)[:2]
            names += [''] * (2 - len(names))
            size = f"{c['source_physical_width_m']:g} x {c['source_physical_height_m']:g} m" if c['source_physical_width_m'] is not None else 'size unknown'
            channels = sorted({ch for maps in candidate_maps(index, c).values() for ch in maps})
            abbreviations = {'basecolor': 'BC', 'baseopacity': 'BC+A', 'normal': 'N', 'roughness': 'R', 'gloss': 'G', 'opacity': 'O', 'metallic': 'M', 'height': 'H', 'emissive': 'E', 'ao': 'AO', 'cavity': 'C', 'bump': 'B', 'specular': 'S', 'orm': 'ORM'}
            marker = '!' if c['warnings'] or preview['warning'] else '-'
            opacity_labels = {'ATLAS_ALPHA': 'atlas alpha', 'EMBEDDED_ALPHA': 'embedded alpha',
                              'SEPARATE_MASK': 'separate mask', 'MATERIAL_SCALAR': 'scalar', 'NONE': 'none', 'UNKNOWN': 'unknown'}
            lines = names + ['ID ' + short_id + ' | ' + c['suggested_family'], c['source_class'],
                'Res: ' + ', '.join(c['available_resolutions']) + ' | ' + size,
                'Maps: ' + ' '.join(abbreviations.get(ch, '?') for ch in channels),
                'Opacity: ' + ' + '.join(opacity_labels[o] for o in c['opacity_source']),
                'Tileable: ' + {True: 'yes', False: 'no', None: 'unknown'}[c['tileable']] + ' | Preview: ' + str(preview['channel']) + '/' + str(preview['resolution']),
                'WHOLE ATLAS - region unresolved' if preview['preview_scope'] == 'WHOLE_ATLAS_UNRESOLVED' else preview['preview_scope'],
                marker + (' warnings: see manifest' if marker == '!' else ' no indexed warnings')]
            for j, line in enumerate(lines):
                draw.text((x + 10, y + 278 + j * 18), line, font=small, fill=(243, 189, 107) if line.startswith(('!', 'WHOLE ATLAS')) else (226, 233, 239))
            page['tiles'].append({'tile_index': i + 1, 'stable_id': c['stable_id'], 'short_id': short_id,
                'display_name': c['display_name'], 'source_class': c['source_class'], 'profile': c['profile'],
                'physical_size_provenance': c['physical_size_provenance'], 'opacity_source': c['opacity_source'],
                'tileable': c['tileable'], 'warnings': c['warnings'],
                'preview': {k: v for k, v in preview.items() if k != 'path'}})
        sheet.save(output / page['image'])
        write_json(output / f'page_{number:02d}.json', page)
        manifest['pages'].append(page)
    manifest['generation_seconds'] = round(time.perf_counter() - start, 4)
    manifest['thumbnail_cache_reused'] = sum(t['preview']['reused'] for p in manifest['pages'] for t in p['tiles'])
    write_json(output / 'batch.json', manifest['batch'])
    write_json(output / 'manifest.json', manifest)
    return manifest


def city_audit(index):
    prefix = 'city-be_selective/'
    records = [c for c in index['logical_candidates'] if any(s['relative_path'].lower().startswith(prefix) for s in c['source_files'])]
    usable = [c['stable_id'] for c in records if c['source_class'] not in ('FULL_SURFACE_MATERIAL', 'UNKNOWN')]
    routed = [c['stable_id'] for c in records if c['route'] == 'EAF3']
    unknown = [c['stable_id'] for c in records if c['source_class'] == 'UNKNOWN']
    unsupported = [f['relative_path'] for f in index['source_files'] if f['relative_path'].lower().startswith(prefix) and f['content_class'] == 'UNSUPPORTED']
    unknown_files = [f['relative_path'] for f in index['source_files'] if f['relative_path'].lower().startswith(prefix) and f['content_class'] == 'UNKNOWN']
    if usable:
        recommendation = 'KEEP PARTIALLY' if routed or unknown or unsupported or unknown_files else 'KEEP'
    else:
        recommendation = 'NEEDS MORE PROFILE SUPPORT' if unknown or unsupported or unknown_files else 'REMOVE FROM EAF4'
    archives = index['archives_ignored']['by_top_directory'].get('City-be_selective', {})
    return {'schema_version': 1, 'relative_directory': 'City-be_selective', 'recommendation': recommendation,
            'usable_eaf4_candidates': usable, 'route_to_eaf3': routed, 'unknown_candidates': unknown,
            'unsupported_files': unsupported, 'unknown_files': unknown_files, 'archives_ignored': archives,
            'note': 'No deletion or movement. Surface-like PBR without explicit tileability/localization remains UNKNOWN.'}


def group_candidates(index):
    labels = {'crack': 'cracks', 'spall_damage': 'damage_spall', 'water_mineral': 'water_mineral',
              'grime': 'grime', 'rust_corrosion': 'rust', 'oil_grease': 'oil', 'scrape_scuff': 'scrapes',
              'paint_damage': 'paint', 'paint_remnant': 'paint', 'imperfection': 'imperfections',
              'soot_smoke': 'soot', 'repair_patch': 'repair_patch'}
    groups = defaultdict(list)
    for c in index['logical_candidates']:
        if c['route'] == 'EAF3':
            group = 'route_to_eaf3'
        elif c['profile'] == 'UNREAL_EXTRACTED_ATLAS_PROFILE':
            group = 'unreal_extracted'
        elif c['source_class'] == 'UNKNOWN':
            group = 'unknown'
        else:
            group = labels.get(c['suggested_family'], 'other')
        groups[group].append(c)
        if c['warnings']:
            groups['warnings'].append(c)
        if c['relative_group'].lower().startswith('city-be_selective/'):
            groups['city_audit'].append(c)
            if c['source_class'] not in ('UNKNOWN', 'FULL_SURFACE_MATERIAL'):
                groups['city_usable'].append(c)
    return dict(sorted(groups.items()))


def build_grouped(repository, index, output, page_size=16):
    start = time.perf_counter()
    output = checked_output(repository, output)
    groups = {}
    for group, candidates in group_candidates(index).items():
        manifest = build_sheets(repository, index, candidates, output / group, output / 'thumbnails', page_size, group)
        groups[group] = {'candidate_count': len(candidates), 'pages': len(manifest['pages']),
                         'manifest': group + '/manifest.json', 'generation_seconds': manifest['generation_seconds'],
                         'thumbnail_cache_reused': manifest['thumbnail_cache_reused']}
        print(f"{group}: {len(candidates)} candidates, {len(manifest['pages'])} pages", flush=True)
    audit = city_audit(index)
    write_json(output / 'city_be_selective_audit.json', audit)
    (output / 'city_be_selective_audit.txt').write_text(audit['recommendation'] + '\n' + json.dumps(audit, indent=2) + '\n', encoding='utf-8')
    unreal = {'families': [f for f in index['source_families'] if f['profile'] == 'UNREAL_EXTRACTED_ATLAS_PROFILE'],
              'logical_entries': [c for c in index['logical_candidates'] if c['profile'] == 'UNREAL_EXTRACTED_ATLAS_PROFILE']}
    write_json(output / 'unreal_atlas_summary.json', unreal)
    result = {'groups': groups, 'generation_seconds': round(time.perf_counter() - start, 4),
              'thumbnail_cache_reused': sum(g['thumbnail_cache_reused'] for g in groups.values())}
    write_json(output / 'triage_manifest.json', result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--index', default=str(INDEX_PATH))
    parser.add_argument('--diff', default=str(DIFF_PATH))
    parser.add_argument('--batch')
    parser.add_argument('--grouped', action='store_true')
    parser.add_argument('--output', default=str(REPORT_DIR / 'triage'))
    parser.add_argument('--page-size', type=int, default=16)
    add_filters(parser)
    args = parser.parse_args()
    try:
        index = load_index(report_path(args.index))
        repository, output = load_repository(), report_path(args.output)
        filters = filter_arguments(args)
        if args.grouped:
            if args.batch or any(v is not None for v in filters.values()):
                raise ValueError('Grouped mode cannot combine with a batch or filters')
            result = build_grouped(repository, index, output, args.page_size)
        else:
            if args.batch:
                if any(v is not None for v in filters.values()):
                    raise ValueError('Choose batch or filters')
                selected = select_batch(index, json.loads(report_path(args.batch).read_text(encoding='utf-8')))
            else:
                diff = json.loads(report_path(args.diff).read_text(encoding='utf-8')) if args.status else None
                selected = query(index, diff=diff, **filters)
            result = build_sheets(repository, index, selected, output, REPORT_DIR / 'thumbnails', args.page_size)
        print(f"Generated in {result['generation_seconds']} seconds; cached previews reused: {result['thumbnail_cache_reused']}")
    except (OSError, ValueError, KeyError) as error:
        parser.exit(1, f'Triage failed: {error}\n')


if __name__ == '__main__':
    main()
