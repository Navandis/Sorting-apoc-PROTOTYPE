extends Resource
class_name ReceivingDeckProfile

const DeckSurfaceSpecScript = preload("res://receiving/receiving_deck_surface_spec.gd")

@export var profile_id: StringName = &""
@export_range(1, 9999, 1) var revision: int = 1
@export_range(1, 9999, 1) var layout_version: int = 1
@export_range(0.025, 1.0, 0.025) var cell_size_m: float = 0.10
@export_range(1, 64, 1) var max_layout_attempts: int = 4
@export var surfaces: Array[Resource] = []


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if profile_id == &"":
		errors.append("ReceivingDeckProfile requires profile_id.")
	if revision <= 0:
		errors.append("ReceivingDeckProfile revision must be positive.")
	if layout_version <= 0:
		errors.append("ReceivingDeckProfile layout_version must be positive.")
	if cell_size_m <= 0.0 or not is_finite(cell_size_m):
		errors.append("ReceivingDeckProfile cell_size_m must be finite and positive.")
	if max_layout_attempts <= 0:
		errors.append("ReceivingDeckProfile max_layout_attempts must be positive.")
	if surfaces.is_empty():
		errors.append("ReceivingDeckProfile requires at least one surface.")
	var seen: Dictionary = {}
	for surface: Resource in surfaces:
		if surface == null:
			errors.append("ReceivingDeckProfile contains a null surface.")
			continue
		if surface.get_script() != DeckSurfaceSpecScript:
			errors.append("ReceivingDeckProfile contains a non-deck surface resource.")
			continue
		for error: String in surface.call("validate"):
			errors.append(error)
		var surface_id: StringName = surface.get("surface_id") as StringName
		if seen.has(surface_id):
			errors.append("ReceivingDeckProfile contains duplicate surface_id '%s'." % String(surface_id))
		seen[surface_id] = true
	return errors


func get_surface(surface_id: StringName) -> Resource:
	for surface: Resource in surfaces:
		if surface != null and surface.get_script() == DeckSurfaceSpecScript and surface.get("surface_id") == surface_id:
			return surface
	return null
