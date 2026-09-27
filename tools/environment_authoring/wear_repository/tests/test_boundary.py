"""Breaks caught: source traversal, link following, and config/CLI root bypass."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from tools.environment_authoring.wear_repository import path_guard as guard


class BoundaryTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.root = self.base / 'source'
        self.root.mkdir()
        (self.root / 'ok.txt').write_text('original')
        self.repo = guard.Repository(self.root)

    def test_containment_and_missing(self):
        with self.repo.open('ok.txt') as stream:
            self.assertEqual(stream.read(), b'original')
        for path in ('../outside.txt', str(self.base / 'outside.txt'), 'Z:/elsewhere/file.png', '/outside.png'):
            with self.subTest(path=path), self.assertRaises(guard.BoundaryError):
                self.repo.resolve(path)
        with self.assertRaises(FileNotFoundError):
            self.repo.resolve('missing.png')

    def test_real_junction_is_never_descended(self):
        outside = self.base / 'outside'
        outside.mkdir()
        (outside / 'secret.txt').write_text('must not read')
        link = self.root / 'escape'
        if os.name == 'nt':
            result = subprocess.run(['cmd', '/c', 'mklink', '/J', str(link), str(outside)], capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr)
        else:
            link.symlink_to(outside, target_is_directory=True)
        self.addCleanup(lambda: os.rmdir(link) if os.name == 'nt' else link.unlink())
        with self.assertRaises(guard.BoundaryError):
            self.repo.resolve('escape/secret.txt')
        self.assertEqual([p for p, _ in self.repo.walk_files()], ['ok.txt'])
        self.assertTrue(self.repo.warnings)
        with self.assertRaises(guard.BoundaryError):
            guard.Repository(link)

    def test_single_config_and_no_project_source(self):
        cfg = self.base / 'config.json'
        for data in ({'source_repository_root': str(self.root), 'roots': []},
                     {'source_repository_root': [str(self.root)]},
                     {'source_repository_root': '.'},
                     {'source_repository_root': str(guard.PROJECT_ROOT / 'tools')}):
            cfg.write_text(json.dumps(data))
            with self.subTest(data=data), self.assertRaises(ValueError):
                guard.load_repository(cfg)
        cfg.write_text(json.dumps({'source_repository_root': str(self.root)}))
        self.assertEqual(guard.load_repository(cfg).root, self.root.resolve())

    def test_production_cli_rejects_root_and_config_flags(self):
        for flag in ('--root', '--config'):
            result = subprocess.run([sys.executable, '-m',
                'tools.environment_authoring.wear_repository.scan_repository', flag, str(self.root)],
                capture_output=True, text=True)
            self.assertEqual(result.returncode, 2)
            self.assertIn('unrecognized arguments', result.stderr)


if __name__ == '__main__':
    unittest.main()
