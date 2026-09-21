extends SceneTree

const FIXTURE_PATH := "res://gameplay/dev/item_storage_pose/item_storage_pose_authoring.tscn"
const ASYMMETRIC_DEFINITION_PATH := "res://data/items/definitions/loot_000037.tres"
const ROUND_TRIP_PATH := "user://canonical_item_pose_authoring_round_trip.tscn"
const ItemDefinitionScript = preload("res://item_definition.gd")

var _failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _check(ResourceLoader.exists(FIXTURE_PATH), "authoring fixture exists"):
		_finish()
		return
	var packed := load(FIXTURE_PATH) as PackedScene
	if not _check(packed != null, "authoring fixture loads"):
		_finish()
		return
	var fixture := packed.instantiate() as Node3D
	root.add_child(fixture)
	_check_fixture_contract(fixture)
	_check_definition_preview(fixture)
	_check_packing_preview_isolation(fixture)
	await _check_external_definition_poll_refresh(fixture)
	_check_suggested_canonical_footprint(fixture)
	_check_symmetric_suggestion(fixture)
	fixture.free()
	if Engine.is_editor_hint():
		await _check_editor_round_trip(packed)
	_finish()


func _check_fixture_contract(fixture: Node3D) -> void:
	for path: NodePath in [
		^"ReferenceShelf",
		^"DirectionMarkers",
		^"DirectionMarkers/Front",
		^"DirectionMarkers/Back",
		^"DirectionMarkers/Left",
		^"DirectionMarkers/Right",
		^"FootprintPreview",
		^"ItemPreviewRoot",
	]:
		_check(fixture.get_node_or_null(path) != null, "fixture contains %s" % path)
	_check(fixture.has_method("refresh_preview"), "fixture exposes refresh_preview")
	_check(fixture.has_method("get_preview_contract"), "fixture exposes get_preview_contract")
	_check(
		fixture.has_method("apply_suggested_footprint"),
		"fixture exposes the explicit suggested-footprint apply action"
	)


func _check_definition_preview(fixture: Node3D) -> void:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.visual_scene = _packed_asymmetric_visual()
	definition.storage_rotation_degrees = Vector3(25.0, 40.0, -15.0)
	definition.storage_footprint = Vector3i(3, 2, 1)
	fixture.set("item_definition", definition)
	fixture.call("refresh_preview")

	var contract := fixture.call("get_preview_contract") as Dictionary
	_check(bool(contract.get("valid", false)), "definition preview is valid")
	_check(
		contract.get("canonical_front", Vector3.ZERO) == Vector3(0.0, 0.0, 1.0),
		"fixture canonical Front is +Z"
	)
	_check(
		contract.get("footprint", Vector2i.ZERO) == Vector2i(3, 2),
		"fixture shows canonical deterministic footprint"
	)
	_check(
		contract.get("storage_rotation_degrees", Vector3.ZERO)
		== Vector3(25.0, 40.0, -15.0),
		"fixture reports the ItemDefinition three-axis pose"
	)
	var pose_root := fixture.get_node_or_null(
		"ItemPreviewRoot/PackingYaw/StorageSeating/AuthoredStoragePose"
	) as Node3D
	_check(pose_root != null, "fixture uses the real StorageVisualPose hierarchy")
	if pose_root != null:
		var expected := Basis.from_euler(Vector3(
			deg_to_rad(25.0),
			deg_to_rad(40.0),
			deg_to_rad(-15.0)
		)).orthonormalized()
		_check(pose_root.basis.is_equal_approx(expected), "preview preserves pitch, yaw, and roll")


func _check_packing_preview_isolation(fixture: Node3D) -> void:
	var definition := fixture.get("item_definition") as ItemDefinition
	var authored_rotation := definition.storage_rotation_degrees
	var marker_transforms := {}
	var markers := fixture.get_node("DirectionMarkers")
	for child: Node in markers.get_children():
		marker_transforms[String(child.name)] = (child as Node3D).transform

	fixture.set("show_packing_rotated", true)
	fixture.call("refresh_preview")
	var contract := fixture.call("get_preview_contract") as Dictionary
	_check(
		definition.storage_rotation_degrees == authored_rotation,
		"packing preview does not mutate the ItemDefinition pose"
	)
	_check(
		contract.get("footprint", Vector2i.ZERO) == Vector2i(2, 3),
		"packing preview transposes only the displayed footprint"
	)
	var packing_root := fixture.get_node_or_null("ItemPreviewRoot/PackingYaw") as Node3D
	_check(packing_root != null, "packing preview root exists")
	if packing_root != null:
		_check(
			packing_root.basis.is_equal_approx(Basis(Vector3.UP, deg_to_rad(90.0))),
			"packing preview root adds +90 degrees"
		)
	for child: Node in markers.get_children():
		_check(
			(child as Node3D).transform == marker_transforms[String(child.name)],
			"%s marker remains fixed" % child.name
		)


func _check_external_definition_poll_refresh(fixture: Node3D) -> void:
	var definition := load(ASYMMETRIC_DEFINITION_PATH) as ItemDefinition
	if not _check(definition != null, "external definition loads for polling regression"):
		return
	var original_rotation := definition.storage_rotation_degrees
	var edited_rotation := Vector3(17.0, 90.0, -13.0)
	fixture.set("show_packing_rotated", false)
	fixture.set("item_definition", definition)
	fixture.call("refresh_preview")

	var original_reference := fixture.get("item_definition") as ItemDefinition
	_check(not definition.resource_path.is_empty(), "polling regression uses an external resource")
	definition.storage_rotation_degrees = edited_rotation
	await process_frame
	await process_frame
	var pose_root := fixture.get_node_or_null(
		"ItemPreviewRoot/PackingYaw/StorageSeating/AuthoredStoragePose"
	) as Node3D
	_check(
		fixture.get("item_definition") == original_reference,
		"external definition edit refresh keeps the assigned resource reference"
	)
	_check(pose_root != null, "external definition edit rebuilds the posed visual")
	if pose_root != null:
		var expected := Basis.from_euler(Vector3(
			deg_to_rad(edited_rotation.x),
			deg_to_rad(edited_rotation.y),
			deg_to_rad(edited_rotation.z)
		)).orthonormalized()
		_check(
			pose_root.basis.is_equal_approx(expected),
			"fingerprint polling refreshes an in-place X/Y/Z edit without rebinding"
		)
	definition.storage_rotation_degrees = original_rotation


func _check_suggested_canonical_footprint(fixture: Node3D) -> void:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.visual_scene = _packed_box_visual(Vector3(0.31, 0.4, 0.11))
	definition.storage_footprint = Vector3i(9, 8, 7)
	definition.storage_rotation_degrees = Vector3.ZERO
	fixture.set("show_packing_rotated", false)
	fixture.set("item_definition", definition)
	fixture.call("refresh_preview")
	var contract := fixture.call("get_preview_contract") as Dictionary
	_check(
		contract.get("authored_footprint", Vector2i.ZERO) == Vector2i(9, 8),
		"contract exposes the authored footprint"
	)
	_check(
		contract.get("suggested_canonical_footprint", Vector2i.ZERO) == Vector2i(4, 2),
		"31 cm by 11 cm canonical bounds suggest a 4 by 2 footprint"
	)
	_check(
		not bool(contract.get("suggestion_exceeds_authored", true)),
		"oversized authored footprint is not reported as exceeded"
	)
	_check(
		definition.storage_footprint == Vector3i(9, 8, 7),
		"suggestion calculation does not overwrite a manual authored footprint"
	)

	definition.storage_rotation_degrees = Vector3(0.0, 90.0, 0.0)
	fixture.call("refresh_preview")
	contract = fixture.call("get_preview_contract") as Dictionary
	_check(
		contract.get("suggested_canonical_footprint", Vector2i.ZERO) == Vector2i(2, 4),
		"90 degree canonical yaw swaps the asymmetric bounds suggestion"
	)
	_check(
		definition.storage_footprint == Vector3i(9, 8, 7),
		"canonical rotation changes never silently rewrite authored footprint"
	)

	fixture.set("show_packing_rotated", true)
	fixture.call("refresh_preview")
	contract = fixture.call("get_preview_contract") as Dictionary
	_check(
		contract.get("suggested_canonical_footprint", Vector2i.ZERO) == Vector2i(2, 4),
		"packing preview does not redefine the canonical suggestion"
	)
	_check(
		contract.get("packing_preview_footprint", Vector2i.ZERO) == Vector2i(8, 9),
		"packing preview footprint remains the transposed authored footprint"
	)

	definition.storage_footprint = Vector3i(1, 1, 7)
	fixture.call("refresh_preview")
	contract = fixture.call("get_preview_contract") as Dictionary
	_check(
		bool(contract.get("suggestion_exceeds_authored", false)),
		"suggestion reports when canonical bounds exceed authored cells"
	)
	var authored_rotation := definition.storage_rotation_degrees
	fixture.call("apply_suggested_footprint")
	_check(
		definition.storage_footprint == Vector3i(2, 4, 7),
		"apply action updates authored width and depth while preserving height"
	)
	_check(
		definition.storage_rotation_degrees == authored_rotation,
		"apply action leaves canonical storage rotation unchanged"
	)


func _check_symmetric_suggestion(fixture: Node3D) -> void:
	var definition: ItemDefinition = ItemDefinitionScript.new()
	definition.visual_scene = _packed_box_visual(Vector3(0.09, 0.2, 0.09))
	definition.storage_footprint = Vector3i(1, 1, 3)
	definition.storage_rotation_degrees = Vector3.ZERO
	fixture.set("show_packing_rotated", false)
	fixture.set("item_definition", definition)
	fixture.call("refresh_preview")
	var contract := fixture.call("get_preview_contract") as Dictionary
	_check(
		contract.get("suggested_canonical_footprint", Vector2i.ZERO) == Vector2i.ONE,
		"sub-cell symmetric visual suggests one by one"
	)
	definition.storage_rotation_degrees = Vector3(0.0, 90.0, 0.0)
	fixture.call("refresh_preview")
	contract = fixture.call("get_preview_contract") as Dictionary
	_check(
		contract.get("suggested_canonical_footprint", Vector2i.ZERO) == Vector2i.ONE,
		"symmetric one-by-one suggestion is unchanged by canonical yaw"
	)


func _check_editor_round_trip(packed: PackedScene) -> void:
	var source := load(ASYMMETRIC_DEFINITION_PATH) as ItemDefinition
	if not _check(source != null, "editor round trip loads an existing asymmetric definition"):
		return
	var source_rotation := source.storage_rotation_degrees
	var working := source.duplicate(true) as ItemDefinition
	working.storage_rotation_degrees = Vector3(19.0, 37.0, -23.0)
	var fixture := packed.instantiate() as Node3D
	root.add_child(fixture)
	fixture.set("item_definition", working)
	fixture.call("refresh_preview")
	var initial_contract := fixture.call("get_preview_contract") as Dictionary
	_check(bool(initial_contract.get("valid", false)), "existing asymmetric visual previews in editor")

	working.storage_rotation_degrees = Vector3(31.0, 58.0, -11.0)
	working.emit_changed()
	await process_frame
	var updated_contract := fixture.call("get_preview_contract") as Dictionary
	_check(
		updated_contract.get("storage_rotation_degrees", Vector3.ZERO)
		== Vector3(31.0, 58.0, -11.0),
		"editor resource changes refresh all three pose axes"
	)
	fixture.set("show_packing_rotated", true)
	await process_frame
	var packed_fixture := PackedScene.new()
	_check(packed_fixture.pack(fixture) == OK, "editor fixture packs for save/reopen")
	_check(
		ResourceSaver.save(packed_fixture, ROUND_TRIP_PATH) == OK,
		"editor fixture saves temporary round-trip scene"
	)
	fixture.free()

	var reopened_scene := ResourceLoader.load(
		ROUND_TRIP_PATH,
		"PackedScene",
		ResourceLoader.CACHE_MODE_IGNORE
	) as PackedScene
	_check(reopened_scene != null, "saved editor fixture reopens")
	if reopened_scene != null:
		var reopened := reopened_scene.instantiate() as Node3D
		root.add_child(reopened)
		reopened.call("refresh_preview")
		var reopened_contract := reopened.call("get_preview_contract") as Dictionary
		_check(bool(reopened_contract.get("valid", false)), "reopened fixture rebuilds preview")
		_check(
			reopened_contract.get("storage_rotation_degrees", Vector3.ZERO)
			== Vector3(31.0, 58.0, -11.0),
			"reopened fixture preserves the authored three-axis pose"
		)
		_check(
			bool(reopened_contract.get("packing_rotated", false)),
			"reopened fixture preserves preview-only packing toggle"
		)
		reopened.free()
	_check(
		source.storage_rotation_degrees == source_rotation,
		"editor round trip leaves the source ItemDefinition unchanged"
	)
	var round_trip_absolute := ProjectSettings.globalize_path(ROUND_TRIP_PATH)
	if FileAccess.file_exists(ROUND_TRIP_PATH):
		_check(
			DirAccess.remove_absolute(round_trip_absolute) == OK,
			"temporary editor round-trip scene is removed"
		)


func _packed_asymmetric_visual() -> PackedScene:
	return _packed_box_visual(Vector3(0.3, 0.5, 0.2), Vector3(0.1, 0.35, -0.05))


func _packed_box_visual(
	size: Vector3,
	mesh_position: Vector3 = Vector3.ZERO
) -> PackedScene:
	var visual := Node3D.new()
	visual.name = "AsymmetricVisual"
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Body"
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = mesh_position
	visual.add_child(mesh_instance)
	mesh_instance.owner = visual
	var packed := PackedScene.new()
	assert(packed.pack(visual) == OK)
	visual.free()
	return packed


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("ASSERTION FAILED: %s" % message)
	return false


func _finish() -> void:
	if _failed:
		push_error("FAIL: item storage pose authoring tests")
		quit(1)
		return
	print("PASS: item storage pose authoring tests")
	quit(0)
