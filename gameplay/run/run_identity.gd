extends RefCounted

var run_id: String
var next_sequence := 1
var clock: RefCounted
var gameplay_seconds: float:
	get: return clock.elapsed if clock != null else 0.0
var scenario := "m2_medical_supply"

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
	scenario = state.scenario
