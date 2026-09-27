"""Contract tests: source facts must remain conservative, portable and grouped."""
import copy
import json
from pathlib import Path
import shutil
import tempfile
import unittest
from PIL import Image

from tools.environment_authoring.wear_repository.path_guard import Repository, BoundaryError
from tools.environment_authoring.wear_repository import source_index as si
from tools.environment_authoring.wear_repository import unreal_instance_parser as ue
from tools.environment_authoring.wear_repository.tests.make_fixtures import FIXTURES


class IndexTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name) / 'source'
        shutil.copytree(FIXTURES, self.root)
        self.repo = Repository(self.root)
        self.index = si.scan(self.repo)

    def candidate(self, name):
        matches = [c for c in self.index['logical_candidates'] if c['display_name'] == name]
        self.assertEqual(len(matches), 1, [c['stable_id'] for c in matches])
        return matches[0]

    def test_profiles_classes_and_resolution_grouping(self):
        expected = {'crack': 'MASKED_DECAL', 'FloorCrack': 'UNKNOWN', 'grunge': 'IMPERFECTION_MASK',
                    'concrete': 'FULL_SURFACE_MATERIAL', 'WallLeak': 'MASKED_DECAL',
                    'paint': 'MASKED_DECAL', 'mark': 'MASKED_DECAL', 'floor': 'UNKNOWN',
                    'chipped_wall': 'PHYSICAL_DAMAGE_MODEL', 'repair': 'MATERIAL_PATCH_SOURCE'}
        for name, kind in expected.items():
            with self.subTest(name=name):
                self.assertEqual(self.candidate(name)['source_class'], kind)
        crack = self.candidate('crack')
        self.assertEqual(crack['profile'], 'FAB_DECAL_PROFILE')
        self.assertEqual(crack['available_resolutions'], ['2K', '4K'])
        self.assertEqual(crack['opacity_source'], ['SEPARATE_MASK'])
        self.assertEqual(self.candidate('concrete')['route'], 'EAF3')
        self.assertIsNone(self.candidate('floor')['route'])
        self.assertIn('missing_opacity_evidence', self.candidate('FloorCrack')['warnings'])
        self.assertNotIn('floor_only', json.dumps(self.index))
        self.assertNotIn('wall_only', json.dumps(self.index))

    def test_alpha_facts_do_not_misinterpret_packed_alpha(self):
        paint = self.candidate('paint')
        self.assertEqual(paint['opacity_source'], ['EMBEDDED_ALPHA'])
        self.assertEqual(paint['alpha_stats']['transparent_fraction'], 0.5)
        self.assertEqual(paint['alpha_stats']['partial_alpha_fraction'], 0.25)
        self.assertEqual(paint['alpha_stats']['opaque_fraction'], 0.25)
        packed = self.candidate('floor')
        self.assertNotIn('EMBEDDED_ALPHA', packed['opacity_source'])
        self.assertTrue(packed['maps_by_resolution']['2K']['orm'][0]['has_alpha'])
        mark = self.candidate('mark')
        self.assertIn('packed_unknown:rsmo', mark['maps_by_resolution']['4K'])
        self.assertIn('packed_channel_semantics_unverified:rsmo', mark['warnings'])
        self.assertEqual(len(mark['maps_by_resolution']['4K']['normal']), 2)
        self.assertEqual({m['normal_convention'] for m in mark['maps_by_resolution']['4K']['normal']}, {'OPENGL', 'DIRECTX'})

    def test_physical_size_tileability_and_imperfection(self):
        crack = self.candidate('crack')
        self.assertEqual(crack['source_physical_width_m'], 0.5)
        self.assertEqual(crack['source_physical_height_m'], 1.0)
        self.assertFalse(crack['tileable'])
        grunge = self.candidate('grunge')
        self.assertTrue(grunge['tileable'])
        self.assertEqual(grunge['available_resolutions'], ['1K', '2K', '4K', '8K'])
        self.assertNotIn('missing_basecolor', grunge['warnings'])
        self.assertIsNone(self.candidate('paint')['source_physical_width_m'])

    def test_unreal_families_missing_none_zero_and_manual_region(self):
        a, b, c = (self.candidate(n) for n in ('MI_A', 'MI_B', 'MI_C'))
        self.assertEqual(a['family_id'], b['family_id'])
        family = next(f for f in self.index['source_families'] if f['stable_id'] == a['family_id'])
        self.assertEqual(len(family['atlas_textures']), 1)
        self.assertEqual(len(family['logical_ids']), 3)
        self.assertEqual(a['unreal_instance']['parameters']['Height'], {'recorded': True, 'override': True, 'value': None})
        self.assertEqual(b['unreal_instance']['parameters']['Height']['value'], 0)
        self.assertEqual(a['unreal_instance']['parameters']['OpacityLevel'], {'recorded': False, 'override': None, 'value': None})
        self.assertIn('ATLAS_ALPHA', a['opacity_source'])
        self.assertIn('MATERIAL_SCALAR', b['opacity_source'])
        self.assertEqual(b['unreal_instance']['parameters']['OpacityLevel']['override'], True)
        self.assertEqual(a['atlas_region']['rect'], [0.0, 0.0, 0.5, 1.0])
        self.assertEqual(b['atlas_region_status'], 'NEEDS_MANUAL_METADATA')
        self.assertEqual(c['atlas_region_status'], 'NEEDS_MANUAL_METADATA')
        self.assertIsNone(c['source_physical_height_m'])  # raw Unreal units aren't metres

    def test_archive_bookkeeping_never_content_or_fingerprint(self):
        self.assertEqual(self.index['archives_ignored']['count'], 6)
        self.assertNotIn('FloorCrack.zip', json.dumps(self.index))
        with self.assertRaises(BoundaryError):
            self.repo.open('bookkeeping/FloorCrack.zip').__enter__()
        (self.root / 'bookkeeping/FloorCrack.zip').write_text('changed archive bytes')
        second = si.scan(self.repo)
        diff = si.diff_indexes(self.index, second)
        self.assertFalse(diff['logical_candidates']['changed'])
        self.assertFalse(diff['source_families']['changed'])

    def test_stable_ids_migration_diff_and_duplicate_rejection(self):
        moved = self.root.with_name('moved')
        shutil.copytree(self.root, moved)
        second = si.scan(Repository(moved))
        self.assertEqual([c['stable_id'] for c in self.index['logical_candidates']], [c['stable_id'] for c in second['logical_candidates']])
        diff = si.diff_indexes(self.index, second)
        self.assertFalse(diff['logical_candidates']['changed'])
        self.assertFalse(diff['source_families']['changed'])
        self.assertNotIn(str(self.root), json.dumps(self.index['logical_candidates']))
        (self.root / 'embedded/paint_1K_Normal.tga').unlink()
        shutil.rmtree(self.root / 'separate')
        third = si.scan(self.repo)
        diff = si.diff_indexes(self.index, third)
        self.assertIn(self.candidate('paint')['stable_id'], diff['logical_candidates']['changed'])
        self.assertIn(self.candidate('mark')['stable_id'], diff['logical_candidates']['removed'])
        bad = copy.deepcopy(self.index)
        bad['logical_candidates'].append(bad['logical_candidates'][0])
        with self.assertRaises(ValueError):
            si.validate_index(bad)

    def test_safe_unreal_association_does_not_follow_metadata_paths(self):
        path = self.root / 'unreal_extracted/leaks/MI_A.txt'
        path.write_text('MI_A\nParent=M_Leaks\nBaseColor=../../../../outside\n')
        current = si.scan(self.repo)
        entry = next(c for c in current['logical_candidates'] if c['display_name'] == 'MI_A')
        self.assertIn('atlas_texture_missing_or_ambiguous', entry['warnings'])

    def test_fab_export_variants_share_one_logical_asset(self):
        extra = self.root / 'grunge_4k_ue_high'
        (extra / 'Textures').mkdir(parents=True)
        shutil.copy2(self.root / 'grunge_8k/grunge.json', extra / 'grunge.json')
        shutil.copy2(self.root / 'grunge_8k/grunge_4K_Roughness.png', extra / 'Textures/T_grunge_4K_MR.png')
        (extra / 'grunge.gltf').write_text('{"asset":{"version":"2.0"}}')
        (extra / 'grunge.bin').write_bytes(b'original placeholder')
        exr = self.root / 'grunge_8k_exr'
        exr.mkdir()
        shutil.copy2(self.root / 'grunge_8k/grunge.json', exr / 'grunge.json')
        (exr / 'grunge_8K_Roughness.exr').write_bytes(b'original unsupported EXR placeholder')
        current = si.scan(self.repo)
        grunge = [c for c in current['logical_candidates'] if c['source_name'] == 'grunge']
        self.assertEqual(len(grunge), 1)
        self.assertEqual(grunge[0]['stable_id'], self.candidate('grunge')['stable_id'])
        self.assertEqual(grunge[0]['available_resolutions'], ['1K', '2K', '4K', '8K'])
        self.assertIn('packed_unknown:mr', grunge[0]['maps_by_resolution']['4K'])
        self.assertTrue(any(s['relative_path'].endswith('.gltf') for s in grunge[0]['source_files']))

    def test_resolution_metadata_conflicts_are_visible(self):
        p = self.root / 'fab_crack_4k/crack.json'
        data = json.loads(p.read_text())
        data['meta'] = [{'key': 'tileable', 'value': True}, {'key': 'scanArea', 'value': '7x8 m'}]
        p.write_text(json.dumps(data))
        current = si.scan(self.repo)
        c = next(c for c in current['logical_candidates'] if c['display_name'] == 'crack')
        self.assertIsNone(c['tileable'])
        self.assertIsNone(c['source_physical_width_m'])
        self.assertIn('conflicting_physical_size_metadata', c['warnings'])
        self.assertIn('conflicting_tileability_metadata', c['warnings'])

    def test_standalone_alpha_and_multiple_color_alpha_evidence(self):
        Image.new('RGBA', (8, 8), (20, 30, 40, 50)).save(self.root / 'unknown/isolated.png')
        Image.new('RGBA', (8, 8), (20, 30, 40, 255)).save(self.root / 'embedded/paint_1K_BaseOpacity.tga')
        current = si.scan(self.repo)
        isolated = next(c for c in current['logical_candidates'] if c['display_name'] == 'isolated')
        paint = next(c for c in current['logical_candidates'] if c['display_name'] == 'paint')
        self.assertEqual(isolated['source_class'], 'MASKED_DECAL')
        self.assertIn('EMBEDDED_ALPHA', paint['opacity_source'])
        self.assertEqual(paint['alpha_stats']['transparent_fraction'], 0.5)

    def test_unknown_metadata_shape_and_bookkeeping_are_conservative(self):
        p = self.root / 'fab_crack_2k/crack.json'
        data = json.loads(p.read_text())
        data['meta'] = None
        p.write_text(json.dumps(data))
        current = si.scan(self.repo)
        self.assertEqual(current['platform_bookkeeping_ignored_count'], 1)
        c = next(c for c in current['logical_candidates'] if c['display_name'] == 'crack')
        self.assertIn('unrecognized_meta_shape', c['warnings'])

    def test_map_vocabulary_is_preserved_without_packed_component_assumptions(self):
        from tools.environment_authoring.wear_repository.profiles.maps import interpret_map
        expected = {'Albedo': 'basecolor', 'Normal': 'normal', 'Roughness': 'roughness',
                    'Metallic': 'metallic', 'AO': 'ao', 'ORM': 'orm', 'Displacement': 'height',
                    'Bump': 'bump', 'Cavity': 'cavity', 'Specular': 'specular', 'Alpha': 'opacity',
                    'Emissive': 'emissive', 'RSMO': 'packed_unknown:rsmo'}
        for suffix, channel in expected.items():
            with self.subTest(suffix=suffix):
                info = interpret_map('group/asset_' + suffix + '_2K.png')
                self.assertEqual(info['channel'], channel)
                self.assertEqual(info['resolution'], '2K')
                self.assertEqual(info['stem'], 'asset')


class ParserTests(unittest.TestCase):
    def test_region_requires_explicit_convention_and_valid_bounds(self):
        data = ue.parse_instance('MI_Test\nParent=M\nBaseColor=T\nSelectX=0.75\nSelectY=0\nCellSizeX=0.5\nCellSizeY=1\nAtlasRegionConvention=normalized_offset_size_top_left\n')
        self.assertEqual(ue.atlas_region(data)['status'], 'NEEDS_MANUAL_METADATA')
        data = ue.parse_instance('MI_Test\nParent=M\nBaseColor=T\nHeight=None\nHeightOverride=true\nOpacityLevel=0\n')
        self.assertEqual(data['parameters']['Height']['value'], None)
        self.assertEqual(data['parameters']['OpacityLevel']['value'], 0)
        self.assertFalse(data['parameters']['Length']['recorded'])


if __name__ == '__main__':
    unittest.main()
