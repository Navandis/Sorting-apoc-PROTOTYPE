extends "res://environment_collision.gd"

const FunctionalStorageManagerScript = preload(
	"res://gameplay/logistics_wing/functional_storage_manager.gd"
)

var _storage_manager: StoragePrototypeManager = null


func _ready() -> void:
	var install_storage: bool = generate_storage_prototype
	generate_storage_prototype = false
	super._ready()
	if not generate_test_collisions or not install_storage:
		return

	_storage_manager = FunctionalStorageManagerScript.new() as StoragePrototypeManager
	_storage_manager.name = "StoragePrototypeManager"
	add_child(_storage_manager)
	_storage_manager.install(self)
	if _storage_manager == null:
		push_error("FunctionalFixtures could not initialize StoragePrototypeManager")
		return
	# This local manager accepts only F6. Its override deliberately never
	# forwards F7 to the historical occupancy demonstration.
	_storage_manager.set_process_unhandled_input(true)


func get_installed_surfaces() -> Array[Node]:
	if _storage_manager == null:
		return []
	return _storage_manager.get_surfaces()


func get_missing_top_clearance_contexts() -> Array[String]:
	if _storage_manager == null:
		return []
	return _storage_manager.get_missing_top_clearance_contexts()


func is_storage_debug_input_enabled() -> bool:
	## True means the non-destructive F6 presentation toggle is available.
	return (
		_storage_manager != null
		and _storage_manager.is_processing_unhandled_input()
	)


func is_storage_occupancy_demo_enabled() -> bool:
	return false
