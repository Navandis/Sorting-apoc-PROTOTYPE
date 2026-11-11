extends Node3D

const Timeline = preload("res://gameplay/run/collection_timeline.gd")
const Identity = preload("res://gameplay/run/run_identity.gd")
const Goal = preload("res://gameplay/run/collection_goal.gd")
const GoalHUD = preload("res://gameplay/run/collection_goal_hud.gd")
const ExpeditionConfig = preload("res://gameplay/expeditions/expedition_test_config.gd")
const ExpeditionOperations = preload("res://gameplay/expeditions/expedition_operations.gd")
const DispatchPanel = preload("res://gameplay/expeditions/dispatch_panel.gd")
const IncineratorOperations = preload("res://gameplay/disposal/incinerator_operations.gd")
const IncineratorPanel = preload("res://gameplay/disposal/incinerator_panel.gd")
const KitchenOperations = preload("res://gameplay/kitchen/kitchen_operations.gd")
const KitchenPanel = preload("res://gameplay/kitchen/kitchen_panel.gd")
const FuelOperations := preload("res://gameplay/fuel/fuel_operations.gd")
const FuelPanel := preload("res://gameplay/fuel/fuel_panel.gd")
const FuelLighting := preload("res://gameplay/fuel/fuel_lighting.gd")
const FUEL_STATION := "ReceivingSetDressing/CollisionProxies/ElectricalCabinetMovement"
const KITCHEN_MESH := "Environment/Greybox/Proxies/KitchenInterface/Mesh"
const KITCHEN_INTERACTION_LAYER := 1 << 10

@export var development_setup_enabled: bool = true
var run_identity: RefCounted
var run_timeline: RefCounted
var restoring := false
var collection_goal: RefCounted
var expeditions: RefCounted
var _collection_hud: CanvasLayer
var dispatch_panel: CanvasLayer
var incinerator: RefCounted
var incinerator_panel: CanvasLayer
var kitchen: RefCounted
var kitchen_panel: CanvasLayer
var fuel: RefCounted
var fuel_panel: CanvasLayer
var _fuel_lighting: RefCounted
var _collection_error := ""


func configure_new_run() -> void:
	run_identity = Identity.new()
	run_timeline = Timeline.new()
	collection_goal = Goal.new(ExpeditionConfig.COLLECTION_TARGET)
	_configure_services()
	var seeds := Crypto.new().generate_random_bytes(16)
	kitchen.initialize(seeds.decode_s64(0), seeds.decode_s64(8))
	fuel.initialize()


func configure_continue(state: Dictionary) -> void:
	restoring = true
	run_identity = Identity.new()
	run_identity.restore_state(state.run)
	run_timeline = Timeline.new()
	run_timeline.restore_state(state.timeline)
	_configure_services()
	fuel.restore_state(state.fuel)
	collection_goal = Goal.new(state.goal.target)
	collection_goal.restore_state(state.goal)

func _configure_services() -> void:
	expeditions = ExpeditionOperations.new(run_identity, run_timeline.clock)
	incinerator = IncineratorOperations.new(run_timeline.clock,
		func(id: String): return expeditions.has_spent_item(id) or kitchen.has_spent_item(id) or fuel.has_spent_item(id))
	kitchen = KitchenOperations.new(run_timeline.clock,
		func(id: String): return expeditions.has_spent_item(id) or incinerator.has_spent_item(id) or fuel.has_spent_item(id))
	fuel = FuelOperations.new(run_timeline.clock, func(id: String):
		return expeditions.has_spent_item(id) or incinerator.has_spent_item(id) or kitchen.has_spent_item(id))
	expeditions.other_consumer_has_spent = func(id: String):
		return incinerator.has_spent_item(id) or kitchen.has_spent_item(id) or fuel.has_spent_item(id)

func _enter_tree() -> void:
	if run_identity != null:
		var setup := get_node_or_null("DevelopmentSetup")
		if setup != null:
			setup.restore_pending = restoring
			setup.get_node("SeedRegistrar").fixture_namespace = run_identity.run_id + ":wing_seed_v1"
		var runtime := get_node("ReceivingRuntime")
		runtime.run_identity = run_identity
	var hud := get_node_or_null("HUD/CarriedItemsHUD")
	if hud != null:
		hud.set("carried_items_path", NodePath("../../Player/CarriedItems"))

	if not development_setup_enabled:
		_remove_development_setup()


func _ready() -> void:
	if run_timeline != null:
		run_timeline.bind($ReceivingRuntime, expeditions, kitchen, fuel)
		if run_timeline.error.is_empty():
			_bind_collection()
	for station: Array in [["MedicalInterface", "Medical"], ["KitchenInterface", "Kitchen"], ["DispatchWorkSurface", "Dispatch"]]:
		var proxy := get_node_or_null("Environment/Greybox/Proxies/" + station[0])
		if proxy != null:
			var label := Label3D.new()
			label.text = station[1] + "\nService inactive"
			if station[1] == "Dispatch" and expeditions != null:
				label.text = "Dispatch\n[F] Prepare expedition"
			elif station[1] == "Kitchen" and $Player.kitchen_station != null:
				label.text = "Kitchen\n[F] Open service"
			label.font_size = 36
			label.pixel_size = 0.003
			label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label.position.y = 0.75
			proxy.add_child(label)


func _bind_collection() -> void:
	var fixtures := get_node_or_null("FunctionalFixtures")
	if fixtures == null or not fixtures.collection_registration_error.is_empty() or fixtures.get_collection_surfaces().is_empty():
		_collection_error = "Qualifying collection storage failed to initialize"
		return
	for definition: ItemDefinition in $ReceivingRuntime.item_catalog.definitions:
		_collection_error = Goal.definition_error(definition)
		if not _collection_error.is_empty():
			return
	if not _bind_kitchen_frontage():
		_collection_error = "Kitchen frontage could not initialize"
		return
	$Player.fuel_station = get_node_or_null(FUEL_STATION) as StaticBody3D
	if $Player.fuel_station == null:
		_collection_error = "Receiving Fuel station could not initialize"
		return
	_fuel_lighting = FuelLighting.new()
	if not _fuel_lighting.bind(self):
		_collection_error = "Fuel working lights could not initialize"
		return
	fuel.power_changed.connect(_apply_fuel_lighting)
	_apply_fuel_lighting()
	var surfaces: Array[StorageSurface] = fixtures.get_collection_surfaces()
	collection_goal.bind(surfaces)
	for surface: StorageSurface in surfaces:
		surface.player_transfer_committed.connect(_refresh_collection)
	if not restoring:
		_refresh_collection()
		if _collection_error.is_empty():
			_attach_collection_hud()
			_attach_service_panels()

func _bind_kitchen_frontage() -> bool:
	var mesh := get_node_or_null(KITCHEN_MESH) as MeshInstance3D
	if mesh == null or not mesh.mesh is BoxMesh:
		return false
	# The authored proxy is decorative. Match its mesh for station rays only.
	var station := StaticBody3D.new()
	station.name = "KitchenInteraction"
	station.collision_layer = KITCHEN_INTERACTION_LAYER
	station.collision_mask = 0
	var bounds := BoxShape3D.new()
	bounds.size = mesh.mesh.size
	var shape := CollisionShape3D.new()
	shape.shape = bounds
	station.add_child(shape)
	mesh.add_child(station)
	var player := $Player
	player.kitchen_station = station
	player.sprint_allowed = kitchen.sprint_allowed
	player.carried_items.capacity_for_normal = kitchen.effective_capacity
	kitchen.changed.connect(player.carried_items.capacity_changed.emit)
	return true

func _apply_fuel_lighting() -> void:
	_fuel_lighting.apply(fuel.lighting_multiplier())


func _refresh_collection() -> void:
	if restoring:
		return
	_collection_error = collection_goal.refresh(run_timeline.clock.elapsed)
	if not _collection_error.is_empty():
		push_error(_collection_error)


func finish_restoring() -> String:
	var error: String = collection_goal.refresh(run_timeline.clock.elapsed, false)
	if not error.is_empty():
		return error
	if collection_goal.is_satisfied() and not collection_goal.completed:
		return "Stored collection meets its target without a completion record"
	restoring = false
	_attach_collection_hud()
	_attach_service_panels()
	return ""


func _attach_collection_hud() -> void:
	_collection_hud = GoalHUD.new()
	_collection_hud.name = "CollectionGoalHUD"
	_collection_hud.goal = collection_goal
	_collection_hud.clock = run_timeline.clock
	_collection_hud.kitchen = kitchen
	add_child(_collection_hud)

func _attach_service_panels() -> void:
	var player := $Player
	player.dispatch_station = get_node("Environment/Greybox/Proxies/DispatchWorkSurface/StaticBody3D")
	dispatch_panel = DispatchPanel.new()
	dispatch_panel.name = "DispatchPanel"
	dispatch_panel.operations = expeditions
	dispatch_panel.carry = player.carried_items
	dispatch_panel.clock = run_timeline.clock
	add_child(dispatch_panel)
	player.dispatch_requested.connect(func():
		if _can_open_service_panel():
			dispatch_panel.open_panel())
	dispatch_panel.panel_toggled.connect(_on_service_panel_toggled)

	player.incinerator_station = get_node("Environment/Greybox/Proxies/IncineratorMachine/StaticBody3D")
	incinerator_panel = IncineratorPanel.new()
	incinerator_panel.name = "IncineratorPanel"
	incinerator_panel.operations = incinerator
	incinerator_panel.carry = player.carried_items
	incinerator_panel.station_reachable = player.can_reach_incinerator
	add_child(incinerator_panel)
	player.incinerator_requested.connect(func():
		if _can_open_service_panel() and player.can_reach_incinerator():
			incinerator_panel.open_panel())
	incinerator_panel.panel_toggled.connect(_on_service_panel_toggled)

	kitchen_panel = KitchenPanel.new()
	kitchen_panel.name = "KitchenPanel"
	kitchen_panel.operations = kitchen
	kitchen_panel.clock = run_timeline.clock
	kitchen_panel.carry = player.carried_items
	kitchen_panel.station_reachable = player.can_reach_kitchen
	add_child(kitchen_panel)
	player.kitchen_requested.connect(func():
		if _can_open_service_panel() and player.can_reach_kitchen():
			kitchen_panel.open_panel())
	kitchen_panel.panel_toggled.connect(_on_service_panel_toggled)

	fuel_panel = FuelPanel.new()
	fuel_panel.name = "FuelPanel"
	fuel_panel.operations = fuel
	fuel_panel.carry = player.carried_items
	fuel_panel.station_reachable = player.can_reach_fuel
	add_child(fuel_panel)
	player.fuel_requested.connect(func():
		if _can_open_service_panel() and player.can_reach_fuel():
			fuel_panel.open_panel())
	fuel_panel.panel_toggled.connect(_on_service_panel_toggled)

func _can_open_service_panel() -> bool:
	return not get_tree().paused and not $Player.world_input_blocked and not $Player._zone_editor_open

func _service_panel_open() -> bool:
	return (dispatch_panel != null and dispatch_panel.is_open()) \
		or (incinerator_panel != null and incinerator_panel.is_open()) \
		or (kitchen_panel != null and kitchen_panel.is_open()) \
		or (fuel_panel != null and fuel_panel.is_open())

func _on_service_panel_toggled() -> void:
	if _service_panel_open():
		$Player.velocity = Vector3.ZERO
	sync_player_input(get_tree().paused)

func sync_player_input(paused: bool) -> void:
	var blocked := paused or _service_panel_open()
	if incinerator_panel != null and incinerator_panel.is_open():
		incinerator_panel.refresh_key_guards()
	if kitchen_panel != null and kitchen_panel.is_open():
		kitchen_panel.refresh_key_guards()
	if fuel_panel != null and fuel_panel.is_open():
		fuel_panel.refresh_key_guards()
	$Player.set_world_input_blocked(blocked)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if blocked else Input.MOUSE_MODE_CAPTURED

func close_service_layer() -> bool:
	if fuel_panel != null and fuel_panel.close_top():
		return true
	if kitchen_panel != null and kitchen_panel.close_top():
		return true
	if incinerator_panel != null and incinerator_panel.close_top():
		return true
	return dispatch_panel != null and dispatch_panel.close_top()


func show_run_notice(message: String) -> void:
	_collection_hud.show_notice(message)


func _process(_delta: float) -> void:
	if run_timeline == null or restoring:
		return
	run_timeline.advance(run_timeline.clock.sample_delta(Time.get_ticks_usec()))


func _notification(what: int) -> void:
	if run_timeline != null and what in [
		NOTIFICATION_PAUSED, NOTIFICATION_UNPAUSED,
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_RESUMED,
	]:
		run_timeline.clock.reset_sample()


func is_development_setup_active() -> bool:
	return get_node_or_null("DevelopmentSetup") != null


func get_functional_surfaces() -> Array[Node]:
	var fixtures := get_node_or_null("FunctionalFixtures")
	if fixtures == null or not fixtures.has_method("get_installed_surfaces"):
		return []
	return fixtures.get_installed_surfaces()


func _remove_development_setup() -> void:
	var setup := get_node_or_null("DevelopmentSetup")
	if setup != null:
		remove_child(setup)
		setup.queue_free()


func get_run_error() -> String:
	if run_timeline != null and not run_timeline.error.is_empty():
		return run_timeline.error
	if expeditions != null and not expeditions.error.is_empty():
		return expeditions.error
	return _collection_error


func get_initialization_error() -> String:
	var error := get_run_error()
	if not error.is_empty():
		return error
	if collection_goal != null and collection_goal.target <= 0:
		return "Collection target must be a positive integer"
	var registrar := get_node_or_null("DevelopmentSetup/SeedRegistrar")
	if registrar == null or (not restoring and not bool(registrar.get("_registration_completed"))):
		return "Starting supplies failed to initialize"
	if not (registrar.get_validation_failures() as Array).is_empty():
		return "Starting supplies are incompatible: " + "; ".join(registrar.get_validation_failures())
	var runtime := get_node_or_null("ReceivingRuntime") as ReceivingRuntime
	if runtime == null or runtime.return_admission == null or not runtime.lift_cycle.is_configured():
		return "Receiving failed to initialize"
	if get_functional_surfaces().is_empty():
		return "Player storage failed to initialize"
	return ""
