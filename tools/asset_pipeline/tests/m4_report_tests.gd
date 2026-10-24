extends SceneTree
var failures := 0
func _init() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error("ASSERTION FAILED: " + message)

func run() -> void:
	var teams: Array = []
	for index: int in 4:
		var team = load("res://gameplay/requests/dispatch_loadout.gd").new("durable-%d" % index,4,index+1)
		team.day = 1
		team.dispatch_underprepared()
		teams.append(team.capture_state())
	var report := {"day":1,"dispatch":teams,"medical":[],"meals":[],"meal_coverage":null,"admitted":[],"forfeits":[],"backlog":[],"scenario_complete":false}
	var view = load("res://gameplay/run/night_report.gd").new()
	root.add_child(view)
	view.present(report,"Continuation saved.")
	await process_frame
	check(view.body.text.contains("DISPATCH") and view.body.text.contains("Team 4") and view.body.text.contains("durable-3"),"Report retains every durable team/member identity")
	check(view.body.text.contains("Manual") and view.body.text.contains("06:00:00") and view.body.text.contains("Return Capacity 112"),"Dispatch reason/time and remaining Return Capacity shown")
	check(view.body.text.contains("Food 0/48") and view.body.text.contains("Medical 0/24") and view.body.text.contains("unmet"),"Five required/credited/unmet lanes shown")
	check(view.body.text.contains("MEDICAL") and view.body.text.contains("MEAL SERVICE") and view.body.text.contains("RECEIVING") and view.save_status.text == "Continuation saved.","Existing report sections and save status preserved")
	check(report.dispatch == teams,"Presentation never resolves or mutates outcomes")
	view.free()
	print("M4_REPORT_COMPLETE failures=",failures)
	quit(1 if failures else 0)
