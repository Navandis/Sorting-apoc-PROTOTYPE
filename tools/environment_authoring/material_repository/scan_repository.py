"""Scan only the machine-local configured source repository, read-only."""
import argparse

try:
    from .path_guard import load_repository
    from .source_index import INDEX_PATH, DIFF_PATH, REPORT_DIR, load_index, scan, diff_indexes, write_json, summary_text
except ImportError:
    from path_guard import load_repository
    from source_index import INDEX_PATH, DIFF_PATH, REPORT_DIR, load_index, scan, diff_indexes, write_json, summary_text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    try:
        repository = load_repository()
        previous = load_index() if INDEX_PATH.exists() else None
        current = scan(repository)
        diff = diff_indexes(previous, current)
        write_json(INDEX_PATH, current)
        write_json(DIFF_PATH, diff)
        summary = summary_text(current, diff)
        (REPORT_DIR / 'scan_summary.txt').write_text(summary, encoding='utf-8')
        print(summary)
    except (OSError, ValueError) as error:
        parser.exit(1, f'Scan failed; no fallback search: {error}\n')


if __name__ == '__main__':
    main()
