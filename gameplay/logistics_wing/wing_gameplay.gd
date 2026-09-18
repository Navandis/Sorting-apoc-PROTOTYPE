extends Node3D

@export var development_setup_enabled: bool = true

var _composition_failures: Array[String] = []


func _enter_tree() -> void:
	var hud := get_node_or_null("HUD/CarriedItemsHUD")
	if hud != null:
		hud.set("carried_items_path", NodePath("../../Player/CarriedItems"))

	if not development_setup_enabled:
		_remove_development_setup()
		return

	var fixture_namespace := _get_fixture_namespace()
	var existing_owner := _find_fixture_namespace_owner(get_tree().root, fixture_namespace)
	if existing_owner != null:
		var failure := "duplicate active seed fixture namespace %s already owned by %s" % [
			fixture_namespace,
			existing_owner.get_path(),
		]
		_composition_failures.append(failure)
		development_setup_enabled = false
		_remove_development_setup()
		push_error("Wing gameplay composition rejected: %s" % failure)


func is_development_setup_active() -> bool:
	return get_node_or_null("DevelopmentSetup") != null


func get_functional_surfaces() -> Array[Node]:
	var fixtures := get_node_or_null("FunctionalFixtures")
	if fixtures == null or not fixtures.has_method("get_installed_surfaces"):
		return []
	return fixtures.call("get_installed_surfaces") as Array[Node]


func get_composition_failures() -> Array[String]:
	return _composition_failures.duplicate()


func _get_fixture_namespace() -> String:
	var registrar := get_node_or_null("DevelopmentSetup/SeedRegistrar")
	if registrar == null:
		return ""
	return String(registrar.get("fixture_namespace"))


func _find_fixture_namespace_owner(search_root: Node, fixture_namespace: String) -> Node:
	if fixture_namespace.is_empty():
		return null
	for child: Node in search_root.get_children():
		if child == self:
			continue
		if child.get_script() == get_script():
			var registrar := child.get_node_or_null("DevelopmentSetup/SeedRegistrar")
			if registrar != null and String(registrar.get("fixture_namespace")) == fixture_namespace:
				return child
		var nested_owner := _find_fixture_namespace_owner(child, fixture_namespace)
		if nested_owner != null:
			return nested_owner
	return null


func _remove_development_setup() -> void:
	var setup := get_node_or_null("DevelopmentSetup")
	if setup != null:
		remove_child(setup)
		setup.queue_free()
