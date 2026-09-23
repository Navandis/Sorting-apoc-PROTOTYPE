@tool
extends Node3D

enum GeometryCase {
	A,
	B,
	C,
}

const BARRIER_REFERENCE_Y := 1.27
const DECK_THICKNESS_M := 0.12
const CASE_FLOOR_YS: Array[float] = [1.17, 0.82, 0.57]
const CASE_ARGUMENT_PREFIX := "--receiving-geometry-case="

@export_enum("A", "B", "C") var comparison_case: int = GeometryCase.B:
	set(value):
		comparison_case = clampi(value, GeometryCase.A, GeometryCase.C)
		_refresh_geometry()


func _ready() -> void:
	_apply_runtime_case_override(OS.get_cmdline_user_args())
	_refresh_geometry()


func _apply_runtime_case_override(arguments: PackedStringArray) -> void:
	for argument: String in arguments:
		if not argument.begins_with(CASE_ARGUMENT_PREFIX):
			continue
		var requested := argument.trim_prefix(CASE_ARGUMENT_PREFIX).to_upper()
		match requested:
			"A":
				comparison_case = GeometryCase.A
			"B":
				comparison_case = GeometryCase.B
			"C":
				comparison_case = GeometryCase.C
		return


func _refresh_geometry() -> void:
	var floor_y := CASE_FLOOR_YS[comparison_case]
	var deck := get_node_or_null("LiftDeck") as Node3D
	var proxy_load := get_node_or_null("ProxyLoad") as Node3D
	var envelope := get_node_or_null("PileEnvelopePreview") as Node3D
	var guides := get_node_or_null("Guides") as Node3D
	var barrier_panel := get_node_or_null("BarrierOcclusionMockup/Panel") as Node3D

	if deck != null:
		deck.position.y = floor_y - DECK_THICKNESS_M * 0.5
	if proxy_load != null:
		proxy_load.position.y = floor_y
	if envelope != null:
		envelope.position.y = floor_y
	if guides != null:
		guides.position.y = floor_y
	if barrier_panel != null:
		barrier_panel.position.y = BARRIER_REFERENCE_Y * 0.5
