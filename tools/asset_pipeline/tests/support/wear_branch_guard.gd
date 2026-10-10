extends RefCounted
# Test-only canonical composition guard. Plain grouping nodes and the exact EAF4
# instance-root helper are allowed; their generated Quad is the only mesh allowed.
const AUTHOR = preload("res://environment_authoring/wear/environment_wear_authoring.gd")

static func validate(branch: Node) -> PackedStringArray:
    var errors: PackedStringArray = []
    _visit(branch, branch, errors)
    return errors

static func _visit(node: Node, branch: Node, errors: PackedStringArray) -> void:
    var path := String(branch.get_path_to(node))
    if node.owner != branch.owner:
        errors.append(path + ": authored organization/placements must belong to the wing scene")
    if node.get_script() == AUTHOR:
        if not node is EnvironmentWearAuthoring or not node._get_configuration_warnings().is_empty() or node.spec == null or not node.spec.validate().is_empty():
            errors.append(path + ": invalid approved wear source/settings")
        if node.get_child_count() != 1:
            errors.append(path + ": helper must have exactly one generated Quad")
        for child in node.get_children():
            if child.get_class() != "MeshInstance3D" or child.name != "Quad" or child.get_script() != null or child.owner != null or child.get_child_count() != 0:
                errors.append(path + ": only the unscripted, ownerless generated Quad is allowed")
        return
    if node.get_class() != "Node3D" or node.get_script() != null:
        errors.append(path + ": only plain Node3D groups and the exact EAF4 authoring helper are allowed")
    for child in node.get_children():
        _visit(child, branch, errors)
