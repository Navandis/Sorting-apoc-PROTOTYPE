import copy
import json
from pathlib import Path
import unittest

from tools.environment_authoring.receiving_proof.audit_pass3_shell import audit_shell

ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT / 'data/environment/receiving_proof/eaf5_receiving_shell_source.json'
CAPTURE = ROOT / 'reports/environment_receiving_proof/eaf5/shell_review_01/manifest.json'

class ShellAuditTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = json.loads(SOURCE.read_text(encoding='utf-8'))
        cls.capture = json.loads(CAPTURE.read_text(encoding='utf-8'))

    def test_generated_shell_matches_accepted_source_and_contact_contract(self):
        result = audit_shell(self.source, self.capture)
        self.assertEqual(result['errors'], [])
        self.assertEqual(result['piece_count'], 19)
        self.assertEqual(result['recipes'], {'rect_solid': 18, 'wall_with_rect_opening': 1})
        self.assertEqual(result['apertures_m'], {'west_freight': 5.0, 'east_backlog_width': 3.84, 'east_backlog_height': 3.4, 'dispatch': 2.4})

    def test_changed_generated_dimension_is_rejected(self):
        capture = copy.deepcopy(self.capture)
        next(record for record in capture['pieces'] if record['piece_id'] == 'Floor_ReceivingApron')['exact_parameters']['dimensions_m'][0] = 10.0
        self.assertTrue(any('dimension' in error for error in audit_shell(self.source, capture)['errors']))

    def test_changed_return_placement_breaks_contact_audit(self):
        capture = copy.deepcopy(self.capture)
        next(record for record in capture['pieces'] if record['piece_id'] == 'ReceivingWestSouthReturn')['position_local_m'][2] = 3.85
        self.assertTrue(any('aperture' in error or 'contact' in error for error in audit_shell(self.source, capture)['errors']))

    def test_changed_uv_phase_is_rejected(self):
        capture = copy.deepcopy(self.capture)
        next(record for record in capture['pieces'] if record['piece_id'] == 'Floor_ReceivingApron')['uv_origin_m'][0] += 0.5
        self.assertTrue(any('UV phase' in error for error in audit_shell(self.source, capture)['errors']))

    def test_duplicate_coplanar_wall_is_rejected(self):
        capture = copy.deepcopy(self.capture)
        duplicate = copy.deepcopy(next(record for record in capture['pieces'] if record['piece_id'] == 'ReceivingSouth'))
        duplicate['piece_id'] = 'DuplicateSouth'
        capture['pieces'].append(duplicate)
        self.assertTrue(any('duplicate coplanar wall' in error for error in audit_shell(self.source, capture)['errors']))

    def test_duplicate_coplanar_wall_is_rejected(self):
        capture = copy.deepcopy(self.capture)
        duplicate = copy.deepcopy(next(record for record in capture['pieces'] if record['piece_id'] == 'ReceivingSouth'))
        duplicate['piece_id'] = 'DuplicateSouth'
        capture['pieces'].append(duplicate)
        self.assertTrue(any('duplicate coplanar wall' in error for error in audit_shell(self.source, capture)['errors']))

    def test_duplicate_coplanar_wall_is_rejected(self):
        capture = copy.deepcopy(self.capture)
        duplicate = copy.deepcopy(next(record for record in capture['pieces'] if record['piece_id'] == 'ReceivingSouth'))
        duplicate['piece_id'] = 'DuplicateSouth'
        capture['pieces'].append(duplicate)
        self.assertTrue(any('duplicate coplanar wall' in error for error in audit_shell(self.source, capture)['errors']))

if __name__ == '__main__':
    unittest.main()
