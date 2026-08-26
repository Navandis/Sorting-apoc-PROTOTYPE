extends RefCounted
class_name MainSceneLootAdapter


static func enumerate_loot_instances(scene_path: String) -> Array[Dictionary]:
	var scene_resource: Resource = load(scene_path)
	if not (scene_resource is PackedScene):
		return []

	var state: SceneState = (scene_resource as PackedScene).get_state()
	var local_transforms: Dictionary = {}
	var parent_paths: Dictionary = {}
	for node_index: int in range(state.get_node_count()):
		var node_path: String = String(state.get_node_path(node_index))
		local_transforms[node_path] = _node_local_transform(state, node_index)
		parent_paths[node_path] = String(state.get_node_path(node_index, true))

	var composed_transforms: Dictionary = {}
	var grouped: Dictionary = {}
	for node_index: int in range(state.get_node_count()):
		var instance_scene: PackedScene = state.get_node_instance(node_index)
		if instance_scene == null:
			continue

		var source_path: String = instance_scene.resource_path
		if not _is_prop_glb(source_path):
			continue

		var node_path: String = String(state.get_node_path(node_index))
		var node_name: String = String(state.get_node_name(node_index))
		var scene_transform: Transform3D = _composed_transform(
			node_path,
			local_transforms,
			parent_paths,
			composed_transforms
		)

		if not grouped.has(source_path):
			grouped[source_path] = {
				"source_path": source_path,
				"scene_nodes": [],
				"instance_transforms": []
			}

		var grouped_value: Variant = grouped[source_path]
		var record: Dictionary = grouped_value as Dictionary
		var scene_nodes_value: Variant = record["scene_nodes"]
		var scene_nodes: Array = scene_nodes_value as Array
		scene_nodes.append(node_name)
		record["scene_nodes"] = scene_nodes

		var transforms_value: Variant = record["instance_transforms"]
		var instance_transforms: Array = transforms_value as Array
		instance_transforms.append(_serialize_transform(node_path, scene_transform))
		record["instance_transforms"] = instance_transforms
		grouped[source_path] = record

	var records: Array[Dictionary] = []
	for source_path_value: Variant in grouped.keys():
		var record_value: Variant = grouped[source_path_value]
		var record: Dictionary = record_value as Dictionary
		var scene_nodes_value: Variant = record["scene_nodes"]
		var scene_nodes: Array = scene_nodes_value as Array
		record["instance_count"] = scene_nodes.size()
		records.append(record)

	records.sort_custom(_record_path_less_than)
	return records


static func _node_local_transform(state: SceneState, node_index: int) -> Transform3D:
	for property_index: int in range(state.get_node_property_count(node_index)):
		var property_name: StringName = state.get_node_property_name(node_index, property_index)
		if property_name == &"transform":
			var value: Variant = state.get_node_property_value(node_index, property_index)
			if value is Transform3D:
				return value as Transform3D
	return Transform3D.IDENTITY


static func _composed_transform(
	node_path: String,
	local_transforms: Dictionary,
	parent_paths: Dictionary,
	cache: Dictionary
) -> Transform3D:
	if cache.has(node_path):
		var cached_value: Variant = cache[node_path]
		return cached_value as Transform3D

	var local_value: Variant = local_transforms.get(node_path, Transform3D.IDENTITY)
	var local_transform: Transform3D = local_value as Transform3D
	var parent_path: String = String(parent_paths.get(node_path, ""))
	var composed: Transform3D = local_transform
	if not parent_path.is_empty() and parent_path != node_path and local_transforms.has(parent_path):
		composed = _composed_transform(parent_path, local_transforms, parent_paths, cache) * local_transform

	cache[node_path] = composed
	return composed


static func _serialize_transform(node_path: String, transform: Transform3D) -> Dictionary:
	var scale: Vector3 = transform.basis.get_scale()
	var scale_magnitude: Vector3 = Vector3(absf(scale.x), absf(scale.y), absf(scale.z))
	return {
		"node_path": node_path,
		"origin": _serialize_vector3(transform.origin),
		"basis": [
			_serialize_vector3(transform.basis.x),
			_serialize_vector3(transform.basis.y),
			_serialize_vector3(transform.basis.z)
		],
		"scale_magnitude": _serialize_vector3(scale_magnitude)
	}


static func _serialize_vector3(value: Vector3) -> Dictionary:
	return {"x": value.x, "y": value.y, "z": value.z}


static func _is_prop_glb(source_path: String) -> bool:
	var normalized_path: String = source_path.to_lower()
	return normalized_path.begins_with("res://assets/props/") and normalized_path.ends_with(".glb")


static func _record_path_less_than(left: Dictionary, right: Dictionary) -> bool:
	var left_path: String = String(left.get("source_path", ""))
	var right_path: String = String(right.get("source_path", ""))
	var left_normalized: String = left_path.to_lower()
	var right_normalized: String = right_path.to_lower()
	if left_normalized == right_normalized:
		return left_path < right_path
	return left_normalized < right_normalized
