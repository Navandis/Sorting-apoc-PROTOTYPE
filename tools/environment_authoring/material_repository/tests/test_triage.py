import copy
from pathlib import Path
import shutil
import tempfile
import unittest

from PIL import Image
from tools.environment_authoring.material_repository.path_guard import Repository, BoundaryError
from tools.environment_authoring.material_repository.source_index import scan, diff_indexes
from tools.environment_authoring.material_repository.query_index import query, batch_manifest, select_batch
from tools.environment_authoring.material_repository.build_triage_sheets import thumbnail, build_sheets


class TriageTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        root = self.base / 'source'
        shutil.copytree(Path(__file__).with_name('fixtures'), root)
        self.repo = Repository(root)
        self.index = scan(self.repo)
        self.concrete = next(c for c in self.index['material_candidates'] if c['package_id'] == 'kb3d_alpha')

    def test_query_filters_and_order(self):
        result = query(self.index, package='alpha', name='concr', family='concrete', resolution='4k', required_channels=['normal'])
        self.assertEqual([c['stable_id'] for c in result], ['kitbash:kb3d_alpha@1.0.0:Concrete'])
        self.assertEqual(len(query(self.index, warnings='none')), 0)
        self.assertEqual(len(query(self.index, warnings='unsupported')), 1)
        self.assertEqual(query(self.index, resolution='8K'), [])
        self.assertEqual(len(query(self.index, required_channels=['ao', 'height'])), 1)
        ids = [c['stable_id'] for c in query(self.index)]
        self.assertEqual(ids, sorted(ids))

    def test_status_query_requires_matching_diff(self):
        diff = diff_indexes(None, self.index)
        self.assertEqual(len(query(self.index, status='new', diff=diff)), 5)
        self.assertEqual(query(self.index, status='changed', diff=diff), [])
        with self.assertRaises(ValueError):
            query(self.index, status='new')
        diff['current_scan'] = 'stale'
        with self.assertRaises(ValueError):
            query(self.index, status='new', diff=diff)

    def test_batch_only_ids_and_unknown_or_stale_rejected(self):
        batch = batch_manifest(self.index, [self.concrete])
        self.assertEqual(batch['stable_ids'], [self.concrete['stable_id']])
        self.assertEqual(select_batch(self.index, batch), [self.concrete])
        self.assertNotIn('relative_path', str(batch))
        batch['stable_ids'].append('../outside.png')
        with self.assertRaises(ValueError):
            select_batch(self.index, batch)
        batch = batch_manifest(self.index, [self.concrete])
        batch['index_fingerprint'] = 'stale'
        with self.assertRaises(ValueError):
            select_batch(self.index, batch)

    def test_thumbnail_reuse_and_changed_source(self):
        cache = self.base / 'cache'
        first = thumbnail(self.repo, self.concrete, cache)
        with Image.open(first['path']) as image:
            self.assertEqual(image.size, (256, 256))
        stamp = Path(first['path']).stat().st_mtime_ns
        second = thumbnail(self.repo, self.concrete, cache)
        self.assertTrue(second['reused'])
        self.assertEqual(Path(second['path']).stat().st_mtime_ns, stamp)
        source = self.repo.resolve(first['source_relative_path'])
        Image.new('RGB', (9, 9), (200, 0, 0)).save(source)
        stale = thumbnail(self.repo, self.concrete, cache)
        self.assertIsNone(stale['path'])
        self.assertIn('source_changed', stale['warning'])
        current = next(c for c in scan(self.repo)['material_candidates'] if c['stable_id'] == self.concrete['stable_id'])
        fresh = thumbnail(self.repo, current, cache)
        self.assertNotEqual(first['path'], fresh['path'])

    def test_preview_path_escape_never_opened(self):
        broken = copy.deepcopy(self.concrete)
        broken['maps_by_resolution']['1K']['basecolor'][0]['relative_path'] = '../outside.png'
        result = thumbnail(self.repo, broken, self.base / 'cache')
        self.assertIsNone(result['path'])
        self.assertIn('unsafe', result['warning'])

    def test_sheets_and_full_id_manifest_include_placeholder(self):
        candidates = query(self.index)
        manifest = build_sheets(self.repo, self.index, candidates, self.base / 'sheets', self.base / 'cache', page_size=3)
        self.assertEqual(len(manifest['pages']), 2)
        ids = [tile['stable_id'] for page in manifest['pages'] for tile in page['tiles']]
        self.assertEqual(ids, [c['stable_id'] for c in candidates])
        self.assertTrue(any(tile['preview_warning'] for page in manifest['pages'] for tile in page['tiles']))
        for page in manifest['pages']:
            with Image.open(self.base / 'sheets' / page['image']) as image:
                image.verify()


if __name__ == '__main__':
    unittest.main()
