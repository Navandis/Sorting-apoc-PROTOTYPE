extends SceneTree

const ITEM_CATALOG = preload("res://data/items/item_catalog.tres")
const PROOF_PROFILE = preload("res://data/receiving/receiving_deck_stage_b_proof.tres")
const DeckProfileScript = preload("res://receiving/receiving_deck_profile.gd")
const DeckSurfaceSpecScript = preload("res://receiving/receiving_deck_surface_spec.gd")

const DEFINITION_SCRIPT_PATH := "res://receiving/receiving_freight_fixture_definition.gd"
const SOCKET_SCRIPT_PATH := "res://receiving/receiving_freight_fixture_socket.gd"
const POLICY_SCRIPT_PATH := "res://receiving/receiving_freight_fixture_policy.gd"
const CALIBRATION_SCENE_PATH := "res://gameplay/logistics_wing/receiving/review/receiving_freight_fixture_calibration.tscn"

const FIXTURE_CASES: Array[Dictionary] = [
	{"path": "res://data/receiving/freight_fixtures/crate_plastic_01.tres", "id": &"crate_plastic_01", "family": 0},
	{"path": "res://data/receiving/freight_fixtures/crate_plastic_06.tres", "id": &"crate_plastic_06", "family": 0},
	{"path": "res://data/receiving/freight_fixtures/crate_palletcart_box.tres", "id": &"crate_palletcart_box", "family": 0},
	{"path": "res://data/receiving/freight_fixtures/crate_wood_01.tres", "id": &"crate_wood_01", "family": 0},
	{"path": "res://data/receiving/freight_fixtures/crate_wood_02.tres", "id": &"crate_wood_02", "family": 0},
	{"path": "res://data/receiving/freight_fixtures/pallet_01.tres", "id": &"pallet_01", "family": 1},
	{"path": "res://data/receiving/freight_fixtures/pallet_wood_03.tres", "id": &"pallet_wood_03", "family": 1},
	{"path": "res://data/receiving/freight_fixtures/pallet_industrial_worn_07.tres", "id": &"pallet_industrial_worn_07", "family": 1},
]

var _failures := 0
var _pending_helpers := 0


func _init() -> void:
	_run_suite()
	_check(_pending_helpers == 0, "%d test or fixture helpers did not complete" % _pending_helpers)
	if _failures > 0:
		print("FAIL: receiving freight fixture policy tests (%d failures)" % _failures)
		quit(1)
		return
	print("PASS: receiving freight fixture policy tests")
	quit(0)


func _run_suite() -> void:
	_pending_helpers += 1
	_test_size_bands_and_count_limits()
	_test_exact_crate_blacklist_and_small_eligibility()
	_test_definition_and_socket_validation_contracts()
	_test_all_fixture_resources_load_and_validate()
	_test_profile_rejects_wrong_types_and_duplicate_ids()
	_test_profile_backward_compatibility_and_proof_authoring()
	_test_calibration_scene_previews_fixture_and_item()
	_pending_helpers -= 1


# Catches either footprint axis being ignored or a threshold moving away from 2/3/4.
func _test_size_bands_and_count_limits() -> void:
	_pending_helpers += 1
	var policy: Script = _load_script(POLICY_SCRIPT_PATH)
	if policy == null:
		_pending_helpers -= 1
		return
	_check(int(policy.get("MAX_CRATES")) == 3, "Receiving crate maximum remains three")
	_check(int(policy.get("MAX_PALLETS")) == 2, "Receiving pallet maximum remains two")
	var cases: Array[Dictionary] = [
		{"footprint": Vector2i(1, 1), "want": 0},
		{"footprint": Vector2i(1, 2), "want": 0},
		{"footprint": Vector2i(2, 2), "want": 0},
		{"footprint": Vector2i(3, 1), "want": 1},
		{"footprint": Vector2i(3, 3), "want": 1},
		{"footprint": Vector2i(4, 1), "want": 2},
		{"footprint": Vector2i(4, 2), "want": 2},
		{"footprint": Vector2i(6, 4), "want": 2},
		{"footprint": Vector2i(10, 5), "want": 2},
		{"footprint": Vector2i(12, 3), "want": 2},
	]
	for case: Dictionary in cases:
		var definition := ItemDefinition.new()
		var footprint := case["footprint"] as Vector2i
		definition.storage_footprint = Vector3i(footprint.x, footprint.y, 1)
		_check(
			int(policy.call("size_band", definition)) == int(case["want"]),
			"%dx%d maps to size band %d" % [footprint.x, footprint.y, int(case["want"])]
		)
		_check(
			int(policy.call("footprint_area", definition)) == footprint.x * footprint.y,
			"%dx%d reports literal footprint area" % [footprint.x, footprint.y]
		)
	_pending_helpers -= 1


# Catches the Receiving-only exception list drifting or broadening into all Small items.
func _test_exact_crate_blacklist_and_small_eligibility() -> void:
	_pending_helpers += 1
	var policy: Script = _load_script(POLICY_SCRIPT_PATH)
	if policy == null:
		_pending_helpers -= 1
		return
	for item_id: StringName in [&"loot_000001", &"loot_000025", &"loot_000030"]:
		var definition: ItemDefinition = ITEM_CATALOG.get_definition_by_id(item_id)
		_check(definition != null, "%s resolves from the current catalogue" % String(item_id))
		if definition != null:
			_check(not bool(policy.call("is_crate_eligible", definition)), "%s is crate-ineligible" % String(item_id))
	var eligible: ItemDefinition = ITEM_CATALOG.get_definition_by_id(&"loot_000022")
	_check(eligible != null, "eligible Small control item resolves")
	if eligible != null:
		_check(bool(policy.call("is_crate_eligible", eligible)), "non-blacklisted Small item is crate-eligible")
	_pending_helpers -= 1


# Catches invalid resources being accepted before later runtime code can trust them.
func _test_definition_and_socket_validation_contracts() -> void:
	_pending_helpers += 1
	var definition_script: Script = _load_script(DEFINITION_SCRIPT_PATH)
	var socket_script: Script = _load_script(SOCKET_SCRIPT_PATH)
	if definition_script == null or socket_script == null:
		_pending_helpers -= 1
		return
	var visual := load("res://assets/environment/dressing/containers/SM_PlasticBox_01.glb") as PackedScene
	var definition: Resource = definition_script.new()
	_check(not (definition.call("validate") as PackedStringArray).is_empty(), "default fixture definition is invalid")
	definition.set("fixture_id", &"test_fixture")
	definition.set("visual_scene", visual)
	definition.set("base_footprint", Vector2i(2, 3))
	definition.set("item_surface_usable_width_m", 0.2)
	definition.set("item_surface_usable_depth_m", 0.3)
	definition.set("item_surface_stack_clearance_m", 0.4)
	_check((definition.call("validate") as PackedStringArray).is_empty(), "complete fixture definition validates")
	definition.set("base_footprint", Vector2i(0, 3))
	_check(not (definition.call("validate") as PackedStringArray).is_empty(), "zero fixture footprint is rejected")
	definition.set("base_footprint", Vector2i(2, 3))
	definition.set("visual_local_transform", Transform3D(Basis.IDENTITY, Vector3(NAN, 0.0, 0.0)))
	_check(not (definition.call("validate") as PackedStringArray).is_empty(), "non-finite fixture transform is rejected")

	var socket: Resource = socket_script.new()
	_check(not (socket.call("validate") as PackedStringArray).is_empty(), "default fixture socket is invalid")
	socket.set("socket_id", &"test_socket")
	socket.set("main_deck_origin", Vector2i(1, 2))
	socket.set("quarter_turns", 3)
	_check((socket.call("validate") as PackedStringArray).is_empty(), "complete fixture socket validates")
	socket.set("main_deck_origin", Vector2i(-1, 2))
	_check(not (socket.call("validate") as PackedStringArray).is_empty(), "negative socket origin is rejected")
	socket.set("main_deck_origin", Vector2i(1, 2))
	socket.set("quarter_turns", 4)
	_check(not (socket.call("validate") as PackedStringArray).is_empty(), "unnormalized socket quarter turn is rejected")
	_pending_helpers -= 1


# Catches a missing/wrong asset binding, family, duplicate ID, or unusable provisional calibration.
func _test_all_fixture_resources_load_and_validate() -> void:
	_pending_helpers += 1
	var definition_script: Script = _load_script(DEFINITION_SCRIPT_PATH)
	if definition_script == null:
		_pending_helpers -= 1
		return
	var seen_ids: Dictionary = {}
	for fixture_case: Dictionary in FIXTURE_CASES:
		var path := String(fixture_case["path"])
		var fixture := load(path) as Resource
		_check(fixture != null, "%s loads" % path)
		if fixture == null:
			continue
		_check(fixture.get_script() == definition_script, "%s uses ReceivingFreightFixtureDefinition" % path)
		var fixture_id := fixture.get("fixture_id") as StringName
		_check(fixture_id == fixture_case["id"], "%s has expected fixture ID" % path)
		_check(not seen_ids.has(fixture_id), "%s is unique" % String(fixture_id))
		seen_ids[fixture_id] = true
		_check(int(fixture.get("family")) == int(fixture_case["family"]), "%s has expected family" % path)
		var visual := fixture.get("visual_scene") as PackedScene
		_check(visual != null, "%s resolves its local visual scene" % path)
		if visual != null:
			var instance := visual.instantiate()
			_check(instance is Node3D, "%s visual instantiates as Node3D" % path)
			instance.free()
		_check((fixture.call("validate") as PackedStringArray).is_empty(), "%s validates" % path)
	_check(seen_ids.size() == 8, "all eight fixture IDs are represented once")
	_pending_helpers -= 1


# Catches profile validation accepting ambiguous authoring IDs or unrelated resources.
func _test_profile_rejects_wrong_types_and_duplicate_ids() -> void:
	_pending_helpers += 1
	var definition_script: Script = _load_script(DEFINITION_SCRIPT_PATH)
	var socket_script: Script = _load_script(SOCKET_SCRIPT_PATH)
	if definition_script == null or socket_script == null:
		_pending_helpers -= 1
		return
	var profile := DeckProfileScript.new()
	profile.profile_id = &"profile_validation"
	var surface := DeckSurfaceSpecScript.new()
	surface.surface_id = &"Deck"
	profile.surfaces = [surface]

	var definition: Resource = load(String(FIXTURE_CASES[0]["path"]))
	profile.freight_fixture_definitions = [definition, definition]
	_check(not profile.validate().is_empty(), "duplicate fixture IDs are rejected")
	profile.freight_fixture_definitions = [surface]
	_check(not profile.validate().is_empty(), "non-fixture definition resources are rejected")
	profile.freight_fixture_definitions = []

	var socket: Resource = socket_script.new()
	socket.set("socket_id", &"duplicate_socket")
	profile.freight_fixture_sockets = [socket, socket]
	_check(not profile.validate().is_empty(), "duplicate socket IDs are rejected")
	profile.freight_fixture_sockets = [surface]
	_check(not profile.validate().is_empty(), "non-socket resources are rejected")
	_pending_helpers -= 1


# Catches fixture authoring becoming mandatory or the proof profile losing its reviewed references.
func _test_profile_backward_compatibility_and_proof_authoring() -> void:
	_pending_helpers += 1
	var profile := DeckProfileScript.new()
	profile.profile_id = &"historical_bare_profile"
	var surface := DeckSurfaceSpecScript.new()
	surface.surface_id = &"BareDeck"
	profile.surfaces = [surface]
	_check(profile.validate().is_empty(), "historical profile with no fixture arrays remains valid")
	if not _has_property(PROOF_PROFILE, &"freight_fixture_definitions") or not _has_property(PROOF_PROFILE, &"freight_fixture_sockets"):
		_check(false, "proof profile exposes fixture definitions and sockets")
		_pending_helpers -= 1
		return
	_check(PROOF_PROFILE.validate().is_empty(), "proof profile with fixture authoring validates")
	var definitions := PROOF_PROFILE.get("freight_fixture_definitions") as Array[Resource]
	var sockets := PROOF_PROFILE.get("freight_fixture_sockets") as Array[Resource]
	_check(definitions.size() == 8, "proof profile references all eight fixture definitions")
	_check(sockets.size() >= 5 and sockets.size() <= 8, "proof profile keeps a small purposeful socket set")
	var family_counts := [0, 0]
	for socket: Resource in sockets:
		if socket == null:
			continue
		var family := int(socket.get("allowed_family"))
		if family >= 0 and family < family_counts.size():
			family_counts[family] += 1
		var origin := socket.get("main_deck_origin") as Vector2i
		_check(origin.x >= 0 and origin.y >= 0 and origin.x < 30 and origin.y < 20, "%s origin lies in the 30x20 MainDeck grid" % String(socket.get("socket_id")))
	_check(family_counts[0] >= 3, "proof profile provides at least three crate candidates")
	_check(family_counts[1] >= 2, "proof profile provides at least two pallet candidates")
	_pending_helpers -= 1


# Catches the retained authoring scene failing to materialize the calibrated fixture or canonical item pose.
func _test_calibration_scene_previews_fixture_and_item() -> void:
	_pending_helpers += 1
	if not ResourceLoader.exists(CALIBRATION_SCENE_PATH):
		_check(false, "calibration scene exists")
		_pending_helpers -= 1
		return
	var scene := load(CALIBRATION_SCENE_PATH) as PackedScene
	_check(scene != null, "calibration scene loads")
	if scene == null:
		_pending_helpers -= 1
		return
	var fixture := scene.instantiate() as Node3D
	_check(fixture != null, "calibration scene instantiates as Node3D")
	if fixture != null:
		fixture.set("fixture_definition", load(String(FIXTURE_CASES[0]["path"])))
		fixture.set("preview_item_definition", ITEM_CATALOG.get_definition_by_id(&"loot_000022"))
		fixture.call("refresh_preview")
		var contract := fixture.call("get_preview_contract") as Dictionary
		_check(bool(contract.get("fixture_valid", false)), "calibration scene previews fixture visual")
		_check(bool(contract.get("item_valid", false)), "calibration scene previews canonical stored item pose")
		_check(contract.get("canonical_front", Vector3.ZERO) == Vector3(0.0, 0.0, 1.0), "calibration scene keeps Receiving FRONT at +Z")
		_check(contract.get("fixture_id", &"") == &"crate_plastic_01", "calibration scene reports fixture identity")
		_check(fixture.get_node_or_null("Guides/BaseFootprint") != null, "calibration scene retains base footprint guide")
		_check(fixture.get_node_or_null("Guides/ItemUsableArea") != null, "calibration scene retains item usable-area guide")
		_check(fixture.get_node_or_null("Guides/StackClearance") != null, "calibration scene retains stack-clearance guide")
		fixture.free()
	_pending_helpers -= 1


func _load_script(path: String) -> Script:
	if not ResourceLoader.exists(path):
		_check(false, "%s exists" % path)
		return null
	var script := load(path) as Script
	_check(script != null, "%s loads as a script" % path)
	return script


func _has_property(object: Object, property_name: StringName) -> bool:
	for property: Dictionary in object.get_property_list():
		if property.get("name", &"") == property_name:
			return true
	return false


func _check(condition: bool, message: String) -> void:
	_pending_helpers += 1
	if not condition:
		_failures += 1
		push_error("FAIL: %s" % message)
	_pending_helpers -= 1
