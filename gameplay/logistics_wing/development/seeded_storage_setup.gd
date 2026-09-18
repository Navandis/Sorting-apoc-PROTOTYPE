extends Node3D

var _initialized: bool = false


func _ready() -> void:
	initialize_if_enabled()


func initialize_if_enabled() -> bool:
	if _initialized:
		return true
	var registrar := get_node_or_null("SeedRegistrar")
	if registrar == null or not registrar.has_method("register_existing_hosts"):
		push_error("SeededStorageSetup requires its SeedRegistrar child")
		return false
	_initialized = bool(registrar.call("register_existing_hosts"))
	return _initialized
