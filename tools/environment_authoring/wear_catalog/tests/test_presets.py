import copy
import importlib.util
import json
from pathlib import Path
import re
import tempfile
import unittest

MODULE = Path(__file__).resolve().parents[1] / 'build_presets.py'
spec = importlib.util.spec_from_file_location('presets', MODULE)
presets = importlib.util.module_from_spec(spec)
spec.loader.exec_module(presets)
ROOT = MODULE.parents[3]

class PresetAuditTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.entry = copy.deepcopy(next(e for e in json.loads((ROOT / presets.CATALOG).read_text())['wear'] if e['effective_status'] == 'APPROVED' and not e['patch_mode']))
        self.path = self.root / 'data/environment/wear_catalog/approved_specs' / (self.entry['catalog_wear_id'] + '.tres')
        self.path.parent.mkdir(parents=True)
        self.original = (ROOT / self.path.relative_to(self.root)).read_text()
        self.path.write_text(self.original)
        for dependency in re.findall(r'path="res://([^"]+)"', self.original):
            target = self.root / dependency
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text('dependency exists')
        self.save_catalog()
    def save_catalog(self):
        target = self.root / presets.CATALOG
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps({'schema_version': 1, 'wear': [self.entry]}))
    def test_current_real_catalog_has_no_eligible_blockers(self):
        items = presets.audit(ROOT)
        self.assertTrue(any(item['eligible'] for item in items))
        self.assertFalse([item for item in items if item['eligible'] and item['blocked']])
    def test_missing_asset_blocks_generation_without_partial_library(self):
        dependency = re.findall(r'path="res://([^"]+)"', self.original)[-1]
        (self.root / dependency).unlink()
        with self.assertRaisesRegex(ValueError, 'missing dependency'):
            presets.build(self.root)
        self.assertFalse((self.root / presets.PRESETS).exists())
    def test_stale_approval_blocks_generation(self):
        self.entry['current_source_fingerprint'] = 'changed'
        self.save_catalog()
        with self.assertRaisesRegex(ValueError, 'stale approval'):
            presets.build(self.root)
    def test_mismapped_spec_blocks_generation(self):
        self.path.write_text(self.original.replace(self.entry['source_stable_id'], 'wrong-source'))
        with self.assertRaisesRegex(ValueError, 'mismatched source identity'):
            presets.build(self.root)
    def test_approved_patch_uses_supported_material_patch_path(self):
        self.entry['patch_mode'] = 'EAF4_SOURCE'
        self.save_catalog()
        presets.build(self.root)
        scene = next((self.root / presets.PRESETS).glob('*.tscn')).read_text()
        self.assertIn(presets.PATCH, scene)
        self.assertIn('mode = 1', scene)
        self.assertIn('wear_spec = ExtResource("2")', scene)
        self.assertNotIn('approved_source =', scene)
    def test_unknown_patch_mode_is_explicitly_blocked(self):
        self.entry['patch_mode'] = 'UNKNOWN'
        self.save_catalog()
        with self.assertRaisesRegex(ValueError, 'unsupported patch mode'):
            presets.build(self.root)
    def test_check_reports_wrapper_drift(self):
        presets.build(self.root)
        path = next((self.root / presets.PRESETS).glob('*.tscn'))
        path.write_text(path.read_text().replace('approved_source =', 'wrong ='))
        with self.assertRaisesRegex(ValueError, 'outdated preset'):
            presets.build(self.root, check=True)
    def test_obsolete_wrapper_is_reported_not_deleted(self):
        presets.build(self.root)
        obsolete = self.root / presets.PRESETS / 'old.tscn'
        obsolete.write_text('preserve for explicit review')
        with self.assertRaisesRegex(ValueError, 'Obsolete wrappers'):
            presets.build(self.root)
        self.assertTrue(obsolete.exists())

if __name__ == '__main__':
    unittest.main()
