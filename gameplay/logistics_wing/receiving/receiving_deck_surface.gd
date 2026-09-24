extends Node3D
class_name ReceivingDeckSurface

## Private Receiving presentation surface. It deliberately reuses the ordinary
## StorageSurface stack mechanics while removing every player PUT target.

const DeckSurfaceSpecScript = preload("res://receiving/receiving_deck_surface_spec.gd")
const StorageSurfaceScript = preload("res://storage_surface.gd")

var _storage_surface: StorageSurface = null


func configure_from_spec(spec: Resource, cell_size_m: float) -> bool:
	if spec == null or spec.get_script() != DeckSurfaceSpecScript:
		return false
	if not spec.validate().is_empty() or not bool(spec.get("enabled")):
		return false
	if cell_size_m <= 0.0 or not is_finite(cell_size_m):
		return false

	return configure_private_surface(
		spec.get("surface_id") as StringName,
		spec.get("local_transform") as Transform3D,
		float(spec.get("usable_width_m")),
		float(spec.get("usable_depth_m")),
		cell_size_m,
		float(spec.get("stack_clearance_m"))
	)


func configure_private_surface(
	surface_id: StringName,
	local_transform: Transform3D,
	usable_width_m: float,
	usable_depth_m: float,
	cell_size_m: float,
	stack_clearance_m: float
) -> bool:
	if (
		surface_id == &""
		or not _is_finite_transform(local_transform)
		or usable_width_m <= 0.0
		or usable_depth_m <= 0.0
		or cell_size_m <= 0.0
		or stack_clearance_m <= 0.0
	):
		return false
	if _storage_surface != null and is_instance_valid(_storage_surface):
		_storage_surface.free()
	_storage_surface = StorageSurfaceScript.new()
	_storage_surface.name = "PrivateStorageSurface"
	_storage_surface.transform = local_transform
	add_child(_storage_surface)
	_storage_surface.configure(
		surface_id,
		usable_width_m,
		usable_depth_m,
		cell_size_m,
		stack_clearance_m
	)
	_storage_surface.set_player_storage_interaction_enabled(false)
	_storage_surface.set_debug_visible(false)
	_storage_surface.set_developer_debug_visible(false)
	return true


func get_storage_surface() -> StorageSurface:
	return _storage_surface


func _is_finite_transform(value: Transform3D) -> bool:
	return (
		value.origin.is_finite()
		and value.basis.x.is_finite()
		and value.basis.y.is_finite()
		and value.basis.z.is_finite()
	)
