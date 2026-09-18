extends SceneTree

const CAPTURE_SCRIPT_PATH := "res://gameplay/logistics_wing/review/wing_gameplay_capture.gd"
const CAPTURE_SCENE_PATH := "res://gameplay/logistics_wing/review/wing_gameplay_capture.tscn"
const CENSUS_SCRIPT_PATH := "res://gameplay/logistics_wing/review/generate_wing_fixture_census.gd"
const F6_CAPTURE_SCRIPT_PATH := "res://gameplay/logistics_wing/review/wing_storage_debug_f6_capture.gd"
const F6_CAPTURE_SCENE_PATH := "res://gameplay/logistics_wing/review/wing_storage_debug_f6_capture.tscn"
const GAMEPLAY_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"

var _failed := false


func _init() -> void:
	if not _check(ResourceLoader.exists(CAPTURE_SCRIPT_PATH), "gameplay capture helper exists"):
		_finish()
		return
	_check(ResourceLoader.exists(CAPTURE_SCENE_PATH), "gameplay capture scene exists")
	_check(ResourceLoader.exists(CENSUS_SCRIPT_PATH), "fixture census generator exists")
	_check(ResourceLoader.exists(F6_CAPTURE_SCRIPT_PATH), "F6 capture helper exists")
	_check(ResourceLoader.exists(F6_CAPTURE_SCENE_PATH), "F6 capture scene exists")
	var script := load(CAPTURE_SCRIPT_PATH) as Script
	if not _check(script != null, "gameplay capture helper loads"):
		_finish()
		return
	var capture := Node3D.new()
	capture.set_script(script)
	_check(not capture.call("should_capture", PackedStringArray()), "capture stays idle without --capture")
	_check(capture.call("should_capture", PackedStringArray(["--capture"])), "--capture enables evidence generation")
	_check(
		String(capture.call("get_output_directory"))
		== "res://reports/logistics_wing/storage_bridge/initial",
		"capture output is isolated from accepted evidence"
	)
	var records := capture.call("get_view_records") as Array
	_check(records.size() == 11, "gameplay review declares eleven proportionate views")
	var basenames: Dictionary = {}
	var states: Dictionary = {}
	for value: Variant in records:
		var record := value as Dictionary
		var basename := String(record.get("basename", ""))
		_check(not basename.is_empty() and not basenames.has(basename), "capture basename is unique: %s" % basename)
		basenames[basename] = true
		states[String(record.get("state", ""))] = true
		_check(record.get("position") is Vector3, "capture position is explicit: %s" % basename)
		_check(record.get("target") is Vector3, "capture target is explicit: %s" % basename)
	_check(states.has("initial"), "capture includes initial editor-authored arrangement")
	_check(states.has("carrying"), "capture includes carrying/HUD state")
	_check(states.has("stacked"), "capture includes a real stored stack")
	_check(states.has("transferred"), "capture includes retrieval and cross-shelf transfer")
	_check(basenames.has("whole_wing_plan.png"), "capture includes whole-wing plan")
	_check(basenames.has("table_loot_coverage.png"), "capture includes table-loot coverage")
	_check(basenames.has("carrying_hud.png"), "capture includes carried HUD")
	_check(basenames.has("stored_stack_gallery_a.png"), "capture includes stored stack")
	_check(basenames.has("retrieval_transfer_gallery_b.png"), "capture includes transfer result")
	var fields := capture.call("get_manifest_static_fields") as Dictionary
	_check(fields.get("scene") == CAPTURE_SCENE_PATH, "manifest names capture scene")
	_check(fields.get("gameplay_scene") == GAMEPLAY_PATH, "manifest names continuing gameplay scene")
	_check((fields.get("source_hash_paths") as PackedStringArray).size() >= 8, "manifest hashes focused source set")
	capture.free()

	if ResourceLoader.exists(CAPTURE_SCENE_PATH):
		var packed := load(CAPTURE_SCENE_PATH) as PackedScene
		if _check(packed != null, "gameplay capture scene loads"):
			var scene := packed.instantiate()
			_check(_find_scene_path(scene, GAMEPLAY_PATH) != null, "capture instances the continuing gameplay scene")
			_check(_find_scene_path(scene, "res://main.tscn") == null, "capture does not instance original main")
			_check(_find_scene_path(scene, "res://greybox/logistics_wing/wing_review.tscn") == null, "capture does not replace neutral review")
			_check(_find_scene_path(scene, "res://receiving/freight_bay_prototype.tscn") == null, "capture excludes rejected Receiving")
			scene.free()
	_assert_f6_capture_contract()
	_finish()


func _assert_f6_capture_contract() -> void:
	if not ResourceLoader.exists(F6_CAPTURE_SCRIPT_PATH):
		return
	var script := load(F6_CAPTURE_SCRIPT_PATH) as Script
	if not _check(script != null, "F6 capture helper loads"):
		return
	var capture := Node3D.new()
	capture.set_script(script)
	_check(not capture.call("should_capture", PackedStringArray()), "F6 capture stays idle without --capture-f6")
	_check(
		capture.call("should_capture", PackedStringArray(["--capture-f6"])),
		"--capture-f6 enables focused evidence generation"
	)
	_check(
		String(capture.call("get_output_directory"))
		== "res://reports/logistics_wing/storage_bridge/f6_followup",
		"F6 capture output is isolated from initial evidence"
	)
	var records := capture.call("get_view_records") as Array
	_check(records.size() == 6, "F6 review declares three matched OFF/ON fixture pairs")
	var state_counts := {"off": 0, "on": 0}
	var fixture_counts := {"gallery_a": 0, "gallery_b": 0, "gallery_c": 0}
	for value: Variant in records:
		var record := value as Dictionary
		var state := String(record.get("state", ""))
		var fixture := String(record.get("fixture", ""))
		_check(state_counts.has(state), "F6 capture state is OFF or ON")
		_check(fixture_counts.has(fixture), "F6 capture fixture is one approved storage unit")
		if state_counts.has(state):
			state_counts[state] += 1
		if fixture_counts.has(fixture):
			fixture_counts[fixture] += 1
		_check(is_equal_approx(float(record.get("fov", 0.0)), 75.0), "F6 capture uses normal player FOV")
	_check(state_counts == {"off": 3, "on": 3}, "F6 capture balances OFF and ON states")
	_check(
		fixture_counts == {"gallery_a": 2, "gallery_b": 2, "gallery_c": 2},
		"F6 capture covers all three storage units equally"
	)
	var fields := capture.call("get_manifest_static_fields") as Dictionary
	_check(fields.get("scene") == F6_CAPTURE_SCENE_PATH, "F6 manifest names focused capture scene")
	_check(fields.get("gameplay_scene") == GAMEPLAY_PATH, "F6 manifest names continuing gameplay scene")
	_check((fields.get("source_hash_paths") as PackedStringArray).has(GAMEPLAY_PATH), "F6 manifest hashes saved gameplay scene")
	capture.free()

	if ResourceLoader.exists(F6_CAPTURE_SCENE_PATH):
		var packed := load(F6_CAPTURE_SCENE_PATH) as PackedScene
		if _check(packed != null, "F6 capture scene loads"):
			var scene := packed.instantiate()
			_check(_find_scene_path(scene, GAMEPLAY_PATH) != null, "F6 capture instances continuing gameplay scene")
			_check(_find_scene_path(scene, "res://main.tscn") == null, "F6 capture does not instance original main")
			_check(_find_scene_path(scene, "res://receiving/freight_bay_prototype.tscn") == null, "F6 capture excludes Receiving")
			scene.free()


func _find_scene_path(node: Node, expected_path: String) -> Node:
	if node.scene_file_path == expected_path:
		return node
	for child: Node in node.get_children():
		var found := _find_scene_path(child, expected_path)
		if found != null:
			return found
	return null


func _finish() -> void:
	if _failed:
		push_error("FAIL: wing gameplay capture tests")
		quit(1)
		return
	print("PASS: wing gameplay capture tests")
	quit(0)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false
