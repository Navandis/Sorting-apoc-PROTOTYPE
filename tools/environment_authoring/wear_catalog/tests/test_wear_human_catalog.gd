extends SceneTree

const Query = preload("res://environment_authoring/wear/environment_wear_catalog_query.gd")
const Spec = preload("res://environment_authoring/wear/environment_wear_overlay_spec.gd")
const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")

func _initialize() -> void:
    var all_records := Query.load_catalog()
    var approved := Query.query()
    assert(all_records.size() == 28)
    assert(approved.size() == 27)
    assert(Query.query("CRACK").size() == 2)
    assert(Query.query("SPALL").size() == 2)
    assert(Query.query("WATER_MINERAL", "moisture_leak", "WALL", "SOFT_BLEND").size() == 3)
    assert(Query.query("OIL_GREASE", "maintenance", "FLOOR", "SOFT_BLEND").size() == 1)
    assert(Query.query("GRIME", "cart_freight", "FLOOR", "SOFT_BLEND").size() == 1)
    assert(Query.query("RUST_CORROSION", "corrosion").size() == 1)
    assert(Query.query("PAINT_DAMAGE").size() == 1)
    assert(Query.query("IMPERFECTION_MASK").size() == 16)
    for entry in approved:
        assert(entry["current_source_fingerprint"] == entry["reviewed_source_fingerprint"])
        if entry["semantic_category"] == "IMPERFECTION_MASK":
            continue
        var path := "res://data/environment/wear_catalog/approved_specs/%s.tres" % entry["catalog_wear_id"]
        var spec := load(path) as Spec
        assert(spec != null)
        assert(spec.validate().is_empty())
        assert(Overlay.build_material(spec) != null)
    var masks: Variant = JSON.parse_string(FileAccess.get_file_as_string(
        "res://data/environment/wear_catalog/approved_specs/approved_masks.json"))
    assert(masks is Dictionary and masks["masks"].size() == 16)
    var opacity_count := 0
    var roughness_count := 0
    for mask in masks["masks"]:
        assert(not mask["modulation_only"])
        assert(mask["supported_uses"] == ["TINTED_OPACITY_LAYER", "WEAR_OPACITY_MODULATION"])
        assert(mask["scalar_sha256"].length() == 64)
        assert(load(mask["texture"]) is Texture2D)
        if mask["scalar_channel"] == "opacity.red": opacity_count += 1
        elif mask["scalar_channel"] == "roughness.red": roughness_count += 1
        else: assert(false)
    assert(opacity_count == 11 and roughness_count == 5)
    var deferred_count := 0
    for entry in all_records:
        if entry["status"] == "DEFERRED":
            deferred_count += 1
            assert(entry["effective_status"] == "DEFERRED")
            assert(entry not in approved)
    assert(deferred_count == 1)
    assert(all_records.filter(func(r): return r["effective_status"] == "DEFERRED" and r["semantic_category"] == "PAINT_REMNANT").size() == 1)
    print("EAF4B_HUMAN_CATALOG_TEST_PASS")
    quit(0)
