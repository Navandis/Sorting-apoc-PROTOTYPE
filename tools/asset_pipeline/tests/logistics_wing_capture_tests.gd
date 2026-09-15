extends SceneTree

const REVIEW_SCENE_PATH := "res://greybox/logistics_wing/wing_review.tscn"
const CAPTURE_SCENE_PATH := "res://greybox/logistics_wing/wing_capture.tscn"
const CAPTURE_SCRIPT_PATH := "res://greybox/logistics_wing/wing_capture.gd"

var _failures := 0


func _init() -> void:
	_test_review_scene_is_isolated_and_runnable()
	_test_capture_manifest_and_image_contract()
	if _failures > 0:
		push_error("FAIL: logistics wing capture contract (%d checks)" % _failures)
		quit(1)
		return
	print("PASS: logistics wing capture contract")
	quit(0)


# Catches accidental reuse of the test room or rejected Receiving scene and a
# review scene that omits the actual player or neutral review lighting.
func _test_review_scene_is_isolated_and_runnable() -> void:
	if not _check(ResourceLoader.exists(REVIEW_SCENE_PATH), "wing review scene exists"):
		return
	var packed := load(REVIEW_SCENE_PATH) as PackedScene
	if not _check(packed != null, "wing review scene loads"):
		return
	var review := packed.instantiate() as Node3D
	if not _check(review != null, "wing review scene instantiates"):
		return
	var geometry := review.get_node_or_null("Geometry")
	var player := review.get_node_or_null("ReviewPlayer")
	_check(geometry != null and geometry.scene_file_path == "res://greybox/logistics_wing/wing_geometry.tscn", "review instances only dedicated wing geometry")
	_check(player is CharacterBody3D and player.scene_file_path == "res://greybox/logistics_wing/review_player.tscn", "review instances the actual review player")
	_check(_count_nodes_of_type(review, CharacterBody3D) == 1, "review contains exactly one player body")
	_check(_count_nodes_of_type(review, Camera3D) == 1, "review contains exactly one normal gameplay camera")
	_check(review.get_node_or_null("ReviewEnvironment") is WorldEnvironment, "review has neutral WorldEnvironment")
	_check(review.get_node_or_null("KeyLight") is DirectionalLight3D, "review has directional key light")
	_check(review.get_node_or_null("FillLights") is Node3D, "review has local fill-light root")
	_check(review.get_node_or_null("OrientationAids") is Node3D, "review has diagnostic orientation aids")
	_check(_find_scene_path(review, "res://main.tscn") == null, "review does not instance main.tscn")
	_check(_find_scene_path(review, "res://receiving/freight_bay_prototype.tscn") == null, "review does not instance rejected Receiving")
	review.free()


# Catches capture drift that hides roofs in saved play, changes normal FOV,
# omits coverage, captures without explicit intent, or makes unreadable sheets.
func _test_capture_manifest_and_image_contract() -> void:
	if not _check(ResourceLoader.exists(CAPTURE_SCRIPT_PATH), "capture helper exists"):
		return
	_check(ResourceLoader.exists(CAPTURE_SCENE_PATH), "capture scene exists")
	var script := load(CAPTURE_SCRIPT_PATH) as Script
	if not _check(script != null, "capture helper loads"):
		return
	var capture := Node3D.new()
	capture.set_script(script)
	_check(not capture.call("should_capture", PackedStringArray()), "capture stays idle without --capture")
	_check(capture.call("should_capture", PackedStringArray(["--capture"])), "--capture explicitly enables evidence generation")
	_check(String(capture.call("get_output_directory")) == "res://reports/logistics_wing/greybox", "capture output directory is stable")
	var records := capture.call("get_view_records") as Array
	_check(records.size() == 18, "capture manifest has all 18 required views")
	var seen_basenames: Dictionary = {}
	for index: int in records.size():
		var record := records[index] as Dictionary
		var basename := String(record.get("basename", ""))
		_check(not basename.is_empty() and not seen_basenames.has(basename), "capture basename is non-empty and unique: " + basename)
		seen_basenames[basename] = true
		_check(record.get("position", null) is Vector3, "capture position is explicit: " + basename)
		_check(record.get("target", null) is Vector3, "capture target is explicit: " + basename)
		if index == 0:
			_check(record.get("overview", false) == true, "first capture is the debug overview")
			_check(record.get("ceiling_on", true) == false, "debug overview alone hides roof visuals")
		else:
			_check(record.get("overview", false) == false, "normal capture is not marked overview: " + basename)
			_check(record.get("ceiling_on", false) == true, "normal capture keeps ceilings on: " + basename)
			_check(is_equal_approx(float(record.get("fov", 0.0)), 75.0), "normal capture preserves 75 degree FOV: " + basename)
	var basenames := capture.call("get_capture_basenames") as Array
	_check(basenames.size() == 20, "18 full views plus two contact sheets are declared")
	_check(basenames.has("overview_debug_topdown.png"), "debug overview basename is declared")
	_check(basenames.has("contact_sheet_01.png") and basenames.has("contact_sheet_02.png"), "both contact sheets are declared")

	var source := Image.create_empty(320, 180, false, Image.FORMAT_RGBA8)
	source.fill(Color.CORNFLOWER_BLUE)
	var normalized := capture.call("normalize_capture_image", source) as Image
	_check(normalized.get_size() == Vector2i(1920, 1080), "full captures normalize to 1920x1080")
	var fixtures: Array[Image] = []
	for index: int in 18:
		var fixture := Image.create_empty(64, 36, false, Image.FORMAT_RGBA8)
		fixture.fill(Color.from_hsv(float(index) / 18.0, 0.65, 0.85))
		fixtures.append(fixture)
	var sheets := capture.call("make_contact_sheets", fixtures) as Array
	_check(sheets.size() == 2, "18 captures produce two contact sheets")
	for sheet: Image in sheets:
		_check(sheet.get_size() == Vector2i(1920, 1080), "contact sheet is readable at 1920x1080")
	capture.free()


func _find_scene_path(node: Node, expected_path: String) -> Node:
	if node.scene_file_path == expected_path:
		return node
	for child in node.get_children():
		var found := _find_scene_path(child, expected_path)
		if found != null:
			return found
	return null


func _count_nodes_of_type(node: Node, expected_type: Variant) -> int:
	var count := 1 if is_instance_of(node, expected_type) else 0
	for child in node.get_children():
		count += _count_nodes_of_type(child, expected_type)
	return count


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failures += 1
	push_error("FAILED: " + message)
	return false
