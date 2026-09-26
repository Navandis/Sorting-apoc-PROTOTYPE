import copy
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

from tools.environment_authoring.material_repository.path_guard import Repository
from tools.environment_authoring.material_repository.source_index import scan, diff_indexes, validate_index

HERE = Path(__file__).parent
TOOL = HERE.parent


class ScannerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name) / 'source'
        shutil.copytree(HERE / 'fixtures', self.root)
        self.index = scan(Repository(self.root))

    def candidate(self, stem, package='kb3d_mixed'):
        return next(c for c in self.index['material_candidates'] if c['display_name'] == stem and c['package_id'] == package)

    def test_positive_evidence_and_mixed_classification(self):
        self.assertEqual(len(self.index['packages']), 2)
        self.assertEqual(len(self.index['material_candidates']), 5)
        self.assertEqual(self.candidate('Concrete')['detection_evidence'], 'both')
        self.assertEqual(self.candidate('Metal')['detection_evidence'], 'texture_set')
        self.assertEqual(self.candidate('DescriptorOnly')['detection_evidence'], 'descriptor')
        counts = self.index['content_summary']
        for kind, expected in [('MODEL', 1), ('SCENE_OR_GEOMETRY', 2), ('DOCUMENTATION', 1),
                               ('IMAGE_PREVIEW', 1), ('METADATA', 1), ('UNKNOWN', 3)]:
            self.assertEqual(counts[kind], expected, kind)
        self.assertNotIn('Geometry', json.dumps(self.candidate('Concrete')))

    def test_resolutions_channels_and_unsupported(self):
        c = self.candidate('Concrete', 'kb3d_alpha')
        self.assertEqual(c['available_resolutions'], ['1K', '2K', '4K'])
        self.assertEqual(len(c['maps_by_resolution']['2K']['normal']), 1)
        self.assertEqual(c['channel_states_by_resolution']['2K']['ao'], 'MISSING')
        metal = self.candidate('Metal')
        self.assertEqual(metal['channel_states_by_resolution']['2K']['packed'], 'UNSUPPORTED')
        self.assertTrue(any('unknown' in w for w in metal['warnings']))
        self.assertEqual(self.candidate('Brick')['channel_states_by_resolution']['2K']['height'], 'OPTIONAL')

    def test_stable_ids_portable_and_distinct(self):
        first = self.candidate('Concrete', 'kb3d_alpha')
        second = self.candidate('Concrete')
        self.assertEqual(first['stable_id'], 'kitbash:kb3d_alpha@1.0.0:Concrete')
        self.assertNotEqual(first['stable_id'], second['stable_id'])
        migrated = self.root.with_name('migrated')
        shutil.copytree(self.root, migrated)
        other = scan(Repository(migrated))
        self.assertEqual(self.index['material_candidates'], other['material_candidates'])
        self.assertNotIn(str(self.root), json.dumps(self.index['material_candidates']))

    def test_duplicate_ids_rejected(self):
        broken = copy.deepcopy(self.index)
        broken['material_candidates'].append(broken['material_candidates'][0])
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            validate_index(broken)

    def test_same_stem_separate_groups_not_merged(self):
        base = self.root / 'kb3d_alpha/1.0.0'
        for group in ['A', 'B']:
            folder = base / f'Textures/{group}/png2k'
            folder.mkdir(parents=True)
            for channel in ['basecolor', 'normal']:
                shutil.copy2(base / f'Textures/png2k/Concrete_{channel}.png', folder / f'Concrete_{channel}.png')
        candidates = scan(Repository(self.root))['material_candidates']
        ids = [c['stable_id'] for c in candidates if c['package_id'] == 'kb3d_alpha']
        self.assertEqual(len(ids), 3)
        self.assertEqual(len(set(ids)), 3)
        self.assertIn('kitbash:kb3d_alpha@1.0.0:Concrete', ids)

    def test_duplicate_channel_ambiguous(self):
        folder = self.root / 'kb3d_alpha/1.0.0/Textures/png2k'
        shutil.copy2(folder / 'Concrete_basecolor.png', folder / 'Concrete_albedo.png')
        c = next(c for c in scan(Repository(self.root))['material_candidates'] if c['package_id'] == 'kb3d_alpha')
        self.assertEqual(c['channel_states_by_resolution']['2K']['basecolor'], 'AMBIGUOUS')

    def test_fingerprints_and_incremental_diff(self):
        same = scan(Repository(self.root))
        diff = diff_indexes(self.index, same)
        self.assertEqual(len(diff['material_candidates']['unchanged']), 5)
        texture = self.root / 'kb3d_alpha/1.0.0/Textures/png2k/Concrete_normal.png'
        texture.write_bytes(texture.read_bytes() + b'changed')
        descriptor = self.root / 'kb3d_mixed/2.0.0/Materials/DescriptorOnly/DescriptorOnly.usda'
        descriptor.unlink()
        new_descriptor = descriptor.with_name('New.usda')
        new_descriptor.parent.mkdir(exist_ok=True)
        # A known descriptor convention requires the matching group name.
        new_descriptor = new_descriptor.parent.parent / 'New/New.usda'
        new_descriptor.parent.mkdir()
        new_descriptor.write_text('#usda 1.0\ndef Material "New" {}')
        current = scan(Repository(self.root))
        diff = diff_indexes(self.index, current)
        self.assertEqual(diff['material_candidates']['changed'], ['kitbash:kb3d_alpha@1.0.0:Concrete'])
        self.assertEqual(diff['material_candidates']['removed'], ['kitbash:kb3d_mixed@2.0.0:DescriptorOnly'])
        self.assertEqual(diff['material_candidates']['new'], ['kitbash:kb3d_mixed@2.0.0:New'])
        self.assertEqual(len(diff['packages']['changed']), 2)

    def test_no_production_root_or_config_override(self):
        for script in ['scan_repository.py', 'build_triage_sheets.py']:
            for flag in ['--root', '--config']:
                result = subprocess.run([sys.executable, str(TOOL / script), flag, str(self.root)], capture_output=True, text=True)
                self.assertEqual(result.returncode, 2)
                self.assertIn('unrecognized arguments', result.stderr)

    def test_texture_set_needs_companion_at_same_resolution(self):
        source = self.root / 'kb3d_mixed/2.0.0/Textures/png2k/Lonely_basecolor.png'
        target = source.parent.parent / 'png4k/Lonely_normal.png'
        target.parent.mkdir()
        shutil.copy2(source, target)
        names = [c['display_name'] for c in scan(Repository(self.root))['material_candidates']]
        self.assertNotIn('Lonely', names)

    def test_package_new_removed_and_descriptor_context(self):
        shutil.rmtree(self.root / 'kb3d_alpha')
        empty = self.root / 'kb3d_empty/3.0.0'
        empty.mkdir(parents=True)
        wrong = self.root / 'kb3d_mixed/2.0.0/Materials/Concrete/geo.usd'
        wrong.write_text('#usda 1.0\ndef Mesh "Geometry" {}')
        updated = scan(Repository(self.root))
        diff = diff_indexes(self.index, updated)
        self.assertEqual(diff['packages']['new'], ['kb3d_empty@3.0.0'])
        self.assertEqual(diff['packages']['removed'], ['kb3d_alpha@1.0.0'])
        self.assertEqual(updated['content_summary']['SCENE_OR_GEOMETRY'], 3)
        self.assertEqual(len(updated['material_candidates']), 4)

    def test_atlas_warning_uses_material_name_not_package_code(self):
        base = self.root / 'kb3d_mixed/2.0.0/Materials'
        for stem in ['KB3D_ATL_Brick', 'KB3D_SDM_ATLSportA', 'KB3D_API_KitchenWareAtlas']:
            folder = base / stem
            folder.mkdir()
            (folder / (stem + '.usd')).write_text('#usda 1.0\ndef Material "' + stem + '" {}')
        by_name = {c['display_name']: c for c in scan(Repository(self.root))['material_candidates']}
        self.assertFalse(any('tileability' in w for w in by_name['KB3D_ATL_Brick']['warnings']))
        for stem in ['KB3D_SDM_ATLSportA', 'KB3D_API_KitchenWareAtlas']:
            self.assertTrue(any('tileability' in w for w in by_name[stem]['warnings']))


if __name__ == '__main__':
    unittest.main()
