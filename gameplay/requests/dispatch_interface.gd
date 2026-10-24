extends "res://gameplay/requests/medical_interface.gd"

var teams: Array = []

func _new_panel() -> CanvasLayer:
	return load("res://gameplay/requests/dispatch_carousel.gd").new()

func configure(wing: Node, state: RefCounted, _context: String = "dispatch", _proxy_name: String = "DispatchWorkSurface", _title: String = "DISPATCH") -> void:
	super.configure(wing,state,"dispatch","DispatchWorkSurface","DISPATCH")

func bind_teams(states: Array) -> void:
	teams = states.duplicate()
	panel.set_teams(teams)
	request = panel.request
	if not is_active(): panel.close_panel()
	_refresh_action_label()

func is_active() -> bool:
	return teams.any(func(team): return team.is_accepting())

func _refresh_action_label() -> void:
	if action_label != null: action_label.text = "DISPATCH\n[F] Team loadouts" if is_active() else "DISPATCH"
