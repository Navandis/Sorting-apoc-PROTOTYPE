"""Original, tiny FAB fixtures; no commercial source bytes."""
import json
from pathlib import Path
import shutil
import tempfile
import unittest

from PIL import Image

from tools.environment_authoring.material_repository.path_guard import Repository
from tools.environment_authoring.material_repository.source_index import scan, diff_indexes
from tools.environment_authoring.material_repository.query_index import query
from tools.environment_authoring.material_catalog import catalog


class FabSurfaceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'source'
        self.root.mkdir()

    def asset(self, directory='weathered_concrete_ab12_2k', asset_id='ab12', kind='surface',
              resolution='2K', channels=('BaseColor', 'Normal', 'Roughness'), extra=()):
        folder = self.root / 'FAB' / directory
        folder.mkdir(parents=True, exist_ok=True)
        metadata = {'id': asset_id, 'name': 'Weathered Concrete Wall',
                    'semanticTags': {'asset_type': kind},
                    'assetCategories': {'surface': {'concrete': {}}},
                    'maps': [{'uri': f'{asset_id}_8K_BaseColor.exr'}],
                    'meta': [{'key': 'tileable', 'value': True},
                             {'key': 'scanArea', 'value': '2x3 m'}]}
        (folder / f'{asset_id}.json').write_text(json.dumps(metadata), encoding='utf-8')
        for channel in (*channels, *extra):
            Image.new('RGB', (2, 2), (48, 96, 144)).save(
                folder / f'Weathered_Concrete_{asset_id}_{resolution}_{channel}.png')
        return folder

    def test_surface_facts_query_staging_and_portability(self):
        self.asset(extra=('Specular', 'Cavity', 'Gloss'))
        index = scan(Repository(self.root))
        candidate, = query(index, package='fab', required_channels=('basecolor', 'normal', 'roughness'))
        self.assertEqual(candidate['stable_id'], 'fab:ab12')
        self.assertEqual(candidate['available_resolutions'], ['2K'])
        self.assertEqual(candidate['suggested_family'], 'concrete')
        self.assertTrue(candidate['tileable'])
        self.assertEqual(candidate['source_physical_size']['width_m'], 2.0)
        self.assertEqual(candidate['channel_states_by_resolution']['2K']['specular'], 'UNSUPPORTED')
        self.assertNotIn('8K', candidate['available_resolutions'])
        self.assertIn('normal_convention_unverified', candidate['warnings'])
        batch = catalog.make_batch('fab_smoke_01', index, [candidate['stable_id']])
        self.assertEqual(catalog.validate_batch(batch, index), [candidate])
        staged = catalog.stage_candidate(Repository(self.root), candidate, '2K', self.root.parent / 'cache')
        self.assertEqual(set(staged['maps']), {'basecolor', 'normal', 'roughness'})
        self.assertIn('source_fingerprint', staged)
        self.assertIn('Weathered Concrete Wall', catalog.spec_text(staged, candidate))
        migrated = self.root.with_name('migrated')
        shutil.copytree(self.root, migrated)
        self.assertEqual(scan(Repository(migrated))['material_candidates'][0]['stable_id'], 'fab:ab12')

    def test_resolution_variant_keeps_id_and_diff_is_changed_only(self):
        self.asset()
        before = scan(Repository(self.root))
        self.asset(directory='weathered_concrete_ab12_4k', resolution='4K')
        after = scan(Repository(self.root))
        self.assertEqual([c['stable_id'] for c in after['material_candidates']], ['fab:ab12'])
        self.assertEqual(after['material_candidates'][0]['available_resolutions'], ['2K', '4K'])
        self.assertEqual(diff_indexes(before, after)['material_candidates']['changed'], ['fab:ab12'])
        self.assertEqual(diff_indexes(before, after)['material_candidate_profiles']
                         ['FAB_SURFACE_PROFILE_V1']['changed'], ['fab:ab12'])

    def test_non_surface_types_are_excluded(self):
        for kind in ('decal', 'imperfection', '3d', 'unknown'):
            self.asset(directory=f'{kind}_asset_2k', asset_id=kind, kind=kind)
        self.assertEqual(scan(Repository(self.root))['material_candidates'], [])

    def test_duplicate_asset_id_in_other_logical_group_rejected(self):
        self.asset()
        self.asset(directory='other_concrete_ab12_2k')
        with self.assertRaisesRegex(ValueError, 'Duplicate FAB asset ID'):
            scan(Repository(self.root))

    def test_duplicate_asset_id_at_same_resolution_rejected(self):
        self.asset()
        self.asset(directory='weathered_concrete_ab12__2k')
        with self.assertRaisesRegex(ValueError, 'Duplicate FAB asset ID and resolution'):
            scan(Repository(self.root))

    def test_explicit_normal_variants_prefer_opengl(self):
        self.asset(channels=('BaseColor', 'Roughness', 'Normal_DirectX', 'Normal_OpenGL'))
        candidate, = scan(Repository(self.root))['material_candidates']
        normal, = candidate['maps_by_resolution']['2K']['normal']
        self.assertIn('OpenGL', normal['relative_path'])
        self.assertEqual(candidate['normal_conventions_by_resolution']['2K'], 'OPENGL')
        self.assertEqual({v['convention'] for v in candidate['normal_variants_by_resolution']['2K']},
                         {'OPENGL', 'DIRECTX'})

    def test_foreign_maps_in_asset_folder_are_not_assigned(self):
        folder = self.asset(channels=())
        for channel in ('BaseColor', 'Normal', 'Roughness'):
            Image.new('RGB', (2, 2)).save(folder / f'Other_zz99_2K_{channel}.png')
        self.assertEqual(scan(Repository(self.root))['material_candidates'], [])

    def test_partial_resolution_is_recorded_but_not_stageable(self):
        self.asset()
        self.asset(directory='weathered_concrete_ab12_4k', resolution='4K', channels=('BaseColor',))
        candidate, = scan(Repository(self.root))['material_candidates']
        self.assertEqual(candidate['available_resolutions'], ['2K'])
        self.assertIn('4K', candidate['maps_by_resolution'])
        self.assertIn('incomplete_resolution:4K', candidate['warnings'])
        with self.assertRaisesRegex(ValueError, 'No indexed fallback'):
            catalog.choose_resolution(candidate, '4K')


if __name__ == '__main__':
    unittest.main()
