"""Validate and package EAF5 Pass-4 wall/floor pair captures."""

import hashlib
import json
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
FOLDER = BASE / "wall_floor_pairs_01"
ZIP = BASE / "eaf5_wall_floor_pair_review_01.zip"
DECISIONS = ROOT / "data/environment/receiving_proof/decisions/eaf5_role_isolation_02_human_review_01.json"
COMPOSITION_HASH = "8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d"
VIEWS = (
    ("NEUTRAL_ARCHITECTURAL", "EastApproachOverview", "Neutral Overall"),
    ("RECEIVING_TARGET", "EastApproachOverview", "Receiving Overall"),
    ("NEUTRAL_ARCHITECTURAL", "WallDominant", "Neutral Wall"),
    ("NEUTRAL_ARCHITECTURAL", "FloorRead", "Neutral Floor"),
)
CRITERIA = (
    "Does the wall/floor relationship read as one old municipal/service structure?",
    "Is there enough value separation?",
    "Are both surfaces too visually noisy?",
    "Are both too dark under Receiving Target?",
    "Does the floor compete with incoming crates/loot?",
    "Does the wall retain quiet area for later freight equipment/services?",
    "Do material scales feel compatible?",
    "Does either source's repetition become more obvious beside the other?",
    "Does the pair still work with ceiling = neutral control, finish = off, wear = off?",
)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def font(size):
    try:
        return ImageFont.truetype("C:/Windows/Fonts/arial.ttf", size)
    except OSError:
        return ImageFont.load_default()


def _check_input(manifest):
    decisions = json.loads(DECISIONS.read_text(encoding="utf-8"))
    assert len(decisions["decisions"]) == 33
    assert sha(DECISIONS) == manifest["role_decision_sha256"]
    assert sha(ROOT / "data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json") == COMPOSITION_HASH
    assert manifest["proof_composition_sha256"] == COMPOSITION_HASH
    assert manifest["capture_type"] == "WALL_FLOOR_PAIR"
    assert manifest["control_material"] == "eaf5_review_control_only"
    assert manifest["wear_enabled"] is False and manifest["applied_finish_enabled"] is False
    assert len(manifest["pieces"]) == 14
    counts = {role: {value: 0 for value in ("KEEP", "HOLD", "DROP_FOR_RECEIVING")} for role in ("WALL_PRIMARY", "FLOOR_PRIMARY", "CEILING_PRIMARY")}
    for entry in decisions["decisions"]:
        counts[entry["role"]][entry["decision"]] += 1
    assert counts == {
        "WALL_PRIMARY": {"KEEP": 5, "HOLD": 7, "DROP_FOR_RECEIVING": 2},
        "FLOOR_PRIMARY": {"KEEP": 3, "HOLD": 3, "DROP_FOR_RECEIVING": 2},
        "CEILING_PRIMARY": {"KEEP": 5, "HOLD": 3, "DROP_FOR_RECEIVING": 3},
    }
    walls = {d["catalog_material_id"] for d in decisions["decisions"] if d["role"] == "WALL_PRIMARY" and d["decision"] == "KEEP"}
    floors = {d["catalog_material_id"] for d in decisions["decisions"] if d["role"] == "FLOOR_PRIMARY" and d["decision"] == "KEEP"}
    assert len(walls) == 5 and len(floors) == 3 and not walls & floors
    pair_ids = [f"W{wi:02d}_F{fi:02d}" for wi in range(1, 6) for fi in range(1, 4)]
    assert manifest["pair_ids"] == pair_ids
    assert [pair["pair_id"] for pair in manifest["pairs"]] == pair_ids
    records = manifest["records"]
    assert len(records) == 60
    by_pair = {}
    names = []
    for record in records:
        pair = record["pair_id"]
        assert pair in pair_ids
        assert record["wall_catalog_material_id"] in walls and record["floor_catalog_material_id"] in floors
        assert record["wall_catalog_material_id"] != record["floor_catalog_material_id"]
        assert record["effective_mapping"] == {"wall": "UV", "floor": "UV"}
        assert record["ceiling_material"] == "eaf5_review_control_only"
        assert record["review_context_material"] == "eaf5_review_control_only"
        assert record["proof_composition_sha256"] == COMPOSITION_HASH
        assert len(record["piece_geometry_fingerprints"]) == 14
        assert record["filename"] == f'{pair}__{record["light_mode"].lower()}__{record["camera"]}.png'
        assert Path(record["filename"]).name == record["filename"]
        name = record["filename"]
        with Image.open(FOLDER / name) as image:
            image.verify()
        names.append(name)
        key = (record["light_mode"], record["camera"])
        assert key not in by_pair.setdefault(pair, {})
        by_pair[pair][key] = record
    assert len(set(names)) == 60
    for pair in pair_ids:
        assert set(by_pair[pair]) == {(mode, camera) for mode, camera, _ in VIEWS}
        wall_ids = {record["wall_catalog_material_id"] for record in by_pair[pair].values()}
        floor_ids = {record["floor_catalog_material_id"] for record in by_pair[pair].values()}
        assert len(wall_ids) == len(floor_ids) == 1
        pair_record = next(item for item in manifest["pairs"] if item["pair_id"] == pair)
        sample = next(iter(by_pair[pair].values()))
        assert pair_record["wall_catalog_material_id"] == sample["wall_catalog_material_id"]
        assert pair_record["floor_catalog_material_id"] == sample["floor_catalog_material_id"]
        assert pair_record["wall_display_name"] == sample["wall_display_name"]
        assert pair_record["floor_display_name"] == sample["floor_display_name"]
        assert pair_record["accepted_shell_composition_sha256"] == COMPOSITION_HASH
        assert pair_record["effective_uv_mapping"] == {"wall": "UV", "floor": "UV"}
        assert pair_record["material_parameters"] == sample["material_parameters"]
    assert len(manifest["ceiling_survivor_ids_for_later"]) == 5
    return pair_ids, by_pair, names


def _sheets(pair_ids, by_pair):
    pages = []
    for start in range(0, 15, 5):
        page = Image.new("RGB", (1480, 90 + 5 * 930), (244, 244, 242))
        draw = ImageDraw.Draw(page)
        draw.text((24, 18), f"EAF5 Receiving wall/floor pairs — page {start // 5 + 1}", fill=(20, 20, 20), font=font(34))
        for row, pair in enumerate(pair_ids[start:start + 5]):
            data = by_pair[pair]
            first = next(iter(data.values()))
            y = 85 + row * 930
            draw.text((24, y), f'{pair}    wall: {first["wall_display_name"]} [{first["wall_catalog_material_id"][-8:]}]', fill=(20, 20, 20), font=font(27))
            draw.text((24, y + 35), f'floor: {first["floor_display_name"]} [{first["floor_catalog_material_id"][-8:]}]', fill=(20, 20, 20), font=font(25))
            for index, (mode, camera, label) in enumerate(VIEWS):
                x = 24 + (index % 2) * 730
                top = y + 80 + (index // 2) * 410
                draw.text((x, top), label, fill=(40, 40, 40), font=font(19))
                with Image.open(FOLDER / data[(mode, camera)]["filename"]) as original:
                    thumb = ImageOps.fit(original.convert("RGB"), (700, 394), Image.Resampling.LANCZOS)
                page.paste(thumb, (x, top + 24))
        path = FOLDER / f"contact_sheet_{start // 5 + 1:02d}.png"
        page.save(path, optimize=True)
        pages.append(path.name)
    return pages


def build():
    manifest = json.loads((FOLDER / "manifest.json").read_text(encoding="utf-8"))
    pair_ids, by_pair, names = _check_input(manifest)
    pages = _sheets(pair_ids, by_pair)
    template = {
        "allowed_decisions": ["KEEP_PAIR", "HOLD_PAIR", "DROP_PAIR"],
        "pairs": [
            {
                "pair_id": pair,
                "wall_catalog_material_id": next(iter(by_pair[pair].values()))["wall_catalog_material_id"],
                "floor_catalog_material_id": next(iter(by_pair[pair].values()))["floor_catalog_material_id"],
                "decision": "PENDING",
                "notes": "",
            }
            for pair in pair_ids
        ],
    }
    (FOLDER / "decision_template.json").write_text(json.dumps(template, indent=2) + "\n", encoding="utf-8")
    summary = "# EAF5 Pass 4 — Receiving wall/floor pair review\n\n"
    summary += "15 ordered pairs, four fixed views each: Neutral Overall, Receiving Overall, Neutral Wall, Neutral Floor. The accepted 14-piece Pass-3A v2 shell, camera transforms, lights, UV mapping and material parameters are unchanged. Ceiling and review context use the EAF5 neutral control. EAF4 wear, applied finish and structural secondary are off. The known freight/elevator enclosure oddity remains a non-blocking deferred follow-up.\n\n"
    summary += "Human wall/floor pair selection is PENDING. Aim for approximately 4–8 KEEP_PAIR selections if the evidence supports them; this is not a quota. Do not use future wear to rescue a weak pair.\n\n## Review criteria\n\n"
    summary += "\n".join("- " + item for item in CRITERIA) + "\n\n## Pair IDs\n\n"
    summary += ", ".join(pair_ids) + "\n\nFive ceiling KEEP candidates are reserved for the next pass and are not applied here.\n"
    (FOLDER / "summary.md").write_text(summary, encoding="utf-8")
    allowlist = names + pages + ["manifest.json", "summary.md", "decision_template.json"]
    with ZipFile(ZIP, "w", ZIP_DEFLATED, compresslevel=6) as archive:
        for name in allowlist:
            archive.write(FOLDER / name, arcname=name)
    with ZipFile(ZIP) as archive:
        assert archive.testzip() is None
        assert sorted(archive.namelist()) == sorted(allowlist)
    result = {"pairs": 15, "captures": 60, "contact_sheets": 3, "zip": str(ZIP), "sha256": sha(ZIP)}
    print(json.dumps(result, indent=2))
    return result


if __name__ == "__main__":
    build()
