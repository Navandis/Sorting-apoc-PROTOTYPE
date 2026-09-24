extends RefCounted
class_name ReceivingFreightFixtureInstance

const FixtureDefinitionScript = preload("res://receiving/receiving_freight_fixture_definition.gd")

var _instance_id: String = ""
var _fixture_definition_id: StringName = &""
var _family: ReceivingFreightFixtureDefinition.FixtureFamily = ReceivingFreightFixtureDefinition.FixtureFamily.CRATE
var _socket_id: StringName = &""
var _surface_id: StringName = &""
var _main_deck_origin: Vector2i = Vector2i(-1, -1)
var _quarter_turns: int = 0
var _base_footprint: Vector2i = Vector2i.ZERO
var _local_transform: Transform3D = Transform3D.IDENTITY

var instance_id: String:
	set(_value):
		pass
	get:
		return _instance_id
var fixture_definition_id: StringName:
	set(_value):
		pass
	get:
		return _fixture_definition_id
var family: ReceivingFreightFixtureDefinition.FixtureFamily:
	set(_value):
		pass
	get:
		return _family
var socket_id: StringName:
	set(_value):
		pass
	get:
		return _socket_id
var surface_id: StringName:
	set(_value):
		pass
	get:
		return _surface_id
var main_deck_origin: Vector2i:
	set(_value):
		pass
	get:
		return _main_deck_origin
var quarter_turns: int:
	set(_value):
		pass
	get:
		return _quarter_turns
var base_footprint: Vector2i:
	set(_value):
		pass
	get:
		return _base_footprint
var local_transform: Transform3D:
	set(_value):
		pass
	get:
		return _local_transform


static func create(
	new_instance_id: String,
	new_fixture_definition_id: StringName,
	new_family: int,
	new_socket_id: StringName,
	new_surface_id: StringName,
	new_main_deck_origin: Vector2i,
	new_quarter_turns: int,
	new_base_footprint: Vector2i,
	new_local_transform: Transform3D
) -> ReceivingFreightFixtureInstance:
	var fixture := ReceivingFreightFixtureInstance.new()
	fixture._instance_id = new_instance_id
	fixture._fixture_definition_id = new_fixture_definition_id
	fixture._family = new_family as ReceivingFreightFixtureDefinition.FixtureFamily
	fixture._socket_id = new_socket_id
	fixture._surface_id = new_surface_id
	fixture._main_deck_origin = new_main_deck_origin
	fixture._quarter_turns = new_quarter_turns
	fixture._base_footprint = new_base_footprint
	fixture._local_transform = new_local_transform
	if not fixture.validate().is_empty():
		return null
	return fixture


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if _instance_id.is_empty():
		errors.append("ReceivingFreightFixtureInstance requires instance_id.")
	if _fixture_definition_id == &"":
		errors.append("ReceivingFreightFixtureInstance requires fixture_definition_id.")
	if _family < 0 or _family > ReceivingFreightFixtureDefinition.FixtureFamily.PALLET:
		errors.append("ReceivingFreightFixtureInstance family is invalid.")
	if _socket_id == &"":
		errors.append("ReceivingFreightFixtureInstance requires socket_id.")
	if _surface_id == &"":
		errors.append("ReceivingFreightFixtureInstance requires surface_id.")
	if _main_deck_origin.x < 0 or _main_deck_origin.y < 0:
		errors.append("ReceivingFreightFixtureInstance main_deck_origin must be non-negative.")
	if _quarter_turns < 0 or _quarter_turns > 3:
		errors.append("ReceivingFreightFixtureInstance quarter_turns must be normalized to 0..3.")
	if _base_footprint.x <= 0 or _base_footprint.y <= 0:
		errors.append("ReceivingFreightFixtureInstance base_footprint must be positive.")
	if not _is_finite_transform(_local_transform):
		errors.append("ReceivingFreightFixtureInstance local_transform must be finite.")
	return errors


func to_snapshot() -> Dictionary:
	return {
		"instance_id": _instance_id,
		"fixture_definition_id": _fixture_definition_id,
		"family": int(_family),
		"socket_id": _socket_id,
		"surface_id": _surface_id,
		"main_deck_origin": _main_deck_origin,
		"quarter_turns": _quarter_turns,
		"base_footprint": _base_footprint,
		"local_transform": _local_transform,
	}


static func from_snapshot(snapshot: Dictionary) -> ReceivingFreightFixtureInstance:
	if (
		typeof(snapshot.get("instance_id")) != TYPE_STRING
		or (typeof(snapshot.get("fixture_definition_id")) != TYPE_STRING_NAME and typeof(snapshot.get("fixture_definition_id")) != TYPE_STRING)
		or typeof(snapshot.get("family")) != TYPE_INT
		or (typeof(snapshot.get("socket_id")) != TYPE_STRING_NAME and typeof(snapshot.get("socket_id")) != TYPE_STRING)
		or (typeof(snapshot.get("surface_id")) != TYPE_STRING_NAME and typeof(snapshot.get("surface_id")) != TYPE_STRING)
		or typeof(snapshot.get("main_deck_origin")) != TYPE_VECTOR2I
		or typeof(snapshot.get("quarter_turns")) != TYPE_INT
		or typeof(snapshot.get("base_footprint")) != TYPE_VECTOR2I
		or typeof(snapshot.get("local_transform")) != TYPE_TRANSFORM3D
	):
		return null
	return create(
		String(snapshot["instance_id"]),
		StringName(snapshot["fixture_definition_id"]),
		int(snapshot["family"]),
		StringName(snapshot["socket_id"]),
		StringName(snapshot["surface_id"]),
		snapshot["main_deck_origin"] as Vector2i,
		int(snapshot["quarter_turns"]),
		snapshot["base_footprint"] as Vector2i,
		snapshot["local_transform"] as Transform3D
	)


static func _is_finite_transform(value: Transform3D) -> bool:
	return (
		value.origin.is_finite()
		and value.basis.x.is_finite()
		and value.basis.y.is_finite()
		and value.basis.z.is_finite()
	)
