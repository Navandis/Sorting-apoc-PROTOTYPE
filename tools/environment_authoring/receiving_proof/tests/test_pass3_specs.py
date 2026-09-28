import json
from pathlib import Path
import tempfile
import unittest

from tools.environment_authoring.receiving_proof.build_pass3_specs import build_specs, piece_role, uv_phase

ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT / 'data/environment/receiving_proof/eaf5_receiving_shell_source.json'


class Pass3SpecTests(unittest.TestCase):
    def test_accepted_shell_generates_nineteen_standard_specs(self):
        manifest = json.loads(SOURCE.read_text(encoding='utf-8'))
        with tempfile.TemporaryDirectory() as folder:
            paths = build_specs(manifest, Path(folder))
            self.assertEqual(len(paths), 19)
            text = {p.stem: p.read_text(encoding='utf-8') for p in paths}
        self.assertEqual(sum('recipe_id = "rect_solid"' in v for v in text.values()), 18)
        self.assertEqual(sum('recipe_id = "wall_with_rect_opening"' in v for v in text.values()), 1)
        self.assertIn('dimensions_m = Vector3(10.5, 0.3, 10.0)', text['Floor_ReceivingApron'])
        self.assertIn('dimensions_m = Vector3(10.0, 4.2, 0.3)', text['ReceivingEastOpeningWall'])
        self.assertIn('opening_width_m = 3.84', text['ReceivingEastOpeningWall'])
        self.assertIn('opening_height_m = 3.4', text['ReceivingEastOpeningWall'])
        self.assertTrue(all('bevel_width_m = 0.0' in v and 'collision_policy = 0' in v for v in text.values()))
        self.assertTrue(all('EnvironmentSubstratePieceSpec' in v for v in text.values()))

    def test_roles_and_uv_phase_keep_accepted_apertures_continuous(self):
        self.assertEqual(piece_role('Floor_DispatchAnnex'), 'CONTEXT_ONLY')
        self.assertEqual(piece_role('Floor_FreightEnclosure'), 'FLOOR_PRIMARY')
        self.assertEqual(piece_role('FreightRear'), 'FREIGHT_RECESS_WALL')
        self.assertEqual(piece_role('ReceivingWestNorthReturn'), 'OPENING_REVEAL')
        self.assertEqual(piece_role('DispatchSouthWest'), 'WALL_PRIMARY')
        self.assertEqual(uv_phase({'dimensions_m': [3.8, 4.2, 0.3], 'center_local_m': [2.9, 2.1, -5], 'rotation_y_degrees': 0, 'semantic_role': 'wall'}), (1.0, 0.0))
        self.assertEqual(uv_phase({'dimensions_m': [3.45, 4.2, 0.3], 'center_local_m': [8.925, 2.1, -5], 'rotation_y_degrees': 0, 'semantic_role': 'wall'}), (7.2, 0.0))
        self.assertEqual(uv_phase({'dimensions_m': [2.5, 4.2, 0.3], 'center_local_m': [0, 2.1, -3.75], 'rotation_y_degrees': 90, 'semantic_role': 'wall'}), (2.5, 0.0))
        self.assertEqual(uv_phase({'dimensions_m': [2.5, 4.2, 0.3], 'center_local_m': [0, 2.1, 3.75], 'rotation_y_degrees': 90, 'semantic_role': 'wall'}), (-5.0, 0.0))


if __name__ == '__main__':
    unittest.main()
