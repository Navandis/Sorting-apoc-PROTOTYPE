import json
from pathlib import Path
import tempfile
import unittest
from zipfile import ZipFile

from tools.environment_authoring.material_catalog import catalog, workflow
from tools.environment_authoring.material_catalog.tests.test_catalog import CatalogFixture


class WorkflowTests(CatalogFixture, unittest.TestCase):
    def test_prepare_writes_specs_pending_template_and_summary(self):
        batch = catalog.make_batch('foundation_mineral_01', self.index, [self.candidate['stable_id']])
        spec_dir = self.root / 'data' / 'review_batches' / batch['batch_id']
        review_dir = self.root / 'reports' / batch['batch_id']
        result = workflow.prepare(batch, self.index, self.repo, self.cache, spec_dir, review_dir)
        self.assertEqual(len(result['candidates']), 1)
        self.assertEqual(result['candidates'][0]['actual_review_resolution'], '2K')
        self.assertTrue((spec_dir / 'review_set.tres').exists())
        self.assertIn('PENDING', (review_dir / 'decision_template.json').read_text())
        self.assertIn('Strong fingerprint', (review_dir / 'batch_summary.md').read_text())
        self.assertEqual(len(list(spec_dir.glob('*.tres'))), 2)
        self.assertNotIn(str(self.source), json.dumps(result))
        first = (spec_dir / 'review_set.tres').read_bytes()
        workflow.prepare(batch, self.index, self.repo, self.cache, spec_dir, review_dir)
        self.assertEqual(first, (spec_dir / 'review_set.tres').read_bytes())
        staged_map = self.cache / result['candidates'][0]['maps']['basecolor']['cache_relative']
        source_mtime = staged_map.stat().st_mtime_ns
        iteration = {'schema_version': 1, 'batch_id': batch['batch_id'],
                     'candidate_overrides': {self.candidate['stable_id']: {'normal_y_flip': True,
                                                                            'meters_per_repeat': 2.5}}}
        workflow.prepare(batch, self.index, self.repo, self.cache, spec_dir, review_dir, iteration)
        self.assertEqual(staged_map.stat().st_mtime_ns, source_mtime)
        self.assertIn('meters_per_repeat = 2.5', next(spec_dir.glob('eaf3b_*.tres')).read_text())

    def test_import_policy_normalizes_generated_records(self):
        staged = catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache)
        for channel, record in staged['maps'].items():
            path = self.cache / record['cache_relative']
            path.with_suffix(path.suffix + '.import').write_text('[params]\ncompress/mode=2\ncompress/normal_map=0\nmipmaps/generate=false\n')
        changed = workflow.normalize_imports([staged], self.cache)
        self.assertEqual(changed, 5)
        self.assertEqual(workflow.normalize_imports([staged], self.cache), 0)
        normal = (self.cache / staged['maps']['normal']['cache_relative']).with_suffix('.png.import').read_text()
        self.assertIn('compress/normal_map=1', normal)
        self.assertIn('mipmaps/generate=true', normal)

    def test_shareable_archive_excludes_staged_facts_and_textures(self):
        review = self.root / 'review'
        review.mkdir()
        for name in ('manifest.json', 'batch_summary.md', 'decision_template.json',
                     'one__neutral__hero.png', 'stage_manifest.json', 'source.png.import'):
            (review / name).write_bytes(b'fixture')
        archive = workflow.package_review(review)
        with ZipFile(archive) as bundle:
            self.assertEqual(set(bundle.namelist()), {'manifest.json', 'batch_summary.md',
                                                       'decision_template.json', 'one__neutral__hero.png'})


if __name__ == '__main__':
    unittest.main()
