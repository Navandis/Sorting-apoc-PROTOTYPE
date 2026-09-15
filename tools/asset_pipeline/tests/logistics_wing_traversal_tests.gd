extends SceneTree

const TRAVERSAL_SCENE_PATH := "res://greybox/logistics_wing/wing_traversal.tscn"
const TRAVERSAL_SCRIPT_PATH := "res://greybox/logistics_wing/wing_traversal.gd"

const REQUIRED_ROUTES := [
	"receiving_to_sorting",
	"receiving_to_storage_near",
	"sorting_to_medical",
	"sorting_to_kitchen",
	"sorting_to_workshop",
	"sorting_to_salvager",
	"sorting_to_incinerator",
	"sorting_to_bunker_ops",
	"sorting_to_blocked_continuation",
	"sorting_to_deeper_closure",
	"gallery_c_to_d_secondary",
	"gallery_c_to_d_via_spine",
	"storage_near_to_gallery_a",
	"storage_near_to_gallery_b",
	"storage_near_to_gallery_c",
	"storage_near_to_gallery_d",
	"storage_near_to_gallery_e",
]

const REQUIRED_BOUNDARIES := [
	"freight_barrier",
	"medical_frontage",
	"kitchen_frontage",
	"workshop_frontage",
	"blocked_continuation",
	"bunker_ops_frontage",
	"deeper_settlement_closure",
]

var _failures := 0


func _init() -> void:
	_test_traversal_scene_contract()
	_test_route_and_boundary_manifest()
	if _failures > 0:
		push_error("FAIL: logistics wing traversal contract (%d checks)" % _failures)
		quit(1)
		return
	print("PASS: logistics wing traversal contract")
	quit(0)


func _test_traversal_scene_contract() -> void:
	if not _check(ResourceLoader.exists(TRAVERSAL_SCRIPT_PATH), "traversal runner exists"):
		return
	_check(ResourceLoader.exists(TRAVERSAL_SCENE_PATH), "traversal scene exists")
	var script := load(TRAVERSAL_SCRIPT_PATH) as Script
	if not _check(script != null, "traversal runner loads"):
		return
	var runner := Node3D.new()
	runner.set_script(script)
	_check(not runner.call("should_run", PackedStringArray()), "traversal stays idle without explicit flag")
	_check(runner.call("should_run", PackedStringArray(["--traversal-evidence"])), "traversal flag explicitly enables evidence run")
	_check(String(runner.call("get_output_path")) == "res://reports/logistics_wing/greybox/traversal_results.json", "traversal output path is stable")
	runner.free()

	if ResourceLoader.exists(TRAVERSAL_SCENE_PATH):
		var packed := load(TRAVERSAL_SCENE_PATH) as PackedScene
		if _check(packed != null, "traversal scene loads"):
			var scene := packed.instantiate() as Node3D
			if _check(scene != null, "traversal scene instantiates"):
				var review := scene.get_node_or_null("Review")
				_check(review != null and review.scene_file_path == "res://greybox/logistics_wing/wing_review.tscn", "traversal instances the dedicated review scene")
				_check(scene.get_node_or_null("Review/ReviewPlayer") is CharacterBody3D, "traversal drives the actual review player")
				scene.free()


func _test_route_and_boundary_manifest() -> void:
	if not ResourceLoader.exists(TRAVERSAL_SCRIPT_PATH):
		return
	var runner := Node3D.new()
	runner.set_script(load(TRAVERSAL_SCRIPT_PATH) as Script)
	var routes := runner.call("get_route_records") as Array
	_check(routes.size() == REQUIRED_ROUTES.size(), "all required direct routes are declared")
	var route_names: Array[String] = []
	for record: Dictionary in routes:
		var route_name := String(record.get("name", ""))
		route_names.append(route_name)
		_check(not String(record.get("start_anchor", "")).is_empty(), "route start anchor is explicit: " + route_name)
		_check(not String(record.get("end_anchor", "")).is_empty(), "route end anchor is explicit: " + route_name)
		var waypoints := record.get("waypoints", PackedVector3Array()) as PackedVector3Array
		_check(not waypoints.is_empty(), "route has hand-authored waypoints: " + route_name)
	for route_name: String in REQUIRED_ROUTES:
		_check(route_names.has(route_name), "required route exists: " + route_name)
	var c_to_d_secondary := _find_record(routes, "gallery_c_to_d_secondary")
	var c_to_d_spine := _find_record(routes, "gallery_c_to_d_via_spine")
	_check(
		c_to_d_secondary.get("start_anchor", "") == c_to_d_spine.get("start_anchor", "")
		and c_to_d_secondary.get("end_anchor", "") == c_to_d_spine.get("end_anchor", ""),
		"C-to-D alternatives use the same named endpoints"
	)

	var boundaries := runner.call("get_boundary_records") as Array
	_check(boundaries.size() == REQUIRED_BOUNDARIES.size(), "all required fixed boundaries are declared")
	var boundary_names: Array[String] = []
	for record: Dictionary in boundaries:
		var boundary_name := String(record.get("name", ""))
		boundary_names.append(boundary_name)
		_check(record.get("start", null) is Vector3, "boundary start is explicit: " + boundary_name)
		_check(record.get("direction", null) is Vector3, "boundary drive direction is explicit: " + boundary_name)
	for boundary_name: String in REQUIRED_BOUNDARIES:
		_check(boundary_names.has(boundary_name), "required boundary exists: " + boundary_name)
	runner.free()


func _find_record(records: Array, record_name: String) -> Dictionary:
	for record: Dictionary in records:
		if String(record.get("name", "")) == record_name:
			return record
	return {}


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failures += 1
	push_error("FAILED: " + message)
	return false
