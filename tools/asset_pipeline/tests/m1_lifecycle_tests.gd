extends SceneTree
var failures := 0
var checks := 0

func _init() -> void:
	create_timer(45).timeout.connect(func():
		push_error("M1 helper aborted; completion missing" )
		quit(3))
	run.call_deferred()

func check(ok: bool, message: String) -> bool:
	checks += 1
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)
	return ok

func run() -> void:
	var cycle = load("res://gameplay/logistics_wing/receiving/receiving_lift_cycle.gd").new()
	if not check(cycle.has_method("capture_state") and cycle.has_method("restore_state"), "lift exposes logical continuation without restarting theatre"):
		cycle.free()
		finish()
		return
	cycle.free()
	check(ResourceLoader.exists("res://gameplay/run/run_shell.tscn"), "launch composition exposes New Run and Continue" )
	finish()

func finish() -> void:
	print("M1_LIFECYCLE_COMPLETE checks=", checks, " failures=", failures)
	quit(1 if failures else 0)
