extends Node3D

const Timeline = preload("res://gameplay/run/collection_timeline.gd")
const Identity = preload("res://gameplay/run/run_identity.gd")
const Goal = preload("res://gameplay/run/collection_goal.gd")
const GoalHUD = preload("res://gameplay/run/collection_goal_hud.gd")

@export var development_setup_enabled: bool = true
var run_identity: RefCounted
var run_timeline: RefCounted
var restoring := false
var collection_goal: RefCounted
var _collection_hud: CanvasLayer
var _collection_error := ""


func configure_new_run(definition: Dictionary = {}) -> void:
	run_identity = Identity.new()
	run_timeline = Timeline.new()
	var fixture := Timeline.default_fixture() if definition.is_empty() else definition.duplicate(true)
	var target: Variant = fixture.get("target")
	var target_is_integer := typeof(target) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(target)) and float(target) == int(target)
	collection_goal = Goal.new(int(target) if target_is_integer else 0)
	fixture.erase("target")
	run_timeline.initialize(fixture)


func configure_continue(state: Dictionary) -> void:
	restoring = true
	run_identity = Identity.new()
	run_identity.restore_state(state.run)
	run_timeline = Timeline.new()
	run_timeline.restore_state(state.timeline)
	collection_goal = Goal.new(state.goal.target)
	collection_goal.restore_state(state.goal)


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
		run_timeline.bind($ReceivingRuntime, restoring)
		if run_timeline.error.is_empty():
			_bind_collection()
	for station: Array in [["MedicalInterface", "Medical"], ["KitchenInterface", "Kitchen"], ["DispatchWorkSurface", "Dispatch"]]:
		var proxy := get_node_or_null("Environment/Greybox/Proxies/" + station[0])
		if proxy != null:
			var label := Label3D.new()
			label.text = station[1] + "\nService inactive"
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
	var surfaces: Array[StorageSurface] = fixtures.get_collection_surfaces()
	collection_goal.bind(surfaces)
	for surface: StorageSurface in surfaces:
		surface.player_transfer_committed.connect(_refresh_collection)
	if not restoring:
		_refresh_collection()
		if _collection_error.is_empty():
			_attach_collection_hud()


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
	return ""


func _attach_collection_hud() -> void:
	_collection_hud = GoalHUD.new()
	_collection_hud.name = "CollectionGoalHUD"
	_collection_hud.goal = collection_goal
	_collection_hud.clock = run_timeline.clock
	add_child(_collection_hud)


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
