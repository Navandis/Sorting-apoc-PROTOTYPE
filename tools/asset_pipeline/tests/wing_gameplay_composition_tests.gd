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
		is_equal_approx(float(player.get("receiving_interaction_distance")), 3.6),
		"%s Receiving reach is separately configured" % context
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
	_check(runtime.position.is_equal_approx(Vector3(-40.905, 0.82, 0.0)), "%s deck root shifts exactly 0.20 m rearward in world -X" % context)
	_check((runtime.basis * Vector3.BACK).is_equal_approx(Vector3.RIGHT), "%s Receiving FRONT local +Z maps to world +X / player-barrier side" % context)
	var manager := runtime.get_node_or_null("ReceivingManager")
	var presenter := runtime.get_node_or_null("ReceivingDeckPresenter") as Node3D
	_check(manager != null, "%s runtime owns one ReceivingManager" % context)
	_check(presenter != null, "%s runtime owns one deck presenter" % context)
	if presenter == null:
		return
	_check(presenter.get_script() != null and presenter.get_script().resource_path == RECEIVING_PRESENTER_SCRIPT_PATH, "%s presenter uses deterministic deck script" % context)
	_check(presenter.get_child_count() >= 1, "%s presenter retains its neutral deck fixture" % context)
	var deck_visual := presenter.get_node_or_null("DeckVisual") as MeshInstance3D
	var deck_mesh := deck_visual.mesh as BoxMesh if deck_visual != null else null
	_check(deck_mesh != null and deck_mesh.size.is_equal_approx(Vector3(3.10, 0.05, 2.10)), "%s physical/support deck is exactly 3.10 m × 2.10 m" % context)
	_check((presenter.call("get_materialized_world_items") as Array).is_empty(), "%s normal launch creates no synthetic Receiving batch" % context)
	var functional_surfaces := scene.call("get_functional_surfaces") as Array
	var private_surfaces := presenter.call("get_private_storage_surfaces") as Array
	_check(private_surfaces.size() == 1, "%s proof presenter owns one private functional grid" % context)
	for surface: Node in private_surfaces:
		_check(not functional_surfaces.has(surface), "%s private deck surface is excluded from functional storage" % context)
		var storage_surface := surface as StorageSurface
		_check(storage_surface.get_grid_size() == Vector2i(30, 20), "%s private grid remains exactly 30 × 20" % context)
		_check(storage_surface.get_usable_size_m().is_equal_approx(Vector2(3.0, 2.0)), "%s functional usable area remains exactly 3.00 m × 2.00 m" % context)
		if deck_mesh != null:
			var margin := (Vector2(deck_mesh.size.x, deck_mesh.size.z) - storage_surface.get_usable_size_m()) * 0.5
			_check(margin.is_equal_approx(Vector2(0.05, 0.05)), "%s support border is centered and non-reservable at 0.05 m per edge" % context)
	for forbidden_name: String in ["ReceivingGeometryComparison", "ReceivingPhysicsPileProof", "ReceivingComparisonA", "ReceivingComparisonB", "ReceivingComparisonC"]:
		_check(scene.find_child(forbidden_name, true, false) == null, "%s omits historical %s" % [context, forbidden_name])


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
