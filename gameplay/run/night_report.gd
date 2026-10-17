extends CanvasLayer

signal begin_day
signal first_frame
var title: Label
var body: Label
var save_status: Label
var begin_button: Button
var card: PanelContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	visible = false
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.008, 0.013, 0.016, 0.86)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	card = PanelContainer.new()
	card.custom_minimum_size = Vector2(780, 0)
	center.add_child(card)
	var margin := MarginContainer.new()
	for side: String in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 30)
	card.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	margin.add_child(column)
	title = Label.new()
	title.add_theme_font_size_override("font_size", 30)
	column.add_child(title)
	body = Label.new()
	body.add_theme_font_size_override("font_size", 22)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(body)
	save_status = Label.new()
	save_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(save_status)
	begin_button = Button.new()
	begin_button.custom_minimum_size.y = 48
	begin_button.add_theme_font_size_override("font_size", 22)
	begin_button.pressed.connect(func(): begin_day.emit())
	column.add_child(begin_button)
	var hint := Label.new()
	hint.text = "[ESC] Menu / Save & Exit"
	column.add_child(hint)

func present(report: Dictionary, status: String) -> void:
	title.text = "End of Day %d" % report.day
	var required := 0
	var supplied := 0
	var unmet := 0
	var waste := 0
	var fulfilled := 0
	var expired := 0
	for request: Dictionary in report.medical:
		required += int(request.result.Medical.required)
		supplied += int(request.result.Medical.supplied)
		unmet += int(request.result.Medical.unmet)
		fulfilled += int(request.closure_reason == "fulfilled")
		expired += int(request.closure_reason == "expired")
		for receipt: Dictionary in request.spent: waste += int(receipt.wasted)
	body.text = "MEDICAL\nRequired %d  ·  Credited %d  ·  Unmet %d\nFulfilled %d  ·  Expired %d  ·  Excess discarded %d\n\nRECEIVING\nHauls admitted %d  ·  Midnight forfeits %d\nDeposited backlog carried forward %d" % [required, supplied, unmet, fulfilled, expired, waste, report.admitted.size(), report.forfeits.size(), report.backlog.size()]
	if report.scenario_complete: body.text += "\n\nAuthored scenario complete."
	save_status.text = status
	begin_button.text = "Begin Day %d" % (int(report.day) + 1)
	visible = true
	if DisplayServer.get_name() != "headless" and not RenderingServer.frame_post_draw.is_connected(_first_draw):
		RenderingServer.frame_post_draw.connect(_first_draw, CONNECT_ONE_SHOT)

func _first_draw() -> void:
	first_frame.emit()
