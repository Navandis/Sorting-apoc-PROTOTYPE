"""Technical FAB staging check against the configured EAF3 source root."""
import json

from tools.environment_authoring.material_catalog import catalog
from tools.environment_authoring.material_repository.path_guard import load_repository, PROJECT_ROOT
from tools.environment_authoring.material_repository.source_index import load_index


def main():
    index = load_index()
    repo = load_repository()
    ids = ['fab:pkngj0', 'fab:vi4idbm', 'fab:pjBkT0']
    batch = catalog.make_batch('fab_technical_smoke', index, ids,
                               notes='Technical staging only; no material approval.')
    records = catalog.validate_batch(batch, index)
    output = PROJECT_ROOT / 'reports/environment_material_catalog/fab_staging_smoke'
    output.mkdir(parents=True, exist_ok=True)
    summary = []
    for candidate in records:
        staged = catalog.stage_candidate(repo, candidate, '2K',
                                         PROJECT_ROOT / 'assets/environment/materials/kitbash_cache')
        spec = catalog.spec_text(staged, candidate)
        assert 'EnvironmentSurfaceMaterialSpec' in spec
        assert staged['actual_review_resolution'] in candidate['available_resolutions']
        assert set(staged['maps']) >= {'basecolor', 'normal', 'roughness'}
        summary.append({'stable_id': candidate['stable_id'],
                        'actual_resolution': staged['actual_review_resolution'],
                        'staged_channels': sorted(staged['maps']),
                        'strong_fingerprint': staged['source_fingerprint'],
                        'spec_generated': True, 'warnings': candidate['warnings']})
    (output / 'batch.json').write_text(json.dumps(batch, indent=2) + '\n', encoding='utf-8')
    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    text = '\n'.join(
        f"{row['stable_id']}: {row['actual_resolution']}, maps={','.join(row['staged_channels'])}, "
        f"fingerprint={row['strong_fingerprint']}, EnvironmentSurfaceMaterialSpec generated"
        for row in summary) + '\n'
    (output / 'summary.txt').write_text(text, encoding='utf-8')
    print(text)


if __name__ == '__main__':
    main()
