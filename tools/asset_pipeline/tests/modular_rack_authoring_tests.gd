extends SceneTree

const RACK_SCENE := "res://gameplay/logistics_wing/storage/modular_rack.tscn"

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_check(ResourceLoader.exists(RACK_SCENE), "ModularRack scene exists")
	if not ResourceLoader.exists(RACK_SCENE):
		_finish()
		return

	var packed := load(RACK_SCENE) as PackedScene
	var rack := packed.instantiate() if packed != null else null
	_check(rack != null, "ModularRack scene instantiates")
	if rack == null:
		_finish()
		return

	root.add_child(rack)
	_check(
		rack.get_script() != null
		and String(rack.get_script().get_global_name()) == "ModularRack",
		"ModularRack scene instantiates as the global ModularRack class"
	)
	_check(rack.get_node_or_null("Frame/Visual") != null, "Rack01 visual exists")
	_check(rack.get_node_or_null("Levels") != null, "Levels root exists")
	_check(
		rack.get_node_or_null("MovementCollision/Shape") is CollisionShape3D,
		"movement collision exists"
	)
	var levels := rack.get_node_or_null("Levels")
	_check(
		levels != null and levels.get_child_count() == 3,
		"starter component contains three authored level wrappers"
	)
	rack.queue_free()
	await process_frame
	_finish()


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false


func _finish() -> void:
	if _failed:
		push_error("FAIL: modular rack authoring tests")
		quit(1)
		return
	print("PASS: modular rack authoring tests")
	quit(0)
