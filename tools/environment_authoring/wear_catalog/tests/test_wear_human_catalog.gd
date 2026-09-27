extends SceneTree

const Query = preload("res://environment_authoring/wear/environment_wear_catalog_query.gd")
const Spec = preload("res://environment_authoring/wear/environment_wear_overlay_spec.gd")
const Overlay = preload("res://environment_authoring/wear/environment_wear_overlay.gd")

func _initialize() -> void:
    var all_records := Query.load_catalog()
    var approved := Query.query()
    assert(all_records.size() == 8)
    assert(approved.size() == 7)
    assert(Query.query("CRACK").size() == 2)
    assert(Query.query("SPALL").size() == 2)
    assert(Query.query("WATER_MINERAL", "moisture_leak", "WALL", "SOFT_BLEND").size() == 1)
    assert(Query.query("OIL_GREASE", "maintenance", "FLOOR", "SOFT_BLEND").size() == 1)
    assert(Query.query("IMPERFECTION_MASK").size() == 1)
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
    assert(masks is Dictionary and masks["masks"].size() == 1)
    var mask: Dictionary = masks["masks"][0]
    assert(mask["modulation_only"])
    assert(load(mask["texture"]) is Texture2D)
    for entry in all_records:
        if entry["status"] == "DEFERRED":
            assert(entry["effective_status"] == "DEFERRED")
            assert(entry not in approved)
    print("EAF4B_HUMAN_CATALOG_TEST_PASS")
    quit(0)
