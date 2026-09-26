"""The only external source I/O boundary. No discovery or fallback roots."""
from contextlib import contextmanager
import json
import os
from pathlib import Path, PureWindowsPath
import stat

PROJECT_ROOT = Path(__file__).resolve().parents[3]
LOCAL_CONFIG = Path(__file__).with_name('local_config.json')


class BoundaryError(ValueError):
    pass


def is_reparse(info):
    return stat.S_ISLNK(info.st_mode) or bool(getattr(info, 'st_file_attributes', 0) & 0x400)


class Repository:
    """Inject this reader for synthetic tests; production uses load_repository().

    Reject all reparse entries, including in-root links. Guard again at every
    enumeration/stat/open. Source trees must remain quiescent during a scan;
    this portable path guard is not a hostile concurrent filesystem sandbox.
    """
    def __init__(self, root):
        raw = Path(root)
        if not raw.is_absolute():
            raise BoundaryError('Repository root must be absolute')
        self.root = raw.resolve(strict=True)
        if self.root == Path(self.root.anchor):
            raise BoundaryError('A drive/filesystem root is not a repository')
        if self.root == PROJECT_ROOT or self.root in PROJECT_ROOT.parents:
            raise BoundaryError('The project or its parents cannot be a source repository')
        if not self.root.is_dir():
            raise BoundaryError('Repository root must be a directory')
        self.warnings = []

    def resolve(self, candidate):
        text = str(candidate)
        win = PureWindowsPath(text)
        path = Path(text)
        if win.drive and (os.name != 'nt' or win.drive.lower() != self.root.drive.lower()):
            raise BoundaryError('Different-drive source path rejected')
        path = path if path.is_absolute() else self.root / path
        # Check lexical containment before reading even the metadata of a path.
        path = Path(os.path.abspath(path))
        if not path.is_relative_to(self.root):
            raise BoundaryError('Source path escapes configured repository')
        current = self.root
        # Also reject replacement of the canonical root with a junction.
        if self.root.resolve(strict=True) != self.root:
            raise BoundaryError('Configured root changed during operation')
        for part in path.relative_to(self.root).parts:
            current = current / part
            if is_reparse(current.lstat()):
                raise BoundaryError('Reparse/symlink source path rejected')
        resolved = path.resolve(strict=True)
        if not resolved.is_relative_to(self.root):
            raise BoundaryError('Canonical source path escapes configured repository')
        return resolved

    def stat(self, relative):
        return self.resolve(relative).stat()

    @contextmanager
    def open(self, relative):
        with self.resolve(relative).open('rb') as stream:
            yield stream

    def entries(self, relative='.'):
        directory = self.resolve(relative)
        with os.scandir(directory) as scan:
            names = sorted((entry.name for entry in scan), key=lambda x: (x.casefold(), x))
        result = []
        for name in names:
            rel = (Path(relative) / name).as_posix()
            try:
                guarded = self.resolve(rel)
                info = guarded.stat()
                result.append((rel, info))
            except BoundaryError:
                self.warnings.append(f'Skipped reparse/unsafe path: {rel}')
        return result

    def walk_files(self, relative='.'):
        for rel, info in self.entries(relative):
            if stat.S_ISDIR(info.st_mode):
                yield from self.walk_files(rel)
            elif stat.S_ISREG(info.st_mode):
                yield rel, info
            else:
                self.warnings.append(f'Skipped non-regular source: {rel}')


def load_repository(config_path=LOCAL_CONFIG):
    data = json.loads(Path(config_path).read_text(encoding='utf-8-sig'))
    if not isinstance(data, dict) or set(data) != {'source_repository_root'}:
        raise ValueError('Config must contain only source_repository_root')
    root = data['source_repository_root']
    if not isinstance(root, str) or not root.strip():
        raise ValueError('source_repository_root must be one absolute path string')
    repository = Repository(root)
    if repository.root.is_relative_to(PROJECT_ROOT):
        raise BoundaryError('Project directories cannot be configured as a source repository')
    return repository
