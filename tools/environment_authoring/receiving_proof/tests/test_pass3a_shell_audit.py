import copy
import json
from pathlib import Path
import unittest

from tools.environment_authoring.receiving_proof.audit_pass3_shell import audit_shell_v2

ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT / 'data/environment/receiving_proof/eaf5_receiving_shell_source.json'
COMPOSITION = ROOT / 'data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json'
CAPTURE = ROOT / 'reports/environment_receiving_proof/eaf5/shell_review_02/manifest.json'


class Pass3AShellAuditTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = json.loads(SOURCE.read_text(encoding='utf-8'))
        cls.composition = json.loads(COMPOSITION.read_text(encoding='utf-8'))
        cls.capture = json.loads(CAPTURE.read_text(encoding='utf-8'))

    def audit(self, capture=None, composition=None):
        return audit_shell_v2(self.source, composition or self.composition, capture or self.capture)

    def test_current_capture_has_clean_interior_ownership(self):
        result = self.audit()
        self.assertEqual(result['errors'], [])
        self.assertEqual(result['piece_count'], 14)
        self.assertEqual(result['perimeter_probe_count'], 52)
        self.assertEqual(result['corner_join_count'], 9)
        self.assertEqual(result['aperture_probe_count'], 27)
        for key in ('floor_perimeter_failures', 'ceiling_perimeter_failures', 'corner_ownership_failures', 'wall_end_face_failures', 'slab_side_face_failures', 'aperture_obstruction_failures'):
            self.assertEqual(result[key], 0, key)

    def test_exposed_floor_edge_is_detected(self):
        capture = copy.deepcopy(self.capture)
        floor = next(p for p in capture['pieces'] if p['piece_id'] == 'Floor_ReceivingApron')
        floor['exact_parameters']['dimensions_m'][0] = 10.0
        self.assertGreater(self.audit(capture)['floor_perimeter_failures'], 0)

    def test_missing_concealed_cap_is_detected(self):
        capture = copy.deepcopy(self.capture)
        wall = next(p for p in capture['pieces'] if p['piece_id'] == 'ReceivingSouth')
        wall['exact_parameters'].pop('concealed_faces')
        self.assertGreater(self.audit(capture)['wall_end_face_failures'], 0)

    def test_exposed_slab_side_is_detected(self):
        capture = copy.deepcopy(self.capture)
        slab = next(p for p in capture['pieces'] if p['piece_id'] == 'Floor_ReceivingApron')
        slab['exact_parameters']['concealed_faces'].remove('POS_Z')
        self.assertGreater(self.audit(capture)['slab_side_face_failures'], 0)

    def test_corner_gap_is_detected(self):
        capture = copy.deepcopy(self.capture)
        wall = next(p for p in capture['pieces'] if p['piece_id'] == 'ReceivingSouth')
        wall['exact_parameters']['dimensions_m'][0] -= 0.2
        self.assertGreater(self.audit(capture)['corner_ownership_failures'], 0)

    def test_full_height_opening_blocker_is_detected(self):
        capture = copy.deepcopy(self.capture)
        wall = next(p for p in capture['pieces'] if p['piece_id'] == 'DispatchSouthWest')
        wall['exact_parameters']['dimensions_m'][0] += 2.4
        self.assertGreater(self.audit(capture)['aperture_obstruction_failures'], 0)


if __name__ == '__main__':
    unittest.main()
