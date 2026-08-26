extends SceneTree

const AuthoringReviewManifestScript = preload("res://tools/asset_pipeline/authoring_review_manifest.gd")
const CATALOG_PATH: String = "res://data/items/item_catalog.tres"
const MANIFEST_PATH: String = "res://tools/asset_pipeline/item_authoring_review.json"
const PANTS_ID: String = "loot_000036"
const PANTS_NOTE: String = "No acceptable current single-mesh ordinary-shelf pose; folded stored visual remains a future candidate."

const EXPECTED_CANDIDATES: Dictionary = {
	"loot_000002": Vector3(0.0, 90.0, 0.0),
	"loot_000003": Vector3(0.0, 90.0, 0.0),
	"loot_000004": Vector3(0.0, 90.0, 0.0),
	"loot_000019": Vector3(0.0, 130.0, 0.0),
	"loot_000020": Vector3(0.0, 90.0, 0.0),
	"loot_000021": Vector3(0.0, 90.0, 0.0),
	"loot_000024": Vector3(0.0, 90.0, 0.0),
	"loot_000027": Vector3(0.0, -120.0, 0.0),
	"loot_000034": Vector3(-90.0, 0.0, 0.0),
	"loot_000038": Vector3(0.0, 0.0, 90.0),
	"loot_000039": Vector3(-90.0, 0.0, 0.0),
	"loot_000040": Vector3(0.0, 0.0, 90.0),
	"loot_000041": Vector3(0.0, 0.0, 180.0)
}

const EXPECTED_FOOTPRINTS: Dictionary = {
	"loot_000001": Vector3i(1, 2, 1), "loot_000002": Vector3i(3, 5, 1),
	"loot_000003": Vector3i(5, 3, 1), "loot_000004": Vector3i(4, 3, 1),
	"loot_000005": Vector3i(2, 1, 1), "loot_000006": Vector3i(3, 2, 1),
	"loot_000007": Vector3i(3, 1, 1), "loot_000008": Vector3i(1, 1, 1),
	"loot_000009": Vector3i(1, 1, 1), "loot_000010": Vector3i(1, 1, 1),
	"loot_000011": Vector3i(10, 6, 1), "loot_000012": Vector3i(3, 3, 1),
	"loot_000013": Vector3i(2, 5, 1), "loot_000014": Vector3i(7, 5, 1),
	"loot_000015": Vector3i(4, 2, 1), "loot_000016": Vector3i(4, 2, 1),
	"loot_000017": Vector3i(4, 4, 1), "loot_000018": Vector3i(3, 3, 1),
	"loot_000019": Vector3i(1, 1, 1), "loot_000020": Vector3i(1, 1, 1),
	"loot_000021": Vector3i(1, 1, 1), "loot_000022": Vector3i(1, 1, 1),
	"loot_000023": Vector3i(1, 1, 1), "loot_000024": Vector3i(1, 1, 1),
	"loot_000025": Vector3i(1, 1, 1), "loot_000026": Vector3i(2, 2, 1),
	"loot_000027": Vector3i(1, 1, 1), "loot_000028": Vector3i(5, 4, 1),
	"loot_000029": Vector3i(2, 2, 1), "loot_000030": Vector3i(3, 2, 1),
	"loot_000031": Vector3i(2, 2, 1), "loot_000032": Vector3i(4, 3, 1),
	"loot_000033": Vector3i(3, 3, 1), "loot_000034": Vector3i(3, 2, 1),
	"loot_000035": Vector3i(3, 3, 1), "loot_000036": Vector3i(4, 2, 1),
	"loot_000037": Vector3i(4, 1, 1), "loot_000038": Vector3i(1, 12, 1),
	"loot_000039": Vector3i(3, 1, 1), "loot_000040": Vector3i(1, 11, 1),
	"loot_000041": Vector3i(1, 1, 1), "loot_000042": Vector3i(3, 6, 1)
}


func _init() -> void:
	var catalogue: Resource = load(CATALOG_PATH)
	assert(catalogue != null)
	var definitions: Array = catalogue.get("definitions") as Array
	assert(definitions.size() == 42)
	var by_id: Dictionary = {}
	for value: Variant in definitions:
		var definition: ItemDefinition = value as ItemDefinition
		by_id[String(definition.item_id)] = definition

	_test_candidate_rotations_and_unchanged_footprints(by_id)
	_test_review_manifest_decisions(by_id)
	print("PASS: storage pose content tests")
	quit(0)


# Catches candidate edits leaking into Footprint authoring or missing a reviewed pose.
func _test_candidate_rotations_and_unchanged_footprints(by_id: Dictionary) -> void:
	assert(by_id.size() == EXPECTED_FOOTPRINTS.size())
	for item_id_value: Variant in EXPECTED_FOOTPRINTS.keys():
		var item_id: String = String(item_id_value)
		var definition: ItemDefinition = by_id[item_id] as ItemDefinition
		var expected_footprint: Vector3i = EXPECTED_FOOTPRINTS[item_id]
		assert(definition.storage_footprint == expected_footprint)
		var expected_rotation: Vector3 = EXPECTED_CANDIDATES.get(item_id, Vector3.ZERO)
		assert(definition.storage_rotation_degrees.is_equal_approx(expected_rotation))
	assert((by_id[PANTS_ID] as ItemDefinition).storage_rotation_degrees == Vector3.ZERO)


# Catches candidate values being recorded as approved snapshots or unresolved
# Pants accidentally becoming eligible for Footprint approval.
func _test_review_manifest_decisions(by_id: Dictionary) -> void:
	var manifest: Dictionary = AuthoringReviewManifestScript.load_manifest(MANIFEST_PATH)
	var records: Dictionary = manifest["assets"] as Dictionary
	assert(records.size() == 42)
	var default_count: int = 0
	var custom_required_count: int = 0
	for key_value: Variant in records.keys():
		var key: String = String(key_value)
		var record: Dictionary = records[key] as Dictionary
		var item_id: String = String(record["item_id"])
		assert(by_id.has(item_id))
		var pose_review: Dictionary = record["storage_pose_review"] as Dictionary
		var footprint_review: Dictionary = record["footprint_review"] as Dictionary
		assert(String(footprint_review["status"]) == "UNREVIEWED")
		if EXPECTED_CANDIDATES.has(item_id) or item_id == PANTS_ID:
			custom_required_count += 1
			assert(String(pose_review["status"]) == "CUSTOM_POSE_REQUIRED")
			assert(String(pose_review["reviewed_source_fingerprint"]) == String(record["source_fingerprint"]))
			assert(pose_review["reviewed_rotation_degrees"] as Array == [0.0, 0.0, 0.0])
			if item_id == PANTS_ID:
				assert(String(pose_review["notes"]) == PANTS_NOTE)
		else:
			default_count += 1
			assert(String(pose_review["status"]) == "DEFAULT_POSE_APPROVED")
			assert(String(pose_review["reviewed_source_fingerprint"]) == String(record["source_fingerprint"]))
			assert(pose_review["reviewed_rotation_degrees"] as Array == [0.0, 0.0, 0.0])
	assert(default_count == 28)
	assert(custom_required_count == 14)
