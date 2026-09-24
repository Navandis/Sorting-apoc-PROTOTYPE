@tool
extends Node3D

const StorageVisualPoseScript = preload("res://storage_visual_pose.gd")
const CELL_SIZE_M := 0.10
const GUIDE_THICKNESS_M := 0.006

@export var fixture_definition: ReceivingFreightFixtureDefinition:
	set(value):
		_disconnect_resource(fixture_definition)
		fixture_definition = value
		_connect_resource(fixture_definition)
		_request_refresh()

@export var preview_item_definition: ItemDefinition:
	set(value):
		_disconnect_resource(preview_item_definition)
		preview_item_definition = value
		_connect_resource(preview_item_definition)
		_request_refresh()

var _refresh_requested := false
var _refresh_deferred := false
var _fixture_valid := false
var _item_valid := false
var _last_authoring_fingerprint: Array = []


func _ready() -> void:
	_connect_resource(fixture_definition)
	_connect_resource(preview_item_definition)
	var camera := get_node_or_null("ReviewCamera") as Camera3D
	if camera != null:
		camera.look_at(Vector3(0.0, 0.28, 0.0), Vector3.UP)
	refresh_preview()


func _process(_delta: float) -> void:
	if _authoring_fingerprint() != _last_authoring_fingerprint:
		refresh_preview()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_disconnect_resource(fixture_definition)
		_disconnect_resource(preview_item_definition)


func refresh_preview() -> void:
	_refresh_requested = false
	_fixture_valid = false
	_item_valid = false
	_clear_children(get_node_or_null("FixtureVisualRoot"))
	_clear_children(get_node_or_null("ItemPreviewRoot"))
	_clear_children(get_node_or_null("Guides/BaseGrid"))
	_clear_guide_meshes()
	if fixture_definition == null:
		_update_debug_label()
		_finish_refresh()
		return

	_build_guides()
	_build_fixture_visual()
	_build_item_preview()
	_update_debug_label()
	_finish_refresh()


func get_preview_contract() -> Dictionary:
	return {
		"fixture_valid": _fixture_valid,
		"item_valid": _item_valid,
		"fixture_id": fixture_definition.fixture_id if fixture_definition != null else &"",
		"canonical_front": Vector3(0.0, 0.0, 1.0),
		"base_footprint": fixture_definition.base_footprint if fixture_definition != null else Vector2i.ZERO,
		"item_surface_transform": fixture_definition.item_surface_local_transform if fixture_definition != null else Transform3D.IDENTITY,
		"usable_size_m": Vector2(
			fixture_definition.item_surface_usable_width_m,
			fixture_definition.item_surface_usable_depth_m
		) if fixture_definition != null else Vector2.ZERO,
		"stack_clearance_m": fixture_definition.item_surface_stack_clearance_m if fixture_definition != null else 0.0,
	}


func _build_fixture_visual() -> void:
	var root := get_node_or_null("FixtureVisualRoot") as Node3D
	if root == null or fixture_definition.visual_scene == null:
		return
	var visual := fixture_definition.visual_scene.instantiate()
	if not visual is Node3D:
		visual.free()
		return
	root.transform = fixture_definition.visual_local_transform
	_disable_embedded_nodes(visual)
	root.add_child(visual)
	_fixture_valid = true


func _build_item_preview() -> void:
	var root := get_node_or_null("ItemPreviewRoot") as Node3D
	if root == null or preview_item_definition == null or preview_item_definition.visual_scene == null:
		return
	root.transform = fixture_definition.item_surface_local_transform
	var packing_root := Node3D.new()
	packing_root.name = "CanonicalStoredPose"
	root.add_child(packing_root)
	var visual := preview_item_definition.visual_scene.instantiate()
	_disable_embedded_nodes(visual)
	var result := StorageVisualPoseScript.build_visual(
		packing_root,
		visual,
		preview_item_definition.storage_rotation_degrees,
		false
	)
	_item_valid = bool(result.get("valid", false))


func _build_guides() -> void:
	var footprint_size := Vector2(
		float(fixture_definition.base_footprint.x) * CELL_SIZE_M,
		float(fixture_definition.base_footprint.y) * CELL_SIZE_M
	)
	_set_box_guide(
		get_node_or_null("Guides/BaseFootprint") as MeshInstance3D,
		Vector3(footprint_size.x, GUIDE_THICKNESS_M, footprint_size.y),
		Color(0.16, 0.66, 1.0, 0.20),
		Transform3D(Basis.IDENTITY, Vector3(0.0, GUIDE_THICKNESS_M * 0.5, 0.0))
	)
	_build_base_grid(footprint_size)

	var surface_transform := fixture_definition.item_surface_local_transform
	var usable_size := Vector2(
		fixture_definition.item_surface_usable_width_m,
		fixture_definition.item_surface_usable_depth_m
	)
	_set_box_guide(
		get_node_or_null("Guides/ItemSupportPlane") as MeshInstance3D,
		Vector3(usable_size.x, GUIDE_THICKNESS_M, usable_size.y),
		Color(0.18, 1.0, 0.45, 0.28),
		surface_transform
	)
	_set_box_guide(
		get_node_or_null("Guides/ItemUsableArea") as MeshInstance3D,
		Vector3(usable_size.x, GUIDE_THICKNESS_M, usable_size.y),
		Color(1.0, 0.78, 0.12, 0.20),
		surface_transform * Transform3D(Basis.IDENTITY, Vector3(0.0, GUIDE_THICKNESS_M * 1.5, 0.0))
	)
	var clearance := fixture_definition.item_surface_stack_clearance_m
	_set_box_guide(
		get_node_or_null("Guides/StackClearance") as MeshInstance3D,
		Vector3(usable_size.x, clearance, usable_size.y),
		Color(0.78, 0.32, 1.0, 0.08),
		surface_transform * Transform3D(Basis.IDENTITY, Vector3(0.0, clearance * 0.5, 0.0))
	)


func _build_base_grid(size_m: Vector2) -> void:
	var root := get_node_or_null("Guides/BaseGrid") as Node3D
	if root == null:
		return
	var columns := fixture_definition.base_footprint.x
	var rows := fixture_definition.base_footprint.y
	for column: int in range(columns + 1):
		var x := -size_m.x * 0.5 + float(column) * CELL_SIZE_M
		_add_grid_line(root, Vector3(GUIDE_THICKNESS_M, GUIDE_THICKNESS_M, size_m.y), Vector3(x, GUIDE_THICKNESS_M, 0.0))
	for row: int in range(rows + 1):
		var z := -size_m.y * 0.5 + float(row) * CELL_SIZE_M
		_add_grid_line(root, Vector3(size_m.x, GUIDE_THICKNESS_M, GUIDE_THICKNESS_M), Vector3(0.0, GUIDE_THICKNESS_M, z))


func _add_grid_line(root: Node3D, size: Vector3, position: Vector3) -> void:
	var line := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = _guide_material(Color(0.28, 0.78, 1.0, 0.70))
	line.mesh = mesh
	line.position = position
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(line)


func _set_box_guide(node: MeshInstance3D, size: Vector3, color: Color, transform_value: Transform3D) -> void:
	if node == null:
		return
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = _guide_material(color)
	node.mesh = mesh
	node.transform = transform_value
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _guide_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material


func _clear_guide_meshes() -> void:
	for path: NodePath in [
		NodePath("Guides/BaseFootprint"),
		NodePath("Guides/ItemSupportPlane"),
		NodePath("Guides/ItemUsableArea"),
		NodePath("Guides/StackClearance"),
	]:
		var mesh_node := get_node_or_null(path) as MeshInstance3D
		if mesh_node != null:
			mesh_node.mesh = null


func _clear_children(value: Node) -> void:
	if value == null:
		return
	for child: Node in value.get_children():
		value.remove_child(child)
		child.free()


func _disable_embedded_nodes(node: Node) -> void:
	if node is CollisionObject3D:
		(node as CollisionObject3D).collision_layer = 0
		(node as CollisionObject3D).collision_mask = 0
	if node is Camera3D:
		(node as Camera3D).current = false
	if node is Light3D:
		(node as Light3D).visible = false
	if node is WorldEnvironment:
		(node as WorldEnvironment).environment = null
	for child: Node in node.get_children():
		_disable_embedded_nodes(child)


func _update_debug_label() -> void:
	var label := get_node_or_null("HUD/DebugLabel") as Label
	if label == null:
		return
	if fixture_definition == null:
		label.text = "Assign a ReceivingFreightFixtureDefinition\nFRONT = +Z / apron    REAR = -Z / lift"
		return
	var item_text := "none"
	if preview_item_definition != null:
		item_text = "%s  footprint=%s" % [
			String(preview_item_definition.item_id),
			preview_item_definition.storage_footprint,
		]
	label.text = (
		"%s  family=%s  base=%s\nusable=%.3f x %.3f m  support_y=%.3f m  clearance=%.3f m\nitem=%s\nFRONT = +Z / apron    REAR = -Z / lift\nUNPROMOTED / HUMAN CALIBRATION PENDING"
		% [
			String(fixture_definition.fixture_id),
			"CRATE" if fixture_definition.family == ReceivingFreightFixtureDefinition.FixtureFamily.CRATE else "PALLET",
			fixture_definition.base_footprint,
			fixture_definition.item_surface_usable_width_m,
			fixture_definition.item_surface_usable_depth_m,
			fixture_definition.item_surface_local_transform.origin.y,
			fixture_definition.item_surface_stack_clearance_m,
			item_text,
		]
	)


func _authoring_fingerprint() -> Array:
	var fixture_values: Array = [0]
	if fixture_definition != null:
		fixture_values = [
			fixture_definition.get_instance_id(),
			fixture_definition.resource_path,
			fixture_definition.fixture_id,
			fixture_definition.family,
			fixture_definition.visual_scene,
			fixture_definition.visual_local_transform,
			fixture_definition.base_footprint,
			fixture_definition.item_surface_local_transform,
			fixture_definition.item_surface_usable_width_m,
			fixture_definition.item_surface_usable_depth_m,
			fixture_definition.item_surface_stack_clearance_m,
		]
	var item_values: Array = [0]
	if preview_item_definition != null:
		item_values = [
			preview_item_definition.get_instance_id(),
			preview_item_definition.resource_path,
			preview_item_definition.item_id,
			preview_item_definition.visual_scene,
			preview_item_definition.storage_rotation_degrees,
			preview_item_definition.storage_footprint,
		]
	return [fixture_values, item_values]


func _connect_resource(resource: Resource) -> void:
	if resource == null:
		return
	var callback := Callable(self, "_on_resource_changed")
	if not resource.changed.is_connected(callback):
		resource.changed.connect(callback)


func _disconnect_resource(resource: Resource) -> void:
	if resource == null:
		return
	var callback := Callable(self, "_on_resource_changed")
	if resource.changed.is_connected(callback):
		resource.changed.disconnect(callback)


func _on_resource_changed() -> void:
	_request_refresh()


func _request_refresh() -> void:
	_refresh_requested = true
	if not is_inside_tree() or _refresh_deferred:
		return
	_refresh_deferred = true
	call_deferred("_flush_refresh")


func _flush_refresh() -> void:
	_refresh_deferred = false
	if _refresh_requested and is_inside_tree():
		refresh_preview()


func _finish_refresh() -> void:
	_last_authoring_fingerprint = _authoring_fingerprint()
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if fixture_definition == null:
		warnings.append("Assign a ReceivingFreightFixtureDefinition for calibration.")
	elif not fixture_definition.validate().is_empty():
		warnings.append("The assigned fixture definition is structurally invalid.")
	elif not _fixture_valid:
		warnings.append("The assigned fixture visual could not be previewed.")
	if preview_item_definition == null:
		warnings.append("Assign an ItemDefinition to inspect its canonical stored pose.")
	elif not _item_valid:
		warnings.append("The assigned item visual could not be previewed.")
	return warnings
