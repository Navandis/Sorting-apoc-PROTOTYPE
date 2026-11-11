extends Node
# Runtime texture binding keeps editor resources free of pathless live textures.
const STATUS := ["IDLE", "INCOMING", "INCOMING", "OPENING", "OPEN", "CLOSING"]
const FOOTER := [
	"AWAITING CARGO", "DELIVERING CARGO",
	"DELIVERING CARGO", "LIFT SHUTTER OPENING",
	"LOOT READY FOR PICK-UP", "LIFT SHUTTER CLOSING",
]
const EMERGENCY_TINT := Color(0.92, 0.54, 0.24)
var _cycle: ReceivingLiftCycle
var _normal_tints: Dictionary = {}
var _shown_emergency := false
var _shown_seconds := -1

func _ready() -> void:
	var mesh := get_node_or_null("../SM_KB3D_CPP_PropTV_A/Mesh") as MeshInstance3D
	if mesh == null:
		return # The passive UI scene can also be previewed on its own.
	var material := mesh.get_surface_override_material(1).duplicate() as StandardMaterial3D
	material.albedo_color = Color.WHITE
	material.albedo_texture = $ScreenViewport.get_texture()
	mesh.set_surface_override_material(1, material)

func bind_cycle(cycle: ReceivingLiftCycle) -> void:
	_cycle = cycle
	for node: Node in $ScreenViewport/Interface.get_children():
		if node is Label:
			_normal_tints[node] = node.get_theme_color("font_color")
	_cycle.readout_changed.connect(_update_readout)
	_update_readout()

func _update_readout() -> void:
	var state: int = _cycle.get_cycle_state()
	var count: int = _cycle.get_deck_item_count()
	var ui := $ScreenViewport/Interface
	var emergency := _cycle.is_emergency_mode()
	if emergency != _shown_emergency:
		_shown_emergency = emergency
		for label: Label in _normal_tints:
			label.add_theme_color_override("font_color", EMERGENCY_TINT if emergency else _normal_tints[label])
	ui.get_node("Mode").text = "MODE   : EMERGENCY FREIGHT" if emergency else "MODE   : NORMAL FREIGHT"
	var waiting := _cycle.is_waiting_to_start()
	ui.get_node("Status").text = "STATUS : " + ("WAITING" if waiting else STATUS[state])
	ui.get_node("Deck").text = "DECK   : " + ("CLEAR" if count == 0 else "%02d" % count)
	ui.get_node("Queue").text = "QUEUE  : %02d" % _cycle.get_queued_batch_count()
	_shown_seconds = -1
	if waiting:
		_update_wait()
	else:
		ui.get_node("Waiting").text = "LIFT RETURNING" if _cycle.is_departing() else FOOTER[state]

func _process(_delta: float) -> void:
	if _cycle != null and _cycle.is_waiting_to_start():
		_update_wait()

func _update_wait() -> void:
	var seconds := ceili(_cycle.wait_remaining())
	if seconds != _shown_seconds:
		_shown_seconds = seconds
		$ScreenViewport/Interface/Waiting.text = "START IN %02d S" % seconds
