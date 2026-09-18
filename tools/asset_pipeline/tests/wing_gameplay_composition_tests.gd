extends SceneTree

const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
const GEOMETRY_PATH := "res://greybox/logistics_wing/wing_geometry.tscn"
const PLAYER_SCRIPT_PATH := "res://player_controller.gd"
const CARRIED_SCRIPT_PATH := "res://carried_items.gd"
const HUD_SCRIPT_PATH := "res://carried_items_hud.gd"
const ENVIRONMENT_PATH := "res://gameplay/logistics_wing/wing_environment.tscn"
const DEVELOPMENT_SETUP_PATH := "res://gameplay/logistics_wing/development/seeded_storage_setup.tscn"
const FIXTURE_NAMES: Array[String] = [
	"SM_MetalShelves_GalleryA_West",
	"SM_MetalShelves_GalleryB_North",
	"SM_ventilated_locker_GalleryC_West",
]
const PROXY_NAMES: Array[String] = [
	"GalleryA_West",
	"GalleryB_North",
	"GalleryC_West",
]
const ORDINARY_CEILING_UNDERSIDE_Y_M := 3.40

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
	await _assert_duplicate_setup_namespace_rejected(packed)
	await _assert_duplicate_fixture_namespace_rejected(packed)

	_finish()


func _assert_composition(scene: Node, context: String) -> void:
	var player := scene.get_node_or_null("Player") as CharacterBody3D
	var carried := scene.get_node_or_null("Player/CarriedItems")
	var hud := scene.get_node_or_null("HUD/CarriedItemsHUD")
	var environment := scene.get_node_or_null("Environment") as Node3D
	var development_setup := scene.get_node_or_null("DevelopmentSetup") as Node3D

	_check(player != null, "%s composition has full gameplay player" % context)
	_check(carried != null, "%s composition has carried-items container" % context)
	_check(hud != null, "%s composition has carried-items HUD" % context)
	_check(environment != null, "%s composition has environment wrapper" % context)
	_check(development_setup != null, "%s composition includes authored development setup" % context)
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
		not _instances_scene(scene, "res://main.tscn"),
		"%s composition does not embed historical main" % context
	)
	_check(
		not _instances_scene(scene, "res://greybox/logistics_wing/wing_review.tscn"),
		"%s composition does not embed neutral-review harness" % context
	)
	_assert_environment_proxy_contract(environment, context)
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
		_check(surfaces.size() == 12, "%s setup keeps twelve storage surfaces" % context)
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
		"SM_MetalShelves_GalleryA_West": Vector3(-2.28, 0.0, -7.20),
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
	_check(surfaces.size() == 12, "%s installs twelve storage surfaces" % context)
	var surface_ids: Dictionary = {}
	var top_surfaces: Dictionary = {}
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
		if String(surface.name) == "StorageSurface_04":
			top_surfaces[String(surface.get_parent().name)] = surface

	_check(surface_ids.size() == 12, "%s has twelve distinct surface IDs" % context)
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
	_check(all_surfaces.size() == 12, "%s no other asset gains a StorageSurface" % context)
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
