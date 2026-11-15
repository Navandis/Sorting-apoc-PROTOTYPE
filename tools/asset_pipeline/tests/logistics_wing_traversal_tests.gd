extends SceneTree

const TRAVERSAL_SCENE_PATH := "res://greybox/logistics_wing/wing_traversal.tscn"
const TRAVERSAL_SCRIPT_PATH := "res://greybox/logistics_wing/wing_traversal.gd"

const REQUIRED_ROUTES := [
	"receiving_to_sorting",
	"receiving_to_dispatch",
	"receiving_to_storage_near",
	"sorting_to_shared_ab_junction",
	"shared_junction_to_gallery_a_east",
	"shared_junction_to_gallery_b_west",
	"shared_junction_to_medical_anteroom",
	"medical_anteroom_to_shared_junction",
	"gallery_b_to_kitchen_service",
	"sorting_to_workshop_service",
	"sorting_to_salvager",
	"salvager_to_sorting",
	"sorting_to_incinerator",
	"sorting_to_bunker_ops",
	"bunker_ops_to_storage_near",
	"sorting_to_deeper_closure",
	"gallery_c_to_d_secondary",
	"gallery_c_to_d_via_spine",
	"storage_near_to_gallery_a",
	"storage_near_to_gallery_b",
	"storage_near_to_gallery_c",
	"storage_near_to_gallery_d",
]

const REQUIRED_BOUNDARIES := [
	"freight_barrier",
	"medical_inner_boundary",
	"kitchen_inner_boundary",
	"workshop_inner_boundary",
	"workshop_south_wall",
	"salvager_machine_end",
	"bunker_ops_inner_boundary",
	"deeper_settlement_door",
	"kitchen_south_wall",
	"ops_link_north",
	"shared_junction_return",
	"sorting_gallery_a_shared_wall",
	"gallery_cd_folded_outer_return",
	"ops_link_south",
	"incinerator_machine_end",
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
	_check(String(runner.call("get_output_path")) == "res://reports/logistics_wing/greybox/compact_layout_slice_9/traversal_results.json", "Compact layout traversal output is isolated from historic evidence")
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
	_check(not route_names.has("sorting_to_blocked_continuation"), "removed Workshop stub has no traversal route")
	var c_to_d_secondary := _find_record(routes, "gallery_c_to_d_secondary")
	var c_to_d_spine := _find_record(routes, "gallery_c_to_d_via_spine")
	_check(
		c_to_d_secondary.get("start_anchor", "") == c_to_d_spine.get("start_anchor", "")
		and c_to_d_secondary.get("end_anchor", "") == c_to_d_spine.get("end_anchor", ""),
		"C-to-D alternatives use the same named endpoints"
	)
	var medical_route := _find_record(routes, "shared_junction_to_medical_anteroom")
	var medical_waypoints := medical_route.get("waypoints", PackedVector3Array()) as PackedVector3Array
	_check(medical_waypoints.has(Vector3(5.0, 0.05, -12.5)), "Medical traversal stays on the centreline of the shorter Medical corridor")
	_check(medical_waypoints.has(Vector3(5.0, 0.05, -15.5)), "Medical traversal enters the room before turning west")
	_check(medical_waypoints.has(Vector3(2.3, 0.05, -18.0)), "Medical traversal reaches the translated anteroom centre")
	for waypoint: Vector3 in medical_waypoints:
		_check(not (waypoint.x < 3.8 and waypoint.z > -14.5), "Medical traversal never cuts diagonally through the corridor west wall")
	var medical_return := _find_record(routes, "medical_anteroom_to_shared_junction")
	_check(medical_return.get("start_anchor", "") == "MedicalAnteroom", "Medical return replay starts in the moved room")
	_check(medical_return.get("end_anchor", "") == "SharedABJunction", "Medical return replay ends in Main Storage")
	var medical_return_waypoints := medical_return.get("waypoints", PackedVector3Array()) as PackedVector3Array
	_check(medical_return_waypoints.has(Vector3(5.0, 0.05, -15.5)), "Medical return replay exits through the south-east room entrance")
	_check(medical_return_waypoints.has(Vector3(5.0, 0.05, -11.5)), "Medical return replay follows the fixed corridor centreline")
	var kitchen_route := _find_record(routes, "gallery_b_to_kitchen_service")
	var kitchen_waypoints := kitchen_route.get("waypoints", PackedVector3Array()) as PackedVector3Array
	_check(kitchen_waypoints.has(Vector3(17.6, 0.05, -7.8)), "Kitchen traversal follows the straight centreline")
	_check(kitchen_waypoints.has(Vector3(23.535, 0.05, -6.15)), "Kitchen traversal reaches the rotated service room")
	var incinerator_route := _find_record(routes, "sorting_to_incinerator")
	var incinerator_waypoints := incinerator_route.get("waypoints", PackedVector3Array()) as PackedVector3Array
	_check(incinerator_waypoints.has(Vector3(21.5, 0.05, 6.6)) and incinerator_waypoints.has(Vector3(21.5, 0.05, 9.25)), "Incinerator route crosses both mouths on the new centreline")
	_check(incinerator_waypoints.has(Vector3(21.5, 0.05, 11.2)), "Incinerator route reaches the moved machine front")
	var ops_return := _find_record(routes, "bunker_ops_to_storage_near")
	var ops_waypoints := ops_return.get("waypoints", PackedVector3Array()) as PackedVector3Array
	_check(ops_return.get("start_anchor") == "BunkerOpsLanding" and ops_return.get("end_anchor") == "StorageNear", "Ops return joins Main Storage")
	_check(ops_waypoints.has(Vector3(27.5, 0.05, 2.30)), "Ops return passes through the center of the straight link")
	var ops_route := _find_record(routes, "sorting_to_bunker_ops")
	var ops_approach := ops_route.get("waypoints", PackedVector3Array()) as PackedVector3Array
	_check(ops_approach.has(Vector3(27.5, 0.05, 2.30)) and ops_approach.has(Vector3(32.5, 0.05, -0.70)), "Ops approach crosses the straight link to the moved interface stance")

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
	var north_rail := _find_record(boundaries, "ops_link_north")
	var south_rail := _find_record(boundaries, "ops_link_south")
	_check(north_rail.get("start") == Vector3(27.5, 0.05, 2.30) and north_rail.get("direction") == Vector3.FORWARD, "north probe drives into the link wall toward Kitchen")
	_check(south_rail.get("start") == north_rail.get("start") and south_rail.get("direction") == Vector3.BACK, "south probe drives into the link wall toward Incinerator")
	var ops_core := _find_record(boundaries, "bunker_ops_inner_boundary")
	_check(ops_core.get("start") == Vector3(32.5, 0.05, -0.70) and ops_core.get("direction") == Vector3.FORWARD, "Ops core probe drives into the moved north barrier")
	var settlement_door := _find_record(boundaries, "deeper_settlement_door")
	_check(settlement_door.get("start") == Vector3(33.65, 0.05, 1.0) and settlement_door.get("direction") == Vector3.RIGHT, "door probe drives into the separate east barrier")
	var machine := _find_record(boundaries, "incinerator_machine_end")
	_check(machine.get("start") == Vector3(21.5, 0.05, 9.9) and machine.get("direction") == Vector3.BACK, "machine probe drives into the relocated north face")
	var kitchen_boundary := _find_record(boundaries, "kitchen_inner_boundary")
	_check(kitchen_boundary.get("direction", Vector3.ZERO) == Vector3.RIGHT, "Kitchen boundary probe drives east into the rotated core wall")
	var kitchen_south := _find_record(boundaries, "kitchen_south_wall")
	_check(kitchen_south.get("direction", Vector3.ZERO) == Vector3.BACK, "Kitchen south probe drives toward the protected Storage hall")
	var cd_outer := _find_record(boundaries, "gallery_cd_folded_outer_return")
	_check(cd_outer.get("start", Vector3.ZERO) == Vector3(8.0, 0.05, 13.8), "C/D outer-return probe begins in playable Gallery D")
	_check(cd_outer.get("direction", Vector3.ZERO) == Vector3(-1, 0, 0), "C/D outer-return probe drives into the reconstructed west boundary")
	var workshop_boundary := _find_record(boundaries, "workshop_inner_boundary")
	_check(workshop_boundary.get("direction", Vector3.ZERO) == Vector3.RIGHT, "Workshop core probe drives into the east frontage")
	var medical_boundary := _find_record(boundaries, "medical_inner_boundary")
	_check(medical_boundary.get("start", Vector3.ZERO) == Vector3(2.3, 0.05, -19.5), "Medical inner-boundary probe starts from the moved safe-side anchor")
	_check(medical_boundary.get("limit", 0.0) == -21.20, "Medical inner-boundary probe targets the moved staffed-core edge")
	_check(not boundary_names.has("blocked_continuation"), "removed Workshop stub has no boundary probe")
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
