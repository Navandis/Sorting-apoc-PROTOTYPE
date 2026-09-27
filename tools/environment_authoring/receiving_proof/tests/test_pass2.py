"""EAF5 Pass-2 handoff checks over promoted EAF3B/EAF1 artifacts."""
import json
import hashlib
from pathlib import Path
import unittest
from zipfile import ZipFile

from tools.environment_authoring.material_catalog import catalog
from tools.environment_authoring.material_repository.path_guard import PROJECT_ROOT, load_repository
from tools.environment_authoring.material_repository.source_index import INDEX_PATH, load_index
from tools.environment_authoring.material_repository.query_index import index_fingerprint


ROOT = PROJECT_ROOT
SHORTLIST = ROOT / 'data/environment/receiving_proof/eaf5_material_source_shortlist_01.json'
BATCH_ROOT = ROOT / 'data/environment/material_catalog/review_batches'
REVIEW_ROOT = ROOT / 'reports/environment_material_catalog/reviews'
BATCH_IDS = {'eaf5_receiving_pbr_01a': 16, 'eaf5_receiving_pbr_01b': 15}
COMBOS = {('neutral', 'Hero'), ('neutral', 'WallGrazing'),
          ('receiving', 'Hero'), ('receiving', 'WallGrazing')}


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8'))


class Pass2ReviewTests(unittest.TestCase):
    def test_human_source_decision_record(self):
        record = read_json(ROOT / 'data/environment/receiving_proof/decisions/'
                           'eaf5_source_shortlist_01_human_review.json')
        shortlist = read_json(SHORTLIST)
        batches = [read_json(BATCH_ROOT / bid / 'batch.json') for bid in BATCH_IDS]
        staged_ids = {sid for batch in batches for sid in batch['candidate_ids']}
        decisions = record['decisions']
        by_status = {status: {d['source_stable_id'] for d in decisions if d['decision'] == status}
                     for status in ('SHORTLIST', 'HOLD', 'DROP', 'HOLD_OR_DROP_UNSPECIFIED')}
        self.assertEqual(record['source_index_fingerprint'], shortlist['source_index_fingerprint'])
        self.assertEqual(record['pass1_shortlist_sha256'], hashlib.sha256(SHORTLIST.read_bytes()).hexdigest())
        self.assertEqual(record['reported_human_counts'], {'SHORTLIST': 31, 'HOLD': 15, 'DROP': 11})
        self.assertEqual(by_status['SHORTLIST'], staged_ids)
        self.assertEqual(len(decisions), 57)
        self.assertEqual(len({d['source_stable_id'] for d in decisions}), 57)
        self.assertEqual({d['source_stable_id'] for d in decisions} |
                         set(record['existing_eaf3_approved_source_ids']),
                         {c['source_stable_id'] for c in shortlist['candidates']})
        self.assertEqual(len(record['existing_eaf3_approved_source_ids']), 5)
        self.assertFalse(staged_ids & (by_status['HOLD'] | by_status['DROP'] |
                                       by_status['HOLD_OR_DROP_UNSPECIFIED']))
        if record['record_state'] == 'COMPLETE':
            self.assertEqual((len(by_status['HOLD']), len(by_status['DROP']),
                              len(by_status['HOLD_OR_DROP_UNSPECIFIED'])), (15, 11, 0))
        else:
            self.assertEqual(record['record_state'],
                             'PARTIAL_ID_DISPOSITIONS_AWAITING_HUMAN_DETAIL')
            self.assertEqual(len(by_status['HOLD_OR_DROP_UNSPECIFIED']), 26)

    def test_selected_sources_and_batches(self):
        shortlist = read_json(SHORTLIST)
        batches = {bid: read_json(BATCH_ROOT / bid / 'batch.json') for bid in BATCH_IDS}
        selected = [sid for batch in batches.values() for sid in batch['candidate_ids']]
        proposed = {c['source_stable_id'] for c in shortlist['candidates']
                    if c['current_eaf3_catalog_state'] == 'UNREVIEWED'}
        decided = {m['source_stable_id'] for m in read_json(
            ROOT / 'data/environment/material_catalog/catalog.json')['materials']}
        self.assertEqual(len(selected), 31)
        self.assertEqual(len(set(selected)), 31)
        self.assertTrue(set(selected) <= proposed)
        self.assertFalse(set(selected) & decided)
        for bid, count in BATCH_IDS.items():
            self.assertEqual(len(batches[bid]['candidate_ids']), count)
            self.assertEqual(set(batches[bid]['candidate_ids']),
                             set(batches[bid]['candidate_overrides']))

        if INDEX_PATH.exists():
            index = load_index(INDEX_PATH)
            self.assertEqual(index_fingerprint(index), shortlist['source_index_fingerprint'])
            for batch in batches.values():
                catalog.validate_batch(batch, index)
            self.assertTrue(set(selected) <= {c['stable_id'] for c in index['material_candidates']})

    def test_staging_and_pending_decisions(self):
        for bid, count in BATCH_IDS.items():
            review = REVIEW_ROOT / bid
            if not (review / 'stage_manifest.json').exists():
                self.skipTest('Local EAF3B staging has not been generated')
            staged = read_json(review / 'stage_manifest.json')['candidates']
            decisions = read_json(review / 'decision_template.json')['decisions']
            batch = read_json(BATCH_ROOT / bid / 'batch.json')
            self.assertEqual([c['source_stable_id'] for c in staged], batch['candidate_ids'])
            self.assertEqual(len(staged), count)
            self.assertEqual(len(decisions), count)
            self.assertTrue(all(d['decision'] == 'PENDING' for d in decisions))
            self.assertTrue(all(len(c['source_fingerprint']) == 64 for c in staged))
            self.assertTrue(all(c['requested_review_resolution'] == '2K' for c in staged))
            if INDEX_PATH.exists():
                index = load_index(INDEX_PATH)
                repository = load_repository()
                for item in staged:
                    candidate = catalog.candidate_by_id(index, item['source_stable_id'])
                    current = catalog.fingerprint_candidate(
                        repository, candidate, item['actual_review_resolution'])
                    self.assertEqual(item['source_fingerprint'], current['source_fingerprint'])

    def test_capture_matrix_and_shareable_zip(self):
        for bid, count in BATCH_IDS.items():
            review = REVIEW_ROOT / bid
            archive = REVIEW_ROOT / f'{bid}_review.zip'
            if not archive.exists():
                self.skipTest('Local EAF1 capture has not been generated')
            staged = read_json(review / 'stage_manifest.json')['candidates']
            records = read_json(review / 'manifest.json')['records']
            self.assertEqual(len(records), count * 4)
            for item in staged:
                material_records = [r for r in records
                                    if r['material_id'] == item['catalog_material_id']]
                self.assertEqual({(r['light_mode'], r['camera']) for r in material_records}, COMBOS)
            with ZipFile(archive) as zipped:
                self.assertIsNone(zipped.testzip())
                names = zipped.namelist()
                expected = {r['filename'] for r in records} | {
                    'manifest.json', 'batch_summary.md', 'decision_template.json'}
                self.assertEqual(set(names), expected)
                self.assertEqual(len(names), count * 4 + 3)


if __name__ == '__main__':
    unittest.main()
