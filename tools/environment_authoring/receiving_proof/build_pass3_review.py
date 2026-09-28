"""Build shareable EAF5 Pass-3 review packages from captured PNGs only."""
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED

from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[3]
REPORT = ROOT / 'reports/environment_receiving_proof/eaf5'
ROLE_VIEW = {'WALL_PRIMARY': 'WallDominant', 'FLOOR_PRIMARY': 'FloorRead', 'CEILING_PRIMARY': 'CeilingRead'}
MODES = ('NEUTRAL_ARCHITECTURAL', 'RECEIVING_TARGET')
CRITERIA = {
    'WALL_PRIMARY': 'Room-scale repetition, large quiet-area potential, baked localized wear, value under both rigs, mineral/service-infrastructure identity, opening/reveal behavior, and visual bandwidth for later fixtures/signage.',
    'FLOOR_PRIMARY': 'Grid/panel repetition, loot contrast, baked traffic patterns, value, noise level, and freight-floor continuity.',
    'CEILING_PRIMARY': 'Overhead repetition, value/darkness, visual compression, future service readability, and mineral slab identity.',
}


def _font(size):
    try:
        return ImageFont.truetype('C:/Windows/Fonts/arial.ttf', size)
    except OSError:
        return ImageFont.load_default()


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def _load_manifest(folder: Path) -> dict:
    return json.loads((folder / 'manifest.json').read_text(encoding='utf-8'))


def _check_images(folder: Path, names: list[str]) -> None:
    for name in names:
        if Path(name).name != name or not name.endswith('.png'):
            raise ValueError(f'unsafe capture name: {name}')
        path = folder / name
        if not path.is_file():
            raise ValueError(f'missing capture: {path}')
        with Image.open(path) as image:
            image.verify()


def _thumbnail(path: Path, size=(700, 394)) -> Image.Image:
    with Image.open(path) as original:
        image = original.convert('RGB')
        return ImageOps.fit(image, size, Image.Resampling.LANCZOS)


def _role_sheets(folder: Path, manifest: dict) -> list[Path]:
    by_id = {}
    for record in manifest['records']:
        by_id.setdefault(record['catalog_material_id'], {})[(record['light_mode'], record['camera'])] = record
    role = manifest['role']
    pages = []
    for start in range(0, len(manifest['candidate_ids']), 4):
        ids = manifest['candidate_ids'][start:start + 4]
        page = Image.new('RGB', (1480, 125 + len(ids) * 920), (244, 244, 242))
        draw = ImageDraw.Draw(page)
        draw.text((24, 20), f'EAF5 {role}   {start // 4 + 1}', fill=(25, 25, 25), font=_font(36))
        for row, material_id in enumerate(ids):
            records = by_id[material_id]
            y = 90 + row * 920
            representative = next(iter(records.values()))
            name = representative['display_name']
            draw.text((24, y), f'{name}   {material_id}', fill=(20, 20, 20), font=_font(28))
            marker = ' | TRANSIENT UV OVERRIDE' if representative.get('transient_uv_review_override') else ''
            details = f"{role} | {representative.get('surface_family', 'unknown family')} | {representative.get('meters_per_repeat', '?')} m/repeat | {representative.get('effective_review_mapping', '?')}{marker}"
            draw.text((24, y + 33), details, fill=(35, 35, 35), font=_font(20))
            for col, (light, camera) in enumerate(((MODES[0], 'EastApproachOverview'), (MODES[1], 'EastApproachOverview'), (MODES[0], ROLE_VIEW[role]), (MODES[1], ROLE_VIEW[role]))):
                x = 24 + (col % 2) * 730
                top = y + 74 + (col // 2) * 410
                thumb = _thumbnail(folder / records[(light, camera)]['filename'])
                page.paste(thumb, (x, top + 23))
                label = ('Neutral' if light == MODES[0] else 'Receiving') + ' / ' + ('Overall' if camera == 'EastApproachOverview' else camera)
                draw.text((x, top), label, fill=(40, 40, 40), font=_font(19))
        path = folder / f'contact_sheet_{start // 4 + 1:02d}.png'
        page.save(path, optimize=True)
        pages.append(path)
    return pages


def _write_zip(output: Path, folder: Path, names: list[str]) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(output, 'w', ZIP_DEFLATED, compresslevel=6) as archive:
        for name in names:
            archive.write(folder / name, arcname=name)
    with ZipFile(output) as archive:
        if archive.testzip() is not None or sorted(archive.namelist()) != sorted(names):
            raise ValueError(f'package integrity failed: {output}')


def build_role_package(folder: Path, output: Path) -> dict:
    manifest = _load_manifest(folder)
    role = manifest['role']
    if role not in ROLE_VIEW:
        raise ValueError('unknown role')
    ids = manifest['candidate_ids']
    if not ids or ids != sorted(set(ids)):
        raise ValueError('candidate IDs must be unique and sorted')
    expected = {(material_id, light, camera) for material_id in ids for light in MODES for camera in ('EastApproachOverview', ROLE_VIEW[role])}
    records = manifest['records']
    actual = {(item['catalog_material_id'], item['light_mode'], item['camera']) for item in records}
    if actual != expected or len(records) != len(expected):
        raise ValueError('role capture matrix differs from four fixed views per candidate')
    names = [item['filename'] for item in records]
    if len(set(names)) != len(names):
        raise ValueError('duplicate capture filenames')
    _check_images(folder, names)
    pages = _role_sheets(folder, manifest)
    decisions = {'role': role, 'allowed_decisions': ['KEEP', 'DROP_FOR_RECEIVING', 'HOLD'], 'candidates': []}
    for material_id in ids:
        first = next(item for item in records if item['catalog_material_id'] == material_id)
        decisions['candidates'].append({'catalog_material_id': material_id, 'display_name': first['display_name'], 'decision': 'PENDING', 'notes': ''})
    (folder / 'decision_template.json').write_text(json.dumps(decisions, indent=2) + '\n', encoding='utf-8')
    summary = f'# EAF5 {role} room role isolation - accepted Pass-3A v2 shell\n\n{len(ids)} current APPROVED candidates, four captures each. Other major roles use the EAF5 tooling-only grey control. The Pass 3A shell is HUMAN-ACCEPTED for role review; role-survivor decisions remain PENDING.\n\nJudge: {CRITERIA[role]}\n\nReview conditions: wear is OFF; applied finish is OFF; do not judge whether wear could fix a weak material. Structural secondary and palette pairing are OFF. DROP_FOR_RECEIVING does not revoke EAF3 approval.\n\nKnown freight/elevator enclosure oddity: NON-BLOCKING DEFERRED FOLLOW-UP. It is not resolved in this package.\n\n'
    if role == 'WALL_PRIMARY':
        summary += 'The east EAF2 opening is one mesh with piers and reveals. For a wall candidate without opening_reveal approval, that entire composite wall stays on control; the manifest flags this per capture.\n\n'
    summary += '\n'.join(f'- {item["display_name"]} — {item["catalog_material_id"]}' for item in decisions['candidates']) + '\n'
    (folder / 'summary.md').write_text(summary, encoding='utf-8')
    allowlist = names + [page.name for page in pages] + ['manifest.json', 'summary.md', 'decision_template.json']
    _write_zip(output, folder, allowlist)
    return {'role': role, 'candidates': len(ids), 'captures': len(records), 'contact_sheets': len(pages), 'zip': str(output), 'sha256': _sha256(output)}


def build_shell_package(folder: Path, output: Path) -> dict:
    manifest = _load_manifest(folder)
    records = manifest['records']
    v2 = manifest.get('schema_version') == 2
    expected_cameras = ('EastApproachOverview', 'FreightAperture', 'FreightRecess', 'EastOpening', 'DispatchOpening', 'UpperCeilingContext')
    if v2:
        expected_cameras += ('JoinAudit_Apron', 'JoinAudit_Dispatch')
    if manifest.get('capture_type') != 'NEUTRAL_SHELL' or tuple(x.get('camera') for x in records) != expected_cameras:
        raise ValueError('shell capture list differs from fixed review views')
    if v2 and (len(manifest.get('pieces', [])) != 14 or not manifest.get('proof_composition_sha256')):
        raise ValueError('v2 shell capture lacks proof composition evidence')
    names = [item['filename'] for item in records]
    if len(names) != len(set(names)):
        raise ValueError('duplicate shell capture filenames')
    _check_images(folder, names)
    page = Image.new('RGB', (1450, 85 + ((len(records) + 1) // 2) * 410), (244, 244, 242))
    draw = ImageDraw.Draw(page)
    draw.text((24, 15), 'EAF5 neutral Receiving shell v2' if v2 else 'EAF5 neutral Receiving shell', fill=(20, 20, 20), font=_font(36))
    for index, record in enumerate(records):
        x = 24 + (index % 2) * 720
        y = 75 + (index // 2) * 410
        draw.text((x, y), record['camera'], fill=(35, 35, 35), font=_font(22))
        page.paste(_thumbnail(folder / record['filename'], (690, 380)), (x, y + 26))
    sheet = folder / 'contact_sheet_01.png'
    page.save(sheet, optimize=True)
    (folder / 'decision_template.json').write_text(json.dumps({'shell_decision': 'PENDING', 'allowed_decisions': ['ACCEPT', 'REJECT'], 'notes': ''}, indent=2) + '\n', encoding='utf-8')
    if v2:
        summary = '# EAF5 Pass 3A neutral shell re-review\n\nEight neutral views: six unchanged principal camera transforms and two join views. The 14 EAF2 pieces derive from the unchanged accepted shell source through proof composition v2. Distant backdrop and floor continuation are review-only context. Inspect closed wall/floor and wall/ceiling contact, corner ownership, and the west, east, and Dispatch apertures. Human shell re-review is pending. The v1 role packages are diagnostic history and remain superseded for promotion; do not make role decisions yet.\n'
    else:
        summary = '# EAF5 neutral shell review\n\nCheck Receiving proportions, freight enclosure, west/east/Dispatch apertures, ceiling transition, and piece contacts. Barrier and distant blockers are review-only context. Human shell acceptance is required before role evidence can promote materials.\n'
    (folder / 'summary.md').write_text(summary, encoding='utf-8')
    _write_zip(output, folder, names + [sheet.name, 'manifest.json', 'summary.md', 'decision_template.json'])
    return {'captures': len(records), 'contact_sheets': 1, 'zip': str(output), 'sha256': _sha256(output)}


def main() -> None:
    results = {}
    for role in ('wall', 'floor', 'ceiling'):
        folder = REPORT / 'role_isolation_02' / role
        output = REPORT / f'eaf5_{role}_role_review_02.zip'
        results[role] = build_role_package(folder, output)
    (REPORT / 'package_results_03.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(results, indent=2))

if __name__ == '__main__':
    main()
