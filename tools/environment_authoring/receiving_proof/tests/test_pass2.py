"""EAF5 Pass-2 handoff checks over promoted EAF3B/EAF1 artifacts."""
import json
import hashlib
import os
from pathlib import Path
import unittest
from zipfile import ZipFile
from collections import Counter

from tools.environment_authoring.material_catalog import catalog
from tools.environment_authoring.material_repository.path_guard import PROJECT_ROOT, load_repository
from tools.environment_authoring.material_repository.source_index import INDEX_PATH, load_index
from tools.environment_authoring.material_repository.query_index import index_fingerprint


ROOT = PROJECT_ROOT
SHORTLIST = ROOT / 'data/environment/receiving_proof/eaf5_material_source_shortlist_01.json'
BATCH_ROOT = ROOT / 'data/environment/material_catalog/review_batches'
REVIEW_ROOT = ROOT / 'reports/environment_material_catalog/reviews'
CACHE_ROOT = ROOT / 'assets/environment/materials/kitbash_cache'
BATCH_IDS = {'eaf5_receiving_pbr_01a': 16, 'eaf5_receiving_pbr_01b': 15}
SUPERSEDED_ZIP_SHA256 = {
    'eaf5_receiving_pbr_01a': 'ae1209cf425b54bd9a1f3138af94fd12b9e3faab0825a5f827df052f20508511',
    'eaf5_receiving_pbr_01b': '65b8d8b9e96298293e28e04269708b2dc7c44ffddad0c66b5e6776aa1850206f',
}
COMBOS = {('neutral', 'Hero'), ('neutral', 'WallGrazing'),
          ('receiving', 'Hero'), ('receiving', 'WallGrazing')}
RERUN_ID = 'eaf5_receiving_pbr_01_rerun_01'
RERUN_ZIP_SHA256 = '625fe5ccd5f84a393749c3ada6868a895e701f0b66b6bd3ef8941a2388922465'
RERUN_CHANGES = {
    'kitbash:kb3d_beyondrepair@7.0.0:KB3D_BYR_COReinforcedConcreteSlabs': {'meters_per_repeat': 3.0},
    'kitbash:kb3d_washingtondc@7.0.3:KB3D_WDC_ConcreteBlocksA': {'albedo_multiplier': 0.75},
    'fab:ugkkedvlw': {'albedo_multiplier': 0.65},
    'kitbash:kb3d_constructionzone@7.0.3:KB3D_CSZ_ConcreteBlocksBPanels': {'albedo_multiplier': 0.75},
    'kitbash:kb3d_everycitypolicedept@7.0.2:KB3D_ECP_StuccoWhite': {'albedo_multiplier': 0.70},
    'kitbash:kb3d_neonyc@7.0.2:KB3D_NNY_ConcretePlasterWhite': {'albedo_multiplier': 0.70},
    'kitbash:kb3d_refineries@7.0.2:KB3D_RFS_ConcretePlasterWhite': {'albedo_multiplier': 0.70},
}


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8'))


class Pass2ReviewTests(unittest.TestCase):
    def test_final_rerun_approvals_and_role_queries(self):
        decisions = read_json(ROOT / 'data/environment/material_catalog/decisions/'
                              'eaf5_receiving_pbr_rerun_01_human_review_02.json')['decisions']
        template = {item['source_stable_id']: item for item in
                    read_json(REVIEW_ROOT / RERUN_ID / 'decision_template.json')['decisions']}
        records = read_json(ROOT / 'data/environment/material_catalog/catalog.json')['materials']
        self.assertEqual({item['source_stable_id'] for item in decisions}, set(RERUN_CHANGES))
        self.assertEqual(len(decisions), 7)
        self.assertTrue(all(item['decision'] == 'APPROVED' for item in decisions))
        for item in decisions:
            captured = template[item['source_stable_id']]
            for key in ('review_resolution', 'reviewed_source_fingerprint', 'display_name',
                        *catalog.PARAMETERS):
                self.assertEqual(item[key], captured[key])
            self.assertEqual(item['approval_revision'], 1)
            self.assertEqual(item['approval_date'], '2026-09-28')
            self.assertEqual(item['mapping_mode'], 'UV')
            self.assertTrue(item['review_notes'])
            current = next(record for record in records
                           if record['source_stable_id'] == item['source_stable_id'])
            self.assertEqual(current['effective_status'], 'APPROVED')
            self.assertTrue(current['current_source_matches_review'])
        self.assertEqual(len(catalog.query(records)), 30)
        for family, layer, role in (
                ('service_floor_concrete', 'structural_substrate', 'floor'),
                ('masonry_block', 'structural_substrate', 'wall'),
                ('cement_render', 'applied_finish', 'wall'),
                ('applied_paint', 'applied_finish', 'wall'),
                ('structural_concrete', 'structural_substrate', 'ceiling')):
            self.assertTrue(catalog.query(records, family, layer, role))
        self.assertFalse(catalog.query(records, 'applied_paint', 'structural_substrate', 'wall'))
        self.assertFalse(catalog.query(records, 'cement_render', 'structural_substrate', 'wall'))
        self.assertFalse(catalog.query(records, 'service_floor_concrete',
                                       'structural_substrate', 'ceiling'))

    def test_human_uv01_decisions_and_catalog(self):
        human = read_json(ROOT / 'data/environment/material_catalog/decisions/'
                          'eaf5_receiving_pbr_uv01_human_review_01.json')['decisions']
        catalog_records = read_json(ROOT / 'data/environment/material_catalog/catalog.json')['materials']
        uv = {item['source_stable_id']: item
              for old_id in BATCH_IDS
              for item in read_json(REVIEW_ROOT / (old_id + '_uv01') /
                                    'decision_template.json')['decisions']}
        self.assertEqual(len(human), 24)
        self.assertEqual(len({item['source_stable_id'] for item in human}), 24)
        self.assertEqual(Counter(item['decision'] for item in human),
                         {'APPROVED': 18, 'DEFERRED': 4, 'REJECTED': 2})
        self.assertEqual(Counter(item['status'] for item in catalog_records),
                         {'APPROVED': 30, 'DEFERRED': 7, 'REJECTED': 6})
        self.assertEqual(len(catalog.query(catalog_records)), 30)
        self.assertEqual(len(catalog_records), 43)
        self.assertEqual(set(RERUN_CHANGES) & {item['source_stable_id'] for item in catalog_records},
                         set(RERUN_CHANGES))
        for item in human:
            captured = uv[item['source_stable_id']]
            for key in ('review_resolution', 'reviewed_source_fingerprint', 'display_name',
                        *catalog.PARAMETERS):
                self.assertEqual(item[key], captured[key])
            self.assertEqual(item['approval_revision'], 1)
            self.assertEqual(item['approval_date'], '2026-09-28')
            self.assertEqual(item['mapping_mode'], 'UV')
            if item['decision'] != 'APPROVED':
                self.assertIsNone(item['surface_family'])
                self.assertIsNone(item['vdd_layer'])
                self.assertEqual(item['approved_roles'], [])
        restage = read_json(ROOT / 'reports/environment_material_catalog/approved_restage_report.json')
        self.assertEqual(len(restage['restaged']), 30)
        self.assertEqual(restage['refused'], [])

    def test_parameter_only_rerun_lineage_and_capture(self):
        batch = read_json(BATCH_ROOT / RERUN_ID / 'batch.json')
        iteration = read_json(BATCH_ROOT / RERUN_ID / 'iteration.json')
        self.assertEqual(set(batch['candidate_ids']), set(RERUN_CHANGES))
        self.assertEqual(iteration['candidate_overrides'], RERUN_CHANGES)
        old = {item['source_stable_id']: item for old_id in BATCH_IDS
               for item in read_json(REVIEW_ROOT / (old_id + '_uv01') /
                                     'stage_manifest.json')['candidates']}
        new_dir = REVIEW_ROOT / RERUN_ID
        if not (new_dir / 'stage_manifest.json').exists():
            self.skipTest('Local parameter rerun has not been prepared')
        staged = read_json(new_dir / 'stage_manifest.json')['candidates']
        pending = read_json(new_dir / 'decision_template.json')['decisions']
        self.assertEqual(len(staged), 7)
        self.assertEqual(len(pending), 7)
        self.assertTrue(all(item['decision'] == 'PENDING' for item in pending))
        for item in staged:
            sid = item['source_stable_id']
            previous = old[sid]
            for key in ('source_fingerprint', 'maps', 'actual_review_resolution'):
                self.assertEqual(item[key], previous[key])
            self.assertEqual(item['mapping_mode'], 'UV')
            changed = {key: item[key] for key in catalog.PARAMETERS
                       if item[key] != previous[key]}
            self.assertEqual(changed, RERUN_CHANGES[sid])
        if not (new_dir / 'manifest.json').exists():
            if os.environ.get('EAF5_REQUIRE_LOCAL_EVIDENCE') == '1':
                self.fail('Required local rerun capture is missing')
            self.skipTest('Local parameter rerun capture has not been generated')
        records = read_json(new_dir / 'manifest.json')['records']
        self.assertEqual(len(records), 28)
        for item in staged:
            material_records = [record for record in records
                                if record['material_id'] == item['catalog_material_id']]
            self.assertEqual({(record['light_mode'], record['camera'])
                              for record in material_records}, COMBOS)
        archive = REVIEW_ROOT / f'{RERUN_ID}_review.zip'
        self.assertEqual(hashlib.sha256(archive.read_bytes()).hexdigest(), RERUN_ZIP_SHA256)
        with ZipFile(archive) as zipped:
            self.assertIsNone(zipped.testzip())
            self.assertEqual(set(zipped.namelist()),
                             {record['filename'] for record in records} |
                             {'manifest.json', 'batch_summary.md', 'decision_template.json'})

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
        human = read_json(ROOT / 'data/environment/material_catalog/decisions/'
                          'eaf5_receiving_pbr_uv01_human_review_01.json')['decisions']
        self.assertEqual(set(selected) & decided,
                         {item['source_stable_id'] for item in human} | set(RERUN_CHANGES))
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

    def test_uv01_tracked_batch_policy(self):
        selected = []
        for old_id, count in BATCH_IDS.items():
            old_batch = read_json(BATCH_ROOT / old_id / 'batch.json')
            new_batch = read_json(BATCH_ROOT / (old_id + '_uv01') / 'batch.json')
            self.assertEqual(new_batch['candidate_ids'], old_batch['candidate_ids'])
            self.assertEqual(len(new_batch['candidate_ids']), count)
            selected.extend(new_batch['candidate_ids'])
            for sid in new_batch['candidate_ids']:
                expected = {**old_batch['candidate_overrides'][sid], 'mapping_mode': 'UV'}
                self.assertEqual(new_batch['candidate_overrides'][sid], expected)
                spec = (BATCH_ROOT / (old_id + '_uv01') /
                        f"{catalog.catalog_id(sid)}.tres").read_text()
                self.assertIn('mapping_mode = 0', spec)
        self.assertEqual(len(selected), len(set(selected)))
        self.assertEqual(len(selected), 31)

    def test_uv01_lineage_and_preserved_triplanar_evidence(self):
        needed = [REVIEW_ROOT / f'{old_id}_review.zip' for old_id in BATCH_IDS]
        needed += [REVIEW_ROOT / f'{old_id}_uv01_review.zip' for old_id in BATCH_IDS]
        needed += [REVIEW_ROOT / old_id / 'stage_manifest.json' for old_id in BATCH_IDS]
        needed += [REVIEW_ROOT / (old_id + '_uv01') / 'stage_manifest.json' for old_id in BATCH_IDS]
        if not all(path.exists() for path in needed):
            if os.environ.get('EAF5_REQUIRE_LOCAL_EVIDENCE') == '1':
                self.fail('Required local old/new EAF5 capture lineage is missing')
            self.skipTest('Local old/new EAF5 capture lineage has not been generated')
        old_sources = {}
        uv_sources = {}
        for old_id, count in BATCH_IDS.items():
            uv_id = old_id + '_uv01'
            old_zip = REVIEW_ROOT / f'{old_id}_review.zip'
            self.assertTrue(old_zip.is_file())
            self.assertEqual(hashlib.sha256(old_zip.read_bytes()).hexdigest(),
                             SUPERSEDED_ZIP_SHA256[old_id])
            old_stage = read_json(REVIEW_ROOT / old_id / 'stage_manifest.json')['candidates']
            new_stage = read_json(REVIEW_ROOT / uv_id / 'stage_manifest.json')['candidates']
            self.assertEqual(len(new_stage), count)
            for before, after in zip(old_stage, new_stage):
                self.assertEqual(after['source_stable_id'], before['source_stable_id'])
                self.assertEqual(after['source_fingerprint'], before['source_fingerprint'])
                self.assertEqual(after['maps'], before['maps'])
                for map_record in after['maps'].values():
                    cached = CACHE_ROOT / map_record['cache_relative']
                    self.assertEqual(hashlib.sha256(cached.read_bytes()).hexdigest(),
                                     map_record['sha256'])
                self.assertEqual(after['mapping_mode'], 'UV')
                old_sources[before['source_stable_id']] = before['source_fingerprint']
                uv_sources[after['source_stable_id']] = after['source_fingerprint']
                spec = (BATCH_ROOT / uv_id / f"{after['catalog_material_id']}.tres").read_text()
                self.assertIn('mapping_mode = 0', spec)
            review = REVIEW_ROOT / uv_id
            decisions = read_json(review / 'decision_template.json')['decisions']
            self.assertEqual(len(decisions), count)
            self.assertTrue(all(item['decision'] == 'PENDING' and item['mapping_mode'] == 'UV'
                                for item in decisions))
            archive = REVIEW_ROOT / f'{uv_id}_review.zip'
            self.assertTrue(archive.is_file())
            records = read_json(review / 'manifest.json')['records']
            self.assertEqual(len(records), count * 4)
            self.assertTrue(all(item['mapping_mode'] == 'UV' for item in records))
            with ZipFile(archive) as zipped:
                self.assertIsNone(zipped.testzip())
                self.assertEqual(set(zipped.namelist()),
                                 {item['filename'] for item in records} |
                                 {'manifest.json', 'batch_summary.md', 'decision_template.json'})
        self.assertEqual(old_sources, uv_sources)
        self.assertEqual(len(uv_sources), 31)

    def test_approved_seed_uv_check_does_not_change_catalog(self):
        seed_id = 'eaf5_seed_uv_policy_check_01'
        batch = read_json(BATCH_ROOT / seed_id / 'batch.json')
        approved = [item for item in read_json(ROOT / 'data/environment/material_catalog/catalog.json')['materials']
                    if item['effective_status'] == 'APPROVED' and item['mapping_mode'] == 'TRIPLANAR']
        self.assertEqual(len(approved), 3)
        current = [item for item in read_json(ROOT / 'data/environment/material_catalog/catalog.json')['materials']
                   if item['effective_status'] == 'APPROVED']
        self.assertEqual(len(current), 30)
        self.assertEqual(sum(item['mapping_mode'] == 'UV' for item in current), 27)
        self.assertEqual(set(batch['candidate_ids']), {item['source_stable_id'] for item in approved})
        for item in approved:
            override = batch['candidate_overrides'][item['source_stable_id']]
            self.assertEqual(override['mapping_mode'], 'UV')
            self.assertEqual(override['review_resolution'], item['review_resolution'])
            for key in catalog.PARAMETERS:
                if key != 'mapping_mode':
                    self.assertEqual(override[key], item[key])
            approved_spec = (ROOT / 'data/environment/material_catalog/approved_specs' /
                             f"{item['catalog_material_id']}.tres").read_text()
            self.assertIn('mapping_mode = 1', approved_spec)
        if not (REVIEW_ROOT / seed_id / 'manifest.json').exists():
            if os.environ.get('EAF5_REQUIRE_LOCAL_EVIDENCE') == '1':
                self.fail('Required local seed UV check capture is missing')
            self.skipTest('Local seed UV check capture has not been generated')
        stage = read_json(REVIEW_ROOT / seed_id / 'stage_manifest.json')['candidates']
        for item in approved:
            before = next(source for source in stage if source['source_stable_id'] == item['source_stable_id'])
            self.assertEqual(before['source_fingerprint'], item['reviewed_source_fingerprint'])
            self.assertEqual(before['actual_review_resolution'], item['review_resolution'])
            for key in catalog.PARAMETERS:
                if key != 'mapping_mode':
                    self.assertEqual(before[key], item[key])
        records = read_json(REVIEW_ROOT / seed_id / 'manifest.json')['records']
        self.assertEqual(len(records), 12)
        self.assertTrue(all(item['mapping_mode'] == 'UV' for item in records))
        for source in stage:
            material_records = [item for item in records
                                if item['material_id'] == source['catalog_material_id']]
            self.assertEqual({(item['light_mode'], item['camera']) for item in material_records},
                             COMBOS)
        with ZipFile(REVIEW_ROOT / f'{seed_id}_review.zip') as zipped:
            self.assertIsNone(zipped.testzip())


if __name__ == '__main__':
    unittest.main()
