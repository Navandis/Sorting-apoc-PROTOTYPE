extends SceneTree

const WingScene = preload("res://gameplay/logistics_wing/wing_gameplay.tscn")
var failed := false

func _init() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> bool:
	if not condition:
		failed = true
		push_error("ASSERTION FAILED: " + message)
	return condition

func run() -> void:
	var scene := WingScene.instantiate()
	root.add_child(scene)
	await physics_frame
	await physics_frame
	var installation := scene.get_node_or_null("ReceivingLiftInstallation") as Node3D
	if check(installation != null, "manual lift has scene-local ownership"):
		assert_shaft_walls(scene, installation)
		check(installation.transform == Transform3D(Basis.IDENTITY, Vector3(3, 0, 0)), "ensemble translates once with unit basis")
		check(installation.find_children("*", "CollisionObject3D", true, false).size() == 1, "installation has exactly one collision authority")
		var barrier := installation.get_node("BarrierCollision") as StaticBody3D
		check(barrier.collision_layer == 1 and barrier.collision_mask == 1, "barrier occupies movement layer only")
		var shape := barrier.get_node("Shape") as CollisionShape3D
		check(shape.shape is BoxShape3D and (shape.shape as BoxShape3D).size.is_equal_approx(Vector3(0.12, 1.2, 4.8)), "simple proxy closes opening below lowered visual top")
		check(shape.global_position.is_equal_approx(Vector3(-35.997356, 0.6, -0.0021447986)), "proxy follows authored barrier boundary")
		var old := scene.get_node("Environment/Greybox/Boundaries/FreightBarrier") as Node3D
		check(not old.visible, "historical barrier visual obsolete")
		var old_shapes := old.find_children("*", "CollisionShape3D", true, false)
		check(old_shapes.size() == 6, "all historical shapes identified")
		for old_shape: CollisionShape3D in old_shapes:
			check(old_shape.disabled, "historical barrier collider disabled")
		var active_path: NodePath = installation.get_meta("active_shutter", NodePath())
		check(active_path == NodePath("SM_KB3D_NWD_ReuGarageDoorBlue_B"), "explicit active NWD shutter reference")
		var door := installation.get_node_or_null(active_path) as Node3D if not active_path.is_empty() else null
		if check(door != null, "active shutter reference resolves"):
			var open_pose := Transform3D(Basis(Vector3(1, 0, 0), Vector3(0, 1.305, 0), Vector3(0, 0, 0.69)), Vector3(-39.164536, 3.1416707, -0.01947911))
			# Human art checkpoint 8857615 saves the visible shutter closed; marker endpoints remain the accepted pose authority.
			var authored_closed := Transform3D(Basis(Vector3(1, 0, 0), Vector3(0, 1.305, 0), Vector3(0, 0, 0.69)), Vector3(-39.165, 0.086, -0.019))
			check(door.visible and door.transform == authored_closed, "human-authored NWD closed transform remains exact")
			for pose: String in ["Closed", "Open"]:
				var expected := open_pose
				if pose == "Closed":
					expected.origin.y = 0.086
				var marker := installation.get_node("ShutterPoseMarkers/" + pose) as Marker3D
				check(marker.transform == expected, "full NWD basis/X/Z/endpoint: " + pose)
			check(installation.get_node_or_null("SM_KB3D_LND_PropGarageDoor_B_Door") == null, "unused hidden predecessor instance retired")
		for name: String in ["SM_KB3D_NWD_ReuGarageDoorBlue_B", "SM_ConcretePillar02", "SM_ConcretePillar03", "SM_MetalBeam15"]:
			var visual := installation.get_node(name)
			check(visual.find_children("*", "CollisionObject3D", true, false).is_empty() and visual.find_children("*", "CollisionShape3D", true, false).is_empty(), name + " remains collisionless")
		# Barrier sweeps start in the clear strip next to the barrier, outside the human-authored pallet-jack staging.
		# Dispatch interior begins east of the west wall at X -34.85.
		var dispatch := AABB(Vector3(-34.85, 0, -7.35), Vector3(6.2, 4.2, 3.2))
		for name: String in ["SM_ConcretePillar02", "SM_ConcretePillar03", "SM_MetalBeam15"]:
			for mesh: MeshInstance3D in installation.get_node(name).find_children("*", "MeshInstance3D", true, false):
				check(not dispatch.intersects(mesh.global_transform * mesh.get_aabb()), name + " stays outside Dispatch playable volume")
		var player := scene.get_node("Player") as CharacterBody3D
		player.set_physics_process(false)
		for z: float in [-2.3, -1.9, -1.2, 0.0, 1.2, 1.9, 2.3]:
			var parameters := PhysicsTestMotionParameters3D.new()
			parameters.from = Transform3D(Basis.IDENTITY, Vector3(-35.5, 0.01, z))
			parameters.motion = Vector3(-2, 0, 0)
			var result := PhysicsTestMotionResult3D.new()
			check(PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result), "capsule excluded at Z %.2f" % z)
			check(result.get_collision_count() > 0 and (result.get_collider() == barrier or (absf(z) > 2.0 and "ReceivingWest" in str(result.get_collider().get_path()))), "barrier or retained aperture jamb stops capsule at Z %.2f" % z)
		for probe: Array in [[Vector3(-35.15, 0.01, -2.25), Vector3(0, 0, 4.0)], [Vector3(-31.714286, 0.01, -3), Vector3(0, 0, -2)]]:
			var parameters := PhysicsTestMotionParameters3D.new()
			parameters.from = Transform3D(Basis.IDENTITY, probe[0])
			parameters.motion = probe[1]
			check(not PhysicsServer3D.body_test_motion(player.get_rid(), parameters), "apron/Dispatch circulation stays open")
	scene.free()
	print("FAIL: Receiving lift installation tests" if failed else "PASS: Receiving lift installation tests")
	quit(1 if failed else 0)

# Catches lining drifting into the measured cage, aperture, or gameplay collision.
func assert_shaft_walls(scene: Node3D, installation: Node3D) -> void:
	var group := installation.get_node_or_null("ShaftWalls") as Node3D
	if not check(group != null, "shaft lining exists under fixed installation"):
		return
	check(group.transform == Transform3D.IDENTITY and group.owner == scene, "shaft group is scene-owned at unit identity")
	check(group.get_child_count() == 3, "exactly three walls; front remains open")
	check(group.find_children("*", "CollisionObject3D", true, false).is_empty() and group.find_children("*", "CollisionShape3D", true, false).is_empty(), "shaft lining adds no collision")
	var cage := AABB()
	var first := true
	var sources: Array[Node] = [scene.get_node("ReceivingRuntime/ReceivingDeckPresenter/DeckVisual/SM_Platform_01")]
	for name: String in ["SM_Fence_01", "SM_Fence_02", "SM_Fence_03", "SM_IndustrialPlatform04", "SM_WallPart_01", "SM_WallPart_02", "SM_WallPart_03"]:
		sources.append(installation.get_node(name))
	for source in sources:
		var bounds := transformed_mesh_bounds(source)
		cage = bounds if first else cage.merge(bounds)
		first = false
	# Saved bounds from human checkpoint c76442f supersede generated recipes.
	var expected_bounds := {
		"ShaftWall_Left": AABB(Vector3(-38.9262, 0, 1.868874), Vector3(2.360313, 4.2, 0.3)),
		"ShaftWall_Right": AABB(Vector3(-38.91947, 0, -2.174801), Vector3(2.360313, 4.2, 0.3)),
		"ShaftWall_Rear": AABB(Vector3(-38.91168, 0, -1.98794), Vector3(0.300003, 4.2, 3.998673)),
	}
	var wall_bounds := {}
	for name: String in ["ShaftWall_Left", "ShaftWall_Right", "ShaftWall_Rear"]:
		var wall := group.get_node_or_null(name) as EnvironmentSubstratePiece
		if not check(wall != null, name + " uses EAF2 owner"):
			continue
		check(wall.owner == scene and wall.scale.is_equal_approx(Vector3.ONE) and wall.validate_authoring().is_empty(), name + " valid unit production authoring")
		var spec := wall.piece_spec
		check(spec.recipe_id == "rect_solid" and spec.collision_policy == EnvironmentSubstratePieceSpec.CollisionPolicy.NONE, name + " collisionless solid recipe")
		check(spec.material_spec.material_id == "eaf3b_1beac3a311a480af8844ea89" and spec.material_spec.mapping_mode == 0 and is_equal_approx(spec.material_spec.meters_per_repeat, 3.0) and spec.uv_quarter_turns == 0, name + " selected Reinforced Concrete Slabs default UV / physical scale")
		var mesh := wall.get_node("GeneratedMesh") as MeshInstance3D
		check(mesh.owner == scene and mesh.mesh != null and mesh.material_override is StandardMaterial3D, name + " saved generated mesh/material")
		var material := mesh.material_override as StandardMaterial3D
		check(material.albedo_texture == spec.material_spec.base_color_texture and material.uv1_scale.is_equal_approx(Vector3.ONE / 3.0) and material.cull_mode == BaseMaterial3D.CULL_BACK, name + " actual material binding and scale")
		check(is_equal_approx(spec.material_spec.normal_strength, 1.0) and is_equal_approx(material.normal_scale, 1.0) and material.normal_texture == spec.material_spec.normal_texture and material.roughness_texture == spec.material_spec.roughness_texture and material.metallic_texture == spec.material_spec.metallic_texture, name + " approved normal/roughness/metallic binding")
		check(is_equal_approx(material.roughness, spec.material_spec.roughness_multiplier) and is_equal_approx(material.metallic, spec.material_spec.metallic_multiplier) and material.albedo_color.is_equal_approx(Color(spec.material_spec.albedo_multiplier, spec.material_spec.albedo_multiplier, spec.material_spec.albedo_multiplier)), name + " approved material multipliers")
		check(not material.uv1_triplanar and not material.uv1_world_triplanar and not material.ao_enabled and not material.heightmap_enabled and mesh.material_overlay == null and mesh.get_child_count() == 0, name + " UV mapping with no finish/secondary/wear")
		var bounds := transformed_mesh_bounds(wall)
		wall_bounds[name] = bounds
		check(not bounds.intersects(cage), name + " separated from full transformed cage bounds")
		check(absf(bounds.position.y) < 0.001 and absf(bounds.end.y - 4.2) < 0.001, name + " joins floor/ceiling without gap")
		check(bounds.position.distance_to(expected_bounds[name].position) < 0.0001 and bounds.size.distance_to(expected_bounds[name].size) < 0.0001, name + " preserves human mesh bounds")
		var clearance: float
		if name == "ShaftWall_Left":
			clearance = bounds.position.z - cage.end.z
			check(absf(bounds.size.z - 0.30) < 0.001, "left thickness extends outward")
		elif name == "ShaftWall_Right":
			clearance = cage.position.z - bounds.end.z
			check(absf(bounds.size.z - 0.30) < 0.001, "right thickness extends outward")
		else:
			clearance = cage.position.x - bounds.end.x
			check(absf(bounds.size.x - 0.30) < 0.001, "rear thickness extends outward")
		check(clearance >= 0.099, name + " retains positive clearance from widened cage")
		print("SHAFT ", name, " bounds=", bounds, " clearance=", clearance)

func transformed_mesh_bounds(node: Node) -> AABB:
	var bounds := AABB()
	var first := true
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			for vertex: Vector3 in mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
				var point := mesh.global_transform * vertex
				bounds = AABB(point, Vector3.ZERO) if first else bounds.expand(point)
				first = false
	return bounds
