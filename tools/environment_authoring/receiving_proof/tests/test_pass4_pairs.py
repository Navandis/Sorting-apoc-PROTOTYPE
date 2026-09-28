import json
import unittest
from collections import Counter
from pathlib import Path
from zipfile import ZipFile

from PIL import Image

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
DECISIONS = ROOT / "data/environment/receiving_proof/decisions/eaf5_role_isolation_02_human_review_01.json"


class Pass4PairEvidenceTests(unittest.TestCase):
    def test_role_decision_counts_and_ordered_pair_sources(self):
        decisions = json.loads(DECISIONS.read_text(encoding="utf-8"))["decisions"]
        self.assertEqual(len(decisions), 33)
        self.assertEqual(Counter((d["role"], d["decision"]) for d in decisions), Counter({
            ("WALL_PRIMARY", "KEEP"): 5, ("WALL_PRIMARY", "HOLD"): 7, ("WALL_PRIMARY", "DROP_FOR_RECEIVING"): 2,
            ("FLOOR_PRIMARY", "KEEP"): 3, ("FLOOR_PRIMARY", "HOLD"): 3, ("FLOOR_PRIMARY", "DROP_FOR_RECEIVING"): 2,
            ("CEILING_PRIMARY", "KEEP"): 5, ("CEILING_PRIMARY", "HOLD"): 3, ("CEILING_PRIMARY", "DROP_FOR_RECEIVING"): 3,
        }))
        manifest = json.loads((BASE / "wall_floor_pairs_01/manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["pair_ids"], [f"W{wi:02d}_F{fi:02d}" for wi in range(1, 6) for fi in range(1, 4)])
        self.assertEqual([pair["pair_id"] for pair in manifest["pairs"]], manifest["pair_ids"])
        self.assertEqual(len(manifest["ceiling_survivor_ids_for_later"]), 5)
        self.assertEqual(len(manifest["records"]), 60)
        self.assertTrue(manifest["palette_pairs_generated"])
        for record in manifest["records"]:
            self.assertNotEqual(record["wall_catalog_material_id"], record["floor_catalog_material_id"])
            self.assertEqual(record["effective_mapping"], {"wall": "UV", "floor": "UV"})
            self.assertEqual(record["ceiling_material"], "eaf5_review_control_only")
            self.assertEqual(len(record["piece_geometry_fingerprints"]), 14)

    def test_package_and_sanity_gate(self):
        folder = BASE / "wall_floor_pairs_01"
        manifest = json.loads((folder / "manifest.json").read_text(encoding="utf-8"))
        sanity = json.loads((folder / "sanity/manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(sanity["pair_ids"], ["W01_F01", "W03_F02", "W05_F03"])
        self.assertEqual(len(sanity["records"]), 12)
        self.assertEqual(sanity["proof_composition_sha256"], manifest["proof_composition_sha256"])
        self.assertEqual(sanity["pieces"], manifest["pieces"])
        self.assertEqual(sanity["environment"], manifest["environment"])
        self.assertEqual(sanity["review_context"], manifest["review_context"])
        expected = {r["filename"] for r in manifest["records"]}
        expected.update({f"contact_sheet_{n:02d}.png" for n in range(1, 4)})
        expected.update({"manifest.json", "summary.md", "decision_template.json"})
        template = json.loads((folder / "decision_template.json").read_text(encoding="utf-8"))
        self.assertEqual(template["allowed_decisions"], ["KEEP_PAIR", "HOLD_PAIR", "DROP_PAIR"])
        self.assertEqual(len(template["pairs"]), 15)
        self.assertEqual({entry["decision"] for entry in template["pairs"]}, {"PENDING"})
        with ZipFile(BASE / "eaf5_wall_floor_pair_review_01.zip") as archive:
            self.assertIsNone(archive.testzip())
            self.assertEqual(set(archive.namelist()), expected)
            for name in expected:
                if name.endswith(".png"):
                    with Image.open(archive.open(name)) as image:
                        image.verify()


if __name__ == "__main__":
    unittest.main()
