import json
import unittest
from collections import Counter
from pathlib import Path
from zipfile import ZipFile

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
FOLDER = BASE / "applied_finish_screen_01"
DECISIONS = ROOT / "data/environment/receiving_proof/decisions/eaf5_structural_palettes_01_human_review_01.json"
FINALISTS = ["P01_C02", "P05_C02", "P04_C02", "P05_C03", "P01_C01", "P01_C05"]
FINISHES = ["eaf3b_7b12b8b3a2e05c502801d22f", "eaf3b_8d5f0cf5add98dfe0a58f18a", "eaf3b_9297ffec71774317b0627951", "eaf3b_b395eb3943870fbfd262e8ce", "eaf3b_c29826cd934f1534ecfb48c5"]

class Pass6AFinishScreenTests(unittest.TestCase):
    def test_human_source_and_sanity(self):
        source = json.loads(DECISIONS.read_text(encoding="utf-8"))
        self.assertEqual(Counter(x["decision"] for x in source["palettes"]), {"KEEP_PALETTE": 6, "HOLD_PALETTE": 9, "DROP_PALETTE": 20})
        self.assertEqual({x["structural_palette_id"] for x in source["palettes"] if x["decision"] == "KEEP_PALETTE"}, set(FINALISTS))
        sanity = json.loads((FOLDER / "sanity/manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(sanity["configuration_ids"], ["S01_A00", "S01_A02", "S02_A03", "S04_A04"])
        self.assertEqual(len(sanity["records"]), 16)
        self.assertEqual(sanity["transient_uv_finish_ids"], [FINISHES[1]])
        for record in sanity["records"]:
            self.assertEqual(record["finish_piece"], "ReceivingSouth")
            self.assertEqual(len(record["piece_geometry_fingerprints"]), 14)
            with Image.open(FOLDER / "sanity" / record["filename"]) as image:
                image.verify()

    def test_full_matrix_controls_and_package(self):
        manifest = json.loads((FOLDER / "manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["structural_finalist_palette_ids"], FINALISTS)
        self.assertEqual(manifest["finish_material_ids"], FINISHES)
        self.assertEqual(len(manifest["configurations"]), 36)
        self.assertEqual(len(manifest["records"]), 144)
        self.assertEqual(len([c for c in manifest["configurations"] if c["finish_id"] == "A00"]), 6)
        self.assertEqual(len([c for c in manifest["configurations"] if c["transient_uv_override"]]), 6)
        self.assertEqual(manifest["pieces"], json.loads((FOLDER / "sanity/manifest.json").read_text(encoding="utf-8"))["pieces"])
        template = json.loads((FOLDER / "decision_template.json").read_text(encoding="utf-8"))
        self.assertEqual(Counter(c["decision"] for c in template["configurations"]), {"CONTROL_NO_FINISH": 6, "PENDING": 30})
        names = {r["filename"] for r in manifest["records"]}
        names.update(f"contact_sheet_{i:02d}.png" for i in range(1, 7))
        names.update({"manifest.json", "summary.md", "decision_template.json"})
        with ZipFile(BASE / "eaf5_applied_finish_screen_01_review.zip") as archive:
            self.assertIsNone(archive.testzip())
            self.assertEqual(set(archive.namelist()), names)
            for name in names:
                if name.endswith(".png"):
                    with Image.open(archive.open(name)) as image:
                        image.verify()

    def test_no_finish_controls_reproduce_structural_capture(self):
        for index, palette in enumerate(FINALISTS, 1):
            for light in ("neutral_architectural", "receiving_target"):
                current = FOLDER / f"S{index:02d}_A00__{light}__EastApproachOverview.png"
                accepted = BASE / "structural_palettes_01" / f"{palette}__{light}__EastApproachOverview.png"
                with Image.open(current) as a, Image.open(accepted) as b:
                    self.assertIsNone(ImageChops.difference(a.convert("RGB"), b.convert("RGB")).getbbox(), str(current))

if __name__ == "__main__":
    unittest.main()
