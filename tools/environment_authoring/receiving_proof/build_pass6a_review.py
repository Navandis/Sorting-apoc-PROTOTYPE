"""Validate and package EAF5 Pass-6A applied-finish screening captures."""
import hashlib
import json
from collections import Counter
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
FOLDER = BASE / "applied_finish_screen_01"
ZIP = BASE / "eaf5_applied_finish_screen_01_review.zip"
DECISIONS = ROOT / "data/environment/receiving_proof/decisions/eaf5_structural_palettes_01_human_review_01.json"
COMPOSITION = ROOT / "data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json"
COMPOSITION_HASH = "8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d"
PASS5_ZIP_HASH = "97034dbad91328f1d53531e3cf2b1816ac63ccf33d14a8e033495aaec61ba748"
FINALISTS = ["P01_C02", "P05_C02", "P04_C02", "P05_C03", "P01_C01", "P01_C05"]
FINISH_IDS = ["eaf3b_7b12b8b3a2e05c502801d22f", "eaf3b_8d5f0cf5add98dfe0a58f18a", "eaf3b_9297ffec71774317b0627951", "eaf3b_b395eb3943870fbfd262e8ce", "eaf3b_c29826cd934f1534ecfb48c5"]
VIEWS = [("NEUTRAL_ARCHITECTURAL", "EastApproachOverview", "Neutral Overall"), ("RECEIVING_TARGET", "EastApproachOverview", "Receiving Overall"), ("NEUTRAL_ARCHITECTURAL", "FinishField", "Neutral FinishField"), ("RECEIVING_TARGET", "FinishField", "Receiving FinishField")]
CRITERIA = [
    "Does the finish add a credible historical Layer-2 surface without overpowering the structural shell?",
    "Does enough structural concrete remain visible for the room to read as inherited civil/service architecture?",
    "Does the finish make Receiving too clean, domestic, office-like, institutional, or purpose-built?",
    "Does the finish's baked history compete with later EAF4 wear?",
    "Does its repeat become obvious across the large wall field?",
    "Does it survive both Neutral and Receiving Target lighting?",
    "Does it improve useful material hierarchy rather than merely add contrast?",
    "Would the structural palette remain acceptable if the finish were removed?",
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
    sanity = json.loads((FOLDER / "sanity/manifest.json").read_text(encoding="utf-8"))
    pass5 = json.loads((BASE / "structural_palettes_01/manifest.json").read_text(encoding="utf-8"))
    decisions = json.loads(DECISIONS.read_text(encoding="utf-8"))
    assert sha(COMPOSITION) == COMPOSITION_HASH
    assert sha(BASE / "eaf5_structural_palette_review_01.zip") == PASS5_ZIP_HASH
    assert sha(DECISIONS) == manifest["pass5_decision_sha256"]
    assert decisions["accepted_shell_composition_sha256"] == COMPOSITION_HASH
    assert decisions["structural_palette_review_package_sha256"] == PASS5_ZIP_HASH
    assert Counter(d["decision"] for d in decisions["palettes"]) == {"KEEP_PALETTE": 6, "HOLD_PALETTE": 9, "DROP_PALETTE": 20}
    assert {d["structural_palette_id"] for d in decisions["palettes"] if d["decision"] == "KEEP_PALETTE"} == set(FINALISTS)
    assert manifest["capture_type"] == "APPLIED_FINISH_SCREEN"
    assert manifest["structural_finalist_palette_ids"] == FINALISTS
    assert manifest["finish_material_ids"] == FINISH_IDS
    assert manifest["finish_region"] == "FINISH_SOUTH_WALL_FIELD" and manifest["finish_piece"] == "ReceivingSouth"
    assert manifest["transient_uv_finish_ids"] == [FINISH_IDS[1]] and manifest["transient_uv_override_configuration_count"] == 6
    assert manifest["configuration_ids"] == [f"S{s:02d}_A{a:02d}" for s in range(1, 7) for a in range(6)]
    assert len(manifest["configurations"]) == 36 and [c["configuration_id"] for c in manifest["configurations"]] == manifest["configuration_ids"]
    assert len(manifest["records"]) == 144
    assert manifest["proof_composition_sha256"] == COMPOSITION_HASH
    assert manifest["pieces"] == pass5["pieces"] == sanity["pieces"]
    assert manifest["environment"] == pass5["environment"] == sanity["environment"]
    assert manifest["review_context"] == pass5["review_context"] == sanity["review_context"]
    assert manifest["wear_enabled"] is False and manifest["eaf4_wear_enabled"] is False and manifest["structural_secondary_enabled"] is False
    assert manifest["applied_finish_mode"] == "PER_CONFIGURATION"
    assert sanity["configuration_ids"] == ["S01_A00", "S01_A02", "S02_A03", "S04_A04"]
    assert len(sanity["records"]) == 16
    by_config = {}
    names = []
    for record in manifest["records"]:
        cid = record["configuration_id"]
        assert cid in manifest["configuration_ids"]
        assert record["structural_palette_id"] == FINALISTS[int(cid[1:3]) - 1]
        assert record["finish_id"] == cid[4:]
        assert record["finish_region"] == "FINISH_SOUTH_WALL_FIELD" and record["finish_piece"] == "ReceivingSouth"
        assert record["proof_composition_sha256"] == COMPOSITION_HASH and len(record["piece_geometry_fingerprints"]) == 14
        assert record["review_context_material"] == "eaf5_review_control_only"
        assert record["effective_mapping"] == {"wall": "UV", "floor": "UV", "ceiling": "UV", "finish": None if cid.endswith("A00") else "UV"}
        assert record["transient_uv_override"] == cid.endswith("A02")
        assert record["applied_finish_enabled"] == (not cid.endswith("A00"))
        assert record["finish_material_id"] == (None if cid.endswith("A00") else FINISH_IDS[int(cid[-2:]) - 1])
        key = (record["light_mode"], record["camera"])
        assert key not in by_config.setdefault(cid, {})
        by_config[cid][key] = record
        name = record["filename"]
        assert name == f'{cid}__{record["light_mode"].lower()}__{record["camera"]}.png'
        with Image.open(FOLDER / name) as image:
            image.verify()
        names.append(name)
    assert len(set(names)) == 144
    for configuration in manifest["configurations"]:
        cid = configuration["configuration_id"]
        assert set(by_config[cid]) == {(mode, camera) for mode, camera, _ in VIEWS}
        sample = next(iter(by_config[cid].values()))
        for field in ("structural_finalist_id", "structural_palette_id", "finish_id", "wall_material_id", "floor_material_id", "ceiling_material_id", "finish_material_id", "finish_region", "finish_piece", "applied_finish_enabled", "transient_uv_override", "material_parameters", "effective_mapping"):
            assert configuration[field] == sample[field]
        assert configuration["accepted_shell_composition_sha256"] == COMPOSITION_HASH
    return manifest, by_config, names

def sheets(manifest, by_config):
    pages = []
    for finalist_index, palette_id in enumerate(FINALISTS, 1):
        page = Image.new("RGB", (1480, 90 + 6 * 950), (244, 244, 242))
        draw = ImageDraw.Draw(page)
        draw.text((24, 18), f"EAF5 finish screen S{finalist_index:02d} / {palette_id}", fill=(20, 20, 20), font=font(34))
        for finish_index in range(6):
            cid = f"S{finalist_index:02d}_A{finish_index:02d}"
            data = by_config[cid]
            first = next(iter(data.values()))
            y = 85 + finish_index * 950
            marker = " [TRANSIENT UV]" if first["transient_uv_override"] else ""
            draw.text((24, y), f'{cid}  {first["finish_display_name"]}{marker}', fill=(20, 20, 20), font=font(27))
            suffix = "CONTROL" if first["finish_material_id"] is None else first["finish_material_id"][-8:]
            draw.text((24, y + 35), f'palette {palette_id}   finish ID: {suffix}   region: ReceivingSouth', fill=(20, 20, 20), font=font(22))
            for index, (mode, camera, label) in enumerate(VIEWS):
                x = 24 + (index % 2) * 730
                top = y + 90 + (index // 2) * 410
                draw.text((x, top), label, fill=(40, 40, 40), font=font(19))
                with Image.open(FOLDER / data[(mode, camera)]["filename"]) as original:
                    thumb = ImageOps.fit(original.convert("RGB"), (700, 375), Image.Resampling.LANCZOS)
                page.paste(thumb, (x, top + 24))
        name = f"contact_sheet_{finalist_index:02d}.png"
        page.save(FOLDER / name, optimize=True)
        pages.append(name)
    return pages

def build():
    manifest, by_config, names = validate()
    pages = sheets(manifest, by_config)
    template = {"allowed_finish_decisions": ["KEEP_FINISH_VARIANT", "HOLD_FINISH_VARIANT", "DROP_FINISH_VARIANT"], "configurations": []}
    for config in manifest["configurations"]:
        control = config["finish_id"] == "A00"
        template["configurations"].append({"configuration_id": config["configuration_id"], "structural_palette_id": config["structural_palette_id"], "finish_id": config["finish_id"], "finish_material_id": config["finish_material_id"], "finish_region": "FINISH_SOUTH_WALL_FIELD", "decision": "CONTROL_NO_FINISH" if control else "PENDING", "notes": ""})
    (FOLDER / "decision_template.json").write_text(json.dumps(template, indent=2) + "\n", encoding="utf-8")
    summary = "# EAF5 Pass 6A — Receiving applied-finish material screen\n\n"
    summary += "Six human-kept structural palettes are compared with their own recaptured A00 NO_FINISH control and five approved Layer-2 finish materials. The fixed finish field is ReceivingSouth only. Four fixed views per configuration cover Neutral and Receiving Target overall and FinishField. This is material screening; region-layout testing follows only for human-kept variants. The accepted 14-piece shell, other structural materials, context, existing cameras, light rigs and UV phase are unchanged. A02 uses a transient UV review clone of its triplanar approved spec; approved textures, fingerprints and PBR parameters stay unchanged. Structural secondary and EAF4 wear remain OFF. The freight/elevator oddity remains a non-blocking deferred follow-up.\n\n"
    summary += "The six A00 records are controls. The 30 finish variants are PENDING human review. A finish cannot rescue a structural palette; all six structural finalists were already accepted without finish. NO_FINISH remains a valid outcome. Do not force one finish across every palette.\n\n## Review criteria\n\n"
    summary += "\n".join(f"{i}. {criterion}" for i, criterion in enumerate(CRITERIA, 1))
    summary += "\n\n## Configuration IDs\n\n" + ", ".join(manifest["configuration_ids"]) + "\n"
    (FOLDER / "summary.md").write_text(summary, encoding="utf-8")
    allowlist = names + pages + ["manifest.json", "summary.md", "decision_template.json"]
    with ZipFile(ZIP, "w", ZIP_DEFLATED, compresslevel=6) as archive:
        for name in allowlist:
            archive.write(FOLDER / name, arcname=name)
    with ZipFile(ZIP) as archive:
        assert archive.testzip() is None and sorted(archive.namelist()) == sorted(allowlist)
    result = {"configurations": 36, "controls": 6, "pending_variants": 30, "captures": 144, "contact_sheets": 6, "transient_uv_finish_sources": len(manifest["transient_uv_finish_ids"]), "zip": str(ZIP), "sha256": sha(ZIP)}
    print(json.dumps(result, indent=2))
    return result

if __name__ == "__main__":
    build()
