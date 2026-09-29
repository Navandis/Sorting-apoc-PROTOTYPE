import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
DATA = ROOT / 'data/environment/receiving_proof'
REPORT = ROOT / 'reports/environment_receiving_proof/eaf5/wear_calibration_01'


class Pass7ACalibrationTests(unittest.TestCase):
    def test_source_and_variant_contract(self):
        source = json.loads((DATA / 'eaf5_receiving_wear_calibration_01.json').read_text())
        self.assertEqual([x['instance_id'] for x in source['instances']], ['WEA01', 'WEA03', 'WEA04'])
        self.assertEqual(source['variants'], {
            'WEA01': [[1.0, .45], [.65, .45], [.65, .30]],
            'WEA03': [[1.0, .40], [.65, .40], [.65, .25]],
            'WEA04': [[1.0, .75], [.60, .75], [.60, .40]],
        })
        prior = json.loads((DATA / 'eaf5_receiving_wear_proof_01.json').read_text())
        placements = {x['instance_id']: x for x in prior['instances']}
        self.assertEqual(source['instances'], [placements[x] for x in ('WEA01', 'WEA03', 'WEA04')])

    def test_capture_matrix(self):
        manifest = json.loads((REPORT / 'manifest.json').read_text())
        records = manifest['records']
        self.assertEqual(len(records), 32)
        self.assertEqual(sum(x['selection_role'] == 'PRIMARY' for x in records), 22)
        self.assertEqual(sum(x['selection_role'] == 'ALTERNATE' for x in records), 10)
        self.assertTrue(all(x['visible_wear_overlays'] in (0, 1) for x in records))
        self.assertTrue(all('WEA02' not in [i['instance_id'] for i in x['wear_instances']] for x in records))


    def test_review_package(self):
        from zipfile import ZipFile
        from PIL import Image
        records = json.loads((REPORT / 'manifest.json').read_text())['records']
        sheets = {'contact_sheet_primary_leak.png', 'contact_sheet_primary_dust.png',
                  'contact_sheet_primary_rust.png', 'contact_sheet_alternate.png'}
        expected = {x['filename'] for x in records} | sheets | {
            'manifest.json', 'summary.md', 'decision_template.json'}
        self.assertEqual(len(expected), 39)
        for name in sheets:
            with Image.open(REPORT / name) as image:
                image.verify()
        with ZipFile(REPORT.parent / 'eaf5_wear_calibration_01_review.zip') as archive:
            self.assertIsNone(archive.testzip())
            self.assertEqual(set(archive.namelist()), expected)
        template = json.loads((REPORT / 'decision_template.json').read_text())
        self.assertEqual([x['selected_variant'] for x in template['sources']], ['PENDING'] * 3)
        self.assertEqual([x['alternate_transfer'] for x in template['sources']], ['PENDING'] * 3)

if __name__ == '__main__':
    unittest.main()
