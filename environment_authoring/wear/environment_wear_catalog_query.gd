class_name EnvironmentWearCatalogQuery
extends RefCounted

const CATALOG_PATH := "res://data/environment/wear_catalog/catalog.json"

static func load_catalog() -> Array:
    if not FileAccess.file_exists(CATALOG_PATH):
        push_error("EAF4B wear catalog missing")
        return []
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
    if not parsed is Dictionary or parsed.get("schema_version") != 1 or not parsed.get("wear") is Array:
        push_error("EAF4B wear catalog schema invalid")
        return []
    return parsed["wear"]

static func query(semantic_category: String = "", cause_tag: String = "", surface_capability: String = "", render_mode: String = "", include_noncurrent := false) -> Array[Dictionary]:
    return query_records(load_catalog(), semantic_category, cause_tag, surface_capability, render_mode, include_noncurrent)

static func query_records(records: Array, semantic_category: String = "", cause_tag: String = "", surface_capability: String = "", render_mode: String = "", include_noncurrent := false) -> Array[Dictionary]:
    var results: Array[Dictionary] = []
    for value in records:
        if not value is Dictionary:
            continue
        var entry: Dictionary = value
        if not include_noncurrent and entry.get("effective_status") != "APPROVED":
            continue
        if not semantic_category.is_empty() and entry.get("semantic_category") != semantic_category:
            continue
        if not cause_tag.is_empty() and cause_tag not in entry.get("cause_tags", []):
            continue
        if not surface_capability.is_empty() and surface_capability not in entry.get("surface_capabilities", []):
            continue
        if not render_mode.is_empty() and entry.get("render_mode") != render_mode:
            continue
        results.append(entry)
    return results
