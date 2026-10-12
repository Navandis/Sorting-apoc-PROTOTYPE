extends Node3D
class_name ReceivingLiftCycle

## One physical delivery. Manager owns deposits/retirement; presenter owns cargo.
## Audio completion never substitutes for staged cargo, open pose or batch drain.
enum State { SEALED_EMPTY, ARRIVAL, SEALED_READY, REVEALING, OPEN, CLOSING }

signal state_changed(state: State)
signal readout_changed

@export_group("Shutter synchronization")
@export_range(0.0, 2.0, 0.05) var arrival_open_overlap_s := 0.65
@export_range(0.0, 1.0, 0.05) var opening_motion_delay_s := 0.15
@export_range(0.1, 12.0, 0.05) var opening_motion_duration_s := 5.3
@export_range(0.0, 1.0, 0.05) var closing_motion_delay_s := 0.15
@export_range(0.1, 12.0, 0.05) var closing_motion_duration_s := 5.6
@export_group("W1 indication")
@export_range(1.0, 6.0, 0.1) var amber_pulse_period_s := 2.8
@export_range(0.0, 3.0, 0.05) var amber_emission_energy := 0.85
@export_range(0.0, 2.0, 0.05) var green_emission_energy := 0.35
@export var amber_color := Color(1.0, 0.48, 0.08)
@export var green_color := Color(0.22, 0.65, 0.32)
@export_group("Positional sound")
@export_range(-24.0, 6.0, 0.5) var audio_volume_db := -3.0
@export_range(1.0, 8.0, 0.1) var audio_unit_size_m := 3.0
@export_range(8.0, 32.0, 0.5) var audio_max_distance_m := 22.0

var _manager: ReceivingManager
var _presenter: ReceivingDeckPresenter
var _shutter: Node3D
var _reflections: Node
var _warning: StandardMaterial3D
var _warning_off_albedo := Color.WHITE
var _warning_off_shading := BaseMaterial3D.SHADING_MODE_PER_PIXEL
var _state := State.SEALED_EMPTY
var _closed_y := 0.086
var _open_y := 3.1416707
var _elapsed := 0.0
var _warning_elapsed := 0.0
var _phase_duration := 0.0
var _busy := false
var _departing := false
var _retiring := false
var _cycle_batch_id := ""
var _configured := false

func _ready() -> void:
	set_process(false)

func configure(manager: ReceivingManager, presenter: ReceivingDeckPresenter, installation: Node3D, warning_mesh: MeshInstance3D, display: Node, reflections: Node) -> bool:
	if _configured or manager == null or presenter == null or installation == null:
		return false
	var shutter_path: NodePath = installation.get_meta("active_shutter", NodePath())
	_shutter = installation.get_node_or_null(shutter_path) as Node3D if not shutter_path.is_empty() else null
	var closed := installation.get_node_or_null("ShutterPoseMarkers/Closed") as Node3D
	var opened := installation.get_node_or_null("ShutterPoseMarkers/Open") as Node3D
	if _shutter == null or closed == null or opened == null or opened.position.y <= closed.position.y:
		return false
	for audio: AudioStreamPlayer3D in _audio_players():
		if audio.stream == null or audio.stream.get_length() <= 0.0:
			return false
		audio.volume_db = audio_volume_db
		audio.unit_size = audio_unit_size_m
		audio.max_distance = audio_max_distance_m
	_manager = manager
	_presenter = presenter
	_reflections = reflections
	_closed_y = closed.position.y
	_open_y = opened.position.y
	_shutter.position.y = _closed_y # Only Y; never rewrite the authored art pose.
	set_as_top_level(true) # Runtime's nonuniform presentation scale is not an audio metric.
	global_transform = Transform3D(Basis.IDENTITY, _shutter.global_position + Vector3(0, 1.4, 0))
	if warning_mesh != null:
		_warning = warning_mesh.get_surface_override_material(1).duplicate() as StandardMaterial3D
		# Uniform runtime lens emission allows both colors; original texture/resource stays intact.
		_warning.emission_texture = null
		_warning_off_albedo = _warning.albedo_color
		_warning_off_shading = _warning.shading_mode
		warning_mesh.set_surface_override_material(1, _warning)
	_presenter.set_lift_pickup_gate(can_take_receiving)
	_presenter.suspend_pickup()
	_manager.active_batch_changed.connect(_on_active_batch_changed)
	_manager.active_batch_drained.connect(_on_active_batch_drained)
	_manager.contents_changed.connect(_on_contents_changed)
	_configured = true
	if display != null:
		display.bind_cycle(self)
	_update_warning()
	# The saved probe initial UPDATE_ONCE captures this closed pose on first render.
	set_process(true)
	if _manager.get_active_batch() != null:
		_on_active_batch_changed(_manager.get_active_batch_id())
	return true

func is_configured() -> bool:
	return _configured

func get_cycle_state() -> State:
	return _state

func is_busy() -> bool:
	return _busy

func can_take_receiving() -> bool:
	return (
		_configured and _state == State.OPEN and not _departing
		and is_instance_valid(_shutter) and is_equal_approx(_shutter.position.y, _open_y)
		and _manager.get_active_batch_id() == _cycle_batch_id
	)

func get_deck_item_count() -> int:
	if not _configured or _state == State.SEALED_EMPTY or _state == State.ARRIVAL:
		return 0
	var batch := _manager.get_active_batch()
	if batch == null or batch.batch_id != _cycle_batch_id:
		return 0
	var count := 0
	for entry: LootBatchEntry in batch.entries:
		if entry.remaining_in_batch:
			count += 1
	return count

func get_queued_batch_count() -> int:
	return _manager.get_queued_batch_ids().size() if _manager != null else 0

func _process(delta: float) -> void:
	if not _configured:
		return
	_elapsed += delta
	_warning_elapsed += delta
	_update_warning()
	if not is_instance_valid(_shutter):
		_presenter.suspend_pickup()
		return
	match _state:
		State.ARRIVAL:
			if _elapsed >= _phase_duration and _presenter.is_active_batch_staged():
				_set_state(State.SEALED_READY)
				_set_state(State.REVEALING) # Internal staging confirmation needs no wait.
				$Opening.play()
		State.REVEALING:
			if _move_shutter(_closed_y, _open_y, opening_motion_delay_s, opening_motion_duration_s):
				if _set_state(State.OPEN):
					_request_refresh()
		State.CLOSING:
			var closed := _move_shutter(_open_y, _closed_y, closing_motion_delay_s, closing_motion_duration_s)
			if closed and _elapsed >= _phase_duration and not $Closing.playing:
				_departing = true
				_set_state(State.SEALED_EMPTY)
				$Arrival.stop()
				$Departure.play()
				_phase_duration = _cue_duration($Departure)
				_request_refresh()
		State.SEALED_EMPTY:
			if _departing and _elapsed >= _phase_duration and not $Departure.playing:
				# Safe completed-turnaround retirement. FIFO promotion stays manager-owned.
				# Physical back-to-back queue activation is the next gate, not this cycle.
				_retiring = true
				_presenter.retire_drained_active_after_close()
				_retiring = false
				_departing = false
				_busy = false
				_cycle_batch_id = ""
				readout_changed.emit()
				_request_refresh()

func _move_shutter(from_y: float, to_y: float, delay_s: float, duration_s: float) -> bool:
	var progress := clampf((_elapsed - delay_s) / maxf(duration_s, .001), 0.0, 1.0)
	_shutter.position.y = lerpf(from_y, to_y, smoothstep(0.0, 1.0, progress))
	if progress < 1.0:
		return false
	_shutter.position.y = to_y
	return is_equal_approx(_shutter.position.y, to_y)

func _set_state(next: State) -> bool:
	var previous := _state
	_state = next
	if next == State.OPEN:
		if not _presenter.reveal_active_batch():
			_state = previous
			return false
	else:
		_presenter.suspend_pickup()
	_elapsed = 0.0
	_update_warning()
	readout_changed.emit()
	state_changed.emit(_state)
	return true

func _on_active_batch_changed(batch_id: String) -> void:
	if batch_id.is_empty() or _busy or _retiring:
		return
	_busy = true
	_cycle_batch_id = batch_id
	_warning_elapsed = 0.0
	_phase_duration = maxf(0.0, _cue_duration($Arrival) - arrival_open_overlap_s)
	_set_state(State.ARRIVAL)
	$Arrival.play()

func _on_active_batch_drained(batch_id: String) -> void:
	if _state != State.OPEN or batch_id != _cycle_batch_id or not _manager.get_active_batch().is_drained():
		return
	_set_state(State.CLOSING)
	$Opening.stop()
	$Closing.play()
	_phase_duration = maxf(_cue_duration($Closing), closing_motion_delay_s + closing_motion_duration_s)

func _on_contents_changed() -> void:
	readout_changed.emit()

func _cue_duration(audio: AudioStreamPlayer3D) -> float:
	return audio.stream.get_length() / maxf(audio.pitch_scale, .01)

func _audio_players() -> Array[AudioStreamPlayer3D]:
	return [$Arrival, $Opening, $Closing, $Departure]

func _update_warning() -> void:
	if _warning == null:
		return
	var amber := _state in [State.ARRIVAL, State.SEALED_READY, State.REVEALING]
	_warning.emission_enabled = amber or _state == State.OPEN
	# The metallic source lens otherwise hides the low emission in reflections.
	_warning.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if _warning.emission_enabled else _warning_off_shading
	if amber:
		var pulse := (sin(_warning_elapsed * TAU / maxf(amber_pulse_period_s, .01)) + 1.0) * .5
		_warning.emission = amber_color
		_warning.emission_energy_multiplier = amber_emission_energy * lerpf(.15, 1.0, pulse)
		_set_warning_tint(amber_color, _warning.emission_energy_multiplier)
	elif _state == State.OPEN:
		_warning.emission = green_color
		_warning.emission_energy_multiplier = green_emission_energy
		_set_warning_tint(green_color, green_emission_energy)
	else:
		_warning.albedo_color = _warning_off_albedo
		_warning.emission_energy_multiplier = 0.0

func _set_warning_tint(color: Color, intensity: float) -> void:
	# Unshaded albedo is the visible indication on Compatibility, including pulse.
	_warning.albedo_color = Color(color.r * intensity, color.g * intensity, color.b * intensity, _warning_off_albedo.a)

func _request_refresh() -> void:
	if is_instance_valid(_reflections):
		_reflections.request_refresh()
