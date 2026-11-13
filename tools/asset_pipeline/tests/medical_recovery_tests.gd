extends SceneTree

const RECOVERY_PATH := "res://gameplay/medical/medical_recovery.gd"
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if check(ResourceLoader.exists(RECOVERY_PATH), "Medical owns active natural recovery"):
		var medical: RefCounted = load(RECOVERY_PATH).new()
		medical.admit("crew", 0, "light", 40.0)
		medical.admit("crew", 1, "severe", 40.0)
		medical.admit("later", 0, "light", 220.0)
		check(medical.active_patients().size() == 3 and medical.next_boundary_at() == 160.0, "patients keep independent deadlines from intake")
		check(medical.settle_due(159.999) == 0 and medical.settle_due(160.0) == 1, "Light recovery completes at exactly 120 active seconds")
		check(medical.settle_due(160.0) == 0 and medical.active_patients().size() == 2, "recovery is released once")
		var restored: RefCounted = load(RECOVERY_PATH).new()
		restored.restore_state(medical.capture_state())
		check(restored.active_patients().size() == 2 and restored.next_boundary_at() == 340.0, "restore preserves completed and active patients")
		check(restored.settle_due(339.999) == 0 and restored.settle_due(340.0) == 2
			and restored.settle_due(999.0) == 0 and restored.active_patients().is_empty(), "simultaneous Light and Severe recovery settles exactly once")
	print("medical_recovery_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok
