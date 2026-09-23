extends Resource
class_name ReceivingDeckSurfaceSpec

@export var surface_id: StringName = &""
@export var local_transform: Transform3D = Transform3D.IDENTITY
@export_range(0.01, 100.0, 0.01) var usable_width_m: float = 1.0
@export_range(0.01, 100.0, 0.01) var usable_depth_m: float = 1.0
@export_range(0.01, 100.0, 0.01) var stack_clearance_m: float = 1.0
@export var enabled: bool = true


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if surface_id == &"":
		errors.append("ReceivingDeckSurfaceSpec requires surface_id.")
	if not _is_finite_transform(local_transform):
		errors.append("ReceivingDeckSurfaceSpec local_transform must be finite.")
	if usable_width_m <= 0.0 or not is_finite(usable_width_m):
		errors.append("ReceivingDeckSurfaceSpec usable_width_m must be finite and positive.")
	if usable_depth_m <= 0.0 or not is_finite(usable_depth_m):
		errors.append("ReceivingDeckSurfaceSpec usable_depth_m must be finite and positive.")
	if stack_clearance_m <= 0.0 or not is_finite(stack_clearance_m):
		errors.append("ReceivingDeckSurfaceSpec stack_clearance_m must be finite and positive.")
	return errors


static func _is_finite_transform(value: Transform3D) -> bool:
	return (
		value.origin.is_finite()
		and value.basis.x.is_finite()
		and value.basis.y.is_finite()
		and value.basis.z.is_finite()
	)
