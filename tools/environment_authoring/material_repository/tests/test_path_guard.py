import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from tools.environment_authoring.material_repository.path_guard import Repository, BoundaryError, load_repository, PROJECT_ROOT


class GuardTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.root = self.base / 'source'
        self.root.mkdir()
        (self.root / 'inside.txt').write_text('inside')
        self.repo = Repository(self.root)

    def test_read_and_reject_escapes(self):
        with self.repo.open('inside.txt') as stream:
            self.assertEqual(stream.read(), b'inside')
        for path in ('../outside.txt', str(self.base / 'outside.txt'), 'Z:\\outside.txt', '/outside.txt'):
            with self.subTest(path=path), self.assertRaises(BoundaryError):
                self.repo.resolve(path)

    def test_config_single_absolute_root_no_fallback(self):
        config = self.base / 'config.json'
        config.write_text(json.dumps({'source_repository_root': str(self.root)}))
        self.assertEqual(load_repository(config).root, self.root.resolve())
        for value in ([], {'source_repository_root': [str(self.root)]},
                      {'source_repository_root': '.'}, {'source_repository_root': str(self.root), 'roots': []},
                      {'source_repository_root': str(self.base / 'missing')}):
            config.write_text(json.dumps(value))
            with self.subTest(value=value), self.assertRaises((ValueError, OSError)):
                load_repository(config)

    def test_reject_drive_root_and_project_root(self):
        for root in (Path(self.root.anchor), Path(__file__).resolve().parents[4]):
            with self.subTest(root=root), self.assertRaises(BoundaryError):
                Repository(root)

    def test_config_cannot_treat_project_subdirectory_as_source(self):
        config = self.base / 'config.json'
        config.write_text(json.dumps({'source_repository_root': str(PROJECT_ROOT / 'tools')}))
        with self.assertRaises(BoundaryError):
            load_repository(config)

    def test_junction_or_symlink_is_skipped(self):
        outside = self.base / 'outside'
        outside.mkdir()
        (outside / 'secret.txt').write_text('must not read')
        link = self.root / 'escape'
        if os.name == 'nt':
            result = subprocess.run(['cmd', '/c', 'mklink', '/J', str(link), str(outside)], capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
        else:
            link.symlink_to(outside, target_is_directory=True)
        self.addCleanup(lambda: link.rmdir() if os.name == 'nt' else link.unlink())
        with self.assertRaises(BoundaryError):
            self.repo.resolve('escape/secret.txt')
        self.assertEqual([p for p, _ in self.repo.walk_files()], ['inside.txt'])
        self.assertTrue(any('reparse' in w.lower() for w in self.repo.warnings))


if __name__ == '__main__':
    unittest.main()
