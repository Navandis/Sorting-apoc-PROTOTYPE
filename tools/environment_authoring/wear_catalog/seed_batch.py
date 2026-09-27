"""Rebuild the tracked, contact-sheet-selected EAF4B starter batch."""
import json
from pathlib import Path

from tools.environment_authoring.wear_catalog.workflow import make_batch
from tools.environment_authoring.wear_repository.source_index import load_index

ROOT = Path(__file__).resolve().parents[3]
BATCH = ROOT / "data/environment/wear_catalog/review_batches/wear_foundation_01/batch.json"

# Choices were checked against the EAF4A cracks, damage, water, oil, rust,
# paint, other, and imperfection contact sheets on 2026-09-27.
CHOICES = [
    ("concrete_crack_sf2moag", "2K", "OVERLAY", "Narrow branched concrete crack with clean separated mask and full PBR; portable substrate stress case.", "crack", ["settlement"], ["WALL"], "CUTOUT", [0.5, 0.5], 0.35),
    ("concrete_crack_sfhmrfg", "2K", "OVERLAY", "Long horizontal fracture suitable for a distinct physical aspect-ratio check.", "crack", ["settlement"], ["WALL"], "CUTOUT", [1.0, 0.25], 0.35),
    ("concrete_damage_sfcmkbg", "2K", "OVERLAY", "Compact concrete chip with readable irregular silhouette and PBR relief.", "spall_damage", ["impact"], ["WALL"], "CUTOUT", [1.0, 0.5], 0.45),
    ("damaged_concrete_tbqmbayr", "2K", "OVERLAY", "Broader broken concrete/rebar edge tests hard mask without introducing a source rectangle.", "spall_damage", ["impact"], ["WALL"], "CUTOUT", [1.0, 1.0], 0.45),
    ("concrete_leakage_tk3jej1c", "2K", "OVERLAY", "Tight vertical dark leak mark, useful beneath a small service origin.", "water_mineral", ["leak"], ["WALL"], "SOFT_BLEND", [0.25, 1.0], 0.25),
    ("leakage_tculfbnc", "2K", "OVERLAY", "Soft descending mineral/water stain with differentiated taper.", "water_mineral", ["leak"], ["WALL"], "SOFT_BLEND", [0.25, 0.5], 0.25),
    ("leakage_skiubhzc", "2K", "OVERLAY", "Broad irregular orange mineral leak with enough area to evaluate imperfection breakup clearly.", "water_mineral", ["leak"], ["WALL"], "SOFT_BLEND", [1.0, 1.0], 0.45),
    ("road_dust_sgzh1so", "2K", "OVERLAY", "Sparse road dust reads as a restrained grime alternative; EAF4A grime page contains excluded fixtures.", "grime", ["accumulation"], ["FLOOR"], "SOFT_BLEND", [1.0, 1.0], 0.2),
    ("rust_debris_ugxhbh0h", "2K", "OVERLAY", "Sparse corrosion flecks rather than a full metal object.", "rust_corrosion", ["corrosion"], ["WALL", "FLOOR"], "SOFT_BLEND", [0.5, 0.5], 0.6),
    ("oil_stain_semlsbi", "2K", "OVERLAY", "Two irregular oil marks, suitable for a localized floor spill.", "oil_grease", ["spill"], ["FLOOR"], "SOFT_BLEND", [0.5, 0.5], 0.45),
    ("chipped_paint_patch_ui2ncdjfw", "2K", "OVERLAY", "Hard fragmented old paint edge, useful for applied-finish contrast.", "paint_damage", ["age"], ["WALL"], "CUTOUT", [1.0, 1.0], 0.7),
    ("industrial_abandonedfactory_wall_concrete_painted_xetubap", "4K", "EAF4_PATCH", "Human EAF4A triage identifies a broad opaque paint remnant; review as patch while retaining MASKED_DECAL source fact.", "paint_remnant", ["old_finish"], ["WALL"], "SOFT_BLEND", [1.5, 2.0], 0.95),
    ("grunge_tedxadjc", "1K", "IMPERFECTION", "Varied scalar grunge without strong directional lines for stain modulation.", "imperfection", ["surface_variation"], ["PLANAR_ANY"], "SOFT_BLEND", [1.0, 1.0], 0.0),
    ("scratched_metal_vdekebbc", "1K", "IMPERFECTION", "Fine scratched mask for testing directional scuff modulation.", "imperfection", ["abrasion"], ["PLANAR_ANY"], "SOFT_BLEND", [0.5, 0.5], 0.0),
]
BASE_LIGHT = "eaf3b_39b926e570fb3824019aade2"
BASE_DARK = "eaf3b_bd0940113f04f3d3784629e7"
BASE_FLOOR = "eaf3b_20c61bd1c85420be2f71a090"
BASE_PLASTER = "eaf3b_8d5f0cf5add98dfe0a58f18a"


def main():
    index = load_index()
    entries = []
    for fragment, resolution, primitive, rationale, category, causes, caps, mode, size, albedo in CHOICES:
        hits = [c for c in index["logical_candidates"] if fragment in c["stable_id"]]
        if len(hits) != 1:
            raise ValueError("Shortlist fragment not unique: " + fragment)
        c = hits[0]
        bases = [BASE_FLOOR] if "FLOOR" in caps and "WALL" not in caps else [BASE_LIGHT, BASE_DARK]
        if primitive == "EAF4_PATCH":
            bases = [BASE_LIGHT, BASE_PLASTER]
        entries.append({
            "stable_id": c["stable_id"], "resolution": resolution, "primitive": primitive,
            "selection_rationale": rationale, "semantic_category": category,
            "cause_tags": causes, "surface_capabilities": caps, "base_material_ids": bases,
            "resolution_rationale": ("Only available indexed review resolution; broad paint patch warrants 4K." if resolution == "4K"
                                     else "One selected 1K scalar review variant; higher grunge variants excluded." if resolution == "1K"
                                     else "Routine localized review at available 2K."),
            "initial_parameters": {"render_mode": mode, "physical_size_m": size, "surface_offset_m": 0.002,
                                   "opacity_multiplier": 0.85, "albedo_strength": albedo,
                                   "normal_strength": 0.8, "roughness_strength": 0.7,
                                   "provenance": "machine-suggested; human-pending"},
        })
    batch = make_batch("wear_foundation_01", index, entries)
    BATCH.parent.mkdir(parents=True, exist_ok=True)
    BATCH.write_text(json.dumps(batch, indent=2) + "\n", encoding="utf-8")
    print("EAF4B_BATCH", len(entries), BATCH)


if __name__ == "__main__":
    main()
