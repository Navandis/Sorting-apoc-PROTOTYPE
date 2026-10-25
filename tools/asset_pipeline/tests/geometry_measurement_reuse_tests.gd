extends SceneTree

const Pose = preload("res://storage_visual_pose.gd")
var checks := 0
var failures := 0
var pose_api: GDScript = load("res://storage_visual_pose.gd")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _init() -> void:
	run.call_deferred()

func run() -> void:
	# Independent vertex oracle also records the accepted Stage A outputs.
	var compound := Node3D.new()
	compound.rotation = Vector3(0.3, -0.2, 0.7)
	compound.scale = Vector3(0.4, 1.3, 0.8)
	var mesh := ArrayMesh.new()
	for height: float in [-0.3, 0.9]:
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3(-0.4, height, 0.1), Vector3(0.7, height + 0.2, 0.3), Vector3(0.1, height + 0.7, -0.5)])
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = Vector3(0.2, -0.7, 0.4)
	compound.add_child(instance)
	var compound_packing := Node3D.new()
	verify(Pose.build_visual(compound_packing, compound, Vector3(17, 31, -12), true), "nested multi-surface procedural bypass")
	compound_packing.free()
	for id: String in ["loot_000061", "loot_000147", "loot_000041", "loot_000059", "loot_000025", "loot_000108", "loot_000152", "loot_000163"]:
		var definition := PrototypeItemCatalog.get_definition_by_id(StringName(id))
		for rotated: bool in [false, true]:
			for factor: float in [1.0, 1.25]:
				var visual := definition.visual_scene.instantiate() as Node3D
				definition.apply_visual_scale(visual)
				visual.scale *= factor
				var packing := Node3D.new()
				var result := Pose.build_visual(packing, visual, definition.storage_rotation_degrees, rotated)
				verify(result, id)
				print("GEOMETRY_REFERENCE ", id, " rotated=", rotated, " scale_factor=", factor, " posed=", result.posed_bounds, " aligned=", result.aligned_bounds, " offset=", result.seating_offset)
				# Reuse the same visual after a changed nested transform and pose.
				visual.get_parent().remove_child(visual)
				packing.free()
				visual.position += Vector3(0.017, -0.023, 0.031)
				var nested := Node3D.new()
				nested.transform = Transform3D(Basis.from_euler(Vector3(0.2, -0.1, 0.3)).scaled(Vector3(1.1, 0.8, 1.2)), Vector3(-0.1, 0.2, 0.07))
				nested.add_child(visual)
				packing = Node3D.new()
				result = Pose.build_visual(packing, nested, definition.storage_rotation_degrees + Vector3(11, 7, -3), rotated)
				verify(result, id + " nested/reused")
				packing.free()
	# A production measurement followed by recreation must do no vertex work.
	var cache_api := pose_api.has_method("get_measurement_cache_stats")
	check(cache_api, "Repeated geometry currently has no process measurement reuse")
	if cache_api:
		pose_api.call("clear_measurement_cache")
		var item := ItemInstance.new(PrototypeItemCatalog.get_definition_by_id(&"loot_000147"))
		var first := Pose.measure_item(item, false)
		var before: Dictionary = pose_api.call("get_measurement_cache_stats")
		var second := Pose.measure_item(item, true)
		var after: Dictionary = pose_api.call("get_measurement_cache_stats")
		check(before.vertex_visits > 0 and after.vertex_visits == before.vertex_visits, "Free/recreate and packing yaw must reuse exact mesh measurements")
		check(after.hits > before.hits, "Repeated mesh/transform produces cache hits")
		check(first.posed_bounds == second.posed_bounds and first.seating_offset == second.seating_offset, "Packing yaw leaves seating geometry unchanged")
		_test_resource_change_and_limit()
	print("GEOMETRY_REUSE_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)

func _test_resource_change_and_limit() -> void:
	var definition := PrototypeItemCatalog.get_definition_by_id(&"loot_000041")
	var visual := definition.visual_scene.instantiate() as Node3D
	var mesh_node := find_mesh(visual)
	var mesh := mesh_node.mesh as ArrayMesh
	var originals: Array = []
	var primitives: Array = []
	for surface: int in mesh.get_surface_count():
		originals.append(mesh.surface_get_arrays(surface))
		primitives.append(mesh.surface_get_primitive_type(surface))
	var packing := Node3D.new()
	verify(Pose.build_visual(packing, visual, definition.storage_rotation_degrees, false), "original mutable resource")
	var before: Dictionary = pose_api.call("get_measurement_cache_stats")
	mesh.clear_surfaces()
	for surface: int in originals.size():
		var changed: Array = originals[surface].duplicate(true)
		var vertices: PackedVector3Array = changed[Mesh.ARRAY_VERTEX]
		for index: int in vertices.size():
			vertices[index] += Vector3(0.09, -0.11, 0.07)
		changed[Mesh.ARRAY_VERTEX] = vertices
		mesh.add_surface_from_arrays(primitives[surface], changed)
	# Mutable resource owners must announce changes; GPU-only deformation is
	# outside immutable imported-loot reuse. No authored file is written here.
	mesh.emit_changed()
	visual.get_parent().remove_child(visual)
	packing.free()
	packing = Node3D.new()
	verify(Pose.build_visual(packing, visual, definition.storage_rotation_degrees, false), "same resource changed geometry")
	var after: Dictionary = pose_api.call("get_measurement_cache_stats")
	check(after.misses > before.misses and after.vertex_visits > before.vertex_visits, "Mesh changed signal invalidates old geometry")
	mesh.clear_surfaces()
	for surface: int in originals.size():
		mesh.add_surface_from_arrays(primitives[surface], originals[surface])
	mesh.emit_changed()
	packing.free()
	# Many different accumulated transforms must stay bounded, including eviction.
	for index: int in 520:
		packing = Node3D.new()
		visual = definition.visual_scene.instantiate()
		visual.position.y = float(index) * 0.01
		var result := Pose.build_visual(packing, visual, definition.storage_rotation_degrees, false)
		if index in [0, 511, 519]:
			verify(result, "cache capacity/eviction")
		packing.free()
	var stats: Dictionary = pose_api.call("get_measurement_cache_stats")
	check(stats.entries <= 512 and stats.meshes <= 512, "Process cache retains bounded measurements and mesh resources")
	pose_api.call("clear_measurement_cache")
	check(pose_api.call("get_measurement_cache_stats").entries == 0, "Explicit cache clear releases measurements")

func find_mesh(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D and node.mesh != null:
		return node
	for child: Node in node.get_children():
		var found := find_mesh(child)
		if found != null:
			return found
	return null

func verify(result: Dictionary, label: String) -> void:
	var state := {"valid": false, "bounds": AABB(), "min_y": INF, "vertices": 0, "surfaces": 0}
	scan(result.pose_root, Transform3D.IDENTITY, state)
	var conservative: AABB = state.bounds
	var expected := AABB(Vector3(conservative.position.x, state.min_y, conservative.position.z), Vector3(conservative.size.x, conservative.end.y - state.min_y, conservative.size.z))
	var posed: AABB = result.posed_bounds
	check(posed.position.is_equal_approx(expected.position) and posed.size.is_equal_approx(expected.size), label + " exact vertex bottom and conservative extents/top")
	check(is_equal_approx(state.min_y + result.seating_offset.y, 0.006), label + " true shelf gap is 6 mm")
	check(is_equal_approx(result.aligned_bounds.position.y, 0.006), label + " aligned shelf gap")
	var center: Vector3 = result.aligned_bounds.get_center()
	check(is_zero_approx(center.x) and is_zero_approx(center.z), label + " conservative horizontal centering")

func scan(node: Node, parent_transform: Transform3D, state: Dictionary) -> void:
	var transform := parent_transform
	if node is Node3D:
		transform *= node.transform
	if node is MeshInstance3D and node.mesh != null:
		var bounds: AABB = transform * node.mesh.get_aabb()
		state.bounds = state.bounds.merge(bounds) if state.valid else bounds
		state.valid = true
		for surface: int in node.mesh.get_surface_count():
			state.surfaces += 1
			for vertex: Vector3 in node.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
				state.min_y = minf(state.min_y, (transform * vertex).y)
				state.vertices += 1
	for child: Node in node.get_children():
		scan(child, transform, state)
