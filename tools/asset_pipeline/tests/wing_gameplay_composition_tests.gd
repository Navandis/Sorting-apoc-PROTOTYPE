extends SceneTree

const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const GEOMETRY_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const PLAYER_SCRIPT_PATH := "res://player_controller.gd"
const CARRIED_SCRIPT_PATH := "res://carried_items.gd"
const HUD_SCRIPT_PATH := "res://carried_items_hud.gd"
const ENVIRONMENT_PATH := "res://gameplay/logistics_wing/wing_environment.tscn"
const DEVELOPMENT_SETUP_PATH := "res://gameplay/logistics_wing/development/seeded_storage_setup.tscn"
const RECEIVING_RUNTIME_PATH := "res://gameplay/logistics_wing/receiving/receiving_runtime.tscn"
const RECEIVING_RUNTIME_SCRIPT_PATH := "res://gameplay/logistics_wing/receiving/receiving_runtime.gd"
const RECEIVING_PRESENTER_SCRIPT_PATH := "res://gameplay/logistics_wing/receiving/receiving_deck_presenter.gd"
const CATALOGUE_PATH := "res://data/items/item_catalog.tres"
const LIVE_PALETTE_ROUND_TRIP_PATH := "user://wing_live_palette_transform_test.tscn"
const BLOCKED_ITEM_IDS: Array[StringName] = [
	&"loot_000034",
	&"loot_000036",
]
const FIXTURE_NAMES: Array[String] = [
	"SM_MetalShelves_GalleryA_West",
	"SM_MetalShelves_GalleryB_North",
	"SM_ventilated_locker_GalleryC_West",
]
const LEGACY_SURFACE_COUNT := 12
const BRIDGE_RACK_NAME := "ModularRack_GalleryB_Initial"
const BRIDGE_LADDER_NAME := "FixedLadder_GalleryB_Initial"
const BRIDGE_LEVEL_NAMES: Array[String] = [
	"Shelf_01",
	"Shelf_02",
	"Shelf_03",
	"Shelf_04",
]
const BRIDGE_LEVEL_YS: Array[float] = [0.30, 1.1643043, 1.8968397, 2.6355634]
const BRIDGE_RACK_FRONT := 0
const PROXY_NAMES: Array[String] = [
	"GalleryA_West",
	"GalleryB_North",
	"GalleryC_West",
]
const ORDINARY_CEILING_UNDERSIDE_Y_M := 3.40
const RECEIVING_SHELL_PATH := "res://gameplay/logistics_wing/receiving/receiving_structural_shell.tscn"
# Accepted evidence is a test oracle only; production has no proof dependency.
const RECEIVING_COMPOSITION_PATH := "res://data/environment/receiving_proof/eaf5_receiving_proof_composition_v2.json"
const RECEIVING_MATERIALS := {
	"WALL_PRIMARY": "eaf3b_5a797fbdc766d7e3dc475abf",
	"FREIGHT_RECESS_WALL": "eaf3b_5a797fbdc766d7e3dc475abf",
	"OPENING_REVEAL": "eaf3b_5a797fbdc766d7e3dc475abf",
	"FLOOR_PRIMARY": "eaf3b_bb32071987faae156ff2d4e8",
	"CEILING_PRIMARY": "eaf3b_6bcd8f817ca2993433e217cc",
}
const RECEIVING_PRODUCTION_TARGETS := {
	"Floor_FreightEnclosure": [[5, 0.3, 7], [-2.5, -0.15, 0]],
	"Ceiling_FreightEnclosure": [[5, 0.3, 7], [-2.5, 4.35, 0]],
	"Floor_ReceivingApron": [[7.35, 0.3, 8], [3.675, -0.15, 0]],
	"Ceiling_ReceivingApron": [[7.5, 0.3, 8], [3.75, 4.35, 0]],
	"FreightNorth": [[4.7, 4.8, 0.3], [-2.5, 2.1, -3.5]],
	"FreightSouth": [[4.7, 4.8, 0.3], [-2.5, 2.1, 3.5]],
	"FreightRear": [[7.3, 4.8, 0.3], [-5, 2.1, 0]],
	"ReceivingWestNorthReturn": [[1.35, 4.8, 0.3], [0, 2.1, -3.175]],
	"ReceivingWestSouthReturn": [[1.35, 4.8, 0.3], [0, 2.1, 3.175]],
	"ReceivingNorthWest": [[1.15, 4.8, 0.3], [0.425, 2.1, -4]],
	"DispatchSouthWest": [[2.085714285714, 4.8, 0.3], [2.042857142857, 2.1, -4]],
	"DispatchSouthEast": [[1.864285714286, 4.8, 0.3], [6.417857142857, 2.1, -4]],
	"ReceivingSouth": [[7.5, 4.8, 0.3], [3.6, 2.1, 4]],
	"ReceivingEastOpeningWall": [[8.3, 4.8, 0.3], [7.5, 2.1, 0]],
}
const RECEIVING_UV_PHASES := {
	"Floor_ReceivingApron": Vector2(0, -4),
	"Ceiling_ReceivingApron": Vector2(0, -4),
	"ReceivingSouth": Vector2(-0.15, -0.3),
	"ReceivingNorthWest": Vector2(-0.15, -0.3),
	"ReceivingWestNorthReturn": Vector2(2.5, -0.3),
	"ReceivingWestSouthReturn": Vector2(-3.85, -0.3),
	"Floor_FreightEnclosure": Vector2(-5, -3.5),
	"Ceiling_FreightEnclosure": Vector2(-5, -3.5),
	"FreightNorth": Vector2(-4.85, -0.3),
	"FreightSouth": Vector2(-4.85, -0.3),
	"FreightRear": Vector2(-3.65, -0.3),
	"DispatchSouthWest": Vector2(1, -0.3),
	"DispatchSouthEast": Vector2(5.485714285714, -0.3),
	"ReceivingEastOpeningWall": Vector2(-4.15, -0.3),
}

var _failed: bool = false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check(ResourceLoader.exists(GAMEPLAY_PATH), "continuing gameplay scene exists"):
		_finish()
		return

	var packed := load(GAMEPLAY_PATH) as PackedScene
	if not _check(packed != null, "continuing gameplay scene loads"):
		_finish()
		return
	_assert_saved_proxy_overrides()
	_assert_saved_receiving_shell()

	var direct := packed.instantiate()
	root.add_child(direct)
	current_scene = direct
	await process_frame
	await physics_frame
	await _assert_composition(direct, "direct")
	root.remove_child(direct)
	direct.free()
	current_scene = null

	var host := Node3D.new()
	host.name = "IdentityHost"
	root.add_child(host)
	current_scene = host
	var parented := packed.instantiate()
	host.add_child(parented)
	await process_frame
	await physics_frame
	await _assert_composition(parented, "parent-hosted")
	host.free()
	current_scene = null
	await _assert_optional_development_setup(packed)
	await _assert_live_host_transform_round_trip(packed)
	await _assert_duplicate_setup_namespace_rejected(packed)
	await _assert_duplicate_fixture_namespace_rejected(packed)

	_finish()


func _assert_composition(scene: Node, context: String) -> void:
	var player := scene.get_node_or_null("Player") as CharacterBody3D
	var carried := scene.get_node_or_null("Player/CarriedItems")
	var hud := scene.get_node_or_null("HUD/CarriedItemsHUD")
	var environment := scene.get_node_or_null("Environment") as Node3D
	var development_setup := scene.get_node_or_null("DevelopmentSetup") as Node3D
	var receiving_runtime := scene.get_node_or_null("ReceivingRuntime") as Node3D

	_check(player != null, "%s composition has full gameplay player" % context)
	_check(carried != null, "%s composition has carried-items container" % context)
	_check(hud != null, "%s composition has carried-items HUD" % context)
	_check(environment != null, "%s composition has environment wrapper" % context)
	_check(development_setup != null, "%s composition includes authored development setup" % context)
	_check(receiving_runtime != null, "%s composition includes permanent Receiving runtime" % context)
	_check(
		scene.has_method("is_development_setup_active")
		and bool(scene.call("is_development_setup_active")),
		"%s composition reports its development setup active" % context
	)
	if player == null or carried == null or hud == null or environment == null:
		return

	_check(
		player.get_script() != null
		and player.get_script().resource_path == PLAYER_SCRIPT_PATH,
		"%s player reuses the shared controller" % context
	)
	_check(
		carried.get_script() != null
		and carried.get_script().resource_path == CARRIED_SCRIPT_PATH,
		"%s player reuses the shared carried-items script" % context
	)
	_check(
		hud.get_script() != null
		and hud.get_script().resource_path == HUD_SCRIPT_PATH,
		"%s HUD reuses the shared carried-items HUD" % context
	)
	_check(
		is_equal_approx(float(player.get("interaction_distance")), 1.4),
		"%s pickup reach preserves main override" % context
	)
	_check(
		is_equal_approx(float(player.get("storage_interaction_distance")), 2.3),
		"%s storage reach preserves main override" % context
	)
	_check(
		player.get("prototype_auto_register_known_loot") == false,
		"%s raw-loot registration is disabled locally" % context
	)
	_check(
		player.get("print_loot_registration") == false,
		"%s registration logging is disabled locally" % context
	)
	_check(
		player.get("enable_held_item_view") == true,
		"%s held-item view remains enabled" % context
	)
	_check(
		is_equal_approx(float(player.get("receiving_interaction_distance")), 3.4),
		"%s Receiving reach uses the smallest value measured across re-review cases" % context
	)
	_assert_receiving_runtime_contract(receiving_runtime, scene, context)

	var collision := player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	var camera := player.get_node_or_null("Camera3D") as Camera3D
	_check(collision != null, "%s player has collision shape" % context)
	_check(camera != null, "%s player has direct camera" % context)
	if collision != null:
		var capsule := collision.shape as CapsuleShape3D
		_check(capsule != null, "%s player keeps capsule shape" % context)
		if capsule != null:
			_check(is_equal_approx(capsule.radius, 0.34), "%s capsule radius is preserved" % context)
			_check(is_equal_approx(capsule.height, 1.75), "%s capsule height is preserved" % context)
		_check(is_equal_approx(collision.position.y, 0.875), "%s capsule center is preserved" % context)
	if camera != null:
		_check(
			camera.position.is_equal_approx(Vector3(-0.00447291, 1.7162851, -0.13648391)),
			"%s camera position preserves main offsets" % context
		)
		_check(is_equal_approx(camera.fov, 75.0), "%s camera FOV is preserved" % context)
		_check(camera.current, "%s camera is current" % context)

	_check(
		hud.get("carried_items_path") == NodePath("../../Player/CarriedItems"),
		"%s HUD has explicit carried-items path" % context
	)
	_check(
		hud.get("_carried_items") == carried,
		"%s HUD resolves the gameplay player's container before readiness" % context
	)
	_check(_count_current_cameras(scene) == 1, "%s composition has exactly one current camera" % context)
	_check(
		scene.find_children("*", "WorldEnvironment", true, false).size() == 1,
		"%s composition has exactly one world environment" % context
	)

	var greybox := environment.get_node_or_null("Greybox") as Node3D
	_check(greybox != null, "%s environment instances accepted geometry" % context)
	if greybox != null:
		_check(
			greybox.scene_file_path == GEOMETRY_PATH,
			"%s environment references accepted geometry path" % context
		)
	_check(
		scene.find_child("ReviewPlayer", true, false) == null,
		"%s composition omits neutral-review player" % context
	)
	_check(
		scene.get_node_or_null("ReceivingGeometryComparison") == null,
		"%s composition omits the experimental Receiving geometry comparison" % context
	)
	_check(
		not _instances_scene(scene, "res://main.tscn"),
		"%s composition does not embed historical main" % context
	)
	_check(
		not _instances_scene(scene, "res://greybox/logistics_wing/wing_review.tscn"),
		"%s composition does not embed neutral-review harness" % context
	)
	_assert_environment_proxy_contract(environment, context)
	_assert_receiving_shell(environment, context)
	_assert_receiving_circulation(scene, context)
	await _assert_fixture_contract(scene, context)
	if development_setup != null:
		var seed_items := development_setup.get_node("SeedItems")
		var seed_hosts := seed_items.get_children()
		_check(
			seed_hosts.size() >= 12,
			"%s composition preserves the editable seed fixture" % context
		)
		var live_instance_ids: Dictionary = {}
		for host_node: Node in seed_hosts:
			var world_item := host_node.get_node_or_null("WorldItem") as WorldItem
			_check(world_item != null, "%s live seed %s registers one WorldItem" % [context, host_node.name])
			if world_item == null or world_item.get_item_instance() == null:
				continue
			var expected_id := "wing_seed_v1:%s" % host_node.name
			_check(
				world_item.get_item_instance().instance_id == expected_id,
				"%s live seed %s keeps its name-derived identity" % [context, host_node.name]
			)
			live_instance_ids[world_item.get_item_instance().instance_id] = true
		_check(
			live_instance_ids.size() == seed_hosts.size(),
			"%s live edited seed fixture has distinct identities" % context
		)
		_assert_live_palette_coverage(development_setup, seed_hosts, context)
		await _assert_live_palette_handling(scene, context)


func _assert_receiving_runtime_contract(runtime: Node3D, scene: Node, context: String) -> void:
	if runtime == null:
		return
	_check(runtime.scene_file_path == RECEIVING_RUNTIME_PATH, "%s uses the Receiving runtime scene" % context)
	_check(runtime.get_script() != null and runtime.get_script().resource_path == RECEIVING_RUNTIME_SCRIPT_PATH, "%s runtime uses the intended script" % context)
	_check(runtime.position.is_equal_approx(Vector3(-37.41487, 0.82, 0.0)) and runtime.scale.is_equal_approx(Vector3(1.11, 1.225, 1)), "%s preserves human-authored platform/runtime datum" % context)
	_check((runtime.basis * Vector3.BACK).is_equal_approx(Vector3.RIGHT), "%s Receiving FRONT local +Z maps to world +X / player-barrier side" % context)
	var manager := runtime.get_node_or_null("ReceivingManager")
	var presenter := runtime.get_node_or_null("ReceivingDeckPresenter") as Node3D
	_check(manager != null, "%s runtime owns one ReceivingManager" % context)
	_check(presenter != null, "%s runtime owns one deck presenter" % context)
	if presenter == null:
		return
	_check(presenter.get_script() != null and presenter.get_script().resource_path == RECEIVING_PRESENTER_SCRIPT_PATH, "%s presenter uses deterministic deck script" % context)
	_check(presenter.get_child_count() >= 1, "%s presenter retains its neutral deck fixture" % context)
	_check(presenter.transform.is_equal_approx(Transform3D.IDENTITY), "%s presenter retains the profile coordinate system" % context)
	var deck_visual := presenter.get_node_or_null("DeckVisual") as Node3D
	_check(int(runtime.get("deck_profile").get("revision")) == 4, "%s new layouts use profile revision 4" % context)
	var support := _assert_receiving_platform(deck_visual, presenter, context)
	_check((presenter.call("get_materialized_world_items") as Array).is_empty(), "%s normal launch creates no synthetic Receiving batch" % context)
	var functional_surfaces := scene.call("get_functional_surfaces") as Array
	var private_surfaces := presenter.call("get_private_storage_surfaces") as Array
	_check(private_surfaces.size() == 1, "%s proof presenter owns one private functional grid" % context)
	for surface: Node in private_surfaces:
		_check(not functional_surfaces.has(surface), "%s private deck surface is excluded from functional storage" % context)
		var storage_surface := surface as StorageSurface
		_check(storage_surface.get_grid_size() == Vector2i(33, 20), "%s private grid is exactly 33 × 20 despite runtime scale" % context)
		_check(storage_surface.get_usable_size_m().is_equal_approx(Vector2(3.3, 2.0)), "%s functional usable area remains exactly 3.30 m × 2.00 m" % context)
		_check(storage_surface.global_position.is_equal_approx(presenter.global_position) and storage_surface.global_basis.is_equal_approx(presenter.global_basis.orthonormalized()), "%s logical MainDeck retains profile origin/orientation with scale-isolated metric coordinates" % context)
		_check(is_equal_approx(storage_surface.cell_size_m, 0.10), "%s live cells remain literal 0.10 m" % context)
		var half_size := storage_surface.get_usable_size_m() * 0.5
		for border: float in [-half_size.x - support.position.x, support.end.x - half_size.x, -half_size.y - support.position.z, support.end.z - half_size.y]:
			_check(border >= 0.05 - 0.00001, "%s every edge retains 0.05 m within mesh precision" % context)
		var margin := (Vector2(support.size.x, support.size.z) - storage_surface.get_usable_size_m()) * 0.5
		_check(margin.is_equal_approx(Vector2(0.0705, 0.05)), "%s support border is centered and non-reservable at 0.0705 m sides / 0.05 m front and rear" % context)
	for forbidden_name: String in ["ReceivingGeometryComparison", "ReceivingPhysicsPileProof", "ReceivingComparisonA", "ReceivingComparisonB", "ReceivingComparisonC"]:
		_check(scene.find_child(forbidden_name, true, false) == null, "%s omits historical %s" % [context, forbidden_name])


func _assert_receiving_platform(visual: Node3D, presenter: Node3D, context: String) -> AABB:
	if not _check(visual != null and not visual is MeshInstance3D, "%s DeckVisual is a stable physical datum wrapper" % context):
		return AABB()
	_check(visual.transform.is_equal_approx(Transform3D.IDENTITY), "%s physical datum stays at the presenter origin" % context)
	var vertices: Array[Vector3] = []
	var imported_count := 0
	for node: Node in visual.find_children("*", "", true, false):
		_check(not node is CollisionObject3D and not node is CollisionShape3D and not node is CollisionPolygon3D, "%s platform adds no gameplay/query collision" % context)
		if node.scene_file_path == "res://assets/environment/architecture/floors/SM_Platform_01.glb":
			imported_count += 1
			var relative := Transform3D(presenter.global_basis.orthonormalized(), presenter.global_position).affine_inverse() * (node as Node3D).global_transform
			# Source inspection establishes that its two yellow strips follow source X.
			_check(relative.basis.x.normalized().is_equal_approx(Vector3.RIGHT), "%s yellow strips run across width, parallel to the barrier" % context)
		if node is MeshInstance3D:
			var mesh_node := node as MeshInstance3D
			_check(not mesh_node.mesh is BoxMesh, "%s placeholder BoxMesh is removed" % context)
			var relative := Transform3D(presenter.global_basis.orthonormalized(), presenter.global_position).affine_inverse() * mesh_node.global_transform
			_check(relative.basis.x.normalized().is_equal_approx(Vector3.RIGHT) and relative.basis.y.normalized().is_equal_approx(Vector3.UP) and relative.basis.z.normalized().is_equal_approx(Vector3.BACK), "%s top stays axis-aligned" % context)
			for surface_index: int in range(mesh_node.mesh.get_surface_count()):
				for vertex: Vector3 in mesh_node.mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_VERTEX]:
					vertices.append(relative * vertex)
	_check(imported_count == 1, "%s normal wing uses one real SM_Platform_01 instance" % context)
	if not _check(not vertices.is_empty(), "%s platform has measurable support geometry" % context):
		return AABB()
	var top_y := -INF
	for vertex: Vector3 in vertices:
		top_y = maxf(top_y, vertex.y)
	_check(absf(top_y) < 0.0001, "%s physical support top plane stays at local Y 0" % context)
	var support := AABB()
	var initialized := false
	for vertex: Vector3 in vertices:
		if absf(vertex.y - top_y) > 0.0001:
			continue
		if not initialized:
			support = AABB(vertex, Vector3.ZERO)
			initialized = true
		else:
			support = support.expand(vertex)
	# Independent top-vertex dimensions from human checkpoint c76442f.
	_check(support.position.distance_to(Vector3(-1.7205, 0, -1.05)) < 0.0001 and support.size.distance_to(Vector3(3.441, 0, 2.10)) < 0.0001, "%s measured top support is centered and 3.441 m × 2.100 m, following human widened checkpoint c76442f" % context)
	return support

func _assert_live_palette_coverage(
	development_setup: Node3D,
	seed_hosts: Array[Node],
	context: String
) -> void:
	var catalogue := load(CATALOGUE_PATH)
	_check(catalogue != null, "%s live palette loads the persistent catalogue" % context)
	if catalogue == null:
		return

	var eligible_ids: Dictionary = {}
	for value: Variant in catalogue.get("definitions") as Array:
		var definition := value as ItemDefinition
		_check(definition != null, "%s catalogue entry is an ItemDefinition" % context)
		if definition != null and not BLOCKED_ITEM_IDS.has(definition.item_id):
			eligible_ids[definition.item_id] = true

	var covered_ids: Dictionary = {}
	var host_names: Dictionary = {}
	for host_node: Node in seed_hosts:
		var host := host_node as Node3D
		_check(host != null, "%s live palette host is Node3D" % context)
		if host == null:
			continue
		var host_name := StringName(host.name)
		_check(not host_names.has(host_name), "%s live palette host name is unique: %s" % [context, host_name])
		host_names[host_name] = true
		var item_id := StringName(host.get("item_id"))
		_check(not BLOCKED_ITEM_IDS.has(item_id), "%s live palette excludes blocked item %s" % [context, item_id])
		var definition := catalogue.call("get_definition_by_id", item_id) as ItemDefinition
		_check(definition != null, "%s live palette host resolves %s" % [context, host_name])
		var visual := host.call("get_authored_visual") as Node3D
		_check(
			int(host.call("get_authored_visual_count")) == 1 and visual != null,
			"%s live palette host has exactly one imported visual: %s" % [context, host_name]
		)
		if definition != null and visual != null:
			_check(
				visual.scene_file_path == definition.visual_scene.resource_path,
				"%s live palette visual matches %s" % [context, host_name]
			)
			covered_ids[item_id] = true

	for eligible_id: StringName in eligible_ids:
		_check(covered_ids.has(eligible_id), "%s live palette covers eligible item %s" % [context, eligible_id])
	_check(
		covered_ids.size() == eligible_ids.size(),
		"%s live palette covers every eligible catalogue type without a fixed host quota" % context
	)
	var tables := development_setup.get_node_or_null("Tables")
	_check(tables != null, "%s live palette retains its table root" % context)
	if tables != null:
		_check(
			tables.find_children("*", "StorageSurface", true, false).is_empty(),
			"%s live palette tables remain TAKE-only furniture" % context
		)


func _assert_live_palette_handling(scene: Node, context: String) -> void:
	var player := scene.get_node_or_null("Player")
	var carried := scene.get_node_or_null("Player/CarriedItems")
	var controller := scene.get_node_or_null("Player/StoragePlacementController") as StoragePlacementController
	var surfaces := scene.call("get_functional_surfaces") as Array
	_check(player != null, "%s palette handling has the normal player" % context)
	_check(carried != null, "%s palette handling has carried items" % context)
	_check(controller != null, "%s palette handling has the normal controller" % context)
	_check(surfaces.size() >= 2, "%s palette handling has real storage surfaces" % context)
	if player == null or carried == null or controller == null or surfaces.size() < 2:
		return
	await _exercise_live_palette_item(scene, carried, controller, surfaces[0] as StorageSurface, &"loot_000015", "Fuel", context)
	await _exercise_live_palette_item(scene, carried, controller, surfaces[1] as StorageSurface, &"loot_000002", "larger electronics", context)


func _assert_live_host_transform_round_trip(packed: PackedScene) -> void:
	var editable_scene := packed.instantiate()
	var host := editable_scene.get_node_or_null("DevelopmentSetup/SeedItems/Fuel_Canister") as Node3D
	_check(host != null, "live palette exposes Fuel_Canister as an editor-movable host")
	if host == null:
		editable_scene.free()
		return
	var moved := host.transform.translated_local(Vector3(0.06, 0.01, -0.05))
	moved = moved.rotated_local(Vector3.UP, deg_to_rad(7.0))
	host.transform = moved
	var temporary := PackedScene.new()
	_check(temporary.pack(editable_scene) == OK, "moved live palette host packs for editor save")
	_check(
		ResourceSaver.save(temporary, LIVE_PALETTE_ROUND_TRIP_PATH) == OK,
		"moved live palette host saves"
	)
	editable_scene.free()
	var reloaded_packed := ResourceLoader.load(
		LIVE_PALETTE_ROUND_TRIP_PATH,
		"PackedScene",
		ResourceLoader.CACHE_MODE_IGNORE
	) as PackedScene
	_check(reloaded_packed != null, "saved live palette host reloads")
	if reloaded_packed != null:
		var reloaded_scene := reloaded_packed.instantiate()
		var reloaded_host := reloaded_scene.get_node_or_null(
			"DevelopmentSetup/SeedItems/Fuel_Canister"
		) as Node3D
		_check(
			reloaded_host != null and reloaded_host.transform.is_equal_approx(moved),
			"saved Fuel_Canister move survives reload"
		)
		reloaded_scene.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(LIVE_PALETTE_ROUND_TRIP_PATH))


func _exercise_live_palette_item(
	scene: Node,
	carried: Node,
	controller: StoragePlacementController,
	surface: StorageSurface,
	item_id: StringName,
	label: String,
	context: String
) -> void:
	var host := _find_live_host(scene, item_id)
	_check(host != null, "%s palette handling finds %s host" % [context, label])
	if host == null or surface == null:
		return
	var world_item := host.get_node_or_null("WorldItem") as WorldItem
	var item := world_item.get_item_instance() as ItemInstance if world_item != null else null
	_check(world_item != null and item != null, "%s palette handling owns %s" % [context, label])
	if world_item == null or item == null:
		return
	_check(world_item.pickup_into(carried), "%s palette handling picks up %s" % [context, label])
	_check(carried.get_selected_item() == item, "%s pickup preserves %s identity" % [context, label])
	surface.set_zone_rect(item.get_storage_category(), Vector2i.ZERO, surface.get_grid_size() - Vector2i.ONE)
	var orientations := controller.call("_entry_orientations_for_item", item) as Array
	var fit := surface.find_zone_stack_or_empty_fit(
		item.get_storage_category(),
		orientations[0],
		orientations[1] if orientations.size() > 1 else null
	)
	controller.set("_current_surface", surface)
	controller.set("_current_fit", fit)
	controller.set("_manual_mode", false)
	_check(controller.place_selected(), "%s palette handling stores %s through the normal controller" % [context, label])
	var stack := surface.get_storage_stack(surface.get_stack_id_for_item(item.instance_id))
	_check(stack != null and not stack.entries.is_empty(), "%s palette handling stores %s once" % [context, label])
	if stack == null or stack.entries.is_empty():
		return
	var stored_world := stack.entries[0].world_item as WorldItem
	_check(stored_world.pickup_into(carried), "%s palette handling retrieves %s" % [context, label])
	_check(carried.get_selected_item() == item, "%s retrieval preserves %s identity" % [context, label])
	carried.call("remove_item", item)
	await process_frame


func _find_live_host(scene: Node, item_id: StringName) -> Node3D:
	var seed_items := scene.get_node_or_null("DevelopmentSetup/SeedItems")
	if seed_items == null:
		return null
	for child: Node in seed_items.get_children():
		if StringName(child.get("item_id")) == item_id and not child.is_queued_for_deletion():
			return child as Node3D
	return null


func _assert_optional_development_setup(packed: PackedScene) -> void:
	var disabled := packed.instantiate()
	disabled.set("development_setup_enabled", false)
	root.add_child(disabled)
	current_scene = disabled
	await process_frame
	_check(
		disabled.get_node_or_null("DevelopmentSetup") == null,
		"disabled-before-tree composition creates no tables or seed hosts"
	)
	_check(
		disabled.has_method("is_development_setup_active")
		and not bool(disabled.call("is_development_setup_active")),
		"disabled-before-tree composition reports setup inactive"
	)
	_assert_permanent_gameplay_survives_without_setup(disabled, "disabled")
	disabled.free()
	current_scene = null

	var omitted := packed.instantiate()
	var setup := omitted.get_node_or_null("DevelopmentSetup")
	if setup != null:
		omitted.remove_child(setup)
		setup.free()
	root.add_child(omitted)
	current_scene = omitted
	await process_frame
	_check(
		omitted.has_method("is_development_setup_active")
		and not bool(omitted.call("is_development_setup_active")),
		"composition reports physically omitted setup inactive"
	)
	_assert_permanent_gameplay_survives_without_setup(omitted, "omitted")
	omitted.free()
	current_scene = null


func _assert_duplicate_fixture_namespace_rejected(packed: PackedScene) -> void:
	var host := Node3D.new()
	host.name = "DuplicateNamespaceHost"
	root.add_child(host)
	current_scene = host

	var first := packed.instantiate()
	first.name = "WingGameplayPrimary"
	host.add_child(first)
	await process_frame
	await physics_frame
	var primary_seed_count := first.get_node("DevelopmentSetup/SeedItems").get_child_count()

	var second := packed.instantiate()
	second.name = "WingGameplayDuplicate"
	host.add_child(second)
	await process_frame
	await physics_frame

	_check(
		first.has_method("is_development_setup_active")
		and bool(first.call("is_development_setup_active")),
		"first fixture namespace owner remains active"
	)
	var second_registrar := second.get_node_or_null("DevelopmentSetup/SeedRegistrar")
	_check(second_registrar != null, "second composition retains inspectable rejected registrar")
	if second_registrar != null:
		var failures := second_registrar.call("get_validation_failures") as Array
		_check(
			"\n".join(failures).contains("duplicate seed identity namespace"),
			"second active fixture namespace exposes a named registrar failure"
		)
		_check(
			(second_registrar.call("get_registered_instance_ids") as Array).is_empty(),
			"second active fixture namespace registers no identities"
		)
	var world_items := host.find_children("WorldItem", "WorldItem", true, false)
	_check(
		world_items.size() == primary_seed_count,
		"duplicate fixture rejection leaves exactly one live seed set"
	)
	var instance_ids: Dictionary = {}
	for value: Node in world_items:
		var world_item := value as WorldItem
		if world_item != null and world_item.get_item_instance() != null:
			instance_ids[world_item.get_item_instance().instance_id] = true
	_check(
		instance_ids.size() == primary_seed_count,
		"duplicate fixture rejection leaves one distinct identity per live seed"
	)

	host.free()
	current_scene = null


func _assert_duplicate_setup_namespace_rejected(gameplay_packed: PackedScene) -> void:
	var setup_packed := load(DEVELOPMENT_SETUP_PATH) as PackedScene
	if not _check(setup_packed != null, "development setup loads for duplicate namespace test"):
		return
	var gameplay := gameplay_packed.instantiate()
	root.add_child(gameplay)
	current_scene = gameplay
	await process_frame
	await physics_frame
	var live_seed_count := gameplay.get_node("DevelopmentSetup/SeedItems").get_child_count()

	var duplicate_setup := setup_packed.instantiate()
	duplicate_setup.name = "DevelopmentSetupCopy"
	gameplay.add_child(duplicate_setup)
	await process_frame
	await physics_frame

	var registrar := duplicate_setup.get_node("SeedRegistrar")
	var failures := registrar.call("get_validation_failures") as Array
	_check(
		"\n".join(failures).contains("duplicate seed identity namespace"),
		"duplicated setup inside one composition reports the active namespace conflict"
	)
	_check(
		duplicate_setup.find_children("WorldItem", "WorldItem", true, false).is_empty(),
		"duplicated setup creates no partial runtime ownership"
	)
	var all_world_items := gameplay.find_children("WorldItem", "WorldItem", true, false)
	_check(
		all_world_items.size() == live_seed_count,
		"duplicated setup leaves exactly one live edited seed owner set"
	)

	gameplay.free()
	current_scene = null


func _assert_permanent_gameplay_survives_without_setup(scene: Node, context: String) -> void:
	_check(scene.get_node_or_null("Environment") != null, "%s setup keeps environment" % context)
	_check(scene.get_node_or_null("Player") != null, "%s setup keeps player" % context)
	_check(scene.get_node_or_null("HUD/CarriedItemsHUD") != null, "%s setup keeps HUD" % context)
	var fixtures := scene.get_node_or_null("FunctionalFixtures")
	_check(fixtures != null, "%s setup keeps fixtures" % context)
	if fixtures != null and fixtures.has_method("get_installed_surfaces"):
		var surfaces := fixtures.call("get_installed_surfaces") as Array
		var rack := fixtures.get_node_or_null(BRIDGE_RACK_NAME) as ModularRack
		var authored_levels := rack.get_layout_contract().get("levels", []) as Array if rack != null else []
		_check(rack != null, "%s setup keeps the intended ModularRack" % context)
		_check(
			surfaces.size() == LEGACY_SURFACE_COUNT + authored_levels.size(),
			"%s setup keeps legacy plus authored ModularRack surfaces" % context
		)
		for value: Variant in surfaces:
			var surface := value as StorageSurface
			_check(surface != null and surface.get_stack_count() == 0, "%s surfaces remain empty" % context)


func _assert_saved_proxy_overrides() -> void:
	var packed := load(ENVIRONMENT_PATH) as PackedScene
	if not _check(packed != null, "environment wrapper loads for saved-state inspection"):
		return
	var environment := packed.instantiate()
	for proxy_name: String in PROXY_NAMES:
		var mesh := environment.get_node_or_null(
			"Greybox/Proxies/%s/Mesh" % proxy_name
		) as MeshInstance3D
		var shape := environment.get_node_or_null(
			"Greybox/Proxies/%s/StaticBody3D/CollisionShape3D" % proxy_name
		) as CollisionShape3D
		_check(mesh != null and not mesh.visible, "%s proxy mesh is suppressed in saved gameplay data" % proxy_name)
		_check(shape != null and shape.disabled, "%s proxy collider is suppressed in saved gameplay data" % proxy_name)
	environment.free()


func _assert_environment_proxy_contract(environment: Node3D, context: String) -> void:
	_check(
		environment.has_method("get_proxy_suppression_failures")
		and (environment.call("get_proxy_suppression_failures") as Array).is_empty(),
		"%s environment reports no proxy-suppression failures" % context
	)
	for proxy_name: String in PROXY_NAMES:
		var mesh := environment.get_node_or_null(
			"Greybox/Proxies/%s/Mesh" % proxy_name
		) as MeshInstance3D
		var shape := environment.get_node_or_null(
			"Greybox/Proxies/%s/StaticBody3D/CollisionShape3D" % proxy_name
		) as CollisionShape3D
		_check(mesh != null and not mesh.visible, "%s %s proxy mesh is hidden" % [context, proxy_name])
		_check(shape != null and shape.disabled, "%s %s proxy collider is disabled" % [context, proxy_name])

	var neutral := (load(GEOMETRY_PATH) as PackedScene).instantiate()
	for proxy_name: String in PROXY_NAMES:
		var neutral_mesh := neutral.get_node_or_null(
			"Proxies/%s/Mesh" % proxy_name
		) as MeshInstance3D
		var neutral_shape := neutral.get_node_or_null(
			"Proxies/%s/StaticBody3D/CollisionShape3D" % proxy_name
		) as CollisionShape3D
		_check(neutral_mesh != null and neutral_mesh.visible, "%s neutral %s proxy mesh remains visible" % [context, proxy_name])
		_check(neutral_shape != null and not neutral_shape.disabled, "%s neutral %s proxy collider remains enabled" % [context, proxy_name])
	neutral.free()


func _assert_fixture_contract(scene: Node, context: String) -> void:
	var fixtures := scene.get_node_or_null("FunctionalFixtures") as Node3D
	if not _check(fixtures != null, "%s composition has fixture root" % context):
		return
	if not _check(
		fixtures.has_method("get_installed_surfaces"),
		"%s fixture root exposes installed surfaces" % context
	):
		return

	var expected_positions := {
		"SM_MetalShelves_GalleryA_West": Vector3(-2.28, 0.0, -3.816217),
		"SM_MetalShelves_GalleryB_North": Vector3(14.00, 0.0, -13.78),
		"SM_ventilated_locker_GalleryC_West": Vector3(-1.35, 0.0, 9.00),
	}
	for fixture_name: String in FIXTURE_NAMES:
		var fixture := fixtures.get_node_or_null(fixture_name) as Node3D
		_check(fixture != null, "%s has fixture %s" % [context, fixture_name])
		if fixture == null:
			continue
		_check(fixture.scale.is_equal_approx(Vector3.ONE), "%s %s uses identity scale" % [context, fixture_name])
		_check(fixture.position.is_equal_approx(expected_positions[fixture_name]), "%s %s uses approved position" % [context, fixture_name])
		var expected_yaw := deg_to_rad(90.0) if fixture_name == "SM_MetalShelves_GalleryB_North" else 0.0
		_check(is_equal_approx(fixture.rotation.y, expected_yaw), "%s %s uses approved yaw" % [context, fixture_name])
		var clearance_context := fixture.get_node_or_null("StorageShelfClearanceContext")
		_check(clearance_context != null, "%s %s has explicit clearance context" % [context, fixture_name])

	var surfaces := fixtures.call("get_installed_surfaces") as Array
	var bridge_rack := fixtures.get_node_or_null(BRIDGE_RACK_NAME) as ModularRack
	_check(bridge_rack != null, "%s has the intended Gallery B ModularRack" % context)
	if bridge_rack == null:
		return
	_check(bridge_rack.get_parent() == fixtures, "%s ModularRack is a direct FunctionalFixtures child" % context)
	_check(bridge_rack.scale.is_equal_approx(Vector3.ONE), "%s ModularRack keeps unit root scale" % context)
	_check(
		bridge_rack.get_storage_orientation_quarter_turns() == BRIDGE_RACK_FRONT,
		"%s ModularRack saves its authored semantic Front" % context
	)
	var levels := bridge_rack.get_node_or_null("Levels") as Node3D
	_check(levels != null, "%s ModularRack keeps its editable local Levels node" % context)
	if levels == null:
		return
	_check(levels.get_child_count() == BRIDGE_LEVEL_NAMES.size(), "%s ModularRack saves four local level wrappers" % context)
	for index: int in range(BRIDGE_LEVEL_NAMES.size()):
		var level := levels.get_node_or_null(BRIDGE_LEVEL_NAMES[index]) as Node3D
		_check(level != null, "%s ModularRack saves %s" % [context, BRIDGE_LEVEL_NAMES[index]])
		if level != null:
			_check(is_equal_approx(level.position.y, BRIDGE_LEVEL_YS[index]), "%s %s keeps its authored support height" % [context, BRIDGE_LEVEL_NAMES[index]])
			_check(level.get_node_or_null("Visual") != null, "%s %s keeps its Rack02 visual wrapper" % [context, BRIDGE_LEVEL_NAMES[index]])
	var layout := bridge_rack.get_layout_contract()
	_check(bool(layout.get("valid", false)), "%s ModularRack layout is valid" % context)
	var authored_levels := layout.get("levels", []) as Array
	_check(authored_levels.size() == BRIDGE_LEVEL_NAMES.size(), "%s ModularRack layout includes every saved level" % context)
	var expected_surface_count := LEGACY_SURFACE_COUNT + authored_levels.size()
	_check(surfaces.size() == expected_surface_count, "%s installs legacy plus authored ModularRack surfaces" % context)

	var bridge_ladder := fixtures.get_node_or_null(BRIDGE_LADDER_NAME) as FixedLadder
	_check(bridge_ladder != null, "%s has the intended Gallery B FixedLadder" % context)
	if bridge_ladder != null:
		_check(bridge_ladder.get_parent() == fixtures, "%s FixedLadder is a direct FunctionalFixtures child" % context)
		_check(not bridge_rack.is_ancestor_of(bridge_ladder), "%s FixedLadder is independent from the ModularRack" % context)
		_check(bridge_ladder.scale.is_equal_approx(Vector3.ONE), "%s FixedLadder keeps unit root scale" % context)
		_check(bridge_ladder.is_authoring_valid(), "%s FixedLadder retains valid promoted authoring" % context)
	var surface_ids: Dictionary = {}
	var top_surfaces: Dictionary = {}
	var bridge_surfaces: Array[StorageSurface] = []
	for value: Variant in surfaces:
		var surface := value as StorageSurface
		if not _check(surface != null, "%s surface census contains StorageSurface" % context):
			continue
		var surface_key := String(surface.surface_id)
		_check(not surface_ids.has(surface_key), "%s surface ID is unique: %s" % [context, surface_key])
		surface_ids[surface_key] = true
		_check(surface.get_reservation_count() == 0, "%s %s starts without reservations" % [context, surface_key])
		_check(surface.get_stack_count() == 0, "%s %s starts without stacks" % [context, surface_key])
		_check(is_zero_approx(surface.get_occupancy_ratio()), "%s %s starts empty" % [context, surface_key])
		_check(not surface.are_zones_initialized(), "%s %s starts unzoned" % [context, surface_key])
		if bridge_rack.is_ancestor_of(surface):
			bridge_surfaces.append(surface)
			_check(
				surface.get_semantic_orientation_quarter_turns() == BRIDGE_RACK_FRONT,
				"%s ModularRack surface inherits its semantic Front" % context
			)
		if String(surface.name) == "StorageSurface_04":
			top_surfaces[String(surface.get_parent().name)] = surface

	_check(surface_ids.size() == expected_surface_count, "%s has distinct legacy and ModularRack surface IDs" % context)
	_check(bridge_surfaces.size() == authored_levels.size(), "%s builds one ModularRack surface per valid authored level" % context)
	_check(top_surfaces.size() == 3, "%s exposes three top surfaces" % context)
	for fixture_name: String in FIXTURE_NAMES:
		var top := top_surfaces.get(fixture_name) as StorageSurface
		if top == null:
			continue
		var physical_ceiling_clearance := ORDINARY_CEILING_UNDERSIDE_Y_M - top.global_position.y
		_check(top.stack_clearance_m > 0.01, "%s %s top clearance is positive" % [context, fixture_name])
		_check(
			top.stack_clearance_m <= physical_ceiling_clearance - 0.019,
			"%s %s top cap stays below ceiling with construction margin" % [context, fixture_name]
		)
		if fixture_name.begins_with("SM_ventilated_locker"):
			_check(
				top.stack_clearance_m <= 0.519001,
				"%s locker top cap respects its lower cabinet obstruction" % context
			)

	_check(
		fixtures.call("get_missing_top_clearance_contexts") == [],
		"%s fixtures have no missing clearance contexts" % context
	)
	_check(
		fixtures.call("is_storage_debug_input_enabled") == true,
		"%s non-destructive F6 grid input is enabled" % context
	)
	_check(
		fixtures.has_method("is_storage_occupancy_demo_enabled")
		and fixtures.call("is_storage_occupancy_demo_enabled") == false,
		"%s destructive F7 occupancy demo remains disabled" % context
	)

	var all_surfaces := scene.find_children("*", "StorageSurface", true, false)
	_check(all_surfaces.size() == expected_surface_count + 1, "%s adds exactly one private Receiving backend beyond functional storage" % context)
	var nonfunctional_surfaces := all_surfaces.filter(func(surface: Node) -> bool: return not surfaces.has(surface))
	_check(nonfunctional_surfaces.size() == 1 and not (nonfunctional_surfaces[0] as StorageSurface).is_player_storage_interaction_enabled(), "%s sole nonfunctional surface is the TAKE-only Receiving deck" % context)
	for index: int in range(LEGACY_SURFACE_COUNT):
		var legacy_surface := surfaces[index] as StorageSurface
		_check(not bridge_rack.is_ancestor_of(legacy_surface), "%s preserves legacy surface ordering before appended ModularRack surfaces" % context)
	var occupancy_before: Array[float] = []
	for surface: StorageSurface in surfaces:
		occupancy_before.append(surface.get_occupancy_ratio())
		_check(not surface.is_debug_visible(), "%s %s starts with its grid hidden" % [context, surface.surface_id])
	var key_down := InputEventKey.new()
	key_down.keycode = KEY_F7
	key_down.pressed = true
	Input.parse_input_event(key_down)
	await process_frame
	var key_up := InputEventKey.new()
	key_up.keycode = KEY_F7
	key_up.pressed = false
	Input.parse_input_event(key_up)
	for index: int in range(surfaces.size()):
		var surface := surfaces[index] as StorageSurface
		_check(
			is_equal_approx(surface.get_occupancy_ratio(), occupancy_before[index]),
			"%s F7 does not change %s occupancy" % [context, surface.surface_id]
		)
		_check(not surface.are_zones_initialized(), "%s F7 does not zone %s" % [context, surface.surface_id])


func _count_current_cameras(root_node: Node) -> int:
	var count := 0
	for value: Node in root_node.find_children("*", "Camera3D", true, false):
		var camera := value as Camera3D
		if camera != null and camera.current:
			count += 1
	return count


func _instances_scene(root_node: Node, scene_path: String) -> bool:
	if root_node.scene_file_path == scene_path:
		return true
	for child: Node in root_node.find_children("*", "Node", true, false):
		if child.scene_file_path == scene_path:
			return true
	return false


func _finish() -> void:
	if _failed:
		push_error("FAIL: wing gameplay composition tests")
		quit(1)
		return
	print("PASS: wing gameplay composition tests")
	quit(0)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false


func _assert_saved_receiving_shell() -> void:
	_check(ResourceLoader.exists(RECEIVING_SHELL_PATH), "production Receiving shell exists")
	var environment := (load(ENVIRONMENT_PATH) as PackedScene).instantiate()
	_assert_receiving_shell(environment, "saved/off-tree")
	environment.free()


func _assert_receiving_shell(environment: Node3D, context: String) -> void:
	var shell := environment.get_node_or_null("ReceivingStructuralShell") as Node3D
	if not _check(shell != null, "%s has production-owned Receiving shell" % context):
		return
	_check(shell.scene_file_path == RECEIVING_SHELL_PATH, "%s instances the production shell" % context)
	_check(shell.position.is_equal_approx(Vector3(-36, 0, 0)) and shell.basis.is_equal_approx(Basis.IDENTITY), "%s shell uses accepted origin and unit root" % context)
	var composition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RECEIVING_COMPOSITION_PATH))
	var pieces: Array = composition["eaf2_recipe_mapping"].duplicate(true)
	for row: Dictionary in pieces:
		var target: Array = RECEIVING_PRODUCTION_TARGETS[row["piece_id"]]
		row["dimensions_m"] = target[0]
		row["center_local_m"] = target[1]
		if row["piece_id"] == "ReceivingEastOpeningWall":
			row["opening_parameters"]["opening_width_m"] = 2.84
	_check(shell.get_child_count() == 14 and pieces.size() == 14, "%s exactly 14 intended EAF2 pieces" % context)
	_check(shell.find_children("*", "CollisionObject3D", true, false).is_empty() and shell.find_children("*", "CollisionShape3D", true, false).is_empty(), "%s shell has no duplicate structural collision" % context)
	var suppressed: Array[String] = []
	for row: Dictionary in pieces:
		var id := String(row["piece_id"])
		var piece := shell.get_node_or_null(NodePath(id)) as EnvironmentSubstratePiece
		if not _check(piece != null, "%s owns intended piece %s" % [context, id]):
			continue
		var spec := piece.piece_spec
		if not _check(spec != null and piece.validate_authoring().is_empty(), "%s %s valid EAF2 authoring" % [context, id]):
			continue
		var role := String(row["semantic_role"]).to_upper() + "_PRIMARY"
		if id in ["FreightNorth", "FreightRear", "FreightSouth"]:
			role = "FREIGHT_RECESS_WALL"
		elif id in ["ReceivingWestNorthReturn", "ReceivingWestSouthReturn"]:
			role = "OPENING_REVEAL"
		elif role == "EAST_BACKLOG_TRANSITION_WALL_PRIMARY":
			role = "WALL_PRIMARY"
		_check(spec.piece_id == id and spec.semantic_role == role and spec.recipe_id == row["recipe_id"], "%s %s accepted ID/role/recipe" % [context, id])
		_check(spec.dimensions_m.is_equal_approx(_receiving_vec3(row["dimensions_m"])) and piece.position.is_equal_approx(_receiving_vec3(row["center_local_m"])) and is_equal_approx(piece.rotation_degrees.y, float(row["rotation_y_degrees"])), "%s %s accepted dimensions/transform" % [context, id])
		_check(spec.concealed_faces == PackedStringArray(row.get("concealed_faces", [])) and spec.bevel_width_m == 0, "%s %s accepted concealed faces and joins" % [context, id])
		_check(spec.collision_policy == EnvironmentSubstratePieceSpec.CollisionPolicy.NONE and piece.scale.is_equal_approx(Vector3.ONE), "%s %s visual only, unit root" % [context, id])
		_check(spec.uv_quarter_turns == 0 and spec.uv_origin_m.is_equal_approx(RECEIVING_UV_PHASES[id]), "%s %s accepted UV phase" % [context, id])
		var approved_path := "res://data/environment/material_catalog/approved_specs/%s.tres" % RECEIVING_MATERIALS[role]
		_check(spec.material_spec == load(approved_path) and spec.material_spec.material_id == RECEIVING_MATERIALS[role], "%s %s references promoted PRIMARY spec" % [context, id])
		_check(spec.material_spec.mapping_mode == EnvironmentSurfaceMaterialSpec.MappingMode.UV and is_equal_approx(spec.material_spec.meters_per_repeat, 1.5), "%s %s UV at 1.5 metres per repeat" % [context, id])
		if row["opening_parameters"] != null:
			for parameter: String in row["opening_parameters"]:
				_check(is_equal_approx(float(spec.get(parameter)), float(row["opening_parameters"][parameter])), "%s %s accepted %s" % [context, id, parameter])
		var generated := piece.get_node_or_null("GeneratedMesh") as MeshInstance3D
		if _check(generated != null and generated.mesh != null, "%s %s persists generated mesh" % [context, id]):
			_check(_receiving_winding_matches_front_faces(generated.mesh), "%s %s outward surface survives Godot back-face culling" % [context, id])
			var rebuilt := EnvironmentSubstrateBuilder.new().build(spec)
			_check(generated.mesh.surface_get_arrays(0) == (rebuilt["mesh"] as ArrayMesh).surface_get_arrays(0), "%s %s saved vertices/normals/tangents/UV match EAF2 owner" % [context, id])
			_check(piece.get_meta("eaf2_generation", {}).get("generator_revision", 0) == EnvironmentSubstrateBuilder.GENERATOR_REVISION and piece.get_meta("eaf2_generation", {}).get("geometry_fingerprint", "") == rebuilt["fingerprint"], "%s %s current saved fingerprint" % [context, id])
			var material := generated.material_override as StandardMaterial3D
			_check(material != null and material.resource_name == RECEIVING_MATERIALS[role] and material.cull_mode == BaseMaterial3D.CULL_BACK and not material.uv1_triplanar and material.uv1_scale.is_equal_approx(Vector3.ONE / 1.5) and material.albedo_texture == spec.material_spec.base_color_texture and material.normal_texture == spec.material_spec.normal_texture and material.normal_enabled and is_equal_approx(material.normal_scale, spec.material_spec.normal_strength) and material.metallic_texture == spec.material_spec.metallic_texture and is_equal_approx(material.metallic, spec.material_spec.metallic_multiplier if spec.material_spec.metallic_texture != null else 0.0) and is_equal_approx(material.roughness, spec.material_spec.roughness_multiplier) and material.roughness_texture == spec.material_spec.roughness_texture and material.ao_texture == spec.material_spec.ao_texture, "%s %s saved P05_C02 PBR material and physical scale" % [context, id])
		for source_id: String in row["source_components"]:
			var parent_path := "RoofVisuals/" if source_id.begins_with("Ceiling_") else "Districts/Receiving/"
			suppressed.append(parent_path + source_id + "/Mesh")
	_check(suppressed.size() == 16, "%s maps exactly 16 legacy visual meshes" % context)
	var baseline := (load(GEOMETRY_PATH) as PackedScene).instantiate() as Node3D
	var live := environment.get_node("Greybox")
	var hidden_count := 0
	for base_mesh: MeshInstance3D in baseline.find_children("*", "MeshInstance3D", true, false):
		var path := String(baseline.get_path_to(base_mesh))
		var mesh := live.get_node_or_null(NodePath(path)) as MeshInstance3D
		if not _check(mesh != null, "%s retains greybox %s" % [context, path]):
			continue
		var storage_proxy := path.get_slice("/", 0) == "Proxies" and PROXY_NAMES.has(path.get_slice("/", 1))
		var expected_visible := false if suppressed.has(path) or storage_proxy else base_mesh.visible
		if path in ["Districts/Receiving/DispatchWest/Mesh", "Districts/Receiving/DispatchEast/Mesh"]:
			var trimmed := mesh.mesh as BoxMesh
			var expected_transform := base_mesh.transform
			expected_transform.origin.z -= 0.15 if String(path).contains("DispatchWest") else 0.075
			_check(mesh.visible == expected_visible and mesh.transform.is_equal_approx(expected_transform) and trimmed != null and trimmed.size.is_equal_approx(Vector3(0.3, 4.2, 3.5)) and mesh.material_override == base_mesh.material_override, "%s Dispatch butt visual stops at Receiving outer face without changing its material" % context)
			var world_bounds: AABB = live.transform * mesh.get_parent().transform * mesh.transform * mesh.get_aabb()
			_check(is_equal_approx(world_bounds.position.z, -7.65) and is_equal_approx(world_bounds.end.z, -4.15), "%s Dispatch visual preserves north extent and removes coplanar Receiving cap" % context)
		else:
			_check(mesh.visible == expected_visible and mesh.transform.is_equal_approx(base_mesh.transform) and mesh.mesh == base_mesh.mesh, "%s exact greybox visual preservation %s" % [context, path])
		if suppressed.has(path) and not mesh.visible:
			hidden_count += 1
	_check(hidden_count == 16, "%s exactly 16 mapped Receiving meshes hidden" % context)
	for base_shape: CollisionShape3D in baseline.find_children("*", "CollisionShape3D", true, false):
		var path := String(baseline.get_path_to(base_shape))
		var shape := live.get_node_or_null(NodePath(path)) as CollisionShape3D
		var storage_proxy := path.get_slice("/", 0) == "Proxies" and PROXY_NAMES.has(path.get_slice("/", 1))
		# Only the production lift replaces the six historical barrier shapes.
		var obsolete_barrier := path.begins_with("Boundaries/FreightBarrier/") and environment.get_parent() != null and environment.get_parent().get_node_or_null("ReceivingLiftInstallation") != null
		var expected_disabled := true if storage_proxy or obsolete_barrier else base_shape.disabled
		_check(shape != null and shape.disabled == expected_disabled and shape.shape == base_shape.shape and shape.transform.is_equal_approx(base_shape.transform), "%s preserves greybox collision %s" % [context, path])
		if shape != null:
			var body := shape.get_parent() as StaticBody3D
			var base_body := base_shape.get_parent() as StaticBody3D
			_check(body != null and body.collision_layer == base_body.collision_layer and body.collision_mask == base_body.collision_mask, "%s retained collision layers %s" % [context, path])
	for base_node: Node3D in baseline.find_children("*", "Node3D", true, false):
		var path := baseline.get_path_to(base_node)
		var live_node := live.get_node_or_null(path) as Node3D
		var expected_transform := base_node.transform
		if String(path) in ["Districts/Receiving/DispatchWest/Mesh", "Districts/Receiving/DispatchEast/Mesh"]:
			expected_transform.origin.z -= 0.15 if String(path).contains("DispatchWest") else 0.075
		_check(live_node != null and live_node.transform.is_equal_approx(expected_transform), "%s greybox transforms/anchors preserved except explicit Dispatch visual butt trim %s" % [context, path])
	baseline.free()
	_assert_sill_partition(environment, context)
	# Test actual saved triangles through each aperture, including its edge and closure.
	for z: float in [-2.49, 0.0, 2.49]:
		_check(not _receiving_visual_hit(shell, Vector3(-1, 2, z), Vector3(1, 2, z)), "%s 5.00 m freight visual aperture at %.2f" % [context, z])
	for x: float in [3.095714, 4.285714, 5.475714]:
		_check(not _receiving_visual_hit(shell, Vector3(x, 2, -3), Vector3(x, 2, -5)), "%s 2.40 m Dispatch visual aperture at %.2f" % [context, x])
	for z: float in [-1.41, 0.0, 1.41]:
		for y: float in [0.01, 1.7, 3.39]:
			_check(not _receiving_visual_hit(shell, Vector3(7, y, z), Vector3(8, y, z)), "%s east 2.84 x 3.40 m aperture at %.2f/%.2f" % [context, z, y])
	for z: float in [-1.43, 1.43]:
		_check(_receiving_visual_hit(shell, Vector3(7, 2, z), Vector3(8, 2, z)), "%s east jamb/reveal retained" % context)
	_check(_receiving_visual_hit(shell, Vector3(7, 3.41, 0), Vector3(8, 3.41, 0)) and _receiving_visual_hit(shell, Vector3(7, 4.19, 0), Vector3(8, 4.19, 0)), "%s east 0.80 m upper closure retained" % context)


func _receiving_vec3(values: Array) -> Vector3:
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _receiving_visual_hit(shell: Node3D, from: Vector3, to: Vector3) -> bool:
	for piece: Node3D in shell.get_children():
		var mesh := piece.get_node("GeneratedMesh") as MeshInstance3D
		var arrays := mesh.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		var count := vertices.size() if indices.is_empty() else indices.size()
		for i in range(0, count, 3):
			var a := piece.transform * vertices[i if indices.is_empty() else indices[i]]
			var b := piece.transform * vertices[i + 1 if indices.is_empty() else indices[i + 1]]
			var c := piece.transform * vertices[i + 2 if indices.is_empty() else indices[i + 2]]
			if Geometry3D.segment_intersects_triangle(from, to, a, b, c) != null:
				return true
	return false


func _assert_receiving_circulation(scene: Node, context: String) -> void:
	var player := scene.get_node("Player") as CharacterBody3D
	# Query the normal player capsule without moving or changing its gameplay values.
	var probes := [
		["Dispatch passage", Vector3(-31.714286, 0.01, -3), Vector3(0, 0, -2), false],
		["Dispatch west jamb", Vector3(-33.15, 0.01, -3), Vector3(0, 0, -2), true],
		["Dispatch east jamb", Vector3(-30.25, 0.01, -3), Vector3(0, 0, -2), true],
		["Backlog north jamb", Vector3(-29.5, 0.01, -1.6), Vector3(2, 0, 0), true],
		["Backlog south jamb", Vector3(-29.5, 0.01, 1.6), Vector3(2, 0, 0), true],
		["old north plane clear", Vector3(-32, 0.01, -5), Vector3(1, 0, 0), false],
		["old south plane clear", Vector3(-32, 0.01, 5), Vector3(1, 0, 0), false],
		["old west plane clear", Vector3(-39.5, 0.01, 3), Vector3(1, 0, 0), false],
		["Backlog passage", Vector3(-29.5, 0.01, 0), Vector3(2, 0, 0), false],
		["freight barrier blocks entry", Vector3(-35, 0.01, 0), Vector3(-2, 0, 0), true],
		["freight north corner", Vector3(-38.5, 0.01, -2.5), Vector3(0, 0, -2), true],
		["freight rear corner", Vector3(-40, 0.01, 0), Vector3(-2, 0, 0), true],
	]
	for probe: Array in probes:
		var parameters := PhysicsTestMotionParameters3D.new()
		parameters.from = Transform3D(Basis.IDENTITY, probe[1])
		parameters.motion = probe[2]
		var blocked := PhysicsServer3D.body_test_motion(player.get_rid(), parameters)
		_check(blocked == bool(probe[3]), "%s normal capsule: %s" % [context, probe[0]])


	for x: float in [-28.66, -28.64, -28.51, -28.49, -28.36, -28.34]:
		for z: float in [-1.2, 0.0, 1.2]:
			var ray := PhysicsRayQueryParameters3D.create(Vector3(x, 0.25, z), Vector3(x, -0.25, z), 1)
			var hit := player.get_world_3d().direct_space_state.intersect_ray(ray)
			_check(not hit.is_empty() and absf(hit["position"].y) < 0.0001 and String(hit["collider"].get_path()).contains("Floor_"), "%s continuous nominal slab support at %.2f/%.2f" % [context, x, z])


func _receiving_winding_matches_front_faces(mesh: Mesh) -> bool:
	# Godot renders clockwise triangle fronts. Outward shading normals must
	# oppose the mathematical (counterclockwise) cross product, not match it.
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	var count := vertices.size() if indices.is_empty() else indices.size()
	for i in range(0, count, 3):
		var a := i if indices.is_empty() else indices[i]
		var b := i + 1 if indices.is_empty() else indices[i + 1]
		var c := i + 2 if indices.is_empty() else indices[i + 2]
		if (vertices[b] - vertices[a]).cross(vertices[c] - vertices[a]).normalized().dot(normals[a]) > -0.99:
			return false
	return count > 0

func _assert_sill_partition(environment: Node3D, context: String) -> void:
	var meshes: Array[MeshInstance3D] = [environment.get_node("ReceivingStructuralShell/Floor_ReceivingApron/GeneratedMesh"), environment.get_node("ReceivingStructuralShell/ReceivingEastOpeningWall/GeneratedMesh"), environment.get_node("Greybox/Districts/Backlog/Floor_BacklogPassage/Mesh")]
	# Interior samples straddle both half-strips formerly overlapped by the sill.
	for x: float in [-28.66, -28.64, -28.51, -28.49, -28.36, -28.34]:
		for z: float in [-1.2, 0.17, 1.2]:
			var hits := 0
			for mesh in meshes:
				var arrays := mesh.mesh.surface_get_arrays(0)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
				var count := indices.size() if not indices.is_empty() else vertices.size()
				for i in range(0, count, 3):
					var a := _receiving_relative_transform(environment, mesh) * vertices[indices[i] if not indices.is_empty() else i]
					var b := _receiving_relative_transform(environment, mesh) * vertices[indices[i+1] if not indices.is_empty() else i+1]
					var c := _receiving_relative_transform(environment, mesh) * vertices[indices[i+2] if not indices.is_empty() else i+2]
					if absf(a.y) < 0.00001 and absf(b.y) < 0.00001 and absf(c.y) < 0.00001 and Geometry3D.segment_intersects_triangle(Vector3(x, 0.1, z), Vector3(x, -0.1, z), a, b, c) != null:
						hits += 1
			_check(hits == 1, "%s one floor triangle across sill at %.2f/%.2f" % [context, x, z])


func _receiving_relative_transform(root_node: Node3D, node: Node3D) -> Transform3D:
	var result := node.transform
	var parent := node.get_parent()
	while parent != root_node:
		if parent is Node3D:
			result = parent.transform * result
		parent = parent.get_parent()
	return result
