extends Node
# Runtime texture binding keeps editor resources free of pathless live textures.
const STATUS := ["IDLE", "INCOMING", "INCOMING", "OPENING", "OPEN", "CLOSING"]
const FOOTER := [
	"AWAITING EXPEDITION LOOT", "DELIVERING EXPEDITION LOOT",
	"DELIVERING EXPEDITION LOOT", "LIFT SHUTTER OPENING",
	"LOOT READY FOR PICK-UP", "LIFT SHUTTER CLOSING",
]
var _cycle: Node

func _ready() -> void:
	var mesh := get_node_or_null("../SM_KB3D_CPP_PropTV_A/Mesh") as MeshInstance3D
	if mesh == null:
		return # The passive UI scene can also be previewed on its own.
	var material := mesh.get_surface_override_material(1).duplicate() as StandardMaterial3D
	material.albedo_color = Color.WHITE
	material.albedo_texture = $ScreenViewport.get_texture()
	mesh.set_surface_override_material(1, material)

func bind_cycle(cycle: Node) -> void:
	_cycle = cycle
	_cycle.readout_changed.connect(_update_readout)
	_update_readout()

func _update_readout() -> void:
	var state: int = _cycle.get_cycle_state()
	var count: int = _cycle.get_deck_item_count()
	var ui := $ScreenViewport/Interface
	ui.get_node("Status").text = "STATUS : " + STATUS[state]
	ui.get_node("Deck").text = "DECK   : " + ("CLEAR" if count == 0 else "%02d" % count)
	ui.get_node("Queue").text = "QUEUE  : %02d" % _cycle.get_queued_batch_count()
	ui.get_node("Waiting").text = FOOTER[state]
