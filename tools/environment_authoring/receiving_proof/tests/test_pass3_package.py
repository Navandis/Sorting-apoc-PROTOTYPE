import json
from pathlib import Path
import tempfile
import unittest
from zipfile import ZipFile
from PIL import Image

from tools.environment_authoring.receiving_proof.build_pass3_review import build_role_package, build_shell_package

class Pass3PackageTests(unittest.TestCase):
    def test_role_package_has_exact_four_view_matrix_and_safe_members(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            role_dir = root / 'wall'
            role_dir.mkdir()
            records = []
            for material in ('eaf3b_a', 'eaf3b_b'):
                for light in ('NEUTRAL_ARCHITECTURAL', 'RECEIVING_TARGET'):
                    for camera in ('EastApproachOverview', 'WallDominant'):
                        filename = f'{material}__{light}__{camera}.png'
                        Image.new('RGB', (32, 18), (128, 128, 128)).save(role_dir / filename)
                        records.append({'catalog_material_id': material, 'display_name': material, 'role': 'WALL_PRIMARY', 'light_mode': light, 'camera': camera, 'filename': filename})
            (role_dir / 'manifest.json').write_text(json.dumps({'role': 'WALL_PRIMARY', 'candidate_ids': ['eaf3b_a', 'eaf3b_b'], 'records': records}), encoding='utf-8')
            (role_dir / 'commercial_map.png').write_bytes(b'forbidden')
            package = root / 'wall.zip'
            result = build_role_package(role_dir, package)
            self.assertEqual(result['captures'], 8)
            self.assertEqual(result['contact_sheets'], 1)
            with ZipFile(package) as zip_file:
                names = zip_file.namelist()
                self.assertEqual(len(names), 12)
                self.assertFalse(any('commercial_map' in name for name in names))
                decisions = json.loads(zip_file.read('decision_template.json'))
                self.assertEqual([item['decision'] for item in decisions['candidates']], ['PENDING', 'PENDING'])

    def test_v2_shell_package_contains_only_eight_fixed_views_and_review_files(self):
        cameras = ('EastApproachOverview', 'FreightAperture', 'FreightRecess', 'EastOpening', 'DispatchOpening', 'UpperCeilingContext', 'JoinAudit_Apron', 'JoinAudit_Dispatch')
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            records = []
            for index, camera in enumerate(cameras, 1):
                filename = f'{index:02d}_{camera}.png'
                Image.new('RGB', (32, 18), (128, 128, 128)).save(root / filename)
                records.append({'camera': camera, 'filename': filename})
            (root / 'manifest.json').write_text(json.dumps({'schema_version': 2, 'capture_type': 'NEUTRAL_SHELL', 'proof_composition_sha256': 'a' * 64, 'pieces': [{}] * 14, 'records': records}), encoding='utf-8')
            (root / 'commercial_map.png').write_bytes(b'forbidden')
            package = root / 'shell.zip'
            result = build_shell_package(root, package)
            self.assertEqual(result['captures'], 8)
            with ZipFile(package) as archive:
                self.assertEqual(len(archive.namelist()), 12)
                self.assertNotIn('commercial_map.png', archive.namelist())
                self.assertEqual(json.loads(archive.read('decision_template.json'))['shell_decision'], 'PENDING')
                self.assertIn('v1 role packages', archive.read('summary.md').decode())

    def test_shell_package_rejects_missing_fixed_capture(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / 'manifest.json').write_text(json.dumps({'capture_type': 'NEUTRAL_SHELL', 'records': [{'filename': 'missing.png'}]}), encoding='utf-8')
            with self.assertRaises(ValueError):
                build_shell_package(root, root / 'shell.zip')

if __name__ == '__main__':
    unittest.main()
