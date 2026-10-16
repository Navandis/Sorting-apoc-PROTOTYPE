extends RefCounted

var run_id: String
var next_sequence := 1
var gameplay_seconds := 0.0
var scenario := "m1_medical_v1"

func _init() -> void:
	run_id = Crypto.new().generate_random_bytes(12).hex_encode()

func allocate(kind: String) -> String:
	var identity := "%s:%s:%d" % [run_id, kind, next_sequence]
	next_sequence += 1
	return identity

func capture_state() -> Dictionary:
	return {"id": run_id, "next_sequence": next_sequence, "gameplay_seconds": gameplay_seconds, "scenario": scenario}

func restore_state(state: Dictionary) -> void:
	run_id = state.id
	next_sequence = state.next_sequence
	gameplay_seconds = state.gameplay_seconds
	scenario = state.scenario
