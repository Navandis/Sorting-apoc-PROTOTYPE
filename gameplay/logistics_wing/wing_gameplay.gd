extends Node3D

@export var development_setup_enabled: bool = true
var run_identity: RefCounted
var medical_request: RefCounted
var restoring := false
var _continue_state: Dictionary = {}
var run_schedule: RefCounted


func configure_new_run(definition: Dictionary = {}) -> void:
	run_identity = load("res://gameplay/run/run_identity.gd").new()
	run_schedule = load("res://gameplay/run/run_schedule.gd").new()
	run_schedule.initialize(definition)
	run_identity.clock = run_schedule.clock
	run_identity.scenario = String(run_schedule.definition.get("id", ""))


func configure_continue(state: Dictionary) -> void:
	restoring = true
	_continue_state = state
	run_identity = load("res://gameplay/run/run_identity.gd").new()
	run_identity.restore_state(state.run)
	run_schedule = load("res://gameplay/run/run_schedule.gd").new()
	run_schedule.clock.restore_state(state.clock)
	run_schedule.restore_state(state.schedule)
	run_identity.clock = run_schedule.clock
	medical_request = run_schedule.latest_request()


func _enter_tree() -> void:
	if run_identity != null:
		var setup := get_node_or_null("DevelopmentSetup")
		if setup != null:
			setup.restore_pending = restoring
			setup.get_node("SeedRegistrar").fixture_namespace = run_identity.run_id + ":wing_seed_v1"
		var runtime := get_node("ReceivingRuntime")
		runtime.restore_pending = restoring
		runtime.run_identity = run_identity
	var hud := get_node_or_null("HUD/CarriedItemsHUD")
	if hud != null:
		hud.set("carried_items_path", NodePath("../../Player/CarriedItems"))

	if not development_setup_enabled:
		_remove_development_setup()


func _ready() -> void:
	if run_schedule == null:
		medical_request = load("res://gameplay/requests/contribution_request.gd").new("medical-prototype")
	var interface: Node = load("res://gameplay/requests/medical_interface.gd").new()
	interface.name = "MedicalContribution"
	add_child(interface)
	interface.configure(self, medical_request)
	if run_schedule != null:
		run_schedule.bind(self)
		var clock_hud = load("res://gameplay/run/clock_hud.gd").new()
		clock_hud.schedule = run_schedule
		add_child(clock_hud)


func _process(delta: float) -> void:
	if run_schedule != null and not restoring:
		run_schedule.advance(delta)


func is_development_setup_active() -> bool:
	return get_node_or_null("DevelopmentSetup") != null


func get_functional_surfaces() -> Array[Node]:
	var fixtures := get_node_or_null("FunctionalFixtures")
	if fixtures == null or not fixtures.has_method("get_installed_surfaces"):
		return []
	return fixtures.call("get_installed_surfaces") as Array[Node]


func _remove_development_setup() -> void:
	var setup := get_node_or_null("DevelopmentSetup")
	if setup != null:
		remove_child(setup)
		setup.queue_free()

func get_initialization_error() -> String:
	if run_schedule != null and not run_schedule.error.is_empty(): return run_schedule.error
	var setup := get_node_or_null("DevelopmentSetup")
	if setup == null:
		return "Persistent run requires the authored DevelopmentSetup"
	var registrar := setup.get_node_or_null("SeedRegistrar")
	if registrar == null or (not restoring and not bool(registrar.get("_registration_completed"))):
		return "Starting supplies failed to initialize; previous continuation retained"
	if not (registrar.get_validation_failures() as Array).is_empty():
		return "Starting supplies are incompatible: " + "; ".join(registrar.get_validation_failures())
	var runtime := get_node_or_null("ReceivingRuntime")
	if runtime == null or runtime.return_admission == null or not runtime.lift_cycle.is_configured():
		return "Receiving failed to initialize; previous continuation retained"
	if get_functional_surfaces().size() != 16 or get_node_or_null("MedicalContribution") == null:
		return "Canonical gameplay owners failed to initialize"
	return ""
