class_name EnvironmentMaterialCatalogQuery
extends RefCounted

const CATALOG_PATH := "res://data/environment/material_catalog/catalog.json"


static func load_catalog() -> Array:
	if not FileAccess.file_exists(CATALOG_PATH):
		push_error("EAF3B catalog is missing")
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if not parsed is Dictionary or parsed.get("schema_version") != 1 or not parsed.get("materials") is Array:
		push_error("EAF3B catalog schema is invalid")
		return []
	return parsed["materials"]


static func query(surface_family: String = "", vdd_layer: String = "", approved_role: String = "", include_noncurrent: bool = false) -> Array[Dictionary]:
	return query_records(load_catalog(), surface_family, vdd_layer, approved_role, include_noncurrent)


static func query_records(records: Array, surface_family: String = "", vdd_layer: String = "", approved_role: String = "", include_noncurrent: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value in records:
		if not value is Dictionary:
			continue
		var record: Dictionary = value
		if not include_noncurrent and record.get("effective_status") != "APPROVED":
			continue
		if not surface_family.is_empty() and record.get("surface_family") != surface_family:
			continue
		if not vdd_layer.is_empty() and record.get("vdd_layer") != vdd_layer:
			continue
		if not approved_role.is_empty() and approved_role not in record.get("approved_roles", []):
			continue
		result.append(record)
	return result
