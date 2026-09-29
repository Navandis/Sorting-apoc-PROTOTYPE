"""Validate and package EAF5 Pass 6B bounded finish-layout captures."""
import hashlib
import json
from collections import Counter
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

from PIL import Image, ImageChops, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
FOLDER = BASE / "applied_finish_layouts_01"
ZIP = BASE / "eaf5_applied_finish_layout_review_01.zip"
DECISIONS = ROOT / "data/environment/receiving_proof/decisions/eaf5_applied_finish_screen_01_human_review_01.json"
COMPOSITION = ROOT / "data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json"
COMPOSITION_HASH = "8361ed7d1d211f40c253cc7bf76821b9d141ab303b0fe7a6573208216f05339d"
PASS6A_ZIP_HASH = "e8bfa330e836687b2fe869a938bf7ed3181ca1a0f076d0d531a32293e6bda66b"
EXPECTED = [
    "S01_L00", "S05_L00", "S06_L00",
    "V01_L01", "V01_L02", "V02_L01", "V02_L02",
    "V03_L01", "V03_L02", "V04_L01", "V04_L02",
    "Q01_L02", "Q02_L02",
]
PAGES = [
    ("S01 / P01_C02", ["S01_L00", "V01_L01", "V01_L02", "Q01_L02", "Q02_L02"]),
    ("S05 / P01_C01", ["S05_L00", "V02_L01", "V02_L02"]),
    ("S06 / P01_C05", ["S06_L00", "V03_L01", "V03_L02", "V04_L01", "V04_L02"]),
]
CRITERIA = [
    "Does the bounded field read as a plausible historical Layer-2 intervention?",
    "Is its size and placement believable rather than decorative?",
    "Does enough structural substrate remain visible?",
    "Is finish repetition still obvious?",
    "Does the finish add hierarchy rather than arbitrary contrast?",
    "Is the substrate/finish edge credible without needing wear to hide it?",
    "Does it survive both lighting rigs?",
    "Is NO_FINISH still better?",
    "For A02/A03, did localization solve the repetition problem?",
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
    scale = json.loads((FOLDER / "scale_sanity/manifest.json").read_text(encoding="utf-8"))
    pass6a = json.loads((BASE / "applied_finish_screen_01/manifest.json").read_text(encoding="utf-8"))
    decisions = json.loads(DECISIONS.read_text(encoding="utf-8"))
    assert sha(COMPOSITION) == COMPOSITION_HASH
    assert sha(BASE / "eaf5_applied_finish_screen_01_review.zip") == PASS6A_ZIP_HASH
    assert decisions["pass6a_review_package_sha256"] == PASS6A_ZIP_HASH
    assert manifest["pass6a_decision_sha256"] == sha(DECISIONS)
    assert Counter(x["decision"] for x in decisions["configurations"]) == {
        "CONTROL_NO_FINISH": 6, "KEEP_FINISH_VARIANT": 4, "HOLD_FINISH_VARIANT": 7, "DROP_FINISH_VARIANT": 19,
    }
    assert manifest["capture_type"] == "APPLIED_FINISH_LAYOUT"
    assert sanity["capture_type"] == "APPLIED_FINISH_LAYOUT_SANITY"
    assert scale["capture_type"] == "APPLIED_FINISH_LAYOUT_SCALE"
    assert manifest["configuration_ids"] == EXPECTED
    assert sanity["configuration_ids"] == ["S01_L00", "V01_L01", "V01_L02", "Q01_L02", "Q02_L02"]
    assert scale["configuration_ids"] == ["V01_L01", "V01_L02"]
    assert len(manifest["records"]) == 52 and len(sanity["records"]) == 20 and len(scale["records"]) == 2
    assert len(manifest["configurations"]) == 13
    assert manifest["proof_composition_sha256"] == COMPOSITION_HASH
    assert manifest["pieces"] == sanity["pieces"] == scale["pieces"] == pass6a["pieces"]
    assert manifest["environment"] == sanity["environment"] == scale["environment"] == pass6a["environment"]
    assert manifest["review_context"] == sanity["review_context"] == scale["review_context"] == pass6a["review_context"]
    assert manifest["structural_palette_ids"] == ["P01_C02", "P01_C01", "P01_C05"]
    assert manifest["eaf4_wear_enabled"] is False and manifest["structural_secondary_enabled"] is False
    assert manifest["applied_finish_mode"] == "BOUNDED_EAF3_MATERIAL_PATCH"
    assert manifest["transient_uv_override_configuration_count"] == 1
    by_config = {}
    names = []
    fixed_cameras = {}
    light_settings = {}
    for record in manifest["records"]:
        cid = record["configuration_id"]
        assert cid in EXPECTED
        by_config.setdefault(cid, {})[(record["light_mode"], record["camera"])] = record
        assert record["finish_piece"] == "ReceivingSouth"
        assert record["proof_composition_sha256"] == COMPOSITION_HASH
        assert len(record["piece_geometry_fingerprints"]) == 14
        assert record["review_context_material"] == "eaf5_review_control_only"
        assert record["effective_mapping"] == {
            "wall": "UV", "floor": "UV", "ceiling": "UV",
            "finish": None if record["layout_id"] == "L00" else "UV",
        }
        if record["layout_id"] == "L00":
            assert record["finish_material_id"] is None
            assert record["physical_size_m"] is None and record["wall_local_position"] is None
            assert record["patch_mesh_uv_extent_m"] is None
        else:
            expected_size = [4.2, 2.4] if record["layout_id"] == "L01" else [1.8, 1.2]
            assert record["physical_size_m"] == expected_size
            assert all(abs(a - b) < 1e-5 for a, b in zip(record["patch_mesh_uv_extent_m"], expected_size))
            assert all(abs(a - b) < 1e-5 for a, b in zip(record["patch_mesh_size_m"], expected_size))
            assert record["patch_root_scale"] == [1.0, 1.0, 1.0]
            assert record["surface_offset_m"] == 0.002
            assert record["approved_finish_mapping"] == ("TRIPLANAR" if cid == "Q01_L02" else "UV")
            assert record["transient_uv_override"] == (cid == "Q01_L02")
            expected_repeats = [value / record["material_parameters"]["finish"]["meters_per_repeat"] for value in expected_size]
            assert all(abs(a - b) < 1e-5 for a, b in zip(record["expected_source_repeats"], expected_repeats))
            assert record["wall_local_position"] == (
                {"offset_x_from_wall_center_m": 0.0, "center_y_m": 2.1, "world_center_m": [5.1, 2.1, 4.85]}
                if record["layout_id"] == "L01"
                else {"offset_x_from_wall_center_m": -2.0, "center_y_m": 1.55, "world_center_m": [3.1, 1.55, 4.85]}
            )
        camera = record["camera"]
        if camera in fixed_cameras:
            assert fixed_cameras[camera] == (record["camera_transform"], record["camera_fov"])
        else:
            fixed_cameras[camera] = (record["camera_transform"], record["camera_fov"])
        mode = record["light_mode"]
        if mode in light_settings:
            assert light_settings[mode] == record["light_settings"]
        else:
            light_settings[mode] = record["light_settings"]
        filename = record["filename"]
        assert filename == f'{cid}__{mode.lower()}__{camera}.png'
        with Image.open(FOLDER / filename) as image:
            image.verify()
        names.append(filename)
    assert len(set(names)) == 52
    assert Counter(c["layout_id"] for c in manifest["configurations"]) == {"L00": 3, "L01": 4, "L02": 6}
    assert sum(c["transient_uv_override"] for c in manifest["configurations"]) == 1
    for cid in EXPECTED:
        views = {
            ("NEUTRAL_ARCHITECTURAL", "EastApproachOverview"),
            ("RECEIVING_TARGET", "EastApproachOverview"),
            ("NEUTRAL_ARCHITECTURAL", "FinishPatch" if cid.endswith("L02") else "FinishField"),
            ("RECEIVING_TARGET", "FinishPatch" if cid.endswith("L02") else "FinishField"),
        }
        assert set(by_config[cid]) == views
    for structural in ("S01", "S05", "S06"):
        for light in ("neutral_architectural", "receiving_target"):
            for camera in ("EastApproachOverview", "FinishField"):
                with Image.open(FOLDER / f"{structural}_L00__{light}__{camera}.png") as current:
                    with Image.open(BASE / "applied_finish_screen_01" / f"{structural}_A00__{light}__{camera}.png") as prior:
                        assert ImageChops.difference(current.convert("RGB"), prior.convert("RGB")).getbbox() is None
    for record in manifest["records"]:
        if record["layout_id"] == "L00" or record["camera"] != "EastApproachOverview":
            continue
        control = record["structural_finalist_id"] + "_L00"
        control_name = f'{control}__{record["light_mode"].lower()}__EastApproachOverview.png'
        with Image.open(FOLDER / record["filename"]) as current:
            with Image.open(FOLDER / control_name) as prior:
                bbox = ImageChops.difference(current.convert("RGB"), prior.convert("RGB")).getbbox()
        assert bbox is not None and bbox[2] < 0.75 * 1920, (record["configuration_id"], bbox)
    return manifest, by_config, names

def sheets(manifest, by_config):
    pages = []
    for page_index, (palette_label, config_ids) in enumerate(PAGES, 1):
        height = 95 + len(config_ids) * 925
        page = Image.new("RGB", (1480, height), (244, 244, 242))
        draw = ImageDraw.Draw(page)
        draw.text((24, 18), f"EAF5 bounded finish layouts / {palette_label}", fill=(20, 20, 20), font=font(31))
        for row, cid in enumerate(config_ids):
            sample = next(iter(by_config[cid].values()))
            y = 84 + row * 925
            size = sample["physical_size_m"]
            size_label = "NO_FINISH" if size is None else f'{size[0]:.2f} × {size[1]:.2f} m'
            marker = " [TRANSIENT UV]" if sample["transient_uv_override"] else ""
            draw.text((24, y), f'{cid}  {sample["finish_display_name"]}{marker}', fill=(20, 20, 20), font=font(26))
            draw.text((24, y + 36), f'{sample["structural_palette_id"]}  |  {sample["layout_name"]}  |  {size_label}', fill=(35, 35, 35), font=font(22))
            views = [
                ("NEUTRAL_ARCHITECTURAL", "EastApproachOverview", "Neutral Overall"),
                ("RECEIVING_TARGET", "EastApproachOverview", "Receiving Overall"),
                ("NEUTRAL_ARCHITECTURAL", "FinishPatch" if cid.endswith("L02") else "FinishField", "Neutral Detail"),
                ("RECEIVING_TARGET", "FinishPatch" if cid.endswith("L02") else "FinishField", "Receiving Detail"),
            ]
            for index, (mode, camera, label) in enumerate(views):
                x = 24 + (index % 2) * 730
                top = y + 85 + (index // 2) * 405
                draw.text((x, top), label, fill=(40, 40, 40), font=font(19))
                with Image.open(FOLDER / by_config[cid][(mode, camera)]["filename"]) as original:
                    thumb = ImageOps.fit(original.convert("RGB"), (700, 375), Image.Resampling.LANCZOS)
                page.paste(thumb, (x, top + 25))
        filename = f"contact_sheet_{page_index:02d}.png"
        page.save(FOLDER / filename, optimize=True)
        pages.append(filename)
    return pages

def build():
    manifest, by_config, names = validate()
    pages = sheets(manifest, by_config)
    template = {
        "allowed_layout_decisions": ["KEEP_LAYOUT_VARIANT", "HOLD_LAYOUT_VARIANT", "DROP_LAYOUT_VARIANT"],
        "configurations": [],
    }
    for config in manifest["configurations"]:
        template["configurations"].append({
            "configuration_id": config["configuration_id"],
            "structural_palette_id": config["structural_palette_id"],
            "finish_material_id": config["finish_material_id"],
            "layout_id": config["layout_id"],
            "physical_size_m": config["physical_size_m"],
            "decision": "CONTROL_NO_FINISH" if config["layout_id"] == "L00" else "PENDING",
            "notes": "",
        })
    (FOLDER / "decision_template.json").write_text(json.dumps(template, indent=2) + "\n", encoding="utf-8")
    summary = "# EAF5 Pass 6B — bounded Receiving finish layouts\n\n"
    summary += "Three NO_FINISH structural controls, four human-kept finish/palette combinations at L01 and L02, and two held finish probes at L02 are shown in four fixed views each. This package does not select a finish winner. Compare every variant against its same-structure control. NO_FINISH remains a fully valid final direction.\n\n"
    summary += "L01 is a 4.20 × 2.40 m inherited field centered on ReceivingSouth at wall-local offset 0 and Y=2.10 m. L02 is a 1.80 × 1.20 m local patch at offset -2.00 m and Y=1.55 m. Both are on the occupied face Z=4.85 m with 0.002 m offset. Structural materials and 14-piece shell are unchanged; EAF4 wear and structural secondary are off. A02 uses a transient UV clone of its triplanar-approved catalog spec.\n\n"
    summary += "## Review criteria\n\n" + "\n".join(f"{i}. {criterion}" for i, criterion in enumerate(CRITERIA, 1)) + "\n\n"
    summary += "Do not assume EAF4 wear will hide a bad boundary or repeated finish.\n\n"
    summary += "## Configurations\n\n" + ", ".join(EXPECTED) + "\n"
    (FOLDER / "summary.md").write_text(summary, encoding="utf-8")
    allowlist = names + pages + ["manifest.json", "summary.md", "decision_template.json"]
    with ZipFile(ZIP, "w", ZIP_DEFLATED, compresslevel=6) as archive:
        for name in allowlist:
            archive.write(FOLDER / name, arcname=name)
    with ZipFile(ZIP) as archive:
        assert archive.testzip() is None
        assert sorted(archive.namelist()) == sorted(allowlist)
    result = {
        "configurations": 13,
        "controls": 3,
        "pending_variants": 10,
        "captures": len(names),
        "contact_sheets": len(pages),
        "transient_uv_configurations": 1,
        "zip": str(ZIP),
        "sha256": sha(ZIP),
    }
    print(json.dumps(result, indent=2))
    return result

if __name__ == "__main__":
    build()
