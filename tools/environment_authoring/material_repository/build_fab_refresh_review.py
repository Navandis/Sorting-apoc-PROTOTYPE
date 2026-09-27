"""Package EAF3 source-refresh evidence without source textures or staged cache."""
from collections import Counter
import json
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

from .path_guard import PROJECT_ROOT
from .query_index import query
from .source_index import REPORT_DIR, diff_indexes, load_index, summary_text, write_json

OBJECT_SPECIFIC_WARNING = 'atlas_trim_or_object_specific_name'
STRUCTURAL_FAMILIES = ('concrete', 'cement_render', 'masonry_block', 'brick', 'tile', 'metal')
FAMILIES = ('fab_overview', 'concrete', 'cement_render', 'masonry_block',
            'brick', 'tile', 'metal', 'fab_warnings', 'object_specific_trim')


def main():
    previous = load_index(REPORT_DIR / 'pre_fab_source_index.json')
    current = load_index()
    diff = diff_indexes(previous, current)
    write_json(REPORT_DIR / 'fab_refresh_diff.json', diff)
    (REPORT_DIR / 'fab_refresh_first_summary.txt').write_text(summary_text(current, diff), encoding='utf-8')
    fab = [c for c in current['material_candidates'] if c['stable_id'].startswith('fab:')]
    kitbash = [c for c in current['material_candidates'] if c['stable_id'].startswith('kitbash:')]
    excluded = query(current, warnings=OBJECT_SPECIFIC_WARNING)
    excluded_by_family = {family: len(query(current, family=family, warnings=OBJECT_SPECIFIC_WARNING))
                          for family in STRUCTURAL_FAMILIES}
    stats = {'old_files': previous['total_repository_files'],
             'refreshed_files': current['total_repository_files'],
             'old_kitbash_packages': len(previous['packages']),
             'refreshed_kitbash_packages': len(current['packages']),
             'old_kitbash_candidates': len(previous['material_candidates']),
             'refreshed_kitbash_candidates': len(kitbash),
             'fab_surface_candidates': len(fab),
             'total_material_candidates': len(current['material_candidates']),
             'object_specific_warning_candidates': len(excluded),
             'structural_review_excluded_candidates': sum(excluded_by_family.values()),
             'structural_review_excluded_by_family': excluded_by_family,
             'family_counts': dict(sorted(Counter(c['suggested_family'] for c in current['material_candidates']).items())),
             'fab_family_counts': dict(sorted(Counter(c['suggested_family'] for c in fab).items())),
             'resolution_distribution': dict(sorted(Counter(r for c in current['material_candidates']
                                                         for r in c['available_resolutions']).items())),
             'fab_resolution_distribution': dict(sorted(Counter(r for c in fab
                                                              for r in c['available_resolutions']).items())),
             'candidate_warning_counts': dict(sorted(Counter(w for c in current['material_candidates']
                                                            for w in c['warnings']).items())),
             'scan_seconds': current['scan_seconds']}
    write_json(REPORT_DIR / 'fab_refresh_statistics.json', stats)
    eligibility = ['EAF5 STRUCTURAL SURFACE REVIEW ELIGIBILITY',
                   f'Raw indexed object-specific/trim candidates: {len(excluded)}',
                   f'Excluded from six structural-facing family sheets: {sum(excluded_by_family.values())}',
                   'Excluded by family:']
    eligibility.extend(f'  {family}: {count}' for family, count in excluded_by_family.items())
    eligibility.extend(['Raw source records are retained; this is a review-sheet filter only.',
                        'The object_specific_trim sheet contains all warned candidates separately.'])
    (REPORT_DIR / 'structural_review_eligibility_summary.txt').write_text(
        '\n'.join(eligibility) + '\n', encoding='utf-8')
    old = {c['stable_id']: c for c in previous['material_candidates']}
    now = {c['stable_id']: c for c in current['material_candidates']}
    changed = diff['material_candidate_profiles']['KITBASH_PROFILE_V1']['changed']
    timestamp_only = [identity for identity in changed if
                      {k: v for k, v in old[identity].items() if k not in ('source_files', 'quick_fingerprint')} ==
                      {k: v for k, v in now[identity].items() if k not in ('source_files', 'quick_fingerprint')}
                      and [(f['relative_path'], f['size']) for f in old[identity]['source_files']] ==
                      [(f['relative_path'], f['size']) for f in now[identity]['source_files']]]
    lines = ['EAF3 FAB SOURCE REFRESH DIFF',
             f"New KitBash candidates: {len(diff['material_candidate_profiles']['KITBASH_PROFILE_V1']['new'])}",
             f"Newly recognized FAB surfaces: {len(diff['material_candidate_profiles']['FAB_SURFACE_PROFILE_V1']['new'])}",
             f"Unchanged existing KitBash candidates: {len(diff['material_candidate_profiles']['KITBASH_PROFILE_V1']['unchanged'])}",
             f"Changed existing KitBash candidate signatures: {len(changed)}",
             f"Of those, descriptor timestamp only with same recorded sizes and interpretation: {len(timestamp_only)}",
             'Historical byte hashes for those descriptors are unavailable; byte equality is unverified.',
             'Changed IDs:'] + [f'  {identity}' for identity in changed]
    (REPORT_DIR / 'fab_refresh_diff_summary.txt').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    validation = PROJECT_ROOT / 'docs/testing/environment-authoring-eaf3-fab-profile-refresh-validation.md'
    if not validation.is_file():
        raise FileNotFoundError(validation)
    archive = REPORT_DIR / 'eaf5_source_refresh_review.zip'
    files = [REPORT_DIR / 'fab_refresh_first_summary.txt', REPORT_DIR / 'scan_summary.txt',
             REPORT_DIR / 'fab_refresh_statistics.json', REPORT_DIR / 'fab_refresh_diff_summary.txt',
             REPORT_DIR / 'structural_review_eligibility_summary.txt',
             REPORT_DIR / 'fab_staging_smoke/summary.txt', validation]
    for family in FAMILIES:
        folder = REPORT_DIR / 'fab_refresh' / family
        manifest = json.loads((folder / 'manifest.json').read_text(encoding='utf-8'))
        if family in STRUCTURAL_FAMILIES:
            expected = query(current, family=family, exclude_warnings=[OBJECT_SPECIFIC_WARNING])
        elif family == 'fab_overview':
            expected = query(current, package='fab')
        elif family == 'fab_warnings':
            expected = query(current, package='fab', warnings='any')
        else:
            expected = excluded
        if manifest['batch']['stable_ids'] != [candidate['stable_id'] for candidate in expected]:
            raise ValueError(f'Sheet selection violates EAF5 review policy: {family}')
        if len(manifest['pages']) != (len(manifest['batch']['stable_ids']) + 23) // 24:
            raise ValueError(f'Incomplete sheet pagination: {family}')
        if sum(len(page['tiles']) for page in manifest['pages']) != len(manifest['batch']['stable_ids']):
            raise ValueError(f'Incomplete sheet tiles: {family}')
        files.extend((folder / 'manifest.json', folder / 'batch.json'))
        for page in manifest['pages']:
            image = folder / page['image']
            page_json = folder / f"page_{page['page']:02d}.json"
            if not image.is_file() or not page_json.is_file():
                raise FileNotFoundError(f'Missing declared sheet page: {family} / {page["page"]}')
            files.extend((image, page_json))
    cement_atlas = 'kitbash:kb3d_constructionzone@7.0.3:KB3D_CSZ_CementBagsAtlas'
    indexed = {candidate['stable_id']: candidate for candidate in current['material_candidates']}
    if (cement_atlas not in indexed or
            not any(OBJECT_SPECIFIC_WARNING in warning for warning in indexed[cement_atlas]['warnings']) or
            cement_atlas not in {candidate['stable_id'] for candidate in excluded}):
        raise ValueError('CementBagsAtlas source/index warning proof failed')
    with ZipFile(archive, 'w', compression=ZIP_DEFLATED, compresslevel=3) as bundle:
        for path in files:
            if path.suffix not in ('.png', '.json', '.txt', '.md'):
                raise ValueError(f'Unexpected review file type: {path}')
            label = path.relative_to(PROJECT_ROOT).as_posix()
            bundle.write(path, label)
    with ZipFile(archive) as bundle:
        if bundle.testzip() is not None:
            raise ValueError('Review ZIP integrity failed')
        print(f'{archive}: {len(bundle.namelist())} files; {archive.stat().st_size} bytes')


if __name__ == '__main__':
    main()
