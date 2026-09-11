extends RefCounted
class_name StackRoleAuthoring

## One-time Phase 1 migration/seed evidence for the 42-item prototype catalogue.
## Future catalogue additions must use the reusable manifest review pipeline and
## must never be added to this closed migration table.

const AuthoringReviewManifestScript = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const AutoStackGroupRegistryScript = preload("res://tools/asset_pipeline/auto_stack_group_registry.gd")

const BLOCKED_ITEM_IDS: PackedStringArray = ["loot_000034", "loot_000036"]
const BATCH_ONE_ITEM_IDS: PackedStringArray = [
	"loot_000003", "loot_000007", "loot_000020", "loot_000021"
]
const BATCH_TWO_ITEM_IDS: PackedStringArray = [
	"loot_000008", "loot_000010", "loot_000015", "loot_000016", "loot_000017",
	"loot_000018", "loot_000022", "loot_000023", "loot_000024", "loot_000025",
	"loot_000027"
]
const BATCH_THREE_ITEM_IDS: PackedStringArray = [
	"loot_000001", "loot_000004", "loot_000012", "loot_000014", "loot_000029",
	"loot_000033", "loot_000035"
]
const BATCH_FOUR_ITEM_IDS: PackedStringArray = [
	"loot_000011", "loot_000026", "loot_000032"
]
const BATCH_FIVE_ITEM_IDS: PackedStringArray = ["loot_000013", "loot_000037", "loot_000038", "loot_000040", "loot_000041", "loot_000042"]
const BATCH_ONE_APPROVAL_NOTES: Dictionary = {
	"loot_000003": "Flat stable base; irregular exposed-electronics top is not a credible support surface."
}
const BATCH_TWO_REVIEWED_ROLES: Dictionary = {
	"loot_000008": [true, true], "loot_000010": [true, true],
	"loot_000015": [true, false], "loot_000016": [true, false],
	"loot_000017": [true, false], "loot_000018": [true, false],
	"loot_000022": [true, true], "loot_000023": [true, true],
	"loot_000024": [true, false], "loot_000025": [true, false],
	"loot_000027": [true, false]
}
const BATCH_TWO_APPROVAL_NOTES: Dictionary = {
	"loot_000024": "Credible resting base; top is too small to be a meaningful generic centered support surface.",
	"loot_000025": "Credible resting base; top is too small to be a meaningful generic centered support surface.",
	"loot_000027": "Credible resting base; upper form is not a credible generic support surface."
}
const BATCH_THREE_REVIEWED_ROLES: Dictionary = {
	"loot_000001": [true, false], "loot_000004": [true, false],
	"loot_000012": [true, false], "loot_000014": [false, false],
	"loot_000029": [true, false], "loot_000033": [true, false],
	"loot_000035": [true, false]
}
const BATCH_THREE_APPROVAL_NOTES: Dictionary = {
	"loot_000012": "Credible deterministic resting relationship on a sufficiently large flat support; rounded upper form is not support-capable.",
	"loot_000014": "Loose firewood pile is not a rigid form-retaining stack member.",
	"loot_000029": "Credible deterministic resting relationship on a sufficiently large flat support; curved upper form is not support-capable."
}
const BATCH_FOUR_REVIEWED_ROLES: Dictionary = {"loot_000011": [false, false], "loot_000026": [true, false], "loot_000032": [true, false]}
const BATCH_FOUR_APPROVAL_NOTES: Dictionary = {"loot_000032": "Semi-rigid upright form is physically credible; display practicality resolves the borderline resting judgment, not support capability."}
const BATCH_FIVE_REVIEWED_ROLES: Dictionary = {"loot_000013": [true, false], "loot_000037": [true, false], "loot_000038": [true, false], "loot_000040": [true, false], "loot_000041": [true, false], "loot_000042": [true, false]}
const BATCH_FIVE_APPROVAL_NOTES: Dictionary = {"loot_000041": "Irregular form; current approved pose places the heavy iron head in a credible resting configuration. Stackability is strongly pose-dependent."}
const GRANDFATHERED: Dictionary = {
	"loot_000002": [false, true, ""],
	"loot_000005": [true, true, "boxed_food"],
	"loot_000006": [true, false, ""],
	"loot_000009": [true, true, "round_cans"],
	"loot_000019": [true, true, "round_cans"],
	"loot_000028": [true, true, "medical_boxes"],
	"loot_000030": [true, true, "flat_media"],
	"loot_000031": [true, true, "flat_media"],
	"loot_000039": [true, false, ""]
}
const CANDIDATES: Dictionary = {
	"loot_000001": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "irregular_rigid", "rationale": "The mouse can rest on a broad support, but its curved shell is not a credible upper support surface."},
	"loot_000003": {"can_be_stacked": true, "can_support_stack": false, "flags": ["SUPPORT_SURFACE_AMBIGUOUS", "VISUAL_REVIEW_RECOMMENDED"], "form_batch": "rigid_boxlike", "rationale": "The printer has a stable base, while its output and top geometry are too interrupted to approve support provisionally."},
	"loot_000004": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "irregular_rigid", "rationale": "The desk phone can rest on a broad support, but the sloped handset assembly cannot credibly support another item."},
	"loot_000007": {"can_be_stacked": true, "can_support_stack": true, "flags": [], "form_batch": "rigid_boxlike", "rationale": "The rigid cereal carton has a stable base and a broad flat top suitable for a smaller centered item."},
	"loot_000008": {"can_be_stacked": true, "can_support_stack": true, "flags": [], "form_batch": "cylindrical_container", "rationale": "The small rigid dry-goods can has a stable base and flat lid."},
	"loot_000010": {"can_be_stacked": true, "can_support_stack": true, "flags": [], "form_batch": "cylindrical_container", "rationale": "The taller rigid dry-goods can has a stable base and flat lid."},
	"loot_000011": {"can_be_stacked": false, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS", "SOFT_OR_DEFORMABLE_FORM", "VISUAL_REVIEW_RECOMMENDED"], "form_batch": "soft_irregular", "rationale": "The skewered carcass is irregular and deformable enough that centered support placement is not provisionally credible."},
	"loot_000012": {"can_be_stacked": false, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS"], "form_batch": "irregular_rigid", "rationale": "The round watermelon lacks a stable resting interface for deterministic centered stacking."},
	"loot_000013": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS", "RESTING_STABILITY_AMBIGUOUS"], "form_batch": "long_narrow", "rationale": "The stored log can lie on a broad support, but rolling risk and its uneven top rule out support capability."},
	"loot_000014": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS", "VISUAL_REVIEW_RECOMMENDED"], "form_batch": "irregular_rigid", "rationale": "The firewood pile can rest as a unit, but its uneven logs do not provide a reliable centered upper surface."},
	"loot_000015": {"can_be_stacked": true, "can_support_stack": false, "flags": ["SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "cylindrical_container", "rationale": "The fuel canister has a stable base, while its handle and cap interrupt the upper surface."},
	"loot_000016": {"can_be_stacked": true, "can_support_stack": false, "flags": ["SUPPORT_SURFACE_AMBIGUOUS", "VISUAL_REVIEW_RECOMMENDED"], "form_batch": "cylindrical_container", "rationale": "The gas canister can stand on a broad support, but its top geometry is not safely support-capable."},
	"loot_000017": {"can_be_stacked": true, "can_support_stack": false, "flags": ["SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "cylindrical_container", "rationale": "The cylinder has a stable base ring and a rounded valve top unsuitable for another item."},
	"loot_000018": {"can_be_stacked": true, "can_support_stack": false, "flags": ["SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "cylindrical_container", "rationale": "The propane tank has a stable base but no broad usable upper support surface."},
	"loot_000020": {"can_be_stacked": true, "can_support_stack": false, "flags": ["SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "rigid_boxlike", "rationale": "The milk carton has a stable box-like base, but its folded top is not a credible support."},
	"loot_000021": {"can_be_stacked": true, "can_support_stack": false, "flags": ["SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "rigid_boxlike", "rationale": "The juice carton has a stable box-like base, but its folded top is not a credible support."},
	"loot_000022": {"can_be_stacked": true, "can_support_stack": true, "flags": [], "form_batch": "cylindrical_container", "rationale": "The standard soda can has a stable base and flat rimmed top."},
	"loot_000023": {"can_be_stacked": true, "can_support_stack": true, "flags": [], "form_batch": "cylindrical_container", "rationale": "The alternate standard soda can has a stable base and flat rimmed top."},
	"loot_000024": {"can_be_stacked": true, "can_support_stack": true, "flags": [], "form_batch": "cylindrical_container", "rationale": "The pill bottle has a stable base and broad flat cap suitable for a smaller centered item."},
	"loot_000025": {"can_be_stacked": true, "can_support_stack": true, "flags": [], "form_batch": "cylindrical_container", "rationale": "The medicine bottle has a stable base and flat cap."},
	"loot_000026": {"can_be_stacked": true, "can_support_stack": false, "flags": ["SUPPORT_SURFACE_AMBIGUOUS", "SOFT_OR_DEFORMABLE_FORM"], "form_batch": "soft_irregular", "rationale": "The bandage package can rest on a broad support, but its soft form is not support-capable."},
	"loot_000027": {"can_be_stacked": true, "can_support_stack": true, "flags": ["VISUAL_REVIEW_RECOMMENDED"], "form_batch": "cylindrical_container", "rationale": "The rigid medicine bottle appears to have a stable base and flat cap, pending human confirmation."},
	"loot_000029": {"can_be_stacked": false, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS"], "form_batch": "irregular_rigid", "rationale": "The ball has no stable resting interface for deterministic centered stacking."},
	"loot_000032": {"can_be_stacked": false, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS", "SOFT_OR_DEFORMABLE_FORM", "POSE_DEPENDENT", "VISUAL_REVIEW_RECOMMENDED"], "form_batch": "soft_irregular", "rationale": "Upright body armor is irregular and deformable, so neither centered resting nor upper support is provisionally credible."},
	"loot_000033": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "irregular_rigid", "rationale": "The boot pair can rest on a broad support, but its uneven uppers cannot support another item."},
	"loot_000035": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "irregular_rigid", "rationale": "The hard hat can rest rim-down on a broad support, but its curved crown is not support-capable."},
	"loot_000037": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "long_narrow", "rationale": "The stored claw hammer can lie on a broad support, but its narrow uneven profile cannot support another item."},
	"loot_000038": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "long_narrow", "rationale": "The approved flat rifle pose can rest on a broad support, but the weapon has no usable upper surface."},
	"loot_000040": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS"], "form_batch": "long_narrow", "rationale": "The approved flat shotgun pose can rest on a broad support, but the weapon has no usable upper surface."},
	"loot_000041": {"can_be_stacked": false, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "RESTING_STABILITY_AMBIGUOUS", "POSE_DEPENDENT", "VISUAL_REVIEW_RECOMMENDED"], "form_batch": "long_narrow", "rationale": "The upright flipped hammer pose has too little stable base area for conservative centered stacking."},
	"loot_000042": {"can_be_stacked": true, "can_support_stack": false, "flags": ["IRREGULAR_SHAPE", "SUPPORT_SURFACE_AMBIGUOUS", "SOFT_OR_DEFORMABLE_FORM"], "form_batch": "long_narrow", "rationale": "The flat racket can rest on a broad support, but its string bed is not treated as a rigid support surface."}
}


static func candidate_ids() -> PackedStringArray:
	return _sorted_keys(CANDIDATES)


static func grandfathered_ids() -> PackedStringArray:
	return _sorted_keys(GRANDFATHERED)


static func candidate_for(item_id: String) -> Dictionary:
	if not CANDIDATES.has(item_id):
		return {}
	return (CANDIDATES[item_id] as Dictionary).duplicate(true)


static func batch_one_rows(records: Array[Dictionary]) -> Array[Dictionary]:
	return _batch_rows(records, BATCH_ONE_ITEM_IDS)


static func batch_two_rows(records: Array[Dictionary]) -> Array[Dictionary]:
	return _batch_rows(records, BATCH_TWO_ITEM_IDS)


static func batch_three_rows(records: Array[Dictionary]) -> Array[Dictionary]:
	return _batch_rows(records, BATCH_THREE_ITEM_IDS)


static func batch_four_rows(records: Array[Dictionary]) -> Array[Dictionary]:
	return _batch_rows(records, BATCH_FOUR_ITEM_IDS)

static func batch_five_rows(records: Array[Dictionary]) -> Array[Dictionary]:
	return _batch_rows(records, BATCH_FIVE_ITEM_IDS)


static func _batch_rows(
	records: Array[Dictionary], item_ids: PackedStringArray
) -> Array[Dictionary]:
	var by_id: Dictionary = {}
	for record: Dictionary in records:
		by_id[String(record.get("item_id", ""))] = record
	var rows: Array[Dictionary] = []
	for item_id: String in item_ids:
		if not by_id.has(item_id):
			continue
		var record: Dictionary = by_id[item_id] as Dictionary
		var candidate: Dictionary = candidate_for(item_id)
		rows.append({
			"item_id": item_id,
			"display_name": String(record.get("display_name", "")),
			"source_path": String(record.get("source_path", "")),
			"storage_category": String(record.get("authored_category", "")),
			"storage_footprint": (record.get("storage_footprint", []) as Array).duplicate(),
			"storage_rotation_degrees": (record.get("storage_rotation_degrees", []) as Array).duplicate(),
			"can_be_stacked": bool(candidate["can_be_stacked"]),
			"can_support_stack": bool(candidate["can_support_stack"]),
			"flags": (candidate["flags"] as Array).duplicate(),
			"rationale": String(candidate["rationale"])
		})
	return rows


static func batch_one_markdown(records: Array[Dictionary]) -> String:
	return _batch_markdown(
		"Batch 1",
		"rigid flat / box-like packages and appliances.",
		batch_one_rows(records)
	)


static func batch_two_markdown(records: Array[Dictionary]) -> String:
	return _batch_markdown(
		"Batch 2",
		"cylindrical / container-like items.",
		batch_two_rows(records)
	)


static func batch_three_markdown(records: Array[Dictionary]) -> String:
	return _batch_markdown(
		"Batch 3",
		"irregular rigid items.",
		batch_three_rows(records)
	)


static func batch_four_markdown(records: Array[Dictionary]) -> String:
	return _batch_markdown(
		"Batch 4",
		"soft / apparel-like items.",
		batch_four_rows(records)
	)

static func batch_five_markdown(records: Array[Dictionary]) -> String:
	return _batch_markdown("Batch 5", "long / narrow items.", batch_five_rows(records))


static func _batch_markdown(
	batch_label: String, physical_form: String, rows: Array[Dictionary]
) -> String:
	var lines: PackedStringArray = [
		"# Stack Role Authoring Review — %s" % batch_label,
		"",
		"Physical form: %s" % physical_form,
		"",
		"| Stable ID | Display / asset | Storage Category | Approved Footprint | Approved rotation | Stackable | Supports | Flags | Rationale |",
		"|---|---|---|---|---|---:|---:|---|---|"
	]
	for row: Dictionary in rows:
		var asset_name: String = String(row["source_path"]).get_file()
		lines.append("| `%s` | %s / `%s` | %s | `%s` | `%s` | %s | %s | %s | %s |" % [
			String(row["item_id"]),
			_markdown_cell(String(row["display_name"])),
			_markdown_cell(asset_name),
			_markdown_cell(String(row["storage_category"])),
			_vector_text(row["storage_footprint"] as Array, "x"),
			_vector_text(row["storage_rotation_degrees"] as Array, ", "),
			str(bool(row["can_be_stacked"])).to_lower(),
			str(bool(row["can_support_stack"])).to_lower(),
			", ".join(PackedStringArray(row["flags"] as Array)) if not (row["flags"] as Array).is_empty() else "—",
			_markdown_cell(String(row["rationale"]))
		])
	lines.append_array(PackedStringArray([
		"", "## Response contract", "",
		"`loot_XXXXXX — APPROVE`  ",
		"`loot_XXXXXX — ADJUST: true / false`  ",
		"`loot_XXXXXX — HOLD`", ""
	]))
	return "\n".join(lines)


static func _vector_text(values: Array, separator: String) -> String:
	var parts: PackedStringArray = []
	for value: Variant in values:
		var number: float = float(value)
		parts.append(str(int(number)) if number == floorf(number) else str(number))
	return separator.join(parts)


static func _markdown_cell(value: String) -> String:
	return value.replace("|", "\\|").replace("\n", " ")


static func apply_phase_1(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary
) -> Dictionary:
	var errors: PackedStringArray = _preflight_errors(manifest, current_assets, registry)
	if not errors.is_empty():
		return {
			"manifest": manifest.duplicate(true),
			"candidate_values": {},
			"counts": {},
			"errors": errors
		}

	var updated_manifest: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = updated_manifest["assets"] as Dictionary
	var assets_by_id: Dictionary = _assets_by_id(current_assets)
	var authoring_keys_by_id: Dictionary = _authoring_keys_by_item_id(
		updated_manifest, current_assets
	)
	var candidate_values: Dictionary = {}

	for item_id: String in grandfathered_ids():
		var asset: Dictionary = assets_by_id[item_id] as Dictionary
		var authoring_key: String = String(authoring_keys_by_id[item_id])
		var record: Dictionary = records[authoring_key] as Dictionary
		var role_review: Dictionary = record["stack_role_review"] as Dictionary
		if String(role_review["status"]) == "UNREVIEWED":
			role_review["status"] = "APPROVED"
			_copy_snapshot_into_review(role_review, AuthoringReviewManifestScript.stack_role_snapshot(asset))
			role_review["flags"] = []
			role_review["notes"] = "Grandfathered from focused deterministic support-stacking technical and human validation."
		var auto_review: Dictionary = record["auto_group_review"] as Dictionary
		if String(auto_review["status"]) == "UNREVIEWED":
			auto_review["status"] = "APPROVED"
			auto_review["reviewed_stack_role_snapshot"] = AuthoringReviewManifestScript.stack_role_snapshot(asset)
			var group_id: String = String(asset["auto_stack_group"])
			auto_review["reviewed_auto_stack_group"] = group_id
			auto_review["reviewed_registry_compatibility_revision"] = (
				0 if group_id.is_empty()
				else AutoStackGroupRegistryScript.compatibility_revision(group_id, registry)
			)
			auto_review["flags"] = []
			auto_review["notes"] = "Grandfathered from focused deterministic support-stacking technical and human validation."
		records[authoring_key] = record

	for item_id: String in candidate_ids():
		var candidate: Dictionary = candidate_for(item_id)
		var authoring_key: String = String(authoring_keys_by_id[item_id])
		var record: Dictionary = records[authoring_key] as Dictionary
		var role_review: Dictionary = record["stack_role_review"] as Dictionary
		role_review["flags"] = (candidate["flags"] as Array).duplicate()
		role_review["notes"] = String(candidate["rationale"])
		records[authoring_key] = record
		candidate_values[item_id] = {
			"definition_path": String((assets_by_id[item_id] as Dictionary).get("definition_path", "")),
			"can_be_stacked": bool(candidate["can_be_stacked"]),
			"can_support_stack": bool(candidate["can_support_stack"])
		}

	return {
		"manifest": AuthoringReviewManifestScript.migrate_manifest(updated_manifest),
		"candidate_values": candidate_values,
		"counts": {"grandfathered": 9, "candidates": 31, "blocked": 2},
		"errors": errors
	}


static func apply_stack_role_batch_1(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary
) -> Dictionary:
	var errors: PackedStringArray = _batch_one_preflight_errors(
		manifest, current_assets, registry
	)
	if not errors.is_empty():
		return {
			"manifest": manifest.duplicate(true),
			"approved_item_ids": PackedStringArray(),
			"errors": errors
		}
	var updated_manifest: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = updated_manifest["assets"] as Dictionary
	var assets_by_id: Dictionary = _assets_by_id(current_assets)
	var authoring_keys_by_id: Dictionary = _authoring_keys_by_item_id(
		updated_manifest, current_assets
	)
	for item_id: String in BATCH_ONE_ITEM_IDS:
		var authoring_key: String = String(authoring_keys_by_id[item_id])
		var record: Dictionary = records[authoring_key] as Dictionary
		var role_review: Dictionary = record["stack_role_review"] as Dictionary
		if String(role_review["status"]) == "UNREVIEWED":
			role_review["status"] = "APPROVED"
			_copy_snapshot_into_review(
				role_review,
				AuthoringReviewManifestScript.stack_role_snapshot(
					assets_by_id[item_id] as Dictionary
				)
			)
			role_review["flags"] = []
			role_review["notes"] = String(BATCH_ONE_APPROVAL_NOTES.get(item_id, ""))
		records[authoring_key] = record
	return {
		"manifest": AuthoringReviewManifestScript.migrate_manifest(updated_manifest),
		"approved_item_ids": BATCH_ONE_ITEM_IDS.duplicate(),
		"errors": errors
	}


static func batch_two_reviewed_role(item_id: String) -> Array:
	return (BATCH_TWO_REVIEWED_ROLES.get(item_id, []) as Array).duplicate()


static func apply_stack_role_batch_2(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary
) -> Dictionary:
	var errors: PackedStringArray = _batch_two_preflight_errors(
		manifest, current_assets, registry
	)
	if not errors.is_empty():
		return {
			"manifest": manifest.duplicate(true),
			"approved_item_ids": PackedStringArray(),
			"errors": errors
		}
	var updated_manifest: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = updated_manifest["assets"] as Dictionary
	var assets_by_id: Dictionary = _assets_by_id(current_assets)
	var authoring_keys_by_id: Dictionary = _authoring_keys_by_item_id(
		updated_manifest, current_assets
	)
	for item_id: String in BATCH_TWO_ITEM_IDS:
		var authoring_key: String = String(authoring_keys_by_id[item_id])
		var record: Dictionary = records[authoring_key] as Dictionary
		var role_review: Dictionary = record["stack_role_review"] as Dictionary
		if String(role_review["status"]) == "UNREVIEWED":
			role_review["status"] = "APPROVED"
			_copy_snapshot_into_review(
				role_review,
				AuthoringReviewManifestScript.stack_role_snapshot(
					assets_by_id[item_id] as Dictionary
				)
			)
			role_review["flags"] = []
			role_review["notes"] = String(BATCH_TWO_APPROVAL_NOTES.get(item_id, ""))
		records[authoring_key] = record
	return {
		"manifest": AuthoringReviewManifestScript.migrate_manifest(updated_manifest),
		"approved_item_ids": BATCH_TWO_ITEM_IDS.duplicate(),
		"errors": errors
	}


static func batch_three_reviewed_role(item_id: String) -> Array:
	return (BATCH_THREE_REVIEWED_ROLES.get(item_id, []) as Array).duplicate()


static func apply_stack_role_batch_3(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary
) -> Dictionary:
	var errors: PackedStringArray = _batch_three_preflight_errors(manifest, current_assets, registry)
	if not errors.is_empty():
		return {"manifest": manifest.duplicate(true), "approved_item_ids": PackedStringArray(), "errors": errors}
	var updated_manifest: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = updated_manifest["assets"] as Dictionary
	var assets_by_id: Dictionary = _assets_by_id(current_assets)
	var authoring_keys_by_id: Dictionary = _authoring_keys_by_item_id(updated_manifest, current_assets)
	for item_id: String in BATCH_THREE_ITEM_IDS:
		var authoring_key: String = String(authoring_keys_by_id[item_id])
		var record: Dictionary = records[authoring_key] as Dictionary
		var role_review: Dictionary = record["stack_role_review"] as Dictionary
		if String(role_review["status"]) == "UNREVIEWED":
			role_review["status"] = "APPROVED"
			_copy_snapshot_into_review(role_review, AuthoringReviewManifestScript.stack_role_snapshot(assets_by_id[item_id] as Dictionary))
			role_review["flags"] = []
			role_review["notes"] = String(BATCH_THREE_APPROVAL_NOTES.get(item_id, ""))
		records[authoring_key] = record
	return {"manifest": AuthoringReviewManifestScript.migrate_manifest(updated_manifest), "approved_item_ids": BATCH_THREE_ITEM_IDS.duplicate(), "errors": errors}

static func batch_four_reviewed_role(item_id: String) -> Array:
	return (BATCH_FOUR_REVIEWED_ROLES.get(item_id, []) as Array).duplicate()

static func apply_stack_role_batch_4(manifest: Dictionary, current_assets: Array[Dictionary], registry: Dictionary) -> Dictionary:
	var errors: PackedStringArray = _batch_four_preflight_errors(manifest, current_assets, registry)
	if not errors.is_empty(): return {"manifest": manifest.duplicate(true), "approved_item_ids": PackedStringArray(), "errors": errors}
	var updated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = updated["assets"] as Dictionary
	var assets: Dictionary = _assets_by_id(current_assets)
	var keys: Dictionary = _authoring_keys_by_item_id(updated, current_assets)
	for item_id: String in BATCH_FOUR_ITEM_IDS:
		var record: Dictionary = records[String(keys[item_id])] as Dictionary
		var review: Dictionary = record["stack_role_review"] as Dictionary
		if String(review["status"]) == "UNREVIEWED":
			review["status"] = "APPROVED"
			_copy_snapshot_into_review(review, AuthoringReviewManifestScript.stack_role_snapshot(assets[item_id] as Dictionary))
			review["flags"] = []
			review["notes"] = String(BATCH_FOUR_APPROVAL_NOTES.get(item_id, ""))
		records[String(keys[item_id])] = record
	return {"manifest": AuthoringReviewManifestScript.migrate_manifest(updated), "approved_item_ids": BATCH_FOUR_ITEM_IDS.duplicate(), "errors": errors}

static func apply_stack_role_batch_5(manifest: Dictionary, current_assets: Array[Dictionary], registry: Dictionary) -> Dictionary:
	var updated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = updated["assets"] as Dictionary
	var assets: Dictionary = _assets_by_id(current_assets)
	var keys: Dictionary = _authoring_keys_by_item_id(updated, current_assets)
	var errors: PackedStringArray = []
	for item_id: String in BATCH_FIVE_ITEM_IDS:
		if not assets.has(item_id) or not keys.has(item_id): errors.append("Batch 5 record missing: %s" % item_id); continue
		var asset: Dictionary = assets[item_id] as Dictionary
		var role: Array = BATCH_FIVE_REVIEWED_ROLES[item_id] as Array
		if bool(asset["can_be_stacked"]) != bool(role[0]) or bool(asset["can_support_stack"]) != bool(role[1]): errors.append("Batch 5 runtime role mismatch: %s" % item_id)
		var record: Dictionary = records[String(keys[item_id])] as Dictionary
		if String((record["auto_group_review"] as Dictionary)["status"]) != "UNREVIEWED": errors.append("Batch 5 must not alter Auto Group: %s" % item_id)
	if not errors.is_empty(): return {"manifest": manifest.duplicate(true), "approved_item_ids": PackedStringArray(), "errors": errors}
	for item_id: String in BATCH_FIVE_ITEM_IDS:
		var record: Dictionary = records[String(keys[item_id])] as Dictionary
		var review: Dictionary = record["stack_role_review"] as Dictionary
		review["status"] = "APPROVED"
		_copy_snapshot_into_review(review, AuthoringReviewManifestScript.stack_role_snapshot(assets[item_id] as Dictionary))
		review["flags"] = []
		review["notes"] = String(BATCH_FIVE_APPROVAL_NOTES.get(item_id, ""))
		records[String(keys[item_id])] = record
	return {"manifest": AuthoringReviewManifestScript.migrate_manifest(updated), "approved_item_ids": BATCH_FIVE_ITEM_IDS.duplicate(), "errors": errors}


static func _preflight_errors(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary
) -> PackedStringArray:
	var errors: PackedStringArray = []
	errors.append_array(AutoStackGroupRegistryScript.validate_registry(registry))
	errors.append_array(AuthoringReviewManifestScript.validate_manifest(manifest))
	if not errors.is_empty():
		return errors
	var assets_by_id: Dictionary = _assets_by_id(current_assets)
	var expected_ids: PackedStringArray = []
	for number: int in range(1, 43):
		expected_ids.append("loot_%06d" % number)
	if _sorted_keys(assets_by_id) != expected_ids:
		errors.append("Phase 1 requires the exact 42-item prototype catalogue set.")
		return errors
	var migrated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	errors.append_array(AuthoringReviewManifestScript.validate_manifest(migrated))
	if not errors.is_empty():
		return errors
	var records: Dictionary = migrated["assets"] as Dictionary
	var authoring_keys_by_id: Dictionary = _authoring_keys_by_item_id(
		migrated, current_assets
	)
	for item_id: String in expected_ids:
		if not authoring_keys_by_id.has(item_id):
			errors.append("Phase 1 manifest record is missing: %s" % item_id)
			continue
		var asset: Dictionary = assets_by_id[item_id] as Dictionary
		var authoring_key: String = String(authoring_keys_by_id[item_id])
		var record: Dictionary = records[authoring_key] as Dictionary
		var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, asset, registry)
		if BLOCKED_ITEM_IDS.has(item_id):
			if bool(evidence["stack_role_review_eligible"]):
				errors.append("Phase 1 blocked item unexpectedly became eligible: %s" % item_id)
			continue
		if not bool(evidence["stack_role_review_eligible"]):
			errors.append("Phase 1 eligible item is dependency-blocked: %s" % item_id)
		if GRANDFATHERED.has(item_id):
			var expected: Array = GRANDFATHERED[item_id] as Array
			if bool(asset.get("can_be_stacked", false)) != bool(expected[0]) \
				or bool(asset.get("can_support_stack", false)) != bool(expected[1]) \
				or String(asset.get("auto_stack_group", "")) != String(expected[2]):
				errors.append("Grandfathered runtime evidence does not match: %s" % item_id)
			var role_status: String = String((record["stack_role_review"] as Dictionary)["status"])
			var auto_status: String = String((record["auto_group_review"] as Dictionary)["status"])
			if role_status == "APPROVED" and not bool(evidence["stack_role_review_current"]):
				errors.append("Refusing to rewrite stale Stack Role approval: %s" % item_id)
			if auto_status == "APPROVED" and not bool(evidence["auto_group_review_current"]):
				errors.append("Refusing to rewrite stale Auto Group approval: %s" % item_id)
		elif CANDIDATES.has(item_id):
			if String((record["stack_role_review"] as Dictionary)["status"]) != "UNREVIEWED":
				errors.append("Phase 1 candidate is already reviewed: %s" % item_id)
			if not String(asset.get("auto_stack_group", "")).is_empty():
				errors.append("Phase 1 candidate already has an Auto Group: %s" % item_id)
	return errors


static func _batch_one_preflight_errors(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary
) -> PackedStringArray:
	var errors: PackedStringArray = []
	errors.append_array(AutoStackGroupRegistryScript.validate_registry(registry))
	errors.append_array(AuthoringReviewManifestScript.validate_manifest(manifest))
	if not errors.is_empty():
		return errors
	var assets_by_id: Dictionary = _assets_by_id(current_assets)
	var expected_ids: PackedStringArray = []
	for number: int in range(1, 43):
		expected_ids.append("loot_%06d" % number)
	if _sorted_keys(assets_by_id) != expected_ids:
		errors.append("Batch 1 approval requires the exact 42-item prototype catalogue set.")
		return errors
	var migrated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = migrated["assets"] as Dictionary
	var authoring_keys_by_id: Dictionary = _authoring_keys_by_item_id(
		migrated, current_assets
	)
	for item_id: String in expected_ids:
		if not authoring_keys_by_id.has(item_id):
			errors.append("Batch 1 manifest record is missing: %s" % item_id)
	if not errors.is_empty():
		return errors
	for item_id: String in BATCH_ONE_ITEM_IDS:
		var asset: Dictionary = assets_by_id[item_id] as Dictionary
		var record: Dictionary = records[String(authoring_keys_by_id[item_id])] as Dictionary
		var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(
			record, asset, registry
		)
		if not bool(evidence["stack_role_review_eligible"]):
			errors.append("Batch 1 item is dependency-blocked: %s" % item_id)
		if bool(asset.get("can_be_stacked", false)) != bool(candidate_for(item_id)["can_be_stacked"]) \
			or bool(asset.get("can_support_stack", false)) != bool(candidate_for(item_id)["can_support_stack"]):
			errors.append("Batch 1 runtime role values do not match candidate: %s" % item_id)
		var role_status: String = String((record["stack_role_review"] as Dictionary)["status"])
		if role_status == "APPROVED" and not bool(evidence["stack_role_review_current"]):
			errors.append("Refusing to rewrite stale Batch 1 approval: %s" % item_id)
		elif role_status != "UNREVIEWED" and role_status != "APPROVED":
			errors.append("Batch 1 item has unsupported Stack Role status: %s" % item_id)
		if String((record["auto_group_review"] as Dictionary)["status"]) != "UNREVIEWED":
			errors.append("Batch 1 must not alter an Auto Group decision: %s" % item_id)
	for item_id: String in candidate_ids():
		if BATCH_ONE_ITEM_IDS.has(item_id):
			continue
		var candidate_record: Dictionary = records[String(authoring_keys_by_id[item_id])] as Dictionary
		if String((candidate_record["stack_role_review"] as Dictionary)["status"]) != "UNREVIEWED":
			errors.append("Batch 1 requires later candidates to remain unreviewed: %s" % item_id)
	return errors


static func _batch_two_preflight_errors(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary
) -> PackedStringArray:
	var errors: PackedStringArray = []
	errors.append_array(AutoStackGroupRegistryScript.validate_registry(registry))
	errors.append_array(AuthoringReviewManifestScript.validate_manifest(manifest))
	if not errors.is_empty():
		return errors
	var assets_by_id: Dictionary = _assets_by_id(current_assets)
	var expected_ids: PackedStringArray = []
	for number: int in range(1, 43):
		expected_ids.append("loot_%06d" % number)
	if _sorted_keys(assets_by_id) != expected_ids:
		errors.append("Batch 2 approval requires the exact 42-item prototype catalogue set.")
		return errors
	var migrated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = migrated["assets"] as Dictionary
	var authoring_keys_by_id: Dictionary = _authoring_keys_by_item_id(
		migrated, current_assets
	)
	for item_id: String in expected_ids:
		if not authoring_keys_by_id.has(item_id):
			errors.append("Batch 2 manifest record is missing: %s" % item_id)
	if not errors.is_empty():
		return errors
	for item_id: String in BATCH_ONE_ITEM_IDS:
		var batch_one_asset: Dictionary = assets_by_id[item_id] as Dictionary
		var batch_one_record: Dictionary = records[String(authoring_keys_by_id[item_id])] as Dictionary
		var batch_one_evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(
			batch_one_record, batch_one_asset, registry
		)
		if String((batch_one_record["stack_role_review"] as Dictionary)["status"]) != "APPROVED" \
			or not bool(batch_one_evidence["stack_role_review_current"]):
			errors.append("Batch 2 requires current Batch 1 approval: %s" % item_id)
	for item_id: String in BATCH_TWO_ITEM_IDS:
		var asset: Dictionary = assets_by_id[item_id] as Dictionary
		var record: Dictionary = records[String(authoring_keys_by_id[item_id])] as Dictionary
		var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, asset, registry)
		if not bool(evidence["stack_role_review_eligible"]):
			errors.append("Batch 2 item is dependency-blocked: %s" % item_id)
		var expected_role: Array = batch_two_reviewed_role(item_id)
		if bool(asset.get("can_be_stacked", false)) != bool(expected_role[0]) \
			or bool(asset.get("can_support_stack", false)) != bool(expected_role[1]):
			errors.append("Batch 2 runtime role values do not match human decision: %s" % item_id)
		var role_status: String = String((record["stack_role_review"] as Dictionary)["status"])
		if role_status == "APPROVED" and not bool(evidence["stack_role_review_current"]):
			errors.append("Refusing to rewrite stale Batch 2 approval: %s" % item_id)
		elif role_status != "UNREVIEWED" and role_status != "APPROVED":
			errors.append("Batch 2 item has unsupported Stack Role status: %s" % item_id)
		if String((record["auto_group_review"] as Dictionary)["status"]) != "UNREVIEWED":
			errors.append("Batch 2 must not alter an Auto Group decision: %s" % item_id)
	for item_id: String in candidate_ids():
		if BATCH_ONE_ITEM_IDS.has(item_id) or BATCH_TWO_ITEM_IDS.has(item_id):
			continue
		var candidate_record: Dictionary = records[String(authoring_keys_by_id[item_id])] as Dictionary
		if String((candidate_record["stack_role_review"] as Dictionary)["status"]) != "UNREVIEWED":
			errors.append("Batch 2 requires later candidates to remain unreviewed: %s" % item_id)
	return errors


static func _batch_three_preflight_errors(
	manifest: Dictionary,
	current_assets: Array[Dictionary],
	registry: Dictionary
) -> PackedStringArray:
	var errors: PackedStringArray = []
	errors.append_array(AutoStackGroupRegistryScript.validate_registry(registry))
	errors.append_array(AuthoringReviewManifestScript.validate_manifest(manifest))
	if not errors.is_empty():
		return errors
	var assets_by_id: Dictionary = _assets_by_id(current_assets)
	var expected_ids: PackedStringArray = []
	for number: int in range(1, 43):
		expected_ids.append("loot_%06d" % number)
	if _sorted_keys(assets_by_id) != expected_ids:
		errors.append("Batch 3 approval requires the exact 42-item prototype catalogue set.")
		return errors
	var migrated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = migrated["assets"] as Dictionary
	var authoring_keys_by_id: Dictionary = _authoring_keys_by_item_id(migrated, current_assets)
	for item_id: String in expected_ids:
		if not authoring_keys_by_id.has(item_id):
			errors.append("Batch 3 manifest record is missing: %s" % item_id)
	if not errors.is_empty():
		return errors
	for item_id: String in BATCH_TWO_ITEM_IDS:
		var prior_asset: Dictionary = assets_by_id[item_id] as Dictionary
		var prior_record: Dictionary = records[String(authoring_keys_by_id[item_id])] as Dictionary
		var prior_evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(prior_record, prior_asset, registry)
		if String((prior_record["stack_role_review"] as Dictionary)["status"]) != "APPROVED" or not bool(prior_evidence["stack_role_review_current"]):
			errors.append("Batch 3 requires current Batch 2 approval: %s" % item_id)
	for item_id: String in BATCH_THREE_ITEM_IDS:
		var asset: Dictionary = assets_by_id[item_id] as Dictionary
		var record: Dictionary = records[String(authoring_keys_by_id[item_id])] as Dictionary
		var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, asset, registry)
		if not bool(evidence["stack_role_review_eligible"]):
			errors.append("Batch 3 item is dependency-blocked: %s" % item_id)
		var expected_role: Array = batch_three_reviewed_role(item_id)
		if bool(asset.get("can_be_stacked", false)) != bool(expected_role[0]) or bool(asset.get("can_support_stack", false)) != bool(expected_role[1]):
			errors.append("Batch 3 runtime role values do not match human decision: %s" % item_id)
		var role_status: String = String((record["stack_role_review"] as Dictionary)["status"])
		if role_status == "APPROVED" and not bool(evidence["stack_role_review_current"]):
			errors.append("Refusing to rewrite stale Batch 3 approval: %s" % item_id)
		elif role_status != "UNREVIEWED" and role_status != "APPROVED":
			errors.append("Batch 3 item has unsupported Stack Role status: %s" % item_id)
		if String((record["auto_group_review"] as Dictionary)["status"]) != "UNREVIEWED":
			errors.append("Batch 3 must not alter an Auto Group decision: %s" % item_id)
	for item_id: String in candidate_ids():
		if BATCH_ONE_ITEM_IDS.has(item_id) or BATCH_TWO_ITEM_IDS.has(item_id) or BATCH_THREE_ITEM_IDS.has(item_id):
			continue
		var candidate_record: Dictionary = records[String(authoring_keys_by_id[item_id])] as Dictionary
		if String((candidate_record["stack_role_review"] as Dictionary)["status"]) != "UNREVIEWED":
			errors.append("Batch 3 requires later candidates to remain unreviewed: %s" % item_id)
	return errors

static func _batch_four_preflight_errors(manifest: Dictionary, current_assets: Array[Dictionary], registry: Dictionary) -> PackedStringArray:
	var errors: PackedStringArray = []
	errors.append_array(AutoStackGroupRegistryScript.validate_registry(registry))
	errors.append_array(AuthoringReviewManifestScript.validate_manifest(manifest))
	if not errors.is_empty(): return errors
	var assets: Dictionary = _assets_by_id(current_assets)
	var expected_ids: PackedStringArray = []
	for number: int in range(1, 43): expected_ids.append("loot_%06d" % number)
	if _sorted_keys(assets) != expected_ids:
		errors.append("Batch 4 approval requires the exact 42-item prototype catalogue set.")
		return errors
	var migrated: Dictionary = AuthoringReviewManifestScript.migrate_manifest(manifest)
	var records: Dictionary = migrated["assets"] as Dictionary
	var keys: Dictionary = _authoring_keys_by_item_id(migrated, current_assets)
	for item_id: String in BATCH_THREE_ITEM_IDS:
		var prior: Dictionary = records[String(keys[item_id])] as Dictionary
		if String((prior["stack_role_review"] as Dictionary)["status"]) != "APPROVED": errors.append("Batch 4 requires Batch 3 approval: %s" % item_id)
	for item_id: String in BATCH_FOUR_ITEM_IDS:
		var record: Dictionary = records[String(keys[item_id])] as Dictionary
		var evidence: Dictionary = AuthoringReviewManifestScript.review_evidence(record, assets[item_id] as Dictionary, registry)
		var role: Array = batch_four_reviewed_role(item_id)
		if not bool(evidence["stack_role_review_eligible"]): errors.append("Batch 4 item is dependency-blocked: %s" % item_id)
		if bool((assets[item_id] as Dictionary)["can_be_stacked"]) != bool(role[0]) or bool((assets[item_id] as Dictionary)["can_support_stack"]) != bool(role[1]): errors.append("Batch 4 runtime role values do not match human decision: %s" % item_id)
		if String((record["auto_group_review"] as Dictionary)["status"]) != "UNREVIEWED": errors.append("Batch 4 must not alter an Auto Group decision: %s" % item_id)
	for item_id: String in candidate_ids():
		if BATCH_ONE_ITEM_IDS.has(item_id) or BATCH_TWO_ITEM_IDS.has(item_id) or BATCH_THREE_ITEM_IDS.has(item_id) or BATCH_FOUR_ITEM_IDS.has(item_id): continue
		if String(((records[String(keys[item_id])] as Dictionary)["stack_role_review"] as Dictionary)["status"]) != "UNREVIEWED": errors.append("Batch 4 requires later candidates to remain unreviewed: %s" % item_id)
	return errors


static func _assets_by_id(current_assets: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {}
	for asset: Dictionary in current_assets:
		var item_id: String = String(asset.get("item_id", ""))
		if not item_id.is_empty() and not result.has(item_id):
			result[item_id] = asset
	return result


static func _authoring_keys_by_item_id(
	manifest: Dictionary, current_assets: Array[Dictionary]
) -> Dictionary:
	var result: Dictionary = {}
	for match: Dictionary in AuthoringReviewManifestScript.correlate_current_assets(
		manifest, current_assets
	):
		var authoring_key: String = String(match.get("authoring_key", ""))
		var asset: Dictionary = match.get("asset", {}) as Dictionary
		var item_id: String = String(asset.get("item_id", ""))
		if not authoring_key.is_empty() and not item_id.is_empty():
			result[item_id] = authoring_key
	return result


static func _copy_snapshot_into_review(review: Dictionary, snapshot: Dictionary) -> void:
	for key_value: Variant in snapshot.keys():
		review[key_value] = snapshot[key_value]


static func _sorted_keys(dictionary: Dictionary) -> PackedStringArray:
	var keys: PackedStringArray = []
	for key_value: Variant in dictionary.keys():
		keys.append(String(key_value))
	keys.sort()
	return keys
