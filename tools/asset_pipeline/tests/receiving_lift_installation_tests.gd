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
		check(installation.transform == Transform3D.IDENTITY, "grouping introduces no transform")
		check(installation.find_children("*", "CollisionObject3D", true, false).size() == 1, "installation has exactly one collision authority")
		var barrier := installation.get_node("BarrierCollision") as StaticBody3D
		check(barrier.collision_layer == 1 and barrier.collision_mask == 1, "barrier occupies movement layer only")
		var shape := barrier.get_node("Shape") as CollisionShape3D
		check(shape.shape is BoxShape3D and (shape.shape as BoxShape3D).size.is_equal_approx(Vector3(0.12, 1.2, 4.8)), "simple proxy closes opening below lowered visual top")
		check(shape.global_position.is_equal_approx(Vector3(-38.997356, 0.6, -0.0021447986)), "proxy follows authored barrier boundary")
		var old := scene.get_node("Environment/Greybox/Boundaries/FreightBarrier") as Node3D
		check(not old.visible, "historical barrier visual obsolete")
		var old_shapes := old.find_children("*", "CollisionShape3D", true, false)
		check(old_shapes.size() == 6, "all historical shapes identified")
		for old_shape: CollisionShape3D in old_shapes:
			check(old_shape.disabled, "historical barrier collider disabled")
		var door := installation.get_node("SM_KB3D_LND_PropGarageDoor_B_Door") as Node3D
		for pose: String in ["Closed", "Open"]:
			var marker := installation.get_node("ShutterPoseMarkers/" + pose) as Marker3D
			check(marker.basis == door.basis and is_equal_approx(marker.position.x, door.position.x) and is_equal_approx(marker.position.z, door.position.z) and is_equal_approx(marker.position.y, 1.85 if pose == "Closed" else 4.93), "shutter endpoint preserves X/Z/basis: " + pose)
		for name: String in ["SM_KB3D_LND_PropGarageDoor_B_Door", "SM_ConcretePillar02", "SM_ConcretePillar03", "SM_MetalBeam15"]:
			var visual := installation.get_node(name)
			check(visual.find_children("*", "CollisionObject3D", true, false).is_empty() and visual.find_children("*", "CollisionShape3D", true, false).is_empty(), name + " remains collisionless")
		# Dispatch interior begins east of the west wall at X -37.85.
		var dispatch := AABB(Vector3(-37.85, 0, -8.35), Vector3(9.2, 3.4, 3.2))
		for name: String in ["SM_ConcretePillar02", "SM_ConcretePillar03", "SM_MetalBeam15"]:
			for mesh: MeshInstance3D in installation.get_node(name).find_children("*", "MeshInstance3D", true, false):
				check(not dispatch.intersects(mesh.global_transform * mesh.get_aabb()), name + " stays outside Dispatch playable volume")
		var player := scene.get_node("Player") as CharacterBody3D
		player.set_physics_process(false)
		for z: float in [-2.3, -1.9, -1.2, 0.0, 1.2, 1.9, 2.3]:
			var parameters := PhysicsTestMotionParameters3D.new()
			parameters.from = Transform3D(Basis.IDENTITY, Vector3(-38, 0.01, z))
			parameters.motion = Vector3(-2, 0, 0)
			var result := PhysicsTestMotionResult3D.new()
			check(PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result), "capsule excluded at Z %.2f" % z)
			check(result.get_collider() == barrier or (absf(z) > 2.0 and "ReceivingWest" in str(result.get_collider().get_path())), "barrier or retained aperture jamb stops capsule at Z %.2f" % z)
		for probe: Array in [[Vector3(-38.2, 0.01, -3), Vector3(0, 0, 6)], [Vector3(-33, 0.01, -4), Vector3(0, 0, -2)]]:
			var parameters := PhysicsTestMotionParameters3D.new()
			parameters.from = Transform3D(Basis.IDENTITY, probe[0])
			parameters.motion = probe[1]
			check(not PhysicsServer3D.body_test_motion(player.get_rid(), parameters), "apron/Dispatch circulation stays open")
	scene.free()
	print("FAIL: Receiving lift installation tests" if failed else "PASS: Receiving lift installation tests")
	quit(1 if failed else 0)
