import hashlib
import json
from collections import Counter
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / 'reports/environment_receiving_proof/eaf5/role_isolation_01'
CATALOG = ROOT / 'data/environment/material_catalog/catalog.json'
FAMILIES = {'WALL_PRIMARY': {'structural_concrete', 'rough_poured_concrete', 'service_floor_concrete'}, 'FLOOR_PRIMARY': {'service_floor_concrete'}, 'CEILING_PRIMARY': {'structural_concrete', 'rough_poured_concrete'}}
APPROVED_ROLE = {'WALL_PRIMARY': 'wall', 'FLOOR_PRIMARY': 'floor', 'CEILING_PRIMARY': 'ceiling'}
VIEW = {'WALL_PRIMARY': 'WallDominant', 'FLOOR_PRIMARY': 'FloorRead', 'CEILING_PRIMARY': 'CeilingRead'}

class Pass3EvidenceTests(unittest.TestCase):
    def test_live_catalog_candidates_and_locked_matrix(self):
        catalog = json.loads(CATALOG.read_text(encoding='utf-8'))['materials']
        transforms, rigs = {}, {}
        for folder in (BASE / 'wall', BASE / 'floor', BASE / 'ceiling'):
            manifest = json.loads((folder / 'manifest.json').read_text(encoding='utf-8'))
            role = manifest['role']
            expected = sorted(row['catalog_material_id'] for row in catalog if row['effective_status'] == 'APPROVED' and row['vdd_layer'] == 'structural_substrate' and row['surface_family'] in FAMILIES[role] and APPROVED_ROLE[role] in row['approved_roles'])
            self.assertEqual(manifest['candidate_ids'], expected)
            counts = Counter(row['catalog_material_id'] for row in manifest['records'])
            self.assertEqual(counts, Counter({item: 4 for item in expected}))
            for record in manifest['records']:
                self.assertEqual(record['effective_review_mapping'], 'UV')
                self.assertEqual(record['role'], role)
                self.assertEqual(record['transient_uv_review_override'], record['approved_catalog_mapping'] != 'UV')
                self.assertTrue((ROOT / 'data/environment/material_catalog/approved_specs' / (record['catalog_material_id'] + '.tres')).is_file())
                self.assertIn(record['camera'], ('EastApproachOverview', VIEW[role]))
                self.assertIn(record['light_mode'], ('NEUTRAL_ARCHITECTURAL', 'RECEIVING_TARGET'))
                key = record['camera']
                if key in transforms:
                    self.assertEqual(record['camera_transform'], transforms[key])
                transforms[key] = record['camera_transform']
                key = record['light_mode']
                if key in rigs:
                    self.assertEqual(record['light_settings'], rigs[key])
                rigs[key] = record['light_settings']

    def test_each_capture_record_carries_shell_and_geometry_provenance(self):
        source_hash = hashlib.sha256((ROOT / 'data/environment/receiving_proof/eaf5_receiving_shell_source.json').read_bytes()).hexdigest()
        for folder in (BASE / 'wall', BASE / 'floor', BASE / 'ceiling'):
            manifest = json.loads((folder / 'manifest.json').read_text(encoding='utf-8'))
            self.assertEqual(manifest['shell_source_sha256'], source_hash)
            expected = {piece['piece_id']: piece['geometry_fingerprint'] for piece in manifest['pieces']}
            self.assertEqual(len(expected), 19)
            for record in manifest['records']:
                self.assertEqual(record['shell_source_sha256'], manifest['shell_source_sha256'])
                self.assertEqual(record['piece_geometry_fingerprints'], expected)

if __name__ == '__main__':
    unittest.main()
