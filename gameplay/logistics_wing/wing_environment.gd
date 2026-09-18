@tool
extends Node3D

const PROXY_NAMES: Array[String] = [
	"GalleryA_West",
	"GalleryB_North",
	"GalleryC_West",
]

var _proxy_suppression_failures: Array[String] = []


func _ready() -> void:
	_proxy_suppression_failures.clear()
	for proxy_name: String in PROXY_NAMES:
		var mesh := get_node_or_null(
			"Greybox/Proxies/%s/Mesh" % proxy_name
		) as MeshInstance3D
		var shape := get_node_or_null(
			"Greybox/Proxies/%s/StaticBody3D/CollisionShape3D" % proxy_name
		) as CollisionShape3D
		if mesh == null or shape == null:
			_proxy_suppression_failures.append(proxy_name)
			push_error(
				"WingEnvironment proxy substitution is incomplete: %s" % proxy_name
			)
			continue
		mesh.visible = false
		shape.disabled = true


func get_proxy_suppression_failures() -> Array[String]:
	return _proxy_suppression_failures.duplicate()
