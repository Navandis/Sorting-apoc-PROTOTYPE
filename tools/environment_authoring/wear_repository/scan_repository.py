"""Read-only EAF4 scan; no production root/config override."""
import argparse


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.parse_args()
    from .path_guard import load_repository
    from .source_index import scan, save_scan
    try:
        print(save_scan(scan(load_repository())))
    except (OSError, ValueError) as error:
        parser.exit(1, f'Scan failed; no fallback search: {error}\n')


if __name__ == '__main__':
    main()
