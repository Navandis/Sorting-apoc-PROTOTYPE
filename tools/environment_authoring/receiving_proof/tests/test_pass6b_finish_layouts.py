import hashlib
import json
import unittest
from collections import Counter
from pathlib import Path
from zipfile import ZipFile

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
FOLDER = BASE / "applied_finish_layouts_01"
ZIP = BASE / "eaf5_applied_finish_layout_review_01.zip"
DECISIONS = ROOT / "data/environment/receiving_proof/decisions/eaf5_applied_finish_screen_01_human_review_01.json"
EXPECTED = [
    "S01_L00", "S05_L00", "S06_L00",
    "V01_L01", "V01_L02", "V02_L01", "V02_L02",
    "V03_L01", "V03_L02", "V04_L01", "V04_L02",
    "Q01_L02", "Q02_L02",
]

class Pass6BLayoutTests(unittest.TestCase):
    def test_human_decisions(self):
        source = json.loads(DECISIONS.read_text(encoding="utf-8"))
        self.assertEqual(
            Counter(x["decision"] for x in source["configurations"]),
            {"CONTROL_NO_FINISH": 6, "KEEP_FINISH_VARIANT": 4, "HOLD_FINISH_VARIANT": 7, "DROP_FINISH_VARIANT": 19},
        )
        for entry in source["configurations"]:
            if entry["configuration_id"] in {"S05_A02", "S05_A03", "S06_A02", "S06_A03"}:
                self.assertNotIn("when held", entry["rationale"])
        self.assertEqual(
            hashlib.sha256((BASE / "eaf5_applied_finish_screen_01_review.zip").read_bytes()).hexdigest(),
            source["pass6a_review_package_sha256"],
        )

    def test_captures_and_controls(self):
        manifest = json.loads((FOLDER / "manifest.json").read_text(encoding="utf-8"))
        sanity = json.loads((FOLDER / "sanity/manifest.json").read_text(encoding="utf-8"))
        scale = json.loads((FOLDER / "scale_sanity/manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["configuration_ids"], EXPECTED)
        self.assertEqual(len(manifest["records"]), 52)
        self.assertEqual(len(sanity["records"]), 20)
        self.assertEqual(len(scale["records"]), 2)
        self.assertEqual(manifest["transient_uv_override_configuration_count"], 1)
        self.assertEqual(sanity["transient_uv_override_configuration_count"], 1)
        self.assertEqual(scale["transient_uv_override_configuration_count"], 0)
        self.assertEqual(len(manifest["pieces"]), 14)
        self.assertEqual(manifest["pieces"], sanity["pieces"], scale["pieces"])
        self.assertEqual(manifest["environment"], sanity["environment"], scale["environment"])
        self.assertFalse(manifest["eaf4_wear_enabled"])
        self.assertFalse(manifest["structural_secondary_enabled"])
        self.assertEqual(sum(c["transient_uv_override"] for c in manifest["configurations"]), 1)
        by_config = {}
        for record in manifest["records"]:
            by_config.setdefault(record["configuration_id"], []).append(record)
            with Image.open(FOLDER / record["filename"]) as image:
                image.verify()
            if record["layout_id"] == "L00":
                self.assertIsNone(record["finish_material_id"])
                self.assertIsNone(record["physical_size_m"])
            else:
                self.assertEqual(record["finish_piece"], "ReceivingSouth")
                self.assertTrue(all(abs(a - b) < 1e-5 for a, b in zip(record["patch_mesh_uv_extent_m"], record["physical_size_m"])))
                self.assertTrue(all(abs(a - b) < 1e-5 for a, b in zip(record["patch_mesh_size_m"], record["physical_size_m"])))
                self.assertEqual(record["patch_root_scale"], [1.0, 1.0, 1.0])
                self.assertEqual(record["effective_finish_mapping"], "UV")
        self.assertEqual({k: len(v) for k, v in by_config.items()}, {k: 4 for k in EXPECTED})
        for structural in ("S01", "S05", "S06"):
            for light in ("neutral_architectural", "receiving_target"):
                for camera in ("EastApproachOverview", "FinishField"):
                    current = FOLDER / f"{structural}_L00__{light}__{camera}.png"
                    prior = BASE / "applied_finish_screen_01" / f"{structural}_A00__{light}__{camera}.png"
                    with Image.open(current) as a, Image.open(prior) as b:
                        self.assertIsNone(ImageChops.difference(a.convert("RGB"), b.convert("RGB")).getbbox(), current.name)

    def test_package(self):
        manifest = json.loads((FOLDER / "manifest.json").read_text(encoding="utf-8"))
        template = json.loads((FOLDER / "decision_template.json").read_text(encoding="utf-8"))
        self.assertEqual(Counter(x["decision"] for x in template["configurations"]), {"CONTROL_NO_FINISH": 3, "PENDING": 10})
        allowlist = {r["filename"] for r in manifest["records"]}
        allowlist.update(f"contact_sheet_{i:02d}.png" for i in range(1, 4))
        allowlist.update({"manifest.json", "summary.md", "decision_template.json"})
        with ZipFile(ZIP) as archive:
            self.assertIsNone(archive.testzip())
            self.assertEqual(set(archive.namelist()), allowlist)
            for name in allowlist:
                if name.endswith(".png"):
                    with Image.open(archive.open(name)) as image:
                        image.verify()

if __name__ == "__main__":
    unittest.main()
