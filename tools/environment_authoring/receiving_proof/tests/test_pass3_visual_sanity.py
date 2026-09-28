from pathlib import Path
import unittest
from PIL import Image

ROOT = Path(__file__).resolve().parents[4]
SHELL = ROOT / 'reports/environment_receiving_proof/eaf5/shell_review_01'

class ShellReadabilityTests(unittest.TestCase):
    def test_neutral_overview_has_broad_readable_shell_surface(self):
        image = Image.open(SHELL / '01_EastApproachOverview.png').convert('RGB')
        image.thumbnail((320, 180))
        pixels = list(image.get_flattened_data())
        visible = sum(max(pixel) > 75 for pixel in pixels)
        self.assertGreater(visible / len(pixels), 0.45)

if __name__ == '__main__':
    unittest.main()
