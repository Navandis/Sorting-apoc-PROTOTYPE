extends SceneTree
# Registry and raw declarations must be checked before any PackedScene load can
# mask a duplicate UID by registering the canonical scene again.
const MAIN_UID := "uid://bljf1nlhijej"
const MAIN_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
var failed := false

func _init() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> bool:
	if not ok:
		failed = true
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	var configured := String(ProjectSettings.get_setting("application/run/main_scene", ""))
	check(configured == MAIN_UID, "configured entry retains intended production UID")
	var uid := ResourceUID.text_to_id(configured)
	var registered := uid != ResourceUID.INVALID_ID and ResourceUID.has_id(uid)
	check(registered, "main UID registered before scene load")
	var resolved := ResourceUID.get_id_path(uid) if registered else ""
	print("STARTUP_REGISTRY configured=", configured, " resolved=", resolved)
	check(resolved == MAIN_PATH, "configured UID resolves to canonical production before load")
	var declarations: Array[String] = []
	collect_main_declarations("res://", declarations)
	declarations.sort()
	print("STARTUP_DECLARATIONS ", declarations)
	check(declarations == [MAIN_PATH], "only canonical scene declares main UID in scanned project")
	if failed:
		finish()
		return
	# Load the configured entry, never an explicit canonical control to hide it.
	var packed := load(configured) as PackedScene
	if not check(packed != null, "configured entry loads as PackedScene"):
		finish()
		return
	var wing := packed.instantiate() as Node3D
	root.add_child(wing)
	await physics_frame
	await physics_frame
	check(wing.scene_file_path == MAIN_PATH and wing.name == &"WingGameplay", "configured entry instantiates current production root")
	check(root.find_children("WingGameplay", "Node3D", true, false).size() == 1, "one production wing")
	var env := wing.get_node("Environment")
	check(env.scene_file_path == "res://gameplay/logistics_wing/wing_environment.tscn", "current shared environment")
	check(env.get_node("ReceivingStructuralShell").position.is_equal_approx(Vector3(-36, 0, 0)), "compact shell placement")
	check(wing.get_node("ReceivingLiftInstallation").transform.is_equal_approx(Transform3D(Basis.IDENTITY, Vector3(3, 0, 0))), "translated lift ensemble")
	var runtime := wing.get_node("ReceivingRuntime")
	check(runtime.position.is_equal_approx(Vector3(-37.41487, .82, 0)), "current Receiving runtime placement")
	check(runtime.get_node("ReceivingManager").get_active_batch() == null, "ordinary startup has no synthetic cargo")
	check(wing.get_functional_surfaces().size() == 16, "sixteen ordinary surfaces")
	var greybox := env.get_node("Greybox")
	check(greybox.get_node("Districts/Receiving/Floor_ReceivingApron/StaticBody3D/CollisionShape3D").shape.size.is_equal_approx(Vector3(7.5, .3, 8)), "current nominal apron")
	check(greybox.get_node("Districts/Receiving/Floor_DispatchAnnex/StaticBody3D/CollisionShape3D").shape.size.is_equal_approx(Vector3(6.5, .3, 3.5)), "current nominal Dispatch")
	var opening = env.get_node("ReceivingStructuralShell/ReceivingEastOpeningWall").piece_spec
	check(is_equal_approx(opening.opening_width_m, 2.84) and is_equal_approx(opening.opening_height_m, 3.4), "current centred Backlog opening")
	var lighting := env.get_node("ReceivingLighting")
	check(lighting.scene_file_path == "res://gameplay/logistics_wing/receiving/receiving_lighting.tscn" and lighting.find_children("*", "SpotLight3D", true, false).size() == 4, "current four-spot Receiving lighting")
	wing.free()
	finish()

func collect_main_declarations(directory: String, declarations: Array[String]) -> void:
	if FileAccess.file_exists(directory.path_join(".gdignore")):
		return
	var access := DirAccess.open(directory)
	if access == null:
		check(false, "can inspect scanned directory " + directory)
		return
	access.list_dir_begin()
	var name := access.get_next()
	while not name.is_empty():
		var path := directory.path_join(name)
		if access.current_is_dir():
			if not name.begins_with("."):
				collect_main_declarations(path, declarations)
		elif name.get_extension().to_lower() == "tscn":
			var file := FileAccess.open(path, FileAccess.READ)
			if file != null:
				var header := file.get_line().strip_edges()
				if header.begins_with("[gd_scene ") and header.contains('uid="' + MAIN_UID + '"'):
					declarations.append(path)
		name = access.get_next()
	access.list_dir_end()

func finish() -> void:
	print("wing_startup_parity_tests: ", "FAIL" if failed else "PASS")
	quit(1 if failed else 0)
