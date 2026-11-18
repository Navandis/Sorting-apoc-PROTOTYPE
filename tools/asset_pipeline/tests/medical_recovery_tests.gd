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
		test_treatment()
	print("medical_recovery_tests: ", "PASS" if failures == 0 else "FAIL", " failures=", failures)
	quit(0 if failures == 0 else 1)

func test_treatment() -> void:
	const NOW := 300.0
	var medical: RefCounted = load(RECOVERY_PATH).new()
	if not check(medical.has_method("treatment_plan"), "Medical can plan one seconds-budget treatment"):
		return
	medical.admit("a", 0, "light", 230.0)
	medical.admit("b", 0, "severe", 70.0)
	medical.admit("c", 0, "light", 280.0)
	var before: Dictionary = medical.capture_state()
	var plan: Dictionary = medical.treatment_plan(NOW, 200.0)
	check(medical.capture_state() == before and plan.applied == 200.0 and plan.wasted == 0.0
		and plan.recovered == 2, "preview plans spillover and leaves patient state untouched")
	medical.apply_treatment(plan)
	check(medical.settle_due(NOW) == 2 and medical.settle_due(NOW) == 0
		and medical.next_boundary_at() == 320.0, "50 / 70 / 100 plus 20 Utility leaves 0 / 0 / 20")

	medical = load(RECOVERY_PATH).new()
	medical.admit("b", 0, "light", 200.0)
	medical.admit("a", 0, "severe", 1.5)
	plan = medical.treatment_plan(NOW, 10.0)
	medical.apply_treatment(plan)
	check(plan.recovered == 1 and medical.settle_due(NOW) == 1 and medical.next_boundary_at() == 311.5,
		"1.5 seconds completes the Severe patient and the exact 8.5-second remainder spills over")
	plan = medical.treatment_plan(301.0, 10.0)
	medical.apply_treatment(plan)
	check(plan.recovered == 0 and medical.next_boundary_at() == 301.5 and medical.settle_due(301.5) == 1,
		"a later item shortens the partial deadline and natural recovery completes it")

	medical = load(RECOVERY_PATH).new()
	medical.admit("b", 0, "light", 200.0)
	medical.admit("a", 0, "severe", 20.0)
	medical.admit("c", 0, "light", 210.0)
	medical.admit("d", 0, "light", 220.0)
	var tie: Dictionary = medical.treatment_plan(NOW, 10.0)
	check(tie.deadlines == {"a:patient:0": 310.0}, "equal deadlines use stable IDs instead of insertion or severity")

	medical = load(RECOVERY_PATH).new()
	medical.admit("a", 0, "light", 200.0)
	medical.admit("b", 0, "light", 210.0)
	medical.admit("c", 0, "light", 220.0)
	var excess: Dictionary = medical.treatment_plan(NOW, 100.0)
	medical.apply_treatment(excess)
	check(excess.applied == 90.0 and excess.wasted == 10.0 and medical.settle_due(NOW) == 3
		and medical.next_boundary_at() == INF and medical.treatment_plan(NOW, 10.0).applied == 0.0,
		"terminal excess is discarded after all deadlines clamp to now")

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)
	return ok
