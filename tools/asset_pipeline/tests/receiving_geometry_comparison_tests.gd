extends SceneTree

const COMPARISON_PATH := "res://gameplay/logistics_wing/receiving/receiving_geometry_comparison.tscn"
const COMPARISON_SCRIPT_PATH := "res://gameplay/logistics_wing/receiving/receiving_geometry_comparison.gd"
const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const GEOMETRY_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const EXPECTED_BARRIER_REFERENCE_Y := 1.27
const EXPECTED_DECK_SIZE := Vector3(4.55, 0.12, 6.55)
const EXPECTED_PANEL_SIZE := Vector3(0.08, 1.27, 4.8)
const EXPECTED_ENVELOPE_SIZE := Vector3(3.6, 1.5, 4.8)
const EXPECTED_FLOOR_YS: Array[float] = [1.17, 0.82, 0.57]
const EXPECTED_FUNCTIONAL_SURFACE_COUNT := 16

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check(ResourceLoader.exists(COMPARISON_PATH), "comparison scene exists"):
		_finish()
		return
	_check(ResourceLoader.exists(COMPARISON_SCRIPT_PATH), "comparison script exists")

	var packed := load(COMPARISON_PATH) as PackedScene
	if not _check(packed != null, "comparison scene loads"):
		_finish()
		return
	var comparison := packed.instantiate() as Node3D
	if not _check(comparison != null, "comparison scene instantiates"):
		_finish()
		return
	root.add_child(comparison)
	await process_frame

	_assert_runtime_case_override(comparison)
	_assert_comparison_contract(comparison)
	await _assert_case_invariants(comparison)
	comparison.free()

	await _assert_wing_composition()
	_assert_accepted_shell_contract()
	_finish()


func _assert_runtime_case_override(comparison: Node3D) -> void:
	var expected_case := 1
	for argument: String in OS.get_cmdline_user_args():
		if not argument.begins_with("--receiving-geometry-case="):
			continue
		match argument.trim_prefix("--receiving-geometry-case=").to_upper():
			"A": expected_case = 0
			"B": expected_case = 1
			"C": expected_case = 2
		break
	_check(int(comparison.get("comparison_case")) == expected_case, "runtime case argument selects the requested comparison")
	var deck_mesh := comparison.get_node("LiftDeck/Mesh") as MeshInstance3D
	var deck_top_y := deck_mesh.global_position.y + (deck_mesh.mesh as BoxMesh).size.y * 0.5
	_check(is_equal_approx(deck_top_y, EXPECTED_FLOOR_YS[expected_case]), "runtime case argument applies the requested deck height")


func _assert_comparison_contract(comparison: Node3D) -> void:
	_check(comparison.position.is_equal_approx(Vector3.ZERO), "standalone comparison scene has a neutral local transform")
	_check(comparison.get_script() != null, "comparison root has a script")
	if comparison.get_script() != null:
		_check(comparison.get_script().resource_path == COMPARISON_SCRIPT_PATH, "comparison root uses the intended tool script")

	var deck_mesh := comparison.get_node_or_null("LiftDeck/Mesh") as MeshInstance3D
	var panel_mesh := comparison.get_node_or_null("BarrierOcclusionMockup/Panel") as MeshInstance3D
	var envelope_mesh := comparison.get_node_or_null("PileEnvelopePreview/Volume") as MeshInstance3D
	var proxy_root := comparison.get_node_or_null("ProxyLoad") as Node3D
	var guides := comparison.get_node_or_null("Guides") as Node3D
	_check(deck_mesh != null, "comparison has a lift-deck mesh")
	_check(panel_mesh != null, "comparison has an occlusion-panel mesh")
	_check(envelope_mesh != null, "comparison has an envelope preview")
	_check(proxy_root != null, "comparison has a proxy-load root")
	_check(guides != null, "comparison has guide geometry")
	if deck_mesh != null:
		var deck_box := deck_mesh.mesh as BoxMesh
		_check(deck_box != null and deck_box.size.is_equal_approx(EXPECTED_DECK_SIZE), "deck uses the bounded horizontal dimensions")
	if panel_mesh != null:
		var panel_box := panel_mesh.mesh as BoxMesh
		_check(panel_box != null and panel_box.size.is_equal_approx(EXPECTED_PANEL_SIZE), "visual barrier panel uses the review dimensions")
	if envelope_mesh != null:
		var envelope_box := envelope_mesh.mesh as BoxMesh
		_check(envelope_box != null and envelope_box.size.is_equal_approx(EXPECTED_ENVELOPE_SIZE), "preview envelope uses the provisional dimensions")

	_check(comparison.find_children("*", "CollisionObject3D", true, false).is_empty(), "comparison adds no collision or physics bodies")
	_check(panel_mesh == null or panel_mesh.find_children("*", "CollisionShape3D", true, false).is_empty(), "barrier mockup has no collision")
	_check(comparison.find_children("*", "WorldItem", true, false).is_empty(), "proxy branch contains no WorldItem")
	_check(comparison.find_children("*", "StorageSurface", true, false).is_empty(), "comparison creates no StorageSurface")
	_check(proxy_root == null or proxy_root.get_child_count() >= 8, "proxy load represents a varied review pile")
	_check(guides == null or guides.get_node_or_null("Height_0_5") != null, "guides include floor plus 0.5 metre reference")
	_check(guides == null or guides.get_node_or_null("Height_1_0") != null, "guides include floor plus 1.0 metre reference")
	_check(guides == null or guides.get_node_or_null("Height_1_5") != null, "guides include floor plus 1.5 metre reference")


func _assert_case_invariants(comparison: Node3D) -> void:
	var deck_mesh := comparison.get_node("LiftDeck/Mesh") as MeshInstance3D
	var proxy_root := comparison.get_node("ProxyLoad") as Node3D
	var envelope_root := comparison.get_node("PileEnvelopePreview") as Node3D
	var guides_root := comparison.get_node("Guides") as Node3D
	var panel := comparison.get_node("BarrierOcclusionMockup/Panel") as MeshInstance3D
	var initial_proxy_transforms := _child_transforms(proxy_root)
	var initial_deck_size := (deck_mesh.mesh as BoxMesh).size
	var initial_panel_transform := panel.transform

	for case_index: int in range(EXPECTED_FLOOR_YS.size()):
		comparison.set("comparison_case", case_index)
		await process_frame
		var floor_y := EXPECTED_FLOOR_YS[case_index]
		var deck_top_y := deck_mesh.global_position.y + (deck_mesh.mesh as BoxMesh).size.y * 0.5
		_check(is_equal_approx(deck_top_y, floor_y), "case %s deck top equals its selected floor Y" % case_index)
		_check(is_equal_approx(proxy_root.global_position.y, floor_y), "case %s proxy root follows deck height" % case_index)
		_check(is_equal_approx(envelope_root.global_position.y, floor_y), "case %s envelope begins at deck height" % case_index)
		_check(is_equal_approx(guides_root.global_position.y, floor_y), "case %s guides begin at deck height" % case_index)
		_check((deck_mesh.mesh as BoxMesh).size.is_equal_approx(initial_deck_size), "case %s preserves horizontal deck dimensions" % case_index)
		_check(_transforms_equal(_child_transforms(proxy_root), initial_proxy_transforms), "case %s preserves all proxy local transforms" % case_index)
		_check(panel.transform.is_equal_approx(initial_panel_transform), "case %s does not move the barrier mockup" % case_index)
		_check(is_equal_approx(panel.global_position.y + EXPECTED_PANEL_SIZE.y * 0.5, EXPECTED_BARRIER_REFERENCE_Y), "case %s keeps barrier reference at 1.27 metres" % case_index)


func _assert_wing_composition() -> void:
	var packed := load(GAMEPLAY_PATH) as PackedScene
	if not _check(packed != null, "wing gameplay scene loads"):
		return
	var gameplay := packed.instantiate() as Node3D
	if not _check(gameplay != null, "wing gameplay scene instantiates"):
		return
	root.add_child(gameplay)
	await process_frame
	await physics_frame

	_check(
		gameplay.get_node_or_null("ReceivingGeometryComparison") == null,
		"wing gameplay remains independent from the isolated comparison"
	)
	_check(gameplay.get_node_or_null("Player") is CharacterBody3D, "normal gameplay player instantiates")
	_check(gameplay.get_node_or_null("HUD/CarriedItemsHUD") != null, "normal carried-items HUD instantiates")
	var surfaces := gameplay.call("get_functional_surfaces") as Array[Node]
	_check(surfaces.size() == EXPECTED_FUNCTIONAL_SURFACE_COUNT, "normal gameplay preserves the promoted functional storage count")
	_check(gameplay.find_children("*", "StorageSurface", true, false).size() == EXPECTED_FUNCTIONAL_SURFACE_COUNT, "isolated comparison creates no normal-gameplay storage surfaces")
	gameplay.free()


func _assert_accepted_shell_contract() -> void:
	var packed := load(GEOMETRY_PATH) as PackedScene
	if not _check(packed != null, "accepted freight geometry loads"):
		return
	var geometry := packed.instantiate() as Node3D
	if not _check(geometry != null, "accepted freight geometry instantiates"):
		return
	root.add_child(geometry)

	var floor := geometry.get_node_or_null("Districts/Receiving/Floor_FreightEnclosure") as Node3D
	var north := geometry.get_node_or_null("Districts/Receiving/FreightNorth") as Node3D
	var south := geometry.get_node_or_null("Districts/Receiving/FreightSouth") as Node3D
	var rear := geometry.get_node_or_null("Districts/Receiving/FreightRear") as Node3D
	var upper_rail := geometry.get_node_or_null("Boundaries/FreightBarrier/UpperRail") as Node3D
	_check(floor != null and floor.position.is_equal_approx(Vector3(-41.5, -0.15, 0.0)), "accepted freight base remains unchanged")
	_check(north != null and north.position.is_equal_approx(Vector3(-41.575, 2.1, -3.5)), "accepted north freight wall remains unchanged")
	_check(south != null and south.position.is_equal_approx(Vector3(-41.575, 2.1, 3.5)), "accepted south freight wall remains unchanged")
	_check(rear != null and rear.position.is_equal_approx(Vector3(-44.0, 2.1, 0.0)), "accepted rear freight wall remains unchanged")
	_check(upper_rail != null and upper_rail.position.is_equal_approx(Vector3(-39.0, 1.15, 0.0)), "accepted upper barrier rail remains unchanged")
	if upper_rail != null:
		var mesh_instance := upper_rail.get_node_or_null("Mesh") as MeshInstance3D
		var rail_box := mesh_instance.mesh as BoxMesh if mesh_instance != null else null
		_check(rail_box != null and is_equal_approx(rail_box.size.y, 0.24), "accepted upper rail height remains unchanged")
	geometry.free()


func _child_transforms(parent: Node3D) -> Array[Transform3D]:
	var transforms: Array[Transform3D] = []
	for child: Node in parent.get_children():
		if child is Node3D:
			transforms.append((child as Node3D).transform)
	return transforms


func _transforms_equal(actual: Array[Transform3D], expected: Array[Transform3D]) -> bool:
	if actual.size() != expected.size():
		return false
	for index: int in range(actual.size()):
		if not actual[index].is_equal_approx(expected[index]):
			return false
	return true


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false


func _finish() -> void:
	if _failed:
		push_error("FAIL: receiving geometry comparison tests")
		quit(1)
		return
	print("PASS: receiving geometry comparison tests")
	quit(0)
