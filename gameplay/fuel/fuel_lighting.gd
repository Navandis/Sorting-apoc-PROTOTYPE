extends RefCounted

const WORK_LIGHTS := [
	"Environment/ReceivingLighting/GeneralFixtures/G1/Light",
	"Environment/ReceivingLighting/GeneralFixtures/G2/Light",
	"Environment/ReceivingLighting/TaskFixtures/T1/Light",
	"Environment/ReceivingLighting/TaskFixtures/T2/Light",
	"Environment/ReceivingLighting/ApronCeilingBounce",
	"Environment/FillLights/StorageWest",
	"Environment/FillLights/StorageEast",
	"Environment/FillLights/MedicalKitchen",
	"Environment/FillLights/MedicalTuning",
	"Environment/FillLights/Workshop",
	"Environment/FillLights/Deeper",
	"Environment/FillLights/East",
]

var _authored: Dictionary = {}
var _reflections: Node
var _multiplier := 1.0

func bind(wing: Node) -> bool:
	_reflections = wing.get_node_or_null("Environment/ReceivingReflections")
	for path: String in WORK_LIGHTS:
		var light := wing.get_node_or_null(path) as Light3D
		if light == null:
			push_error("Missing Fuel working light: " + path)
			return false
		_authored[light] = light.light_energy
	return true

func apply(multiplier: float) -> void:
	if multiplier == _multiplier:
		return
	_multiplier = multiplier
	for light: Light3D in _authored:
		light.light_energy = _authored[light] * multiplier
	if is_instance_valid(_reflections):
		_reflections.request_refresh()
