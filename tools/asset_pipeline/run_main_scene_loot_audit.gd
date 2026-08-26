extends SceneTree

const LootAuditCoreScript = preload("res://tools/asset_pipeline/loot_audit_core.gd")
const MainSceneLootAdapterScript = preload("res://tools/asset_pipeline/main_scene_loot_adapter.gd")
const PrototypeItemCatalogScript = preload("res://prototype_item_catalog.gd")
const StoragePrototypeManagerScript = preload("res://storage_prototype_manager.gd")

const MAIN_SCENE_PATH: String = "res://main.tscn"
const REPORT_DIRECTORY: String = "res://reports/asset_pipeline"
const CSV_REPORT_PATH: String = REPORT_DIRECTORY + "/main_scene_loot_audit.csv"
const JSON_REPORT_PATH: String = REPORT_DIRECTORY + "/main_scene_loot_audit.json"
const SCHEMA_VERSION: String = "1.1"


func _init() -> void:
	quit(_run_audit())


func _run_audit() -> int:
	var cell_size_m: float = StoragePrototypeManagerScript.DEFAULT_WORLD_CELL_SIZE_M
	var scene_records: Array[Dictionary] = MainSceneLootAdapterScript.enumerate_loot_instances(
		MAIN_SCENE_PATH
	)
	var audit_records: Array[Dictionary] = []
	for scene_record: Dictionary in scene_records:
		audit_records.append(_audit_asset(scene_record, cell_size_m))

	var sorted_records: Array[Dictionary] = LootAuditCoreScript.sort_records(audit_records)
	if not _write_reports(sorted_records, cell_size_m):
		return 1

	print("LOOT_AUDIT_COMPLETE assets=%d csv=%s json=%s" % [
		sorted_records.size(),
		CSV_REPORT_PATH,
		JSON_REPORT_PATH
	])
	return 0


func _audit_asset(scene_record: Dictionary, cell_size_m: float) -> Dictionary:
	var source_path: String = String(scene_record.get("source_path", ""))
	var notes: Array[String] = []
	var root_local_bounds: AABB = AABB()
	var effective_canonical_bounds: AABB = AABB()
	var mesh_count: int = 0
	var root_transform: Transform3D = Transform3D.IDENTITY
	var root_scale: Vector3 = Vector3.ONE
	var has_mesh_bounds: bool = false

	var resource: Resource = load(source_path)
	if resource is PackedScene:
		var asset_root: Node = (resource as PackedScene).instantiate()
		if asset_root is Node3D:
			var root_node: Node3D = asset_root as Node3D
			root_transform = root_node.transform
			root_scale = _absolute_scale(root_transform.basis.get_scale())
		else:
			notes.append("ASSET_ROOT_NOT_NODE3D")

		var contributors: Array[Dictionary] = []
		_collect_mesh_contributors(asset_root, Transform3D.IDENTITY, false, contributors)
		var aggregate_result: Dictionary = LootAuditCoreScript.aggregate_contributors(contributors)
		mesh_count = int(aggregate_result.get("mesh_count", 0))
		has_mesh_bounds = bool(aggregate_result.get("valid", false))
		if has_mesh_bounds:
			var root_bounds_value: Variant = aggregate_result.get("bounds", AABB())
			root_local_bounds = root_bounds_value as AABB
			effective_canonical_bounds = LootAuditCoreScript.transform_bounds(
				root_local_bounds,
				root_transform
			)
		else:
			notes.append("NO_MESH_BOUNDS")
		asset_root.free()
	else:
		notes.append("ASSET_LOAD_FAILED")

	var definition: ItemDefinition = PrototypeItemCatalogScript.create_definition_for_scene_path(source_path)
	var has_item_definition: bool = definition != null
	var authored_category: String = ""
	var item_id: String = ""
	var display_name: String = ""
	var existing_footprint: Vector3i = Vector3i.ZERO
	var bulk: int = 0
	if has_item_definition:
		authored_category = definition.storage_category
		item_id = String(definition.item_id)
		display_name = definition.display_name
		existing_footprint = definition.storage_footprint
		bulk = definition.bulk

	var folder_category_hint: String = LootAuditCoreScript.folder_category_hint(source_path)
	var category_source: String = _category_source(
		authored_category,
		folder_category_hint,
		has_item_definition
	)
	var instance_scales: Array = _instance_scale_vectors(scene_record)
	var raw_footprint: Dictionary = _empty_raw_footprint()
	if has_mesh_bounds:
		raw_footprint = LootAuditCoreScript.raw_footprint(
			effective_canonical_bounds.size.abs(),
			cell_size_m
		)

	var flags: PackedStringArray = LootAuditCoreScript.audit_flags({
		"source_path": source_path,
		"authored_category": authored_category,
		"folder_category_hint": folder_category_hint,
		"root_scale": root_scale,
		"instance_scales": instance_scales,
		"mesh_count": mesh_count,
		"effective_bounds": effective_canonical_bounds,
		"raw_width_cells": int(raw_footprint["width_cells"]),
		"raw_depth_cells": int(raw_footprint["depth_cells"]),
		"existing_footprint": existing_footprint,
		"has_item_definition": has_item_definition
	})

	return {
		"asset_key": source_path.get_file().get_basename(),
		"source_path": source_path,
		"scene_nodes": scene_record.get("scene_nodes", []),
		"instance_count": int(scene_record.get("instance_count", 0)),
		"instance_transforms": scene_record.get("instance_transforms", []),
		"item_id": item_id,
		"display_name": display_name,
		"authored_category": authored_category,
		"folder_category_hint": folder_category_hint,
		"category_source": category_source,
		"mesh_count": mesh_count,
		"root_local_bounds": _serialize_bounds(root_local_bounds, has_mesh_bounds),
		"effective_canonical_bounds": _serialize_bounds(
			effective_canonical_bounds,
			has_mesh_bounds
		),
		"width_m": effective_canonical_bounds.size.abs().x if has_mesh_bounds else 0.0,
		"height_m": effective_canonical_bounds.size.abs().y if has_mesh_bounds else 0.0,
		"depth_m": effective_canonical_bounds.size.abs().z if has_mesh_bounds else 0.0,
		"origin_offset_m": _bounds_center(effective_canonical_bounds).length() if has_mesh_bounds else 0.0,
		"longest_dimension_m": _longest_dimension(effective_canonical_bounds) if has_mesh_bounds else 0.0,
		"shortest_dimension_m": _shortest_dimension(effective_canonical_bounds) if has_mesh_bounds else 0.0,
		"aspect_ratio": _aspect_ratio(effective_canonical_bounds) if has_mesh_bounds else 0.0,
		"asset_root_transform": _serialize_transform(root_transform),
		"asset_root_scale": _serialize_vector3(root_scale),
		"cell_size_m": cell_size_m,
		"storage_width_axis": "effective_asset_x",
		"storage_depth_axis": "effective_asset_z",
		"raw_width_cells": int(raw_footprint["width_cells"]),
		"raw_depth_cells": int(raw_footprint["depth_cells"]),
		"raw_orientation_a": String(raw_footprint["orientation_a"]),
		"raw_orientation_b": String(raw_footprint["orientation_b"]),
		"existing_footprint": _serialize_vector3i(existing_footprint),
		"bulk": bulk,
		"flags": _packed_strings_to_array(flags),
		"notes": notes
	}


func _collect_mesh_contributors(
	node: Node,
	accumulated_transform: Transform3D,
	include_node_transform: bool,
	contributors: Array[Dictionary]
) -> void:
	var next_transform: Transform3D = accumulated_transform
	if include_node_transform and node is Node3D:
		next_transform = accumulated_transform * (node as Node3D).transform

	if node is MeshInstance3D:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh != null:
			contributors.append({
				"bounds": mesh_instance.mesh.get_aabb(),
				"transform": next_transform
			})

	for child: Node in node.get_children():
		_collect_mesh_contributors(child, next_transform, true, contributors)


func _write_reports(records: Array[Dictionary], cell_size_m: float) -> bool:
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(REPORT_DIRECTORY)
	)
	if directory_error != OK:
		push_error("Unable to create audit report directory: %s" % REPORT_DIRECTORY)
		return false

	var report: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"audit_configuration": {
			"cell_size_m": cell_size_m,
			"storage_axes": {
				"effective_asset_x": "storage_width",
				"effective_asset_z": "storage_depth"
			},
			"heuristic_thresholds": LootAuditCoreScript.threshold_metadata()
		},
		"assets": records
	}
	var json_text: String = JSON.stringify(report, "\t", true)
	if not _write_text_file(JSON_REPORT_PATH, json_text):
		return false
	return _write_text_file(CSV_REPORT_PATH, _csv_text(records))


func _write_text_file(path: String, content: String) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write audit report: %s" % path)
		return false
	file.store_string(content)
	file.close()
	return true


func _csv_text(records: Array[Dictionary]) -> String:
	var headers: PackedStringArray = [
		"asset_key", "source_path", "scene_nodes", "instance_count", "item_id",
		"display_name", "authored_category", "folder_category_hint", "category_source",
		"mesh_count", "root_local_bounds", "effective_canonical_bounds", "width_m",
		"height_m", "depth_m", "origin_offset_m", "longest_dimension_m",
		"shortest_dimension_m", "aspect_ratio", "asset_root_scale",
		"scene_instance_scales", "cell_size_m", "storage_width_axis",
		"storage_depth_axis", "raw_width_cells", "raw_depth_cells", "raw_orientation_a",
		"raw_orientation_b", "existing_footprint", "bulk", "flags", "notes"
	]
	var lines: PackedStringArray = [",".join(headers)]
	for record: Dictionary in records:
		var row: Array[String] = [
			str(record["asset_key"]),
			str(record["source_path"]),
			_json_inline(record["scene_nodes"]),
			str(record["instance_count"]),
			str(record["item_id"]),
			str(record["display_name"]),
			str(record["authored_category"]),
			str(record["folder_category_hint"]),
			str(record["category_source"]),
			str(record["mesh_count"]),
			_json_inline(record["root_local_bounds"]),
			_json_inline(record["effective_canonical_bounds"]),
			str(record["width_m"]),
			str(record["height_m"]),
			str(record["depth_m"]),
			str(record["origin_offset_m"]),
			str(record["longest_dimension_m"]),
			str(record["shortest_dimension_m"]),
			str(record["aspect_ratio"]),
			_json_inline(record["asset_root_scale"]),
			_json_inline(_instance_scales_for_csv(record["instance_transforms"])),
			str(record["cell_size_m"]),
			str(record["storage_width_axis"]),
			str(record["storage_depth_axis"]),
			str(record["raw_width_cells"]),
			str(record["raw_depth_cells"]),
			str(record["raw_orientation_a"]),
			str(record["raw_orientation_b"]),
			_json_inline(record["existing_footprint"]),
			str(record["bulk"]),
			_json_inline(record["flags"]),
			_json_inline(record["notes"])
		]
		var escaped: PackedStringArray = []
		for value: String in row:
			escaped.append(_csv_escape(value))
		lines.append(",".join(escaped))
	return "\n".join(lines) + "\n"


func _csv_escape(value: String) -> String:
	if value.contains(",") or value.contains("\"") or value.contains("\n") or value.contains("\r"):
		return "\"%s\"" % value.replace("\"", "\"\"")
	return value


func _instance_scale_vectors(scene_record: Dictionary) -> Array:
	var scales: Array = []
	var transforms_value: Variant = scene_record.get("instance_transforms", [])
	var transforms: Array = transforms_value as Array
	for transform_value: Variant in transforms:
		if not (transform_value is Dictionary):
			continue
		var transform_data: Dictionary = transform_value as Dictionary
		var scale_value: Variant = transform_data.get("scale_magnitude", {})
		if scale_value is Dictionary:
			scales.append(_vector3_from_dictionary(scale_value as Dictionary))
	return scales


func _instance_scales_for_csv(instance_transforms_value: Variant) -> Array:
	var scales: Array = []
	if not (instance_transforms_value is Array):
		return scales
	for transform_value: Variant in instance_transforms_value as Array:
		if transform_value is Dictionary:
			var transform_data: Dictionary = transform_value as Dictionary
			scales.append(transform_data.get("scale_magnitude", {}))
	return scales


func _category_source(
	authored_category: String,
	folder_category_hint: String,
	has_item_definition: bool
) -> String:
	if has_item_definition and not authored_category.strip_edges().is_empty():
		return "authored_and_folder" if not folder_category_hint.strip_edges().is_empty() else "authored"
	if not folder_category_hint.strip_edges().is_empty():
		return "folder"
	return "unknown"


func _empty_raw_footprint() -> Dictionary:
	return {
		"width_cells": 0,
		"depth_cells": 0,
		"orientation_a": "",
		"orientation_b": ""
	}


func _serialize_bounds(bounds: AABB, valid: bool) -> Dictionary:
	if not valid:
		return {"valid": false}
	var size: Vector3 = bounds.size.abs()
	return {
		"valid": true,
		"min": _serialize_vector3(bounds.position),
		"max": _serialize_vector3(bounds.position + size),
		"size": _serialize_vector3(size),
		"center": _serialize_vector3(bounds.position + size * 0.5)
	}


func _serialize_transform(transform: Transform3D) -> Dictionary:
	return {
		"origin": _serialize_vector3(transform.origin),
		"basis": [
			_serialize_vector3(transform.basis.x),
			_serialize_vector3(transform.basis.y),
			_serialize_vector3(transform.basis.z)
		]
	}


func _serialize_vector3(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


func _serialize_vector3i(value: Vector3i) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


func _vector3_from_dictionary(value: Dictionary) -> Vector3:
	return Vector3(
		float(value.get("x", 1.0)),
		float(value.get("y", 1.0)),
		float(value.get("z", 1.0))
	)


func _absolute_scale(scale: Vector3) -> Vector3:
	return Vector3(absf(scale.x), absf(scale.y), absf(scale.z))


func _bounds_center(bounds: AABB) -> Vector3:
	return bounds.position + bounds.size.abs() * 0.5


func _longest_dimension(bounds: AABB) -> float:
	var size: Vector3 = bounds.size.abs()
	return maxf(size.x, maxf(size.y, size.z))


func _shortest_dimension(bounds: AABB) -> float:
	var size: Vector3 = bounds.size.abs()
	return minf(size.x, minf(size.y, size.z))


func _aspect_ratio(bounds: AABB) -> float:
	var shortest: float = _shortest_dimension(bounds)
	return _longest_dimension(bounds) / shortest if shortest > 0.000001 else 0.0


func _packed_strings_to_array(values: PackedStringArray) -> Array[String]:
	var output: Array[String] = []
	for value: String in values:
		output.append(value)
	return output


func _json_inline(value: Variant) -> String:
	return JSON.stringify(value, "", true)
