extends Resource
class_name ReceivingFreightFixtureSocket

@export var socket_id: StringName = &""
@export var allowed_family: ReceivingFreightFixtureDefinition.FixtureFamily = ReceivingFreightFixtureDefinition.FixtureFamily.CRATE
@export var main_deck_origin: Vector2i = Vector2i.ZERO
@export_range(0, 3, 1) var quarter_turns: int = 0
@export var enabled: bool = true


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if socket_id == &"":
		errors.append("ReceivingFreightFixtureSocket requires socket_id.")
	if main_deck_origin.x < 0 or main_deck_origin.y < 0:
		errors.append("ReceivingFreightFixtureSocket main_deck_origin must be non-negative.")
	if quarter_turns < 0 or quarter_turns > 3:
		errors.append("ReceivingFreightFixtureSocket quarter_turns must be normalized to 0..3.")
	return errors
