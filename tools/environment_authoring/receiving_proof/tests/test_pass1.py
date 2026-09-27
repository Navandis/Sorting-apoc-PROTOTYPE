import copy
import json
from pathlib import Path
import unittest

from tools.environment_authoring.receiving_proof.build_pass1_review import (
    validate_shell, validate_shortlist, validate_approved_seed_set,
)


ROOT = Path(__file__).resolve().parents[4]
DATA = ROOT / 'data/environment/receiving_proof'


class Pass1ManifestTests(unittest.TestCase):
    def test_saved_shell_maps_without_missing_topology(self):
        shell = json.loads((DATA / 'eaf5_receiving_shell_source.json').read_text())
        counts = validate_shell(shell)
        self.assertEqual(counts, {'source_elements': 21, 'mapped_pieces': 19, 'composition_openings': 2,
                                  'missing_topology': 0})
        broken = copy.deepcopy(shell)
        broken['openings'][1]['clear_height_m'] = 4.3
        with self.assertRaisesRegex(ValueError, 'opening height'):
            validate_shell(broken)

    def test_shortlist_rejects_warned_or_historically_rejected_source(self):
        shortlist = json.loads((DATA / 'eaf5_material_source_shortlist_01.json').read_text())
        first = shortlist['candidates'][0]
        index = {'material_candidates': [{
            'stable_id': first['source_stable_id'], 'warnings': first['warnings'],
            'suggested_family': first['source_family'], 'quick_fingerprint': 'x',
        }]}
        mini = copy.deepcopy(shortlist)
        mini['candidates'] = [first]
        mini['source_index_fingerprint'] = None
        validate_shortlist(mini, index, [])
        index['material_candidates'][0]['warnings'] = ['atlas_trim_or_object_specific_name;tileability_unverified']
        with self.assertRaisesRegex(ValueError, 'structural warning'):
            validate_shortlist(mini, index, [])
        index['material_candidates'][0]['warnings'] = first['warnings']
        catalog = [{'source_stable_id': first['source_stable_id'], 'status': 'REJECTED'}]
        with self.assertRaisesRegex(ValueError, 'REJECTED'):
            validate_shortlist(mini, index, catalog)

    def test_all_five_approved_seeds_must_be_in_role_sheets(self):
        shortlist = json.loads((DATA / 'eaf5_material_source_shortlist_01.json').read_text())
        validate_approved_seed_set(shortlist)
        broken = copy.deepcopy(shortlist)
        broken['candidates'] = [c for c in broken['candidates']
                                if c['existing_catalog_material_id'] != 'eaf3b_1435ce254f04bb8e61bd3e96']
        with self.assertRaisesRegex(ValueError, 'five approved'):
            validate_approved_seed_set(broken)


if __name__ == '__main__':
    unittest.main()
