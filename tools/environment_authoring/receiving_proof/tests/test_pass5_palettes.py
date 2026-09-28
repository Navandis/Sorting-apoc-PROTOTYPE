import json
import unittest
from collections import Counter
from pathlib import Path
from zipfile import ZipFile

from PIL import Image

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
FOLDER = BASE / "structural_palettes_01"
DECISIONS = ROOT / "data/environment/receiving_proof/decisions/eaf5_wall_floor_pairs_01_human_review_01.json"
PAIRS = ["W01_F02", "W01_F03", "W02_F02", "W03_F01", "W03_F02", "W04_F01", "W04_F02"]
CEILINGS = ["eaf3b_2dc87647fd382ad8287a0280", "eaf3b_6bcd8f817ca2993433e217cc", "eaf3b_71edb3fc983ed8f7655d9523", "eaf3b_d335d94fd85c2c95c26b6b8b", "eaf3b_800060297ab83f24c0fb0d75"]

class Pass5PaletteEvidenceTests(unittest.TestCase):
    def test_human_source_and_sanity_gate(self):
        decisions = json.loads(DECISIONS.read_text(encoding="utf-8"))
        self.assertEqual(Counter(d["decision"] for d in decisions["pairs"]), {"KEEP_PAIR": 7, "HOLD_PAIR": 2, "DROP_PAIR": 6})
        self.assertEqual([d["pair_id"] for d in decisions["pairs"] if d["decision"] == "KEEP_PAIR"], PAIRS)
        self.assertEqual([d["pair_id"] for d in decisions["pairs"] if d["decision"] == "HOLD_PAIR"], ["W03_F03", "W04_F03"])
        self.assertEqual([d["pair_id"] for d in decisions["pairs"] if d["decision"] == "DROP_PAIR"], ["W01_F01", "W02_F01", "W02_F03", "W05_F01", "W05_F02", "W05_F03"])
        self.assertTrue(all(d["notes"] for d in decisions["pairs"] if d["decision"] != "KEEP_PAIR"))
        sanity = json.loads((FOLDER / "sanity/manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(sanity["structural_palette_ids"], ["P01_C03", "P04_C01", "P07_C02"])
        self.assertEqual(len(sanity["records"]), 12)
        self.assertEqual(sanity["transient_uv_override_count"], 0)
        for record in sanity["records"]:
            self.assertEqual(record["effective_mapping"], {"wall": "UV", "floor": "UV", "ceiling": "UV"})
            self.assertEqual(len(record["piece_geometry_fingerprints"]), 14)
            with Image.open(FOLDER / "sanity" / record["filename"]) as image:
                image.verify()

    def test_full_matrix_and_package(self):
        manifest = json.loads((FOLDER / "manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["source_pair_ids"], PAIRS)
        self.assertEqual(manifest["ceiling_survivor_ids"], CEILINGS)
        self.assertEqual(len(manifest["palettes"]), 35)
        self.assertEqual(len(manifest["records"]), 140)
        self.assertEqual(sum(p["same_wall_ceiling_material"] for p in manifest["palettes"]), 4)
        self.assertEqual(manifest["pieces"], json.loads((FOLDER / "sanity/manifest.json").read_text(encoding="utf-8"))["pieces"])
        self.assertEqual(manifest["environment"], json.loads((FOLDER / "sanity/manifest.json").read_text(encoding="utf-8"))["environment"])
        self.assertEqual(manifest["review_context"], json.loads((FOLDER / "sanity/manifest.json").read_text(encoding="utf-8"))["review_context"])
        template = json.loads((FOLDER / "decision_template.json").read_text(encoding="utf-8"))
        self.assertEqual(template["allowed_decisions"], ["KEEP_PALETTE", "HOLD_PALETTE", "DROP_PALETTE"])
        self.assertEqual(len(template["palettes"]), 35)
        self.assertEqual({p["decision"] for p in template["palettes"]}, {"PENDING"})
        names = {r["filename"] for r in manifest["records"]}
        names.update(f"contact_sheet_{i:02d}.png" for i in range(1, 8))
        names.update({"manifest.json", "summary.md", "decision_template.json"})
        with ZipFile(BASE / "eaf5_structural_palette_review_01.zip") as archive:
            self.assertIsNone(archive.testzip())
            self.assertEqual(set(archive.namelist()), names)
            for name in names:
                if name.endswith(".png"):
                    with Image.open(archive.open(name)) as image:
                        image.verify()

if __name__ == "__main__":
    unittest.main()
