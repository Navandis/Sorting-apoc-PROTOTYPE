extends SceneTree

var _failed_checks: int = 0

const EXPECTED_ROOTS := {
	"res://assets/environment/furniture/storage/SM_ClothesCabinet.glb": "SM_ClothesCabinet",
	"res://assets/environment/furniture/work_surfaces/SM_Table.glb": "SM_Table",
	"res://assets/environment/furniture/storage/SM_MetalShelves.glb": "SM_MetalShelves",
	"res://assets/environment/furniture/storage/SM_ventilated_locker.glb": "SM_ventilated_locker",
}


func _init() -> void:
	var requested_family := ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--family="):
			requested_family = argument.trim_prefix("--family=")
	for resource_path: String in EXPECTED_ROOTS:
		if not requested_family.is_empty() and resource_path.get_file().get_basename() != requested_family:
			continue
		_check(ResourceLoader.exists(resource_path), "relocated source exists: %s" % resource_path)
		if not ResourceLoader.exists(resource_path):
			continue
		var packed: PackedScene = load(resource_path) as PackedScene
		_check(packed != null, "relocated source loads: %s" % resource_path)
		if packed == null:
			continue
		var instance: Node = packed.instantiate()
		_check(
			String(instance.name) == String(EXPECTED_ROOTS[resource_path]),
			"imported root name remains stable: %s" % resource_path
		)
		instance.free()

	if _failed_checks == 0:
		print("PASS: relocated high-risk environment roots retain their identities.")
		quit(0)
	else:
		push_error("FAIL: %d environment relocation checks failed." % _failed_checks)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failed_checks += 1
	push_error("FAIL: %s" % message)
