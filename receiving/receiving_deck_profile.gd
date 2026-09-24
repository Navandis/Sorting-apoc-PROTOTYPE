extends Resource
class_name ReceivingDeckProfile

const DeckSurfaceSpecScript = preload("res://receiving/receiving_deck_surface_spec.gd")
const FreightFixtureDefinitionScript = preload("res://receiving/receiving_freight_fixture_definition.gd")
const FreightFixtureSocketScript = preload("res://receiving/receiving_freight_fixture_socket.gd")

@export var profile_id: StringName = &""
@export_range(1, 9999, 1) var revision: int = 1
@export_range(1, 9999, 1) var layout_version: int = 1
@export_range(0.025, 1.0, 0.025) var cell_size_m: float = 0.10
@export_range(1, 64, 1) var max_layout_attempts: int = 4
@export var surfaces: Array[Resource] = []
@export var freight_fixture_definitions: Array[Resource] = []
@export var freight_fixture_sockets: Array[Resource] = []


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
	_validate_freight_fixture_definitions(errors)
	_validate_freight_fixture_sockets(errors)
	return errors


func _validate_freight_fixture_definitions(errors: PackedStringArray) -> void:
	var seen: Dictionary = {}
	for definition: Resource in freight_fixture_definitions:
		if definition == null:
			errors.append("ReceivingDeckProfile contains a null freight fixture definition.")
			continue
		if definition.get_script() != FreightFixtureDefinitionScript:
			errors.append("ReceivingDeckProfile contains a non-freight fixture definition resource.")
			continue
		var fixture_id: StringName = definition.get("fixture_id") as StringName
		if seen.has(fixture_id):
			errors.append("ReceivingDeckProfile contains duplicate fixture_id '%s'." % String(fixture_id))
		seen[fixture_id] = true
		if bool(definition.get("enabled")):
			for error: String in definition.call("validate"):
				errors.append(error)


func _validate_freight_fixture_sockets(errors: PackedStringArray) -> void:
	var seen: Dictionary = {}
	for socket: Resource in freight_fixture_sockets:
		if socket == null:
			errors.append("ReceivingDeckProfile contains a null freight fixture socket.")
			continue
		if socket.get_script() != FreightFixtureSocketScript:
			errors.append("ReceivingDeckProfile contains a non-freight fixture socket resource.")
			continue
		var socket_id: StringName = socket.get("socket_id") as StringName
		if seen.has(socket_id):
			errors.append("ReceivingDeckProfile contains duplicate socket_id '%s'." % String(socket_id))
		seen[socket_id] = true
		if bool(socket.get("enabled")):
			for error: String in socket.call("validate"):
				errors.append(error)


func get_surface(surface_id: StringName) -> Resource:
	for surface: Resource in surfaces:
		if surface != null and surface.get_script() == DeckSurfaceSpecScript and surface.get("surface_id") == surface_id:
			return surface
	return null
