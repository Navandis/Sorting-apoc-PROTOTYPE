"""Explicit one-shot scalar-library staging; never edits the approval authority."""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image
from tools.environment_authoring.wear_repository.path_guard import PROJECT_ROOT, load_repository
from tools.environment_authoring.wear_repository.source_index import load_index
from tools.environment_authoring.wear_catalog.workflow import fingerprint_candidate, stage_candidate

LIBRARY = Path('environment_authoring/wear/imperfection_experiments')
CACHE = Path('assets/environment/wear/imperfection_experiments_cache')
EXPECTED = set('dust_uh4qbeic dust_uh4qbflc dust_uh4rdfvc grain_sc2nbisc grunge_tedwdiic grunge_tedxadjc grunge_tjnncdwc grunge_tjvibebc grunge_uh4uaawc grungy_surface_slnnecvc leakage_sl3ace3c scratched_metal_vdekebbc stains_ulttebjc stains_ultwabqc stains_ultwaekc wipe_marks_uh4scioc'.split())


def audit(repository, index, catalog):
    sources = sorted((c for c in index['logical_candidates'] if c['source_class'] == 'IMPERFECTION_MASK' and c['stable_id'].split(':')[2] in EXPECTED), key=lambda c:c['stable_id'])
    if {c['stable_id'].split(':')[2] for c in sources} != EXPECTED or len(sources) != 16:
        raise ValueError('Source index must contain exactly the 16 triaged identities; rescan the configured repository')
    rows = []
    for c in sources:
        for sig in c['source_files']:
            stat = repository.stat(sig['relative_path'])
            if stat.st_size != sig['size'] or stat.st_mtime_ns != sig['mtime_ns']:
                raise ValueError('Stale source index: ' + sig['relative_path'])
        facts = fingerprint_candidate(repository, c, '1K')
        channel = 'opacity' if 'opacity' in facts['maps'] else 'roughness'
        m = facts['maps'][channel]
        with repository.open(m['source_relative']) as stream:
            image = Image.open(stream)
            image.load()
            if max(image.size) > 1024 or min(image.size) < 1:
                raise ValueError('Unexpected 1K dimensions')
            pixels = list(image.size)
        slug = c['stable_id'].split(':')[2]
        rows.append(dict(stable_id=c['stable_id'], slug=slug, name=c['display_name'],
                         channel=channel, sampled_component='red', selected_resolution='1K', pixels=pixels,
                         source_relative=m['source_relative'], sha256=m['sha256'],
                         source_fingerprint=facts['source_fingerprint'], source_maps=facts['maps'],
                         provenance=c['physical_size_provenance'], physical_size_estimate_m=[c['source_physical_width_m'],c['source_physical_height_m']],
                         available_resolutions=c['available_resolutions'],
                         status_at_audit=next((r['effective_status'] for r in catalog['wear'] if r['source_stable_id']==c['stable_id']), 'UNREVIEWED'),
                         texture_path='res://' + (CACHE / ('eaf4b_' + hashlib.sha256(c['stable_id'].encode()).hexdigest()[:24]) / '1k' / (channel + Path(m['source_relative']).suffix.lower())).as_posix(),
                         blocker=''))
    return sources, rows


def wrapper(row):
    return ('[gd_scene load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="res://environment_authoring/wear/imperfection_experiments/imperfection_audition.gd" id="1"]\n\n'
            '[node name="Experimental' + row['slug'].title().replace('_','') + '" type="Node3D"]\n'
            'script = ExtResource("1")\nmask_source = "' + row['name'] + ' (' + row['slug'] + ') | ' + row['stable_id'] + '"\n')


def build(check=False):
    repository = load_repository()
    index = load_index()
    catalog = json.loads((PROJECT_ROOT / 'data/environment/wear_catalog/catalog.json').read_text(encoding='utf-8'))
    sources, rows = audit(repository, index, catalog) # Complete audit before any output.
    target = PROJECT_ROOT / LIBRARY
    manifest = json.dumps(dict(schema_version=1, purpose='Scalar-layer source coverage; catalog decisions govern approved uses; placements require separate acceptance; no substrate material changes', candidates=rows), indent=2, ensure_ascii=False) + '\n'
    outputs = {target / 'manifest.json':manifest}
    outputs.update({target / 'presets' / (r['slug'] + '.tscn'):wrapper(r) for r in rows})
    obsolete = set((target / 'presets').glob('*.tscn')) - set(outputs)
    if obsolete: raise ValueError('Obsolete experimental wrappers require explicit review: ' + str(obsolete))
    if check:
        for path, text in outputs.items():
            if not path.exists() or path.read_text(encoding='utf-8') != text: raise ValueError('Outdated experimental artifact: ' + str(path))
        for row in rows:
            path = PROJECT_ROOT / row['texture_path'].removeprefix('res://')
            if not path.exists() or hashlib.sha256(path.read_bytes()).hexdigest() != row['sha256']:
                raise ValueError('Missing/changed experimental texture: ' + str(path))
    else:
        for c in sources: stage_candidate(repository, c, '1K', PROJECT_ROOT / CACHE)
        for path, text in outputs.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding='utf-8')
    print('Scalar coverage: 16 genuine 1K sources; no approval decisions written; ' + ('CHECK PASS' if check else 'staged'))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    build(parser.parse_args().check)
