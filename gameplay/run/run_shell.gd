extends Node

const SaveService = preload("res://gameplay/run/run_save_service.gd")
const Snapshot = preload("res://gameplay/run/run_snapshot.gd")
const WING_PATH := "res://gameplay/logistics_wing/wing_gameplay.tscn"
var save_service: RefCounted
var wing: Node3D
var menu_open := false
var pause_owners: Dictionary = {}
var launch: Control
var pause_menu: Control
var continue_button: Button
var status_label: Label
var pause_status: Label
var confirmation: ConfirmationDialog
var _pending_new_run := false
var _escape_down := false
var report_view: CanvasLayer
var midnight_save_status := ""
var _transition_started_usec := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if save_service == null:
		save_service = SaveService.new()
	_build_ui()
	_show_launch()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		if not event.pressed:
			_escape_down = false
		elif not event.echo and not _escape_down:
			_escape_down = true
			if wing != null and not confirmation.visible:
				var panel := wing.get_node("MedicalContribution/ContributionPanel")
				if panel.is_open():
					panel.close_panel()
				else:
					set_menu_open(not menu_open)
		get_viewport().set_input_as_handled()
	elif menu_open and event is InputEventKey:
		get_viewport().set_input_as_handled()

func request_pause(owner: String, enabled: bool) -> void:
	if enabled: pause_owners[owner] = true
	else: pause_owners.erase(owner)
	_sync_pause()

func _sync_pause() -> void:
	var paused := not pause_owners.is_empty()
	get_tree().paused = paused
	if wing != null:
		wing.get_node("ReceivingRuntime/ReceivingLiftCycle").set_menu_audio_paused(paused)
		wing.get_node("Player").set_world_input_blocked(paused)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED

func set_menu_open(opened: bool) -> void:
	if wing == null: return
	var panel := wing.get_node("MedicalContribution/ContributionPanel")
	if panel.is_open(): panel.close_panel()
	menu_open = opened
	pause_menu.visible = opened
	request_pause("menu", opened)

func request_new_run() -> void:
	if wing != null or FileAccess.file_exists(save_service.directory.path_join(SaveService.POINTER)):
		_pending_new_run = true
		confirmation.dialog_text = "Start a new run and replace the current continuation? Unsaved progress will be lost."
		confirmation.popup_centered(Vector2i(580, 180))
	else:
		start_new_run()

func cancel_new_run() -> void:
	_pending_new_run = false
	confirmation.hide()

func confirm_new_run() -> void:
	if not _pending_new_run: return
	_pending_new_run = false
	confirmation.hide()
	start_new_run()

func _candidate() -> Node3D:
	var candidate: Node3D = load(WING_PATH).instantiate()
	candidate.process_mode = Node.PROCESS_MODE_PAUSABLE
	return candidate

func start_new_run() -> bool:
	request_pause("loading", true)
	var candidate := _candidate()
	candidate.configure_new_run()
	add_child(candidate)
	var initialization_error: String = candidate.get_initialization_error()
	if not initialization_error.is_empty():
		candidate.free()
		_show_error(initialization_error)
		request_pause("loading", false)
		return false
	# Initialization is synchronous while the complete gameplay tree is held.
	var snapshot := Snapshot.new().capture(candidate)
	var saved: Dictionary = save_service.save_snapshot(snapshot)
	if not saved.ok:
		candidate.free()
		_show_error(saved.error)
		request_pause("loading", false)
		return false
	_publish_run(candidate)
	return true

func continue_run() -> bool:
	var loaded: Dictionary = save_service.load_snapshot()
	if not loaded.ok:
		_show_error(loaded.error)
		return false
	request_pause("loading", true)
	var candidate := _candidate()
	candidate.configure_continue(loaded.snapshot)
	add_child(candidate)
	var initialization_error: String = candidate.get_initialization_error()
	if not initialization_error.is_empty():
		candidate.free()
		_show_error(initialization_error)
		request_pause("loading", false)
		return false
	var restore_error := Snapshot.new().restore(candidate, loaded.snapshot)
	if not restore_error.is_empty():
		candidate.free()
		_show_error(restore_error)
		request_pause("loading", false)
		return false
	_publish_run(candidate)
	return true

func _publish_run(candidate: Node3D) -> void:
	if wing != null:
		wing.free()
	wing = candidate
	wing.name = "WingGameplay"
	wing.get_node("Player")._zone_editor.pause_owner = self
	pause_owners.clear()
	wing.run_schedule.night_started.connect(_on_night_started)
	wing.run_schedule.night_ready.connect(_on_night_ready)
	var pending: bool = wing.run_schedule.phase == "REPORT_PENDING"
	wing.get_node("ReceivingRuntime").return_admission.admission_open = not pending
	if pending:
		pause_owners["night_report"] = true
		midnight_save_status = "Continuation saved."
		report_view.present(wing.run_schedule.report, midnight_save_status)
	else:
		report_view.hide()
	menu_open = false
	pause_menu.hide()
	launch.hide()
	pause_status.text = ""
	_sync_pause()
	wing.get_node("Player").reset_pending_commands()

func save_and_exit() -> bool:
	if wing == null: return false
	set_menu_open(true)
	var snapshot := Snapshot.new().capture(wing)
	var saved: Dictionary = save_service.save_snapshot(snapshot)
	if not saved.ok:
		pause_status.text = "Save failed: " + saved.error
		return false
	wing.free()
	wing = null
	report_view.hide()
	pause_owners.clear()
	menu_open = false
	get_tree().paused = false
	_show_launch()
	return true

func _show_error(message: String) -> void:
	if wing != null: pause_status.text = message
	else:
		status_label.text = message
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _show_launch() -> void:
	pause_menu.hide()
	launch.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var slot: Dictionary = save_service.inspect_slot()
	continue_button.disabled = not slot.ok
	status_label.text = "One continuing run" if slot.ok else slot.error

func _build_ui() -> void:
	report_view = load("res://gameplay/run/night_report.gd").new()
	add_child(report_view)
	report_view.begin_day.connect(begin_next_day)
	report_view.first_frame.connect(_on_report_first_frame)
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	launch = _menu_card(layer, "SORTING APOCALYPSE", false)
	_button(launch, "New Run", request_new_run)
	continue_button = _button(launch, "Continue", continue_run)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	launch.get_node("Center/Card/Margin/Column").add_child(status_label)
	pause_menu = _menu_card(layer, "PAUSED", true)
	_button(pause_menu, "Resume", func(): set_menu_open(false))
	_button(pause_menu, "Save & Exit", save_and_exit)
	_button(pause_menu, "New Run", request_new_run)
	pause_status = Label.new()
	pause_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pause_menu.get_node("Center/Card/Margin/Column").add_child(pause_status)
	confirmation = ConfirmationDialog.new()
	confirmation.title = "Replace run"
	confirmation.confirmed.connect(confirm_new_run)
	confirmation.canceled.connect(cancel_new_run)
	add_child(confirmation)

func _on_night_started() -> void:
	_transition_started_usec = Time.get_ticks_usec()
	var panel := wing.get_node("MedicalContribution/ContributionPanel")
	panel.close_panel()
	request_pause("night_report", true)

func _on_night_ready() -> void:
	var capture_started := Time.get_ticks_usec()
	var snapshot := Snapshot.new().capture(wing)
	var write_started := Time.get_ticks_usec()
	var saved: Dictionary = save_service.save_snapshot(snapshot)
	var presentation_started := Time.get_ticks_usec()
	wing.run_schedule.transition_metrics.capture_ms = (write_started - capture_started) / 1000.0
	wing.run_schedule.transition_metrics.write_ms = (presentation_started - write_started) / 1000.0
	wing.run_schedule.transition_metrics.disk_write_ms = save_service.last_disk_write_ms
	midnight_save_status = "Continuation saved." if saved.ok else "Automatic save failed. Progress since the last successful save is not saved."
	if not saved.ok: push_warning("Midnight automatic save failed: " + saved.error)
	report_view.present(wing.run_schedule.report, midnight_save_status)
	wing.run_schedule.transition_metrics.presentation_setup_ms = (Time.get_ticks_usec() - presentation_started) / 1000.0
	wing.run_schedule.transition_metrics.response_ms = (Time.get_ticks_usec() - _transition_started_usec) / 1000.0
	print("M2_MIDNIGHT_TIMING ", wing.run_schedule.transition_metrics)

func _on_report_first_frame() -> void:
	if wing != null and _transition_started_usec > 0:
		wing.run_schedule.transition_metrics.first_report_frame_ms = (Time.get_ticks_usec() - _transition_started_usec) / 1000.0
		print("M2_REPORT_FIRST_FRAME_MS ", wing.run_schedule.transition_metrics.first_report_frame_ms)
		_transition_started_usec = 0

func begin_next_day() -> void:
	if wing == null or wing.run_schedule.phase != "REPORT_PENDING": return
	wing.run_schedule.begin_day()
	report_view.hide()
	request_pause("night_report", false)
	wing.get_node("Player").reset_pending_commands()

func _menu_card(layer: CanvasLayer, title: String, translucent: bool) -> Control:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.008, 0.013, 0.016, 0.72 if translucent else 1.0)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)
	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var card := PanelContainer.new()
	card.name = "Card"
	card.custom_minimum_size = Vector2(520, 0)
	center.add_child(card)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.05, 0.052, 0.97)
	style.border_color = Color(0.22, 0.37, 0.3)
	style.set_border_width_all(1)
	card.add_theme_stylebox_override("panel", style)
	var margin := MarginContainer.new()
	margin.name = "Margin"
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 32)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.name = "Column"
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	var heading := Label.new()
	heading.text = title
	heading.add_theme_font_size_override("font_size", 30)
	column.add_child(heading)
	return root

func _button(menu: Control, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(action)
	menu.get_node("Center/Card/Margin/Column").add_child(button)
	return button
