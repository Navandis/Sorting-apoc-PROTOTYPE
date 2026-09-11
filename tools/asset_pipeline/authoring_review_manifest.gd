extends RefCounted
class_name AuthoringReviewManifest

const AutoStackGroupRegistryScript = preload("res://tools/asset_pipeline/auto_stack_group_registry.gd")

const SCHEMA_VERSION: String = "2.0"
const LEGACY_SCHEMA_VERSION: String = "1.0"
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
const POSE_APPROVED: PackedStringArray = ["DEFAULT_POSE_APPROVED", "CUSTOM_POSE_APPROVED"]
const FOOTPRINT_COMPLETED: PackedStringArray = ["GEOMETRY_APPROVED", "OVERRIDE_APPROVED"]
const STACK_REVIEW_STATUSES: PackedStringArray = ["UNREVIEWED", "APPROVED"]
const STACK_ROLE_REVIEW_FLAGS: PackedStringArray = [
	"IRREGULAR_SHAPE",
	"SUPPORT_SURFACE_AMBIGUOUS",
	"RESTING_STABILITY_AMBIGUOUS",
	"SOFT_OR_DEFORMABLE_FORM",
	"POSE_DEPENDENT",
	"VISUAL_REVIEW_RECOMMENDED"
]
const AUTO_GROUP_REVIEW_FLAGS: PackedStringArray = [
	"NEW_GROUP_CANDIDATE",
	"GROUP_MEMBERSHIP_AMBIGUOUS",
	"PLAYER_EXPECTATION_AMBIGUOUS",
	"CROSS_CATEGORY_REVIEW",
	"VISUAL_REVIEW_RECOMMENDED"
]


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
		},
		"stack_role_review": _new_stack_role_review(),
		"auto_group_review": _new_auto_group_review()
	}


static func migrate_manifest(manifest: Dictionary) -> Dictionary:
	var schema_version: String = String(manifest.get("schema_version", ""))
	if schema_version != LEGACY_SCHEMA_VERSION and schema_version != SCHEMA_VERSION:
		push_error("Unsupported authoring review manifest schema: %s" % schema_version)
		return empty_manifest()
	return _normalized_manifest(manifest)


static func validate_manifest(manifest: Dictionary) -> PackedStringArray:
	var errors: PackedStringArray = []
	var schema_version: String = String(manifest.get("schema_version", ""))
	if schema_version != LEGACY_SCHEMA_VERSION and schema_version != SCHEMA_VERSION:
		errors.append("Unsupported manifest schema_version: %s" % schema_version)
		return errors
	var assets_value: Variant = manifest.get("assets", {})
	if not (assets_value is Dictionary):
		errors.append("Manifest assets must be a Dictionary.")
		return errors
	if schema_version == LEGACY_SCHEMA_VERSION:
		return errors
	var assets: Dictionary = assets_value as Dictionary
	for key_value: Variant in assets.keys():
		var key: String = String(key_value)
		var record_value: Variant = assets[key_value]
		if not (record_value is Dictionary):
			errors.append("%s record must be a Dictionary." % key)
			continue
		var record: Dictionary = record_value as Dictionary
		var stack_role_value: Variant = record.get("stack_role_review", {})
		_validate_new_review(
			key,
			"stack_role_review",
			stack_role_value,
			STACK_ROLE_REVIEW_FLAGS,
			"Stack Role",
			errors
		)
		if stack_role_value is Dictionary:
			_validate_stack_role_snapshot_fields(
				"%s.stack_role_review" % key,
				stack_role_value as Dictionary,
				errors
			)
		var auto_group_value: Variant = record.get("auto_group_review", {})
		_validate_new_review(
			key,
			"auto_group_review",
			auto_group_value,
			AUTO_GROUP_REVIEW_FLAGS,
			"Auto Group",
			errors
		)
		if auto_group_value is Dictionary:
			_validate_auto_group_snapshot_fields(
				"%s.auto_group_review" % key,
				auto_group_value as Dictionary,
				errors
			)
	return errors


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
	var schema_version: String = String(manifest.get("schema_version", ""))
	if schema_version != LEGACY_SCHEMA_VERSION and schema_version != SCHEMA_VERSION:
		push_error("Unsupported authoring review manifest schema: %s" % path)
		return empty_manifest()
	if not (manifest.get("assets", {}) is Dictionary):
		manifest["assets"] = {}
	return migrate_manifest(manifest)


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
		if String(record.get("source_path", "")) != current_path:
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


static func apply_scale_review_reconciliation(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	normalized_item_ids: PackedStringArray
) -> Dictionary:
	var sync_result: Dictionary = seed_or_sync(manifest, current_assets)
	var updated_manifest: Dictionary = sync_result["manifest"] as Dictionary
	var errors: PackedStringArray = []
	var approved_keys: PackedStringArray = []
	var unreviewed_keys: PackedStringArray = []
	var matches: Array[Dictionary] = correlate_current_assets(updated_manifest, current_assets)
	var found_normalized_ids: Dictionary = {}

	for match: Dictionary in matches:
		var authoring_key: String = String(match.get("authoring_key", ""))
		var problem_flag: String = String(match.get("problem_flag", ""))
		var asset: Dictionary = match.get("asset", {}) as Dictionary
		var item_id: String = String(asset.get("item_id", ""))
		if authoring_key.is_empty() or not problem_flag.is_empty() or item_id.is_empty():
			errors.append("Unable to reconcile review state for %s." % String(asset.get("source_path", "")))
			continue
		var record: Dictionary = (updated_manifest["assets"] as Dictionary)[authoring_key] as Dictionary
		var scale_review: Dictionary = record["scale_review"] as Dictionary
		if normalized_item_ids.has(item_id):
			found_normalized_ids[item_id] = true
			scale_review["status"] = "UNREVIEWED"
			scale_review["reviewed_source_fingerprint"] = ""
			scale_review["notes"] = "Normalized after initial scale review; pending in-game recheck."
			unreviewed_keys.append(authoring_key)
		else:
			scale_review["status"] = "APPROVED"
			scale_review["reviewed_source_fingerprint"] = String(asset.get("source_fingerprint", ""))
			approved_keys.append(authoring_key)
		record["scale_review"] = scale_review
		(updated_manifest["assets"] as Dictionary)[authoring_key] = record

	for item_id: String in normalized_item_ids:
		if not found_normalized_ids.has(item_id):
			errors.append("Normalized item ID not found in current main-scene assets: %s" % item_id)

	return {
		"manifest": _normalized_manifest(updated_manifest),
		"approved_keys": approved_keys,
		"unreviewed_keys": unreviewed_keys,
		"errors": errors
	}


static func apply_auto_group_approvals(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary,
	decisions: Dictionary
) -> Dictionary:
	var errors: PackedStringArray = validate_manifest(manifest)
	errors.append_array(AutoStackGroupRegistryScript.validate_registry(registry))
	if not errors.is_empty():
		return {
			"manifest": manifest.duplicate(true),
			"approved_item_ids": PackedStringArray(),
			"errors": errors
		}
	var updated_manifest: Dictionary = migrate_manifest(manifest)
	var records: Dictionary = updated_manifest["assets"] as Dictionary
	var assets_by_id: Dictionary = {}
	for asset: Dictionary in current_assets:
		var item_id: String = String(asset.get("item_id", ""))
		if assets_by_id.has(item_id):
			errors.append("Duplicate current Auto Group asset item ID: %s" % item_id)
		assets_by_id[item_id] = asset
	var record_keys_by_id: Dictionary = {}
	for key_value: Variant in records.keys():
		var authoring_key: String = String(key_value)
		var record: Dictionary = records[authoring_key] as Dictionary
		var item_id: String = String(record.get("item_id", ""))
		if record_keys_by_id.has(item_id):
			errors.append("Duplicate manifest Auto Group item ID: %s" % item_id)
		record_keys_by_id[item_id] = authoring_key

	var ordered_item_ids: PackedStringArray = []
	for item_id_value: Variant in decisions.keys():
		ordered_item_ids.append(String(item_id_value))
	ordered_item_ids.sort()
	var newly_approved_item_ids: PackedStringArray = []
	var approval_assets_by_id: Dictionary = {}
	for item_id: String in ordered_item_ids:
		var group_id: String = String(decisions[item_id])
		for message: String in AutoStackGroupRegistryScript.validate_reference(group_id, registry):
			errors.append("%s: %s" % [item_id, message])
		if not assets_by_id.has(item_id) or not record_keys_by_id.has(item_id):
			errors.append("Auto Group approval target is missing: %s" % item_id)
			continue
		var asset: Dictionary = assets_by_id[item_id] as Dictionary
		var record_key: String = String(record_keys_by_id[item_id])
		var record: Dictionary = records[record_key] as Dictionary
		var evidence: Dictionary = review_evidence(record, asset, registry)
		if not bool(evidence["stack_role_review_current"]):
			errors.append("Auto Group approval target lacks a current Stack Role: %s" % item_id)
			continue
		var review: Dictionary = record["auto_group_review"] as Dictionary
		var status: String = String(review.get("status", "UNREVIEWED"))
		if status == "APPROVED":
			if String(review.get("reviewed_auto_stack_group", "")) != group_id:
				errors.append("Existing Auto Group approval conflicts with the decision for %s." % item_id)
			elif String(asset.get("auto_stack_group", "")) != group_id:
				errors.append("Current Auto Group does not match the approved decision for %s." % item_id)
			elif not bool(evidence["auto_group_review_current"]):
				errors.append("Auto Group existing approval is stale for %s." % item_id)
			continue
		if status != "UNREVIEWED":
			errors.append("Unsupported Auto Group review status for %s: %s" % [item_id, status])
			continue
		var current_group: String = String(asset.get("auto_stack_group", ""))
		if not current_group.is_empty() and current_group != group_id:
			errors.append("Current Auto Group does not match the approved decision for %s." % item_id)
			continue
		var approval_asset: Dictionary = asset.duplicate(true)
		approval_asset["auto_stack_group"] = group_id
		approval_assets_by_id[item_id] = approval_asset
		newly_approved_item_ids.append(item_id)

	if not errors.is_empty():
		return {
			"manifest": manifest.duplicate(true),
			"approved_item_ids": PackedStringArray(),
			"errors": errors
		}

	for item_id: String in newly_approved_item_ids:
		var group_id: String = String(decisions[item_id])
		var record_key: String = String(record_keys_by_id[item_id])
		var record: Dictionary = records[record_key] as Dictionary
		var review: Dictionary = record["auto_group_review"] as Dictionary
		review["status"] = "APPROVED"
		review["reviewed_stack_role_snapshot"] = stack_role_snapshot(
			approval_assets_by_id[item_id] as Dictionary
		)
		review["reviewed_auto_stack_group"] = group_id
		review["reviewed_registry_compatibility_revision"] = (
			0 if group_id.is_empty()
			else AutoStackGroupRegistryScript.compatibility_revision(group_id, registry)
		)
		review["flags"] = []
		review["notes"] = (
			"Human-approved explicit None."
			if group_id.is_empty()
			else "Human-approved existing Auto Stack Group."
		)
		record["auto_group_review"] = review
		records[record_key] = record
	updated_manifest["assets"] = records

	for item_id: String in newly_approved_item_ids:
		var record: Dictionary = records[String(record_keys_by_id[item_id])] as Dictionary
		if not bool(review_evidence(
			record, approval_assets_by_id[item_id] as Dictionary, registry
		)["auto_group_review_current"]):
			errors.append("Auto Group approval did not become current: %s" % item_id)
	errors.append_array(validate_manifest(updated_manifest))
	if not errors.is_empty():
		return {
			"manifest": manifest.duplicate(true),
			"approved_item_ids": PackedStringArray(),
			"errors": errors
		}
	return {
		"manifest": _normalized_manifest(updated_manifest),
		"approved_item_ids": ordered_item_ids,
		"errors": errors
	}


static func review_evidence(
	record: Dictionary,
	current_asset: Dictionary,
	registry: Dictionary = {}
) -> Dictionary:
	var scale_review: Dictionary = record.get("scale_review", {}) as Dictionary
	var pose_review: Dictionary = record.get("storage_pose_review", {}) as Dictionary
	var footprint_review: Dictionary = record.get("footprint_review", {}) as Dictionary
	var stack_role_review: Dictionary = record.get("stack_role_review", {}) as Dictionary
	var auto_group_review: Dictionary = record.get("auto_group_review", {}) as Dictionary
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
		var pose_status: String = String(pose_review.get("status", "UNREVIEWED"))
		var pose_fingerprint_current: bool = _review_current(
			pose_review,
			POSE_COMPLETED,
			current_fingerprint
		)
		if pose_status == "CUSTOM_POSE_REQUIRED":
			pose_current = pose_fingerprint_current
		elif POSE_APPROVED.has(pose_status):
			pose_current = pose_fingerprint_current and _arrays_approximately_equal(
				_array_value(pose_review.get("reviewed_rotation_degrees", [])),
				current_rotation
			)
		if _is_completed(pose_review, POSE_COMPLETED) and not pose_current:
			flags.append(FLAG_POSE_STALE)

	var footprint_current: bool = false
	if has_item_definition:
		var pose_approved_for_footprint: bool = pose_current and POSE_APPROVED.has(
			String(pose_review.get("status", "UNREVIEWED"))
		)
		footprint_current = pose_approved_for_footprint \
			and _review_current(footprint_review, FOOTPRINT_COMPLETED, current_fingerprint) \
			and _arrays_equal(_array_value(footprint_review.get("reviewed_footprint", [])), current_footprint) \
			and _arrays_approximately_equal(
				_array_value(footprint_review.get("reviewed_rotation_degrees", [])), current_rotation
			)
		if _is_completed(footprint_review, FOOTPRINT_COMPLETED) and not footprint_current:
			flags.append(FLAG_FOOTPRINT_STALE)

	var stack_role_status: String = String(stack_role_review.get("status", "UNREVIEWED"))
	var stack_role_eligible: bool = (
		pose_current
		and POSE_APPROVED.has(String(pose_review.get("status", "UNREVIEWED")))
		and footprint_current
	)
	var current_stack_role_snapshot: Dictionary = stack_role_snapshot(current_asset)
	var stack_role_current: bool = (
		stack_role_status == "APPROVED"
		and stack_role_eligible
		and _stack_role_review_matches_snapshot(stack_role_review, current_stack_role_snapshot)
	)
	var stack_role_stale: bool = stack_role_status == "APPROVED" and not stack_role_current

	var auto_group_status: String = String(auto_group_review.get("status", "UNREVIEWED"))
	var auto_group_eligible: bool = stack_role_current
	var current_group: String = String(current_asset.get("auto_stack_group", ""))
	var reference_errors: PackedStringArray = AutoStackGroupRegistryScript.validate_reference(
		current_group,
		registry
	)
	var reference_valid: bool = reference_errors.is_empty()
	var current_revision: int = (
		0 if current_group.is_empty()
		else AutoStackGroupRegistryScript.compatibility_revision(current_group, registry)
	)
	var reviewed_stack_snapshot: Dictionary = _normalized_stack_role_snapshot(
		auto_group_review.get("reviewed_stack_role_snapshot", {})
	)
	var auto_group_current: bool = (
		auto_group_status == "APPROVED"
		and auto_group_eligible
		and reference_valid
		and String(auto_group_review.get("reviewed_auto_stack_group", "")) == current_group
		and reviewed_stack_snapshot == current_stack_role_snapshot
		and int(auto_group_review.get("reviewed_registry_compatibility_revision", 0)) == current_revision
	)
	var auto_group_stale: bool = auto_group_status == "APPROVED" and not auto_group_current

	return {
		"scale_review_status": String(scale_review.get("status", "UNREVIEWED")),
		"scale_review_current": scale_current,
		"storage_pose_review_status": String(pose_review.get("status", "UNREVIEWED")),
		"storage_pose_review_current": pose_current,
		"footprint_review_status": String(footprint_review.get("status", "UNREVIEWED")),
		"footprint_review_current": footprint_current,
		"stack_role_review_status": stack_role_status,
		"stack_role_review_eligible": stack_role_eligible,
		"stack_role_review_current": stack_role_current,
		"stack_role_review_stale": stack_role_stale,
		"stack_role_review_dependency_blocked": not stack_role_eligible,
		"stack_role_review_flags": _ordered_known_flags(
			stack_role_review.get("flags", []), STACK_ROLE_REVIEW_FLAGS
		),
		"stack_role_review_notes": String(stack_role_review.get("notes", "")),
		"auto_group_review_status": auto_group_status,
		"auto_group_review_eligible": auto_group_eligible,
		"auto_group_review_current": auto_group_current,
		"auto_group_review_stale": auto_group_stale,
		"auto_group_review_dependency_blocked": not auto_group_eligible,
		"auto_group_review_flags": _ordered_known_flags(
			auto_group_review.get("flags", []), AUTO_GROUP_REVIEW_FLAGS
		),
		"auto_group_review_notes": String(auto_group_review.get("notes", "")),
		"auto_group_reference_valid": reference_valid,
		"auto_group_reference_errors": reference_errors,
		"auto_group_registry_compatibility_revision": current_revision,
		"auto_group_reviewed_registry_compatibility_revision": int(
			auto_group_review.get("reviewed_registry_compatibility_revision", 0)
		),
		"flags": flags
	}


static func stack_role_snapshot(current_asset: Dictionary) -> Dictionary:
	return {
		"reviewed_source_fingerprint": String(current_asset.get("source_fingerprint", "")),
		"reviewed_rotation_degrees": _rotation_array(current_asset.get("storage_rotation_degrees", [])),
		"reviewed_footprint": _footprint_array(current_asset.get("storage_footprint", [])),
		"reviewed_can_be_stacked": bool(current_asset.get("can_be_stacked", false)),
		"reviewed_can_support_stack": bool(current_asset.get("can_support_stack", false))
	}


static func _stack_role_review_matches_snapshot(
	review: Dictionary,
	snapshot: Dictionary
) -> bool:
	return (
		String(review.get("reviewed_source_fingerprint", ""))
			== String(snapshot.get("reviewed_source_fingerprint", ""))
		and _arrays_approximately_equal(
			_array_value(review.get("reviewed_rotation_degrees", [])),
			_array_value(snapshot.get("reviewed_rotation_degrees", []))
		)
		and _arrays_equal(
			_array_value(review.get("reviewed_footprint", [])),
			_array_value(snapshot.get("reviewed_footprint", []))
		)
		and bool(review.get("reviewed_can_be_stacked", false))
			== bool(snapshot.get("reviewed_can_be_stacked", false))
		and bool(review.get("reviewed_can_support_stack", false))
			== bool(snapshot.get("reviewed_can_support_stack", false))
	)


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
	var stack_role_value: Variant = record.get("stack_role_review", {})
	var stack_role_review: Dictionary = (
		stack_role_value as Dictionary if stack_role_value is Dictionary else {}
	)
	var auto_group_value: Variant = record.get("auto_group_review", {})
	var auto_group_review: Dictionary = (
		auto_group_value as Dictionary if auto_group_value is Dictionary else {}
	)
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
		},
		"stack_role_review": {
			"status": String(stack_role_review.get("status", "UNREVIEWED")),
			"reviewed_source_fingerprint": String(stack_role_review.get("reviewed_source_fingerprint", "")),
			"reviewed_rotation_degrees": _rotation_array(stack_role_review.get("reviewed_rotation_degrees", [])),
			"reviewed_footprint": _footprint_array(stack_role_review.get("reviewed_footprint", [])),
			"reviewed_can_be_stacked": bool(stack_role_review.get("reviewed_can_be_stacked", false)),
			"reviewed_can_support_stack": bool(stack_role_review.get("reviewed_can_support_stack", false)),
			"flags": _ordered_known_flags(stack_role_review.get("flags", []), STACK_ROLE_REVIEW_FLAGS),
			"notes": String(stack_role_review.get("notes", ""))
		},
		"auto_group_review": {
			"status": String(auto_group_review.get("status", "UNREVIEWED")),
			"reviewed_stack_role_snapshot": _normalized_stack_role_snapshot(
				auto_group_review.get("reviewed_stack_role_snapshot", {})
			),
			"reviewed_auto_stack_group": String(auto_group_review.get("reviewed_auto_stack_group", "")),
			"reviewed_registry_compatibility_revision": int(auto_group_review.get("reviewed_registry_compatibility_revision", 0)),
			"flags": _ordered_known_flags(auto_group_review.get("flags", []), AUTO_GROUP_REVIEW_FLAGS),
			"notes": String(auto_group_review.get("notes", ""))
		}
	}


static func _new_stack_role_review() -> Dictionary:
	return {
		"status": "UNREVIEWED",
		"reviewed_source_fingerprint": "",
		"reviewed_rotation_degrees": [0.0, 0.0, 0.0],
		"reviewed_footprint": [0, 0, 0],
		"reviewed_can_be_stacked": false,
		"reviewed_can_support_stack": false,
		"flags": [],
		"notes": ""
	}


static func _new_auto_group_review() -> Dictionary:
	return {
		"status": "UNREVIEWED",
		"reviewed_stack_role_snapshot": {},
		"reviewed_auto_stack_group": "",
		"reviewed_registry_compatibility_revision": 0,
		"flags": [],
		"notes": ""
	}


static func _normalized_stack_role_snapshot(value: Variant) -> Dictionary:
	if not (value is Dictionary) or (value as Dictionary).is_empty():
		return {}
	var snapshot: Dictionary = value as Dictionary
	return {
		"reviewed_source_fingerprint": String(snapshot.get("reviewed_source_fingerprint", "")),
		"reviewed_rotation_degrees": _rotation_array(snapshot.get("reviewed_rotation_degrees", [])),
		"reviewed_footprint": _footprint_array(snapshot.get("reviewed_footprint", [])),
		"reviewed_can_be_stacked": bool(snapshot.get("reviewed_can_be_stacked", false)),
		"reviewed_can_support_stack": bool(snapshot.get("reviewed_can_support_stack", false))
	}


static func _ordered_known_flags(value: Variant, vocabulary: PackedStringArray) -> Array[String]:
	var present: Dictionary = {}
	if value is Array:
		for flag_value: Variant in value as Array:
			if flag_value is String:
				present[String(flag_value)] = true
	var result: Array[String] = []
	for flag: String in vocabulary:
		if present.has(flag):
			result.append(flag)
	return result


static func _validate_new_review(
	key: String,
	field: String,
	value: Variant,
	vocabulary: PackedStringArray,
	label: String,
	errors: PackedStringArray
) -> void:
	if not (value is Dictionary):
		errors.append("%s.%s must be a Dictionary." % [key, field])
		return
	var review: Dictionary = value as Dictionary
	var status: String = String(review.get("status", ""))
	if not STACK_REVIEW_STATUSES.has(status):
		errors.append("%s.%s.status is unknown: %s" % [key, field, status])
	var flags_value: Variant = review.get("flags", [])
	if not (flags_value is Array):
		errors.append("%s.%s.flags must be an Array." % [key, field])
	else:
		for flag_value: Variant in flags_value as Array:
			if not (flag_value is String) or not vocabulary.has(String(flag_value)):
				errors.append("Unknown %s flag for %s: %s" % [label, key, str(flag_value)])
	var notes_value: Variant = review.get("notes", "")
	if not (notes_value is String):
		errors.append("%s.%s.notes must be a String." % [key, field])


static func _validate_stack_role_snapshot_fields(
	path: String, snapshot: Dictionary, errors: PackedStringArray
) -> void:
	if not (snapshot.get("reviewed_source_fingerprint", "") is String):
		errors.append("%s.reviewed_source_fingerprint must be a String." % path)
	_validate_three_value_array(
		"%s.reviewed_rotation_degrees" % path,
		snapshot.get("reviewed_rotation_degrees", []),
		false,
		errors
	)
	_validate_three_value_array(
		"%s.reviewed_footprint" % path,
		snapshot.get("reviewed_footprint", []),
		true,
		errors
	)
	if not (snapshot.get("reviewed_can_be_stacked", false) is bool):
		errors.append("%s.reviewed_can_be_stacked must be a bool." % path)
	if not (snapshot.get("reviewed_can_support_stack", false) is bool):
		errors.append("%s.reviewed_can_support_stack must be a bool." % path)


static func _validate_auto_group_snapshot_fields(
	path: String, review: Dictionary, errors: PackedStringArray
) -> void:
	var snapshot_value: Variant = review.get("reviewed_stack_role_snapshot", {})
	if not (snapshot_value is Dictionary):
		errors.append("%s.reviewed_stack_role_snapshot must be a Dictionary." % path)
	elif not (snapshot_value as Dictionary).is_empty():
		_validate_stack_role_snapshot_fields(
			"%s.reviewed_stack_role_snapshot" % path,
			snapshot_value as Dictionary,
			errors
		)
	if not (review.get("reviewed_auto_stack_group", "") is String):
		errors.append("%s.reviewed_auto_stack_group must be a String." % path)
	var revision_value: Variant = review.get("reviewed_registry_compatibility_revision", 0)
	var revision_number: float = (
		float(revision_value)
		if revision_value is int or revision_value is float
		else -1.0
	)
	if revision_number < 0.0 or revision_number != floorf(revision_number):
		errors.append(
			"%s.reviewed_registry_compatibility_revision must be a non-negative integer."
			% path
		)


static func _validate_three_value_array(
	path: String,
	value: Variant,
	integers_only: bool,
	errors: PackedStringArray
) -> void:
	if not (value is Array) or (value as Array).size() != 3:
		errors.append("%s must be a three-value Array." % path)
		return
	for component: Variant in value as Array:
		if integers_only:
			if not (component is int) and not (component is float):
				errors.append("%s must contain integers." % path)
				return
			var component_number: float = float(component)
			if component_number != floorf(component_number):
				errors.append("%s must contain integers." % path)
				return
		elif not (component is int) and not (component is float):
			errors.append("%s must contain numbers." % path)
			return


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
