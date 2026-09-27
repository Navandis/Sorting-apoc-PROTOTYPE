"""Breaks caught: bypassed index paths, stale batches/cache, misleading previews."""
import copy
import json
from pathlib import Path
import shutil
import tempfile
import unittest
from PIL import Image

from tools.environment_authoring.wear_repository.path_guard import Repository
from tools.environment_authoring.wear_repository.source_index import scan, diff_indexes
from tools.environment_authoring.wear_repository import query_index as qi
from tools.environment_authoring.wear_repository import build_triage_sheets as sheets
from tools.environment_authoring.wear_repository.tests.make_fixtures import FIXTURES


class TriageTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.root = self.base / 'source'
        shutil.copytree(FIXTURES, self.root)
        self.repo = Repository(self.root)
        self.index = scan(self.repo)
        self.cache = self.base / 'cache'

    def candidate(self, name):
        return next(c for c in self.index['logical_candidates'] if c['display_name'] == name)

    def test_query_conjunction_and_status(self):
        result = qi.query(self.index, source_class='MASKED_DECAL', profile='FAB_DECAL_PROFILE',
                          family='crack', opacity='SEPARATE_MASK', has_normal=True, has_roughness=True,
                          has_alpha_mask=True, tileable='false', resolution='2K', directory='fab_crack')
        self.assertEqual([c['display_name'] for c in result], ['crack'])
        self.assertEqual([c['display_name'] for c in qi.query(self.index, tileable='true', source_class='IMPERFECTION_MASK')], ['grunge'])
        self.assertTrue(qi.query(self.index, warnings='missing_opacity'))
        diff = diff_indexes(None, self.index)
        self.assertEqual(len(qi.query(self.index, diff=diff, status='new')), len(self.index['logical_candidates']))
        self.assertEqual(qi.query(self.index, diff=diff, status='changed'), [])
        diff['current_scan'] = 'stale'
        with self.assertRaises(ValueError):
            qi.query(self.index, diff=diff, status='new')
        self.assertEqual(qi.query(self.index, profile='UNREAL_EXTRACTED_ATLAS_PROFILE', has_alpha_mask=True)[0]['source_class'], 'UNREAL_ATLAS_DECAL_FAMILY')

    def test_batches_only_ids_and_exact_index(self):
        selection = qi.query(self.index, family='imperfection')
        batch = qi.batch_manifest(self.index, selection)
        self.assertEqual(qi.select_batch(self.index, batch), selection)
        for modified in ({**batch, 'source_path': '../outside.png'},
                         {**batch, 'stable_ids': ['../outside.png']},
                         {**batch, 'stable_ids': batch['stable_ids'] * 2},
                         {**batch, 'index_fingerprint': 'stale'}):
            with self.subTest(batch=modified), self.assertRaises(ValueError):
                qi.select_batch(self.index, modified)

    def test_previews_scalar_mask_alpha_and_cache(self):
        grunge = sheets.thumbnail(self.repo, self.index, self.candidate('grunge'), self.cache)
        self.assertEqual(grunge['channel'], 'roughness')
        self.assertEqual(grunge['resolution'], '1K')
        self.assertFalse(grunge['reused'])
        self.assertTrue(sheets.thumbnail(self.repo, self.index, self.candidate('grunge'), self.cache)['reused'])
        paint = sheets.thumbnail(self.repo, self.index, self.candidate('paint'), self.cache)
        self.assertEqual(paint['opacity_compositing'], 'embedded_alpha')
        crack = sheets.thumbnail(self.repo, self.index, self.candidate('crack'), self.cache)
        self.assertEqual(crack['opacity_compositing'], 'separate_mask')
        with Image.open(paint['path']) as im:
            self.assertEqual(im.size, (256, 256))
            self.assertNotEqual(im.getpixel((32, 128)), im.getpixel((240, 128)))
        a = sheets.thumbnail(self.repo, self.index, self.candidate('MI_A'), self.cache)
        self.assertEqual(a['preview_scope'], 'LOGICAL_ATLAS_REGION')
        b = sheets.thumbnail(self.repo, self.index, self.candidate('MI_B'), self.cache)
        self.assertEqual(b['preview_scope'], 'WHOLE_ATLAS_UNRESOLVED')
        self.assertTrue(b['warning'])

    def test_manipulated_index_and_changed_source_cannot_reuse_cache(self):
        entry = self.candidate('paint')
        sheets.thumbnail(self.repo, self.index, entry, self.cache)
        changed = self.root / 'embedded/paint_1K_BaseColor.tga'
        changed.write_bytes(changed.read_bytes() + b'changed')
        preview = sheets.thumbnail(self.repo, self.index, entry, self.cache)
        self.assertEqual(preview['warning'], 'source_changed_rescan_required')
        for path in ('../../outside.png', str(self.base / 'outside.png'), 'Z:/outside.png'):
            bad = copy.deepcopy(entry)
            bad['maps_by_resolution']['1K']['basecolor'][0]['relative_path'] = path
            self.assertEqual(sheets.thumbnail(self.repo, self.index, bad, self.cache)['warning'], 'unsafe_preview_path_rejected')

    def test_sheets_manifests_and_city_audit(self):
        selected = [self.candidate('grunge'), self.candidate('paint'), self.candidate('MI_B')]
        manifest = sheets.build_sheets(self.repo, self.index, selected, self.base / 'sheets', self.cache, page_size=2)
        self.assertEqual(len(manifest['pages']), 2)
        self.assertEqual({t['stable_id'] for p in manifest['pages'] for t in p['tiles']}, {c['stable_id'] for c in selected})
        self.assertTrue(all((self.base / 'sheets' / p['image']).exists() for p in manifest['pages']))
        city = sheets.city_audit(self.index)
        self.assertEqual(city['recommendation'], 'KEEP PARTIALLY')
        self.assertEqual(len(city['usable_eaf4_candidates']), 1)
        self.assertEqual(len(city['route_to_eaf3']), 1)
        self.assertEqual(len(city['unsupported_files']), 1)
        self.assertEqual(city['archives_ignored']['.zip'], 1)
        groups = sheets.group_candidates(self.index)
        self.assertIn('imperfections', groups)
        self.assertIn('route_to_eaf3', groups)
        self.assertIn('city_usable', groups)
        self.assertNotIn(self.candidate('concrete'), groups.get('cracks', []))

    def test_report_paths_cannot_target_source_tree(self):
        with self.assertRaises(ValueError):
            qi.report_path(self.root / 'output.json')


if __name__ == '__main__':
    unittest.main()
