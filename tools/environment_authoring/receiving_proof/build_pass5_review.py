"""Validate and package EAF5 Pass-5 structural palette captures."""
import hashlib
import json
from collections import Counter
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile
from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
FOLDER = BASE / "structural_palettes_01"
ZIP = BASE / "eaf5_structural_palette_review_01.zip"
DECISIONS = ROOT / "data/environment/receiving_proof/decisions/eaf5_wall_floor_pairs_01_human_review_01.json"
COMPOSITION = ROOT / "data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json"
COMPOSITION_HASH = "8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d"
PAIR_ZIP_HASH = "fa32ebd095eddf14a3218740b089f61b8c83db8ae73a3b266e1fe1194e3f6353"
PAIR_IDS = ["W01_F02", "W01_F03", "W02_F02", "W03_F01", "W03_F02", "W04_F01", "W04_F02"]
CEILING_IDS = ["eaf3b_2dc87647fd382ad8287a0280", "eaf3b_6bcd8f817ca2993433e217cc", "eaf3b_71edb3fc983ed8f7655d9523", "eaf3b_d335d94fd85c2c95c26b6b8b", "eaf3b_800060297ab83f24c0fb0d75"]
VIEWS = [("NEUTRAL_ARCHITECTURAL", "EastApproachOverview", "Neutral Overall"), ("RECEIVING_TARGET", "EastApproachOverview", "Receiving Overall"), ("NEUTRAL_ARCHITECTURAL", "CeilingRead", "Neutral CeilingRead"), ("RECEIVING_TARGET", "CeilingRead", "Receiving CeilingRead")]
CRITERIA = [
    "Does the room read as one coherent old municipal/service structure?",
    "Do wall, floor and ceiling have enough hierarchy without looking artificially contrasted?",
    "Does the ceiling make the 4.20 m room feel compressed or excessively dark?",
    "Do wall/floor/ceiling texture scales feel physically compatible?",
    "Does any repeated motif become dominant now that all three roles are active?",
    "Does the floor remain quiet enough for incoming loot and freight?",
    "Does the ceiling leave visual bandwidth for later services and lighting fixtures?",
    "Does the wall leave visual bandwidth for barrier/shutter/signage/services?",
    "Does the palette survive both Neutral and Receiving Target lighting?",
    "If wall and ceiling share one material, does that read as plausible cast structure or as visual flattening?",
    "Would the palette still work with applied finish OFF, structural secondary OFF and wear OFF?",
]

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def font(size):
    try:
        return ImageFont.truetype("C:/Windows/Fonts/arial.ttf", size)
    except OSError:
        return ImageFont.load_default()

def validate():
    manifest = json.loads((FOLDER / "manifest.json").read_text(encoding="utf-8"))
    decisions = json.loads(DECISIONS.read_text(encoding="utf-8"))
    assert sha(COMPOSITION) == COMPOSITION_HASH
    assert sha(BASE / "eaf5_wall_floor_pair_review_01.zip") == PAIR_ZIP_HASH
    assert sha(DECISIONS) == manifest["pair_decision_sha256"]
    assert decisions["accepted_shell_composition_sha256"] == COMPOSITION_HASH
    assert decisions["pair_review_package_sha256"] == PAIR_ZIP_HASH
    assert Counter(d["decision"] for d in decisions["pairs"]) == {"KEEP_PAIR": 7, "HOLD_PAIR": 2, "DROP_PAIR": 6}
    assert [d["pair_id"] for d in decisions["pairs"] if d["decision"] == "KEEP_PAIR"] == PAIR_IDS
    ids = [f"P{p:02d}_C{c:02d}" for p in range(1, 8) for c in range(1, 6)]
    assert manifest["capture_type"] == "STRUCTURAL_PALETTE"
    assert manifest["source_pair_ids"] == PAIR_IDS and manifest["ceiling_survivor_ids"] == CEILING_IDS
    assert manifest["structural_palette_ids"] == ids
    assert len(manifest["palettes"]) == 35 and [p["structural_palette_id"] for p in manifest["palettes"]] == ids
    assert manifest["transient_uv_override_count"] == 0
    assert manifest["wear_enabled"] is False and manifest["applied_finish_enabled"] is False and manifest["structural_secondary_enabled"] is False
    assert manifest["proof_composition_sha256"] == COMPOSITION_HASH
    assert len(manifest["pieces"]) == 14
    records = manifest["records"]
    assert len(records) == 140
    grouped = {}
    names = []
    for record in records:
        pid = record["structural_palette_id"]
        assert pid in ids and record["source_pair_id"] == PAIR_IDS[int(pid[1:3]) - 1]
        assert record["ceiling_catalog_material_id"] == CEILING_IDS[int(pid[5:7]) - 1]
        assert record["same_wall_ceiling_material"] == (record["wall_catalog_material_id"] == record["ceiling_catalog_material_id"])
        assert record["effective_mapping"] == {"wall": "UV", "floor": "UV", "ceiling": "UV"}
        assert record["transient_uv_review_override"] is False
        assert record["review_context_material"] == "eaf5_review_control_only"
        assert record["proof_composition_sha256"] == COMPOSITION_HASH and len(record["piece_geometry_fingerprints"]) == 14
        key = (record["light_mode"], record["camera"])
        assert key not in grouped.setdefault(pid, {})
        grouped[pid][key] = record
        name = record["filename"]
        assert name == f'{pid}__{record["light_mode"].lower()}__{record["camera"]}.png'
        with Image.open(FOLDER / name) as image:
            image.verify()
        names.append(name)
    assert len(set(names)) == 140
    for palette in manifest["palettes"]:
        pid = palette["structural_palette_id"]
        assert set(grouped[pid]) == {(mode, camera) for mode, camera, _ in VIEWS}
        sample = next(iter(grouped[pid].values()))
        for field in ("source_pair_id", "wall", "floor", "ceiling", "same_wall_ceiling_material", "material_parameters", "effective_mapping"):
            assert palette[field] == sample[field]
        assert palette["accepted_shell_composition_sha256"] == COMPOSITION_HASH
    return manifest, grouped, names

def sheets(ids, grouped):
    pages = []
    for start in range(0, 35, 5):
        page = Image.new("RGB", (1480, 90 + 5 * 950), (244, 244, 242))
        draw = ImageDraw.Draw(page)
        draw.text((24, 18), f"EAF5 Receiving structural palettes — page {start // 5 + 1}", fill=(20, 20, 20), font=font(34))
        for row, pid in enumerate(ids[start:start + 5]):
            data = grouped[pid]
            first = next(iter(data.values()))
            y = 85 + row * 950
            marker = "  [SAME WALL/CEILING]" if first["same_wall_ceiling_material"] else ""
            draw.text((24, y), pid + marker, fill=(20, 20, 20), font=font(27))
            for index, role in enumerate(("wall", "floor", "ceiling")):
                info = first[role]
                draw.text((24, y + 35 + index * 29), f'{role}: {info["display_name"]} [{info["catalog_material_id"][-8:]}]', fill=(20, 20, 20), font=font(22))
            for index, (mode, camera, label) in enumerate(VIEWS):
                x = 24 + (index % 2) * 730
                top = y + 125 + (index // 2) * 400
                draw.text((x, top), label, fill=(40, 40, 40), font=font(19))
                with Image.open(FOLDER / data[(mode, camera)]["filename"]) as original:
                    thumb = ImageOps.fit(original.convert("RGB"), (700, 375), Image.Resampling.LANCZOS)
                page.paste(thumb, (x, top + 23))
        name = f"contact_sheet_{start // 5 + 1:02d}.png"
        page.save(FOLDER / name, optimize=True)
        pages.append(name)
    return pages

def build():
    manifest, grouped, names = validate()
    ids = manifest["structural_palette_ids"]
    pages = sheets(ids, grouped)
    template = {"allowed_decisions": ["KEEP_PALETTE", "HOLD_PALETTE", "DROP_PALETTE"], "palettes": []}
    for palette in manifest["palettes"]:
        template["palettes"].append({"structural_palette_id": palette["structural_palette_id"], "source_pair_id": palette["source_pair_id"], "wall_catalog_material_id": palette["wall"]["catalog_material_id"], "floor_catalog_material_id": palette["floor"]["catalog_material_id"], "ceiling_catalog_material_id": palette["ceiling"]["catalog_material_id"], "decision": "PENDING", "notes": ""})
    (FOLDER / "decision_template.json").write_text(json.dumps(template, indent=2) + "\n", encoding="utf-8")
    summary = "# EAF5 Pass 5 — Receiving complete structural palette review\n\n"
    summary += "35 unranked palettes from seven human-kept wall/floor pairs and five kept ceilings. Four fixed views each: Neutral Overall, Receiving Overall, Neutral CeilingRead, Receiving CeilingRead. All ingredients retain approved UV mapping and PBR parameters. The accepted 14-piece Pass-3A v2 shell, camera transforms, lighting, UV phase and review-only context are unchanged. Applied finish, structural secondary and EAF4 wear are OFF. The freight/elevator enclosure oddity remains a non-blocking deferred follow-up.\n\n"
    summary += "Human structural-palette review is PENDING. A soft target is 4–8 KEEP_PALETTE selections, without a quota. Do not use later wear to rescue a weak structural palette.\n\n## Review criteria\n\n"
    summary += "\n".join(f"{i}. {criterion}" for i, criterion in enumerate(CRITERIA, 1))
    summary += "\n\n## Palette IDs\n\n" + ", ".join(ids) + "\n"
    (FOLDER / "summary.md").write_text(summary, encoding="utf-8")
    allowlist = names + pages + ["manifest.json", "summary.md", "decision_template.json"]
    with ZipFile(ZIP, "w", ZIP_DEFLATED, compresslevel=6) as archive:
        for name in allowlist:
            archive.write(FOLDER / name, arcname=name)
    with ZipFile(ZIP) as archive:
        assert archive.testzip() is None and sorted(archive.namelist()) == sorted(allowlist)
    result = {"palettes": 35, "captures": 140, "contact_sheets": 7, "same_wall_ceiling": sum(p["same_wall_ceiling_material"] for p in manifest["palettes"]), "zip": str(ZIP), "sha256": sha(ZIP)}
    print(json.dumps(result, indent=2))
    return result

if __name__ == "__main__":
    build()
