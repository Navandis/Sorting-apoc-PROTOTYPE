extends SceneTree

const REVIEW_SCENE_PATH := "res://greybox/logistics_wing/wing_review.tscn"
const CAPTURE_SCENE_PATH := "res://greybox/logistics_wing/wing_capture.tscn"
const CAPTURE_SCRIPT_PATH := "res://greybox/logistics_wing/wing_capture.gd"
const REQUIRED_MATCHED_BASENAMES := [
	"overview_debug_topdown.png",
	"receiving_freight_aperture.png", "receiving_apron.png",
	"receiving_backlog_threshold.png", "dispatch_annex.png",
	"backlog_sorting_approach.png", "backlog_sorting_threshold.png",
	"backlog_sorting_departure.png", "sorting_table.png",
	"sorting_desk_freight_aperture.png", "sorting_storage_turn.png",
	"storage_ab_junction.png", "gallery_a_northwest.png",
	"storage_cd_south.png", "storage_cd_folded_c.png",
	"storage_cd_folded_roofoff.png", "storage_network.png",
	"gallery_e_projection.png", "medical_approach.png",
	"medical_plan_roofoff.png", "medical_entrance.png",
	"medical_east_wall.png", "kitchen_b_east.png",
	"kitchen_turn.png", "kitchen_service.png",
	"workshop_approach.png", "workshop_service.png",
	"workshop_salvager_approach_reveal.png", "salvager_local.png",
	"salvager_rear_clearance.png",
	"deeper_storage_sightline.png",
	"deeper_dogleg.png", "incinerator.png",
	"bunker_ops_landing.png", "bunker_ops_door.png",
	"ceiling_transition_approach.png", "ceiling_transition_threshold.png",
	"ceiling_transition_departure.png",
]
const ROOF_OFF_DIAGNOSTIC_BASENAMES := [
	"storage_cd_folded_roofoff.png",
	"medical_plan_roofoff.png",
	"salvager_rear_clearance.png",
]

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
	var shared_medical_kitchen_light := review.get_node_or_null("FillLights/MedicalKitchen") as OmniLight3D
	_check(shared_medical_kitchen_light != null and shared_medical_kitchen_light.position == Vector3(17.0, 2.7, -20.0), "shared Medical/Kitchen light stays fixed for Kitchen coverage")
	var medical_tuning_light := review.get_node_or_null("FillLights/MedicalTuning") as OmniLight3D
	_check(medical_tuning_light != null and medical_tuning_light.position == Vector3(4.3, 2.7, -26.5), "moved Medical room gets a local neutral review fill")
	var medical_label := review.get_node_or_null("OrientationAids/MedicalLabel") as Label3D
	_check(medical_label != null and medical_label.position == Vector3(4.3, 2.5, -26.5), "Medical label translates with the unchanged-size room")
	var medical_north_label := review.get_node_or_null("OrientationAids/MedicalNorthLabel") as Label3D
	_check(medical_north_label != null and medical_north_label.position == Vector3(2.0, 0.1, -29.0), "Medical plan evidence has an inset local north label")
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
	_check(String(capture.call("get_output_directory")) == "res://reports/logistics_wing/greybox/revision_04", "Medical tuning capture output is isolated from historic evidence")
	var records := capture.call("get_view_records") as Array
	_check(records.size() == 38, "capture manifest retains the wing set and adds focused Medical views")
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
		elif basename in ROOF_OFF_DIAGNOSTIC_BASENAMES:
			_check(record.get("overview", true) == false, "local roof-off diagnostic omits global orientation aids: " + basename)
			_check(record.get("ceiling_on", true) == false, "local diagnostic hides roof visuals: " + basename)
			_check(is_equal_approx(float(record.get("fov", 0.0)), 50.0), "local diagnostic preserves 50 degree FOV: " + basename)
		else:
			_check(record.get("overview", false) == false, "normal capture is not marked overview: " + basename)
			_check(record.get("ceiling_on", false) == true, "normal capture keeps ceilings on: " + basename)
			_check(is_equal_approx(float(record.get("fov", 0.0)), 75.0), "normal capture preserves 75 degree FOV: " + basename)
	for basename: String in REQUIRED_MATCHED_BASENAMES:
		_check(seen_basenames.has(basename), "matched revision view is declared: " + basename)
	_check(not seen_basenames.has("workshop_blocked.png"), "removed Workshop stub has no capture")
	var synthetic_bounds := AABB(Vector3(-44.15, -0.3, -30.15), Vector3(110.475, 4.8, 58.8))
	var framed_overview := capture.call("frame_overview_record", records[0] as Dictionary, synthetic_bounds) as Dictionary
	_check((framed_overview["target"] as Vector3).is_equal_approx(Vector3(11.0875, 0.0, -0.75)), "overview targets the computed geometry centre")
	_check(is_equal_approx((framed_overview["position"] as Vector3).x, 11.0875) and is_equal_approx((framed_overview["position"] as Vector3).z, -0.75), "overview camera is centred over computed current extents")
	_check((framed_overview["position"] as Vector3).y > synthetic_bounds.end.y, "overview height is derived above the current geometry bounds")
	var salvager_reveal := _find_record(records, "workshop_salvager_approach_reveal.png")
	_check(salvager_reveal.get("position", Vector3.ZERO) == Vector3(-8.0, 1.7162851, 20.5), "Salvager reveal starts on the Workshop side of the spur opening")
	_check(salvager_reveal.get("target", Vector3.ZERO) == Vector3(7.0, 1.4, 25.0), "Salvager reveal aims at the visible near-east machine face instead of through the cross-corridor wall")
	var kitchen_turn := _find_record(records, "kitchen_turn.png")
	_check(kitchen_turn.get("position", Vector3.ZERO) == Vector3(25.0, 1.7162851, -7.8), "Kitchen turn view starts inside the translated north leg")
	_check(kitchen_turn.get("target", Vector3.ZERO) == Vector3(25.0, 1.4, -13.5), "Kitchen turn view looks cleanly down the translated north leg")
	var c_folded := _find_record(records, "storage_cd_folded_c.png")
	_check(c_folded.get("position", Vector3.ZERO) == Vector3(0.0, 1.7162851, 13.7), "C-side folded-perimeter view starts inside Gallery C")
	_check(c_folded.get("target", Vector3.ZERO) == Vector3(3.4, 1.4, 10.8), "C-side folded-perimeter view targets the inset cap and sole opening")
	var c_folded_roofoff := _find_record(records, "storage_cd_folded_roofoff.png")
	_check(c_folded_roofoff.get("position", Vector3.ZERO) == Vector3(4.0, 15.0, 19.0), "C/D roof-off audit is local to the folded perimeter")
	_check(c_folded_roofoff.get("target", Vector3.ZERO) == Vector3(4.0, 0.0, 14.0), "C/D roof-off audit centres the full folded wall chain")
	var salvager_rear := _find_record(records, "salvager_rear_clearance.png")
	_check(salvager_rear.get("position", Vector3.ZERO) == Vector3(10.0, 10.0, 31.0), "Salvager rear-clearance audit is elevated outside the enclosure")
	_check(salvager_rear.get("target", Vector3.ZERO) == Vector3(5.0, 0.8, 26.5), "Salvager rear-clearance audit centres the machine and tightened rear wall")
	var medical_approach := _find_record(records, "medical_approach.png")
	_check(medical_approach.get("position", Vector3.ZERO) == Vector3(6.75, 1.7162851, -11.0), "Medical approach preserves the Storage-side camera position")
	_check(medical_approach.get("target", Vector3.ZERO) == Vector3(7.0, 1.4, -24.5), "Medical approach looks through the doubled exclusive corridor")
	var medical_plan := _find_record(records, "medical_plan_roofoff.png")
	_check(medical_plan.get("position", Vector3.ZERO) == Vector3(4.3, 24.0, -21.5), "Medical roof-off plan is centred high enough to include the complete tuned footprint")
	_check(medical_plan.get("target", Vector3.ZERO) == Vector3(4.3, 0.0, -21.5), "Medical roof-off plan points straight at the tuned footprint")
	_check(medical_plan.get("show_orientation_aids", false) == true, "Medical roof-off plan enables its local north label")
	var wall_top_vertical_span := 2.0 * (24.0 - 3.4) * tan(deg_to_rad(25.0))
	_check(wall_top_vertical_span > 17.0, "Medical roof-off plan frames the full 17 m footprint above wall-top height")
	var medical_entrance := _find_record(records, "medical_entrance.png")
	var has_camera_up := _check(capture.has_method("get_camera_up_vector"), "capture exposes a safe camera-up calculation")
	if has_camera_up:
		_check(capture.call("get_camera_up_vector", medical_plan) == Vector3(0, 0, -1), "vertical Medical plan view uses a non-collinear north-up vector")
		_check(capture.call("get_camera_up_vector", medical_entrance) == Vector3.UP, "ordinary first-person views retain world-up orientation")
	_check(medical_entrance.get("position", Vector3.ZERO) == Vector3(7.0, 1.7162851, -21.0), "Medical entrance view arrives on the unchanged corridor centreline")
	_check(medical_entrance.get("target", Vector3.ZERO) == Vector3(4.3, 1.4, -26.5), "Medical entrance view turns into the west-expanded room")
	var medical_east_wall := _find_record(records, "medical_east_wall.png")
	_check(medical_east_wall.get("position", Vector3.ZERO) == Vector3(2.0, 1.7162851, -26.5), "Medical east-wall view begins on the west side of the moved room")
	_check(medical_east_wall.get("target", Vector3.ZERO) == Vector3(7.0, 1.4, -18.5), "Medical east-wall view looks through the entrance along the aligned corridor side")
	var incinerator := _find_record(records, "incinerator.png")
	_check(incinerator.get("position", Vector3.ZERO) == Vector3(36.5, 1.7162851, 7.5), "Incinerator view moves east with the complete spur")
	var workshop_service := _find_record(records, "workshop_service.png")
	_check(workshop_service.get("position", Vector3.ZERO) == Vector3(-12.0, 1.7162851, 18.0), "Workshop service view stays inside the retained room")
	_check(workshop_service.get("target", Vector3.ZERO) == Vector3(-12.0, 1.4, 24.8), "Workshop service view proves the solid south perimeter")
	var desk_view := _find_record(records, "sorting_desk_freight_aperture.png")
	_check(desk_view.get("position", Vector3.ZERO) == Vector3(-10.0, 1.7162851, -4.4), "freight sightline evidence uses the real Sorting work position")
	var basenames := capture.call("get_capture_basenames") as Array
	_check(basenames.size() == 42, "38 full views plus four contact sheets are declared")
	_check(basenames.has("overview_debug_topdown.png"), "debug overview basename is declared")
	_check(basenames.has("contact_sheet_01.png") and basenames.has("contact_sheet_02.png") and basenames.has("contact_sheet_03.png") and basenames.has("contact_sheet_04.png"), "all four contact sheets are declared")
	var has_manifest_fields := _check(capture.has_method("get_manifest_static_fields"), "capture exposes revision and hash manifest fields")
	if has_manifest_fields:
		var manifest_fields := capture.call("get_manifest_static_fields") as Dictionary
		_check(manifest_fields.get("layout_revision", "") == "logistics-wing-greybox-medical-tuning-revision-04", "manifest identifies Medical tuning revision four")
		_check(manifest_fields.get("source_hash_paths", PackedStringArray()).size() == 8, "manifest hashes all five wing sources and three focused test sources")
		_check(not String(manifest_fields.get("final_commit_relation", "")).is_empty(), "manifest states its relation to the final commit")

	var source := Image.create_empty(320, 180, false, Image.FORMAT_RGBA8)
	source.fill(Color.CORNFLOWER_BLUE)
	var normalized := capture.call("normalize_capture_image", source) as Image
	_check(normalized.get_size() == Vector2i(1920, 1080), "full captures normalize to 1920x1080")
	var has_contact_layout := _check(capture.has_method("get_contact_tile_layout"), "capture exposes deterministic contact layout")
	var has_aspect_fit := _check(capture.has_method("fit_capture_into_contact_image"), "capture exposes aspect-preserving image fit")
	if has_contact_layout:
		var layout := capture.call("get_contact_tile_layout") as Dictionary
		_check(layout.get("tile_size") == Vector2i(480, 360), "contact tile remains 480x360")
		_check(layout.get("image_size") == Vector2i(480, 270), "contact image region preserves 16:9")
		_check(layout.get("caption_origin_y") == 270, "caption begins outside the image")
		_check(layout.get("caption_height") == 90, "caption has a separate 90px band")
	if has_aspect_fit:
		_check(capture.call("fit_capture_into_contact_image", Vector2i(1920, 1080)) == Rect2i(0, 0, 480, 270), "16:9 capture fills only the 16:9 image region")
		_check(capture.call("fit_capture_into_contact_image", Vector2i(800, 600)) == Rect2i(60, 0, 360, 270), "non-16:9 source is letterboxed without distortion")
	capture.free()


func _find_scene_path(node: Node, expected_path: String) -> Node:
	if node.scene_file_path == expected_path:
		return node
	for child in node.get_children():
		var found := _find_scene_path(child, expected_path)
		if found != null:
			return found
	return null


func _find_record(records: Array, basename: String) -> Dictionary:
	for record: Dictionary in records:
		if String(record.get("basename", "")) == basename:
			return record
	return {}


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
