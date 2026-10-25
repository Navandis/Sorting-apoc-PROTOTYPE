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
	check(view.body.text.contains("Team 4") and not view.body.text.contains("durable-"),"Report retains teams without exposing opaque identities")
	check(view.body.text.contains("Dispatched 06:00:00") and not view.body.text.contains("Manually") and not view.body.text.contains("Departed") and view.body.text.contains("Return Capacity 112"),"Report shows dispatch timestamp without departure reason")
	check(view.body.text.contains("Food 0/48 · Hydration 0/48 · Medical 0/24 · Weapons 0/48 · Protection 0/48\n"),"Five lanes form one naturally wrapping text line")
	check(view.body.text.contains("Food 0/48") and view.body.text.contains("Medical 0/24") and not view.body.text.contains("unmet"),"Five lane values without redundant unmet suffixes")
	check(view.body.text.contains("Incoming supplies — scripted scenario") and view.save_status.text == "Continuation saved.","Scripted supply summary and save status preserved")
	var tabs: TabContainer = view.get("tabs")
	check(tabs != null,"Three report tabs replace combined scrolling body")
	if tabs != null:
		check(tabs.get_tab_count() == 3 and tabs.get_tab_title(0) == "Expeditions" and tabs.get_tab_title(1) == "Medical" and tabs.get_tab_title(2) == "Meal Service","Exact tab order")
		var before := report.duplicate(true)
		var begins := [0]
		view.begin_day.connect(func(): begins[0] += 1)
		for index: int in 3:
			tabs.current_tab = index
			await process_frame
		check(report == before and begins[0] == 0,"Tab changes never mutate report or begin day")
		check(view.bodies[1].text.contains("No Medical activity") and view.bodies[1].text.contains("Unmet 0") and view.bodies[2].text.contains("Daily Meal Coverage: N/A") and view.bodies[2].text.contains("No Meal Service scheduled"),"Empty tabs retain aggregates and N/A")
		view.present(report,"Save failed: fixture")
		check(tabs.current_tab == 0 and view.save_status.text == "Save failed: fixture","New presentation resets tab and retains truthful save failure")
		var partial := report.duplicate(true)
		partial.scenario_complete = true
		partial.medical = [{"result":{"Medical":{"required":12,"supplied":7,"unmet":5}},"closure_reason":"expired","spent":[{"wasted":2}]},{"result":{"Medical":{"required":3,"supplied":3,"unmet":0}},"closure_reason":"fulfilled","spent":[]}]
		partial.meals = [{"meal":"Breakfast","credited":{"Food":32,"Hydration":48},"targets":{"Food":48,"Hydration":48},"closure_reason":"expired"},{"meal":"Lunch","credited":{"Food":48,"Hydration":48},"targets":{"Food":48,"Hydration":48},"closure_reason":"fulfilled"},{"meal":"Dinner","credited":{"Food":0,"Hydration":0},"targets":{"Food":60,"Hydration":48},"closure_reason":"expired"}]
		partial.meal_coverage = 83.333
		partial.admitted = [{}]
		partial.forfeits = [{},{}]
		partial.backlog = [{},{},{}]
		partial.dispatch[0].dispatch_result.reason = "full"
		partial.dispatch[0].dispatch_result.at = 293.0417
		partial.dispatch[1].dispatch_result.reason = "cutoff"
		view.present(partial,"")
		check(view.body.text.contains("Dispatched 07:57:13") and not view.body.text.contains("Fully provisioned") and not view.body.text.contains("Cutoff") and not view.body.text.contains("Manually"),"All dispatch reasons hidden while actual stored timestamp retained")
		check(view.body.text.contains("Hauls admitted 1") and view.body.text.contains("Midnight forfeits 2") and view.body.text.contains("Deposited backlog carried forward 3"),"Scripted Receiving aggregates retained")
		check(view.bodies[1].text.contains("Required 15") and view.bodies[1].text.contains("Credited 10") and view.bodies[1].text.contains("Unmet 5") and view.bodies[1].text.contains("Expired 1") and view.bodies[1].text.contains("Fulfilled 1") and view.bodies[1].text.contains("Excess discarded 2"),"Medical aggregate facts retained")
		check(view.bodies[2].text.contains("83.3%") and view.bodies[2].text.contains("Food 32/48") and view.bodies[2].text.contains("Hydration 48/48") and view.bodies[2].text.contains("Fulfilled") and view.bodies[2].text.contains("Expired"),"Meal coverage read from frozen aggregate and per-meal outcomes retained")
		check(view.bodies[2].text.contains("Breakfast · Partially fulfilled") and view.bodies[2].text.contains("Lunch · Fulfilled") and view.bodies[2].text.contains("Dinner · Expired"),"Partial, complete and untouched meals have distinct presentation outcomes")
		check(partial.meals[0].closure_reason == "expired","Partial meal wording preserves stored expiry semantics")
		for credit: Dictionary in [{"Food":1,"Hydration":0},{"Food":0,"Hydration":1}]:
			var one_lane := partial.duplicate(true)
			one_lane.meals[0].credited = credit
			view.present(one_lane,"")
			check(view.bodies[2].text.contains("Breakfast · Partially fulfilled"),"Contribution in either meal lane is partial fulfillment")
		view.present(partial,"")
		check(view.scenario_notice.visible and not tabs.is_ancestor_of(view.scenario_notice),"Scenario notice is fixed outside scroll")
		await capture_report(view)
		for index: int in 3: view.bodies[index].text += "\nLong presentation fixture".repeat(80)
		for index: int in 3:
			tabs.current_tab = index
			await process_frame
			await process_frame
			var region: ScrollContainer = tabs.get_child(index)
			region.scroll_vertical = 90 + index * 20
			await process_frame
		for index: int in 3: check(tabs.get_child(index).scroll_vertical == 90 + index * 20,"Independent tab scroll retained: " + str(index))
		partial.dispatch = []
		view.present(partial,"")
		check(view.body.text.contains("No teams scheduled"),"No team empty state")
	check(report.dispatch == teams,"Presentation never resolves or mutates outcomes")
	view.free()
	await process_frame
	print("M4_REPORT_COMPLETE failures=",failures)
	quit(1 if failures else 0)

func capture_report(view: CanvasLayer) -> void:
	var destination := ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--m4-report-evidence-dir="): destination = arg.trim_prefix("--m4-report-evidence-dir=")
	if DisplayServer.get_name() == "headless" or destination.is_empty(): return
	DirAccess.make_dir_recursive_absolute(destination)
	for size: Vector2i in [Vector2i(1920,1080),Vector2i(1280,720)]:
		DisplayServer.window_set_size(size)
		for index: int in 3:
			view.tabs.current_tab = index
			for frame: int in 6: await process_frame
			await RenderingServer.frame_post_draw
			check(root.get_visible_rect().encloses(view.card.get_global_rect()),"Report fits at " + str(size))
			check(root.get_texture().get_image().save_png(destination.path_join("report-tab-%d-%d.png" % [index,size.x])) == OK,"Revised report captured")
