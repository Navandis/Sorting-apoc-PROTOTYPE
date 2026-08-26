extends RefCounted
class_name AuthoringReviewManifest

const SCHEMA_VERSION: String = "1.0"
const FLOAT_TOLERANCE: float = 0.001
const FLAG_UNTRACKED: String = "AUTHORING_REVIEW_UNTRACKED"
const FLAG_AMBIGUOUS: String = "AUTHORING_REVIEW_AMBIGUOUS"
const FLAG_PATH_STALE: String = "AUTHORING_REVIEW_PATH_STALE"
const FLAG_SCALE_STALE: String = "SCALE_REVIEW_STALE"
const FLAG_POSE_STALE: String = "STORAGE_POSE_REVIEW_STALE"
const FLAG_FOOTPRINT_STALE: String = "FOOTPRINT_REVIEW_STALE"

const SCALE_COMPLETED: PackedStringArray = ["APPROVED", "NORMALIZATION_REQUIRED"]
const POSE_COMPLETED: PackedStringArray = [
	"DEFAULT_POSE_APPROVED", "CUSTOM_POSE_REQUIRED", "CUSTOM_POSE_APPROVED"
]
const FOOTPRINT_COMPLETED: PackedStringArray = ["GEOMETRY_APPROVED", "OVERRIDE_APPROVED"]


static func empty_manifest() -> Dictionary:
	return {"schema_version": SCHEMA_VERSION, "assets": {}}


static func new_record(asset: Dictionary) -> Dictionary:
	return {
		"source_path": String(asset.get("source_path", "")),
		"item_id": String(asset.get("item_id", "")),
		"source_fingerprint": String(asset.get("source_fingerprint", "")),
		"scale_review": {
			"status": "UNREVIEWED",
			"reviewed_source_fingerprint": "",
			"notes": ""
		},
		"storage_pose_review": {
			"status": "UNREVIEWED",
			"reviewed_source_fingerprint": "",
			"reviewed_rotation_degrees": [0.0, 0.0, 0.0],
			"notes": ""
		},
		"footprint_review": {
			"status": "UNREVIEWED",
			"reviewed_source_fingerprint": "",
			"reviewed_footprint": [0, 0, 0],
			"reviewed_rotation_degrees": [0.0, 0.0, 0.0],
			"notes": ""
		}
	}


static func load_manifest(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return empty_manifest()
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Unable to read authoring review manifest: %s" % path)
		return empty_manifest()
	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not (parser.data is Dictionary):
		push_error("Invalid authoring review manifest JSON: %s" % path)
		return empty_manifest()
	var manifest: Dictionary = parser.data as Dictionary
	if String(manifest.get("schema_version", "")) != SCHEMA_VERSION:
		push_error("Unsupported authoring review manifest schema: %s" % path)
		return empty_manifest()
	if not (manifest.get("assets", {}) is Dictionary):
		manifest["assets"] = {}
	return manifest


static func write_manifest(path: String, manifest: Dictionary) -> bool:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write authoring review manifest: %s" % path)
		return false
	file.store_string(serialize_manifest(manifest))
	file.close()
	return true


static func serialize_manifest(manifest: Dictionary) -> String:
	return JSON.stringify(_normalized_manifest(manifest), "\t", true) + "\n"


static func fingerprint_for_path(source_path: String) -> String:
	if not FileAccess.file_exists(source_path):
		return ""
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(source_path)
	var context: HashingContext = HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		push_error("Unable to start SHA-256 fingerprint: %s" % source_path)
		return ""
	if context.update(bytes) != OK:
		push_error("Unable to hash source asset: %s" % source_path)
		return ""
	return context.finish().hex_encode()


static func correlate_current_assets(manifest: Dictionary, current_assets: Array[Dictionary]) -> Array[Dictionary]:
	var records: Dictionary = manifest.get("assets", {}) as Dictionary
	var results: Array[Dictionary] = []
	var used_keys: Dictionary = {}
	var current_item_counts: Dictionary = _current_value_counts(current_assets, "item_id")
	var current_fingerprint_counts: Dictionary = _current_value_counts(current_assets, "source_fingerprint")

	for current_asset: Dictionary in current_assets:
		var match: Dictionary = _match_current_asset(
			records, current_asset, used_keys, current_item_counts, current_fingerprint_counts
		)
		if not String(match["authoring_key"]).is_empty():
			used_keys[String(match["authoring_key"])] = true
		results.append(match)
	return results


static func seed_or_sync(manifest: Dictionary, current_assets: Array[Dictionary]) -> Dictionary:
	var updated_manifest: Dictionary = _normalized_manifest(manifest)
	var records: Dictionary = updated_manifest["assets"] as Dictionary
	var matches: Array[Dictionary] = correlate_current_assets(updated_manifest, current_assets)
	var added_keys: Array[String] = []
	var updated_keys: Array[String] = []
	var ambiguous_paths: Array[String] = []
	var next_number: int = _highest_key_suffix(records) + 1

	for match: Dictionary in matches:
		var asset: Dictionary = match["asset"] as Dictionary
		var authoring_key: String = String(match["authoring_key"])
		if authoring_key.is_empty():
			if String(match["problem_flag"]) == FLAG_AMBIGUOUS:
				ambiguous_paths.append(String(asset.get("source_path", "")))
				continue
			authoring_key = "loot_%06d" % next_number
			next_number += 1
			records[authoring_key] = new_record(asset)
			added_keys.append(authoring_key)
			continue

		var record: Dictionary = records[authoring_key] as Dictionary
		var changed: bool = false
		var current_path: String = String(asset.get("source_path", ""))
		var current_fingerprint: String = String(asset.get("source_fingerprint", ""))
		var current_item_id: String = String(asset.get("item_id", ""))
		if String(match["correlation"]) == "fingerprint" and String(record.get("source_path", "")) != current_path:
			record["source_path"] = current_path
			changed = true
		if String(record.get("source_fingerprint", "")) != current_fingerprint:
			record["source_fingerprint"] = current_fingerprint
			changed = true
		if not current_item_id.is_empty() and String(record.get("item_id", "")) != current_item_id:
			record["item_id"] = current_item_id
			changed = true
		records[authoring_key] = record
		if changed:
			updated_keys.append(authoring_key)

	updated_manifest["assets"] = records
	return {
		"manifest": _normalized_manifest(updated_manifest),
		"added_keys": added_keys,
		"updated_keys": updated_keys,
		"ambiguous_paths": ambiguous_paths
	}


static func sync_item_id_associations(
	manifest: Dictionary, associations: Dictionary
) -> Dictionary:
	var updated_manifest: Dictionary = manifest.duplicate(true)
	var records_value: Variant = updated_manifest.get("assets", {})
	var records: Dictionary = records_value as Dictionary if records_value is Dictionary else {}
	var keys: Array[String] = []
	for key_value: Variant in associations.keys():
		keys.append(String(key_value))
	keys.sort()
	var updated_keys: PackedStringArray = []
	var unknown_keys: PackedStringArray = []
	for key: String in keys:
		if not records.has(key):
			unknown_keys.append(key)
			continue
		var record: Dictionary = records[key] as Dictionary
		var item_id: String = String(associations[key])
		if String(record.get("item_id", "")) == item_id:
			continue
		record["item_id"] = item_id
		records[key] = record
		updated_keys.append(key)
	updated_manifest["assets"] = records
	return {
		"manifest": updated_manifest,
		"updated_keys": updated_keys,
		"unknown_keys": unknown_keys
	}


static func review_evidence(record: Dictionary, current_asset: Dictionary) -> Dictionary:
	var scale_review: Dictionary = record.get("scale_review", {}) as Dictionary
	var pose_review: Dictionary = record.get("storage_pose_review", {}) as Dictionary
	var footprint_review: Dictionary = record.get("footprint_review", {}) as Dictionary
	var has_item_definition: bool = bool(current_asset.get("has_item_definition", true))
	var current_fingerprint: String = String(current_asset.get("source_fingerprint", ""))
	var current_rotation: Array = _array_value(current_asset.get("storage_rotation_degrees", []))
	var current_footprint: Array = _array_value(current_asset.get("storage_footprint", []))
	var flags: PackedStringArray = []

	var scale_current: bool = _review_current(scale_review, SCALE_COMPLETED, current_fingerprint)
	if _is_completed(scale_review, SCALE_COMPLETED) and not scale_current:
		flags.append(FLAG_SCALE_STALE)

	var pose_current: bool = false
	if has_item_definition:
		pose_current = _review_current(pose_review, POSE_COMPLETED, current_fingerprint) and _arrays_approximately_equal(
			_array_value(pose_review.get("reviewed_rotation_degrees", [])), current_rotation
		)
		if _is_completed(pose_review, POSE_COMPLETED) and not pose_current:
			flags.append(FLAG_POSE_STALE)

	var footprint_current: bool = false
	if has_item_definition:
		footprint_current = _review_current(footprint_review, FOOTPRINT_COMPLETED, current_fingerprint) \
			and _arrays_equal(_array_value(footprint_review.get("reviewed_footprint", [])), current_footprint) \
			and _arrays_approximately_equal(
				_array_value(footprint_review.get("reviewed_rotation_degrees", [])), current_rotation
			)
		if _is_completed(footprint_review, FOOTPRINT_COMPLETED) and not footprint_current:
			flags.append(FLAG_FOOTPRINT_STALE)

	return {
		"scale_review_status": String(scale_review.get("status", "UNREVIEWED")),
		"scale_review_current": scale_current,
		"storage_pose_review_status": String(pose_review.get("status", "UNREVIEWED")),
		"storage_pose_review_current": pose_current,
		"footprint_review_status": String(footprint_review.get("status", "UNREVIEWED")),
		"footprint_review_current": footprint_current,
		"flags": flags
	}


static func _match_current_asset(
	records: Dictionary,
	current_asset: Dictionary,
	used_keys: Dictionary,
	current_item_counts: Dictionary,
	current_fingerprint_counts: Dictionary
) -> Dictionary:
	var result: Dictionary = {
		"asset": current_asset,
		"authoring_key": "",
		"correlation": "",
		"problem_flag": FLAG_UNTRACKED
	}
	var item_id: String = String(current_asset.get("item_id", ""))
	if not item_id.is_empty() and int(current_item_counts.get(item_id, 0)) == 1:
		var item_keys: Array[String] = _matching_keys(records, "item_id", item_id, used_keys)
		if item_keys.size() == 1:
			result["authoring_key"] = item_keys[0]
			result["correlation"] = "item_id"
			result["problem_flag"] = ""
			return result

	var source_path: String = String(current_asset.get("source_path", ""))
	var path_keys: Array[String] = _matching_keys(records, "source_path", source_path, used_keys)
	if path_keys.size() == 1:
		result["authoring_key"] = path_keys[0]
		result["correlation"] = "source_path"
		result["problem_flag"] = ""
		return result
	if path_keys.size() > 1:
		result["problem_flag"] = FLAG_AMBIGUOUS
		return result

	var fingerprint: String = String(current_asset.get("source_fingerprint", ""))
	if fingerprint.is_empty():
		return result
	var fingerprint_keys: Array[String] = _matching_keys(records, "source_fingerprint", fingerprint, used_keys)
	if fingerprint_keys.size() == 1 and int(current_fingerprint_counts.get(fingerprint, 0)) == 1:
		result["authoring_key"] = fingerprint_keys[0]
		result["correlation"] = "fingerprint"
		result["problem_flag"] = FLAG_PATH_STALE
		return result
	if fingerprint_keys.size() > 0:
		result["problem_flag"] = FLAG_AMBIGUOUS
	return result


static func _matching_keys(records: Dictionary, field: String, value: String, used_keys: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key_value: Variant in records.keys():
		var key: String = String(key_value)
		if used_keys.has(key):
			continue
		var record: Dictionary = records[key] as Dictionary
		if String(record.get(field, "")) == value:
			keys.append(key)
	keys.sort()
	return keys


static func _current_value_counts(current_assets: Array[Dictionary], field: String) -> Dictionary:
	var counts: Dictionary = {}
	for asset: Dictionary in current_assets:
		var value: String = String(asset.get(field, ""))
		if not value.is_empty():
			counts[value] = int(counts.get(value, 0)) + 1
	return counts


static func _review_current(review: Dictionary, completed_states: PackedStringArray, fingerprint: String) -> bool:
	return _is_completed(review, completed_states) and String(review.get("reviewed_source_fingerprint", "")) == fingerprint


static func _is_completed(review: Dictionary, completed_states: PackedStringArray) -> bool:
	return completed_states.has(String(review.get("status", "UNREVIEWED")))


static func _arrays_equal(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for index: int in range(left.size()):
		if int(left[index]) != int(right[index]):
			return false
	return true


static func _arrays_approximately_equal(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for index: int in range(left.size()):
		if absf(float(left[index]) - float(right[index])) > FLOAT_TOLERANCE:
			return false
	return true


static func _array_value(value: Variant) -> Array:
	return value as Array if value is Array else []


static func _highest_key_suffix(records: Dictionary) -> int:
	var highest: int = 0
	for key_value: Variant in records.keys():
		var key: String = String(key_value)
		if not key.begins_with("loot_"):
			continue
		var suffix: String = key.trim_prefix("loot_")
		if suffix.is_valid_int():
			highest = maxi(highest, suffix.to_int())
	return highest


static func _normalized_manifest(manifest: Dictionary) -> Dictionary:
	var raw_assets: Dictionary = manifest.get("assets", {}) as Dictionary
	var keys: Array[String] = []
	for key_value: Variant in raw_assets.keys():
		keys.append(String(key_value))
	keys.sort()
	var assets: Dictionary = {}
	for key: String in keys:
		assets[key] = _normalized_record(raw_assets[key] as Dictionary)
	return {"schema_version": SCHEMA_VERSION, "assets": assets}


static func _normalized_record(record: Dictionary) -> Dictionary:
	var scale_review: Dictionary = record.get("scale_review", {}) as Dictionary
	var pose_review: Dictionary = record.get("storage_pose_review", {}) as Dictionary
	var footprint_review: Dictionary = record.get("footprint_review", {}) as Dictionary
	return {
		"source_path": String(record.get("source_path", "")),
		"item_id": String(record.get("item_id", "")),
		"source_fingerprint": String(record.get("source_fingerprint", "")),
		"scale_review": {
			"status": String(scale_review.get("status", "UNREVIEWED")),
			"reviewed_source_fingerprint": String(scale_review.get("reviewed_source_fingerprint", "")),
			"notes": String(scale_review.get("notes", ""))
		},
		"storage_pose_review": {
			"status": String(pose_review.get("status", "UNREVIEWED")),
			"reviewed_source_fingerprint": String(pose_review.get("reviewed_source_fingerprint", "")),
			"reviewed_rotation_degrees": _rotation_array(pose_review.get("reviewed_rotation_degrees", [])),
			"notes": String(pose_review.get("notes", ""))
		},
		"footprint_review": {
			"status": String(footprint_review.get("status", "UNREVIEWED")),
			"reviewed_source_fingerprint": String(footprint_review.get("reviewed_source_fingerprint", "")),
			"reviewed_footprint": _footprint_array(footprint_review.get("reviewed_footprint", [])),
			"reviewed_rotation_degrees": _rotation_array(footprint_review.get("reviewed_rotation_degrees", [])),
			"notes": String(footprint_review.get("notes", ""))
		}
	}


static func _rotation_array(value: Variant) -> Array:
	var source: Array = _array_value(value)
	var result: Array[float] = []
	for index: int in range(3):
		result.append(float(source[index]) if index < source.size() else 0.0)
	return result


static func _footprint_array(value: Variant) -> Array:
	var source: Array = _array_value(value)
	var result: Array[int] = []
	for index: int in range(3):
		result.append(int(source[index]) if index < source.size() else 0)
	return result
