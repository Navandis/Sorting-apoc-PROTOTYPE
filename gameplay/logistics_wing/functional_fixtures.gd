extends "res://environment_collision.gd"

const FunctionalStorageManagerScript = preload(
	"res://gameplay/logistics_wing/functional_storage_manager.gd"
)

## Every installed level of these explicitly designated storage units scores.
@export var collection_storage_units: Array[NodePath] = []
var _storage_manager: StoragePrototypeManager = null
var _collection_surfaces: Array[StorageSurface] = []
var collection_registration_error := ""


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
	_register_collection_surfaces()
	# This local manager accepts only F6. Its override deliberately never
	# forwards F7 to the historical occupancy demonstration.
	_storage_manager.set_process_unhandled_input(true)


func _register_collection_surfaces() -> void:
	for path: NodePath in collection_storage_units:
		var unit := get_node_or_null(path)
		var found := false
		for surface: StorageSurface in _storage_manager.get_surfaces():
			if unit != null and unit.is_ancestor_of(surface):
				found = true
				if not _collection_surfaces.has(surface):
					_collection_surfaces.append(surface)
		if not found:
			collection_registration_error = "No installed collection storage for " + String(path)
			return


func get_collection_surfaces() -> Array[StorageSurface]:
	return _collection_surfaces.duplicate()


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
