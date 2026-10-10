extends RefCounted
# Test-only canonical composition guard. Plain grouping nodes and the exact EAF4
# instance-root helper are allowed; their generated Quad is the only mesh allowed.
const EXPERIMENT = preload("res://environment_authoring/wear/imperfection_experiments/imperfection_audition.gd")
const AUTHOR = preload("res://environment_authoring/wear/environment_wear_authoring.gd")

static func validate(branch: Node) -> PackedStringArray:
    var errors: PackedStringArray = []
    _visit(branch, branch, errors, AUTHOR)
    return errors

# This separate entry point is used only for WingGameplay/ImperfectionExperiments.
# It never broadens validate() / the approved AuthoredWear allowance.
static func validate_experiments(branch: Node) -> PackedStringArray:
    var errors: PackedStringArray = []
    _visit(branch, branch, errors, EXPERIMENT)
    return errors

static func _visit(node: Node, branch: Node, errors: PackedStringArray, helper: Script) -> void:
    var path := String(branch.get_path_to(node))
    if node.owner != branch.owner:
        errors.append(path + ": authored organization/placements must belong to the wing scene")
    if node.get_script() == helper:
        if node.get_class() != "Node3D":
            errors.append(path + ": helper root must be plain Node3D, never native gameplay/light/camera authority")
        if not node._get_configuration_warnings().is_empty() or (helper == AUTHOR and (node.spec == null or not node.spec.validate().is_empty())):
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
        _visit(child, branch, errors, helper)
