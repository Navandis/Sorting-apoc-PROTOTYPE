"""Package EAF5 Pass 7A per-source wear calibration."""
import hashlib, json
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile
from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[3]
DATA = ROOT / "data/environment/receiving_proof"
BASE = ROOT / "reports/environment_receiving_proof/eaf5"
FOLDER = BASE / "wear_calibration_01"
ZIP = BASE / "eaf5_wear_calibration_01_review.zip"
LIGHTS = ("NEUTRAL_ARCHITECTURAL", "RECEIVING_TARGET")
VARIANTS = {"L0": (1.0, .45), "L1": (.65, .45), "L2": (.65, .30),
            "D0": (1.0, .40), "D1": (.65, .40), "D2": (.65, .25),
            "R0": (1.0, .75), "R1": (.60, .75), "R2": (.60, .40)}
CAMERA = {"L": "WallCausalDetail", "D": "FreightFloorDetail", "R": "FreightFloorDetail"}
ID = {"L": "WEA01", "D": "WEA03", "R": "WEA04"}

def read(path):
    return json.loads(path.read_text(encoding="utf-8"))

def save(path, data):
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")

def font(size):
    try:
        return ImageFont.truetype("C:/Windows/Fonts/arial.ttf", size)
    except OSError:
        return ImageFont.load_default()

def validate():
    manifest = read(FOLDER / "manifest.json")
    source = read(DATA / "eaf5_receiving_wear_calibration_01.json")
    prior = read(DATA / "eaf5_receiving_wear_proof_01.json")
    assert source["instances"] == [x for x in prior["instances"] if x["instance_id"] != "WEA02"]
    assert manifest["capture_type"] == "WEAR_CALIBRATION_01"
    assert len(manifest["records"]) == 32
    assert sum(r["selection_role"] == "PRIMARY" for r in manifest["records"]) == 22
    assert sum(r["selection_role"] == "ALTERNATE" for r in manifest["records"]) == 10
    by = {}
    baseline = {}
    for r in manifest["records"]:
        state = r["wear_state"]
        role = r["selection_role"]
        palette = r["structural_palette_id"]
        assert (role, palette) in (("PRIMARY", "P01_C02"), ("ALTERNATE", "P05_C03"))
        assert role == "PRIMARY" or state in ("WEAR_OFF", "L2", "D2", "R2")
        assert r["camera"] == (CAMERA[state[0]] if state != "WEAR_OFF" else r["camera"])
        assert len(r["cause_proxies"]) == 2 and len(r["wear_instances"]) == 3
        assert [i["instance_id"] for i in r["wear_instances"]] == ["WEA01", "WEA03", "WEA04"]
        visible = [i for i in r["wear_instances"] if i["visible"]]
        assert len(visible) == (0 if state == "WEAR_OFF" else 1)
        if visible:
            assert visible[0]["instance_id"] == ID[state[0]]
            actual = visible[0]["opacity_multiplier"], visible[0]["albedo_strength"]
            assert all(abs(a - b) < 1e-5 for a, b in zip(actual, VARIANTS[state]))
        key = palette, r["camera"], r["light_mode"], state
        assert key not in by
        by[key] = r
        with Image.open(FOLDER / r["filename"]) as im:
            im.verify()
        invariant = {k: r[k] for k in ("camera_transform", "camera_fov", "light_settings", "cause_proxies", "piece_geometry_fingerprints", "wall", "floor", "ceiling")}
        basekey = palette, r["camera"], r["light_mode"]
        assert invariant == baseline.setdefault(basekey, invariant)
    assert len(by) == 32
    return manifest, by

def label(state):
    if state == "WEAR_OFF":
        return "OFF  |  overlays hidden  |  catalog defaults"
    opacity, albedo = VARIANTS[state]
    kind = "catalog-default" if state.endswith("0") else "instance override"
    return f"{state}  |  opacity {opacity:.2f}  |  albedo_strength {albedo:.2f}  |  {kind}"

def sheet(name, role, palette, states, by):
    page = Image.new("RGB", (24 + len(states) * 635, 910), (246, 245, 241))
    draw = ImageDraw.Draw(page)
    draw.text((24, 12), f"EAF5 PASS 7A / {role} / {palette} / {name}", font=font(32), fill=(25, 29, 32))
    draw.text((24, 55), "NO_FINISH  |  NO STRUCTURAL SECONDARY  |  one source at a time  |  both light modes", font=font(20), fill=(50, 50, 50))
    for row, light in enumerate(LIGHTS):
        for col, state in enumerate(states):
            camera = CAMERA[state[0]] if state != "WEAR_OFF" else ("WallCausalDetail" if (name == "primary_leak" or (name == "alternate" and col == 0)) else "FreightFloorDetail")
            rec = by[palette, camera, light, state]
            x, y = 24 + col * 635, 98 + row * 400
            draw.text((x, y), label(state), font=font(17), fill=(20, 25, 30))
            draw.text((x, y + 24), f"{light} / {camera}", font=font(16), fill=(50, 50, 50))
            with Image.open(FOLDER / rec["filename"]) as im:
                tile = ImageOps.fit(im.convert("RGB"), (610, 343), Image.Resampling.LANCZOS)
            page.paste(tile, (x, y + 48))
    filename = f"contact_sheet_{name}.png"
    page.save(FOLDER / filename, optimize=True)
    return filename

def main():
    manifest, by = validate()
    sheets = [
        sheet("primary_leak", "PRIMARY", "P01_C02", ("WEAR_OFF", "L0", "L1", "L2"), by),
        sheet("primary_dust", "PRIMARY", "P01_C02", ("WEAR_OFF", "D0", "D1", "D2"), by),
        sheet("primary_rust", "PRIMARY", "P01_C02", ("WEAR_OFF", "R0", "R1", "R2"), by),
        sheet("alternate", "ALTERNATE", "P05_C03", ("WEAR_OFF", "L2", "WEAR_OFF", "D2", "R2"), by),
    ]
    template = {"review": "EAF5 Pass 7A Receiving wear calibration",
                "allowed_selected_variant": [0, 1, 2, "DISABLED"],
                "allowed_alternate_transfer": ["ACCEPTABLE", "NEEDS_SEPARATE_CALIBRATION", "NOT_APPLICABLE"],
                "sources": [{"instance_id": sid, "selected_variant": "PENDING", "alternate_transfer": "PENDING", "rationale": ""}
                            for sid in ("WEA01", "WEA03", "WEA04")]}
    save(FOLDER / "decision_template.json", template)
    lines = ["# EAF5 Pass 7A — Receiving wear calibration", "",
             "The Pass 7 causal architecture and three placements remain fixed. Crack WEA02 is disabled for the maintained Receiving apron. These captures compare one source at a time; there is no combined wear state.",
             "", "PRIMARY P01_C02 has OFF plus L0–L2, D0–D2, R0–R2 under both light modes (22 captures). ALTERNATE P05_C03 has OFF plus L2, D2, R2 under both modes (10 captures).",
             "", "Every placed spec is duplicated from its approved EAF4 spec. Only opacity_multiplier and albedo_strength are local overrides. Physical size, offset, normal, roughness, imperfection, position, rotation and mirror settings remain approved/unchanged.",
             "", "| Source | Catalog default | Opacity only | Opacity + albedo |", "| --- | --- | --- | --- |",
             "| WEA01 leak | L0 1.00 / 0.45 | L1 0.65 / 0.45 | L2 0.65 / 0.30 |",
             "| WEA03 freight dust | D0 1.00 / 0.40 | D1 0.65 / 0.40 | D2 0.65 / 0.25 |",
             "| WEA04 rust debris | R0 1.00 / 0.75 | R1 0.60 / 0.75 | R2 0.60 / 0.40 |",
             "", "## Review criteria", "",
             "1. Is it visible enough when intentionally inspected?",
             "2. Does it disappear naturally into the substrate at ordinary room scale?",
             "3. Does it still look like a discrete decal/swatch?",
             "4. Is color contribution too strong?",
             "5. Is opacity the main issue, or source color?",
             "6. Does the cause remain legible?",
             "7. Does substantial quiet surface remain?",
             "8. Does the restrained variant transfer acceptably to the alternate palette?",
             "", "Choose the weakest treatment that still reads appropriately. Do not optimize for screenshot visibility. Decisions remain PENDING; do not infer a combined composition from this package.", ""]
    (FOLDER / "summary.md").write_text("\n".join(lines), encoding="utf-8")
    allow = [r["filename"] for r in manifest["records"]] + sheets + ["manifest.json", "summary.md", "decision_template.json"]
    assert len(allow) == 39 and len(set(allow)) == 39
    with ZipFile(ZIP, "w", ZIP_DEFLATED, compresslevel=6) as archive:
        for name in allow:
            archive.write(FOLDER / name, arcname=name)
    with ZipFile(ZIP) as archive:
        assert archive.testzip() is None and set(archive.namelist()) == set(allow)
    print("captures=32 sheets=4 members=39 sha256=" + hashlib.sha256(ZIP.read_bytes()).hexdigest())

if __name__ == "__main__":
    main()