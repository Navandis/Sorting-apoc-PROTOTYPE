extends RefCounted

const Codec = preload("res://gameplay/run/state_codec.gd")
const Snapshot = preload("res://gameplay/run/run_snapshot.gd")
const POINTER := "active-slot.json"
const MAX_SAVE_BYTES := 16 * 1024 * 1024
var directory: String

func _init(destination: String = "user://saves") -> void:
	directory = ProjectSettings.globalize_path(destination)

func _failure(message: String) -> Dictionary:
	return {"ok": false, "error": message}

func _active_filename() -> String:
	var pointer := FileAccess.open(directory.path_join(POINTER), FileAccess.READ)
	if pointer == null: return ""
	var data: Variant = JSON.parse_string(pointer.get_as_text())
	if not data is Dictionary or not data.get("snapshot") is String: return ""
	var filename: String = data.snapshot
	if filename != filename.get_file() or not filename.begins_with("Save_") or not filename.ends_with(".json"): return ""
	return filename

func inspect_slot() -> Dictionary:
	return load_snapshot()

func load_snapshot() -> Dictionary:
	var name := _active_filename()
	if name.is_empty():
		return _failure("No compatible continuation is available" if not FileAccess.file_exists(directory.path_join(POINTER)) else "The active save pointer is invalid; save left untouched")
	var path := directory.path_join(name)
	var read := _read_snapshot(path)
	if not read.ok: return read
	read.path = path
	return read

func _read_snapshot(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return _failure("Cannot open save: " + error_string(FileAccess.get_open_error()))
	if file.get_length() > MAX_SAVE_BYTES: return _failure("Save exceeds supported size")
	var codec := Codec.new()
	var state := codec.parse(file.get_as_text())
	if not codec.error.is_empty(): return _failure(codec.error)
	var validation := Snapshot.new().validate(state)
	if not validation.is_empty(): return _failure(validation)
	return {"ok": true, "snapshot": state}

func save_snapshot(state: Dictionary, local_time: Dictionary = {}) -> Dictionary:
	var validation := Snapshot.new().validate(state)
	if not validation.is_empty(): return _failure(validation)
	var codec := Codec.new()
	var serialized := codec.stringify(state)
	if not codec.error.is_empty(): return _failure(codec.error)
	if serialized.to_utf8_buffer().size() > MAX_SAVE_BYTES: return _failure("Save exceeds supported size")
	var ancestor := directory
	while not ancestor.is_empty() and not DirAccess.dir_exists_absolute(ancestor):
		if FileAccess.file_exists(ancestor): return _failure("Save directory is blocked by an existing file: " + ancestor)
		var parent := ancestor.get_base_dir()
		if parent == ancestor: break
		ancestor = parent
	var mkdir := DirAccess.make_dir_recursive_absolute(directory)
	if mkdir != OK: return _failure("Cannot create save directory: " + error_string(mkdir))
	var previous := _active_filename()
	if FileAccess.file_exists(directory.path_join(POINTER)) and previous.is_empty(): return _failure("Existing active pointer is invalid; save left untouched")
	var stamp := local_time if not local_time.is_empty() else Time.get_datetime_dict_from_system(false)
	var filename := "Save_%s_%02d%02d%02d-%02d-%02d.json" % [state.run.id, stamp.day, stamp.month, int(stamp.year) % 100, stamp.hour, stamp.minute]
	var final_path := directory.path_join(filename)
	var stage_path := directory.path_join(".m1-snapshot.tmp")
	var backup_path := directory.path_join(".m1-replace.tmp")
	var pointer_stage := directory.path_join(".m1-pointer.tmp")
	var pointer_backup := directory.path_join(".m1-old-pointer.tmp")
	# Unexpected working files are preserved for inspection, never blindly deleted.
	for path: String in [stage_path, backup_path, pointer_stage, pointer_backup]:
		if FileAccess.file_exists(path): return _failure("Unexpected save working file; left untouched: " + path)
	if FileAccess.file_exists(final_path) and filename != previous: return _failure("Unexpected existing snapshot; left untouched: " + final_path)
	var write_error := _write_file(stage_path, serialized)
	if not write_error.is_empty(): return _failure(write_error)
	var staged := _read_snapshot(stage_path)
	if not staged.ok:
		DirAccess.remove_absolute(stage_path)
		return staged
	write_error = _write_file(pointer_stage, JSON.stringify({"snapshot": filename, "saved_at_local": stamp}))
	if not write_error.is_empty():
		DirAccess.remove_absolute(stage_path)
		return _failure(write_error)
	var same_name := previous == filename
	if same_name and DirAccess.rename_absolute(final_path, backup_path) != OK:
		DirAccess.remove_absolute(stage_path)
		DirAccess.remove_absolute(pointer_stage)
		return _failure("Cannot stage previous save for same-minute replacement")
	if DirAccess.rename_absolute(stage_path, final_path) != OK:
		if same_name: DirAccess.rename_absolute(backup_path, final_path)
		DirAccess.remove_absolute(stage_path)
		DirAccess.remove_absolute(pointer_stage)
		return _failure("Cannot install validated snapshot; previous slot retained")
	var pointer_path := directory.path_join(POINTER)
	var had_pointer := FileAccess.file_exists(pointer_path)
	if had_pointer and DirAccess.rename_absolute(pointer_path, pointer_backup) != OK:
		_rollback_snapshot(final_path, backup_path, pointer_stage, same_name)
		return _failure("Cannot replace active pointer; previous slot retained")
	if DirAccess.rename_absolute(pointer_stage, pointer_path) != OK:
		if had_pointer: DirAccess.rename_absolute(pointer_backup, pointer_path)
		_rollback_snapshot(final_path, backup_path, pointer_stage, same_name)
		return _failure("Cannot publish active pointer; previous slot retained")
	# Publication succeeded. Cleanup failures do not turn a successful save into a
	# reported write failure; no unrelated file can be selected for retirement.
	if had_pointer: DirAccess.remove_absolute(pointer_backup)
	if same_name: DirAccess.remove_absolute(backup_path)
	elif not previous.is_empty(): DirAccess.remove_absolute(directory.path_join(previous))
	return {"ok": true, "path": final_path}

func _rollback_snapshot(final_path: String, backup_path: String, pointer_stage: String, same_name: bool) -> void:
	DirAccess.remove_absolute(final_path)
	if same_name: DirAccess.rename_absolute(backup_path, final_path)
	DirAccess.remove_absolute(pointer_stage)

func _write_file(path: String, contents: String) -> String:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return "Cannot write save: " + error_string(FileAccess.get_open_error())
	file.store_string(contents)
	file.flush()
	var result := file.get_error()
	file.close()
	if result != OK:
		DirAccess.remove_absolute(path)
		return "Save write failed: " + error_string(result)
	return ""
