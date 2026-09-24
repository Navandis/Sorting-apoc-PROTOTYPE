extends Resource
class_name ReceivingFreightFixtureDefinition

enum FixtureFamily {
	CRATE,
	PALLET,
}

@export var fixture_id: StringName = &""
@export var family: FixtureFamily = FixtureFamily.CRATE

@export var visual_scene: PackedScene
@export var visual_local_transform: Transform3D = Transform3D.IDENTITY

@export var base_footprint: Vector2i = Vector2i.ONE

@export var item_surface_local_transform: Transform3D = Transform3D.IDENTITY
@export var item_surface_usable_width_m: float = 0.10
@export var item_surface_usable_depth_m: float = 0.10
@export var item_surface_stack_clearance_m: float = 0.10

@export var enabled: bool = true


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if fixture_id == &"":
		errors.append("ReceivingFreightFixtureDefinition requires fixture_id.")
	if visual_scene == null:
		errors.append("ReceivingFreightFixtureDefinition requires visual_scene.")
	if base_footprint.x <= 0 or base_footprint.y <= 0:
		errors.append("ReceivingFreightFixtureDefinition base_footprint must be positive.")
	if not _is_finite_transform(visual_local_transform):
		errors.append("ReceivingFreightFixtureDefinition visual_local_transform must be finite.")
	if not _is_finite_transform(item_surface_local_transform):
		errors.append("ReceivingFreightFixtureDefinition item_surface_local_transform must be finite.")
	if item_surface_usable_width_m <= 0.0 or not is_finite(item_surface_usable_width_m):
		errors.append("ReceivingFreightFixtureDefinition item_surface_usable_width_m must be finite and positive.")
	if item_surface_usable_depth_m <= 0.0 or not is_finite(item_surface_usable_depth_m):
		errors.append("ReceivingFreightFixtureDefinition item_surface_usable_depth_m must be finite and positive.")
	if item_surface_stack_clearance_m <= 0.0 or not is_finite(item_surface_stack_clearance_m):
		errors.append("ReceivingFreightFixtureDefinition item_surface_stack_clearance_m must be finite and positive.")
	return errors


static func _is_finite_transform(value: Transform3D) -> bool:
	return (
		value.origin.is_finite()
		and value.basis.x.is_finite()
		and value.basis.y.is_finite()
		and value.basis.z.is_finite()
	)
