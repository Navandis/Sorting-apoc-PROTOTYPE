import json
from copy import deepcopy
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools.environment_authoring.material_repository.path_guard import Repository, BoundaryError
from tools.environment_authoring.material_catalog import catalog


class CatalogFixture:
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / 'source'
        self.source.mkdir()
        self.cache = self.root / 'cache'
        self.repo = Repository(self.source)
        self.candidate = {
            'stable_id': 'kitbash:kb3d_alpha@1.0.0:Concrete',
            'display_name': 'Concrete', 'package_id': 'kb3d_alpha',
            'package_version': '1.0.0',
            'relative_material_group': 'kb3d_alpha/1.0.0/Materials/Concrete',
            'available_resolutions': ['1K', '2K', '4K'],
            'suggested_family': 'concrete', 'warnings': ['tileability_unverified'],
            'maps_by_resolution': {}, 'channel_states_by_resolution': {},
        }
        for resolution in ('1K', '2K', '4K'):
            maps = {}
            for channel in ('basecolor', 'normal', 'roughness', 'metallic', 'ao', 'opacity'):
                relative = f'kb3d_alpha/1.0.0/Textures/png{resolution.lower()}/Concrete_{channel}.png'
                path = self.source / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(f'{resolution}-{channel}'.encode())
                maps[channel] = [{'relative_path': relative}]
            self.candidate['maps_by_resolution'][resolution] = maps
            self.candidate['channel_states_by_resolution'][resolution] = {
                channel: 'SUPPORTED' for channel in maps
            }
        self.index = {'schema_version': 1, 'scanner_revision': 'eaf3a-1',
                      'profile_id': 'KITBASH_PROFILE_V1', 'profile_revision': 1,
                      'scan_finished_at': '2026-09-26T00:00:00Z',
                      'material_candidates': [self.candidate], 'packages': []}

    def _decision(self, stable_id, status, revision):
        reviewed = catalog.fingerprint_candidate(self.repo, self.candidate, '2K')
        return {'source_stable_id': stable_id, 'decision': status, 'approval_revision': revision,
                'approval_date': '2026-09-26', 'display_name': 'Synthetic concrete',
                'review_resolution': '2K', 'reviewed_source_fingerprint': reviewed['source_fingerprint'],
                'surface_family': 'structural_concrete', 'vdd_layer': 'structural_substrate',
                'approved_roles': ['wall'], 'mapping_mode': 'TRIPLANAR', 'meters_per_repeat': 1.0,
                'normal_y_flip': False, 'normal_strength': 1.0,
                'roughness_multiplier': 1.0, 'metallic_multiplier': 1.0,
                'albedo_multiplier': 1.0, 'review_notes': 'synthetic technical proof'}


class CatalogTests(CatalogFixture, unittest.TestCase):
    def test_resolution_order_and_indexed_maps_only(self):
        self.assertEqual(catalog.choose_resolution(self.candidate, '2K'), ('2K', None))
        self.assertEqual(catalog.choose_resolution(self.candidate, '4K'), ('4K', None))
        self.candidate['available_resolutions'].remove('2K')
        self.assertEqual(catalog.choose_resolution(self.candidate, '2K'), ('4K', '2K unavailable'))
        self.candidate['available_resolutions'].remove('4K')
        self.assertEqual(catalog.choose_resolution(self.candidate, '2K'), ('1K', '2K and 4K unavailable'))
        staged = catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache)
        self.assertEqual(staged['actual_review_resolution'], '1K')
        self.assertEqual(staged['fallback_reason'], '2K and 4K unavailable')

    def test_stage_hashes_selected_maps_and_reuses_cache(self):
        first = catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache)
        self.assertEqual(set(first['maps']), {'basecolor', 'normal', 'roughness', 'metallic', 'ao'})
        self.assertEqual(len(first['source_fingerprint']), 64)
        self.assertEqual(len(list(self.cache.rglob('*.png'))), 5)
        self.assertEqual(first, catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache))
        self.assertNotIn('opacity', json.dumps(first['maps']))
        self.assertNotIn(str(self.source), json.dumps(first))
        source_normal = self.source / self.candidate['maps_by_resolution']['2K']['normal'][0]['relative_path']
        source_normal.write_bytes(b'changed-normal')
        second = catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache)
        self.assertNotEqual(first['source_fingerprint'], second['source_fingerprint'])
        self.assertEqual((self.cache / second['maps']['normal']['cache_relative']).read_bytes(), b'changed-normal')

    def test_unstaged_height_does_not_change_review_fingerprint(self):
        relative = 'kb3d_alpha/1.0.0/Textures/exr2k/Concrete_height.exr'
        path = self.source / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b'height-one')
        self.candidate['maps_by_resolution']['2K']['height'] = [{'relative_path': relative}]
        self.candidate['channel_states_by_resolution']['2K']['height'] = 'OPTIONAL'
        original = catalog.fingerprint_candidate(self.repo, self.candidate, '2K')['source_fingerprint']
        path.write_bytes(b'height-two')
        self.assertEqual(original, catalog.fingerprint_candidate(self.repo, self.candidate, '2K')['source_fingerprint'])
        staged = catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache)
        self.assertNotIn('height', staged['maps'])

    def test_guard_rejects_unindexed_and_escaping_sources(self):
        self.candidate['maps_by_resolution']['2K']['basecolor'][0]['relative_path'] = '../outside.png'
        with self.assertRaises(BoundaryError):
            catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache)

    def test_batch_detects_cache_identity_collision(self):
        other = deepcopy(self.candidate)
        other['stable_id'] += 'Other'
        self.index['material_candidates'].append(other)
        with patch.object(catalog, 'catalog_id', return_value='collision'):
            with self.assertRaises(ValueError):
                catalog.make_batch('foundation_mineral_01', self.index,
                                   [self.candidate['stable_id'], other['stable_id']])

    def test_batch_and_overrides_validate_without_paths(self):
        batch = catalog.make_batch('foundation_mineral_01', self.index, [self.candidate['stable_id']])
        self.assertEqual(catalog.validate_batch(batch, self.index), [self.candidate])
        batch['candidate_overrides'] = {self.candidate['stable_id']: {'mapping_mode': 'UV', 'meters_per_repeat': 1.5}}
        self.assertEqual(catalog.validate_batch(batch, self.index), [self.candidate])
        batch['candidate_overrides'][self.candidate['stable_id']]['review_resolution'] = '4K'
        self.assertEqual(catalog.validate_batch(batch, self.index), [self.candidate])
        batch['candidate_overrides'][self.candidate['stable_id']]['source_path'] = 'C:\\other\\texture.png'
        with self.assertRaises(ValueError):
            catalog.validate_batch(batch, self.index)

    def test_spec_generation_and_overrides_are_deterministic(self):
        staged = catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache)
        a = catalog.spec_text(staged, self.candidate, {'mapping_mode': 'UV', 'normal_y_flip': True,
                                                       'meters_per_repeat': 1.5, 'normal_strength': 0.8})
        self.assertEqual(a, catalog.spec_text(staged, self.candidate, {'normal_strength': 0.8,
                                                                       'meters_per_repeat': 1.5,
                                                                       'normal_y_flip': True, 'mapping_mode': 'UV'}))
        self.assertIn('mapping_mode = 0', a)
        self.assertIn('normal_y_flip = true', a)
        self.assertIn('meters_per_repeat = 1.5', a)

    def test_synthetic_decisions_freshness_restage_and_query(self):
        staged = catalog.stage_candidate(self.repo, self.candidate, '2K', self.cache)
        decisions = [self._decision(self.candidate['stable_id'], 'APPROVED', 1)]
        records, diff = catalog.reconcile([], decisions, self.index, self.repo)
        self.assertEqual(records[0]['effective_status'], 'APPROVED')
        self.assertEqual(diff['new_approved'], [records[0]['catalog_material_id']])
        self.assertEqual(catalog.query(records, family='structural_concrete', layer='structural_substrate', role='wall'), records)
        self.assertEqual(catalog.reconcile(records, decisions, self.index, self.repo)[1]['unchanged'], [records[0]['catalog_material_id']])
        self.assertEqual(catalog.restage_approved(records, self.index, self.repo, self.cache)[0], [records[0]['catalog_material_id']])
        records = deepcopy(records)
        self.candidate['available_resolutions'].append('8K')
        refreshed_availability, availability_diff = catalog.reconcile(records, [], self.index, self.repo)
        self.assertIn('8K', refreshed_availability[0]['available_resolutions'])
        self.assertEqual(availability_diff['source_availability_changed'], [records[0]['catalog_material_id']])
        normal = self.source / self.candidate['maps_by_resolution']['2K']['normal'][0]['relative_path']
        normal.write_bytes(b'changed-normal')
        refreshed, diff = catalog.reconcile(records, [], self.index, self.repo)
        self.assertEqual(refreshed[0]['status'], 'APPROVED')
        self.assertEqual(refreshed[0]['effective_status'], 'STALE')
        self.assertEqual(diff['became_stale'], [records[0]['catalog_material_id']])
        self.assertEqual(catalog.query(refreshed), [])
        self.assertEqual(catalog.restage_approved(refreshed, self.index, self.repo, self.cache)[0], [])
        normal.unlink()
        missing, _ = catalog.reconcile(refreshed, [], self.index, self.repo)
        self.assertEqual(missing[0]['effective_status'], 'SOURCE_MISSING')

    def test_rejected_deferred_conflicts_and_duplicate_ids(self):
        one = self._decision(self.candidate['stable_id'], 'REJECTED', 1)
        records, diff = catalog.reconcile([], [one], self.index, self.repo)
        self.assertEqual(diff['new_rejected'], [records[0]['catalog_material_id']])
        self.assertEqual(catalog.query(records), [])
        two = self._decision(self.candidate['stable_id'], 'DEFERRED', 2)
        records, diff = catalog.reconcile(records, [two], self.index, self.repo)
        self.assertEqual(diff['status_changed'], [records[0]['catalog_material_id']])
        with self.assertRaises(ValueError):
            catalog.reconcile(records, [one], self.index, self.repo)
        with self.assertRaises(ValueError):
            catalog.reconcile(records + records, [], self.index, self.repo)

    def test_nonapproved_decisions_need_no_approved_taxonomy(self):
        for status in ('REJECTED', 'DEFERRED'):
            with self.subTest(status=status):
                decision = self._decision(self.candidate['stable_id'], status, 1)
                decision.update(surface_family=None, vdd_layer=None, approved_roles=[])
                records, _ = catalog.reconcile([], [decision], self.index, self.repo)
                self.assertEqual(records[0]['effective_status'], status)
                self.assertEqual(catalog.query(records), [])
        approved = self._decision(self.candidate['stable_id'], 'APPROVED', 1)
        approved.update(surface_family=None, vdd_layer=None, approved_roles=[])
        with self.assertRaises(ValueError):
            catalog.reconcile([], [approved], self.index, self.repo)

    def test_three_synthetic_statuses_and_approved_spec(self):
        rejected_candidate = deepcopy(self.candidate)
        rejected_candidate['stable_id'] += 'Rejected'
        deferred_candidate = deepcopy(self.candidate)
        deferred_candidate['stable_id'] += 'Deferred'
        self.index['material_candidates'] += [rejected_candidate, deferred_candidate]
        decisions = []
        for candidate, status in ((self.candidate, 'APPROVED'),
                                  (rejected_candidate, 'REJECTED'),
                                  (deferred_candidate, 'DEFERRED')):
            decision = self._decision(candidate['stable_id'], status, 1)
            decision['reviewed_source_fingerprint'] = catalog.fingerprint_candidate(self.repo, candidate, '2K')['source_fingerprint']
            decisions.append(decision)
        records, diff = catalog.reconcile([], decisions, self.index, self.repo)
        self.assertEqual({r['effective_status'] for r in records}, {'APPROVED', 'REJECTED', 'DEFERRED'})
        self.assertEqual(len(catalog.query(records)), 1)
        spec_root = self.root / 'approved_specs'
        completed, refused = catalog.restage_approved(records, self.index, self.repo, self.cache, spec_root)
        self.assertEqual(len(completed), 1)
        self.assertEqual(refused, [])
        self.assertIn('Synthetic concrete', (spec_root / f'{completed[0]}.tres').read_text())
        self.assertEqual(len(diff['new_approved']), 1)
        self.assertEqual(len(diff['new_rejected']), 1)
        self.assertEqual(len(diff['new_deferred']), 1)

    def test_unsupported_source_facts_preserve_human_status(self):
        decision = self._decision(self.candidate['stable_id'], 'APPROVED', 1)
        records, _ = catalog.reconcile([], [decision], self.index, self.repo)
        self.candidate['maps_by_resolution']['2K']['basecolor'] = []
        refreshed, _ = catalog.reconcile(records, [], self.index, self.repo)
        self.assertEqual(refreshed[0]['status'], 'APPROVED')
        self.assertEqual(refreshed[0]['effective_status'], 'UNSUPPORTED')

if __name__ == '__main__':
    unittest.main()
