import copy
import tempfile
from PIL import Image
from tools.environment_authoring.wear_catalog.build_imperfection_experiments import audit
from tools.environment_authoring.wear_repository.path_guard import Repository
import hashlib
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[4]
LIBRARY = ROOT / 'environment_authoring/wear/imperfection_experiments'
EXPECTED = set('dust_uh4qbeic dust_uh4qbflc dust_uh4rdfvc grain_sc2nbisc grunge_tedwdiic grunge_tedxadjc grunge_tjnncdwc grunge_tjvibebc grunge_uh4uaawc grungy_surface_slnnecvc leakage_sl3ace3c scratched_metal_vdekebbc stains_ulttebjc stains_ultwabqc stains_ultwaekc wipe_marks_uh4scioc'.split())

class ImperfectionLibraryTests(unittest.TestCase):
    def test_actual_dependencies_and_all_sixteen_unique_bindings(self):
        self.assertTrue((LIBRARY / 'manifest.json').exists(), 'experimental library missing')
        data = json.loads((LIBRARY / 'manifest.json').read_text(encoding='utf-8'))
        self.assertEqual({r['slug'] for r in data['candidates']}, EXPECTED)
        self.assertEqual(len({r['stable_id'] for r in data['candidates']}), 16)
        for r in data['candidates']:
            with self.subTest(source=r['slug']):
                self.assertEqual(r['selected_resolution'], '1K')
                self.assertIn(r['channel'], ('opacity', 'roughness'))
                self.assertEqual(r['sampled_component'], 'red')
                self.assertEqual(r['pixels'], [1024, 1024])
                self.assertEqual(len(r['source_fingerprint']), 64)
                texture = ROOT / r['texture_path'].removeprefix('res://')
                self.assertEqual(hashlib.sha256(texture.read_bytes()).hexdigest(), r['sha256'])
                self.assertNotIn('triage', str(texture))
                wrapper = (LIBRARY / 'presets' / (r['slug'] + '.tscn')).read_text(encoding='utf-8')
                self.assertIn(r['stable_id'], wrapper)
                self.assertIn('imperfection_audition.gd', wrapper)
    def test_library_cannot_become_approval_authority(self):
        self.assertTrue((LIBRARY / 'manifest.json').exists(), 'experimental library missing')
        rows = json.loads((LIBRARY / 'manifest.json').read_text(encoding='utf-8'))['candidates']
        statuses = {r['slug']:r['status_at_audit'] for r in rows}
        self.assertEqual(statuses['grunge_tedxadjc'], 'APPROVED')
        self.assertEqual(statuses['scratched_metal_vdekebbc'], 'DEFERRED')
        self.assertEqual(sum(s=='UNREVIEWED' for s in statuses.values()), 14)
        self.assertFalse(any('approval' in r for r in rows))

class SourceAuditFailureTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        folder = Path(self.tmp.name)
        self.repo = Repository(folder)
        candidates = []
        for slug in sorted(EXPECTED):
            path = folder / (slug + '.png')
            Image.new('RGB', (2,2), (80,80,80)).save(path)
            stat = path.stat()
            candidates.append(dict(stable_id='eaf4:IMPERFECTION_TEXTURE_PROFILE:' + slug + ':' + slug.split('_')[-1],
                                   source_class='IMPERFECTION_MASK',display_name=slug,profile='IMPERFECTION_TEXTURE_PROFILE',
                                   available_resolutions=['1K'],maps_by_resolution={'1K':{'roughness':[{'relative_path':path.name}]}},
                                   source_files=[{'relative_path':path.name,'size':stat.st_size,'mtime_ns':stat.st_mtime_ns}],
                                   physical_size_provenance={'status':'SYNTHETIC_TEST'},source_physical_width_m=1,source_physical_height_m=1))
        self.index = {'logical_candidates':candidates}
        self.catalog = {'wear':[]}
    def test_missing_original_blocks_without_substitution(self):
        (self.repo.root / self.index['logical_candidates'][0]['source_files'][0]['relative_path']).unlink()
        with self.assertRaises(FileNotFoundError): audit(self.repo,self.index,self.catalog)
    def test_changed_index_signature_requires_rescan(self):
        self.index['logical_candidates'][0]['source_files'][0]['size'] += 1
        with self.assertRaisesRegex(ValueError,'Stale source index'): audit(self.repo,self.index,self.catalog)
    def test_ambiguous_scalar_channel_blocks_instead_of_guessing(self):
        c = self.index['logical_candidates'][0]
        c['maps_by_resolution']['1K']['roughness'].append(copy.deepcopy(c['maps_by_resolution']['1K']['roughness'][0]))
        with self.assertRaisesRegex(ValueError,'Ambiguous indexed map'): audit(self.repo,self.index,self.catalog)
    def test_no_resolution_fallback(self):
        self.index['logical_candidates'][0]['available_resolutions'] = ['8K']
        with self.assertRaisesRegex(ValueError,'Resolution unavailable'): audit(self.repo,self.index,self.catalog)
    def test_selected_channel_hash_and_strong_anchor_follow_real_bytes(self):
        _,before = audit(self.repo,self.index,self.catalog)
        c = self.index['logical_candidates'][0]
        path = self.repo.root / c['source_files'][0]['relative_path']
        Image.new('RGB',(2,2),(120,120,120)).save(path)
        stat = path.stat()
        c['source_files'][0].update(size=stat.st_size,mtime_ns=stat.st_mtime_ns)
        _,after = audit(self.repo,self.index,self.catalog)
        self.assertNotEqual(before[0]['sha256'],after[0]['sha256'])
        self.assertNotEqual(before[0]['source_fingerprint'],after[0]['source_fingerprint'])

if __name__ == '__main__': unittest.main()
