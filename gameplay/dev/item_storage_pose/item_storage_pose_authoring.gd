@tool
extends Node3D

const StorageVisualPoseScript = preload("res://storage_visual_pose.gd")

const STORAGE_CELL_SIZE_M := 0.10
const FOOTPRINT_PAD_HEIGHT_M := 0.008

@export var item_definition: ItemDefinition:
	set(value):
		_disconnect_definition()
		item_definition = value
		_connect_definition()
		_request_refresh()

@export var show_packing_rotated := false:
	set(value):
		show_packing_rotated = value
		_request_refresh()

var _refresh_requested := false
var _refresh_deferred := false
var _preview_valid := false
var _preview_footprint := Vector2i.ONE


func _ready() -> void:
	_connect_definition()
	_request_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_disconnect_definition()


func refresh_preview() -> void:
	_refresh_requested = false
	var preview_root := get_node_or_null("ItemPreviewRoot") as Node3D
	if preview_root == null:
		_preview_valid = false
		return
	for child: Node in preview_root.get_children():
		preview_root.remove_child(child)
		child.free()

	_preview_valid = false
	_preview_footprint = _definition_footprint()
	if show_packing_rotated:
		_preview_footprint = Vector2i(
			_preview_footprint.y,
			_preview_footprint.x
		)
	_update_footprint_preview()

	if item_definition == null or item_definition.visual_scene == null:
		update_configuration_warnings()
		return

	var packing_root := Node3D.new()
	packing_root.name = "PackingYaw"
	preview_root.add_child(packing_root)
	var visual := item_definition.visual_scene.instantiate()
	_disable_embedded_nodes(visual)
	var result := StorageVisualPoseScript.build_visual(
		packing_root,
		visual,
		item_definition.storage_rotation_degrees,
		show_packing_rotated
	)
	_preview_valid = bool(result.get("valid", false))
	update_configuration_warnings()


func get_preview_contract() -> Dictionary:
	return {
		"valid": _preview_valid,
		"canonical_front": Vector3(0.0, 0.0, 1.0),
		"footprint": _preview_footprint,
		"storage_rotation_degrees": (
			item_definition.storage_rotation_degrees
			if item_definition != null
			else Vector3.ZERO
		),
		"packing_rotated": show_packing_rotated,
	}


func _definition_footprint() -> Vector2i:
	if item_definition == null:
		return Vector2i.ONE
	return Vector2i(
		maxi(1, item_definition.storage_footprint.x),
		maxi(1, item_definition.storage_footprint.y)
	)


func _update_footprint_preview() -> void:
	var footprint_preview := get_node_or_null("FootprintPreview") as MeshInstance3D
	if footprint_preview == null:
		return
	var mesh := BoxMesh.new()
	mesh.size = Vector3(
		float(_preview_footprint.x) * STORAGE_CELL_SIZE_M,
		FOOTPRINT_PAD_HEIGHT_M,
		float(_preview_footprint.y) * STORAGE_CELL_SIZE_M
	)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.18, 0.72, 0.95, 0.38)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = false
	mesh.material = material
	footprint_preview.mesh = mesh
	footprint_preview.position = Vector3(0.0, FOOTPRINT_PAD_HEIGHT_M * 0.5, 0.0)


func _connect_definition() -> void:
	if item_definition == null:
		return
	var callback := Callable(self, "_on_definition_changed")
	if not item_definition.changed.is_connected(callback):
		item_definition.changed.connect(callback)


func _disconnect_definition() -> void:
	if item_definition == null:
		return
	var callback := Callable(self, "_on_definition_changed")
	if item_definition.changed.is_connected(callback):
		item_definition.changed.disconnect(callback)


func _on_definition_changed() -> void:
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


func _disable_embedded_nodes(node: Node) -> void:
	if node is CollisionObject3D:
		var collision_object := node as CollisionObject3D
		collision_object.collision_layer = 0
		collision_object.collision_mask = 0
	if node is Camera3D:
		(node as Camera3D).current = false
	if node is Light3D:
		(node as Light3D).visible = false
	if node is WorldEnvironment:
		(node as WorldEnvironment).environment = null
	if node is GeometryInstance3D:
		(node as GeometryInstance3D).cast_shadow = (
			GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		)
	for child: Node in node.get_children():
		_disable_embedded_nodes(child)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if item_definition == null:
		warnings.append("Assign an ItemDefinition to preview its canonical stored pose.")
	elif item_definition.visual_scene == null:
		warnings.append("The assigned ItemDefinition has no visual_scene.")
	elif not _preview_valid:
		warnings.append("The assigned visual contains no measurable MeshInstance3D geometry.")
	return warnings
